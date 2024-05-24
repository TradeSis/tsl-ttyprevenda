/* helio02082023 - INCLUIR CAMPO TEMPO DE GARANTIA NA PRÉ VENDA - PROCESSO 521910 */

/* helio 06022023 - cria registro estoq quando este nao existir na base */
/* helio #092022 - LIGA/DESLIGA api consultarproduto + CACHE  api consultarproduto */
/* helio 1106222 - consultar produto no barramento  */
/*
{"dadosEntrada":[{"loja":"188","produto":"586726"}]}
*/
def input param petbcod as int.
def input param pprocod as int.

/* #092022 */
def shared var vapiconsultarproduto as log format "Ligado/Desligado".
/* #092022 */

def var phttp_code as int.

def var vdec as dec.
def var vint as int.
def var vdate as date.

def buffer atu-produ for produ.
def buffer atu-estoq for estoq.

def var vstatusitem as char. 
def var vnovo_statusitem as char.
        
FUNCTION acha2 returns character
    (input par-oque as char, 
     input par-onde as char). 
      
    def var vx as int. 
    def var vret as char.  
    vret = ?.  
    do vx = 1 to num-entries(par-onde,"|"). 
        if num-entries( entry(vx,par-onde,"|"),"#") = 2 and
                entry(1,entry(vx,par-onde,"|"),"#") = par-oque
        then do: 
            vret = entry(2,entry(vx,par-onde,"|"),"#"). 
            leave. 
        end. 
    end. 
    return vret. 
END FUNCTION.



DEF VAR startTime as DATETIME.
def var endTime   as datetime.
startTime = DATETIME(TODAY, MTIME).

/*log_datahora_ini = string(today,"99999999") + replace(string(xtime,"HH:MM:SS"),":","").*/
def stream log.
output stream log to value("/usr/admcom/logs/apipdv_consultarProduto" + string(today,"99999999") + ".log").

def temp-table ttprodutoloja no-undo serialize-name "produtoLoja"
  field codigoProduto as char
  field etbcod               as char serialize-name "codigoLoja"
  field statusItem  as char
  field tipo       as char
  field tempoGarantia    as char
  field pedidoEspecial    as char
  field mercadologico        as char
  field dataInclusao    as char
  field idServicoHubSeg   as char
  field precoCusto as char
  field precoRegular       as char
  field precoRemarcado   as char
  field precoPraticado    as char
  field precoPromocional        as char
  field dataInicialPromocao   as char format "x(10)"
  field dataFinalPromocao   as char format "x(10)"
    field codTributacao as char
    field cfop as char
    field aliquotaIcms as char
    field aliquotaPis as char
    field aliquotaCofins as char
    field cst as char
    field cstPis as char
    field cstCofins as char
    field aliquotaIcmsEfetivo as char
    field aliquotaFundoCombatePobreza as char
    field percentualImpostoMedio as char
    field percentualImpostoMedioFederal as char
    field percentualImpostoMedioEstadual as char
    field percentualImpostoMedioMunicipal as char
    field codigoCbenef as char
    field percentualBaseReduzida as char.

def temp-table tterro no-undo serialize-name  "erro"
   field pstatus as char serialize-name "status"
   field descricao as char .

def var vlcentrada as longchar.
def var vlcsaida as longchar.
def var hsaida as handle.
def var hEntrada as handle.


put stream log unformatted 
startTime "-ENTRADA->produto=" + string(pprocod) + " loja=" + string(petbcod) skip.

put stream log unformatted 
startTime "-FLAG->" + string(vapiconsultarproduto,"LIGADO/DESLIGADO") skip.
if not vapiconsultarproduto
then return.

find apipdvconsultarproduto where apipdvconsultarproduto.procod = pprocod no-lock no-error.
if not avail apipdvconsultarproduto
then do on error undo:
    create apipdvconsultarproduto.
    apipdvconsultarproduto.procod = pprocod.
    apipdvconsultarproduto.dtultima = today.
    apipdvconsultarproduto.hrultima = time.

    put stream log unformatted 
        startTime "-NOVO CACHE->" + string(pprocod) " " string(apipdvconsultarproduto.dtultima,"99/99/9999") " "
                                                        string(apipdvconsultarproduto.hrultima,"HH:MM:SS")
                                                        skip.
