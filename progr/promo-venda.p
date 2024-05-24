/* helio 09032022 - [ORQUESTRA 243179 - ESCOPO ADICIONAL] Sele��o de moeda a vista na Pr�-Venda  */

/****************************************************************************
    Tipos: LIBERA-PRECO    ;   LIBERA-PLANO    ;  CASADINHA       ;
           DINHEIRO-NA-MAO ;   PLANO-DEFAULT   ;  PRECO-ESPECIAL  ; 
           DESCONTO-ITEM   ;   DESCONTO-TOTAL  ;  GERA-CPG        ;
           COMBO           ;
****************************************************************************/

{admcab.i} 

def new global shared var vpromocod   as char. /* helio 09032022 - [ORQUESTRA 243179 - ESCOPO ADICIONAL] Sele��o de moeda a vista na Pr�-Venda  */
def var xx as char.
function promocod returns char 
    ( input vsequencia as int):

    if vpromocod = ""
    then vpromocod = string(vsequencia).
    else do:
        if index(vpromocod,string(vsequencia)) = 0
        then vpromocod = vpromocod + "," + string(vsequencia).
    end.    

    return vpromocod.

end function.

def input parameter parametro-in as char.
def output parameter parametro-out as char.
def var vparam-despesa as log init no.
def var vok-promo-plano as log init no.
def var valor-produto-venda-casada as dec.
def var tipo-valor-venda-casada like ctpromoc.tipo.
def var venda-acima-de as log init no.
def var v-ativa as log.
def var p-brinde as dec.
def var prazo-total as dec.
def new shared var p-dtentra as date.
def new shared var p-dtparcela as date.
def new global shared var scartao as char.
def var vindice as dec.
def var promo-tudo as log .
def var spromoc as log init no.
def var produto-vinculado as log.
def var parcela-fixada as dec.
def var qtd-vinculado as int.
def var vin-valor as dec.
def var vin-pct as dec.
def var vpreco as dec.
def var p-venda-prazo as dec.
def var parce-total as dec. 
def var vpctgerente as dec.
def var vpctvendedor as dec.
def var vacha-despesa as char.
def var vacha-recibo as char.
def var vok-estac as log init no.
def var val-estac as log init no.
def new shared temp-table tt-wfcc
    field procod like produ.procod
    field clacod like produ.clacod
    field etccod like produ.etccod
    field catcod like produ.catcod
    field fabcod like produ.fabcod
    field movpc like movim.movpc
    field movqtm like movim.movqtm
    field qcomprado as dec
    field qcasado as dec
    field qbrinde as dec
    field lcomprado as log init no
    field lcasado as log init no
    field lbirnde as log init no .
def shared temp-table tt-valpromo 
    field tipo   as int
    field forcod as int
    field nome   as char
    field valor  as dec
    field recibo as log 
    field despro as char
    field desval as char.
def temp-table tt-valp
    field tipo   as int
    field forcod as int
    field nome   as char
    field valor  as dec
    field venda  as dec
    field recibo as log 
    field despro as char
    field desval as char
    index i1 tipo forcod valor .
for each tt-valpromo. delete tt-valpromo. end.
def var na-promocao as log.
def var na-casadinha as log.
def var p-procod like produ.procod.
def var p-fincod like finan.fincod.
def var p-ok as log.
def var vbrinde-menos as log init no. 
def var valt-movpc as log init no.
def var va as int.
def var vbr-ok as log.
def var vsetcod as int.
def shared var vdata-teste-promo as date.
assign
    p-procod = int(acha("PRODUTO",parametro-in))
    p-fincod = int(acha("PLANO",parametro-in))
    parametro-out = ""
    p-ok = no.
if acha("ALTERA-PRECO",parametro-in) = "N"
then valt-movpc = no.
else valt-movpc = yes.
def shared temp-table wf-movim no-undo
    field wrec      as   recid
    field movqtm    like movim.movqtm
    field lipcor    like liped.lipcor
    field movalicms like movim.movalicms
    field desconto  like movim.movdes
    field movpc     like movim.movpc
    field precoori  like movim.movpc
    field vencod    like func.funcod
    field KITproagr   like produ.procod.
def buffer bctpromoc for ctpromoc.
def buffer b1ctpromoc for ctpromoc.
def buffer fctpromoc for ctpromoc.
def buffer dctpromoc for ctpromoc.
def buffer qctpromoc for ctpromoc.
def var vliqui as dec.
def var vparce as dec.
def var ventra as dec.
def var total-venda as dec.
def var total-produ as dec.
def var total-venda-prazo as dec.
def var total-produ-prazo as dec.
def var total-vinculado as dec.
def var cartao-valor as dec. 
def var le-vinculado as log.
def var vqtd-pro as int init 0.
def var vpro-promo as int init 0.
def var vqtd-venda as int init 0.
def var vqtd-produ as int init 0.
def var val-tot-promo as dec init 0.
for each wf-movim:
    find produ where recid(produ) = wf-movim.wrec no-lock no-error.
    if not avail produ then next.
    if produ.proipiper = 98 /* Servico */
    then next.
    if produ.procod = p-procod
    then do:
        total-produ = wf-movim.movqtm * wf-movim.movpc.
        vqtd-produ = vqtd-produ + wf-movim.movqtm.
    end.
    total-venda = total-venda + (wf-movim.movqtm * wf-movim.movpc).
    vqtd-pro = vqtd-pro + wf-movim.movqtm.    
end.
if total-produ > 0
then do:
    if p-fincod > 0
    then do:
        
        run gercpg1.p( input p-fincod, 
                           input total-produ, 
                           input 0, 
                           input 0, 
                           output vliqui, 
                           output ventra,
                           output vparce). 
        find finan where finan.fincod = p-fincod no-lock no-error.
        if avail finan
        then total-venda-prazo = ventra + (vparce * finan.finnpc).
        else total-venda-prazo = vliqui.
    end.
    else total-produ-prazo = total-produ.
end.
if total-venda > 0
then do:
    if p-fincod > 0
    then do:
        run gercpg1.p( input p-fincod, 
                   input total-venda, 
                           input 0, 
                           input 0, 
                           output vliqui, 
                           output ventra,
                           output vparce). 
        find finan where finan.fincod = p-fincod no-lock no-error.
        if avail finan
        then total-venda-prazo = ventra + (vparce * finan.finnpc).
        else total-venda-prazo = vliqui.
    end.
    else total-venda-prazo = total-venda.
end. 
    
if p-fincod > 0 and acha("LIBERA-PLANO",parametro-in) <> ?
then do:
    find finan where finan.fincod = p-fincod no-lock no-error.
    if not avail finan then return.
    RUN p-libera-plano.
end.

if acha("PLANO-DEFAULT",parametro-in) <> ?
then do:
    vsetcod = int(acha("CATEGORIA",parametro-in)).
    if vsetcod > 0
    then RUN p-plano-default.
end.

if p-procod > 0 and acha("LIBERA-PRECO",parametro-in) <> ?
then do:
    find produ where produ.procod = p-procod no-lock no-error.
    if not avail produ then return.
    find clase where clase.clacod = produ.clacod no-lock no-error.
    if not avail clase then return.

    if (setbcod = 665 or setbcod = 907) and
       produ.catcod = 31 and produ.pronom begins "-RICK"
    then parametro-out = "LIBERA-PRECO=SIM".
    else RUN p-libera-preco.
end.

if p-procod > 0 and acha("DESCONTO-ITEM",parametro-in) <> ?
then do:
    find produ where produ.procod = p-procod no-lock no-error.
    if not avail produ then return.
    find clase where clase.clacod = produ.clacod no-lock no-error.
    if not avail clase then return.
    RUN p-desconto-item.
end.


if p-procod > 0 and acha("PRECO-ESPECIAL",parametro-in) <> ?
then do:
    find produ where produ.procod = p-procod no-lock no-error.
    if not avail produ then return.
    find clase where clase.clacod = produ.clacod no-lock no-error.
    if not avail clase then return.
    RUN preco-especial.
end.

if p-procod = 0 and acha("PRECO-ESPECIAL",parametro-in) <> ?
then do:
    for each wf-movim:
        find produ where recid(produ) = wf-movim.wrec no-lock no-error.
        if not avail produ then next.
        if produ.proipiper = 98 /* Servico */
        then next.
        find clase where clase.clacod = produ.clacod no-lock no-error.
        if not avail clase then next.
        RUN preco-especial1.
    end.
end.

if acha("CASADINHA",parametro-in) <> ?
then do:
    run p-casadinha.
end.

if acha("DINHEIRO-NA-MAO",parametro-in) <> ?
then do:
    run p-dinheiro-na-mao.
end.

if acha("DESCONTO-TOTAL",parametro-in) <> ?
then do:
    RUN p-desconto-total.
end.


if acha("GERA-CPG",parametro-in) <> ?
then do:
    find finan where finan.fincod = p-fincod no-lock no-error.
    if not avail finan then return.
    RUN p-gera-cpg.
end.

if acha("COMBO",parametro-in) <> ?
then do: 
    run p-combo.
end.


def var v-menos1 as log init yes.
def var vi as int init 0.
def var vbrinde like produ.procod extent 20 init 0.
def var vqbrinde as int extent 20 init 0.
def var qbrinde as int init 0.
def var qpago as int init 0.
def var vprodu like produ.procod extent 20 init 0.
def var qprodu as int init 0.
def var qtd-item as int init 0.
def var qtd-prod as int init 0.
def var qtd-menos as int init 0.
def var vok as log init no.
def var qtd-vendida as int.
def var cod-vendedor as int.
def var tipo-venda as char.
def buffer ectpromoc for ctpromoc.
def buffer pctpromoc for ctpromoc.
def buffer tctpromoc for ctpromoc.
def var vclicod like clien.clicod.

/* helio 09032022 - [ORQUESTRA 243179 - ESCOPO ADICIONAL] Sele��o de moeda a vista na Pr�-Venda  */

/**if vpromocod <> 0
then parametro-out = parametro-out + "PROMOCOD=" + 
                            string(vpromocod) +
                            "|". ***/

/* helio 09032022 - [ORQUESTRA 243179 - ESCOPO ADICIONAL] Sele��o de moeda a vista na Pr�-Venda  */

procedure desconto:
    def var qvp-qtd as dec.
    qvp-qtd = 0.
    if valt-movpc
    then do:
        if ctpromoc.campolog4 = yes
        then do:
            if wf-movim.movqtm >= campodec2[4] and
               wf-movim.movqtm <= campodec2[5]
            then do:
                spromoc = no.
                find first wf-movim where 
                       wf-movim.wrec = recid(produ) no-error.
                if avail wf-movim
                then do:     
                    vpreco = wf-movim.movpc.
                    run find-pro-promo.
                    if na-promocao
                    then do:
                        if ctpromoc.descontovalor > 0
                        then do:
                            wf-movim.movpc = vpreco - ctpromoc.descontovalor.
                            spromoc = yes.
                        end.
                        else if ctpromoc.descontopercentual > 0
                        then do:
                            wf-movim.movpc = vpreco -
                             (vpreco * (ctpromoc.descontopercentual / 100)) .
                            spromoc = yes.
                            
                            /* helio 09032022 - [ORQUESTRA 243179 - ESCOPO ADICIONAL] Sele��o de moeda a vista na Pr�-Venda  */

                            xx = promocod(ctpromoc.sequencia).
                            
                            
                        end.
                        wf-movim.desconto =  
                            wf-movim.precoori - wf-movim.movpc.
                    end.
                end.
            end.   
        end.
        else do:
           
             
            qvp-qtd = 0.
            for each wf-movim no-lock:
                find produ where recid(produ) = wf-movim.wrec no-lock no-error.
                if not avail produ then next.
                
                
                /* helio 27042023 - modulo bis moda, desconto no plano bis */
                if ((ctpromoc.sequencia = 30085 or ctpromoc.sequencia = 30106) and setbcod = 188) or
                   (ctpromoc.sequencia = 60878 or
                    ctpromoc.sequencia = 65507) 
                then do:
                    if produ.proipiper = 98
                    then do:
                        if produ.procod = 559911 /* permite desconto somente para este codigo plano bis */
                        then.
                        else next.
                    end.    
                end.
                else do:   
                /**/
                    if produ.proipiper = 98 /* Servico */
                    then next.
                end.
                run find-pro-promo.
                if na-promocao
                then qvp-qtd  = qvp-qtd + wf-movim.movqtm.
            end.
            if (ctpromoc.campodec2[4] = 0 or
                qvp-qtd >= ctpromoc.campodec2[4]) and
               (ctpromoc.campodec2[5] = 0 or
                qvp-qtd <= ctpromoc.campodec2[5]) 
            then do:
                for each wf-movim no-lock:
                    find produ where recid(produ) = wf-movim.wrec
                           no-lock no-error.
                    if not avail produ then next.
                    
                    /* helio 27042023 - modulo bis moda, desconto no plano bis */ 
                    
                    if ((ctpromoc.sequencia = 30085 or ctpromoc.sequencia = 30106) and setbcod = 188) or
                       (ctpromoc.sequencia = 60878 or
                        ctpromoc.sequencia = 65507) 
                    then do:
                        if produ.proipiper = 98
                        then do:
                            if produ.procod = 559911 /* permite desconto somente para este codigo plano bis */
                            then.
                            else next.
                        end.    
                    end.
                    else do:   
                    /**/
                        if produ.proipiper = 98 /* Servico */
                        then next.
                    end.
                    
                    vpreco = wf-movim.movpc.
                    run find-pro-promo.

                    if ((ctpromoc.sequencia = 30085 or ctpromoc.sequencia = 30106) and setbcod = 188) or
                       (ctpromoc.sequencia = 60878 or
                        ctpromoc.sequencia = 65507) 
                    then do:
                        if produ.proipiper = 98
                        then do:
                            if produ.procod = 559911 /* permite desconto somente para este codigo plano bis */
                            then na-promocao = yes.
                        end.    
                    end.

                    if na-promocao
                    then do:
                        if ctpromoc.descontovalor > 0
                        then do:
                            wf-movim.movpc = vpreco - ctpromoc.descontovalor.
                            spromoc = yes.
                        end.
                        else if ctpromoc.descontopercentual > 0
                        then do:
                            wf-movim.movpc = vpreco -
                             (vpreco * (ctpromoc.descontopercentual / 100)) .

                            /* helio 09032022 - [ORQUESTRA 243179 - ESCOPO ADICIONAL] Sele��o de moeda a vista na Pr�-Venda  */ 
                            xx = promocod(ctpromoc.sequencia).
 
                            spromoc = yes.
                        end.
                        wf-movim.desconto =  
                            wf-movim.precoori - wf-movim.movpc.
                    end.
                end.
            end. 
        end.
    end.
end procedure.
procedure promo-casadinha-especial:
    def var qtd-comprado as dec.
    def var qtd-casado as dec.
    def var vrep as int.
    for each tt-wfcc: delete tt-wfcc. end.
    for each wf-movim no-lock by wf-movim.movpc descending:
        find produ where recid(produ) = wf-movim.wrec no-lock no-error.
        if not avail produ then next.
        if produ.proipiper = 98 /* Servico */
        then next.
        create tt-wfcc.
        assign
            tt-wfcc.procod = produ.procod
            tt-wfcc.catcod = produ.catcod
            tt-wfcc.fabcod = produ.fabcod
            tt-wfcc.etccod = produ.etccod
            tt-wfcc.clacod = produ.clacod
            tt-wfcc.movpc  = wf-movim.movpc
            tt-wfcc.movqtm = wf-movim.movqtm.
        na-promocao = no.
        run find-pro-promo.
        na-casadinha = no.
        run find-cas-promo.
        if na-promocao 
        then tt-wfcc.lcomprado = yes.
        if na-casadinha
        then tt-wfcc.lcasado = yes.
    end.
    def var vterminou as log.
    def var q-comprado as dec init 0.
    def var q-casado   as dec init 0.
    def buffer btt-wfcc for tt-wfcc.
    vterminou = no.
    repeat:
        do vi = 1 to ctpromoc.qtdvenda:
            find first tt-wfcc where
                       tt-wfcc.lcomprado = yes and
                       tt-wfcc.movqtm   > 0 
                        no-error .
            if not avail tt-wfcc
            then vterminou = yes.
            else do:
                tt-wfcc.qcomprado = tt-wfcc.qcomprado + 1.
                tt-wfcc.movqtm   = tt-wfcc.movqtm   - 1.
            end.    
        end.
        do vi = 1 to ctpromoc.qtdbrinde:  
            find first btt-wfcc where
                       btt-wfcc.lcasado = yes and
                       btt-wfcc.movqtm   > 0 no-error.
            if not avail btt-wfcc
            then vterminou = yes.
            else do:
                btt-wfcc.qcasado = btt-wfcc.qcasado + 1.
                btt-wfcc.movqtm   = btt-wfcc.movqtm - 1.
            end.
        end.
        if vterminou then leave.
    end.
    qtd-comprado = 0.
    qtd-casado = 0.
    for each tt-wfcc no-lock:
        if tt-wfcc.qcomprado = 0 then lcomprado = no.
        if tt-wfcc.qcasado = 0 then lcasado = no.
        qtd-comprado = qtd-comprado + tt-wfcc.qcomprado.
        qtd-casado   = qtd-casado + tt-wfcc.qcasado.
    end.    
    if ctpromoc.qtdvenda = qtd-comprado and
       ctpromoc.qtdbrinde = qtd-casado
    then do:   
    find first tt-wfcc where tt-wfcc.etccod <> 1 no-lock no-error.
    if not avail tt-wfcc 
    then do:
        for each wf-movim no-lock:
            find produ where recid(produ) = wf-movim.wrec no-lock no-error.
            if not avail produ then next.
            if produ.proipiper = 98 /* Servico */
            then next.
            find first tt-wfcc where
                       tt-wfcc.procod = produ.procod and 
                       tt-wfcc.lcasado = yes and
                       tt-wfcc.qcasado > 0  and
                       tt-wfcc.qcasado <= wf-movim.movqtm
                       no-error.
            if avail tt-wfcc  and
                tt-wfcc.qcasado + tt-wfcc.qcomprado = wf-movim.movqtm
            then do:
                wf-movim.movpc = ((wf-movim.movpc * wf-movim.movqtm) -
                             (wf-movim.movpc * tt-wfcc.qcasado) +
                            ( 1 * tt-wfcc.qcasado)) / wf-movim.movqtm.
            end.
        end.
    end.
    else do:
        for each wf-movim no-lock:
            find produ where recid(produ) = wf-movim.wrec no-lock no-error.
            if not avail produ then next.
            if produ.proipiper = 98 /* Servico */
            then next.
            find first tt-wfcc where
                       tt-wfcc.procod = produ.procod and
                       tt-wfcc.lcasado = yes and
                       tt-wfcc.qcasado > 0  and
                       tt-wfcc.qcasado <= wf-movim.movqtm
                       no-error.
            if avail tt-wfcc  and
                tt-wfcc.qcasado + tt-wfcc.qcomprado = wf-movim.movqtm
            then do:
                wf-movim.movpc = wf-movim.movpc * .50.
            end.
        end.
    end.
    end.
end procedure.
procedure calcula-total-venda:
    total-produ = 0.
    total-venda = 0.
    vqtd-pro = 0.
    for each wf-movim:
        find produ where recid(produ) = wf-movim.wrec no-lock no-error.
        if not avail produ then next.
        if produ.proipiper = 98 /* Servico */
        then next.
        na-promocao = no.
        run find-pro-promo.
        if ctpromoc.campolog4
        then do:
            if not na-promocao
            then vqtd-pro = vqtd-pro + wf-movim.movqtm.
            else do:
                total-venda = total-venda + (wf-movim.movqtm * wf-movim.movpc).
                vqtd-pro = vqtd-pro + wf-movim.movqtm.    
                do vi = 1 to ctpromoc.qtdbrinde:
                    if vbrinde[vi] = produ.procod
                    then do:
                        total-venda = total-venda -
                            (wf-movim.movqtm * wf-movim.movpc).
                        vbrinde-menos = yes.
                    end.
                end.
            end.
        end.
        else do:
            if produ.procod = p-procod
            then total-produ = wf-movim.movqtm * wf-movim.movpc.
            vqtd-pro = vqtd-pro + wf-movim.movqtm.
            if na-promocao 
            then do: 
                total-venda = total-venda + (wf-movim.movqtm * wf-movim.movpc).
                do vi = 1 to ctpromoc.qtdbrinde:
                    if vbrinde[vi] = produ.procod
                    then do:
                        total-venda = total-venda -
                            (vqbrinde[vi] * wf-movim.movpc).
                        vbrinde-menos = yes.
                    end.
                end.
            end.
        end.
    end.
end procedure.
procedure quantidade-vendida:
    def input parameter vp-tipo as char.
    qtd-vendida = 0.
    cod-vendedor = 0.
    def var venda-total as dec.
    def var gb as dec init 1.
    def var gm as dec init 200.
    def var ga as dec init 500.
    tipo-venda = "".
    for each wf-movim no-lock:
        find produ where recid(produ) = wf-movim.wrec no-lock no-error.
        if not avail produ then next.
        if produ.proipiper = 98 /* Servico */
        then next.
        find clase where clase.clacod = produ.clacod no-lock no-error.
        if avail clase and
           (clase.clanom begins "CHIP" or
            clase.clanom matches "*CHIP*")
        then next.         
        run find-pro-promo.
        if na-promocao 
        then do:
            cod-vendedor = wf-movim.vencod.
            venda-total = venda-total + (wf-movim.movpc * wf-movim.movqtm).
            qtd-vendida = qtd-vendida + wf-movim.movqtm.
        end.    
    end. 
    if vp-tipo = "PROMOTOR"
    then cod-vendedor = 0.
    if venda-total > 0  and
       venda-total >= ctpromoc.vendaacimade  and
       venda-total <= ctpromoc.campodec2[3]
    then do:    
        if venda-total >= ga
        then tipo-venda = "GA".
        else if venda-total >= gm
            then tipo-venda = "GM".
            else if venda-total >= gb
                then tipo-venda = "GB".
        for each tctpromoc where
                 tctpromoc.sequencia = ctpromoc.sequencia and
                 tctpromoc.linha > 0 and
                 tctpromoc.procod > 0
                 no-lock .
            find produ where produ.procod = tctpromoc.procod no-lock.
            find clase where clase.clacod = produ.clacod no-lock no-error.
            if avail clase and
                (clase.clanom begins "CHIP" or
                clase.clanom matches "*CHIP*")
            then next. 
            for each movim where 
                     movim.etbcod = setbcod and
                     movim.movtdc = 5 and
                     movim.procod = produ.procod and
                     movim.movdat >= ctpromoc.dtinicio and
                     movim.movdat <= ctpromoc.dtfim
                     no-lock,
                    first plani where plani.etbcod = movim.etbcod and
                                  plani.placod = movim.placod and
                                  plani.movtdc = movim.movtdc and
                                  plani.pladat = movim.movdat and
                                 (if cod-vendedor > 0
                                  then plani.vencod = cod-vendedor else true)
                                  no-lock:
                    if movim.movpc >= ctpromoc.vendaacimade and
                        movim.movpc <= ctpromoc.campodec2[3]
                    then qtd-vendida = qtd-vendida + movim.movqtm.
                end.
        end.
        for tctpromoc where
                    tctpromoc.sequencia = ctpromoc.sequencia and
                    tctpromoc.linha > 0 and
                    tctpromoc.clacod > 0
                    no-lock .
            if tctpromoc.situacao = "I" or
               tctpromoc.situacao = "E"
            then next.  
            find clase where clase.clacod = tctpromoc.clacod no-lock no-error.
            if avail clase and
                (clase.clanom begins "CHIP" or
                clase.clanom matches "*CHIP*")
            then next. 
            for each produ where produ.clacod = tctpromoc.clacod no-lock:
                find first pctpromoc where 
                           pctpromoc.sequencia = ctpromoc.sequencia and
                           pctpromoc.linha > 0 and
                           pctpromoc.procod = produ.procod
                           no-lock no-error.
                if avail pctpromoc and
                         (pctpromoc.situacao = "I" or
                         pctpromoc.situacao = "E")
                then next.           
                for each movim where 
                     movim.etbcod = setbcod and
                     movim.movtdc = 5 and
                     movim.procod = produ.procod and
                     movim.movdat >= ctpromoc.dtinicio and
                     movim.movdat <= ctpromoc.dtfim
                     no-lock,
                    first plani where plani.etbcod = movim.etbcod and
                                  plani.placod = movim.placod and
                                  plani.movtdc = movim.movtdc and
                                  plani.pladat = movim.movdat and
                                 (if cod-vendedor > 0
                                  then plani.vencod = cod-vendedor else true)
                                  no-lock:
                    if movim.movpc >= ctpromoc.vendaacimade and
                        movim.movpc <= ctpromoc.campodec2[3]
                    then qtd-vendida = qtd-vendida + movim.movqtm.
                end. 
            end.
        end.
    end.
end procedure.
procedure cria-temp-valor:
    def input parameter p-tipo as int.
    def input parameter p-nome as char.
    def input parameter p-valor as dec.
    def input parameter p-venda as dec.
    def var p-forcod as int.
    def var p-gerente as int.
    def var p-supervisor as int.
    def var p-promotor as int.
    if p-nome = "VENDEDOR"
    THEN DO:
        p-forcod = int(acha("FORNE-VENDEDOR",ctpromoc.campochar[2])).
        find first  
            tt-valp where
            tt-valp.tipo   = p-tipo and
            tt-valp.forcod = p-forcod and
            tt-valp.venda = p-venda        
            no-error.
        if not avail tt-valp
        then do:
            create tt-valp.
            assign
                tt-valp.tipo = p-tipo
                tt-valp.forcod = p-forcod
                tt-valp.nome = p-nome
                tt-valp.recibo = ctpromoc.recibo
                tt-valp.venda = p-venda
                tt-valp.valor = p-valor.
        END.
        else assign tt-valp.valor = tt-valp.valor + p-valor.
    end. 
    if p-nome = "GERENTE"
    THEN DO:
        p-gerente = int(acha("FORNE-GERENTE",ctpromoc.campochar[2])).
        find first  
            tt-valp where
            tt-valp.tipo   = p-tipo and
            tt-valp.forcod = p-gerente and
            tt-valp.venda = p-venda        
            no-error.

        if not avail tt-valp
        then do:
            create tt-valp.
            assign
                tt-valp.tipo = p-tipo
                tt-valp.forcod = p-gerente
                tt-valp.nome = p-nome
                tt-valp.recibo = ctpromoc.recibo
                tt-valp.venda = p-venda.
        END.
        tt-valp.valor = tt-valp.valor + p-valor .
    end.                          
    if p-nome = "SUPERVISOR"
    THEN DO:
        p-supervisor = int(acha("FORNE-SUPERVISOR",ctpromoc.campochar[2])).
        find first  
            tt-valp where
            tt-valp.tipo   = p-tipo and
            tt-valp.forcod = p-supervisor and
            tt-valp.venda = p-venda        
            no-error.
        if not avail tt-valp
        then do:
            create tt-valp.
            assign
                tt-valp.tipo = p-tipo
                tt-valp.forcod = p-supervisor
                tt-valp.nome = p-nome
                tt-valp.recibo = ctpromoc.recibo
                tt-valp.venda = p-venda.
        END.
        tt-valp.valor = tt-valp.valor + p-valor.
    end.  
    if p-nome = "PROMOTOR"
    THEN DO:
        p-promotor = int(acha("FORNE-PROMOTOR",ctpromoc.campochar[2])).
        find first  
            tt-valp where
            tt-valp.tipo   = p-tipo and 
            tt-valp.forcod = p-promotor and
            tt-valp.venda = p-venda        
            no-error.
        if not avail tt-valp
        then do:
            create tt-valp.
            assign
                tt-valp.tipo = p-tipo
                tt-valp.forcod = p-promotor
                tt-valp.nome = p-nome
                tt-valp.recibo = ctpromoc.recibo
                tt-valp.venda = p-venda.
        END.
        tt-valp.valor =  tt-valp.valor + p-valor    .
    end.
    if p-nome = "PROMOCAO"
    THEN DO:
        find first  
            tt-valp where
            tt-valp.tipo   = p-tipo and 
            tt-valp.forcod = ctpromoc.sequencia
            no-error.
        if not avail tt-valp
        then do:
            create tt-valp.
            assign
                tt-valp.tipo = p-tipo
                tt-valp.forcod = ctpromoc.sequencia
                tt-valp.nome = p-nome.
        END.
    end.  
    if p-nome = "COMBOV" or p-nome = "COMBOP" 
    then do:
        find first  
            tt-valp where
            tt-valp.tipo   = p-tipo and 
            tt-valp.forcod = ctpromoc.sequencia
            no-error.
        if not avail tt-valp
        then do:
            create tt-valp.
            assign
                tt-valp.tipo = p-tipo
                tt-valp.forcod = ctpromoc.sequencia
                tt-valp.nome = p-nome
                tt-valp.valor = p-valor .
        END.
    end. 
end procedure.
procedure p-gera-cpg:
    for each ctpromoc where  (if vdata-teste-promo <> ?
                              then ctpromoc.dtinicio >= vdata-teste-promo
                              else ctpromoc.dtinicio <= today) and
         ctpromoc.dtfim  >= today and
         ctpromoc.linha = 0 
         no-lock:
         if ctpromoc.situacao <> "L"
         then next.
         if ctpromo.promocod = 54 then next.
        if ctpromoc.tipo <> ""
        then next.
        if scartao = "" and 
            (ctpromo.promocod = 28 or
             ctpromoc.descricao[1] matches "*CARTAO LEBES*" or
             ctpromoc.descricao[2] matches "*CARTAO LEBES*")
        THEN NEXT.   
        if ctpromoc.situacao = "L" and 
            ((ctpromoc.dtentrada <> ? and
            ctpromoc.dtentrada >= today ) or
            (ctpromoc.dataparcela <> ? and
            ctpromoc.dataparcela >= today) or
            (ctpromoc.arredonda   <> ? and
             ctpromoc.arredonda   <> 0))
        then do:
            p-ok = no.
            find first bctpromoc where
                 bctpromoc.sequenci = ctpromoc.sequencia and
                 bctpromoc.linha > 0 and
                 bctpromoc.fincod <> ? no-lock no-error.
            if avail bctpromoc 
            then do:    
            for each bctpromoc where
                 bctpromoc.sequenci = ctpromoc.sequencia and
                 bctpromoc.linha > 0 and
                 bctpromoc.fincod <> ? no-lock:
                if bctpromoc.fincod = p-fincod and
                    bctpromoc.situacao <> "I" and
                    bctpromoc.situacao <> "E"
                then do:
                    find first ectpromoc where
                               ectpromoc.sequencia = ctpromoc.sequencia and
                               ectpromoc.etbcod > 0 no-lock no-error.
                    if not avail ectpromoc
                    then p-ok = yes.
                    else do:   
                        find first ectpromoc where
                               ectpromoc.sequencia = ctpromoc.sequencia and
                               ectpromoc.etbcod = setbcod no-lock no-error.
                        if avail ectpromoc
                        then do:
                            if ectpromoc.situacao <> "I" and
                               ectpromoc.situacao <> "E"
                            then     p-ok = yes.
                        end.
                    end. 
                end.
            end.
            end.
            if p-ok = yes
            then do:
                spromoc = no.
                if ctpromoc.dtentrada <> ?
                then do:
                    parametro-out = parametro-out + "DATA-ENTRADA=" + 
                            string(ctpromoc.dtentrada,"99/99/9999") +
                            "|".
                    spromoc = yes.
                end.
                if ctpromoc.dataparcela <> ?
                then do:
                    parametro-out = parametro-out + "DATA-PARCELA=" + 
                            string(ctpromoc.dataparcela,"99/99/9999") +
                            "|".
                    spromoc = yes.
                end.
                if ctpromoc.arredonda <> ? and
                   ctpromoc.arredonda <> 0
                then do:
                    parametro-out = parametro-out + "ARREDONDA-PARCELA=" + 
                        string(ctpromoc.arredonda,">>9.99") + "|".
                    spromoc = yes.
                end. 
                if spromoc = yes
                then run cria-temp-valor(9, "PROMOCAO", 0, 0).
            end.
        end.
        else if ctpromoc.situacao = "L" and 
             ((ctpromoc.diasentrada <> ? and
              ctpromoc.diasentrada <> 0) or
             (ctpromoc.diasparcela <> ? and
              ctpromoc.diasparcela <> 0) or
             (ctpromoc.arredonda   <> ? and
              ctpromoc.arredonda   <> 0))
        then do:
            p-ok = no.
            find first bctpromoc where
                 bctpromoc.sequenci = ctpromoc.sequencia and
                 bctpromoc.linha > 0 and
                 bctpromoc.fincod <> ? no-lock no-error.
            if avail bctpromoc
            then do:    
            for each bctpromoc where
                 bctpromoc.sequenci = ctpromoc.sequencia and
                 bctpromoc.linha > 0 and
                 bctpromoc.fincod <> ? no-lock:
                if bctpromoc.fincod = p-fincod  and
                   bctpromoc.situacao <> "I" and
                   bctpromoc.situacao <> "E"
                then do:
                    find first ectpromoc where
                               ectpromoc.sequencia = ctpromoc.sequencia and
                               ectpromoc.etbcod > 0 no-lock no-error.
                    if not avail ectpromoc
                    then p-ok = yes.
                    else do:
                        find first ectpromoc where
                               ectpromoc.sequencia = ctpromoc.sequencia and
                               ectpromoc.etbcod = setbcod no-lock no-error.
                        if avail ectpromoc
                        then do:
                            if ectpromoc.situacao <> "I" and
                               ectpromoc.situacao <> "E"
                            then     p-ok = yes.
                        end.
                    end. 
                end.
            end.
            end.
            if p-ok = yes
            then do:
                spromoc = no.
                if ctpromoc.diasentrada <> ? and
                   ctpromoc.diasentrada > 0
                then do:
                    parametro-out = parametro-out + "DATA-ENTRADA=" + 
                        string(today + ctpromoc.diasentrada,"99/99/9999") +
                            "|".
                    spromoc = yes.
                end.
                if ctpromoc.diasparcela <> ? and
                   ctpromoc.diasparcela > 0
                then do:
                    parametro-out = parametro-out + "DATA-PARCELA=" + 
                        string(today + ctpromoc.diasparcela,"99/99/9999") +
                            "|".
                    spromoc = yes.
                end.
                if ctpromoc.arredonda <> ? and
                   ctpromoc.arredonda <> 0
                then do:
                    parametro-out = parametro-out + "ARREDONDA-PARCELA=" + 
                        string(ctpromoc.arredonda,">>9.99") + "|".
                    spromoc = yes.
                end. 
                if spromoc = yes
                then run cria-temp-valor(9, "PROMOCAO", 0, 0).
            end.
        end.
    end.        
