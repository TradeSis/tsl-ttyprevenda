/*         
helio 22122021    fase II.3 
helio 08/12/2021  fase II.2
helio 12/11/2021  fase II
*/

{admcab.i}
def var vdescricaoFornecedor as char.

/* CHAMADA AO BARRAMENTO */
{wc-consultaestoque.i new}

def var par-tipozoom as char init "NORMAL" . /* AVANCADO */
{setbrw.i}
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
                                                           
                                                           
def var primeiro as log.
def var vprocod as char format "x(12)" label "Codigo Produto".
def buffer xprodu for produ.
def buffer sclase for clase.
    
def var vpesquisa as char format "x(58)".
def var oldpesquisa as char.
def var vletra as char.
def var par-ultimofiltro    as char.
def var par-catcod  like produ.catcod.
def var par-mix     like estab.etbcod init 0.    
def var par-situacao    as char.
def var par-pe          as char.
def var par-vex         as char.
def var par-descontinuado as char.
def var par-fabri     as char.
def var par-subclasse    as char.



def var fil-campo as char.
def var fil-mensagem as char.

def var fil-contador as int.

def var vprosit as log format "SIM/NAO". 
def var vpe     as log format "SIM/NAO".
def var vvex    as log format "SIM/NAO".
def var vtipomix as char format "x(6)".
def var vleadtime as char format "x(4)".
def var vstatusitem as char format "x(13)".
def var vmixloja  as char format "x(5)". 
def var vfabcod as char format "x(8)".
def var vdescontinuado   as log format "SIM/NAO".

def var vmix    as log format "SIM/NAO".
def var vloop   as int.
def var par-fabcod  like fabri.fabcod.
def var vpreco      like estoq.estvenda.
/*def var vestoq      like estoq.estatual.*/

def temp-table ttprodu no-undo
    field procod    like produ.procod
    field pronom    like produ.pronom
    field indicegenerico    like produ.indicegenerico
    index procod is unique primary pronom asc procod asc.


def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(15)" extent 5
    initial ["  <Seleciona>"," <Estoque>","    <Filtros>", "", "<Prev.Entregas>"].
/*                              1234567890123456*/

pause 0.
disp 
string("") format "x(80)"
skip(17)

    with frame capa
    row 2
    color messages
    overlay
    no-box.
   pause 0.
    pause 0.
    disp fil-campo format "x(78)"
            with frame fcab row 21 no-box no-labels centered 
            width 80 overlay.
    disp fil-mensagem format "x(78)"
            with frame fcabmensagem row 20 no-box no-labels centered 
            width 80 overlay.
    pause 0.   
run seleciona-categoria (input 0, output par-catcod ).
if par-catcod = 0
then do:
    hide frame fcategoria no-pause.
    return.
end.


          
            
form
    esqcom1
    with frame f-com1 row 19 no-box no-labels column 1 centered
    overlay width 80.

assign
    esqpos1  = 1.

    form 
            produ.procod format ">>>>>>>>9"
            produ.pronom column-label "Descricao"  format "x(49)"
            vpreco          format ">>>>9.99" column-label "Preco"
/*            vestoq          format "->>>>9" column-label "Estoq"*/
        with frame frame-a 9 down centered  row 5 no-box no-underline
        overlay.

   pause 0.
    disp esqcom1 with frame f-com1.
    
    form with frame f-linha.

run seleciona-situacao  (input "ATIVO",output par-situacao).
/*run seleciona-pe        (input "",output par-pe).
run seleciona-vex       (input "",output par-vex).
run seleciona-fdescontinuado  (input "",output par-descontinuado).
*/

par-mix = if setbcod = 999 or setbcod = 188 or setbcod = 189
          then 0
          else setbcod .

if par-tipozoom = "AVANCADO"
then  run gera-filtro.

