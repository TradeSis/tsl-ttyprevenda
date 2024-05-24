/* bag 102022 - helio */
def new shared var vapiconsultarproduto as log format "Ligado/Desligado".

{admcab.i}
{bagdefs.i}
{dftempWG.i new}
{baginc-def-pre.i new}
{garan-rfq.i new}

def var vpassa as log.
def var vf5 as log.
def var vliqui as dec.
def var ventra-ori as dec.
def var vplano-ori as int.
def var ventra as dec.
def var vparce as dec.
def var vmen-pla as char.
def var block-plano as log init no.

def var vparam-WG as char.
def var perc-desc as dec.
def buffer fprodu for produ.

def buffer cttitens for ttitens.
def var varquivo as char.
def var vpdf as char no-undo.

def new shared var etb-entrega like setbcod.
def new shared var dat-entrega as date.
def new shared var dat-entrega1 as date.
def new shared var p-dtentra as date.
def new shared var p-dtparcela as date.
def new shared var nome-retirada as char format "x(30)".
def new shared var fone-retirada as char format "x(15)".
def new shared temp-table tt-liped like com.liped.
def new shared temp-table tt-senauto
    field procod     like produ.procod
    field preco-ori  like movim.movpc
    field desco      as   log init no
    field senauto    as   dec format ">>>>>>>>>>"
    index i-pro is primary unique procod.
def new shared temp-table tt-prodesc
    field procod     like produ.procod
    field preco      like movim.movpc
    field preco-ven  like movim.movpc
    field desco  as   log.
def new shared temp-table Black_Friday
    field numero as int
    field valor as dec
    field desconto as log init no
    field pctdes as dec.    
def new shared temp-table tt-cartpre
    field seq    as int
    field numero as int
    field valor  as dec.
def new shared temp-table tt-planos-vivo
    field procod like produ.procod
    field tipviv as   int
    field codviv as   int
    field pretab as   dec
    field prepro as   dec.
def new shared temp-table wf-imei
    field wrec      as recid
    field imei      as char.
    
def new shared var pmoeda as char format "x(30)".
def new global shared var vpromocod   as char. /* helio 09032022 - [ORQUESTRA 243179 - ESCOPO ADICIONAL] Seleção de moeda a vista na Pré-Venda  */
vpromocod = "".

def var vpromocavista as log.

def NEW shared temp-table tt-seguroPrestamista no-undo
    field wrec          as recid
    field procod        as int.
def var par-valor as char. 
def var vseq as int.

{bagseguroprest.i}
vende-seguro = no.
run lemestre.p (input "VENDE-SEGURO", output par-valor).     
vende-seguro = par-valor = "SIM".


def var vmoecod like moeda.moecod.
def var ventradadiferenciada as log.
def var libera-plano as log.

def input param pcpf as dec format "99999999999".
def input param pidbag  as int.

/* uso do promo-venda.p */
def var vtextopromocao as char.
def var parametro-in as char.
def var parametro-out as char.
def var vlibera as log.
def var vpromoc as char.

def new shared temp-table tt-valpromo
    field tipo   as int
    field forcod as int
    field nome   as char
    field valor  as dec
    field recibo as log 
    field despro as char
    field desval as char.
def new shared var vdata-teste-promo as date init ?.

/* uso do promo-venda.p */
 
def buffer bttitens for ttitens.
def var vsalvar as log.

def var presposta as char.
def var phttp_code as int.


def var ctitle as char.



def var vhelp as char.
def var xtime as int.
def var vconta as int.
def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(14)" extent 7
    initial ["venda","digita","trocar","elimina","salva","fecha venda","ret sem venda"] .
form
    esqcom1[1] format "x(7)"
    esqcom1[2] format "x(7)"
    esqcom1[3] format "x(7)"
    esqcom1[4] format "x(7)"
    esqcom1[5] format "x(7)"
    esqcom1[6] 
    esqcom1[7] 
    
    with frame f-com1 row 6 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

form
        ttitens.sequencial format ">>>9" column-label "seq"
        ttitens.codigoProduto column-label "codigo" format ">>>>>>>>9"
        produ.pronom column-label "nome produto" format "x(20)"
        ttitens.quantidade format ">>>9" column-label "qtd"

        ttitens.quantidadeConvertida format ">>>9" column-label "qtd!vendida"
        ttitens.valorUnitario format ">>>9.99" column-label "preco"
        ttitens.valorLiquido  format ">>>9.99" column-label "promo"
        
        ttitens.valorTotalConvertida format ">>>>9.99" column-label "total!vendido"

        with frame frame-a 7 down centered row 7
        no-box.


    disp 
        ctitle format "x(70)" no-label
        with frame ftit
            side-labels
            row 5
            centered
            no-box
            color messages.


empty temp-table ttbag.
empty temp-table ttitens.

run bagapiresgatabag.p (setbcod, pcpf, pidbag , output phttp_code, output presposta).    

    
if phttp_code <> 200
then do on endkey undo, retry:
    message phttp_code presposta.
    pause.
    return.