end procedure.
procedure p-libera-preco:
    for each ctpromoc where  (if vdata-teste-promo <> ?
                              then ctpromoc.dtinicio >= vdata-teste-promo
                              else ctpromoc.dtinicio <= today) and
         ctpromoc.dtfim  >= today and
         ctpromoc.linha = 0
         no-lock:
        if ctpromo.promocod = 54 then next.
        if ctpromoc.tipo <> ""
        then next.
        if scartao = "" and
            (ctpromoc.promocod = 28  or
             ctpromoc.descricao[1] matches "*CARTAO LEBES*" or
             ctpromoc.descricao[2] matches "*CARTAO LEBES*")
        THEN NEXT.
        if ctpromoc.situacao = "L" and ctpromoc.precoliberado
        then do:
            for each bctpromoc where
                 bctpromoc.sequenci = ctpromoc.sequencia and
                 bctpromoc.linha > 0 and
                 bctpromoc.procod > 0 no-lock:
                if bctpromoc.procod = produ.procod 
                then do:
                    p-ok = yes.
                    leave.
                end.
            end.
            if p-ok = no
            then
            for each bctpromoc where
                 bctpromoc.sequenci = ctpromoc.sequencia and
                 bctpromoc.linha > 0 and
                 bctpromoc.clacod > 0 no-lock:
                if bctpromoc.situacao = "I" or
                   bctpromoc.situacao = "E"
                then next.   
                if bctpromoc.clacod = clase.clacod or
                   bctpromoc.clacod = clase.clasup
                then do:
                    p-ok = yes.
                    leave.
                end.
            end.
            if p-ok = no
            then
            for each bctpromoc where
                 bctpromoc.sequenci = ctpromoc.sequencia and
                 bctpromoc.linha > 0 and
                 bctpromoc.setcod > 0 no-lock:
                if bctpromoc.setcod = produ.catcod
                then do:
                    p-ok = yes.
                    leave.
                end.
            end.
            if p-ok = no
            then
            for each bctpromoc where
                 bctpromoc.sequenci = ctpromoc.sequencia and
                 bctpromoc.linha > 0 and
                 bctpromoc.fabcod > 0 no-lock:
                if bctpromoc.fabcod = produ.fabcod
                then do:
                    p-ok = yes.
                    leave.
                end.
            end.         
            if p-ok = yes
            then do:
                find first bctpromoc where
                    bctpromoc.sequenci = ctpromoc.sequencia and
                    bctpromoc.linha > 0 and
                    bctpromoc.etbcod  > 0 no-lock no-error.
                if avail bctpromoc
                then do:
                    find first dctpromoc where
                        dctpromoc.sequenci = ctpromoc.sequencia and
                        dctpromoc.linha  > 0 and
                        dctpromoc.etbcod = setbcod no-lock no-error.
                    if not avail dctpromoc  or
                        dctpromoc.situacao = "I"  or
                        dctpromoc.situacao = "E"
                    then p-ok = no.
                end.    
            end.
            if p-ok = yes and
               ctpromoc.promocod <> 20
            then do:
                run cria-temp-valor(9, "PROMOCAO", 0, 0).
                parametro-out = parametro-out + "LIBERA-PRECO=S|".
                leave.
            end.
        end.
    end.
end procedure.
procedure p-desconto-item:
    for each ctpromoc where  (if vdata-teste-promo <> ?
                              then ctpromoc.dtinicio >= vdata-teste-promo
                              else ctpromoc.dtinicio <= today) and
         ctpromoc.dtfim  >= today and
         ctpromoc.linha = 0
         no-lock by ctpromoc.descontopercentual:
        if ctpromo.promocod = 54 then next.
        if ctpromoc.tipo <> ""
        then next.
        if scartao = "" and 
            (ctpromo.promocod = 28 or
             ctpromoc.descricao[1] matches "*CARTAO LEBES*" or
             ctpromoc.descricao[2] matches "*CARTAO LEBES*")
        THEN NEXT. 
        p-ok = no.
        if ctpromoc.situacao = "L" and 
            (ctpromoc.descontovalor > 0 or
             ctpromoc.descontopercentual > 0) and
              ctpromoc.campolog4 = yes and
              valt-movpc = yes
        then do:
            for each bctpromoc where
                 bctpromoc.sequenci = ctpromoc.sequencia and
                 bctpromoc.linha > 0 and
                 bctpromoc.procod > 0 and
                 bctpromoc.situacao <> "I" and 
                 bctpromoc.situacao <> "E"
                 no-lock:
                if bctpromoc.procod = produ.procod 
                then do:
                    p-ok = yes.
                    leave.
                end.
            end.
            if p-ok = no
            then
            for each bctpromoc where
                 bctpromoc.sequenci = ctpromoc.sequencia and
                 bctpromoc.linha > 0 and
                 bctpromoc.clacod > 0 and
                 bctpromoc.situacao <> "I" and 
                 bctpromoc.situacao <> "E"
                 no-lock:
                if bctpromoc.clacod = clase.clacod or
                   bctpromoc.clacod = clase.clasup
                then do:
                    p-ok = yes.
                    leave.
                end.
            end.
            if p-ok = no
            then
            for each bctpromoc where
                 bctpromoc.sequenci = ctpromoc.sequencia and
                 bctpromoc.linha > 0 and
                 bctpromoc.setcod > 0 no-lock:
                if bctpromoc.setcod = produ.catcod
                then do:
                    p-ok = yes.
                    leave.
                end.
            end.
            if p-ok = no
            then
            for each bctpromoc where
                 bctpromoc.sequenci = ctpromoc.sequencia and
                 bctpromoc.linha > 0 and
                 bctpromoc.fabcod > 0 no-lock:
                if bctpromoc.fabcod = produ.fabcod
                then do:
                    p-ok = yes.
                    leave.
                end.
            end.         
            if p-ok = yes
            THEN DO:
                find first bctpromoc where
                    bctpromoc.sequenci = ctpromoc.sequencia and
                    bctpromoc.linha > 0 and
                    bctpromoc.etbcod  > 0 
                    no-lock no-error.
                if avail bctpromoc
                then do:
                    find first dctpromoc where
                        dctpromoc.sequenci = ctpromoc.sequencia and
                        dctpromoc.linha  > 0 and
                        dctpromoc.etbcod = setbcod no-lock no-error.
                    if avail dctpromoc and
                        dctpromoc.situacao <> "I" and
                        dctpromoc.situacao <> "E"
                    then.
                    else if avail dctpromoc
                    then p-ok = no.
                    else if not avail dctpromoc
                    then do:
                        find first dctpromoc where
                                   dctpromoc.sequenci = ctpromoc.sequencia and
                                   dctpromoc.linha  > 0 and
                                   dctpromoc.etbcod > 0 and
                                   dctpromoc.situacao <> "I" and
                                   dctpromoc.situacao <> "E"
                                   no-lock no-error.
                        if avail dctpromoc
                        then p-ok = no.
                    end.
                end.
                if p-ok = yes
                then do:
                    find first bctpromoc where
                        bctpromoc.sequenci = ctpromoc.sequencia and
                        bctpromoc.linha > 0 and
                        bctpromoc.procod = produ.procod no-lock no-error.
                    if avail bctpromoc and 
                        bctpromoc.situacao <> "I" and 
                        bctpromoc.situacao <> "E"
                    then.
                    else if avail bctpromoc
                    then p-ok = no.
                end.
                if p-ok = yes
                then do:
                    find first bctpromoc where
                        bctpromoc.sequenci = ctpromoc.sequencia and
                        bctpromoc.linha > 0 and
                        bctpromoc.clacod = clase.clacod
                        no-lock no-error.
                    if avail bctpromoc and
                        bctpromoc.situacao <> "I" and 
                        bctpromoc.situacao <> "E"
                    then.
                    else if avail bctpromoc
                    then p-ok = no.    
                    else if not avail bctpromoc
                    then do:
                        find first bctpromoc where
                            bctpromoc.sequenci = ctpromoc.sequencia and
                            bctpromoc.linha > 0 and
                            bctpromoc.clacod = clase.clasup
                            no-lock no-error.
                        if avail bctpromoc and
                            bctpromoc.situacao <> "I" and 
                            bctpromoc.situacao <> "E"
                        then.
                        else if avail bctpromoc
                        then p-ok = no.  
                    end.
                end.
            end.
            if p-ok = yes 
            then do:
                run calcula-total-venda.
                if ctpromoc.vendaacimade > 0  and
                    total-venda > 0
                then do:
                    if ctpromoc.campolog3 = no
                    then do:
                            run valor-prazo.
                    end.
                    else total-venda-prazo = total-venda.
                end.    
                if ctpromoc.vendaacimade = 0 or
                        (total-venda-prazo >= ctpromoc.vendaacimade and
                        (ctpromoc.campodec2[3] = 0 or
                         total-venda-prazo <= ctpromoc.campodec2[3]))
                then do:
                spromoc = no.
                find first wf-movim where 
                       wf-movim.wrec = recid(produ) no-error.
                if avail wf-movim
                then do:     
                    vpreco = wf-movim.movpc.
                    run find-pro-promo.
                    if na-promocao
                    then do:
                        if ctpromoc.descontovalor > 0
                        then do:
                            wf-movim.movpc = vpreco - ctpromoc.descontovalor.

                            /* helio 09032022 - [ORQUESTRA 243179 - ESCOPO ADICIONAL] Sele��o de moeda a vista na Pr�-Venda  */ 
                            xx = promocod(ctpromoc.sequencia).
                            
                            spromoc = yes.
                        end.
                        else if ctpromoc.descontopercentual > 0
                        then do:
                            wf-movim.movpc = vpreco -
                             (vpreco * (ctpromoc.descontopercentual / 100)) .

                            /* helio 09032022 - [ORQUESTRA 243179 - ESCOPO ADICIONAL] Sele��o de moeda a vista na Pr�-Venda  */ 
                            xx = promocod(ctpromoc.sequencia).
                             
                            spromoc = yes.
                        end.
                        wf-movim.desconto =  
                            wf-movim.precoori - wf-movim.movpc.
                    end.
                end.
                if spromoc = yes
                then run cria-temp-valor(9, "PROMOCAO", 0, 0).
                end.
            end.
        end.
    end.
end procedure.
procedure preco-especial:
    def var vprsugerido as dec.
    for each ctpromoc use-index indx2
            where  (if vdata-teste-promo <> ?
                              then ctpromoc.dtinicio >= vdata-teste-promo
                              else ctpromoc.dtinicio <= today) and
         ctpromoc.dtfim  >= today and
         ctpromoc.linha = 0
         no-lock:

        if ctpromo.promocod = 54 then next.
        if ctpromoc.tipo <> ""
        then next. 
        if scartao = "" and 
            (ctpromo.promocod = 28 or
             ctpromoc.descricao[1] matches "*CARTAO LEBES*" or
             ctpromoc.descricao[2] matches "*CARTAO LEBES*")
        THEN NEXT.   
        if ctpromoc.situacao = "L" and ctpromoc.precoliberado 
        then do:
            
            vprsugerido = ctpromoc.precosugerido.
            p-ok = no.
            run find-pro-promo.
            if na-promocao 
            then p-ok = yes.
            
            if p-ok = yes
            then do:
                find first bctpromoc where
                    bctpromoc.sequenci = ctpromoc.sequencia and
                    bctpromoc.linha > 0 and
                    bctpromoc.etbcod  > 0 no-lock no-error.
                if avail bctpromoc
                then do:
                    find first dctpromoc where
                        dctpromoc.sequenci = ctpromoc.sequencia and
                        dctpromoc.linha  > 0 and
                        dctpromoc.etbcod = setbcod no-lock no-error.
                    if not avail dctpromoc
                            or dctpromoc.situacao = "I"
                            or dctpromoc.situacao = "E"
                    then p-ok = no.
                end.  
            end.
            if p-ok = yes 
            then do:
                vprsugerido = ctpromoc.precosugerido.
            find first dctpromoc where
                       dctpromoc.sequencia = ctpromoc.sequencia and
                       dctpromoc.linha > 0 and
                       dctpromoc.procod = produ.procod and
                       dctpromoc.situacao <> "I" and
                       dctpromoc.situacao <> "E"
                       no-lock no-error.
            if avail dctpromoc
            then do:
               if dctpromoc.precosugerido > 0 
               then vprsugerido = dctpromoc.precosugerido.
               
               
               if ctpromoc.qtdvenda = 0 or
                   ctpromoc.qtdvenda = vqtd-pro  + 1
               then do:   
                    run cria-temp-valor(9, "PROMOCAO", 0, 0).
                    if (ctpromoc.sequencia = 2932 or
                        ctpromoc.sequencia = 2939) and
                       (setbcod = 100 or setbcod = 101)
                    then parametro-out = "LIBERA-PRECO=S|PRECO-ESPECIAL=" +
                         string(vprsugerido * .90) +
                         "|PROMOCAO=" + string(ctpromoc.sequencia).
                    else parametro-out = "LIBERA-PRECO=S|PRECO-ESPECIAL=" + string(vprsugerido)  +
                                             "|PROMOCAO=" + string(ctpromoc.sequencia).
               end.
               else if  
                ctpromoc.qtdvenda > 0 and
                ctpromoc.qtdvenda = vqtd-produ + 1
               then do:   
                    run cria-temp-valor(9, "PROMOCAO", 0, 0).
                    if (ctpromoc.sequencia = 2932 or
                        ctpromoc.sequencia = 2939) and
                       (setbcod = 100 or setbcod = 101)
                    then parametro-out = "LIBERA-PRECO=S|PRECO-ESPECIAL=" +
                            string(vprsugerido * .90) +
                            "|PROMOCAO=" + string(ctpromoc.sequencia).
                    else parametro-out = "LIBERA-PRECO=S|PRECO-ESPECIAL=" + string(vprsugerido)  +
                                             "|PROMOCAO=" + string(ctpromoc.sequencia).
               end.
            end.
            end.
        end.
    end.
end procedure.
procedure preco-especial1:
    def var vprsugerido as dec.
    for each ctpromoc where  (if vdata-teste-promo <> ?
                              then ctpromoc.dtinicio >= vdata-teste-promo
                              else ctpromoc.dtinicio <= today) and
         ctpromoc.dtfim  >= today and
         ctpromoc.linha = 0
         no-lock:
        if ctpromo.promocod = 54 then next.
        if ctpromoc.tipo <> ""
        then next. 
        if scartao = "" and 
            (ctpromo.promocod = 28 or
             ctpromoc.descricao[1] matches "*CARTAO LEBES*" or
             ctpromoc.descricao[2] matches "*CARTAO LEBES*")
        THEN NEXT.   

        find first dctpromoc where
                       dctpromoc.sequencia = ctpromoc.sequencia and
                       dctpromoc.linha > 0 and
                       dctpromoc.procod > 0 and
                       dctpromoc.situacao <> "I" and
                       dctpromoc.situacao <> "E" and
                       dctpromoc.precosugerido > 0
                       no-lock no-error.
 
        if ctpromoc.situacao = "L" and 
            ctpromoc.precoliberado  = no and
            (ctpromoc.precosugerido > 0 or avail dctpromoc)
        then do:
            vprsugerido = ctpromoc.precosugerido.
            p-ok = no.
            run find-pro-promo.
            if na-promocao 
            then p-ok = yes.
            if p-ok = yes
            then do:
            find first bctpromoc where
                 bctpromoc.sequenci = ctpromoc.sequencia and
                 bctpromoc.linha > 0 and
                 bctpromoc.fincod <> ? no-lock no-error.
            if avail bctpromoc
            then do:    
                p-ok = no.
                find first bctpromoc where
                           bctpromoc.sequenci = ctpromoc.sequencia and
                           bctpromoc.linha > 0 and
                           bctpromoc.fincod = p-fincod no-lock no-error.
                if avail bctpromoc and
                         bctpromoc.situacao <> "I" and
                         bctpromoc.situacao <> "E"
                then do:
                    find first ectpromoc where
                               ectpromoc.sequencia = ctpromoc.sequencia and
                               ectpromoc.etbcod > 0 no-lock no-error.
                    if not avail ectpromoc
                    then p-ok = yes.
                    else do:    
                        find first ectpromoc where
                               ectpromoc.sequencia = ctpromoc.sequencia and
                               ectpromoc.etbcod = setbcod no-lock no-error.
                        if avail ectpromoc and
                                 ectpromoc.situacao <> "I" and
                                 ectpromoc.situacao <> "E"
                        then p-ok = yes.         
                    end.
                end.
            end.            
            else do:
                p-ok = no. 
                    find first ectpromoc where
                               ectpromoc.sequencia = ctpromoc.sequencia and
                               ectpromoc.etbcod > 0 no-lock no-error.
                    if not avail ectpromoc
                    then p-ok = yes.
                    else do:    
                        find first ectpromoc where
                               ectpromoc.sequencia = ctpromoc.sequencia and
                               ectpromoc.etbcod = setbcod no-lock no-error.
                        if avail ectpromoc and
                                 ectpromoc.situacao <> "I" and
                                 ectpromoc.situacao <> "E"
                        then p-ok = yes.         
                    end.
            end.
            end.
            if p-ok = yes and
                (ctpromoc.campodec2[4] = 0 or
                 wf-movim.movqtm >= ctpromoc.campodec2[4]) and
                (ctpromoc.campodec2[5] = 0 or
                 wf-movim.movqtm <= ctpromoc.campodec2[5])
            then do:
                vprsugerido = ctpromoc.precosugerido.
          
                find first dctpromoc where
                       dctpromoc.sequencia = ctpromoc.sequencia and
                       dctpromoc.linha > 0 and
                       dctpromoc.procod = produ.procod and
                       dctpromoc.situacao <> "I" and
                       dctpromoc.situacao <> "E"
                       no-lock no-error.
                if avail dctpromoc
                then do:
                    if ctpromoc.precosugerido > 0
                    then do:
                        wf-movim.movpc = ctpromoc.precosugerido.  
                        xx = promocod(ctpromoc.sequencia).

                    end.    
                    if dctpromoc.precosugerido > 0 
                    then do:
                        wf-movim.movpc = dctpromoc.precosugerido. 
                        xx = promocod(dctpromoc.sequencia).
                    end.    
                end.
            end.
        end.
    end.
end procedure.

def temp-table tp-libera
    field promoc like ctpromoc.sequencia
    field plano  like ctpromoc.fincod
    field etbcod like ctpromoc.etbcod
    field procod like produ.procod
    field libera as log
                    .
                    
procedure p-libera-plano:
    def var p-libera as log.
    for each tp-libera: delete tp-libera. end.
    for each ctpromoc where  (if vdata-teste-promo <> ?
                              then ctpromoc.dtinicio >= vdata-teste-promo
                              else ctpromoc.dtinicio <= today) and
                              ctpromoc.dtfim  >= today and
                              ctpromoc.linha = 0 
                              no-lock:
        if not ctpromoc.liberavenda and not ctpromoc.compolog5
        then next.
        if ctpromo.promocod = 54 then next.
        if ctpromoc.tipo <> "" then next.
        if scartao = "" and (ctpromo.promocod = 28 or
                             ctpromoc.descricao[1] matches "*CARTAO LEBES*" or
                             ctpromoc.descricao[2] matches "*CARTAO LEBES*")
        THEN NEXT.
        if ctpromoc.situacao = "L" and
          (ctpromoc.liberavenda or ctpromoc.compolog5)
        then do:
            p-ok = no.
            p-libera = yes.
            find first bctpromoc where
                       bctpromoc.sequencia = ctpromoc.sequencia and
                       bctpromoc.linha > 0 and
                       bctpromoc.fincod <> ? no-lock no-error.
            if avail bctpromoc
            then do:
                for each    bctpromoc where
                            bctpromoc.sequencia = ctpromoc.sequencia and
                            bctpromoc.linha > 0 and
                            bctpromoc.fincod = p-fincod no-lock .
                    if bctpromoc.fincod <> p-fincod then next.
                    if bctpromoc.situacao <> "I" and
                       bctpromoc.situacao <> "E"
                    then do:
                        find first ectpromoc where
                                   ectpromoc.sequencia = ctpromoc.sequencia and
                                   ectpromoc.linha > 0 and
                                   ectpromoc.etbcod > 0 no-lock no-error.
                        if not avail ectpromoc
                        then do:
                            for each wf-movim:
                                find produ where recid(produ) = wf-movim.wrec
                                            no-lock no-error.
                                if not avail produ then next.
                                if produ.proipiper = 98 then next.
                                na-promocao = no.
                                run find-pro-promo.
                                if na-promocao
                                then do:
                                    find first tp-libera where
                                         tp-libera.promoc = bctpromoc.sequencia
                                     and tp-libera.procod = produ.procod
                                        no-error.
                                    if not avail tp-libera
                                    then do:
                                        create tp-libera.
                                        assign
                                        tp-libera.promoc = bctpromoc.sequencia
                                        tp-libera.plano  = bctpromoc.fincod
                                        tp-libera.procod = produ.procod
                                        tp-libera.libera = yes.
                                    end.
                                end.
                            end.
                            p-ok = yes.
                        end.
                        else do:
                            find first ectpromoc where
                                   ectpromoc.sequencia = ctpromoc.sequencia and
                                   ectpromoc.linha > 0 and
                                   ectpromoc.etbcod = setbcod no-lock no-error.
                            if avail ectpromoc
                            then do:
                                for each wf-movim:
                                    find produ where 
                                        recid(produ) = wf-movim.wrec
                                        no-lock no-error.
                                    if not avail produ then next.
                                    if produ.proipiper = 98  then next.
                                    na-promocao = no.
                                    run find-pro-promo.
                                    if na-promocao and ectpromoc.situacao <> "I"
                                    then do:
                                        find first tp-libera where
                                         tp-libera.promoc = ectpromoc.sequencia
                                         and tp-libera.procod = produ.procod
                                         no-error.
                                        if not avail tp-libera
                                        then do:
                                             create tp-libera.
                                             assign
                                             tp-libera.promoc =
                                                    ectpromoc.sequencia
                                             tp-libera.plano  = bctpromoc.fincod
                                             tp-libera.etbcod =                                                         ectpromoc.etbcod
                                             tp-libera.procod = produ.procod
                                             tp-libera.libera = yes.
                                             if ectpromoc.situacao = "E"
                                                then tp-libera.libera = no.
                                        end.
                                    end.
                                end.
                                p-ok = yes.
                            end.
                            else do:
                                /****
                                for each wf-movim:
                                    find produ where
                                        recid(produ) = wf-movim.wrec
                                        no-lock no-error.
                                    if not avail produ then next.
                                    if produ.proipiper = 98  then next.
                                    na-promocao = no.
                                    run find-pro-promo.
                                    if na-promocao
                                    then do:
                                        find first tp-libera where
                                        tp-libera.promoc = bctpromoc.sequencia
                                        and tp-libera.procod = produ.procod
                                        no-error.
                                        if not avail tp-libera
                                        then do:
                                             create tp-libera.
                                             assign
                                                tp-libera.promoc =
                                                        bctpromoc.sequencia
                                             tp-libera.plano  = bctpromoc.fincod
                                             tp-libera.procod = produ.procod
                                             tp-libera.libera = no.
                                        end.
                                    end.
                                end.
                                *****/
                                p-ok = yes.
                            end.
                        end.
                    end.
                    else do:
                        for each wf-movim:
                            find produ where recid(produ) = wf-movim.wrec
                            no-lock no-error.
                            if not avail produ then next.
                            if produ.proipiper = 98 then next.
                            na-promocao = no.
                            run find-pro-promo.
                            if na-promocao and bctpromoc.situacao <> "I"
                            then do:
                                find first tp-libera where
                                        tp-libera.promoc = bctpromoc.sequencia
                                    and tp-libera.procod = produ.procod
                                        no-error.
                                if not avail tp-libera
                                then do:
                                     create tp-libera.
                                     assign
                                        tp-libera.promoc = bctpromoc.sequencia
                                        tp-libera.plano  = bctpromoc.fincod
                                        tp-libera.procod = produ.procod
                                        tp-libera.libera = yes.
                                     if bctpromoc.situacao = "E"
                                     then tp-libera.libera = no.
                                end.
                            end.
                        end.
                        p-ok = yes.
                    end.
                end.
            end.
            else do:
                find first ectpromoc where
                           ectpromoc.sequencia = ctpromoc.sequencia and
                           ectpromoc.linha > 0 and
                            ectpromoc.etbcod > 0 no-lock no-error.
                if not avail ectpromoc
                then do:
                    for each wf-movim:
                        find produ where recid(produ) = wf-movim.wrec
                                no-lock no-error.
                        if not avail produ then next.
                        if produ.proipiper = 98  then next.
                        na-promocao = no.
                        run find-pro-promo.
                        if na-promocao
                        then do:
                            find first tp-libera where
                                       tp-libera.promoc = ctpromoc.sequencia
                                   and tp-libera.procod = produ.procod
                                       no-error.
                            if not avail tp-libera
                            then do:
                                create tp-libera.
                                assign
                                    tp-libera.promoc = ctpromoc.sequencia
                                    tp-libera.procod = produ.procod
                                    tp-libera.libera = yes.
                            end.
                        end.
                    end.
                    p-ok = yes.
                end.
                else do:
                    find first ectpromoc where
                               ectpromoc.sequencia = ctpromoc.sequencia and
                               ectpromoc.linha > 0 and
                               ectpromoc.etbcod = setbcod no-lock no-error. 
                    if avail ectpromoc
                    then do:
                        for each wf-movim:
                            find produ where recid(produ) = wf-movim.wrec
                                                   no-lock no-error.
                            if not avail produ then next.
                            if produ.proipiper = 98 then next.
                            na-promocao = no.
                            run find-pro-promo.
                            if na-promocao and ectpromoc.situacao <> "I"
                            then do:
                                find first tp-libera where
                                        tp-libera.promoc = ectpromoc.sequencia
                                    and tp-libera.procod = produ.procod
                                        no-error.
                                if not avail tp-libera
                                then do:
                                    create tp-libera.
                                    assign
                                        tp-libera.promoc = ectpromoc.sequencia
                                        tp-libera.etbcod = ectpromoc.etbcod
                                        tp-libera.procod = produ.procod
                                        tp-libera.libera = yes.
                                    if ectpromoc.situacao = "E"
                                    then tp-libera.libera = no.
                                end.
                            end.
                        end.
                        p-ok = yes.
                    end.
                    else do:
                        /*******
                        for each wf-movim:
                            find produ where recid(produ) = wf-movim.wrec
                                    no-lock no-error.
                            if not avail produ then next.
                            if produ.proipiper = 98  then next.
                            na-promocao = no.
                            run find-pro-promo.
                            if na-promocao
                            then do:
                                find first tp-libera where
                                           tp-libera.promoc = ctpromoc.sequencia
                                       and tp-libera.procod = produ.procod
                                           no-error.
                                if not avail tp-libera
                                then do:
                                    create tp-libera.
                                    assign
                                        tp-libera.promoc = ctpromoc.sequencia
                                        tp-libera.procod = produ.procod
                                        tp-libera.libera = no.
                                end.
                            end.
                        end.
                        ****/
                        p-ok = yes.
                    end.
                end.
            end.
        end.
    end.
    p-libera = no.
    def buffer btp-libera for tp-libera.
    find first tp-libera where tp-libera.promoc > 0
                no-error.
    if avail tp-libera
    then do:
        p-libera = no.
        find first ctpromoc where
                   ctpromoc.sequencia = tp-libera.promoc and
                   ctpromoc.linha = 0
                   no-lock no-error.

        find first btp-libera where btp-libera.libera = no no-error.
        if avail btp-libera
        then do:
            find first ctpromoc where ctpromoc.sequencia = btp-libera.promoc
                               no-lock no-error.
            if avail ctpromoc
            then do:
                run cria-temp-valor(9, "PROMOCAO", 0, 0).
                parametro-out = "LIBERA-PLANO=N|" + parametro-out.
            end.
            else parametro-out = "LIBERA-PLANO=N|" + parametro-out.
        end.
        else do:
            p-libera = no.
            for each wf-movim:
                find produ where recid(produ) = wf-movim.wrec
                            no-lock no-error.
                if not avail produ then next.
                if produ.proipiper = 98 /* Servico */
                then next.
                find first tp-libera where
                       tp-libera.procod = produ.procod
                       no-error.
                if not avail tp-libera
                then do:
                    p-libera = no.
                    if ctpromoc.liberavenda
                    then leave.
                end.
                else do:
                    p-libera = yes.
                    if ctpromoc.compolog5
                            then leave.
                end.
            end.
            if p-libera
            then do:
                find first btp-libera where
                       btp-libera.libera = yes no-error.
                if avail btp-libera
                then do:
                    find first ctpromoc where
                        ctpromoc.sequencia = btp-libera.promoc
                                no-lock no-error.
                    if avail ctpromoc
                    then do:
                        p-ok = yes.
                        if ctpromoc.vendaacimade > 0
                        then do:
                            venda-acima-de = no.
                            run valida-venda-acimade.
                            if not venda-acima-de
                            then p-ok = no.
                        end.
                        if p-ok
                        then do:
                            run cria-temp-valor(9, "PROMOCAO", 0, 0).
                            parametro-out = "LIBERA-PLANO=S|" + parametro-out.
                            xx = promocod(ctpromoc.sequencia). /* helio 23052023 - guardar vpromocod */
                            
                        end.
                    end.
                end.
            end.
        end.
    end.
end procedure.
            
procedure p-plano-default:
    for each ctpromoc where  (if vdata-teste-promo <> ?
                              then ctpromoc.dtinicio >= vdata-teste-promo
                              else ctpromoc.dtinicio <= today) and
         ctpromoc.dtfim  >= today and
         ctpromoc.linha = 0
         no-lock:
        if ctpromo.promocod = 54 then next.
        if ctpromoc.tipo <> ""
        then next.
        if scartao = "" and 
            (ctpromo.promocod = 28 or
             ctpromoc.descricao[1] matches "*CARTAO LEBES*" or
             ctpromoc.descricao[2] matches "*CARTAO LEBES*")
        THEN NEXT.   
        if ctpromoc.situacao = "L" and ctpromoc.defaultprevenda
        then do:
            p-ok = no.
            find first  bctpromoc where
                 bctpromoc.sequenci = ctpromoc.sequencia and
                 bctpromoc.linha > 0 and
                 bctpromoc.fincod = ? and
                 bctpromoc.setcod = vsetcod no-lock no-error.
            if avail bctpromoc
            then do:
                    find first ectpromoc where
                               ectpromoc.sequencia = ctpromoc.sequencia and
                               ectpromoc.etbcod > 0 no-lock no-error.
                    if not avail ectpromoc
                    then p-ok = yes.
                    else do:   
                        find first ectpromoc where
                               ectpromoc.sequencia = ctpromoc.sequencia and
                               ectpromoc.etbcod = setbcod no-lock no-error.
                        if avail ectpromoc
                        then do:
                            if ectpromoc.situacao <> "I" and
                                ectpromoc.situacao <> "E"
                                then p-ok = yes.
                        end.    
                    end. 
                if p-ok = yes
                then do:
                    find first ectpromoc where
                         ectpromoc.sequenci = ctpromoc.sequencia and
                         ectpromoc.linha > 0 and
                         ectpromoc.fincod <> ? no-lock no-error.
                    if avail ectpromoc
                    then do:
                        find finan where 
                         finan.fincod = ectpromoc.fincod no-lock no-error.
                        if avail finan
                        then parametro-out = parametro-out +
                            "PLANO-DEFAULT=" + string(finan.fincod) + "|" +
                            "MENSAGEM=" + ctpromoc.fraseprevenda + "|".
                    end.
                end.        
            end.
        end.
    end.
