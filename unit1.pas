unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  sockets, blcksock, Synautil, dbf;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    editMessage: TEdit;
    Label1: TLabel;
    memoProtocol: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure AddProtocol(S:AnsiString);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;
  ASocket : TTCPBlockSocket;
  DBFProtocol : TDbf;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.AddProtocol(S: AnsiString)  ;
begin
  try
    DBFProtocol := TDbf.Create(nil);

    DBFProtocol.FilePath:=ExtractFilePath(Application.ExeName);

    DBFProtocol.TableName := 'demolog.dbf';

    DBFProtocol.Open;

    DBFProtocol.Insert;

    DBFProtocol.FieldByName('Message').AsString:= S;

    DBFProtocol.Post;

    memoProtocol.Text:=S + #13#10 + memoProtocol.Text;

  except

    DBFProtocol.Insert;

    DBFProtocol.FieldByName('Message').AsString:='Необработанная ошибка';
    DBFProtocol.Post;
    memoProtocol.Text:='Необработанная ошибка' + #13#10 + memoProtocol.Text;
  end;

  DBFProtocol.Close;

end;

procedure TForm1.Button1Click(Sender: TObject);
var
  timeout : integer;
  S : string;
begin
  try
     AddProtocol('d');
     AddProtocol('Открываем файл БД: ' + DBFProtocol.FilePath
                                                        + '\demolog.dbf');

    timeout := 12000;
    ASocket := TTCPBlockSocket.Create;
    ASocket.Connect('127.0.0.1', '69555');
    ASocket.SendBlock(editMessage.Text);
    AddProtocol('CLIENT to SERVER: ' + editMessage.Text);

     if    ASocket.CanRead(timeout) then
     begin
          S:=ASocket.RecvString(timeout);

          AddProtocol('SERVER to CLIENT: ' + S);
     end;

  except
        AddProtocol('Необработанная ошибка');
  end;

  ASocket.CloseSocket;


end;

end.

