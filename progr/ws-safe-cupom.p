/*
04.02.2020 helio.neto - 189 - cupom desconto
*/

{admcab.i}

def var vtabela   as char.

def var lokxml as log.
def var vlcentrada    as longchar.   
def var vlcsaida      as longchar.
def var hsafe         as handle.
   
def input param par-cpf      as dec decimals 0.
def input param par-campanha as int.
def input param par-valor    as dec.
def output param par-NSUSafe as char.
def output param par-mensagem as char.

def var vmetodo     as char init "ConsultaCuponagemD5V2".  

DEFINE TEMP-TABLE RespostaSAFE NO-UNDO 
    field CodigoResposta    as char
    field NSUSafe           as char
    field MensagemPDV   as char format "x(30)"
    field SaldoDisponivel as char
    field Cartao        as char
    field Bit62         as char
    field TempoResposta as char
    field ValorTotalTransacao   as char.

vlcentrada = "codigoLoja="       + string(setbcod,"9999") +
              "&pdv=001" +
              "&estabelecimento=" + string(setbcod,"9999") + fill(" ", 11) +
              "&cpf="              + string(par-cpf,"99999999999999") + 
              "&numeroCampanha="   + string(par-campanha,"9999999") + 
              "&cuponagemExterna=" + "N" +
              "&valorTransacao="   + trim(string(par-valor,">>>>>>>>>>>>>>>9.99")).


hide message no-pause.
message "Consultando webservice P2K SAFE " + vmetodo par-cpf par-campanha par-valor.

run rest-safe.p  (input vmetodo, vlcentrada, output vlcsaida).

/*hsafe  = temp-table RespostaSAFE:handle.
 lokXML = hsafe:READ-XML("longchar", vLCSaida, "EMPTY").*/

hide message no-pause.
message "Tratando retorno webservice P2K SAFE " + vmetodo par-cpf par-campanha par-valor.
run lexml (vlcsaida).


find first RespostaSAFE no-error.
if avail RespostaSAFE
then do:
    par-mensagem   = mensagemPDV.
    par-NSUSafe    = NSUSafe.
end.


procedure lexml.

def input parameter vlcsaida as longchar.

def var Hdoc      as handle.
def var Hroot     as handle.

create x-document HDoc.
if not Hdoc:load("longchar", vLCsaida, false)
then do.
    message "Nao foi possivel tratar retorno WS SAFE" view-as alert-box.
    return.
end.
create x-noderef hroot.
hDoc:get-document-element(hroot).

create respostaSAFE.

run obtemnode (input hroot).

end procedure.

procedure obtemnode.

    def input parameter vh as handle.

    def var hc as handle.
    def var loop  as int.

    create x-noderef hc.
    do loop = 1 to vh:num-children.
        
        vh:get-child(hc,loop).

        
        if hc:subtype = "Element"
        then do:
            if vh:name = "RespostaSAFE"
            then vtabela = vh:name.
        end.

        if hc:subtype = "text"
        then do:
            
            if vtabela = "RespostaSAFE"
            then do.
                
                if vh:name = "MensagemPDV"
                then do.
                    RespostaSAFE.MensagemPDV = hc:node-value.
                end.
                if vh:name = "NSUSafe"
                then do:
                    RespostaSAFE.NSUSafe = hc:node-value.
                end.

            end.
            
        end.
        run obtemnode (input hc:handle).
    end.

end procedure.


