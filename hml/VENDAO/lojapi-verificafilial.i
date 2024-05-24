/* helio 01022023 - nao permitir mesma filial */
/* verifica filial por api */
def var vfilialemoperacao as log.

if {1} = setbcod
then do:
    message "mesma filial nao pode"
        view-as alert-box.
    undo, retry.
end.

run lojapi-verificafilial.p (input {1},output vfilialemoperacao).

if not vfilialemoperacao 
then do:
    message "filial" {1} "nao esta em operacao"
        view-as alert-box.
    undo, retry.
end.


