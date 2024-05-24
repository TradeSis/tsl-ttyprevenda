/* #082022 helio bau */
{admcab.i}
def var presposta as char.
def var phttp_code as int.
def input param ptitle as char.
def var cmensagem as char.

def var pseguevenda as log.

{baudefs.i new}


INPUT THROUGH "echo $PPID".
DO ON ENDKEY UNDO, LEAVE:
IMPORT unformatted spid.
END.
INPUT CLOSE.
spidseq = spidseq + 1.


 
    disp setbcod label "Filial"
         with frame f1 row 3 
            centered title ptitle
            color messages side-labels
            overlay.

    update pvencod  label "Vendedor"
                with frame f1.

    find first func where func.etbcod = setbcod and
                              func.funcod = pvencod
                              no-lock no-error.
                                      
    disp func.funnom no-labels
                with frame f1.    

output to value("/usr/admcom/logs/apibau" + string(today,"99999999") + ".log") append.
put unformatted 
"bau PID=" spid "_" spidseq 
" vendedor " pvencod
    skip.
output close.
    
    run bauapigetprodutos.p (output phttp_code).
    if phttp_code <> 200
    then do:
        hide message no-pause.
        message "api bau - get produto ERRO=" phttp_code.
        pause 2 no-message.
        return.
    end.
    
        find first ttbauprodu where ttbauprodu.procod = pprocod no-lock.
                
        pause 0.
        disp pprocod format ">>>>>>>>9" 
             ttbauprodu.pronom
             ttbauprodu.tipoServico
             
            with frame frame-cab 1 down centered row 5 no-box overlay
            no-labels.

repeat:

    update space(2) pcpf 
    with frame fcabcli row 6 no-box color messages side-labels
    width 46 column 1.

     
output to value("/usr/admcom/logs/apibau" + string(today,"99999999") + ".log") append.
put unformatted 
"bau PID=" spid "_" spidseq 
" cliente " pcpf
    skip.
output close.

    empty TEMP-TABLE ttgetcarne.
    empty TEMP-TABLE ttgetparcelas.
         
    if pcpf <> 0
    then do:
        run bauapigetcliente.p (output phttp_code, output presposta).
        if phttp_code <> 200 
        then do:
            return.
        end.

        find first  ttgetcliente.
        disp ttgetcliente.nome no-labels
            with frame fcabcli.

        run bauapigetcarnes.p (output phttp_code, output presposta).
        if phttp_code <> 200 
        then do:
            undo.
        end.
    
        run bauselcarnes.p  (output pseguevenda, output cmensagem).
    end.
    else do:

        update  space(1) pbaucarne format  "9999999999" 
                with frame fcarne row 6 no-box side-labels color messages
                width 34 column 47.
            if pbaucarne = 0
            then undo.

        output to value("/usr/admcom/logs/apibau" + string(today,"99999999") + ".log") append.
        put unformatted 
        "bau PID=" spid "_" spidseq 
        " carne novo " pbaucarne
            skip.
        output close.
    
        run bauapigetparcelas.p (output phttp_code, output presposta).
        if phttp_code <> 200 
        then do:
            undo.
        end.

        find first ttgetcarne.
    
        if ttgetcarne.carneNovo = yes
        then do:
            hide message no-pause.
            message "carne" pbaucarne "NOVO".
            message trim(ptitle) "NAO PERMITIDA".
            undo.
        end.

        find first ttgetparcelas no-error.
        if avail ttgetparcelas
        then         run bauselparcela.p  (no /* pagamento*/, input-output pseguevenda, output cmensagem).
        else do:
            message "Carne nao encontrado ou totalmente liquidado".
            pause 2.
        end.
 

    end.                
                    
                   
        if pseguevenda and pfincod <> ? 
        then do:

            find finan where finan.fincod = pfincod no-lock.
            if (pfincod = 0 and pmoedapdv <> ?) or pfincod > 0
            then do:
                sresp = yes.
                message "Confirma plano" pfincod finan.finnom pmoedapdv cmensagem update sresp.
                if not sresp
                then undo.
                
                run bauproposta.p.
                           
                leave.        
            end.
        end.

end.                    
