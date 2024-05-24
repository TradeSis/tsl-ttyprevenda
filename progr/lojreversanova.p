/* helio 22062023 - Bloqueio L998 no menu destino REVERSA */
{admcab.i}
{lojreversa.i new}
def var presposta as char.
def var phttp_code as int.

def var petbdest like estab.etbcod.
def var pcodCaixa as int.
 
disp
    setbcod label "estabelecimento origem"
    with frame fcab
    row 6
     side-labels centered  
     title " ABERTURA DE NOVA CAIXA - REVERSA ".

petbdest = 900.     
update 
    petbdest label "estabelecimento destino"
        with frame fcab.
find estab where estab.etbcod = petbdest no-lock no-error.
if not avail estab
then do:
    message "estabelecimento nao cadastrado".
    undo.
end.
if petbdest = setbcod
then do:
    message "destino invalido".
    undo.
end.    
/* helio 22062023 */ 
if petbdest = 998
then do:
    message "UTILIZAR PROCESSO DE ASSISTENCIA TECNICA"
        view-as alert-box.
    undo.    
end.

sresp = yes.
message "Confirma criar uma nova caixa" update sresp.
IF SRESP = NO
THEN RETURN.

run lojapireversa-abrecaixa.p (setbcod,petbdest,output pcodCaixa, output phttp_code, output presposta).     



if pcodcaixa <> ?
then do:
    hide message no-pause.
    message "nova caixa " pcodcaixa "criada". 
    run lojreversaprodu.p (pcodCaixa).
end.

