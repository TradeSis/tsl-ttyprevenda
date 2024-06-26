{admcab.i}                                                

def var vpromo-comp as log.
def var vcadeira-405249 as log.
def var vcadeira-405249q as int.
def var vqtdcomp as int.
def var valorparcela   like plani.platot.
def var plano-especial as log.
def var vv as dec /* like plani.platot*/.
def var vcat like produ.catcod.
def var vk as log.
def var v-down as log.
def var wpar            as integer format ">9" label "Num.Parcelas".
def var wcon            as integer format ">9" label "Parc.".
def var wval            as decimal format ">>>,>>>,>>9.99".
def var rsp             as logical format "Sim/Nao" initial yes.
def var vtprcod         like comis.tprcod.
def var vreccont        as recid.
def var vlrtot          like contrato.vltotal.
def var vgera           like geranum.contnum.
def var vok             as log.
def var wnp             as int.
def var vval as dec.
def var vval1 as dec decimals 1.
def var vsal as dec.
def var vdtentra        like titulo.titdtven label "Data da Entrada".
def var vdtven          like titulo.titdtven.
def var vano            as int.
def var vmes            as int.
def var vday            as   int format "99".
def var i               as   int .
def var cont            as   int.
def var vnotas          as char format "x(60)" label "Nota(s) Fiscal(is)".
def var vcrecod         like plani.crecod.
def var vvencod         like plani.vencod.
def var vvaltit         like titulo.titvlcob.
def var vdata           like contrato.dtinicial.
def var vetbcod         like estab.etbcod .
def var vvltotal        like contrato.vltotal.
def var vpladat         like contrato.dtinicial.
def var vlfrete         like contrato.vltotal label "Valor Frete".
def var vlfinan         like contrato.vltotal label "Vlr Financiamento".
def var vorient         like contrato.vlentra.
def var dd as i.
def var mm as i.

def var ventrada90 as log.
def var ventrada60 as log.
def var ventrada30 as log.

def var datafim like plani.pladat.

def input  parameter vfincod    like finan.fincod.
find finan where finan.fincod = vfincod no-lock.

/* planos com arredondamento - solicitacao de maio/2014 
def var arr-plano  as int extent 8
    init [111 , 116 , 316 , 121 , 321 , 126 , 326 , 311 ].
def var arr-arred  as dec extent 8
    init [0.10, 0.50, 0.50, 0.50, 0.50, 0.50, 0.50, 0.10 ].
planos originais *******************************************/    
    
/* planos com arredondamento - solicitacao de jun/2014 
def var arr-plano  as int extent 5
    init [111 , 311 ,200 , 201, 135].
def var arr-arred  as dec extent 5
    init [0.10, 0.10 , 0.10, 0.10, 0.10].
**** ALTERADO EM 28/07/2015 CLAUDIR *******/

def var arr-plano  as int extent 83
    init[200,201,410,116,121,126,113,111,311,314,108,109,202,135,99,138,69,47,101,102,103,111,250,301,302,604,920,606,150,513,504,151,152,511,48,117,118,108,426,63,74,503,608,651,
990 /* helio 05042022 */,
38,39,512,944,332,333,352,353,357,358 /* https://trello.com/c/jy6jIIZd */,
34,38,102,103,111,151,250,301,302,332,333,352,353,357,358,503,511,604,608,944,
512,
251,252,253,254,255,260,261
].
def var arr-arred  as dec extent 83
    init[.10,.10,.90,.90,.90,.90,.00,.00,.00,.00,.10,.10,.10,.10,.00,.10,.00,.00,.00,.00,.00,.00,.00,.00,.00,.00,.00,.00,.00,.00,.00,.00,.00,.00,.10,.10,.10,.10,.00,.00,.00,.00,.00,.00,
0.00,
.00,.00,.00,.00,.00,.00,.00,.00,.00,.00,
.00,.00,.00,.00,.00,.00,.00,.00,.00,.00,.00,.00,.00,.00,.00,.00,.00,.00,.00,.00,
.00,
.10,.10,.10,.10,.10,.10,.10
].


/* https://trello.com/c/3s4DnvzH */

def var plano_sem_arr as int extent 27
    init[51,52,53,54,55,
        60,61,77,
            251,252,253,254,255,
                260,261,
                    272,273,274,275,276,277,278,279,280,
                        299,
                        117,118].
                        
/* */

def temp-table tt-arr
    field fincod as int
    field arred  as dec
    index fincod is primary unique fincod.
def var t as int.
for each tt-arr.
    delete tt-arr.
end.
if finan.datexp >= 08/28/15
then do:
    create tt-arr.
    assign tt-arr.fincod = finan.fincod
           tt-arr.arred  = .90. 
end.
do t = 1 to 83.
    if arr-plano[t] = 00
    then leave.
    find first tt-arr where
               tt-arr.fincod = arr-plano[t] no-error.
    if not avail tt-arr
    then create tt-arr.
    assign tt-arr.fincod = arr-plano[t]
           tt-arr.arred  = arr-arred[t]. 
end.

/* https://trello.com/c/3s4DnvzH */
def var tt as int.
do tt = 1 to 27.
     if plano_sem_arr[tt] = 00
          then leave.
               find first tt-arr where
                               tt-arr.fincod = plano_sem_arr[tt] no-error.
                                    if not avail tt-arr then create tt-arr.
                                         assign tt-arr.fincod = plano_sem_arr[tt]
            tt-arr.arred  = 0.
            end.
