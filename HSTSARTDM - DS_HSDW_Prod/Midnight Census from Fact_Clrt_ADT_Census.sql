USE DS_HSDW_Prod

IF OBJECT_ID('tempdb..#census') IS NOT NULL
DROP TABLE #census

IF OBJECT_ID('tempdb..#unique') IS NOT NULL
DROP TABLE #unique

SELECT [EVENT_ID]
      ,[PAT_ENC_CSN_ID]
      ,[sk_Fact_Pt_Enc_Clrt]
      ,census.[sk_Dim_Pt]
	  ,pt.MRN_int
      ,[HSP_ACCOUNT_ID]
      ,[AcctNbr_Clrt]
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
      ,census.[sk_Dim_Clrt_DEPt]
	  ,dep.DEPARTMENT_ID
	  ,dep.Clrt_DEPt_Nme
	  ,mdm.SERVICE_LINE
      ,[sk_Dim_Clrt_Rm]
      ,[sk_Dim_Clrt_Bed]
      ,[Envt_Sub_Nme]
      ,[Fr_Base_Cls]
      ,[To_Base_Cls]
      ,[Labor_Sts]
      ,[sk_Dim_AccountClass]
      ,[sk_Dim_HospitalService]
      ,[sk_Dim_Clrt_ADT_Evnt]
      ,[sk_ADT_Evnt_In]
      ,[sk_ADT_Evnt_Out]
      ,[Seq_Num_in_Enc]
      ,[Seq_Num_in_Bed_Min]
      ,[Admit]
      ,[Discharge]
      ,[Pt_Days]
      ,[Occ_Minutes]
      ,census.[Load_Dtm]
      ,census.[ETL_GUID]
      ,census.[UpDte_Dtm]
      ,[Cancelled]
      ,[sk_Dim_BedUnit]
      ,[First_IP_in_IP_YN]
      ,[TO_BASE_CLASS_C]
      ,[FROM_BASE_CLASS_C]

  INTO #census

  FROM [dbo].[Fact_Clrt_ADT_Census] census
  LEFT OUTER JOIN dbo.Dim_Clrt_DEPt dep
  ON census.sk_Dim_Clrt_DEPt = dep.sk_Dim_Clrt_DEPt
  LEFT OUTER JOIN dbo.Dim_Clrt_Pt pt
  ON pt.sk_Dim_Pt = census.sk_Dim_Pt
  LEFT OUTER JOIN dbo.Ref_MDM_Location_Master mdm
  ON mdm.EPIC_DEPARTMENT_ID = dep.DEPARTMENT_ID
  WHERE sk_Dim_Clrt_ADT_Evnt = 6
  --AND sk_ADT_In_Dte BETWEEN 20210424 AND 20210425
  AND sk_ADT_In_Dte >= 20230701
  --AND Fr_Base_Cls = 'IP'
  AND Cancelled = 0

  --SELECT *
  --FROM #census
  --WHERE AcctNbr_Clrt = 13008522918

  SELECT census.*
                ,ROW_NUMBER() OVER (PARTITION BY census.ADT_In_Dtm, census.AcctNbr_Clrt ORDER BY census.AcctNbr_Clrt) AS 'Seq'

  INTO #unique

  FROM #census census

  SELECT *
  FROM #unique
  WHERE Seq = 1
  ORDER BY ADT_In_Dtm, AcctNbr_Clrt, Seq
 /*
  SELECT 
         CAST(ADT_In_Dtm AS DATE) AS Effective_Date,
         AcctNbr_Clrt AS Account_Number,
         MRN_int AS MRN,
         DEPARTMENT_ID AS Department_Id,
         Clrt_DEPt_Nme AS Department_Name,
		 SERVICE_LINE AS Service_Line,
		 Fr_Base_Cls AS Patient_Class,
         PAT_ENC_CSN_ID AS CSN,
		 ADT_In_Dtm AS Event_Time--,
         --EVENT_ID,
         --sk_Fact_Pt_Enc_Clrt,
         --sk_Dim_Pt,
         --HSP_ACCOUNT_ID,
         --ADT_In_Dtm,
         --sk_ADT_In_Dte,
         --sk_ADT_In_Tm,
         --ADT_Out_Dtm,
         --sk_ADT_Out_Dte,
         --sk_ADT_Out_Tm,
         --Enter_Dtm,
         --sk_ADT_Enter_Dte,
         --sk_ADT_Enter_Tm,
         --Hsp_Adm_Event_Id,
         --Hsp_Dis_Event_Id,
         --Xfer_in_Event_Id,
         --Xfer_Out_Event_Id,
         --sk_Dim_Clrt_DEPt,
         --sk_Dim_Clrt_Rm,
         --sk_Dim_Clrt_Bed,
         --Envt_Sub_Nme,
         --Fr_Base_Cls,
         --To_Base_Cls,
         --Labor_Sts,
         --sk_Dim_AccountClass,
         --sk_Dim_HospitalService,
         --sk_Dim_Clrt_ADT_Evnt,
         --sk_ADT_Evnt_In,
         --sk_ADT_Evnt_Out,
         --Seq_Num_in_Enc,
         --Seq_Num_in_Bed_Min,
         --Admit,
         --Discharge,
         --Pt_Days,
         --Occ_Minutes,
         --Load_Dtm,
         --ETL_GUID,
         --UpDte_Dtm,
         --Cancelled,
         --sk_Dim_BedUnit,
         --First_IP_in_IP_YN,
         --TO_BASE_CLASS_C,
         --FROM_BASE_CLASS_C
  FROM #unique
  WHERE Seq = 1
  --ORDER BY sk_ADT_In_Dte
  --                  , sk_ADT_In_Tm
  ORDER BY Department_Name
                    , sk_ADT_In_Dte
                    , sk_ADT_In_Tm
*/

