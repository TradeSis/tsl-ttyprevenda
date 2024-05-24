/* reversa 092022 - helio */

{admcab.i}
{lojreversa.i new}
def var presposta as char.
def var phttp_code as int.

INPUT THROUGH "echo $PPID".
DO ON ENDKEY UNDO, LEAVE:
IMPORT unformatted spid.
END.
INPUT CLOSE.
spidseq = spidseq + 1.


def var ctitle as char.
ctitle = "caixas abertas     - REVERSA".

/*def temp-table ttabertas no-undo
    field estabOrigem    as int
    field codCaixa  as int
    field etbdest   as int
    field dtalt     as date
    field hralt     as int
    field catcod    as int    
    field pid    as int
    index x codcaixa asc.
*/    
def var vhelp as char.
def var xtime as int.
def var vconta as int.
def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(11)" extent 6
    initial ["conteudo","nova caixa"," ",""].

form
    esqcom1
    with frame f-com1 row 5 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

form
        ttabertas.estabOrigem column-label "fil" format ">>9"
        ttabertas.codCaixa  column-label "caixa"
        ttabertas.etbdest  column-label "dest" format ">>9"
        ttabertas.catcod    column-label "cat" format ">>9"
        categ.catnom format "x(10)"        column-label "Categoria"
        ttabertas.dtalt column-label "dt digt " format "99/99/9999"
        ttabertas.hralt column-label "hr digt " format "99999999"
        
        ttabertas.pid format ">>>>>9"        
        ttabertas.idPedidoGerado format "x(10)"
        with frame frame-a 9 down centered row 7
        no-box.


    disp 
        ctitle format "x(70)" no-label
        with frame ftit
            side-labels
            row 3
            centered
            no-box
            color messages.


empty temp-table ttabertas.
run montatt.
recatu1 = ?.

bl-princ:
repeat:
    

    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find ttabertas where recid(ttabertas) = recatu1 no-lock.
    if not available ttabertas
    then do.
        message "nenhuma caixa aberta, deseja abrir?" update sresp.
        if not sresp then return.
                run lojreversanova.p .
                run montatt.
                find first ttabertas no-error.
                if not avail ttabertas
                then return.
                recatu1 = ?.
                next.

    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(ttabertas).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available ttabertas
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find ttabertas where recid(ttabertas) = recatu1 no-lock.

        esqcom1[1] = if ttabertas.idPedidoGerado = ? then "conteudo" else "". 
        esqcom1[5] = " ". 
        esqcom1[3] = "". 