recatu1 = ?.
form 
vpesquisa format "x(68)" label "Pesquisa"
                            with frame fcampo
                row 3 side-labels no-box overlay centered.

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.

    if recatu1 = ?
    then run leitura (input "pri").
    else do:
        if par-tipozoom = "AVANCADO"
        then find ttprodu where recid(ttprodu) = recatu1 no-lock.
        else find produ where recid(produ) = recatu1 no-lock.
        
    end.    
    if par-tipozoom = "AVANCADO"
    then
        if not available ttprodu 
        then do.

            hide message no-pause.
            message "Nenhum registro Encontrado neste Filtro " 
            replace(replace(fil-campo,"&"," "),"#","=")
                     view-as alert-box.
            
            par-tipozoom = "NORMAL".
            run campo.
            if not avail produ
            then do:
                vpesquisa = "".
                recatu1 = ?.
                esqpos1 = 1.
            end.     
            /*            
            fil-campo = par-ultimofiltro.
            run montatt (par-ultimofiltro).
            */
            next.
        end.
    if par-tipozoom = "NORMAL"
    then
        if not available produ 
        then do.

            hide message no-pause.
            message "Nenhum registro Encontrado neste Filtro " 
            replace(replace(fil-campo,"&"," "),"#","=")
                     view-as alert-box.
            pause 2 no-message.
            recatu1 = ?.
            next.
        end.
    
    
    
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = if par-tipozoom = "AVANCADO"
              then recid(ttprodu)
              else recid(produ).

    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if par-tipozoom = "AVANCADO" 
        then  if not available ttprodu  then leave.
        if par-tipozoom = "normal" 
        then  if not available produ  then leave.
        
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        if par-tipozoom = "AVANCADO" 
        then do:
            find ttprodu where recid(ttprodu) = recatu1 no-lock.
            find produ where produ.procod = ttprodu.procod no-lock.
        end.
        if par-tipozoom = "NORMAL"
        then do:
            find produ where recid(produ) = recatu1 no-lock.
        end.    
        
        disp replace(replace(fil-campo,"&"," "),"#","=")
            @ fil-campo
            with frame fcab. 

        
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

        /*helio 08/12/2021  fase II.2
        if vstatusitem = "BC" then vstatusitem = "Susp.Compra". */
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
                with frame 
                    fdet
                    row 16
                    no-box
                    centered 
                    color messages
                    width 78
                    side-labels 
                    overlay.
        if esqcom1[3] = ""
        then status default 
            "Digite o nome do produto".
        else status default 
            "Digite o nome do produto, use * para partes do nome e <Procurar>".
            

        
        disp esqcom1 with frame f-com1.
        
        run color-message.
        
            pause 0.
            disp vpesquisa 
                            with frame fcampo.

            color disp input vpesquisa with frame fcampo.

        choose field produ.pronom
                help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right F7 PF7
                       1 2 3 4 5 6 7 8 9 0 " " "*"
                      page-down   page-up 
                      PF4 F4 ESC return   del-char backspace DELETE-CHARACTER
                      CUT F10 PF10
                      a b c d e f g h i j k l m n o p q r s t u v x z w y 
                      A B C D E F G H I J K L M N O P Q R S T U V X Z W Y
                      "." "/").
        
        fil-mensagem = "".
        pause 0.
        disp fil-mensagem format "x(78)"
            with frame fcabmensagem row 20 no-box no-labels centered 
            width 80 overlay.
        pause 0.   
                      
        run color-normal.
        pause 0. 

            vletra = keyfunction(lastkey).
            if length(vletra) = 1 or
               keyfunction(lastkey) = "BACKSPACE" or
               keyfunction(lastkey) = "DELETE-CHARACTER" 
            then do:
                if keyfunction(lastkey) = "backspace" or 
                   keyfunction(lastkey) = "DELETE-CHARACTER"
                then do:
                    vpesquisa = substring(vpesquisa,1,length(vpesquisa) - 1).
                    if vpesquisa = ""
                    then do:
                        esqcom1[3] = "". 
                    end.
                    run campo.
                    leave.
                end.
                if vpesquisa = "" and
                /*
                    keyfunction(lastkey) = "F7" or
                    keyfunction(lastkey) = "PF7"
                    */
                   (vletra >= "0" and vletra <= "9") 

                    and esqcom1[3] <> "< Procurar >" 
                   
                then do
                    with frame fbusca
                        
                        row 4
                        color messages
                        overlay
                        side-labels 
                        width 40
                        title "Digite todo o Codigo do produto":
                    vprocod = (vletra).
                    primeiro = yes.
                    update vprocod  
                    editing: 
                        if  primeiro 
                        then do: 
                            apply  keycode("cursor-right"). 
                            primeiro = no. 
                        end. 
                        readkey. 
                        apply lastkey. 
                    end.
                    find xprodu where xprodu.procod = int(vprocod) no-lock no-error.
                    if not avail xprodu
                    then do:
                        message "Produto" vprocod "Nao cadastrado"
                            view-as alert-box.
                    end.
                    else do:
                        if par-tipozoom = "AVANCADO"
                        then do:
                            find first ttprodu where 
                                ttprodu.procod = xprodu.procod
                                no-lock no-error.
                            if not avail ttprodu
                            then do:
                                message "Produto" vprocod xprodu.pronom
                                 "Nao Disponivel na Atual Selecao"
                                 view-as alert-box.
                            end.    
                            else do:
                                recatu1 = recid(ttprodu).
                            end.
                        end.
                        if par-tipozoom = "NORMAL"
                        then do:
                            find first produ where 
                                produ.procod = xprodu.procod
                                no-lock no-error.
                            if not avail produ
                            then do:
                                message "Produto" vprocod xprodu.pronom
                                 "Nao Disponivel na Atual Selecao"
                                 view-as alert-box.
                            end.    
                            else do:
                                recatu1 = recid(produ).
                            end.
                        end.
                        
                    end.
                    hide frame fbusca no-pause.
                    leave.
                end.
                else   
                if (vletra >= "a" and vletra <= "z") or
                   (vletra >= "0" and vletra <= "9") or
                    vletra = " "   or
                    vletra = "."   or
                    vletra = "/"  or
                    vletra = "*"
                then do:         
                    
                    vpesquisa = vpesquisa + vletra.
                    
                    if  true /*vletra = " " */ /* 06/08/2021 */
                    then do:
                        esqcom1[3] = "< Procurar >". 
                    end.
                    
                    run campo.
                    leave.
                end.
                /**
                else do:
                    vpesquisa = "".
                end.
                **/
            end.
            /*
            else vpesquisa = "".
            */
            pause 0.
            disp vpesquisa with frame fcampo.
                                                         
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
                    if par-tipozoom = "AVANCADO"
                    then do:
                        if not avail ttprodu then leave.
                        recatu1 = recid(ttprodu).
                    end.
                    if par-tipozoom = "NORMAL"
                    then do:
                        if not avail produ then leave.
                        recatu1 = recid(produ).
                    end.
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if par-tipozoom = "AVANCADO"
                    then do:
                        if not avail ttprodu then leave.
                        recatu1 = recid(ttprodu).
                    end.
                    if par-tipozoom = "NORMAL"
                    then do:
                        if not avail produ then leave.
                        recatu1 = recid(produ).
                    end.

                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                    if par-tipozoom = "AVANCADO"
                    then do:
                        if not avail ttprodu then leave.
                        recatu1 = recid(ttprodu).
                    end.
                    if par-tipozoom = "NORMAL"
                    then do:
                        if not avail produ then leave.
                        recatu1 = recid(produ).
                    end.

                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                    if par-tipozoom = "AVANCADO"
                    then do:
                        if not avail ttprodu then leave.
                        recatu1 = recid(ttprodu).
                    end.
                    if par-tipozoom = "NORMAL"
                    then do:
                        if not avail produ then leave.
                        recatu1 = recid(produ).
                    end.

                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
        
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        
        
        if keyfunction(lastkey) = "return"
        then do:
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

            if trim(esqcom1[esqpos1]) = "<seleciona>"
            then do:
                if par-tipozoom = "AVANCADO"
                then frame-value = string(ttprodu.procod).
                if par-tipozoom = "NORMAL"
                then frame-value = string(produ.procod).
                leave bl-princ.
            end.
            if trim(esqcom1[esqpos1]) = "<Filtros>"
            then do:
                vpesquisa = "".
                disp vpesquisa with frame fcampo.
                esqcom1[3] = "".
                color disp normal esqcom1[2] esqcom1[3] with frame f-com1.
                esqpos1 = 1.               
                par-tipozoom = "AVANCADO".    
                run busca.
                run gera-filtro.
                recatu1=?.
                leave.
            end. 
            if trim(esqcom1[esqpos1]) = "<Estoque>"
            then do:
                run estoque-disponivel.
                color disp normal esqcom1[2] esqcom1[3] with frame f-com1.
                esqpos1 = 1.               
                color disp messa esqcom1[1] with frame f-com1.
                next.
            end. 
            if trim(esqcom1[esqpos1]) = "<Prev.Entregas>"
            then do:
                run previsaoEntregas.
                color disp normal esqcom1[2] esqcom1[3] esqcom1[4] esqcom1[5] with frame f-com1.
                esqpos1 = 1.               
                color disp messa esqcom1[1] with frame f-com1.
                next.
            end. 
            
            
            if trim(esqcom1[esqpos1]) = "< Procurar >" 
            then do:
                    par-tipozoom = "AVANCADO".                    
                        run gera-filtro.
                        esqcom1[4] = "<DesProcurar>" .
                        recatu1 = ?.
                        leave.
            end.
            if trim(esqcom1[esqpos1]) = "<DesProcurar>"  and
                par-tipozoom = "AVANCADO"
            then do:
                    /*
                        oldpesquisa = entry(1,vpesquisa," ") + " ".
                        vpesquisa = "".
                        run gera-filtro.
                        vpesquisa = oldpesquisa.
                        run leitura ("busca").
                        esqcom1[4] = "" .
                        esqpos1 = 3.
                        color disp normal esqcom1[4] with frame f-com1.
                        recatu1 = recid(ttprodu).
                        leave.
                    */
                    par-tipozoom = "NORMAL".
                    run campo.
                    color disp normal esqcom1[4] with frame f-com1.

                    if not avail produ
                    then do:
                        vpesquisa = "".
                        recatu1 = ?.
                    end.     
                    esqpos1 = 1.
                    leave.
            end.
            
            if esqcom1[esqpos1] = "Exclui Cliente"
            then do:
                recatu1 = ?.
                leave.
            end.
        end.
        
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        if par-tipozoom = "AVANCADO"
        then  recatu1 = recid(ttprodu).
        if par-tipozoom = "NORMAL"
        then recatu1 = recid(produ).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame fcategoria no-pause.
