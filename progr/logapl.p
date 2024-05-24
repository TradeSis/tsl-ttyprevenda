/*
*
*    Esqueletao de Programacao
*
*/

/*----------------------------------------------------------------------------*/

def var vtipo as char format "x(35)" extent 12
    initial[" 1. Pre Venda",
            " 2. Consultas",
            " 3. Pedidos",
            " 4. Ass.Tecnica",
            " 5. Atualiza",
            " 6. NF Transferencia",
            " 7. Analise de planos por vendedor",
            " 8. Intencao de compra", 
            " 9. Solicita Cartao Lebes",
            " 10. Assistencia Tecnica - SSC",
            " 11. Porta-relatorios", 
            " 12. Sair"].
    
def var tipo-atualiza as char format "x(30)" extent 4
    initial["Atualiza Promocao/Plano",
            "Atualiza Produto",
            "Atualiza Promocoes/Modulo",
            "Atualiza Promocoes Novas"].
    
def var tipo-consulta as char format "x(10)" extent 4
    initial["Estoque","Extrato","Est/For","Vendas"].


/*def var tipo-pedido as char format "x(10)" extent 3
    initial["Manual","Automatico","filtro"].
*/
def var tipo-pedido as char format "x(15)" extent 1
    initial[" Automatico"].

def var tipo-vivo as char format "x(10)" extent 2
    initial["Inclusao","Consulta"].

def var tipo-spc as char format "x(30)" extent 3
    initial[" 1. Analise de Credito  ",
            " 2. Consulta Pagamentos ",
            " 3. Cadastro de Clientes"].

def var vtipo_pag as char format "x(20)" extent 2 
    initial["Pagamento","  Sair"].

def var vsenha like func.senha format "x(10)".
def var senha_pag  like func.senha.
def var vpropath        as char format "x(150)".
def var vtprnom         as char. /* like tippro.tprnom.   */
input from /usr/admcom/propath no-echo.  /* Seta Propath */
set vpropath with width 200 no-box frame ff.
input close.
propath = "/usr/admcom/verus," + vpropath + ",\dlc".

{/usr/admcom/progr/admcab.i new}

sestacao = SESSION:PARAMETER.

def var funcao          as char format "x(20)".
def var parametro       as char format "x(20)".
def var v-ok            as log.
def var vok             as log.
def var vpre            as char.
def var vpag            as char.
def var vsen            as char.
sprog-fiscal = ?.
vpag = "".
input from ./admcom.ini no-echo.
repeat:
    set funcao parametro.
    if funcao = "ESTAB"
    then setbcod = int(parametro).
    if funcao = "CAIXA"
    then scxacod = int(parametro).
    if funcao = "CLIEN"
    then scliente = parametro.
    if funcao = "RAMO"
    then stprcod = int(parametro).
    else stprcod = ?.
    if funcao = "FISCAL" 
    then sprog-fiscal = parametro.
    if funcao = "PORTAECF" 
    then sporta-ecf = parametro.
    if funcao = "PREVENDA"
    then vpre = parametro. 

    if funcao = "PAGAMENTO"
    then vpag = parametro. 
    
    if funcao = "SENHA"
    then vsen = parametro. 
    
    if funcao = "CARNE" 
    then scarne = parametro.

    if funcao = "RECIBO" 
    then srecibo = parametro.

    if funcao = "MODELO-ECF"
    then smodelo-ecf = parametro.
                                  
end.

input close.

def var numero-ecf as int.
def var serie-ecf as char.
def var vnumserie1 as char.

if vpre = "YES" or
   vpre = "SIM"
then.
else do:   
sresp = no.

run /usr/admcom/progr/ecfstatus.p(output sresp).
if sresp
then do:
    secf = "numero-serie".
    run /usr/admcom/progr/retorno.p (output vnumserie1).
    secf = "".

    numero-ecf = int(acha("caixa",vnumserie1)).
    serie-ecf  = acha("SERIE",vnumserie1).

    scxacod = numero-ecf.
    
    find caixa where caixa.etbcod = setbcod and
                 caixa.cxacod = scxacod
                 no-lock no-error.
    if not avail caixa
    then do:
        message "Caixa " scxacod " não cadastrado." view-as alert-box.
        quit.    
    end.
end.
end.
                 
find admcom where admcom.cliente = scliente no-lock.
wdata = today.

on F5 help.
on PF5 help.
on PF7 help.
on F7 help.
on f6 help.
on PF6 help.
def var vfuncod like func.funcod.

find estab where estab.etbcod = setbcod no-lock.
find first wempre no-lock.

def var vempre as char format "x(75)".

vempre = trim(caps(wempre.emprazsoc)) + 
        " / " + trim(caps(estab.etbnom)) +
                         " /CAIXA " + string(scxacod) + " work" + sestacao +
        string(vtprnom,"x(18)").