/*        esqcom1[4] = "historico". */

        status default "".
        
                        
        /*             
        def var vx as int.
        def var va as int.
        va = 1.
        do vx = 1 to 6.
            if esqcom1[vx] = ""
            then next.
            esqcom1[va] = esqcom1[vx].
            va = va + 1.  
        end.
        vx = va.
        do vx = va to 6.
            esqcom1[vx] = "".
        end.     
        */
    hide message no-pause.
    /*    
    if ttabertas.titdescjur <> 0
    then do:
        if ttabertas.titdescjur > 0
        then do:
                message color normal 
            "juros calculado em" ttabertas.dtinc "de R$" trim(string(ttabertas.titvljur + ttabertas.titdescjur,">>>>>>>>>>>>>>>>>9.99"))    
            " dispensa de juros de R$"  trim(string(ttabertas.titdescjur,">>>>>>>>>>>>>>>>>9.99")).
        end.
        else do:
            message color normal 
            "juros calculado em" ttabertas.dtinc "de R$" trim(string(ttabertas.titvljur + ttabertas.titdescjur,">>>>>>>>>>>>>>>>>9.99"))    

            " juros cobrados a maior R$"  trim(string(ttabertas.titdescjur * -1 ,">>>>>>>>>>>>>>>>>9.99")).
        
        end.
        
    end.
    */    
        
        disp esqcom1 with frame f-com1.
        
        run color-message.
        vhelp = "".
        
        
        status default vhelp.
        choose field ttabertas.etbdest
                      help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      L l
                      tab PF4 F4 ESC return).

        if keyfunction(lastkey) <> "return"
        then run color-normal.

        hide message no-pause.
                 
        pause 0. 

                                                                
            if keyfunction(lastkey) = "cursor-right"
            then do:
                color display normal esqcom1[esqpos1] with frame f-com1.
                esqpos1 = if esqpos1 = 6 then 6 else esqpos1 + 1.
                color display messages esqcom1[esqpos1] with frame f-com1.
                next.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                color display normal esqcom1[esqpos1] with frame f-com1.
                esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                color display messages esqcom1[esqpos1] with frame f-com1.
                next.
            end.
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail ttabertas
                    then leave.
                    recatu1 = recid(ttabertas).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail ttabertas
                    then leave.
                    recatu1 = recid(ttabertas).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail ttabertas
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail ttabertas
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.
                
                
        if keyfunction(lastkey) = "return"
        then do:
            
            
             /*if esqcom1[esqpos1] = "cancela"
             then do: 
                hide message no-pause.
                sresp = no.
                message "Confirma cancelamento adesao numero " ttabertas.etbdest "?"
                    update sresp.
                if sresp
                then do:
                    run api/medcancelaadesao.p (recid(ttabertas)).
                    leave.
                end.
            end.
            */
            
             if esqcom1[esqpos1] = " csv "
             then do: 
                run geraCSV.
            end.
            if esqcom1[esqpos1] = "nova caixa"
            then do:
                hide frame frame-a no-pause.
                
                pause 0.
                run lojreversanova.p .
                run montatt.
                disp 
                    ctitle 
                        with frame ftit.
                recatu1 = ?.
                leave.
                    
            end.
            
            if esqcom1[esqpos1] = "conteudo"
            then do:
                pause 0.
                run lojreversaprodu.p (ttabertas.codCaixa).
                 run montatt. 
                 recatu1 = ?. 
                 leave.
                
            end.

            if esqcom1[esqpos1] = "historico"
            then do:
                pause 0.
                run  med/tmedadecanc.p (recid(ttabertas)).

                disp 
                    ctitle 
                        with frame ftit.
                
            end.
        end.        
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(ttabertas).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.
hide frame ftit no-pause.
hide frame ftot no-pause.
return.
 
procedure frame-a.
    find categoria of ttabertas no-lock no-error.
    display  
        ttabertas.estabOrigem
        ttabertas.codCaixa
        ttabertas.etbdest
        ttabertas.dtalt
        string(ttabertas.hralt,"HH:MM:SS") @ ttabertas.hralt
        ttabertas.catcod  
        categoria.catnom when avail categoria
        ttabertas.pid 
    ttabertas.idPedidoGerado
        with frame frame-a.


end procedure.

procedure color-message.
    color display message
        ttabertas.estabOrigem
        ttabertas.codCaixa
        ttabertas.etbdest
        ttabertas.dtalt
        ttabertas.catcod  
        ttabertas.pid 
                    
        with frame frame-a.
end procedure.


procedure color-input.
    color display input
        ttabertas.estabOrigem
        ttabertas.codCaixa
        ttabertas.etbdest
        ttabertas.dtalt
        ttabertas.catcod  
        ttabertas.pid 
                     
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        ttabertas.estabOrigem
        ttabertas.codCaixa
        ttabertas.etbdest
        ttabertas.dtalt
        ttabertas.catcod  
        ttabertas.pid 
 
        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.

    if par-tipo = "pri" 
    then do:
        find last ttabertas 
            no-lock no-error.
    end.    
                                             
    if par-tipo = "seg" or par-tipo = "down" 
    then do:
        find prev ttabertas 
            no-lock no-error.
    end.    
             
    if par-tipo = "up" 
    then do:
        find next ttabertas
            no-lock no-error.

    end.  
        
end procedure.





