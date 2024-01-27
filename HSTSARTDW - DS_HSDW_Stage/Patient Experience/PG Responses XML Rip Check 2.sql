USE DS_HSDW_Stage

IF OBJECT_ID('tempdb..#surveys ') IS NOT NULL
DROP TABLE #surveys

IF OBJECT_ID('tempdb..#surveys2 ') IS NOT NULL
DROP TABLE #surveys2

IF OBJECT_ID('tempdb..#depts ') IS NOT NULL
DROP TABLE #depts

IF OBJECT_ID('tempdb..#depts2 ') IS NOT NULL
DROP TABLE #depts2

IF OBJECT_ID('tempdb..#svcs ') IS NOT NULL
DROP TABLE #svcs

-----------------------------------------------------------------------------------------------------------------------------------
/*
SELECT *
  FROM [DS_HSDW_Stage].[PressGaney].[PG_Responses_xmlrip]
  WHERE VARNAME = 'ITCSN'
  --AND VALUE = '200046604471' -- Test
  --AND VALUE = '200047077082'
  AND VALUE IN
  (
 '200047077082'
,'200047994672'
,'200046731386'
,'200046906849'
,'200047462274'
,'200047862187'
,'200046871411'
,'200047831951'
,'200047889638'
,'200045657839'
,'200046573509'
,'200047639720'
,'200046534279'
,'200047522942'
,'200047039019'
,'200047573447'
,'200047878093'
,'200047138743'
,'200047162635'
,'200047953033'
,'200046616912'
,'200047136936'
,'200047189334'
)
*/
/*
  SELECT *
  FROM DS_HSDW_Prod.dbo.Fact_PressGaney_Responses
  WHERE Pat_Enc_CSN_Id IN
  (
 200047077082
,200047994672
,200046731386
,200046906849
,200047462274
,200047862187
,200046871411
,200047831951
,200047889638
,200045657839
,200046573509
,200047639720
,200046534279
,200047522942
,200047039019
,200047573447
,200047878093
,200047138743
,200047162635
,200047953033
,200046616912
,200047136936
,200047189334
)
*/
/*
SELECT *
  FROM [DS_HSDW_Stage].[PressGaney].[PG_Responses_xmlrip_OAS_CAHPS]
  WHERE VARNAME = 'ITCSN'
  --AND VALUE = '200046604471' -- Test
  --AND VALUE = '200047077082'
  AND VALUE IN
  (
 '200047077082'
,'200047994672'
,'200046731386'
,'200046906849'
,'200047462274'
,'200047862187'
,'200046871411'
,'200047831951'
,'200047889638'
,'200045657839'
,'200046573509'
,'200047639720'
,'200046534279'
,'200047522942'
,'200047039019'
,'200047573447'
,'200047878093'
,'200047138743'
,'200047162635'
,'200047953033'
,'200046616912'
,'200047136936'
,'200047189334'
)
*/
/*
SELECT *, sts.Appt_Sts_Nme, enct.Enc_Typ_Nme, dep.DEPARTMENT_ID, dep.Clrt_DEPt_Nme
  FROM [DS_HSDW_Prod].Rptg.vwFact_Pt_Enc_Clrt enc
  LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Clrt_Appt_Sts sts
  ON sts.sk_Dim_Clrt_Appt_Sts = enc.sk_Dim_Clrt_Appt_Sts
  LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Clrt_Enc_Typ enct
  ON enct.sk_Dim_Clrt_Enc_Typ = enc.sk_Dim_Clrt_Enc_Typ
  LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Clrt_DEPt dep
  ON dep.sk_Dim_Clrt_DEPt = enc.sk_Dim_Clrt_DEPt
  WHERE PAT_ENC_CSN_ID IN
  (
 200047077082
,200047994672
,200046731386
,200046906849
,200047462274
,200047862187
,200046871411
,200047831951
,200047889638
,200045657839
,200046573509
,200047639720
,200046534279
,200047522942
,200047039019
,200047573447
,200047878093
,200047138743
,200047162635
,200047953033
,200046616912
,200047136936
,200047189334
)
ORDER BY PAT_ENC_CSN_ID
*/
-----------------------------------------------------------------------------------------------------------------------------------

SELECT DISTINCT
       [SURVEY_ID]

  INTO #surveys

  --FROM [DS_HSDW_Stage].[PressGaney].[PG_Responses_xmlrip]
  FROM [DS_HSDW_Stage].[PressGaney].[PG_Responses_xmlrip_OAS_CAHPS]
  WHERE RECDATE >= '4/1/2023 00:00' AND RECDATE <= '4/30/2023 23:59'
  AND VARNAME = 'O4'
  AND VALUE IS NOT NULL

  --SELECT *
  --FROM #surveys
  --ORDER BY SURVEY_ID
