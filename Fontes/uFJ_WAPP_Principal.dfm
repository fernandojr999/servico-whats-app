object frmPrincipal: TfrmPrincipal
  Left = 754
  Top = 386
  Caption = 'Principal'
  ClientHeight = 255
  ClientWidth = 432
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu
  OldCreateOrder = False
  Position = poDesigned
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object pgcControle: TPageControl
    Left = 0
    Top = 0
    Width = 432
    Height = 255
    ActivePage = tabServico
    Align = alClient
    TabOrder = 0
    object tabServico: TTabSheet
      Caption = 'Configura'#231#245'es'
      ImageIndex = 1
      object Label2: TLabel
        Left = 78
        Top = 46
        Width = 36
        Height = 13
        Caption = 'Usu'#225'rio'
      end
      object Label3: TLabel
        Left = 84
        Top = 73
        Width = 30
        Height = 13
        Caption = 'Senha'
      end
      object lblStatusServico: TLabel
        Left = 233
        Top = 134
        Width = 72
        Height = 13
        Caption = 'Status: Parado'
      end
      object Label1: TLabel
        Left = 37
        Top = 19
        Width = 77
        Height = 13
        Caption = 'Banco de Dados'
      end
      object edtUsuario: TEdit
        Left = 120
        Top = 43
        Width = 225
        Height = 21
        TabOrder = 0
      end
      object edtSenha: TEdit
        Left = 120
        Top = 70
        Width = 225
        Height = 21
        PasswordChar = '*'
        TabOrder = 1
      end
      object btnSalvar: TButton
        Left = 78
        Top = 97
        Width = 75
        Height = 25
        Caption = 'Salvar'
        TabOrder = 2
        OnClick = btnSalvarClick
      end
      object edtBancoDados: TEdit
        Left = 120
        Top = 16
        Width = 225
        Height = 21
        TabOrder = 3
        TextHint = 'Caminho do banco de dados'
      end
      object btnTestarConexão: TButton
        Left = 248
        Top = 97
        Width = 97
        Height = 25
        Caption = 'Testar Conex'#227'o'
        TabOrder = 4
        OnClick = btnTestarConexãoClick
      end
    end
  end
  object MainMenu: TMainMenu
    Left = 24
    Top = 200
    object Opes1: TMenuItem
      Caption = 'Op'#231#245'es'
      object ObterQRCode1: TMenuItem
        Caption = 'Autenticar dispositivo'
        OnClick = ObterQRCode1Click
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object IniciarServio1: TMenuItem
        Caption = 'Iniciar'
        OnClick = IniciarServio1Click
      end
      object PararServio1: TMenuItem
        Caption = 'Parar'
        OnClick = PararServio1Click
      end
    end
  end
  object FWhatsApp: TInject
    InjectJS.AutoUpdateTimeOut = 10
    Config.AutoDelay = 1000
    AjustNumber.LengthPhone = 8
    AjustNumber.DDIDefault = 55
    FormQrCodeType = Ft_Http
    Left = 84
    Top = 200
  end
  object TrayIcon: TTrayIcon
    Hint = 'PH WhatsApp - PH Sys'
    BalloonHint = 'PH WhatsApp - PH Sys'
    BalloonTimeout = 3000
    PopupMenu = PopupMenu
    Left = 152
    Top = 202
  end
  object PopupMenu: TPopupMenu
    Left = 224
    Top = 202
    object btnpmRestaurarAplicao: TMenuItem
      Caption = 'Restaurar'
      OnClick = btnpmRestaurarAplicaoClick
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object btnpmCertificadoDigital: TMenuItem
      Caption = 'Auntenticar Dispositivo'
      OnClick = btnpmCertificadoDigitalClick
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object btnpmServico: TMenuItem
      Caption = 'Servi'#231'o'
      object btnpmIniciar: TMenuItem
        Caption = 'Iniciar'
        OnClick = btnpmIniciarClick
      end
      object btnpmParar: TMenuItem
        Caption = 'Parar'
      end
    end
    object MenuItem1: TMenuItem
      Caption = '-'
    end
    object btnpmFecharAplicacao: TMenuItem
      Caption = 'Fechar'
      OnClick = btnpmFecharAplicacaoClick
    end
  end
  object ApplicationEvents: TApplicationEvents
    OnMinimize = ApplicationEventsMinimize
    Left = 312
    Top = 202
  end
end