/**

procedure geraCSV.
def var pordem as int.
 
def var varqcsv as char format "x(65)".
    varqcsv = "/admcom/relat/ttabertas_" + lc(psituacao) + "_" + 
                string(today,"999999") + replace(string(time,"HH:MM:SS"),":","") + ".csv".
    
    
    disp varqcsv no-label colon 12
                            with side-labels width 80 frame f1
                            row 15 title "csv protestos ativos"
                            overlay.


message "Aguarde...". 
pause 1 no-message.

output to value(varqcsv).

put unformatted 
        "CPF ADESAO;NOME CLIENTE LEBES;NOME PACIENTE;DATA VENDA;DATA INICIO VIGENCIA;DATA FIM VIGENCIA;PLANO PGTO;STATUS VENDA;"   
        "DATA CANCELAMENTO;CERTIFICADO;LOJA;VALOR VENDA;VALOR REPASSE;VENDEDOR;PDV;NSU;"
        skip.
    for each ttabertas.
        find ttabertas where recid(ttabertas) = ttabertas.rec no-lock.
        run geraCsvImp.
    end.  


output close.

        hide message no-pause.
        message "Arquivo csv gerado " varqcsv.
        hide frame f1 no-pause.
        pause.    
end procedure.

procedure geraCsvImp.
def var vlrcobradocustas as dec.
def var vlrcobrado as dec.
def var vcp as char init ";".

        
def var vnomecliente    as char.        
def var vnomepaciente   as char.
def var vstatus         as char.
def var vvlrrepasse     as dec.
def var vvendedor       as char.
def var vcxacod         as int.
def var vdtinivig       as date.
def var vdtfimvig       as date.

    find baupagdados of ttabertas where baupagdados.idcampo = "proposta.dataInicioVigencia" no-lock no-error.
    vdtinivig   = if avail baupagdados 
        then date(int(entry(2,baupagdados.conteudo,"-")), int(entry(3,baupagdados.conteudo,"-")),int(entry(1,baupagdados.conteudo,"-")))
        else ?.
    find baupagdados of ttabertas where baupagdados.idcampo = "proposta.dataFimVigencia" no-lock no-error.
    vdtfimvig   = if avail baupagdados 
        then date(int(entry(2,baupagdados.conteudo,"-")), int(entry(3,baupagdados.conteudo,"-")),int(entry(1,baupagdados.conteudo,"-")))
        else ?.

    find baupagdados of ttabertas where baupagdados.idcampo = "proposta.cliente.nome" no-lock no-error.
    vnomepaciente   = if avail baupagdados then baupagdados.conteudo else "".

    release clien.
    if ttabertas.clicod <> 0 and ttabertas.clicod <> ?
    then do:
        find clien where clien.clicod = ttabertas.clicod no-lock no-error.    
    end.        
    vnomecliente    =  if avail clien then clien.clinom else vnomepaciente.
    
    vstatus = if ttabertas.dtcanc = ? then "ATIVA" else if ttabertas.dtcanc - ttabertas.dtalt <= 8 then "ANULADO" else "CANCELADA". 
    
    find baupagdados of ttabertas where baupagdados.idcampo = "proposta.codigoVendedor" no-lock no-error.
    vvendedor = baupagdados.conteudo + "-" .
    find func where func.estabOrigem = ttabertas.estabOrigem and func.funcod = int(baupagdados.conteudo) no-lock no-error.
    if avail func then vvendedor = vvendedor + func.funnom.
    find cmon of ttabertas no-lock no-error.
    vcxacod = if avail cmon then cmon.cxacod else 0.
        
    put unformatted 
        string(ttabertas.cpf,"99999999999")       vcp
        vnomecliente    vcp
        vnomepaciente   vcp
        string(ttabertas.dtalt,"99/99/9999") vcp
        if vdtinivig = ? then "" else string(vdtinivig,"99/99/9999")       vcp
        if vdtfimvig = ? then "" else string(vdtfimvig,"99/99/9999")       vcp
        ttabertas.fincod         vcp
        vstatus         vcp
        if ttabertas.dtcanc = ? then "" else string(ttabertas.dtcanc,"99/99/9999") vcp
        ttabertas.etbdest vcp
        ttabertas.estabOrigem            vcp
        
        trim(replace(string(ttabertas.valorServico,"->>>>>>>>>>>>>>>>>>>>>>9.99"),".",","))      vcp
        trim(replace(string(vvlrrepasse,"->>>>>>>>>>>>>>>>>>>>>>9.99"),".",","))                 vcp
        
        vvendedor                   vcp
        vcxacod                    vcp
        ttabertas.nsuTransacao      vcp
        skip.
            

end procedure.
 

**/

procedure montatt.
    
    
    run lojapireversa-abertas.p (output phttp_code, output presposta).
    
end procedure.
