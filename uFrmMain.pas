unit uFrmMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  System.ImageList, FMX.ImgList, FMX.Controls.Presentation, FMX.StdCtrls,
  FMX.Layouts, FMX.Effects, System.Net.URLClient, System.Net.HttpClient,
  System.Net.HttpClientComponent, System.JSON, ShellApi, IniFiles, Winapi.Windows, FMX.Platform.Win;

type
  TResponseLauncher = record
    version: integer;
    fivem_link: string;
    discord_link: string;
    teamspeak_link: string;
    new_version_link: string;
  end;

  TFrmMain = class(TForm)
    Image1: TImage;
    ShadowEffect1: TShadowEffect;
    Layout1: TLayout;
    Button1: TButton;
    Button2: TButton;
    ImageList1: TImageList;
    StyleBook1: TStyleBook;
    Label1: TLabel;
    NetHTTPClient1: TNetHTTPClient;
    procedure NetHTTPClient1RequestCompleted(const Sender: TObject;
      const AResponse: IHTTPResponse);
    procedure NetHTTPClient1ReceiveData(const Sender: TObject; AContentLength,
      AReadCount: Int64; var Abort: Boolean);
    procedure NetHTTPClient1RequestError(const Sender: TObject;
      const AError: string);
    procedure NetHTTPClient1ValidateServerCertificate(const Sender: TObject;
      const ARequest: TURLRequest; const Certificate: TCertificate;
      var Accepted: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
    FVersion: Integer;
    FFivem: string;
    FDiscord: string;
    FTeamSpeak: string;
    FUpdateLink: string;
    FNewVersionUpdate: string;
    procedure atualizarStatus(msg: string);
    procedure atualizarLauncher();
    function deserialize(obj: string): TResponseLauncher;
    procedure verificar;
  public
    { Public declarations }
  end;

var
  FrmMain: TFrmMain;

implementation

{$R *.fmx}

procedure TFrmMain.atualizarLauncher();
begin
  MessageBox(WindowHandleToPlatform(self.Handle).Wnd, PChar('Uma nova versão foi encontrada, deseja atualizar?'), PChar('PATCH'), MB_YESNO + MB_ICONQUESTION);
  ShellExecute(0, 'open', Pchar(FNewVersionUpdate), nil, nil, 0);
  Application.Terminate;
end;

procedure TFrmMain.atualizarStatus(msg: string);
begin
  Label1.Text := msg;
end;

procedure TFrmMain.Button1Click(Sender: TObject);
begin
    TThread.CreateAnonymousThread(procedure() begin
      (Sender as TButton).Enabled := false;
       ShellExecute(0, 'open', 'explorer.exe', PWideChar('fivem://connect/' + FFivem), nil, 0);
       ShellExecute(0, 'open', 'explorer.exe', PWideChar('ts3server://' + FTeamSpeak), nil, 0);
       Sleep(4000);
       Application.Terminate;
    end).Start;
end;

procedure TFrmMain.Button2Click(Sender: TObject);
begin
    TThread.CreateAnonymousThread(procedure()
    begin
      ShellExecute(0, 'open', PWideChar('https://discord.gg/' + FDiscord), nil, nil, 0);
    end).Start;
end;

function TFrmMain.deserialize(obj: string): TResponseLauncher;
begin
   var JsonValue := TJSONObject.ParseJSONValue(obj);
   Result.version := JsonValue.GetValue<integer>('version');
   Result.fivem_link := JsonValue.GetValue<string>('fivem_link');
   Result.discord_link := JsonValue.GetValue<string>('discord_link');
   Result.teamspeak_link := JsonValue.GetValue<string>('teamspeak_link');
   Result.new_version_link := JsonValue.GetValue<string>('new_version_link');
end;

procedure TFrmMain.FormCreate(Sender: TObject);
var
  c: TIniFile;
  updLink: string;
  version: integer;
begin
  c := TIniFile.Create( ExtractFilePath(ParamStr(0)) +  '\patch.ini');
  try
   updLink := c.ReadString('PATCH', 'updatelink', '');
   version := c.ReadInteger('PATCH', 'version', 0);
   if (Trim(updLink) <> '') and (version > 0) then
   begin
      FVersion := version;
      FUpdateLink := updLink;
      verificar;
   end else begin
     ShowMessage('Falha na leitura das configurações. Verifique o Arquivo patch.ini');
     Application.Terminate;
   end;
  finally
    c.Free;
  end;
end;

procedure TFrmMain.NetHTTPClient1ReceiveData(const Sender: TObject;
  AContentLength, AReadCount: Int64; var Abort: Boolean);
begin
  atualizarStatus('Recebendo informação...');
end;

procedure TFrmMain.NetHTTPClient1RequestCompleted(const Sender: TObject;
  const AResponse: IHTTPResponse);
var
  Response: TResponseLauncher;
begin
  atualizarStatus('Conexão terminada');
  if AResponse.StatusCode = 200 then
  begin
     Response := deserialize(AResponse.ContentAsString());
     FFivem := Response.fivem_link;
     FDiscord := Response.discord_link;
     FTeamSpeak := Response.teamspeak_link;
     FNewVersionUpdate := Response.new_version_link;
     Button1.Enabled := True;
     Button2.Enabled := True;
     if Response.version > FVersion then
     begin
      atualizarLauncher()
     end else
     begin
      atualizarStatus('Você tá usando a última versão...');
     end;
  end;
end;

procedure TFrmMain.NetHTTPClient1RequestError(const Sender: TObject;
  const AError: string);
begin
  atualizarStatus('Falha na conexão com o servidor...');
  ShowMessage('Falha na conexão com o servidor...');
end;

procedure TFrmMain.NetHTTPClient1ValidateServerCertificate(
  const Sender: TObject; const ARequest: TURLRequest;
  const Certificate: TCertificate; var Accepted: Boolean);
begin
  atualizarStatus('Validando certificado...');
end;

procedure TFrmMain.verificar;
begin
    TThread.CreateAnonymousThread(procedure()
    begin
      Sleep(4000);
//      NetHTTPClient1.Get('https://pacific-anchorage-54554.herokuapp.com/launcher/update');
        NetHTTPClient1.Get(FUpdateLink);
    end).Start;
end;

end.