end procedure.
procedure p-casadinha:
    def var lbrinde as log init no.
    def var lcasada as log init no.
    def var pr-brinde as log init no.
    def var q-casado as dec.
    val-tot-promo = 0.
    for each ctpromoc    where   (if vdata-teste-promo <> ?
                              then ctpromoc.dtinicio >= vdata-teste-promo
                              else ctpromoc.dtinicio <= today) and
            ctpromoc.dtfim  >= today and
            ctpromoc.linha = 0 
            no-lock by ctpromoc.descontopercentual:
        if ctpromoc.situacao <> "L"
        then next.
        if ctpromo.promocod = 54 then next.
        if ctpromoc.tipo <> ""
        then next.
        if scartao = "" and 
            (ctpromo.promocod = 28 or
             ctpromoc.descricao[1] matches "*CARTAO LEBES*" or
             ctpromoc.descricao[2] matches "*CARTAO LEBES*")
        THEN NEXT.   
        spromoc = no.
        if ctpromoc.situacao = "L" 
        then do:
            /***** BRINDE *****/
            assign
                pr-brinde = no
                lbrinde = no
                qbrinde = 0
                qpago = 0
                qprodu = 0
                vbrinde = 0
                vprodu = 0
                vok = no.
            find first dctpromoc where 
                        dctpromoc.sequencia = ctpromoc.sequencia and
                        dctpromoc.probrinde > 0
                        no-lock no-error.
            if avail dctpromoc 
            then do:
                lbrinde = yes.
                if ctpromoc.sequencia = 11271 or
                   ctpromoc.sequencia = 11470 or
                   ctpromoc.sequencia = 12005 or
                   ctpromoc.sequencia = 12551 or
                   ctpromoc.sequencia = 12552 or
                   ctpromoc.sequencia = 116475 
                then do:
                    run promo-compra1brinde1.
                end.
                else do:    
                if ctpromoc.sequencia = 10987 or
                   ctpromoc.sequencia = 11036 or
                   ctpromoc.sequencia = 11034 or
                   ctpromoc.sequencia = 11821 or
                   ctpromoc.sequencia = 11822 or
                   ctpromoc.sequencia = 12419 or
                   ctpromoc.sequencia = 13857 or
                   ctpromoc.sequencia = 15354 
                then do:
                    run brinde-slqtd.
                end.
                else if ctpromoc.qtdvenda > 0 and ctpromoc.qtdbrinde > 0
                    and ctpromoc.vendaacimade = 0
                    and valt-movpc
                then do:
                    if ctpromoc.qtdvenda = 1 
                    then run promo-compra1brinde1.
                    else run promo-compraXbrindeY.
                end.
                else if ctpromoc.qtdvenda > 0 and ctpromoc.qtdbrinde > 0
                    and ctpromoc.vendaacimade > 0
                    and valt-movpc
                then do:
                    run brinde-slqtd.
                end.
                else do:
                for each wf-movim :
                    find produ where recid(produ) = wf-movim.wrec
                           no-lock no-error.
                    if not avail produ then next.
                    if produ.proipiper = 98 /* Servico */
                    then next.
                    find first bctpromoc where
                         bctpromoc.sequenci = ctpromoc.sequencia and
                         bctpromoc.probrinde = produ.procod 
                         no-lock no-error.
                    if avail bctpromoc
                    then do:
                        do vi = 1 to ctpromoc.qtdbrinde:
                            if vbrinde[vi] = 0
                            then do:
                                vbrinde[vi] = produ.procod.
                                leave.
                            end.
                        end.
                        run find-pro-promo.
                        if na-promocao = no
                        then qbrinde = qbrinde + wf-movim.movqtm.
                        else qbrinde = qbrinde + wf-movim.movqtm.
                    end.     
                end.
                if qbrinde > 0 and
                   qbrinde = ctpromoc.qtdbrinde
                then do:
                    for each wf-movim :
                        find produ where recid(produ) = wf-movim.wrec
                           no-lock no-error.
                        if not avail produ then next.
                        if produ.proipiper = 98 /* Servico */
                        then next.
                        find first bctpromoc where
                         bctpromoc.sequenci = ctpromoc.sequencia and
                         bctpromoc.probrinde = produ.procod 
                         no-lock no-error.
                        if avail bctpromoc and
                           wf-movim.movqtm >= 1
                        then next.
                        run find-pro-promo.
                        if na-promocao = no 
                        then next.
                        if wf-movim.movpc > qbrinde  or
                           wf-movim.movpc = 1 
                        then 
                        do vi = 1 to ctpromoc.qtdvenda:
                            if vprodu[vi] = 0
                            then do:
                                vprodu[vi] = produ.procod.
                                leave.
                            end.
                        end.
                        qprodu = qprodu + wf-movim.movqtm.
                        if avail bctpromoc
                        then qprodu = qprodu - wf-movim.movqtm.    
                    end.    
                end.
                end.
                vok = no. 
                if (qbrinde > 0 and
                     qbrinde = ctpromoc.qtdbrinde) or
                    (qprodu > 0 and 
                     qprodu  >= ctpromoc.qtdvenda)
                then do:
                    find first ectpromoc where
                               ectpromoc.sequencia = ctpromoc.sequencia and
                               ectpromoc.etbcod > 0 no-lock no-error.
                    if not avail ectpromoc or
                        ectpromoc.situacao = "I" or
                        ectpromoc.situacao = "E"
                    then do:
                        find first ectpromoc where
                               ectpromoc.sequencia = ctpromoc.sequencia and
                               ectpromoc.fincod <> ? no-lock no-error.
                        if not avail ectpromoc
                        then vok = yes.
                        else do:
                            run valida-promo-plano.
                            vok = vok-promo-plano. 
                        end.
                    end.
                    else do:   
                        find first ectpromoc where
                               ectpromoc.sequencia = ctpromoc.sequencia and
                               ectpromoc.etbcod = setbcod no-lock no-error.
                        if avail ectpromoc  and
                            ectpromoc.situacao <> "I" and
                            ectpromoc.situacao <> "E"
                        then do:
                            find first ectpromoc where
                               ectpromoc.sequencia = ctpromoc.sequencia and
                               ectpromoc.fincod <> ? no-lock no-error.
                            if not avail ectpromoc
                            then vok = yes.
                            else do:
                                run valida-promo-plano.
                                vok = vok-promo-plano.
                            end.    
                        end.
                    end.  
                end.
                if vok = yes
                then do:
                    spromoc = no.
                    run calcula-total-venda.
                    if ctpromoc.vendaacimade > 0  and
                        total-venda > 0
                    then do:
                        if ctpromoc.campolog3 = no
                        then do:
                            do:
                                parce-total = 0.
                                parcela-fixada = 0.
                                prazo-total = 0.
                                for each wf-movim no-lock:
                                    find first produ where 
                                        recid(produ) = wf-movim.wrec no-lock
                                        no-error.
                                    if not avail produ then next.
                                    if produ.proipiper = 98 /* Servico */
                                    then next.
                                    vi = 0.
                                    do vi = 1 to qbrinde:
                                       if vbrinde[vi] = produ.procod
                                       then do:
                                            vi = 99.
                                            leave.
                                       end.     
                                    end.   
                                    if vi = 99 then next.      
                                    
                                    run find-pro-promo.
                                    if not na-promocao
                                    then  next.
                                    total-venda = 
                                        wf-movim.movpc * wf-movim.movqtm.
                                    parcela-fixada = 0.
                                    run pro-parcela-fixada.
                                    
                                    run valor-prazo.
                                    prazo-total = prazo-total + 
                                        total-venda-prazo.
                                end.
                                if prazo-total > 0
                                then total-venda-prazo = prazo-total.
                            end.
                            if total-venda-prazo = 0
                            then total-venda-prazo = total-venda.    
                        end.
                        else total-venda-prazo = total-venda.
                    end.
                    if qbrinde > 0 and
                       qbrinde = ctpromoc.qtdbrinde and
                       qprodu >= ctpromoc.qtdvenda 
                    then do:
                        if ctpromoc.vendaacimade = 0 or
                           (total-venda-prazo >= ctpromoc.vendaacimade and
                            (ctpromoc.campodec2[3] = 0 or
                            total-venda-prazo <= ctpromoc.campodec2[3]))
                        then do: 
                        vbr-ok = no.
                        do vi = 1 to qbrinde:
                            if vbrinde[vi] = 0
                            then leave.
                            find produ where 
                                 produ.procod = vbrinde[vi] no-lock no-error.
                            if not avail produ then next.     
                            find first wf-movim where 
                                       wf-movim.wrec = recid(produ) no-error.
                            if avail wf-movim
                            then do:
                                vbr-ok = no.
                                if valt-movpc = yes 
                                then do:
                                    run find-pro-promo.
                                    
                                    if na-promocao = no or
                                       wf-movim.movqtm = 1
                                    then wf-movim.movpc = 1.
                                    else if wf-movim.movqtm > 1 and
                                           wf-movim.movqtm = ctpromoc.qtdbrinde 
                                    then wf-movim.movpc = 1.
                                    else do:
                                        if wf-movim.movqtm > ctpromoc.qtdbrinde
                                        then do:
                                            wf-movim.movpc =
                                           ((wf-movim.movpc * wf-movim.movqtm)
                                       - (wf-movim.movpc * ctpromoc.qtdbrinde))
                                         / wf-movim.movqtm.
                                            v-menos1 = no.

                                    /* helio 09032022 - [ORQUESTRA 243179 - ESCOPO ADICIONAL] Sele��o de moeda a vista na Pr�-Venda  */ 
                                    xx = promocod(ctpromoc.sequencia).
                                            
                                        end.
                                        else 
                                        wf-movim.movpc =
                                        ((wf-movim.movpc * wf-movim.movqtm) -
                                        (wf-movim.movpc * 
                                        (int(substr(string((wf-movim.movqtm /
                                     (ctpromoc.qtdbrinde + ctpromoc.qtdvenda)),
                                      ">>>>9.99"),1,5))))) / wf-movim.movqtm  .
                            /* helio 09032022 - [ORQUESTRA 243179 - ESCOPO ADICIONAL] Sele��o de moeda a vista na Pr�-Venda  */ 
                            xx = promocod(ctpromoc.sequencia).
                                            
                                      
                                    end.    
                                    vbr-ok = yes.
                                    spromoc = yes.
                                end.
                            end. 
                        end.
                    end.
                        if vprodu[1] = 0 and
                           ctpromoc.vendaacimade > 0 and
                           total-venda-prazo >= ctpromoc.vendaacimade and
                           (ctpromoc.campodec2[3] = 0 or
                           total-venda-prazo <= ctpromoc.campodec2[3])
                        then do:
                            for each wf-movim:
                                find produ where 
                                    recid(produ) = wf-movim.wrec 
                                    no-lock no-error.
                                if not avail produ then next.    
                                if produ.proipiper = 98 /* Servico */
                                then next.
                                pr-brinde = no.
                                do vi = 1 to qbrinde:
                                    if vbrinde[vi] = produ.procod
                                    then pr-brinde = yes.
                                end.    
                                run find-pro-promo.
                                if  na-promocao and
                                    pr-brinde = no and
                                   wf-movim.movpc > qbrinde
                                then do:
                                    if valt-movpc = yes and
                                       v-menos1 = yes
                                    then do:
                                        wf-movim.movpc =  wf-movim.movpc - 
                                        (qbrinde / wf-movim.movqtm).
                                        spromoc = yes.                
                            /* helio 09032022 - [ORQUESTRA 243179 - ESCOPO ADICIONAL] Sele��o de moeda a vista na Pr�-Venda  */ 
                            xx = promocod(ctpromoc.sequencia).
                
                                        
                                    end.
                                    leave.
                                end.
                            end.
                        end.
                    end.
                    if qprodu > 0 and
                       qprodu >= ctpromoc.qtdvenda
                    then    
                    if vprodu[1] > 0
                    then do:
                        if ctpromoc.vendaacimade = 0 or
                           (total-venda-prazo >= ctpromoc.vendaacimade and
                            (ctpromoc.campodec2[3] = 0 or
                            total-venda-prazo <= ctpromoc.campodec2[3]))
                        then do va = 1 to qprodu:
                            find produ where produ.procod = vprodu[va] 
                            no-lock no-error.
                            if not avail produ then next.
                            find first wf-movim where 
                                  wf-movim.wrec = recid(produ) no-error.
                            if avail wf-movim
                            then do:
                                pr-brinde = no.
                                do vi = 1 to qbrinde:
                                    if vbrinde[vi] = produ.procod
                                    then assign
                                        pr-brinde = yes
                                        qbrinde = qbrinde - 1.
                                end.
                                if pr-brinde then next.
                                if valt-movpc = yes  and
                                    v-menos1 = yes
                                then do:
                                    wf-movim.movpc = wf-movim.movpc - 
                                        (qbrinde / wf-movim.movqtm).
                            /* helio 09032022 - [ORQUESTRA 243179 - ESCOPO ADICIONAL] Sele��o de moeda a vista na Pr�-Venda  */ 
                            xx = promocod(ctpromoc.sequencia).
                                    
                                    spromoc = yes.
                                    /*
                                    leave. 20/03/2023
                                        https://trello.com/c/mkoY1f4K
                                    */
                                end.
                            end.
                        end.          
                    end.
                end. 
                end.
                if spromoc = yes
                then run cria-temp-valor(9, "PROMOCAO", 0, 0).
            end.
            /*** VENDA CASADA ****/
            lcasada = no.
            find first dctpromoc where 
                        dctpromoc.sequencia = ctpromoc.sequencia and
                        dctpromoc.produtovendacasada > 0
                        no-lock no-error.
            if avail dctpromoc  
                    /*and (vbr-ok = no or ctpromoc.promocod = 49)*/ 
            then do:
                
                if  valt-movpc and
                   ( ctpromoc.sequencia = 11097 
                   or ctpromoc.sequencia = 11303
                   or ctpromoc.sequencia = 11305
                   or ctpromoc.sequencia = 11304
                   or ctpromoc.sequencia = 11478
                   or ctpromoc.sequencia = 11488
                   or ctpromoc.sequencia = 11670
                   or ctpromoc.sequencia = 12551
                   or ctpromoc.sequencia = 12143  
                   or ctpromoc.sequencia = 12252  
                   or ctpromoc.sequencia = 12239
                   or ctpromoc.sequencia = 12874 
                   or ctpromoc.sequencia = 12952
                   or ctpromoc.sequencia = 13264
                   or ctpromoc.sequencia = 13277
                   or ctpromoc.sequencia = 13651
                   or ctpromoc.sequencia = 13764
                   or ctpromoc.sequencia = 13765   
                   or ctpromoc.sequencia = 13767
                   or ctpromoc.sequencia = 13768              
                   or ctpromoc.sequencia = 14081
                   or ctpromoc.sequencia = 14134
                   or ctpromoc.sequencia = 14061
                   or ctpromoc.sequencia = 14062
                   or ctpromoc.sequencia = 14267  
                   or ctpromoc.sequencia = 14265        
                   or ctpromoc.sequencia = 14283 
                   or ctpromoc.sequencia = 14284                            
                   or ctpromoc.sequencia = 14527
                   or ctpromoc.sequencia = 14528  
                   or ctpromoc.sequencia = 14797
                   or ctpromoc.sequencia = 14759  
                   or ctpromoc.sequencia = 14988
                   or ctpromoc.sequencia = 14989 
                   or ctpromoc.sequencia = 15333
                   or ctpromoc.sequencia = 15334
                   or ctpromoc.sequencia = 15420
                   or ctpromoc.sequencia = 15415
                   or ctpromoc.sequencia = 15286
                   or ctpromoc.sequencia = 15264
                   or ctpromoc.sequencia = 116475  
                    )
                   then do:     
                    lcasada = yes.
                    run promo-compra1casa1.
                end.
                else if valt-movpc and (
                    ctpromoc.sequencia = 11781 or
                    ctpromoc.sequencia = 11940 or
                    ctpromoc.sequencia = 214044 or
                    ctpromoc.sequencia = 11751 or
                    ctpromoc.sequencia = 12301 or
                    ctpromoc.sequencia = 116475 
                    )
                then do:
                    lcasada = yes.
                    run promo-compra2casada1.
                end.
                else if valt-movpc and
                        (ctpromoc.sequencia = 12519 or
                        ctpromoc.sequencia = 12555 or
                        ctpromoc.sequencia = 12952 or
                        ctpromoc.sequencia = 13767 or
                        ctpromoc.sequencia = 13768 or
                        ctpromoc.sequencia = 14044 or
                        ctpromoc.sequencia = 14283 or
                        ctpromoc.sequencia = 14284 or
                        ctpromoc.sequencia = 15940 or
                        ctpromoc.sequencia = 161475 or
                        ctpromoc.sequencia = 21801 
                        )
                then do:
                    lcasada = yes.
                    run promo-compraXcasaY.
                end.
                else if valt-movpc and
                        ctpromoc.qtdbrinde = 1 and
                        ctpromoc.qtdvenda  = 1 and
                        dctpromoc.valorprodutovendacasada > 0 and
                        (acha("PERCENTUAL",dctpromoc.tipo) = ? or
                        acha("VALOR",dctpromoc.tipo) = ?)
                then do:
                    lcasada = yes.
                    spromoc = no.
                    run promo-compra1casa1.
                end.    
                else if valt-movpc and
                    ctpromoc.qtdbrinde >= 1 and
                    ctpromoc.qtdvenda <> 0 and
                    ctpromoc.qtdbrinde <= ctpromoc.qtdvenda and
                    ctpromoc.sequencia <> 16512 /*and
                    ctpromoc.sequencia <> 18671 */
                then do:
                    spromoc = no.
                    lcasada = yes.
                    run promo-compraXcasaY.
                end.
                else do:
                if (ctpromoc.sequencia >= 625 and
                    ctpromoc.sequencia <= 646) or
                   (ctpromoc.sequencia >= 650 and
                    ctpromoc.sequencia <= 653) or
                    ctpromoc.sequencia = 734 or
                    ctpromoc.sequencia = 736 or
                    ctpromoc.sequencia = 770 or
                   (ctpromoc.sequencia >= 1915 and
                    ctpromoc.sequencia <= 1919) or
                   (ctpromoc.sequencia >= 1924 and 
                    ctpromoc.sequencia <= 1927) or
                    ctpromoc.sequencia = 4605 or
                    ctpromoc.sequencia = 10383 or
                    ctpromoc.sequencia = 10382 or
                    ctpromoc.sequencia = 13767 or
                    ctpromoc.sequencia = 13768 or
                    ctpromoc.sequencia = 14081 or
                    ctpromoc.sequencia = 14134 or
                    ctpromoc.sequencia = 14061 or
                    ctpromoc.sequencia = 14062 or
                    ctpromoc.sequencia = 14267 or
                    ctpromoc.sequencia = 116475 
                then do:
                    run promo-conf-especial.
                end. 
                else do: 
                total-venda = 0.
                lcasada = yes.   
                qtd-item = 0.
                vpro-promo = 0.
                val-tot-promo = 0.
                for each wf-movim by wf-movim.movpc:
                    find produ where recid(produ) = wf-movim.wrec
                           no-lock no-error.
                    if not avail produ then next.
                    if produ.proipiper = 98 /* Servico */
                    then next.
                    na-casadinha = no.
                    find first bctpromoc where
                         bctpromoc.sequenci = ctpromoc.sequencia and
                         bctpromoc.produtovendacasada = produ.procod and
                         (bctpromoc.tipo begins "PRODUTO" or
                          bctpromoc.tipo = "")
                         no-lock no-error.
                    if not avail bctpromoc
                    then find first bctpromoc where
                         bctpromoc.sequenci = ctpromoc.sequencia and
                         bctpromoc.produtovendacasada = produ.clacod and
                         bctpromoc.tipo begins "CLASSE"
                         no-lock no-error.
                    if not avail bctpromoc
                    then do:
                        find first  b1ctpromoc where
                            b1ctpromoc.sequenci = ctpromoc.sequencia and
                            b1ctpromoc.produtovendacasada > 0 and
                            b1ctpromoc.produtovendacasada <> ?  and
                            b1ctpromoc.tipo begins "CLASSE"
                            no-lock no-error.
                        if avail b1ctpromoc
                        then do:    
                            na-casadinha = no.
                            run find-cas-promo.
                            if na-casadinha
                            then find bctpromoc where
                                    recid(bctpromoc) = recid(fctpromoc)
                                    no-lock no-error.
                        end.
                    end.
                    p-brinde = 0.
                    if  avail bctpromoc and
                        qbrinde < ctpromoc.qtdbrinde
                    then do:
                        do vi = 1 to ctpromoc.qtdbrinde:
                            if vbrinde[vi] = 0
                            then do:
                                vbrinde[vi] = produ.procod.
                                leave.
                            end.
                        end.
                        if wf-movim.movqtm > ctpromoc.qtdbrinde
                        then assign
                                qbrinde = qbrinde + 1
                                p-brinde = 1.
                        else assign
                                qbrinde = qbrinde + wf-movim.movqtm
                                p-brinde = wf-movim.movqtm.
                    end.
                    qtd-item = qtd-item + 1.
                    total-venda = total-venda +
                        (wf-movim.movpc * wf-movim.movqtm).
                    na-promocao = no.
                    run find-pro-promo.

                    if na-promocao = yes
                    then assign
                            vpro-promo = vpro-promo + wf-movim.movqtm
                            val-tot-promo = val-tot-promo +
                                (wf-movim.movpc * wf-movim.movqtm). 
                    if na-casadinha
                    then q-casado = q-casado + wf-movim.movqtm.
                end.
                if qtd-item = 1 and
                    qbrinde > ctpromoc.qtdbrinde 
                then qbrinde = ctpromoc.qtdbrinde.
                
                if qbrinde > 0 and
                   ctpromoc.qtdbrinde > 0
                then do:
                    for each wf-movim :
                        find produ where recid(produ) = wf-movim.wrec
                           no-lock no-error.
                        if not avail produ then next.
                        if produ.proipiper = 98 /* Servico */
                        then next.
                        na-promocao = no.
                        run find-pro-promo.
                        if not na-promocao
                        then next.
                        do vi = 1 to ctpromoc.qtdvenda:
                            if vbrinde[vi] = produ.procod and
                               qtd-item > 1 and
                               wf-movim.movqtm = 1
                            then leave.    
                            if vprodu[vi] = 0
                            then do:
                                vprodu[vi] = produ.procod.
                                leave.
                            end.
                        end.
                        qprodu = qprodu + wf-movim.movqtm.
                    end.    
                end.
                /*** Casadinha PNEU ***/
                if vprodu[1] = vbrinde[1]
                then qprodu = qprodu - qbrinde.
                vok = no. 
                if (qbrinde > 0 and qbrinde = ctpromoc.qtdbrinde) or 
                    (qprodu  > 0 and qprodu  >= ctpromoc.qtdvenda) 
                then do:
                    find first ectpromoc where
                               ectpromoc.sequencia = ctpromoc.sequencia and
                               ectpromoc.etbcod > 0 no-lock no-error.
                    if not avail ectpromoc or
                        ectpromoc.situacao = "I" or
                        ectpromoc.situacao = "E"
                    then do:
                        find first ectpromoc where
                               ectpromoc.sequencia = ctpromoc.sequencia and
                               ectpromoc.fincod <> ? no-lock no-error.
                        if not avail ectpromoc
                        then vok = yes.
                        else do:
                            run valida-promo-plano.
                            vok = vok-promo-plano.
                        end.
                    end.
                    else do:    
                        find first ectpromoc where
                               ectpromoc.sequencia = ctpromoc.sequencia and
                               ectpromoc.etbcod = setbcod no-lock no-error.
                        if avail ectpromoc and
                            ectpromoc.situacao <> "I" and
                            ectpromoc.situacao <> "E"
                        then do:
                            find first ectpromoc where
                               ectpromoc.sequencia = ctpromoc.sequencia and
                               ectpromoc.fincod <> ? no-lock no-error.
                            if not avail ectpromoc
                            then vok = yes.
                            else do:
                                run valida-promo-plano.
                                vok = vok-promo-plano.
                            end.    
                        end.
                    end.    
                end.
                if vok = yes
                then do:
                    if ctpromoc.sequencia = 210045 or
                         (ctpromoc.sequencia >= 210072   and
                          ctpromoc.sequencia <= 210075)  or
                         (ctpromoc.sequencia >= 210106   and
                          ctpromoc.sequencia <= 210110)  or
                          ctpromoc.sequencia = 10078    or
                         (ctpromoc.sequencia >= 10111    and
                          ctpromoc.sequencia <= 10116) or
                         (ctpromoc.sequencia >= 10129 and
                          ctpromoc.sequencia <= 10131) or
                          ctpromoc.sequencia = 10290 or
                          ctpromoc.sequencia = 10291 or
                          ctpromoc.sequencia = 10292 or
                          ctpromoc.sequencia = 15478 or
                          ctpromoc.sequencia = 116475             
                    then do:
                        if program-name(1) = "wf-pre.p" or
                           program-name(2) = "wf-pre.p" or
                           program-name(3) = "wf-pre.p" or
                           program-name(4) = "wf-pre.p"
                        then run promo-casadinha-especial.
                    end.
                    else do:
                    spromoc = no.
                    if ctpromoc.vendaacimade > 0  and
                        total-venda > 0
                    then do:
                        vbrinde-menos = no.
                        total-venda = 0.
                        run calcula-total-venda.
                        if ctpromoc.campolog3 = no
                        then do:
                            vbrinde-menos = yes.
                            run valor-prazo.
                        end.
                        else total-venda-prazo = total-venda.
                    end.
                    if qbrinde > 0 and
                       qbrinde = ctpromoc.qtdbrinde and
                       vqtd-pro > 1 and
                       vpro-promo >= ctpromoc.qtdvenda and
                       vprodu[1] > 0 
                    then do:
                    do vi = 1 to qbrinde: 
                        if vbrinde[vi] = 0
                        then leave.
                        find produ where produ.procod = vbrinde[vi] 
                        no-lock no-error.
                        if not avail produ then next.
                        find first wf-movim where 
                                  wf-movim.wrec = recid(produ) no-error.
                    
                        if avail wf-movim and
                            wf-movim.movqtm <= ctpromoc.qtdbrinde
                        then do:
                            find first pctpromoc where 
                                       pctpromoc.sequencia = ctpromoc.sequencia
                                   and pctpromoc.produtovendacasada =
                                       produ.procod 
                                   and pctpromoc.fincod <> ?
                                       no-lock no-error.
                            if not avail pctpromoc
                            then  find first pctpromoc where 
                                       pctpromoc.sequencia = ctpromoc.sequencia
                                   and pctpromoc.produtovendacasada =
                                       produ.clacod 
                                   and pctpromoc.fincod <> ?
                                       no-lock no-error.
                            if avail pctpromoc
                            then do:
                                find first pctpromoc where 
                                       pctpromoc.sequencia = ctpromoc.sequencia
                                   and pctpromoc.produtovendacasada =
                                       produ.procod 
                                   and pctpromoc.fincod = p-fincod
                                       no-lock no-error.
                                if not avail pctpromoc
                                then find first pctpromoc where 
                                       pctpromoc.sequencia = ctpromoc.sequencia
                                   and pctpromoc.produtovendacasada =
                                       produ.clacod 
                                   and pctpromoc.fincod = p-fincod
                                       no-lock no-error.
                            end.
                            else do:
                                find first pctpromoc where 
                                       pctpromoc.sequencia = ctpromoc.sequencia
                                   and pctpromoc.produtovendacasada =
                                       produ.procod 
                                       no-lock no-error.
                                if not avail pctpromoc
                                then find first pctpromoc where 
                                       pctpromoc.sequencia = ctpromoc.sequencia
                                   and pctpromoc.produtovendacasada =
                                       produ.clacod 
                                       no-lock no-error.
                            end.
                            if not avail pctpromoc
                            then do:
                                na-casadinha = no.
                                na-promocao = no.
                                run find-pro-promo.
                                do:
                                    na-casadinha = no.
                                    run find-cas-promo.
                                end.
                                if na-casadinha
                                then
                                find pctpromoc where
                                    recid(pctpromoc) = recid(fctpromoc)
                                    no-lock no-error.
                            end.
                            if avail pctpromoc 
                            then do:
                                if ctpromoc.vendaacimade = 0 or
                                  (total-venda-prazo >= ctpromoc.vendaacimade 
                                  and (ctpromoc.campodec2[3] = 0 or
                                  total-venda-prazo <= ctpromoc.campodec2[3]))
                                then do:
                                  if pctpromoc.campolog2 = no
                                  then do:
                                    if valt-movpc = yes
                                    then do:
                                      if acha("PERCENTUAL",pctpromoc.tipo) = ?
                                      then do:     
                                        if qtd-item = 1
                                        then do:
                                            if vbrinde[1] <> vprodu[1]
                                            then
                                            wf-movim.movpc = 
                                                 wf-movim.movpc -       
                                           (pctpromoc.valorprodutovendacasada
                                            / vqtd-pro).
                                            else wf-movim.movpc =
                                            ((wf-movim.movpc * 
                                            (vpro-promo - qbrinde)) +
                                             (pctpromoc.valorprodutovendacasada
                                                * qbrinde)) / vpro-promo.
                                                
                                            if avail ctpromoc
                                            then                             /* helio 09032022 - [ORQUESTRA 243179 - ESCOPO ADICIONAL] Sele��o de moeda a vista na Pr�-Venda  */ 
                                                xx = promocod(ctpromoc.sequencia).
                                                
                                        end.
                                        else do:
                                         if pctpromoc.valorprodutovendacasada
                                            > 0
                                         then do:
                                            if vprodu[1] <> vbrinde[1]
                                            then do:
                                                if wf-movim.movqtm = 1 
                                                then wf-movim.movpc = 
                                           pctpromoc.valorprodutovendacasada.
                                                else do:
                                                    wf-movim.movpc =
                                             pctpromoc.valorprodutovendacasada.
                                                end.
                                            end.
                                            else wf-movim.movpc =
                                            ((wf-movim.movpc * 
                                            (wf-movim.movqtm - qbrinde)) +
                                             (pctpromoc.valorprodutovendacasada
                                                * qbrinde)) / wf-movim.movqtm.
                                         end.
                                         else 
                                           wf-movim.movpc = 
                                             wf-movim.movpc - 1.
                                         end.   
                                      end.
                                      else do:
                                        if produ.catcod <> 31
                                        then do:
                                            run csadinha-desconto-percentual.
                                        end.
                                        else do:
                                        if qtd-item = 1
                                        then do:
                                            wf-movim.movpc = 
                                             wf-movim.movpc - 
                                             ((wf-movim.movpc *     
                                           (pctpromoc.valorprodutovendacasada /
                                            100))
                                            / vqtd-pro).
                                        end.
                                        else do:
                                            if vprodu[1] <> vbrinde[1]
                                            then wf-movim.movpc = 
                                             wf-movim.movpc - 
                                             ((wf-movim.movpc  /
                                             wf-movim.movqtm)
                                              *     
                                           (pctpromoc.valorprodutovendacasada /
                                            100)).
                                            else do:
                                             wf-movim.movpc =
                                            ((wf-movim.movpc * 
                                            (vpro-promo - qbrinde)) +
                                            ((wf-movim.movpc *  (100 - 
                                            pctpromoc.valorprodutovendacasada)
                                            / 100) / qbrinde)) / vpro-promo.
                                            end.
                                        end.
                                        end.
                                      end.
                                      spromoc = yes.
                                    end.
                                    v-menos1 = no.
                                  end.
                                  else do:
                                      find first qctpromoc where 
                                       qctpromoc.sequencia = ctpromoc.sequencia
                                            and qctpromoc.produtovendacasada =
                                            produ.procod 
                                            and qctpromoc.fincod = p-fincod
                                            no-lock no-error.
                                        if avail qctpromoc and
                                        qctpromoc.valorprodutovendacasada > 0
                                        then do:
                                            if valt-movpc = yes
                                            then do:
                                             wf-movim.movpc =
                                            qctpromoc.valorprodutovendacasada.
                                            parametro-out = parametro-out +
                                            "ARREDONDA=N|PARCELA-" +
                                            string(produ.procod) + "=" +
                                      string(pctpromoc.valorprodutovendacasada)
                                            + "|".
                                            spromoc = yes.
                                            end.
                                            v-menos1 = no.
                                        end.
                                        else do:
                                            if valt-movpc = yes
                                            then do:
                                            wf-movim.movpc = 
                                            pctpromoc.valorprodutovendacasada
                                                        / finan.finfat.
                                            spromoc = yes.
                                            end.
                                            v-menos1 = no.
                                        end.
                                    end.  
                                end.                     
                            end.
                            else do:
                                if ctpromoc.vendaacimade > 0 and
                                   ctpromoc.vendaacimade <= total-venda-prazo
                                then.
                            end.    
                        end.
                        else if avail wf-movim and
                            wf-movim.movqtm >= ctpromoc.qtdbrinde
                        then do:
                            find first pctpromoc where 
                                       pctpromoc.sequencia = ctpromoc.sequencia
                                   and pctpromoc.produtovendacasada =
                                       produ.procod 
                                   and pctpromoc.fincod <> ?
                                       no-lock no-error.
                            if not avail pctpromoc
                            then  find first pctpromoc where 
                                       pctpromoc.sequencia = ctpromoc.sequencia
                                   and pctpromoc.produtovendacasada =
                                       produ.clacod 
                                   and pctpromoc.fincod <> ?
                                       no-lock no-error.
                            if avail pctpromoc
                            then do:
                                find first pctpromoc where 
                                       pctpromoc.sequencia = ctpromoc.sequencia
                                   and pctpromoc.produtovendacasada =
                                       produ.procod 
                                   and pctpromoc.fincod = p-fincod
                                       no-lock no-error.
                                if not avail pctpromoc
                                then find first pctpromoc where 
                                       pctpromoc.sequencia = ctpromoc.sequencia
                                   and pctpromoc.produtovendacasada =
                                       produ.clacod 
                                   and pctpromoc.fincod = p-fincod
                                       no-lock no-error.
                            end.
                            else do:
                                find first pctpromoc where 
                                       pctpromoc.sequencia = ctpromoc.sequencia
                                   and pctpromoc.produtovendacasada =
                                       produ.procod 
                                       no-lock no-error.
                                if not avail pctpromoc
                                then find first pctpromoc where 
                                       pctpromoc.sequencia = ctpromoc.sequencia
                                   and pctpromoc.produtovendacasada =
                                       produ.clacod 
                                       no-lock no-error.
                            end.
                            if not avail pctpromoc
                            then do:
                                na-casadinha = no.
                                na-promocao = no.
                                run find-pro-promo.
                                do:
                                    na-casadinha = no.
                                    run find-cas-promo.
                                end.
                                if na-casadinha
                                then
                                find pctpromoc where
                                    recid(pctpromoc) = recid(fctpromoc)
                                    no-lock no-error.
                            end.
                            if avail pctpromoc 
                            then do:
                                if ctpromoc.vendaacimade = 0 or
                                  (total-venda-prazo >= ctpromoc.vendaacimade 
                                  and (ctpromoc.campodec2[3] = 0 or
                                  total-venda-prazo <= ctpromoc.campodec2[3]))
                                then do:
                                  if pctpromoc.campolog2 = no
                                  then do:
                                    if valt-movpc = yes
                                    then do:
                                      if acha("PERCENTUAL",pctpromoc.tipo) = ?
                                      then do:     
                                        if qtd-item = 1
                                        then do:
                                            if vbrinde[1] <> vprodu[1]
                                            then
                                            wf-movim.movpc = 
                                                 wf-movim.movpc -       
                                           (pctpromoc.valorprodutovendacasada
                                            / vqtd-pro).
                                            else do:
                                                wf-movim.movpc =
                                            (((wf-movim.movpc * 
                                            (vpro-promo)) +
                                             (pctpromoc.valorprodutovendacasada
                                                * qbrinde))) / wf-movim.movqtm
                                                .
                                            end.
                                        end.
                                        else do:
                                         if pctpromoc.valorprodutovendacasada
                                            > 0
                                         then do:
                                            if vprodu[1] <> vbrinde[1]
                                            then do:
                                                if wf-movim.movqtm = 1 
                                                then wf-movim.movpc = 
                                           pctpromoc.valorprodutovendacasada.
                                                else do:
                                                    wf-movim.movpc =
                                            ((wf-movim.movpc * 
                                            (wf-movim.movqtm - qbrinde)) +
                                             (pctpromoc.valorprodutovendacasada
                                                * qbrinde)) / 
                                                wf-movim.movqtm.
                                                end.
                                            end.
                                            else do:
                                                wf-movim.movpc =
                                                ((wf-movim.movpc *
                                                (wf-movim.movqtm - qbrinde)) +
                                             (pctpromoc.valorprodutovendacasada
                                                * qbrinde)) / wf-movim.movqtm.
                                            end.
                                         end.
                                         else 
                                           wf-movim.movpc = 
                                             wf-movim.movpc - 1.
                                         end.   
                                      end.
                                      else do:
                                        if produ.catcod <> 31
                                        then do:
                                            run csadinha-desconto-percentual.
                                        end.
                                        else do:
                                        if qtd-item = 1
                                        then do:
                                            wf-movim.movpc = 
                                             wf-movim.movpc - 
                                             ((wf-movim.movpc *     
                                           (pctpromoc.valorprodutovendacasada /
                                            100))
                                            / vqtd-pro).
                                        end.
                                        else do:
                                            if vprodu[1] <> vbrinde[1]
                                            then wf-movim.movpc = 
                                             wf-movim.movpc - 
                                             ((wf-movim.movpc  /
                                             wf-movim.movqtm)
                                              *     
                                           (pctpromoc.valorprodutovendacasada /
                                            100)).
                                            else do:
                                             wf-movim.movpc =
                                            ((wf-movim.movpc * 
                                            (vpro-promo - qbrinde)) +
                                            ((wf-movim.movpc *  (100 - 
                                            pctpromoc.valorprodutovendacasada)
                                            / 100) / qbrinde)) / vpro-promo.
                                            end.
                                        end.
                                        end.
                                      end.
                                      spromoc = yes.
                                    end.
                                    v-menos1 = no.
                                  end.
                                  else do:
                                      find first qctpromoc where 
                                       qctpromoc.sequencia = ctpromoc.sequencia
                                            and qctpromoc.produtovendacasada =
                                            produ.procod 
                                            and qctpromoc.fincod = p-fincod
                                            no-lock no-error.
                                        if avail qctpromoc and
                                        qctpromoc.valorprodutovendacasada > 0
                                        then do:
                                            if valt-movpc = yes
                                            then do:
                                             wf-movim.movpc =
                                            qctpromoc.valorprodutovendacasada.
                                            parametro-out = parametro-out +
                                            "ARREDONDA=N|PARCELA-" +
                                            string(produ.procod) + "=" +
                                      string(pctpromoc.valorprodutovendacasada)
                                            + "|".
                                            spromoc = yes.
                                            end.
                                            v-menos1 = no.
                                        end.
                                        else do:
                                            if valt-movpc = yes
                                            then do:
                                            wf-movim.movpc = 
                                            pctpromoc.valorprodutovendacasada
                                                        / finan.finfat.
                                            spromoc = yes.
                                            end.
                                            v-menos1 = no.
                                        end.
                                    end.  
                                end.                     
                            end.
                            else do:
                                if ctpromoc.vendaacimade > 0 and
                                   ctpromoc.vendaacimade <= total-venda-prazo
                                then.
                            end.    
                        end. 
                    end. 
                    end.
                    if qprodu > 0  and
                       qprodu >= ctpromoc.qtdvenda
                    then do:
                    do vi = 1 to qprodu:
                        if vprodu[vi] = 0 or ctpromoc.precosugerido = 0
                        then leave.
                        find produ where produ.procod = vprodu[vi] no-lock.
                        find first wf-movim where 
                                  wf-movim.wrec = recid(produ) no-error.
                        if avail wf-movim and
                            wf-movim.movqtm >= ctpromoc.qtdvenda
                        then do:
                            if valt-movpc = yes and
                                ctpromoc.precosugerido > 0
                            then do:
                                wf-movim.movpc = ctpromoc.precosugerido.
                            /* helio 09032022 - [ORQUESTRA 243179 - ESCOPO ADICIONAL] Sele��o de moeda a vista na Pr�-Venda  */ 
                            xx = promocod(ctpromoc.sequencia).
                                
                                spromoc = yes.
                            end.
                            v-menos1 = no.
                        end.          
                    end.
                    end.
                    if spromoc = yes
                    then run cria-temp-valor(9, "PROMOCAO", 0, 0).
                    end.
                end. 
                end.
                end.
            end.
            if lcasada = no and
               lbrinde = no
            then do:
                spromoc = no.
                vok = no.
                find first ectpromoc where
                               ectpromoc.sequencia = ctpromoc.sequencia and
                               ectpromoc.etbcod > 0 no-lock no-error.
                if not avail ectpromoc  
                then do:
                    find first ectpromoc where
                               ectpromoc.sequencia = ctpromoc.sequencia and
                               ectpromoc.fincod <> ?
                               no-lock no-error.
                    if not avail ectpromoc
                    then vok = yes.
                    else do:
                        run valida-promo-plano.
                        vok = vok-promo-plano.
                    end.
                end.
                else do:    
                    find first ectpromoc where
                               ectpromoc.sequencia = ctpromoc.sequencia and
                               ectpromoc.etbcod = setbcod no-lock no-error.
                    if avail ectpromoc
                        AND ectpromoc.situacao <> "I" and
                        ectpromoc.situacao <> "E"
                    then do:
                        find first ectpromoc where
                               ectpromoc.sequencia = ctpromoc.sequencia and
                               ectpromoc.fincod <> ? 
                               no-lock no-error.
                        if not avail ectpromoc
                        then vok = yes.
                        else do:
                            run valida-promo-plano.
                            vok = vok-promo-plano.
                        end.    
                    end.
                end. 
                if ctpromoc.qtdvenda > 0
                then do:
                    qprodu = 0.
                    total-vinculado = 0.
                    le-vinculado = no.
                    qtd-vinculado = 0.
                    for each wf-movim:
                        find produ where recid(produ) = wf-movim.wrec
                           no-lock no-error.
                        if not avail produ then next.
                        if produ.proipiper = 98 /* Servico */
                        then next.
                        produto-vinculado = no.
                        run prod-vinculado.
                        if produto-vinculado
                        then qtd-vinculado = qtd-vinculado + 1.
                        run find-pro-promo.
                        if not na-promocao
                        then  next.
                        run conf-vinculado.
                        if le-vinculado = no
                        then next.
                        qprodu = qprodu + wf-movim.movqtm.
                        total-vinculado = total-vinculado + 
                            (wf-movim.movqtm * wf-movim.movpc).
                         do vi = 1 to ctpromoc.qtdvenda:
                            if vprodu[vi] = 0
                            then do:
                                vprodu[vi] = produ.procod.
                                leave.
                            end.
                        end.
                    end.
                    if qtd-vinculado > 0 and
                        program-name(3) <> "gerpla.p"
                    then do:
                        vin-valor = 0.
                        vin-pct = 0.
                        if ctpromoc.descontovalor > 0
                        then do:
                            for each wf-movim:
                                find produ where recid(produ) = wf-movim.wrec
                                        no-lock no-error.
                                if not avail produ then next.
                                if produ.proipiper = 98 /* Servico */
                                then next.
                                produto-vinculado = no.
                                run prod-vinculado.
                                if produto-vinculado
                                then next.
                                run find-pro-promo.
                                if not na-promocao
                                then  next.
                                vin-valor = vin-valor + 
                                        (wf-movim.movpc * wf-movim.movqtm).
                            end.  
                            if ctpromoc.descontovalor > vin-valor
                            then vin-pct = 0.
                            else vin-pct = ctpromoc.descontovalor / vin-valor.
                        end.
                        else if ctpromoc.descontopercentual > 0
                        then do:
                            vin-pct = ctpromoc.descontopercentual.
                        end.
                        if vin-pct > 0 and
                            valt-movpc 
                        then do:
                            for each wf-movim:
                                find produ where recid(produ) = wf-movim.wrec
                                        no-lock no-error.
                                if not avail produ then next.
                                if produ.proipiper = 98 /* Servico */
                                then next.
                                produto-vinculado = no.
                                run prod-vinculado.
                                if produto-vinculado
                                then next.
                                run find-pro-promo.
                                if not na-promocao
                                then  next.
                                wf-movim.movpc = wf-movim.movpc - 
                                        (wf-movim.movpc * vin-pct).
                            end.
                        end.
                    end.
                    if qprodu < ctpromoc.qtdvenda and
                        vok = yes
                    then vok = no. 
                    if total-vinculado > 0
                    then total-venda = total-vinculado. 
                end.
                run valor-prazo.
                if vok = yes and ctpromoc.campodec[1] > 0
                   and ctpromoc.campodec[1] <= ctpromoc.qtdvenda
                   and valt-movpc 
                then do:    
                    if ctpromoc.sequencia = 6928 and
                       vbr-ok = yes
                    then.
                    else   
                    run leva-x-paga-y.
                end.
                if vok = yes and
                   ctpromoc.vendaacimade > 0  and
                   ctpromoc.vendaacimade <= total-venda-prazo
                then do: 
                    if ctpromoc.campolog1 = yes
                    then do:
                        run mensagem-na-venda.
                    end.
                end.
                if vok = yes
                then do:
                    if ctpromoc.precosugerido > 0
                    then do vi = 1 to qprodu:
                        if vprodu[vi] = 0 
                        then leave.
                        find produ where produ.procod = vprodu[vi] no-lock.
                        find first wf-movim where 
                                  wf-movim.wrec = recid(produ) no-error.
                        if avail wf-movim and
                            wf-movim.movqtm >= ctpromoc.qtdvenda
                        then do:
                            if valt-movpc = yes
                            then do:
                                wf-movim.movpc =  ctpromoc.precosugerido.
                                spromoc = yes.
                            /* helio 09032022 - [ORQUESTRA 243179 - ESCOPO ADICIONAL] Sele��o de moeda a vista na Pr�-Venda  */ 
                            xx = promocod(ctpromoc.sequencia).
                                
                            end.
                            v-menos1 = no.
                        end.          
                    end.
                    if ctpromoc.cartaovalor > 0 
                    then do:
                        if ctpromoc.campolog3 = yes
                        then total-venda-prazo = total-venda.
                        if ctpromoc.campolog4 = no and
                           total-venda-prazo  >= ctpromoc.vendaacimade and
                           total-venda-prazo  <= ctpromoc.campodec2[3]
                        then do:
                            parametro-out = "PROMOCAO=" + 
                            string(ctpromoc.sequencia) + "|" +
                            "CARTAO-PRESENTE=VAL|" +
                            "VALOR-CARTAO-PRESENTE=" + 
                            string(ctpromoc.cartaovalor) + "|" + parametro-out.
                            spromoc = yes.
                        end.
                        else if ctpromoc.campolog4 = yes
                        then do:
                            cartao-valor = 0.
                            for each wf-movim no-lock:
                                find produ where recid(produ) = wf-movim.wrec
                                        no-lock no-error.
                                if not avail produ then next.
                                if produ.proipiper = 98 /* Servico */
                                then next.
                                run find-pro-promo.
                                if not na-promocao
                                then next.
                                total-venda = wf-movim.movpc * wf-movim.movqtm.
                                if ctpromoc.campolog3 = no
                                then run valor-prazo.
                                else total-venda-prazo = total-venda.
                                if total-venda-prazo >= ctpromoc.vendaacimade 
                                    and total-venda-prazo <=                                                         ctpromoc.campodec2[3]
                                 then do:
                                    cartao-valor = cartao-valor +
                                            ctpromoc.cartaovalor.
                                end. 
                            end.
                            if cartao-valor > 0
                            then do:
                                parametro-out = "PROMOCAO=" + 
                                    string(ctpromoc.sequencia) + "|" +
                                    "CARTAO-PRESENTE=VAL|" +
                                    "VALOR-CARTAO-PRESENTE=" + 
                                        string(cartao-valor) + 
                                        "|" + parametro-out.
                               spromoc = yes.
                            end. 
                        end.
                        if ctpromoc.geradespesa = yes
                        then do:
                        parametro-out = parametro-out + "GERA-DESPESA-CP=S|"
                            + ctpromoc.campochar[2].
                        end.    
                        if ctpromoc.recibo = yes
                        then 
                        parametro-out = parametro-out + "EMITE-RECIBO-CP=S|".
                    end.
                    if ctpromoc.cartaoparcela = yes
                    then do:
                        promo-tudo = yes.
                        for each wf-movim no-lock:
                                find produ where recid(produ) = wf-movim.wrec
                                        no-lock no-error.
                                if not avail produ then next.
                                if produ.proipiper = 98 /* Servico */
                                then next.
                                run find-pro-promo. 
                                if not na-promocao
                                then do:
                                    promo-tudo = no.
                                    next.
                                end. 
                        end.
                        if (ctpromoc.campolog4 = no or
                            promo-tudo = yes) and
                           total-venda-prazo  >= ctpromoc.vendaacimade and
                           total-venda-prazo  <= ctpromoc.campodec2[3]
                        then do:
                            parametro-out = 
                                parametro-out + "CARTAO-PRESENTE=PAR|".
                            spromoc = yes.
                        end.
                        else if ctpromoc.campolog4 = yes 
                        then do:
                            cartao-valor = 0.
                            parce-total = 0.
                            parcela-fixada = 0.
                            for each wf-movim no-lock:
                                find produ where recid(produ) = wf-movim.wrec
                                        no-lock no-error.
                                if not avail produ then next.
                                if produ.proipiper = 98 /* Servico */
                                then next.
                                run find-pro-promo.
                                if not na-promocao
                                then  next.
                                total-venda = wf-movim.movpc * wf-movim.movqtm.
                                if ctpromoc.campolog3 = no
                                then do:
                                    parcela-fixada = 0.
                                    run pro-parcela-fixada.
                                    run valor-prazo.
                                end.
                                else total-venda-prazo = total-venda.
                            end.        
                            if ctpromoc.vendaacimade = 0 or
                                (total-venda-prazo >= ctpromoc.vendaacimade and
                                 total-venda-prazo <= ctpromoc.campodec2[3])
                            then do:
                                cartao-valor = parce-total.
                                parametro-out = "PROMOCAO=" + 
                                    string(ctpromoc.sequencia) + "|" +
                                    "CARTAO-PRESENTE=VAL|" +
                                    "VALOR-CARTAO-PRESENTE=" + 
                                        string(cartao-valor) + 
                                        "|" + parametro-out.
                               spromoc = yes.
                            end.     
                        end.
                        if ctpromoc.geradespesa = yes
                        then do:
                        parametro-out = parametro-out + "GERA-DESPESA-CP=S|"
                            + ctpromoc.campochar[2].
                        end.
                        if ctpromoc.recibo = yes
                        then 
                        parametro-out = parametro-out + "EMITE-RECIBO-CP=S|".
                    end. 
                    if ctpromoc.cartaopercentual > 0
                    then do:
                        promo-tudo = yes.
                        for each wf-movim no-lock:
                                find produ where recid(produ) = wf-movim.wrec
                                        no-lock no-error.
                                if not avail produ then next.
                                if produ.proipiper = 98 /* Servico */
                                then next.
                                run find-pro-promo. 
                                if not na-promocao
                                then do:
                                    promo-tudo = no.
                                    next.
                                end. 
                        end.
                        if ctpromoc.campolog3 = yes
                        then total-venda-prazo = total-venda.
                        if (ctpromoc.campolog4 = no or
                            promo-tudo = yes) and
                            (ctpromoc.vendaacimade = 0 or
                           total-venda-prazo  >= ctpromoc.vendaacimade) and
                           (ctpromoc.campodec2[3] = 0 or
                           total-venda-prazo  <= ctpromoc.campodec2[3])
                        then do:
                            cartao-valor = total-venda-prazo * 
                                (ctpromoc.cartaopercentual / 100).
                            parametro-out = "PROMOCAO=" +
                                    string(ctpromoc.sequencia) + "|" +
                                    "CARTAO-PRESENTE=VAL|" +
                                    "VALOR-CARTAO-PRESENTE=" +
                                        string(cartao-valor) +
                                    "|" + parametro-out.
                            spromoc = yes.
                        end.
                        else if ctpromoc.campolog4 = yes 
                        then do:
                            cartao-valor = 0.
                            parce-total = 0.
                            parcela-fixada = 0.
                            for each wf-movim no-lock:
                                find produ where recid(produ) = wf-movim.wrec
                                        no-lock no-error.
                                if not avail produ then next.
                                if produ.proipiper = 98 /* Servico */
                                then next.
                                run find-pro-promo.
                                if not na-promocao
                                then  next.
                                total-venda = wf-movim.movpc * wf-movim.movqtm.
                                if ctpromoc.campolog3 = no
                                then do:
                                    parcela-fixada = 0.
                                    run pro-parcela-fixada.
                                    run valor-prazo.
                                end.
                                else total-venda-prazo = total-venda.
                            end.        
                            if ctpromoc.vendaacimade = 0 or
                                (total-venda-prazo >= ctpromoc.vendaacimade and
                                 total-venda-prazo <= ctpromoc.campodec2[3])
                            then do:
                                cartao-valor = total-venda-prazo * 
                                (ctpromoc.cartaopercentual / 100).
                                parametro-out = "PROMOCAO=" +
                                    string(ctpromoc.sequencia) + "|" +
                                    "CARTAO-PRESENTE=VAL|" +
                                    "VALOR-CARTAO-PRESENTE=" +
                                        string(cartao-valor) +
                                    "|" + parametro-out.
                                spromoc = yes.
 
                            end.     
                        end.
                        if ctpromoc.geradespesa = yes
                        then do:
                        parametro-out = parametro-out + "GERA-DESPESA-CP=S|"
                            + ctpromoc.campochar[2].
                        end.
                        if ctpromoc.recibo = yes
                        then 
                        parametro-out = parametro-out + "EMITE-RECIBO-CP=S|".
                    end.
                    if (ctpromoc.descontovalor > 0  or
                       ctpromoc.descontopercentual > 0 ) and
                       ctpromoc.campolog4 = no and
                       valt-movpc = yes
                    then do: 
                        total-venda = 0.
                        total-venda-prazo=0.
                        for each wf-movim no-lock:
                            find produ where recid(produ) = wf-movim.wrec
                                        no-lock no-error.
                            if not avail produ then next.
                            if produ.proipiper = 98 /* Servico */
                            then next.
                            run find-pro-promo.
                            if not na-promocao then  next.
                            total-venda = wf-movim.movpc * wf-movim.movqtm.
                            if ctpromoc.campolog3 = no
                            then do:
                                parcela-fixada = 0.
                                run pro-parcela-fixada.
                                run valor-prazo.
                            end.
                            else total-venda-prazo = total-venda.
                        end.
                        if ctpromoc.campolog3 and
                            ctpromoc.vendaacimade = 0 or
                            (total-venda >= ctpromoc.vendaacimade and
                             total-venda <= ctpromoc.campodec2[3])
                        then do:
                            run desconto.
                        end.
                        else if not ctpromoc.campolog3 and
                              ctpromoc.vendaacimade = 0 or
                                (total-venda-prazo >= ctpromoc.vendaacimade and
                                 total-venda-prazo <= ctpromoc.campodec2[3])                             then do:

                                 
                                run desconto.
                          end.
                        if ctpromoc.geradespesa = yes
                        then parametro-out = parametro-out + "GERA-DESPESA=S|"
                            + ctpromoc.campochar[2].
                        if ctpromoc.recibo = yes
                        then parametro-out = parametro-out + "EMITE-RECIBO=S|".
                    end.
                end.
            end.
            if spromoc = yes
            then run cria-temp-valor(9, "PROMOCAO", 0, 0).  
        end.
    end.
