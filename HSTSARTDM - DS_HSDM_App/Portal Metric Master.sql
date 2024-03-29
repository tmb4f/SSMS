USE DS_HSDM_App

SELECT mstr.[sk_Data_Portal_Metrics_Master]
      ,[Metric_ID]
      ,[Metric_Name]
      ,[Metric_Sub_Name]
      ,[Data_Portal]
      ,[Data_Portal_Subgroup]
      ,mstr.[Load_Dtm]
      ,mstr.[sk_Data_Portal_Object_Lineage]
      ,[Dev_Tableau_Workbook]
      ,[Production_Tableau_Workbook]
      ,[Tabcmd_Batch_File_Name]
      ,[Reporting_Period_Enddate]
	  ,lin.Stored_Proc_Name
	  ,lin.Stage_Table_Name
	  ,lin.TabRptg_Table_Name
  FROM [ETL].[Data_Portal_Metrics_Master] mstr
  LEFT OUTER JOIN ETL.Data_Portal_Object_Lineage lin
  ON lin.sk_Data_Portal_Object_Lineage = mstr.sk_Data_Portal_Object_Lineage
  --WHERE mstr.sk_Data_Portal_Metrics_Master = 10
  --WHERE mstr.Metric_ID IN (268,270,272,273,276,277)
  --WHERE mstr.Metric_ID IN (18,19,20,418)
  --WHERE mstr.Metric_ID = 530
  --WHERE mstr.Metric_ID IN (276,379)
  --WHERE mstr.Data_Portal_Subgroup = 'Patient Experience'
  --WHERE lin.Stored_Proc_Name LIKE '%AmbOpt%'
  --WHERE lin.Stored_Proc_Name LIKE '%CAHP%'
  --WHERE lin.Stored_Proc_Name LIKE '%BeSafe%'
  --WHERE lin.Stored_Proc_Name LIKE '%Telemed%'
  --WHERE mstr.Production_Tableau_Workbook LIKE '%Transfer%'
  --WHERE lin.Stored_Proc_Name LIKE '%Sat%'
  --OR lin.Stored_Proc_Name LIKE '%Stat%'
  --OR lin.Stored_Proc_Name LIKE '%Press%'
  --OR lin.Stored_Proc_Name LIKE '%CAHP%'
  --WHERE lin.TabRptg_Table_Name LIKE '%Env%'
  --WHERE lin.TabRptg_Table_Name LIKE '%Emergency%'
  WHERE lin.TabRptg_Table_Name LIKE '%LOS%'
  --WHERE lin.TabRptg_Table_Name LIKE '%Transport%'
  --ORDER BY lin.Stored_Proc_Name
  --ORDER BY [sk_Data_Portal_Metrics_Master]
  --ORDER BY [mstr].[Production_Tableau_Workbook]
  ORDER BY [mstr].[Metric_ID]