hide frame fdescontinuado no-pause.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.
hide frame ftipobusca no-pause.
 hide frame fmessage no-pause.
 hide frame fbusca no-pause.
 hide frame fdet no-pause.
 hide frame fcampo no-pause.
 hide frame f-linha no-pause.
 hide frame fcab no-pause.
 hide frame fcabmensagem no-pause.
 hide frame capa no-pause.

procedure frame-a.
    if par-tipozoom = "AVANCADO"
    then do:  
        find produ where produ.procod = ttprodu.procod no-lock.
    end.

    find estoq where estoq.etbcod = setbcod and estoq.procod = produ.procod
        no-lock no-error.
    vpreco = if avail estoq then estoq.estvenda else 0.
                
    disp 
            produ.procod
            produ.pronom
            vpreco    
/*            vestoq      */
        with frame frame-a.
end procedure.

procedure color-message.
    color display message
            produ.procod
            produ.pronom
            vpreco    
/*            vestoq      */

        with frame frame-a.
end procedure.

procedure color-normal.
    color display normal
            produ.procod
            produ.pronom
            vpreco    
/*            vestoq      */

        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.

if par-tipozoom = "AVANCADO"
then do:
    if par-tipo = "busca"
    then do: 
        find first ttprodu where
                ttprodu.pronom begins vpesquisa
                no-lock no-error.
    end.        
    if par-tipo = "pri" 
    then do:
        find first ttprodu where
            true
            no-lock no-error.
            
    end.    
    if par-tipo = "seg" or par-tipo = "down" 
    then do:
        find next ttprodu where
            true
            no-lock no-error.
    end.        
    if par-tipo = "up" 
    then do:
        find prev ttprodu where
            true
            no-lock no-error.
    end.    
