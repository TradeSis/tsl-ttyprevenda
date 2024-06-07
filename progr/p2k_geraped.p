/* helio 08022024 - versao 2 garantias 555859 */
/* helio 02082023 - IDENTIFICAÇÃO VENDAS COM COTAS - PROCESSO 521965*/
/* helio 23022023 Projeto Alteração Alíquota de ICMS PR - Volmir */
/* 31012023 helio - ajuste projeto cupom desconto b2b - sera enviado o cupom no tipo 8 */
/* helio 20012022 - [UNIFICAÇÃO ZURICH - FASE 2] NOVO CÁLCULO PARA SEGURO PRESTAMISTA MÓVEIS NA PRÉ-VENDA */

/* 
helio 09022022 - [ORQUESTRA 243179] Seleção de moeda a vista na Pré-Venda 
helio 20122021 mudanca aliquita icms 2022        
04.02.2020 helio.neto - 189 - cupom desconto
17/02/2020 helio.neto - 188
*/

/*  
  envio de pre-venda para P2K
  10/2017 - registro 05: garantia e RFQ
  #1 04/2018 - registro 11: entrega em outra loja
*/
{admcab.i}

def input parameter par-rec as recid.

def input param par-campanha as int.
def input param par-valorcupomdesconto as dec.

def var vx as int. /* contador */
def shared var pmoeda as char format "x(30)".
def shared var vcupomb2b as int format ">>>>>>>>>9". /* helio 31012023 - cupom b2b */
def shared var vplanocota as int. /* helio 02082023 */
def shared var p-supervisor as char.

def var vforma as int.
def var varq   as char.
def var num_pedido as int.
def var vprotot   as dec.
def var vservico  as char.
def var valiquota as dec.
def var vcst     as int.
def var vmovpc    like movim.movpc.
def var vmovdes   like movim.movdes.
def var vtempogar as int.
def var vtipogar  as char.
def var vtipoped  as int init 1. /* #1 */
def buffer bliped for liped.
def buffer bprodu for produ.


def shared temp-table tt-liped like com.liped.

def shared temp-table tt-cartpre
    field seq    as int
    field numero as int
    field valor  as dec.

def shared temp-table tt-prodesc
    field procod like produ.procod
    field preco  like movim.movpc
    field preco-ven like movim.movpc
    field desco  as   log.

def shared var etb-entrega like setbcod.
def shared var dat-entrega as date.
def shared var nome-retirada as char format "x(30)".
def shared var fone-retirada as char format "x(15)".

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

def shared temp-table tt-seguroPrestamista no-undo
    field wrec          as recid
    field procod        as int.

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

varq = "/usr/admcom/p2k/PD" + string(plani.etbcod,"9999") + /* p2k */
       string(plani.numero,"99999999") + ".csi".

def var vhora as int.
def var Codigo_CPF_CNPJ as char format "x(18)".
def var Digito_CPF_CNPJ as char format "xx".

vhora = int(substr(string(Plani.horincl,"HH:MM:SS"),1,2) +
            substr(string(Plani.horincl,"HH:MM:SS"),4,2) +
            substr(string(Plani.horincl,"HH:MM:SS"),7,2)) no-error.
find clien where clien.clicod = plani.desti no-lock.

run p2k_cpfcliente.p (input clien.clicod,
                      output Codigo_CPF_CNPJ, 
                      output Digito_CPF_CNPJ).

/***
    Combo
***/
def var vtipodesc as int.

/*** retirado de pdv-gerpla.p ***/

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

def var parametro-in-cbo  as char.
def var parametro-out-cbo as char.
def var combo-pc as dec.
def var combo-pr as dec.

if (setbcod = 189 or setbcod = 789) and plani.crecod = 2 
   /* P2K nao esta pronto para o Combo ainda */
