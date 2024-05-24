/*----------------------------------------------------------------------------*/
/* /usr/admger/cab.i                           Cabecalho Geral das Aplicacoes */
/*                                                                            */
/* Data     Autor   Caracteristica                                            */
/* -------- ------- ------------------                                        */
/* 27/02/92 Masiero Criacao                                                   */
/*----------------------------------------------------------------------------*/
/***
message program-name(1) program-name(2). PAUSE 1 NO-MESSAGE.
***/
def {1} shared variable wdata as date format "99/99/9999"
                      label "Data de Processamento".
def {1} shared variable wtittela as char format "x(30)".
def {1} shared buffer wempre for empre.
def {1} shared variable wmodulo as c.
def {1} shared variable wareasis as char format "x(38)".
def {1} shared variable wtitulo  as char format "x(80)".
def {1} shared var lclifor as log .        
def {1} shared var wretorno-pdv as log.
def {1} shared var wstatusr-pdv as char.
def {1} shared var wmotivor-pdv as char.
def {1} shared var wparctef-pdv as int.
def var b1 as char format "x".
def var b2 as char format "x".
def var b3 as char format "x".
def var b4 as char format "x".
def var smens as char format "x(20)".
b1 = "|".
b2 = "|".
b3 = "|".
b4 = "|".
define variable ytit like wtittela.
def new global shared var sparam      as char.
def new global shared var sresp      as log format "Sim/Nao".
def new global shared var setbcod    like estab.etbcod.
def new global shared var sfuncod    like func.funcod.
def new global shared var scxacod    like estab.etbcod.
def new global shared var scliente   like admcom.cliente.
def new global shared var sautoriza  like autoriz.motivo.
def new global shared var svalor1    like autoriz.valor1.
def new global shared var svalor2    like autoriz.valor2.
def new global shared var svalor3    like autoriz.valor3.
def new global shared var scliaut    like autoriz.clicod.
def new global shared var stprcod    like tippro.tprcod.
def new global shared var scli       like clien.clicod.
def new global shared var sprog-fiscal    as   char format "x(40)".
def new global shared var secf            as   char format "x(40)".
def new global shared var sporta-ecf      as   char format "x(40)".
def new global shared var scarne          as   char format "x(40)".
def new global shared var srecibo         as   char format "x(40)".
def new global shared var srecibo         as   char format "x(40)".
def new global shared var spagto          as   char format "x(40)".
def new global shared var svenda          as   char format "x(40)".
def new global shared var smodelo-ecf     as   char format "x(40)".
def new global shared var sretorno-ecf     as   char format "x(40)".
def new global shared var scabrel       as char.
def new global shared var sretorno     as    char format "x(40)".
def new global shared var sestacao     as char.
def new global shared var wserie-nf  like plani.serie.
def new global shared var wemite-nf  like plani.emite. 
def new global shared var wnumero-nf like plani.numero.
def new global shared var wplacod-nf like plani.placod.
def new global shared var warqlog-pdv as char.
def new global shared var wcontnum   like contrato.contnum.
def new global shared var wtpamb-nf  as char.
def new global shared var wmodelo-nf  as char.
def new global shared var wfuso-hora as char.

/*def new global shared var sPROGRAMA  like PROGRAMA.PROGRAMA. */

define            variable vmesabr  as char format "x(04)" extent 12 initial
    ["Jan","Fev","Mar","Abr","Maio","Jun","Jul","Ago","Set","Out","Nov","Dez"].
define            variable vmescomp as char format "x(09)" extent 12 initial
    ["Janeiro","Fevereiro","Mar‡o","Abril","Maio","Junho",
     "Julho","Agosto", "Setembro","Outubro","Novembro","Dezembro"].
define            variable vsemabr  as char extent  7 format "x(03)" initial
    ["Dom", "Seg", "Ter", "Qua", "Qui", "Sex", "Sab"].
define            variable vsemcomp as char format "x(7)" extent 7 initial
    ["Domingo","Segunda","Ter‡a","Quarta","Quinta","Sexta","S bado"].


def {1} shared frame fc1.
def {1} shared frame fc2.
if "{1}" = "new"
then do:
    find first wempre NO-LOCK.
    wdata    = today.
    wareasis = " TESTE ".
    wtittela = "teste".
    wtitulo  = "                             ADMCOM VERSAO 2.0".
    setbcod = 188. /* 99. */
    scxacod = 1.
    stprcod = ?.
    on F6  help.
    on PF6 help.
    on F5  help.
    on PF5 help.
    on F7  help.
    on PF7 help.
end.

ytit = fill(" ",integer((30 - length(wtittela)) / 2)) + wtittela.

find estab where estab.etbcod = setbcod no-lock.

form space(1)
    wempre.emprazsoc format "x(65)" space(05) wdata
    with column 1 page-top no-labels top-only row 1 width 81 no-hide frame fc1
        no-box color black/gray.
form
    wtitulo          format "x(80)"
    with column 1 page-top no-labels top-only row 2 width 81 no-hide frame fc2
        no-box color blue/cyan overlay.

if "{1}" = "new"
then do:
    display wempre.emprazsoc + "/" + estab.etbnom @ wempre.emprazsoc
            wdata with frame fc1.
    display wtitulo                with frame fc2.
end.
status input "Digite os dados ou pressione [F4] para encerrar.".

if search("F:\OPERADOR\SJERONIM.CHP") <> ?
then put screen "LIGACAO INTERROMPIDA!" row 23 column 60 color blink/red.

FUNCTION acha returns character
    (input par-oque as char,
     input par-onde as char).
         
    def var vx as int. 
    def var vret as char.
               
    vret = ?.
                  
    do vx = 1 to num-entries(par-onde,"|").
         if entry(1,entry(vx,par-onde,"|"),"=") = par-oque
         then do: 
            vret = entry(2,entry(vx,par-onde,"|"),"=").
            leave. 
         end.
    end.
    return vret. 
END FUNCTION.

FUNCTION fusohr returns character.
    return
    SUBSTRING(  STRING(DATETIME-TZ(DATE(STRING(DAY(today),"99") + "/" +
    STRING(MONTH(today),"99") + "/" + STRING(YEAR(today),"9999")), MTIME,
    TIMEZONE)),  24,6)
       .
END FUNCTION.

wfuso-hora = fusohr().

