program Receiver;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.SysUtils,
  MessageDispatcher in 'MessageDispatcher.pas',
  Logger in 'Logger.pas';

type

  TMessageListener = class(TInterfacedObject, IMessageListener)
  private
    lLogger: TLogWriter;
  public
    constructor Create;
    procedure OnMessageReceived(message: string);
  end;

constructor TMessageListener.Create;
begin
  lLogger := TLogWriter.Create('receiverlog.db3');
end;

procedure TMessageListener.OnMessageReceived(message: string);
var
  logMessage: string;
begin
  logMessage := Format('Message recieved "[%s]".', [message]);
  lLogger.Write(Now, logMessage);
  WriteLn(output);
end;

var
  messageReceiver: TMessageReceiver;

begin
  try
    messageReceiver := TMessageReceiver.Create('localhost', 61613, 'myQueue',
      'guest', 'guest', TMessageListener.Create);
    WriteLn('mesage receiver started..');
    messageReceiver.Run();
    WriteLn('Press Enter to exit..');
    ReadLn;
  except
    on E: Exception do
      WriteLn(E.ClassName, ': ', E.message);
  end;

end.