end.

find first ttbag where ttbag.estaborigem = setbcod and
                           ttbag.idbag   = pidbag and 
                           ttbag.cpf     = pcpf
                           no-lock.

ctitle = "VENDA DA BAG " + string(pidbag) + " - " + string(ttbag.cpf,"99999999999") + " " + ttbag.nome.
    disp 
        ctitle 
        with frame ftit.



recatu1 = ?.
def var vtotalvenda as dec.
bl-princ:
repeat:
    vtotalvenda = 0.
    for each bttitens.
        if bttitens.valorTotalConvertida <> ?
        then vtotalvenda = vtotalvenda + bttitens.valorTotalConvertida.
    end.    

    disp vtotalvenda label "Total Vendido" colon 60 with frame ftotal row 20 no-box centered side-labels.
        

    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find ttitens where recid(ttitens) = recatu1 no-lock.
    if not available ttitens
    then do.
        run pdigita.

                find first ttitens where ttitens.quantidadeconvertida <> ? no-error.
                if not avail ttitens
                then return.
                recatu1 = ?.
                next.

    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(ttitens).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available ttitens
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find ttitens where recid(ttitens) = recatu1 no-lock.
      /*
        find first bttitens where 
                recid(bttitens) <> recatu1 and
                bttitens.quantidadeconvertida <> ? no-error. 
        esqcom1[1] = "venda".
        
        if ttitens.quantidadeConvertida = ttitens.quantidade and not avail bttitens
        then esqcom1[1] = "".
      */  
        status default "".
        /*
        def var vx as int.
        def var va as int.
        va = 1.
        do vx = 1 to 6.
            if esqcom1[vx] = ""
            then next.
            esqcom1[va] = esqcom1[vx].
            va = va + 1.  
        end.
        vx = va.
        do vx = va to 6.
            esqcom1[vx] = "".
        end.     
        */
    hide message no-pause.
        
        find first bttitens where bttitens.quantidadeconvertida <> ? and bttitens.quantidadeconvertida > 0 no-error.
        if avail bttitens then esqcom1[7] = "". else esqcom1[7] = "ret sem venda".
        find first bttitens where bttitens.quantidadeconvertida <> ? and bttitens.quantidadeconvertida > 0 no-error.
        if not avail bttitens then esqcom1[6] = "". else esqcom1[6] = "fecha venda".
        
        
        disp esqcom1 with frame f-com1.
        
        run color-message.

        vhelp = "".
        
        
        status default vhelp.
        choose field ttitens.sequencial
                      help "(a) descontos de funcionario"
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      L l A a
                      tab PF4 F4 ESC return).

        if keyfunction(lastkey) <> "return"
        then run color-normal.

        hide message no-pause.
                 
        pause 0. 

        if keyfunction(lastkey) = "A"
        then do:
            run pdesconto.        
        end.
                                                                
            if keyfunction(lastkey) = "cursor-right"
            then do:
                color display normal esqcom1[esqpos1] with frame f-com1.
                esqpos1 = if esqpos1 = 7 then 7 else esqpos1 + 1.
                color display messages esqcom1[esqpos1] with frame f-com1.
                next.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                color display normal esqcom1[esqpos1] with frame f-com1.
                esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                color display messages esqcom1[esqpos1] with frame f-com1.
                next.
            end.
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail ttitens
                    then leave.
                    recatu1 = recid(ttitens).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail ttitens
                    then leave.
                    recatu1 = recid(ttitens).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail ttitens
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail ttitens
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then do:
            hide message no-pause.
            if vsalvar
            then do:
                sresp = yes.
                message "SALVAR bag?" UPDATE SRESP.
                if sresp then run psalva.                
            end.
            leave bl-princ.
        end.    
                
                
        if keyfunction(lastkey) = "return"
        then do:
            
             if esqcom1[esqpos1] = "venda"
             then do on endkey undo,retry: 
                run pvenda.
                vsalvar = yes.     
                leave.           
            end. 
             if esqcom1[esqpos1] = "digita"
             then do: 
                run pdigita.
                recatu1 = ?.
                leave.
            end.
             if esqcom1[esqpos1] = "trocar"
             then do: 
                run ptroca.
                recatu1 = ?.
                leave.
            end.
            

                /*
             if esqcom1[esqpos1] = "altera"
             then do: 
                update ttitens.quantidadeConvertida with frame frame-a.
                vsalvar = yes.
            end. 
            */
            
            if esqcom1[esqpos1] = "elimina"
            then do: 
                sresp = no.
                message "confirma?" update sresp.
                if sresp
                then do:
                    vsalvar = yes.
                    ttitens.quantidadeconvertida = ?.
                    ttitens.valortotalconvertida = ?.
                    if ttitens.quantidade = ? then delete ttitens.
                    clear frame frame-a all no-pause.
                    recatu1 = ?.
                    leave.
                end.
            end.
            if esqcom1[esqpos1] = "salva"
            then do: 
                run psalva.
                hide frame f-com1 no-pause.
                hide frame frame-a no-pause.
                hide frame ftotal no-pause.
                return.
            end.
            if esqcom1[esqpos1] = "fecha venda"
            then do: 
                run pfechavenda.
                hide frame f-com1 no-pause.
                hide frame frame-a no-pause.
                hide frame ftotal no-pause.
                return.
            end.
            if esqcom1[esqpos1] = "ret sem venda"
            then do: 
                sresp = no.
                message "confirma retorno da bag sem venda?" update sresp.
                if sresp
                then do:
                    run pfechasemvenda.
                    hide frame f-com1 no-pause.
                    hide frame frame-a no-pause.
                    hide frame ftotal no-pause.
                    return.
                end.
            end.
            
            
            
            
        end.        
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(ttitens).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.
hide frame ftit no-pause.
hide frame ftot no-pause.
hide frame ftotal no-pause.
return.
 
