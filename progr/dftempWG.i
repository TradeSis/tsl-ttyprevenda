def {1} shared temp-table tp-vndseguro like vndseguro.
def {1} shared temp-table tp-pedid like pedid.
def {1} shared temp-table tp-liped like liped.
def {1} shared temp-table tp-contrato like contrato.
def {1} shared temp-table tp-contnf like contnf.
def {1} shared var conecta-ok as log.
def {1} shared temp-table tp-clien like clien.
def {1} shared temp-table tp-cpclien like cpclien.
def {1} shared temp-table tp-carro like carro.
def {1} shared temp-table tp-estoq like estoq.
def {1} shared temp-table tp-plani like plani
    index ipladat-d pladat desc.
def {1} shared temp-table tp-titluc like titluc.
def {1} shared temp-table tp-movim like movim.
def {1} shared temp-table tp-cheque like cheque.
def {1} shared temp-table tp-titulo like titulo
    index dt-ven titdtven 
    index titnum /*is primary unique*/ empcod  
                                   titnat  
                                   modcod  
                                   etbcod 
                                   clifor 
                                   titnum  
                                   titpar.

def {1} shared temp-table tp-tbprice like tbprice.

DEFINE {1} shared temp-table tp-campanha 
  FIELD acaocod      AS INTEGER     FORMAT ">>>>>>9" 
  FIELD clicod       AS INTEGER     FORMAT ">>>>>>>9" 
  FIELD crmcod       AS INTEGER     FORMAT ">>>>>>9" 
  FIELD etbcod       AS INTEGER     FORMAT ">>9"
  FIELD segmentacao  AS INTEGER     FORMAT ">>9"
  FIELD publico      AS INTEGER     FORMAT ">>9"
  FIELD perfil       AS INTEGER     FORMAT ">>9"
  FIELD departamento AS INTEGER     FORMAT ">>9"
  FIELD setor        AS INTEGER     FORMAT ">>9"
  FIELD produto      AS INTEGER     FORMAT ">>>>>9"
  FIELD apelo        AS INTEGER     FORMAT ">>9"
  FIELD canal        AS INTEGER     FORMAT ">>9"
  FIELD lucro_medio  AS DECIMAL     DECIMALS 2
  .

def {1} shared temp-table ttclitel
    field CliCod          as inte      format ">>>>>>99"
    field teldat          as date      format "99/99/9999"
    field telhor          as inte      format "->,>>>,>>9"
    field FunCod          as inte      format ">>>>>9"
    field telobs          as char      format "x(50)" extent 3
    field titcod          as inte      format "->,>>>,>>9"
    field titnum          as char      format "x(12)"
    field datac           as date      format "99/99/9999"
    field tiphis          as char      format "x(3)"
    field codcont         as inte      format ">9"
    field dtpagcont       as date      format "99/99/9999"
    field fonecont        as char      format "x(15)"
    field ndiascont       as inte      format ">>>9"
    field carta           as logi      format "Sim/Nao"
    field spc             as logi      format "Sim/Nao"
    field hrpagcont       as inte      format ">>>>>>9"
    field etbcod          as inte      format ">>>9"
    field empcod          as inte      format ">>9"
    field modcod          as char      format "x(5)"
    field titnat          as logi      format "yes/no"
    field titpar          as inte      format ">>9"
    field etbcobra        as inte      format ">>>9"
    field desccont        as            char       format "x(30)"
    index ttclitel   is unique primary CliCod asc  
                                 teldat asc 
                                 telhor asc.


def {1} shared temp-table tp-pro like produ.

def {1} shared temp-table tpb-pedid like pedid.
def {1} shared temp-table tpb-liped like liped.

