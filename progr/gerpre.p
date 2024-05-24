/*  helio 28062023 - 479847 ALTERAÇÃO NO FLUXO DE GERAÇÃO DE PEDIDOS ESPECIAIS */

{admcab.i}

{dftempWG.i}

/*********** DEFINICAO DE PARAMETROS **************/

def input  parameter par-cre    as recid.
def input  parameter par-clf    as recid.            /** recid do Ag.Com. **/
def input  parameter par-bon    like plani.platot.  /** recid opcom **/
def input  parameter par-num    like plani.numero.    /** numero da nota **/
def input  parameter vsubtot2   like titulo.titvlcob.
def input  parameter vdev       like titulo.titvlcob.
def input  parameter vdevval    like plani.vlserv.
def input  parameter par-ser    like plani.serie.   /** serie da nota **/

def output parameter par-rec    as recid.
def input  parameter vnome      like clien.clinom.
def input  parameter p-entrada  as dec.
def input  parameter vmoecod    like moeda.moecod.
def input  parameter p-infoVIVO as char.

def new global shared var scartao as char.

disable triggers for load of plani.
disable triggers for load of movim.
def var pedidoespecial as log.
def var ped-esp as log.
def var pedataespecial as date format "99/99/9999".
def shared var etb-entrega like setbcod.
def shared var dat-entrega as date.
def shared var nome-retirada as char format "x(30)".
def shared var fone-retirada as char format "x(15)".
 
def buffer zplani for plani.
def var not-ass like plani.notass.

def shared temp-table tt-liped like liped.

/** Chamado 16177 - supervisor **/
def shared temp-table tt-senauto
    field procod     like produ.procod
    field preco-ori  like movim.movpc
    field desco      as   log init no
    field senauto    as   dec format ">>>>>>>>>>"
    index i-pro is primary unique procod.
/** **/

def shared temp-table tt-prodesc
    field procod like produ.procod
    field preco  like movim.movpc
    field preco-ven like movim.movpc
    field desco  as   log.

def shared temp-table Black_Friday
    field numero as int
    field valor as dec
    field desconto as log init no
    field pctdes as dec
    . 
    
def shared temp-table tt-cartpre
    field seq    as int
    field numero as int
    field valor  as dec.

def var vnumeracao-automatica as log.
def var vcriapedidoautomatico as log.

def shared var vnumero-chp like titulo.titnum.
def shared var vvalor-chp like titulo.titvlcob.

def shared var vnumero-chpu like titulo.titnum.
def shared var vvalor-chpu like titulo.titvlcob.

def shared temp-table tt-planos-vivo
    field procod like produ.procod
    field tipviv as   int
    field codviv as   int
    field pretab as   dec 
    field prepro as   dec.

def var par-valor as char.

{setbrw.i}.

vnumeracao-automatica = no.  
run lemestre.p (input  "NUMERACAOAUTOMATICA",  
                output par-valor). 

if par-valor = "YES"  
then vnumeracao-automatica = yes. 
else vnumeracao-automatica = no.

vcriapedidoautomatico = no.
run lemestre.p (input  "CRIAPEDIDOAUTOMATICO",
                output par-valor).
if par-valor = "YES"
then vcriapedidoautomatico = yes.
else vcriapedidoautomatico = no.


/*********** DEFINICAO DE VARIAVEIS *************/
def var rec-plani as recid.
def var rec-tit as recid.
def buffer xplani for plani.
def var vpednum     like pedid.pednum.
def var vreccont as recid.
def var vgera   like contrato.contnum.
def var vtroco  as dec format ">,>>9.99".
def var vvalor  like vtroco.
def var par-certo as log.
def var vtitvlpag as dec.
def var vtotpag as dec.
def var v-letra as char.
def var v-ult   as char format "x(4)".
def var vletra  as char.
def var vdata   as date.
def var a       as int.
def var vdia    as int.
def var v-impnf as log format "Sim/Nao".
def var vltabjur  as dec.
def var vldesc  as dec.
def var zzz as int format  "999999".
def var yyy as char format "999999999".
def var vche as log initial no.
def var vacre       like plani.platot.
def var valor       like plani.platot.
def var vparcela    as int.
def var vprotot     like plani.platot.
def var vplacod     like plani.placod.
def var vnumero     like plani.numero.
def var    vperc    as decimal.
def var    vmovseq  like movim.movseq.
def var ventrada    like titulo.titvlcob no-undo.
def var v           as int format "99" no-undo.
def var vi          as int format "99" no-undo.
def var v-i         as int.
def var vbon        like plani.numero.
def var vfunc                   like func.funcod.
def var vnome1                  like clien.clinom.