end.

if par-tipozoom = "NORMAL"
then do:
    if par-tipo = "busca"
    then do: 
        if par-situacao = "ATIVO"
        then
            find first produ use-index AtivoCatNome where
                    produ.proseq = 0 and
                    produ.catcod = par-catcod and    
                    produ.pronom begins vpesquisa
                    no-lock no-error.
        if par-situacao = "INATIVO"
        then
            find first produ use-index AtivoCatNome where
                    produ.proseq = 99 and
                    produ.catcod = par-catcod and    
                    produ.pronom begins vpesquisa
                    no-lock no-error.
        if par-situacao = "TODOS"
        then
            find first produ use-index catpro where
                    produ.catcod = par-catcod and    
                    produ.pronom begins vpesquisa
                    no-lock no-error.
    end.        
    if par-tipo = "pri" 
    then do:
        if par-situacao = "ATIVO"
        then
            find first produ use-index AtivoCatNome where
                    produ.proseq = 0 and
                    produ.catcod = par-catcod 
                    no-lock no-error.
        if par-situacao = "INATIVO"
        then
            find first produ use-index AtivoCatNome where
                    produ.proseq = 99 and
                    produ.catcod = par-catcod 
                    no-lock no-error.
        if par-situacao = "TODOS"
        then
            find first produ use-index catpro where
                    produ.catcod = par-catcod 
                    no-lock no-error.
    end.    
    if par-tipo = "seg" or par-tipo = "down" 
    then do:
        if par-situacao = "ATIVO"
        then
            find next produ use-index AtivoCatNome where
                    produ.proseq = 0 and
                    produ.catcod = par-catcod 
                    no-lock no-error.
        if par-situacao = "INATIVO"
        then
            find next produ use-index AtivoCatNome where
                    produ.proseq = 99 and
                    produ.catcod = par-catcod 
                    no-lock no-error.
        if par-situacao = "TODOS"
        then
            find next produ use-index catpro where
                    produ.catcod = par-catcod 
                    no-lock no-error.

    end.        
    if par-tipo = "up" 
    then do:
        if par-situacao = "ATIVO"
        then
            find prev produ use-index AtivoCatNome where
                    produ.proseq = 0 and
                    produ.catcod = par-catcod 
                    no-lock no-error.
        if par-situacao = "INATIVO"
        then
            find prev produ use-index AtivoCatNome where
                    produ.proseq = 99 and
                    produ.catcod = par-catcod 
                    no-lock no-error.
        if par-situacao = "TODOS"
        then
            find prev produ use-index catpro where
                    produ.catcod = par-catcod 
                    no-lock no-error.
            
    end.    
