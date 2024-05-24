/* medico na tela 042022 - helio */

{admcab.i}                                          
def input param pidpai as char.          
def input param pidcampo  as char.
def input param pcampo as char. 
def output param popcao as char.
def output param popcaoexpor as char.

{meddefs.i}

DEF VAR hObj AS HANDLE.

def var vtem as log.

def var aux-format as char.
def var aux-texto as char.
def var vdata as date. 
def var vinteirodata as dec. 
def var vtexto as char.

def var vlabel as char.
def var venter as log.
def var recatu1         as recid.
def var vdown as int.
for each ttopcoes where ttopcoes.idpai = pidpai and ttopcoes.idcampo = pidcampo.
    vdown = vdown + 1.
end.    
if vdown > 10 then vdown = 10.
pause 0.
    form 
         ttopcoes.nomeOpcao  format "x(50)" 
            with frame frame-a vdown down centered row 8  overlay
            no-labels
            title "   " + pcampo + "   ". 

recatu1 = ?.

bl-princ:
repeat:
    if recatu1 = ?
    then run leitura (input "pri").
    else find ttopcoes where recid(ttopcoes) = recatu1 no-lock.

    if not available ttopcoes
    then return.
    clear frame frame-a all no-pause.
    run frame-a.
    recatu1 = recid(ttopcoes).
    repeat:
        run leitura (input "down").
        if not available ttopcoes
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find ttopcoes where recid(ttopcoes) = recatu1 no-lock.
        choose field
                    ttopcoes.nomeOpcao
                        help ""
                    go-on(PF4 F4 ESC return 
                         cursor-down cursor-up  ).
            
        hide message no-pause.
            if keyfunction(lastkey) = "cursor-down" 
            then do:
                run leitura (input "down").
                if not avail ttopcoes
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail ttopcoes
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.

 
        if keyfunction(lastkey) = "end-error"
        then do:
            leave bl-princ.
        end.    

        if keyfunction(lastkey) = "return"
        then do:       
            popcao      = ttopcoes.nomeopcao.            
            popcaoexpor = ttopcoes.valor.

            leave bl-princ.
        end.
        run frame-a.
        recatu1 = recid(ttopcoes).
    end.
end.
hide frame f-com1  no-pause.
hide frame f-com2  no-pause.
hide frame frame-a no-pause.


procedure frame-a.
    display 
            ttopcoes.nomeOpcao
            with frame frame-a.
            
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
            
     if par-tipo = "pri" 
     then        
        find first ttopcoes where ttopcoes.idpai = pidpai and ttopcoes.idcampo = pidcampo no-lock no-error.
     if par-tipo = "down"
     then    
        find next ttopcoes  where ttopcoes.idpai = pidpai and ttopcoes.idcampo = pidcampo no-lock no-error.
     if par-tipo = "up" 
     then                   
        find prev ttopcoes  where ttopcoes.idpai = pidpai and ttopcoes.idcampo = pidcampo no-lock no-error.
 
end procedure.
         

