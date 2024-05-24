/* helio 10072023 - combo descontos planos */

def input param vfincod as int. 
def input param pidentificador as char.
def input param pvendedor as int.
def output param pfincodusar as int.

def new global shared var setbcod as int.
def var sresp as log format "sim/nao".
def var vperc   as dec.    

def buffer subclasse for clase.
def buffer classe    for clase.
def buffer grupo     for clase.
def buffer setor     for clase.

def shared temp-table wf-movim no-undo
    field wrec      as   recid
    field movqtm    like movim.movqtm
    field lipcor    like liped.lipcor
    field movalicms like movim.movalicms
    field desconto  like movim.movdes
    field movpc     like movim.movpc
    field precoori  like movim.movpc
    field vencod    like func.funcod
    field KITproagr   like produ.procod.



def new shared temp-table ttentrada serialize-name "pedido" 
    field estabOrigem   as int 
    field codigoPlano   as int
    field identificador as char
    field vendedor      as int.
        
def new shared temp-table ttitens serialize-name "itens"  
    field codigoProduto as int 
    field quantidade    as int 
    field valorUnitario as dec.  
    
def new shared temp-table ttcombo serialize-name "combo" 
    field estabOrigem   as int 
    field codigoPlano   as int 
    field filial   as int 
    field codigoPlanoUsar       as int 
    field percDesc      as dec.
                    
def new shared temp-table ttcombo-itens serialize-name "itens"  
    field codigoProduto as int 
    field quantidade    as int 
    field valorUnitario as dec 
    field categoria     as char 
    field setor         as char 
    field regra         as char 
    field percDesc      as dec 
    field valorDesc     as dec.

def var vtotal as dec.

create ttentrada.
ttentrada.estabOrigem = setbcod.
ttentrada.codigoPlano  = vfincod.
ttentrada.identificador = pidentificador.
ttentrada.vendedor = pvendedor.
for each wf-movim.
    find produ where recid(produ) = wf-movim.wrec no-lock.
    create ttitens.
    ttitens.codigoProduto = produ.procod.
    ttitens.quantidade    = wf-movim.movqtm.
    ttitens.valorUnitario   = wf-movim.movpc.
end.
run lojapi-comboplancalcula.p (input pidentificador, pvendedor).



find first ttcombo no-error.
if not avail ttcombo
then do:
    pfincodusar = ?. 
    return.
end.


    pfincodusar = ttcombo.codigoPlanoUsar. 

    for each wf-movim.
        find produ where recid(produ) = wf-movim.wrec no-lock.
        find first ttcombo-itens where ttcombo-itens.codigoproduto = produ.procod.
        if ttcombo-itens.percdesc > 0
        then do:
            /* helio 15082023 - ajuste calculo por movpc, que é o preco liquido */
            wf-movim.movpc =  (wf-movim.movpc - ((wf-movim.movpc * ttcombo-itens.percdesc) / 100)).
        end.    
    end.
        