/************* DEFINICAO DE WORKFILES E TEMP-TABLES **************/

def workfile wtabjur
    field jrec as recid
    field tabjur like titulo.titvljur
    field wdesc like titulo.titvldes.

def workfile tt-cheque
    field titnum like titulo.titnum
    field titpar like titulo.titpar
    field titdtven like titulo.titdtven
    field rec as recid
    field titvlcob like titulo.titvlcob
    field bancod   as i format "999" label "Banco".

def workfile wletra
    field letra like moeda.moecod
    field nome  like moeda.moenom.

def workfile wftit
    field rec as recid.

def shared workfile wbonus
    field bonus like plani.numero.

def shared workfile wfunc
    field procod like produ.procod
    field funcod like func.funcod.

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
 
def new shared workfile wf-plani    like plani.
def new shared workfile wf-titulo   like titulo.
def new shared workfile wf-contrato like contrato.
def new shared workfile wf-contnf   like contnf.

/************* DEFINICAO DE BUFFERS ***************/
def buffer bwf-titulo   for wf-titulo.
def buffer bplani       for plani.
def buffer ass-plani    for plani.
def buffer btitulo      for titulo.
def buffer ctitulo      for titulo.
def buffer cplani       for plani.
def buffer bliped       for liped.

/************* DEFINICAO DE FORMS ****************/

form
    titulo.titdtpag      colon 20 label "Data Pagamento"
    vtitvlpag            label "Total a Pagar"
    titulo.moecod        colon 20 label "Moeda"
    moeda.moenom         no-label
    vtroco               label "Troco"
    with frame fpag1 side-label row 14 color white/cyan
         overlay centered title " Pagamento " .

form
    wletra.letra
    wletra.nome   format "x(10)"
    with frame f-letra
        column 1 row 14  overlay
        5 down title  " TIPOS  "
        color white/cyan.

def var vqtdcart as int.

vnome1 = vnome.

def var vtotdesc like movim.movpc.

vtotdesc = 0.

for each tt-prodesc.
    
    vtotdesc = vtotdesc + (tt-prodesc.preco - tt-prodesc.preco-ven).
    
end.

find finan where recid(finan) = par-cre no-lock.
find clien where recid(clien) = par-clf no-lock.

if finan.fincod = 0
then find crepl where crepl.crecod = 1 no-lock.
else find crepl where crepl.crecod = 2 no-lock.

if par-bon = ?
then par-bon = 0.

def var vvaltot as dec.
def var vperchpven as dec format ">>9.99".

vvaltot = 0.
vperchpven = 0.


for each wf-plani:
    delete wf-plani.
