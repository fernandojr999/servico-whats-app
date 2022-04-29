object RDW: TRDW
  OldCreateOrder = False
  Encoding = esUtf8
  Height = 253
  Width = 358
  object whatsapp: TDWServerEvents
    IgnoreInvalidParams = False
    Events = <
      item
        Routes = [crGet]
        NeedAuthorization = True
        DWParams = <
          item
            TypeObject = toParam
            ObjectDirection = odINOUT
            ObjectValue = ovString
            ParamName = 'numero'
            Encoded = True
          end
          item
            TypeObject = toParam
            ObjectDirection = odINOUT
            ObjectValue = ovString
            ParamName = 'mensagem'
            Encoded = True
          end>
        JsonMode = jmPureJSON
        Name = 'enviarMensagemTexto'
        EventName = 'enviarMensagemTexto'
        OnlyPreDefinedParams = False
        OnReplyEvent = whatsappEventsenviarMensagemTextoReplyEvent
      end>
    Left = 32
    Top = 16
  end
end
