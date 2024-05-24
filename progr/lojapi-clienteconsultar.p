
def new global shared var spid as int.
def new global shared var spidseq as int.

def var pnomeapi as char        init "lojas".
def var pnomerecurso as char    init "clienteconsultar".

def output  param pclicod    as int.
pclicod = ?.

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
def shared temp-table ttentrada serialize-name "dadosEntrada" 
    field codigoFilial   as int 
    field cpfCnpj        as char 
    field nomeCliente         as char  
    field dataNascimento         as date 
    field telefone       as char.

def temp-table ttconsultarEntrada serialize-name "dadosEntrada" 
    field codigoFilial   as int 
    field codigoCliente  as int 
    field cpfCnpj        as char.   
            
def temp-table ttclien serialize-name "cliente" 
    field codigoFilial   as int 
    field codigoCliente        as int 
    field cpfCnpj        as char 
    field nomeCliente         as char  
    field dataNascimento         as date 
    field telefone       as char.
    
find first ttentrada.
create ttconsultarEntrada.
ttconsultarEntrada.codigoFilial = setbcod.
ttconsultarEntrada.codigoCliente    = ?.
ttconsultarEntrada.cpfCnpj      = ttentrada.cpfCnpj.


    hentrada = temp-table ttconsultarEntrada:HANDLE.
    hentrada:WRITE-JSON("LONGCHAR", vlcEntrada, TRUE).
     
    hsaida   = temp-table ttclien:HANDLE.
                                
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
    then do:
        vchost = "sv-ca-db-qa". 
    end.        
    else vchost = "10.2.0.83". 

    vapi = "http://\{IP\}/bsweb/api/lojas/cliente".
    
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
        find first ttclien no-error.
        if avail ttclien
        then do:
            pclicod = ttclien.codigocliente.
            if pclicod <> ?
            then do on error undo: /* cadastra localmente */ 
                find clien where clien.clicod = pclicod exclusive no-error.
                if not avail clien
                then do:
                   
                    create clien. 
                    assign 
                        clien.clicod = pclicod . 
                        clien.tippes = yes. 
                        clien.etbcad = setbcod. 
                end.                        
                    clien.ciccgc = string(ttclien.cpfCnpj). 
                    clien.clinom = string(ttclien.nomeCliente). 
                        clien.dtnasc = ttclien.dataNascimento. 
                    clien.fone = ttclien.telefone.
            end.
        end. 
    end.

    unix silent value("rm -f " + vsaida).  
    unix silent value("rm -f " + vsaida + ".erro").  
    unix silent value("rm -f " + vsaida + ".sh"). 

end.
/* Nao precisa mensagem de erro
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
*/

hide message no-pause.



