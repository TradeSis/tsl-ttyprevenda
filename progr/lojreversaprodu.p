/*helio 06022023 - ID 158383 - Código EAN menu reversa - Pré venda */
/* reversa 092022 - helio */

{admcab.i}
{lojreversa.i}

def input param pcodCaixa   as int.
def buffer bttitens for ttitens.
def var vsalvar as log.

def var presposta as char.
def var phttp_code as int.


def var ctitle as char.
ctitle = "caixas " + string(pcodCaixa) + "    - REVERSA".



def var vhelp as char.
def var xtime as int.
def var vconta as int.
def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(11)" extent 6
    initial ["digita","altera","elimina","salva","fecha",""].

form
    esqcom1
    with frame f-com1 row 5 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

form
        ttitens.sequencial format ">>>9" column-label "seq"
        ttitens.codigoProduto column-label "codigo" format ">>>>>>>>9"
        produ.pronom column-label "nome produto" format "x(20)"
        ttitens.quantidade format ">>>9" column-label "qtd"

        with frame frame-a 7 down centered row 10
        no-box.


    disp 
        ctitle format "x(70)" no-label
        with frame ftit
            side-labels
            row 3
            centered
            no-box
            color messages.


empty temp-table ttreversa.
empty temp-table ttitens.

run lojapireversa-resgatacaixa.p (setbcod, pcodCaixa, output phttp_code, output presposta).    

    
if phttp_code <> 200
then do on endkey undo, retry:
    message phttp_code presposta.
    pause.
    return.
end.

find first ttreversa where ttreversa.estaborigem = string(setbcod) and
                           ttreversa.codcaixa    = string(pcodCaixa)
                           no-lock.


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
        
                        
        /*             
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
        */
    hide message no-pause.
    /*    
    if ttitens.titdescjur <> 0
    then do:
        if ttitens.titdescjur > 0
        then do:
                message color normal 
            "juros calculado em" ttitens.dtinc "de R$" trim(string(ttitens.titvljur + ttitens.titdescjur,">>>>>>>>>>>>>>>>>9.99"))    
            " dispensa de juros de R$"  trim(string(ttitens.titdescjur,">>>>>>>>>>>>>>>>>9.99")).
        end.
        else do:
            message color normal 
            "juros calculado em" ttitens.dtinc "de R$" trim(string(ttitens.titvljur + ttitens.titdescjur,">>>>>>>>>>>>>>>>>9.99"))    

            " juros cobrados a maior R$"  trim(string(ttitens.titdescjur * -1 ,">>>>>>>>>>>>>>>>>9.99")).
        
        end.
        
    end.
    */    
        
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
                message "SALVAR CAIXA?" UPDATE SRESP.
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
            if esqcom1[esqpos1] = "fecha"
            then do: 
                run pfecha.
                hide frame f-com1 no-pause.
                hide frame frame-a no-pause.

                return.
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
        with frame frame-a.


end procedure.

procedure color-message.
    color display message
        ttitens.sequencial
        produ.pronom 
        ttitens.codigoProduto
        ttitens.quantidade
    
        with frame frame-a.
end procedure.


procedure color-input.
    color display input
        ttitens.sequencial
        produ.pronom 
        ttitens.codigoProduto
        ttitens.quantidade
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        ttitens.sequencial
        produ.pronom 
        ttitens.codigoProduto
        ttitens.quantidade
 
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





