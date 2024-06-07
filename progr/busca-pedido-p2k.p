{admcab.i} 
def output param vCodigo_Cliente as int.

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

def SHARED temp-table tt-seg-movim
    field seg-procod  as int             /* procod do seguro */
    field procod      like movim.procod  /* procod de venda */
    field ramo        as int
    field meses       as int
    field subtipo     as char
    field movpc       like movim.movpc
    field precoori    like movim.movpc
    field p2k-datahoraprodu as char
    field p2k-id_seguro     as int
    field p2k-datahoraplano as char
    field recid-wf-movim    as recid
    index seg-movim is primary unique seg-procod procod.
def buffer bprodu for produ.
vCodigo_Cliente = 0.

def var parquivo as char.
{pedidos_p2k.i new}

    run get_file_p2k.p (setbcod,
                        output parquivo).
    if parquivo = "" or parquivo = ? then do:
        hide message no-pause.
        message "Nenhum pedido disponivel". 
        pause 2.
        return.
    end.    
    for each ttp2k_pedido01.  delete ttp2k_pedido01.  end.
 
    run importa_file_p2k.p (input parquivo,?).
 

    find first ttp2k_pedido01 no-error.
    if avail ttp2k_pedido01
    then do:
        vCodigo_Cliente = ttp2k_pedido01.Codigo_Cliente.
        delete ttp2k_pedido01.    
    end.
    for each ttp2k_pedido02 by ttp2k_pedido02.Seq_Item_Pedido desc.    
        create wf-movim.  
        /**ttp2k_pedido02.rec-movim = recid(wf-movim).**/
        find produ where produ.procod = ttp2k_pedido02.codigo_produto no-lock. 
        find estoq where estoq.etbcod = setbcod  and
                         estoq.procod = produ.procod
                no-lock.             
        wf-movim.wrec   = recid(produ). 
        wf-movim.movqtm = ttp2k_pedido02.Quant_Produto. 
        wf-movim.movpc  = ttp2k_pedido02.Valor_Unitario -  ttp2k_pedido02.desconto. 
        wf-movim.precoori   = estoq.estvenda.
        wf-movim.vencod     = ttp2k_pedido02.Codigo_Vendedor.        

        /*
        field lipcor    like liped.lipcor
        field movalicms like movim.movalicms
        field desconto  like movim.movdes
        field KITproagr   like produ.procod.
        */
        for each ttp2k_pedido05 where ttp2k_pedido05.Numero_Pedido = ttp2k_pedido02.Numero_Pedido and
                                      ttp2k_pedido05.movseq        = ttp2k_pedido02.Seq_Item_Pedido.        
            find bprodu where bprodu.procod = ttp2k_pedido05.Codigo_Garantia no-lock.

            find first tt-seg-movim
                       where tt-seg-movim.seg-procod = ttp2k_pedido05.Codigo_Garantia
                         and tt-seg-movim.procod     = ttp2k_pedido05.Codigo_Produto
                       no-error.
            if not avail tt-seg-movim
            then do:    
                create  tt-seg-movim.
                tt-seg-movim.seg-procod = ttp2k_pedido05.Codigo_Garantia.  
                tt-seg-movim.procod     = ttp2k_pedido05.Codigo_Produto.          
                /*tt-seg-movim.ramo       = */
                tt-seg-movim.meses      = ttp2k_pedido05.meses.
                tt-seg-movim.subtipo    = ttp2k_pedido05.subtipo.
                tt-seg-movim.movpc      = ttp2k_pedido05.Valor_Garantia.
                tt-seg-movim.precoori   = ttp2k_pedido05.Valor_Garantia.
                tt-seg-movim.p2k-datahoraprodu  = ttp2k_pedido05.p2k-datahoraprodu.
                tt-seg-movim.p2k-id_seguro  = ttp2k_pedido05.p2k-id_seguro.
                tt-seg-movim.p2k-datahoraplano  = ttp2k_pedido05.p2k-datahoraplano.
                /*tt-seg-movim.recid-wf-movim = ttp2k_pedido02.rec-movim. */
        
                create wf-movim. 
                wf-movim.wrec      = recid(bprodu). 
                wf-movim.movalicms = 98.
                wf-movim.movqtm = 1 .  
                wf-movim.movpc  = tt-seg-movim.movpc.
                tt-seg-movim.recid-wf-movim = recid(wf-movim).
                wf-movim.KITproagr  =   ttp2k_pedido05.Codigo_Produto.
                wf-movim.vencod     = ttp2k_pedido02.codigo_vendedor.
            end.
            else do:
                find first wf-movim where recid(wf-movim) = tt-seg-movim.recid-wf-movim no-error.
                if avail wf-movim
                then wf-movim.movqtm = wf-movim.movqtm + 1 .  
            end.
        end.     
    
    end.
    
