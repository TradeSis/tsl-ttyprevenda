/* bauico na tela 042022 - helio */

{admcab.i}                                                   
def input param ppagamento as log.
def input-output param pseguevenda as log.
def output param cmoedapdv as char.

pseguevenda = no.
def var vtem as log.

{baudefs.i}
pfincod = ?.
pmoedapdv = ?.

def buffer bttgetparcelas for ttgetparcelas.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend       as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Seleciona"," ","  ","  ",""].
def var esqcom2         as char format "x(12)" extent 5.

def var esqhel1         as char format "x(80)" extent 5
    initial [" Enter para pagar parcela ",
             " Dados completos, Pode seguir com a venda","",
             " "].
def var esqhel2         as char format "x(12)" extent 5.


form
    esqcom1
    with frame f-com1
                 row 7 no-box no-labels column 1 centered.
/*form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels column 1 centered.*/
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

find first ttbauprodu where ttbauprodu.procod = pprocod no-lock.
    def var vtotal as dec format "R$ >>>>>>9.99".
    def var vqtd   as int format ">>9".

    form 
        skip(1)
        vqtd        colon 15 label "qtd parcelas" 
        vtotal      colon 15 label "total a pagar"
        skip(1)            
    with frame frame-b            
        column 50 row 8
        side-labels
        color messages no-box.

 
        form 
            ttgetparcelas.marca format "*/ " column-label "*"
            ttgetparcelas.codCarne 
            ttgetparcelas.numero   
            ttgetparcelas.dataVencimento format "x(10)"
            ttgetparcelas.titvlcob  column-label "valor"
            with frame frame-a 13 down column 2 row 9 no-box
            no-labels. 
run totais.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
/*    disp esqcom2 with frame f-com2.*/
    if recatu1 = ?
    then run leitura (input "pri").
    else find ttgetparcelas where recid(ttgetparcelas) = recatu1 no-lock.

    if not available ttgetparcelas
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(ttgetparcelas).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
/*    else color display message esqcom2[esqpos2] with frame f-com2.*/
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available ttgetparcelas
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
            find ttgetparcelas where recid(ttgetparcelas) = recatu1 no-lock.

            vtem = no.
            find first bttgetparcelas where bttgetparcelas.marca = yes no-error.
            esqcom1[2] = if avail bttgetparcelas and ppagamento = no
                         then " Finaliza"     
                         else "".

            esqcom1[1] = " Seleciona".
            if ttgetparcelas.numero = 13 
            then do:
                if ttgetparcelas.marca = no
                then esqcom1[1] = " Digita".
            end.
            if ttgetparcelas.marca
            then esqcom1[1] = " Desmarca".

                                                            
            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 = 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(ttgetparcelas.numero)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(ttgetparcelas.numero)
                                        else "".
            run color-message.
            
                
                disp esqcom1 with frame f-com1.
                choose field
                    ttgetparcelas.titvlcob
                        help ""
                    go-on(cursor-down cursor-up
                          cursor-left cursor-right
                          page-down   page-up
                          /*tab*/ PF4 F4 ESC return) /*color white/black*/ .

                         
            run color-normal.
            status default "".
            hide message no-pause.
        end.
            if keyfunction(lastkey) = "TAB"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
/*                    color display message esqcom2[esqpos2] with frame f-com2.*/
                end.
                else do:
