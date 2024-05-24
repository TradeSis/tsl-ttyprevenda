/* helio 06022024 - colocado view-as nas messges */

def input param pcpfcnpj    as char.
def output param pclicod    as int.
def output param vresp      as log.
pclicod = ?.

def new global shared var setbcod as int.
def var par-certo as log.
/* helio 06022024 - testes de telefone */
def var vx as char.
def var vok as log.
def var vconta as int.
def new shared temp-table ttentrada serialize-name "dadosEntrada" 
    field codigoFilial   as int 
    field cpfCnpj        as char 
    field nomeCliente         as char  
    field dataNascimento         as date 
    field telefone       as char.
                    
    create ttentrada.
    ttentrada.codigoFilial = setbcod.
    ttentrada.cpfCnpj      = pcpfcnpj.

repeat 
    with frame fcad
    row 6
    overlay
    1 col
    centered
    title "CADASTRAMENTO DE CLIENTE"
    1 down
    on endkey undo, retry:
    if retry and keyfunction(lastkey) = "END-ERROR"
    then do:
        vresp = no.
                run clitelamensagem.p (INPUT-OUTPUT vresp,
                                   input "            CLIENTE NAO ESTA SENDO CADASTRADO!" + 
                                            chr(10) + chr(10) + "          Deseja Nao Cadastrar o Cliente?" ,
                                   input "",
                                   input "Sair Sem Cadastrar",
                                   input "Cadastrar").  
                    if vresp = yes  
                    then do:
                        vresp = no.
                            run clitelamensagem.p (INPUT-OUTPUT vresp,
                                   input "            CLIENTE NAO ESTA SENDO CADASTRADO!" + 
                                            chr(10) + chr(10) + " Tem Certeza que Deseja NAO cadastrar o Cliente?" ,
                                   input "",
                                   input "SIM",
                                   input "Cadastrar").  
                        if vresp = yes
                        then return.
                    end.                            
    
    end.
    update ttentrada.cpfCnpj       format "x(14)" label "CPF/CNPJ".
    
    run cpf.p (ttentrada.cpfCnpj, output par-certo).
    if not par-certo    
    then do:
        message "CPF Invalido" view-as alert-box.
        undo .
    end.

    /* verifica se nao existe ja na matriz */
    run lojapi-clienteconsultar.p (output pclicod).
    if pclicod <> ?
    then do:
        hide message no-pause.
        hide frame fcad no-pause.
        return.
    end.            


        
    
    update  ttentrada.nomeCliente   format "x(40)" label "Nome".
    if ttentrada.nomeCliente = ? or num-entries(ttentrada.nomeCliente," ") < 2
    then do:
        message "NOME Invalido" view-as alert-box.
        undo.
    end.
    ttentrada.nomeCliente = caps(ttentrada.nomeCliente).
    disp ttentrada.nomeCliente.
    update     ttentrada.datanascimento    format "99/99/9999" label "Data Nascimento".
    if ttentrada.datanascimento = ?
    then do:
        message "DATA NASCIMENTO Invalida" view-as alert-box.
        undo.
    end.
    update     ttentrada.telefone      format "(xx)xxxxxxxxx" label "Telefone".
    if ttentrada.telefone = ? or trim(ttentrada.telefone) = "" or
        length(trim(ttentrada.telefone)) < 10 
    then do:
        message "TELEFONE Invalido" view-as alert-box.
        undo.
    end.
    vok = no.
    vx = substring(ttentrada.telefone,3,1).
    do vconta = 3 to  length(ttentrada.telefone):
        if substring(ttentrada.telefone,vconta,1) <> vx
        then do:
            vok = yes.
            leave.
        end.    
    end.
    if vok = no
    then do:
        message "TELEFONE Invalido" view-as alert-box.
        undo.
    end.

    run lojapi-clientecadastrar.p (output pclicod).
    
    leave.
                        
end.

hide frame fcad no-pause.