procedure frame-a.
    find produ where produ.procod = ttitens.codigoProduto no-lock no-error.
    display  
        ttitens.sequencial
        produ.pronom when avail produ
        ttitens.codigoProduto
        ttitens.quantidadeConvertida when ttitens.quantidadeConvertida <> ?
        ttitens.quantidade
        ttitens.valorUnitario
        ttitens.valorLiquido
        
        ttitens.valorTotalConvertida
        with frame frame-a.


end procedure.

procedure color-message.
    color display message
        ttitens.sequencial
        produ.pronom 
        ttitens.codigoProduto
        ttitens.quantidadeConvertida
        ttitens.quantidade
    
        with frame frame-a.
end procedure.


procedure color-input.
    color display input
        ttitens.sequencial
        produ.pronom 
        ttitens.codigoProduto
        ttitens.quantidadeConvertida
        ttitens.quantidade
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        ttitens.sequencial
        produ.pronom 
        ttitens.codigoProduto
        ttitens.quantidadeConvertida
        ttitens.quantidade
 
        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.

    if par-tipo = "pri" 
    then do:
        find last ttitens where ttitens.trocado = 0
            no-lock no-error.
    end.    
                                             
    if par-tipo = "seg" or par-tipo = "down" 
    then do:
        find prev ttitens  where ttitens.trocado = 0
            no-lock no-error.
    end.    
             
    if par-tipo = "up" 
    then do:
        find next ttitens where ttitens.trocado = 0
            no-lock no-error.

    end.  
        
end procedure.





procedure psalva.

    find first ttitens no-error.
    
    if avail ttitens
    then do:
        run bagapisalva.p (setbcod, pidbag, pcpf, ttitens.catcod, output phttp_code, output presposta).    
        if phttp_code = 200
        then vsalvar = no.
    end.        

end procedure.

procedure pfechavenda .
def var vok as log.
        for each ttitens where ttitens.quantidadeconvertida = ?.
            ttitens.quantidadeconvertida = 0.
        end.    
        
            for each wf-movim.
                delete wf-movim.
            end.    
            vprotot = 0.
            for each ttitens where ttitens.quantidadeconvertida > 0.
                find produ where produ.procod = ttitens.codigoProduto no-lock.
                find first wf-movim where wf-movim.wrec = recid(produ)
                                    no-lock no-error.
                if not avail wf-movim
                then do:
                    create wf-movim.
                    wf-movim.wrec  = recid(produ).
                    wf-movim.movalicms = 17.
                    wf-movim.movqtm = ttitens.quantidadeconvertida.
                    wf-movim.precoori = ttitens.valorUnitario. /* helio 07062023 - trocado para precoori */
                    wf-movim.movpc = ttitens.valorliquido. /* helio 07062023 - trocado para valorLiquido */
                    wf-movim.vencod = ttbag.consultor.
                    vprotot = vprotot + (ttitens.valorUnitario * ttitens.quantidadeconvertida).
                end.     
            end.
    
            v-serie = "P". 
            vok = no.
            
            bl-plano:
            do on error undo.
            
                {inc-fim-pre-bag.i}
                           
            end.
            if vok
            then run bagapifechavenda.p (setbcod, pcpf,  input pidBAG, output phttp_code, output presposta).    
        
       /*
        if phttp_code = 200
        then do:
            vsalvar = no.
            message "BAG" skip(2)
            pidBAG
            skip(2)
            "VENDA CONCLUIDA"
            view-as alert-box.
        
        end.            
        */

end procedure.

procedure pfechasemvenda .

        for each ttitens where ttitens.quantidadeconvertida = ?.
            ttitens.quantidadeconvertida = 0.
        end.    
        
        
        run bagapifechavenda.p (setbcod, pcpf,  input pidBAG, output phttp_code, output presposta).    
        

end procedure.