end.
 
end procedure.

procedure seleciona-situacao.
    def input param par-opcao as char.
    def output param par-situacao as char.

    def var csituacao as char extent 3 init [ "  Todos",
                                              "  Ativo ",
                                              " Inativo "  ].
    
    if par-opcao = ?
    then do:
        disp csituacao
            with frame fsituacao
            row 10 centered
            overlay no-labels.
        choose field csituacao
                with frame fsituacao.
        par-situacao = trim(csituacao[frame-index]).        
        if par-situacao = "todos"
        then par-situacao = "".
    end.            
    else par-situacao = par-opcao.

end procedure.

procedure seleciona-descontinuado.
    def input param par-opcao as char.
    def output param par-descontinuado as char.

    def var cdescontinuado as char extent 3 init [ "  Todos",
                                              "  Sim ",
                                              " Nao "  ].
    
    if par-opcao = ?
    then do:
        disp cdescontinuado
            with frame fdescontinuado
            row 10 centered
            overlay no-labels.
        choose field cdescontinuado
                with frame fdescontinuado.
        par-descontinuado = trim(cdescontinuado[frame-index]).        
        if par-descontinuado = "todos"
        then par-descontinuado = "".
    end.            
    else par-descontinuado = caps(trim(par-opcao)).

end procedure.


