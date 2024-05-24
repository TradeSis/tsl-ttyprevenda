def output param pidusuario as char.
            
def new shared temp-table ttusertoken serialize-name "usuarios"  
    field idUsuario     as char.

run lojapi-tokenusuarios.p.


def var recatu1         as recid.

bl-princ:
repeat:

    if recatu1 = ?
    then
        find first ttusertoken where true no-error.
    else
        find ttusertoken where recid(ttusertoken) = recatu1.
    if not available ttusertoken
    then do:
        message "Nenhum cartao cadastrado".
        pause.
        return.
    end.
    clear frame frame-a all no-pause.

    display ttusertoken.idusuario format "x(20)"
            with frame frame-a 11 down overlay
                centered row 5  no-labels
                title " Escolha o Usuario ".

    recatu1 = recid(ttusertoken).
    repeat:
        find next ttusertoken where true no-lock.
        if not available ttusertoken
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        display ttusertoken.idusuario 
                with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find ttusertoken where recid(ttusertoken) = recatu1.

        choose field ttusertoken.idusuario 
            go-on(cursor-down cursor-up
                  PF4 F4 ESC return).
    
        if keyfunction(lastkey) = "cursor-down"
        then do:
            find next ttusertoken where true no-error.
            if not avail ttusertoken
            then next.
            color display white/red
                ttusertoken.idusuario.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev ttusertoken where true no-error.
            if not avail ttusertoken
            then next.
            color display white/red
                ttusertoken.idusuario.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error"
        then do:
            pidusuario = "".
            hide frame frame-a no-pause.
            leave bl-princ.
        end.

        if keyfunction(lastkey) = "return"
        then do on error undo, retry on endkey undo, leave.
            hide frame frame-a no-pause.
            pidusuario = ttusertoken.idusuario.
            return.
        end.    
        /*
        if keyfunction(lastkey) = "end-error"
        then view frame frame-a.
        */
        display ttusertoken.idusuario 
                    with frame frame-a.
        recatu1 = recid(ttusertoken).
   end.
end.