end.

    do on error undo:
        create wf-plani.
        assign
            wf-plani.placod   = int(string("211") + string(par-num,"9999999"))
            wf-plani.etbcod   = estab.etbcod
            wf-plani.numero   = par-num
            wf-plani.cxacod   = scxacod
            wf-plani.emite    = estab.etbcod
            wf-plani.pedcod   = vfunc
            wf-plani.vlserv   = vdevval
            wf-plani.descprod = par-bon
            wf-plani.serie    = par-ser
            wf-plani.movtdc   = 30
            wf-plani.desti    = clien.clicod
            wf-plani.pladat   = today
            wf-plani.horincl  = time
            wf-plani.crecod   = crepl.crecod
            wf-plani.notsit   = no
            wf-plani.datexp   = today
            wf-plani.notobs[1] = 
                if scartao <> ""
                then "CARTAO-LEBES=" + scartao + "|" + vnome
                else vnome
            wf-plani.notobs[2] = string(vtotdesc)
            wf-plani.notobs[3] = p-infoVIVO
            wf-plani.ufemi    = vmoecod
            wf-plani.opccod   = finan.fincod
            wf-plani.isenta   = p-entrada
            vacre             = 0.
            
        find first tt-cartpre no-error.
        if avail tt-cartpre
        then do:
            vqtdcart = 0.
            for each tt-cartpre. 
                if tt-cartpre.numero = 0
                then delete tt-cartpre.
                else assign vqtdcart = vqtdcart + 1
                            tt-cartpre.seq = vqtdcart.
            end.

            wf-plani.notobs[3] = "".
            wf-plani.notobs[3] = "QTDCHQUTILIZADO=" + string(vqtdcart).
            
            for each tt-cartpre.
                wf-plani.notobs[3] = wf-plani.notobs[3] 
                            + "|NUMCHQPRESENTEUTILIZACAO" 
                            + string(tt-cartpre.seq)
                            + "="
                            + string(tt-cartpre.numero)
                            + "|VALCHQPRESENTEUTILIZACAO"
                            + string(tt-cartpre.seq)
                            + "="
                            + string(tt-cartpre.valor).
            end.
        end.
        find first black_friday where
                   black_friday.numero > 0 no-error.
        if avail black_friday
        then do:
            if black_friday.desconto = no
            then wf-plani.notobs[3] = wf-plani.notobs[3] +
                "|BLACK-FRIDAY=" + string(black_friday.numero) + ";"
                                 + string(black_friday.valor) + "|"
                                 .
            else wf-plani.notobs[3] = wf-plani.notobs[3] +
                 "|BLACK-FRIDAY-DESCONTO=" + string(black_friday.numero) + ";"
                                  + string(black_friday.valor) + ";"
                                  + string(black_friday.pctdes) + "|"
                                  .  
        end.

        if crepl.crecod = 2
        then wf-plani.modcod   = "CRE".
        else wf-plani.modcod   = "VVI".
        vacre = vsubtot2.
        wf-plani.platot = wf-plani.platot + vacre.
        vacre = vacre - (vsubtot2 - vdev).
        if vacre < 0
        then vacre = 0.
        
        find first tt-descfunc where tt-descfunc.tem_cadastro = yes
                                 and tt-descfunc.tipo_funcionario = yes
                                            no-lock no-error.
                                            
        if avail tt-descfunc
        then assign wf-plani.notobs[3] = wf-plani.notobs[3]
                                            + "|DESCONTO_FUNCIONARIO=SIM|".
        
    end.

find first wbonus no-error.
if avail wbonus
then vbon = wbonus.bonus.
else vbon = 0.

if wf-plani.crecod = 2
then do:
   create wf-contrato.
   assign wf-contrato.contnum   = ?
          wf-contrato.clicod    = wf-plani.desti
          wf-contrato.dtinicial = wf-plani.pladat
          wf-contrato.etbcod    = wf-plani.etbcod
          wf-contrato.datexp    = today
          wf-contrato.crecod    = finan.fincod
          wf-contrato.vltotal   = wf-plani.platot * finan.finfat
          wf-contrato.vlentra   = ventrada.

   create wf-contnf.
   assign wf-contnf.contnum = wf-contrato.contnum
          wf-contnf.etbcod  = wf-plani.etbcod
          wf-contnf.placod  = wf-plani.placod
          wf-contnf.notanum = wf-plani.numero
          wf-contnf.notaser = wf-plani.serie.
end.


if keyfunction( lastkey ) = "end-error"
then undo, leave.
/**
sresp = no.
message "Voce já fez a venda Adicional ?" update sresp.
if not sresp
then do:
    sparam = "voltar".
    return.
end. 
**/
/***/
def var vpq as char.
repeat on endkey undo:
    if keyfunction(lastkey) = "END-ERROR"
    then leave.
    sresp = no.
    message "Voce já fez a venda Adicional ?" update sresp.
    if not sresp
    then do:
        disp "Informe o motivo por não fazer a venda adicional"
                no-label with frame f-adicional.
        update vpq label "Porque?" format "x(70)"
            with frame f-adicional  1 down
            side-label row 20 no-box color message overlay.
        vpq = "PORQUE=" + vpq + "|".
    end. 
    else do:
        disp "Informe o codigo do produto adicional"
                no-label with frame f-adicional1.
        update vpq label "Produto" format "x(70)"
            with frame f-adicional1  1 down
                side-label row 20 no-box color message overlay.
        vpq = "PRODUTO=" + vpq + "|".
    end.
    hide frame f-adicional.
    hide frame f-adicional1.
    if vpq = "" then undo.   
    leave.
