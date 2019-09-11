USE DS_HSDW_Prod

IF OBJECT_ID('tempdb..#yogapt ') IS NOT NULL
DROP TABLE #yogapt

SELECT dtes.MRN_int
      ,yoga.Appt_Dtm
	  ,yoga.Appt_Sts_Nme
	  ,yoga.Clrt_DEPt_Nme
	  ,yoga.Prc_Ext_Nme
      ,yoga.Prov_Nme
	  ,dtes.Appt_Date
INTO #yogapt
  FROM
(
SELECT pat.[MRN_int]
     , dte.Appt_Date
FROM
(
SELECT DISTINCT [MRN_int]
  FROM [DS_HSDW_Prod].[Rptg].[vwFact_Pt_Enc_Clrt] fact
  LEFT OUTER JOIN [DS_HSDW_Prod].[Rptg].vwDim_Clrt_Prc prc
  ON prc.sk_Dim_Clrt_Prc = fact.sk_Dim_Clrt_Prc
  LEFT OUTER JOIN [DS_HSDW_Prod].[Rptg].vwDim_Clrt_SERsrc ser
  ON ser.sk_Dim_Clrt_SERsrc = fact.sk_Dim_Clrt_SERsrc
  LEFT OUTER JOIN [DS_HSDW_Prod].[Rptg].vwDim_Clrt_Appt_Sts sts
  ON sts.sk_Dim_Clrt_Appt_Sts = fact.sk_Dim_Clrt_Appt_Sts
  --LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Clrt_DEPt dep
  --ON dep.sk_Dim_Clrt_DEPt = fact.sk_Dim_Clrt_DEPt
  WHERE prc.PRC_ID IN ('11700175','
11700220','
11702333','
11702334')
AND ser.Prov_Nme LIKE '%WAY%'
AND sts.sk_Dim_Clrt_Appt_Sts NOT IN (5,6)
) pat
CROSS JOIN
(
SELECT CAST(day_date AS DATE) AS Appt_Date
FROM DS_HSDW_Prod.Rptg.vwDim_Date
--WHERE date_key BETWEEN 20150101 AND 20200630
WHERE date_key BETWEEN 20170701 AND 20200630
) dte
) dtes
LEFT OUTER JOIN
(
SELECT fact.MRN_int
      ,fact.Appt_Dtm
	  ,sts.Appt_Sts_Nme
	  ,dep.Clrt_DEPt_Nme
	  ,prc.Prc_Ext_Nme
      ,ser.Prov_Nme
  FROM [DS_HSDW_Prod].[Rptg].[vwFact_Pt_Enc_Clrt] fact
  LEFT OUTER JOIN [DS_HSDW_Prod].[Rptg].vwDim_Clrt_Prc prc
  ON prc.sk_Dim_Clrt_Prc = fact.sk_Dim_Clrt_Prc
  LEFT OUTER JOIN [DS_HSDW_Prod].[Rptg].vwDim_Clrt_SERsrc ser
  ON ser.sk_Dim_Clrt_SERsrc = fact.sk_Dim_Clrt_SERsrc
  LEFT OUTER JOIN [DS_HSDW_Prod].[Rptg].vwDim_Clrt_Appt_Sts sts
  ON sts.sk_Dim_Clrt_Appt_Sts = fact.sk_Dim_Clrt_Appt_Sts
  LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Clrt_DEPt dep
  ON dep.sk_Dim_Clrt_DEPt = fact.sk_Dim_Clrt_DEPt
  WHERE prc.PRC_ID IN ('11700175','
11700220','
11702333','
11702334')
AND ser.Prov_Nme LIKE '%WAY%'
AND sts.sk_Dim_Clrt_Appt_Sts NOT IN (5,6)
) yoga
ON ((yoga.MRN_int = dtes.MRN_int)
AND (CAST(yoga.Appt_Dtm AS DATE) = dtes.Appt_Date))

SELECT *
FROM #yogapt
ORDER BY MRN_int
       , Appt_Date
