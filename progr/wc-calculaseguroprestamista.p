/* helio 112022 - campanha seguro prestamista gratis */
/* helio 20012022 - [UNIFICAÇÃO ZURICH - FASE 2] NOVO CÁLCULO PARA SEGURO PRESTAMISTA MÓVEIS NA PRÉ-VENDA */

def var vLCEntrada as longchar.
def var vLCSaida   as longchar.

DEFINE VARIABLE lokJSON                  AS LOGICAL.

{jsonprestamista.i}


lokJSON = hEntrada:WRITE-JSON("longchar",vLCEntrada, TRUE).

def var vsaida as char.

def var ppid as char.
def var vchost as char.
def var vhostname as char.
def var wurl as char.

input through hostname.
import unformatted vhostname.
input close. 

INPUT THROUGH "echo $PPID".
DO ON ENDKEY UNDO, LEAVE:
IMPORT unformatted ppid.
END.
INPUT CLOSE.

    vsaida  = "/usr/admcom/work/calculaseguroprestamista" + string(today,"999999") + replace(string(time,"HH:MM:SS"),":","") + 
                    trim(ppid) + ".json". 
    
    if vhostname = "filial188"  
    then vchost = "sv-ca-db-qa".  
    else vchost = "10.2.0.83".


    wurl = "http://" + vchost + "/bsweb/api/prestamista/calculaSeguroPrestamista".
                
    output to value(vsaida + ".sh").
    put unformatted
        "curl -X POST -s \"" + wURL + ""\" " +
        " -H \"Content-Type: application/json\" " +
        " -d '" + string(vLCEntrada) + "' " + 
        " -o "  + vsaida.
    output close.

    unix silent value("sh " + vsaida + ".sh " + ">" + vsaida + ".erro").

    COPY-LOB FILE vsaida  TO vlcsaida.
    
    unix silent value("rm -f " + vsaida). 
    unix silent value("rm -f " + vsaida + ".erro"). 
    unix silent value("rm -f " + vsaida + ".sh"). 
   
    lokJSON = hSaida:READ-JSON("longchar",vLCSaida, "EMPTY") no-error.

     


 
