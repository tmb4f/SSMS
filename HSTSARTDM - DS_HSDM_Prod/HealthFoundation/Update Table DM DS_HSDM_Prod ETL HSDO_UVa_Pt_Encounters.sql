USE DS_HSDM_Prod

UPDATE [ETL].[HSDO_UVa_Pt_Encounters]
SET Atn_Dr_LName = SUBSTRING(Atn_Dr_LName,1,LEN(Atn_Dr_LName)-1)
WHERE SUBSTRING(Atn_Dr_LName,LEN(Atn_Dr_LName),1) = ','