/* */            

def var varre100-01012023 as log init yes.
def var val-arr as dec init 1.00 /*0.90*/.
def var tp-rr as char.


if (finan.fincod >= 251 and finan.fincod <= 255) or
   (finan.fincod >= 260 and finan.fincod <= 261) or
   finan.fincod = 117 or
   finan.fincod = 48  or
   finan.fincod = 274 or
   finan.fincod = 276 or
   finan.fincod = 299 or
   finan.fincod = 272 or
   finan.fincod = 77 
   then assign
            varre100-01012023 = no
            tp-rr = "R-+".
    
def workfile wf-titulo   like titulo.

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
    
def input  parameter wfplatot   like plani.platot.
def input  parameter wfvlserv   like plani.platot.
def input  parameter wfdescprod like plani.platot.
def output parameter vliqui     as dec.
def output parameter ventra     as dec.
def output parameter vparce     as dec.
def var wfvlentra  like contrato.vlentra.
def var wfvltotal  like contrato.vltotal.
def var vpassa     as log.

vliqui = 0.
ventra = 0.
vparce = 0.
vvltotal = 0.
vlfinan = 0.
mm = month(today) + 1.
datafim = date(1,mm,year(today)) - 1.
dd = day(datafim).

def var parametro-in as char.
def var parametro-out as char .
def shared var p-dtentra as date.
def shared var p-dtparcela as date.
/**
if search("/usr/admcom/progr/promo-venda.p") <> ?
then do:
            parametro-in = "GERA-CPG=S|PLANO="
                    + string(finan.fincod) + "|".
            run promo-venda.p(input parametro-in ,
                              output parametro-out).
            if acha("DATA-ENTRADA",parametro-out) <> ?
            then p-dtentra = date(acha("DATA-ENTRADA",parametro-out)).
end.
message parametro-out. pause.
**/ 

plano-especial = no.
valorparcela   = 0.

def var vcadeira-1383 as log init no.
def var vcadeira-402820 as log init no.

def var vqtdcad as int.

vpromo-comp = no.

vcadeira-405249  = no.
vcadeira-405249q = 0.

if  finan.fincod = 42   and 
   (setbcod      = 81   or setbcod = 82 or setbcod = 42) and
   (today >= 09/19/2007 and
    today <= 10/20/2007)
then do:
    vcadeira-405249  = no.
    vcadeira-405249q = 0.

    for each wf-movim:

        find produ where recid(produ) = wf-movim.wrec no-lock no-error.
        
        if produ.procod = 405248
        then do:
            vcadeira-405249 = yes.
            vcadeira-405249q = vcadeira-405249q + wf-movim.movqtm.
        end.
    end.
end.
ventrada30 = no.
ventrada60 = no.
ventrada90 = no.

if not ventrada30 and
   not ventrada60 and
   finan.finnom matches "*90 DIAS*"
then ventrada90 = yes.   

def var vrecarga as log init no.
def var vprodu like produ.procod init 0.
def var vbrinde as dec init 0.
def var vmovpc as dec init 0.
def var vnaoaltent as log.

for each wf-movim:
    find produ where recid(produ) = wf-movim.wrec no-lock no-error.
    if not avail produ then next.
    if scli > 0 and
       scli <> produ.procod
    then next.

    if produ.pronom matches "*RECARGA*"
    then assign
            vnaoaltent = no
            vrecarga = yes.

    if vprodu = 0 or
       wf-movim.movpc > vmovpc
    then vprodu = produ.procod.
    if wf-movim.movpc = 1
    then vbrinde = vbrinde + (wf-movim.movpc * wf-movim.movqtm).
end.

for each wf-movim:
    find produ where recid(produ) = wf-movim.wrec no-lock no-error.
    if not avail produ
    then next.
    if scli > 0 and
       scli <> produ.procod
    then next.

    if vbrinde > 0 and
       vprodu > 0 and
       vprodu = produ.procod
    then next.   
    
    find estoq where estoq.procod = produ.procod and
                     estoq.etbcod = setbcod no-lock no-error.
    if not avail estoq
    then next.
    
    if estoq.estbaldat <> ?
    then do:
        if estoq.estmin > 0            and
           estoq.tabcod = finan.fincod and
           estprodat <> ?              and
           estbaldat <= today          and
           estprodat >= today          and
           wfvlserv   = 0       and
           wfdescprod = 0
        then assign plano-especial = yes
                    valorparcela   = valorparcela + 
                                     (estoq.estmin * wf-movim.movqtm).   
        else do:
            plano-especial = no.
            valorparcela   = 0.
            leave.
        end.
    end.
    else do: 
        if estoq.estmin > 0            and
           estoq.tabcod = finan.fincod and
           estprodat <> ?              and
           estprodat >= today          and
           wfvlserv   = 0              and
           wfdescprod = 0
        then assign plano-especial = yes
                    valorparcela   = valorparcela + 
                                     (estoq.estmin * wf-movim.movqtm).   
        else do:
            plano-especial = no.
            valorparcela   = 0.
            leave.
        end. 
    end.   
       
end.

vvltotal = vvltotal + wfplatot - wfvlserv - wfdescprod.

def var valorori as dec.