procedure seleciona-pe.
    def input param par-opcao as char.
    def output param par-pe as char.

    def var cpe as char extent 3 init [ " Todos",
                                        "  Sim ", 
                                         " Nao "  ].
    
    if par-opcao = ?
    then do:
        disp cpe
            with frame fpe
            row 12 centered
            overlay no-labels.
        choose field cpe
                with frame fpe.
        par-pe = trim(cpe[frame-index]).        
        if par-pe = "todos"
        then par-pe = "".
    end.
    else par-pe = par-opcao.

end procedure.

procedure seleciona-fabri.
    def output param par-fabcod as char.

    run zoomfabri.p (output par-fabcod).
    
    par-fabri = par-fabcod.
    
end procedure.


procedure seleciona-subclasse.
    def output param par-clacod as char.

    run zoocla-cod.p (output par-clacod).
    
    par-subclasse = par-clacod.
    
end procedure.



procedure seleciona-mix.
    def input param par-opcao as char.
    def output param par-mix as int.
    
    if par-opcao = "999" or par-opcao = "188" or par-opcao = "189"
    then message "Qual FILIAL de MIX?" update par-mix.
    else par-mix = setbcod.

end procedure.



procedure seleciona-categoria.

    {setbrw.i}

    def input  parameter par-catdefault as int. 
    def output parameter par-categoria like categoria.catcod.

