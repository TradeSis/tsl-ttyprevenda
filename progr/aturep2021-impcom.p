/*{admdisparo.i}*/
def new global shared var setbcod    like ger.estab.etbcod.

def input param dd-rep as int.
def input param vlog as char.


def var cont-sel as int.
def var cont-atu as int.

PROCEDURE log.
    def input param par-texto as char.

        output to value(vlog) append.
        put unformatted string(time,"HH:MM:SS")  
                        "   aturep2021-impcom.p DIAS " + string(dd-rep) " "
                        par-texto
                        skip.
        output close.

end PROCEDURE.


def var i as int.

    run log ("IMP COM INICIO - FILIAL = " + string(setbcod)).
 
assign
    cont-sel = 0 cont-atu = 0.
    run log ("INTEGRACAO commatriz.produ").
    
    for each commatriz.produ where 
         commatriz.produ.datexp <= today and
         commatriz.produ.datexp >= today - dd-rep 
         no-lock: 
        cont-sel = cont-sel + 1.
    end.
    if cont-sel > 0
    then do:
        run log (" INTEGRACAO commatriz.produ Selecionados " + string(cont-sel) + " Registros").

        for each commatriz.produ where 
                 commatriz.produ.datexp <= today and
                 commatriz.produ.datexp >= today - dd-rep 
                 no-lock: 
            find first com.produ where
                       com.produ.procod = commatriz.produ.procod 
                       exclusive no-wait no-error.
            if not avail com.produ
            then do:
                if locked com.produ
                then.
                else do: 
                    create com.produ.
                    {tt-produ.i com.produ commatriz.produ}
                    com.produ.exportado = yes.
                    cont-atu = cont-atu + 1.
                end.
            end.
            else do:
                buffer-copy commatriz.produ to com.produ.
                cont-atu = cont-atu + 1.
            end.
        end.  
        run log(" INTEGRACAO commatriz.produ  Atualizados " + string(cont-atu) + " Registros").
        
    end.
    
    assign
        cont-sel = 0 cont-atu = 0.
    run log ("INTEGRACAO commatriz.unida - Elimina base local").
    for each com.unida no-lock:
        cont-sel = cont-sel + 1.
        find commatriz.unida where commatriz.unida.unicod = com.unida.unicod 
                no-lock no-error.
        if not avail commatriz.unida
        then do:        
            run punida.
        end.
    end.
    procedure punida.
        do on error undo:              
            find current com.unida exclusive no-wait no-error.
            if avail com.unida
            then do:
                delete com.unida.
                cont-atu = cont-atu + 1.
            end.     
        end.     
    end procedure.
    run log(" INTEGRACAO commatriz.unida - Elimina base local, Selecionados " + string(cont-sel) + 
                                                            ", Atualizados " + string(cont-atu) + " Registros").
        
    assign
        cont-sel = 0 cont-atu = 0.
    run log ("INTEGRACAO commatriz.unida").
    for each commatriz.unida no-lock:
        cont-sel = cont-sel + 1.
    end.
    if cont-sel > 0
    then do:
        run log (" INTEGRACAO commatriz.unida Selecionados " + string(cont-sel) + " Registros").
    
        for each commatriz.unida no-lock:
            find com.unida where com.unida.unicod = commatriz.unida.unicod 
                exclusive no-wait no-error.
            if not avail com.unida
            then do:
                if locked com.unida
                then .
                else do:
                    create com.unida.
                    assign com.unida.unicod = commatriz.unida.unicod
                       com.unida.uninom = commatriz.unida.uninom.
                    cont-atu = cont-atu + 1.
                end.
            end.
        end.
        run log (" INTEGRACAO commatriz.unida  Atualizados " + string(cont-atu) + " Registros").
    end.

assign cont-sel = 0 cont-atu = 0.
    run log ("INTEGRACAO commatriz.clase").
    for each commatriz.clase no-lock:
        cont-sel = cont-sel + 1.
    end.
    if cont-sel > 0
    then do:
        run log (" INTEGRACAO commatriz.clase Selecionados " + string(cont-sel) + " Registros").
        for each commatriz.clase no-lock:
            find com.clase where
              com.clase.clacod = commatriz.clase.clacod 
                 exclusive no-wait no-error.
            if not avail com.clase
            then do:
                if locked com.clase
                then.
                else do:
                    create com.clase.
                    buffer-copy commatriz.clase to com.clase.
                    cont-atu = cont-atu + 1.
                end.
            end.
            if avail com.clase
            then if com.clase.clanom <> commatriz.clase.clanom 
                 then do:
                    com.clase.clanom = commatriz.clase.clanom.
                    cont-atu = cont-atu + 1.
                 end.    
        end.
        run log (" INTEGRACAO commatriz.clase  Atualizados " + string(cont-atu) + " Registros").
    end.


