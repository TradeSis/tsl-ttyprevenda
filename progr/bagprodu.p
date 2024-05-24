/* bag 102022 - helio */
def new shared var vapiconsultarproduto as log format "Ligado/Desligado".

{admcab.i}
{bagdefs.i}
def input param pcpf as dec format "99999999999".
def input param pidbag  as int.
def var varquivo as char.
def var vpdf as char no-undo.
def buffer bprodu for produ.
def buffer bfunc for func.

/* uso do promo-venda.p */
def new shared temp-table tt-valpromo
    field tipo   as int
    field forcod as int
    field nome   as char
    field valor  as dec
    field recibo as log 
    field despro as char
    field desval as char.
def new shared var vdata-teste-promo as date init ?.
def new shared temp-table wf-movim no-undo
    field wrec      as   recid
    field movqtm    like movim.movqtm
    field lipcor    like liped.lipcor
    field movalicms like movim.movalicms
    field desconto  like movim.movdes
    field movpc     like movim.movpc
    field precoori  like movim.movpc
    field vencod    like func.funcod
    field KITproagr   like produ.procod.

/* uso do promo-venda.p */
 
def buffer bttitens for ttitens.
def var vsalvar as log.

def var presposta as char.
def var phttp_code as int.


def var ctitle as char.



def var vhelp as char.
def var xtime as int.
def var vconta as int.
def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(11)" extent 6
    initial ["digita","altera",/*"desconto",*/ "elimina","salva","registra",""].

form
    esqcom1
    with frame f-com1 row 6 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

form
        ttitens.sequencial format ">>>9" column-label "seq"
        ttitens.codigoProduto column-label "codigo" format ">>>>>>>>9"
        produ.pronom column-label "nome produto" format "x(20)"
        ttitens.quantidade format ">>>9" column-label "qtd"
        ttitens.quantidadeConvertida format ">>>9" column-label "qtd!vendida"
        
        ttitens.valorUnitario format ">>>9.99" column-label "preco"

        ttitens.valorLiquido  format ">>>9.99" column-label "promo"
        
        ttitens.valorTotal format ">>>>9.99" column-label "total"

        with frame frame-a 7 down centered row 9
        no-box.


    disp 
        ctitle format "x(70)" no-label
        with frame ftit
            side-labels
            row 5
            centered
            no-box
            color messages.


empty temp-table ttbag.
empty temp-table ttitens.

run bagapiresgatabag.p (setbcod, pcpf, pidbag , output phttp_code, output presposta).    

    
if phttp_code <> 200
then do on endkey undo, retry:
    message phttp_code presposta.
    pause.
    return.
end.

find first ttbag where ttbag.estaborigem = setbcod and
                           ttbag.idbag   = pidbag and 
                           ttbag.cpf     = pcpf
                           no-lock.

ctitle = "CONTEUDO DA BAG " + string(pidbag) + " - " + string(ttbag.cpf,"99999999999") + " " + ttbag.nome.
    disp 
        ctitle 
        with frame ftit.



recatu1 = ?.

