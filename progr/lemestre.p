/*  programa que le parametro do ../mestre(loja).ini */
{admcab.i}
def input  parameter  par-tipo          as char format "x(40)".
def output parameter  par-valor         as char format "x(40)".
def var               v-tipo            as char format "x(40)".
def var               v-valor           as char format "x(40)".
assign par-valor = ""
       v-tipo    = ""
       v-valor   = "".
if search("/usr/admcom/etc/mestre" + string(setbcod) + ".ini") <> ?
then do:
    input from value("/usr/admcom/etc/mestre" + string(setbcod) + ".ini") no-echo.
    repeat:
        set v-tipo
            v-valor.
        if par-tipo = v-tipo
        then do:
            par-valor = v-valor.
            leave.
        end.    
    end. 
    input close.
end.        