l0:
repeat:
    assign wpar = 0.
    do with frame f1:
        do on error undo with 1 column width 39 frame f2 title " Valores "
                                color white/cyan overlay row 6:

            
            for each wf-titulo:
                delete wf-titulo.
            end.

            wfvltotal = wfplatot - wfvlserv - wfdescprod.
            wnp = finan.finnpc + if finan.finent = yes
                                 then 1
                                 else 0.
            vval = 0.
            vval1 = 0.
            vsal = 0.
            
            vval = (wfvltotal * finan.finfat).
            def var par-protot like wfvltotal.    
            par-protot = wfvltotal.
            
            valorori = wfvltotal.
            
            def var vplanonovo as log.
            vplanonovo = no.
            def var vplanonovo_010 as log.
            vplanonovo_010 = no.
            if finan.fincod = 102 or
               finan.fincod = 302 or
               finan.fincod = 103 or
               finan.fincod = 303 or
               finan.fincod = 610
            then vplanonovo_010 = yes.   
            
            /*  arredondamentos para planos novos - 18/02/2014  */
            if 
               finan.fincod = 105 or
               finan.fincod = 305 or
               finan.fincod = 107 or
               finan.fincod = 307 or
               finan.fincod = 110 or
               finan.fincod = 310 or
               finan.fincod = 112 or
               finan.fincod = 312 or
               finan.fincod = 115 or
               finan.fincod = 315 or
               finan.fincod = 120 or
               finan.fincod = 320 or
               finan.fincod = 125 or
               finan.fincod = 325 or
               /* Arredondamento de planos 28/05/2015*/
               finan.fincod = 313 or
               /*finan.fincod = 314 or*/
               finan.fincod = 317 or
               finan.fincod = 318 or
               finan.fincod = 323 or
               finan.fincod = 324 or
               finan.fincod = 421 or
               finan.fincod = 422 or
               /* Alteração arredondamento de planos 06/2014 */
               finan.fincod = 116 or 
               finan.fincod = 316 or
               finan.fincod = 121 or
               finan.fincod = 321 or 
               finan.fincod = 126 or 
               finan.fincod = 326 or                
               vplanonovo_010
            then do.  
                vval = vval. 
                def var int as int. 
                def var dec as dec decimals 2. 
                int = truncate(vval,0). 
                dec = vval - int. 
                
                if varre100-01012023
                then do:
                    if val-arr = 0.90
                    then run arredonda-90(input-output vval).
                    else
                if int(substr(string(truncate(vval,2),">>>>>>>>9.99"),11,2)) > 0
                then vval = 1 + 
                    dec(substr(string(truncate(vval,2),">>>>>>>>9.99"),1,9)).
                end.
                else do:
                
                if vplanonovo_010 
                then do.
                    dec =  if dec >= 0.01 and dec <= 0.10
                           then 0.10
                           else
                           if dec >= 0.11 and dec <= 0.20
                           then 0.20
                           else
                           if dec >= 0.21 and dec <= 0.30
                           then 0.30
                           else   
                           if dec >= 0.31 and dec <= 0.40
                           then 0.40
                           else
                           if dec >= 0.41 and dec <= 0.50
                           then 0.50
                           else
                           if dec >= 0.51 and dec <= 0.60
                           then 0.60
                           else
                           if dec >= 0.61 and dec <= 0.70
                           then 0.70
                           else
                           if dec >= 0.71 and dec <= 0.80
                           then 0.80
                           else
                           if dec >= 0.81 and dec <= 0.90
                           then 0.90
                           else
                           if dec >= 0.91 and dec <= 1.00
                           then 1
                           else dec.
                    vval = int + dec.
                end.
                else do.
                    if dec < 0.50 and int <> 0
                    then int = int - 1 . 
                    vval = int + 0.90. 
                end.    
                end.
                vlfinan = vval * wnp.
                vplanonovo = yes.
            end.
            else
            if finan.fincod <> 94 and
               finan.fincod <> 89 and 
               finan.fincod <> 96 and
               finan.fincod <> 95 and
               finan.fincod <> 92 and
               finan.fincod <> 77 and
               finan.fincod <> 76 and
               finan.fincod <> 66 and
               finan.fincod <> 67 and
               finan.fincod <> 80                
               and finan.fincod <> 303 
            then do:
                if (finan.fincod < 50  or 
                    finan.fincod >= 90 or
                    finan.fincod = 70 or
                    finan.fincod = 71 or
                    finan.fincod = 75  or
                    finan.fincod = 85  or
                    finan.fincod = 81 or
                    finan.fincod = 82 or
                    finan.fincod = 83 or
                    finan.fincod = 84 or
                    finan.fincod = 87 or
                    finan.fincod = 88 or
                    finan.fincod = 86 or
             
                    
                    finan.fincod = 76) and
                    finan.fincod <> 40 and
                    finan.fincod <> 97 and
                    finan.fincod <> 94 and
                    finan.fincod <> 77 
                    
                then do:
            
                  if ((finan.fincod    = 42 or
                      finan.fincod    = 43 or
                      finan.fincod    = 87) and
                     vcadeira-405249 = yes  )  
                  then do:          
                    vval1 = vval.
                    if vval1 > vval
                    then vval1 = vval1 - 0.10.
                    vlfinan = vvltotal.
                  end.
                  else do:
                    if varre100-01012023
                    then do:
                        if val-arr = 0.90
                        then run arredonda-90(input-output vval).
                        else
               if int(substr(string(truncate(vval,2),">>>>>>>>9.99"),11,2)) > 0
               then
                    vval = 1 +
                    dec(substr(string(truncate(vval,2),">>>>>>>>9.99"),1,9)).
                    end.
                    else do:
                        vsal = vval - int(vval).
                        if vsal > 0
                        then vval = vval + (0.50 - vsal).
                        if vsal < 0 and vsal <> -0.50
                        then vval = ((vval - int(vval)) * -1) + vval.
                    end.
                    vlfinan = vval * wnp.
                  end.
                end.
                else do:
                    vval1 = vval.
                    if vval1 > vval
                    then vval1 = vval1 - 0.10.
                    vlfinan = vvltotal.
                end.

                if finan.fincod = 38 or
                   finan.fincod = 39 or
                   /*finan.fincod = 17 or*/
                   finan.fincod = 90 or
                   finan.fincod = 44 or
                   finan.fincod = 70 or
                   finan.fincod = 68 or
                   finan.fincod = 69 or
                   finan.fincod = 100 or
                   finan.fincod = 46 or
                   finan.fincod = 79 or
                   finan.fincod = 91 or
                   finan.fincod = 71 or
                   finan.fincod = 36 or
                   finan.fincod = 15 or
                   finan.fincod = 35 or
                   finan.fincod = 62 or
                   finan.fincod = 14 or
                   finan.fincod = 98 
                   
                then do:
                    vval = (vvltotal * finan.finfat).
                    if varre100-01012023
                    then do:
                        if val-arr = 0.90
                        then run arredonda-90(input-output vval).
                        else
                if int(substr(string(truncate(vval,2),">>>>>>>>9.99"),11,2)) > 0
                then vval = 1 +
                    dec(substr(string(truncate(vval,2),">>>>>>>>9.99"),1,9)).
                    end.
                    else do:
                        vv = ( (int(vval) - vval ) ) - 
                            round(( (int(vval) - (vval)) ),1).
                        if vv < 0
                        then vv = 0.10 - (vv * -1). 
                        if finan.fincod = 17
                        then.
                        else vval = vval + vv.
                    end.
                    vlfinan = vval * wnp.
                end.   
            end.
            else do:

                vval = (vvltotal * finan.finfat).
                if varre100-01012023
                then do:
                    if val-arr = 0.90
                    then run arredonda-90(input-output vval).
                    else
                if int(substr(string(truncate(vval,2),">>>>>>>>9.99"),11,2)) > 0
                then vval = 1 + 
                     dec(substr(string(truncate(vval,2),">>>>>>>>9.99"),1,9)).
                end.
                else do:
                    vv = ( (int(vvltotal * finan.finfat) -
                       (vvltotal * finan.finfat)) )  -
                      round(( (int(vvltotal * finan.finfat) -
                            (vvltotal * finan.finfat)) ),1).

                    if vv < 0
                    then vv = 0.10 - (vv * -1).

                    vval = (vvltotal * finan.finfat) + vv.
                end.
                vlfinan = vval * wnp.

            /*    disp vv vval vvltotal vlfinan with frame f1.*/
            end.
            
            if p-dtentra = ?
            then vdtentra = today.
            else vdtentra = p-dtentra.
            if finan.finent = yes and plano-especial = no
            then do:
                    if (finan.fincod < 50 or 
                        finan.fincod >= 90 or
                        finan.fincod = 71 or
                        finan.fincod = 75  or
                        finan.fincod = 89  or 
                        finan.fincod = 85  or
                        finan.fincod = 81 or
                        finan.fincod = 82 or
                        finan.fincod = 83 or
                        finan.fincod = 84 or
                        finan.fincod = 87 or
                        finan.fincod = 88 or
                        finan.fincod = 86 or
                        finan.fincod = 69 or
                        finan.fincod <> 40 and
                        finan.fincod <> 97 
                        ) or  vplanonovo   
                    then do:
                        assign wfvlentra = vval.
                    end.
                    else do:
                        assign wfvlentra = vvltotal - (vval1 * finan.finnpc).
                    end.
                vorient = wfvlentra.

                do:
                    if wfvlentra <= 0
                    then do:
                        message "Entrada Invalida(1)".
                        undo, retry.
                    end.
                end.
                
                vdtentra = today.
                if day(vdtentra) >= 20 and
                   day(vdtentra) <= 31
                then do:
                    vdtentra = today.
                    if vdtentra > (today + 10) or vdtentra < today
                    then do:
                        hide message no-pause. message "Data da Entrada Invalida(1)". pause 1.
                        undo,retry.
                    end.
                    if vdtentra <> today
                    then do:
                        vok = yes.
                        run senha.p(output vok).
                        if vok = no
                        then undo,retry.
                    end.
                end.
                else do:
                    vdtentra = today.

                    if vdtentra > (today + 5) or vdtentra < today 
                    then do:
                        hide message no-pause. message "Data da Entrada Invalida(2)". pause 1.
                        undo,retry.
                    end.
                end.

            end.
            else wfvlentra = 0.
            
            if plano-especial and finan.finent = yes
            then wfvlentra = valorparcela.
            
            vval = 0.
            vval1 = 0.
            vsal = 0.

            vval = (vlfinan - wfvlentra) / finan.finnpc.


            if finan.fincod <> 94 and
               finan.fincod <> 89 and 
               finan.fincod <> 96 and
               finan.fincod <> 95 and 
               finan.fincod <> 92 and 
               vplanonovo = no
            then do:    
                if (finan.fincod < 50 or 
                    finan.fincod >= 90 or
                    finan.fincod = 70 or
                    finan.fincod = 71 or
                    finan.fincod = 75  or
                    finan.fincod = 85  or
                    finan.fincod = 81 or
                    finan.fincod = 82 or
                    finan.fincod = 83 or
                    finan.fincod = 84 or
                    finan.fincod = 87 or
                    finan.fincod = 88 or
                    finan.fincod = 86) and
                    finan.fincod <> 40 and
                    finan.fincod <> 97 and
                    finan.fincod <> 94


                then do:
                  if (finan.fincod    = 42 or
                      finan.fincod    = 43 or
                      finan.fincod    = 87) and
                     vcadeira-405249 = yes
                  then do:
                              
                    vval1 = vval.
                    if vval1 > vval
                    then vval1 = vval1 - 0.10.
                    vlfinan = vvltotal.

                  end.
                  else do:
                    vsal = vval - int(vval).
                        if vsal > 0
                        then vval = vval + (0.50 - vsal).
                        if vsal < 0 and vsal <> -0.50
                        then vval = ((vval - int(vval)) * -1) + vval.
                  end.  
                  
                end.
                else do:
                    if vval > 1 /*** 234429 ***/
                    then do.
                        vval1 = vval.
                        if vval1 > vval
                        then vval1 = vval1 - 0.10.
                        vval = vval1.
                    end.
                    else vval1 = vval.
                end.
                
                if finan.fincod = 38 or
                   finan.fincod = 39 or
                   /*finan.fincod = 17 or*/
                   finan.fincod = 90 or
                   finan.fincod = 44 or
                   finan.fincod = 70 or
                   finan.fincod = 68 or
                   finan.fincod = 69 or
                   finan.fincod = 100 or
                   finan.fincod = 46 or
                   finan.fincod = 79 or
                   finan.fincod = 91 or
                   finan.fincod = 71 or
                   finan.fincod = 36 or
                   finan.fincod = 86 or
                   finan.fincod = 15 or
                   finan.fincod = 35 or  
                   finan.fincod = 62 or
                   finan.fincod = 14  or
                   finan.fincod = 76  or
                   finan.fincod = 98
                then do:

                    vval = (vvltotal * finan.finfat).
                    
                    if varre100-01012023
                    then do:
                        if val-arr = 0.90
                        then run arredonda-90(input-output vval).
                        else
                if int(substr(string(truncate(vval,2),">>>>>>>>9.99"),11,2)) > 0
                then vval = 1 +
                    dec(substr(string(truncate(vval,2),">>>>>>>>9.99"),1,9)).
                    end.
                    else do:
                        vv = ( (int(vval) - vval ) ) - 
                            round(( (int(vval) - (vval)) ),1).
                            
                        if vv < 0  
                        then vv = 0.10 - (vv * -1).
                    
                        if finan.fincod = 17
                        then.
                        else vval = vval + vv.
                    end.
                    vlfinan = vval * wnp.

                end.   
            end.
            
            if (finan.fincod < 50 or 
                finan.fincod >= 90 or
                finan.fincod = 70 or
                finan.fincod = 79 or
                finan.fincod = 71 or
                finan.fincod = 75  or
                finan.fincod = 89  or 
                finan.fincod = 85  or
                finan.fincod = 81 or
                finan.fincod = 82 or
                finan.fincod = 83 or
                finan.fincod = 84 or
                finan.fincod = 87 or
                finan.fincod = 88 or
                finan.fincod = 86 or
                                      
                finan.fincod = 62 or
                finan.fincod = 76 or                                  
                finan.fincod = 66) and
                finan.fincod <> 40 and
                finan.fincod <> 97
            then do:
                wfvltotal = wfvlentra + (vval * finan.finnpc).
            end.
            else do:
                wfvltotal = vvltotal.
            end.
               
            vlfinan = wfvltotal - wfvlentra.

            if plano-especial
            then vlfinan = finan.finnpc * valorparcela.

            if plano-especial = no
            then vlfrete = 0.
            
            if finan.fincod = 38 or finan.fincod = 39
            then do:
                if setbcod = 76 or setbcod = 77 or setbcod = 78
                then do:
                
                    if vcadeira-1383 = yes
                    then do:
                        wfvlentra = (1.29 * vqtdcad).
                        vlfinan = finan.finnpc * (1.29 * vqtdcad).
                    end.
                    else
                    if vcadeira-402820 = yes
                    then do:
                        wfvlentra = (1.49 * vqtdcad).
                        vlfinan = finan.finnpc * (1.49 * vqtdcad).
                    end.
                end.
                else do:
                
                    if vcadeira-1383 = yes
                    then do:
                        wfvlentra = (1.99 * vqtdcad).
                        vlfinan = finan.finnpc * (1.99 * vqtdcad).
                    end.
                end.
            end.
            
            vliqui = vlfinan + wfvlentra.

            wpar = finan.finnpc.

            /*** planos especiais de inauguração ***/
            if finan.fincod = 35 or
               finan.fincod = 36 or
               finan.fincod = 38 or
               finan.fincod = 39 
            then do:
                if finan.finent
                then do:
                    wfvlentra = valorori / (finan.finnpc + 1).
                    vlfinan = valorori - wfvlentra.
                end.
                else vlfinan = vvltotal .
            end.
            
            find first tt-arr where tt-arr.fincod = finan.fincod no-error.
            if avail tt-arr and plano-especial = no
            then do.
                run arredondamento_novos_planos (input  par-protot,
                                                 input  finan.fincod,
                                                 output vval).
                
                if finan.finent
                then do:
                    wfvlentra = vval.
                end.    
                vvltotal = par-protot.
                vval1 = vval.
                vlfinan  = vval * wpar.
                vplanonovo = yes.                 
                vliqui = (vlfinan + wfvlentra) .  
            end.
            
            /***              ***/
            
            if finan.fincod = 1
            then do:
                wfvlentra = vvltotal - vlfinan.
            end.
            /****************************************************************
             VENDA COM ENTRADA
            ****************************************************************/
            if wfvlentra > 0
            then do:
                create wf-titulo.
                assign wf-titulo.empcod   = wempre.empcod
                       wf-titulo.modcod   = "CRE"
                       wf-titulo.cxacod   = scxacod
                       wf-titulo.clifor   = 1
                       wf-titulo.titnum   = "1"
                       wf-titulo.titpar   = (if vdtentra = today
                                          then 0
                                          else 1)
                       wf-titulo.titsit   = "LIB"
                       wf-titulo.titnat   = no
                       wf-titulo.etbcod   = setbcod
                       wf-titulo.titdtemi = today
                       wf-titulo.titdtven = vdtentra /*wf-titulo.titdtemi*/
                       wf-titulo.titvlcob = wfvlentra + vlfrete
                       wf-titulo.cobcod = 2
                       wf-titulo.datexp = today
                       ventra           = wfvlentra.
            end.
        end.
    end.
    assign wcon = (if vdtentra = today
                   then 0
                   else 1)
    wval = 0
    vday = day(vdtentra).
    
    
    assign vmes = month (vdtentra) + 1.
    assign vano = year (vdtentra).
    if  vmes > 12 then
        assign vano = vano + 1
               vmes = vmes - 12. 

    repeat on endkey undo l0,retry l0:

        clear frame f3 all.

        assign wcon = wcon + 1.

        find first wf-titulo
            where wf-titulo.empcod = 19                          and
                  wf-titulo.titnat = no                          and
                  wf-titulo.modcod = "cre"                       and
                  wf-titulo.clifor = 1                           and
                  wf-titulo.etbcod = setbcod                     and
                  wf-titulo.titnum = "1"                         and
                  wf-titulo.titpar = wcon no-error.
        if avail wf-titulo
        then leave.
        create wf-titulo.
        assign wf-titulo.empcod = wempre.empcod
               wf-titulo.modcod = "CRE"
               wf-titulo.cxacod = scxacod
               wf-titulo.cliFOR = 1
               wf-titulo.titnum = "1"
               wf-titulo.titpar = wcon
               wf-titulo.titnat = no
               wf-titulo.etbcod = setbcod
               wf-titulo.titdtemi = today
               wf-titulo.titdtven = date(vmes,
                                       IF  VMES = 2 THEN
                                           IF  VDAY > 28 THEN
                                               28
                                            ELSE VDAY
                                       ELSE
                                            if vday = 31 then
                                                30
                                            else VDAY,
                                       vano)
               wf-titulo.cobcod = 2
               wf-titulo.titsit  = "LIB"
               wf-titulo.datexp  = today.

        if finan.fincod = 203 or /*Moveis*/
