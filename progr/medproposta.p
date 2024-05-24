/* medico na tela 042022 - helio */

{admcab.i}

def input param pqtdvezes   as int.

def var pmensagem as char.
def var pidPropostaLebes as char.
def var par-rec as recid.

def var pseguevenda as log.
def var vfincod as int.

{meddefs.i} 

find first ttmedprodu where ttmedprodu.procod = pprocod no-lock.

for each ttproposta.
    delete ttproposta.
end.    
for each ttrespostas.
    delete ttrespostas.
end.
    

        create ttproposta.
        ttproposta.codigoLoja     = string(setbcod).
        ttproposta.dataProposta  = string(year(today),"9999") + "-" +
                                  string(month(today),"99") + "-" +
                                  string(day(today),"99").
        ttproposta.cpf          = string(pcpf).
        ttproposta.tipoServico  = ttmedprodu.tipoServico.
        ttproposta.valorServico = ttmedprodu.valorServico.
        ttproposta.procod       = string(ttmedprodu.procod).
        ttproposta.idmedico     = ttmedprodu.idmedico.
                
        for each ttcampos where ttcampos.conteudo <> "".
            create ttrespostas.
            ttrespostas.idcampo     = ttcampos.idcampo.
            ttrespostas.conteudo    = if ttcampos.conteudoexpor <> ""
                                      then ttcampos.conteudoexpor
                                      else ttcampos.conteudo.
        end.
        
        
        
    pidPropostaLebes = ?.
    run medapienviaproposta.p (output pidPropostaLebes, output pmensagem).
    if pmensagem = ? or pmensagem = ""
    then pmensagem = "Ocorreu um erro.".

    
    if pidPropostaLebes <> ?
    then do:
        message pidPropostaLebes.
        pause 1 no-message .
    
        find first ttproposta.
        ttproposta.idPropostaLebes = pidPropostaLebes.
        find finan where finan.fincod = pfincod no-lock.
        find clien where clien.clicod = pclicod no-lock no-error.
        create ttpropostacliente.

        for each ttrespostas:
            if ttrespostas.idcampo =  "proposta.cliente.nome" 
                then ttpropostacliente.clinom = ttrespostas.conteudo.
            if ttrespostas.idcampo =  "proposta.cliente.rua"
                then ttpropostacliente.endereco = ttrespostas.conteudo.
            if ttrespostas.idcampo =  "proposta.cliente.numero" 
                then ttpropostacliente.numero = ttrespostas.conteudo.
            if ttrespostas.idcampo =  "proposta.cliente.complemento" 
                then ttpropostacliente.compl = ttrespostas.conteudo.
            if ttrespostas.idcampo =  "proposta.cliente.bairro" 
                then ttpropostacliente.bairro = ttrespostas.conteudo.
            if ttrespostas.idcampo =  "proposta.cliente.cidade" 
                then ttpropostacliente.cidade = ttrespostas.conteudo.
            if ttrespostas.idcampo =  "proposta.cliente.estado" 
                then ttpropostacliente.ufecod = ttrespostas.conteudo.
            if ttrespostas.idcampo =  "proposta.cliente.cep" 
                then ttpropostacliente.cep = ttrespostas.conteudo.
        end.
                
        run medgerpre.p   (recid(finan),recid(clien),output par-rec).
        run medpedidop2k.p (par-rec).
        
        find plani where recid(plani) = par-rec no-lock.
        message color red/with 
            skip "PREVENDA GERADA" 
            skip(2) "PROPOSTA " pidPropostaLebes skip(1)
            skip "RESGATE P2K:" string(plani.numero) 
            skip(1) view-as alert-box title "". 
    
    end.
    else do:
        message pmensagem.
        pause 3 message "ocorreu um problema...".
    end.
    
            
            

    
    