/*
procedure gercpg:
    
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
    
    assign
        vliqui = 0
        vparce = 0
        vprodu = 0
        vmovpc = 0
        vbrinde = 0
        vconf  = yes.
    
    sretorno = "".
    if ventradadiferenciada
    then sretorno = "Entrada=" + string(ventra).
    else ventra = 0.    
    vprotot = 0.
    for each wf-movim:
        find produ where recid(produ) = wf-movim.wrec no-lock no-error.
        if not avail produ then next.

        /*find first tt-seguroPrestamista where tt-seguroPrestamista.wrec = wf-movim.wrec no-error.
        if avail tt-seguroPrestamista
        then next.*/
        
        if vprodu = 0 or
           wf-movim.movpc > vmovpc
        then vprodu = produ.procod.
        if wf-movim.movpc = 1
        then vbrinde = vbrinde + (wf-movim.movpc * wf-movim.movqtm).
        if produ.catcod <> 41
        then vconf = no.
        vprotot = vprotot + (wf-movim.movpc * wf-movim.movqtm).
    end.       
    
    if true or vconf or ventradadiferenciada
    then do:

        run gercpg1.p( input vfincod, 
                           input vprotot, 
                           input vdevval, 
                           input vbonus, 
                           output vliqui, 
                           output ventra,
                           output vparce). 

    end.
/*BAG    else
    for each wf-movim:
        find produ where recid(produ) = wf-movim.wrec no-lock no-error.
        if not avail produ then next.

        /*find first tt-seguroPrestamista where tt-seguroPrestamista.wrec = wf-movim.wrec no-error.
        if avail tt-seguroPrestamista
        then next.*/
    
        if wf-movim.movpc = 1 then next.
        
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
    BAG*/
end procedure.

*/






procedure pvenda.


/* bloco do wf-pre */  
        find produ where produ.procod = ttitens.codigoproduto no-lock.
        find estoq where estoq.procod = produ.procod and
                         estoq.etbcod = setbcod no-lock.
                                            
                def var valt as int.
                valt = ttitens.quantidadeConvertida.
                
                if ttitens.quantidadeConvertida = ?
                then do:
                    ttitens.quantidadeConvertida = ttitens.quantidade.
                    if ttitens.quantidadeConvertida > 1
                    then update ttitens.quantidadeConvertida with frame frame-a.
                end.
                else do:
                    update ttitens.quantidadeConvertida with frame frame-a.
                end.
                if ttitens.quantidade <> ?
                then
                if ttitens.quantidadeConvertida > ttitens.quantidade
                then do:
                    sresp = yes.
                    message "quantidade maior que o que estava na bag, confirma?" update sresp.
                    if not sresp
                    then do:
                        ttitens.quantidadeConvertida = valt.
                        disp ttitens.quantidadeConvertida with frame frame-a.
                        
                    end.
                end.
        
                vpreco = estoq.estvenda.
                vtextopromocao = "".
                if estoq.estbaldat <> ? and
                   estoq.estprodat <> ?
                then do:
                    if estoq.estbaldat <= today and
                       estoq.estprodat >= today
                    then do:
                        vpreco = estoq.estproper.   
                        vtextopromocao = "Preco Promocional de " + string(estoq.estbaldat,"99/99/9999") + " ate " + string(estoq.estprodat,"99/99/9999") + " R$ " +
                                        trim(string(estoq.estproper,"->>>>>>>>>>9.99")).
                    end.    
                end.
                else do:
                    if estoq.estprodat <> ?
                    then if estoq.estprodat >= today
                         then do:
                            vpreco = estoq.estproper.
                            vtextopromocao = "Preco Promocional ate " + string(estoq.estprodat,"99/99/9999") + " R$ " +
                                        trim(string(estoq.estproper,"->>>>>>>>>>9.99")).

                         end.   
                end.

                /*** PRECO ESPECIAL ***/

                        parametro-in = "PRECO-ESPECIAL=S|PRODUTO=" +
                                    string(produ.procod) + "|".
                        run promo-venda.p(input parametro-in ,
                                          output parametro-out).
                        if acha("LIBERA-PRECO",parametro-out) <> ?
                        then vlibera = yes.
                        if acha("PRECO-ESPECIAL",parametro-out) <> ? and
                            dec(acha("PRECO-ESPECIAL",parametro-out)) > 0
                        then vpreco = dec(acha("PRECO-ESPECIAL",parametro-out)).

                        if acha("PROMOCAO",parametro-out) <> ? 
                        then vpromoc = acha("promocao",parametro-out).
                        else vpromoc = "".
            hide message no-pause.
                           
            ttitens.valorunitario = estoq.estvenda.
            ttitens.valorliquido = if ttitens.valorliquido = 0 then vpreco else ttitens.valorliquido.
            ttitens.descontoproduto  = (ttitens.valorunitario - ttitens.valorliquido) * ttitens.quantidadeconvertida.
            ttitens.valortotalconvertida = ttitens.valorliquido * ttitens.quantidadeconvertida.        
            
              
             
            disp ttitens.valorliquido ttitens.valortotalconvertida
            ttitens.quantidadeconvertida
            with frame frame-a.
        
        /* fim bloco do wf-pre */
        


