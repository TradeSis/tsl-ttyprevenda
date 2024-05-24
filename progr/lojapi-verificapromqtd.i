/* verifica limite quantidade promocaopor api */

run lojapi-verificapromqtd.p (input {1},
                              input {2},
                              input {3},
                              output vpromocaolimite).

if vpromocaolimite = "true"
then do:
    if avail wf-movim
    then do:
        wf-movim.movpc      = wf-movim.precoori.
        vpreco              = wf-movim.precoori.
    end.    
        
    hide message no-pause.
    message "produto" {2} "ultrapassou o limite da promocao" {1}
        view-as alert-box.
end.