display vempre @  wempre.emprazsoc
                    wdata with frame fc1.


ytit = fill(" ",integer((30 - length(wtittela)) / 2)) + wtittela.

if serie-ecf <> ""
then status default "CUSTOM Business Solutions    ECF:"
                + string(numero-ecf,"999") + " FAB:" + serie-ecf.
else status default "CUSTOM Business Solutions  ".

do on error undo, return on endkey undo, retry:
    vsenha = "".

    hide frame f-vivo no-pause.
    hide frame f-spc no-pause.

    update vfuncod label "Matricula"
           vsenha blank with frame f-senh side-label centered row 10.

    if vfuncod = 0 and
       vsenha  = "cel"
    then repeat: 

        hide frame f-senh no-pause.
        display tipo-vivo no-label with frame 
                f-vivo centered row 5.
        choose field tipo-vivo with frame f-vivo.
        
        if frame-index = 1
        then run habil.p.
        else run relhabil.p.
        hide frame f-vivo no-pause.
    
    end.
    
    if vfuncod = 0 and
       vsenha  = "spc"
    then repeat:

        hide frame f-senh no-pause.
        run wf-spc.p.
        disp "" with frame xx1 row 4 no-box.
        disp "" with frame xx2 row 21 overlay no-box
                width 80.
        leave.
    end.
    
    if vfuncod = 0 and
       vsenha  = "proedlinx"
    then return.
    
    find first func where func.funcod = vfuncod and
                          func.etbcod = setbcod and
                          func.senha  = vsenha no-lock no-error.
    if not avail func
    then do:
        message "Funcionario Invalido.".
        undo, retry.
    end.
    else sfuncod = func.funcod.

end.

hide frame fca no-pause.

find estab where estab.etbcod = setbcod no-lock.
find first wempre no-lock.

vempre = trim(caps(wempre.emprazsoc)) + " / " + trim(caps(estab.etbnom))
 + "-" + trim(func.funnom) + " /CAIXA " + string(scxacod) + " work" + sestacao
      + "  " + string(vtprnom,"x(18)"). 
               
display vempre  @  wempre.emprazsoc
                    wdata with frame fc1.

ytit = fill(" ",integer((30 - length(wtittela)) / 2)) + wtittela.

if serie-ecf <> ""
then status default "CUSTOM Business Solutions     ECF:"
                + string(numero-ecf,"999") + " FAB:" + serie-ecf.
