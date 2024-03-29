USE DS_HSDW_App_Dev

SELECT [SURVEY_ID]
      ,CASE WHEN pg.BARCODE IS NULL THEN 'N' ELSE 'Y' END AS PGDB
      ,[RECDATE]
      ,[ITCSN]
      ,[ITSERVTY]
      ,[CG_26CL]
      ,[O4]
--SELECT DISTINCT
--       [SURVEY_ID]
  FROM [Rptg].[PressGaney_Pivot_MD] pvt
  LEFT OUTER JOIN Rptg.MD2561data pg
  ON pg.BARCODE = pvt.SURVEY_ID
  WHERE pvt.CG_26CL IS NOT NULL -- 8763 rows
  AND pvt.CG_26CL = 'Yes, definitely' -- 8203 rows
  ORDER BY [RECDATE]
  --ORDER BY [SURVEY_ID]
 