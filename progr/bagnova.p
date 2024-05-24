/* bag 102022 - helio */

{admcab.i}
{bagdefs.i new}
def var presposta as char.
def var phttp_code as int.

INPUT THROUGH "echo $PPID".
DO ON ENDKEY UNDO, LEAVE:
IMPORT unformatted spid.
END.
INPUT CLOSE.
spidseq = spidseq + 1.


def var ctitle as char.
ctitle = "Bags abertas     - BAG".

def var vhelp as char.
def var xtime as int.
def var vconta as int.
def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(11)" extent 6
    initial ["conteudo","nova Bag"," ",""].

form
    esqcom1
    with frame f-com1 row 5 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.
def var vhralt as char.
form
        ttbaglistagem.estabOrigem column-label "fil" format ">>9"
        ttbaglistagem.consultor  column-label "vend" format ">>>>>9"
        ttbaglistagem.idbag   column-label "bag" format ">>>9"     
        ttbaglistagem.cpf   column-label "cpf" format "99999999999"
        ttbaglistagem.nome  column-label "cliente" format "x(10)"
        
        ttbaglistagem.dtalt column-label "dt digt" format "99999999"
        vhralt column-label "hr" format "x(5)"
        
        ttbaglistagem.pid format ">>>>>9"        
        with frame frame-a 9 down centered row 7
        no-box.


    disp 
        ctitle format "x(70)" no-label
        with frame ftit
            side-labels
            row 3
            centered
            no-box
            color messages.

def var pmensagem as char.

empty temp-table ttbaglistagem.
run montatt (output pmensagem).

if pmensagem <> ""
then do:
    message pmensagem view-as alert-box.
    return.
end.
recatu1 = ?.

bl-princ:
repeat:
    

    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find ttbaglistagem where recid(ttbaglistagem) = recatu1 no-lock.
    if not available ttbaglistagem
    then do.
        message "nenhuma Bag aberta, deseja abrir?" update sresp.
        if not sresp then return.
                run bagabre.p .
                run montatt (output pmensagem).
                find first ttbaglistagem no-error.
                if not avail ttbaglistagem
                then return.
                recatu1 = ?.
                next.

    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(ttbaglistagem).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available ttbaglistagem
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find ttbaglistagem where recid(ttbaglistagem) = recatu1 no-lock.

        esqcom1[1] = "conteudo". 
        esqcom1[5] = " ". 
        esqcom1[3] = "". 
/*        esqcom1[4] = "historico". */

        status default "".
        
                        
        /*             
        def var vx as int.
        def var va as int.
        va = 1.
        do vx = 1 to 6.
            if esqcom1[vx] = ""
            then next.
            esqcom1[va] = esqcom1[vx].
            va = va + 1.  
        end.
        vx = va.
        do vx = va to 6.
            esqcom1[vx] = "".
        end.     
        */
    hide message no-pause.
    /*    
    if ttbaglistagem.titdescjur <> 0
    then do:
        if ttbaglistagem.titdescjur > 0
        then do:
                message color normal 
            "juros calculado em" ttbaglistagem.dtinc "de R$" trim(string(ttbaglistagem.titvljur + ttbaglistagem.titdescjur,">>>>>>>>>>>>>>>>>9.99"))    
            " dispensa de juros de R$"  trim(string(ttbaglistagem.titdescjur,">>>>>>>>>>>>>>>>>9.99")).
        end.
        else do:
            message color normal 
            "juros calculado em" ttbaglistagem.dtinc "de R$" trim(string(ttbaglistagem.titvljur + ttbaglistagem.titdescjur,">>>>>>>>>>>>>>>>>9.99"))    

            " juros cobrados a maior R$"  trim(string(ttbaglistagem.titdescjur * -1 ,">>>>>>>>>>>>>>>>>9.99")).
        
        end.
        
    end.
    */    
        
        disp esqcom1 with frame f-com1.
        
        run color-message.
        vhelp = "".
        
        
        status default vhelp.
        choose field ttbaglistagem.consultor
                      help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      L l
                      tab PF4 F4 ESC return).

        if keyfunction(lastkey) <> "return"
        then run color-normal.

        hide message no-pause.
                 
        pause 0. 

                                                                
            if keyfunction(lastkey) = "cursor-right"
            then do:
                color display normal esqcom1[esqpos1] with frame f-com1.
                esqpos1 = if esqpos1 = 6 then 6 else esqpos1 + 1.
                color display messages esqcom1[esqpos1] with frame f-com1.
                next.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                color display normal esqcom1[esqpos1] with frame f-com1.
                esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                color display messages esqcom1[esqpos1] with frame f-com1.
                next.
            end.
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail ttbaglistagem
                    then leave.
                    recatu1 = recid(ttbaglistagem).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail ttbaglistagem
                    then leave.
                    recatu1 = recid(ttbaglistagem).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail ttbaglistagem
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail ttbaglistagem
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.
                
                
        if keyfunction(lastkey) = "return"
        then do:
            
            
            if esqcom1[esqpos1] = "nova Bag"
            then do:
                hide frame frame-a no-pause.
                
                pause 0.
                run montatt (output pmensagem).
                if pmensagem <> ""
                then do:
                    message pmensagem view-as alert-box.
                end. 
                else do:
                    run bagabre.p .
                    run montatt (output pmensagem).
               end.
                disp 
                    ctitle 
                        with frame ftit.
                recatu1 = ?.
                leave.
                    
            end.
            
            if esqcom1[esqpos1] = "conteudo"
            then do:
                pause 0.
                run bagprodu.p (ttbaglistagem.cpf, ttbaglistagem.idbag).
                 run montatt (output pmensagem). 
                 recatu1 = ?. 
                 leave.
                
            end.

        end.        
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(ttbaglistagem).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.
hide frame ftit no-pause.
hide frame ftot no-pause.
return.
 
procedure frame-a.
    display  
        ttbaglistagem.estabOrigem
        ttbaglistagem.consultor
        ttbaglistagem.idbag
        ttbaglistagem.dtalt
        string(ttbaglistagem.hralt,"HH:MM")  @ vhralt
        ttbaglistagem.pid 
        ttbaglistagem.cpf
        ttbaglistagem.nome
        with frame frame-a.


end procedure.

procedure color-message.
    color display message
        ttbaglistagem.estabOrigem
        ttbaglistagem.consultor
        ttbaglistagem.idbag
        ttbaglistagem.dtalt
        ttbaglistagem.pid 
                    
        with frame frame-a.
end procedure.


procedure color-input.
    color display input
        ttbaglistagem.estabOrigem
        ttbaglistagem.consultor
        ttbaglistagem.idbag
        ttbaglistagem.dtalt
        ttbaglistagem.pid 
                     
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        ttbaglistagem.estabOrigem
        ttbaglistagem.consultor
        ttbaglistagem.dtalt
        ttbaglistagem.pid 
ttbaglistagem.idbag 
        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.

    if par-tipo = "pri" 
    then do:
        find last ttbaglistagem 
            no-lock no-error.
    end.    
                                             
    if par-tipo = "seg" or par-tipo = "down" 
    then do:
        find prev ttbaglistagem 
            no-lock no-error.
    end.    
             
    if par-tipo = "up" 
    then do:
        find next ttbaglistagem
            no-lock no-error.

    end.  
        
end procedure.






procedure montatt.
def output param presposta as char.    
    
    run bagapiabertas.p (output phttp_code, output presposta).
    if phttp_code <> 401
    then presposta = "".
         
end procedure.
