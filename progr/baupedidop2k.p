/* bau 092022 - helio */

{admcab.i}

def input parameter par-rec as recid.

{baudefs.i}
find first ttproposta no-error.
if not avail ttproposta
then do:
    message "Ocorreu um erro (ttproposta nor avail)".
    pause.
    return.
end.    
find first ttgetcliente no-error.

def var vservico  as char.

def var varq   as char.
def var vtipoped  as int init 1. /* #1 */
def var vforma as int.


function formatadata returns character 
    (input par-data  as date).  

    def var vdata as char. 

    if par-data <> ? 
    then vdata = string(year (par-data), "9999") +
                 string(month(par-data), "99") + 
                 string(day  (par-data), "99")  . 
    else vdata = "00000000". 

    return vdata. 

end function.


find plani where recid(plani) = par-rec no-lock.
if plani.movtdc <> 30 or            /* somente pre-vendas sao enviadas */
   plani.notped = "U" or            /* excluidas nao sao enviadas      */ 
   plani.etbcod <> setbcod          /* somente pre-vendas da filial    */ 
then return.
find clien where clien.clicod = plani.desti and clien.clicod > 1 no-lock no-error.
 
varq = "/usr/admcom/p2k/" +
       "PD" + string(plani.etbcod,"9999") +
       string(plani.numero,"99999999") + ".csi".

def var vhora as int.
def var Codigo_CPF_CNPJ as char format "x(18)".
def var Digito_CPF_CNPJ as char format "xx".

vhora = int(substr(string(Plani.horincl,"HH:MM:SS"),1,2) +
            substr(string(Plani.horincl,"HH:MM:SS"),4,2) +
            substr(string(Plani.horincl,"HH:MM:SS"),7,2)) no-error.

if avail clien 
    and plani.crecod = 2 /*#01082022*/
then do:
        def var dcpf as dec.
        def var ccpf as char.
        dcpf = dec(ttproposta.cpf) no-error.
        ccpf = string(dcpf,"99999999999").
        Codigo_CPF_CNPJ = substr(fill(" ", 11 - length(ccpf)) + ccpf, 1, 9).
        Digito_CPF_CNPJ = substr(string(dcpf,"99999999999"),10,2).
    
end.

/***
    Combo
***/
def var vtipodesc as int.

/**
def shared var vdata-teste-promo as date.

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

def shared temp-table wf-imei
    field wrec      as recid
    field imei      as char.
 
def NEW shared temp-table tt-valpromo 
    field tipo   as int
    field forcod as int
    field nome   as char
    field valor  as dec
    field recibo as log 
    field despro as char
    field desval as char.
**/

output to value(varq).


/***
    Registro tipo 01 - Capa de pedido
***/
put unformatted 
    "01"                format "xx"         /* Tipo_Reg      */
    Plani.Etbcod        format "99999"      /* Codigo_Loja   */
    plani.numero        format "9999999999" /* Numero_Pedido */
    "3"                 format "x"          /* Status_Pedido */
    0                   format "99999"      /* Num_Componente*/
    formatadata(Plani.pladat) format "xxxxxxxx"   /*  Data   */
    vhora               format "999999"     /* Hora          */
    string(if avail clien 
             and plani.crecod = 2 /*#01082022*/
            then clien.clicod else 0, "99999999999999999999")     format "x(20)"      
                                            /* Codigo_Cliente*/
    Codigo_CPF_CNPJ     format "x(18)"      /* Codigo_CPF_CNPJ  */
    Digito_CPF_CNPJ     format "xx"         /* Digito_CPF_CNPJ  */

    if avail ttgetcliente
            and plani.crecod = 2 /*#01082022*/
            then ttgetcliente.nome else " " format "x(40)"      /* Nome_Cliente */

    if avail ttgetcliente 
        and plani.crecod = 2 /*#01082022*/
        then ttgetcliente.endereco else "" format "x(30)"  /* End_Cliente */
    if avail ttgetcliente 
        and plani.crecod = 2 /*#01082022*/
        then string(ttgetcliente.numero)   else "" format "x(05)"  /* Num_End_Cliente  */
    if avail ttgetcliente 
        and plani.crecod = 2 /*#01082022*/
        then ""   else "" format "x(35)"  /* Compl_End_Cliente*/
    if avail ttgetcliente 
        and plani.crecod = 2 /*#01082022*/
        then ttgetcliente.cidade   else "" format "x(35)"   /* Cidade_End_Cliente */
    if avail ttgetcliente 
        and plani.crecod = 2 /*#01082022*/
        then ttgetcliente.estado   else "" format "xxx"     /* Estado_End_Cliente */
    
    "BRA"               format "xxx"        /* Pais_End_Cliente */
    if avail ttgetcliente 
        and plani.crecod = 2 /*#01082022*/
        then ttgetcliente.cep      else "" format "x(10)"     /* CEP_End_Cliente  */
    
    "1"                 format "x"          /* Tipo_Desconto */
    0                   format "9999999999999"  /* Desconto  */
    Plani.etbcod        format "99999"      /* Codigo_Loja_Trs  */
    formatadata(pladat) format "xxxxxxxx"   /* Data_Trs      */
    0                   format "99999"      /* Componente_Trs*/
    0                   format "999999"     /* Nsu_Trs       */
    0                   format "999999"     /* Codigo_Vendedor  */
    1 format "9" /* Tipo_CPF_CNPJ */
    vtipoped /* #1 1 */ format "9"          /* Tipo          */
    formatadata(pladat) format "xxxxxxxx"   /* Data_Vencimento  */
    0                   format "99999999"   /* Data_Cancel   */
    1                   format "9"          /* Tipo_Acrescimo*/
    0                format "9999999999999" /* Acrescimo */
    plani.numero        format "9999999999" /* Numero_PV */
    skip.
    

