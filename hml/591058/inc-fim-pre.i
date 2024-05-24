/* helio 02082023 - IDENTIFICAÇÃO VENDAS COM COTAS - PROCESSO 521965*/
/* helio 07062023 Demanda 328 - Liberação de Cotas + Módulos de promoção pré venda */
/* #042023 helio libera plano */
/* helio 10042023 - cashb por cliente */
/* helio 112022 - campanha seguro prestamista gratis */

/*
/* helio 09032022 - [ORQUESTRA 243179 - ESCOPO ADICIONAL] Seleção de moeda a vista na Pré-Venda  */

helio 09022022 - [ORQUESTRA 243179] Seleção de moeda a vista na Pré-Venda 
04.02.2020 helio.neto - 189 - cupom desconto
17.02.2020 helio.neto - 188
*/

def new shared var vplanocota as int. /* helio 02082023 */
def var vtemmodulo as log.
def var vtemmodulo-i as int.
def var vpassa as log.
def var vf5 as log.
def var vliqui as dec.
def var ventra-ori as dec.
def var vplano-ori as int.
def var ventra as dec.
def var vparce as dec.
def var vmen-pla as char.
def var block-plano as log init no.
for each ant-movim .
    delete ant-movim.
end.    
for each wf-movim no-lock:
    create ant-movim.
    buffer-copy wf-movim to ant-movim.
end.    


        do:
                def var pcpf        as dec init ?.
                def var par-valordescontocupom   as dec init 0.
                def var par-campanha as int.
                if avail clien
                then pcpf = dec(clien.ciccgc) no-error.
                
                
                if pcpf <> ?
                then do:
                    par-valordescontocupom = 0.
                    run vercupomsafe.p (input pcpf, 
                                                          output par-campanha,
                                                          output par-valordescontocupom).

                    if par-valordescontocupom <> 0 and par-valordescontocupom <> ?
                    then do:
                        def var vtotal as dec.
                        vtotal = 0.
                        for each wf-movim.
                            find produ where recid(produ) = wf-movim.wrec no-lock.
                            wf-movim.desconto = 0.
                            if produ.catcod = 31 or
                               produ.catcod = 41
                            then vtotal = vtotal + (wf-movim.movpc * wf-movim.movqtm).
                        end.
                    
                        message "Valor cupom Desconto" par-valordescontocupom "TOTAL" vtotal.
                        pause 1 no-message .
                        for each wf-movim.
                            find produ where recid(produ) = wf-movim.wrec no-lock.
                            if produ.catcod = 31 or
                               produ.catcod = 41
                            then .
                            else next.   

                            wf-movim.desconto = (wf-movim.movpc * wf-movim.movqtm) / vtotal * par-valordescontocupom.
                            /*
                            message wf-movim.desconto (wf-movim.movpc * wf-movim.movqtm)
                             wf-movim.desconto >= (wf-movim.movpc * wf-movim.movqtm).
                             pause.
                             */
                            if wf-movim.desconto >= (wf-movim.movpc * wf-movim.movqtm)
                            then wf-movim.desconto = 0.
                            else do:
                                wf-movim.movpc    = wf-movim.movpc - (wf-movim.desconto / wf-movim.movqtm). 
                            end.    
                        end.
                        find first wf-movim where wf-movim.desconto > 0 no-error.
                        if not avail wf-movim
                        then do:
                            hide message no-pause.
                            message "Valor do cupom do Desconto SUPERIOR ao total da venda".
                            pause 2 no-message.
                        end.
                        else do:
                            for each bwf-movim.
                                find produ where recid(produ) = bwf-movim.wrec no-lock.
                                if produ.catcod = 31 or
                                   produ.catcod = 41
                                then do:
                                   if vende-garan
                                   then run altera-segprod(produ.procod).
                                end.
                            end.      
                        end.

                        /*
                        *run p-atu-frame.
                        */
                    end.
                end.
        end.

         
