USE DS_HSDW_Prod

SELECT DISTINCT
	   dphys.[sk_Dim_Physcn]
	  ,dphys.DisplayName
      ,[IDNumber]
      ,[current_flag]
      ,[Staff_checksum]
      ,[lastupdate] AS dphys_lastupdate
      ,[Status] AS dphys_Status
	  ,dser.PROV_ID
	  ,dser.Updte_Dtm AS dser_Updte_Dtm
	  ,dser.Active_Status AS dser_Active_Status
  FROM [DS_HSDW_Prod].[dbo].[Dim_Physcn] dphys
  INNER JOIN DS_HSDW_Prod.dbo.Dim_Clrt_SERsrc dser
  ON dser.sk_Dim_Physcn = dphys.sk_Dim_Physcn
  WHERE dphys.current_flag = 1
  AND (dphys.Status = 'Resigned' AND dser.Active_Status = 'Active')
  AND dphys.sk_Dim_Physcn > 0