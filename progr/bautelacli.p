/* #082022 helio bau */

{admcab.i}
def output param phttp_code as int.
def var presposta as char.

def var pcliennovo  as log.
{acentos.i}
{baudefs.i}

find first ttbauprodu where ttbauprodu.procod = pprocod no-lock.

def var vnome as char format "x(35)".
def var vsobrenome as char .

        form 
     ttgetcliente.nome  colon 20 format "x(10)"
     ttgetcliente.sobrenome format "x(30)" no-label
     ttgetcliente.cpf   colon 20 format "x(11)"
     ttgetcliente.dtnasc colon 20 
     ttgetcliente.cep colon 20 format "99999999"
     ttgetcliente.estado colon 20 format "X(2)"
     ttgetcliente.cidade colon 20 format "x(40)"
     ttgetcliente.bairro colon 20 format "x(40)"
     ttgetcliente.endereco colon 20 format "x(40)"
     ttgetcliente.numero format ">>>>>>9"
     ttgetcliente.email colon 20 format "x(40)"
     ttgetcliente.celular colon 20 format "x(40)"
        
        with frame fcli
        centered row 7 title " CLIENTE BAU "
        side-labels.

    
find clien where clien.ciccgc = string(pcpf) no-lock no-error.
if avail clien
then do:
    vnome         = entry(1,clien.clinom," "). 
    vsobrenome    = trim(replace(clien.clinom,entry(1,clien.clinom," "),"")).
end.
else do:
    find clien where clien.ciccgc = string(pcpf,"99999999999") no-lock no-error.
    if avail clien
    then do:
        vnome         = entry(1,clien.clinom," ").
        vsobrenome    = trim(replace(clien.clinom,entry(1,clien.clinom," "),"")).
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
    
    vnome = removeAcento(vnome).     
    vsobrenome = removeAcento(vsobrenome).
    
    disp vnome @ ttgetcliente.nome
         vsobrenome @ ttgetcliente.sobrenome
         string(pcpf,"99999999999")       @ ttgetcliente.cpf
         with frame fcli.

output to value("/usr/admcom/logs/apibau" + string(today,"99999999") + ".log") append.
put unformatted 
"bau PID=" spid "_" spidseq 
" cliente " pcpf
    skip.
output close.
         
    run bauapigetcliente.p (output phttp_code, output presposta).

    if phttp_code <> 200 and phttp_code <> 404
    then do:
        return.
    end.
    pclicod = if avail clien then clien.clicod else 0.

    
    pcliennovo = phttp_code = 404.
    if pcliennovo
    then do: 

output to value("/usr/admcom/logs/apibau" + string(today,"99999999") + ".log") append.
put unformatted 
"bau PID=" spid "_" spidseq 
" cliente " pcpf " nao encontrato no BAU"
    skip.
output close.
        
     end.           
    
    do
        with frame fcli.

        find first ttgetcliente no-error.  
        if not avail ttgetcliente
        then do:         
            create ttgetcliente.
            if avail clien
            then do:
                ttgetcliente.nome         = removeAcento(entry(1,clien.clinom," ")).
                ttgetcliente.sobrenome    = removeAcento(trim(replace(clien.clinom,entry(1,clien.clinom," "),""))).
                ttgetcliente.cpf          = string(pcpf,"99999999999").
                ttgetcliente.dtnasc       = clien.dtnasc.
                ttgetcliente.cep          = string(int(clien.cep[1])).
                ttgetcliente.estado     = clien.ufecod[1].
                ttgetcliente.cidade     = clien.cidade[1].
                ttgetcliente.bairro     = clien.bairro[1].
                ttgetcliente.endereco   = clien.endereco[1].
                ttgetcliente.numero     = clien.numero[1].
                ttgetcliente.email      = string(clien.zona).
                ttgetcliente.celular    = string(clien.fax).
            end.            
            
        end.
        else do:
            
        end.

        disp ttgetcliente.nome ttgetcliente.sobrenome ttgetcliente.cpf
                ttgetcliente.dtnasc
                    ttgetcliente.cep  
                    ttgetcliente.estado  
                    ttgetcliente.cidade  
                    ttgetcliente.bairro  
                    ttgetcliente.endereco  
                    ttgetcliente.numero  
                    ttgetcliente.email  
                    ttgetcliente.celular.
                     
        if pcliennovo and 
           not avail clien
        then update 
            ttgetcliente.nome 
            ttgetcliente.sobrenome.
        ttgetcliente.cpf = string(pcpf,"99999999999").
        disp ttgetcliente.cpf.
        
        if not avail clien and pcliennovo
        then do:
            update ttgetcliente.dtnasc .
            
        end.
        if pcliennovo
        then 
        update    
                    ttgetcliente.cep  
                    ttgetcliente.estado  
                    ttgetcliente.cidade  
                    ttgetcliente.bairro  
                    ttgetcliente.endereco  
                    ttgetcliente.numero  
                    ttgetcliente.email  
                    ttgetcliente.celular.
        if pcliennovo
        then do:
            /*
               POST https://hmlsacbau.jequiti.com.br/api/cliente
            */    
            
            message "confirma cadastramento do cliente" ttgetcliente.nome "? " update sresp.
            if not sresp
            then return.
            
            pause 1.
            hide message no-pause.
            /* Chamada API BAU CadastraCliente POST /api/cliente/ */
            run bauapipostcliente.p (output phttp_code, output presposta).
            
output to value("/usr/admcom/logs/apibau" + string(today,"99999999") + ".log") append.
put unformatted 
"bau PID=" spid "_" spidseq 
" cliente " pcpf " CADASTRADO"
phttp_code presposta
    skip.
output close.
            
            
        end.
        
            
            
        
    end.        
