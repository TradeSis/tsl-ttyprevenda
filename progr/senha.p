{admcab.i}
def output parameter vok as log.
def var vsen as int.
    vok = no.
    pause 0.
        prompt-for skip(1) func.funcod
                   with frame fsenha overlay
                   color black/yellow side-label
                   title " Autorizacao do Gerente " row 5 centered.
        find func where func.funcod = input func.funcod and 
                        func.etbcod = setbcod no-lock.
        if func.funmec = no
        then do:
            bell.
            message "Funcionario Nao e' Gerente".
            undo.
        end.
        vsen = 0.
        repeat on endkey undo, retry:
            prompt-for func.senha blank skip(1)
                   with frame fsenha.
            if input func.senha <> func.senha
            then do:
                message "Senha Invalida".
                vsen = vsen + 1.
                if vsen >= 3
                then do:
                    hide frame fsenha no-pause.
                    return.
                end.
            end.
            else leave.
        end.

        hide frame fsenha no-pause.
        if sautoriza <> "" or
           scliaut   <> 0
        then do:
            create autoriz.
            assign autoriz.etbcod = setbcod
                   autoriz.funcod = func.funcod
                   autoriz.data   = today
                   autoriz.hora   = time
                   autoriz.motivo = sautoriza
                   autoriz.clicod = scliaut
                   autoriz.valor1 = svalor1
                   autoriz.valor2 = svalor2
                   autoriz.valor3 = svalor3
                   sautoriza      = ""
                   scliaut        = 0.
        end.
        vok = yes.
