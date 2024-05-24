/* bau 092022 - helio */

def output param pseguevenda as log.
def output param cmoedapdv as char.

{admcab.i}                                                   
def var vtem as log.

{baudefs.i}
def buffer bttgetparcelas for ttgetparcelas.
def buffer bttcarnes for ttcarnes.

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
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels column 1 centered.
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

 
run totais.

        form 
            ttcarnes.codigoBarras format "9999999999"
            ttcarnes.quantidadeParcelas
            ttcarnes.SelecPar
            ttcarnes.vlrSelec
            with frame frame-a 8 down column 2 row 9 no-box
            no-labels. 

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then run leitura (input "pri").
    else find ttcarnes where recid(ttcarnes) = recatu1 no-lock.

    if not available ttcarnes
    then do:
        esqvazio = yes.
        message "carnes nao encontratos para este cliente".
        pause 2 no-message.
        return.
    end.    
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(ttcarnes).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available ttcarnes
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
            find ttcarnes where recid(ttcarnes) = recatu1 no-lock.

            vtem = no.
            /*
            for each bttcarnes where bttcarnes.titvlcob = ? or bttcarnes.titvlcob = "".
                if bttcarnes.marca
                then vtem = yes.
            end. 
            */
            find first bttgetparcelas where bttgetparcelas.marca = yes no-error.
            esqcom1[2] = if avail bttgetparcelas 
                         then " Finaliza"     
                         else "".

                                                
            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 = 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(ttcarnes.numero)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(ttcarnes.numero)
                                        else "".
            run color-message.
            
                
                disp esqcom1 with frame f-com1.
                choose field
                            ttcarnes.codigoBarras
                        help ""
                    go-on(cursor-down cursor-up
                          cursor-left cursor-right
                          page-down   page-up
                          tab PF4 F4 ESC return) /*color white/black*/ .

                         
            run color-normal.
            status default "".
            hide message no-pause.
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
                    if not avail ttcarnes
                    then leave.
                    recatu1 = recid(ttcarnes).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail ttcarnes
                    then leave.
                    recatu1 = recid(ttcarnes).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down" 
            then do:
                run leitura (input "down").
                if not avail ttcarnes
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail ttcarnes
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
            for each ttcarnes where ttcarnes.titvlcob = ? or ttcarnes.titvlcob = "".
                if ttcarnes.marca
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
            then leave bl-princ.
            else next.
        end.    

        if keyfunction(lastkey) = "return" or esqvazio
        then do:    
            if esqcom1[esqpos1] = " Seleciona"
            then do:

                pbaucarne = int(ttcarnes.codigobarras).
                run selecionaParcelas.
                run totais.
                
                recatu1 = ?.
                leave.
            end.                         
            if esqcom1[esqpos1] = " Finaliza"
            then do:
                    
                pseguevenda = yes.
                run bausimparcela.p (output cmoedapdv).
                leave bl-princ.
            end.

        end.

        if not esqvazio
        then do:
            run frame-a.
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(ttcarnes).
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

         
    display 
                ttcarnes.codigoBarras
            ttcarnes.quantidadeParcelas
            ttcarnes.SelecPar
            ttcarnes.vlrSelec

            with frame frame-a.
            
end procedure.
procedure color-message.

    color display message
            ttcarnes.codigoBarras
            ttcarnes.quantidadeParcelas
            ttcarnes.SelecPar
            ttcarnes.vlrSelec

            with frame frame-a.
end procedure.

procedure color-normal.

    color display normal
            ttcarnes.codigoBarras
            ttcarnes.quantidadeParcelas
            ttcarnes.SelecPar
            ttcarnes.vlrSelec

            with frame frame-a.
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
    if par-tipo = "pri" 
    then  
        if esqascend  
        then      
            find first ttcarnes where
                true
                       no-lock no-error.
        else  
            find last ttcarnes  where
                true
                      no-lock no-error.
    if par-tipo = "seg" or par-tipo = "down" 
    then      
        if esqascend  
        then  
            find next ttcarnes  where
                      no-lock no-error.
        else  
            find prev ttcarnes  where
                      no-lock no-error.
    if par-tipo = "up" 
    then                  
        if esqascend   
        then   
            find prev ttcarnes  where
                      no-lock no-error.
        else   
            find next ttcarnes  where 
                  no-lock no-error.
 
end procedure.
         


procedure totais.
    vtotal = 0.
    vqtd   = 0.
    for each bttcarnes.
        bttcarnes.selecpar = 0.
        bttcarnes.vlrselec = 0.
    end.    
    for each bttgetparcelas where bttgetparcelas.marca = yes.
        vqtd = vqtd + 1.
        vtotal = vtotal + bttgetparcelas.titvlcob.
        find first bttcarnes where bttcarnes.codcarne =  bttgetparcelas.codcarne.
            bttcarnes.selecpar = bttcarnes.selecpar + 1.
            bttcarnes.vlrselec = bttcarnes.vlrselec + bttgetparcelas.titvlcob.
    end.
    
    pause 0 .
    disp 
        vqtd        colon 15 label "qtd parcelas" 
        vtotal      colon 15 label "total a pagar"
    with frame frame-b            .


end.


procedure selecionaParcelas.
def var presposta as char.
def var phttp_code as int.
def var cmensagem as char.

disp  space(1) pbaucarne format  "9999999999" 
        with frame fcarne row 6 no-box side-labels color messages
        width 34 column 47.
    
    
output to value("/usr/admcom/logs/apibau" + string(today,"99999999") + ".log") append.
put unformatted 
"bau PID=" spid "_" spidseq 
" carne novo " pbaucarne
    skip.
output close.

    find first ttgetparcelas where ttgetparcelas.codcarne = pbaucarne no-error.
    if not avail  ttgetparcelas
    then do:
        run bauapigetparcelas.p (output phttp_code, output presposta).
        if phttp_code <> 200 
        then do:
            return.
        end.

        find first ttgetcarne where ttgetcarne.codCarne = pbaucarne.
    
        if ttgetcarne.cpfClie = ? or ttgetcarne.cpfClie = ""
        then do:
            hide message no-pause.
            message "carne" pbaucarne "SEM CLIENTE VINCULADO".
            message "PAGAMENTO NAO PERMITIDO".
            undo.
        end.
    end.
    find first ttgetparcelas no-error.
    if avail ttgetparcelas
    then run bauselparcela.p  (yes /* pagamento*/, input-output pseguevenda, output cmensagem).



end procedure.
