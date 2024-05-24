/* medico na tela 042022 - helio */

def input param petbcod as int.
def var vlcentrada as longchar.
def var vlcsaida as longchar.
def var hsaida as handle.
def var hentrada as handle.
{meddefs.i}

def temp-table ttentrada no-undo serialize-name "dadosEntrada"
    field codigoFilial as char.
create ttentrada.
ttentrada.codigoFilial = string(petbcod).
   
hentrada = TEMP-TABLE ttentrada:HANDLE.
hentrada:WRITE-JSON("LONGCHAR", vlcEntrada, TRUE).   
   
hsaida = DATASET medicoSaida:HANDLE.
                                
def var vsaida as char.
def var vresposta as char.

vsaida  = "/usr/admcom/work/medapibuscaprodutos" + string(today,"999999") + replace(string(time,"HH:MM:SS"),":","") + ".json". 

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
    "curl -X POST -s \"http://" + vchost + "/bsweb/api/medico/buscaProdutos" + "\" " +
    " -H \"Content-Type: application/json\" " +
    " -d '" + string(vLCEntrada) + "' " + 
    " -o "  + vsaida.
output close.


hide message no-pause.
message "Aguarde... Fazendo Busca Produtos no Matriz...".
pause 1 no-message.
unix silent value("sh " + vsaida + ".sh " + ">" + vsaida + ".erro").
unix silent value("echo \"\n\">>"+ vsaida).

input from value(vsaida) no-echo.
import unformatted vresposta.
input close.

vLCsaida = vresposta.

hSaida:READ-JSON("longchar",vLCSaida, "EMPTY").
/*
            unix silent value("rm -f " + vsaida). 
            unix silent value("rm -f " + vsaida + ".erro"). 
            unix silent value("rm -f " + vsaida + ".sh"). 
*/
hide message no-pause.



