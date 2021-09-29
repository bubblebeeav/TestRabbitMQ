unit Logger;

interface

uses
  SysUtils,
  SQLiteWrap;

type
  TLogWriter = class
  private
    database: TSqliteDatabase;
  public
    constructor Create(databasename : string);
    procedure Write(logDate:TDateTime; message: string);
  end;

implementation

constructor TLogWriter.Create(databasename : string);
begin
  database := TSqliteDatabase.Create(databasename);
  database.ExecSQL
    ('CREATE TABLE IF NOT EXISTS LOGS(ID INTEGER NOT NULL PRIMARY KEY, DT TEXT NOT NULL, MSG TEXT)');
  database.SetTimeout(1000);
end;

procedure TLogWriter.Write(logDate:TDateTime; message: string);
begin
  database.Start('', 'TRANSACTION');
  database.AddParamText(':dt', FormatDateTime('yyyy-mm-dd"T"hh:nn:ss.zzz', logDate));
  database.AddParamText(':msg', message);
  database.ExecSQL('INSERT INTO LOGS(DT,MSG) VALUES(:dt,:msg)');
  database.Commit('');
  Writeln(Format('%s - %s', [FormatDateTime('dd.mm.yyyy hh:nn:ss', logDate),
    message]));
end;

end.
