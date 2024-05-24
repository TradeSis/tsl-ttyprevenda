/* helio 17062022 - (Gabriela) PreVenda - Tela de simulação de parcelas */

{jsonloteprestamista.i NEW}

def var vsegtipo     as int.
def var vsegprest    as dec.
def var vsegvalor    as dec.
def var vseguro-nota as log init no.
def var vende-seguro as log.

    
procedure seguroprestamistalote.

    def output parameter p-elegivel as log.
    def output parameter p-segvalor as dec.
        
    def var vconfec  as log.
    def var vmoveis  as log.
    
    def var vprocod  as int.
    def var vprotot  as dec.

    for each ttprodutos. delete ttprodutos. end.
    for each ttpedidoCartaoLebes. delete ttpedidoCartaoLebes. end.
    for each ttparcelas. delete ttparcelas. end.
    
    p-elegivel = no.

    do.
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
/***

        /* ajustado helio 01042022. */
        if not program-name(1) matches "*simula_parcela*"  
        then run p-atu-frame.
    
        if vmoveis then p-segtipo = 31.
                   else p-segtipo = 41.
***/        
        def var vvalorEntrada as dec.
        def var vseqparcelas as int.

        create ttpedidoCartaoLebes.
        ttpedidoCartaoLebes.codigoLoja = string(setbcod).
        ttpedidoCartaoLebes.valorTotal = string(vprotot).
        vvalorEntrada   = 0.

        for each tt-simula.
            create ttparcelas. 
            ttparcelas.fincod       = string(tt-simula.fincod). 
            ttparcelas.valorEntrada      = string(vvalorEntrada).
            ttparcelas.qtdParcelas  = string(tt-simula.finnpc).
            ttparcelas.valorParcela = string(tt-simula.par-sem-seg) .
            ttparcelas.valorAcrescimo    = string((tt-simula.finnpc * tt-simula.par-sem-seg) - vprotot).
        end.    

        run wc-calculaloteseguroprestamista.p.

        def var vvalorTotalSeguroPrestamista as dec.
    
        find first ttsegprestpar.
    
        p-elegivel = ttsegprestpar.elegivel = "true".
    
        if p-elegivel
        then do:
            vprocod = int(ttsegprestpar.codigoSeguroPrestamista).
            vvalorTotalSeguroPrestamista = dec(ttsegprestpar.valorTotalSeguroPrestamista).
            
            find produ where produ.procod = vprocod no-lock.
            find first ttsaidaparcelas.

            p-segvalor = vvalorTotalSeguroPrestamista.

                create wf-movim.
                assign
                    wf-movim.wrec   = recid(produ)
                    wf-movim.movqtm = 1
                    wf-movim.movpc = vvalorTotalSeguroPrestamista
/***                    wf-movim.vencod = p-vencod ***/
                    wf-movim.movalicms = 98.
            create tt-seguroPrestamista.
            tt-seguroPrestamista.wrec = wf-movim.wrec.
            tt-seguroPrestamista.procod = produ.procod.
        end.        
        
    end.
    
    if p-elegivel = no
    then do:
        /* Desfazer seguro */
        for each tt-seguroPrestamista.
            find first wf-movim where wf-movim.wrec = tt-seguroPrestamista.wrec no-error.
            if avail wf-movim
            then delete wf-movim.
        end.     
    end.
    
end procedure.


