/****** Script for SelectTopNRows command from SSMS  ******/
SELECT [EPIC_DEPARTMENT_ID]
      ,[EPIC_DEPT_NAME]
      ,[EPIC_EXT_NAME]
      ,[serviceline_division_flag]
      ,[serviceline_division_id]
      ,[serviceline_division_name]
      ,[mc_operation_flag]
      ,[mc_operation_id]
      ,[mc_operation_name]
      ,[post_acute_flag]
      ,[ambulatory_operation_flag]
      ,[ambulatory_operation_id]
      ,[ambulatory_operation_name]
      ,[inpatient_adult_flag]
      ,[inpatient_adult_id]
      ,[inpatient_adult_name]
      ,[childrens_flag]
      ,[childrens_id]
      ,[childrens_name]
      ,[Load_Dtm]
  FROM [CLARITY_App].[Rptg].[vwRef_MDM_Supplemental]
SELECT DISTINCT
       [inpatient_adult_name]
      ,[inpatient_adult_id]
  FROM [CLARITY_App].[Rptg].[vwRef_MDM_Supplemental]
  ORDER BY inpatient_adult_name
SELECT DISTINCT
       [childrens_name]
      ,[childrens_id]
  FROM [CLARITY_App].[Rptg].[vwRef_MDM_Supplemental]
  ORDER BY childrens_name
SELECT DISTINCT
       [mc_operation_name]
      ,[mc_operation_id]
  FROM [CLARITY_App].[Rptg].[vwRef_MDM_Supplemental]
  ORDER BY mc_operation_name
SELECT DISTINCT
       [ambulatory_operation_name]
      ,[ambulatory_operation_id]
  FROM [CLARITY_App].[Rptg].[vwRef_MDM_Supplemental]
  ORDER BY ambulatory_operation_name
SELECT DISTINCT
       [serviceline_division_name]
      ,[serviceline_division_id]
  FROM [CLARITY_App].[Rptg].[vwRef_MDM_Supplemental]
  ORDER BY serviceline_division_name