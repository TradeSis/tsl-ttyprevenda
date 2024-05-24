def {1} shared work-table ttp2k_pedido01 no-undo
    field Numero_Pedido  as int format ">>>>>>>>>>9" 
    field codigo_loja    as int format ">>9"
    field Codigo_Cliente as int format ">>>>>>>>>9"
    field nome_cliente   as char format "x(20)".

def {1} shared work-table ttp2k_pedido02 no-undo
    field Numero_Pedido  as int format ">>>>>>>>>>9"  
    field Seq_Item_Pedido   as int format ">>>>>9" 
    field Codigo_Vendedor   as int format ">>>>>9" 
    field Codigo_Produto    as int format ">>>>>>>>9" 
    field Quant_Produto     as int format ">>>>9" 
    field Valor_Unitario    as dec format ">>>>>>>>9.99" 
    field desconto          as dec format ">>>>>>>>9.99"
    field Val_Total_Item    as dec format ">>>>>>>>9.99"
/*    field rec-movim        as recid */ .
def {1} shared work-table ttp2k_pedido05 no-undo
    field Numero_Pedido  as int format ">>>>>>>>>>9"  
    field Codigo_Vendedor   as int format ">>>>>9" 
    field Codigo_Produto    as int format ">>>>>>>>9" 
    field Codigo_Garantia   as int format ">>>>>>>>9" 
    field Valor_Garantia    as dec format ">>>>>>>>9.99" 
    field tempogar          as int format "999"
    field meses             as int format "999"
    field subtipo           as char format "x(1)"
    field p2k-datahoraprodu as char format "x(14)" /* 1,8 + 9,6 */
    field p2k-datahoraplano as char format "x(14)"
    field movseq            as int format "999999"
    field p2k-id_seguro     as int format "9999999999".
        