end.
wf-plani.usercod = vpq.

if keyfunction(lastkey) = "END-ERROR"
then do:
    sparam = "Voltar".
    return.
end.    
/****/

/***** Criacao de titulo, plani, movim, contrato e contnf *******/

    if vnumeracao-automatica = yes
    then do:
        /*do for xplani transaction:*/
        find last xplani where xplani.movtdc = 30 and
                               xplani.etbcod = setbcod and 
                               xplani.emite  = setbcod and 
                               xplani.serie  = "P"     and
                               xplani.numero <> ?
                               use-index nota no-lock no-error.
        par-num = if avail xplani
                  then xplani.numero + 1 
                  else 1.                                
        
        find last zplani where zplani.movtdc = 30 and
                               zplani.etbcod = setbcod and 
                               zplani.emite  = setbcod and 
                               zplani.serie  = "P"     and
                               zplani.numero <> ?      and
                               zplani.pladat = today
                               use-index nota no-lock no-error.
        if avail zplani
        then not-ass = zplani.notass + 1.
        else not-ass = 1. 
        /*end.*/

        do transaction:
            wf-plani.placod   = int(string("211") + string(par-num,"9999999")).
            if avail wf-contnf
            then wf-contnf.placod  = wf-plani.placod.
        
            create plani.
            rec-plani = recid(plani). 
            {tt-plani.i plani wf-plani}. 

            plani.numero = par-num.
            plani.notass = not-ass.
            plani.exportado = yes.
            wf-plani.numero = plani.numero.
            wf-plani.notass = plani.notass.
        end.
    end.

    if plani.crecod = 2 
    then do:  
        /**
        do for geranum on error undo on endkey undo:
            find geranum where geranum.etbcod = setbcod.
            vgera = geranum.contnum.
            do transaction:
                geranum.contnum = geranum.contnum + 1.
            end.
            find current geranum no-lock.
        end.
        **/
        wf-contrato.vltotal = 0. 
        for each wf-titulo: 
            wf-contrato.vltotal = wf-contrato.vltotal + wf-titulo.titvlcob. 
        end.

        do  transaction:
            assign plani.pedcod = wf-contrato.crecod
                   plani.biss   = wf-contrato.vltotal.
        end.
    end.
   
    pedidoespecial = no.
    for each wf-movim by wf-movim.movalicms:
        
        vmovseq = vmovseq + 1.
        find produ where recid(produ) = wf-movim.wrec no-lock.
        
        if produ.proipival = 1
        then pedidoespecial = yes.
        
        do transaction:
            plani.protot = plani.protot + (wf-movim.movqtm * wf-movim.movpc).
            if wf-movim.vencod > 0
            then plani.vencod = wf-movim.vencod.

            find first tt-planos-vivo where 
                       tt-planos-vivo.procod = produ.procod no-lock no-error.

            find first movim where movim.etbcod = plani.etbcod and
                                   movim.placod = plani.placod and
                                   movim.procod = produ.procod
                                   exclusive no-error.
            if avail movim
            then do:
                def var vmovtot as dec.
                vmovtot = (movim.movpc * movim.movqtm).
                movim.movqtm = movim.movqtm + wf-movim.movqtm.
                movim.movpc  = (vmovtot + wf-movim.movpc) / movim.movqtm.
            end.
            else do:
                create movim.
                assign
                    movim.movtdc    = plani.movtdc
                   movim.PlaCod    = plani.placod 
                   movim.etbcod    = plani.etbcod 
                   movim.emite     = plani.emite 
                   movim.desti     = plani.desti 
                   movim.movseq    = vmovseq 
                   movim.procod    = produ.procod 
                   movim.movqtm    = wf-movim.movqtm 
                   movim.movpc     = wf-movim.movpc 
                   movim.movalicms = wf-movim.movalicms 
                   movim.movdat    = plani.pladat 
                   movim.MovHr     = int(time) 
                   movim.datexp    = today
                   movim.ocnum[8]  = tt-planos-vivo.tipviv 
                                     when avail tt-planos-vivo
                   movim.ocnum[9]  = tt-planos-vivo.codviv
                                     when avail tt-planos-vivo.
            
            end.
                                                 
            /** Chamado 16177 - supervisor **/
            find first tt-senauto where 
                       tt-senauto.procod = produ.procod no-lock no-error.
            if avail tt-senauto and tt-senauto.desco = yes
            then do:
                 assign movim.ocnum[5] = tt-senauto.preco-ori 
                        movim.ocnum[6] = tt-senauto.senauto.
            end.
            /** **/
            
            movim.exportado = yes.
        end.          
        
        if wf-movim.lipcor <> ""
        then do transaction:  
            find first tp-tbprice where
                     tp-tbprice.nota_compra = produ.procod no-error.
            if avail tp-tbprice
            then do:         
                find first tbprice where
                      /*tbprice.tipo = tp-tbprice.tipo and*/
                      tbprice.serial = tp-tbprice.serial
                      no-error.
                if not avail tbprice
                then do:
                    create tbprice.
                    buffer-copy tp-tbprice to tbprice.
                end.
                assign
                    tbprice.tipo = tp-tbprice.tipo
                    tbprice.etb_venda = plani.etbcod 
                    tbprice.nota_venda = plani.numero
                    tbprice.data_venda = plani.pladat
                    tbprice.char1 = "PRE-VENDA"
                    tbprice.char2 = tp-tbprice.char2
                    tbprice.etb_compra = 0
                    tbprice.nota_compra = produ.procod
                    tbprice.exportado = yes
                    tbprice.dec1 = wf-movim.precoori.
             end.
        end.
    end.
    
    find plani where recid(plani) = rec-plani no-lock.
    /*
    run fil-ped-esp.
    */
    ped-esp = no.
    
    run pedido-especial.

    for each wf-movim:
    
        find produ where recid(produ) = wf-movim.wrec no-lock.
        if wf-movim.lipcor <> "" 
        then do:
            create liped.
            assign
               liped.pednum    = plani.placod
               liped.pedtdc    = 30
               liped.predt     = today
               liped.etbcod    = plani.etbcod
               liped.procod    = produ.procod
               liped.lippreco  = wf-movim.movpc
               liped.lipqtd    = wf-movim.movqtm
               liped.lipcor    = wf-movim.lipcor
               liped.lipsit    = "Z"
               liped.predt     = today.
        end.
        if etb-entrega <> 0 and
           etb-entrega <> setbcod 
        then do:
            create liped.
            assign
               liped.pednum    = plani.placod
               liped.pedtdc    = 32
               liped.predt     = today
               liped.etbcod    = plani.etbcod
               liped.procod    = produ.procod
               liped.lippreco  = wf-movim.movpc
               liped.lipqtd    = wf-movim.movqtm
               liped.lipcor    = wf-movim.lipcor + 
                    "|NOME-RETIRADA= " + nome-retirada +
                    "|FONE-RETIRADA= " + fone-retirada + "|"
               liped.lipsit    = "Z"
               liped.predtf    = dat-entrega
               liped.lipsep    = etb-entrega.
            if ped-esp = yes
            then liped.protip = "6".   
        end.

        if ped-esp = no
        then do:
            find first tt-liped where tt-liped.procod = produ.procod no-error.
            if avail tt-liped
            then do:
                create liped.
                assign liped.pednum    = plani.placod
                   liped.pedtdc    = 33
                   liped.predt     = today
                   liped.etbcod    = plani.etbcod
                   liped.procod    = produ.procod
                   liped.lippreco  = wf-movim.movpc
                   liped.lipqtd    = wf-movim.movqtm
                   liped.lipcor    = wf-movim.lipcor
                   liped.lipsit    = "Z"
                   liped.predtf    = tt-liped.predt.
                delete tt-liped.
            end.
        end.               
    end.                          
    par-rec = recid(plani).