finan.fincod = 205 or /*Moveis*/
finan.fincod = 206 or /*Moveis*/
finan.fincod = 207 or /*Moveis*/
finan.fincod = 210 or /*Moveis*/
finan.fincod = 211 or /*Moveis*/
finan.fincod = 212 or /*Moveis*/
finan.fincod = 213 or /*Moveis*/
finan.fincod = 214 or /*Moveis*/
finan.fincod = 215 or /*Moveis*/
finan.fincod = 216 or /*Moveis*/
finan.fincod = 217 or /*Moveis*/
finan.fincod = 220 or /*Moveis*/
finan.fincod = 221 or /*Moveis*/
finan.fincod = 222 or /*Moveis*/
finan.fincod = 225 or /*Moveis*/
finan.fincod = 226 or /*Moveis*/
finan.fincod = 227 or /*Moveis*/
finan.fincod = 230 or /*Moveis*/
finan.fincod = 231 or /*Moveis*/
finan.fincod = 232 or /*Moveis*/
finan.fincod = 233 or /*Moveis*/
finan.fincod = 411 or /*Moveis*/
finan.fincod = 601 or /*Moveis*/
finan.fincod = 602 or /*Moveis*/
finan.fincod = 603 or /*Moveis*/
finan.fincod = 606 or /*Moveis*/
finan.fincod = 607 or /*Moveis*/
finan.fincod = 712 or /*Moveis*/
finan.fincod = 715 or /*Moveis*/
finan.fincod = 83    /*Moveis*/
/*
finan.fincod = 55 or /*Moda*/
finan.fincod = 60 or /*Moda*/
finan.fincod = 108 or /*Moda*/
finan.fincod = 200 or /*Moda*/
finan.fincod = 89 or /*Moda*/
finan.fincod = 80 /*Moda*/ 
*/  
      then wf-titulo.titdtven = today + 60.   
            
        vdtven = wf-titulo.titdtven.

        if day(today) >= 20 and
           day(today) <= 31
        then do on error undo, retry:
            if wf-titulo.titdtven > (vdtven + 10) or
               wf-titulo.titdtven < today
            then do:
                hide message no-pause. message "Data de Vencimento Invalida(1)". pause 1.
                undo, return.
            end.
            if wf-titulo.titdtven <> vdtven
            then do:
                vok = yes.
                run senha.p(output vok).
                if vok = no
                then undo,retry.
            end.
            if wf-titulo.titdtven > today + 60
            then do:
                if today >= 03/28/2003 and
                   today <= 04/30/2003 /*and
                   finan.fincod = 17     */
                then.
                else do:
                    if finan.fincod = 559
                    then.
                    else do:
                        if today >= 08/29/2003 and
                           today <= 09/30/2003 and
                           (finan.fincod = 22  or
                            finan.fincod = 94  or
                            finan.fincod = 60  or
                            finan.fincod = 97 )
                        then.
                        else do:
                            hide message no-pause. /*message "Data de vencimento invalida(31)". pause 1. */
                            undo, return.
                        end.
                    end.    
                end.
            end.
        end.
        else do on error undo, retry:
            wf-titulo.titdtven - today.
            if wf-titulo.titdtven > (vdtven + 5) or
               wf-titulo.titdtven < today
            then do:
                hide message no-pause. message "Data da Entrada Invalida(33)". pause 1.
                undo,retry.
            end.
            
            if finan.fincod = 559 and
               wf-titulo.titdtven > 02/05/2013
            then do:
                hide message no-pause. message "Data de vencimento invalida(5)". pause 1.
                undo, return.
            end.
            /*message finan.fincod wf-titulo.titdtven. pause.*/
            if wf-titulo.titdtven > today + 60
            then do:
                if today >= 03/28/2003 and
                   today <= 04/30/2003 /*and
                   finan.fincod = 17     */
                then.
                else do:
                    if finan.fincod = 559
                    then.
                    else do:
                        if today >= 08/29/2003 and
                           today <= 09/30/2003 and
                           (finan.fincod = 22  or
                            finan.fincod = 94  or
                            finan.fincod = 60  or
                            finan.fincod = 97)
                        then.
                        else do:
                            message "Data de vencimento invalida(6)".
                            pause 0.
                            undo, return.
                        end.    
                    end.    
                end.
                
                if finan.fincod = 559 and
                   wf-titulo.titdtven > 02/05/2003
                then do:
                    hide message no-pause. message "Data de vencimento invalida(7)". pause 1.
                    undo, return.
                end.
            end.
        end.

        if wf-titulo.titdtven < vdtentra
        then do:
            hide message no-pause. message "Data de vencimento invalida(8)". pause 1.
            undo, return.
        end.
        
        if vplanonovo = no
        then do.
            if finan.finent = yes or
               ((finan.fincod < 50  or 
                 finan.fincod >= 90 or
                 finan.fincod = 70 or
                 finan.fincod = 79 or
                 finan.fincod = 71 or
                 finan.fincod = 75  or
                 finan.fincod = 89  or 
                 finan.fincod = 85  or
                 finan.fincod = 81 or
                 finan.fincod = 82 or
                 finan.fincod = 83 or
                 finan.fincod = 84 or
                 finan.fincod = 87 or
                 finan.fincod = 88 or
                 finan.fincod = 86 or
                 finan.fincod = 69 or
                 finan.fincod = 62 or
                 finan.fincod = 76) and
                 finan.fincod <> 40 and
                 finan.fincod <> 97) 
            then do:
                wf-titulo.titvlcob = vlfinan / wpar.
            end.
            else do:
                wf-titulo.titvlcob = 
                            (vvltotal - (vval1 * finan.finnpc)) + vval1 .
                            
            end.
        end.
        else do.
        
            wf-titulo.titvlcob = vlfinan / wpar  .

        end.
        vparce = wf-titulo.titvlcob.
        
        
        vmes = month(wf-titulo.titdtven) + 1.
        vano = year (wf-titulo.titdtven).
        if  vmes > 12 then
            assign vano = vano + 1
                   vmes = vmes - 12.

        if wfvlentra  = 0
        then vlrtot = (wfvltotal - vlfrete).
        else vlrtot = (wfvltotal - wfvlentra - vlfrete).

        vday = day(wf-titulo.titdtven).
        view frame f3.
        v-down = no.
        
        do i = wcon + 1 to (if vdtentra = today
                             then wpar
                             else wpar + 1).

            assign wcon = 0
                   vmes = month(wf-titulo.titdtven) + 1
                   vano = year (wf-titulo.titdtven).

            if  vmes > 12 then
                assign vano = vano + 1
                       vmes = vmes - 12.
            do on error undo:
                create wf-titulo.
                assign
                    wf-titulo.empcod = wempre.empcod
                    wf-titulo.modcod = "CRE"
                    wf-titulo.cxacod = scxacod
                    wf-titulo.cliFOR = 1
                    wf-titulo.titnum = "1"
                    wf-titulo.titpar = i
                    wf-titulo.titnat = no
                    wf-titulo.etbcod = setbcod
                    wf-titulo.titdtemi = today
                    wf-titulo.titdtven = date(vmes,
                                       IF VMES = 2
                                       THEN IF VDAY > 28
                                            THEN 28
                                            ELSE VDAY
                                        ELSE if VDAY > 30
                                             then 30
                                             else vday,
                                       vano).


                    /*****/
                    if finan.finent = yes or
                       ((finan.fincod < 50  or 
                         finan.fincod >= 90 or
                         finan.fincod = 70 or
                         finan.fincod = 79 or
                         finan.fincod = 71 or
                         finan.fincod = 75  or
                         finan.fincod = 89  or 
                         finan.fincod = 85  or
                         finan.fincod = 81 or
                         finan.fincod = 82 or
                         finan.fincod = 83 or
                         finan.fincod = 84 or
                         finan.fincod = 87 or
                         finan.fincod = 88 or
                         finan.fincod = 86 or
                         finan.fincod = 62 or
                         finan.fincod = 69 or
                         finan.fincod = 76 or
                         finan.fincod = 77) and
                         finan.fincod <> 40 and
                         finan.fincod <> 97)
                    then do:
                        wf-titulo.titvlcob = vlfinan / wpar.
                    end.

                    else
                    if finan.finent <> yes
                    then do:
                        wf-titulo.titvlcob = (vvltotal -
                                           (vval1 * finan.finnpc)).
                        wf-titulo.titvlcob = ((wfvltotal - wfvlentra) / wpar) -
                                          (wf-titulo.titvlcob / finan.finnpc).
                    end.
                    else wf-titulo.titvlcob = (wfvltotal - wfvlentra) / wpar.

                    assign
                    wf-titulo.cobcod = 2
                    wf-titulo.titsit = "LIB"
                    wf-titulo.datexp = today.

            end.

            down with frame f3.
            vparce = wf-titulo.titvlcob.
            down with frame f3.
            assign wval = wval + wf-titulo.titvlcob.
                   vmes = vmes + 1.
                   if  vmes > 12 then
                        assign vano = vano + 1
                               vmes = vmes - 12.
        end.

        if wcon = (if vdtentra = today
                   then wpar
                   else wpar + 1)
        then leave.
    end.
    cont = 0.
    leave.
