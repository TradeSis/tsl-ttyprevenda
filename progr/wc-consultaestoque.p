/* helio 01/12/2021 - substituicao do rest-barramento.p pelo curl */ 

def input parameter p-etbcod    as int.
def input parameter p-procod    as int.
    
def var vcJSON as longchar.
/***
vcjson = "\{
    \"consultaEstoqueEntrada\": \{
            \"codigoEstabelecimento\": \"" + string(p-etbcod) + "\",
                    \"codigoProduto\": \"" + string(p-procod) + "\"
                        \}
                        \}".
message string(vcjson) view-as alert-box.
***/

def var vcMetodo as char.
def var vLCEntrada as longchar.
def var vLCSaida   as longchar.
def var vcsaida    as char.

vcMetodo = "consultaEstoqueRestResource".

DEFINE VARIABLE lokJSON                  AS LOGICAL.
def var hconsultaEstoqueEntrada          as handle.
def var hconsultaEstoqueSaida            as handle.
def var hretorno                         as handle.

/* ENTRADA */
DEFINE TEMP-TABLE ttentrada NO-UNDO SERIALIZE-NAME "consultaEstoqueEntrada"
    field codigoEstabelecimento as char 
    field codigoProduto as char.
hconsultaEstoqueEntrada = TEMP-TABLE ttentrada:HANDLE.

{wc-consultaestoque.i}


    
DEFINE DATASET consultaEstoqueSaida FOR ttestoque, ttretorno.
hconsultaEstoqueSaida = DATASET consultaEstoqueSaida:HANDLE.
/*
DEFINE DATASET dsretorno SERIALIZE-NAME "consultaEstoqueSaida"
    FOR ttretorno.
hretorno = DATASET dsretorno:HANDLE.
*/



create ttentrada.
ttentrada.codigoEstabelecimento = if p-etbcod = 0
                                  then "*"
                                  else string(p-etbcod).
ttentrada.codigoProduto         = string(p-procod).


lokJSON = hconsultaEstoqueEntrada:WRITE-JSON("longchar",vLCEntrada, TRUE).

def var hsaida as handle.

def var vsaida as char.
def var vresposta as char.

vsaida  = "estoque" + string(today,"999999") + replace(string(time,"HH:MM:SS"),":","") + ".json". 

    def var vchost as char.
    def var vhostname as char.
    input through hostname.
    import vhostname.
    input close.
        if vhostname = "filial188" 
        then vchost = "172.19.130.11:5555". 
        else vchost = "172.19.130.175:5555". /* era=172.19.130.5:5555, mudanca em 18042022 */
                
    output to value(vsaida + ".sh").
    put unformatted
        "curl -X POST -s \"http://" + vchost + "/gateway/pdvRestAPI/1.0/" + vcMetodo + "\" " +
        " -H \"Content-Type: application/json\" " +
        " -d '" + string(vLCEntrada) + "' " + 
        " -o "  + vsaida.
    output close.

    hide message no-pause.
    message "Aguarde... Buscando estoques  no barramento...".

    unix silent value("sh " + vsaida + ".sh " + ">" + vsaida + ".erro").
    /*unix silent value("echo \"\n\">>"+ vsaida).*/

    COPY-LOB FILE vsaida  TO vlcsaida.

            unix silent value("rm -f " + vsaida). 
            unix silent value("rm -f " + vsaida + ".erro"). 
            unix silent value("rm -f " + vsaida + ".sh"). 
            hide message no-pause.





lokJSON = hconsultaEstoqueSaida:READ-JSON("longchar",vLCSaida, "EMPTY") no-error.

     
find first ttestoque no-error.
if not avail ttestoque
then do:
    /*
    vcsaida  = string(vLCSaida).
    vcSaida  = replace(vcsaida,"\"estoque\":[],",""). 
    vcSaida  = replace(vcsaida,"\"statusRetorno\":","\"statusRetorno\":[").
    vcSaida  = replace(vcsaida,"\}\}\}","\}]\}\}").
    vlcsaida = vcSaida.
    
    hretorno:READ-JSON("longchar",vLCSaida, "EMPTY").
    
    */
    find first ttretorno no-error.
    if avail ttretorno
    then do:
        hide message no-pause.
        message ttretorno.descricao.
        pause 1 no-message.
    end.
    
end.


 
