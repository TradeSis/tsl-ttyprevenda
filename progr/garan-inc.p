
def input param vprocod like produ.procod.
def input param vprecoori  as dec.
def input param vmovpc     as dec.
def input param vautomatico as log.

{admcab.i}
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

def buffer bseg-produ for produ.
{garan-rfq.i}
    def buffer bprodu for produ.
    {setbrw.i}
def var vexistente as log.
def var vlimpeza as log.  
def var vx as int.
def var vqtd as int.
    form
        tt-segprodu.sequencia label "Seq" format "x(3)"
        tt-segprodu.meses     format ">>9"
        produ.procod
        produ.pronom          format "x(30)"
        tt-segprodu.prvenda   label "Preco" format ">,>>9.99"
        with frame f-selec centered down title " Inclusao de Seguros "
               color withe/red overlay
               row 8.
         
        if vautomatico 
        then do: 
            vexistente = no.
            for each tt-seg-movim where tt-seg-movim.procod =  vprocod.
                find wf-movim where recid(wf-movim) = tt-seg-movim.recid-wf-movim.
                wf-movim.movqtm = wf-movim.movqtm + 1.    
                vexistente = yes.
            end.
            if vexistente
            then return.
        end.
                                
        run garan-ws.p (vprocod, vprecoori, vmovpc).
        find first tt-segprodu no-lock no-error.
        if not avail tt-segprodu
        then return.
        
        
        
        if vautomatico 
        then do:
            for each tt-segprodu /*where tt-segprodu.padrao*/ no-lock
                break by tt-segprodu.ramo.
                if first-of((tt-segprodu.ramo)) and last-of (tt-segprodu.ramo)
                then do:
                    run inclusao-segprod (recid(tt-segprodu),
                                           vprocod,
                                           vmovpc).
                    delete tt-segprodu.
                end.
            end.
        end. 
        /* limpezas */
        vlimpeza = no.
        for each tt-segprodu.
            /* ja tem um seguro incluido no ramos */
            find first btt-seg-movim where btt-seg-movim.procod = vprocod
                                   and btt-seg-movim.ramo   = tt-segprodu.ramo 
                    no-error.
            if avail btt-seg-movim
            then do:
                /* o seguro do ramos , eh de outro produto */
                find first btt-seg-movim where btt-seg-movim.procod = vprocod
                                   and btt-seg-movim.ramo   = tt-segprodu.ramo and
                                       btt-seg-movim.seg-procod <> tt-segprodu.seg-procod 
                                 no-error.
                if avail btt-seg-movim  
                then do:
                    delete tt-segprodu.
                    vlimpeza = yes.
                end.    
                else do:
                    /* o seguro do ramos , eh do mesmo produto */
                    find first btt-seg-movim where btt-seg-movim.procod = vprocod
                                   and btt-seg-movim.ramo   = tt-segprodu.ramo and
                                       btt-seg-movim.seg-procod = tt-segprodu.seg-procod 
                                 no-error.
                    if avail btt-seg-movim
                    then do:             
                        find wf-movim where recid(wf-movim) = btt-seg-movim.recid-wf-movim.
                        find produ where produ.procod = vprocod no-lock.
                        find first pwf-movim where pwf-movim.wrec = recid(produ).
                        if wf-movim.movqtm + 1 > pwf-movim.movqtm 
                        then do:
                            delete tt-segprodu.
                            vlimpeza = yes.    
                        end.
                    end.    
                end.
            end.
        end.
        find first tt-segprodu no-error.
        if not avail tt-segprodu
        then do:
            if vlimpeza
            then do:
                message "nao ha possibilidade de inclusao" view-as  alert-box.
            end.
            return.
        end.            

        {sklcls.i
            &File   = tt-segprodu
            &help   = "                ENTER=Seleciona  F4=Retorna"
            &CField = tt-segprodu.sequencia
            &Ofield = "tt-segprodu.meses produ.procod produ.pronom
                       tt-segprodu.prvenda"
            &Where  = "true"
            &LockType = "NO-LOCK"
            &aftfnd1  = "find produ where produ.procod = tt-segprodu.seg-procod
                                    no-lock."
            &Form   = "frame f-selec"
        }
        hide frame f-selec no-pause.

        if keyfunction(lastkey) = "end-error"
        then return.
        
        /* Validacao: Substituicao */
        find first btt-seg-movim where btt-seg-movim.procod = vprocod
                                   and btt-seg-movim.seg-procod    = tt-segprodu.seg-procod 
                                 no-lock no-error.
        if avail btt-seg-movim
        then do. 
            find wf-movim where recid(wf-movim) = btt-seg-movim.recid-wf-movim.
            find produ where produ.procod = vprocod no-lock.
            find first pwf-movim where pwf-movim.wrec = recid(produ).
            if wf-movim.movqtm + 1 <= pwf-movim.movqtm 
            then wf-movim.movqtm = wf-movim.movqtm + 1.    
            else do:
                message "garantias já inclusas para quantidade do item" produ.procod pwf-movim.movqtm
                    view-as alert-box. 
            end.
            return.
        end.
        find first btt-seg-movim where btt-seg-movim.procod = vprocod
                                   and btt-seg-movim.ramo   = tt-segprodu.ramo and
                                       btt-seg-movim.seg-procod <> tt-segprodu.seg-procod 
                                 no-error.
        if avail btt-seg-movim
        then do. 
                    
            sresp = yes.
            message "Ja incluido um seguro para este tipo" btt-seg-movim.meses
                    "meses. Usa Substituicao"
                    view-as alert-box.
            return.
        end.
        /* */
        
        run inclusao-segprod (recid(tt-segprodu), vprocod, vmovpc).


