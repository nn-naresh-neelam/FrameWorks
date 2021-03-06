SELECT RELATION||'=>'||RPAD(DM_COLUMN_NAME,40,' ')||
RPAD(DM_COLUMN_DATA_TYPE,24,' ')||
RPAD(CASE WHEN DM_COLUMN_NULL_TYPE='TRUE' THEN 'NOT NULL' ELSE '' END,10,' ')||','
AS TXT FROM
(
SELECT RELATION,ATTNAME,CASE WHEN CONTYPE='p' THEN 0 ELSE 1 END AS PKFK_SEQ,CONSEQ FROM _v_relation_keydata WHERE RELATION IN
(SELECT  DM_TABLE_NAME  FROM STG_DEV_AUTO_DM_DDL DL
WHERE NOT EXISTS ( SELECT 1 FROM STG_DEV_AUTO_PRD_DDL PR WHERE DL.DM_TABLE_NAME=PR.PRD_TABLE_NAME))
)SRC
INNER JOIN STG_DEV_AUTO_DM_DDL DM_DDL
ON SRC.RELATION=DM_DDL.DM_TABLE_NAME
AND SRC.ATTNAME=DM_DDL.DM_COLUMN_NAME
ORDER BY RELATION,PKFK_SEQ,CONSEQ