end procedure.



procedure pdigita.
hide frame f-com1 no-pause.
def var vprocod like produ.procod format ">>>>>>>>9".
def var vqtd like ttitens.quantidade.
def var vpreco as dec.
def var vtextopromocao as char.
def var parametro-in as char.
def var parametro-out as char.
def var vlibera as log.
def var vpromoc as char.

    form
        vprocod
        produ.pronom format "x(30)" no-label
        ttitens.quantidadeConvertida label "Quantidade"
        with frame fdigita
        row 6
        1 down
        centered
        side-labels
        color messages.

    repeat with frame fdigita.
        
        
        update vprocod.
        find produ where produ.procod = vprocod no-lock no-error.
        if not avail produ
        then do:
            hide message no-pause.
            message "produto nao cadastrado".
            undo.
            
        end.                          
        
        run pdvapiconsultarproduto.p (setbcod, produ.procod).
        
        disp produ.pronom.
        if produ.catcod <> 41
        then do:
                hide message no-pause.
                message "categoria do produto invalida para bag".
                undo.
        end.
                
        /* validacoes do wf-pre */
        if produ.proseq = 99 
        then do: 
            hide message no-pause.
            message "Venda bloqueada para produto INATIVO." view-as alert-box.  
            undo. 
        end.
                if produ.descontinuado 
                then do: 
                    sresp = no. 
                    run message.p  
                        (input-output sresp,  
                        input     "          PRODUTO DESCONTINUADO.        "  + 
                        "                                        "  +     
                        "    Só seguir com a venda se o mesmo    "  + 
                        " estiver disponível no estoque na loja. "   + 
                        "                                        "  + 
                        "                CONTINUAR ?             ", 
                        input "").          
                    if sresp = no  
                    then undo. 
                end. 

        /* fim validacoes do wf-pre */

        
        
        if int(ttbag.categoria) = 0
        then do:
            find first bttitens where bttitens.codigoproduto <> vprocod no-error.
            if avail bttitens
            then do:
                if bttitens.catcod <> produ.catcod
                then do:
                    hide message no-pause.
                    message "categoria do produto invalida para esta bag".
                    undo.
                end.
            end.
        end.
        else do:
            if int(ttbag.categoria) <> produ.catcod
            then do:
                hide message no-pause.
                message "categoria do produto invalida para esta bag".
                undo.
            end.
       end.
            find estoq where estoq.procod = produ.procod
                         and estoq.etbcod = setbcod
                       no-lock no-error. 
            if not available estoq 
            then do: 
                message "Sem registro de ESTOQUE/PRECO" view-as alert-box. 
                next. 
            end.
        
        find first ttitens where ttitens.codigoproduto = vprocod no-error.
        if not avail ttitens
        then do:
            find last ttitens no-error.
            vseq = if avail ttitens then ttitens.sequencial + 1 else 1.
            create ttitens.
            ttitens.sequencial = vseq.
            ttitens.codigoproduto = vprocod.
            ttitens.catcod = produ.catcod.
            ttitens.quantidade = ?.
            ttitens.quantidadeConvertida = 0. 
        end.
        if ttitens.quantidadeConvertida = ? then ttitens.quantidadeConvertida = 0.
        ttitens.quantidadeConvertida = ttitens.quantidadeConvertida + 1.
        
        /* bloco do wf-pre */  
        
                vpreco = estoq.estvenda.
                vtextopromocao = "".
                if estoq.estbaldat <> ? and
                   estoq.estprodat <> ?
                then do:
                    if estoq.estbaldat <= today and
                       estoq.estprodat >= today
                    then do:
                        if estoq.estproper > 0 then vpreco = estoq.estproper.   
                        vtextopromocao = "Preco Promocional de " + string(estoq.estbaldat,"99/99/9999") + " ate " + string(estoq.estprodat,"99/99/9999") + " R$ " +
                                        trim(string(estoq.estproper,"->>>>>>>>>>9.99")).
                    end.    
                end.
                else do:
                    if estoq.estprodat <> ?
                    then if estoq.estprodat >= today
                         then do:
                            if estoq.estproper > 0 then vpreco = estoq.estproper.   
                            vtextopromocao = "Preco Promocional ate " + string(estoq.estprodat,"99/99/9999") + " R$ " +
                                        trim(string(estoq.estproper,"->>>>>>>>>>9.99")).

                         end.   
                end.

                /*** PRECO ESPECIAL ***/

                        parametro-in = "PRECO-ESPECIAL=S|PRODUTO=" +
                                    string(produ.procod) + "|".
                        run promo-venda.p(input parametro-in ,
                                          output parametro-out).
                        if acha("LIBERA-PRECO",parametro-out) <> ?
                        then vlibera = yes.
                        if acha("PRECO-ESPECIAL",parametro-out) <> ? and
                            dec(acha("PRECO-ESPECIAL",parametro-out)) > 0
                        then do:
                            if dec(acha("PRECO-ESPECIAL",parametro-out)) <> ? and dec(acha("PRECO-ESPECIAL",parametro-out)) > 0
                            then vpreco = dec(acha("PRECO-ESPECIAL",parametro-out)).
                        end.    

                        if acha("PROMOCAO",parametro-out) <> ? 
                        then vpromoc = acha("promocao",parametro-out).
                        else vpromoc = "".
                                
            ttitens.valorunitario = estoq.estvenda.                                       
            ttitens.valorliquido = if ttitens.valorliquido = 0 then vpreco else ttitens.valorliquido.
            ttitens.descontoproduto  = (ttitens.valorunitario - ttitens.valorliquido) * ttitens.quantidadeconvertida.
            ttitens.valortotalconvertida = ttitens.valorliquido * ttitens.quantidadeconvertida.        

            disp ttitens.valorunitario ttitens.valorliquido ttitens.valortotalconvertida
            ttitens.quantidadeconvertida
            with frame frame-a.
        
        
        /* fim bloco do wf-pre */
        
        
        
        vsalvar =  yes.
        pause 0.
        disp           ttitens.quantidadeConvertida.
                       
            recatu1 = ?.
            run leitura (input "pri").
            clear frame frame-a all no-pause.
            run frame-a.
            recatu1 = recid(ttitens).
            repeat:
                run leitura (input "seg").
                if not available ttitens
                then leave.
                if frame-line(frame-a) = frame-down(frame-a)
                then leave.
                down with frame frame-a.
                run frame-a.
            end.
        
        
    end.

    hide frame fdigita no-pause.

