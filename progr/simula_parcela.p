/* helio 12072022 - card sust Planos novos nãaparecem no F7 - préenda  - alterado para nao ler mais cpag, e ler direto finan */
/* helio 20012022 - [UNIFICAÇÃO ZURICH - FASE 2] NOVO CÁLCULO PARA SEGURO PRESTAMISTA MÓVEIS NA PRÉ-VENDA */

{admcab.i}

def input parameter vprotot as dec.
def input parameter vdevval as dec.
def input parameter vbonus as dec.
def input parameter parcela-especial as dec.
def input parameter ventradadiferenciada as log.
def output parameter vfincod like finan.fincod.

def new shared var p-dtentra as date.
def new shared var p-dtparcela as date.

def var wtot as dec.
def var wdev as dec.
def var wbon as dec.
def var wliq as dec.
def var went as dec.
def var wpar as dec.
def var vprodu as int.
def var vmovpc as dec.
def var vbrinde as dec.
def var vconf as log.
 
def var ventra as dec.
def var vparce as dec.
def var vliqui as dec.
def shared var vdata-teste-promo as date.
def new shared temp-table tt-valpromo 
    field tipo   as int
    field forcod as int
    field nome   as char
    field valor  as dec
    field recibo as log 
    field despro as char
    field desval as char.

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

def shared temp-table tt-seguroPrestamista no-undo
    field wrec          as recid
    field procod        as int.


def var vpar-sem-seg as dec.
def var vpar-com-seg as dec.

def temp-table tt-simula  no-undo
    field fincod like finan.fincod
    field finnom like finan.finnom
    field finnpc like finan.finnpc
    field par-com-seg as dec
    field par-sem-seg as dec
    index i1 fincod
    index i2 finnpc  
    .
    
def var vcatcod like produ.catcod.
def var vtm as dec.
def var vtc as dec.
vprotot = 0.
vcatcod = 0.
vtm = 0.
vtc = 0.
for each wf-movim where wf-movim.movalicms <> 98 /*GE/RFQ*/:
    find produ where recid(produ) = wf-movim.wrec no-lock no-error.
    if not avail produ then next.
    if vcatcod = 0 
    then vcatcod = produ.catcod.  
    else if vcatcod = 41 and produ.catcod <> 41
        then vcatcod = 31.  
    vprotot = vprotot + (wf-movim.movqtm * wf-movim.movpc).
    if produ.catcod = 41
    then vtc = vtc + (wf-movim.movqtm * wf-movim.movpc).
    else vtm = vtm + (wf-movim.movqtm * wf-movim.movpc).
end.
/*
if vtm > vtc and vcatcod = 41
then vcatcod = 31.
else if vtc > vtm and vcatcod <> 41
    then vcatcod = 41.
*/
def var velegivel as log.
{seguroprestlote.i}

def var par-valor as char.
vende-seguro = no.
run lemestre.p (input "VENDE-SEGURO", output par-valor).     
vende-seguro = par-valor = "SIM".

def temp-table tt-promoc no-undo like ctpromoc .
def buffer bctpromoc for ctpromoc.

for each ctpromoc where ctpromoc.linha = 0 and
                        ctpromoc.dtfim >= today and
                        ctpromoc.situacao = "L"
                        no-lock:
    if  ctpromoc.liberavenda or 
        ctpromoc.compolog5   
    then do:     
        
    
            find first bctpromoc where 
                           bctpromoc.sequencia = ctpromoc.sequencia and
                           bctpromoc.etbcod > 0 
                           no-lock no-error. 
        if avail bctpromoc
        then do:
            if bctpromoc.etbcod <> setbcod and bctpromoc.etbcod <> 0
            then next.
        end.        
        
        create tt-promoc.
        buffer-copy ctpromoc to tt-promoc.
    end.
end. 


def var parametro-in as char.
def var parametro-out as char.
def var libera-plano as log.
def var block-plano as log.
hide message no-pause .

message "Aguarde...".
def var xtime as int.
xtime = time.