do on error undo, retry  on endkey undo, leave with frame f-desti:
    clear frame f-condi all.
    hide frame f-condi no-pause.        
    repeat on endkey undo, leave bl-plano: 
        if vclicod = 1 then vclicod = 0.
        if keyfunction(lastkey) = "end-error"
        then do:  
            clear frame f-desti all no-pause.
            
            for each ant-movim no-lock:
                find first wf-movim where wf-movim.wrec = ant-movim.wrec
                        and wf-movim.KITproagr = ant-movim.KITproagr
                   no-error.
                if avail wf-movim
                then do:
                    buffer-copy ant-movim to wf-movim.
                end.
            end.
            run p-atu-frame.
            vcupomb2b = 0.
            vfincod = 0.
            
        end.       
        
        find first wf-movim where wf-movim.movalicms <> 98 /*GE/RFQ*/ no-error.
        if avail wf-movim  
        then do: 
            vmen-pla = "".
            vpromocod = "".   
            
            find produ where recid(produ) = wf-movim.wrec no-lock no-error. 
            if avail produ 
            then do: 
                parametro-in = "PLANO-DEFAULT=S|CATEGORIA=" +
                               string(produ.catcod) + "|".

                run promo-venda.p(input parametro-in ,
                               output parametro-out).  
                    
                if acha("PLANO-DEFAULT",parametro-out) <> ?
                then vfincod = int(acha("PLANO-DEFAULT",parametro-out)).
                if acha("MENSAGEM",parametro-out) <> ?
                then vmen-pla = acha("MENSAGEM",parametro-out).
                run ver-promocao.
                
                find finan where finan.fincod = vfincod no-lock no-error.
                if avail finan
                then disp finan.fincod @ vfincod 
                          finan.finnom with frame  f-desti.
                if vfincod > 0 
                then do:
                    assign
                        vliqui = 0
                        ventra = 0
                        vparce = 0.
                    
                    run seguroprestamista (finan.finnpc, vparce, v-vencod,
                                           output vsegtipo,
                                           output vsegprest,
                                           output vsegvalor).
                    /*
                    *run p-atu-frame.
                    */
                    run gercpg.
                    
                    display ventra at 20 label "Entrada" 
                            /*vparce + vsegprest @*/ vparce at 20 label "Parcela"  
                            with frame f-condi row 20  /*19*/
                                overlay 1 down column 43 no-box
                                color message side-label.
                end.
                
                if vmen-pla <> ""
                then do:
                    run mens-plano.
                    disp vmen-pla format "x(58)"
                         with 1 down row 13 color message
                         overlay no-box no-label column 23.       
                    pause 0.
                end. 
                
            end. 
        end.                  
       
        
                if search("tcupomb2b.p") <> ? 
                then do:
                    if vcupomb2b = 0
                    then do:
                        pause 0.
                        update vcupomb2b 
                            help "informe o numero de cupom de desconto, se o cliente for conveniado"
                            with frame f-desti.
                        
                        if vcupomb2b <> 0
                        then do:
                            run tcupomb2b.p (input vclicod). 
                            if vcupomb2b = 0
                            then undo.
                        end.
                    end.
                end.

        run p-atu-frame.
        if vmoecod = ""
        then do:
            find finan where finan.fincod = vfincod no-lock no-error.
            if avail finan
            then disp finan.fincod @ vfincod 
                      finan.finnom with frame f-desti.
            ventradadiferenciada = no.
            vplano-ori = vfincod.
            
            vplanocota = 0.
            update vfincod 
                help "F7 Pesquisa"
                go-on (C c F7 f7) 
                                with frame f-desti.  
            
            
            if lastkey = keycode("F7") or
               lastkey = keycode("f7")
            then do:
                
                run simula_parcela.p(input vprotot, 
                                     input vdevval, 
                                     input vbonus,
                                     input parcela-especial, 
                                     input ventradadiferenciada,
                                     output vfincod).
                if vfincod = ?
                then do:
                    vfincod = vplano-ori.
                    undo, retry.                     
                end.
            end.
            disp vfincod with frame f-desti.
            pause 0.

            /****************/            
            find finan where finan.fincod = vfincod no-lock no-error.  
            if not avail finan  
            then do:  
                message "Plano nao cadastrado".  
                pause.
                /*undo, retry.*/
                vfincod = 0.
                next. 
            end. 

            /* 17.02.2020 liberado GERAL para pascoa
                    if vfincod =47
                    or vfincod =51
                    or vfincod =54
                    or vfincod =55
                    or vfincod =60
                    or vfincod =61
                    or vfincod =66
                    or vfincod =69
                    or vfincod =72
                    or vfincod =80
                    or vfincod =89
                    or vfincod =91
                    or vfincod =99
               /*     or vfincod =108 - liberado para pascoa 03.03.2020 */
                    or vfincod =109
                    or vfincod =127
                    or vfincod =128
                    or vfincod =194
                    or vfincod =200
                    or vfincod =201
                then do:
                sresp = no.
                for each wf-movim :
                    find produ where recid(produ) = wf-movim.wrec no-lock.
                    if produ.clacod = 228010101 or
                       produ.clacod = 228010102 or
                       produ.clacod = 228010103 or
                       produ.clacod = 228010201 or
                       produ.clacod = 228010202 or
                       produ.clacod = 228010203 or
                       produ.clacod = 228010401 or
                       produ.clacod = 228010501 or
                       produ.clacod = 228010502                                                
        
                    then do:
                        sresp = yes.
                        leave.
                    end.
                end.
                if sresp
                then do:
                    message color red/with
                    "Plano invalido(pascoa)."
                    view-as alert-box.
                    undo, retry.
                end.
            end.
            pascoa **/

            
            if avail finan
               and finan.finnpc = 0
               and can-find(first tt-descfunc
                             where tt-descfunc.tem_cadastro = yes
                               and tt-descfunc.tipo_funcionario = yes)
            then do:
                message "Plano à vista não pode ser usado para vendas "
                        "com desconto para funcionário. "
                        "Selecione um plano de Crediário." view-as alert-box.
                undo, retry.
            end.
            
            pause 0.
            disp finan.fincod @ vfincod 
                 finan.finnom with frame f-desti.
            /*
            hide frame f-condi no-pause.
            clear frame f-condi all.
            */
            
            if vfincod > 0 
            then do:  
                assign
                    vliqui = 0
                    ventra = 0
                    vparce = 0.
                
                run gercpg.

                ventra-ori = ventra.
                repeat.
                    pause 0.
                    display 
                         ventra at 20 label "Entrada" 
                         /*vparce + vsegprest @*/ vparce at 20 label "Parcela"
                         with frame f-condi.
                    
                    sresp = yes.
                    
                    if p-alteraentrada and
                       finan.finent and
                       (finan.finnpc * finan.finfat) > 1
                    then do.
                        update ventra help "F4 confirma valor"
                               with frame f-condi.
                        if ventra entered
                        then do.
                            if ventra > 0 and
                               (ventra < ventra-ori or
                                ventra > vprotot)
                            then do.
                                message "Entrada invalida" view-as alert-box.
                                undo.
                            end.
                            sretorno = "".
                            if ventra > 0 and ventra <> ventra-ori
                            then assign
                                    sretorno = "Entrada=" + string(ventra)
                                    ventradadiferenciada = yes.
                            else ventradadiferenciada = no.
                            
                            run gercpg.
                        end.
                        else leave.
                    end.
                    else leave.
                end.
            end. 
        end.
        else do: 
            vfincod = 0.
            find finan where finan.fincod = vfincod no-lock no-error.  
            find moeda where moeda.moecod = vmoecod no-lock.
            pause 0.
            disp moeda.moecod @ vfincod 
                 moeda.moenom format "x(20)" @ finan.finnom with frame f-desti.
        end.
        val-prazo = 0.
        
        if vfincod > 0 
        then run val-prazo-promo.
        else do:
            run seguroprestamista (0, 0, 0,
                                    output vsegtipo,
                                    output vsegprest,
                                    output vsegvalor).

            for each wf-titulo: delete wf-titulo. end.
        end.

        if setbcod = 1133 or
           setbcod = 1185 or
           setbcod = 1142
        then do:
            run promo-filial33e85.
            run p-atu-frame.
        end.
        
        assign
            p-dtentra = ?
            p-dtparcela = ?
            libera-plano = no
                block-plano  = no.
                /* coloquei calcular o seguro assim que digita o plano */        
                    run seguroprestamista (finan.finnpc, vparce, v-vencod,
                                           output vsegtipo,
                                           output vsegprest,
                                           output vsegvalor).
            /*HELIO 1203
            *run p-atu-frame.
            */
            
            parametro-in = "LIBERA-PLANO=S|CASADINHA=S|GERA-CPG=S|"
                        + "PLANO=" + string(finan.fincod) + "|"
                        + "ALTERA-PRECO=S|".

            run promo-venda.p(input parametro-in ,
                              output parametro-out).

            vpromocaoLimite = "false".
            def var vpromocod-verificado as char. /* helio 15122023 - lentidao prevenda - rodando verificapromqtd 2 vezes */
            
            if vpromocod <> ""
            then do:
                vpromocod-verificado = vpromocod. /* helio 15122023 - lentidao prevenda - rodando verificapromqtd 2 vezes */
                for each wf-movim. 
                    if wf-movim.movalicms = 98 then next. /* helio 15122023 - lentidao prevenda - rodando verificapromqtd 2 vezes */
                    find produ where recid(produ) = wf-movim.wrec no-lock.
                    do vi = 1 to num-entries(vpromocod):
                        vpromoc = entry(vi,vpromocod).
                        {lojapi-verificapromqtd.i vpromoc produ.procod wf-movim.movqtm}
                        if vpromocaolimite = "true"
                        then leave.
                    end.                
                end.
            end.
            
            if acha("LIBERA-PLANO",parametro-out) <> ?
            then do:
                if acha("LIBERA-PLANO",parametro-out) = "S"
                then libera-plano = yes. 
                else block-plano = yes.
            end.

            /*if acha("PROMOCOD",parametro-out) <> ?
            then do:
                vpromocod = int(acha("PROMOCOD",parametro-out)).
            end.*/
            
            
            
            if acha("DATA-ENTRADA",parametro-out) <> ?
            then p-dtentra = date(acha("DATA-ENTRADA",parametro-out)).
            if acha("DATA-PARCELA",parametro-out) <> ?
            then p-dtparcela = date(acha("DATA-PARCELA",parametro-out)).
            if acha("ARREDONDA-PARCELA",parametro-out) <> ?
            then sparam = "ARREDONDA=" + 
                        acha("ARREDONDA-PARCELA",parametro-out) + "|".

            /*** preço especial ****/
            
            /*HELIO 1203
            *run p-atu-frame. 
            *run ver-promocao.
            */            


            parametro-in = "PRECO-ESPECIAL=S|PRODUTO=|"
                           + "PLANO=" + string(finan.fincod) + "|".

            run promo-venda.p(input parametro-in, output parametro-out).
            
            vpromocaoLimite = "false".
              
            if vpromocod <> ""
            then do:
                for each wf-movim.
                    if wf-movim.movalicms = 98 then next. /* helio 15122023 - lentidao prevenda - rodando verificapromqtd 2 vezes */
                    find produ where recid(produ) = wf-movim.wrec no-lock.
                    
                    do vi = 1 to num-entries(vpromocod):
                        vpromoc = entry(vi,vpromocod).

                        /* helio 15122023 - lentidao prevenda - rodando verificapromqtd 2 vezes */
                        if  lookup(vpromoc,vpromocod-verificado) <> 0 then next. /* nao verificar nvamente */ 

                        {lojapi-verificapromqtd.i vpromoc produ.procod wf-movim.movqtm}
                        if vpromocaolimite = "true"
                        then leave.
                    end.                
                end.
            end.
            

            if acha("PROMOCAO",parametro-out) <> ? 
            then vpromoc = acha("promocao",parametro-out).
            else vpromoc = "".
 
            /* HELIO 05122023 - Prioridade precos telefonia */    
            
            for each wf-movim.
                 find produ where recid(produ) = wf-movim.wrec no-lock.
                 find first tt-promo where tt-promo.rec-pro = recid(produ) no-lock no-error.
                 if avail tt-promo
                 then do:
                    if tt-promo.prpromo <> 0 and tt-promo.prpromo <> wf-movim.precoori
                    then wf-movim.movpc = tt-promo.prpromo.
                 end.
                                                                          
            end.    
                

            run altera-segprod (0). /* Verificar se algum preco foi alterado */
 
            run ver-promocao.

            run p-atu-frame.

        if libera-plano  = no and
           block-plano = yes
        then do:
            message color red/with
              "Plano bloqueado para produto(s) incluido(s)." view-as alert-box.
            undo, retry.
        end.
        /** helio libera plano **/
        /* teste de tipo de promo */
        vtemmodulo = no.
        do vtemmodulo-i = 1 to num-entries(vpromocod):    
            find first    ctpromoc where ctpromoc.sequencia = int(entry(vtemmodulo-i,vpromocod)) and ctpromoc.fincod = vfincod no-lock no-error.
            if avail ctpromoc
            then do:
                vtemmodulo = yes.
                leave.
            end.    
        end.
        if vfincod <> 0 and vtemmodulo = no /* helio 06072023 vpromocod = ""*/
        then do:
            {lojapi-cotasplanoverifica.i vfincod}                           
        end.
                     
        /** helio libera plano **/                        

        vpassa = yes.

        if vfincod <> 0   
        then do:
            run gercpg.
            pause 0.
            
            display ventra
                    /*vparce + vsegprest @*/ vparce
                    with frame f-condi.
        end.
        
        /* helio 09022022 - [ORQUESTRA 243179] Seleção de moeda a vista na Pré-Venda */
        pmoeda = "".
        
        if vfincod = 990 and vpromocod <> ""
        then do:
            def var vpromocoes as char.
            vpromocoes = "".
            run pdvpromavista.p (input setbcod, input vpromocod ,
                                            output vpromocavista,
                                            output vpromocoes).
            if vpromocavista
            then do:
                 run seguroprestamista (0 , 0, 0,   output vsegtipo,
                                           output vsegprest,
                                           output vsegvalor).
        
                    assign vliqui = 0
                           ventra = 0
                           vparce = 0.
        
                    run seguroprestamista (finan.finnpc, vparce, v-vencod,
                                                       output vsegtipo,
                                                       output vsegprest,
                                                       output vsegvalor).
                    run p-atu-frame.

                    run gercpg.
                    pause 0.
                    display ventra at 20 label "Entrada" 
                            /*vparce + vsegprest @*/ vparce at 20 label "Parcela"
                            with frame f-condi.
                    pause 0.         

                hide message no-pause .
                bell.
                message "Selecione uma moeda de pagamento, pois a venda eh com produto em promoção". 
                def var cmoedas as char format "x(36)" extent 2 init ["     [Pagamento em Dinheiro]",
                                                                      "[Pagamento em Cartao de Debito]"].
                        disp cmoedas with frame fcmoedas row 10 centered 
                    overlay no-labels
                    title " PAGAMENTO A VISTA COM PROMOCAO " + string(vpromocoes) + " - SELECIONE MOEDAS ".
                choose field cmoedas with frame fcmoedas.
                pmoeda = if frame-index = 1 then "DINHEIRO" else "TEFDEBITO".
                disp 
                     finan.finnom + " [" + pmoeda + "]" @ finan.finnom with frame f-desti.
                hide message no-pause.
                hide frame fcmoedas no-pause.                
            end.
        end.

        view frame f-desti.  
        view frame f-produ.   
        view frame f-opcom.
        
        leave.
    end.  /* repeat */

    vpassa = yes.   

    for each wf-movim where wf-movim.movalicms <> 98 /*GE/RFQ*/:
        find produ where recid(produ) = wf-movim.wrec no-lock.
        if produ.proipiper = 98 then next.
        find finesp where finesp.fincod = finan.fincod no-lock no-error.
        if avail finesp  
        then do:
            if finesp.catcod <> 0
            then do:
                if substring(string(finesp.catcod),1,1) <> /*=*/
                   substring(string(produ.catcod),1,1)
                then do:
                    find finpro where finpro.fincod = finesp.fincod and
                                      finpro.procod = produ.procod
                                no-lock no-error.
                    if not avail finpro
                    then vpassa = no.
                    next.                    
                end.    
            end.
        
            if today >= finesp.dataini and
               today <= finesp.datafin 
            then. 
            else do:
                vpassa = no.
                next.
            end.
            
            find first finfab where finfab.fincod = finesp.fincod 
                              no-lock no-error.
            if avail finfab
            then do:
                find finfab where finfab.fincod = finesp.fincod and
                                  finfab.fabcod = produ.fabcod
                            no-lock no-error.
                if not avail finfab
                then vpassa = no.
                else do:
                    vpassa = yes.
                    next.
                end.
            end.
        
            find first fincla where fincla.fincod = finesp.fincod 
                              no-lock no-error.
            if avail fincla
            then do:
                find fincla where fincla.fincod = finesp.fincod and
                                  fincla.clacod = produ.clacod
                            no-lock no-error.
                if not avail fincla
                then vpassa = no.
                else do:
                    vpassa = yes.
                    next.
                end.
            end.
            if finesp.catcod = 0
            then do:
                find first finpro where finpro.fincod = finesp.fincod 
                                  no-lock no-error.
                if avail finpro 
                then do: 
                    find finpro where finpro.fincod = finesp.fincod and
                                      finpro.procod = produ.procod
                                no-lock no-error.
                    if not avail finpro
                    then vpassa = no.
                    else do:
                        vpassa = yes.
                        next.
                    end.
                end.
            end.
        end.
    end.

    if (vfincod = 35 or
        vfincod = 36) and
        libera-plano
    then vpassa = yes.

    if vpassa = no and
       vfincod <> 0 and 
       libera-plano = no
    then do:  
        if vplanoCota = 0 
        then do:
            message "Plano Invalido (2)". 
            pause.
            for each ant-movim no-lock:
                find first wf-movim where wf-movim.wrec = ant-movim.wrec and
                                          wf-movim.KITproagr = ant-movim.KITproagr no-error.
                if avail wf-movim
                then buffer-copy ant-movim to wf-movim.
            end.
            undo, retry. 
        end.            
    end.

    find first black_friday where black_friday.numero > 0 no-error.
    if avail black_friday           
    then do:
        if finan.fincod = 0
        then val-black = vprotot.
        else val-black = ventra + (vparce * finan.finnpc).
        sresp = no.
        run Black-Friday.p("validar", val-black, output sresp).
        if sresp and vdes-black 
        then do:
            color disp normal vopcre[2] with frame f-opcom.
            run Black-Friday.p("DESCONTO-ITEM", val-black, output sresp).
            run p-atu-frame.
            if vfincod > 0 
            then do:
                assign
                    vliqui = 0
                    ventra = 0
                    vparce = 0.
                    
                run gercpg.
                display ventra vparce with frame f-condi.
                pause 0.
            end.
        end.
        else undo, retry.             
    end.
    /**** aqui seguro ***/

    /*pause 0.*/
    
    if avail finan and vende-seguro and
       vfincod > 0
    then do:
            if ((vpromocod = "30106" or vpromocod = "30085") and setbcod = 188) or
           (lookup("60878",vpromocod) > 0 or
            lookup("65507",vpromocod) > 0)
        then do:
            /*nao recalcula segujro */
        end.
        else do:
            run seguroprestamista (0 , 0, 0,   output vsegtipo,
                                           output vsegprest,
                                           output vsegvalor).
        
            for each wf-titulo: delete wf-titulo. end.

            assign vliqui = 0
                   ventra = 0
                   vparce = 0.
      
            run gercpg.

            run seguroprestamista (finan.finnpc, vparce, v-vencod,
                                           output vsegtipo,
                                           output vsegprest,
                                           output vsegvalor).

        end.
        
        run p-atu-frame.

        run gercpg.
        
        pause 0.
        
        display ventra at 20 label "Entrada" 
                /*vparce + vsegprest @*/ vparce at 20 label "Parcela"
                with frame f-condi.
        pause 0.         
        
        sresp = not (vsegtipo = 0).
        if vsegtipo = 99
        then do:
            
            sresp = yes.

              run medtelamensagem.p (INPUT-OUTPUT sresp,
                        input     
                        "             INFORME O CLIENTE          "  + 
                        "                                        "  +   
                        "QUE ELE GANHOU O SEGURO PRESTAMISTA " +  
                        "                                       "   + 
                        "              NA CAMPANHA LEBES " +
                        "                                        "  + 
                        "                           ", 
                                   input "",
                                   input "OK",
                                   input "---").  
            sresp = no.                                 
                
        end.
        else do:
            if vsegtipo = 31
            then message 
          "Manter vantagens da PARCELA PROTEGIDA LEBES e ainda concorrer a 5000"
          "mensais?" update sresp.
            else if vsegtipo = 41
            then message
          "Quer concorrer a 5000 mensais e ainda ter sua parcela protegida Lebes?"
                            update sresp.
        end.
        
        if not sresp
        then do.
            run seguroprestamista (0, 0, 0,
                                               output vsegtipo,
                                               output vsegprest,
                                               output vsegvalor).
            run p-atu-frame.
            run gercpg.
            
            disp ventra
                 /*vparce  @*/ vparce with frame f-condi.
            pause 0.
        end.
    end.

    /*****/
    
    sresp = yes. 
    do /*on error undo*/:  
        identificador = "".  
        if vfincod = 0  and vclicod = 0
        then vclicod = 1.
        /**    
        else do: 
            vclicod = 0. 
        end.     
        **/
        if vfincod <> 0 and vclicod = 1 
        then do: 
            message "Cliente Invalido". 
            undo, retry.
        end. 
        
        if setbcod = 189 and vpromocao <> ""
        then do:
            message vpromocao. pause.
        end.
                                    
        find clien where clien.clicod = vclicod no-lock no-error. 
        if vclicod = 0 or vclicod = 1 
        then do: 
            identificador = "". 
            update identificador label "Identificador" colon 15 format "x(25)"
                             with frame f-desti.
        end.    
        else identificador = clien.clinom.  
        if not avail clien 
        then do: 
            message "Cliente digitado nao existe". 
            undo, retry.
        end.
        hide message no-pause.
        
        if identificador <> "" 
        then display identificador with frame f-desti.                
    end.
    find first wf-movim no-lock no-error.
    if avail wf-movim
    then v-vendedor = wf-movim.vencod.
    else v-vendedor = 0.
    do on error undo: 
        v-vencod = v-vendedor.
        update v-vendedor with  frame f-desti. 
        if v-vencod > 0 and v-vendedor <> v-vencod
        then do:
            message " Vendedor nao pode ser alterado.".
            v-vendedor = v-vencod.
            undo.
        end.
        find func where func.funcod = v-vendedor and 
                        func.etbcod = setbcod no-lock no-error.
        if not avail func 
        then do: 
            message "Codigo do Funcionario invalido". 
            undo, retry.
        end.
    
        disp v-vendedor 
             func.funnom with frame f-desti. 
    
        v-vencod = v-vendedor. 
    
        for each wf-movim. 
            wf-movim.vencod = func.funcod. 
        end.
    end. 
