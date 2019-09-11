USE DS_HSDM_App

SELECT [sk_Data_Portal_Metrics_Master]
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
  WHERE mstr.Metric_ID IN (168,169)