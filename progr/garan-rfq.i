/*
    Projeto Garantia/RFQ: out/2017
#1 Ajuste da quantidade
*/
def var vende-garan as log.

/*
  Para cada produto de seguro informa quais sao os produtos de venda
*/
def {1} SHARED temp-table tt-seg-movim
    field seg-procod  as int             /* procod do seguro */
    field procod      like movim.procod    
    field ramo        as int
    field meses       as int
    field subtipo     as char
    field movpc       like movim.movpc
    field precoori    like movim.movpc
    field p2k-datahoraprodu as char
    field p2k-id_seguro     as int
    field p2k-datahoraplano as char
    field recid-wf-movim as recid init ?
    index seg-movim is primary unique seg-procod procod.

/*
  Para inclusao via WS
*/
def {1} SHARED temp-table tt-segprodu no-undo
    field sequencia  as char
    field seg-procod as int
    field tipo       as char
    field Meses      as int
    field prvenda    as dec
    field ramo       as int
    field padrao     as log
    field p2k-datahoraprodu as char
    field p2k-id_seguro     as int
    field p2k-datahoraplano as char.

/***
    Venda
***/
def buffer pprodu for produ.
def buffer pwf-movim for wf-movim.
def buffer btt-seg-movim for tt-seg-movim.
procedure vende-segprod.

    def input parameter par-procod   as int. /* procod da venda */
    def input parameter par-precoori as dec.
    def input parameter par-movpc    as dec.

    /*
        1. Verificar se tem seguro
    */
    def var vtempogar as int.
    find first produaux where produaux.procod     = produ.procod
                          and produaux.nome_campo = "TempoGar"
                        NO-LOCK no-error.
    if avail produaux
    then vtempogar = int(produaux.valor_campo).
    if vtempogar > 0
    then do.
        /* Nao executa mais o inclusao-sewgprod aqui, mas chama o garan-inc.p */
        run garan-inc.p (par-procod, par-precoori, par-movpc, yes).
    end.

end procedure.


/***
    Inclusao de Seguro
***/
procedure inclusao-segprod.
    
    def input parameter par-rec-segpro as recid.
    def input parameter par-procod     as int.
    def input parameter par-preco      as dec.

    def buffer btt-segprodu for tt-segprodu.
    def buffer bprodu for produ.

    find btt-segprodu where recid(btt-segprodu) = par-rec-segpro no-lock.
    find bprodu where bprodu.procod = btt-segprodu.seg-procod no-lock.


    /*
      Produtos que compoem o seguro
    */
    find first tt-seg-movim
                       where tt-seg-movim.seg-procod = btt-segprodu.seg-procod
                         and tt-seg-movim.procod     = par-procod
                       no-error.
    if not avail tt-seg-movim
    then do.
        create tt-seg-movim.
        assign
            tt-seg-movim.seg-procod = btt-segprodu.seg-procod
            tt-seg-movim.procod    = par-procod
            tt-seg-movim.ramo       = btt-segprodu.ramo
            tt-seg-movim.meses      = btt-segprodu.meses
            tt-seg-movim.subtipo    = btt-segprodu.tipo
            tt-seg-movim.movpc      = btt-segprodu.prvenda
            tt-seg-movim.precoori   = par-preco
            tt-seg-movim.p2k-datahoraprodu = btt-segprodu.p2k-datahoraprodu
            tt-seg-movim.p2k-id_seguro     = btt-segprodu.p2k-id_seguro
            tt-seg-movim.p2k-datahoraplano = btt-segprodu.p2k-datahoraplano.

        
        create wf-movim.
        assign
                wf-movim.wrec      = recid(bprodu)
                wf-movim.movalicms = 98.
        wf-movim.movqtm = /*wf-movim.movqtm +*/ 1 .  /* helio 101123 - 555859 - Duas Garantias em produtos iguais PRÉ VENDA */
        wf-movim.movpc  = wf-movim.movpc + btt-segprodu.prvenda.
            
        tt-seg-movim.recid-wf-movim = recid(wf-movim).
        /* helio 12/03/2024 - usando um campo do tempo */
        wf-movim.KITproagr  =   par-procod.
    end.
    else do:
    
        find first wf-movim where recid(wf-movim) = tt-seg-movim.recid-wf-movim no-error.
        if avail wf-movim
        then wf-movim.movqtm = wf-movim.movqtm + 1 .  /* helio 101123 - 555859 - Duas Garantias em produtos iguais PRÉ VENDA */

    end.

