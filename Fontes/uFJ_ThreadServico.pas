unit uFJ_ThreadServico;

interface
uses
  System.Classes,
  System.SysUtils,
  System.JSON,
  System.SyncObjs,
  System.IOUtils,

  uFJ_EnvioWhatsApp;

type
  TExecutaEnvio = class(TThread)
  private
    FTermEvent:TEvent;
  public
    FEnvioWhatsApp: TEnvioWhatsApp;

    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
    procedure Execute; override;
    procedure TerminatedSet; override;
  end;

implementation

{ TExecutaIntegracaoSoftDesk }

procedure TExecutaEnvio.AfterConstruction;
begin
  inherited;
  FTermEvent := TEvent.Create(nil, True, False, '');
  FEnvioWhatsApp := TEnvioWhatsApp.Create;

  FreeOnTerminate := True;
end;

procedure TExecutaEnvio.BeforeDestruction;
begin
  inherited;
  FTermEvent.Free;
  FEnvioWhatsApp.Free;
end;

procedure TExecutaEnvio.Execute;
begin
  inherited;
  while not Terminated do
  begin
    try
      FEnvioWhatsApp.IniciarEnvio;
    except
      On E:Exception do
      begin
        var sl := TStringList.Create;
        try
          if not FileExists('logerro.txt') then
            sl.SaveToFile('logerro.txt');

          sl.LoadFromFile('logerro.txt');

          sl.Add(DateTimeToStr(now)+' - '+e.Message);

          sl.SaveToFile('logerro.txt');
        finally
          sl.Free;
        end;
      end;
    end;

    FTermEvent.WaitFor(10000);
  end;
end;

procedure TExecutaEnvio.TerminatedSet;
begin
  inherited;
  FTermEvent.SetEvent;
end;

end.
