def input param prectt-seg-movim as recid.

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
def var vx as int.
def var vqtd as int.
def buffer ptt-seg-movim for tt-seg-movim.
def var vprocod as int.
def var vprecoori as dec.
def var vmovpc as dec.

    find ptt-seg-movim where recid(ptt-seg-movim) = prectt-seg-movim.
    find produ where produ.procod = ptt-seg-movim.procod no-lock.    
    find bprodu where bprodu.procod = ptt-seg-movim.seg-procod no-lock.
    find first pwf-movim where pwf-movim.wrec = recid(produ).
    
    vprocod = ptt-seg-movim.procod.
    vprecoori = pwf-movim.precoori.
    vmovpc  = pwf-movim.movpc.
    
    
    form
        tt-segprodu.sequencia label "Seq" format "x(3)"
        tt-segprodu.meses     format ">>9"
        produ.procod
        produ.pronom          format "x(30)"
        tt-segprodu.prvenda   label "Preco" format ">,>>9.99"
        with frame f-selec centered down title " Inclusao de Seguros "
               color withe/red overlay
               row 8.
         
        run garan-ws.p (vprocod, vprecoori, vmovpc).
        find first tt-segprodu no-lock no-error.
        if not avail tt-segprodu
        then return.
        vx = 0.
        for each tt-segprodu :
            if tt-segprodu.ramo <> ptt-seg-movim.ramo or
               tt-segprodu.seg-procod = ptt-seg-movim.seg-procod
            then delete tt-segprodu.   
            else vx = vx + 1.
        end.
        if vx = 0
        then do:
            message bprodu.pronom " nao pode ser substituido" view-as alert-box.
            return.
            end.    
        pause 0.
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
        
        run subs.
                        

procedure subs.

                find wf-movim where recid(wf-movim) = ptt-seg-movim.recid-wf-movim.
                vqtd = wf-movim.movqtm.
                delete wf-movim.
                delete ptt-seg-movim.     
                
                run inclusao-segprod (recid(tt-segprodu), vprocod, vmovpc).
                find first btt-seg-movim where btt-seg-movim.procod = vprocod
                                   and btt-seg-movim.seg-procod    = tt-segprodu.seg-procod 
                                 no-lock no-error.
                if avail btt-seg-movim
                then do. 
                    find wf-movim where recid(wf-movim) = btt-seg-movim.recid-wf-movim.
                    wf-movim.movqtm = vqtd.
                end.
end procedure.
