USE DS_HSDW_Prod

if OBJECT_ID('tempdb..#adt') is not NULL
DROP TABLE #adt

SELECT [EVENT_ID]
      ,fact.[PAT_ENC_CSN_ID]
      ,fact.[sk_Fact_Pt_Enc_Clrt]
      ,fact.[sk_Dim_Pt]
      ,[HSP_ACCOUNT_ID]
      ,fact.[AcctNbr_Clrt]
	  ,hclrt.ADT_PATIENT_STAT
	  ,hclrt.ADMIT_CONF_STAT
      ,[ADT_In_Dtm]
      ,[sk_ADT_In_Dte]
      ,[sk_ADT_In_Tm]
      ,[ADT_Out_Dtm]
      ,[sk_ADT_Out_Dte]
      ,[sk_ADT_Out_Tm]
      ,[Enter_Dtm]
      ,[sk_ADT_Enter_Dte]
      ,[sk_ADT_Enter_Tm]
      ,[Hsp_Adm_Event_Id]
      ,[Hsp_Dis_Event_Id]
      ,[Xfer_in_Event_Id]
      ,[Xfer_Out_Event_Id]
      ,fact.[sk_Dim_Clrt_DEPt]
	  ,dep.DEPARTMENT_ID
	  ,dep.Clrt_DEPt_Nme
      ,fact.[sk_Dim_Clrt_Rm]
	  ,rm. Rm_Nme
	  ,rm.Room_Number
      ,fact.[sk_Dim_Clrt_Bed]
	  ,bed.Bed_Nme
      ,[Envt_Sub_Nme]
      ,[Fr_Base_Cls]
      ,[To_Base_Cls]
      ,[Labor_Sts]
      ,[sk_Dim_AccountClass]
      ,[sk_Dim_HospitalService]
      ,fact.[sk_Dim_Clrt_ADT_Evnt]
	  ,dim.EVENT_TYPE_C
	  ,dim.ADT_Evnt_Nme
      ,[sk_ADT_Evnt_In]
      ,[sk_ADT_Evnt_Out]
      ,[Seq_Num_in_Enc]
      ,[Seq_Num_in_Bed_Min]
      ,[Admit]
      ,[Discharge]
      ,[Pt_Days]
      ,[Occ_Minutes]
      ,fact.[Load_Dtm]
      ,[ETL_GUID]
      ,fact.[UpDte_Dtm]
      ,[Cancelled]
      ,[sk_Dim_BedUnit]
      ,[First_IP_in_IP_YN]
      ,[TO_BASE_CLASS_C]
      ,[FROM_BASE_CLASS_C]
  INTO #adt
  FROM [DS_HSDW_Prod].[dbo].[Fact_Clrt_ADT_Census] fact
  LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Clrt_ADT_Evnt dim
  ON dim.sk_Dim_Clrt_ADT_Evnt = fact.sk_Dim_Clrt_ADT_Evnt
  LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Clrt_DEPt dep
  ON dep.sk_Dim_Clrt_DEPt = fact.sk_Dim_Clrt_DEPt
  LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Clrt_Rm rm
  ON rm.sk_Dim_Clrt_Rm = fact.sk_Dim_Clrt_Rm
  LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Clrt_Bed bed
  ON bed.sk_Dim_Clrt_Bed = fact.sk_Dim_Clrt_Bed
  LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwFact_Pt_Enc_Hsp_Clrt AS hclrt WITH(NOLOCK)
  ON hclrt.sk_Fact_Pt_Enc_Clrt = fact.sk_Fact_Pt_Enc_Clrt
  INNER JOIN DS_HSDW_Prod.Rptg.vwFact_Pt_Enc_Clrt AS clrt WITH(NOLOCK)
  ON hclrt.sk_Fact_Pt_Enc_Clrt = clrt.sk_Fact_Pt_Enc_Clrt
  WHERE dim.ADT_Evnt_Nme <> 'Patient Update'
  AND dim.EVENT_TYPE_C = 6 -- Census
  AND dep.Clrt_DEPt_Nme LIKE 'TCIR%'
  AND CAST(fact.ADT_In_Dtm AS DATE) BETWEEN '7/1/2021' AND '6/30/2022'
  AND fact.Cancelled = 0
  --ORDER BY dep.Clrt_DEPt_Nme, fact.sk_ADT_In_Dte

SELECT 
	*
	--DEPARTMENT_ID,
	--Clrt_DEPt_Nme,
	--ADT_In_Dtm,
	--PAT_ENC_CSN_ID
FROM #adt
ORDER BY
	DEPARTMENT_ID,
	Clrt_DEPt_Nme,
	CAST(ADT_In_Dtm AS DATE),
	PAT_ENC_CSN_ID

SELECT
	DEPARTMENT_ID,
	Clrt_DEPt_Nme AS DEPARTMENT_NAME,
	CAST(ADT_In_Dtm AS DATE) AS Event_Date,
	COUNT(*) AS Midnight_Census
FROM #adt
GROUP BY
	DEPARTMENT_ID,
	Clrt_DEPt_Nme,
	CAST(ADT_In_Dtm AS DATE)
ORDER BY
	DEPARTMENT_ID,
	Clrt_DEPt_Nme,
	CAST(ADT_In_Dtm AS DATE)