USE DS_HSDW_Prod

--DECLARE @Yoga TABLE (MRN_int INTEGER, sk_Cont_Dte INTEGER, PROV_ID VARCHAR(18), Prov_Nme VARCHAR(200), DX_NAME VARCHAR(200))
DECLARE @Yoga TABLE (MRN_int INTEGER)
--DECLARE @Yoga TABLE (EDG_Dx_Grp VARCHAR(200), DX_NAME VARCHAR(200))

INSERT INTO @Yoga
(
    MRN_int
   --,sk_Cont_Dte
   --,PROV_ID
   --,Prov_Nme
   --,DX_NAME
   -- EDG_Dx_Grp
   --,DX_NAME
)
--SELECT DISTINCT fact.[MRN_int], fact.sk_Cont_Dte, ser.PROV_ID, ser.Prov_Nme, DIAG.DX_NAME
SELECT DISTINCT fact.[MRN_int]
--SELECT DISTINCT EDG_Dx_Grp, DIAG.DX_NAME
  FROM [DS_HSDW_Prod].[Rptg].[vwFact_Pt_Enc_Clrt] fact
  LEFT OUTER JOIN [DS_HSDW_Prod].[Rptg].vwDim_Clrt_Prc prc
  ON prc.sk_Dim_Clrt_Prc = fact.sk_Dim_Clrt_Prc
  LEFT OUTER JOIN [DS_HSDW_Prod].[Rptg].vwDim_Clrt_SERsrc ser
  ON ser.sk_Dim_Clrt_SERsrc = fact.sk_Dim_Clrt_SERsrc
  LEFT OUTER JOIN [DS_HSDW_Prod].[Rptg].vwDim_Clrt_Appt_Sts sts
  ON sts.sk_Dim_Clrt_Appt_Sts = fact.sk_Dim_Clrt_Appt_Sts
  --LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Clrt_DEPt dep
  --ON dep.sk_Dim_Clrt_DEPt = fact.sk_Dim_Clrt_DEPt
  LEFT OUTER JOIN [DS_HSDW_Prod].[Rptg].[vwFact_Pt_Prblm_List] PROB
  ON PROB.sk_Fact_Pt_Enc_Clrt = fact.sk_Fact_Pt_Enc_Clrt
  LEFT OUTER JOIN [DS_HSDW_Prod].[Rptg].[vwDim_Clrt_EDiaGnosis] DIAG
  ON PROB.sk_dim_Clrt_EDiagnosis = DIAG.sk_dim_Clrt_EDiagnosis
  LEFT OUTER JOIN [DS_HSDW_Prod].[Rptg].[vwDim_Clrt_EDiaGnosis_List_Split] DIAG2
  ON DIAG.sk_dim_Clrt_EDiagnosis = DIAG2.sk_dim_Clrt_EDiagnosis
  WHERE prc.PRC_ID IN ('11700175','
11700220','
11702333','
11702334')
--AND ser.Prov_Nme LIKE '%WAY%'
AND ser.PROV_ID = '28885'
AND sts.sk_Dim_Clrt_Appt_Sts NOT IN (5,6)
--AND PROB.prblm_sts = 'Active'
AND fact.Appt_Dtm BETWEEN '7/1/2017 00:00 AM' AND '6/30/2020 11:59 PM'
--  WHERE ser.PROV_ID = '28885'
--AND sts.sk_Dim_Clrt_Appt_Sts NOT IN (5,6)

--SELECT *
--FROM @Yoga
----ORDER BY MRN_int, sk_Cont_Dte, DX_NAME
--ORDER BY MRN_int
----ORDER BY EDG_Dx_Grp, DX_NAME

--SELECT DISTINCT fact.[MRN_int]
--  FROM [DS_HSDW_Prod].[Rptg].[vwFact_Pt_Enc_Clrt] fact
--  LEFT OUTER JOIN [DS_HSDW_Prod].[Rptg].vwDim_Clrt_Prc prc
--  ON prc.sk_Dim_Clrt_Prc = fact.sk_Dim_Clrt_Prc
--  LEFT OUTER JOIN [DS_HSDW_Prod].[Rptg].vwDim_Clrt_SERsrc ser
--  ON ser.sk_Dim_Clrt_SERsrc = fact.sk_Dim_Clrt_SERsrc
--  LEFT OUTER JOIN [DS_HSDW_Prod].[Rptg].vwDim_Clrt_Appt_Sts sts
--  ON sts.sk_Dim_Clrt_Appt_Sts = fact.sk_Dim_Clrt_Appt_Sts
--  --LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Clrt_DEPt dep
--  --ON dep.sk_Dim_Clrt_DEPt = fact.sk_Dim_Clrt_DEPt
--  LEFT OUTER JOIN @Yoga y
--  ON y.MRN_int = fact.MRN_int
--  --WHERE ser.Prov_Nme LIKE '%WAY%'
--  WHERE ser.PROV_ID = '28885'
--AND sts.sk_Dim_Clrt_Appt_Sts NOT IN (5,6)
--AND fact.Appt_Dtm BETWEEN '7/1/2017 00:00 AM' AND '6/30/2020 11:59 PM'
--AND y.MRN_int IS NULL
/*10758*/
/*1096*/

SELECT dtes.MRN_int
      ,yoga.Appt_Dtm
	  ,yoga.Appt_Sts_Nme
	  ,yoga.Clrt_DEPt_Nme
	  ,yoga.Prc_Ext_Nme
      ,yoga.Prov_Nme
	  ,dtes.Appt_Date
  FROM
(
SELECT pat.[MRN_int]
     , dte.Appt_Date
FROM
(
SELECT DISTINCT fact.[MRN_int]
  FROM [DS_HSDW_Prod].[Rptg].[vwFact_Pt_Enc_Clrt] fact
  LEFT OUTER JOIN [DS_HSDW_Prod].[Rptg].vwDim_Clrt_Prc prc
  ON prc.sk_Dim_Clrt_Prc = fact.sk_Dim_Clrt_Prc
  LEFT OUTER JOIN [DS_HSDW_Prod].[Rptg].vwDim_Clrt_SERsrc ser
  ON ser.sk_Dim_Clrt_SERsrc = fact.sk_Dim_Clrt_SERsrc
  LEFT OUTER JOIN [DS_HSDW_Prod].[Rptg].vwDim_Clrt_Appt_Sts sts
  ON sts.sk_Dim_Clrt_Appt_Sts = fact.sk_Dim_Clrt_Appt_Sts
  --LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Clrt_DEPt dep
  --ON dep.sk_Dim_Clrt_DEPt = fact.sk_Dim_Clrt_DEPt
  LEFT OUTER JOIN @Yoga y
  ON y.MRN_int = fact.MRN_int
  --WHERE ser.Prov_Nme LIKE '%WAY%'
  WHERE ser.PROV_ID = '28885'
AND sts.sk_Dim_Clrt_Appt_Sts NOT IN (5,6)
AND fact.Appt_Dtm BETWEEN '7/1/2017 00:00 AM' AND '6/30/2020 11:59 PM'
AND y.MRN_int IS NULL
--AND fact.MRN_int = 10758
) pat
CROSS JOIN
(
SELECT CAST(day_date AS DATE) AS Appt_Date
FROM DS_HSDW_Prod.Rptg.vwDim_Date
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
  LEFT OUTER JOIN @Yoga y
  ON y.MRN_int = fact.MRN_int
  --WHERE ser.Prov_Nme LIKE '%WAY%'
  WHERE ser.PROV_ID = '28885'
AND sts.sk_Dim_Clrt_Appt_Sts NOT IN (5,6)
AND fact.Appt_Dtm BETWEEN '7/1/2017 00:00 AM' AND '6/30/2020 11:59 PM'
AND y.MRN_int IS NULL
--AND fact.MRN_int = 10758
) yoga
ON ((yoga.MRN_int = dtes.MRN_int)
AND (CAST(yoga.Appt_Dtm AS DATE) = dtes.Appt_Date))
ORDER BY dtes.MRN_int
       , yoga.Appt_Dtm DESC
       , dtes.Appt_Date
	   , yoga.Appt_Sts_Nme
	   , yoga.Clrt_DEPt_Nme
