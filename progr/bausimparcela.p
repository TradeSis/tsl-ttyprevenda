/* bau 092022 - helio */
{admcab.i}

def output param cmoedapdv as char.

{baudefs.i}

find first ttbauprodu .

pfincod = ?.
pmoedapdv = ?.


def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqascend     as log initial yes.

recatu1 = ?.
recatu2 = ?.
def var vi as int.
for each ttplanos.
    vi = vi + 1.
end.
if vi = 1
then do:
    find first ttplanos where ttplanos.fincod = 0 no-error.
    if avail ttplanos
    then do:
        pfincod = 0.
        run pmoeda.
        return.
    end.
end. 

bl-princ:
repeat:
    
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find ttplanos  where recid(ttplanos) = recatu1 no-lock.
    
    if not available ttplanos
    then do:
        message "Nenhum plano cadastrado".
        pause 2 no-message.
        leave bl-princ.
    end.
    
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(ttplanos).
    repeat:
        run leitura (input "seg").
        if not available ttplanos
        then leave .

        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    
    up frame-line(frame-a) - 1 with frame frame-a.
    
    
    repeat with frame frame-a:

            find ttplanos  
                        where recid(ttplanos) = recatu1 no-lock.

            run color-message.
            choose field ttplanos.fincod help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return) color message.
            run color-normal.
            status default "".

        if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail ttplanos
                    then leave.
                    recatu1 = recid(ttplanos).
                end.
                leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail ttplanos
                    then leave.
                    recatu1 = recid(ttplanos).
                end.
                leave.
        end.
        if keyfunction(lastkey) = "cursor-down"
        then do:
                run leitura (input "down").
                if not avail ttplanos
                then next.
                color display white/red ttplanos.fincod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
                run leitura (input "up").
                if not avail ttplanos
                then next.
                color display white/red ttplanos.fincod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
        end.
 
        if keyfunction(lastkey) = "end-error"
        then do:
            pfincod = ?.
            leave bl-princ.
        end.
        if keyfunction(lastkey) = "return"
        then do:
            pfincod = ttplanos.fincod.
            run pmoeda.
            leave bl-princ.
        end.
        run frame-a.
        recatu1 = recid(ttplanos).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame frame-a no-pause.
return.

procedure frame-a.
display ttplanos.fincod      column-label "Plano"
        ttplanos.finnom     column-label "Nome Plano" format "x(16)"
        /*
        ttplanos.par-sem-seg column-label "S/Seguro"
        ttplanos.par-com-seg column-label "C/Seguro"
            when ttplanos.par-com-seg > 0
            */
        with frame frame-a 4 down column 50 row 11 no-labels        overlay.
end procedure.
procedure color-message.
color display message
        ttplanos.fincod
        ttplanos.finnom
        /*
        ttplanos.par-com-seg
        ttplanos.par-sem-seg
        */
        with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        ttplanos.fincod
        ttplanos.finnom
        /*
        ttplanos.par-com-seg
        ttplanos.par-sem-seg
        */
        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first ttplanos  where true
                                                no-lock no-error.
    else  
        find last ttplanos   where true
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next ttplanos  where true
                                                no-lock no-error.
    else  
        find prev ttplanos   where true
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev ttplanos  where true  
                                        no-lock no-error.
    else   
        find next ttplanos  where true 
                                        no-lock no-error.
        
end procedure.
         

procedure pmoeda.
            
            pmoedapdv = ?.
            if pfincod = 0
            then do:
                if ttplanos.moedaspdv <> ""
                then do:  
                    hide message no-pause . 
                    bell. 
                    message "Selecione uma moeda de pagamento".

                    def var cmoedas as char format "x(30)" extent 6.
                    def var imoedas as int extent 10. 
                    def var vx as int.
                    
                    cmoedas = "".
                    imoedas = 0.
                    do vx = 1 to num-entries(ttplanos.moedaspdv).
                        if vx > 6
                        then leave.
                        imoedas[vx] = int(entry(vx,ttplanos.moedaspdv)).
                        
                        if imoedas[vx] = 1
                        then cmoedas[vx] = "[Pagamento em Dinheiro]".
                        if imoedas[vx] = 9
                        then cmoedas[vx] = "[Pagamento em Cartao de Debito]".
                        
                    end.
                    pause 0.
                    disp skip(1) cmoedas with frame fcmoedas row 13 column 48  overlay no-labels
                        title " A VISTA - SELECIONE MOEDAS ".
                    choose field cmoedas with frame fcmoedas.
                    pmoedapdv = imoedas[frame-index].
                    cmoedapdv = cmoedas[frame-index].
                end.
            end.
 end procedure.