then do.
    parametro-in-cbo = "COMBO=S|PLANO=" + string(plani.opccod) + "|"
                       + "ALTERA-PRECO=N|".
    run promo-venda.p (input parametro-in-cbo, output parametro-out-cbo).

    if acha("COMBO-VALOR",parametro-out-cbo) <> ?
    THEN combo-pr = dec(acha("COMBO-VALOR",parametro-out-cbo)).
    else if acha("COMBO-PERCENTUAL",parametro-out-cbo) <> ?
    THEN combo-pc = dec(acha("COMBO-PERCENTUAL",parametro-out-cbo)).
end.
/***
    Fim Combo
***/

output to value(varq).

/* #1 */
if etb-entrega <> 0 and
   etb-entrega <> setbcod 
then vtipoped = 2.

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
    string(if plani.desti = 1 then 0 else Plani.desti
            , "99999999999999999999")     format "x(20)"      
                                            /* Codigo_Cliente*/
/***
    string(dec(Codigo_CPF_CNPJ) , "999999999999999999")
                        format "x(18)"      /* Codigo_CPF_CNPJ  */
***/
    Codigo_CPF_CNPJ     format "x(18)"      /* Codigo_CPF_CNPJ  */
    Digito_CPF_CNPJ     format "xx"         /* Digito_CPF_CNPJ  */

   (if plani.notobs[1] <> "" or clien.clicod = 0
    then plani.notobs[1]
    else Clien.clinom)  format "x(40)"      /* Nome_Cliente */

   (if clien.clicod = 0
    then ""
    else Clien.endereco[1]) format "x(30)"  /* End_Cliente */
   (if clien.clicod = 0
    then 0
    else Clien.numero[1])   format "99999"  /* Num_End_Cliente  */
   (if clien.clicod = 0
    then ""
    else Clien.compl[1])    format "x(35)"  /* Compl_End_Cliente*/
   (if clien.clicod = 0
    then ""
    else Clien.cidade[1])  format "x(35)"   /* Cidade_End_Cliente */
   (if clien.clicod = 0
    then ""
    else Clien.ufecod[1])  format "xxx"     /* Estado_End_Cliente */
    
    "BRA"               format "xxx"        /* Pais_End_Cliente */
   (if clien.clicod = 0
    then ""
    else Clien.cep[1])   format "x(10)"     /* CEP_End_Cliente  */
    
    "1"                 format "x"          /* Tipo_Desconto */
    0                   format "9999999999999"  /* Desconto  */
    Plani.etbcod        format "99999"      /* Codigo_Loja_Trs  */
    formatadata(pladat) format "xxxxxxxx"   /* Data_Trs      */
    0                   format "99999"      /* Componente_Trs*/
    0                   format "999999"     /* Nsu_Trs       */
    0                   format "999999"     /* Codigo_Vendedor  */
    (if clien.tippes then 1 else 2) format "9" /* Tipo_CPF_CNPJ */
    vtipoped /* #1 1 */ format "9"          /* Tipo          */
    formatadata(pladat) format "xxxxxxxx"   /* Data_Vencimento  */
    0                   format "99999999"   /* Data_Cancel   */
    1                   format "9"          /* Tipo_Acrescimo*/
    0                format "9999999999999" /* Acrescimo */
    plani.numero        format "9999999999" /* Numero_PV */
    skip.
    
/***
    Registro tipo 02 - Item de pedido
***/
def var vmovalicms as dec.
def var vsittributaria as char.
def var par-imposto as dec.
def var vcha-dat-entrega-futura as char.
def var vcha-dat-ped-especial as char.
def var vcha-obs-ped-especial as char.
def buffer xestab for estab.

