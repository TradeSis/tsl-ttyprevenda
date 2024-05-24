/* medico na tela 042022 - helio */
{admcab.i}

{meddefs.i}

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


run medapibuscaprodutos.p (setbcod).


def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend       as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Seleciona",""].
def var esqcom2         as char format "x(12)" extent 5.


form
    esqcom1
    with frame f-com1
                 row 6 no-box no-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels column 1 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

    form
        ttmedprodu.procod
        ttmedprodu.pronom
        ttmedprodu.idmedico
        ttmedprodu.valorServico
        ttmedprodu.tipoServico
            with frame frame-a 5 down centered row 9 no-box
            no-labels.


bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then run leitura (input "pri").
    else find ttmedprodu where recid(ttmedprodu) = recatu1 no-lock.

    if not available ttmedprodu
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(ttmedprodu).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available ttmedprodu
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        run frame-a.
    end.
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        if not esqvazio
        then do:
            find ttmedprodu where recid(ttmedprodu) = recatu1 no-lock.

            status default
                "Selecione o Produto".
                
            run color-message.
            choose field
                    ttmedprodu.procod
                    help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return) /*color white/black*/ .
            run color-normal.
            status default "".

        end.
            if keyfunction(lastkey) = "TAB"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    color display message esqcom2[esqpos2] with frame f-com2.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    color display message esqcom1[esqpos1] with frame f-com1.
                end.
                esqregua = not esqregua.
            end.
            if keyfunction(lastkey) = "cursor-right"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 5 then 5 else esqpos2 + 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.
                next.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 1 then 1 else esqpos2 - 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.
                next.
            end.
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail ttmedprodu
                    then leave.
                    recatu1 = recid(ttmedprodu).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail ttmedprodu
                    then leave.
                    recatu1 = recid(ttmedprodu).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail ttmedprodu
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail ttmedprodu
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" 
        then do:                      
            
                pprocod = ttmedprodu.procod. 
                leave bl-princ.
        
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(ttmedprodu).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame f-com2  no-pause.
hide frame frame-a no-pause.

procedure frame-a.

    display ttmedprodu.procod
            ttmedprodu.pronom
            ttmedprodu.idmedico
            ttmedprodu.valorservico
            
            with frame frame-a.
            
end procedure.
procedure color-message.
    color display message
            ttmedprodu.procod
            ttmedprodu.pronom
            ttmedprodu.idmedico

            with frame frame-a.
end procedure.

procedure color-normal.

    color display normal
            ttmedprodu.procod
            ttmedprodu.pronom
            ttmedprodu.idmedico
            with frame frame-a.
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
    if par-tipo = "pri" 
    then  
        if esqascend  
        then      
            find first ttmedprodu where
                       no-lock no-error.
        else  
            find last ttmedprodu  where
                      no-lock no-error.
    if par-tipo = "seg" or par-tipo = "down" 
    then      
        if esqascend  
        then  
            find next ttmedprodu  where
                      no-lock no-error.
        else  
            find prev ttmedprodu  where
                      no-lock no-error.
    if par-tipo = "up" 
    then                  
        if esqascend   
        then   
            find prev ttmedprodu  where
                      no-lock no-error.
        else   
            find next ttmedprodu  where 
                  no-lock no-error.

 
end procedure.
         