/**

procedure geraCSV.
def var pordem as int.
 
def var varqcsv as char format "x(65)".
    varqcsv = "/admcom/relat/ttitens_" + lc(psituacao) + "_" + 
                string(today,"999999") + replace(string(time,"HH:MM:SS"),":","") + ".csv".
    
    
    disp varqcsv no-label colon 12
                            with side-labels width 80 frame f1
                            row 15 title "csv protestos ativos"
                            overlay.


message "Aguarde...". 
pause 1 no-message.

output to value(varqcsv).

put unformatted 
        "CPF ADESAO;NOME CLIENTE LEBES;NOME PACIENTE;DATA VENDA;DATA INICIO VIGENCIA;DATA FIM VIGENCIA;PLANO PGTO;STATUS VENDA;"   
        "DATA CANCELAMENTO;CERTIFICADO;LOJA;VALOR VENDA;VALOR REPASSE;VENDEDOR;PDV;NSU;"
        skip.
    for each ttitens.
        find ttitens where recid(ttitens) = ttitens.rec no-lock.
        run geraCsvImp.
    end.  


output close.

        hide message no-pause.
        message "Arquivo csv gerado " varqcsv.
        hide frame f1 no-pause.
        pause.    
end procedure.

procedure geraCsvImp.
def var vlrcobradocustas as dec.
def var vlrcobrado as dec.
def var vcp as char init ";".

        
def var vnomecliente    as char.        
def var vnomepaciente   as char.
def var vstatus         as char.
def var vvlrrepasse     as dec.
def var vvendedor       as char.
def var vcxacod         as int.
def var vdtinivig       as date.
def var vdtfimvig       as date.

    find baupagdados of ttitens where baupagdados.idcampo = "proposta.dataInicioVigencia" no-lock no-error.
    vdtinivig   = if avail baupagdados 
        then date(int(entry(2,baupagdados.conteudo,"-")), int(entry(3,baupagdados.conteudo,"-")),int(entry(1,baupagdados.conteudo,"-")))
        else ?.
    find baupagdados of ttitens where baupagdados.idcampo = "proposta.dataFimVigencia" no-lock no-error.
    vdtfimvig   = if avail baupagdados 
        then date(int(entry(2,baupagdados.conteudo,"-")), int(entry(3,baupagdados.conteudo,"-")),int(entry(1,baupagdados.conteudo,"-")))
        else ?.

    find baupagdados of ttitens where baupagdados.idcampo = "proposta.cliente.nome" no-lock no-error.
    vnomepaciente   = if avail baupagdados then baupagdados.conteudo else "".

    release clien.
    if ttitens.clicod <> 0 and ttitens.clicod <> ?
    then do:
        find clien where clien.clicod = ttitens.clicod no-lock no-error.    
    end.        
    vnomecliente    =  if avail clien then clien.clinom else vnomepaciente.
    
    vstatus = if ttitens.dtcanc = ? then "ATIVA" else if ttitens.dtcanc - ttitens.dtalt <= 8 then "ANULADO" else "CANCELADA". 
    
    find baupagdados of ttitens where baupagdados.idcampo = "proposta.codigoVendedor" no-lock no-error.
    vvendedor = baupagdados.conteudo + "-" .
    find func where func.estabOrigem = ttitens.estabOrigem and func.funcod = int(baupagdados.conteudo) no-lock no-error.
    if avail func then vvendedor = vvendedor + func.funnom.
    find cmon of ttitens no-lock no-error.
    vcxacod = if avail cmon then cmon.cxacod else 0.
        
    put unformatted 
        string(ttitens.cpf,"99999999999")       vcp
        vnomecliente    vcp
        vnomepaciente   vcp
        string(ttitens.dtalt,"99/99/9999") vcp
        if vdtinivig = ? then "" else string(vdtinivig,"99/99/9999")       vcp
        if vdtfimvig = ? then "" else string(vdtfimvig,"99/99/9999")       vcp
        ttitens.fincod         vcp
        vstatus         vcp
        if ttitens.dtcanc = ? then "" else string(ttitens.dtcanc,"99/99/9999") vcp
        ttitens.etbdest vcp
        ttitens.estabOrigem            vcp
        
        trim(replace(string(ttitens.valorServico,"->>>>>>>>>>>>>>>>>>>>>>9.99"),".",","))      vcp
        trim(replace(string(vvlrrepasse,"->>>>>>>>>>>>>>>>>>>>>>9.99"),".",","))                 vcp
        
        vvendedor                   vcp
        vcxacod                    vcp
        ttitens.nsuTransacao      vcp
        skip.
            

end procedure.
 

**/


procedure pdigita.
hide frame f-com1 no-pause.

/*def var vprocod like produ.procod format ">>>>>>>>9". helio 06022023 */
/* helio 06022023 - ean */
def var vprocod     as dec format ">>>>>>>>>>>>9" label "Produto".

def var vseq as int.
def var vqtd like ttitens.quantidade.
    form
        vprocod
        produ.pronom format "x(30)" no-label
        ttitens.quantidade
        with frame fdigita
        row 7
        1 down
        centered
        side-labels
        color messages.

    repeat with frame fdigita.
        
        
        update vprocod.
        /* helio 06022023 - inclusao ean */
            find produ where produ.procod = int(vprocod) no-lock no-error.
            if not avail produ
            then do:
                find first produ where produ.proindice = input vprocod
                                 no-lock no-error.
                if avail produ
                then vprocod = produ.procod.
            end.
            find produ where produ.procod = int(vprocod) no-lock no-error.
        /**/            
        if not avail produ
        then do:
            hide message no-pause.
            message "produto nao cadastrado".
            undo.
            
        end.                          
        disp produ.pronom.
        
        if int(ttreversa.categoria) = 0
        then do:
            find first bttitens where bttitens.codigoproduto <> vprocod no-error.
            if avail bttitens
            then do:
                if bttitens.catcod <> produ.catcod
                then do:
                    hide message no-pause.
                    message "categoria do produto invalida para esta caixa".
                    undo.
                end.
            end.
        end.
        else do:
            if int(ttreversa.categoria) <> produ.catcod
            then do:
                hide message no-pause.
                message "categoria do produto invalida para esta caixa".
                undo.
            end.
       end.
        
        find first ttitens where ttitens.codigoproduto = produ.procod no-error.
        if not avail ttitens
        then do:
            find last ttitens no-error.
            vseq = if avail ttitens then ttitens.sequencial + 1 else 1.
            create ttitens.
            ttitens.sequencial = vseq.
            ttitens.codigoproduto = produ.procod.
            ttitens.catcod = produ.catcod.
        end.

        ttitens.quantidade = ttitens.quantidade + 1.
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
        run lojapireversa-salvacaixa.p (setbcod, pcodCaixa, ttitens.catcod, output phttp_code, output presposta).    
        if phttp_code = 200
        then vsalvar = no.
    end.        

end procedure.

procedure pfecha.
def var pidPedidoGerado as char.
    find first ttitens no-error.
    
    if avail ttitens
    then do:
        run lojapireversa-fechacaixa.p (setbcod, pcodCaixa, ttitens.catcod, 
                output pidPedidoGerado,
                output phttp_code, output presposta).    
        if phttp_code = 200
        then do:
            vsalvar = no.
            message "PEDIDO GERADO NO SAP" skip(2)
            pidPedidoGerado
            view-as alert-box.
        end.    
        else do:
            message SKIP(2) presposta SKIP(2)
                view-as alert-box.
        
        end.
    end.        

end procedure.


