def input param petbcod as int.
def output param par-arq as char.

def var par-dir as char.

par-dir = "/usr/p2ksp/pedidos/ped_download/" + string(petbcod,"9999") + "/".

def temp-table tt-arqs no-undo
    field arquivos as char format "x(25)" label "Arquivo"
    field full-pathname as char
     field Numero_Pedido  as int format ">>>>>>>>>>9"
    field codigo_loja    as int format ">>9" label "Fil"
    field Codigo_Cliente as int format ">>>>>>>>>9" label "Cliente"
    field nome_cliente   as char format "x(20)" label "Nome"
    index arquivo is unique primary arquivos asc.

{pedidos_p2k.i}

for each tt-arqs.
    delete tt-arqs.
end.

pause 0.
DEFINE VARIABLE cFileStream AS CHARACTER NO-UNDO.
/*
if search(par-dir) = ?
then do:
    message par-dir. pause.
    return.
end.    
*/
    INPUT FROM OS-DIR (par-dir).
    REPEAT:
        IMPORT cFileStream. 
        FILE-INFO:FILE-NAME = par-dir + cFileStream.
        if  entry(num-entries(cFileStream,"."),cFileStream,".") = "csi" /*or
            entry(num-entries(cFileStream,"."),cFileStream,".") = "pag" */
        then.
        else  next.
    
        create tt-arqs.
        tt-arqs.arquivos        = cFileStream.
        tt-arqs.FULL-PATHNAME   = FILE-INFO:FULL-PATHNAME.
    /*
            DISPLAY cFileStream FORMAT "X(18)" LABEL 'name of the file'
                        FILE-INFO:FULL-PATHNAME FORMAT "X(21)" LABEL 'FULL-PATHNAME'
                                    FILE-INFO:PATHNAME FORMAT "X(21)" LABEL 'PATHNAME'
                                                FILE-INFO:FILE-TYPE FORMAT "X(5)" LABEL 'FILE-TYPE'.
*/                                                
        for each ttp2k_pedido01. 
                delete ttp2k_pedido01. 
        end.
 
        run importa_file_p2k.p (input tt-arqs.FULL-PATHNAME,1).
 

        find first ttp2k_pedido01.
        tt-arqs.numero_pedido   = ttp2k_pedido01.numero_pedido.
        tt-arqs.codigo_loja     = ttp2k_pedido01.codigo_loja.
        tt-arqs.Codigo_Cliente  = ttp2k_pedido01.Codigo_Cliente.
        tt-arqs.nome_cliente    = ttp2k_pedido01.nome_cliente.
        delete ttp2k_pedido01.    
    
    END.
    input close.
 
/*

*/

def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqvazio        as log.
def var esqascend       as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial ["Seleciona","" ,"",""].


form
    esqcom1
    with frame f-com1 row 4 no-box no-labels column 1 centered
        overlay.
assign
    esqpos1  = 1.

find first tt-arqs no-error.
if not avail tt-arqs 
then return.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find tt-arqs where recid(tt-arqs) = recatu1 no-lock.
    if not available tt-arqs
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then run frame-a.

    recatu1 = recid(tt-arqs).
    color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tt-arqs
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        if not esqvazio
        then do:
            find tt-arqs where recid(tt-arqs) = recatu1 no-lock.


            status default "".

            choose field tt-arqs.arquivos help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      PF4 F4 ESC return).

            status default "".
        end.

            if keyfunction(lastkey) = "cursor-right"
            then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
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
                    if not avail tt-arqs
                    then leave.
                    recatu1 = recid(tt-arqs).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-arqs
                    then leave.
                    recatu1 = recid(tt-arqs).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-arqs
                then next.
                color display white/red tt-arqs.arquivos with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-arqs
                then next.
                color display white/red tt-arqs.arquivos with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            hide frame frame-a no-pause.
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

            if esqcom1[esqpos1] = "Seleciona "
            then do:
                par-arq = tt-arqs.full-pathname .
                leave bl-princ.
            end.
        end.
        if not esqvazio
        then run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(tt-arqs).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.
hide frame f-sub   no-pause.

procedure frame-a.

    display
        tt-arqs.arquivos
        tt-arqs.numero_pedido
        tt-arqs.codigo_loja
        tt-arqs.Codigo_Cliente
        tt-arqs.nome_cliente
        with frame frame-a 12 down centered color white/red row 6 no-box
            overlay.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first tt-arqs 
                                no-lock no-error.
    else  
        find last tt-arqs 
                                no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next tt-arqs  
                                no-lock no-error.
    else  
        find prev tt-arqs  
                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev tt-arqs  
                                        no-lock no-error.
    else   
        find next tt-arqs 
                                        no-lock no-error.
end procedure.


