def var vplanobloqueio as int.
def var vplanobloqueiomensagem as char format "x(70)". 
    run lojapi-cotasplanoverifica.p (input {1}, output vplanobloqueio, output vplanobloqueiomensagem).
        if vplanobloqueio = 1
        then do: 
            disp
                skip(1)
                vplanobloqueiomensagem skip(1)  
                with frame favisocotas1 
                                centered no-labels
                                row 7 overlay
                                color messages.

                                
            do on endkey undo, retry : 
                hide message no-pause. 
                pause 2 no-message.  
                hide frame favisocotas1 no-pause.
                vfincod = 0.
                disp vfincod  
                    "" @ finan.finnom with frame f-desti.
                undo, retry.
              end.
            
        end . 
        if vplanobloqueio = 2    
        then do: 
            disp  
                skip(1)               
                    substring(vplanobloqueiomensagem,1,50) format "x(52)" skip
                    substring(vplanobloqueiomensagem,51)  format "x(52)"
                    skip(1)    
               with frame favisocotas2 
                                centered no-labels
                                row 8 overlay.
                        
              message "(11) solicite senha do gerente".
              run senha_gerente (output vgerentelibera).  
              hide frame f-senha no-pause.
              hide frame favisocotas2 no-pause.                
              
              if not vgerentelibera 
              then do on endkey undo, retry : 
                hide message no-pause. 
                message "plano nao autorizado pelo gerente.". 
                pause 1 no-message.  
                undo, retry.
              end.
              
              vplanoCota = vfincod.
              
              
        end.
        
