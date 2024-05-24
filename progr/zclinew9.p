{admcab.i}
{setbrw.i}
{anset.i}
{dftempWG.i new}

def var sretorno as char.
def var vsobreno as char format "x(30)".
def var v-localizar as char.
def var v-cpf like clien.ciccgc.
def var vprevenda as log.
def var esqcom2         as char format "x(20)" extent 3
 initial [" Enter - Seleciona ","F4 - Encerrar", "F8 - Filtra Nome"].
    
def buffer bclien for clien.

def var v-op as char format "x(15)" extent 4
    initial [" CPF "," NOME ", " SOBRENOME ", " MANUTENCAO "].
if program-name(3) = "wf-pre.p"  or
   program-name(4) = "wf-pre.p"
then assign
        v-op[4] = ""
        vprevenda = yes.

if program-name(3) = "intcmp00.p" or
   program-name(3) = "intcmp01.p"
then v-op[4] = "".

def temp-table tt-selclien
    field clicod like clien.clicod column-label "Conta"
    field clinom like clien.clinom column-label "N o m e"
    field ciinsc like clien.ciinsc column-label "Identidade".

form
    v-cpf     label "CPF" 
    with frame f-cpf
        centered
        row 10
        title " PROCURA "
        1 down side-labels
        overlay.
        
form
    v-op[1]
    v-op[2]
    v-op[3]
    with frame f-opcao 
        /*centered*/  col 30
        overlay
        color cyan/black
        no-labels 
        1 down
        title " Opcoes "
        side-labels.

form
    clien.clicod     help "ENTER=Seleciona   "
    clien.clinom
    with frame f-sobrenome
        centered
        down
        title " Clientes - Pesquisa por Sobrenome " .

form
    clien.clicod 
    clien.clinom
    clien.ciccgc help "ENTER=Seleciona  F8=Procura"
    with frame f-ciccgc
        centered
        down
        title " Clientes - Pesquisa por CGC/CPF " .

form
    clien.clicod
    clien.clinom
    with frame f-consulta
        centered
        down
        title " Clientes - Pesquisa Normal " .
        
