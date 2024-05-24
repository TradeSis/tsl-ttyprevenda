/* helio 17/08/2021 HubSeguro */
/*VERSAO 1*/


def var vlcentrada as longchar.
def var vlcsaida as longchar.
def var hsaida as handle.

{seg/defhubperfildin.i}

hsaida = TEMP-TABLE ttsegprodu:HANDLE.
                                
def var vsaida as char.
def var vresposta as char.

vsaida  = "segbuscaprodutos" + string(today,"999999") + replace(string(time,"HH:MM:SS"),":","") + ".json". 

    def var vchost as char.
    def var vhostname as char.
    input through hostname.
    import vhostname.
    input close.
    if vhostname = "filial188"
    then vchost = "sv-ca-db-qa". 
    else vchost = "10.2.0.83". 

output to value(vsaida + ".sh").
put unformatted
    "curl -X POST -s \"http://" + vchost + "/bsweb/api/seguro/buscaProdutos" + "\" " +
    " -H \"Content-Type: application/json\" " +
 /*   " -d '" + string(vLCEntrada) + "' " + */
    " -o "  + vsaida.
output close.


hide message no-pause.
message "Aguarde... Fazendo Buscando Seguros no Matriz...".
unix silent value("sh " + vsaida + ".sh " + ">" + vsaida + ".erro").
unix silent value("echo \"\n\">>"+ vsaida).

input from value(vsaida) no-echo.
import unformatted vresposta.
input close.

vLCsaida = vresposta.

hSaida:READ-JSON("longchar",vLCSaida, "EMPTY").


            unix silent value("rm -f " + vsaida). 
            unix silent value("rm -f " + vsaida + ".erro"). 
            unix silent value("rm -f " + vsaida + ".sh"). 

hide message no-pause.