for each movim where movim.etbcod = plani.etbcod
                 and movim.placod = plani.placod
               no-lock.


    
    find produ of movim no-lock. 
    release wf-imei.
    find first wf-movim where wf-movim.wrec = recid(produ) no-lock no-error.    
    if avail wf-movim
    then find first wf-imei where wf-imei.wrec = wf-movim.wrec no-lock no-error.

    if produ.proipiper = 98 /* Servico */
    then next.

    vprotot = vprotot + (movim.movpc * movim.movqtm).

    if produ.pronom begins "CARTAO PRESENTE" or 
       produ.procod = 10000
    then next.

    valiquota = produ.proipiper.

    find xestab where xestab.etbcod = plani.etbcod no-lock.
   
    /* Helio 04032024 estoq.cst e estoq.aliquotaicms */
    find estoq where estoq.procod = produ.procod and estoq.etbcod = xestab.etbcod no-lock no-error.
    if not avail estoq
    then do:    
        /* Versao antiga */
        if valiquota = 99 
        then do:
            assign vsittributaria = "F"
                   vmovalicms = 0. 
        end.
        else do:
            assign vsittributaria = "T"
                   vmovalicms = valiquota. 
                   vmovalicms = 17.
        end.        
        if xestab.ufecod = "SC"  
        then do:
            valiquota = 17.
            vmovalicms = valiquota. /* helio 13/04/2022 a pedido milena */
        end.    
        if xestab.ufecod = "PR"  
        then do:
            valiquota = 19.
            vmovalicms = valiquota. /* helio 13/04/2022 a pedido milena */
        end.    
        /* fim versao antiga */
    end.
    else do:
        /* Versao nova, pega dados cst e aliquotaicms de estoq */
        valiquota   = estoq.aliquotaicms.
        vcst        = estoq.cst.
        /* Regra ate 20/03/2024
        *if vcst = 60 then do:
        *    vmovalicms      = 0.
        *    vsittributaria  = "F".
        *end.    
        *else do:
        *    vsittributaria  = "T".
        *    vmovalicms      = valiquota.
        *end.
        */
        /* helio 20032024 */
        if vcst = 0 or vcst = 20 then do:
            vsittributaria  = "T".
            vmovalicms      = valiquota.
            if vmovalicms = 0 
            then do:
                if xestab.ufecod = "PR" then vmovalicms = 19.5. 
                if xestab.ufecod = "SC" then vmovalicms = 17. 
                if xestab.ufecod = "RS" then vmovalicms = 17. 
            end. 
        end.
        else do:
           vmovalicms      = 0.
           vsittributaria  = "F".
        end.    
        
    end.
    
    find clafis where clafis.codfis = produ.codfis no-lock no-error.
    par-imposto = 0.
    if avail clafis and clafis.dec1 > 0
    then assign
            par-imposto = clafis.dec1 + clafis.dec2.
    
    assign
        vcha-dat-entrega-futura = ""
        vcha-dat-ped-especial   = ""
        vtipodesc = 1.

    find first tbprice where  
                    tbprice.etb_venda   = plani.etbcod  and
                    tbprice.nota_venda  = plani.numero  and
                    tbprice.data_venda  = plani.pladat  and
                    tbprice.char1       = "PRE-VENDA"   and
                    tbprice.etb_compra  = 0             and
                    tbprice.nota_compra = produ.procod no-lock no-error.
    
    find first bliped where bliped.etbcod = movim.etbcod
                        and bliped.pedtdc = 33
                        and bliped.pednum = plani.placod
                        and bliped.procod = movim.procod
                      no-lock no-error.
    if avail bliped
    then assign vcha-dat-entrega-futura = string(year(bliped.predtf),"9999")
                                           + string(month(bliped.predtf),"99")
                                           + string(day(bliped.predtf),"99").