end procedure.
procedure ver-linha-ativa:
    v-ativa = no.
    find first ectpromoc where
               ectpromoc.sequencia = ctpromoc.sequencia and
               ectpromoc.etbcod > 0 no-lock no-error.
    if not avail ectpromoc or
                 ectpromoc.situacao = "I" or
                 ectpromoc.situacao = "E"
    then do:
        find first ectpromoc where
                   ectpromoc.sequencia = ctpromoc.sequencia and
                   ectpromoc.fincod <> ? no-lock no-error.
        if not avail ectpromoc
        then v-ativa = yes.
        else do:
            run valida-promo-plano.
            v-ativa = vok-promo-plano.
        end.
    end.
    else do:    
        find first ectpromoc where
                   ectpromoc.sequencia = ctpromoc.sequencia and
                   ectpromoc.etbcod = setbcod no-lock no-error.
        if avail ectpromoc and
                 ectpromoc.situacao <> "I" and
                 ectpromoc.situacao <> "E"
        then do:
            find first ectpromoc where
                       ectpromoc.sequencia = ctpromoc.sequencia and
                       ectpromoc.fincod <> ? no-lock no-error.
            if not avail ectpromoc
            then v-ativa = yes.
            else do:
                run valida-promo-plano.
                v-ativa = vok-promo-plano.
            end.    
        end.
    end. 
end procedure.
def temp-table tt-c1c1
    field procod like produ.procod
    field movqtm like movim.movqtm
    field movpc  like movim.movpc
    field movseq like movim.movseq
    field qtdcom as dec
    field qtdcas as dec
    field valorcas as dec
    field tipocas as char
    field indcasa as log
    field indprom as log
    field sequencia like ctpromoc.sequencia
    index i1 movseq procod .
def temp-table tt-c1b1
    field procod like produ.procod
    field movqtm like movim.movqtm
    field movpc  like movim.movpc
    field movseq like movim.movseq
    field qtdcom as dec
    field qtdbri as dec
    index i1 movseq procod .

procedure promo-compra1casa1:
    def var tq-prom as dec init 0.
    def var tq-casa as dec init 0.
    def var tq-movi as dec init 0.
    def var q-prom as dec init 0.
    def var q-casa as dec init 0.
    def var q-c1 as dec init 0.
    def var q-c2 as dec init 0.
    def var v-totven as dec.
    def var vdif as dec init 0.
    
    for each tt-c1c1: delete tt-c1c1. end.
    
    if ctpromoc.qtdvenda = 1 and
       ctpromoc.qtdbrinde = 1
    then do:
        venda-acima-de = yes.
        if ctpromoc.vendaacimade > 0
        then do:
            venda-acima-de = no.
            run valida-venda-acimade.
        end.
        run ver-linha-ativa.
        if v-ativa
        then do:
            for each tt-c1c1: delete tt-c1c1. end.
            tq-movi = 0.
            for each wf-movim by wf-movim.movpc :
                find produ where recid(produ) = wf-movim.wrec no-lock no-error.
                if not avail produ then next.
                if produ.proipiper = 98 /* Servico */
                then next.
                na-promocao = no.
                run find-pro-promo.
                na-casadinha = no.
                valor-produto-venda-casada = 0.
                tipo-valor-venda-casada = "".
                run find-cas-promo.
                if venda-acima-de = no then na-casadinha = no.
                if na-promocao = no and
                   na-casadinha = no
                then next.
                find first tt-c1c1 where
                           tt-c1c1.procod = produ.procod
                           no-error.
                if not avail tt-c1c1
                then do:
                    create tt-c1c1.
                    assign
                        tt-c1c1.procod = produ.procod
                        tt-c1c1.movpc  = wf-movim.movpc
                        tt-c1c1.movqtm = wf-movim.movqtm .
                end.           
                assign
                    tt-c1c1.valorcas = valor-produto-venda-casada
                    tt-c1c1.tipocas  = tipo-valor-venda-casada 
                    tq-movi = tq-movi + wf-movim.movqtm.
          
                if na-promocao or na-casadinha
                then do:   
                    if na-promocao and not na-casadinha
                    then do:
                        assign
                            tt-c1c1.qtdcom = wf-movim.movqtm
                            tq-prom = tq-prom + wf-movim.movqtm .
                    end.        
                    else if not na-promocao and na-casadinha
                        then do:
                            assign
                                tt-c1c1.qtdcas = wf-movim.movqtm
                                tq-casa = tq-casa + wf-movim.movqtm .
                        end.
                        else if na-promocao and na-casadinha
                            then do:
                                if ctpromoc.vendaacimade > 0
                                then do:
                                    if (tq-casa + wf-movim.movqtm) <=
                                               ctpromoc.qtdbrinde
                                    then do:
                                        assign
                                           tt-c1c1.qtdcas = ctpromoc.qtdbrinde
                                           tt-c1c1.qtdcom = wf-movim.movqtm -
                                                    ctpromoc.qtdbrinde.
                                           if tt-c1c1.qtdcom < 0
                                           then tt-c1c1.qtdcom = 0.
                                        tq-prom = tq-prom + tt-c1c1.qtdcom.
                                        tq-casa = tq-casa + tt-c1c1.qtdcas.
                                        
                                    end.
                                    else do:
                                        vdif = (tq-casa + wf-movim.movqtm) -
                                                    ctpromoc.qtdbrinde.
                                        tt-c1c1.qtdcas = wf-movim.movqtm - vdif.
                                        tt-c1c1.qtdcom = vdif.
                                        if tt-c1c1.qtdcom < 0
                                        then tt-c1c1.qtdcom = 0.
                                        tq-prom = tq-prom + tt-c1c1.qtdcom.
                                        tq-casa = tq-casa + tt-c1c1.qtdcas.
                                    end.
                                end.
                                else do:
                                    /*if tq-casa < ctpromoc.qtdbrinde
                                    then*/ do:
                                        if wf-movim.movqtm <= ctpromoc.qtdbrinde
                                        then
                                        assign
                                            tt-c1c1.qtdcas = wf-movim.movqtm
                                            tt-c1c1.qtdcom = 0
                                            tq-casa = tq-casa + wf-movim.movqtm
                                            tq-prom = tq-prom + wf-movim.movqtm
                                            tt-c1c1.indcas = yes
                                            .
                                        else do:
                                        assign
                                           tt-c1c1.qtdcas =
                                           truncate(dec(wf-movim.movqtm / 2),0)
                                            tt-c1c1.qtdcom = wf-movim.movqtm -
                                           truncate(dec(wf-movim.movqtm / 2),0)
                                            tq-casa = tq-casa + tt-c1c1.qtdcas
                                            tq-prom = tq-prom + wf-movim.movqtm
                                            tt-c1c1.indcas = yes
                                            tt-c1c1.indprom = yes
                                            .
                                        end.
                                    end.
                                    /*
                                    else         
                                    assign
                                    tt-c1c1.qtdcom = wf-movim.movqtm
                                    tq-prom = tq-prom + wf-movim.movqtm
                                    tq-casa = tq-casa + wf-movim.movqtm .
                                    */
                                end.
                            end.        
                end.
            end.
            if tq-movi > 1
            then do:
            
            if tq-casa >= tq-prom
            then do:
                assign
                    tq-prom = int(tq-movi / 2)
                    tq-casa = tq-movi - tq-prom.
            end.
            
            def var ind-cas as int.
            def var ind-com as int.
            def var mov-qtm as int.
            ind-cas = 0.
            ind-com = 0.
            mov-qtm = 0.

            for each tt-c1c1:
                mov-qtm = mov-qtm + tt-c1c1.movqtm.
            end. 
            for each tt-c1c1 where tt-c1c1.indcas:
                ind-cas = ind-cas + tt-c1c1.qtdcas.
            end.
            for each tt-c1c1 where tt-c1c1.indprom:
                ind-com = ind-com + tt-c1c1.qtdcom.
            end.
            
            /**************
            if ind-cas > ind-com
            then do:
                assign
                        ind-com = int(ind-cas / 2) 
                        ind-cas = ind-cas - ind-com.
            
                
                for each tt-c1c1 where tt-c1c1.indcas by tt-c1c1.movpc:
                    
                    if ind-cas <= 0 and tt-c1c1.qtdcas > 0
                    then assign
                             tt-c1c1.qtdcom = tt-c1c1.qtdcom + tt-c1c1.qtdcas
                             tt-c1c1.qtdcas = 0.
                             
                    ind-cas = ind-cas - tt-c1c1.qtdcas.
                    
                end.
            end.
            *************/

            if ind-cas > ind-com
            then do:
                assign
                        ind-com = int(ind-cas / 2) 
                        ind-cas = ind-cas - ind-com.
                
                if ind-com > ind-cas and ind-com + ind-cas < mov-qtm
                then ind-cas = ind-com.
                
                for each tt-c1c1 where tt-c1c1.indcas by tt-c1c1.movpc
                                        :
                    if ind-cas <= 0 and tt-c1c1.qtdcas > 0
                    then assign
                             tt-c1c1.qtdcom = tt-c1c1.qtdcom + tt-c1c1.qtdcas
                             tt-c1c1.qtdcas = 0.
                             
                    if tt-c1c1.movqtm >= ind-cas
                    then assign
                            tt-c1c1.qtdcas = ind-cas
                            tt-c1c1.qtdcom = tt-c1c1.movqtm - ind-cas
                            .

                    ind-cas = ind-cas - tt-c1c1.qtdcas.
                end.
            end.
            else if ind-cas > 0 and ind-com > 0
            then do:
                if ind-cas = ind-com
                then
                for each tt-c1c1 where tt-c1c1.indcas by tt-c1c1.movpc
                                        :
                    if ind-cas <= 0 and tt-c1c1.qtdcas > 0
                    then assign
                             tt-c1c1.qtdcom = tt-c1c1.qtdcom + tt-c1c1.qtdcas
                             tt-c1c1.qtdcas = 0.
                             
                    if tt-c1c1.movqtm >= ind-cas
                    then assign
                            tt-c1c1.qtdcas = ind-cas
                            tt-c1c1.qtdcom = tt-c1c1.movqtm - ind-cas
                            .
                    else assign
                             tt-c1c1.qtdcas = tt-c1c1.movqtm
                             tt-c1c1.qtdcom = 0
                             .
                             
                    ind-cas = ind-cas - tt-c1c1.qtdcas.
                end.
            end.

            for each tt-c1c1:
                if tt-c1c1.qtdcom = 0 and
                   tt-c1c1.qtdcas > 0
                then tq-casa = tq-casa - tt-c1c1.qtdcas.
            end.
             
            def var t-co as dec.
            def var t-ca as dec.
            def var t-qt as dec.
            assign
                t-qt = 0
                t-co = 0
                t-ca = 0
                q-c1 = 0 
                q-c2 = 0.
            for each tt-c1c1:
                assign
                    q-c1 = q-c1 + tt-c1c1.qtdcom 
                    q-c2 = q-c2 + tt-c1c1.qtdcas .
            end.
            
            if ctpromoc.vendaacimade > 0
            then do:
                total-venda = 0.
                if q-c1 > 0 and q-c2 > 0
                then
                for each wf-movim by wf-movim.movpc /*descending*/:
                find produ where recid(produ) = wf-movim.wrec no-lock no-error.
                if not avail produ then next.
                if produ.proipiper = 98 /* Servico */
                then next.
                v-totven = 0.
                find first tt-c1c1 where
                           tt-c1c1.procod = produ.procod and
                           (tt-c1c1.qtdcom > 0 or
                            tt-c1c1.qtdcas > 0) no-error.
                if avail tt-c1c1
                then do:
                    if acha("PERCENTUAL",tt-c1c1.tipocas) = ?
                    then v-totven = (wf-movim.movpc * tt-c1c1.qtdcom) +
                        (tt-c1c1.valorcas * tt-c1c1.qtdcas).
                    else v-totven = (wf-movim.movpc * tt-c1c1.qtdcom) +
                        ((wf-movim.movpc -
                        ((wf-movim.movpc * (tt-c1c1.valorcas / 100))))
                             * tt-c1c1.qtdcas). 

                    if v-totven / wf-movim.movqtm > wf-movim.movpc
                    then.
                    else total-venda = total-venda + v-totven.
                    /*
                                (v-totven / wf-movim.movqtm). */
                end.
                end.
                venda-acima-de = no.
                run valida-venda-acimade-casadinha.
            end.

            if q-c1 > 0 and q-c2 > 0 and venda-acima-de
            then
            for each wf-movim by wf-movim.movpc /*descending*/:
                find produ where recid(produ) = wf-movim.wrec no-lock no-error.
                if not avail produ then next.
                if produ.proipiper = 98 /* Servico */
                then next.
                v-totven = 0.
                find first tt-c1c1 where
                           tt-c1c1.procod = produ.procod and
                           (tt-c1c1.qtdcom > 0 or
                            tt-c1c1.qtdcas > 0) no-error.
                if avail tt-c1c1
                then do:
                    if acha("PERCENTUAL",tt-c1c1.tipocas) = ?
                    then v-totven = (wf-movim.movpc * tt-c1c1.qtdcom) +
                        (tt-c1c1.valorcas * tt-c1c1.qtdcas).
                    else v-totven = (wf-movim.movpc * tt-c1c1.qtdcom) +
                        ((wf-movim.movpc -
                        ((wf-movim.movpc * (tt-c1c1.valorcas / 100))))
                             * tt-c1c1.qtdcas). 

                    if v-totven / wf-movim.movqtm > wf-movim.movpc
                    then.
                    else wf-movim.movpc = v-totven / wf-movim.movqtm.

                    if avail ctpromoc
                    then 
                                                /* helio 09032022 - [ORQUESTRA 243179 - ESCOPO ADICIONAL] Sele��o de moeda a vista na Pr�-Venda  */ 
                            xx = promocod(ctpromoc.sequencia).
                    
                    spromoc = yes.
                end.
            end.
            end. 
        end.
    
        for each tt-c1c1: delete tt-c1c1. end.
    
    end.