bl-princ:
repeat:
    

    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find ttitens where recid(ttitens) = recatu1 no-lock.
    if not available ttitens
    then do.
        run pdigita.

                find first ttitens no-error.
                if not avail ttitens
                then return.
                recatu1 = ?.
                next.

    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(ttitens).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available ttitens
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find ttitens where recid(ttitens) = recatu1 no-lock.


        status default "".
    
        if ttbag.dtfec <> ?
        then do:
            esqcom1 = "".
            esqcom1[1] = "romaneio".
        end.    
            
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

    hide message no-pause.
        
        disp esqcom1 with frame f-com1.
        
        run color-message.
        vhelp = "".
        
        
        status default vhelp.
        choose field ttitens.sequencial
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
                    if not avail ttitens
                    then leave.
                    recatu1 = recid(ttitens).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail ttitens
                    then leave.
                    recatu1 = recid(ttitens).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail ttitens
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail ttitens
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then do:
            hide message no-pause.
            if vsalvar
            then do:
                sresp = yes.
                message "SALVAR bag?" UPDATE SRESP.
                if sresp then run psalva.                
            end.
            leave bl-princ.
        end.    
                
                
        if keyfunction(lastkey) = "return"
        then do:
            
            
             if esqcom1[esqpos1] = "digita"
             then do: 
                run pdigita.
                recatu1 = ?.
                leave.
            end.
             if esqcom1[esqpos1] = "altera"
             then do: 
                update ttitens.quantidade with frame frame-a.
                ttitens.valortotal  = ttitens.valorliquido * ttitens.quantidade.
                ttitens.descontoproduto  = (ttitens.valorunitario - ttitens.valorliquido) * ttitens.quantidade.
                vsalvar = yes.
            end. 
             if esqcom1[esqpos1] = "desconto"
             then do: 
                update  ttitens.valorliquido with frame frame-a.
                ttitens.valortotal  = ttitens.valorliquido * ttitens.quantidade.
                ttitens.descontoproduto  = (ttitens.valorunitario - ttitens.valorliquido) * ttitens.quantidade.
                vsalvar = yes.
            end. 
            
            if esqcom1[esqpos1] = "elimina"
            then do: 
                sresp = no.
                message "confirma?" update sresp.
                if sresp
                then do:
                    vsalvar = yes.
                    delete ttitens.
                    clear frame frame-a all no-pause.
                    recatu1 = ?.
                    leave.
                end.
            end.
            if esqcom1[esqpos1] = "salva"
            then do: 
                run psalva.
                hide frame f-com1 no-pause.
                hide frame frame-a no-pause.
                return.
            end.
            if esqcom1[esqpos1] = "registra"
            then do: 
                run pfecha.
                hide frame f-com1 no-pause.
                hide frame frame-a no-pause.

                return.
            end.
            if esqcom1[esqpos1] = "romaneio"
            then do: 
                run promaneio.
                hide frame f-com1 no-pause.
                hide frame frame-a no-pause.

            end.
            
            
            
        end.        
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(ttitens).
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
    find produ where produ.procod = ttitens.codigoProduto no-lock no-error.
    display  
        ttitens.sequencial
        produ.pronom when avail produ
        ttitens.codigoProduto
        ttitens.quantidade         
        ttitens.quantidadeConvertida when ttitens.quantidadeConvertida <> ?

        ttitens.valorUnitario
        ttitens.valorLiquido /* helio 07062023 */
        ttitens.valortotal
        with frame frame-a.


end procedure.

procedure color-message.
    color display message
        ttitens.sequencial
        produ.pronom 
        ttitens.codigoProduto
        ttitens.quantidade ttitens.quantidadeConvertida
    
        with frame frame-a.
end procedure.


procedure color-input.
    color display input
        ttitens.sequencial
        produ.pronom 
        ttitens.codigoProduto
        ttitens.quantidade ttitens.quantidadeConvertida
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        ttitens.sequencial
        produ.pronom 
        ttitens.codigoProduto
        ttitens.quantidade ttitens.quantidadeConvertida
 
        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.

    if par-tipo = "pri" 
    then do:
        find last ttitens 
            no-lock no-error.
    end.    
                                             
    if par-tipo = "seg" or par-tipo = "down" 
    then do:
        find prev ttitens 
            no-lock no-error.
    end.    
             
    if par-tipo = "up" 
    then do:
        find next ttitens
            no-lock no-error.

    end.  
        
end procedure.