end.

if not avail finan 
then undo, leave bl-plano.


                if search("rcomboplan.p") <> ? 
                then do:
                    if vfincod > 0
                    then do:
                            def var pfincodusar as int.
                            run rcomboplan.p (input vfincod, identificador, v-vencod, output pfincodusar ). 
                            if pfincodusar <> ? and pfincodusar <> 0
                            then do:
                                find finan where finan.fincod = pfincodusar no-lock no-error.
                                if not avail finan
                                then  find finan where finan.fincod = vfincod no-lock.
                            end.    
                    end.
                end.

sparam = "".
run gerpre.p (input recid(finan), 
              input recid(clien), 
              input vbonus, 
              input v-numero, 
              input vprotot, 
              input ( if vdevval > vprotot 
                      then vprotot 
                      else vdevval ),
              input vdevval, 
              input v-serie, 
              output rec-plani, 
              input  identificador, 
              input (if ventra-ori > 0 and
                        ventra-ori <> ventra
                     then ventra else 0) /* Entrada diferenciada */,
              input vmoecod,
              input vinfo-VIVO).
    
if keyfunction(lastkey) = "END-ERROR"
then do:
    for each ant-movim no-lock:
        find first wf-movim where wf-movim.wrec = ant-movim.wrec and
                                  wf-movim.KITproagr = ant-movim.KITproagr
                   no-error.
        if avail wf-movim
        then do:
            buffer-copy ant-movim to wf-movim.
        end.
    end.
    run p-atu-frame.
    undo.              