end procedure.
procedure promo-compra2casada1:
    def var v-casa as dec init 0.
    def var tq-prom as dec init 0.
    def var tq-casa as dec init 0.
    def var tq-movi as dec init 0.
    def var q-prom as dec init 0.
    def var q-casa as dec init 0.
    def var q-c1 as dec init 0.
    def var q-c2 as dec init 0.
    def var v-totven as dec.
    def var lp as dec.
    for each tt-c1c1: delete tt-c1c1. end.
    do:
        run ver-linha-ativa.
        if v-ativa
        then do:
            tq-movi = 0.
            for each wf-movim by wf-movim.movpc descending:
                find produ where recid(produ) = wf-movim.wrec no-lock no-error.
                if not avail produ then next.
                if produ.proipiper = 98 /* Servico */
                then next.
                na-promocao = no.
                run find-pro-promo.
                na-casadinha = no.
                valor-produto-venda-casada = 0.
                tipo-valor-venda-casada = "".
                run find-cas-promo.
                if na-promocao = no and
                   na-casadinha = no
                then next.  
                find first tt-c1c1 where
                           tt-c1c1.procod = produ.procod
                           no-error.
                if not avail tt-c1c1
                then do:
                    create tt-c1c1.
                    assign
                        tt-c1c1.procod = produ.procod
                        tt-c1c1.movpc  = wf-movim.movpc
                        tt-c1c1.movqtm = wf-movim.movqtm .
                end.           
                assign
                    tt-c1c1.valorcas = valor-produto-venda-casada
                    tt-c1c1.tipocas  = tipo-valor-venda-casada .
                tq-movi = tq-movi + wf-movim.movqtm.
                if na-promocao or na-casadinha
                then do:   
                    if na-promocao and not na-casadinha
                    then assign
                            tt-c1c1.qtdcom = wf-movim.movqtm
                            tq-prom = tq-prom + wf-movim.movqtm .
                    else if not na-promocao and na-casadinha
                        then assign
                                tt-c1c1.qtdcas = wf-movim.movqtm
                                tq-casa = tq-casa + wf-movim.movqtm .
                        else if na-promocao and na-casadinha
                            then do:
                                if wf-movim.movqtm >= ctpromoc.qtdvenda + 
                                                      ctpromoc.qtdbrinde
                                then do:                      
                                    v-casa = truncate((wf-movim.movqtm /
                                  (ctpromoc.qtdvenda + ctpromoc.qtdbrinde)),0).
                                    assign
                                    tt-c1c1.qtdcom = wf-movim.movqtm - v-casa
                                    tt-c1c1.qtdcas = v-casa
                                    tq-prom = tq-prom + 
                                    (wf-movim.movqtm - v-casa)
                                    tq-casa = tq-casa + v-casa
                                    v-casa = 0 .
                                end.
                                else do:
                                    if lp = 0
                                    then
                                        assign
                                            tt-c1c1.qtdcom = wf-movim.movqtm
                                            tq-prom = tq-prom + wf-movim.movqtm
                                            lp = wf-movim.movqtm .
                                    else do:
                                        if wf-movim.movqtm <= lp
                                        then
                                        assign
                                            tt-c1c1.qtdcas = wf-movim.movqtm
                                            tq-casa = tq-casa + wf-movim.movqtm
                                            lp = lp - wf-movim.movqtm .
                                        else
                                        assign
                                            tt-c1c1.qtdcas = lp
                                            tq-casa = tq-casa + lp
                                            tt-c1c1.qtdcom = 
                                            wf-movim.movqtm - lp
                                            tq-prom = tq-prom + 
                                                (wf-movim.movqtm - lp)
                                            lp = wf-movim.movqtm - lp .
                                    end.
                                end.
                            end.    
                end.
            end.
            if tq-movi > ctpromoc.qtdvenda
            then do:
            if tq-casa > tq-prom
            then tq-casa = truncate((tq-prom / ctpromoc.qtdvenda),0).
            if tq-casa > 0
            then do:
                for each tt-c1c1 by tt-c1c1.movpc:
                    if tq-casa > 0 
                    then do:
                        if tt-c1c1.qtdcas > 0 and
                           tt-c1c1.qtdcom > 0
                        then do:
                            if tq-casa > tt-c1c1.qtdcas
                            then assign
                                tq-casa = tq-casa - tt-c1c1.qtdcas.
                        end.
                        else if tt-c1c1.qtdcas > 0
                        then if tq-casa > tt-c1c1.qtdcas
                            then tq-casa = tq-casa - tt-c1c1.qtdcas .
                            else assign
                                    tt-c1c1.qtdcas = tq-casa
                                    tq-casa = 0.
                    end.
                    else if tq-casa = 0 and
                        tt-c1c1.qtdcom > 0
                    then tt-c1c1.qtdcas = 0.
                    else if tt-c1c1.qtdcas > 0
                    then assign
                            tt-c1c1.qtdcom  = tt-c1c1.qtdcas
                            tt-c1c1.qtdcas = 0 .
                end. 
            end.       
            def var t-co as dec.
            def var t-ca as dec.
            def var t-qt as dec.
            assign
                t-qt = 0
                t-co = 0
                t-ca = 0
                q-c1 = 0 
                q-c2 = 0.
            for each tt-c1c1:
                assign
                    q-c1 = q-c1 + tt-c1c1.qtdcom 
                    q-c2 = q-c2 + tt-c1c1.qtdcas .
            end.
            if q-c1 > 0 and q-c2 > 0
            then
            for each wf-movim by wf-movim.movpc descending:
                find produ where recid(produ) = wf-movim.wrec no-lock no-error.
                if not avail produ then next.
                if produ.proipiper = 98 /* Servico */
                then next.
                find first tt-c1c1 where
                           tt-c1c1.procod = produ.procod and
                           (tt-c1c1.qtdcom > 0 or
                            tt-c1c1.qtdcas > 0) no-error.
                if avail tt-c1c1
                then do:
                    if acha("PERCENTUAL",tt-c1c1.tipocas) = ?
                    then v-totven = (wf-movim.movpc * tt-c1c1.qtdcom) +
                        (tt-c1c1.valorcas * tt-c1c1.qtdcas).
                    else v-totven = (wf-movim.movpc * tt-c1c1.qtdcom) +
                        ((wf-movim.movpc * (tt-c1c1.valorcas / 100))
                             * tt-c1c1.qtdcas).
                    wf-movim.movpc = v-totven / wf-movim.movqtm.
                    spromoc = yes.
                end.
            end.
            end. 
        end.                
    end.
end procedure.
procedure promo-compraXcasaY:
    def var v-casa as dec init 0.
    def var tq-prom as dec init 0.
    def var tq-casa as dec init 0.
    def var tq-movi as dec init 0.
    def var q-prom as dec init 0.
    def var q-casa as dec init 0.
    def var q-c1 as dec init 0.
    def var q-c2 as dec init 0.
    def var v-totven as dec.
    def var lp as dec.
    def var q-df as dec.

    for each tt-c1c1: delete tt-c1c1. end.
    
    venda-acima-de = yes.
        if ctpromoc.vendaacimade > 0
        then do:
            venda-acima-de = no.
            run valida-venda-acimade.
        end.
    run ver-linha-ativa.
    if v-ativa
    then do:
        tq-movi = 0.
        for each wf-movim no-lock by wf-movim.movpc descending: 
            find produ where recid(produ) = wf-movim.wrec no-lock no-error.
            if not avail produ then next.
            if produ.proipiper = 98 /* Servico */
            then next.
            na-promocao = no.
            run find-pro-promo.
            assign
                na-casadinha = no
                valor-produto-venda-casada = 0
                tipo-valor-venda-casada = "".
            run find-cas-promo.
            if venda-acima-de = no then na-casadinha = no.
            if na-promocao = no and
               na-casadinha = no
            then next.  
            find first tt-c1c1 where
                           tt-c1c1.procod = produ.procod
                           no-error.
            if not avail tt-c1c1
            then do:
                create tt-c1c1.
                assign
                    tt-c1c1.procod = produ.procod
                    tt-c1c1.movpc  = wf-movim.movpc
                    tt-c1c1.movqtm = wf-movim.movqtm .
            end.           
            assign
                tt-c1c1.valorcas = valor-produto-venda-casada
                tt-c1c1.tipocas  = tipo-valor-venda-casada 
                tq-movi = tq-movi + wf-movim.movqtm.
            if na-promocao and not na-casadinha
            then assign
                     tt-c1c1.qtdcom = wf-movim.movqtm
                     tt-c1c1.indprom = yes
                     tq-prom = tq-prom + wf-movim.movqtm.
            else if not na-promocao and na-casadinha
                then assign
                         tt-c1c1.qtdcas = wf-movim.movqtm
                         tt-c1c1.indcasa = yes
                         tq-casa = tq-casa + wf-movim.movqtm.
                else if na-promocao and na-casadinha
                    then do:
                        assign
                            tt-c1c1.indcasa = yes
                            tt-c1c1.indprom = yes .
                        if wf-movim.movqtm >= ctpromoc.qtdvenda /*+ 
                                                      ctpromoc.qtdbrinde*/
                        then do:                                  
                             v-casa = truncate((wf-movim.movqtm /
                             (ctpromoc.qtdvenda /*+ ctpromoc.qtdbrinde*/)),0).
                            assign
                                tt-c1c1.qtdcom = wf-movim.movqtm - v-casa
                                tt-c1c1.qtdcas = v-casa
                                tq-prom = tq-prom + 
                                    (wf-movim.movqtm - v-casa)
                                    tq-casa = tq-casa + v-casa
                                    v-casa = 0 .
                        end.
                        else do:
                            if lp = 0 or lp < ctpromoc.qtdvenda -
                                        ctpromoc.qtdbrinde
                            then assign
                                     tt-c1c1.qtdcom = wf-movim.movqtm
                                     tq-prom = tq-prom + wf-movim.movqtm
                                     lp = lp + wf-movim.movqtm .
                            else do:
                                if wf-movim.movqtm <= lp
                                then assign
                                         tt-c1c1.qtdcas = wf-movim.movqtm
                                         tq-casa = tq-casa + wf-movim.movqtm
                                         lp = lp - wf-movim.movqtm .
                                else assign
                                         tt-c1c1.qtdcas = lp
                                         tq-casa = tq-casa + lp
                                         tt-c1c1.qtdcom = 
                                            wf-movim.movqtm - lp
                                         tq-prom = tq-prom + 
                                                (wf-movim.movqtm - lp)
                                         lp = wf-movim.movqtm - lp .
                            end.
                        end.
                    end. 
            end.
            /*
             for each tt-c1c1:
                             disp tt-c1c1. pause.
                             end.
            */

            if tq-movi > ctpromoc.qtdvenda - ctpromoc.qtdbrinde
            then do:
                if tq-casa > tq-prom
                then tq-casa = truncate((tq-prom / 
                (ctpromoc.qtdvenda - ctpromoc.qtdbrinde)),0).
                else tq-casa = truncate((tq-casa + tq-prom) / 
                            (ctpromoc.qtdvenda /*+ ctpromoc.qtdbrinde*/), 0 ).
                
                tq-casa = ctpromoc.qtdbrinde * tq-casa.
                
                if tq-casa > 0
                then for each tt-c1c1 by tt-c1c1.movpc:
                     if tq-casa > 0 
                     then do:
                        if tt-c1c1.qtdcas > 0 and
                           tt-c1c1.qtdcom > 0
                        then do:
                            if tq-casa > tt-c1c1.qtdcas + tt-c1c1.qtdcom
                            then assign
                                tt-c1c1.qtdcas = tt-c1c1.qtdcas + 
                                                 tt-c1c1.qtdcom
                                tt-c1c1.qtdcom = 0
                                tq-casa = tq-casa - tt-c1c1.qtdcas  .
                            else assign
                                 tt-c1c1.qtdcom = tt-c1c1.qtdcom -
                                 (tq-casa - tt-c1c1.qtdcas)
                                 tt-c1c1.qtdcas = tq-casa
                                 tq-casa = 0.
                        end.
                        else do:
                            if tt-c1c1.qtdcas > 0
                            then do:
                                if tq-casa > tt-c1c1.qtdcas
                                then tq-casa = tq-casa - tt-c1c1.qtdcas .
                                else assign
                                    tt-c1c1.qtdcas = tq-casa
                                    tq-casa = 0.
                            end.
                            else do:
                                if tt-c1c1.indcasa and 
                                    tq-casa >= tt-c1c1.qtdcom
                                then assign
                                        tt-c1c1.qtdcas = tt-c1c1.qtdcom    
                                        tt-c1c1.qtdcom = 0
                                        tq-casa = tq-casa - tt-c1c1.qtdcas .
                                else if tt-c1c1.indcasa  
                                    then assign
                                           tt-c1c1.qtdcas = tq-casa
                                           tt-c1c1.qtdcom = tt-c1c1.qtdcom -
                                            tq-casa
                                           tq-casa = 0. 
                                
                            end.
                        end.
                    end.
                    else if tq-casa = 0 and
                        tt-c1c1.qtdcom > 0
                    then assign
                            tt-c1c1.qtdcom = tt-c1c1.qtdcom +
                                tt-c1c1.qtdcas
                            tt-c1c1.qtdcas = 0.
                    else if tt-c1c1.qtdcas > 0
                    then assign
                            tt-c1c1.qtdcom  = tt-c1c1.qtdcas
                            tt-c1c1.qtdcas = 0 .
                end.
            end.     
            else 
                for each tt-c1c1 where tt-c1c1.qtdcom = 
                (ctpromoc.qtdvenda /*- ctpromoc.qtdbrinde*/) and
                                       tt-c1c1.qtdcas = 0:
                    tt-c1c1.qtdcas = ctpromoc.qtdbrinde.
                    tt-c1c1.qtdcom = tt-c1c1.qtdcom - ctpromoc.qtdbrinde.
                end.
                    
            def var t-co as dec.
            def var t-ca as dec.
            def var t-qt as dec.

            assign
                t-qt = 0
                t-co = 0
                t-ca = 0
                q-c1 = 0 
                q-c2 = 0.
            
            for each tt-c1c1:
                assign
                    q-c1 = q-c1 + tt-c1c1.qtdcom 
                    q-c2 = q-c2 + tt-c1c1.qtdcas .
            end.
          
            if q-c1 < q-c2 then q-c1 = 0.
            if q-c2 < ctpromoc.qtdbrinde then q-c2 = 0.
            
            if q-c1 > 0 and q-c2 > 0
            then
            for each wf-movim by wf-movim.movpc descending:
                find produ where recid(produ) = wf-movim.wrec no-lock no-error.
                if not avail produ then next.
                if produ.proipiper = 98 /* Servico */
                then next.
                find first tt-c1c1 where
                           tt-c1c1.procod = produ.procod and
                           (tt-c1c1.qtdcom > 0 or
                            tt-c1c1.qtdcas > 0) no-error.
                if avail tt-c1c1
                then do:
                    if tt-c1c1.qtdcom > wf-movim.movqtm
                    then tt-c1c1.qtdcom = wf-movim.movqtm.
                    if tt-c1c1.qtdcas > wf-movim.movqtm
                    then tt-c1c1.qtdcas = wf-movim.movqtm.
                    if tt-c1c1.qtdcom + tt-c1c1.qtdcas > wf-movim.movqtm
                    then repeat:
                        if tt-c1c1.qtdcom > 0
                        then tt-c1c1.qtdcom = tt-c1c1.qtdcom - 1.
                        else tt-c1c1.qtdcas = tt-c1c1.qtdcas - 1.
                        if tt-c1c1.qtdcom + tt-c1c1.qtdcas = wf-movim.movqtm
                        then leave.    
                    end.
                    if acha("PERCENTUAL",tt-c1c1.tipocas) = ?
                    then v-totven = (wf-movim.movpc * tt-c1c1.qtdcom) +
                        (tt-c1c1.valorcas * tt-c1c1.qtdcas).
                    else v-totven = (wf-movim.movpc * tt-c1c1.qtdcom) +
                        ((wf-movim.movpc * tt-c1c1.qtdcas) -
                        (wf-movim.movpc * (tt-c1c1.valorcas / 100))
                             * tt-c1c1.qtdcas).
          
                    q-df = wf-movim.movqtm - tt-c1c1.qtdcom - tt-c1c1.qtdcas.
                    if q-df > 0
                    then v-totven = v-totven + (wf-movim.movpc * q-df).
                    wf-movim.movpc = v-totven / wf-movim.movqtm.
                    spromoc = yes.
                end.
            end.
            /*end. */

    end.
    
    for each tt-c1c1: delete tt-c1c1. end.
    
end procedure.
procedure promo-compraXbrindeY:
    def var v-casa as dec init 0.
    def var tq-prom as dec init 0.
    def var tq-casa as dec init 0.
    def var tq-movi as dec init 0.
    def var q-prom as dec init 0.
    def var q-casa as dec init 0.
    def var q-c1 as dec init 0.
    def var q-c2 as dec init 0.
    def var v-totven as dec.
    def var lp as dec.
    def var q-df as dec.
    def var no-brinde as log.
    def var pr-diminui as dec.
    def var vpn as int.
    
    venda-acima-de = yes.
        if ctpromoc.vendaacimade > 0
        then do:
            venda-acima-de = no.
            run valida-venda-acimade.
        end.
    run ver-linha-ativa.
    if v-ativa
    then do:
        tq-movi = 0.
        for each wf-movim by wf-movim.movpc descending: 
            find produ where recid(produ) = wf-movim.wrec no-lock no-error.
            if not avail produ then next.
            if produ.proipiper = 98 /* Servico */
            then next.
            na-promocao = no.
            run find-pro-promo.
            no-brinde = no.
            find first bctpromoc where
                         bctpromoc.sequenci = ctpromoc.sequencia and
                         bctpromoc.probrinde = produ.procod 
                         no-lock no-error.
            if avail bctpromoc
            then no-brinde = yes.
            if na-promocao = no and
               no-brinde = no
            then next.  

            find first tt-c1c1 where
                           tt-c1c1.procod = produ.procod
                           no-error.
            if not avail tt-c1c1
            then do:
                create tt-c1c1.
                assign
                    tt-c1c1.procod = produ.procod
                    tt-c1c1.movpc  = wf-movim.movpc
                    tt-c1c1.movqtm = wf-movim.movqtm .
            end.           
            tq-movi = tq-movi + wf-movim.movqtm.
            if na-promocao and not no-brinde
            then assign
                     tt-c1c1.qtdcom = wf-movim.movqtm
                     tt-c1c1.indprom = yes
                     tq-prom = tq-prom + wf-movim.movqtm.
            else if not na-promocao and no-brinde
                then do: 
                    /**** TP 23691258
                    assign
                         tt-c1c1.qtdcas = wf-movim.movqtm
                         tt-c1c1.indcasa = yes
                         tq-casa = tq-casa + wf-movim.movqtm.
                    ****/
                    if tq-casa + wf-movim.movqtm <= ctpromoc.qtdbrinde
                    then assign
                        tt-c1c1.qtdcas = wf-movim.movqtm
                        tt-c1c1.indcasa = yes
                        tq-casa = tq-casa + wf-movim.movqtm.
                    else tt-c1c1.qtdcom = wf-movim.movqtm.
                end.
                else if na-promocao and no-brinde
                    then do:
                        assign
                            tt-c1c1.indcasa = yes
                            tt-c1c1.indprom = yes .
                        if wf-movim.movqtm >= ctpromoc.qtdvenda + 
                                                      ctpromoc.qtdbrinde
                        then do:                      
                             v-casa = truncate((wf-movim.movqtm /
                                  (ctpromoc.qtdvenda + ctpromoc.qtdbrinde)),0).
                            assign
                                tt-c1c1.qtdcom = wf-movim.movqtm - v-casa
                                tt-c1c1.qtdcas = v-casa
                                tq-prom = tq-prom + 
                                    (wf-movim.movqtm - v-casa)
                                    tq-casa = tq-casa + v-casa
                                    v-casa = 0 .
                        end.
                        else do:
                            if lp = 0
                            then assign
                                     tt-c1c1.qtdcom = wf-movim.movqtm
                                     tq-prom = tq-prom + wf-movim.movqtm
                                     lp = wf-movim.movqtm .
                            else do:
                                if wf-movim.movqtm <= lp
                                then assign
                                         tt-c1c1.qtdcas = wf-movim.movqtm
                                         tq-casa = tq-casa + wf-movim.movqtm
                                         lp = lp - wf-movim.movqtm .
                                else assign
                                         tt-c1c1.qtdcas = lp
                                         tq-casa = tq-casa + lp
                                         tt-c1c1.qtdcom = 
                                            wf-movim.movqtm - lp
                                         tq-prom = tq-prom + 
                                                (wf-movim.movqtm - lp)
                                         lp = wf-movim.movqtm - lp .
                            end.
                        end.
                    end. 
            end.
            
            if tq-movi > ctpromoc.qtdvenda
            then do:
                if tq-casa > tq-prom
                then tq-casa = truncate((tq-prom / ctpromoc.qtdvenda),0).
                
                if tq-casa > 0
                then for each tt-c1c1 where
                              tt-c1c1.indcas 
                                by tt-c1c1.movpc:
                     if tq-casa > 0 
                     then do:
                        if tt-c1c1.qtdcas > 0 and
                           tt-c1c1.qtdcom > 0
                        then do:
                            if tq-casa > tt-c1c1.qtdcas + tt-c1c1.qtdcom
                            then assign
                                tt-c1c1.qtdcas = tt-c1c1.qtdcas + 
                                                 tt-c1c1.qtdcom
                                tt-c1c1.qtdcom = 0
                                tq-casa = tq-casa - tt-c1c1.qtdcas  .
                            else assign
                                 tt-c1c1.qtdcom = tt-c1c1.qtdcom -
                                 (tq-casa - tt-c1c1.qtdcas)
                                 tt-c1c1.qtdcas = tq-casa
                                 tq-casa = 0.
                        end.
                        else do:
                            if tt-c1c1.qtdcas > 0
                            then do:
                                if tq-casa > tt-c1c1.qtdcas
                                then tq-casa = tq-casa - tt-c1c1.qtdcas .
                                else do:
                                    if tt-c1c1.qtdcas > ctpromoc.qtdbrinde
                                        and tt-c1c1.indcasa = yes
                                        and tt-c1c1.indprom = yes
                                    then do:    
                                        assign
                                            tq-casa = tq-casa - tt-c1c1.qtdcas 
                                            tt-c1c1.qtdcom = tt-c1c1.qtdcom +
                                          (tt-c1c1.qtdcas - ctpromoc.qtdbrinde)
                                           tt-c1c1.qtdcas = ctpromoc.qtdbrinde
                                           .
                                    end.
                                    else if tt-c1c1.qtdcas > ctpromoc.qtdbrinde
                                    and tt-c1c1.indcasa = yes
                                    and tt-c1c1.indprom = no
                                    then do:
                                        assign
                                            vpn = trunca((tq-prom /                                                       ctpromoc.qtdvenda),0)
                                            tt-c1c1.qtdcom =  tq-casa - 
                                                (ctpromoc.qtdbrinde * vpn)
                                            tt-c1c1.qtdcas = 
                                                ctpromoc.qtdbrinde * vpn
                                            tq-casa = 0.
                                    end.
                                    else
                                    assign
                                        tt-c1c1.qtdcas = tq-casa
                                        tq-casa = 0.
                                end.
                            end.
                            else do:
                                if tt-c1c1.indcasa and 
                                    tq-casa >= tt-c1c1.qtdcom
                                then assign
                                        tt-c1c1.qtdcas = tt-c1c1.qtdcom    
                                        tt-c1c1.qtdcom = 0
                                        tq-casa = tq-casa - tt-c1c1.qtdcas .
                                else if tt-c1c1.indcasa  
                                    then assign
                                           tt-c1c1.qtdcas = tq-casa
                                           tt-c1c1.qtdcom = tt-c1c1.qtdcom -
                                            tq-casa
                                           tq-casa = 0. 
                            end.
                        end.
                    end.
                    else if tq-casa = 0 and
                        tt-c1c1.qtdcom > 0
                    then assign
                            tt-c1c1.qtdcom = tt-c1c1.qtdcom +
                                tt-c1c1.qtdcas
                            tt-c1c1.qtdcas = 0.
                    else if tt-c1c1.qtdcas > 0
                    then assign
                            tt-c1c1.qtdcom  = tt-c1c1.qtdcas
                            tt-c1c1.qtdcas = 0 .
            end.       
            def var t-co as dec.
            def var t-ca as dec.
            def var t-qt as dec.
            assign
                t-qt = 0
                t-co = 0
                t-ca = 0
                q-c1 = 0 
                q-c2 = 0.
            for each tt-c1c1:
                assign
                    q-c1 = q-c1 + tt-c1c1.qtdcom 
                    q-c2 = q-c2 + tt-c1c1.qtdcas .
            end.
            pr-diminui = 0.
            if q-c1 > 0 and q-c2 > 0 
            then
            for each wf-movim by wf-movim.movpc descending:
                find produ where recid(produ) = wf-movim.wrec no-lock no-error.
                if not avail produ then next.
                if produ.proipiper = 98 /* Servico */
                then next.
                find first tt-c1c1 where
                           tt-c1c1.procod = produ.procod and
                           (tt-c1c1.qtdcom > 0 or
                            tt-c1c1.qtdcas > 0) no-error.
                if avail tt-c1c1
                then do:
                    /*
                    if tt-c1c1.qtdcas > 0 and tt-c1c1.valorcas = 0
                        and tt-c1c1.qtdcom = 0
                    then tt-c1c1.valorcas = 1.
                    */
                    if acha("PERCENTUAL",tt-c1c1.tipocas) = ?
                    then v-totven = (wf-movim.movpc * tt-c1c1.qtdcom) +
                        (tt-c1c1.valorcas * tt-c1c1.qtdcas).
                    else v-totven = (wf-movim.movpc * tt-c1c1.qtdcom) +
                        ((wf-movim.movpc * (tt-c1c1.valorcas / 100))
                             * tt-c1c1.qtdcas).
                    q-df = wf-movim.movqtm - tt-c1c1.qtdcom - tt-c1c1.qtdcas.
                    if q-df > 0
                    then v-totven = v-totven + (wf-movim.movpc * q-df).
                    wf-movim.movpc = v-totven / wf-movim.movqtm.
                    if wf-movim.movpc = 0 and wf-movim.movqtm >= 1
                    then assign
                            pr-diminui = 1 * wf-movim.movqtm
                            wf-movim.movpc = 1.
                    else if wf-movim.movpc > 1
                    then assign
                            wf-movim.movpc = wf-movim.movpc -
                                    (pr-diminui / wf-movim.movqtm)
                            pr-diminui = 0 .

                    if avail ctpromoc
                    then                             /* helio 09032022 - [ORQUESTRA 243179 - ESCOPO ADICIONAL] Sele��o de moeda a vista na Pr�-Venda  */ 
                            xx = promocod(ctpromoc.sequencia).
                    
                    spromoc = yes.
                end.
            end.
            if pr-diminui > 0
            then do:
                for each wf-movim where wf-movim.movpc > 1
                            by wf-movim.movpc descending:
                    find produ where recid(produ) = wf-movim.wrec
                           no-lock no-error.
                    if not avail produ then next.
                    if produ.proipiper = 98 /* Servico */
                    then next.
                    assign
                        wf-movim.movpc = wf-movim.movpc -
                                    (pr-diminui / wf-movim.movqtm)
                        pr-diminui = 0.

                    leave. 
                end.
            end.
            end. 
    end.
end procedure.
procedure promo-compra1brinde1:
    def buffer bwf-movim for wf-movim.
    def buffer bprodu for produ.
    def buffer btt-c1b1 for tt-c1b1.
    def var no-brinde as log.
    def var tq-prom as dec init 0.
    def var tq-brin as dec init 0.
    def var tq-movi as dec init 0.
    def var q-prom as dec init 0.
    def var q-brin as dec init 0.
    def var q-c1 as dec init 0.
    def var q-c2 as dec init 0.
    def var t-prom as int init 0.
    def var v-totven as dec.
    for each tt-c1b1: delete tt-c1b1. end.
    do:
        run ver-linha-ativa.
        if v-ativa
        then do:
            tq-movi = 0.
            for each wf-movim by wf-movim.movpc:
                find produ where recid(produ) = wf-movim.wrec no-lock no-error.
                if not avail produ then next.
                if produ.proipiper = 98 /* Servico */
                then next.
                na-promocao = no.
                run find-pro-promo.
                no-brinde = no.
                /*
                find first bctpromoc where
                         bctpromoc.sequenci = ctpromoc.sequencia and
                         bctpromoc.probrinde = produ.procod 
                         no-lock no-error.
                if avail bctpromoc
                then no-brinde = yes.
                */
                if na-promocao and not no-brinde 
                then t-prom = t-prom + wf-movim.movqtm.  
            end.
            for each wf-movim by wf-movim.movpc:
                find produ where recid(produ) = wf-movim.wrec no-lock no-error.
                if not avail produ then next.
                if produ.proipiper = 98 /* Servico */
                then next.
                na-promocao = no.
                run find-pro-promo.
                no-brinde = no.
                find first bctpromoc where
                         bctpromoc.sequenci = ctpromoc.sequencia and
                         bctpromoc.probrinde = produ.procod 
                         no-lock no-error.
                if avail bctpromoc
                then no-brinde = yes.
                if na-promocao = no and
                   no-brinde = no
                then next.  
                find first tt-c1b1 where
                           tt-c1b1.procod = produ.procod
                           no-error.
                if not avail tt-c1b1
                then do:
                    create tt-c1b1.
                    assign
                        tt-c1b1.procod = produ.procod
                        tt-c1b1.movpc  = wf-movim.movpc
                        tt-c1b1.movqtm = wf-movim.movqtm .
                end.           
                tq-movi = tq-movi + wf-movim.movqtm.
                if na-promocao or no-brinde
                then do:   
                    if na-promocao and not no-brinde
                    then assign
                            tt-c1b1.qtdcom = wf-movim.movqtm
                            tq-prom = tq-prom + wf-movim.movqtm .
                    else if not na-promocao and no-brinde
                        then do:
                            /*** TP 24006506 /***/
                            assign  
                                tt-c1b1.qtdbri = wf-movim.movqtm
                                tq-brin = tq-brin + wf-movim.movqtm .
                            ***/
                            if tq-brin + wf-movim.movqtm <= 
                                    (ctpromoc.qtdbrinde * 
                                            (t-prom / ctpromoc.qtdvenda))
                            then assign
                                tt-c1b1.qtdbri = wf-movim.movqtm
                                /*tt-c1b1.indcasa = yes*/
                                tq-brin = tq-brin + wf-movim.movqtm.
                            else do:
                                if tq-brin < (ctpromoc.qtdbrinde *
                                    (t-prom / ctpromoc.qtdvenda))
                                then assign
                                        tt-c1b1.qtdbri =
                                        (ctpromoc.qtdbrinde *
                                        (t-prom / ctpromoc.qtdvenda)) -                                             tq-brin
                                        tt-c1b1.qtdcom = wf-movim.movqtm
                                        - tt-c1b1.qtdbri
                                        .
                                else tt-c1b1.qtdcom = wf-movim.movqtm.
                            end.
                            /*****/
                        end.
                        else if na-promocao and no-brinde
                            then do:
                                assign
                                    tt-c1b1.qtdcom = wf-movim.movqtm
                                    tt-c1b1.qtdbri = wf-movim.movqtm
                                    tq-prom = tq-prom + wf-movim.movqtm
                                    tq-brin = tq-brin + wf-movim.movqtm .
                        end.
                end.
            end.

            if tq-movi > ctpromoc.qtdvenda
            then do:

                if int(tq-brin / ctpromoc.qtdbrinde) > tq-prom
                then tq-brin = truncate((tq-prom / ctpromoc.qtdvenda),0).
                
            /*
            if tq-brin >= tq-prom
            then tq-prom = int(tq-movi / 2).
            tq-brin = tq-movi - tq-prom.
            for each tt-c1b1:
                if tt-c1b1.qtdcom = 0 and
                   tt-c1b1.qtdbri > 0
                then tq-brin = tq-brin - tt-c1b1.qtdbri.
            end.    
            */

            /*********
            if tq-brin > 0
            then do:
                for each tt-c1b1 by tt-c1b1.movpc:
                    if tq-brin > 0 
                     then do:
                        if tt-c1b1.qtdbri > 0 and
                           tt-c1b1.qtdcom > 0
                        then do:
                            if tq-brin > tt-c1b1.qtdbri + tt-c1b1.qtdcom
                            then assign
                                tt-c1b1.qtdbri = tt-c1b1.qtdbri + 
                                                 tt-c1b1.qtdcom
                                tt-c1b1.qtdcom = 0
                                tq-brin = tq-brin - tt-c1b1.qtdbri .
                            else assign
                                 tt-c1b1.qtdcom = tt-c1b1.qtdcom -
                                 (tq-brin - tt-c1b1.qtdbri)
                                 tt-c1b1.qtdbri = tq-brin
                                 tq-brin = 0.
                        end.
                        else do:
                            if tt-c1b1.qtdbri > 0
                            then do:
                                if tq-brin > tt-c1b1.qtdbri
                                then tq-brin = tq-brin - tt-c1b1.qtdbri .
                                else do:
                                    if tt-c1b1.qtdbri > ctpromoc.qtdbrinde
                                                        * 
                                    then do:    
                                        assign
                                            tq-brin = tq-brin - tt-c1b1.qtdbri 
                                            tt-c1b1.qtdcom = tt-c1b1.qtdcom +
                                          (tt-c1b1.qtdbri - ctpromoc.qtdbrinde)
                                           tt-c1b1.qtdbri = ctpromoc.qtdbrinde
                                           .
                                    end.
                                    /*****
                                    else if tt-c1b1.qtdbri > ctpromoc.qtdbride
                                    and tt-c1c1.indcasa = yes
                                    and tt-c1c1.indprom = no
                                    then do:
                                        assign
                                            vpn = trunca((tq-prom /            ~                                           ctpromoc.qtdvenda),0)
                                            tt-c1c1.qtdcom =  tq-casa - 
                                                (ctpromoc.qtdbride * vpn)
                                            tt-c1c1.qtdcas = 
                                                ctpromoc.qtdbride * vpn
                                            tq-casa = 0.
                                    end.
                                    *****/
                                    else
                                    assign
                                        tt-c1b1.qtdbri = tq-brin
                                        tq-brin = 0.
                                end.
                            end.
                            else do:
                                if tq-brin >= tt-c1b1.qtdbri
                                then assign
                                        tt-c1b1.qtdbri = tt-c1b1.qtdcom    
                                        tt-c1b1.qtdcom = 0
                                        tq-brin = tq-brin - tt-c1b1.qtdbri.
                                else if tt-c1b1.qtdcom > 0  
                                    then assign
                                           tt-c1b1.qtdbri = tq-brin
                                           tt-c1b1.qtdcom = tt-c1b1.qtdcom -
                                            tq-brin
                                           tq-brin = 0. 
                            end.
                        end.
                    end.
                    else if tq-brin = 0 and
                        tt-c1b1.qtdcom > 0
                    then assign
                            tt-c1b1.qtdcom = tt-c1b1.qtdcom +
                                tt-c1b1.qtdbri
                            tt-c1b1.qtdbri = 0.
                    else if tt-c1b1.qtdbri > 0
                    then assign
                            tt-c1b1.qtdcom  = tt-c1b1.qtdbri
                            tt-c1b1.qtdbri = 0 .

                /**************
                    if tq-brin > 0 and
                       tt-c1b1.qtdbri > 0 and
                       tt-c1b1.qtdcom > 0 and
                       tq-brin <> tt-c1b1.qtdbri
                    then do:
                        if tq-brin > tt-c1b1.qtdbri
                        then assign
                                tq-brin = tq-brin - tt-c1b1.qtdbri
                                tt-c1b1.qtdcom = 
                                    tt-c1b1.qtdcom - tt-c1b1.qtdbri.
                        else assign
                                 tt-c1b1.qtdcom = tt-c1b1.qtdcom - tq-brin
                                 tt-c1b1.qtdbri = tq-brin
                                 tq-brin = 0.   
                    end.
                    if tq-brin > 0 and
                       tt-c1b1.qtdbri > 0 and
                       tt-c1b1.qtdcom = 0
                    then do:
                        if tq-brin > tt-c1b1.qtdbri
                        then assign
                                tt-c1b1.qtdcom = tt-c1b1.qtdbri
                                tt-c1b1.qtdbri = 0
                                tq-brin = tq-brin - tt-c1b1.qtdbri
                                 .
                        else assign
                                 tt-c1b1.qtdcom = tt-c1b1.qtdbri
                                 tt-c1b1.qtdbri = 0
                                 tq-brin = 0.  
                    end.                    else if tq-brin = 0 and
                        tt-c1b1.qtdcom > 0
                    then tt-c1b1.qtdbri = 0.
                    *****/
                
                end. 
            end.       
            ****/
            def var t-co as dec.
            def var t-cb as dec.
            def var t-qt as dec.
            assign
                t-qt = 0
                t-co = 0
                t-cb = 0
                q-c1 = 0 
                q-c2 = 0.
            for each tt-c1b1:
                assign
                    q-c1 = q-c1 + tt-c1b1.qtdcom 
                    q-c2 = q-c2 + tt-c1b1.qtdbri .
            end.
            if q-c1 > 0 and q-c2 > 0
            then
            for each wf-movim by wf-movim.movpc descending:
                find produ where recid(produ) = wf-movim.wrec no-lock no-error.
                if not avail produ then next.
                if produ.proipiper = 98 /* Servico */
                then next.
                find first tt-c1b1 where
                           tt-c1b1.procod = produ.procod and
                           (tt-c1b1.qtdcom > 0 or
                            tt-c1b1.qtdbri > 0) no-error.
                if avail tt-c1b1
                then do:
                    if tt-c1b1.qtdcom = 0 and 
                       tt-c1b1.qtdbri > 0 
                    then do:
                        v-totven = (wf-movim.movpc * tt-c1b1.qtdcom) +
                                tt-c1b1.qtdbri.
                        wf-movim.movpc = v-totven / wf-movim.movqtm.
                        if tt-c1b1.qtdcom = 0 
                        then 
                        for each bwf-movim :
                            find bprodu where recid(bprodu) = bwf-movim.wrec
                                    no-lock no-error.
                            if not avail bprodu then next.        
                            find first btt-c1b1 where 
                                       btt-c1b1.procod = bprodu.procod and 
                                       btt-c1b1.qtdcom > 0 no-error.
                            if avail btt-c1b1
                            then do: 
                                v-totven = (bwf-movim.movpc * btt-c1b1.qtdcom) 
                                    - tt-c1b1.qtdbri.
                                bwf-movim.movpc = v-totven / bwf-movim.movqtm.
                                leave.
                            end.
                        end.    
                    end.
                    else if tt-c1b1.qtdcom > 0 and
                            tt-c1b1.qtdbri > 0
                    then do:  
                        v-totven = (wf-movim.movpc * tt-c1b1.qtdcom).
                        wf-movim.movpc = v-totven / wf-movim.movqtm.
                     end.
                    spromoc = yes.    
                end.
            end.
            end. 
        end.                
    end.
