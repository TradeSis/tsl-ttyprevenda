/* #082022 helio bau */
def var pnomeapi as char        init "reversa".
def var pnomerecurso as char    init "reversa-fechacaixa".

def input  param pestabOrigem as int.
def input  param pcodCaixa  as int.
def input  param pcatcod    as int.   
def output param pidPedidoGerado as char.
def output param phttp_code as int.
def output param presposta  as char.

def new global shared var setbcod as int.

def var vlcentrada as longchar.
def var vlcsaida as longchar.
def var hsaida as handle.
def var hentrada as handle.

{acentos.i}

/* HANDLE */
{lojreversa.i}

def temp-table ttentrada no-undo serialize-name "reversa"
    field estabOrigem as char 
    field dataPedido    as char     /* "2022-09-15", */
    field codCaixa    as char 
    field pid           as char 
    field categoria   as char
    field idPedidoGerado    as char. /* vai no request para poder enviar para o fechapedido */  
    
define dataset dadosEntrada for ttentrada, ttitens.

def temp-table ttpedidofechado no-undo serialize-name "pedidofechado" 
    field codCaixa     as int 
    field estabOrigem  as int 
    field idPedidoGerado  as char .     
define dataset conteudoSaida for ttpedidofechado. 
                                                                
        
def temp-table ttsaida  no-undo serialize-name "conteudoSaida" 
    field tstatus        as int serialize-name "status" 
    field descricaoStatus      as char.
                                

    
    create ttentrada.
    ttentrada.estabOrigem   = string(pestabOrigem).
    ttentrada.datapedido    = string(year(today)) + "-" + 
                              string(month(today),"99") + "-" +
                              string(day(today),"99").
                              
    ttentrada.codCaixa      = string(pcodCaixa).
    ttentrada.pid           = string(spid).
    ttentrada.categoria     = string(pcatcod,"9999").
    
    hentrada = dataset dadosEntrada:handle.
    hentrada:WRITE-JSON("LONGCHAR", vlcEntrada, TRUE).     
    
    empty temp-table ttpedidofechado.
    hsaida = dataset conteudoSaida:HANDLE.

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
    then vchost = "sv-ca-db-qa". 
    else vchost = "10.2.0.83". 

    vapi = "http://\{IP\}/bsweb/api/lojas/\{codigoFilial\}/reversa-fechacaixa/\{codCaixa\}".
    
    vapi = replace(vapi,"\{IP\}",vchost).
    vapi = replace(vapi,"\{codigoFilial\}",string(setbcod)).
    vapi = replace(vapi,"\{codCaixa\}",string(pcodCaixa)).
    
put stream log unformatted 
    pnomeapi " PID=" spid "_" spidseq " "
    pnomerecurso " " startTime 
    " sh "  vsaida + ".sh" skip.

output to value(vsaida + ".sh").
put unformatted
    "curl -X POST -s -k1 \"" + vapi + "\" " +
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
        
        find first ttpedidofechado no-error.
        if avail ttpedidofechado
        then do: 
            pidPedidoGerado = ttpedidofechado.idPedidoGerado .
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
        message phttp_code removeacento(substring(tterro.retorno,1,50)).
        presposta = tterro.retorno.
        pause 1 no-message.
    end.        
          
    

end.


hide message no-pause.