/*                    color display normal esqcom2[esqpos2] with frame f-com2.*/
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
/*                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 5 then 5 else esqpos2 + 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.*/
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
/*                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 1 then 1 else esqpos2 - 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.*/
                end.
                next.
            end.
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail ttgetparcelas
                    then leave.
                    recatu1 = recid(ttgetparcelas).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail ttgetparcelas
                    then leave.
                    recatu1 = recid(ttgetparcelas).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down" 
            then do:
                run leitura (input "down").
                if not avail ttgetparcelas
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail ttgetparcelas
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then do:
            sresp = yes.
            vtem = no.
            /*
            for each ttgetparcelas where ttgetparcelas.titvlcob = ? or ttgetparcelas.titvlcob = "".
                if ttgetparcelas.marca
                then vtem = yes.
            end.      
            if vtem
            then do:
                sresp = no.
                run bautelamensagem.p (INPUT-OUTPUT sresp,
                                   input "Existem campos OBRIGATORIOS nao preenchidos!" + 
                                            chr(10) + chr(10) + "Deseja sair?" ,
                                   input "",
                                   input "Sair",
                                   input "Ajustar").  
                if sresp
                then do:
                    recatu1 = ?.
                end.
            end.
            */
                  
            if sresp
            then do:
                hide frame f-com1 no-pause.
                hide frame frame-a no-pause.
                hide frame frame-b no-pause.
                leave bl-princ.
            end.    
            else next.
        end.    

        if keyfunction(lastkey) = "return" or esqvazio
        then do:    
            if esqcom1[esqpos1] = " Seleciona" 
            then do:
                find first bttgetparcelas where bttgetparcelas.codcarne = pbaucarne and
                            bttgetparcelas.numero = ttgetparcelas.numero - 1 no-error.
                if not avail bttgetparcelas or
                   (avail bttgetparcelas and bttgetparcelas.marca and not ttgetparcelas.marca)
                then if ttgetparcelas.titvlcob > 0 then ttgetparcelas.marca = yes.
                disp ttgetparcelas.marca with frame frame-a.
                
                run leitura (input "down").
                if not avail ttgetparcelas
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
                
            end.                         
            if esqcom1[esqpos1] = " Desmarca" 
            then do:
                find first bttgetparcelas where  bttgetparcelas.codcarne = pbaucarne and
                            bttgetparcelas.numero = ttgetparcelas.numero + 1 no-error.
                if not avail bttgetparcelas or
                   (avail bttgetparcelas and not bttgetparcelas.marca and ttgetparcelas.marca)
                then  ttgetparcelas.marca = no.
                disp ttgetparcelas.marca with frame frame-a.
            end.                         
            
            if esqcom1[esqpos1] = " Digita"
            then do: 
                update ttgetparcelas.titvlcob with frame frame-a.
                
                find first bttgetparcelas where  bttgetparcelas.codcarne = pbaucarne and
                        bttgetparcelas.numero = ttgetparcelas.numero - 1 no-error.
                if not avail bttgetparcelas or
                   (avail bttgetparcelas and bttgetparcelas.marca and not ttgetparcelas.marca)
                then if ttgetparcelas.titvlcob > 0 then ttgetparcelas.marca = yes.
                disp ttgetparcelas.marca with frame frame-a.
                /*
                ttgetparcelas.marca = ttgetparcelas.titvlcob > 0.  
                disp ttgetparcelas.marca with frame frame-a.
                */
            end.                         
            
            if esqcom1[esqpos1] = " Finaliza"
            then do:
                pseguevenda = yes.
                run bausimparcela.p (output cmoedapdv).
                leave bl-princ.
            end.

            run totais.

        end.

        if not esqvazio
        then do:
            run frame-a.
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
/*        else display esqcom2[esqpos2] with frame f-com2.*/
        recatu1 = recid(ttgetparcelas).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        
        view frame fc1.
        view frame fc2.
    end.
end.
/*hide frame f-com2  no-pause.*/


procedure frame-a.

         
    display ttgetparcelas.marca 
            ttgetparcelas.numero
            ttgetparcelas.codCarne
            ttgetparcelas.dataVencimento
            ttgetparcelas.titvlcob
            with frame frame-a.
            
end procedure.
procedure color-message.

    color display message
            ttgetparcelas.numero
            ttgetparcelas.codCarne
            ttgetparcelas.dataVencimento
            ttgetparcelas.titvlcob
            with frame frame-a.
end procedure.

procedure color-normal.

    color display normal
            ttgetparcelas.numero
            ttgetparcelas.codCarne
            ttgetparcelas.dataVencimento
            ttgetparcelas.titvlcob
            with frame frame-a.
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
    if par-tipo = "pri" 
    then  
        if esqascend  
        then      
            find first ttgetparcelas where ttgetparcelas.codcarne = pbaucarne
                       no-lock no-error.
        else  
            find last ttgetparcelas  where  ttgetparcelas.codcarne = pbaucarne
                      no-lock no-error.
    if par-tipo = "seg" or par-tipo = "down" 
    then      
        if esqascend  
        then  
            find next ttgetparcelas  where  ttgetparcelas.codcarne = pbaucarne
                      no-lock no-error.
        else  
            find prev ttgetparcelas  where  ttgetparcelas.codcarne = pbaucarne
                      no-lock no-error.
    if par-tipo = "up" 
    then                  
        if esqascend   
        then   
            find prev ttgetparcelas  where  ttgetparcelas.codcarne = pbaucarne
                      no-lock no-error.
        else   
            find next ttgetparcelas  where   ttgetparcelas.codcarne = pbaucarne
                  no-lock no-error.
 
end procedure.
         


procedure totais.
    vtotal = 0.
    vqtd   = 0.
    for each bttgetparcelas where bttgetparcelas.marca = yes.
        vqtd = vqtd + 1.
        vtotal = vtotal + bttgetparcelas.titvlcob.
    end.
    
    pause 0 .
    disp 
        vqtd        colon 15 label "qtd parcelas" 
        vtotal      colon 15 label "total a pagar"
    with frame frame-b            .


end.