/***
    find first tt-liped where tt-liped.procod = produ.procod no-lock no-error.
    if avail tt-liped
    then assign vcha-dat-entrega-futura = string(year(tt-liped.predt),"9999")
                                           + string(month(tt-liped.predt),"99")
                                           + string(day(tt-liped.predt),"99").
***/

    find first liped where liped.etbcod = movim.etbcod
                       and liped.pedtdc = 31
                       and liped.pednum = plani.placod
                       and liped.procod = movim.procod
                     no-lock no-error.
    if avail liped
    then assign vcha-dat-ped-especial = string(year(liped.predt),"9999")
                                      + string(month(liped.predt),"99")
                                      + string(day(liped.predt),"99").
    /*** 22/05/2016 ***/
    assign
        vmovpc  = movim.movpc
        vmovdes = 0.
    find first tt-prodesc where tt-prodesc.procod = movim.procod
                            and tt-prodesc.desco
               no-lock no-error.
    if avail tt-prodesc
    then
        if tt-prodesc.preco > tt-prodesc.preco-ven
        then assign
                vmovdes = tt-prodesc.preco - tt-prodesc.preco-ven
                vmovpc  = vmovpc + vmovdes.
    
    if vcupomb2b <> 0 and  vcupomb2b <> ? /* helio 06032023 - colocado teste de so quand for b2b */
    then do.
        /* helio 03022023 - nao estava enviando o desconto */
        vmovpc  = wf-movim.precoori.
        vmovdes = wf-movim.precoori - wf-movim.movpc.
    end.
    

    put unformatted
        2               format "99"         /* Tipo_Reg */
        Plani.etbcod    format "99999"      /* Codigo_Loja */
        Plani.notass    format "9999999999" /* Numero_Pedido */
        Movim.movseq    format "999999"     /* Seq_Item_Pedido */
        0               format "99999"      /* Num_Componente  */
        plani.vencod    format "999999"     /* Codigo_Vendedor */
        string(Movim.procod,"99999999999999999999")
                        format "x(20)"      /* Codigo_Produto */
        0 /**Movim.procod**/    format "99999999999999" /* Cod_Autom_Prod */
        movim.movqtm * 1000   format "99999999"   /* Quant_Produto */ 
        produ.prounven  format "xx"         /* Unid_Venda_Prod */ 
        vmovpc  * 100   format "9999999999999"  /* Valor_Unitario */ 
        movim.movqtm * vmovpc * 100
                        format "9999999999999"  /* Val_Total_Item */ 
        vtipodesc       format "9"              /* Tipo_Desconto */ 
        vmovdes * 100   format "9999999999999"  /* Desconto_Unit */ 
        plani.etbcod    format "99999"          /* Loja_Item_Entg */ 
        "00000"         format "x(5)"           /* Depos_Item_Entg */ 
        "RL"            format "xx"             /* Forma_Entrega */ 
        0               format "99999999"       /* Qtd_Item_Entfut */ 
        vsittributaria  format "x"              /* Situacao_Tributaria */ 
        vmovalicms * 100 format "99999"         /* Perc_Tributacao */ 
        produ.pronom    format "x(40)"          /* Descr_Compl_Trunc */ 
        1               format "9999999999999"  /* Qtd_Unid_Venda_Prod */ 
        trim(produ.pronom) format "x(50)"       /* Descricao Completa */ 
        ""              format "x(21)"          /* Descricao Completa */
        ""              format "x(30)"          /* Nao Serial */
        0               format "99999"          /* Seq_Obriga_Forma */
        produ.codfis    format "99999999"       /* Codigo_NCM */ 
        par-imposto * 100 format "99999"        /* Percent_Imp_Medio */ 
        ""              format "x(3)"           /* CST */
        if avail clafis then clafis.dec1 * 100 else 0
                        format "99999"          /* % federal  */
        if avail clafis then clafis.dec2 * 100 else 0
                        format "99999"          /* % estadual */
        0               format "99999"          /* % municipal */
        vcha-dat-entrega-futura  format "x(8)"  /* Entrega Futura */
        vcha-dat-ped-especial    format "x(8)"  /* Pedido Especial */
        ""              format "x(7)"           /* CEST */
        ""              format "x(10)"          /* vendedor */
        ""              format "x(10)"          /* vendedor */
        if avail wf-imei and wf-imei.imei <> ? then wf-imei.imei else ""
                        format "x(15)"          /* IMEI */
        skip.        
end.

for each tt-seg-movim no-lock.
    find first wf-movim where recid(wf-movim) = tt-seg-movim.recid-wf-movim.
    do vx = 1 to wf-movim.movqtm:
        vprotot = vprotot + tt-seg-movim.movpc.
    end.        
