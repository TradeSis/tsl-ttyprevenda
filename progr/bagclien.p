/* #102022 helio bag */

{admcab.i}
def input param pcpf as dec format "99999999999" label "CPF".

def var presposta as char.

{acentos.i}
{bagdefs.i}

def var vnome as char format "x(35)".

        form 
     ttcliente.nome  colon 20 format "x(35)"
     ttcliente.cpf   colon 20 
     ttcliente.cep colon 20 format "99999999"
     ttcliente.estado colon 20 format "X(2)"
     ttcliente.cidade colon 20 format "x(40)"
     ttcliente.bairro colon 20 format "x(40)"
     ttcliente.logradouro colon 20 format "x(40)"
     ttcliente.numero format ">>>>>>9"
     ttcliente.email colon 20 format "x(40)"
     ttcliente.celular colon 20 format "x(40)"
        
        with frame fcli
        centered row 10 title " CLIENTE LEBES BAG " overlay
        side-labels.

    
find clien where clien.ciccgc = string(pcpf) no-lock no-error.
if avail clien
then do:
    vnome         = clien.clinom.
end.
else do:
    find clien where clien.ciccgc = string(pcpf,"99999999999") no-lock no-error.
    if avail clien
    then do:
        vnome         = clien.clinom.
    end.
    else do:
        message "CLIENTE PRECISA SER CADASTRADO!"
            view-as alert-box .
        undo, return.     
        /* helio 16082023    
        run cpf.p (string(pcpf,"99999999999"), output sresp). 
        if not sresp 
        then do: 
            message "CPF INVALIDO" view-as alert-box. 
            undo. 
        end. 
        */
    end.
end.    
    
    vnome = caps(removeAcento(vnome)).     
    
    disp vnome @ ttcliente.nome
         string(pcpf,"99999999999")       @ ttcliente.cpf
         with frame fcli.

    /*pclicod = if avail clien then clien.clicod else 0.*/

            create ttcliente.
            ttcliente.nome         = vnome.
            ttcliente.cpf          = pcpf.
            
            if avail clien
            then do:
                ttcliente.clicod     = clien.clicod.           
                ttcliente.cep          = string(int(clien.cep[1])).
                ttcliente.estado     = clien.ufecod[1].
                ttcliente.cidade     = clien.cidade[1].
                ttcliente.bairro     = clien.bairro[1].
                ttcliente.logradouro   = clien.endereco[1].
                ttcliente.numero     = clien.numero[1].
                ttcliente.email      = string(clien.zona).
                ttcliente.celular    = string(clien.fax).
            end.            
            
    do with frame fcli.
    
        disp ttcliente.nome  ttcliente.cpf
                    ttcliente.cep  
                    ttcliente.estado  
                    ttcliente.cidade  
                    ttcliente.bairro  
                    ttcliente.logradouro  
                    ttcliente.numero  
                    ttcliente.email  
                    ttcliente.celular.

            
        ttcliente.cpf = pcpf.
        
        disp ttcliente.cpf.
                      
        if not avail clien
        then update 
            ttcliente.nome .
        ttcliente.nome  = caps(removeAcento(ttcliente.nome)).     
        disp ttcliente.nome.
               
        update    
                    ttcliente.cep  
                    ttcliente.estado  
                    ttcliente.cidade  
                    ttcliente.bairro  
                    ttcliente.logradouro  
                    ttcliente.numero  
                    ttcliente.email  
                    ttcliente.celular.
            
        
            
            
    end.    