end.


hide frame f1 no-pause.
hide frame f2 no-pause.
hide frame f3 no-pause.                




procedure arredondamento_novos_planos.
def input  parameter par-protot     as dec.
def input  parameter par-fincod     like finan.fincod.
def output parameter par-titvlcob   as dec.

def var arr-vval    as dec.
def var arr-wval    as dec.
def var arr-wnp     as int.

def var arr-vval1 as dec decimals 1.
def var arr-vlfinan         like contrato.vltotal label "Vlr Financiamento".
def var arr-vvltotal        like contrato.vltotal .
def var arr-vfincod like finan.fincod.

arr-vvltotal = par-protot.
for each tt-arr where tt-arr.fincod = par-fincod.
    arr-vfincod = tt-arr.fincod.
    find finan where finan.fincod = arr-vfincod no-lock.
    arr-wnp = finan.finnpc + if finan.finent = yes 
                         then 1 
                         else 0.          
    arr-vval = (arr-vvltotal * finan.finfat). 

    arr-vlfinan = arr-vval * arr-wnp.
    def var int as int.  
    def var dec as dec decimals 2.  
    int = truncate(arr-vval,0).  
    dec = arr-vval - int.  
    
    if varre100-01012023 and tt-arr.arr > 0
    then do:
        if val-arr = 0.90
        then run arredonda-90(input-output arr-vval).
        else
        if int(substr(string(truncate(arr-vval,2),">>>>>>>>9.99"),11,2)) > 0
        then arr-vval = 1 +
            dec(substr(string(truncate(arr-vval,2),">>>>>>>>9.99"),1,9)).
    end.
    else if not varre100-01012023
    then do:                
    if tt-arr.arr = 0.10 
    then do. 
        if tp-rr = "R-+"
        then dec = round(dec,1).
        else
        dec = if dec >= 0.01 and dec <= 0.10  
              then 0.10  
              else  
              if dec >= 0.11 and dec <= 0.20  
              then 0.20  
              else  
              if dec >= 0.21 and dec <= 0.30  
              then 0.30  
              else     
              if dec >= 0.31 and dec <= 0.40  
              then 0.40  
              else  
              if dec >= 0.41 and dec <= 0.50  
              then 0.50  
              else  
              if dec >= 0.51 and dec <= 0.60  
              then 0.60  
              else  
              if dec >= 0.61 and dec <= 0.70  
              then 0.70  
              else  
              if dec >= 0.71 and dec <= 0.80  
              then 0.80  
              else  
              if dec >= 0.81 and dec <= 0.90  
              then 0.90  
              else  
              if dec >= 0.91 and dec <= 1.00  
              then 1  
              else dec.  
        arr-vval = int + dec.
    end. 
    else if tt-arr.arr = 0.50 
    then do. 
        dec = if dec >= 0.01 and dec <= 0.50 
              then 0.50 
              else if dec >= 0.51 and dec <= 1.00 
              then 1                      
              else dec. 
        arr-vval = int + dec.
    end. 
    else if tt-arr.arr = 0.90 
    then do. 
        if dec > 0
        then do:
            if dec < .50 and int > 0
            then assign int = int - 1 dec = .90.
            else if dec >= .50
                then dec = .90.    
        end.
        arr-vval = int + dec.
    end. 
    else if tt-arr.arr = 0
    then do:
        arr-vval = int + dec.
    end.
    end.
    arr-wval = arr-vval.
end.
par-titvlcob = arr-wval.
end procedure.

procedure arredonda-90:
         def input-output parameter par-valor as dec.
             def var dec as dec.
                 dec = dec(substr(string(truncate(par-valor,2),">>>>>>>>9.99"),11,2)).

    if  dec <> 90
        then par-valor =
        dec(substr(string(truncate(par-valor,2),">>>>>>>>9.99"),1,9))
                        + .90
                                        .
                                        end.
                                        
    
    
        
