/* medico na tela 042022 - helio */

{admcab.i}

def var pseguevenda as log.
def var pqtdvezes   as int.

{meddefs.i}


find first ttmedprodu where ttmedprodu.procod = pprocod no-lock.

def var vnome as char format "x(35)".

update pcpf colon 15
    with frame fcab row 6 no-box color messages side-labels
    width 80.
    
find clien where clien.ciccgc = string(pcpf) no-lock no-error.
if avail clien
then do:
    vnome = clien.clinom.
    disp vnome no-label with frame fcab.
end.
else do:
    find clien where clien.ciccgc = string(pcpf,"99999999999") no-lock no-error.
    if avail clien
    then do:
        vnome = clien.clinom.
        disp vnome no-label with frame fcab.
    end.
    else do:
        run cpf.p (string(pcpf,"99999999999"), output sresp). 
        if not sresp 
        then do: 
            message "CPF INVALIDO" view-as alert-box. 
            undo. 
        end. 
    end.
end.    
    

    for each ttcampos.
        if ttcampos.idcampo =  "proposta.dataInicioVigencia" then ttcampos.conteudo = 
                                    string(year(today),"9999") + "-" +
                                  string(month(today),"99") + "-" +
                                  string(day(today),"99").

        if ttcampos.idcampo =  "proposta.dataFimVigencia" then ttcampos.conteudo = 
                                    string(year(today + 365),"9999") + "-" +
                                  string(month(today + 365),"99") + "-" +
                                  string(day(today + 365),"99").

        if ttcampos.idcampo =  "proposta.vigenciaPeriodoEmMeses" then ttcampos.conteudo = "12".
        
        if ttcampos.idcampo =  "proposta.cliente.cpf" then ttcampos.conteudo = string(pcpf,"99999999999").
        if ttcampos.idcampo =  "proposta.codigoVendedor" then ttcampos.conteudo = string(pvencod).
        if ttcampos.idcampo =  "vendedor.nome" then do:
            find first func where func.etbcod = setbcod and func.funcod = pvencod no-lock no-error.
            if avail func
            then ttcampos.conteudo = string(func.funnom).
        end.    
        if ttcampos.idcampo =  "codigoFilial" then ttcampos.conteudo = string(setbcod).
        if ttcampos.idcampo =  "origemComercial.nome" then do:
                ttcampos.conteudo = "Filial " + string(setbcod,"9999").
        end.    
        
        
        if avail clien
        then do:
            if clien.dtnasc <> ?
            then
                if ttcampos.idcampo =  "proposta.cliente.dataNascimento" then ttcampos.conteudo = 
                            string(year(clien.dtnasc),"9999") + "-" +
                                  string(month(clien.dtnasc),"99") + "-" +
                                  string(day(clien.dtnasc),"99").
            if ttcampos.idcampo =  "proposta.cliente.nome" then ttcampos.conteudo = string(clien.clinom).
            if ttcampos.idcampo =  "proposta.cliente.genero" then ttcampos.conteudo =  trim(string(clien.sexo,"M/F")). 
            if ttcampos.idcampo =  "proposta.cliente.estadoCivil" then ttcampos.conteudo = "".
            if ttcampos.idcampo =  "proposta.cliente.endereco.rua" then ttcampos.conteudo = clien.endereco[1].
            if ttcampos.idcampo =  "proposta.cliente.endereco.numero" then ttcampos.conteudo = string(clien.numero[1]).
            if ttcampos.idcampo =  "proposta.cliente.endereco.complemento" then ttcampos.conteudo = clien.compl[1].
            if ttcampos.idcampo =  "proposta.cliente.endereco.bairro" then ttcampos.conteudo = clien.bairro[1].
            if ttcampos.idcampo =  "proposta.cliente.endereco.cidade" then ttcampos.conteudo = clien.cidade[1].
            if ttcampos.idcampo =  "proposta.cliente.endereco.estado" then ttcampos.conteudo = clien.ufecod[1].
            if ttcampos.idcampo =  "proposta.cliente.endereco.cep" then ttcampos.conteudo = string(int(clien.cep[1])) no-error.
            if length(clien.fone) = 10 or length(clien.fone) = 11
            then do:
                if ttcampos.idcampo =  "ddd" then ttcampos.conteudo = substring(string(clien.fone),1,2).
                if ttcampos.idcampo =  "proposta.cliente.endereco.celular" then ttcampos.conteudo  = substring(string(clien.fone),3).
            end.
            else do:
                if ttcampos.idcampo =  "ddd" then ttcampos.conteudo = "".
                if ttcampos.idcampo =  "numero" then ttcampos.conteudo = string(clien.fax).
            end.
            
            if length(clien.fax) = 11 or length(clien.fax) = 10
            then do:
                if ttcampos.idcampo =  "ddd" then ttcampos.conteudo    = substring(string(clien.fax),1,2).
                if ttcampos.idcampo =  "numero" then ttcampos.conteudo = substring(string(clien.fax),3).
            end.
            else do:
                if ttcampos.idcampo =  "ddd" then ttcampos.conteudo = "".
                if ttcampos.idcampo =  "numero" then ttcampos.conteudo = string(clien.fax).
            end.
            
            if ttcampos.idcampo =  "logradouro" then ttcampos.conteudo = clien.endereco[1].
            if ttcampos.idcampo =  "numero" then ttcampos.conteudo = string(clien.numero[1]).
            if ttcampos.idcampo =  "complemento" then ttcampos.conteudo = clien.compl[1].
            if ttcampos.idcampo =  "bairro" then ttcampos.conteudo = clien.bairro[1].
            if ttcampos.idcampo =  "cidade" then ttcampos.conteudo = clien.cidade[1].
            if ttcampos.idcampo =  "estado" then ttcampos.conteudo = clien.ufecod[1].
            if ttcampos.idcampo =  "cep" then ttcampos.conteudo = string(clien.cep[1]).
            /* 03/09/2021*/
            if ttcampos.idcampo =  "rg.documento" then ttcampos.conteudo = string(clien.ciinsc).
            if ttcampos.idcampo =  "proposta.cliente.endereco.email" then ttcampos.conteudo = string(clien.zona).
            if ttcampos.idcampo =  "nacionalidade" then ttcampos.conteudo = string(clien.nacion).
            
            def var cestcivil as char.
            cestcivil = if clien.estciv = 1 then "SOLTEIRO" else
                        if clien.estciv = 2 then "CASADO"   else 
                        if clien.estciv = 3 then "VIUVO"    else 
                        if clien.estciv = 4 then "DESQUITADO" else 
                        if clien.estciv = 5 then "DIVORCIADO" else 
                        if clien.estciv = 6 then "OUTROSo" 
                        else "OUTROS". 
            if ttcampos.idcampo =  "estadoCivil" then ttcampos.conteudo = string(cestcivil).
                                                                                        
                                                                                        
        end.
    end. 


    if not avail clien
    then do:
        hide message no-pause.
        message "Cliente nao encontrato na base. Preencha o cadastro...".
    end.    

    pclicod = if avail clien then clien.clicod else 0.

    repeat:
        run medteladinam.p (output pseguevenda).
    
        if pseguevenda
        then do:

            run medsimparcela.p (output pfincod, output pqtdvezes).
        
            if true /*pfincod <> 0*/
            then do:
                find finan where finan.fincod = pfincod no-lock no-error.
                if not avail finan 
                then do: 
                    undo.
                end.
                                                    
            message "Confirma fechamento proposta, plano" pfincod finan.finnom update sresp.
                if not sresp
                then undo.
            
                run medproposta.p (input pqtdvezes).
            
            end.    
        end.
        leave.
        
    end.        