end.

/***
    Registro 03
***/
vforma = if plani.crecod = 2 and pmoeda = ""
         then 93
         else 1.
if vforma = 93 
then put unformatted
        "03"            format "xx"    /* tipo_reg */
        "00001"         format "99999" /* Numero_Pedido */
        vforma          format "99999" /* forma */
        plani.pedcod    format "99999" /* plani */
        vprotot * 100   format "9999999999999"
        skip.

else
if pmoeda <> ""
then do:
    
    vplano = 0.
    if pmoeda = "DINHEIRO"  then vforma = 1.
    if pmoeda = "TEFDEBITO" then vforma = 9.
    if pmoeda = "PIX"       
    then do:
        vforma = 20. /* Helio 04032024 */
        vplano = 2.
    end.    
    
    put unformatted
        "03"            format "xx"    /* tipo_reg */
        "00001"         format "99999" /* Numero_Pedido */
        vforma          format "99999" /* forma */
        vplano format "99999" /* plano */
        vprotot * 100   format "9999999999999"
        skip.

end.
/***
    Registro 05 - GE / RFQ
***/
for each tt-seg-movim no-lock.

    
    find first movim where movim.etbcod = plani.etbcod
                       and movim.placod = plani.placod
                       and movim.procod = tt-seg-movim.procod
                     no-lock.
    find first wf-movim where recid(wf-movim) = tt-seg-movim.recid-wf-movim.

    find produ of tt-seg-movim no-lock.
    find bprodu where bprodu.procod = tt-seg-movim.seg-procod no-lock.

    vtempogar = 0.
    find first produaux where produaux.procod     = produ.procod
                          and produaux.nome_campo = "TempoGar"
                        no-lock no-error.
    if avail produaux
    then vtempogar = int(produaux.valor_campo).

    do vx = 1 to wf-movim.movqtm:
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
        movim.movseq       format "999999"    
        tt-seg-movim.p2k-id_seguro format "9999999999" /* WS */
        skip.
    end.
end.

/***
    Registro 07
***/
for each movim where movim.etbcod = plani.etbcod
                 and movim.placod = plani.placod no-lock.

    find produ of movim no-lock. 
    find first tt-seguroprestamista where 
            tt-seguroprestamista.procod = produ.procod
             no-lock no-error.
             
    if produ.pronom begins "CHEQUE PRESENTE" or 
       produ.pronom begins "CARTAO PRESENTE" or 
       produ.procod = 10000  or
       avail tt-seguroprestamista
    then.
    else next.

    if avail tt-seguroprestamista
    then assign
            vforma   = 2 /* seguro prestamista */
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

/***
    Registro tipo 8 - Pedido especial
***/

/* 31012023 */ vcha-obs-ped-especial = "".

for each movim where movim.etbcod = plani.etbcod and
                     movim.placod = plani.placod no-lock.

    find produ where produ.procod = movim.procod no-lock.

    assign vcha-obs-ped-especial = "".
           
    find first liped where liped.etbcod = movim.etbcod
                       and liped.pedtdc = 31
                       and liped.pednum = plani.placod
                       and liped.procod = movim.procod
                     no-lock no-error.
        if avail liped
        then do:
            assign
                vcha-obs-ped-especial = trim(acha("OBS1",liped.lipcor)) + " "
                                       + trim(acha("OBS2",liped.lipcor)) + " "
                                       + trim(acha("OBS3",liped.protip)) + " "
                                       + trim(acha("OBS4",liped.protip)).
          /* 31012023 - retirado o envio do tipo 8 desta linha
           * put unformatted
           *     8                     format "99"     /* Tipo_Reg */ 
           *     vcha-obs-ped-especial format "x(250)" /* OBS Pedido Especial*/
           *     /***formatadata(liped.predt)***/
           *     skip.
           */
        /************************************************************
        ****    Sai após colocar a primeira linha do registro 9  ****
        ****    no arquivo pois todas serão iguais.              ****
        *************************************************************/
        leave.
    end.