--SELECT DISTINCT
--	uniq.MRN_int
--FROM #unique uniq
--INNER JOIN
--(
--SELECT
--	*
--FROM [DS_HSDM_Prod].[Rptg].[ADT_TransferCenter_ExternalTransfers]
--WHERE EntryTime >= '7/1/2023'
--) tc
--ON uniq.MRN_int = CAST(tc.AdtPatientID AS INTEGER)
--ORDER BY uniq.MRN_int

SELECT DISTINCT
	--uniq.EVENT_ID,
    uniq.PAT_ENC_CSN_ID,
    uniq.ADT_In_Dtm,
	tc.AdmissionCSN,
    tc.Referring_Facility,
    tc.TransferType,
    tc.TransferTypeHx,
    tc.Disposition,
    --tc.Status,
    --tc.XTPlacementStatusName,
    --uniq.sk_Fact_Pt_Enc_Clrt,
    --uniq.sk_Dim_Pt,
    --uniq.MRN_int,
    --uniq.HSP_ACCOUNT_ID,
    --uniq.AcctNbr_Clrt,
    --uniq.sk_ADT_In_Dte,
    --uniq.sk_ADT_In_Tm,
    --uniq.ADT_Out_Dtm,
    --uniq.sk_ADT_Out_Dte,
    --uniq.sk_ADT_Out_Tm,
    --uniq.Enter_Dtm,
    --uniq.sk_ADT_Enter_Dte,
    --uniq.sk_ADT_Enter_Tm,
    --uniq.Hsp_Adm_Event_Id,
    --uniq.Hsp_Dis_Event_Id,
    --uniq.Xfer_in_Event_Id,
    --uniq.Xfer_Out_Event_Id,
    --uniq.sk_Dim_Clrt_DEPt,
    uniq.DEPARTMENT_ID,
    uniq.Clrt_DEPt_Nme--,
    --uniq.SERVICE_LINE,
    --uniq.sk_Dim_Clrt_Rm,
    --uniq.sk_Dim_Clrt_Bed,
    --uniq.Envt_Sub_Nme,
    --uniq.Fr_Base_Cls,
    --uniq.To_Base_Cls,
    --uniq.Labor_Sts,
    --uniq.sk_Dim_AccountClass,
    --uniq.sk_Dim_HospitalService,
    --uniq.sk_Dim_Clrt_ADT_Evnt,
    --uniq.sk_ADT_Evnt_In,
    --uniq.sk_ADT_Evnt_Out,
    --uniq.Seq_Num_in_Enc,
    --uniq.Seq_Num_in_Bed_Min,
    --uniq.Admit,
    --uniq.Discharge,
    --uniq.Pt_Days,
    --uniq.Occ_Minutes,
    --uniq.Load_Dtm,
    --uniq.ETL_GUID,
    --uniq.UpDte_Dtm,
    --uniq.Cancelled,
    --uniq.sk_Dim_BedUnit,
    --uniq.First_IP_in_IP_YN,
    --uniq.TO_BASE_CLASS_C,
    --uniq.FROM_BASE_CLASS_C,
    --uniq.Seq
FROM #unique uniq
LEFT JOIN
(
SELECT
	AdmissionCSN
   ,Referring_Facility
   ,TransferType
   ,TransferTypeHx
   ,Disposition
   ,Status
   ,XTPlacementStatusName
FROM [DS_HSDM_Prod].[Rptg].[ADT_TransferCenter_ExternalTransfers]
WHERE EntryTime >= '7/1/2023'
) tc
ON uniq.PAT_ENC_CSN_ID = tc.AdmissionCSN
WHERE uniq.Seq = 1
ORDER BY uniq.PAT_ENC_CSN_ID, uniq.ADT_In_Dtm