/***
    Registro 03
***/
vforma = if plani.crecod = 2
         then 93
         else 1.
if vforma = 93
then put unformatted
        "03"            format "xx"    /* tipo_reg */
        "00001"         format "99999" /* Numero_Pedido */
        vforma          format "99999" /* forma */
        pfincod         format "99999" /* plani */
        dec(ttproposta.valorservico) * 100   format "9999999999999"
        skip.

else do:
    if pmoedapdv <> 0
    then do:
        vforma = pmoedapdv.
         put unformatted
            "03"            format "xx"    /* tipo_reg */
            "00001"         format "99999" /* Numero_Pedido */
            vforma          format "99999" /* forma */
            0 /* forca plano 0*/ /*plani.pedcod */   format "99999" /* plani */
            dec(ttproposta.valorservico) * 100   format "9999999999999"
            skip.
    end.
end.

/***
    Registro 05 - GE / RFQ
for each tt-seg-movim no-lock.
    find first movim where movim.etbcod = plani.etbcod
                       and movim.placod = plani.placod
                       and movim.procod = tt-seg-movim.procod
                     no-lock.

    find produ of tt-seg-movim no-lock.
    find bprodu where bprodu.procod = tt-seg-movim.seg-procod no-lock.

    vtempogar = 0.
    find first produaux where produaux.procod     = produ.procod
                          and produaux.nome_campo = "TempoGar"
                        no-lock no-error.
    if avail produaux
    then vtempogar = int(produaux.valor_campo).

    put unformatted
        5                   format "99"         /* Tipo_Reg */
        Plani.etbcod        format "99999"      /* Codigo_Loja */
        Plani.notass        format "9999999999" /* Numero_Pedido */
        0                   format "99999"      /* Num_Componente */
        plani.vencod        format "999999"     /* Codigo_Vendedor */
        string(tt-seg-movim.procod,"99999999999999999999")
                            format "x(20)"      /* Codigo_Produto */
        0                   format "99999999999999" /* Cod_Autom_Prod */
        trim(bprodu.pronom) format "x(40)"      /* Descricao Completa */
        ""                  format "x(20)"      /* Numero do certificado */
        bprodu.procod       format "9999999999" /* codigo garantia */
        tt-seg-movim.movpc * 100 format "9999999999999" /* vlr.total */
        tt-seg-movim.movpc * 100 format "9999999999999" /* vlr.custo */
        vtempogar           format "999"
        tt-seg-movim.meses  format "999"
        tt-seg-movim.subtipo format "x(1)"
        0                   format "9999999999" /* cupom venda produto */
        substr(tt-seg-movim.p2k-datahoraprodu, 1, 8)
                            format "x(8)"       /* data venda produto */
        0                   format "99999"      /* seq obriga forma */
        0                   format "99999999"   /* data inicio */
        0                   format "99999999"   /* data fim */
        substr(tt-seg-movim.p2k-datahoraprodu, 9, 6)
                            format "x(6)"       /* Hora Venda */
        tt-seg-movim.p2k-datahoraplano  format "x(14)" /* WS */
        movim.movseq        format "999999"    
        tt-seg-movim.p2k-id_seguro format "9999999999" /* WS */
        skip.
end.
***/

/***
    Registro 07
for each movim where movim.etbcod = plani.etbcod
                 and movim.placod = plani.placod no-lock.

    find produ of movim no-lock. 
    if produ.pronom begins "CHEQUE PRESENTE" or 
       produ.pronom begins "CARTAO PRESENTE" or 
       produ.procod = 10000  or
       produ.procod = 559910 or
       produ.procod = 559911 or
       produ.procod = 578790 or
       produ.procod = 579359
    then.
    else next.

    if produ.procod = 559910 or
       produ.procod = 559911 or
       produ.procod = 578790 or
       produ.procod = 579359
    then assign
            vforma   = 2
            vservico = string(produ.procod).
    else assign
            vforma   = 1
            vservico = fill("0", 30).

    put unformatted 
        "07"            format "xx"
        vforma          format "99"
        plani.etbcod    format "99999"
        Plani.numero    format "9999999999" /* Numero_Pedido */
        9999            format "99999"
        plani.vencod    format "999999"     /* Codigo_Vendedor */
        vservico        format "x(30)"
        movim.movpc * 100   format "9999999999999"
        skip.
end.
***/

vservico = string(pprocod).

    put unformatted 
        "07"            format "xx"
        "09"            format "99"
        plani.etbcod    format "99999"
        Plani.numero    format "9999999999" /* Numero_Pedido */
        9999            format "99999"
        pvencod    format "999999"     /* Codigo_Vendedor */
        vservico        format "x(30)"
        dec(ttproposta.valorservico)  * 100   format "9999999999999"
        ttproposta.idPropostaLebes format "x(30)"
        
        skip.




/***
    Registro 99
***/
put unformatted 
    "99"                format "xx"         /* Tipo_Reg */
    skip.

output close.


