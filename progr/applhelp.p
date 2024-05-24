/*----------------------------------------------------------------------------*/
/* /usr/admger/applhelp.p                             Rotina Generica de Help */
/*                                                                            */
/* Data     Autor   Caracteristica                                            */
/* -------- ------- ------------------                                        */
/* 27/02/92 Masiero Criacao                                                   */
/*----------------------------------------------------------------------------*/
def var wbk as char.
def var vesc    as char format "x(11)"
       extent 3 initial ["Abre gaveta","Calculadora","Calendario"].
{admcab.i}

if lastkey = keycode("F5") or
   lastkey = keycode("PF5")
then do:
    display vesc with row 4 column 35
            frame fesc no-label overlay color white/blue
            .
    choose field vesc with frame fesc.
    hide frame fesc no-pause.
    if frame-index = 1
    then
        run bema-gaveta.p.
    else if frame-index = 2    
    then
        run calculat.p .
    else
        run calendar.p.
end.

if lastkey = keycode("F7") or
   lastkey = keycode("PF7")
then do:
    /*
    find first processo where
            processo.tipo    = yes and
            processo.campo   = frame-field and
            processo.programa = sprograma no-error.
    if not avail processo
    then
        find first processo where
            processo.tipo = yes and
            processo.campo   = frame-field no-error.
    if available processo
    then run value(processo.executar + ".p").
    */
if frame-field matches "*tclcod*"
    then run ztcliFOR.p.

if frame-field matches "*fordes*"
    then run zforaut.p.
    
if frame-field matches "*juscod*"
    then run ztabjus.p.
    
if frame-field matches "*modcod*"
    then run zmodal.p.
if frame-field matches "*cobcod*"
    then run zcobra.p.
if frame-field matches "*crecod*"
    then run zcrepl.p.
if frame-field matches "*cxacod*"
    then run zcaixa.p.
if frame-field matches "*moecod*"
    then run zmoeda.p.
if frame-field matches "*funcod*"
    then run zfunc.p.
if frame-field matches "*eve*"
    then run zevent.p.

if frame-field matches "*tipviv*"
    then run zpromoviv.p.
if frame-field matches "*tiptim*"
    then run zpromotim.p.
if frame-field matches "*tipxxx*"
    then run zpromox.p.        
if frame-field matches "*codviv*"    
    then run zplanoviv.p.
if frame-field matches "*codxxx*"    
    then run zplanox.p.    
    
if frame-field matches "*opecod*"
    then run zopera.p.
if frame-field matches "*forcod*" or
   frame-field matches "*tracod*"
    then if program-name(2) = "cotin.p"
            then run zcotin.p.
            else run zforne.p.
if frame-field matches "*empcod*"
    then run zempre.p.
if frame-field matches "*ufecod*"
    then run zunfed.p.
if frame-field matches "*etb-*"
    then run zestab-munic.p.
else if frame-field matches "*etb*"
    then run zestab.p.
if frame-field matches "*setcod*"
    then run zsetor.p.
if frame-field matches "*clf*" or
   frame-field matches "*emi*" or
   frame-field matches "*des*"
    then do:
       run zclF.p.
    end.
if frame-field matches "*cli*"
then /*if program-name(2) <> "tstzoom.p"
     then run clienf7.p.
     else*/ run zclinew9.p .    /* zclien.p. */
    
    
if frame-field matches "*unocod*"
    then run zunorg.p.
if frame-field matches "*indcod*"
    then run zind.p.
if frame-field matches "*crecod*"
    then run zcrepl.p.
if frame-field matches "*clacod*"
    then run zclase.p.
if frame-field matches "*pednum*"
    then run zpedcli.p.
if frame-field matches "*corcod*"
    then run zcor.p.
if frame-field matches "*itecod*"
    then run zitem.p.
if frame-field matches "*fabcod*"
    then run zfabri.p.
if frame-field matches "*proindice*"
then run zproind.p .
if frame-field matches "*proind*"
    then run zproind.p.
/**
if frame-field matches "*procod*"
    then run zprodu.p.
**/


if frame-field matches "*procod*"
then if program-name(2) matches "*wf-pre*" or program-name(2) matches "*pesco*" or  program-name(2) matches "*bagprodu*"
     then run novozoom.p. 
     else do:
        if program-name(2) = "monmov.p"
        then.
        else run zprodu.p.
     end.
     
if frame-field matches "*unicod*" or
   frame-field matches "*uncom*" or
   frame-field matches "*unven*"
    then run zunida.p.
if frame-field matches "*comcod*"
    then run zcompr.p.
if frame-field matches "*motcod*"
    then run zmotiv.p.
if frame-field matches "*tofcod*" or
   frame-field matches "*etbtof*"
    then run ztofis.p.
if frame-field matches "*tracod*"
    then run ztrans.p.
if frame-field matches "*vencod*"
    then run zvende.p.
if frame-field matches "*etccod*"
    then run zestac.p.
if frame-field matches "*ctrcod*"
    then run zctrib.p.
if frame-field matches "*catcod*"
    then run zcateg.p.
if frame-field matches "*gracod*"
    then run zgrade.p.
if frame-field matches "*clasup*"
    then run zclasu.p.
if frame-field matches "*gfcod*"
    then run zglofin.p.
if frame-field matches "*fincod*"
    then run zfinan.p.
if frame-field matches "*bancod*"
    then run zbanco.p.
if frame-field matches "*codprof*"
    or frame-field matches "*var-int4*"
    or frame-field matches "*var-int5*"
    then run zcodprof.p.
if frame-field matches "*var-char10*" or
   frame-field matches "*natur*" 
    then run zmuncod.p.
                
    
    
end.
                      /*
if lastkey = keycode("F6") or
   lastkey = keycode("PF6")
    then do:
    {hadmger.i}
    {hadmcom.i}
    {hadmfin.i}
    end.                */
