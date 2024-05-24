/* medico na tela 042022 - helio */

{admcab.i}                                                   
def output param pseguevenda as log.

def var vpermin as int.
def var vpermax as int.
def var vtempo  as char.
def var vanos   as int.

pseguevenda = no.

{meddefs.i}

def buffer bttcampos for ttcampos.
                    DEF VAR hObj AS HANDLE.




def var vtem as log.

def var aux-format as char.
def var aux-texto as char.
def var vdata as date. 
def var vinteirodata as dec. 
def var vtexto as char.

def var vlabel as char.
def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend       as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Digita"," ","  ","  ",""].
def var esqcom2         as char format "x(12)" extent 5.

def var esqhel1         as char format "x(80)" extent 5
    initial [" Enter para digitar ",
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

find first ttmedprodu where ttmedprodu.procod = pprocod no-lock.

 
def var vobri as log format "*/ " column-label "*".
    form vobri
            ttcampos.nome      format "x(25)" column-label "Campo"
            ttcampos.Conteudo  format "x(50)" column-label "Conteudo"
            with frame frame-a 8 down centered row 9 no-box
            no-labels. 

    /*form vdata format "99/99/9999" no-label
                        with frame fdata
                            centered row vrow overlay. */
FORM
    skip(1)
  space(10) vlabel format "x(35)" no-label skip
  skip(1)
  SPACE(10) vdata format "99/99/9999" no-label SPACE(6) 
  SKIP(1)
  WITH FRAME fdata OVERLAY NO-LABELS ATTR-SPACE
  WIDTH 40 CENTERED ROW 9
  COLOR messages .
FORM
    skip(1)
  space(10) vlabel format "x(35)" no-label skip
  skip(1)
  SPACE(10) vinteirodata no-label SPACE(6) 
  SKIP(1)
  WITH FRAME finteirodata OVERLAY NO-LABELS ATTR-SPACE
  WIDTH 40 CENTERED ROW 9
  COLOR messages .
FORM
    skip(1)
  space(10) vlabel format "x(35)" no-label skip
  skip(1)
  SPACE(1) vtexto no-label SPACE(1) 
  SKIP(1)
  WITH FRAME ftextodata OVERLAY NO-LABELS ATTR-SPACE
  WIDTH 80 CENTERED ROW 9
  COLOR messages .
  
  



bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then run leitura (input "pri").
    else find ttcampos where recid(ttcampos) = recatu1 no-lock.

    if not available ttcampos
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(ttcampos).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available ttcampos
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
            find ttcampos where recid(ttcampos) = recatu1 no-lock.
                if ttcampos.idcampo =  "proposta.codigoVendedor" or
                   ttcampos.idcampo =  "proposta.cliente.cpf" or
                   ttcampos.idcampo =  "nomeVendedor" or
                   ttcampos.idcampo =  "codigoFilial" or
                   ttcampos.idcampo =  "nomeFilial" 
                then do:
                    esqcom1[1] = "".
                end.    
                else esqcom1[1] = " Digita".
            
                                                         
            sresp = yes.
            
            vtem = no.
            for each bttcampos where bttcampos.conteudo = ? or bttcampos.conteudo = "".
                if bttcampos.OBRIGATORIEDADE
                then vtem = yes.
            end. 
            esqcom1[2] = " Segue Venda".     
            if vtem
            then do:
                esqcom1[2] = "".
            end.
                                                
                /*                                
  for each ttopcoes where ttopcoes.idpai = ttcampos.id.
        disp ttopcoes
            with row 12 4 down.
    end.          
                  */
            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 = 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(ttcampos.nome)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(ttcampos.nome)
                                        else "".
            run color-message.
            
                
                disp esqcom1 with frame f-com1.
                choose field
                    ttcampos.conteudo
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
                    if not avail ttcampos
                    then leave.
                    recatu1 = recid(ttcampos).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail ttcampos
                    then leave.
                    recatu1 = recid(ttcampos).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down" 
            then do:
                run leitura (input "down").
                if not avail ttcampos
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail ttcampos
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then do:
            sresp = yes.
            vtem = no.
            for each ttcampos where ttcampos.conteudo = ? or ttcampos.conteudo = "".
                if ttcampos.OBRIGATORIEDADE
                then vtem = yes.
            end.      
            if vtem
            then do:
                sresp = no.
                run medtelamensagem.p (INPUT-OUTPUT sresp,
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
                  
            if sresp
            then leave bl-princ.
            else next.
        end.    

        if keyfunction(lastkey) = "return" or esqvazio
        then do:    
            if esqcom1[esqpos1] = " Segue Venda"
            then do:
                pseguevenda = yes.  
                leave bl-princ.
            end.                         
            if esqcom1[esqpos1] = " Digita"
            then do:
                
                /* HELIO 08012023 - ID 61585 - Correção data de vigência chama doutor */
                if ttcampos.idcampo = "proposta.dataInicioVigencia" or
                   ttcampos.idcampo = "proposta.dataFimVigencia" or
                   ttcampos.idcampo = "proposta.vigenciaPeriodoEmMeses"
                then next.
                                                
                find first ttopcoes where ttopcoes.idPAI = ttcampos.id and
                                          ttopcoes.idcampo  = ttcampos.idcampo
                                          no-error.
                if avail ttopcoes
                then do:
                    run medtelaopcoes.p (ttcampos.id, ttopcoes.idcampo, 
                                         input ttcampos.nome,
                                         output ttcampos.conteudo, 
                                         output ttcampos.conteudoexpor).
                    run frame-a.
                    next.
                end.    

                
                if ttcampos.TIPO = "NUMERICO" or
                   ttcampos.TIPO = "INTEIRO"
                then do:
                    

                    vinteirodata = dec(ttcampos.conteudo).
                    /*vrow = frame-line + 2.*/
                    vlabel = ttcampos.nome.
                    pause 0.
                    disp vlabel 
                            vinteirodata
                            with frame finteirodata.
                    hObj = vinteirodata:HANDLE.
                    hObj:format = fill("9",if ttcampos.MAXIMO <> ? then int(ttcampos.MAXIMO) else 
                                    if ttcampos.vlrMaximo <> ? then length(string(ttcampos.vlrMaximo)) else 16).
                             
                    update vinteirodata 
                        with frame finteirodata.
                
                    ttcampos.conteudo = string(vinteirodata).
                    if ttcampos.vlrMINIMO <> ? or ttcampos.vlrMAXIMO <> ?
                    then do:
                        if ttcampos.vlrMINIMO <> ?
                        then do:
                            if dec(ttcampos.conteudo) < int(ttcampos.vlrMINIMO)
                            then do:
                                message "Valor MENOR que o minimo Permitido"
                                    view-as alert-box.
                                undo.
                            end.
                        end.
                        if ttcampos.vlrMAXIMO <> ?
                        then do:
                            if dec(ttcampos.conteudo) > int(ttcampos.vlrMAXIMO)
                            then do:
                                message "Valor MAIOR que o maximo Permitido"
                                    view-as alert-box.
                                undo.
                            end.
                        end.
                        
                    end.
                    
                end.
                
                if ttcampos.TIPO = "TEXTO" 
                then do on error undo, retry on endkey undo, retry:
                    if retry and keyfunction(lastkey) = "END-ERROR"
                    then do:
                        ttcampos.conteudo = aux-texto.
                        leave.
                    end.    
                    if not retry then do:
                        vtexto    = ttcampos.conteudo.
                        aux-texto = ttcampos.conteudo.
                    end.    
                     
                    /*vrow = frame-line + 2.*/
                    vlabel = ttcampos.nome.
                    pause 0.
                    if ttcampos.MAXIMO <> ?  and int(ttcampos.MAXIMO) > 50
                    then do:
                        disp vlabel 
                            vtexto
                            with frame ftextodata.
                        hObj = vtexto:HANDLE.
                        hObj:format = "x(" + ( if ttcampos.MAXIMO <> ? then trim(
                                                                if int(ttcampos.MAXIMO) > 76 then "76" else string(ttcampos.MAXIMO))
                                                                        else "76" ) + ")".
                             
                        update vtexto with frame ftextodata .
                        ttcampos.conteudo = string(caps(vtexto)).
                        vtexto = "".
                    end.
                    else do:
                        hObj = ttcampos.conteudo:HANDLE.
                        aux-format = hObj:format.
                        hObj:format = "x(" + ( if ttcampos.MAXIMO <> ? then trim(
                                                                if int(ttcampos.MAXIMO) > 50 then "50" else string(ttcampos.MAXIMO))
                                                                        else "50" ) + ")".
                             
                        update ttcampos.conteudo
                            with frame frame-a /*ftextodata*/ .
                        ttcampos.conteudo = caps(ttcampos.conteudo).    
                        hObj:format = aux-format.
                    end.

                    if ttcampos.MINIMO <> ?
                    then do:
                        if length(ttcampos.conteudo) < int(ttcampos.MINIMO)
                        then do:
                            message "Conteudo MENOR que o minumo Permitido"
                                view-as alert-box.
                            undo.
                        end.
                    end.
                    
                end.
                
                if ttcampos.TIPO = "DATA" 
                then do:
                    /*vrow = frame-line + 2.*/
                    vdata = date(int(entry(2,ttcampos.conteudo,"-")) , 
                                 int(entry(3,ttcampos.conteudo,"-")) ,
                                 int(entry(1,ttcampos.conteudo,"-")))
                                    no-error.
                    vlabel = ttcampos.nome.
                    pause 0.
                    disp vlabel with frame fdata.
                    update vdata 
                        with frame fdata.
                
                    ttcampos.conteudo =  string(year(vdata),"9999") + "-" +
                                  string(month(vdata),"99") + "-" +
                                  string(day(vdata),"99").
                    if ttcampos.PERIODO_MINIMO <> ? or ttcampos.PERIODO_MAXIMO <> ?
                    then do:
                        if ttcampos.PERIODO_MINIMO <> ?
                        then do:
                            vpermin = int(substring(trim(ttcampos.PERIODO_MINIMO),1,length(trim(ttcampos.PERIODO_MINIMO)) - 1)).
                            vtempo  =    substring(trim(ttcampos.PERIODO_MINIMO),length(trim(ttcampos.PERIODO_MINIMO))).
                            
                            if vtempo = "Y"
                            then do:
                                vanos = truncate((today - vdata) / 365,0).
                                if vanos < vpermin
                                then do:
                                    message "Idade Minima " vpermin "Anos"
                                        view-as alert-box.
                                    undo.
                                end.     
                            end.
                        end.
                        if ttcampos.PERIODO_MAXIMO <> ?
                        then do:
                            vpermax = int(substring(trim(ttcampos.PERIODO_MAXIMO),1,length(trim(ttcampos.PERIODO_MAXIMO)) - 1)).
                            vtempo  =    substring(trim(ttcampos.PERIODO_MAXIMO),length(trim(ttcampos.PERIODO_MAXIMO))).
                            if vtempo = "Y"
                            then do:
                                vanos = truncate((today - vdata) / 365,0).
                                if vanos > vpermax
                                then do:
                                    message "Idade Maxima " vpermax "Anos"
                                        view-as alert-box.
                                    undo.
                                end.     
                            end.
                        end.
                        
                    end.

                end.
            
                    run frame-a.
                    run leitura (input "down").
                    if not avail ttcampos
                    then next.
                    if frame-line(frame-a) = frame-down(frame-a)
                    then scroll with frame frame-a.
                    else down with frame frame-a.
            
            
            end.
            
            

        end.

        if not esqvazio
        then do:
            run frame-a.
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(ttcampos).
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

         
    display ttcampos.OBRIGATORIEDADE @ vobri
            ttcampos.nome
            ttcampos.conteudo
            with frame frame-a.
            
end procedure.
procedure color-message.

    color display message
            ttcampos.nome
            ttcampos.conteudo
            with frame frame-a.
end procedure.

procedure color-normal.

    color display normal
            ttcampos.nome
            ttcampos.conteudo
            with frame frame-a.
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
    if par-tipo = "pri" 
    then  
        if esqascend  
        then      
            find first ttcampos where
                true
                       no-lock no-error.
        else  
            find last ttcampos  where
                true
                      no-lock no-error.
    if par-tipo = "seg" or par-tipo = "down" 
    then      
        if esqascend  
        then  
            find next ttcampos  where
                      no-lock no-error.
        else  
            find prev ttcampos  where
                      no-lock no-error.
    if par-tipo = "up" 
    then                  
        if esqascend   
        then   
            find prev ttcampos  where
                      no-lock no-error.
        else   
            find next ttcampos  where 
                  no-lock no-error.
 
end procedure.
         