end procedure.
def temp-table tt-lxpy
    field procod like produ.procod
    field movpc  as dec
    field movqtm as int
    field qtprom as int
    index i1 procod.

procedure leva-x-paga-y:
    def var vtotal as dec init 0.
    def var vdesco as dec init 0.
    def var vpdesc as dec init 0.
    def buffer sctpromoc for ctpromoc. 
    if vok = yes and ctpromoc.campodec[1] > 0
                 and ctpromoc.campodec[1] <= ctpromoc.qtdvenda
                 and valt-movpc 
    then do:  
        spromoc = yes.
        qtd-menos = 0.
        qtd-prod = int(substr
        (string(qprodu / ctpromoc.qtdvenda,">>>>9.99"),1,5))  .
        qtd-prod = (ctpromoc.qtdvenda - ctpromoc.campodec[1]) * qtd-prod.
        for each wf-movim break by wf-movim.movpc :
            find produ where recid(produ) = wf-movim.wrec no-lock no-error.
            if not avail produ then next.
            if produ.proipiper = 98 /* Servico */
            then next.
            run find-pro-promo.
            if not na-promocao
            then next.
            find first sctpromoc where sctpromoc.sequencia = ctpromoc.sequencia
                    and sctpromoc.linha <> 0
                    and sctpromoc.procod = produ.procod
                    no-lock no-error.
            if avail sctpromoc and
                     sctpromoc.precosugerido > 0
            then 
            vtotal = vtotal + (sctpromoc.precosugerido * wf-movim.movqtm).
            else vtotal = vtotal + (wf-movim.movpc * wf-movim.movqtm).
            if qtd-prod > 0
            then do:
            if wf-movim.movqtm = 1  and
            wf-movim.movpc > 1 
            then do:
                vdesco = vdesco + wf-movim.movpc.
                qtd-prod = qtd-prod - 1.
                qtd-menos = qtd-menos + 1.
                spromoc = yes.
            end.    
            else if wf-movim.movqtm >= qtd-prod
            then do:
                vdesco = vdesco + (wf-movim.movpc * qtd-prod).
                spromoc = yes.
                qtd-prod = 0.    
            end.
            else if wf-movim.movqtm < qtd-prod
            then do:
                vdesco = vdesco + (wf-movim.movpc *  wf-movim.movqtm).
                qtd-prod = qtd-prod -  wf-movim.movqtm.
                spromoc = yes.
            end.    
            end.
        end.
        for each wf-movim:
            find produ where recid(produ) = wf-movim.wrec no-lock no-error.
            if not avail produ then next.
            if produ.proipiper = 98 /* Servico */
            then next.
            run find-pro-promo.
            if not na-promocao
            then next.
            find first sctpromoc where sctpromoc.sequencia = ctpromoc.sequencia
                    and sctpromoc.linha <> 0
                    and sctpromoc.procod = produ.procod
                    no-lock no-error.
            if avail sctpromoc and
                     sctpromoc.precosugerido > 0
            then wf-movim.movpc = sctpromoc.precosugerido -
                    (vdesco * (sctpromoc.precosugerido / vtotal)).
            else wf-movim.movpc = wf-movim.movpc -
                    (vdesco * (wf-movim.movpc  / vtotal)).
        end.
    end. 
end procedure.

/***************************************************
procedure leva-x-paga-y:
    def var vtotal as dec init 0.
    def var vdesco as dec init 0.
    def var vpdesc as dec init 0.
    def var qtddes as dec init 0.
    def var qtdpag as dec init 0.
    def var prsugerido as log.
    def buffer sctpromoc for ctpromoc. 
    if vok = yes and ctpromoc.campodec[1] > 0
                 and ctpromoc.campodec[1] <= ctpromoc.qtdvenda
                 and valt-movpc 
    then do:  
       
        empty temp-table tt-lxpy.
        
        spromoc = yes.
        qtd-menos = 0.
        qtd-prod = int(substr
        (string(qprodu / ctpromoc.qtdvenda,">>>>9.99"),1,5))  .
        
        /*
        qtd-prod = (ctpromoc.qtdvenda - ctpromoc.campodec[1]) * qtd-prod.
        
        */
        
        qtddes = ctpromoc.qtdvenda * qtd-prod.
    
        qtdpag = qtddes - qtd-prod.
        
        for each wf-movim break by wf-movim.movpc descending:
            find produ where recid(produ) = wf-movim.wrec no-lock no-error.
            if not avail produ then next.
            if produ.proipiper = 98 /* Servico */
            then next.
            run find-pro-promo.
            if not na-promocao
            then next.
            find first sctpromoc where sctpromoc.sequencia = ctpromoc.sequencia
                    and sctpromoc.linha <> 0
                    and sctpromoc.procod = produ.procod
                    no-lock no-error.
            if avail sctpromoc and
                     sctpromoc.precosugerido > 0
            then prsugerido = yes.
            else prsugerido = no.
            /*
            vtotal = vtotal + (sctpromoc.precosugerido * wf-movim.movqtm).
            else vtotal = vtotal + (wf-movim.movpc * wf-movim.movqtm).
            */
            
            if qtd-prod > 0 and qtddes > 0
            then do:
                if  wf-movim.movqtm = 1 and 
                    wf-movim.movpc > 1
                then do:
                    /**********
                    vdesco = vdesco + wf-movim.movpc.
                    /*qtd-prod = qtd-prod - 1.
                    */
                    qtddes = qtddes - 1.
                    qtd-menos = qtd-menos + 1.
                    spromoc = yes.
                    if prsugerido
                    then vtotal = vtotal + 
                                (sctpromoc.precosugerido * wf-movim.movqtm).
                    else vtotal = vtotal + (wf-movim.movpc * wf-movim.movqtm).
                    ******/
                
                    if qtdpag > 0
                    then do:
                        create tt-lxpy.
                        assign
                            tt-lxpy.procod = produ.procod
                            tt-lxpy.movpc  = if prsugerido
                                         then sctpromoc.precosugerido
                                         else wf-movim.movpc
                            tt-lxpy.movqtm = wf-movim.movqtm
                            tt-lxpy.qtprom = wf-movim.movqtm
                            qtddes = qtddes - 1
                            qtdpag = qtdpag - 1
                            .                  
                    end.
                    else do:
                        create tt-lxpy.
                        assign
                            tt-lxpy.procod = produ.procod
                            tt-lxpy.movpc  = 1
                            tt-lxpy.movqtm = wf-movim.movqtm
                            tt-lxpy.qtprom = wf-movim.movqtm
                            qtddes = qtddes - 1
                            qtdpag = 0
                            qtd-prod = qtd-prod - 1.
                            .
                    end.
                end.    
                else if wf-movim.movqtm >= qtddes /*qtd-prod*/
                then do:

                    /*********
                    /*
                    vdesco = vdesco + (wf-movim.movpc * qtd-prod).
                    */
                    vdesco = vdesco + (wf-movim.movpc * qtddes).
                    spromoc = yes.
                    /*qtd-prod = 0.    
                    */
                    if prsugerido
                    then vtotal = vtotal + 
                        (sctpromoc.precosugerido * wf-movim.movqtm).
                    else vtotal = vtotal + (wf-movim.movpc * wf-movim.movqtm).
                    qtddes = 0.
                    **********/
                  
                    
                    if wf-movim.movqtm > qtdpag
                    then do:
                        create tt-lxpy.
                        assign
                            tt-lxpy.procod = produ.procod
                            tt-lxpy.movpc  = if prsugerido
                                      then sctpromoc.precosugerido
                                      else wf-movim.movpc
                            tt-lxpy.movqtm = wf-movim.movqtm
                            tt-lxpy.qtprom = wf-movim.movqtm
                            .
                        
                        if wf-movim.movqtm - qtdpag >= qtd-prod
                        then do:
                            tt-lxpy.movpc = ((tt-lxpy.movpc * wf-movim.movqtm)
                            - (tt-lxpy.movpc * qtd-prod)) / wf-movim.movqtm.
                            qtd-prod = 0.
                        end.    
                            
                        assign
                            qtddes = 0
                            qtdpag = 0
                            . 
                        
                    end.
                    else do:
                        create tt-lxpy.
                        assign
                            tt-lxpy.procod = produ.procod
                            tt-lxpy.movpc  = if prsugerido
                                             then sctpromoc.precosugerido
                                             else wf-movim.movpc
                            tt-lxpy.movqtm = wf-movim.movqtm
                            tt-lxpy.qtprom = wf-movim.movqtm
                            qtddes = qtddes - wf-movim.movqtm
                            qtdpag = qtdpag - wf-movim.movqtm
                            .
                            
                    end.
                end.        
                else if wf-movim.movqtm < qtddes /*qtd-prod */
                then do:

                    /**********
                    /*vdesco = vdesco + (wf-movim.movpc *  wf-movim.movqtm).
                    */
                    vdesco = vdesco + (wf-movim.movpc *  wf-movim.movqtm).
                    /*qtd-prod = qtd-prod -  wf-movim.movqtm.
                    */
                    qtddes = qtddes - wf-movim.movqtm.
                    spromoc = yes.
                    if prsugerido
                    then vtotal = vtotal +
                                (sctpromoc.precosugerido * wf-movim.movqtm).
                    else 
                    vtotal = vtotal + (wf-movim.movpc * wf-movim.movqtm).  
                                         ***********/

                    if wf-movim.movqtm > qtdpag
                    then do:
                        create tt-lxpy.
                        assign
                            tt-lxpy.procod = produ.procod
                            tt-lxpy.movpc  = if prsugerido
                                     then sctpromoc.precosugerido
                                     else wf-movim.movpc
                            tt-lxpy.movqtm = wf-movim.movqtm
                            tt-lxpy.qtprom = wf-movim.movqtm
                            qtddes = qtddes - wf-movim.movqtm
                            .     
                                       
                        if wf-movim.movqtm - qtdpag >= qtd-prod
                        then do:
                             tt-lxpy.movpc = ((tt-lxpy.movpc * wf-movim.movqtm)
                              - (tt-lxpy.movpc * qtd-prod)) / wf-movim.movqtm.
                             qtd-prod = 0.
                        end.
                                                    
                         assign
                            qtddes = 0
                            qtdpag = 0
                                 .
                                 
                    end.
                    else do:
                        create tt-lxpy.
                        assign
                            tt-lxpy.procod = produ.procod
                            tt-lxpy.movpc  = if prsugerido
                                             then sctpromoc.precosugerido
                                             else wf-movim.movpc
                            tt-lxpy.movqtm = wf-movim.movqtm
                            tt-lxpy.qtprom = wf-movim.movqtm
                            qtddes = qtddes - wf-movim.movqtm
                            qtdpag = qtdpag - wf-movim.movqtm
                            .
                    end.
                end.    
            end.
        end.
        
        for each wf-movim:
            find produ where recid(produ) = wf-movim.wrec no-lock no-error.
            if not avail produ then next.
            if produ.proipiper = 98 /* Servico */
            then next.
            run find-pro-promo.
            if not na-promocao
            then next.
            find first sctpromoc where sctpromoc.sequencia = ctpromoc.sequencia
                    and sctpromoc.linha <> 0
                    and sctpromoc.procod = produ.procod
                    no-lock no-error.

            /**********
            /*if avail sctpromoc and
                     sctpromoc.precosugerido > 0
            then wf-movim.movpc = (-1 * (sctpromoc.precosugerido -
                    (vdesco * (sctpromoc.precosugerido / vtotal)))).
            else wf-movim.movpc = (-1 * (wf-movim.movpc -
                    (vdesco * (wf-movim.movpc  / vtotal)))).
            */
            wf-movim.movpc = wf-movim.movpc -
                        (vdesco * (sctpromoc.precosugerido / vtotal)).
                        
            *****/
            
            find first  tt-lxpy where
                        tt-lxpy.procod = produ.procod no-lock no-error.
            if avail tt-lxpy 
            then 
                 wf-movim.movpc = 
                    ((wf-movim.movpc * (wf-movim.movqtm - tt-lxpy.qtprom)) +
                    (tt-lxpy.movpc * tt-lxpy.qtprom)) / wf-movim.movqtm
                    .
                    
                /*    
                wf-movim.movpc =  
                ((wf-movim.movpc * (wf-movim.movqtm - tt-lxpy.qtprom) + 
                (tt-lxpy.movpc * tt-lxpy.qtprom)) / wf-movim.movqtm
                .
                  */      
                        
        end.
    end. 
end procedure.
*********************************************/

procedure mensagem-na-venda:
    def var resposta-io as log init no.
    if ctpromoc.campochar[1] <> ""
    then
    repeat on endkey undo :
        run mensagem.p (input-output resposta-io,
                        input ctpromoc.campochar[1],
                        input "  Mensagem  ",
                        input "OK", 
                        input "OK").
        leave.
    end.
end procedure.
def var lg-vinculado as log init no.
def var qtd-val as dec.
procedure p-dinheiro-na-mao:
    def var val-vendedor as dec.
    val-vendedor = 0.
    for each ctpromoc where   (if vdata-teste-promo <> ?
                              then ctpromoc.dtinicio >= vdata-teste-promo
                              else ctpromoc.dtinicio <= today) and
         ctpromoc.dtfim  >= today and
         ctpromoc.linha = 0
         no-lock:
        if ctpromo.promocod = 54 then next.
        if ctpromoc.tipo <> ""
        then next.
        if scartao = "" and 
            (ctpromo.promocod = 28 or
             ctpromoc.descricao[1] matches "*CARTAO LEBES*" or
             ctpromoc.descricao[2] matches "*CARTAO LEBES*")
        THEN NEXT.   
        if ctpromoc.situacao = "L"  
        then do:
            vparam-despesa = no.
            qprodu = 0.
            qbrinde = 0.
            if ctpromoc.qtdvenda > 0
            then do:
                for each wf-movim:
                    find produ where recid(produ) = wf-movim.wrec
                           no-lock no-error.
                    if not avail produ then next.
                    if produ.proipiper = 98 /* Servico */
                    then next.
                    run find-pro-promo.
                    if not na-promocao
                    then next.
                    do vi = 1 to ctpromoc.qtdvenda:
                            if vprodu[vi] = 0
                            then do:
                                vprodu[vi] = produ.procod.
                                leave.
                            end.
                    end.
                    qprodu = qprodu + wf-movim.movqtm.
                end.    
            end.
            vok = no. 
            if qprodu  >= ctpromoc.qtdvenda
            then do:
                if (ctpromoc.campodec2[4] = 0 or
                   qprodu >= ctpromoc.campodec2[4]) and
                   (ctpromoc.campodec2[5] = 0 or
                    qprodu <= ctpromoc.campodec2[5])
                then do:   
                    find first ectpromoc where
                               ectpromoc.sequencia = ctpromoc.sequencia and
                               ectpromoc.etbcod > 0 and
                               ectpromoc.situacao <> "I" and
                               ectpromoc.situacao <> "E"
                               no-lock no-error.
                    if not avail ectpromoc 
                    then do:
                        find first ectpromoc where
                               ectpromoc.sequencia = ctpromoc.sequencia and
                               ectpromoc.fincod <> ? 
                               no-lock no-error.
                        if not avail ectpromoc
                        then vok = yes.
                        else do:
                            run valida-promo-plano.
                            vok = vok-promo-plano.
                        end.
                    end.
                    else do:    
                        find first ectpromoc where
                               ectpromoc.sequencia = ctpromoc.sequencia and
                               ectpromoc.etbcod = setbcod no-lock no-error.
                        if avail ectpromoc and
                            ectpromoc.situacao <> "I" and
                            ectpromoc.situacao <> "E"
                        then do:
                            find first ectpromoc where
                               ectpromoc.sequencia = ctpromoc.sequencia and
                               ectpromoc.fincod <> ? 
                                no-lock no-error.
                            if not avail ectpromoc
                            then vok = yes.
                            else do:
                                run valida-promo-plano.
                                vok = vok-promo-plano.
                            end.    
                        end.
                    end.  
                end.
            end.
            if vok = yes
            then do:
                assign
                    spromoc = no
                    parce-total = 0
                    parcela-fixada = 0
                    prazo-total = 0 .
                if ctpromoc.vendaacimade > 0  and
                    total-venda > 0
                then do:
                    if ctpromoc.campolog3 = no
                    then do:
                        parce-total = 0.
                        parcela-fixada = 0.
                        prazo-total = 0.
                        for each wf-movim no-lock:
                            find first produ where recid(produ) = wf-movim.wrec 
                                   no-lock no-error.
                            if not avail produ then next.
                            if produ.proipiper = 98 /* Servico */
                            then next.
                            vi = 0.
                            do vi = 1 to qbrinde:
                                if vbrinde[vi] = produ.procod
                                then do:
                                    vi = 99.
                                    leave.
                                end.     
                            end.   
                            if vi = 99 then next.      
                            run find-pro-promo.
                            if not na-promocao then  next.
                            total-venda = wf-movim.movpc * wf-movim.movqtm.
                            parcela-fixada = 0.
                            run pro-parcela-fixada.
                            run valor-prazo.
                            prazo-total = prazo-total + total-venda-prazo.
                        end.
                        if prazo-total > 0
                        then total-venda-prazo = prazo-total.
                    end.
                    else do:
                        total-venda = 0.
                        for each wf-movim no-lock:
                            find first produ where recid(produ) = wf-movim.wrec
                                   no-lock no-error. 
                            if not avail produ then next.
                            if produ.proipiper = 98 /* Servico */
                            then next.
                            vi = 0.
                            do vi = 1 to qbrinde:
                                if vbrinde[vi] = produ.procod
                                then do:
                                    vi = 99.
                                    leave.
                                end.     
                            end.   
                            if vi = 99 then next.      
                            run find-pro-promo.
                            if not na-promocao then  next.
                            total-venda = total-venda
                                + (wf-movim.movpc * wf-movim.movqtm).
                        end.
                        total-venda-prazo = total-venda.
                    end.
                end.
                if ctpromoc.bonusvalor > 0
                then do:
                    run bonus-valor.
                end.
                if ctpromoc.bonusparcela = yes
                then do:
                    if ctpromoc.vendaacimade = 0 or
                        (total-venda-prazo >= ctpromoc.vendaacimade and
                        (ctpromoc.campodec2[3] = 0 or
                         total-venda-prazo <= ctpromoc.campodec2[3]))
                    then do:
                        parametro-out = parametro-out + "BONUS=PAR|"
                        + "VALOR-PARCELA=" + string(parce-total)
                        + "|".
                        spromoc = yes.
                    end.
                end. 
                if ctpromoc.bonuspercentual > 0
                then do:
                    if ctpromoc.vendaacimade = 0 or
                        (total-venda-prazo >= ctpromoc.vendaacimade and
                        (ctpromoc.campodec2[3] = 0 or
                         total-venda-prazo <= ctpromoc.campodec2[3]))
                    then do:
                        parametro-out = "BONUS=VAL|" + "VALOR-BONUS=" +
                            string(total-venda-prazo *
                            (ctpromoc.bonuspercentual / 100)) + "|" +
                            parametro-out.
                        spromoc = yes.        
                    end.
                end.
                if ctpromoc.valvendedor > 0
                then do:
                    qtd-val = 0.
                    if ctpromoc.campolog4 = yes
                    then do:
                        for each wf-movim no-lock:
                            find produ where recid(produ) = wf-movim.wrec
                                    no-lock no-error.
                            if not avail produ then next.
                            if produ.proipiper = 98 /* Servico */
                            then next.
                            run find-pro-promo.
                            if not na-promocao
                            then next.
                            qtd-val = qtd-val + wf-movim.movqtm.
                        end.
                    end.    
                    else qtd-val = 1.
                    if ctpromoc.vendaacimade = 0
                    then do:
                        run cria-temp-valor(1, "VENDEDOR",
                                ctpromoc.valvendedor * qtd-val, 0).
                        spromoc = yes.
                    end.
                    else if ctpromoc.vendaacimade > 0  and
                        (total-venda-prazo >= ctpromoc.vendaacimade and
                        (ctpromoc.campodec2[3] = 0 or
                         total-venda-prazo <= ctpromoc.campodec2[3]))
                    then do:
                        if ctpromoc.campodec2[4] > 0 and
                           ctpromoc.campodec2[5] > 0
                        then run quantidade-vendida("VENDEDOR").
                        if ctpromoc.vendaacimade <= total-venda-prazo and
                           (ctpromoc.campodec2[4] = 0 or 
                            qtd-vendida >= ctpromoc.campodec2[4]) and
                           (ctpromoc.campodec2[5] = 0 or
                            qtd-vendida <= ctpromoc.campodec2[5]) 
                        then do:
                            run cria-temp-valor(1, "VENDEDOR",
                                ctpromoc.valvendedor * qtd-val,
                                 ctpromo.vendaacimade) .
                            parametro-out = tipo-venda + "=" + 
                                            string(qtd-vendida) + "|" +
                                            parametro-out.
                            spromoc = yes.
                        end.
                    end.
                end.
                p-venda-prazo = total-venda-prazo.
                if ctpromoc.pctvendedor > 0
                then do:
                    qtd-val = 0.
                    total-venda = 0.
                    for each wf-movim no-lock:
                        find produ where recid(produ) = wf-movim.wrec
                                    no-lock no-error.
                        if not avail produ then next.
                        if produ.proipiper = 98 /* Servico */
                        then next.
                        run find-pro-promo.
                        if not na-promocao
                        then next.
                        qtd-val = qtd-val + 1.
                        total-venda = total-venda +
                                    (wf-movim.movpc * wf-movim.movqtm).
                    end.
                    if ctpromoc.campolog3 = no
                    then do:
                        qtd-val = 1.
                        run valor-prazo.
                        total-venda = total-venda-prazo.
                    end.                    
                    if ctpromoc.vendaacimade = 0
                    then do:
                        vpctvendedor = ctpromoc.pctvendedor.
                        if ctpromoc.campolog4 = no
                        then qtd-val = 1.
                        run cria-temp-valor(2, "VENDEDOR",
                         (total-venda * (vpctvendedor / 100)) * qtd-val, 0).
                        spromoc = yes.
                        total-venda-prazo = p-venda-prazo.
                    end.
                    else if ctpromoc.vendaacimade > 0
                    then do:
                        if ctpromoc.campodec2[4] > 0 and
                           ctpromoc.campodec2[5] > 0
                        then run quantidade-vendida("VENDEDOR").
                        if ctpromoc.vendaacimade <= total-venda-prazo and
                           (ctpromoc.campodec2[4] = 0 or 
                            qtd-vendida >= ctpromoc.campodec2[4]) and
                           (ctpromoc.campodec2[5] = 0 or
                            qtd-vendida <= ctpromoc.campodec2[5]) 
                        then do:
                            run cria-temp-valor(2, "VENDEDOR",
                                ctpromoc.pctvendedor, ctpromo.vendaacimade) .
                            parametro-out = tipo-venda + "=" + 
                                            string(qtd-vendida) + "|" +
                                            parametro-out.
                            spromoc = yes.
                        end.
                    end.
                end.
                if ctpromoc.valgerente > 0
                then do:
                    qtd-val = 0.
                    if ctpromoc.campolog4 = yes
                    then do:
                        for each wf-movim no-lock:
                            find produ where recid(produ) = wf-movim.wrec
                                    no-lock no-error.
                            if not avail produ then next.
                            if produ.proipiper = 98 /* Servico */
                            then next.
                            run find-pro-promo.
                            if not na-promocao
                            then next.
                            qtd-val = qtd-val + wf-movim.movqtm.
                        end.
                    end.    
                    else qtd-val = 1.
                    if ctpromoc.vendaacimade = 0
                    then do:
                        run cria-temp-valor(1, "GERENTE",
                                ctpromoc.valgerente * qtd-val, 0).
                        spromoc = yes.        
                    end.
                    ELSE if ctpromoc.vendaacimade > 0 and
                        (total-venda-prazo >= ctpromoc.vendaacimade and
                        (ctpromoc.campodec2[3] = 0 or
                         total-venda-prazo <= ctpromoc.campodec2[3]))
                    then do:
                        if ctpromoc.campodec2[4] > 0 and
                           ctpromoc.campodec2[5] > 0
                        then run quantidade-vendida("GERENTE").
                        if ctpromoc.vendaacimade <= total-venda-prazo and
                           (ctpromoc.campodec2[4] = 0 or 
                            qtd-vendida >= ctpromoc.campodec2[4]) and
                           (ctpromoc.campodec2[5] = 0 or
                            qtd-vendida <= ctpromoc.campodec2[5]) 
                        then do:
                            run cria-temp-valor(1, "GERENTE",
                                ctpromoc.valgerente * qtd-val,
                                 ctpromo.vendaacimade).
                            spromoc = yes.
                        end.
                    end.
                end.
                if ctpromoc.pctgerente > 0
                then do:
                    qtd-val = 0.
                    total-venda = 0.
                    for each wf-movim no-lock:
                        find produ where recid(produ) = wf-movim.wrec
                                    no-lock no-error.
                        if not avail produ then next.
                        if produ.proipiper = 98 /* Servico */
                        then next.
                        run find-pro-promo.
                        if not na-promocao
                        then next.
                        qtd-val = qtd-val + 1.
                        total-venda = total-venda +
                                    (wf-movim.movpc * wf-movim.movqtm).
                    end.
                    if ctpromoc.campolog3 = no
                    then do:
                        qtd-val = 1.
                        run valor-prazo.
                        total-venda = total-venda-prazo.
                    end.
                    if ctpromoc.vendaacimade = 0
                    then do:
                        vpctgerente = ctpromoc.pctgerente.
                        if ctpromoc.campolog4 = no
                        then qtd-val = 1.
                        run cria-temp-valor(2, "GERENTE",
                             (total-venda * (vpctgerente / 100)) * qtd-val,
                              0).
                        spromoc = yes. 
                        total-venda-prazo = p-venda-prazo.       
                    end.
                    ELSE if ctpromoc.vendaacimade > 0 and
                        (total-venda-prazo >= ctpromoc.vendaacimade and
                        (ctpromoc.campodec2[3] = 0 or
                         total-venda-prazo <= ctpromoc.campodec2[3]))
                    then do:
                        if ctpromoc.campodec2[4] > 0 and
                           ctpromoc.campodec2[5] > 0
                        then run quantidade-vendida("GERENTE").
                        if ctpromoc.vendaacimade <= total-venda-prazo and
                           (ctpromoc.campodec2[4] = 0 or 
                            qtd-vendida >= ctpromoc.campodec2[4]) and
                           (ctpromoc.campodec2[5] = 0 or
                            qtd-vendida <= ctpromoc.campodec2[5]) 
                        then do:
                            run cria-temp-valor(2, "GERENTE",
                                ctpromoc.pctgerente, ctpromo.vendaacimade).
                            spromoc = yes.
                        end.
                    end.
                end.
                if ctpromoc.valsupervisor > 0
                then do:
                    if ctpromoc.vendaacimade > 0
                    then do:
                        if ctpromoc.campodec2[4] > 0 and
                           ctpromoc.campodec2[5] > 0
                        then run quantidade-vendida("SUPERVISOR").
                        if ctpromoc.vendaacimade <= total-venda-prazo and
                           (ctpromoc.campodec2[4] = 0 or 
                            qtd-vendida >= ctpromoc.campodec2[4]) and
                           (ctpromoc.campodec2[5] = 0 or
                            qtd-vendida <= ctpromoc.campodec2[5]) 
                        then do:
                            run cria-temp-valor(1, "SUPERVISOR",
                                ctpromoc.valsupervisor, ctpromoc.vendaacimade).
                            spromoc = yes.
                        end.
                    end.
                end.
                if ctpromoc.pctsupervisor > 0
                then do:
                  run cria-temp-valor(2, "SUPERVISOR",
                                ctpromoc.pctsupervisor, 0).
                    spromoc = yes.
                end.
                if ctpromoc.campodec2[1] > 0
                then do:
                    qtd-val = 0.
                    if ctpromoc.vendaacimade = 0
                    then do:
                        if ctpromoc.campolog4 = yes
                        then
                        for each wf-movim no-lock:
                            find produ where recid(produ) = wf-movim.wrec
                                    no-lock no-error.
                            if not avail produ then next.
                            if produ.proipiper = 98 /* Servico */
                            then next.
                            run find-pro-promo.
                            if not na-promocao
                            then next.
                            qtd-val = qtd-val + 1.
                        end.
                        else qtd-val = 1.
                        run cria-temp-valor(1, "PROMOTOR",
                                ctpromoc.campodec2[1] * qtd-val, 0).
                        spromoc = yes.
                    end.
                    ELSE if ctpromoc.vendaacimade > 0 and
                        (total-venda-prazo >= ctpromoc.vendaacimade and
                        (ctpromoc.campodec2[3] = 0 or
                         total-venda-prazo <= ctpromoc.campodec2[3]))
                    then do:
                        if ctpromoc.campodec2[4] > 0 and
                           ctpromoc.campodec2[5] > 0
                        then run quantidade-vendida("PROMOTOR").

                        if ctpromoc.vendaacimade <= total-venda-prazo and
                           (ctpromoc.campodec2[4] = 0 or 
                            qtd-vendida >= ctpromoc.campodec2[4]) and
                           (ctpromoc.campodec2[5] = 0 or
                            qtd-vendida <= ctpromoc.campodec2[5]) 
                        then do:
                            run cria-temp-valor(1, "PROMOTOR",
                                ctpromoc.campodec2[1], ctpromoc.vendaacimade).
                            spromoc = yes.
                        end.
                    end.
                end.
                if ctpromoc.campodec2[2] > 0
                then do:
                    run cria-temp-valor(2, "PROMOTOR",
                                ctpromoc.campodec2[2], 0).
                    spromoc = yes.
                end.
                if vparam-despesa = no and spromoc
                then do:
                if ctpromoc.perguntaprodutousado = yes
                then parametro-out = parametro-out + "PRODUTO-USADO=S|".
                if ctpromoc.geradespesa = yes and
                    vacha-despesa <> ""
                then assign parametro-out = parametro-out + vacha-despesa +
                                        ctpromoc.campochar[2]
                            vacha-despesa = "".
                else if ctpromoc.geradespesa = yes
                then  parametro-out = parametro-out + "GERA-DESPESA=S|"
                        + ctpromoc.campochar[2].
                if ctpromoc.recibo = yes and
                        vacha-recibo <> ""
                then assign
                        parametro-out = parametro-out + vacha-recibo
                        vacha-recibo = "".        
                else if ctpromoc.recibo = yes
                then parametro-out = parametro-out + "EMITE-RECIBO=S|".
                end.
                if spromoc = yes
                then run cria-temp-valor(9, "PROMOCAO", 0, 0).
            end.
        end.
    end.