else status default "CUSTOM Business Solutions   ".

    if vpag  = "yes" or
       vpag = "sim" 
    then do:
        if vsen = ""
        then do:
            message "Caixa sem senha para pagamento".
            undo, retry.
        end.
    end.

    if vpag = "yes" or
       vpag = "sim"
    then repeat:
        find estab where estab.etbcod = setbcod no-lock.
        find caixa where caixa.etbcod = setbcod and
                         caixa.cxacod = scxacod no-lock.
        display vtipo_pag no-label with frame f-escolha_pag centered.
        choose field vtipo_pag with frame f-escolha_pag.
        if frame-index = 1
        then do:
            senha_pag = "".
            update senha_pag blank 
                with frame f-senhapag centered side-label.
            if senha_pag <> vsen
            then do:
                message "Senha Invalida".
                pause.
                undo, retry.
            end.

            hide frame f-senhapag no-pause.
            hide frame f-senh     no-pause.
            hide frame f-escolha_pag no-pause.
            run wf-pag.p.
        end.    
        else quit.
    end.
    if vpag = "sim" or
       vpag = "yes" 
    then quit.
    
    if vpre = "yes" or
       vpre = "sim" 
    then do:
        find estab where estab.etbcod = setbcod no-lock.
        find caixa where caixa.etbcod = setbcod and
                         caixa.cxacod = scxacod no-lock.

        hide frame f-senh no-pause.

        run menuprojeto.p.    

        /*
        display vtipo[1]
                vtipo[2]
                vtipo[3]
                vtipo[4]
                vtipo[5]
                vtipo[6]
                vtipo[7]
                vtipo[8]
                vtipo[9]
                vtipo[10]
                vtipo[11]
                vtipo[12]
                with frame 
                f-escolha centered row 5 no-labels 1 col
                            title " Menu ".
        choose field vtipo auto-return with frame f-escolha.
        
        hide frame f-escolha.
        
        if frame-index = 1
        then do:
            hide frame f-escolha no-pause.
            run wf-pre.p.
        end.
        
        if frame-index = 2
        then do:
    
            display tipo-consulta no-label with frame 
                      f-consulta centered.
            choose field tipo-consulta with frame f-consulta.
            hide frame f-consulta no-pause.
            if frame-index = 1
            then run pesco.p.
            if frame-index = 2
            then run extra0_p.p.
            if frame-index = 3
            then run estloja0.p.
            if frame-index = 4
            then run dreb061.p.
        
        end.
        if frame-index = 3
        then do:
    
            display tipo-pedido no-label with frame 
                      f-pedido centered.
            choose field tipo-pedido with frame f-pedido.
            hide frame f-pedido no-pause.
            /*if frame-index = 1
            then do:
                message "Modulo disponovel no menu do SSH".
                pause.
                /*
                run pedido.p.
                */
            end.*/
            if frame-index = 1
            then run pedautco.p.
            if frame-index = 2
            then run prodexc.p.
        
        end.

        if frame-index = 4
        then do:
            /*run asstec0.p.*/
            /*Alterado em maio/2018 pelo Leote (917194)*/
            message "Menu desativado. As OS devem ser emitidas na nova retaguarda!" view-as alert-box title "  ATENCAO!  ".
        end.
        
        if frame-index = 5
        then do:
        
            display tipo-atualiza no-label with frame 
                      f-atualiza centered.
            choose field tipo-atualiza with frame f-atualiza.
            hide frame f-atualiza no-pause.
            if frame-index = 1
            then run buscadmf.p.
            else 
            if frame-index = 2
            then run busccomf.p.
            else
            if frame-index = 3
            then run promomat.p.
            else
            if frame-index = 4
            then run promomat2.p.          
 
        end.
        
        if frame-index = 6
        then do:
        
            vok = yes. 
            /*
            run senha.p(output vok). 
            if vok = no 
            then do: 
        
                message "Funcionario invalido".
                undo, retry. 
        
            end.
            */
                 
            /*Alterado em mar/2018 pelo Leote (885941)*/
            message "Menu desativado. As notas devem ser emitidas na nova retaguarda!" view-as alert-box title "  ATENCAO!  ".

            /*run nftra.p.*/
            
        end.    
        if frame-index = 7
        then do:
            run anaplave.p.
        end.
        if frame-index = 8
        then do:
            run intcmp01.p.
        end.    
        if frame-index = 9
        then do:
            run pdcartao.p.
        end.               

        if frame-index = 10
        then do:
            /*run not_cdetiqueta_lj.p.*/
            /*Alterado em maio/2018 pelo Leote (917194)*/
            message "Menu desativado. As OS devem ser emitidas na nova retaguarda!" view-as alert-box title "  ATENCAO!  ".
        end.                    
 
        if frame-index = 11
        then do:
            run edit-arq.p.
        end.

        if frame-index = 12
        then quit.

        */
        
    end.
    if vpre = "sim" or
       vpre = "yes" 
    then quit.

    if func.funfunc begins "VEN"
    then do:
        message "Usuario sem permissao para acessar o Menu Principal".
        pause.
        quit.
    end.



/*-----  R1 - Pede a Identificacao do Caixa  -----------------

repeat with frame f1 row 20 col 56 side-labels overlay
            on endkey undo, retry.
    display scxacod @ caixa.cxacod.
    prompt-for caixa.cxacod.
    find first caixa using caixa.cxacod no-lock no-error.

    hide frame f1 no-pause.
    if  not available caixa then do:
        next.
    end.
    else do:
        scxacod = input caixa.cxacod.
        leave.
    end.
end.

-----  Fim do R1 -----------------------------------------*/

def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 5
            initial ["Inclusao","Alteracao","Exclusao","Consulta","Listagem"].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].


def buffer bAPLICATIVO       for APLICATIVO.

def var v-down           as int.

    form
        esqcom1
            with frame f-com1
                 row 3 no-box no-labels side-labels column 1.
    form
        esqcom2
            with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1.
    esqregua  = yes.
    esqpos1  = 1.
    esqpos2  = 1.
    v-down = 0.
    for each aplicativo:
        v-down = v-down + 1.
    end.
bl-princ:
repeat:
display "" with frame ff1
            1 down centered no-labels
                color normal  row 4 width 60 no-box.