assign cont-sel = 0 cont-atu = 0.
    run log ("INTEGRACAO commatriz.estoq - filial " + string(setbcod)).
    for each commatriz.estoq use-index idatexp where commatriz.estoq.datexp >= today - dd-rep   
                           and commatriz.estoq.datexp <= today 
                           and commatriz.estoq.etbcod = setbcod
                           no-lock:
        cont-sel = cont-sel + 1.
    end.
    if cont-sel > 0
    then do:
        run log (" INTEGRACAO commatriz.estoq Selecionados " + string(cont-sel) + " Registros").

        for each commatriz.estoq use-index idatexp where commatriz.estoq.datexp >= today - dd-rep   
                           and commatriz.estoq.datexp <= today 
                           and commatriz.estoq.etbcod = setbcod
                           no-lock:
            find first com.estoq where com.estoq.procod = commatriz.estoq.procod
                                   and com.estoq.etbcod = commatriz.estoq.etbcod
                                   exclusive no-wait no-error.
            if not avail com.estoq
            then do:
                if locked com.estoq
                then.
                else do:
                    create com.estoq.
                    {tt-estoq.i com.estoq commatriz.estoq}.
                    cont-atu = cont-atu + 1.
                end.    
            end.        
            else do:
                IF
                        com.estoq.estvenda  <> commatriz.estoq.estvenda or
                        com.estoq.estcusto  <> commatriz.estoq.estcusto or
                        com.estoq.estproper <> commatriz.estoq.estproper or
                        com.estoq.estbaldat <> commatriz.estoq.estbaldat or
                        com.estoq.estprodat <> commatriz.estoq.estprodat or
                        com.estoq.estrep    <> commatriz.estoq.estrep or
                        com.estoq.estmin    <> commatriz.estoq.estmin or
                        com.estoq.tabcod    <> commatriz.estoq.tabcod or
                        com.estoq.estinvdat <> commatriz.estoq.estinvdat or
                        /* helio 04/03/2024 */
                        com.estoq.cst       <> commatriz.estoq.cst or
                        com.estoq.aliquotaicms  <> commatriz.estoq.aliquotaicms
                        
                then do:
                    assign
                        com.estoq.estvenda  = commatriz.estoq.estvenda
                        com.estoq.estcusto  = commatriz.estoq.estcusto
                        com.estoq.estproper = commatriz.estoq.estproper
                        com.estoq.estbaldat = commatriz.estoq.estbaldat
                        com.estoq.estprodat = commatriz.estoq.estprodat
                        com.estoq.estrep    = commatriz.estoq.estrep
                        com.estoq.estmin    = commatriz.estoq.estmin
                        com.estoq.tabcod    = commatriz.estoq.tabcod
                        com.estoq.estinvdat = commatriz.estoq.estinvdat.
                        
                        com.estoq.cst           = commatriz.estoq.cst.
                        com.estoq.aliquotaicms  = commatriz.estoq.aliquotaicms.

                    cont-atu = cont-atu + 1.
                end.
            end.
        end.
        run log (" INTEGRACAO commatriz.estoq  Atualizados " + string(cont-atu) + " Registros").
    end.
    
assign cont-sel = 0 cont-atu = 0.
    run log ("INTEGRACAO commatriz.produaux").
    for each commatriz.produaux where
         commatriz.produaux.exportar = yes and
         commatriz.produaux.datexp <= today and
         commatriz.produaux.datexp >= today - dd-rep
         no-lock:
        cont-sel = cont-sel + 1.
    end.
    if cont-sel > 0
    then do:
        run log (" INTEGRACAO commatriz.produaux Selecionados " + string(cont-sel) + " Registros").
        for each commatriz.produaux where
                 commatriz.produaux.exportar = yes and
                 commatriz.produaux.datexp <= today and
                 commatriz.produaux.datexp >= today - dd-rep
                 no-lock:
            if commatriz.produaux.nome_campo = "mix" 
            then next.
            else if commatriz.produaux.nome_campo <> "produ-equivalente" and
                    commatriz.produaux.nome_campo <> "ST" and
                    commatriz.produaux.nome_campo <> "TempoGar"
                 then next.
            find first com.produaux where 
                 com.produaux.procod      = commatriz.produaux.procod and
                 com.produaux.nome_campo  = commatriz.produaux.nome_campo 
                 exclusive no-wait no-error.
            if not avail com.produaux 
            then do:
                if locked com.produaux
                then.
                else do:
                    if not avail com.produaux and not locked com.produaux
                    then do:
                        create com.produaux.
                        buffer-copy commatriz.produaux to com.produaux.
                        cont-atu = cont-atu + 1.
                    end.
                end.
            end.
            else do:
                assign
                    com.produaux.valor_campo = commatriz.produaux.valor_campo
                    com.produaux.datexp      = commatriz.produaux.datexp.
                cont-atu = cont-atu + 1.
            end.
        end.
        run log (" INTEGRACAO commatriz.produaux  Atualizados " + string(cont-atu) + " Registros").
        
    end.

run log("FIM").