for each finan no-lock:
    find first finesp where finesp.fincod = finan.fincod
               no-lock no-error.
    if not avail finesp and
       finan.fincod > 0
    then next.           
    if avail finesp 
    then do:
       if vcatcod <> finesp.catcod 
       then next.
       if finesp.datafin = ? then next.   
       if finesp.datafin < today and
          finesp.dataven = ?
       then next.   
    end.  
    if int(vprotot * finan.finfat) >= int(vprotot) and
       finan.finnpc > 0
    then next.
 
    
    if avail finesp and
        finesp.dataven < today
        /*
             finesp.dataini < today and
             finesp.datafin < today   */
    then do:
        assign
            p-dtentra = ?
            p-dtparcela = ?
            libera-plano = no
            block-plano  = no.
        if finesp.dataini = finesp.datafin and
           finesp.dataven = finesp.datafin
        then do:
            for each tt-promoc:
                find first ctpromoc where 
                           ctpromoc.sequencia = tt-promoc.sequencia and
                           ctpromoc.fincod = finan.fincod 
                           no-lock no-error. 
                if avail ctpromoc 
                then do:
                    block-plano  = yes.          
                    leave.
                end.    
            end.
        end.
        if block-plano 
        then do:
            parametro-out = "".
            parametro-in = "LIBERA-PLANO=S|"
                        + "PLANO=" + string(finan.fincod) + "|".
                        
            run promo-venda.p(input parametro-in ,
                              output parametro-out).
            
            if acha("LIBERA-PLANO",parametro-out) <> ? and
               acha("LIBERA-PLANO",parametro-out) = "S"
            then do:
                libera-plano = yes. 
            end.
        end.
        block-plano  = no.
        
        /*disp finan.fincod libera-plano.*/
        
        if not libera-plano
        then next.
    end.
    
        
    assign
        vfincod = finan.fincod
        vliqui = 0
        ventra = 0
        vparce = 0
        wtot = 0
        wdev = 0
        wbon = 0
        wliq = 0
        went = 0
        wpar = 0.

    assign
            vsegtipo = 0
            vsegprest = 0
            vsegvalor = 0
            vpar-sem-seg = 0
            vpar-com-seg = 0.

    if finan.fincod > 0 and finan.finnpc <> 0
    then do:        
        for each wf-movim:
            find produ where recid(produ) = wf-movim.wrec no-lock no-error.
            if not avail produ then next.
            
            find first tt-seguroPrestamista where tt-seguroPrestamista.wrec = wf-movim.wrec no-error.
            if avail tt-seguroPrestamista
            then next.
                                
            if wf-movim.movpc = 1
            then next.
            wtot = wf-movim.movpc * wf-movim.movqtm.
            if vdevval > 0
            then wdev = vdevval * (wtot / vprotot).
            else wdev = 0.

            if vbonus > 0
            then wbon = vbonus * (wtot / vprotot).

            scli = produ.procod.
            if vbrinde > 0 and
               vprodu = produ.procod
            then do:
                wtot = wtot + vbrinde.
                vbrinde = 0.
            end.    
        
            parcela-especial = 0.

            run gercpg1.p( input vfincod, 
                       input wtot, 
                       input wdev, 
                       input wbon, 
                       output wliq, 
                       output went,
                       output wpar).
        
            scli = 0.               
        
            if parcela-especial > 0
            then wpar = parcela-especial.
        
            if not ventradadiferenciada
            then ventra = ventra + went.
            assign
                vliqui = vliqui + wliq
                vparce = vparce + wpar
                wtot = 0
                wdev = 0
                wbon = 0
                wliq = 0
                went = 0
                wpar = 0.
        end.

        assign
            vsegtipo = 0
            vsegprest = 0
            vsegvalor = 0
            vpar-sem-seg = 0
            vpar-com-seg = 0.
        vpar-sem-seg = vparce.
        
        create tt-simula.
        assign
            tt-simula.fincod = finan.fincod
            tt-simula.finnom = finan.finnom
            tt-simula.finnpc = finan.finnpc
            tt-simula.par-sem-seg = vparce.

        /** helio 17062022 nao calcula mais o seguro prestamista individualmente
        run seguroprestamistalote (finan.finnpc, vparce, 0,
                                           output vsegtipo,
                                           output vsegprest,
                                           output vsegvalor).
        message "rodou" finan.finnpc vparce "retorno" vsegtipo vsegprest vsegvalor . 
        
        
        if vsegprest > 0
        then vpar-com-seg = vparce + vsegprest.
        else if vsegvalor > 0
        then do:
            vpar-com-seg = vparce.
            assign
               vfincod = finan.fincod
                vliqui = 0
                ventra = 0
                /*vparce = 0*/
                wtot = 0
                wdev = 0
                wbon = 0
                wliq = 0
                went = 0
                wpar = 0.
            
            for each wf-movim:
                find produ where recid(produ) = wf-movim.wrec no-lock no-error.
                if not avail produ then next.

                find first tt-seguroPrestamista where tt-seguroPrestamista.wrec = wf-movim.wrec no-error.
                if   avail tt-seguroPrestamista
                then.
                else next.

                                
                if wf-movim.movpc = 1
                then next.
                wtot = wf-movim.movpc * wf-movim.movqtm.
                if vdevval > 0
                then wdev = vdevval * (wtot / vprotot).
                else wdev = 0.

                if vbonus > 0
                then wbon = vbonus * (wtot / vprotot).

                scli = produ.procod.
                if vbrinde > 0 and
                    vprodu = produ.procod
                then do:
                    wtot = wtot + vbrinde.
                    vbrinde = 0.
                end.    
        
                parcela-especial = 0.

                run gercpg1.p( input vfincod, 
                       input wtot, 
                       input wdev, 
                       input wbon, 
                       output wliq, 
                       output went,
                       output wpar).
        
                scli = 0.               
        
                if parcela-especial > 0
                then wpar = parcela-especial.
        
                if not ventradadiferenciada
                then ventra = ventra + went.
                assign
                    vliqui = vliqui + wliq
                    vpar-com-seg = vpar-com-seg + wpar
                    /*vparce = vparce + wpar*/
                    wtot = 0
                    wdev = 0
                    wbon = 0
                    wliq = 0
                    went = 0
                    wpar = 0.
            end.
        end.
        helio 17062022 nao calcula mais o seguro prestamista individualmente */
        
        
    end.
    else do:
        vparce = vprotot.
        create tt-simula.
        assign
            tt-simula.fincod = finan.fincod
            tt-simula.finnom = finan.finnom
            tt-simula.finnpc = finan.finnpc
            tt-simula.par-sem-seg = vparce.
    end.
            /*
    vpar-sem-seg = vparce.
        tt-simula.par-com-seg = vpar-com-seg.
        */
    /*disp finan    .*/
    
