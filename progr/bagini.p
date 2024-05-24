/* #102022 helio BAG */

{admcab.i}

def var ibag as int.
def var vbag as char format "x(30)"
    extent 2 init [" NOVA BAG ", " RETORNO DE BAG"].
form
    skip(1)
    space(10)
    vbag[1]
    vbag[2]
    space(10)
    skip(1)
    with frame fcabbag
        row 6 centered no-labels title " BAG LEBES ".
disp vbag with frame fcabbag.

choose field vbag
    with frame fcabbag.
ibag = frame-index.

HIDE FRAME fcabbag no-pause.

if ibag = 1 /*1 NOVA BAG */
then do:
    
    run bagnova.p.

end.


if ibag = 2 /*2 RETORNO BAG */
then do:
    
    run bagretorno.p.

end.


