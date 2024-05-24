/*
04.02.2020 helio.neto - 189 - cupom desconto
*/

{admcab.i}

def input  param pcpf        as dec.
def output param par-campanha   as int.
def output param par-valor      as dec init 0.

def var par-barracupom as char format "x(42)".
def var par-cpf        as dec.
  
par-barracupom = "".
/*  "112240000506868594130000028184018900005000". */
repeat.
  
update skip(2) 
    par-barracupom
    skip(2)
    with frame fbarra
     row 5 centered
     color messages
     no-labels
     overlay
     title "BARRA DO CUPOM DE DESCONTO".
hide frame fbarra no-pause.

if par-barracupom = ""
then return.

par-cpf      = dec(substring(par-barracupom,10,11)).
if par-cpf <> pcpf
then do:
    message color normal "CPF DIFERE DO CLIENTE".
    pause.
    next.
    /*
    hide frame fbarra no-pause.
    return.
    **/
end.

par-campanha = int(substring(par-barracupom,1,6)).
par-valor    = dec(substring(par-barracupom,35)) / 100.  

def var par-NSUSafe  as char.
def var par-mensagem as char.

run ws-safe-cupom.p
        (par-cpf,
         par-campanha,
         par-valor,
         output par-NSUSafe,
         output par-mensagem).

hide message no-pause.
message "RETORNO SAFE:" par-mensagem "NSU" par-NSUSafe.
if par-mensagem <> "TRANSAC APROVADA"
then do:
    par-valor = 0.
    par-campanha = 0.
    pause.
    next.
end.    
pause 2 no-message .
hide frame fbarra no-pause.
leave.
end.