procedure pdigita.
hide frame f-com1 no-pause.
def var vprocod like produ.procod format ">>>>>>>>9".
def var vseq as int.
def var vqtd like ttitens.quantidade.
def var vpreco as dec.
def var vtextopromocao as char.
def var parametro-in as char.
def var parametro-out as char.
def var vlibera as log.
def var vpromoc as char.

    form
        vprocod
        produ.pronom format "x(30)" no-label
        ttitens.quantidade
        with frame fdigita
        row 6
        1 down
        centered
        side-labels
        color messages.

    repeat with frame fdigita.
        
        
        update vprocod.
        find produ where produ.procod = vprocod no-lock no-error.
        if not avail produ
        then do:
            hide message no-pause.
            message "produto nao cadastrado".
            undo.
            
        end.                          
        
        run pdvapiconsultarproduto.p (setbcod, produ.procod).
        
        disp produ.pronom.
        if produ.catcod <> 41
        then do:
                hide message no-pause.
                message "categoria do produto invalida para bag".
                undo.
        end.
                
        /* validacoes do wf-pre */
        if produ.proseq = 99 
        then do: 
            hide message no-pause.
            message "Venda bloqueada para produto INATIVO." view-as alert-box.  
            undo. 
        end.
                if produ.descontinuado 
                then do: 
                    sresp = no. 
                    run message.p  
                        (input-output sresp,  
                        input     "          PRODUTO DESCONTINUADO.        "  + 
                        "                                        "  +     
                        "    Só seguir com a venda se o mesmo    "  + 
                        " estiver disponível no estoque na loja. "   + 
                        "                                        "  + 
                        "                CONTINUAR ?             ", 
                        input "").          
                    if sresp = no  
                    then undo. 
                end. 

        /* fim validacoes do wf-pre */

        
        
        if int(ttbag.categoria) = 0
        then do:
            find first bttitens where bttitens.codigoproduto <> vprocod no-error.
            if avail bttitens
            then do:
                if bttitens.catcod <> produ.catcod
                then do:
                    hide message no-pause.
                    message "categoria do produto invalida para esta bag".
                    undo.
                end.
            end.
        end.
        else do:
            if int(ttbag.categoria) <> produ.catcod
            then do:
                hide message no-pause.
                message "categoria do produto invalida para esta bag".
                undo.
            end.
       end.
            find estoq where estoq.procod = produ.procod
                         and estoq.etbcod = setbcod
                       no-lock no-error. 
            if not available estoq 
            then do: 
                message "Sem registro de ESTOQUE/PRECO" view-as alert-box. 
                next. 
            end.
        
        find first ttitens where ttitens.codigoproduto = vprocod no-error.
        if not avail ttitens
        then do:
            find last ttitens no-error.
            vseq = if avail ttitens then ttitens.sequencial + 1 else 1.
            create ttitens.
            ttitens.sequencial = vseq.
            ttitens.codigoproduto = vprocod.
            ttitens.catcod = produ.catcod.
        end.

        ttitens.quantidade = ttitens.quantidade + 1.
        
        /* bloco do wf-pre */  
        
                vpreco = estoq.estvenda.
                vtextopromocao = "".
                if estoq.estbaldat <> ? and
                   estoq.estprodat <> ?
                then do:
                    if estoq.estbaldat <= today and
                       estoq.estprodat >= today
                    then do:
                        vpreco = estoq.estproper.   
                        vtextopromocao = "Preco Promocional de " + string(estoq.estbaldat,"99/99/9999") + " ate " + string(estoq.estprodat,"99/99/9999") + " R$ " +
                                        trim(string(estoq.estproper,"->>>>>>>>>>9.99")).
                    end.    
                end.
                else do:
                    if estoq.estprodat <> ?
                    then if estoq.estprodat >= today
                         then do:
                            vpreco = estoq.estproper.
                            vtextopromocao = "Preco Promocional ate " + string(estoq.estprodat,"99/99/9999") + " R$ " +
                                        trim(string(estoq.estproper,"->>>>>>>>>>9.99")).

                         end.   
                end.

                /*** PRECO ESPECIAL ***/

                        parametro-in = "PRECO-ESPECIAL=S|PRODUTO=" +
                                    string(produ.procod) + "|".
                        run promo-venda.p(input parametro-in ,
                                          output parametro-out).
                        if acha("LIBERA-PRECO",parametro-out) <> ?
                        then vlibera = yes.
                        if acha("PRECO-ESPECIAL",parametro-out) <> ? and
                            dec(acha("PRECO-ESPECIAL",parametro-out)) > 0
                        then vpreco = dec(acha("PRECO-ESPECIAL",parametro-out)).

                        if acha("PROMOCAO",parametro-out) <> ? 
                        then vpromoc = acha("promocao",parametro-out).
                        else vpromoc = "".
                           
            ttitens.valorunitario = estoq.estvenda. /* helio 07062023 - trocado para estgenda*/
            ttitens.valorliquido  = vpreco.         /* helio 07062023 - acrescentado */
            ttitens.descontoproduto  = (ttitens.valorunitario - ttitens.valorliquido) * ttitens.quantidade.
            ttitens.valortotal = ttitens.valorliquido * ttitens.quantidade.        /*  helio 07062023 - trocado para valorliquido */
        
        
        /* fim bloco do wf-pre */
        
        
        
        vsalvar =  yes.
        disp           ttitens.quantidade.
                       
            recatu1 = ?.
            run leitura (input "pri").
            clear frame frame-a all no-pause.
            run frame-a.
            recatu1 = recid(ttitens).
            repeat:
                run leitura (input "seg").
                if not available ttitens
                then leave.
                if frame-line(frame-a) = frame-down(frame-a)
                then leave.
                down with frame frame-a.
                run frame-a.
            end.
        
        
    end.

    hide frame fdigita no-pause.

