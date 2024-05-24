
DEFINE {1} SHARED TEMP-TABLE ttimei NO-UNDO SERIALIZE-NAME "imei"
    field codigoImei as char
    field tstatus as char serialize-name "status"
    field ultimoLocalRastreado as char.

define {1} shared temp-table ttretornoimei serialize-name "statusRetorno"
    field tstatus   as char serialize-name "status"
    field descricao as char
    .
    