def var vciccgc like clien.ciccgc.
repeat :
    clear frame f-consulta all.
    hide frame f-consulta.
    clear frame f-sobrenome all.
    hide frame f-sobrenome.
    clear frame f-cgcpf all.
    hide frame f-ciccgc.
    clear frame f-opcao all.
    hide frame f-opcao no-pause.
    hide frame f-data no-pause.
    hide frame f-cpf no-pause.
        
    disp v-op with frame f-opcao.
    choose field v-op with frame f-opcao width 70 centered.

    if frame-index = 1 /*cpf*/
    then do : 
        {zoomesq.i clien clicod ciccgc 20 Cliente 
            "ciccgc <> """"" /* "true"*/}
        hide frame f-opcao no-pause.
        
        if keyfunction(lastkey) = "END-ERROR"
        THEN DO:
            vciccgc = "".
            message "Procurar na MATRIZ.... CPF: "
            update vciccgc.
            if vciccgc <> ""
            then do:
                run agil4_WG.p (input "clien",
                         input (string(setbcod,"999") +
                                string(0,"9999999999") +
                                string(vciccgc,"x(11)"))).
                
                find first tp-clien where
                           tp-clien.clicod > 0 no-error.
                if avail tp-clien
                then do transaction:
                    find clien where clien.clicod = tp-clien.clicod
                            no-error.
                    if not avail clien
                    then create clien.
                    buffer-copy tp-clien to clien.
                    frame-value = string(tp-clien.clicod).
                end.        
                find first tp-cpclien where tp-cpclien.clicod > 0 no-error.
                if avail tp-cpclien
                then do transaction:
                    find cpclien where cpclien.clicod = tp-cpclien.clicod
                               no-error.
                    if not avail cpclien
                    then create cpclien.
                    buffer-copy tp-cpclien to cpclien.
                end.
                find first tp-carro where tp-carro.clicod > 0 no-error.
                if avail tp-carro
                then do transaction:
                    find carro where carro.clicod = tp-carro.clicod no-error.
                    if not avail carro
                    then create carro.
                    buffer-copy tp-carro to carro.
                end.                       
            end.
        END.
        leave.
    end.

    if frame-index = 2 /*nome*/
    then do : 
      pause 0.
      run zclien.p.  
      hide frame f-opcao no-pause.
      leave.
    end. 

    if frame-index = 3 /*sobrenome*/
    then do : 
      pause 0.
      run pi-pesq-sobreno.
      hide frame f-com2 no-pause.
      hide frame f-opcao no-pause.
      leave.
    end. 
    
    if frame-index = 4 and
        v-op[frame-index] <> "" /*manutencao*/
    then do:
        run clienf7.p.
        hide frame f-opcao no-pause.
        leave.
    end.
end.

hide frame f-opcao no-pause.
hide frame f-consulta.
hide frame f-sobrenome.
hide frame f-ciccgc.
hide frame f-opcao no-pause.
hide frame f-data no-pause.
hide frame f-cpf no-pause.


Procedure pi-pesq-sobreno.

def var vcompar-i  as char.
def var vcompar-j  as char.

for each tt-selclien:
        delete tt-selclien.
end.

update vsobreno label "Informe Sobrenome " with frame f-psobre 
    centered row 7 side-labels.

if vsobreno = ""
then do:
    message "Sobrenome Invalido " view-as alert-box.
    undo, retry.
end.

assign vsobreno = "*" + vsobreno + "*".

l1 : repeat : 

hide frame f-opcao.
assign a-seeid = -1 a-recid = -1 a-seerec = ?.

disp esqcom2 no-labels with frame f-com2 overlay row 22 no-box 
     width 65.
pause 0.
     
{sklcls.i       
                &File   = clien
                &CField = clien.clinom format "x(40)"
                &Color = "normal"
                &Ofield = " clien.clicod
                            clien.ciinsc "
                &Where = " clien.clinom matches vsobreno and not 
                            (entry(1, clien.clinom, ' ') matches vsobreno)"
                &NonCharacter = /*          
                &Aftfnd1 = " "
                &go-on = TAB
                &naoexiste1 = " message ""Nenhum registro encontrado !""
                                view-as alert-box.
                                a-seeid  = -1.
                                leave l1."
                &AftSelect1 = " if keyfunction(lastkey) = ""RETURN""
                                then do:
                                    assign scli = clien.clicod.
                                    leave keys-loop. /* leave l1.*/
                                end."
                &otherkeys1 = " run controle.
                                if keyfunction(lastkey) = ""CLEAR""    
                                then next keys-loop. "
                &LockType = "no-lock" 
                &Form = " frame f-clien-mos down centered row 6" 
                }
                if keyfunction(lastkey) = "end-error"         
                then do:                           
                     hide frame f-com2 no-pause.       
                     hide frame f-clien-mos no-pause.              
                     leave l1 . 
                 end.                                          
                if  keyfunction(lastkey) = "return"
                then do:
                     hide frame f-com2 no-pause.       
                     hide frame f-clien-mos no-pause.            
                     assign frame-value = string(clien.clicod).
                     leave.
                end.
end.  

hide frame f-clien-mos.

end procedure.


Procedure controle.

if keyfunction(lastkey) = "RETURN"
then do:
    leave.
end.

if keyfunction(lastkey) = "CLEAR"
then do:
      message "Informe Primeiro Nome ou parte : " update 
               v-localizar format "x(20)".
      find first bclien where 
            bclien.clinom matches ("*" + v-localizar + "*") and
            bclien.clinom matches vsobreno no-lock no-error.
      if not avail bclien 
      then do:
            message "Nenhum registro encontrado com parametro informado"
                        view-as alert-box.
            undo, retry.
      end.
      else do:
          find first clien where clien.clicod = bclien.clicod no-lock no-error.
          assign a-recid = recid(clien).
     end.       
end.
      
end procedure.
