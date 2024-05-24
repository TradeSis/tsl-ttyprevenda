/* bau 092022 - helio */

{admcab.i}

def var pmensagem as char.
def var pidPropostaLebes as char.
def var par-rec as recid.

def var pseguevenda as log.
def var vfincod as int.

{baudefs.i} 

find first ttbauprodu where ttbauprodu.procod = pprocod no-lock.

for each ttproposta.
    delete ttproposta.
end.    
for each ttrespostas.
    delete ttrespostas.
end.
    
        find first ttgetcliente no-error.

        create ttproposta.
        ttproposta.codigoLoja     = string(setbcod).
        ttproposta.dataProposta  = string(year(today),"9999") + "-" +
                                  string(month(today),"99") + "-" +
                                  string(day(today),"99").
        ttproposta.tipoServico  = ttbauprodu.tipoServico.
        ttproposta.procod       = string(ttbauprodu.procod).
        ttproposta.idbau        = "JEQUITI".
        ttproposta.cpf          = if avail ttgetcliente then ttgetcliente.cpf else "".
        
        ttproposta.vlrservico = 0.
        
        if avail ttgetcliente
        then do:
            create ttrespostas. 
            ttrespostas.idcampo     = "proposta.cliente.cpf". 
            ttrespostas.conteudo    = ttgetcliente.cpf.
            create ttrespostas. 
            ttrespostas.idcampo     = "proposta.cliente.nome". 
            ttrespostas.conteudo    = ttgetcliente.nome + " " + ttgetcliente.sobrenome.
        end.
        
        for each ttgetparcelas where ttgetparcelas.marca = yes.    
            find first ttgetcarne where ttgetcarne.codcarne = ttgetparcelas.codcarne.
            create ttpostParcelas.
            ttpostParcelas.recorrente   = false.
            ttpostParcelas.data         = ttproposta.dataProposta.
            ttpostParcelas.codigoBarrasParcela  = ttgetparcelas.codigoBarras.
            ttpostParcelas.valor    = ttgetparcelas.titvlcob.
            ttpostparcelas.numeroParcela = ttgetparcelas.numero.
            ttpostParcelas.codigoBarras = ttgetcarne.codBarrasCarne.
            ttpostParcelas.numeroTransacao = "null".
            ttpostParcelas.codeLocalPagamento = "LEBES".

            ttproposta.vlrservico  = ttproposta.vlrservico + ttgetparcelas.titvlcob.
            
            if ttgetparcelas.numero = 1 and pcpf <> 0
            then do:
                run bauapivincularcarne.p (string(substring(ttpostParcelas.codigoBarras,1,3),"999"),
                                            string(substring(ttpostParcelas.codigoBarras,4),"9999999")).
            end.                                        
        end.                

        ttproposta.valorservico = trim(string(ttproposta.vlrservico,"->>>>>>>>>>>>>>>>>>>>>>>>>>>9.99")).
        
    pidPropostaLebes = ?.
    run bauapipostproposta.p (output pidPropostaLebes, output pmensagem).
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
        
                
        run baugerpre.p   (recid(finan),recid(clien),output par-rec).
        run baupedidop2k.p (par-rec).
        
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
    
            
            

    
    
