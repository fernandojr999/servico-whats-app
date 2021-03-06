unit uFJ_EnvioWhatsApp;

interface

uses
  System.Classes,
  System.SysUtils,
  System.JSON,
  System.SyncObjs,

  Data.DB,
  uFJ_Conexao,

  FireDAC.Comp.Client,
  FireDAC.Stan.Param,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.UI.Intf,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.Phys,
  FireDAC.DatS,
  FireDAC.DApt.Intf,
  FireDAC.DApt,
  FireDAC.Comp.DataSet;

type
  TEnvioWhatsApp = class
  private
    FIntegrando: Boolean;
    FMensagem: String;
    procedure BuscarNaoEnviados;
    procedure MontaMensagemComercio(IDComercio: Integer);
    procedure InsereMovimentacoes(IDComercio: Integer);
    procedure ExcluiDadoEnvio(DadoEnvio: Integer);
    procedure ExcluiMovimentacoes(Movimentacao: Integer);
    procedure EnviaMensagem(IDComercio: Integer; Mensagem: String);
  public
    procedure IniciarEnvio;
  end;

implementation

{ TEnvioWhatsApp }

uses uFJ_WAPP_Principal;

procedure TEnvioWhatsApp.BuscarNaoEnviados;
var
  Q: TFDQuery;
begin
  Q := NewFDQuery;
  try
    Q.SQL.Add('SELECT * '+
              'FROM COMERCIO '+
              'WHERE ENVIAR = 1 '+
              'AND ATIVO = 1');
    Q.Open;

    while not Q.Eof do
    begin
      MontaMensagemComercio(Q.FieldByName('ID_COMERCIO').AsInteger);

      Q.Edit;
      Q.FieldByName('ENVIAR').AsInteger := 0;
      Q.FieldByName('DATA_ULT_ENVIO').AsDateTime := Now;
      Q.FieldByName('HORA_ULT_ENVIO').AsDateTime := Now;
      Q.Post;

      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

procedure TEnvioWhatsApp.EnviaMensagem(IDComercio: Integer; Mensagem: String);
var
  Q: TFDQuery;
begin
  Q := NewFDQuery;
  try
    Q.SQL.Add('SELECT * FROM CEL_ENVIO WHERE ID_COMERCIO = :COM');
    Q.ParamByName('COM').AsInteger := IDComercio;
    Q.Open;

    while not Q.Eof do
    begin
      try
        if not frmPrincipal.FWhatsApp.Auth then
           Exit;

        frmPrincipal.FWhatsApp.send(Q.FieldByName('CEL').AsString+'@c.us', Mensagem);
      except
        on E: Exception do
        begin
          raise Exception.Create(E.message);
        end;
      end;

      q.Next;
    end;
  finally
    Q.Free;
  end;
end;

procedure TEnvioWhatsApp.ExcluiDadoEnvio(DadoEnvio: Integer);
var
  Q: TFDQuery;
begin
  Q := NewFDQuery;
  try
    Q.SQL.Add('DELETE FROM DADOS_ENVIO WHERE ID_DADOS_ENVIO = :COM');
    Q.ParamByName('COM').AsInteger := DadoEnvio;
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure TEnvioWhatsApp.ExcluiMovimentacoes(Movimentacao: Integer);
var
  Q: TFDQuery;
begin
  Q := NewFDQuery;
  try
    Q.SQL.Add('DELETE FROM MOVIMENTACOES_ENVIO WHERE ID_MOVIMENTACOES_ENVIO = :COM');
    Q.ParamByName('COM').AsInteger := Movimentacao;
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure TEnvioWhatsApp.IniciarEnvio;
begin
  try
    if not FIntegrando then
    begin
      FIntegrando := True;

      BuscarNaoEnviados;

      FIntegrando := False;
    end;
  except
    on E: Exception do
    begin
      raise Exception.Create(e.Message);
    end;
  end;
end;

