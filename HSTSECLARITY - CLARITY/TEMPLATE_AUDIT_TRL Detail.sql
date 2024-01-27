USE CLARITY

--SELECT aud.[DEPARTMENT_ID]
--      ,dep.DEPARTMENT_NAME
--	  ,c.clinical_area_name
--      ,aud.[AUDIT_DATETIME]
--      ,aud.[PROV_ID]
--	  ,ser.PROV_NAME
--      ,aud.[TMPLT_AUDIT_ACT_C]
--	  ,ztaa.NAME AS TMPLT_AUDIT_ACT_NAME
--	  ,ztaa.TITLE AS TMPLT_AUDIT_ACT_TITLE
--      ,aud.[USER_ID]
--	  ,emp.NAME AS [USER_Name]
--      ,aud.[TEMPLATE_BEG_DATE]
--      ,aud.[TEMPLATE_END_DATE]
--      ,aud.[DAY_OF_THE_WEEK_C]
--      ,aud.[AUDIT_DETAILS]
--  FROM [CLARITY].[dbo].[TEMPLATE_AUDIT_TRL] aud
--  LEFT OUTER JOIN dbo.CLARITY_DEP dep
--  ON dep.DEPARTMENT_ID = aud.DEPARTMENT_ID
--  LEFT JOIN [CLARITY_App].[Mapping].[Epic_Dept_Groupers] g ON aud.DEPARTMENT_ID = g.epic_department_id
--  LEFT JOIN [CLARITY_App].[Mapping].Ref_Clinical_Area_Map c on g.sk_Ref_Clinical_Area_Map = c.sk_Ref_Clinical_Area_Map
--  LEFT JOIN [CLARITY_App].[Mapping].Ref_Service_Map s on c.sk_Ref_Service_Map = s.sk_Ref_Service_Map
--  LEFT JOIN [CLARITY_App].[Mapping].Ref_Organization_Map o on s.organization_id = o.organization_id
--  LEFT OUTER JOIN dbo.CLARITY_SER ser
--  ON ser.PROV_ID = aud.PROV_ID
--  LEFT OUTER JOIN dbo.CLARITY_EMP emp
--  ON emp.USER_ID = aud.USER_ID
--  LEFT OUTER JOIN dbo.ZC_TMPLT_AUDIT_ACT ztaa
--  ON ztaa.TMPLT_AUDIT_ACT_C = aud.TMPLT_AUDIT_ACT_C
--  WHERE aud.AUDIT_DATETIME >= '7/1/2021 00:00 AM'
--  ORDER BY dep.DEPARTMENT_NAME, aud.AUDIT_DATETIME

  SELECT
	   c.clinical_area_name
	  ,aud.[DEPARTMENT_ID]
      ,dep.DEPARTMENT_NAME
	  ,aud.TMPLT_AUDIT_ACT_C
	  ,ztaa.TITLE AS TMPLT_AUDIT_ACT_TITLE
      ,COUNT(*) AS Action_Count
  FROM [CLARITY].[dbo].[TEMPLATE_AUDIT_TRL] aud
  LEFT OUTER JOIN dbo.CLARITY_DEP dep
  ON dep.DEPARTMENT_ID = aud.DEPARTMENT_ID
  LEFT JOIN [CLARITY_App].[Mapping].[Epic_Dept_Groupers] g ON aud.DEPARTMENT_ID = g.epic_department_id
  LEFT JOIN [CLARITY_App].[Mapping].Ref_Clinical_Area_Map c on g.sk_Ref_Clinical_Area_Map = c.sk_Ref_Clinical_Area_Map
  LEFT JOIN [CLARITY_App].[Mapping].Ref_Service_Map s on c.sk_Ref_Service_Map = s.sk_Ref_Service_Map
  LEFT JOIN [CLARITY_App].[Mapping].Ref_Organization_Map o on s.organization_id = o.organization_id
  --LEFT OUTER JOIN dbo.CLARITY_SER ser
  --ON ser.PROV_ID = aud.PROV_ID
  --LEFT OUTER JOIN dbo.CLARITY_EMP emp
  --ON emp.USER_ID = aud.USER_ID
  LEFT OUTER JOIN dbo.ZC_TMPLT_AUDIT_ACT ztaa
  ON ztaa.TMPLT_AUDIT_ACT_C = aud.TMPLT_AUDIT_ACT_C
  WHERE aud.AUDIT_DATETIME >= '7/1/2021 00:00 AM'
  GROUP BY 
	c.clinical_area_name
   ,aud.DEPARTMENT_ID
   ,dep.DEPARTMENT_NAME
   ,aud.TMPLT_AUDIT_ACT_C
   ,ztaa.TITLE
  ORDER BY 
	c.clinical_area_name
   ,aud.DEPARTMENT_ID
   ,dep.DEPARTMENT_NAME
   ,aud.TMPLT_AUDIT_ACT_C
   ,ztaa.TITLE