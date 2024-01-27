/****** Script for SelectTopNRows command from SSMS  ******/
SELECT
       mdmhg.HOSPITAL_GROUP
	  ,mdmhg.HOSPITAL_CODE
      ,c.clinical_area_name
      ,[DEPARTMENT_ID]
      ,[DEPARTMENT_NAME]
      --,[SLOT_BEGIN_TIME]
      --,[SLOT_DATE]
      --,[SLOT_HOUR]
      --,[PROV_ID]
      --,[PROV_NM_WID]
      --,[APPT_NUMBER]
      --,[DEPT_SPECIALTY_C]
      --,[DEPT_SPECIALTY_NAME]
      --,[CENTER_C]
      --,[CENTER_NAME]
      --,[LOC_ID]
      --,[LOC_NAME]
      --,[SERV_AREA_ID]
      --,[SERV_AREA_NAME]
      --,[PROV_SCHED_TYPE_NAME]
      --,[PAT_ID]
      --,[NUM_APTS_SCHEDULED]
      --,[ORG_REG_OPENINGS]
      --,[ORG_OVBK_OPENINGS]
      --,[SLOT_LENGTH]
      ,avail.[UNAVAILABLE_RSN_C]
      --,[UNAVAILABLE_RSN_NAME]
	  ,zur.NAME AS UNAVAILABLE_RSN_NAME
      --,[PRIVATE_YN]
      --,[APPT_OVERBOOK_YN]
      --,[APPT_BLOCK_C]
      --,[APPT_BLOCK_NAME]
      --,[APPT_PRC_ID]
      --,[APPT_PRC_NAME]
      --,[PAT_ENC_CSN_ID]
      --,[DAY_UNAVAIL_YN]
      --,[DAY_UNAVAIL_RSN_C]
      --,[DAY_UNAVAIL_RSN_NAME]
      --,[TIME_UNAVAIL_YN]
      --,[TIME_UNAVAIL_RSN_C]
      --,[DAY_HELD_RSN_NAME]
      --,[TIME_HELD_YN]
      --,[TIME_HELD_RSN_C]
      --,[TIME_HELD_RSN_NAME]
      --,[OUTSIDE_TEMPLATE_YN]
      --,[SLOT_END_TIME]
      --,[CM_PHY_OWNER_ID]
      --,[CM_LOG_OWNER_ID]
	  ,COUNT(*) AS UNAVAILABLE_RSN_COUNT
  FROM [CLARITY].[dbo].[V_AVAILABILITY] avail
  LEFT OUTER  JOIN CLARITY.dbo.ZC_UNAVAIL_REASON zur
  ON zur.UNAVAILABLE_RSN_C = avail.UNAVAILABLE_RSN_C
  LEFT JOIN [CLARITY_App].[Mapping].[Epic_Dept_Groupers] g ON avail.DEPARTMENT_ID = g.epic_department_id
  LEFT JOIN [CLARITY_App].[Mapping].Ref_Clinical_Area_Map c on g.sk_Ref_Clinical_Area_Map = c.sk_Ref_Clinical_Area_Map
  LEFT JOIN [CLARITY_App].[Mapping].Ref_Service_Map s on c.sk_Ref_Service_Map = s.sk_Ref_Service_Map
  LEFT JOIN [CLARITY_App].[Mapping].Ref_Organization_Map o on s.organization_id = o.organization_id
  LEFT JOIN [CLARITY_App].Rptg.vwRef_MDM_Location_Master_Hospital_Group mdmhg ON mdmhg.EPIC_DEPARTMENT_ID = avail.DEPARTMENT_ID
  --WHERE
  --SLOT_DATE >= '7/1/2021 00:00 AM'
  --AND TIME_UNAVAIL_YN <> 'N'
  --AND c.clinical_area_name IS NOT NULL
  WHERE
  SLOT_DATE >= '11/1/2022 00:00 AM'
  AND SLOT_DATE < '1/1/2023 00:00 AM'
  AND TIME_UNAVAIL_YN <> 'N'
  AND mdmhg.HOSPITAL_GROUP = 'UVA-CH'
  GROUP BY 
    mdmhg.HOSPITAL_GROUP
   ,mdmhg.HOSPITAL_CODE
   ,c.clinical_area_name
   ,avail.DEPARTMENT_ID
   ,avail.DEPARTMENT_NAME
   ,avail.UNAVAILABLE_RSN_C
   ,zur.NAME
  ORDER BY
    mdmhg.HOSPITAL_GROUP
   ,mdmhg.HOSPITAL_CODE
   ,c.clinical_area_name
   ,avail.DEPARTMENT_ID
   ,avail.DEPARTMENT_NAME
   ,avail.UNAVAILABLE_RSN_C
   ,zur.NAME