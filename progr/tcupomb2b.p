/* helio 10042023 - cashb por cliente */

def input param vclicod as int. /* helio 10042023 cashb - so para cliente */
def new global shared var setbcod as int.
def var sresp as log format "sim/nao".
def shared var vcupomb2b        as int format ">>>>>>>>>9". /* cupomb2b */
def var vperc   as dec.    

def buffer subclasse for clase.
def buffer classe    for clase.
def buffer grupo     for clase.
def buffer setor     for clase.
def buffer cupom-clase for clase.
def var vvenda-clacod as int.

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

def new shared temp-table ttentrada serialize-name "cupomb2b" 
    field estabOrigem   as int 
    field idCupom       as int
    field clicod        as int.
        
def new shared temp-table ttitens serialize-name "itens"  
    field codigoProduto as int 
    field quantidade    as int 
    field valorUnitario as dec.
    
def new shared temp-table ttcupomb2b no-undo serialize-name "cupomb2b" 
    field estabOrigem   as int 
    field idCupom       as int 
    field categoria     as int 
    field subclasse     as int 
    field valorDesconto as dec 
    field percentualDesconto as dec 
    field dataValidade  as date.

disp vcupomb2b label "cupom de desconto" colon 20
                            help "informe o numero do cupom de desconto e aguarde"
                             with frame f-cupomb2b row 17 side-label overlay column 23 no-box color messages
                            width 58.

def var vtotal as dec.

create ttentrada.
ttentrada.estabOrigem = setbcod.
ttentrada.idCupom = vcupomb2b.
ttentrada.clicod  = vclicod.
for each wf-movim.
    find produ where recid(produ) = wf-movim.wrec no-lock.
    create ttitens.
    ttitens.codigoProduto = produ.procod.
    ttitens.quantidade    = wf-movim.movqtm.
    ttitens.valorUnitario   = wf-movim.movpc.
end.
run lojapi-cupomb2bconsulta.p.

find first ttcupomb2b no-error.
if not avail ttcupomb2b
then do:
    vcupomb2b = 0.
    hide frame f-cupomb2b no-pause. 
    return.
end.

/*
ttcupomb2b.percentualDesconto = if vcupomb2b = 222 then 10 else 20 .
if vcupomb2b = 333 then do:
    ttcupomb2b.percentualDesconto = 0.
    ttcupomb2b.valorDesconto = 12.
end.
ttcupomb2b.dataValidade       = 01/31/2023.
*/

find cupom-clase where cupom-clase.clacod = ttcupomb2b.subclasse no-lock.

vtotal = 0.
for each wf-movim.
    
    vvenda-clacod = 0.
    find produ where recid(produ) = wf-movim.wrec no-lock.
    find subclasse   where   subclasse.clacod = produ.clacod         no-lock.
    find classe where classe.clacod = subclasse.clasup no-lock.
    find grupo where grupo.clacod = classe.clasup no-lock.
    find setor where setor.clacod = grupo.clasup no-lock.
    if cupom-clase.clagrau = 4
    then  vvenda-clacod = subclasse.clacod.
    if cupom-clase.clagrau = 3
    then  vvenda-clacod = classe.clacod.
    if cupom-clase.clagrau = 2
    then  vvenda-clacod = grupo.clacod.
    if cupom-clase.clagrau = 1
    then  vvenda-clacod = setor.clacod.
     
    if vvenda-clacod = ttcupomb2b.subclasse
    then do:
        vtotal = vtotal + (wf-movim.movqtm * wf-movim.movpc).
    end.
    
end.                                    

if ttcupomb2b.percentualDesconto > 0
then do:
    
    for each wf-movim.
        vvenda-clacod = 0.
        find produ where recid(produ) = wf-movim.wrec no-lock.
        find subclasse   where   subclasse.clacod = produ.clacod         no-lock.
        find classe where classe.clacod = subclasse.clasup no-lock.
        find grupo where grupo.clacod = classe.clasup no-lock.
        find setor where setor.clacod = grupo.clasup no-lock.
        if cupom-clase.clagrau = 4
        then  vvenda-clacod = subclasse.clacod.
        if cupom-clase.clagrau = 3
        then  vvenda-clacod = classe.clacod.
        if cupom-clase.clagrau = 2
        then  vvenda-clacod = grupo.clacod.
        if cupom-clase.clagrau = 1
        then  vvenda-clacod = setor.clacod.
     
        if vvenda-clacod = ttcupomb2b.subclasse
        then do:
            if ttcupomb2b.percentualDesconto > 0
            then wf-movim.movpc =  (wf-movim.precoori - ((wf-movim.precoori * ttcupomb2b.percentualDesconto) / 100)).
            vtotal = vtotal - (wf-movim.movqtm * wf-movim.movpc).
        end.                                    
    end.
    
    ttcupomb2b.valorDesconto = vtotal.
    
end.
else do:
    vperc = ttcupomb2b.valorDesconto / vtotal * 100.
    for each wf-movim.
        vvenda-clacod = 0.
        find produ where recid(produ) = wf-movim.wrec no-lock.
        find subclasse   where   subclasse.clacod = produ.clacod         no-lock.
        find classe where classe.clacod = subclasse.clasup no-lock.
        find grupo where grupo.clacod = classe.clasup no-lock.
        find setor where setor.clacod = grupo.clasup no-lock.
        if cupom-clase.clagrau = 4
        then  vvenda-clacod = subclasse.clacod.
        if cupom-clase.clagrau = 3
        then  vvenda-clacod = classe.clacod.
        if cupom-clase.clagrau = 2
        then  vvenda-clacod = grupo.clacod.
        if cupom-clase.clagrau = 1
        then  vvenda-clacod = setor.clacod.
     
        if vvenda-clacod = ttcupomb2b.subclasse
        then do:
            wf-movim.movpc =  (wf-movim.precoori - ((wf-movim.precoori * vperc) / 100)).
        end.
    end.                                    
    ttcupomb2b.percentualDesconto = vperc.
end.
    
disp 
    ttcupomb2b.percentualDesconto when ttcupomb2b.percentualDesconto <> 0 label "Perc"  format ">>9.99%" colon 20
    ttcupomb2b.valorDesconto      when ttcupomb2b.valorDesconto <> 0      label "Valor" format ">>>>9.99"  
    ttcupomb2b.dataValidade           colon 20  label "Validade" format "99/99/9999"
    with frame f-cupomb2b.
sresp = yes.
message "confirma utilizar o cupom" vcupomb2b "?" update sresp.
if not sresp
then do:
    vcupomb2b = 0.
end.
hide frame f-cupomb2b no-pause.    