end.

if sparam = "voltar"
then undo.
        
find plani where recid(plani) = rec-plani no-lock no-error. 

if plani.notass > 0
then do:
    vpassa = yes.

    if search("/usr/admcom/progr/p2k_geraped.p") <> ? and
       vpassa
    then do. 
        /* programa para gerar prevenda para o P2K  */ 
        run p2k_geraped.p (rec-plani, par-campanha, par-valordescontocupom). 
        
        /* helio 31012023 cupomb2b - marca o cupom como usado */
        if vcupomb2b <> 0
        then do:
            if search("lojapi-cupomb2bmarca.p") <> ?
            then do:
                run lojapi-cupomb2bmarca.p.
            end.    
        end.

        /* #042023 helio libera plano */
        if vplanocota <> 0
        then do:
            if search("lojapi-cotasplanoutiliza.p") <> ?
            then do:
                run lojapi-cotasplanoutiliza.p (vplanocota).
            end.    
        end.
        
        
        
        message color red/with
            skip
            "PREVENDA GERADA:" string(plani.notass,">>>>9")
            skip
            "RESGATE P2K:" string(plani.numero)
            skip(1)
            view-as alert-box title "".
    end.
    else message color red/with
            skip
            "PREVENDA GERADA : " string(plani.notass,">>>>9")
            skip(1)
            view-as alert-box title "".
end.
for each wf-movim. 
    delete wf-movim. 
end.
for each ant-movim.
    delete ant-movim.
end.            
v-vendedor = 0. 
v-vencod   = 0. 
identificador    = "". 
clear frame f-desti  no-pause. 
clear frame f-produ  no-pause. 
clear frame f-produ1 no-pause.

