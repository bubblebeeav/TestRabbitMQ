program Sender;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  StompClient,
  MessageDispatcher in 'MessageDispatcher.pas',
  Logger in 'Logger.pas';

var
  messageSender: TMessageSender;
  message: string;
  Logger: TLogWriter;

procedure MessageSent(message: string);
var
  logMessage: string;
begin
  logMessage := Format('Message sent "[%s]".', [message]);
  Logger.Write(Now, logMessage);
  WriteLn(output);
end;

begin

  try
    messageSender := TMessageSender.Create('localhost', 61613, 'myQueue', 'guest', 'guest');
    Logger := TLogWriter.Create('senderlog.db3');
    messageSender.OnMessageSent := MessageSent;
    while True do
    begin
      WriteLn('Type message or "exit" for quit the appliction ');
      ReadLn(input, message);
      if message.ToLower = 'exit' then
        break;
      messageSender.Send(message);
    end;
  except
    on E: Exception do
      WriteLn(E.ClassName, ': ', E.message);
  end;

end.
