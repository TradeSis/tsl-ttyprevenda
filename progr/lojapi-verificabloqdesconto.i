/* verifica bloqueio desconto por api */
def var vprodutobloqueio as log.

run lojapi-verificabloqdesconto.p (input {1},output vprodutobloqueio).

vindbldes = vprodutobloqueio.