end procedure.



procedure ptroca.
hide frame f-com1 no-pause.
def var vprocod like produ.procod format ">>>>>>>>9".
def var vseq as int.
def var vqtd like ttitens.quantidade.
def var vpreco as dec.
def var vtextopromocao as char.
def var parametro-in as char.
def var parametro-out as char.
def var vlibera as log.
def var vpromoc as char.
def var vtrocado as int.
def var vtrocar as int.
    form
        vprocod
        produ.pronom format "x(30)" no-label
        ttitens.quantidadeConvertida label "Quantidade"
        with frame fdigita
        row 6
        1 down
        centered
        side-labels
        color messages.
    
    find cttitens where recid(cttitens) = recid(ttitens).
    
    vtrocado = ttitens.codigoproduto.
    
    vtrocar = 0.
    
    repeat with frame fdigita.
        
        
        update vprocod.
        find produ where produ.procod = vprocod no-lock no-error.
        if not avail produ
        then do:
            hide message no-pause.
            message "produto nao cadastrado".
            undo.
            
        end.                          
        
        if vtrocar = 0  then do:
            find first ttitens where ttitens.codigoproduto = vprocod no-error.
            if avail ttitens
            then do:
                message "produto ja esta na bag".
                undo.
            end.    
            vtrocar = vprocod.
        end.    
        
        if vtrocar <> vprocod
        then do:
            hide message no-pause.
            message "nao pode trocar por outro produto".
            undo.
        end.
        
        run pdvapiconsultarproduto.p (setbcod, produ.procod).
        
        disp produ.pronom.
        if produ.catcod <> 41
        then do:
                hide message no-pause.
                message "categoria do produto invalida para bag".
                undo.
        end.
                
        /* validacoes do wf-pre */
        if produ.proseq = 99 
        then do: 
            hide message no-pause.
            message "Venda bloqueada para produto INATIVO." view-as alert-box.  
            undo. 
        end.
                if produ.descontinuado 
                then do: 
                    sresp = no. 
                    run message.p  
                        (input-output sresp,  
                        input     "          PRODUTO DESCONTINUADO.        "  + 
                        "                                        "  +     
                        "    Só seguir com a venda se o mesmo    "  + 
                        " estiver disponível no estoque na loja. "   + 
                        "                                        "  + 
                        "                CONTINUAR ?             ", 
                        input "").          
                    if sresp = no  
                    then undo. 
                end. 

        /* fim validacoes do wf-pre */

        
        
        if int(ttbag.categoria) = 0
        then do:
            find first bttitens where bttitens.codigoproduto <> vprocod no-error.
            if avail bttitens
            then do:
                if bttitens.catcod <> produ.catcod
                then do:
                    hide message no-pause.
                    message "categoria do produto invalida para esta bag".
                    undo.
                end.
            end.
        end.
        else do:
            if int(ttbag.categoria) <> produ.catcod
            then do:
                hide message no-pause.
                message "categoria do produto invalida para esta bag".
                undo.
            end.
       end.
            find estoq where estoq.procod = produ.procod
                         and estoq.etbcod = setbcod
                       no-lock no-error. 
            if not available estoq 
            then do: 
                message "Sem registro de ESTOQUE/PRECO" view-as alert-box. 
                next. 
            end.

        cttitens.trocado = vtrocado.
        
        find first ttitens where ttitens.codigoproduto = vprocod no-error.
        if not avail ttitens
        then do:
            find last ttitens no-error.
            vseq = if avail ttitens then ttitens.sequencial + 1 else 1.
            create ttitens.
            ttitens.sequencial = vseq.
            ttitens.codigoproduto = vprocod.
            ttitens.catcod = produ.catcod.
            ttitens.quantidade = ?.
            ttitens.quantidadeConvertida = 0. 
        end.

        ttitens.quantidadeConvertida = ttitens.quantidadeConvertida + 1.
        
        /* bloco do wf-pre */  
        
                vpreco = estoq.estvenda.
                vtextopromocao = "".
                if estoq.estbaldat <> ? and
                   estoq.estprodat <> ?
                then do:
                    if estoq.estbaldat <= today and
                       estoq.estprodat >= today
                    then do:
                        if estoq.estproper > 0 then vpreco = estoq.estproper.   
                        vtextopromocao = "Preco Promocional de " + string(estoq.estbaldat,"99/99/9999") + " ate " + string(estoq.estprodat,"99/99/9999") + " R$ " +
                                        trim(string(estoq.estproper,"->>>>>>>>>>9.99")).
                    end.    
                end.
                else do:
                    if estoq.estprodat <> ?
                    then if estoq.estprodat >= today
                         then do:
                            if estoq.estproper > 0 then vpreco = estoq.estproper.   
                            vtextopromocao = "Preco Promocional ate " + string(estoq.estprodat,"99/99/9999") + " R$ " +
                                        trim(string(estoq.estproper,"->>>>>>>>>>9.99")).

                         end.   
                end.

                /*** PRECO ESPECIAL ***/

                        parametro-in = "PRECO-ESPECIAL=S|PRODUTO=" +
                                    string(produ.procod) + "|".
                        run promo-venda.p(input parametro-in ,
                                          output parametro-out).
                        if acha("LIBERA-PRECO",parametro-out) <> ?
                        then vlibera = yes.
                        if acha("PRECO-ESPECIAL",parametro-out) <> ? and
                            dec(acha("PRECO-ESPECIAL",parametro-out)) > 0
                        then do:
                            if dec(acha("PRECO-ESPECIAL",parametro-out)) <> ? and dec(acha("PRECO-ESPECIAL",parametro-out)) > 0
                            then vpreco = dec(acha("PRECO-ESPECIAL",parametro-out)).
                        end.    

                        if acha("PROMOCAO",parametro-out) <> ? 
                        then vpromoc = acha("promocao",parametro-out).
                        else vpromoc = "".
                                       
            ttitens.valorunitario = vpreco.

            ttitens.valortotalconvertida = ttitens.valorunitario * ttitens.quantidadeconvertida.        
            disp ttitens.valorunitario ttitens.valortotalconvertida
            ttitens.quantidadeconvertida
            with frame frame-a.
        
        
        /* fim bloco do wf-pre */
        
        
        
        vsalvar =  yes.
        pause 0.
        disp           ttitens.quantidadeConvertida.
                       
            recatu1 = ?.
            run leitura (input "pri").
            clear frame frame-a all no-pause.
            run frame-a.
            recatu1 = recid(ttitens).
            repeat:
                run leitura (input "seg").
                if not available ttitens
                then leave.
                if frame-line(frame-a) = frame-down(frame-a)
                then leave.
                down with frame frame-a.
                run frame-a.
            end.
        
        
    end.

    hide frame fdigita no-pause.

