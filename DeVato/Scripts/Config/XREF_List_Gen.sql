SELECT  DISTINCT DM_TABLE_NAME  FROM STG_DEV_AUTO_DM_DDL DL
WHERE NOT EXISTS ( SELECT 1 FROM STG_DEV_AUTO_PRD_DDL PR WHERE DL.DM_TABLE_NAME=PR.PRD_TABLE_NAME)