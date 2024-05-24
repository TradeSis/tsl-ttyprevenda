/* 23012023 helio - projeto cupom desconto b2b */
def new shared var vcupomb2b as int format ">>>>>>>>>9". /* cupomb2b */

def var vpreco like movim.movpc.
def var v-numero like plani.numero.
def var v-serie  like plani.serie.
def var vfincod like finan.fincod.
def var v-qtd       as int format ">>>9".
def var v-desc      as dec format ">>9.99" .
def  var v-vendedor like func.funcod.
def var v-atr       as i.
def var v-vencod    like func.funcod.
def var vsem        like plani.platot.
def buffer bplani   for plani.
def var vbonus      like plani.numero.
def var v-preco     like movim.movpc label "Preco".
def var vplatot     like plani.platot.
def var vdep        like clien.clicod.
def var mmmm        as char format "x(26)".
def var mens        as char format "X(60)".
def var menss       as char format "x(60)".
def var vmens1      as char format "x(8)".
def var vnome       like clien.clinom.
def var vent        like plani.platot.
def var vo          as log.
def var v-recid     as recid.
def var vant        as l.
def var ger-sit     as log initial no.
def var vdown       as i.
def var vi          as int.
def var rec-plani   as recid.
def var vplacod     like plani.placod.
def var vopcod      like finan.fincod.
def var vcrecod     like finan.fincod.
def var vclicod     like clien.clicod format ">>>>>>>>>>9".
def var vcgccpf     like clien.ciccgc.
def var identificador     like clien.clinom format "x(30)".
def var vfaturar    like clien.clicod format ">>>>>>>>9".
def var vprotot     like plani.platot.
def var v-procod    like produ.procod format ">>>>>>>>>".
def var vprocod     as dec format ">>>>>>>>>>>>9".
def var vopcre      as char extent 3 format "x(20)".
def var vcont       as int.
def var v           as char.
def var vmens       as char format "x(60)".
def var vopv        as int extent 5 format ">>9".
def var vqtd        like movim.movqtm.
def var vsubtotal   like movim.movpc no-undo.
def var par-ok      as log.
def buffer bclien  for clien.
def buffer bprodu   for produ.
def buffer xclien  for clien.
def buffer cclien  for clien.
def workfile wf-clien like clien.
def var vdias1 as int.
def var i as int.
def var v-valorp like titulo.titvlcob.
def var vdevval     as dec format ">>>,>>9.99" label "Devolucao".
def var xclicod     as recid.
def new shared frame ferro.
def new shared workfile wbonus
    field bonus     like plani.numero.
def new shared workfile wfunc
    field procod    like produ.procod
    field funcod    like func.funcod.
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

def new shared temp-table ant-movim
    field wrec      as   recid
    field movqtm    like movim.movqtm
    field lipcor    like liped.lipcor
    field movalicms like movim.movalicms
    field desconto  like movim.movdes
    field movpc     like movim.movpc
    field precoori  like movim.movpc
    field vencod    like func.funcod
    field KITproagr   like produ.procod.

def var regua1      as char format "x(10)" extent 7
    initial ["Pre-Venda","Parcelas","","",
             "","",""].
form v-vendedor label "Vendedor"
        with  frame f-vende centered side-label
            1 down  overlay row 10.
form vmens no-label
     sresp no-label
      with frame f-mensagem color message row screen-lines
             overlay centered no-box.
form
    vcupomb2b           colon 15 label "Cupom"   /* 23012023 helio - projeto cupom desconto b2b */
     vfincod              colon 15 label "Plano"
     finan.finnom        no-label  
          identificador   label "Identificador" colon 15
     v-vendedor label "Vendedor" colon 15
     func.funnom no-label format "x(25)"
     with frame f-desti row 14 side-label overlay column 23 color white/cyan
            width 58.
form vprocod       label "Produto"
     produ.pronom  no-label format "x(25)"
     vpreco        label "Pr:" format ">>,>>9.99"
     vprotot       format ">>,>>9.99"
     with frame f-produ
         centered color message side-label row 4 no-box width 81.
form finan.fincod
     finan.finnom format "x(15)"
    with frame f-finan column 1 no-labels 5 down row 15
        overlay title " FINANCIAMENTOS " color yellow/blue.
def var ff as int.
def var v-row as int.
def var v-ok as log.
def var v-notas as int.
def var v-inicial as int.
def var vitem as int.

form produ.procod
     produ.pronom    format "x(37)"
     wf-movim.movqtm format ">>>9" column-label "Qtd"
     wf-movim.precoori format ">,>>9.99" column-label "Preco"
     wf-movim.movpc  format ">,>>9.99" column-label "Promo"
     vsubtotal       format ">>,>>9.99" column-label "Total"
     with frame f-produ1 overlay
            /*verus row 5 */ row 5 no-box
            7 /* fase 2 5*/ down retain 7 centered width 80.