end procedure.





procedure pdesconto.

def var vescd as char format "x(15)" extent 1
                 init [/*"1. Valor     ", "2. Percentual",*/ "Funcionário"].
def var vtipo-desc as int.
                
                vtipo-desc = 0.
                display vescd no-label 
                    with frame f-escd centered row 9 overlay
                        title " DESCONTO ".
                
                choose field vescd with frame f-escd.
                
                vtipo-desc = frame-index. /*1=Valor/2=Percentual/3=Funcionario*/
                vtipo-desc = 3. /* fixo por enquanto */
                
                hide frame f-escd no-pause.
                
                    if vtipo-desc = 3
                    then do:
                        
                        find first tt-descfunc no-lock no-error.
                        if not avail tt-descfunc
                        then do:
                            vparam-WG = string(pcpf,"99999999999").
                            run agil4_WG.p (input "descfunc",  input vparam-WG). 
                            if conecta-ok = no 
                            then do:
                                hide message no-pause.
                                message "sem conexao com a matriz".
                                undo.
                            end.                            
                            find first tt-descfunc no-lock no-error.
                        end.
                        
                        if avail tt-descfunc
                            and tt-descfunc.tem_cadastro = no
                        then do:
                            message "CPF não cadastrado na base de Clientes, "
                                    "faça o cadastro e entre em contato "
                                    "com o RH para alterar o tipo "
                                    "para Funcionário" view-as alert-box.
                            return.
                        end.

                        if avail tt-descfunc
                            and tt-descfunc.tem_cadastro = yes
                            and tt-descfunc.tipo_funcionario = no
                        then do:
                            message "CPF não é de um funcionário."
                                        view-as alert-box.
                            return.
                        end.

                        if avail tt-descfunc
                            and tt-descfunc.tem_cadastro = yes
                            and tt-descfunc.tipo_funcionario = yes
                        then do:
                            do:
                                
                                find fprodu where fprodu.procod = ttitens.codigoProduto no-lock.
                                if fprodu.catcod = 31
                                then assign ttitens.valorLiquido = ttitens.valorUnitario
                                    - (ttitens.valorUnitario * tt-descfunc.desc31 / 100).
                                else if fprodu.catcod = 41
                                then assign ttitens.valorLiquido = ttitens.valorUnitario
                                    - (ttitens.valorUnitario * tt-descfunc.desc41 / 100).
                                
                                ttitens.descontoproduto  = (ttitens.valorunitario - ttitens.valorliquido) * ttitens.quantidadeconvertida.
                                ttitens.valortotalconvertida = ttitens.valorliquido * ttitens.quantidadeconvertida.        

                            end.
                                    
                            find tt-prodesc where   tt-prodesc.procod = fprodu.procod no-error.
                            if not avail tt-prodesc 
                            then do:
                                create tt-prodesc.
                                assign tt-prodesc.procod = fprodu.procod
                                       tt-prodesc.preco  = ttitens.valorUnitario
                                       tt-prodesc.preco-ven = ttitens.valorLiquido.
                            end.
                            if tt-prodesc.preco > ttitens.valorLiquido
                            then tt-prodesc.desco = yes.
                            else tt-prodesc.desco = no.

                        end.
                        
                    end. /* fim 3 */

 