end procedure.


/***
    Exclui
***/
procedure exclui-segprod.
    def input parameter par-procod   as int. /* Produto de venda */
    def input parameter par-segprodu as int. /* Produto de Seguro */

    def buffer bprodu for produ.
    def buffer btt-seg-movim for tt-seg-movim.

    for each tt-seg-movim where tt-seg-movim.procod = par-procod.
        if par-segprodu > 0 and
           tt-seg-movim.seg-procod <> par-segprodu
        then next.

        find wf-movim where recid(wf-movim) = tt-seg-movim.recid-wf-movim.
        wf-movim.movqtm = wf-movim.movqtm - 1.
        
        if wf-movim.movqtm <= 0  /* helio 101123 - 555859 - Duas Garantias em produtos iguais PRÉ VENDA */
        then do:
            delete wf-movim.
            delete tt-seg-movim.
        end.
    end.

/***
    run totaliza-garantia.
***/

end procedure.


/***
    Totaliza
procedure totaliza-garantia.

    def buffer bseg-produ for produ.

    for each tt-seg-movim no-lock break by tt-seg-movim.seg-procod.
        /* movim do seguro */
        find bseg-produ where bseg-produ.procod = tt-seg-movim.seg-procod
                         no-lock.
        find first wf-movim where wf-movim.wrec = recid(bseg-produ) no-lock.

        if first-of(tt-seg-movim.seg-procod)
        then assign
                wf-movim.movpc  = 0
                wf-movim.movqtm = 0.

        wf-movim.movpc = wf-movim.movpc + tt-seg-movim.movpc.
    end.

end procedure.
***/

/***
    Alteracao
    Se altrou o preco do produto deve chamar o Safe novamente
    Somente Garantia
***/
procedure altera-segprod.

    def input parameter par-procod as int. /* produto de venda */

    def var vpreco as dec.
    def buffer bseg-produ for produ.

    for each tt-seg-movim where tt-seg-movim.ramo = 710
                            /*and tt-seg-movim.movpc <> tt-seg-movim.precoori*/.
        if par-procod > 0 and
           tt-seg-movim.procod <> par-procod
        then next.

        /* Item de venda */
        find produ where produ.procod = tt-seg-movim.procod no-lock.
        find first wf-movim where wf-movim.wrec = recid(produ) no-lock.
        vpreco = wf-movim.movpc.

        if tt-seg-movim.precoori = wf-movim.movpc
        then next.

        run garan-ws.p (tt-seg-movim.procod,
                        wf-movim.movpc,
                        wf-movim.movpc).
        find first tt-segprodu
                         where tt-segprodu.seg-procod = tt-seg-movim.seg-procod
                         no-lock no-error.
        if avail tt-segprodu
        then do.
            find bseg-produ where bseg-produ.procod = tt-segprodu.seg-procod
                            no-lock.
            find first wf-movim where wf-movim.wrec = recid(bseg-produ) and
                                      wf-movim.kitproagr = tt-seg-movim.procod  .
            wf-movim.movpc = wf-movim.movpc
                             - tt-seg-movim.movpc
                             + tt-segprodu.prvenda.
            tt-seg-movim.movpc = tt-segprodu.prvenda.
            tt-seg-movim.precoori = vpreco.
        end.
    end.

end procedure.