procedure TEnvioWhatsApp.InsereMovimentacoes(IDComercio: Integer);
var
  Q: TFDQuery;
begin
  Q := NewFDQuery;
  try
    Q.SQL.Add('SELECT * FROM MOVIMENTACOES_ENVIO WHERE ID_COMERCIO = :COM');
    Q.ParamByName('COM').AsInteger := IDComercio;
    Q.Open;

    while not Q.Eof do
    begin
      FMensagem := FMensagem + 'MOVIMENTA??O: '+Q.FieldByName('TIPO_MOVIMENTACAO').AsString+'\n';
      FMensagem := FMensagem + 'NOME DA MOVIMENTA??O: '+Q.FieldByName('NOME_MOVIMENTACAO').AsString+'\n';
      FMensagem := FMensagem + 'RESPONS?VEL: '+Q.FieldByName('RESPONSAVEL').AsString+'\n';
      FMensagem := FMensagem + 'VALOR: '+FormatFloat('###,###,##0.00', Q.FieldByName('VALOR').AsFloat)+'\n\n';

      ExcluiMovimentacoes(Q.FieldByName('ID_MOVIMENTACOES_ENVIO').AsInteger);
      Q.Next;
    end;
  finally
    Q.Free;
  end;
end;

procedure TEnvioWhatsApp.MontaMensagemComercio(IDComercio: Integer);
var
  Q: TFDQuery;
  Total: Double;
