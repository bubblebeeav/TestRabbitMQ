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
    procedure Write(message: string);
  end;

implementation

constructor TLogWriter.Create(databasename : string);
begin
  database := TSqliteDatabase.Create(databasename);
  database.ExecSQL
    ('CREATE TABLE IF NOT EXISTS LOGS(ID INTEGER NOT NULL PRIMARY KEY, DT TEXT NOT NULL, MSG TEXT)');
  database.SetTimeout(1000);
end;

procedure TLogWriter.Write(message: string);
var
  myDate: TDateTime;
begin
  database.Start('', 'TRANSACTION');
  database.AddParamText(':dt', FormatDateTime('dd.mm.yyyy hh:nn:ss', Now));
  database.AddParamText(':msg', message);
  database.ExecSQL('INSERT INTO LOGS(DT,MSG) VALUES(:dt,:msg)');
  database.Commit('');
  Writeln(Format('%s - %s', [FormatDateTime('dd.mm.yyyy hh:nn:ss', Now),
    message]));
end;

end.
