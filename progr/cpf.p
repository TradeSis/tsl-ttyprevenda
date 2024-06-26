/* cpf.p  -  Validação do CPF                                                 */

/*******************************************************************************
*         Vari veis necess rias no programa                                    *
*                                                                              *
*   def var v-certo         as log.                                            *
*   def var v-resto1        as int.                                            *
*   def var v-resto2        as int.                                            *
*   def var v-digito1       as int.                                            *
*   def var v-digito2       as int.                                            *
*                                                                              *
*******************************************************************************/

def var v-certo         as log.
def var v-resto1        as int.
def var v-resto2        as int.
def var v-digito1       as int.
def var v-digito2       as int.

def input  param par-cpf     like clien.ciccgc.
def output param par-certo   as log.

par-certo = yes.

if length(par-cpf) <> 11
then do:
    par-certo = no.
    return.
end.

def var i as int.

do i = 1 to 11:
    if substr(string(par-cpf),i,1) <> "1" and
       substr(string(par-cpf),i,1) <> "2" and
       substr(string(par-cpf),i,1) <> "3" and
       substr(string(par-cpf),i,1) <> "4" and
       substr(string(par-cpf),i,1) <> "5" and
       substr(string(par-cpf),i,1) <> "6" and
       substr(string(par-cpf),i,1) <> "7" and
       substr(string(par-cpf),i,1) <> "8" and
       substr(string(par-cpf),i,1) <> "9" and
       substr(string(par-cpf),i,1) <> "0" 
     then do:
        par-certo = no.
        leave.
     end.
end.

if par-certo = no then return.

v-digito1 = (if ((int(substr(string(par-cpf,"99999999999"),01,1)) * 10 +
                  int(substr(string(par-cpf,"99999999999"),02,1)) *  9 +
                  int(substr(string(par-cpf,"99999999999"),03,1)) *  8 +
                  int(substr(string(par-cpf,"99999999999"),04,1)) *  7 +
                  int(substr(string(par-cpf,"99999999999"),05,1)) *  6 +
                  int(substr(string(par-cpf,"99999999999"),06,1)) *  5 +
                  int(substr(string(par-cpf,"99999999999"),07,1)) *  4 +
                  int(substr(string(par-cpf,"99999999999"),08,1)) *  3 +
                  int(substr(string(par-cpf,"99999999999"),09,1)) *  2)
                  modulo 11 = 0) or
                ((int(substr(string(par-cpf,"99999999999"),01,1)) * 10 +
                  int(substr(string(par-cpf,"99999999999"),02,1)) *  9 +
                  int(substr(string(par-cpf,"99999999999"),03,1)) *  8 +
                  int(substr(string(par-cpf,"99999999999"),04,1)) *  7 +
                  int(substr(string(par-cpf,"99999999999"),05,1)) *  6 +
                  int(substr(string(par-cpf,"99999999999"),06,1)) *  5 +
                  int(substr(string(par-cpf,"99999999999"),07,1)) *  4 +
                  int(substr(string(par-cpf,"99999999999"),08,1)) *  3 +
                  int(substr(string(par-cpf,"99999999999"),09,1)) *  2)
                  modulo 11 = 1)
              then  0
              else (11 -
                   (int(substr(string(par-cpf,"99999999999"),01,1)) * 10 +
                    int(substr(string(par-cpf,"99999999999"),02,1)) *  9 +
                    int(substr(string(par-cpf,"99999999999"),03,1)) *  8 +
                    int(substr(string(par-cpf,"99999999999"),04,1)) *  7 +
                    int(substr(string(par-cpf,"99999999999"),05,1)) *  6 +
                    int(substr(string(par-cpf,"99999999999"),06,1)) *  5 +
                    int(substr(string(par-cpf,"99999999999"),07,1)) *  4 +
                    int(substr(string(par-cpf,"99999999999"),08,1)) *  3 +
                    int(substr(string(par-cpf,"99999999999"),09,1)) *  2)
                    modulo 11)).

if v-digito1 <> int(substr(string(par-cpf,"99999999999"),10,1))
then
    par-certo = no.

v-digito2 = (if ((int(substr(string(par-cpf,"99999999999"),01,1)) * 11 +
                  int(substr(string(par-cpf,"99999999999"),02,1)) * 10 +
                  int(substr(string(par-cpf,"99999999999"),03,1)) *  9 +
                  int(substr(string(par-cpf,"99999999999"),04,1)) *  8 +
                  int(substr(string(par-cpf,"99999999999"),05,1)) *  7 +
                  int(substr(string(par-cpf,"99999999999"),06,1)) *  6 +
                  int(substr(string(par-cpf,"99999999999"),07,1)) *  5 +
                  int(substr(string(par-cpf,"99999999999"),08,1)) *  4 +
                  int(substr(string(par-cpf,"99999999999"),09,1)) *  3 +
                  int(substr(string(par-cpf,"99999999999"),10,1)) *  2)
                  modulo 11 = 0) or
                ((int(substr(string(par-cpf,"99999999999"),01,1)) * 11 +
                  int(substr(string(par-cpf,"99999999999"),02,1)) * 10 +
                  int(substr(string(par-cpf,"99999999999"),03,1)) *  9 +
                  int(substr(string(par-cpf,"99999999999"),04,1)) *  8 +
                  int(substr(string(par-cpf,"99999999999"),05,1)) *  7 +
                  int(substr(string(par-cpf,"99999999999"),06,1)) *  6 +
                  int(substr(string(par-cpf,"99999999999"),07,1)) *  5 +
                  int(substr(string(par-cpf,"99999999999"),08,1)) *  4 +
                  int(substr(string(par-cpf,"99999999999"),09,1)) *  3 +
                  int(substr(string(par-cpf,"99999999999"),10,1)) *  2)
                  modulo 11 = 1)
                  then  0
                  else (11 -
                 (int(substr(string(par-cpf,"99999999999"),01,1)) * 11 +
                  int(substr(string(par-cpf,"99999999999"),02,1)) * 10 +
                  int(substr(string(par-cpf,"99999999999"),03,1)) *  9 +
                  int(substr(string(par-cpf,"99999999999"),04,1)) *  8 +
                  int(substr(string(par-cpf,"99999999999"),05,1)) *  7 +
                  int(substr(string(par-cpf,"99999999999"),06,1)) *  6 +
                  int(substr(string(par-cpf,"99999999999"),07,1)) *  5 +
                  int(substr(string(par-cpf,"99999999999"),08,1)) *  4 +
                  int(substr(string(par-cpf,"99999999999"),09,1)) *  3 +
                  int(substr(string(par-cpf,"99999999999"),10,1)) *  2)
                  modulo 11)).

if v-digito2 <> int(substr(string(par-cpf,"99999999999"),11,1))
then
    par-certo = no.

if par-cpf = "0" or
   par-cpf = ?   or
   par-cpf = "" or
   length(par-cpf) <> 11   or
   par-cpf = "11111111111" or
   par-cpf = "22222222222" or
   par-cpf = "33333333333" or
   par-cpf = "44444444444" or
   par-cpf = "55555555555" or
   par-cpf = "66666666666" or
   par-cpf = "77777777777" or
   par-cpf = "88888888888" or
   par-cpf = "99999999999" or
   par-cpf = "00000000000" 
then par-certo = no.

