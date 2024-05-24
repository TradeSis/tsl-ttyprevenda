                hide message no-pause .
                bell.
                message "Selecione uma moeda de pagamento, pois a venda eh com produto em promoção". 
                def var cmoedas as char format "x(36)" extent 3 init ["     [Pagamento em Dinheiro]",
                                                                       "[Pagamento em Cartao de Debito]",
                                                                       "     [Pagamento em PIX]"].
                        disp cmoedas with frame fcmoedas row 10 centered 
                    overlay no-labels
                    title " PAGAMENTO A VISTA COM PROMOCAO " + string(vpromocoes) + " - SELECIONE MOEDAS ".
                choose field cmoedas with frame fcmoedas.
                if frame-index = 1 then pmoeda = "DINHEIRO".
                if frame-index = 2 then pmoeda = "TEFDEBITO".
                if frame-index = 3 then pmoeda = "PIX" .
                disp 
                     finan.finnom + " [" + pmoeda + "]" @ finan.finnom with frame f-desti.
                hide message no-pause.
                hide frame fcmoedas no-pause.                