end.

message "tempo processamento inicial" string(time - xtime,"HH:MM:SS").

hide message no-pause.
message "chamando api" string(time - xtime,"HH:MM:SS").
xtime = time.
run seguroprestamistalote (output velegivel, output vsegvalor).
hide message no-pause.
message "tempo api" string(time - xtime,"HH:MM:SS").
hide message no-pause.

for each tt-simula.

    if not vende-seguro 
    then velegivel = no.
        
    find first ttsaidaparcelas where ttsaidaparcelas.qtdParcelas = string(tt-simula.finnpc) no-error.
    if velegivel
    then do:
        vfincod = tt-simula.fincod.
        find finan where finan.fincod = vfincod no-lock.
        
        vsegprest = dec(ttsaidaparcelas.valorParcela).
        vparce = tt-simula.par-sem-seg.

        /*if vsegprest > 0 /* nao usa o valor da parcela que esta retornando, mas aplica o fator no finan com o seguro somado */
        then vpar-com-seg = vsegprest.
        else*/ if vsegvalor > 0
        then do:
            vpar-com-seg = vparce.
            assign
               vfincod = finan.fincod
                vliqui = 0
                ventra = 0
                /*vparce = 0*/
                wtot = 0
                wdev = 0
                wbon = 0
                wliq = 0
                went = 0
                wpar = 0.
            
            for each wf-movim:
                find produ where recid(produ) = wf-movim.wrec no-lock no-error.
                if not avail produ then next.

                find first tt-seguroPrestamista where tt-seguroPrestamista.wrec = wf-movim.wrec no-error.
                if   avail tt-seguroPrestamista
                then.
                else next.

                                
                if wf-movim.movpc = 1
                then next.
                wtot = wf-movim.movpc * wf-movim.movqtm.
                if vdevval > 0
                then wdev = vdevval * (wtot / vprotot).
                else wdev = 0.

                if vbonus > 0
                then wbon = vbonus * (wtot / vprotot).

                scli = produ.procod.
                if vbrinde > 0 and
                    vprodu = produ.procod
                then do:
                    wtot = wtot + vbrinde.
                    vbrinde = 0.
                end.    
        
                parcela-especial = 0.

                run gercpg1.p( input vfincod, 
                       input wtot, 
                       input wdev, 
                       input wbon, 
                       output wliq, 
                       output went,
                       output wpar).
        
                scli = 0.               
        
                if parcela-especial > 0
                then wpar = parcela-especial.
        
                if not ventradadiferenciada
                then ventra = ventra + went.
                assign
                    vliqui = vliqui + wliq
                    vpar-com-seg = vpar-com-seg + wpar
                    /*vparce = vparce + wpar*/
                    wtot = 0
                    wdev = 0
                    wbon = 0
                    wliq = 0
                    went = 0
                    wpar = 0.
            end.
        end.
        
        tt-simula.par-com-seg = vpar-com-seg.
        
    end.    
    else tt-simula.par-com-seg = 0.
    
