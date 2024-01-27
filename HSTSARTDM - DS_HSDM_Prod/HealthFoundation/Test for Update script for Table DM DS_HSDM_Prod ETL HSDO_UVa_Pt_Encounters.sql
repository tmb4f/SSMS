USE DS_HSDM_Prod

SELECT *, SUBSTRING(Atn_Dr_LName,1,LEN(Atn_Dr_LName)-1) AS Atn_Dr_LName_New
FROM ETL.HSDO_UVa_Pt_Encounters
WHERE SUBSTRING(Atn_Dr_LName,LEN(Atn_Dr_LName),1) = ','
ORDER BY Atn_Dr_LName, Atn_Dr_FName, Atn_Dr_MI