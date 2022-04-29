program FJWhatsApp;

uses
  Vcl.Forms,
  System.IOUtils,
  System.SysUtils,
  uTInject.ConfigCEF,
  uFJ_WAPP_Principal in 'uFJ_WAPP_Principal.pas' {frmPrincipal},
  Vcl.Themes,
  Vcl.Styles,
  uFJ_Conexao in 'uFJ_Conexao.pas' {dmConexao: TDataModule},
  uFJ_ThreadServico in 'uFJ_ThreadServico.pas',
  uFJ_EnvioWhatsApp in 'uFJ_EnvioWhatsApp.pas';

{$R *.res}

begin
//  GlobalCEFApp.PathLogFile          := '';
//  GlobalCEFApp.PathFrameworkDirPath := TPath.Combine(System.SysUtils.GetCurrentDir,'BinWhatsApp');
//  GlobalCEFApp.PathResourcesDirPath := TPath.Combine(System.SysUtils.GetCurrentDir,'BinWhatsApp');
//  GlobalCEFApp.PathLocalesDirPath   := TPath.Combine(System.SysUtils.GetCurrentDir,'BinWhatsApp\locales');
//  GlobalCEFApp.Pathcache            := TPath.Combine(System.SysUtils.GetCurrentDir,'BinWhatsApp\Cache');
//  GlobalCEFApp.PathUserDataPath     := TPath.Combine(System.SysUtils.GetCurrentDir,'BinWhatsApp\User Data');

  If not GlobalCEFApp.StartMainProcess then
    exit;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Aqua Light Slate');
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.CreateForm(TdmConexao, dmConexao);
  Application.Run;
end.
