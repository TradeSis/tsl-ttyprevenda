/* helio02082023 - INCLUIR CAMPO TEMPO DE GARANTIA NA PRÉ VENDA - PROCESSO 521910 */
/*
helio 22122021    fase II.3 
helio 08/12/2021  fase II.2
helio 12/11/2021 novos campos fase 2 
*/

def var vdescricaoFornecedor as char.


def buffer zprodu for produ.
def shared temp-table wf-movim no-undo
    field wrec      as   recid
    field movqtm    like movim.movqtm
    field lipcor    like liped.lipcor
    field movalicms like movim.movalicms
    field desconto  like movim.movdes
    field movpc     like movim.movpc
    field precoori  like movim.movpc
    field vencod    like func.funcod
    field KITproagr   like produ.procod.


def var vprosit as log format "SIM/NAO". 
def var vpe     as log format "SIM/NAO".
def var vvex    as log format "SIM/NAO".
def var vtipomix as char format "x(6)".
def var vleadtime as char format "x(4)".
def var vstatusitem as char format "x(13)".
def var vmixloja  as char format "x(5)". 
def var vfabcod as char format "x(8)".
def var vtempogar as char format "x(03)".

def var vdescontinuado   as log format "SIM/NAO".

def var vmix    as log format "SIM/NAO".
def var vloop   as int.
def buffer sclase for clase.
FUNCTION acha2 returns character
    (input par-oque as char, 
     input par-onde as char). 
      
    def var vx as int. 
    def var vret as char.  
    vret = ?.  
    do vx = 1 to num-entries(par-onde,"|"). 
        if num-entries( entry(vx,par-onde,"|"),"#") = 2 and
                entry(1,entry(vx,par-onde,"|"),"#") = par-oque
        then do: 
            vret = entry(2,entry(vx,par-onde,"|"),"#"). 
            leave. 
        end. 
    end. 
    return vret. 
END FUNCTION.
 

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.

form zprodu.procod    column-label "Codigo"     format ">>>>>>>>9"
        zprodu.pronom    column-label "Produto"    format "x(40)"
        wf-movim.movqtm  column-label "Quantidade" format ">>>9"
        wf-movim.movpc   column-label "Preco"
        with frame frame-a 10 down width 80 row 4
                title (" Produtos ") overlay.


/*
def var esqcom1         as char format "x(12)" extent 5
    initial [" Voltar "," "," "," "," "].
def var esqcom2         as char format "x(12)" extent 5
            initial [" "," ","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial [" ",
             " ",
             " ",
             " ",
             " "].
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].
*/

{admcab.i}

def buffer bwf-movim       for wf-movim.


/*
form
    esqcom1
    with frame f-com1
                 row 4 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
*/
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

bl-princ:
repeat:

/*    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.*/
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find wf-movim where recid(wf-movim) = recatu1 no-lock.
    if not available wf-movim
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(wf-movim).
/*    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.*/
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available wf-movim
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        run frame-a.
    end.
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        if not esqvazio
        then do:
            find wf-movim where recid(wf-movim) = recatu1 no-lock.
        
        find produ where recid(produ) = wf-movim.wrec no-lock.
        vprosit = produ.proseq = 0.
        vvex    = no.
        vpe     = produ.proipival = 1.
        vmix    = no.
        vdescontinuado = produ.descontinuado.
        vfabcod = "".
         
        vtipomix = acha2("TIPOMIX",produ.indicegenerico).
        if vtipomix = ? then vtipomix = "".
        vleadtime = acha2("LEADTIME",produ.indicegenerico).
        if vleadtime = ? then vleadtime = "".
        vstatusitem = acha2("statusItem",produ.indicegenerico).
        if vstatusitem = ? then vstatusitem = "".
        if vstatusitem = "BC" then vstatusitem = "Susp.Compra". 
        if vstatusitem = "DE" then vstatusitem = "Descontinuado". 
        
        vmixloja = acha2("MIX" + string(setbcod),produ.indicegenerico).
        if vmixloja = ? then vmixloja = "".
        
        do vloop = 1 to num-entries(produ.indicegenerico,"|"):
            if entry(vloop,produ.indicegenerico,"|") = "MIX#" + string(setbcod)
            then vmix = yes.
            if entry(vloop,produ.indicegenerico,"|") = "VEX#SIM"
            then vvex = yes.
            
        end.
        find categoria of produ no-lock no-error.
        find fabri     of produ no-lock no-error.
        find sclase    of produ no-lock no-error.

                vfabcod = string(produ.fabcod).
        /* helio 22122021    fase II.3 */
        vdescricaoFornecedor = acha2("descricaoFornecedor",produ.indicegenerico).
        if vdescricaoFornecedor = ? or vdescricaoFornecedor = ""
        then vdescricaoFornecedor = if avail fabri
                                    then fabri.fabfant
                                    else "".
        /**/
        /* helio 02082023 */
        vtempogar = "".
            find first produaux where produaux.procod = produ.procod and 
                                      produaux.nome_campo = "TempoGar"
                                      no-lock no-error.
            vtempogar = if avail produaux
                        then produaux.valor_campo
                        else "".
        /**/

        disp
            categoria.catnom when avail categoria
                format "x(16)" label "CATEG" colon 7  

            /* helio 22122021    fase II.3 
             *fabri.fabfant when avail fabri
             */
             vdescricaoFornecedor
                format "x(16)" label "FORNE" colon 34
                
           sclase.clanom when avail sclase
                format "x(16)" label "SUBCLA" colon 60

           /* helio 08/12/2021  fase II.2 */
           vstatusItem colon 7 label "STATUS"                               

           /* helio 08/12/2021  fase II.2
           *vdescontinuado  colon 7 label "DESCON"*/
                    
           /* helio 08/12/2021  fase II.2
           *vprosit colon 20 label "ATIVO"  */
           
           vmix colon 34 label "MIX"    
            vmixloja colon 50 label "QTD MIX"
           
           /* helio 08/12/2021  fase II.2
           * vtipomix colon 65 label "TipoMIX" */

            /* helio 08/12/2021  fase II.2 */
              vleadtime colon 70 label "PRZ ENTREGA"                     

            vpe colon 7 label "PE"
           vvex colon 20 label "VEX"
           /* helio 22122021    fase II.3 
            *   vfabcod colon 50 label "FORNE"
            */
           /* helio 02082023 */
           vtempogar label "Tempo Gar"
           /**/
           
           skip(1)

                with frame 
                    fdet
                    row 18
                    no-box
                    centered 
                    color messages
                    width 78
                    side-labels 
                    overlay.

            run color-message.
            choose field zprodu.pronom help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return).
            run color-normal.
            status default "".

        end.
            if keyfunction(lastkey) = "TAB"
            then do:
                if esqregua
                then do:
