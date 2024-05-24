/* helio 30102023 - Novo modelo TOKEN regional lojas - Orquestra 538865 */
def output param p-ok as log.
def output param pidusuario as char.
def var ptoken as char format "x(30)".


run tokenuser.p (output pidusuario).

if pidusuario = "" 
then return.

disp pidusuario label "USUARIO" format "x(20)" colon 20.

update ptoken label "DIGITE O TOKEN" colon 20
    with row 15 overlay width 60 color messages centered
    title "TOKEN" side-labels.

hide no-pause.

run lojapi-tokenverifica.p (input pidusuario,
                          input ptoken,
                          output p-ok).


