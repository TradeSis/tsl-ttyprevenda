/* helio 10042023 - cashb por cliente */

def new global shared var spid as int.
def new global shared var spidseq as int.

def var pnomeapi as char        init "lojas-cupomb2b".
def var pnomerecurso as char    init "consulta".

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
def shared temp-table ttentrada serialize-name "cupomb2b" 
    field estabOrigem   as int 
    field idCupom       as int
    field clicod        as int.
        
def shared temp-table ttitens serialize-name "itens"  
    field codigoProduto as int 
    field quantidade    as int 
    field valorUnitario as dec.
    
def shared temp-table ttcupomb2b no-undo serialize-name "cupomb2b" 
    field estabOrigem   as int 
    field idCupom       as int 
    field categoria     as int 
    field subclasse     as int 
    field valorDesconto as dec 
    field percentualDesconto as dec 
    field dataValidade  as date.


    define dataset dadosEntrada for ttentrada, ttitens.

    hentrada = dataset dadosEntrada:HANDLE.
    hentrada:WRITE-JSON("LONGCHAR", vlcEntrada, TRUE).
     
    hsaida   = temp-table ttcupomb2b:HANDLE.

    find first ttentrada.

def var vsaida as char.

DEF VAR startTime as DATETIME.
def var endTime   as datetime.
startTime = DATETIME(TODAY, MTIME).

def stream log.
output stream log to value("/usr/admcom/logs/api" + pnomeapi + string(today,"99999999") + ".log") append.

put stream log unformatted skip(1)
    pnomeapi " PID=" spid "_" spidseq " "
    pnomerecurso " " startTime 
    " ENTRADA-> loja=" + string(setbcod) 
    " cupomloja=" + string(ttentrada.idcupom) 
    
    skip.

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

    vapi = "http://\{IP\}/bsweb/api/lojas/\{codigoFilial\}/consultaCupomB2b/\{idCupom\}".
    
    vapi = replace(vapi,"\{IP\}",vchost).
    vapi = replace(vapi,"\{codigoFilial\}",string(setbcod)).
    vapi = replace(vapi,"\{idCupom\}",string(ttentrada.idcupom)).

put stream log unformatted 
    pnomeapi " PID=" spid "_" spidseq " "
    pnomerecurso " " startTime 
    " sh "  vsaida + ".sh" skip.

output to value(vsaida + ".sh").
put unformatted
    "curl -X GET -s -k1 \"" + vapi + "\" " +
    " -H \"Accept-Charset: ISO-8859-1,utf-8;q=0.7,*;q=0.7\" " +
    " -H \"Content-Type: application/json\" " +
    " -d '" + string(vLCEntrada) + "' " +  
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
import unformatted presposta.
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
        find first ttcupomb2b no-error.
        if avail ttcupomb2b
        then do:
        end. 
    
    
    end.
        
    unix silent value("rm -f " + vsaida).  
    unix silent value("rm -f " + vsaida + ".erro").  
    unix silent value("rm -f " + vsaida + ".sh"). 
    
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
        pause 3 no-message.
    end.        
          
    

end.

hide message no-pause.