display "" with frame ff2
             1 down centered no-labels
                color normal  row 5 + v-down width 60 no-box.

    if recatu1 = ?
    then
        find first APLICATIVO  where
                   not can-find( aplifun where aplifun.funcod = func.funcod and
                                 aplifun.aplicod = aplicativo.aplicod)
                  no-lock no-error.
    else find APLICATIVO where recid(APLICATIVO) = recatu1 no-lock.
    if not available APLICATIVO
    then leave.
    clear frame frame-a all no-pause.
    display
        APLICATIVO.APLINOM at 20
            with frame frame-a v-down down centered no-labels
                color white/blue  row 5 width 60 no-box.

    recatu1 = recid(APLICATIVO).
    repeat:
        find next APLICATIVO  where
                   not can-find( aplifun where aplifun.funcod = func.funcod and
                       aplifun.aplicod = aplicativo.aplicod) no-lock no-error.
        if not available APLICATIVO
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        display
            APLICATIVO.APLINOM
                with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        hide frame f-senha.
        find APLICATIVO where recid(APLICATIVO) = recatu1 no-lock.
        put screen row 24 column 1 string(aplicativo.aplihel,"x(80)")
            color black/cyan.
        on F5 help.
        on f10 delete-line.
        choose field APLICATIVO.APLINOM color message
            go-on(cursor-down cursor-up
                  cursor-left cursor-right PF5 F5 PF10 F10
                  tab PF4 F4 ESC return).
        hide message no-pause.
        if keyfunction(lastkey) = "get"
        then do WITH FRAME F-F5 ROW 20 COLUMN 56 SIDE-LABEL overlay
                    on endkey undo, retry.
            disp setbcod @ estab.etbcod.
            prompt-for estab.etbcod.
            find estab using estab.etbcod no-lock no-error.
            hide frame f-f5 no-pause.
            if not avail estab
            then next.
            setbcod = input estab.etbcod.
            disp trim(caps(wempre.emprazsoc)) + "/" +
                      trim(caps(estab.etbnom)) @ wempre.emprazsoc wdata
                      with frame fc1.
        end.
        on F5 help.
        hide message no-pause.
        if keyfunction(lastkey) = "cursor-down"
        then do:
            find next APLICATIVO  where
                   not can-find( aplifun where aplifun.funcod = func.funcod and
                       aplifun.aplicod = aplicativo.aplicod) no-lock no-error.
            if not avail APLICATIVO
            then next.
            color display white/blue
                APLICATIVO.APLINOM.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev APLICATIVO  where
                   not can-find( aplifun where aplifun.funcod = func.funcod and
                       aplifun.aplicod = aplicativo.aplicod) no-lock no-error.
            if not avail APLICATIVO
            then next.
            color display white/blue
                APLICATIVO.APLINOM.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error"
        then do:
            run mensagem.p (input-output sresp,
                            input "          CONFIRMA SAIR DO SISTEMA ?     ",
                            input "",
                            input "   SIM", 
                            input "   NÃO").

            if not sresp
            then next bl-princ.
            else quit.
        end.

        /*
        if keyfunction(lastkey) = "delete-line"
        then do:
            return.
        end.
        */

        if keyfunction(lastkey) = "return" or
           keyfunction(lastkey) = "cursor-right"
        then do on error undo, retry on endkey undo, leave.
            v-ok = no.
            for each menu where menu.aplicod = aplicativo.aplicod and
                not can-find(admaplic
                        where admaplic.cliente = scliente and
                              admaplic.aplicod = aplicativo.aplicod and
                              admaplic.menniv  = 1        and
                              admaplic.ordsup  = 0        and
                              admaplic.menord  = menu.menord) and
                    menniv = 1 no-lock:
                v-ok = yes.
                leave.
            end.
            if not v-ok
            then do:
                message "MODULO NAO DISPONIVEL".
                next.
            end.
            hide frame ff1.
            hide frame ff2.
            hide frame f-senha.
            vok = yes.

            if aplicativo.aplicod = "labo"
            then do:
                vsenha = "".
                update vsenha blank with frame f-senha side-label overlay
                                    centered.
                if vsenha <> "senha"
                then do:
                    message "Senha Invalida".
                    undo, retry.
                end.
                /* run senha.p(output vok). */
            end.
            hide frame f-senha.
            if vok = yes
            then
            run logmenp.p( input aplicativo.aplicod,input 0).
            hide all no-pause.
            view frame ff1.
            view frame ff2.
            view frame fc1.
        end.
        if keyfunction(lastkey) = "end-error"
        then do:
            view frame frame-a.
        end.
                    
        if keyfunction(lastkey) = "GET"
        then do with frame fs row 20 col 56 side-labels overlay
            on endkey undo, retry.
            display setbcod @ estab.etbcod.
            prompt-for estab.etbcod.
            find estab using estab.etbcod no-lock no-error.
            hide frame fs no-pause.
            if not available estab
            then next.
            setbcod = input estab.etbcod.
            display trim(caps(wempre.emprazsoc)) + "/" +
                        trim(caps(estab.etbnom)) @ wempre.emprazsoc
                    wdata with frame fc1.
        end.
        display
                APLICATIVO.APLINOM
                    with frame frame-a.
        recatu1 = recid(aplicativo).
  
        if serie-ecf <> ""
        then status default "CUSTOM Business Solutions      ECF:"
                + string(numero-ecf,"999") + " FAB:" + serie-ecf.
        else status default "CUSTOM Business Solutions        ".

   end.
end.
return.