end procedure.



procedure p-atu-frame.
    pause 0 before-hide.
    clear frame frame-a all no-pause.
    run leitura ("pri").
    run frame-a.

    recatu1 = recid(ttitens).
    repeat:
        run leitura (input "seg").
        if not available ttitens
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.
    vtotalvenda = 0.
    for each bttitens.
        if bttitens.valorTotalConvertida <> ?
        then vtotalvenda = vtotalvenda + bttitens.valorTotalConvertida.
    end.    

    disp vtotalvenda label "Total Vendido" colon 60 with frame ftotal row 20 no-box centered side-labels.
    pause before-hide.
end procedure.



procedure gercpg:
    
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
    assign
        vliqui = 0
        vparce = 0
        vprodu = 0
        vmovpc = 0
        vbrinde = 0
        vconf  = yes.
    vbonus = 0.
        
    sretorno = "".
    if ventradadiferenciada
    then sretorno = "Entrada=" + string(ventra).
    else ventra = 0.    
    vprotot = 0.
    for each wf-movim:
        find produ where recid(produ) = wf-movim.wrec no-lock no-error.
        if not avail produ then next.

        /*find first tt-seguroPrestamista where tt-seguroPrestamista.wrec = wf-movim.wrec no-error.
        if avail tt-seguroPrestamista
        then next.*/
        
        if vprodu = 0 or
           wf-movim.movpc > vmovpc
        then vprodu = produ.procod.
        if wf-movim.movpc = 1
        then vbrinde = vbrinde + (wf-movim.movpc * wf-movim.movqtm).
        if produ.catcod <> 41
        then vconf = no.
        vprotot = vprotot + (wf-movim.movpc * wf-movim.movqtm).
    end.       
    
    if true /*BAGor vconf or ventradadiferenciada*/
    then do:
        run gercpg1.p( input vfincod, 
                           input vprotot, 
                           input vdevval, 
                           input vbonus, 
                           output vliqui, 
                           output ventra,
                           output vparce). 

    end.
    /*BAG
    else for each wf-movim:
        find produ where recid(produ) = wf-movim.wrec no-lock no-error.
        if not avail produ then next.

        /*find first tt-seguroPrestamista where tt-seguroPrestamista.wrec = wf-movim.wrec no-error.
        if avail tt-seguroPrestamista
        then next.*/
    
        if wf-movim.movpc = 1 then next.
        
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
        /*BAGparcela-especial = 0.*/

        message "TESTEHELIO 2 " vfincod wtot wdev wbon view-as alert-box .
        run gercpg1.p( input vfincod, 
                       input wtot, 
                       input wdev, 
                       input wbon, 
                       output wliq, 
                       output went,
                       output wpar).
        scli = 0.               
        
        /*BAGif parcela-especial > 0
        then wpar = parcela-especial.*/
        
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
    */
end procedure.




procedure mens-plano:
    def var vl as int.
    repeat while vl < 10:
        form vmp as char format "x(58)" with row 13
            column 23 no-box no-labels 
            frame f-mp overlay.
        color disp message vmp with frame f-mp.
        pause 1 no-message.
        disp vmen-pla @  vmp with frame f-mp.
        pause 1 no-message.
        hide frame f-mp no-pause.
        vl = vl + 1.
        if keyfunction(lastkey) = "RETURN"
        then leave.
    end.           
end procedure.

