/* validar ICCID */
def input parameter p-iccid  as char.
def input parameter p-clacod as int.
def output parameter p-ok as log init yes.

def buffer bclase for clase.

find first bclase where bclase.clacod = p-clacod no-lock.

        case (bclase.clasup):
            
            when 129050200
            then do:
                if substring(p-iccid,1,4) <> "8955"
                then do:
                    message "ICCID INVÁLIDO!! O ICCID da Vivo inicia com 8955"
                                view-as alert-box.
                    p-ok = no.
                end.                
            end.

            when 129030100
            then do:
                if substring(p-iccid,1,4) <> "8955"
                then do:
                    message "ICCID INVÁLIDO!! O ICCID da Claro inicia com 8955"
                                view-as alert-box.
                    p-ok = no.
                end.
            end.         

            when 129070300
            then do:
                if substring(p-iccid,1,4) <> "8955"
                then do:
                    message "ICCID INVÁLIDO!! O ICCID da TIM inicia com 8955"
                                view-as alert-box.
                    p-ok = no.
                end.                
            end.
            end case.

