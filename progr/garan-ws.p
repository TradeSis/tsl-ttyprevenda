/*
    Projeto Garantia/RFQ: out/2017
*/
{admcab.i}

def input parameter par-procod   as int.
def input parameter par-precoori as dec.
def input parameter par-movpc    as dec.

/* para inclusao via WS */
def SHARED temp-table tt-segprodu no-undo
    field sequencia  as char
    field seg-procod as int
    field tipo       as char
    field Meses      as int
    field prvenda    as dec
    field ramo       as int
    field padrao     as log
    field p2k-datahoraprodu as char
    field p2k-id_seguro     as int
    field p2k-datahoraplano as char.
    
empty temp-table tt-segprodu.

/***
    Webservice
***/
def var vip         as char.
def var vwebservice as char.
def var vparametros as char.
def var varqretorno as char.


vip = "".
run lemestre.p (input "IPSAFE", output vip).     

if vip = "" or vip = ?
then do:
    if setbcod = 189 or setbcod = 188
    then vip = "10.145.0.191". /* 09052023 HELIO "10.2.0.191". */
    else vip = "10.2.0.195". /* Producao */
end.

message "Consultando webservice P2K SAFE " + vip.

vwebservice = vip + "/ws-safe/optimus.asmx/ConsultaProdutoGarantia7C".

vparametros = "codigoLoja="       + string(setbcod,"9999") +
              "&pdv=001" +
              "&estabelecimento=" + string(setbcod,"9999") + fill(" ", 11) +
              "&codigoProduto="   + string(par-procod) +
              "&valorTransacao="  + string(par-movpc).

varqretorno = "/usr/admcom/relat/seguro_" + string(par-procod) + "_" +
              string(mtime).
/*
unix silent value("wget \"" + vwebservice +
                  "?" + vparametros + "\"" +
                  " --timeout=10 " + " -O " + varqretorno + " -q").
*/
unix silent value("wget -q -T 10 --timeout=10 -O " + varqretorno +
                  " \"" + vwebservice + "?" + vparametros + "\"").

/***
    Tratamento do retorno
***/
def var Hdoc      as handle.
def var Hroot     as handle.
def var vtabela   as char.
def var vtag-pai  as char.
def var vseq      as int.
def var vdatahora as char.

hide message no-pause.
message "Tratando retorno WS SAFE".

FILE-INFO:FILE-NAME = varqretorno.
if FILE-INFO:FILE-SIZE < 100
then do.
    message "Sem conexao com WS SAFE" view-as alert-box.
    return.
end.

create x-document HDoc.
if not Hdoc:load("file", varqretorno, false)
then do.
    message "Nao foi possivel tratar retorno WS SAFE" view-as alert-box.
    return.
end.
create x-noderef hroot.
hDoc:get-document-element(hroot).

run obtemnode (input hroot).

if setbcod <> 188
then unix silent rm -f value(varqretorno).

hide message no-pause.

/***
    Convertendo para Admcom
***/
def var vproindice like produ.proindice.
def buffer bprodu for produ.

for each tt-segprodu.
    vproindice = string(tt-segprodu.ramo) + "," +
                 tt-segprodu.tipo + "," +
                 string(tt-segprodu.meses).
    
    find first bprodu where bprodu.proindice = vproindice no-lock no-error.
    if avail bprodu
    then tt-segprodu.seg-procod = bprodu.procod.
    else do.
        message "Nao encontrado produto para" vproindice view-as alert-box.
        delete tt-segprodu.
    end.
end.


procedure obtemnode.

    def input parameter vh as handle.

    def var hc as handle.
    def var loop  as int.

    create x-noderef hc.
    do loop = 1 to vh:num-children.
        vh:get-child(hc,loop).

        if hc:subtype = "Element"
        then do:
            vtag-pai = vh:name.
            if vh:name = "Produto" or
               vh:name = "Planos"
            then vtabela = vh:name.
        end.

        if hc:subtype = "text"
        then do:
            /* message vtabela vh:name. */
            if vtabela = "Produto"
            then
                if vh:name = "DataHoraInclusao"
                then vdatahora = trim(hc:node-value).

            if vtabela = "Planos"
            then do.
                if vtag-pai = "Plano" and
                   vh:name = "Id"
                then do.
                    vseq = vseq + 1.
                    create tt-segprodu.
                    tt-segprodu.p2k-id_seguro = int(hc:node-value).
                    tt-segprodu.sequencia     = string(vseq).
                    tt-segprodu.p2k-datahoraprodu = vdatahora.
                end.

                if vh:name = "CodigoTipoServico" /* R/Y/Q */
                then tt-segprodu.tipo = trim(hc:node-value).

                if vh:name = "Prazo"
                then tt-segprodu.meses = int(hc:node-value).

                if vh:name = "ValorVenda"
                then tt-segprodu.prvenda = dec(hc:node-value).

                if vh:name = "DataHoraInclusaoPlano"
                then tt-segprodu.p2k-datahoraplano = hc:node-value.

                if vh:name = "Default"
                then tt-segprodu.padrao = hc:node-value = "true".

                if vtag-pai = "Ramo" and
                   vh:name = "Id"
                then tt-segprodu.ramo = int(hc:node-value).
            end.
        end.

        run obtemnode (input hc:handle).
    end.

end procedure.