end.

/* 31012023 helio - ajuste projeto cupom desconto b2b - sera enviado o cupom no tipo 8 */
/* alterado o envio do tipo 8 */
if vcha-obs-ped-especial <> "" or vcupomb2b <> 0  or p-supervisor <> ""
    /* helio 02082023 */ or vplanocota <> 0
then do:
    if vcha-obs-ped-especial = "PEDIDOESPECIAL" then vcha-obs-ped-especial = "PEDIDOESPECIAL=SIM".
     
    if vcupomb2b <> 0
    then vcha-obs-ped-especial = vcha-obs-ped-especial + 
                                 (if vcha-obs-ped-especial <> ""
                                  then "|"
                                  else "") +
                                    "CUPOM_DESCONTO=" + string(vcupomb2b).
    if vplanocota <> 0
    then vcha-obs-ped-especial = vcha-obs-ped-especial + 
                                 (if vcha-obs-ped-especial <> ""
                                  then "|"
                                  else "") +
                                    "USA_COTA_PLANO=SIM".

    if p-supervisor <> "" 
    then vcha-obs-ped-especial = vcha-obs-ped-especial + 
                                (if vcha-obs-ped-especial <> "" 
                                 then "|" 
                                 else "") + 
                                 "DESC_REGIONAL=" + p-supervisor.

    put unformatted
                8                     format "99"     /* Tipo_Reg */ 
                vcha-obs-ped-especial format "x(250)" 
                skip.

end.
/*31012023 */

/***
    Registro 09 - Combo
***/
/**** 17.01.2020 helio.neto
if setbcod = 140 or setbcod = 162 or setbcod = 189 /* Incluida FL 189 para homologacao 06-07-2018*/
then
for each movim where movim.etbcod = plani.etbcod
                 and movim.placod = plani.placod
               no-lock.
    find produ of movim no-lock.

    if produ.proipiper = 98 /* Servico */ or
       produ.pronom begins "CARTAO PRESENTE" or 
       produ.procod = 10000
    then next.

    if acha("COMBO-" + string(produ.procod), parametro-out-cbo) <> ?
    then vmovdes = movim.movpc * combo-pc / 100.
    else next.

    put unformatted
        9               format "99"         /* Tipo_Reg */
        54              format "9999999"    /* Codigo Campanha = ctpromoc */
        27              format "99"         /* Tipo Campanha */
        Movim.movseq    format "999999"     /* Seq_Item_Pedido */
        movim.movqtm * 1000   format "99999999" /* Quant_Produto */
        vmovdes * 100   format "9999999999999"  /* Desconto_Unit */
        skip.        
end.
17.01.2020 helio.neto ***/

if par-campanha <> 0
then do:
    put unformatted
        9               format "99"         /* Tipo_Reg */
        par-campanha    format "9999999"    /* Codigo Campanha = ctpromoc */
        00              format "99"         /* Tipo Campanha */
        0               format "999999"     /* Seq_Item_Pedido */
        0               format "99999999" /* Quant_Produto */
        par-valorcupomdesconto * 100   format "9999999999999"  /* Desconto_Unit */
        skip.        
end.

/***
    #1 Registro 11 - Entrega em outra loja
***/
if etb-entrega <> 0 and
   etb-entrega <> setbcod 
then
    put unformatted
        11              format "99"         /* Tipo_Reg */
        etb-entrega     format "99999"
        plani.numero    format "9999999999" /* Numero_Pedido */
        trim(fone-retirada)   format "x(11)"
        nome-retirada   format "x(19)"
        formatadata(dat-entrega) format "xxxxxxxx"
        skip.

/***
    Registro 99
***/
put unformatted 
    "99"                format "xx"         /* Tipo_Reg */
    skip.

output close.

if setbcod = 189
then unix silent scp value(varq) /usr/admcom/relat/.

