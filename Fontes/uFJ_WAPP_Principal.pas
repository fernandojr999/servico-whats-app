unit uFJ_WAPP_Principal;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.IOUtils,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,

  synacode,

  ServerUtils,
  uFJ_ThreadServico,

  uTInject.ConfigCEF,
  uTInject,
  uTInject.Constant,
  uTInject.JS,
  uInjectDecryptFile,
  uTInject.Console,
  uTInject.Diversos,
  uTInject.AdjustNumber,
  uTInject.Config,
  uTInject.Classes,

  Vcl.ExtCtrls,
  Vcl.Menus,
  Vcl.ComCtrls,
  Vcl.AppEvnts,

  Data.Bind.Components,
  Data.Bind.ObjectScope,
  System.ImageList,
  Vcl.ImgList;

type
  TfrmPrincipal = class(TForm)
    MainMenu: TMainMenu;
    Opes1: TMenuItem;
    ObterQRCode1: TMenuItem;
    N1: TMenuItem;
    IniciarServio1: TMenuItem;
    PararServio1: TMenuItem;
    pgcControle: TPageControl;
    tabServico: TTabSheet;
    Label2: TLabel;
    Label3: TLabel;
    edtUsuario: TEdit;
    edtSenha: TEdit;
    btnSalvar: TButton;
    FWhatsApp: TInject;
    TrayIcon: TTrayIcon;
    PopupMenu: TPopupMenu;
    btnpmRestaurarAplicao: TMenuItem;
    N2: TMenuItem;
    btnpmServico: TMenuItem;
    btnpmIniciar: TMenuItem;
    btnpmParar: TMenuItem;
    MenuItem1: TMenuItem;
    btnpmCertificadoDigital: TMenuItem;
    btnpmFecharAplicacao: TMenuItem;
    ApplicationEvents: TApplicationEvents;
    N4: TMenuItem;
    lblStatusServico: TLabel;
    edtBancoDados: TEdit;
    Label1: TLabel;
    btnTestarConex?o: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ObterQRCode1Click(Sender: TObject);
    procedure IniciarServio1Click(Sender: TObject);
    procedure PararServio1Click(Sender: TObject);
    procedure Reiniciar1Click(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ApplicationEventsMinimize(Sender: TObject);
    procedure btnpmRestaurarAplicaoClick(Sender: TObject);
    procedure btnpmFecharAplicacaoClick(Sender: TObject);
    procedure btnpmCertificadoDigitalClick(Sender: TObject);
    procedure btnpmIniciarClick(Sender: TObject);
    procedure btnTestarConex?oClick(Sender: TObject);
  private
    { Private declarations }
    FServico: TExecutaEnvio;

    procedure CarregarConfiguracao;
    procedure AutenticarDispositivo;
    procedure IniciarServico;
    procedure PararServico;
    procedure Restaurar;
    procedure ConfigurarConexao;
  public
    { Public declarations }
  end;

var
  frmPrincipal: TfrmPrincipal;

CONST ARQUIVO_CONF = 'confbdwpp.conf';

implementation

{$R *.dfm}

uses uFJ_Conexao;

procedure TfrmPrincipal.ApplicationEventsMinimize(Sender: TObject);
begin
  Self.Hide();
end;

procedure TfrmPrincipal.AutenticarDispositivo;
begin
  if not FWhatsApp.Auth(false) then
  Begin
    FWhatsApp.FormQrCodeType := Ft_Http;
    FWhatsApp.FormQrCodeStart;
  End;
end;

procedure TfrmPrincipal.btnpmCertificadoDigitalClick(Sender: TObject);
begin
  AutenticarDispositivo;
end;

procedure TfrmPrincipal.btnpmFecharAplicacaoClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmPrincipal.btnpmIniciarClick(Sender: TObject);
begin
  IniciarServico;
end;

procedure TfrmPrincipal.btnpmRestaurarAplicaoClick(Sender: TObject);
begin
  Restaurar;
end;

procedure TfrmPrincipal.btnSalvarClick(Sender: TObject);
begin
  var sl := TStringList.Create;
  try
    sl.Add('CAMINHO='+edtBancoDados.Text);
    sl.Add('USUARIO='+edtUsuario.Text);
    sl.Add('SENHA='+edtSenha.Text);

    sl.SaveToFile(ARQUIVO_CONF);
  finally
    sl.Free
  end;
end;

procedure TfrmPrincipal.btnTestarConex?oClick(Sender: TObject);
begin
  ConfigurarConexao;

  dmConexao.conexao.Connected := True;

  if dmConexao.conexao.Connected then
    ShowMessage('Conectado com sucesso');
end;

procedure TfrmPrincipal.CarregarConfiguracao;
begin
  var sl := TStringList.Create;
  try
    sl.LoadFromFile(ARQUIVO_CONF);

    var Caminho := Copy(sl.Strings[0], pos('=',sl.Strings[0]) + 1, sl.Strings[0].Length - pos('=',sl.Strings[0]));
    var Usuario := Copy(sl.Strings[1], pos('=',sl.Strings[1]) + 1, sl.Strings[1].Length - pos('=',sl.Strings[1]));
    var Senha   := Copy(sl.Strings[2], pos('=',sl.Strings[2]) + 1, sl.Strings[2].Length - pos('=',sl.Strings[2]));

    edtBancoDados.Text := Caminho;
    edtUsuario.Text    := Usuario;
    edtSenha.Text      := Senha;
  finally
    sl.Free
  end;
end;

procedure TfrmPrincipal.ConfigurarConexao;
begin
  dmConexao.conexao.Connected       := False;
  dmConexao.conexao.Params.Database := edtBancoDados.Text;
  dmConexao.conexao.Params.UserName := edtUsuario.Text;
  dmConexao.conexao.Params.Password := edtSenha.Text;
end;

procedure TfrmPrincipal.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  TrayIcon.Visible := False;

  Application.Terminate;
  inherited;
end;

procedure TfrmPrincipal.FormCreate(Sender: TObject);
begin
  CarregarConfiguracao;

  FWhatsApp := TInject.Create(Nil);

  TrayIcon.Visible := True;

  FServico := TExecutaEnvio.Create(True);
end;

procedure TfrmPrincipal.FormDestroy(Sender: TObject);
begin
  FWhatsApp.Free;
  FServico.Free;
end;

procedure TfrmPrincipal.IniciarServico;
begin
  ConfigurarConexao;

  FServico.Priority           := tpNormal;
  FServico.FreeOnTerminate    := True;
  FServico.Start;


  lblStatusServico.Caption := 'Status: Iniciado...';
end;

procedure TfrmPrincipal.IniciarServio1Click(Sender: TObject);
begin
  IniciarServico;
end;

procedure TfrmPrincipal.ObterQRCode1Click(Sender: TObject);
begin
  AutenticarDispositivo;
end;

procedure TfrmPrincipal.PararServico;
begin
  FServico.Suspend;

  lblStatusServico.Caption := 'Status: Parado...';
end;

procedure TfrmPrincipal.PararServio1Click(Sender: TObject);
begin
  PararServico;
end;

procedure TfrmPrincipal.Reiniciar1Click(Sender: TObject);
begin
  PararServico;

  IniciarServico;
end;

procedure TfrmPrincipal.Restaurar;
begin
  Show;
  Application.Restore;
end;

end.