procedure pedido-especial:
    def var vobs like pedid.pedobs format "x(60)". 
    def var vfabcod like produ.fabcod.
    def var vok as log.
    def var vfor-esp like produ.fabcod.  

    ped-esp = no.
    vfor-esp = 0.

    if pedidoespecial = yes
    then do:
        sresp = yes.
        /* helio 25102023 - 558955 PEDIDO ESPECIAL = SIM PRÉ VENDA - RETIRADO        
        *do on endkey undo.
       *     message "DESEJA FAZER PEDIDO ESPECIAL?" update sresp.
       * end.
       * **/
        /* helio 31102023 -  558955 PEDIDO ESPECIAL = SIM PRÉ VENDA - incluido mensagem */
        message skip(1) 
                "O produto de pedido especial (PE) será gerado automaticamente. " skip
                "Caso a loja deseje cancelar o pedido, entrar em contato com o " skip
                "   time de compras pelo e-mail pedidoespecial@lebes.com.br.   " skip(2)      
                " ATENÇÃO: Para produto PE descontinuado não será gerado pedido. " skip(1) /* helio 27112023 */
        view-as alert-box.                         
        if sresp
        then do:
            ped-esp = yes.
            vfabcod = 0.
            vok = yes.
            /*  helio 28062023 - retirado tranca por fabricante */ 
            /**
            *for each wf-movim:
            *    find produ where recid(produ) = wf-movim.wrec no-lock.
            *    if produ.proipival = 1
            *    then vfor-esp = produ.fabcod.
            *    else next.
            *    if vfabcod = 0
            *    then vfabcod = produ.fabcod.
            *    else if produ.fabcod <> vfabcod and
            *            produ.proipival <> 0
            *         then vok = no.
            *end.
            *if vok = no
            *then do:
            *    message color red/with
            *       "Produto especial de fabricante diferente na Nota."  skip
            *            "Impossivel gerar pedido especial."
            *            view-as alert-box.
            *    sparam = "voltar".
            *    return.        
            *end.
            */
            /*  helio 28062023 - Retirada do campo de data de inclusão na tela, com preenchimento automático da data atual */
            /*  helio 28062023 - Retirada do campo de observações na tela, com preenchimento automático da palavra .Pedido Especial. */
            pedataespecial = today.
            vobs = "".
            vobs[1] = "PEDIDOESPECIAL".

            /*
            *REPEAT ON endkey undo:
            *    /*if dat-entrega <> ?
            *    then pedataespecial = dat-entrega.
            *    else*/ pedataespecial = today.
            *    disp "INFORMACOES PARA PEDIDO ESPECIAL" at 25
            *        WITH FRAME f-peddisp 1 down 
            *            no-box no-label row 14 overlay color message width 80.
            *    update pedataespecial at 5 label "Data de inclusao do pedido"
            *         validate(pedataespecial <> ? and
            *                 pedataespecial >= today,
            *              "Data deve ser igual ou maior que " 
            *                + string(today,"99/99/9999"))
            *       /*"                " at 1*/ 
            *       vobs[1] at 5 label "Observacao"
            *       vobs[2] at 17 no-label
            *       vobs[3] at 17 no-label
            *       vobs[4] at 17 no-label
            *       with frame f-pedesp 1 down row 15
            *       side-label color message overlay width 80.
            *    hide frame f-peddisp no-pause.
            *    hide frame f-pedesp no-pause.
            *    leave.
            *end.
            */
            
            for each wf-movim:
                find produ where recid(produ) = wf-movim.wrec no-lock.

                /*  helio 28062023 - retirado tranca por fabricante */ 
                /*if vfor-esp <> produ.fabcod
                *then next.
                */
                
                create liped. 
                assign liped.pednum   = plani.placod 
                       liped.pedtdc   = 31 
                       liped.etbcod   = plani.etbcod  
                       liped.lipsep   = etb-entrega 
                       liped.procod   = produ.procod  
                       liped.lippreco = wf-movim.movpc  
                       liped.lipqtd   = wf-movim.movqtm  
                       liped.lipsit   = "W"  
                       liped.predt    = pedataespecial 
                       liped.lipcor   = "OBS1=" + vobs[1] + "|OBS2=" + vobs[2] 
                       liped.protip   = "OBS3=" + vobs[3] + "|OBS4=" + vobs[4].
                wf-movim.lipcor = "".
            end.
        end.
    end.
end procedure.   
 
/***
procedure fil-ped-esp:
    
    if setbcod <> 7 and
       setbcod <> 8 and
       setbcod <> 15 and
       setbcod <> 29 and
       setbcod <> 30 and
       setbcod <> 36 and
       setbcod <> 38 and
       setbcod <> 49 and
       setbcod <> 59 and
       setbcod <> 70 and
       setbcod <> 74 and
       setbcod <> 78 and 
       setbcod <> 80
    then pedidoespecial = no.
      
end procedure.
***/