end procedure.


procedure psalva.

    find first ttitens no-error.
    
    if avail ttitens
    then do:
        run bagapisalva.p (setbcod, pidbag, pcpf, ttitens.catcod, output phttp_code, output presposta).    
        if phttp_code = 200
        then vsalvar = no.
    end.        

end procedure.

procedure senha_gerente.
    def output parameter par-ok  as log.
def var vfuncod like func.funcod.
def var vsenha  as char.
def var dsresp as log init no.

    DO ON ERROR UNDO:
        hide frame f-senha no-pause.    
        if keyfunction(lastkey) = "END-ERROR"
        then do:
            vfuncod = 0.
            vsenha = "".
            par-ok = no.
            next.
        end.
        
        do on error undo.
            if keyfunction(lastkey) = "END-ERROR"
            then do:
                vfuncod = 0.
                vsenha = "".
                par-ok = no. 
                hide frame f-senha no-pause.    

                next.
            end.

            vfuncod = 0. vsenha = "". par-ok = no.
        
            update vfuncod label "Matricula" 
                   vsenha  label "Senha" blank 
                   with frame f-senha side-label centered color message row 16
                        title " Senha Gerente ".

            find bfunc where bfunc.etbcod = setbcod
                         and bfunc.funcod = vfuncod no-lock no-error. 
            if not avail bfunc 
            then do:
                message "Funcionario Invalido".
                pause 3 no-message.
                par-ok = no.
                undo, retry.
            end.  
            if bfunc.funmec = no 
            then do:
                message "Funcionario nao e gerente". 
                pause 3 no-message. 
                par-ok = no.
                undo, retry. 
            end.     
            if vsenha <> bfunc.senha 
            then do:
                message "Senha invalida".
                pause 3 no-message.  
                par-ok = no.
                undo, retry. 
            end.
        end.
        par-ok = yes.
    END.        

    hide frame f-senha no-pause.
end procedure.


procedure pfecha.
def var pok as log.
    
    find first ttitens no-error.
    
    if avail ttitens
    then do:
        pok = no. 
        run senha_gerente (output pok).
        if pok
        then do:     
            run bagapifecha.p (setbcod, pcpf, ttitens.catcod, 
                            input-output pidBAG,
                            output phttp_code, output presposta).    

            run promaneio.

            if phttp_code = 200
            then do:
                vsalvar = no.
            end.    
            else do:
                message SKIP(2) presposta SKIP(2)
                    view-as alert-box.
        
            end.
        end.
    end.        

