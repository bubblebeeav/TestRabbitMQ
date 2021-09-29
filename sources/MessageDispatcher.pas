unit MessageDispatcher;

interface

uses
  StompClient,
  SysUtils,
  Classes;

type
  TMessageSentEvent = procedure(message: string);

  // Интерфейс обработчика событий.
  IMessageListener = interface
    procedure OnMessageReceived(message: string);
  end;

  // Поток обработки входящих событий.
  TListenerThread = class(TThread)
  protected
    procedure Execute; override;
  private
    lListener: IMessageListener;
    lClient: IStompClient;
    constructor Create(listener: IMessageListener; client: IStompClient);
  end;

  // Базовый класс работы с очередью сообщений.
  TMessageDispatcher = class abstract
  protected
    lClient: IStompClient;
    queueName: string;
  public
    constructor Create(host: string; port: integer; queue: string;
      username: string; password: string);
  end;

  // Класс для отправки сообщений.
  TMessageSender = class(TMessageDispatcher)
  private
    FMessageSent: TMessageSentEvent;
  public
    procedure Send(message: string);
    property OnMessageSent: TMessageSentEvent read FMessageSent
      write FMessageSent;
  end;

  // Класс для обработки входящих сообщений.
  TMessageReceiver = class(TMessageDispatcher)
  private
    listenerThread: TListenerThread;
  public
    constructor Create(host: string; port: integer; queue: string;
      username: string; password: string; listener: IMessageListener);
    procedure Run();
  end;

implementation

constructor TListenerThread.Create(listener: IMessageListener;
  client: IStompClient);
begin
  lListener := listener;
  lClient := client;
  FreeOnTerminate := true;
  inherited Create(true);
end;

procedure TListenerThread.Execute;
var
  lStompFrame: IStompFrame;
  lMessage: string;
begin
  while true do
  begin
    if lClient.Receive(lStompFrame, 5000) then
    begin
      lMessage := lStompFrame.GetBody;
      lListener.OnMessageReceived(lMessage);
      lClient.Ack(lStompFrame.MessageID);
    end;
  end;
end;

constructor TMessageDispatcher.Create(host: string; port: integer;
  queue: string; username: string; password: string);
begin
  queueName := queue;
  lClient := StompUtils.StompClient;
  lClient.SetHost(host);
  lClient.SetPort(port);
  lClient.SetUserName(username);
  lClient.SetPassword(password);
  repeat
    try
      lClient.Connect();
    except
      on E: Exception do
        WriteLn('Cannot connect to rabbit, try again...');
    end;
    Sleep(5000);
  until lClient.Connected;
  WriteLn('Conencted');
end;

procedure TMessageSender.Send(message: string);
begin
  lClient.Send(Format('/queue/%s', [queueName]), message,
    StompUtils.Headers.Add('auto-delete', 'true'));
  if Assigned(FMessageSent) then
    FMessageSent(message);
end;

constructor TMessageReceiver.Create(host: string; port: integer; queue: string;
  username: string; password: string; listener: IMessageListener);
begin
  inherited Create(host, port, queue, username, password);
  lClient.Subscribe(Format('/queue/%s', [queueName]), TAckMode.amClient,
    StompUtils.Headers.Add('auto-delete', 'true'));
  if listener = nil then
    Raise EArgumentNilException.Create('listener cannot be nil');
  listenerThread := TListenerThread.Create(listener, lClient);

end;

procedure TMessageReceiver.Run();
begin
  listenerThread.Start;
end;

end.
