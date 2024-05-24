/* #082022 helio bau */

{admcab.i}

def var ibau as int.
def var vbau as char format "x(30)"
    extent 2 init [" NOVO CARNE ", " PAGAMENTO PARCELAS"].
form
    skip(1)
    space(10)
    vbau[1]
    vbau[2]
    space(10)
    skip(1)
    with frame fcabbau
        row 6 centered no-labels title " BAU DA FELICIDADE ".
disp vbau with frame fcabbau.

choose field vbau
    with frame fcabbau.
ibau = frame-index.

HIDE FRAME fcabbau no-pause.

if ibau = 1 /*1 NOVO CARNE */
then do:
    
    run baunovo.p (input " BAU DA FELICIDADE - " + vbau[ibau]).

end.

if ibau = 2 /*2 PAGAMENTO PARCELAS */
then do:
    
    run baupagar.p (input " BAU DA FELICIDADE - " + vbau[ibau]).

end.