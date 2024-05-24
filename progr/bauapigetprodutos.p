/* #082022 helio bau */
def var pnomeapi as char        init "bau".
def var pnomerecurso as char    init "buscaProdutos".

def output param phttp_code as int.

def new global shared var setbcod as int.

def var vlcentrada as longchar.
def var vlcsaida as longchar.
def var hsaida as handle.
def var hentrada as handle.

{acentos.i}

    {baudefs.i}
/* HANDLE */
    def temp-table ttentrada no-undo serialize-name "dadosEntrada"
        field codigoFilial as char.
    create ttentrada.
    ttentrada.codigoFilial = string(setbcod).
   
    hentrada = TEMP-TABLE ttentrada:HANDLE.
    hentrada:WRITE-JSON("LONGCHAR", vlcEntrada, TRUE).   
   
    hsaida = DATASET bauSaida:HANDLE.
                                
def var vsaida as char.
def var vresposta as char.

DEF VAR startTime as DATETIME.
def var endTime   as datetime.
startTime = DATETIME(TODAY, MTIME).

def stream log.
output stream log to value("/usr/admcom/logs/api" + pnomeapi + string(today,"99999999") + ".log") append.

put stream log unformatted 
    pnomeapi " PID=" spid "_" spidseq " "
    pnomerecurso " " startTime 
    " ENTRADA->loja=" + string(setbcod) skip.

vsaida  = "/usr/admcom/work/" + replace(pnomeapi," ","") + replace(pnomerecurso," ","") +
            string(today,"999999") + replace(string(time,"HH:MM:SS"),":","") + string(spid) + ".json". 

def var vchost as char.
def var vhostname as char.
def var vapi as char.
input through hostname.
import vhostname.
input close.

/* HOST API */
    if vhostname = "filial188"
    then vchost = "sv-ca-db-qa". 
    else vchost = "10.2.0.83". 

    vapi = "http://\{IP\}/bsweb/api/bau/buscaProdutos".
            
    vapi = replace(vapi,"\{IP\}",vchost).
    
put stream log unformatted 
    pnomeapi " PID=" spid "_" spidseq " "
    pnomerecurso " " startTime 
    " sh "  vsaida + ".sh" skip.

output to value(vsaida + ".sh").
put unformatted
    "curl -X GET -s -k1 \"" + vapi + "\" " +
/*    " -H \"Accept-Charset: ISO-8859-1,utf-8;q=0.7,*;q=0.7\" " + */
    " -H \"Content-Type: application/json\" " +
/*    pBearer +        */
    " -d '" + string(vLCEntrada) + "' " + 
    " --connect-timeout 15  --max-time 15 " + 
    " -w \"%\{response_code\}\" " +
    " -o "  + vsaida.
output close.

hide message no-pause.
    message "Aguarde... executando " pnomeapi + "/" pnomerecurso "em " vchost.

put stream log unformatted 
    pnomeapi " PID=" spid "_" spidseq " "
    pnomerecurso " " startTime 
    " curl GET " vapi skip.

unix silent value("sh " + vsaida + ".sh " + ">" + vsaida + ".erro").
unix silent value("echo \"\n\">>"+ vsaida).
unix silent value("echo \"\n\">>"+ vsaida + ".erro").

put stream log unformatted 
    pnomeapi " PID=" spid "_" spidseq " "
    pnomerecurso " " startTime 
    " json "  vsaida skip.

input from value(vsaida + ".erro") no-echo.
import unformatted phttp_code.
input close.
put stream log unformatted  
    pnomeapi " PID=" spid "_" spidseq " "
    pnomerecurso " " startTime 
    " HTTP_CODE->"  phttp_code if phttp_code = 0 then " TIMEOUT" else "" skip.

input from value(vsaida) no-echo.
import unformatted vresposta.
input close.

put stream log unformatted  
    pnomeapi " PID=" spid "_" spidseq " "
    pnomerecurso " " startTime 
    " SAIDA->" + vresposta skip.

endTime = DATETIME(TODAY, MTIME).

def var xtime as int.

xtime = INTERVAL( endTime, startTime,"milliseconds").

put stream log unformatted  
    pnomeapi " PID=" spid "_" spidseq " "
    pnomerecurso " " startTime 
    " FINAL DA EXECUCAO>" endTime  "  tempo da api em milissegundos=>" string(xtime) skip.

/**    vresposta = '\{\"getcliente\": [' + vresposta + ' \} ] \}'. **/
 
vLCsaida = vresposta.

hSaida:READ-JSON("longchar",vLCSaida, "EMPTY").


    /** TESTE TT - TRATAMENTO DE DADOS */
    find first ttbauprodu no-error.
    if avail ttbauprodu
    then do:
        pprocod = ttbauprodu.procod.
    end.

if phttp_code = 200
then do:
    /*
            unix silent value("rm -f " + vsaida). 
            unix silent value("rm -f " + vsaida + ".erro"). 
            unix silent value("rm -f " + vsaida + ".sh"). 
    */
end.

hide message no-pause.