def {1} shared temp-table tt-asstec
    field etbcod  as int  format ">>9"
    field oscod   as int  format ">>>>>>9"
    field procod  as int  format ">>>>>>>9"
    field clicod  as int  format ">>>>>>>>9"
    field plaetb  as int  format ">>9"
    field planum  as int  format ">>>>>>>9"
    field serie   as char format "x(8)"
    field apaser  as char format "x(20)"
    field proobs  as char format "x(60)"
    field defeito as char format "x(60)"
    field nftnum  as int  format ">>>>>>>9"
    field dtentdep as date format "99/99/9999"
    field dtenvass as date format "99/99/9999"
    field reincid as log format "Sim/Nao"
    field dtretass as date format "99/99/9999"    
    field dtenvfil as date format "99/99/9999"
    field osobs as char format "x(60)"
    field pladat as date format "99/99/9999"
    field forcod as int format ">>>>>9"
    field datexp as date format "99/99/9999".
 
def {1} shared temp-table tp-tbcartao like tbcartao.

def {1} shared temp-table tp-historico
        field clicod like clien.clicod
        field sal-aberto like clien.limcrd
        field lim-credito as dec
        field lim-calculado like clien.limcrd format "->>,>>9.99"
        field ult-compra like plani.pladat
        field qtd-contrato as int format ">>>9"
        field parcela-paga as int format ">>>>9"
        field parcela-aberta as int format ">>>>9"
        field qtd-15 as int format ">>>>9"
        field vtotal as dec
        field media-contrato as dec
        field qtd-45  as int format ">>>>9"
        field vqtd as dec
        field v-acum like clien.limcrd
        field v-mes as int format "99"
        field v-ano as int format "9999"
        field qtd-46 as int format ">>>>9"
    field pct-pago2 as dec
    field v-media like clien.limcrd
    field vrepar as log format "Sim/Nao"
    field proximo-mes  as dec
    field maior-atraso as date
    field vencidas like clien.limcrd
    field cheque_devolvido like plani.platot
    field pagas-posicli as int format ">>>>9". 

def {1} shared temp-table tp-contacor
    field valor as dec
    field confirma as char 
    field pct as dec
    field tipo as char
    field vldescont as dec.

DEFINE {1} shared temp-TABLE foraut 
  FIELD autlp  AS LOGICAL     FORMAT "Sim/Nao" INITIAL TRUE LABEL "LP"
  FIELD forcod AS INTEGER     FORMAT ">>>>>9" LABEL "Fornecedor"
  FIELD fornom AS CHARACTER   FORMAT "x(50)" LABEL "Nome"
  FIELD modcod AS CHARACTER   FORMAT "x(3)" LABEL "Modalidade"
  FIELD setcod AS INTEGER     FORMAT ">>9" LABEL "Setor".

    
/* temp-table para retornar se cliente esta no cyber */  
def {1} shared temp-table tp-cyber 
    field clicod    as int 
    field situacao  as log init no.
            
DEFINE {1} shared temp-table tp-novacordo  
  FIELD id_acordo       AS DECIMAL     DECIMALS 0
          FORMAT "99999999999999999999" LABEL "Acordo" COLUMN-LABEL "Acordo"
  FIELD Dtinclu         AS DATE        FORMAT "99/99/9999"
                          LABEL "Dtinclu" COLUMN-LABEL "Dtinclu"
  FIELD Dtrefer         AS DATE        FORMAT "99/99/9999"
                                  LABEL "Dtrefer" COLUMN-LABEL "Dtrefer"
  FIELD Dtvalidade      AS DATE        FORMAT "99/99/9999"
                                  LABEL "Validade" COLUMN-LABEL "Validade"
  FIELD Valor_ori       AS DECIMAL     DECIMALS 2
  FIELD Valor_acordo    AS DECIMAL     DECIMALS 2
  FIELD Valor_entrada   AS DECIMAL     DECIMALS 2
  FIELD Valor_liquido   AS DECIMAL     DECIMALS 2
  FIELD Qtd_parcelas    AS INTEGER     FORMAT ">>>>>9"
  FIELD user_inclusao   AS INTEGER
  FIELD user_alteracao  AS INTEGER
  FIELD user_efetivacao AS INTEGER
  FIELD DtAlteracao     AS DATE
  FIELD DtEfetivacao    AS DATE
  FIELD horinclu        AS INTEGER
  FIELD horalteracao    AS INTEGER
  FIELD horefetivacao   AS INTEGER
  FIELD char1           AS CHARACTER   FORMAT "x(60)"
  FIELD char2           AS CHARACTER   FORMAT "x(60)"
  FIELD clicod          AS INTEGER     FORMAT ">>>>>>>>>9" 
                LABEL "Codigo Cliente" COLUMN-LABEL "Cliente"
  FIELD situacao        AS CHARACTER   FORMAT "x(20)"
  FIELD contnum         AS INTEGER     FORMAT ">>>>>>>>>9" INITIAL ? 
                            LABEL "Contrato"
  FIELD etb_acordo      AS INTEGER     FORMAT ">>9"
  FIELD etb_efetiva     AS INTEGER     FORMAT ">>9"
  FIELD etb_altera      AS INTEGER     FORMAT ">>9"
  FIELD datexp          AS DATE        LABEL "Data Export" 
                        COLUMN-LABEL "Dt.Exp."
  FIELD exportado       AS LOGICAL     FORMAT "Sim/Nao" INITIAL TRUE
                              LABEL "Exp" COLUMN-LABEL "Exp"
  FIELD destino         AS INTEGER     FORMAT ">>9"
  FIELD tipnova         AS INTEGER     FORMAT ">>9"
  FIELD Motivo1         AS CHARACTER   FORMAT "x(80)"
  FIELD Motivo2         AS CHARACTER   FORMAT "x(80)"
  FIELD Motivo3         AS CHARACTER   FORMAT "x(80)"
  FIELD Motivo4         AS CHARACTER   FORMAT "x(80)"
  FIELD Motivo5         AS CHARACTER   FORMAT "x(80)"
  .

