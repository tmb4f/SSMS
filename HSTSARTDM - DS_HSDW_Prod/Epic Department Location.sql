/****** Script for SelectTopNRows command from SSMS  ******/
SELECT DISTINCT
	   --[sk_Dim_Clrt_DEPt]
      --,[DEPARTMENT_ID]
       [DEPARTMENT_ID]							AS			Epic_Department_Id
      ,[Clrt_DEPt_Nme]								AS			Epic_Department_Name
      ,[Clrt_DEPt_Abbrv]							AS			Epic_Department_Abbrv
      ,[Clrt_DEPt_Spclty]							AS			Epic_Department_Specialty
      --,[Clrt_DEPt_Lic_Beds]
      ,[Clrt_DEPt_Ext_Nme]						AS			Epic_Department_Ext_Name
      ,[Clrt_DEPt_Phn_Num]						AS			Epic_Department_Phn_Num
      ,[Clrt_DEPt_Addr_Cty]						AS			Epic_Department_Addr_City
      ,[Clrt_DEPt_Addr_Zip]						AS			Epic_Department_Addr_Zip
      ,[Clrt_DEPt_Addr_St]						AS			Epic_Department_Addr_St
      ,[Clrt_DEPt_Loctn_Nme]					AS			Epic_Department_Loc_Name
      --,[Clrt_DEPt_Loctn_POS_typ]
      --,[Clrt_DEPt_Loctn_Abbrv]
      --,[SERV_AREA_ID]
      --,[Clrt_DEPt_Svc_Area_Nme]
      --,[Clrt_DEPt_Svc_Area_Abbrv]
      --,[Clrt_DEPt_Svc_Area_Typ]
      --,[BILLING_SYSTEM_C]
      --,[Clrt_DEPt_Billg_Nme]
      --,[Clrt_DEPt_Billg_Abbrv]
      --,[Rec_Sts]
      --,[Prov_Based_Clinic]
      --,[Updte_Dtm]
      --,[Load_Dte]
      --,[Reimb_340B_Eligible_Clinic]
      --,[Clrt_DEPt_Typ]
      --,[PBB_NonPBB]
      --,[MSPQ]
      ,[GL_Business_Unit]							AS			GL_Business_Unit
      --,[GL_Operating_Unit]
      --,[GL_Cde]
      --,[HUB]
      --,[POD]
      --,[DEPt_Rec_Sts]
      --,[ICU_Dept_YN]
      --,[Service_Line]
      --,[PG_Survey_Designator]
      ,dep.[Hospital_Code]							AS			Hospital_Code
	  ,mdm.HOSPITAL_CODE					AS			Hospital_Code_Name
      ,[Hospital_Name]								AS			Hospital_Name
	  --,mdm.DE_HOSPITAL_CODE
	  ,mdm.HOSPITAL_GROUP				AS			Hospital_Group
  FROM [DS_HSDW_Prod].[Rptg].[vwDim_Clrt_DEPt] dep
  LEFT OUTER JOIN Rptg.vwRef_MDM_Location_Master_Hospital_Group mdm
  ON mdm.EPIC_DEPARTMENT_ID = dep.DEPARTMENT_ID
  WHERE dep.DEPt_Rec_Sts = 'Active'
  AND dep.DEPARTMENT_ID > 8
  ORDER BY dep.DEPARTMENT_ID