def var par-ccategoria as char.
    if par-catdefault <> 0
    then do:
        par-categoria = par-catdefault.
        return.
    end.

    def var ccategoria as char 
        format "x(12)"
        extent 3 init [ " Moveis", " Moda", "Outros"  ].

    do with frame fcategoria.    
        disp skip (2) ccategoria 
        skip(2) 
            with frame fcategoria
            row 10 centered
            overlay no-labels
            title "CATEGORIA".
        choose field ccategoria
                with frame fcategoria
                .
        par-ccategoria = trim(ccategoria[frame-index]).        
        hide frame fcategoria no-pause.
    end.        
        if par-ccategoria = "outros"
        then.
        else do:
            if trim(par-ccategoria) = "Moveis"
            then par-categoria = 31.
            else par-categoria = 41.
            return.
        end.

    

    hide frame f-linha no-pause.    
    clear frame f-linha all.
    assign a-seerec = ?.
    assign a-seeid  = -1  
           a-recid  = -1 .

    {sklcls.i
        &color  = withe
        &color1 = brown
        &file   = categoria 
        &noncharacter = /* 
        &cfield = categoria.catnom
        &ofield = categoria.catcod
        &where  = " true "
        &form = " frame f-linha 10 down centered no-label overlay
                     title "" CATEGORIA DE PRODUTO "" 
                        row 9
                        " }.
                    
    if keyfunction(lastkey) = "end-error"
    then do:
        hide frame f-linha no-pause.
        leave.
    end.                    
       
    find categoria where recid(categoria) = a-seerec[frame-line(f-linha)] no-lock                                                         no-error.
    
    par-categoria = if avail categoria
                 then categoria.catcod
                 else 0.
       hide frame f-linha no-pause.
end procedure. 


procedure gera-filtro.
    status     default "Aguarde...".
    fil-campo = "".
    if vpesquisa <> ""
    then do:
        if num-entries(vpesquisa,"*") > 1
        then 
        fil-campo = "PRONOM#" + " "  +
                (if substring(vpesquisa,1,1) = " " 
                                 then "*"
                                 else "") 
                                    + vpesquisa.
        else fil-campo = "PRONOM#" + "* "  + vpesquisa.
                                    
    end.
    if par-situacao <> ""
    then do:
        fil-campo = fil-campo +
                    (if fil-campo <> "" then "&" else "") +
                    ("SITUACAO#" + par-situacao).
    end.
    if par-descontinuado <> ""
    then do:
        fil-campo = fil-campo +
                    (if fil-campo <> "" then "&" else "") +
                    ("DESCONTINUADO#" + par-descontinuado).
    end.
    
    if par-catcod <> 0
    then do:
        fil-campo = fil-campo +
                    (if fil-campo <> "" then "&" else "") +
                    (
                     "CATEGORIA#" + string(par-catcod)
                    ).
    end.    
    if par-pe <> ""
    then do:
        fil-campo = fil-campo +
                    (if fil-campo <> "" then "&" else "") +
                    (
                    "PE#" + par-pe
                    ).
    end.
    if par-vex <> ""
    then do:
        fil-campo = fil-campo +
                    (if fil-campo <> "" then "&" else "") +
                    (
                    "VEX#" + par-vex
                    ).
    end.
    
    if par-mix <> 0
    then do:
        fil-campo = fil-campo +
                    (if fil-campo <> "" then "&" else "") +
                    (
                    "MIX#" + string(par-mix)
                    ).
                    
    end.
    if par-fabri <> ""
    then do:
        fil-campo = fil-campo +
                    (if fil-campo <> "" then "&" else "") +
                    (
                    "FABRI#" + par-fabri
                    ).
    end.
    if par-subclasse <> ""
    then do:
        fil-campo = fil-campo +
                    (if fil-campo <> "" then "&" else "") +
                    (
                    "SUBCLASSE#" + par-subclasse
                    ).
    end.
    
         
    pause 0.
    disp fil-campo 
            with frame fcab .

    run montatt (fil-campo).
    
    if fil-contador <> 0
    then do:
        par-ultimofiltro = fil-campo.
    end.
    /*
    else do:
        if par-catcod <> 0
        then do:
            if vpesquisa <> ""
            then do:
                fil-campo = par-ultimofiltro.
                run montatt (fil-campo).         
            end.
            else do:
                fil-campo = 
                         "CATEGORIA#" + string(par-catcod).
                run montatt (fil-campo).         
                         
            end.
        end.    
    end.
    */
    
end procedure.

procedure montatt.
    def input parameter par-campo as char.
    
    def var fil-time as int.

    for each ttprodu.
        delete ttprodu.
    end.
    fil-contador = 0.
    fil-time     = time.
    
    if par-campo = ""
    then 
    for each produ where produ.indicegenerico <> ""
            no-lock.
        create ttprodu.
        ttprodu.procod = produ.procod.
        ttprodu.indicegenerico = produ.indicegenerico.
        ttprodu.pronom = produ.pronom.
        fil-contador = fil-contador + 1.
        if fil-contador mod 1000 =0 or (fil-contador < 400 and time - fil-time > 5)
        then do:
            hide message no-pause.
            fil-mensagem = "Filtrados " 
                           + string(fil-contador) +  
            " Produtos em " + string(time - fil-time,"HH:MM:SS").
            pause 0.
             
            disp fil-mensagem with frame fcabmensagem.
        end.
    end.    
    
    else 
    for each produ where produ.indicegenerico 
        contains  par-campo no-lock.

        if acha2("ZOOM",produ.indicegenerico) = "NAO"
        then  next.

        create ttprodu.
        ttprodu.procod = produ.procod.
        ttprodu.indicegenerico = produ.indicegenerico.
        ttprodu.pronom = produ.pronom.
        fil-contador = fil-contador + 1.
        if fil-contador mod 1000 =0 or (fil-contador < 500 and time - fil-time >~  5) 
        then do:
            hide message no-pause.
            fil-mensagem = "Filtrados " 
                           + string(fil-contador) +  
            " Produtos em " + string(time - fil-time,"HH:MM:SS").
            pause 0.
             
            disp fil-mensagem with frame fcabmensagem.
        end.
    end.    
    if time - fil-time >= 5
    then do:
        hide message no-pause.
        fil-mensagem = 
        "Filtrados " + string(fil-contador ) + 
        " Produtos em " + string(time - fil-time,"HH:MM:SS").
        disp fil-mensagem with frame fcabmensagem.
    end.
            
end procedure.


procedure campo.
                    
                    run leitura ("BUSCA").
                    if par-tipozoom = "AVANCADO"
                    then do:
                        if avail ttprodu then recatu1 = recid(ttprodu).
                    end.    
                    if par-tipozoom = "NORMAL"
                    then do:
                        if avail produ then recatu1 = recid(produ).
                    end.    
                    pause 0.
                    disp vpesquisa with frame fcampo.
                    

end procedure.


procedure busca.  

        def var vtipobusca as char format "x(55)" extent  8
            init    [ "1-Categoria",
                      "2-Marca (fabricante)" ,
                      "3-Estrutura de Classe (mercadologico)",
                      "4-Situacao", 
                      "5-Vex",
                      "6-Pedido Especial",
                      "7-Mix",
                      "8-Descontinuado"].

        def var vfiltro as char.
        def var rectit as recid.
        def var recag as recid.
        pause 0.
        display " O P C O E S " at 16
                skip(10)
                with frame fmessage color message row 7 column 11 
                    width 64 no-box overlay.
        pause 0.
        display vtipobusca at 4
                with frame ftipobusca  column 13
                row 8  no-label overlay  1 column.
        choose field vtipobusca auto-return
                     with frame ftipobusca.
        vfiltro = entry(2,vtipobusca[frame-index],"-").

        
        if vfiltro = "Categoria"
        then run seleciona-categoria (0,output par-catcod).
        if vfiltro = "mix"
        then run seleciona-mix (string(setbcod),output par-mix).
        if vfiltro = "Situacao"
        then run seleciona-situacao (?,output par-situacao).
        if vfiltro = "Pedido especial"
        then run seleciona-pe (?,output par-pe).
        if vfiltro = "VEX"
        then run seleciona-vex (?,output par-vex).
        if vfiltro = "Descontinuado"
        then run seleciona-descontinuado (?,output par-descontinuado).
        if vfiltro begins "Marca"
        then run seleciona-fabri (output par-fabri).
        if vfiltro begins "Estrutura"
        then run seleciona-subclasse (output par-subclasse).
        
        
        hide frame ftipobusca no-pause.
        hide frame fmessage no-pause.
         
    
    end procedure.




procedure estoque-disponivel:

    def var vdisponivel like estoq.estatual.
    def var vtransito   like estoq.estatual.
    
    def var vest-filial like estoq.estatual.
    def buffer bprodu for produ.
    form "                       DISPONIBILIDADE DO PRODUTO " skip
         " " skip
         produ.procod label "Produto"
         produ.pronom no-label
         with frame est-disp.
     
    pause 0.
    disp produ.procod 
        produ.pronom with frame est-disp.

    /* CHAMADA AO BARRAMENTO */
    run wc-consultaestoque.p (setbcod, int(produ.procod)).

    find first ttestoque no-error.
    if not avail ttestoque
    then do:
        find first ttretorno no-error.
        if avail ttretorno
        then do:
            hide message no-pause.
            message "barramento consultaestoque" ttretorno.tstatus ttretorno.descricao.
            pause 2 no-message.
        end.
    end.
    else do:
        vdisponivel = 0.
        vtransito   = 0.
        for each ttestoque where int(codigoEstabelecimento) <> setbcod and
                                 int(codigoEstabelecimento) >= 900.
            vdisponivel = vdisponivel + int(ttestoque.qtdDisponivel).
        end.            
        find first ttestoque where int(codigoEstabelecimento) = setbcod no-error.
        vest-filial = if avail ttestoque
                      then int(ttestoque.qtdDisponivel)
                      else 0.
        vtransito = if avail ttestoque
                    then int(ttestoque.qtdTransito)
                    else 0.          
        disp produ.procod   at 8
             produ.pronom no-label
             skip(1)
             vest-filial at 1 label "    Estoque Filial" format "->>>,>>9"
             skip(1)
             vtransito   at 1 label "Em Transito Filial" format "->>>,>>9"
             skip(1)
             vdisponivel at 1 label "Disponivel Deposit"     format "->>>,>>9"
             with frame est-disp overlay row 5
             width 80 15 down color message no-box side-label.
        pause 30.             
    end.
    
end procedure.




procedure previsaoEntregas.

    run previsaoentrega.p (int(produ.procod)).
    
    
end procedure.