end.


hide message no-pause.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqascend     as log initial yes.

recatu1 = ?.
recatu2 = ?.

bl-princ:
repeat:
    
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find tt-simula use-index i2 where recid(tt-simula) = recatu1 no-lock.
    
    if not available tt-simula
    then leave bl-princ.
    
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(tt-simula).
    repeat:
        run leitura (input "seg").
        if not available tt-simula
        then leave .

        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    
    up frame-line(frame-a) - 1 with frame frame-a.
    
    
    repeat with frame frame-a:

            find tt-simula use-index i2 
                        where recid(tt-simula) = recatu1 no-lock.

            run color-message.
            choose field tt-simula.fincod help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return) color message.
            run color-normal.
            status default "".

        if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail tt-simula
                    then leave.
                    recatu1 = recid(tt-simula).
                end.
                leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-simula
                    then leave.
                    recatu1 = recid(tt-simula).
                end.
                leave.
        end.
        if keyfunction(lastkey) = "cursor-down"
        then do:
                run leitura (input "down").
                if not avail tt-simula
                then next.
                color display white/red tt-simula.fincod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
                run leitura (input "up").
                if not avail tt-simula
                then next.
                color display white/red tt-simula.fincod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
        end.
 
        if keyfunction(lastkey) = "end-error"
        then do:
            vfincod = ?.
            leave bl-princ.
        end.
        if keyfunction(lastkey) = "return"
        then do:
            vfincod = tt-simula.fincod.
            leave bl-princ.
        end.
        run frame-a.
        recatu1 = recid(tt-simula).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame frame-a no-pause.
return.

procedure frame-a.
display tt-simula.fincod      column-label "Plano"
        tt-simula.finnom
        tt-simula.par-sem-seg column-label "Parcela"
        tt-simula.par-com-seg column-label "C/Seguro" 
            when tt-simula.par-com-seg > 0
        with frame frame-a 11 down column 20 row 5
        overlay.
end procedure.
procedure color-message.
color display message
        tt-simula.fincod
        tt-simula.finnom
/*        tt-simula.par-com-seg*/
        /*tt-simula.par-sem-seg*/
        with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        tt-simula.fincod
        tt-simula.finnom
/*        tt-simula.par-com-seg*/
        /*tt-simula.par-sem-seg*/
        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first tt-simula use-index i2 where true
                                                no-lock no-error.
    else  
        find last tt-simula  use-index i2 where true
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next tt-simula use-index i2 where true
                                                no-lock no-error.
    else  
        find prev tt-simula use-index i2  where true
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev tt-simula use-index i2 where true  
                                        no-lock no-error.
    else   
        find next tt-simula use-index i2 where true 
                                        no-lock no-error.
        
end procedure.
         
