/* helio 15052023 - ID 25571 - Seguro prestamista */
/* helio 112022 - campanha seguro prestamista gratis */
/* helio 20012022 - [UNIFICAÇÃO ZURICH - FASE 2] NOVO CÁLCULO PARA SEGURO PRESTAMISTA MÓVEIS NA PRÉ-VENDA */

def var vsegtipo     as int.
def var vsegprest    as dec.
def var vsegvalor    as dec.
def var vseguro-nota as log init no.
def var vende-seguro as log.

{jsonprestamista.i NEW}

procedure seguroprestamista.
    def input  parameter p-nprest  as int.
    def input  parameter p-parcela as dec.
    def input  parameter p-vencod  as int.
    def output parameter p-segtipo  as int init 0.
    def output parameter p-segprest as dec init 0.
    def output parameter p-segvalor as dec init 0.

    
    def var vconfec  as log.
    def var vmoveis  as log.
    
    def var vprocod  as int.
    def var vprotot  as dec.
    def var velegivel   as log.
    def var vcampanhaGratis  as log.

    for each ttprodutos. delete ttprodutos. end.
    for each ttpedidoCartaoLebes. delete ttpedidoCartaoLebes. end.
    for each ttcartaoLebes. delete ttcartaoLebes. end.
    for each ttparcelas. delete ttparcelas. end.
    
    velegivel = no.

    if vende-seguro and
       p-nprest >= 3 /* helio 15052023 - alterado de 2 para 3 */  
    then do.
        for each wf-movim:  

            find first tt-seguroPrestamista where tt-seguroPrestamista.wrec = wf-movim.wrec no-error.
            if avail tt-seguroPrestamista
            then do:
                delete wf-movim.
                delete tt-seguroPrestamista.
                next.
            end.

            /*if wf-movim.movalicms = 98
            then next.*/

            find produ where recid(produ) = wf-movim.wrec no-lock no-error.
            if not avail produ
            then next.
        
        
            vprotot = vprotot + (wf-movim.movpc * wf-movim.movqtm).
            find produ where recid(produ) = wf-movim.wrec no-lock.
            create ttprodutos.
            ttprodutos.codigoProduto = string(produ.procod).
        
            if produ.catcod = 31
            then vmoveis = yes.
            else if produ.catcod = 41
            then vconfec = yes.
        
        end.

        /* ajustado helio 01042022. */
        if not program-name(1) matches "*simula_parcela*"  
        then run p-atu-frame.
    
        def var vvalorEntrada as dec.
        def var vseqparcelas as int.

        create ttpedidoCartaoLebes.
        ttpedidoCartaoLebes.codigoLoja = string(setbcod).
        ttpedidoCartaoLebes.valorTotal = string(vprotot).
        vvalorEntrada   = 0.

        create ttcartaoLebes.
        ttcartaoLebes.valorEntrada      = string(vvalorEntrada).
        ttcartaoLebes.valorAcrescimo    = string((p-parcela * p-nprest) - vprotot).
        ttcartaoLebes.qtdParcelas       = string(p-nprest).

        vseqparcelas = 0.
        do vseqparcelas = 1 to p-nprest.
            create ttparcelas. 
            ttparcelas.seqParcela   = string(vseqparcelas).
            ttparcelas.valorParcela = string(p-parcela) .
            ttparcelas.dataVencimento = "".
        end.    

        run wc-calculaseguroprestamista.p.

        def var vvalorTotalSeguroPrestamista as dec.
    
        find first ttsegprestpar.
    
        velegivel = ttsegprestpar.elegivel = "true".

        vcampanhaGratis = trim(ttsegprestpar.campanhaGratis) = "true".
        
        p-segtipo = 0.
        
        if velegivel
        then do:
            if vmoveis then p-segtipo = 31.
                       else p-segtipo = 41.
        
        
            if vcampanhaGratis
            then do:

                p-segtipo = 99. /* Avisar que Elegivel, mas esta em campanha Gratis */
                        
            end.
            else do:
                vprocod = int(ttsegprestpar.codigoSeguroPrestamista).
                vvalorTotalSeguroPrestamista = dec(ttsegprestpar.valorTotalSeguroPrestamista).
            
                find produ where produ.procod = vprocod no-lock.
                find first ttsaidaparcelas.
                p-segprest = dec(ttsaidaparcelas.valorSeguroRateado).       
                p-segvalor = vvalorTotalSeguroPrestamista.

                create wf-movim.
                assign
                    wf-movim.wrec   = recid(produ)
                    wf-movim.movqtm = 1
                    wf-movim.movpc = vvalorTotalSeguroPrestamista
                    wf-movim.vencod = p-vencod
                    wf-movim.movalicms = 98.
                create tt-seguroPrestamista.
                tt-seguroPrestamista.wrec = wf-movim.wrec.
                tt-seguroPrestamista.procod = produ.procod.

                /* lebes bag */
                find first ttitens where ttitens.codigoproduto = produ.procod no-error.
                if not avail ttitens
                then do:
                    find last ttitens no-error.
                    vseq = if avail ttitens then ttitens.sequencial + 1 else 1.
                    create ttitens.
                    ttitens.sequencial = vseq.
                    ttitens.codigoproduto = produ.procod.
                    ttitens.catcod = produ.catcod.
                    ttitens.quantidade = ?.
                    ttitens.quantidadeConvertida = 0. 
                end.
                ttitens.quantidadeConvertida = 1.
                    
                ttitens.valorunitario = wf-movim.movpc.
                ttitens.valorliquido  = wf-movim.movpc.
                ttitens.descontoproduto  = 0.
                ttitens.valortotalconvertida = ttitens.valorliquido * ttitens.quantidadeconvertida.        

 
            

            end.
        end.        
        
    end.
    if velegivel = no
    then do:
        /* Desfazer seguro */
        for each tt-seguroPrestamista.
            find first wf-movim where wf-movim.wrec = tt-seguroPrestamista.wrec no-error.
            if avail wf-movim
            then do:
                find produ where recid(produ) = wf-movim.wrec no-lock.
                find first ttitens where ttitens.codigoproduto = produ.procod no-error.
                if avail ttitens then delete ttitens.
                delete wf-movim.
            end.    
        end.     
    end.
    
