/* #082022 helio bau */
def var pnomeapi as char        init "bau".
def var pnomerecurso as char    init "getCliente".

def output param phttp_code as int.
def output param presposta  as char.

def new global shared var setbcod as int.

def var vlcentrada as longchar.
def var vlcsaida as longchar.
def var hsaida as handle.
def var hentrada as handle.

{acentos.i}

    {baudefs.i}
    
    empty TEMP-TABLE ttgetcliente.
    hsaida = TEMP-TABLE ttgetcliente:HANDLE.
                                
def var vsaida as char.

DEF VAR startTime as DATETIME.
def var endTime   as datetime.
startTime = DATETIME(TODAY, MTIME).

def stream log.
output stream log to value("/usr/admcom/logs/api" + pnomeapi + string(today,"99999999") + ".log") append.

put stream log unformatted 
    pnomeapi " PID=" spid "_" spidseq " "
    pnomerecurso " " startTime 
    " ENTRADA->cpf=" + string(pcpf) + " loja=" + string(setbcod) skip.

vsaida  = "/usr/admcom/work/" + replace(pnomeapi," ","") + replace(pnomerecurso," ","") +
            string(today,"999999") + replace(string(time,"HH:MM:SS"),":","") + string(spid) + ".json". 

def var vchost as char.
def var vhostname as char.
def var vapi as char.
input through hostname.
import vhostname.
input close.
    if vhostname = "filial188"
    then vchost = "sv-ca-db-qa". 
    else vchost = "10.2.0.83". 

    vapi = "http://\{IP\}/bsweb/api/bau/cliente/\{cpf\}".
    
    vapi = replace(vapi,"\{IP\}",vchost).
    vapi = replace(vapi,"\{cpf\}",string(pcpf,"99999999999")).
    
put stream log unformatted 
    pnomeapi " PID=" spid "_" spidseq " "
    pnomerecurso " " startTime 
    " sh "  vsaida + ".sh" skip.

output to value(vsaida + ".sh").
put unformatted
    "curl -X GET -s -k1 \"" + vapi + "\" " +
    " -H \"Accept-Charset: ISO-8859-1,utf-8;q=0.7,*;q=0.7\" " +
    " -H \"Content-Type: application/json\" " +
    " --connect-timeout 15 --max-time 15  " + 
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

if phttp_code = 200 or phttp_code = 404
then do:

    if phttp_code = 200
    then do:
        hSaida:READ-JSON("longchar",vLCSaida, "EMPTY").
        find first ttgetcliente no-error.
        if avail ttgetcliente
        then do:
            ttgetcliente.dtnasc = date(int(entry(2,dataNascimento,"/")),int(entry(1,dataNascimento,"/")), int(entry(3,dataNascimento,"/"))).
            ttgetcliente.nome           = removeacento(ttgetcliente.nome).
            ttgetcliente.sobrenome      = removeacento(ttgetcliente.sobrenome).
            ttgetcliente.endereco       = removeacento(ttgetcliente.endereco).
        end.
        
    end.    
    if phttp_code = 404
    then do:
        presposta = "Cliente nao cadastrado na base Bau".
        hide message no-pause. message phttp_code presposta.
        pause 2 no-message.
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
    if avail tterro and trim(tterro.erro) <> ""
    then do:
        hide message no-pause.
        message phttp_code removeacento(tterro.erro).
        presposta = tterro.erro.
        pause 2 no-message.
    end.        

end.


hide message no-pause.