begin
  FMensagem := EmptyStr;

  Q := NewFDQuery;
  try
    Q.SQL.Add('SELECT A.*, '+
              '       B.NOME, '+
              '       B.CNPJ,  '+
              '       B.ATIVA_LP, '+
              '       B.ATIVA_DROGARIA, '+
              '       B.ATIVA_CAIXA, '+
              '       B.ATIVA_LOJA '+
              'FROM DADOS_ENVIO A '+
              'INNER JOIN COMERCIO B ON B.ID_COMERCIO = A.ID_COMERCIO '+
              'WHERE A.ID_COMERCIO = :COM');
    Q.ParamByName('COM').AsInteger := IDComercio;
    Q.Open;

    while not Q.Eof do
    begin
      FMensagem := FMensagem + '-               '+Q.FieldByName('NOME').AsString+'\n';
      FMensagem := FMensagem + '             '+Q.FieldByName('CNPJ').AsString+'\n\n';
      FMensagem := FMensagem + '------------------------------------------------------------\n';
      FMensagem := FMensagem + '          CONFERENCIA DE CAIXA\n';
      FMensagem := FMensagem + '------------------------------------------------------------\n';
      FMensagem := FMensagem + 'DATA DA ABERTURA: '+FormatDateTime('DD/MM/YYYY',Q.FieldByName('DATA_ABERTURA').AsDateTime)+'\n';
      FMensagem := FMensagem + 'HORA DA ABERTURA: '+FormatDateTime('HH:NN:SS',Q.FieldByName('HORA_ABERTURA').AsDateTime)+'\n';
      FMensagem := FMensagem + 'ABERTO POR: '+Q.FieldByName('FUNCIONARIO_ABERTURA').AsString+'\n';
      FMensagem := FMensagem + 'VALOR INICIAL: '+FormatFloat('###,###,##0.00', Q.FieldByName('VALOR_INICIAL').AsFloat)+'\n\n';
      FMensagem := FMensagem + '------------------------------------------------------------'+'\n';
      FMensagem := FMensagem + '          DADOS DO FECHAMENTO'+'\n';
      FMensagem := FMensagem + '------------------------------------------------------------'+'\n';
      FMensagem := FMensagem + 'DATA FECHAMENTO: '+FormatDateTime('DD/MM/YYYY',Q.FieldByName('DATA_FECHAMENTO').AsDateTime)+'\n';
      FMensagem := FMensagem + 'HORA FECHAMENTO: '+FormatDateTime('HH:NN:SS',Q.FieldByName('HORA_FECHAMENTO').AsDateTime)+'\n';
      FMensagem := FMensagem + 'FECHADO POR: '+Q.FieldByName('FUNCIONARIO_FECHA').AsString+'\n';
      FMensagem := FMensagem + 'VALOR NO DINHEIRO: '+FormatFloat('###,###,##0.00', Q.FieldByName('FECHA_DIN').AsFloat)+'\n';
      FMensagem := FMensagem + 'VALOR NO D?BITO: '+FormatFloat('###,###,##0.00', Q.FieldByName('FECHA_DEB').AsFloat)+'\n';
      FMensagem := FMensagem + 'VALOR NO CR?DITO: '+FormatFloat('###,###,##0.00', Q.FieldByName('FECHA_CRED').AsFloat)+'\n';
      FMensagem := FMensagem + 'VALOR NO CHEQUE: '+FormatFloat('###,###,##0.00', Q.FieldByName('FECHA_CHEQUE').AsFloat)+'\n';
      FMensagem := FMensagem + 'VALOR DO FECHAMENTO: '+FormatFloat('###,###,##0.00', Q.FieldByName('FECHA_TRANSF').AsFloat)+'\n\n';
      FMensagem := FMensagem + '------------------------------------------------------------'+'\n';
      FMensagem := FMensagem + '          VALORES VENDIDOS'+'\n';
      FMensagem := FMensagem + '------------------------------------------------------------'+'\n';
      FMensagem := FMensagem + 'VALOR NO DINHEIRO: '+FormatFloat('###,###,##0.00', Q.FieldByName('VENDA_DIN').AsFloat)+'\n';
      FMensagem := FMensagem + 'VALOR NO D?BITO: '+FormatFloat('###,###,##0.00', Q.FieldByName('VENDA_DEB').AsFloat)+'\n';
      FMensagem := FMensagem + 'VALOR NO CR?DITO: '+FormatFloat('###,###,##0.00', Q.FieldByName('VENDA_CRED').AsFloat)+'\n';
      FMensagem := FMensagem + 'VALOR NO CHEQUE: '+FormatFloat('###,###,##0.00', Q.FieldByName('VENDA_CHEQUE').AsFloat)+'\n';
      FMensagem := FMensagem + 'VALOR TRANSFERENCIA: '+FormatFloat('###,###,##0.00', Q.FieldByName('VENDA_TRANSF').AsFloat)+'\n';
      FMensagem := FMensagem + 'VALOR OUTROS: '+FormatFloat('###,###,##0.00', Q.FieldByName('VENDA_OUTROS').AsFloat)+'\n';

      Total := Q.FieldByName('VENDA_DIN').AsFloat + Q.FieldByName('VENDA_DEB').AsFloat +
               Q.FieldByName('VENDA_CRED').AsFloat + Q.FieldByName('VENDA_CHEQUE').AsFloat+
               Q.FieldByName('VENDA_TRANSF').AsFloat + Q.FieldByName('VENDA_OUTROS').AsFloat;

      if (not (Q.FieldByName('ATIVA_LP').AsInteger = 1)) and (not (Q.FieldByName('ATIVA_LOJA').AsInteger = 1)) then
      begin
        FMensagem := FMensagem + 'VALOR VIDA LINK: '+FormatFloat('###,###,##0.00', Q.FieldByName('VENDA_VIDALINK').AsFloat)+'\n';
        FMensagem := FMensagem + 'VALOR FP: '+FormatFloat('###,###,##0.00', Q.FieldByName('VENDA_FP').AsFloat)+'\n';
        FMensagem := FMensagem + 'VALOR ULTRACARD: '+FormatFloat('###,###,##0.00', Q.FieldByName('VENDA_ULTRACARD').AsFloat)+'\n';

        Total := Total + Q.FieldByName('VENDA_VIDALINK').AsFloat + Q.FieldByName('VENDA_FP').AsFloat + Q.FieldByName('VENDA_ULTRACARD').AsFloat;
      end;

      FMensagem := FMensagem + 'TOTAL VENDIDO: '+FormatFloat('###,###,##0.00', Total)+'\n';
      FMensagem := FMensagem + '     '+'\n';
      FMensagem := FMensagem + 'TOTAL VENDIDO + VLR. ABERTURA: '+FormatFloat('###,###,##0.00', Total + Q.FieldByName('VALOR_INICIAL').AsFloat)+'\n\n';

      if not (Q.FieldByName('ATIVA_DROGARIA').AsInteger = 1) then
      begin
        if (not (Q.FieldByName('ATIVA_LOJA').AsInteger = 1)) then
        begin
          FMensagem := FMensagem + '------------------------------------------------------------'+'\n';
          FMensagem := FMensagem + '     VALORES SINAIS DE OS'+'\n';
          FMensagem := FMensagem + '------------------------------------------------------------'+'\n';
          FMensagem := FMensagem + 'SINAL OS DINHEIRO: '+FormatFloat('###,###,##0.00', Q.FieldByName('SINALOS_DIN').AsFloat)+'\n';
          FMensagem := FMensagem + 'SINAL OS DEBITO: '+FormatFloat('###,###,##0.00', Q.FieldByName('SINALOS_DEB').AsFloat)+'\n';
          FMensagem := FMensagem + 'SINAL OS CREDITO: '+FormatFloat('###,###,##0.00', Q.FieldByName('SINALOS_CRED').AsFloat)+'\n';
          FMensagem := FMensagem + 'SINAL OS CHEQUE: '+FormatFloat('###,###,##0.00', Q.FieldByName('SINALOS_CHEQUE').AsFloat)+'\n';
          FMensagem := FMensagem + 'SINAL OS TRANSFERENCIA: '+FormatFloat('###,###,##0.00', Q.FieldByName('SINALOS_TRANSF').AsFloat)+'\n';
          FMensagem := FMensagem + 'SINAL OS OUTROS: '+FormatFloat('###,###,##0.00', Q.FieldByName('SINALOS_CHEQUE').AsFloat)+'\n';

          Total := Q.FieldByName('SINALOS_DIN').AsFloat + Q.FieldByName('SINALOS_DEB').AsFloat +
                   Q.FieldByName('SINALOS_CRED').AsFloat + Q.FieldByName('SINALOS_CHEQUE').AsFloat+
                   Q.FieldByName('SINALOS_TRANSF').AsFloat + Q.FieldByName('SINALOS_OUTROS').AsFloat;

          FMensagem := FMensagem + 'TOTAL SINAL OS: '+FormatFloat('###,###,##0.00', Total)+'\n\n';
          FMensagem := FMensagem + '------------------------------------------------------------'+'\n';
          FMensagem := FMensagem + '     VALORES RECEBIMENTOS DE OS'+'\n';
          FMensagem := FMensagem + '------------------------------------------------------------'+'\n';
          FMensagem := FMensagem + 'RECEBIMENTO OS DINHEIRO: '+FormatFloat('###,###,##0.00', Q.FieldByName('RECEBE_OS_DIN').AsFloat)+'\n';
          FMensagem := FMensagem + 'RECEBIMENTO OS DEBITO: '+FormatFloat('###,###,##0.00', Q.FieldByName('RECEBE_OS_DEB').AsFloat)+'\n';
          FMensagem := FMensagem + 'RECEBIMENTO OS CREDITO: '+FormatFloat('###,###,##0.00', Q.FieldByName('RECEBE_OS_CRED').AsFloat)+'\n';
          FMensagem := FMensagem + 'RECEBIMENTO OS CHEQUE: '+FormatFloat('###,###,##0.00', Q.FieldByName('RECEBE_OS_CHEQUE').AsFloat)+'\n';
          FMensagem := FMensagem + 'RECEBIMENTO OS TRANSFERENCIA: '+FormatFloat('###,###,##0.00', Q.FieldByName('RECEBE_OS_TRANSF').AsFloat)+'\n';
          FMensagem := FMensagem + 'RECEBIMENTO OS OUTROS: '+FormatFloat('###,###,##0.00', Q.FieldByName('RECEBE_OS_OUTROS').AsFloat)+'\n';

          Total := Q.FieldByName('RECEBE_OS_DIN').AsFloat + Q.FieldByName('RECEBE_OS_DEB').AsFloat +
                   Q.FieldByName('RECEBE_OS_CRED').AsFloat + Q.FieldByName('RECEBE_OS_CHEQUE').AsFloat+
                   Q.FieldByName('RECEBE_OS_TRANSF').AsFloat + Q.FieldByName('RECEBE_OS_OUTROS').AsFloat;

          FMensagem := FMensagem + 'TOTAL RECEBIMENTO OS: '+FormatFloat('###,###,##0.00', Total)+'\n\n';
        end;

        FMensagem := FMensagem + '------------------------------------------------------------'+'\n';
        FMensagem := FMensagem + '  VALORES RECEBIMENTOS DE TROCA'+'\n';
        FMensagem := FMensagem + '------------------------------------------------------------'+'\n';
        FMensagem := FMensagem + 'TROCA DINHEIRO: '+FormatFloat('###,###,##0.00', Q.FieldByName('TROCA_DIN').AsFloat)+'\n';
        FMensagem := FMensagem + 'TROCA DEBITO: '+FormatFloat('###,###,##0.00', Q.FieldByName('TROCA_DEB').AsFloat)+'\n';
        FMensagem := FMensagem + 'TROCA CREDITO: '+FormatFloat('###,###,##0.00', Q.FieldByName('TROCA_CRED').AsFloat)+'\n';
        FMensagem := FMensagem + 'TROCA CHEQUE: '+FormatFloat('###,###,##0.00', Q.FieldByName('TROCA_CHEQUE').AsFloat)+'\n';
        FMensagem := FMensagem + 'TROCA TRANSFERENCIA: '+FormatFloat('###,###,##0.00', Q.FieldByName('TROCA_TRANSF').AsFloat)+'\n';
        FMensagem := FMensagem + 'TROCA OUTROS: '+FormatFloat('###,###,##0.00', Q.FieldByName('TROCA_OUTROS').AsFloat)+'\n';

        Total := Q.FieldByName('TROCA_DIN').AsFloat + Q.FieldByName('TROCA_DEB').AsFloat +
                 Q.FieldByName('TROCA_CRED').AsFloat + Q.FieldByName('TROCA_CHEQUE').AsFloat+
                 Q.FieldByName('TROCA_TRANSF').AsFloat + Q.FieldByName('TROCA_OUTROS').AsFloat;

        FMensagem := FMensagem + 'TOTAL RECEBIMENTO TROCA: '+FormatFloat('###,###,##0.00', Total)+'\n\n';
      end;

      FMensagem := FMensagem + '------------------------------------------------------------'+'\n';
      FMensagem := FMensagem + '                  MOVMENTA??ES'+'\n';
      FMensagem := FMensagem + '------------------------------------------------------------'+'\n';
      InsereMovimentacoes(IDComercio);
      FMensagem := FMensagem + '------------------------------------------------------------'+'\n';
      FMensagem := FMensagem + '           STATUS DO CAIXA'+'\n';
      FMensagem := FMensagem + '------------------------------------------------------------'+'\n';
      FMensagem := FMensagem + 'COM OS VALORES APRESENTADOS O CAIXA APRESENTA UMA DIFEREN?A DE '+
                               FormatFloat('###,###,##0.00', Q.FieldByName('DIFERENCA').AsFloat) +'\n';
      EnviaMensagem(IDComercio, FMensagem);

      ExcluiDadoEnvio(Q.FieldByName('ID_DADOS_ENVIO').AsInteger);

      Q.Next;
    end;

  finally
    Q.Free;
  end;
end;

end.