/*
SELECT DISTINCT
       [SURVEY_ID]

  INTO #surveys2

  FROM [DS_HSDW_Stage].[PressGaney].[PG_Responses_xmlrip]
  WHERE RECDATE >= '3/1/2022 00:00' AND RECDATE <= '3/31/2022 23:59'
  AND VARNAME = 'O4PR'
  AND VALUE IS NOT NULL

  --SELECT *
  --FROM #surveys2
  --ORDER BY SURVEY_ID

SELECT DISTINCT
       [PG_Responses_xmlrip].[SURVEY_ID]

  INTO #depts

  FROM [DS_HSDW_Stage].[PressGaney].[PG_Responses_xmlrip]
  INNER JOIN #surveys ON #surveys.SURVEY_ID = PG_Responses_xmlrip.SURVEY_ID
  WHERE VARNAME = 'ITDEPT_I'
  AND VALUE IN ('10419011','10419014')
  ORDER BY [PG_Responses_xmlrip].SURVEY_ID

  --SELECT *
  --FROM #depts
  --ORDER BY SURVEY_ID

SELECT DISTINCT
       [PG_Responses_xmlrip].[SURVEY_ID]

  INTO #depts2

  FROM [DS_HSDW_Stage].[PressGaney].[PG_Responses_xmlrip]
  INNER JOIN #surveys2 ON #surveys2.SURVEY_ID = PG_Responses_xmlrip.SURVEY_ID
  WHERE VARNAME = 'ITDEPT_I'
  AND VALUE IN ('10419011','10419014')
  ORDER BY [PG_Responses_xmlrip].SURVEY_ID

  --SELECT *
  --FROM #depts2
  --ORDER BY SURVEY_ID

SELECT DISTINCT
       [PG_Responses_xmlrip].[SURVEY_ID]

  INTO #svcs

  FROM [DS_HSDW_Stage].[PressGaney].[PG_Responses_xmlrip]
  INNER JOIN #depts ON #depts.SURVEY_ID = PG_Responses_xmlrip.SURVEY_ID
  WHERE VARNAME = 'ITSERVTY'
  AND SUBSTRING(VALUE,1,2) = 'MD'
  ORDER BY [PG_Responses_xmlrip].SURVEY_ID

  --SELECT *
  --FROM #svcs
  --ORDER BY SURVEY_ID

  SELECT DISTINCT
         svcs.SURVEY_ID,
         RECDATE,
         DISDATE,
         ITCSN,
         ITDEPIDN,
         ITDEPT,
         ITDEPT_I,
         ITMD_NAM,
         ITMD_NO1,
         ITMD_NO2,
         ITMDNO,
         ITMEDREC,
         ITNPI,
         ITPAT_NA,
         ITPATNO,
         ITSERVTY,
         ITUNIT,
         O4
  FROM PressGaney.Pivot_MD pvt
  INNER JOIN #svcs svcs ON pvt.SURVEY_ID = svcs.SURVEY_ID
  ORDER BY svcs.SURVEY_ID
*/

SELECT 
       xmlrip.[SURVEY_ID]
      ,[CLIENT_ID]
      ,[SERVICE]
      ,[RECDATE]
      ,[DISDATE]
      ,[RESP_CAT]
      ,[VARNAME]
      ,[VALUE]
      ,[filename]
      ,[Load_Dtm]
  --FROM [DS_HSDW_Stage].[PressGaney].[PG_Responses_xmlrip] xmlrip
  FROM [DS_HSDW_Stage].[PressGaney].[PG_Responses_xmlrip_OAS_CAHPS] xmlrip
  INNER JOIN #surveys ON #surveys.SURVEY_ID = xmlrip.SURVEY_ID
  --WHERE VARNAME = 'ITSERVTY'
  --WHERE VARNAME IN ('F68','O15','O15PR','F3')
  --AND ITDEPT_I IN ('10419011','10419014')
  --AND SUBSTRING(ITSERVTY,1,2) = 'MD'
  --AND SUBSTRING(VALUE,1,2) IN ('MD','MT')
  --ORDER BY [PG_Responses_xmlrip].SURVEY_ID
  ORDER BY xmlrip.SERVICE, xmlrip.SURVEY_ID