DEFINE {1} shared temp-table tp-segnumsorte 
  FIELD Certifi   AS CHARACTER   FORMAT "x(11)" LABEL "Certificado"
  FIELD contnum   AS INTEGER     FORMAT ">>>>>>>>999" LABEL "Contrato"
  FIELD DtFVig    AS DATE        LABEL "Vigencia" COLUMN-LABEL "Vig."
  FIELD DtIncl    AS DATE        INITIAL today LABEL "Inclusao"
  FIELD DtIVig    AS DATE        LABEL "Ini.Vigencia" COLUMN-LABEL "Ini.Vig."
  FIELD DtSorteio AS DATE        LABEL "Sorteio"
  FIELD DtUso     AS DATE        LABEL "Dt.Uso"
  FIELD etbcod    AS INTEGER     FORMAT ">>9" 
                LABEL "Estabelecimento" COLUMN-LA~BEL "Etb"
  FIELD HrUso     AS INTEGER     FORMAT ">,>>>,>>9" LABEL "Hora"
  FIELD NSorteio  AS INTEGER     FORMAT ">>>>9" LABEL "N.Sorte"
  FIELD PlaCod    AS INTEGER     FORMAT ">>>>>>>>>9" INITIAL ?
  FIELD Serie     AS INTEGER     FORMAT ">>9" COLUMN-LABEL "Ser"
  .
    
define {1} shared temp-table tt-descfunc
  field ciccgc            as char
  field tem_cadastro      as logical
  field tipo_funcionario  as logical
  field desc31            as decimal
  field desc41            as decimal.
    
define {1} shared temp-table tp-crediario
    field clicod          like clien.clicod
    field clientenovo     as log.

define {1} shared temp-table tp-atrdia
    field etbcod          as int
    field dias            as int.

DEFINE {1} shared temp-TABLE tp-tabparam
  FIELD tipo       AS CHARACTER
  FIELD grupo      AS INTEGER     FORMAT ">>9"
  field etbcod     as integer     format ">>9"
  FIELD parametro  AS CHARACTER   FORMAT "x(30)"
  FIELD valor      AS DECIMAL     DECIMALS 2
  FIELD percentual AS DECIMAL     DECIMALS 2
  FIELD string     AS CHARACTER
  FIELD bloqueio   AS LOGICAL     FORMAT "Sim/Nao" INITIAL TRUE
  FIELD condicao   AS CHARACTER
  FIELD dtinclu    AS DATE
  FIELD dtexp      AS DATE
  FIELD aplicacao  AS CHARACTER
  FIELD Datai      AS DATE
  FIELD Dataf      AS DATE
  .