end.
else do: 
    put stream log unformatted 
                startTime "-ULTIMO CACHE->" + string(pprocod) " " string(apipdvconsultarproduto.dtultima,"99/99/9999") " "
                                                        string(apipdvconsultarproduto.hrultima,"HH:MM:SS")
                                                        
                                                        " " if apipdvconsultarproduto.dtultima = today
                                                            then string(time - apipdvconsultarproduto.hrultima,"HH:MM:SS")
                                                            else ""
                                                        
                                                        skip.

    if apipdvconsultarproduto.dtultima <> today
    then do on error undo:
        find current apipdvconsultarproduto exclusive no-wait no-error.
        if avail apipdvconsultarproduto
        then do:
            apipdvconsultarproduto.dtultima = today.
            apipdvconsultarproduto.hrultima = time.
            put stream log unformatted 
                startTime "-NOVO CACHE DO DIA->" + string(pprocod) " " string(apipdvconsultarproduto.dtultima,"99/99/9999") " "
                                                        string(apipdvconsultarproduto.hrultima,"HH:MM:SS")
                            skip.
        end.
    end.
    else do:
        if time - apipdvconsultarproduto.hrultima > (60 * 60)
        then do:
            find current apipdvconsultarproduto exclusive no-wait no-error.
            if avail apipdvconsultarproduto
            then do:
                apipdvconsultarproduto.dtultima = today.
                apipdvconsultarproduto.hrultima = time.
                put stream log unformatted 
                    startTime "-ATUALIZANDO CACHE->" + string(pprocod) " " string(apipdvconsultarproduto.dtultima,"99/99/9999") " "
                                                        string(apipdvconsultarproduto.hrultima,"HH:MM:SS") " "
                                                        string(time - apipdvconsultarproduto.hrultima)
                            skip.
            end.
        end.
        else do:
            return.
        end.
    end.
end.

/*hEntrada = TEMP-TABLE ttentrada:HANDLE.
hEntrada:WRITE-JSON("longchar",vLCEntrada, false).*/
                                
def var vsaida as char.
def var vresposta as char.
def var vapi as char.
    def var vchost as char.
    def var vhostname as char.
    input through hostname.
    import vhostname.
    input close.
    
/*    vapi = "http://172.19.130.11:5555/gateway/pre-venda-api/1.0/lojas/188/produtos/586726.*/
    vapi = "http://\{IP\}/gateway/pre-venda-api/1.0/lojas/\{codigoLoja\}/produtos/\{codigoProduto\}".
    
    
    if vhostname = "filial188"
    then vchost = "172.19.130.11:5555". 
    else vchost = "172.19.130.175:5555". 
    
    vapi = replace(vapi,"\{IP\}",vchost).
    vapi = replace(vapi,"\{codigoLoja\}",string(petbcod)).
    vapi = replace(vapi,"\{codigoProduto\}",string(pprocod)).

vsaida  = "/usr/admcom/work/pdvapiconsultarproduto" + string(today,"999999") + replace(string(time,"HH:MM:SS"),":","") + ".json". 

output to value(vsaida + ".sh").
put unformatted
    "curl -X GET -s \"" + vapi + "\" " +
    " -H \"Content-Type: application/json\" " +
/*    " -d '" + string(vLCEntrada) + "' " + */
    " --connect-timeout 7  --max-time 7 " + /* helio 05072022 colocado timeout */
    " -w \"%\{response_code\}\" " +
    " -o "  + vsaida.
output close.

hide message no-pause.
message "Aguarde... consultando produto " pprocod "...". 

put stream log unformatted  
startTime "-REQUEST-" + vapi
                            skip.

unix silent value("sh " + vsaida + ".sh " + ">" + vsaida + ".erro").
unix silent value("echo \"\n\">>"+ vsaida).
unix silent value("echo \"\n\">>"+ vsaida + ".erro").

input from value(vsaida + ".erro") no-echo.
import unformatted phttp_code.
input close.


put stream log unformatted  
    startTime 
    " HTTP_CODE->"  phttp_code if phttp_code = 0 then " TIMEOUT" else "" skip.
if phttp_code = 0
then do:
    vapiconsultarproduto = no.
    put stream log unformatted 
    startTime "-FLAG->" + string(vapiconsultarproduto,"LIGADO/DESLIGADO") skip.
end.