end procedure.



procedure promaneio.
def var tquantidade as int.
def var tvalor as dec.
varquivo = "/usr/admcom/relat/promaneio_bag_" + string(pidbag) + ".txt".
find estab where estab.etbcod = setbcod no-lock.
find first ttbag.

output to value(varquivo).
put unformatted skip
"                          " + "TERMO DE RECEBIMENTO E COMPRAS DE MERCADORIAS"
SKIP(2)
ttbag.nome + ", inscrito(a) sob cpf " + string(ttbag.cpf,"99999999999") + ", declaro que recebi de " 
estab.etbnom skip 
"inscrita sob o cnpj " + string(estab.etbcgc,"99999999999999") + ", nesta data, as " +
"mercadorias abaixo especificadas na BAG " + string(estab.etbcod,"999") + "/" + string(pidbag) + " :" skip(2).


    put unformatted skip
        "   " +
        string("SEQ","x(3)") + " | " +
        string("          ITEM","x(50)") + " | " +
        string(" QTD","x(4)") + " | " +
        string("Item que Escolhi","x(16)") + " | " 
        "     VALOR |"
        skip(1).
tquantidade = 0.
tvalor = 0.
for each bttitens by bttitens.sequencia.
    find bprodu where bprodu.procod = bttitens.codigoproduto no-lock no-error.
    put unformatted skip
        "   " +
        string(bttitens.sequencial,"zz9") + " | " +
        string(bttitens.codigoProduto,"zzzzzzzzz") + " " +
        string(if avail bprodu then bprodu.pronom else "","x(40)") + " | " +
        string(bttitens.quantidade,"zzz9") + " | " +
        string("________________","x(16)") + " | " +
        string(bttitens.valorTotal,"zzzzzz9.99") + " | " 
        
        skip.
    tquantidade = tquantidade + bttitens.quantidade.
    tvalor      = tvalor      + (bttitens.valorTotal).
     
end.
    put unformatted skip
        string("                                                             ","x(59)") " |_" +
        string("____") + "_|                  |____________|  " 
skip.
    put unformatted skip
        string("                                            TOTAL ITENS ->","x(59)") " | " +
        string(tquantidade,"zzz9") + " | " +
        "                 | " +
        string(tvalor,"zzzzzz9.99") + " | " 
        
        skip(1).
                  
put unformatted skip( 1)
    "                          " + caps(estab.munic) + "/" + caps(estab.ufecod) 
                        + ", " + string(day(today),"99") + " de " +
                caps(vmescomp[month(today)]) + " de " +  string(YEAR(today),"9999") + "." SKIP.

put unformatted skip(2)
"   Confirmo a compra das peças acima assinaladas em X, conforme os termos acordados com o(a) consultor Lebes." skip.
                
put unformatted skip(3)
    "                          " +  "_________________________________________________________" skip               .
put unformatted skip
    "                                            " +  ttbag.nome skip               .

find func where func.etbcod = setbcod and func.funcod = ttbag.consultor no-lock no-error.
put unformatted skip (3)
"Em caso de extravio ou perda de algumas das peças relacionadas acima, será debitado o valor no crediário Lebes do cliente." skip(2)
"Consultor (SISPE) : " + string(ttbag.consultor) + " " + (if avail func then func.funnom else "") skip(3)
"--------------------------------------------------------------------------------------------------------------------------" skip.

put unformatted skip(2)
"  Ciencia do recebimento:" skip(2)
"  Data:                                                     Assinatura:"
skip.

output close.

        run pdfout.p (input varquivo,
                      input "/usr/admcom/relat-pdf/",
                      input "promaneio_bag_" + string(pidbag) + ".pdf",
                      input "Portrait",
                      input 8.2,
                      input 1,
                      output vpdf).
              
        message "ID BAG " pidBAG skip(2)
                 "romaneio " + vpdf + " gerado!"
                view-as alert-box.


end procedure.