end procedure.


procedure seguroprestamista_VERSAOANTIGA.
    def input  parameter p-nprest  as int.
    def input  parameter p-parcela as dec.
    def input  parameter p-vencod  as int.
    def output parameter p-segtipo  as int init 0.
    def output parameter p-segprest as dec init 0.
    def output parameter p-segvalor as dec init 0.

    def var vconfec  as log.
    def var vmoveis  as log.
    def var vprocod  as int.
    def var vprocod-del as int.
    def var vprotot  as dec.
    def var vct      as int.
    def var mprodseg as int extent 3 init [578790, 579359, 559911].

    if vende-seguro and
       p-nprest >= 3 and
       p-parcela >= 10
    then do.
        for each wf-movim:
            if wf-movim.movpc = 1
            then next.

            find produ where recid(produ) = wf-movim.wrec no-lock no-error.
            if not avail produ
            then next.

            if produ.catcod = 31
            then vmoveis = yes.
            else if produ.catcod = 41
            then vconfec = yes.
            vprotot = vprotot + (wf-movim.movpc * wf-movim.movqtm).
        end.
        if vmoveis and vconfec
        then.
        else do.
            vprocod-del = 0.
            if vmoveis
            then 
                if vprotot <= 300
                then assign
                        vprocod = 578790
                        vprocod-del = 579359.
                else assign
                        vprocod = 579359
                        vprocod-del = 578790.
            else vprocod  = 559911.

            if vprocod-del > 0
            then do.
                find produ where produ.procod = vprocod-del no-lock.
                find first wf-movim where wf-movim.wrec = recid(produ)
                               no-error.
                if avail wf-movim
                then delete wf-movim.
            end.

            find produ where produ.procod = vprocod no-lock.
            find first estoq of produ no-lock.

            if vmoveis then p-segtipo = 31.
                       else p-segtipo = 41.
            find first wf-movim where wf-movim.wrec = recid(produ) no-error.
            if not avail wf-movim
            then do.
                create wf-movim.
                assign
                    wf-movim.wrec   = recid(produ)
                    wf-movim.movqtm = 1
                    wf-movim.movpc = estoq.estvenda
                    wf-movim.vencod = p-vencod
                    wf-movim.movalicms = 98.
                if vmoveis
                then assign
                         p-segprest = 0
                         p-segvalor = estoq.estvenda.
                else assign
                         p-segprest = estoq.estvenda /* 2.99 */
                         p-segvalor = estoq.estvenda * p-nprest.
                wf-movim.movpc = p-segvalor.
            end.
            else
                if vmoveis
                then assign
                         p-segprest = 0
                         p-segvalor = estoq.estvenda.
                else assign
                         p-segprest = estoq.estvenda /* 2.99 */
                         p-segvalor = estoq.estvenda * p-nprest.

        end.
    end.
    else
        /* Desfazer seguro */
        do vct = 1 to 3.
            find produ where produ.procod = mprodseg[vct] no-lock.
            find first wf-movim where wf-movim.wrec = recid(produ) no-error.
            if avail wf-movim
            then delete wf-movim.
        end.

end procedure.

