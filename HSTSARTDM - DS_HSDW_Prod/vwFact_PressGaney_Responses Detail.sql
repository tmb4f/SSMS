--USE DS_HSDM_App

IF OBJECT_ID('tempdb..#resp ') IS NOT NULL
DROP TABLE #resp

SELECT [SURVEY_ID]
      ,[DISDATE]
      ,[RECDATE]
      ,[sk_Rec_Dte]
      ,resp.[sk_Dim_PG_Question]
	  ,qust.QUESTION_TEXT
	  ,attr.DOMAIN
	  ,qust.VARNAME
	  ,qust.Svc_Cde AS qust_Svc_Cde
      ,[sk_Fact_Pt_Acct]
      ,[FY]
      ,[sk_Dim_Pt]
      ,[PG_AcctNbr]
      ,resp.[Svc_Cde] AS resp_Svc_Cde
      ,resp.[RESP_CAT]
      ,[VALUE]
      ,[Dim_RSS_Group_sk]
      ,[Dim_RSS_Location_sk]
      ,[sk_Dim_Physcn]
      ,resp.[Load_Dtm]
      ,resp.[sk_Dim_Clrt_DEPt]
	  ,dep.DEPARTMENT_ID
	  ,dep.Clrt_DEPt_Nme
	  ,mdmhgr.HOSPITAL_CODE
      ,[Survey_Designator]
	  ,resp.Pat_Enc_CSN_Id
  INTO #resp
  FROM [DS_HSDW_Prod].[Rptg].[vwFact_PressGaney_Responses] resp
  LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Clrt_DEPt dep
  ON dep.sk_Dim_Clrt_DEPt = resp.sk_Dim_Clrt_DEPt
  LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_PG_Question qust
  ON qust.sk_Dim_PG_Question = resp.sk_Dim_PG_Question
  LEFT OUTER JOIN DS_HSDW_App.Rptg.PG_Extnd_Attr attr
  ON attr.sk_Dim_PG_Question = resp.sk_Dim_PG_Question
  LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwRef_MDM_Location_Master_Hospital_Group mdmhgr
  ON mdmhgr.EPIC_DEPARTMENT_ID = dep.DEPARTMENT_ID
  WHERE resp.RESP_CAT = 'ANALYSIS'
  --AND dep.DEPARTMENT_ID = 10217004
  --AND dep.DEPARTMENT_ID = 10341010
  --AND resp.Svc_Cde = 'AS'
  --AND resp.Svc_Cde = 'OU'
  AND resp.Svc_Cde = 'MD'
  --AND resp.Svc_Cde = 'IN'
  --WHERE resp.Svc_Cde = 'ER'
  --WHERE resp.Svc_Cde = 'PD'
  --WHERE resp.Svc_Cde IN ('DS','MD','OY')
  --WHERE resp.Svc_Cde IN ('DS','OY')
  --WHERE resp.Svc_Cde IN ('ER','IN')
  --WHERE resp.Svc_Cde IN ('OU')
  --AND qust.QUESTION_TEXT LIKE '%staff worked%'
  AND resp.sk_Dim_PG_Question = '1333'
  --AND resp. sk_Dim_PG_Question IN (2720, 2733)
  AND resp.sk_Rec_Dte BETWEEN 20231201 AND 20231231
  --AND resp.sk_Rec_Dte >= 20220701
  --AND dep.DEPARTMENT_ID = 10369022
  --WHERE resp.sk_Rec_Dte >= 20221001
  --AND qust.QUESTION_TEXT LIKE '%worked%'
  --WHERE resp. sk_Dim_PG_Question IN (2720, 2733)
  --ORDER BY qust.QUESTION_TEXT, resp.sk_Rec_Dte, resp.SURVEY_ID
  --ORDER BY resp.DISDATE, resp.sk_Rec_Dte, qust.QUESTION_TEXT, resp.SURVEY_ID
  --ORDER BY qust.VARNAME, resp.sk_Rec_Dte, resp.DISDATE, resp.SURVEY_ID, qust.QUESTION_TEXT

  --SELECT *
  SELECT DISTINCT
	
  --SELECT DISTINCT
		--SURVEY_ID
	 --  ,DISDATE
	 --  ,RECDATE
	 --  ,Pat_Enc_CSN_Id
	 --  ,sk_Dim_PG_Question
	 --  ,QUESTION_TEXT
 -- SELECT DISTINCT
	--sk_Rec_Dte
 --  ,resp_Svc_Cde
 --   --resp_Svc_Cde
 --  ,sk_Dim_Clrt_DEPt
 --  ,Clrt_DEPt_Nme
 --  ,HOSPITAL_CODE
 --  ,VARNAME
 --  ,sk_Dim_PG_Question
 --  ,QUESTION_TEXT
 --  ,DOMAIN
 -- SELECT DISTINCT
	--resp_Svc_Cde
 --  ,RESP_CAT
 --  ,DOMAIN
 --  ,QUESTION_TEXT
 --  ,sk_Dim_PG_Question
 --  ,VARNAME
  FROM #resp
  --WHERE sk_Dim_Clrt_DEPt <> 0
  --WHERE DOMAIN LIKE '%Medicines'
  --ORDER BY DOMAIN, sk_Rec_Dte
  --ORDER BY resp_Svc_Cde, DOMAIN, sk_Rec_Dte
  --ORDER BY resp_Svc_Cde, RESP_CAT, DOMAIN, QUESTION_TEXT
  --ORDER BY VARNAME, resp_Svc_Cde, sk_Rec_Dte, DOMAIN, QUESTION_TEXT
  --ORDER BY QUESTION_TEXT, Clrt_DEPt_Nme--, sk_Rec_Dte
  --ORDER BY HOSPITAL_CODE, Clrt_DEPt_Nme, QUESTION_TEXT --, sk_Rec_Dte
  --ORDER BY HOSPITAL_CODE, Clrt_DEPt_Nme, sk_Rec_Dte, QUESTION_TEXT
  --ORDER BY DISDATE, RECDATE, SURVEY_ID, QUESTION_TEXT
  ORDER BY DEPARTMENT_ID, RECDATE, SURVEY_ID, QUESTION_TEXT

--SELECT DISTINCT
--       [SURVEY_ID]
--  FROM [DS_HSDW_Prod].[Rptg].[vwFact_PressGaney_Responses] resp
--  LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Clrt_DEPt dep
--  ON dep.sk_Dim_Clrt_DEPt = resp.sk_Dim_Clrt_DEPt
--  LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_PG_Question qust
--  ON qust.sk_Dim_PG_Question = resp.sk_Dim_PG_Question
--  WHERE resp.RESP_CAT = 'ANALYSIS'
--  --AND dep.DEPARTMENT_ID = 10217004
--  --AND dep.DEPARTMENT_ID = 10341010
--  --AND resp.Svc_Cde = 'AS'
--  --AND resp.Svc_Cde = 'OU'
--  AND resp.Svc_Cde = 'MD'
--  AND qust.QUESTION_TEXT LIKE '%likelihood%'
--  --AND qust.QUESTION_TEXT LIKE '%facility%'
--  AND resp.sk_Rec_Dte BETWEEN 20190701 AND 20220630
--  --ORDER BY qust.QUESTION_TEXT, resp.sk_Rec_Dte, resp.SURVEY_ID
--  --ORDER BY resp.DISDATE, resp.sk_Rec_Dte, qust.QUESTION_TEXT, resp.SURVEY_ID
--  ORDER BY resp.SURVEY_ID