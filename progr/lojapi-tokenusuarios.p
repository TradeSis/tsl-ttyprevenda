
def new global shared var spid as int.
def new global shared var spidseq as int.

def var pnomeapi as char        init "vendas-token".
def var pnomerecurso as char    init "token-usuarios".

def var phttp_code as int.
def var presposta   as char.

def new global shared var setbcod as int.

def var vlcentrada as longchar.
def var vlcsaida as longchar.
def var hsaida as handle.
def var hentrada as handle.

{acentos.i}
def temp-table tterro no-undo serialize-name "return"
    field pstatus as char serialize-name "status"
    field retorno  as char.
 
/* HANDLE */
def shared temp-table ttusertoken serialize-name "usuarios"  
    field idUsuario     as char.
                                
     
hsaida   = temp-table ttusertoken:HANDLE.
                                
def var vsaida as char.

DEF VAR startTime as DATETIME.
def var endTime   as datetime.
startTime = DATETIME(TODAY, MTIME).

def stream log.
output stream log to value("/usr/admcom/logs/api" + pnomeapi + string(today,"99999999") + ".log") append.

put stream log unformatted skip(1)
    pnomeapi " PID=" spid "_" spidseq " "
    pnomerecurso " " startTime 
    " ENTRADA-> loja=" + string(setbcod) skip.

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
    then vchost = "10.145.0.60". 
    else vchost = "10.2.0.221". 

    vapi = "http://\{IP\}/tslebes/api/vendas/token".
    vapi = replace(vapi,"\{IP\}",vchost).
    
put stream log unformatted 
    pnomeapi " PID=" spid "_" spidseq " "
    pnomerecurso " " startTime 
    " sh "  vsaida + ".sh" skip.

output to value(vsaida + ".sh").
put unformatted
    "curl -X GET -s -k1 \"" + vapi + "\" " +
    " -H \"Accept-Charset: ISO-8859-1,utf-8;q=0.7,*;q=0.7\" " +
    " -H \"Content-Type: application/json\" " +
/*    " -d '" + string(vLCEntrada) + "' " +   */
    " --connect-timeout 15 --max-time 15 " + 
    " -w \"%\{response_code\}\" " +
/*    " --dump-header " + vsaida + ".header " + */
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
    " HTTP_CODE->"  phttp_code skip.

input from value(vsaida) no-echo.
repeat:
    import unformatted presposta.
    if presposta <> ""
    then leave.
end.    
input close.

put stream log unformatted  
    pnomeapi " PID=" spid "_" spidseq " "
    pnomerecurso " " startTime 
    " SAIDA->" + presposta skip.

endTime = DATETIME(TODAY, MTIME).

def var xtime as int.

xtime = INTERVAL( endTime, startTime,"milliseconds").

put stream log unformatted  
    pnomeapi " PID=" spid "_" spidseq " "
    pnomerecurso " " startTime 
    " FINAL DA EXECUCAO>" endTime  "  tempo da api em milissegundos=>" string(xtime) skip.

 
vLCsaida = presposta.

if phttp_code = 200 
then do:

    if phttp_code = 200
    then do:

        hSaida:READ-JSON("longchar",vLCSaida, "EMPTY").

        /** TESTE TT - TRATAMENTO DE DADOS */
        find first ttusertoken no-error.
        if avail ttusertoken
        then do:
        end. 
    
    
    end.
    /*
    unix silent value("rm -f " + vsaida).  
    unix silent value("rm -f " + vsaida + ".erro").  
    unix silent value("rm -f " + vsaida + ".sh"). 
    */
end.
else do:
    
    hsaida = TEMP-TABLE tterro:HANDLE.
    presposta = "\{\"return\" : [ "  + presposta + " ] \}".
    vLCSaida = presposta.
    hSaida:READ-JSON("longchar",vLCSaida, "EMPTY").
    find first tterro no-error.
    if avail tterro and trim(tterro.retorno) <> ""
    then do:
        hide message no-pause.
        message phttp_code removeacento(tterro.retorno).
        presposta = tterro.retorno.
        pause 2 no-message.
    end.        
          
    

end.


hide message no-pause.



