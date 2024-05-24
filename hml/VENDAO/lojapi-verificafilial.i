/* helio 01022023 - nao permitir mesma filial */
/* verifica filial por api */
def var vfilialemoperacao as log.

if {1} = setbcod
then do:
    message "mesma filial nao pode"
        view-as alert-box.
    undo, retry.
end.

def buffer bestab for estab.
def buffer cestab for estab.
find bestab where bestab.etbcod = setbcod no-lock.
find cestab where cestab.etbcod = {1}     no-lock.

if bestab.ufecod <> cestab.ufecod
then do:
    message "Filiais Destino eh do Estado "  cestab.ufecod skip(1)
            " NAO EH PERMITIDO OPERACAO "
            VIEW-as alert-box.
    undo, retry.            
end.

run lojapi-verificafilial.p (input {1},output vfilialemoperacao).

if not vfilialemoperacao 
then do:
    message "filial" {1} "nao esta em operacao"
        view-as alert-box.
    undo, retry.
end.