end procedure.
procedure p-combo:
    for each ctpromoc where ctpromoc.promocod = 54 and  
                (if vdata-teste-promo <> ?
                              then ctpromoc.dtinicio >= vdata-teste-promo
                              else ctpromoc.dtinicio <= today) and
         ctpromoc.dtfim  >= today and
         ctpromoc.linha = 0
         no-lock:
         if ctpromoc.situacao = "L"  
         then do:
            vparam-despesa = no.
            qprodu = 0.
            qbrinde = 0.
            if ctpromoc.qtdvenda > 0
            then do:
                for each wf-movim:
                    find produ where recid(produ) = wf-movim.wrec
                           no-lock no-error.
                    if not avail produ then next.
                    if produ.proipiper = 98 /* Servico */
                    then next.
                    run find-pro-promo.
                    if not na-promocao
                    then next.
                    do vi = 1 to ctpromoc.qtdvenda:
                            if vprodu[vi] = 0
                            then do:
                                vprodu[vi] = produ.procod.
                                leave.
                            end.
                    end.
                    qprodu = qprodu + wf-movim.movqtm.
                end.    
            end.
            vok = no. 
            if qprodu  > 0 /*= ctpromoc.qtdvenda*/
            then do:
                if (ctpromoc.campodec2[4] = 0 or
                   qprodu >= ctpromoc.campodec2[4]) and
                   (ctpromoc.campodec2[5] = 0 or
                    qprodu <= ctpromoc.campodec2[5])
                then do:   
                    find first ectpromoc where
                               ectpromoc.sequencia = ctpromoc.sequencia and
                               ectpromoc.etbcod > 0 and
                               ectpromoc.situacao <> "I" and
                               ectpromoc.situacao <> "E"
                               no-lock no-error.
                    if not avail ectpromoc 
                    then do:
                        find first ectpromoc where
                               ectpromoc.sequencia = ctpromoc.sequencia and
                               ectpromoc.fincod <> ? 
                               no-lock no-error.
                        if not avail ectpromoc
                        then vok = yes.
                        else do:
                            run valida-promo-plano.
                            vok = vok-promo-plano.
                        end.
                    end.
                    else do:    
                        find first ectpromoc where
                               ectpromoc.sequencia = ctpromoc.sequencia and
                               ectpromoc.etbcod = setbcod no-lock no-error.
                        if avail ectpromoc and
                            ectpromoc.situacao <> "I" and
                            ectpromoc.situacao <> "E"
                        then do:
                            find first ectpromoc where
                               ectpromoc.sequencia = ctpromoc.sequencia and
                               ectpromoc.fincod <> ? 
                                no-lock no-error.
                            if not avail ectpromoc
                            then vok = yes.
                            else do:
                                run valida-promo-plano.
                                vok = vok-promo-plano.
                            end.    
                        end.
                    end.  
                end.
            end.
            if vok = yes
            then do:
                assign
                    spromoc = no
                    parce-total = 0
                    parcela-fixada = 0
                    prazo-total = 0 .
                if ctpromoc.vendaacimade > 0  and
                    total-venda > 0
                then do:
                    if ctpromoc.campolog3 = no
                    then do:
                        parce-total = 0.
                        parcela-fixada = 0.
                        prazo-total = 0.
                        for each wf-movim no-lock:
                            find first produ where 
                                   recid(produ) = wf-movim.wrec 
                                   no-lock no-error.
                            if not avail produ then next.
                            if produ.proipiper = 98 /* Servico */
                            then next.
                            vi = 0.
                            do vi = 1 to qbrinde:
                                if vbrinde[vi] = produ.procod
                                then do:
                                    vi = 99.
                                    leave.
                                end.     
                            end.   
                            if vi = 99 then next.      
                            run find-pro-promo.
                            if not na-promocao then  next.
                            total-venda = wf-movim.movpc * wf-movim.movqtm.
                            parcela-fixada = 0.
                            run pro-parcela-fixada.
                            run valor-prazo.
                            prazo-total = prazo-total + total-venda-prazo.
                        end.
                        if prazo-total > 0
                        then total-venda-prazo = prazo-total.
                    end.
                    else do:
                        total-venda = 0.
                        for each wf-movim no-lock:
                            find first produ where recid(produ) = wf-movim.wrec
                                   no-lock no-error. 
                            if not avail produ then next.
                            if produ.proipiper = 98 /* Servico */
                            then next.
                            vi = 0.
                            do vi = 1 to qbrinde:
                                if vbrinde[vi] = produ.procod
                                then do:
                                    vi = 99.
                                    leave.
                                end.     
                            end.   
                            if vi = 99 then next.      
                            run find-pro-promo.
                            if not na-promocao then  next.
                            total-venda = total-venda
                                + (wf-movim.movpc * wf-movim.movqtm).
                        end.
                        total-venda-prazo = total-venda.
                    end.
                end.
                p-venda-prazo = total-venda-prazo.
                if ctpromoc.descontovalor > 0
                then do:
                    parametro-out = parametro-out + "COMBO-VALOR=" 
                            + string(ctpromoc.descontovalor) + "|".
                    run cria-temp-valor(3, "COMBOV",
                                ctpromoc.descontovalor, 0).
                    for each wf-movim:
                        find produ where recid(produ) = wf-movim.wrec
                           no-lock no-error.
                        if not avail produ then next.
                        if produ.proipiper = 98 /* Servico */
                        then next.
                        run find-pro-promo.
                        if not na-promocao
                        then next.
                        parametro-out = parametro-out + 
                            "COMBO-" + string(produ.procod)
                                    + "=" + string(wf-movim.movpc) + "|". 
                        wf-movim.movpc = wf-movim.movpc -
                                         ctpromoc.descontovalor.
                    end.
                end.
                else if ctpromoc.descontopercentual > 0
                then do:
                    parametro-out = parametro-out + "COMBO-PERCENTUAL=" 
                                + string(ctpromoc.descontopercentual) 
                                + "|".
                    run cria-temp-valor(3, "COMBOP",
                                ctpromoc.descontopercentual, 0).
                    for each wf-movim:
                        find produ where recid(produ) = wf-movim.wrec
                           no-lock no-error.
                        if not avail produ then next.
                        if produ.proipiper = 98 /* Servico */
                        then next.
                        run find-pro-promo.
                        if not na-promocao
                        then next.
                        parametro-out = parametro-out + 
                            "COMBO-" + string(produ.procod)
                                    + "=" + string(wf-movim.movpc) + "|". 
                        wf-movim.movpc = wf-movim.movpc -
                            (wf-movim.movpc * 
                            (ctpromoc.descontopercentual / 100)).
                    end.
                end.
            end.
        end.
    end.
end procedure.
def buffer bclase for clase.
def buffer gclase for clase.
procedure find-pro-promo:
    na-promocao = no.
    find clase where clase.clacod = produ.clacod no-lock no-error.
    find bclase where bclase.clacod = clase.clasup no-lock no-error.
    find gclase where gclase.clacod = bclase.clasup no-lock no-error.
    if not avail clase
    then.
    else do:
    find first fctpromoc where
               fctpromoc.sequencia = ctpromoc.sequencia and
               fctpromoc.procod = produ.procod and
               produ.procod > 0 and
               fctpromoc.situacao <> "I" and
               fctpromoc.situacao <> "E"
               no-lock no-error.
    if not avail fctpromoc
    then find first fctpromoc where
                    fctpromoc.sequenci = ctpromoc.sequencia and
                    fctpromoc.procod = 0 and
                    fctpromoc.clacod = produ.clacod and
                    clase.clacod > 0 and
                    fctpromoc.situacao <> "I" and
                    fctpromoc.situacao <> "E" 
                    no-lock no-error.
    if not avail fctpromoc
    then find first fctpromoc where
                    fctpromoc.sequenci = ctpromoc.sequencia and
                    fctpromoc.procod = 0 and
                    fctpromoc.clacod = clase.clasup   and
                    clase.clasup > 0 and
                    fctpromoc.situacao <> "I" and
                    fctpromoc.situacao <> "E" 
                    no-lock no-error.
    if not avail fctpromoc and
        avail bclase
    then find first fctpromoc where
                    fctpromoc.sequenci = ctpromoc.sequencia and
                    fctpromoc.procod = 0 and
                    fctpromoc.clacod = bclase.clasup and
                    fctpromoc.clacod > 0 and
                    fctpromoc.situacao <> "I" and
                    fctpromoc.situacao <> "E" 
                    no-lock no-error.
    if not avail fctpromoc and
        avail gclase
    then find first fctpromoc where
                    fctpromoc.sequenci = ctpromoc.sequencia and
                    fctpromoc.procod = 0 and
                    fctpromoc.clacod = gclase.clasup and
                    fctpromoc.clacod > 0 and
                    fctpromoc.situacao <> "I" and
                    fctpromoc.situacao <> "E" 
                     no-lock no-error.
    if not avail fctpromoc
    then find first fctpromoc where
                    fctpromoc.sequenci = ctpromoc.sequencia and
                    fctpromoc.procod = 0 and
                    fctpromoc.clacod = 0 and
                    fctpromoc.setcod = produ.catcod and
                    produ.catcod > 0  and
                    fctpromoc.situacao <> "I" and
                    fctpromoc.situacao <> "E" 
                    no-lock no-error.
    if not avail fctpromoc 
    then find first fctpromoc where
                    fctpromoc.sequenci = ctpromoc.sequencia and
                    fctpromoc.procod = 0 and
                    fctpromoc.clacod = 0 and
                    fctpromoc.setcod = 0 and
                    fctpromoc.fabcod = produ.fabcod and
                    produ.fabcod > 0
                    no-lock no-error.
    end.
    if avail fctpromoc
    then do:
        if fctpromoc.procod > 0
        then do:
        end.
        else if fctpromoc.clacod > 0
        then do:
            find first pctpromoc where 
               pctpromoc.sequencia = ctpromoc.sequencia and
               pctpromoc.procod    = produ.procod
               no-lock no-error.
        end.
        else if fctpromoc.fabcod > 0
        then do:
            find first pctpromoc where 
               pctpromoc.sequencia = ctpromoc.sequencia and
               pctpromoc.procod    = produ.procod
               no-lock no-error.
        end.
        else if fctpromoc.setcod > 0
        then do:
            find first pctpromoc where 
               pctpromoc.sequencia = ctpromoc.sequencia and
               pctpromoc.procod    = produ.procod
               no-lock no-error.
            if not avail pctpromoc
            then find first pctpromoc where 
               pctpromoc.sequencia = ctpromoc.sequencia and
               pctpromoc.procod    = 0 and
               pctpromoc.clacod = produ.clacod
               no-lock no-error.
            if not avail pctpromoc
            then find first pctpromoc where 
               pctpromoc.sequencia = ctpromoc.sequencia and
               pctpromoc.procod    = 0 and
               pctpromoc.clacod = clase.clasup
               no-lock no-error.
            if not avail pctpromoc
            then find first pctpromoc where 
               pctpromoc.sequencia = ctpromoc.sequencia and
               pctpromoc.procod    = 0 and
               pctpromoc.clacod = bclase.clasup
               no-lock no-error.
            if not avail pctpromoc
            then find first pctpromoc where 
               pctpromoc.sequencia = ctpromoc.sequencia and
               pctpromoc.procod    = 0 and
               pctpromoc.clacod = gclase.clasup
               no-lock no-error.
        end.
        if avail pctpromoc and
               (pctpromoc.situacao = "I" or
                pctpromoc.situacao = "E")
        then.
        else na-promocao = yes.
    end.
    if na-promocao and ctpromoc.sequencia = 3187 and
       produ.fabcod <> 5027
    then na-promocao = no.
    if na-promocao and ctpromoc.sequencia = 4039
      and produ.fabcod <> 5027
    then na-promocao = no.
    if na-promocao and ctpromoc.sequencia = 5966
      and produ.fabcod <> 5027
    then na-promocao = no.
    if na-promocao and ctpromoc.sequencia = 7941
      and produ.fabcod <> 5027 
        and produ.procod <> 515395
        and produ.procod <> 510244
        and produ.procod <> 510243
        and produ.procod <> 510242
        and produ.procod <> 513072
        and produ.procod <> 510241
        and produ.procod <> 513071
        and produ.procod <> 513070
        and produ.procod <> 528394
        and produ.procod <> 526729
        and produ.procod <> 527772
        and produ.procod <> 526741
        and produ.procod <> 526738
        and produ.procod <> 526733
        and produ.procod <> 526721
        and produ.procod <> 526721
        and produ.procod <> 526734
        and produ.procod <> 526741
        and produ.procod <> 526738
        and produ.procod <> 526729
        and produ.procod <> 526733
        and produ.procod <> 518937
        and produ.procod <> 524623
        and produ.procod <> 526436
        and produ.procod <> 523758
        and produ.procod <> 526421
        and produ.procod <> 526361
        and produ.procod <> 526434
        and produ.procod <> 524745
        and produ.procod <> 524727
        and produ.procod <> 524725
        and produ.procod <> 526496
        and produ.procod <> 524625
        and produ.procod <> 518620
        and produ.procod <> 524624
        and produ.procod <> 530722
        and produ.procod <> 525643
        and produ.procod <> 525643
        and produ.procod <> 530722
        and produ.procod <> 525466
        and produ.procod <> 530720
        and produ.procod <> 525468
        and produ.procod <> 525467
        and produ.procod <> 530721
        and produ.procod <> 526360
        and produ.procod <> 525646
        and produ.procod <> 524621
        and produ.procod <> 525632
        and produ.procod <> 525633
        and produ.procod <> 525636
        and produ.procod <> 525637
        and produ.procod <> 525638 
    then na-promocao = no.                          
    if na-promocao and ctpromoc.sequencia = 8636
      and produ.fabcod <> 5027
      and produ.procod <> 515395
      and produ.procod <> 510244
      and produ.procod <> 510243
      and produ.procod <> 510242
      and produ.procod <> 513072
      and produ.procod <> 510241
      and produ.procod <> 513071
      and produ.procod <> 513070
      and produ.procod <> 528394
      and produ.procod <> 526729
      and produ.procod <> 527772
      and produ.procod <> 526741
      and produ.procod <> 526738
      and produ.procod <> 526733
      and produ.procod <> 526721
      and produ.procod <> 526721
      and produ.procod <> 526734
      and produ.procod <> 526741
      and produ.procod <> 526738
      and produ.procod <> 526729
      and produ.procod <> 526733
      and produ.procod <> 518937
      and produ.procod <> 524623
      and produ.procod <> 526436
      and produ.procod <> 523758
      and produ.procod <> 526421
      and produ.procod <> 526361
      and produ.procod <> 526434
      and produ.procod <> 524745
      and produ.procod <> 524727
      and produ.procod <> 524725
      and produ.procod <> 526496
      and produ.procod <> 524625
      and produ.procod <> 518620
      and produ.procod <> 524624
      and produ.procod <> 530722
      and produ.procod <> 525643
      and produ.procod <> 525643
      and produ.procod <> 530722
      and produ.procod <> 525466
      and produ.procod <> 530720
      and produ.procod <> 525468
      and produ.procod <> 525467
      and produ.procod <> 530721
      and produ.procod <> 526360
      and produ.procod <> 525646
      and produ.procod <> 524621
      and produ.procod <> 525632
      and produ.procod <> 525633
      and produ.procod <> 525636
      and produ.procod <> 525637
      and produ.procod <> 525638
        then na-promocao = no.                          
    if na-promocao and 
        (ctpromoc.sequencia = 13764 or
         ctpromoc.sequencia = 13765 or
         ctpromoc.sequencia = 14081 or
         ctpromoc.sequencia = 14134 or
         ctpromoc.sequencia = 14061 or
         ctpromoc.sequencia = 14062 or
         ctpromoc.sequencia = 14265 )
      and produ.etccod <> 1
    then na-promocao = no.
    if na-promocao and
        (ctpromoc.sequencia = 13651 /*10320*/ )
      and produ.etccod <> 1
    then na-promocao = no. 
    if na-promocao and
        (ctpromoc.sequencia = 210045 or
         ctpromoc.sequencia = 210072 or
         ctpromoc.sequencia = 210073 or
         ctpromoc.sequencia = 210074 or
         ctpromoc.sequencia = 210075 or
         ctpromoc.sequencia = 210106 or
         ctpromoc.sequencia = 210107 or
         ctpromoc.sequencia = 210108 or
         ctpromoc.sequencia = 210109 or
         ctpromoc.sequencia = 210110  )
      and produ.etccod <> 1
    then na-promocao = no.  
  if na-promocao and
        (ctpromoc.sequencia = 9099)
      and produ.etccod <> 1
      and produ.etccod <> 3  
    then na-promocao = no.         
  if na-promocao and
        (ctpromoc.sequencia = 8872 or
         ctpromoc.sequencia = 8873 or
         ctpromoc.sequencia = 8874 or
         ctpromoc.sequencia = 8875 or
         ctpromoc.sequencia = 8876 or
         ctpromoc.sequencia = 8916 or
         ctpromoc.sequencia = 8877 or
         ctpromoc.sequencia = 8992 or
         ctpromoc.sequencia = 8993 or
         ctpromoc.sequencia = 8994 or
         ctpromoc.sequencia = 8995 or
         ctpromoc.sequencia = 8996 or
         ctpromoc.sequencia = 8997 or
         ctpromoc.sequencia = 8998 or
         ctpromoc.sequencia = 8999 or
         ctpromoc.sequencia = 9000 or
         ctpromoc.sequencia = 9001 or
         ctpromoc.sequencia = 9095 or
         ctpromoc.sequencia = 9098 or
         ctpromoc.sequencia = 9205 or
         ctpromoc.sequencia = 12301 or
         ctpromoc.sequencia = 12519 or
         ctpromoc.sequencia = 14267 or
         ctpromoc.sequencia = 15478 or
         ctpromoc.sequencia = 15880 )
      and produ.etccod <> 2
    then na-promocao = no.            
    if na-promocao and
        (ctpromoc.sequencia = 11670 or
         ctpromoc.sequencia = 11676 or
         ctpromoc.sequencia = 11677 or
         ctpromoc.sequencia = 11679 or
         ctpromoc.sequencia = 11680 or
         ctpromoc.sequencia = 12519)
         and produ.etccod <> 2
    then na-promocao = no.  
    if ctpromoc.sequencia = 14044 and
       produ.etccod <> 2 /*and
       produ.etccod <> 3*/
    then na-promocao = no.
    if ctpromoc.sequencia = 13651 and
        produ.etccod <> 1 
        then na-promocao = no.    
    if produ.pronom begins "CARTAO PRESENTE"
    THEN NA-PROMOCAO = NO.
    vok-estac = no.
    val-estac = no.
    if na-promocao
    then do:
        run valida-estacao(input "PESTACAO").
        if vok-estac and not val-estac
        then na-promocao = no.
    end.
end procedure.                
procedure find-cas-promo:
    na-casadinha = no.
    find clase where clase.clacod = produ.clacod no-lock no-error.
    find bclase where bclase.clacod = clase.clasup no-lock no-error.
    find gclase where gclase.clacod = bclase.clasup no-lock no-error.
    if not avail clase
    then.
    else do:
    find first fctpromoc where
               fctpromoc.sequenci = ctpromoc.sequencia and
               fctpromoc.tipo begins "PRODUTO" and
               fctpromoc.produtovendacasada = produ.procod
               no-lock no-error.
    if not avail fctpromoc
    then find first fctpromoc where
                    fctpromoc.sequenci = ctpromoc.sequencia and
                    fctpromoc.tipo begins "CLASSE" and
                    fctpromoc.produtovendacasada = produ.clacod 
                    no-lock no-error.
    if not avail fctpromoc
    then find first fctpromoc where
                    fctpromoc.sequenci = ctpromoc.sequencia and
                    fctpromoc.tipo begins "CLASSE" and
                    fctpromoc.produtovendacasada = clase.clasup
                    no-lock no-error.
    if not avail fctpromoc and
        avail gclase
    then find first fctpromoc where
                    fctpromoc.sequenci = ctpromoc.sequencia and
                    fctpromoc.tipo begins "CLASSE" and
                    fctpromoc.produtovendacasada = gclase.clacod 
                    no-lock no-error.
    if not avail fctpromoc and
        avail gclase
    then find first fctpromoc where
                    fctpromoc.sequenci = ctpromoc.sequencia and
                    fctpromoc.tipo begins "CLASSE" and
                    fctpromoc.produtovendacasada = gclase.clasup 
                    no-lock no-error.
    end.
    if avail fctpromoc
    then do:
        if fctpromoc.valorprodutovendacasada = 0
        then find first fctpromoc where
               fctpromoc.sequenci = ctpromoc.sequencia and
               fctpromoc.fincod = p-fincod and
               fctpromoc.produtovendacasada = produ.procod
               no-lock no-error.
        if avail fctpromoc
        then
        assign
             na-casadinha = yes
             valor-produto-venda-casada = fctpromoc.valorprodutovendacasada
             tipo-valor-venda-casada = fctpromoc.tipo.
    end.
    if na-casadinha and ctpromoc.sequencia = 3187 and
       produ.fabcod <> 5027
    then na-casadinha = no.
    if na-casadinha and ctpromoc.sequencia = 4039 and
       produ.fabcod <> 5027
    then na-casadinha = no.
    if na-casadinha and ctpromoc.sequencia = 5966 and
       produ.fabcod <> 5027
    then na-casadinha = no.
    if  na-casadinha 
        and ctpromoc.sequencia = 7941 
        and produ.fabcod <> 5027
        and produ.procod <> 515395
        and produ.procod <> 510244
        and produ.procod <> 510243
        and produ.procod <> 510242
        and produ.procod <> 513072
        and produ.procod <> 510241
        and produ.procod <> 513071
        and produ.procod <> 513070
        and produ.procod <> 528394
        and produ.procod <> 526729
        and produ.procod <> 527772
        and produ.procod <> 526741
        and produ.procod <> 526738
        and produ.procod <> 526733
        and produ.procod <> 526721
        and produ.procod <> 526721
        and produ.procod <> 526734
        and produ.procod <> 526741
        and produ.procod <> 526738
        and produ.procod <> 526729
        and produ.procod <> 526733
        and produ.procod <> 518937
        and produ.procod <> 524623
        and produ.procod <> 526436
        and produ.procod <> 523758
        and produ.procod <> 526421
        and produ.procod <> 526361
        and produ.procod <> 526434
        and produ.procod <> 524745
        and produ.procod <> 524727
        and produ.procod <> 524725
        and produ.procod <> 526496
        and produ.procod <> 524625
        and produ.procod <> 518620
        and produ.procod <> 524624
        and produ.procod <> 530722
        and produ.procod <> 525643
        and produ.procod <> 525643
        and produ.procod <> 530722
        and produ.procod <> 525466
        and produ.procod <> 530720
        and produ.procod <> 525468
        and produ.procod <> 525467
        and produ.procod <> 530721
        and produ.procod <> 526360
        and produ.procod <> 525646
        and produ.procod <> 524621
        and produ.procod <> 525632
        and produ.procod <> 525633
        and produ.procod <> 525636
        and produ.procod <> 525637
        and produ.procod <> 525638       
    then na-casadinha = no.  
    if na-casadinha 
        and ctpromoc.sequencia = 7942 
        and produ.fabcod <> 5027
        and produ.procod <> 515395
        and produ.procod <> 510244
        and produ.procod <> 510243
        and produ.procod <> 510242
        and produ.procod <> 513072
        and produ.procod <> 510241
        and produ.procod <> 513071
        and produ.procod <> 513070
        and produ.procod <> 528394
        and produ.procod <> 526729
        and produ.procod <> 527772
        and produ.procod <> 526741
        and produ.procod <> 526738
        and produ.procod <> 526733
        and produ.procod <> 526721
        and produ.procod <> 526721
        and produ.procod <> 526734
        and produ.procod <> 526741
        and produ.procod <> 526738
        and produ.procod <> 526729
        and produ.procod <> 526733
        and produ.procod <> 518937
        and produ.procod <> 524623
        and produ.procod <> 526436
        and produ.procod <> 523758
        and produ.procod <> 526421
        and produ.procod <> 526361
        and produ.procod <> 526434
        and produ.procod <> 524745
        and produ.procod <> 524727
        and produ.procod <> 524725
        and produ.procod <> 526496
        and produ.procod <> 524625
        and produ.procod <> 518620
        and produ.procod <> 524624
        and produ.procod <> 530722
        and produ.procod <> 525643
        and produ.procod <> 525643
        and produ.procod <> 530722
        and produ.procod <> 525466
        and produ.procod <> 530720
        and produ.procod <> 525468
        and produ.procod <> 525467
        and produ.procod <> 530721
        and produ.procod <> 526360
        and produ.procod <> 525646
        and produ.procod <> 524621
        and produ.procod <> 525632
        and produ.procod <> 525633
        and produ.procod <> 525636
        and produ.procod <> 525637
        and produ.procod <> 525638     
    then na-casadinha = no.  
    if na-casadinha and
        (ctpromoc.sequencia = 210045 or
         ctpromoc.sequencia = 210072 or
         ctpromoc.sequencia = 210073 or
         ctpromoc.sequencia = 210074 or
         ctpromoc.sequencia = 210075 or
         ctpromoc.sequencia = 210106 or
         ctpromoc.sequencia = 210107 or
         ctpromoc.sequencia = 210108 or
         ctpromoc.sequencia = 210109 or
         ctpromoc.sequencia = 210110 or 
         ctpromoc.sequencia = 10078 or
         ctpromoc.sequencia = 10111 or
         ctpromoc.sequencia = 10112 or
         ctpromoc.sequencia = 10113 or
         ctpromoc.sequencia = 10114 or
         ctpromoc.sequencia = 10115 or
         ctpromoc.sequencia = 10116 or
         ctpromoc.sequencia = 10129 or
         ctpromoc.sequencia = 10130 or
         ctpromoc.sequencia = 10131 or
         ctpromoc.sequencia = 10290 or
         ctpromoc.sequencia = 10291 or
         ctpromoc.sequencia = 10292 or
         ctpromoc.sequencia = 13651 or
         ctpromoc.sequencia = 13764 or
         ctpromoc.sequencia = 13765 ) 
          and
         produ.etccod <> 1 
    then na-casadinha = no.
    if na-casadinha and
        (ctpromoc.sequencia = 11670 or
         ctpromoc.sequencia = 11781 or
         ctpromoc.sequencia = 14044 or
         ctpromoc.sequencia = 12301)   
         and produ.etccod <> 1
    then na-casadinha = no. 
    vok-estac = no.
    val-estac = no.
    if na-casadinha
    then do:
        run valida-estacao(input "CESTACAO").
        if vok-estac and not val-estac
        then na-casadinha = no.
    end.
end procedure.  
procedure valor-prazo:
        def buffer vp-produ for produ.
        def buffer bwf-movim for wf-movim.
        total-venda-prazo = total-venda.
        if vbrinde-menos = no
        then
        do vi = 1 to qbrinde:
            if vbrinde[vi] = 0 or vbrinde[vi] <> produ.procod
            then leave.
            find vp-produ where vp-produ.procod = vbrinde[vi] no-lock.
            find first bwf-movim where 
                      bwf-movim.wrec = recid(vp-produ) no-error.
            if avail bwf-movim
            then do:
                total-venda-prazo = total-venda-prazo -
                               (bwf-movim.movpc * bwf-movim.movqtm).
            end.  
            vbrinde-menos = yes.  
        end.
        if total-venda-prazo > 0
        then do:
            if p-fincod > 0
            then do:
                run gercpg1.p( input p-fincod, 
                               input total-venda-prazo, 
                               input 0, 
                               input 0, 
                               output vliqui, 
                               output ventra,
                               output vparce). 
                if parcela-fixada > 0
                then vparce = parcela-fixada.
                find finan where finan.fincod = p-fincod no-lock no-error.
                if avail finan
                then assign
                         total-venda-prazo = ventra + (vparce * finan.finnpc)
                         parce-total = parce-total + vparce.
                else  total-venda-prazo = vliqui.
             end.
        end.
end procedure.
procedure prod-vinculado:
    find first ectpromoc where
                ectpromoc.sequencia = ctpromoc.sequencia and
                ectpromoc.probrinde = 0  and
                ectpromoc.fincod = ? and
                ectpromoc.campodec1[2] = produ.procod
                no-lock no-error.
    if avail ectpromoc
    then produto-vinculado = yes.
end procedure.
procedure conf-vinculado:
     le-vinculado = no.
     def buffer ectpromoc for ctpromoc.
     find estoq where estoq.etbcod = setbcod and
                      estoq.procod = produ.procod
                      no-lock.
     find first ectpromoc where
                ectpromoc.sequencia = ctpromoc.sequencia and
                ectpromoc.probrinde = 0  and
                ectpromoc.fincod = ? and
                ectpromoc.campodec1[2] > 0
                no-lock no-error.
     if not avail ectpromoc
     then find first ectpromoc where
                ectpromoc.sequencia = ctpromoc.sequencia and
                ectpromoc.probrinde = 0  and
                ectpromoc.fincod = ? and
                ectpromoc.campodec1[3] > 0
                no-lock no-error.
     if not avail ectpromoc
     then le-vinculado = yes.
     else do:
        if ectpromoc.campodec1[1] = 0
        then do:
            find estoq where estoq.etbcod = setbcod and
                             estoq.procod = produ.procod
                             no-lock no-error.
            if avail estoq
            then do:
                for each ectpromoc where
                         ectpromoc.sequencia = ctpromoc.sequencia and
                         ectpromoc.probrinde = 0  and
                         ectpromoc.fincod = ? and
                         ectpromoc.campodec1[3] > 0
                         no-lock:
                    if estoq.estvenda >= ectpromoc.campodec1[2] and
                       estoq.estvenda <= ectpromoc.campodec1[3] 
                    then le-vinculado = yes.    
                    if ctpromoc.sequencia = 1522 and
                       setbcod < 100 and 
                       produ.etccod <> 2
                   then le-vinculado = no.  
                   vok-estac = no.
                   val-estac = no.
                   if le-vinculado
                   then do:
                       run valida-estacao(input "VESTACAO").
                       if vok-estac and not val-estac
                       then le-vinculado = no.
                   end.
                end.
            end.
        end.                    
     end.
end procedure.
def var v-venda as dec.
def var v-promo as dec.
for each tt-valp where
         tt-valp.tipo   = 1  and
         tt-valp.forcod > 0 and
         tt-valp.venda  > 0 break by tt-valp.forcod:
    if tt-valp.venda > v-venda
    then do:
        v-venda = tt-valp.venda.
        v-promo = v-promo + tt-valp.valor.
    end.
    if last-of(tt-valp.forcod)
    then do:
        create tt-valpromo.
        assign
            tt-valpromo.tipo   = tt-valp.tipo
            tt-valpromo.forcod = tt-valp.forcod
            tt-valpromo.nome   = tt-valp.nome
            tt-valpromo.valor  = v-promo
            tt-valpromo.recibo = tt-valp.recibo
            tt-valpromo.despro = tt-valp.despro
            tt-valpromo.desval = tt-valp.desval.
        v-venda = 0.
        v-promo = 0.
    end.    
end.
for each tt-valp where
         tt-valp.venda  = 0 :
    find first tt-valpromo where 
               tt-valpromo.tipo   = tt-valp.tipo and
               tt-valpromo.forcod = tt-valp.forcod 
               no-error.
    if not avail tt-valpromo
    then do:           
        create tt-valpromo.
        assign
            tt-valpromo.tipo   = tt-valp.tipo
            tt-valpromo.forcod = tt-valp.forcod .
    end.
    assign        
            tt-valpromo.nome   = tt-valp.nome
            tt-valpromo.valor  = tt-valpromo.valor + tt-valp.valor
            tt-valpromo.recibo = tt-valp.recibo
            tt-valpromo.despro = tt-valp.despro
            tt-valpromo.desval = tt-valp.desval.
end.
def temp-table tt-produ
    field procod like produ.procod
    field val as dec
    field pct as dec
    index i1 procod.
