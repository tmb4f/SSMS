/****** Script for SelectTopNRows command from SSMS  ******/
SELECT 
       vw.[sk_Dim_Pt]
      ,[Pt_FName_MI]
      ,[Pt_LName]
      ,[CURR_PT_ADDR1]
      ,[CURR_PT_ADDR2]
      ,[CURR_PT_CITY]
      ,[CURR_PT_STATE]
      ,[CURR_PT_ZIP]
	  ,dpat.Address_Line1
	  ,dpat.Addres_Line2
	  ,dpat.StateOrProvince
	  ,dpat.City
	  ,dpat.Country
	  ,[sk_Dim_Physcn]
	  ,[Adm_Dt]
      ,[Atn_Dr_Prov_Id]
      ,[Atn_Dr_SMS_Id]
      ,[Atn_Dr_LName]
      ,[Atn_Dr_FName]
      ,[Atn_Dr_MI]
      ,[Atn_Dr_Type]
      ,[Atn_Dr_Status]
      ,[Atn_Dr_Last_Update_Dt]
      ,[Source]
      ,[IO_Flag]
      ,vw.[Sex]
      ,[Birth_Dt]
      ,[Age]
      ,[Age_Group]
      ,[CURR_PT_PHONE]
      ,[GUAR_FNAME]
      ,[GUAR_MNANE]
      ,[GUAR_LNAME]
      ,[GUAR_ADDR1]
      ,[GUAR_ADDR2]
      ,[GUAR_CITY]
      ,[GUAR_STATE]
      ,[GUAR_ZIP]
      ,[GUAR_PHONE]
      ,[GUAR_TO_PT]
      ,[Status]
      ,[Load_Date_Time]
      ,[Email]
  FROM [DS_HSDM_Prod].[HSDO].[vwGPP_Encounters_New] vw
  LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Patient dpat
  ON dpat.sk_Dim_Pt = vw.sk_Dim_Pt
  WHERE vw.CURR_PT_STATE IS NULL
  ORDER BY vw.sk_Dim_Pt