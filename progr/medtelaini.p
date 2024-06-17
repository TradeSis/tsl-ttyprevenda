/* medico na tela 042022 - helio */
{admcab.i}

{meddefs.i new}

 
    disp setbcod label "Filial"
         with frame f1 row 3 
            centered title "CHAMA DOUTOR" 
            color messages side-labels
            overlay.

    update pvencod  label "Vendedor"
                with frame f1.

    find first func where func.etbcod = setbcod and
                              func.funcod = pvencod
                              no-lock no-error.
                                      
    disp func.funnom no-labels
                with frame f1.    
         
        run medtelapro.p.
    
    do:    
        find first ttmedprodu where ttmedprodu.procod = pprocod no-lock no-error.
        if not avail ttmedprodu then do:
            return.
        end.    
                
        
        disp pprocod format ">>>>>>>>9" 
             ttmedprodu.pronom
             ttmedprodu.idPerfil
             ttmedprodu.tipoServico
             ttmedprodu.valorServico
             
            with frame frame-cab 1 down centered row 5 no-box overlay
            no-labels.
            
            
        /* Limpa os Perfis e Planos de outros produtos */.
        for each ttcampos where ttcampos.idperfil <> ttmedprodu.idPerfil.
                delete ttcampos.
        end.        
        for each ttplanos where ttplanos.procod <> ttmedprodu.procod.
            delete ttplanos.
        end.    
        run medtelaper.p.
    
        
    end.