procedure promo-conf-especial:
    def var qtd-casadinha as int.
    def var ite-casadinha as int.
    def var qtd-vendida as int.
    def var ite-vendida as int.
    def var vmovpc as dec.
    def var pro-casadinha as int extent 5.
    for each tt-produ: delete tt-produ. end.
    for each bctpromoc where bctpromoc.sequencia = ctpromoc.sequencia and
                             bctpromoc.produtovendacasada > 0
                             no-lock:
        if bctpromoc.tipo = "" or
           substr(bctpromoc.tipo,1,7) = "PRODUTO"
        THEN DO:
            find first tt-produ where
                       tt-produ.procod = bctpromoc.produtovendacasada
                       no-error.
            if not avail tt-produ
            then do:
                create tt-produ.
                tt-produ.procod = bctpromoc.produtovendacasada.
                if acha("PERCENTUAL",bctpromoc.tipo) <> ?
                then tt-produ.pct = bctpromoc.valorprodutovendacasada.
                else tt-produ.val = bctpromoc.valorprodutovendacasada. 
            end.           
        END.
        else do:
            for each wf-movim no-lock:
                find produ where recid(produ) = wf-movim.wrec no-lock no-error.
                if not avail produ then next.
                if produ.proipiper = 98 /* Servico */
                then next.
                find clase where clase.clacod = produ.clacod no-lock no-error.
                if not avail clase then next.    
                find bclase where bclase.clacod = clase.clasup no-lock
                    no-error.
                if not avail bclase then next.    
                if  produ.clacod <> bctpromoc.produtovendacasada and
                    clase.clasup <> bctpromoc.produtovendacasada and
                    bclase.clasup <> bctpromoc.produtovendacasada
                then next.
                find first tt-produ where
                       tt-produ.procod = produ.procod 
                       no-error.
                if not avail tt-produ
                then do:
                    create tt-produ.
                    tt-produ.procod = produ.procod.
                    if acha("PERCENTUAL",bctpromoc.tipo) <> ?
                    then tt-produ.pct = bctpromoc.valorprodutovendacasada.
                    else tt-produ.val = bctpromoc.valorprodutovendacasada. 
                end.          
            end.         
        end.
    END.
    for each wf-movim no-lock:
        find produ where recid(produ) = wf-movim.wrec no-lock no-error.
        if not avail produ then next.
        if produ.proipiper = 98 /* Servico */
        then next.
        find first tt-produ where tt-produ.procod = produ.procod no-error.
        if avail tt-produ
        then assign
                qtd-casadinha = qtd-casadinha + wf-movim.movqtm
                ite-casadinha = ite-casadinha + 1.
    end.
    def var vpct as dec decimals 0.
    spromoc = no.
    if qtd-casadinha >= 5
    then.
    else do:
    if ite-casadinha = 1
    then do:
            if valt-movpc = yes and
                qtd-casadinha >= 2 
            then do:
                for each wf-movim no-lock:
                    find produ where 
                            recid(produ) = wf-movim.wrec no-lock no-error.
                    if not avail produ then next.
                    if produ.proipiper = 98 /* Servico */
                    then next.
                    find first tt-produ where 
                    tt-produ.procod = produ.procod no-error.
                    if avail tt-produ
                    then do:
                        if qtd-casadinha = 4
                        then vpct = tt-produ.pct / 2.
                        else vpct = tt-produ.pct / wf-movim.movqtm.
                        if tt-produ.val > 0
                        then wf-movim.movpc = wf-movim.movpc -
                                (tt-produ.val / wf-movim.movqtm).
                        else wf-movim.movpc = wf-movim.movpc - 
                              (wf-movim.movpc * (vpct / 100 )).

                        if avail ctpromoc
                        then                             /* helio 09032022 - [ORQUESTRA 243179 - ESCOPO ADICIONAL] Sele��o de moeda a vista na Pr�-Venda  */ 
                            xx = promocod(ctpromoc.sequencia).
                              
                        spromoc = yes.
                    end.
                end.
            end.
    end. 
    else if ite-casadinha = 2   
    then do:
        if qtd-casadinha = 2
        then do:
            if valt-movpc = yes
            then do:
                vmovpc = 0.
                for each wf-movim no-lock:
                    find produ where 
                        recid(produ) = wf-movim.wrec no-lock no-error.
                    if not avail produ then next.
                    if produ.proipiper = 98 /* Servico */
                    then next.
                    find first tt-produ where 
                    tt-produ.procod = produ.procod no-error.
                    if avail tt-produ
                    then do:
                        if vmovpc = 0 or
                           wf-movim.movpc <= vmovpc
                        then do:
                            vmovpc = wf-movim.movpc.
                            pro-casadinha[1] = produ.procod.
                        end.    
                    end.
                end.
                for each wf-movim no-lock:
                    find produ where 
                        recid(produ) = wf-movim.wrec no-lock no-error.
                    if not avail produ then next.
                    if produ.proipiper = 98 /* Servico */
                    then next.
                    find first tt-produ where 
                    tt-produ.procod = produ.procod no-error.
                    if avail tt-produ and
                        pro-casadinha[1] = produ.procod
                    then do:
                        if tt-produ.val > 0
                        then wf-movim.movpc = wf-movim.movpc -
                                (tt-produ.val / wf-movim.movqtm).
                        else do:
                            vpct = tt-produ.pct / wf-movim.movqtm.
                            wf-movim.movpc = wf-movim.movpc - 
                              (wf-movim.movpc * (vpct / 100)).
                        end.
                        if avail ctpromoc
                        then                             /* helio 09032022 - [ORQUESTRA 243179 - ESCOPO ADICIONAL] Sele��o de moeda a vista na Pr�-Venda  */ 
                            xx = promocod(ctpromoc.sequencia).

                        spromoc = yes.
                    end.
                end.
            end.
        end.
        else if qtd-casadinha = 3
        then do:
            if valt-movpc = yes
            then do:
                for each wf-movim no-lock
                    break by wf-movim.movqtm:
                    find produ where recid(produ) = wf-movim.wrec
                            no-lock no-error.
                    if not avail produ then next.
                    if produ.proipiper = 98 /* Servico */
                    then next.
                    find first tt-produ where 
                    tt-produ.procod = produ.procod no-error.
                    if avail tt-produ 
                    then do:
                        if vmovpc = 0 or
                           wf-movim.movpc <= vmovpc
                        then do:
                            vmovpc = wf-movim.movpc.
                            pro-casadinha[1] = produ.procod.
                        end.    
                    end.
                end.
                for each wf-movim no-lock:
                    find produ where 
                        recid(produ) = wf-movim.wrec no-lock no-error.
                    if not avail produ then next.
                    if produ.proipiper = 98 /* Servico */
                    then next.
                    find first tt-produ where 
                    tt-produ.procod = produ.procod no-error.
                    if avail tt-produ and
                        pro-casadinha[1] = produ.procod
                    then do:
                        if tt-produ.val > 0
                        then wf-movim.movpc = wf-movim.movpc -
                                (tt-produ.val / wf-movim.movqtm).
                        else wf-movim.movpc = wf-movim.movpc - 
                              (wf-movim.movpc *     
                               ((tt-produ.pct / wf-movim.movqtm) / 100)).

                        if avail ctpromoc
                        then                             /* helio 09032022 - [ORQUESTRA 243179 - ESCOPO ADICIONAL] Sele��o de moeda a vista na Pr�-Venda  */ 
                            xx = promocod(ctpromoc.sequencia).
                               
                        spromoc = yes.
                    end.
                end.
            end.
        end.
        else if qtd-casadinha = 4
        then do:
            if valt-movpc = yes
            then do:
                vmovpc = 0.
                for each wf-movim no-lock:
                    find produ where 
                        recid(produ) = wf-movim.wrec no-lock no-error.
                    if not avail produ then next.
                    if produ.proipiper = 98 /* Servico */
                    then next.
                    find first tt-produ where 
                    tt-produ.procod = produ.procod no-error.
                    if avail tt-produ 
                    then do:
                        if vmovpc = 0 or
                            wf-movim.movpc <= vmovpc
                        then do:
                            vmovpc = wf-movim.movpc.
                            pro-casadinha[1] = produ.procod.
                        end.    
                    end.
                end.
                vmovpc = 0.
                for each wf-movim no-lock:
                    find produ where 
                        recid(produ) = wf-movim.wrec no-lock no-error.
                    if not avail produ then next.
                    if produ.proipiper = 98 /* Servico */
                    then next.
                    find first tt-produ where 
                    tt-produ.procod = produ.procod no-error.
                    if avail tt-produ 
                    then do:
                        if (vmovpc = 0 or
                            wf-movim.movpc <= vmovpc) and
                            pro-casadinha[1] <> produ.procod
                        then do:
                            vmovpc = wf-movim.movpc.
                            pro-casadinha[2] = produ.procod.
                        end.    
                    end.
                end.
                for each wf-movim no-lock
                    break by wf-movim.movpc:
                    find produ where 
                        recid(produ) = wf-movim.wrec no-lock no-error.
                    if not avail produ then next.
                    if produ.proipiper = 98 /* Servico */
                    then next.
                    find first tt-produ where 
                    tt-produ.procod = produ.procod no-error.
                    vpct = 0.
                    if avail tt-produ and
                       (pro-casadinha[1] = produ.procod or
                        pro-casadinha[2] = produ.procod)
                    then do:
                        if tt-produ.val > 0
                        then wf-movim.movpc = wf-movim.movpc -
                                (tt-produ.val / wf-movim.movqtm).
                        else do:
                            if wf-movim.movqtm = 3  and
                                pro-casadinha[1] = produ.procod
                            then do:
                                vpct = 33.
                                pro-casadinha[1] = 0.
                            end.
                            else
                            if wf-movim.movqtm = 3  and
                                pro-casadinha[2] = produ.procod
                            then do:
                                vpct = 17.
                                pro-casadinha[2] = 0.
                            end.
                            else
                            if wf-movim.movqtm = 2  and
                                pro-casadinha[1] = produ.procod
                            then do:
                                vpct = 50 / wf-movim.movqtm.
                                pro-casadinha[1] = 0.
                            end.
                            else if wf-movim.movqtm = 2  and
                                pro-casadinha[2] = produ.procod
                            then do:
                                vpct = 50 / wf-movim.movqtm.
                                pro-casadinha[2] = 0.
                            end.
                            else vpct = tt-produ.pct / wf-movim.movqtm.
                            
                            if vpct > 0
                            then do:
                                wf-movim.movpc = wf-movim.movpc - 
                              (wf-movim.movpc * (vpct / 100)).
                                spromoc = yes.
                                
                                if avail ctpromoc
                                then                             /* helio 09032022 - [ORQUESTRA 243179 - ESCOPO ADICIONAL] Sele��o de moeda a vista na Pr�-Venda  */ 
                            xx = promocod(ctpromoc.sequencia).
                                
                            end.
                        end.
                    end.
                end.
            end.
        end.
    end.
    else if ite-casadinha = 3
    then do:
        if qtd-casadinha = 3
        then do:
            if valt-movpc = yes
            then do:
                vmovpc = 0.
                for each wf-movim no-lock:
                    find produ where 
                        recid(produ) = wf-movim.wrec no-lock no-error.
                    if not avail produ then next.
                    if produ.proipiper = 98 /* Servico */
                    then next.
                    find first tt-produ where 
                    tt-produ.procod = produ.procod no-error.
                    if avail tt-produ 
                    then do:
                        if vmovpc = 0 or
                           wf-movim.movpc  <= vmovpc
                        then do:
                            vmovpc = wf-movim.movpc.
                            pro-casadinha[1] = produ.procod.
                        end.    
                    end.
                end.
                for each wf-movim no-lock:
                    find produ where 
                        recid(produ) = wf-movim.wrec no-lock no-error.
                    if not avail produ then next.
                    if produ.proipiper = 98 /* Servico */
                    then next.
                    find first tt-produ where 
                    tt-produ.procod = produ.procod no-error.
                    if avail tt-produ and
                       pro-casadinha[1] = produ.procod
                    then do:
                        if tt-produ.val > 0
                        then wf-movim.movpc = wf-movim.movpc -
                                (tt-produ.val / wf-movim.movqtm).
                        else wf-movim.movpc = wf-movim.movpc - 
                              (wf-movim.movpc *     
                               ((tt-produ.pct / wf-movim.movqtm) / 100)).
                        spromoc = yes.
                        if avail ctpromoc
                        then                             /* helio 09032022 - [ORQUESTRA 243179 - ESCOPO ADICIONAL] Sele��o de moeda a vista na Pr�-Venda  */ 
                            xx = promocod(ctpromoc.sequencia).
                        
                    end.
                end.
            end.
        end.
        else if qtd-casadinha = 4
        then do:
            if valt-movpc = yes
            then do:
                vmovpc = 0.
                for each wf-movim no-lock:
                    find produ where 
                        recid(produ) = wf-movim.wrec no-lock no-error.
                    if not avail produ then next.
                    if produ.proipiper = 98 /* Servico */
                    then next.
                    find first tt-produ where 
                    tt-produ.procod = produ.procod no-error.
                    if avail tt-produ 
                    then do:
                        if vmovpc = 0 or
                           wf-movim.movpc <= vmovpc
                        then do:
                            vmovpc = wf-movim.movpc.
                            pro-casadinha[1] = produ.procod.
                        end.    
                    end.
                end.
                vmovpc = 0.
                for each wf-movim no-lock:
                    find produ where 
                        recid(produ) = wf-movim.wrec no-lock no-error.
                    if not avail produ then next.
                    if produ.proipiper = 98 /* Servico */
                    then next.
                    find first tt-produ where 
                    tt-produ.procod = produ.procod no-error.
                    if avail tt-produ 
                    then do:
                        if (vmovpc = 0 or
                           wf-movim.movpc <= vmovpc) and
                           pro-casadinha[1] <> produ.procod
                        then do:
                            vmovpc = wf-movim.movpc.
                            pro-casadinha[2] = produ.procod.
                        end.    
                    end.
                end.
                vmovpc = 0.
                for each wf-movim no-lock:
                    find produ where 
                        recid(produ) = wf-movim.wrec no-lock no-error.
                    if not avail produ then next.
                    if produ.proipiper = 98 /* Servico */
                    then next.
                    find first tt-produ where 
                    tt-produ.procod = produ.procod no-error.
                    if avail tt-produ and
                        (pro-casadinha[1] = produ.procod or
                         pro-casadinha[2] = produ.procod)
                    then do:
                        if tt-produ.val > 0
                        then wf-movim.movpc = wf-movim.movpc -
                                (tt-produ.val / wf-movim.movqtm).
                        else wf-movim.movpc = wf-movim.movpc - 
                              (wf-movim.movpc *     
                               ((tt-produ.pct / wf-movim.movqtm) / 100)).

                        if avail ctpromoc
                        then                             /* helio 09032022 - [ORQUESTRA 243179 - ESCOPO ADICIONAL] Sele��o de moeda a vista na Pr�-Venda  */ 
                            xx = promocod(ctpromoc.sequencia).
                               
                        spromoc = yes.
                    end.
                end.
            end.
        end.
    end.
    else if ite-casadinha = 4
    then do:
        if qtd-casadinha = 4
        then do:
            if valt-movpc = yes
            then do:
                vmovpc = 0.
                for each wf-movim no-lock:
                    find produ where 
                        recid(produ) = wf-movim.wrec no-lock no-error.
                    if not avail produ then next.
                    if produ.proipiper = 98 /* Servico */
                    then next.
                    find first tt-produ where 
                    tt-produ.procod = produ.procod no-error.
                    if avail tt-produ 
                    then do:
                        if vmovpc = 0 or
                           wf-movim.movpc <= vmovpc
                        then do:
                            vmovpc = wf-movim.movpc.
                            pro-casadinha[1] = produ.procod.
                        end.    
                    end.
                end.
                vmovpc = 0.
                for each wf-movim no-lock:
                    find produ where 
                        recid(produ) = wf-movim.wrec no-lock no-error.
                    if not avail produ then next.
                    if produ.proipiper = 98 /* Servico */
                    then next.
                    find first tt-produ where 
                    tt-produ.procod = produ.procod no-error.
                    if avail tt-produ and
                        pro-casadinha[1] <> produ.procod
                    then do:
                        if vmovpc = 0 or
                           wf-movim.movpc <= vmovpc
                        then do:
                            vmovpc = wf-movim.movpc.
                            pro-casadinha[2] = produ.procod.
                        end.    
                    end.
                end.
                for each wf-movim no-lock:
                    find produ where 
                        recid(produ) = wf-movim.wrec no-lock no-error.
                    if not avail produ then next.
                    if produ.proipiper = 98 /* Servico */
                    then next.
                    find first tt-produ where 
                    tt-produ.procod = produ.procod no-error.
                    if avail tt-produ and
                        (pro-casadinha[1] = produ.procod or
                         pro-casadinha[2] = produ.procod)
                    then do:
                        if tt-produ.val > 0
                        then wf-movim.movpc = wf-movim.movpc -
                                (tt-produ.val / wf-movim.movqtm).
                        else wf-movim.movpc = wf-movim.movpc - 
                              ((wf-movim.movpc *     
                               (tt-produ.pct / 100)) / wf-movim.movqtm).

                        
                        if avail ctpromoc
                        then                             /* helio 09032022 - [ORQUESTRA 243179 - ESCOPO ADICIONAL] Sele��o de moeda a vista na Pr�-Venda  */ 
                            xx = promocod(ctpromoc.sequencia).
                               
                        spromoc = yes.
                    end.
                end.
            end.
        end.
    end.
    end. 
    if spromoc = yes
    then run cria-temp-valor(9, "PROMOCAO", 0, 0).
end procedure.             
procedure csadinha-desconto-percentual:
    def var vfator as dec.
    def var total-desconto as dec.
    def var qt-promo as int.
    total-desconto =  wf-movim.movpc * 
          ((pctpromoc.valorprodutovendacasada / 100) / 
                wf-movim.movqtm).
    qt-promo = int(substr(string(vpro-promo / ctpromo.qtdvenda,
                ">>>9.99"),1,4)).
    if ctpromoc.campolog4 = yes
    then total-desconto = total-desconto * qt-promo.
    vfator = total-desconto / val-tot-promo /*total-venda*/. 
    for each wf-movim :
        find produ where recid(produ) = wf-movim.wrec no-lock no-error.
        if not avail produ then next.
        if produ.proipiper = 98 /* Servico */
        then next.
        if produ.procod <> vbrinde[1]
        then next.
        na-promocao = no.
        run find-pro-promo.
        na-casadinha = no.
        run find-cas-promo.
        if na-casadinha = no
        then next.
        wf-movim.movpc  = wf-movim.movpc - total-desconto. 
        
        if avail ctpromoc
        then                             /* helio 09032022 - [ORQUESTRA 243179 - ESCOPO ADICIONAL] Sele��o de moeda a vista na Pr�-Venda  */ 
                            xx = promocod(ctpromoc.sequencia).
        
    end.
end procedure.
procedure pro-parcela-fixada:
    find estoq where estoq.etbcod = setbcod and
                     estoq.procod = produ.procod
                     no-lock no-error.
    if avail estoq and avail finan
    then do: 
    if estoq.estbaldat <> ?
    then do:
        if estoq.estmin > 0            and
           estoq.tabcod = finan.fincod and
           estprodat <> ?              and
           estbaldat <= today          and
           estprodat >= today     
        then parcela-fixada = parcela-fixada + 
                    (estoq.estmin * wf-movim.movqtm).
    end.
    else do:
        if estoq.estmin > 0            and
           estoq.tabcod = finan.fincod and
           estprodat <> ?              and
           estprodat >= today      
        then parcela-fixada = parcela-fixada +
                        (estoq.estmin * wf-movim.movqtm).
    end.   
    end.
end.     
procedure parcela-acima-de:
    if vok = yes
    then do:
        spromoc = no.
        if ctpromoc.campodec2[4] > 0  and
           total-venda > 0
        then do:
            vbrinde-menos = no.
            total-venda = 0.
            run calcula-total-venda.
            if ctpromoc.campolog3 = no
            then do:
                vbrinde-menos = yes.
                run valor-prazo.
            end.
            else total-venda-prazo = total-venda.
        end.
        if qbrinde > 0 and
           qbrinde = ctpromoc.qtdbrinde and
           vqtd-pro > 1 and
           vpro-promo >= ctpromoc.qtdvenda and
           vprodu[1] > 0 
        then do:
            do vi = 1 to qbrinde: 
                if vbrinde[vi] = 0
                then leave.
                find produ where produ.procod = vbrinde[vi] no-lock.
                find first wf-movim where 
                           wf-movim.wrec = recid(produ) no-error.
                if avail wf-movim
                then do:
                    find first pctpromoc where 
                               pctpromoc.sequencia = ctpromoc.sequencia
                           and pctpromoc.produtovendacasada = produ.procod 
                           and pctpromoc.fincod <> ?
                           no-lock no-error.
                    if not avail pctpromoc
                    then find first pctpromoc where 
                                     pctpromoc.sequencia = ctpromoc.sequencia
                                 and pctpromoc.produtovendacasada =
                                     produ.clacod 
                                 and pctpromoc.fincod <> ?
                                 no-lock no-error.
                    if avail pctpromoc
                    then do:
                        find first pctpromoc where 
                                   pctpromoc.sequencia = ctpromoc.sequencia
                               and pctpromoc.produtovendacasada =
                                    produ.procod 
                               and pctpromoc.fincod = p-fincod
                               no-lock no-error.
                        if not avail pctpromoc
                        then find first pctpromoc where 
                                       pctpromoc.sequencia = ctpromoc.sequencia
                                   and pctpromoc.produtovendacasada =
                                       produ.clacod 
                                   and pctpromoc.fincod = p-fincod
                                       no-lock no-error.
                    end.
                    else do:
                        find first pctpromoc where 
                                       pctpromoc.sequencia = ctpromoc.sequencia
                                   and pctpromoc.produtovendacasada =
                                       produ.procod 
                                       no-lock no-error.
                        if not avail pctpromoc
                        then find first pctpromoc where 
                                       pctpromoc.sequencia = ctpromoc.sequencia
                                   and pctpromoc.produtovendacasada =
                                       produ.clacod 
                                       no-lock no-error.
                    end.
                    if not avail pctpromoc
                    then do:
                        na-casadinha = no.
                        na-promocao = no.
                        run find-pro-promo.
                        do:
                               na-casadinha = no.
                               run find-cas-promo.
                        end.
                        if na-casadinha
                        then
                                find pctpromoc where
                                    recid(pctpromoc) = recid(fctpromoc)
                                    no-lock no-error.
                    end.
                    if avail pctpromoc 
                    then do:
                        if vparce >= ctpromoc.campodec2[4] and
                           vparce <= ctpromoc.campodec2[5]
                        then do:
                            if pctpromoc.campolog2 = no
                            then do:
                                if valt-movpc = yes
                                then do:
                                    if acha("PERCENTUAL",pctpromoc.tipo) = ?
                                    then do:     
                                        if qtd-item = 1
                                        then do:
                                            if vbrinde[1] <> vprodu[1]
                                            then
                                            wf-movim.movpc = 
                                                 wf-movim.movpc -       
                                           (pctpromoc.valorprodutovendacasada
                                            / vqtd-pro).
                                            else wf-movim.movpc =
                                            ((wf-movim.movpc * 
                                            (vpro-promo - qbrinde)) +
                                             (pctpromoc.valorprodutovendacasada
                                                * qbrinde)) / vpro-promo.
                                        end.
                                        else do:
                                         if pctpromoc.valorprodutovendacasada
                                            > 0
                                         then do:
                                            if vprodu[1] <> vbrinde[1]
                                            then do:
                                                
                                                if wf-movim.movqtm = 1 
                                                then wf-movim.movpc = 
                                           pctpromoc.valorprodutovendacasada.
                                                else wf-movim.movpc =
                                                     ((wf-movim.precoori *
                                             (wf-movim.movqtm -
                                             (vpro-promo - wf-movim.movqtm))) +
                                             (pctpromoc.valorprodutovendacasada
                                           * (vpro-promo - wf-movim.movqtm)))
                                              / wf-movim.movqtm.
                                            end.
                                            else wf-movim.movpc =
                                            ((wf-movim.movpc * 
                                            (vpro-promo - qbrinde)) +
                                             (pctpromoc.valorprodutovendacasada
                                                * qbrinde)) / vpro-promo.
                                         end.
                                         else 
                                           wf-movim.movpc = 
                                             wf-movim.movpc - 1.
                                         end.   
                                      end.
                                      else do:
                                        run csadinha-desconto-percentual.
                                      end.
                                      spromoc = yes.
                                    end.
                                    v-menos1 = no.
                                end.
                                else do:
                                      find first qctpromoc where 
                                       qctpromoc.sequencia = ctpromoc.sequencia
                                            and qctpromoc.produtovendacasada =
                                            produ.procod 
                                            and qctpromoc.fincod = p-fincod
                                            no-lock no-error.
                                        if avail qctpromoc and
                                        qctpromoc.valorprodutovendacasada > 0
                                        then do:
                                            if valt-movpc = yes
                                            then do:
                                             wf-movim.movpc =
                                            qctpromoc.valorprodutovendacasada.
                                            parametro-out = parametro-out +
                                            "ARREDONDA=N|PARCELA-" +
                                            string(produ.procod) + "=" +
                                      string(pctpromoc.valorprodutovendacasada)
                                            + "|".
                                            spromoc = yes.
                                            end.
                                            v-menos1 = no.
                                        end.
                                        else do:
                                            if valt-movpc = yes
                                            then do:
                                            wf-movim.movpc = 
                                            pctpromoc.valorprodutovendacasada
                                                        / finan.finfat.
                                            spromoc = yes.
                                            end.
                                            v-menos1 = no.
                                        end.
                                    end.  
                                end.                     
                            end.
                        else do:
                        end.    
                    end.          
                end. 
        end.
        if qprodu > 0  and
           qprodu >= ctpromoc.qtdvenda
        then do vi = 1 to qprodu:
                        if vprodu[vi] = 0 or ctpromoc.precosugerido = 0
                        then leave.
                        find produ where produ.procod = vprodu[vi] no-lock.
                        find first wf-movim where 
                                  wf-movim.wrec = recid(produ) no-error.
                        if avail wf-movim and
                            wf-movim.movqtm >= ctpromoc.qtdvenda
                        then do:
                            if valt-movpc = yes and
                                ctpromoc.precosugerido > 0
                            then do:
                                wf-movim.movpc = ctpromoc.precosugerido.
                                spromoc = yes.
                            end.
                            v-menos1 = no.
                        end.          
        end.
        if spromoc = yes
        then run cria-temp-valor(9, "PROMOCAO", 0, 0).
    end.
end procedure.
procedure brinde-slqtd:
    def var vb as int.
    for each wf-movim by movqtm:
        find produ where recid(produ) = wf-movim.wrec no-lock no-error.
        if not avail produ then next.
        if produ.proipiper = 98 /* Servico */
        then next.
        find first bctpromoc where
                         bctpromoc.sequenci = ctpromoc.sequencia and
                         bctpromoc.probrinde = produ.procod 
                         no-lock no-error.
        if avail bctpromoc
        then do:
            do vi = 1 to ctpromoc.qtdbrinde:
                if vbrinde[vi] = 0
                then do:
                    vbrinde[vi] = produ.procod.
                    vb = vi.
                    leave.
                end.
            end.
            run find-pro-promo.
            if na-promocao = no
            then qbrinde = qbrinde + wf-movim.movqtm.
            else do:
                if ctpromoc.qtdbrinde > qbrinde
                then do:
                    if ctpromoc.qtdbrinde >= wf-movim.movqtm + qbrinde
                    then qbrinde = qbrinde + wf-movim.movqtm.
                    else if ctpromoc.qtdbrinde < wf-movim.movqtm + qbrinde
                        then do:
                            qprodu = qprodu + (wf-movim.movqtm -
                                        (ctpromoc.qtdbrinde - qbrinde)).
                            qbrinde = qbrinde +
                                (ctpromoc.qtdbrinde - qbrinde).
                        end.
                end. 
                else qprodu = qprodu + wf-movim.movqtm.              
            end. 
            vqbrinde[vb] = qbrinde.
        end.  
        else do:
            run find-pro-promo.
            if na-promocao
            then qprodu = qprodu + wf-movim.movqtm.
        end. 
    end.
end procedure.
procedure bonus-valor:
    def var vp as int.
    def var vacha-par as char.
    def var vacha-val as char.
    if ctpromoc.perguntaprodutousado = yes
    then do:
        if acha("BONUSVALOR", parametro-out) = ?
        then parametro-out = "BONUSVALOR" + "=S|" + parametro-out.
        vacha-par = "BONUSVALORUSADO".
        if acha(vacha-par, parametro-out) = ?
        then assign
                parametro-out = vacha-par + "=S|" + parametro-out.
                parametro-out = parametro-out +
                           "PERGUNTAPRODUTOUSADO" + "=S|".
        do vp = 1 to 10:
            vacha-val = vacha-par + string(vp,"99").
            if acha(vacha-val, parametro-out) = ?
            then do:
                parametro-out = parametro-out + vacha-val + "=" + 
                            string(ctpromoc.bonusvalor) + "|".
                if ctpromoc.geradespesa = yes
                then parametro-out =  parametro-out +
                            vacha-par + "DESPESA" + string(vp,"99") + "="
                            + acha("FORNECEDOR", ctpromoc.campochar[2])
                            + "|".
                if ctpromoc.recibo = yes
                then parametro-out = parametro-out +
                            vacha-par + "RECIBO" + string(vp,"99") + "=S|".
                vparam-despesa = yes.
                spromoc = yes.
                leave.
            end.                
        end.
    end.
    else if acha("RECARGA",ctpromoc.campochar[3]) = "SIM"
    then do:
        lg-vinculado = no.
        find first bctpromoc where
                   bctpromoc.sequencia = ctpromoc.sequencia and
                   bctpromoc.campodec1[2] > 0
                   no-lock no-error.
        if avail bctpromoc
        then
        for each wf-movim:
            find produ where recid(produ) = wf-movim.wrec no-lock no-error.
            if not avail produ then next.
            if produ.proipiper = 98 /* Servico */
            then next.
            run find-pro-promo.
            if na-promocao then next.
            find first bctpromoc where
                       bctpromoc.sequencia = ctpromoc.sequencia and
                       bctpromoc.campodec1[2] = dec(produ.procod)
            no-lock no-error.
            if avail bctpromoc
            then do:
                lg-vinculado = yes.
                leave.
            end.    
        end.
        else lg-vinculado = yes.
        if lg-vinculado
        then do:
            if acha("BONUSVALOR", parametro-out) = ?
            then parametro-out = "BONUSVALOR" + "=S|" + parametro-out.
            vacha-par = "BONUSVALORRECARGA".
            if acha(vacha-par, parametro-out) = ?
            then parametro-out = vacha-par + "=S|" + parametro-out.
            do vp = 1 to 10:
                vacha-val = vacha-par + string(vp,"99").
                if acha(vacha-val, parametro-out) = ?
                then do:
                    parametro-out = parametro-out + vacha-val + "=" + 
                            string(ctpromoc.bonusvalor) + "|".
                    if ctpromoc.geradespesa = yes
                    then parametro-out =  parametro-out +
                            vacha-par + "DESPESA" + string(vp,"99") + "=" 
                            + acha("FORNECEDOR", ctpromoc.campochar[2])
                            + "|".
                            .
                    if ctpromoc.recibo = yes
                    then parametro-out = parametro-out +
                            vacha-par + "RECIBO" + string(vp,"99") + "=S|".
                    vparam-despesa = yes.
                    spromoc = yes.
                    leave.
                end.                
            end.
        end.            
    end.        
    else if acha("DINHEIRO",ctpromoc.campochar[3]) = "SIM"
    then do:
        total-venda = 0.
                        for each wf-movim no-lock,
                            first produ where 
                                   recid(produ) = wf-movim.wrec no-lock.
                            if produ.proipiper = 98 /* Servico */
                            then next.
                            
                            vi = 0.
                            do vi = 1 to qbrinde:
                                if vbrinde[vi] = produ.procod
                                then do:
                                    vi = 99.
                                    leave.
                                end.     
                            end.   
                            if vi = 99 then next.      
                            run find-pro-promo.
                            if not na-promocao then  next.
                        
                            total-venda = total-venda
                                + (wf-movim.movpc * wf-movim.movqtm).
                        end.
                        total-venda-prazo = total-venda.
        if ctpromoc.vendaacimade = 0 or
           (total-venda-prazo >= ctpromoc.vendaacimade and
           (ctpromoc.campodec2[3] = 0 or
            total-venda-prazo <= ctpromoc.campodec2[3]))
        then do:
            if acha("BONUSVALOR", parametro-out) = ?
            then parametro-out = "BONUSVALOR" + "=S|" + parametro-out.
            vacha-par = "BONUSVALORVALOR".
            if acha(vacha-par, parametro-out) = ?
            then parametro-out = vacha-par + "=S|" + parametro-out.
            do vp = 1 to 10:
                vacha-val = vacha-par + string(vp,"99").
                if acha(vacha-val, parametro-out) = ?
                then do:
                    parametro-out = parametro-out + vacha-val + "=" + 
                            string(ctpromoc.bonusvalor) + "|".
                    if ctpromoc.geradespesa = yes
                    then parametro-out =  parametro-out +
                            vacha-par + "DESPESA" + string(vp,"99") + "="
                            + acha("FORNECEDOR", ctpromoc.campochar[2])
                            + "|".
                    if ctpromoc.recibo = yes
                    then parametro-out = parametro-out +
                            vacha-par + "RECIBO" + string(vp,"99") + "=S|".
                    vparam-despesa = yes.
                    spromoc = yes.
                    leave.
                 end.
            end.
        end.
    end.
end procedure.

procedure valida-estacao:
    def input parameter p-campo as char.
    def var vsel-estac as char init "".
    def var vi as int.
    if ctpromoc.campochar2[1] <> ""
    then if acha(p-campo,ctpromoc.campochar2[1]) <> ?
         then vsel-estac = acha(p-campo,ctpromoc.campochar2[1]).
    vok-estac = no.
    val-estac = no.
    do vi = 1 to num-entries(vsel-estac,";"):
        if entry(vi,vsel-estac,";") <> ""
        then do:
            vok-estac = yes.
            if entry(vi,vsel-estac,";") = string(produ.etccod,"99")
            then do:
                val-estac = yes.
                leave.
            end.
        end.     
    end.
end procedure.

procedure valida-promo-plano:
    vok-promo-plano  = no.
    find first ectpromoc where
               ectpromoc.sequencia = ctpromoc.sequencia and
               ectpromoc.fincod <> ? 
               no-lock no-error.
    if not avail ectpromoc
    then vok-promo-plano = yes.
    else do:
        find first ectpromoc where
                   ectpromoc.sequencia = ctpromoc.sequencia and
                   ectpromoc.fincod = p-fincod no-lock no-error.
        if avail ectpromoc and
                 ectpromoc.situacao <> "I" and
                 ectpromoc.situacao <> "E"
        then do:
            if ectpromoc.vendaacimade > 0 and
                (ectpromoc.tipo = "VALORTOTAL" or
                 ectpromoc.tipo = "VALOPARCELA")
            then do:
                run calcula-total-venda.
                run valor-prazo.
                if ectpromoc.tipo = "VALORTOTAL" and
                   total-venda-prazo >= ectpromoc.vendaacimade and
                   (ectpromoc.campodec2[3] = 0 or
                    total-venda-prazo <= ectpromoc.campodec2[3])
                then vok-promo-plano = yes.
                else if ectpromoc.tipo = "VALOPARCELA" and
                        parce-total >= ectpromoc.vendaacimade and
                       (ectpromoc.campodec2[3] = 0 or
                        parce-total <= ectpromoc.campodec2[3])
                    then vok-promo-plano = yes.        
            end.
            else vok-promo-plano = yes. 
        end.
    end.
end procedure.
procedure valida-venda-acimade:
    total-venda = 0.
    run calcula-total-venda.
    if ctpromoc.vendaacimade > 0  and total-venda > 0
    then do:
        total-venda-prazo = 0.
        if ctpromoc.campolog3 = no
        then run valor-prazo.
        else total-venda-prazo = total-venda.
    end.  
    if ctpromoc.vendaacimade = 0 or
       (total-venda-prazo >= ctpromoc.vendaacimade and
       (ctpromoc.campodec2[3] = 0 or
       total-venda-prazo <= ctpromoc.campodec2[3]))
    then venda-acima-de = yes.
end procedure.
procedure valida-venda-acimade-casadinha:
    if ctpromoc.vendaacimade > 0  and total-venda > 0
    then do:
        total-venda-prazo = 0.
        if ctpromoc.campolog3 = no
        then run valor-prazo.
        else total-venda-prazo = total-venda.
    end.  
    if ctpromoc.vendaacimade = 0 or
       (total-venda-prazo >= ctpromoc.vendaacimade and
       (ctpromoc.campodec2[3] = 0 or
       total-venda-prazo <= ctpromoc.campodec2[3]))
    then venda-acima-de = yes.
end procedure.