/*                    color display normal esqcom1[esqpos1] with frame f-com1.
                    color display message esqcom2[esqpos2] with frame f-com2.
                */
                end.
                else do:
                /*
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    color display message esqcom1[esqpos1] with frame f-com1.
                    */
                end.
                esqregua = not esqregua.
            end.
            if keyfunction(lastkey) = "cursor-right"
            then do:
                if esqregua
                then do:
/*                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                */
                end.
                else do:
/*
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 5 then 5 else esqpos2 + 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
*/                    
                end.
                next.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                if esqregua
                then do:
/*                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
*/                    
                end.
                else do:
/*                
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 1 then 1 else esqpos2 - 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
*/                    
                end.
                next.
            end.
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail wf-movim
                    then leave.
                    recatu1 = recid(wf-movim).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail wf-movim
                    then leave.
                    recatu1 = recid(wf-movim).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail wf-movim
                then next.
                color display white/red zprodu.pronom with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail wf-movim
                then next.
                color display white/red zprodu.pronom with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form wf-movim
                 with frame f-wf-movim color black/cyan
                      centered side-label row 5.
            hide frame frame-a no-pause.
            if esqregua
            then do:
/*                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.*/


/*                if esqcom1[esqpos1] = " Voltar " or esqvazio
                then do:
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-wf-movim.
                    disp wf-movim.
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-wf-movim on error undo.
                    find wf-movim where
                            recid(wf-movim) = recatu1 
                        exclusive.
                    update wf-movim.
                end.*/
            end.
            else do:
/*                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                if esqcom2[esqpos2] = "  "
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    /* run programa de relacionamento.p (input ). */
                    view frame f-com1.
                    view frame f-com2.
                end.
                leave.*/
            end.
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
/*        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.*/
        recatu1 = recid(wf-movim).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame f-com2  no-pause.
hide frame frame-a no-pause.

procedure frame-a.
find zprodu where recid(zprodu) = wf-movim.wrec no-lock no-error.

display zprodu.procod    column-label "Codigo"     format ">>>>>>>9"
        zprodu.pronom    column-label "Produto"    format "x(40)"
        wf-movim.movqtm  column-label "Quantidade" format ">>>9"
        wf-movim.movpc   column-label "Preco"
        with frame frame-a.
end procedure.
procedure color-message.

color display message
        zprodu.procod
        wf-movim.movqtm
        wf-movim.movpc
        with frame frame-a.
end procedure.
procedure color-normal.

color display normal
        zprodu.procod
        wf-movim.movqtm
        wf-movim.movpc
        with frame frame-a.
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first wf-movim where true
                                                no-lock no-error.
    else  
        find last wf-movim  where true
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next wf-movim  where true
                                                no-lock no-error.
    else  
        find prev wf-movim   where true
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev wf-movim where true  
                                        no-lock no-error.
    else   
        find next wf-movim where true 
                                        no-lock no-error.
        
end procedure.
         
