{admcab.i}
{bagdefs.i new}

 DEFINE new shared TEMP-TABLE ttclien NO-UNDO       serialize-name 'creditoCliente'
    field tipo    as char format "x(18)"
    field clicod    as int serialize-name 'codigoCliente'
    field cpfCNPJ    as char format "x(18)"    serialize-name 'cpfCNPJ'
    field clinom    as char format "x(40)" serialize-name 'nomeCliente'
    field limite      as dec
    field vctoLimite  as date
    field saldoLimite  as dec
    field comprometido as dec
    field comprometidoTotal as dec
    field comprometidoPrincipal as dec
    field comprometidoNormal as dec
    field comprometidoNovacao as dec
    /* #092022 */
    field dataUltimaCompra as date
    field quantidadeContratos as int
    field quantidadeParcelasPagas as int
    field quantidadeParcelasEmAberto as int
    field valorParcelasAtraso as dec
    field quantidadeAte15Dias as int
    field quantidadeAte45Dias as int
    field quantidadeAcima45Dias as int
    /* #092022 */
    index cli is unique primary clicod asc tipo desc.

def var pcpf    as dec format "99999999999" label "CPF".
def var pidbag  as int.
def var presposta as char.
def var phttp_code as int.

def var pconsultor like func.funcod.
 
form
    setbcod label "filial" colon 15
    pconsultor label "consultor" colon 15
    pcpf colon 15 
    ttcliente.nome format "x(30)" no-labels
    
    with frame fcab
    row 6
     side-labels centered  width 80
     title " ABERTURA DE NOVA BAG ".
disp setbcod with frame fcab.
 
pconsultor = sfuncod.     
update 
    pconsultor 
        with frame fcab.

    update pcpf
        with frame fcab.

    
    if pcpf = 0 or pcpf = ?
    then do:
        message "cliente precisa ser identificado".
        undo.
    end. 
    else do:

        find clien where clien.ciccgc = string(pcpf) no-lock no-error.
        if not avail clien
        then
            find clien where clien.ciccgc = string(pcpf,"99999999999") no-lock no-error.
        if not avail clien
        then do:
            message "CLIENTE PRECISA SER CADASTRADO!" skip(2)
                    "NÃO É POSSIVEL CRIAÇÃO DE BAG PARA O CLIENTE," skip 
                    "FAVOR CONTACTAR SETOR DE CRÉDITO"
                view-as alert-box .
            undo.
        end.
    end.    
    /*update pcpf with frame fcab.*/
    
    
    /* teste limites */
def var vok as log.    
    empty temp-table ttclien.
       
    run apilimites-consulta.p (input pcpf, output phttp_code, output presposta).
    
    vok = no.
    find first ttclien where ttclien.tipo = "GLOBAL" no-error.
    if avail ttclien and phttp_code = 200
    then do:
        if ttclien.vctolimite >= today
        then do:
            if ttclien.valorParcelasAtraso <= 0
            then vok = yes.        
        end.
     end.
    
    if not vok
    then do:
            message 
                    "NÃO É POSSIVEL CRIAÇÃO DE BAG PARA O CLIENTE," skip 
                    "FAVOR CONTACTAR SETOR DE CRÉDITO"
                view-as alert-box .
            undo.
    end.    

        
        run bagclien.p (input pcpf).
        find first  ttcliente no-error.
        if not avail ttcliente
        then undo, return.
        disp ttcliente.nome 
            with frame fcab.




sresp = yes.
message "Confirma criar uma nova bag" update sresp.
IF SRESP = NO
THEN RETURN.

run bagapiabrebag.p (setbcod,pconsultor, input pcpf, output pidbag, output phttp_code, output presposta).     



if phttp_code = 200
then do:
    hide message no-pause.
    message "nova bag criada". 
    run bagprodu.p (input pcpf, input pidbag).
end.

