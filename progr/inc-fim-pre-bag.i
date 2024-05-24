/*
/* helio 09032022 - [ORQUESTRA 243179 - ESCOPO ADICIONAL] Seleção de moeda a vista na Pré-Venda  */

helio 09022022 - [ORQUESTRA 243179] Seleção de moeda a vista na Pré-Venda 
04.02.2020 helio.neto - 189 - cupom desconto
17.02.2020 helio.neto - 188
*/
for each ant-movim .
    delete ant-movim.
end.    
for each wf-movim no-lock:
    create ant-movim.
    buffer-copy wf-movim to ant-movim.
end.    
    
        do:
            
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
                            /*BAG
                            for each bwf-movim.
                                find produ where recid(produ) = bwf-movim.wrec no-lock.
                                if produ.catcod = 31 or
                                   produ.catcod = 41
                                then do:
                                   if vende-garan
                                   then run altera-segprod(produ.procod).
                                end.
                            end.     
                            BAG*/ 
                        end.

                    end.
                end.
        end.
        
do on error undo, retry  on endkey undo, leave with frame f-desti:
    clear frame f-condi all.
    hide frame f-condi no-pause.        
    repeat on endkey undo, leave bl-plano: 
        if vclicod = 1 then vclicod = 0.
        message keyfunction(lastkey).
        if keyfunction(lastkey) = "end-error"
        then do:  
            for each ant-movim no-lock:
                find first wf-movim where wf-movim.wrec = ant-movim.wrec
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
                /*BAGrun ver-promocao.*/
                pause 0.
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
                    run p-atu-frame.
                    run gercpg.
                    pause 0.
                    display ventra at 20 label "Entrada" 
                            vparce at 20 label "Parcela"  
                            with frame f-condi row 18  
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
        if vmoecod = ""
        then do:
            find finan where finan.fincod = vfincod no-lock no-error.
            if avail finan
            then disp finan.fincod @ vfincod 
                      finan.finnom with frame f-desti.
            ventradadiferenciada = no.
            vplano-ori = vfincod.
            
            update vfincod go-on (C c F5 f5 F7 f7) with frame f-desti.  
            /************** teste Claudir ***/
            if lastkey = keycode("F7") or
               lastkey = keycode("f7")
            then do:

                run simula_parcela.p(input vprotot, 
                                     input vdevval, 
                                     input vbonus,
                                     input no /*BAGparcela-especial*/, 
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

            /*BAG
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
            */
            
            disp finan.fincod @ vfincod 
                 finan.finnom with frame f-desti.
            hide frame f-condi no-pause.
            clear frame f-condi all.
            
            /*BAG
            if vfincod > 0 
            then do:  
                assign
                    vliqui = 0
                    ventra = 0
                    vparce = 0.
                
                run gercpg.

                ventra-ori = ventra.
                repeat.
                    display 
                         ventra at 20 label "Entrada" 
                         vparce at 20 label "Parcela"
                         with frame f-condi row 19  
                                overlay 1 down column 43 no-box
                                color message side-label.
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
            BAG*/
        end.
        else do: 
            vfincod = 0.
            find finan where finan.fincod = vfincod no-lock no-error.  
            find moeda where moeda.moecod = vmoecod no-lock.
            disp moeda.moecod @ vfincod 
                 moeda.moenom format "x(20)" @ finan.finnom with frame f-desti.
        end.
        /*BAGval-prazo = 0.
        
        if vfincod > 0 
        then run val-prazo-promo.
        else do:
            run seguroprestamista (0, 0, 0,
                                    output vsegtipo,
                                    output vsegprest,
                                    output vsegvalor).

            /*BAGfor each wf-titulo: delete wf-titulo. end.*/
        end.
            */

        /*BAG
        if setbcod = 1133 or
           setbcod = 1185 or
           setbcod = 1142
        then do:
            run promo-filial33e85.
            run p-atu-frame.
        end.
        */
        
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
        
        
            parametro-in = "LIBERA-PLANO=S|CASADINHA=S|GERA-CPG=S|"
                        + "PLANO=" + string(finan.fincod) + "|"
                        + "ALTERA-PRECO=S|".
            
            run promo-venda.p(input parametro-in ,
                              output parametro-out).

    /* BAG atualiza precos */   
    for each ttitens.
        find produ where produ.procod = ttitens.codigoProduto no-lock.
        find first wf-movim where wf-movim.wrec   = recid(produ) no-lock no-error.
        if avail wf-movim
        then do:
            if wf-movim.movpc <> ttitens.valorLiquido
            then do:
                ttitens.valorLiquido = wf-movim.movpc.
                ttitens.descontoproduto  = 0.
                ttitens.valortotalconvertida = ttitens.valorliquido * ttitens.quantidadeconvertida.        

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
            
            /*run p-atu-frame. */
            /*BAGrun ver-promocao.*/
            
            parametro-in = "PRECO-ESPECIAL=S|PRODUTO=|"
                           + "PLANO=" + string(finan.fincod) + "|".
            run promo-venda.p(input parametro-in, output parametro-out).
            
            if acha("PROMOCAO",parametro-out) <> ? 
            then vpromoc = acha("promocao",parametro-out).
            else vpromoc = "".

    /* BAG atualiza precos */
    for each ttitens.
        find produ where produ.procod = ttitens.codigoProduto no-lock.
        find first wf-movim where wf-movim.wrec   = recid(produ) no-lock no-error.
        if avail wf-movim
        then do:
            if wf-movim.movpc <> ttitens.valorLiquido
            then do:
                ttitens.valorLiquido = wf-movim.movpc.
                ttitens.descontoproduto  = 0.
                ttitens.valortotalconvertida = ttitens.valorliquido * ttitens.quantidadeconvertida.        

            end.
        end.    
    end.

            run p-atu-frame.
            /*BAGrun ver-promocao.*/

        /*BAGrun altera-segprod (0). /* Verificar se algum preco foi alterado */
          */
          
        if libera-plano  = no and
           block-plano = yes
        then do:
            message color red/with
              "Plano bloqueado para produto(s) incluido(s)." view-as alert-box.
            undo, retry.
        end.

        vpassa = yes.

        if vfincod <> 0   
        then do:
            run gercpg.
            pause 0.
            
            display ventra
                    vparce
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
            /*                                            
            find first wf-movim where wf-movim.movpC < wf-movim.precoori no-error.
            if avail wf-movim
            then do:
            */
        
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
                            vparce at 20 label "Parcela"
                            with frame f-condi.
                    pause 0.         

                hide message no-pause .
                bell.
                message "Selecione uma moeda de pagamento, pois a venda eh com produto em promoção". 
                def var cmoedas as char format "x(36)" extent 2 init ["     [Pagamento em Dinheiro]",
                                                                      "[Pagamento em Cartao de Debito]"].
                        disp cmoedas with frame fcmoedas row 10 centered 
                    overlay no-labels
                    title " PAGAMENTO A VISTA COM PROMOCAO - SELECIONE MOEDAS ".
                choose field cmoedas with frame fcmoedas.
                pmoeda = if frame-index = 1 then "DINHEIRO" else "TEFDEBITO".
                disp 
                     finan.finnom + " [" + pmoeda + "]" @ finan.finnom with frame f-desti.
                hide message no-pause.
                hide frame fcmoedas no-pause.                
            end.
        end.
        
        /* helio 09022022 - [ORQUESTRA 243179] Seleção de moeda a vista na Pré-Venda */
                        
                        
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
        message "Plano Invalido (2)". 
        pause.
        for each ant-movim no-lock:
            find first wf-movim where wf-movim.wrec = ant-movim.wrec no-error.
            if avail wf-movim
            then buffer-copy ant-movim to wf-movim.
        end.
        /*BAGrun p-atu-frame.*/
        undo, retry. 
    end.

/*BAG
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
BAG*/
    
    /**** aqui seguro ***/

    /*pause 0.*/

    if avail finan and vende-seguro and
       vfincod > 0
    then do:
        
        /*BAG
        if (vpromocod = "30085") or
           (vpromocod = "60878")
        then do:
            /*nao recalcula segujro */
        end.
        else do:
        
            run seguroprestamista (0 , 0, 0,   output vsegtipo,
                                           output vsegprest,
                                           output vsegvalor).
        
   
            /*BAGfor each wf-titulo: delete wf-titulo. end.*/

            assign vliqui = 0
                   ventra = 0
                 vparce = 0.
            run gercpg.
    
        
            run seguroprestamista (finan.finnpc, vparce, v-vencod,
                                           output vsegtipo,
                                           output vsegprest,
                                           output vsegvalor).

        end.
        **/
        run p-atu-frame.
        
        run gercpg.
        
        pause 0.
        view frame f-desti.
        display ventra at 20 label "Entrada" 
                vparce at 20 label "Parcela"
                with frame f-condi.
        pause 0.         

        if vsegtipo = 31
        then message 
      "Manter vantagens da PARCELA PROTEGIDA LEBES e ainda concorrer a 5000"
      "mensais?"
                            update sresp.
        else if vsegtipo = 41
            then message
      "Quer concorrer a 5000 mensais e ainda ter sua parcela protegida Lebes?"
                            update sresp.
        if not sresp
        then do.
            run seguroprestamista (0, 0, 0,
                                               output vsegtipo,
                                               output vsegprest,
                                               output vsegvalor).
            run p-atu-frame.
            run gercpg.
            pause 0.
            disp ventra
                 vparce with frame f-condi.
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
        
/*BAG        if setbcod = 189 and vpromocao <> ""
        then do:
            message vpromocao. pause.
        end.
*/                                    
        /*BAG*/
        identificador = "BAG " + string(pidbag) + " " + ttbag.nome. 
        find clien where clien.clicod = vclicod no-lock no-error. 
        /*BAG
        if vclicod = 0 or vclicod = 1 
        then do: 
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
        */
        
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


sparam = "".
run baggerpre.p (input recid(finan), 
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
              input "" /*BAGvinfo-VIVO*/).
    
if keyfunction(lastkey) = "END-ERROR"
then do:
    for each ant-movim no-lock:
        find first wf-movim where wf-movim.wrec = ant-movim.wrec
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
    /*BAG
    if etb-entrega <> 0 and
       etb-entrega <> setbcod and
       (setbcod = 140 or /* P2K Entrega em outra loja */
        setbcod = 162)    /* LOJA SC */
    then vpassa = no.
    */
    
    if vpassa
    then do. 
        /* programa para gerar prevenda para o P2K  */ 
        run bagpedido.p (pidbag, rec-plani, par-campanha, par-valordescontocupom). 
        vok = yes.
        
        message color red/with
            skip
            "PREVENDA GERADA:" string(plani.notass,">>>>9")
            skip
            "RESGATE P2K:" string(plani.numero)
            skip(1)
            "BAG" pidbag 
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