if phttp_code = 200
then do:
    input from value(vsaida) no-echo.
    import unformatted vresposta.
    input close.

    put stream log unformatted  startTime "-SAIDA->" + vresposta skip.

    endTime = DATETIME(TODAY, MTIME).

    def var xtime as int.

    xtime = INTERVAL( endTime, startTime,"milliseconds").

    put stream log unformatted  startTime "-FINAL DA EXECUCAO>" endTime 
        "  tempo da api em milissegundos=>" string(xtime) skip.

    hsaida = temp-table ttprodutoLoja:handle.
    vLCsaida = vresposta.

    hSaida:READ-JSON("longchar",vLCSaida, "EMPTY") no-error.

    find first ttprodutoloja where ttprodutoloja.codigoproduto = string(pprocod)
        no-error.
    if avail ttprodutoloja    
    then do:                
        find atu-produ where atu-produ.procod = pprocod exclusive no-wait no-error.
        if avail atu-produ
        then do:        
            vstatusitem = acha2("statusItem",atu-produ.indicegenerico).
            if vstatusitem = ? then vstatusitem = "".
            if vstatusitem = "BC" then vstatusitem = "Susp.Compra". 
            if vstatusitem = "DE" then vstatusitem = "Descontinuado". 
            
            vnovo_statusItem = if ttprodutoLoja.statusItem = "null" or ttprodutoLoja.statusItem = ?
                               then ""
                               else ttprodutoLoja.statusItem.
            
            atu-produ.indicegenerico = replace(atu-produ.indicegenerico,"statusItem#" + vstatusitem,"statusItem#" + vnovo_statusitem ) .
        end.
        
        find atu-estoq where atu-estoq.procod = pprocod and atu-estoq.etbcod = petbcod exclusive no-wait no-error.
        if not avail atu-estoq
        then do:
            if not locked atu-estoq
            then do:
                /* helio 06022023 https://trello.com/c/44909geA/969-ajuste-na-api-para-criar-registro-de-estoque-pr%C3%A9-venda 
                        criacao de registro estoq */
                create atu-estoq.
                atu-estoq.procod = pprocod.
                atu-estoq.etbcod = petbcod.
                atu-estoq.datexp = today.

                vdec = ?.
                vdec = dec(ttprodutoloja.precopraticado) no-error.
                if vdec <> ? and vdec <> 0 and vdec <> atu-estoq.estvenda 
                then do: 
                    atu-estoq.estvenda  = vdec.
                    atu-estoq.datexp    = today.
                end.    
                
            end.
        end.
        if avail atu-estoq
        then do:
            vdec = ?.
            vdec = dec(ttprodutoloja.precopraticado) no-error.
            if vdec <> ? and vdec <> 0 and vdec <> atu-estoq.estvenda 
            then do: 
                atu-estoq.estvenda  = vdec.
                atu-estoq.datexp    = today.
            end.    
            vdec = ?.
            vdec = dec(ttprodutoloja.precoPromocional) no-error.
                
                if vdec <> ? and vdec <> 0
                then do:
                    if vdec <> atu-estoq.estproper
                    then do: 
                        atu-estoq.estproper = vdec.
                        atu-estoq.estbaldat = ?.
                        atu-estoq.datexp    = today.
                    end.    
                    vdate = ?. 
                    vdate = date(int(entry(2,ttprodutoloja.dataInicialPromocao,"-")),
                                 int(entry(3,ttprodutoloja.dataInicialPromocao,"-")),
                                 int(entry(1,ttprodutoloja.dataInicialPromocao,"-")))                         
                                    no-error.
                     
                    if vdate <> atu-estoq.estbaldat
                    then do:
                        atu-estoq.estbaldat = vdate.
                        atu-estoq.datexp    = today.
                    end.
                    vdate = ?.
                    vdate = date(int(entry(2,ttprodutoloja.dataFinalPromocao,"-")),
                                 int(entry(3,ttprodutoloja.dataFinalPromocao,"-")),
                                 int(entry(1,ttprodutoloja.dataFinalPromocao,"-")))                         
                                    no-error.
                    
                    if vdate <> atu-estoq.estprodat
                    then do:
                        atu-estoq.estprodat = vdate.
                        atu-estoq.datexp    = today.
                    end.  
                    
                end.
                else do:
                        atu-estoq.estbaldat = ?.
                        atu-estoq.estprodat = ?.
                        atu-estoq.estproper = 0.
                        atu-estoq.datexp    = today.
                 end.
                    
                vint = int(ttprodutoloja.cst) no-error.
                if vint <> ? and vint <> atu-estoq.cst
                then do: 
                    atu-estoq.cst  = vint.
                    atu-estoq.datexp    = today.
                end.    
                vdec = dec(ttprodutoloja.aliquotaicms) no-error. /* 18032024 helio ajuste para dec */
                if vdec <> ? and vdec <> atu-estoq.aliquotaicms
                then do: 
                    atu-estoq.aliquotaicms  = vdec.
                    atu-estoq.datexp    = today.
                end.    



        end.
        /* helio 02082023 */
        if ttprodutoloja.tempoGarantia <> ? and ttprodutoloja.tempoGarantia <> ""
        then do on error undo:
            find first produaux where produaux.procod = pprocod and 
                                      produaux.nome_campo = "TempoGar"
                                      no-error.
            if not avail produaux
            then do:
                create produaux.
                produaux.procod = pprocod.
                produaux.nome_campo = "TempoGar".
            end.
            produaux.Valor_Campo = ttprodutoloja.tempoGarantia.
                                      
        end.
        
        
    end.

                unix silent value("rm -f " + vsaida). 
                unix silent value("rm -f " + vsaida + ".erro"). 
                unix silent value("rm -f " + vsaida + ".sh"). 

    
end.     
else do:
        hsaida = temp-table tterro:handle.
        hSaida:READ-JSON("longchar",vLCSaida, "EMPTY") no-error.
    
        find first tterro no-error.
        if avail tterro
        then do:
            put stream log unformatted  startTime "-ERRO> " 
            tterro.pstatus " " tterro.descricao skip.

             hide message no-pause.        
             message tterro.descricao pprocod.
             pause 1 no-message.
         
        end. 
end.
output stream log close.

hide message no-pause.
    
