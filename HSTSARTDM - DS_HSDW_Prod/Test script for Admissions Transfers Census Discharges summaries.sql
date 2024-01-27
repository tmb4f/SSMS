USE DS_HSDW_Prod
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************************************
Script for generating the ADT event detail needed for calculating the average daily
inpatient admission, transfer, census, and discharge count for a set of target departments
over a specific date range.  Counts are grouped by event category, and COVID indicator and
Care Unit type (Acute, IMU, ICU).

Reportable event categories: Daily Census, OR/IR Admissions, ED Admissions,
                             Other Admissions (Transfers,Planned, etc.), Discharges

Adapted from HSTSARTDW DS_HSDW_App ETL uspSrc_PatientDischargeByService_Stage By Tom Burgan
--------------------------------------------------------------------------------------------
INFO:	
	INPUTS:
	        Rptg.vwFact_Pt_Enc_Hsp_Clrt
			Rptg.vwFact_Pt_Enc_Clrt
            Rptg.vwDim_Date
			Rptg.vwDim_Clrt_Admt_Chrcstc
			Rptg.vwDim_Clrt_Disch_Disp
			Rptg.vwFact_Pt_Enc_Atn_Prov_All
			Rptg.vwFact_Pt_Enc_ED_Clrt_Sumry
			Rptg.vwFact_Ordr_Prcdr
			Rptg.vwFact_Clrt_Flo_Msr
			Rptg.vwDim_Clrt_Flo_GrpRow
			Rptg.vwFact_Clrt_ADT
			Rptg.vwDim_Clrt_ADT_Evnt
			Rptg.vwDim_Clrt_DEPt
			Rptg.vwDim_Clrt_Rm
			Rptg.vwDim_Clrt_Bed
			Rptg.vwDim_Clrt_LOCtn
			Rptg.vwRef_MDM_Location_Master_locsvc
			Rptg.vwDim_Physcn
			dbo.Dim_Clrt_Pt
			Rptg.vwDim_Pt
			Rptg.vwDim_Clrt_SERsrc
			
	OUTPUTS:

			Detail list of reportable events for an encounter by COVID indicator and Care Unit Type
			Average daily count by reportable event, COVID indicator, and Care Unit Type
--------------------------------------------------------------------------------------------
MODS:
		01/14/2021 - TMB - script created
*******************************************************************************************/

SET NOCOUNT ON;

DECLARE @strBegindt AS SMALLDATETIME
DECLARE @strEnddt AS SMALLDATETIME

-- First day of a previous month
SET @strBegindt = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 3, 0) + ' 00:00'

-- Yesterday
SET @strEnddt = DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()) - 1, 0) + ' 23:59'

--SET @strBegindt = '10/1/2020 00:00'
SET @strBegindt = '7/1/2022 00:00'
----SET @strEnddt = '12/31/2020 23:59'
--SET @strEnddt = '3/31/2021 23:59'
SET @strEnddt = '1/23/2023 23:59'

--SELECT @strBegindt AS [Begin], @strEnddt AS [End]

if OBJECT_ID('tempdb..#ip_accts') is not NULL
DROP TABLE #ip_accts

if OBJECT_ID('tempdb..#ip_events') is not NULL
DROP TABLE #ip_events

if OBJECT_ID('tempdb..#ip_xfers_out') is not NULL
DROP TABLE #ip_xfers_out

if OBJECT_ID('tempdb..#ip_xfers_in') is not NULL
DROP TABLE #ip_xfers_in

if OBJECT_ID('tempdb..#ip_events_countable') is not NULL
DROP TABLE #ip_events_countable

if OBJECT_ID('tempdb..#RptgTemp ') is not null
Drop table #RptgTemp

if OBJECT_ID('tempdb..#RptgEvents ') is not null
Drop table #RptgEvents

if OBJECT_ID('tempdb..#RptgSummary') is not null
Drop table #RptgSummary

if OBJECT_ID('tempdb..#RptgSummaryDOW') is not null
Drop table #RptgSummaryDOW

/*  build a temp table of the target departments  */
DECLARE @Department TABLE (DepartmentId NUMERIC(18,0) PRIMARY KEY)

INSERT INTO @Department
(
    DepartmentId
)
VALUES
 (10243051) -- UVHE 3 CENTRAL
,(10243052) -- UVHE 3 EAST
,(10243089) -- UVHE 3 NORTH
,(10243122) -- UVHE 3 SOUTH
,(10243053) -- UVHE 3 WEST
,(10243054) -- UVHE 4 CENTRAL CV
,(10243110) -- UVHE 4 CENTRAL TXP
,(10243055) -- UVHE 4 EAST
--,(10243091) -- UVHE 4 NORTH
,(10243123) -- UVHE 4 SOUTH CVICU
,(10243057) -- UVHE 4 WEST
,(10243058) -- UVHE 5 CENTRAL
,(10243059) -- UVHE 5 EAST
,(10243090) -- UVHE 5 NORTH
,(10243124) -- UVHE 5 SOUTH
,(10243060) -- UVHE 5 WEST
,(10243061) -- UVHE 6 CENTRAL
,(10243062) -- UVHE 6 EAST
,(10243092) -- UVHE 6 NORTH
,(10243063) -- UVHE 6 WEST
--,(10243064) -- UVHE 7 CENTRAL
--,(10243108) -- UVHE 7 CIMU
--,(10243093) -- UVHE 7 NORTH
--,(10243113) -- UVHE 7 NORTH OB
--,(10243065) -- UVHE 7 WEST
--,(10243103) -- UVHE 7NORTH ACUTE
--,(10243094) -- UVHE 8 NORTH OB
,(10243068) -- UVHE 8 WEST
,(10243115) -- UVHE 8 NORTH ONC
,(10243096) -- UVHE 8 WEST STEM CELL
,(10243035) -- UVHE CORONARY CARE
,(10243038) -- UVHE MEDICAL ICU
,(10243041) -- UVHE NEUR ICU
,(10243046) -- UVHE SURG TRAM ICU
,(10243049) -- UVHE TCV POST OP
;

/*  build a temp table of all valid inpatient accounts  */
SELECT distinct hclrt.PAT_ENC_CSN_ID
      ,clrt.sk_Fact_Pt_Enc_Clrt
      ,hclrt.[sk_Fact_Pt_Acct]
      ,hclrt.[AcctNbr_int]
	  ,clrt.sk_Dim_Clrt_Pt
	  ,adte.Fyear_num AS adm_Fyear_num
	  ,ddte.Fyear_num AS dsch_Fyear_num
	  ,adte.fmonth_num AS adm_fmonth_num
	  ,ddte.fmonth_num AS dsch_fmonth_num
	  ,adte.FYear_name AS adm_FYear_name
	  ,ddte.FYear_name AS dsch_FYear_name
      ,hclrt.[MRN_int]
      ,hclrt.[sk_Adm_Dte]
      ,hclrt.[sk_Dsch_Dte]
      ,adte.day_date as IndexAdmission
	  ,hclrt.sk_Dim_Pt
	  ,hclrt.sk_Phys_Adm AS adm_enc_sk_phys_adm
	  ,adte.day_date AS adm_date
	  ,ddte.day_date AS dsch_date
      ,CAST(CAST(adte.day_date AS DATE) AS SMALLDATETIME) + CAST(CAST(hclrt.Adm_Tm AS TIME) AS SMALLDATETIME) AS adm_date_time
      ,CAST(CAST(ddte.day_date AS DATE) AS SMALLDATETIME) + CAST(CAST(hclrt.Dsch_Tm AS TIME) AS SMALLDATETIME) AS dsch_date_time
      ,CAST(hclrt.Adm_Tm AS TIME) AS adm_time
      ,CAST(hclrt.Dsch_Tm AS TIME) AS dsch_time
	  ,hclrt.HOSP_ADMSSN_STATS_C
	  ,admt.ADMIT_CATEGORY_C
	  ,admt.ADMIT_CATEGORY
	  ,admt.ADM_SOURCE
	  ,admt.HOSP_ADMSN_TYPE
	  ,admt.HOSP_ADMSN_STATUS
	  ,hclrt.sk_Adm_SERsrc AS adm_enc_sk_ser
	  ,hclrt.sk_Dsch_SERsrc AS dsch_enc_sk_ser
	  ,clrt.sk_Dim_Physcn AS enc_sk_physcn
	  ,hclrt.adt_pt_cls
	  ,hclrt.ADMIT_CONF_STAT
	  ,hclrt.ADT_PATIENT_STAT
	  ,ddisp.sk_Dim_Clrt_Disch_Disp
	  ,ddisp.DISCH_DISP_C
	  ,ddisp.Clrt_Disch_Disp
      ,dschatn.sk_Dim_Clrt_SERsrc AS dsch_atn_prov_sk_ser
      ,dschatn.sk_Dim_Physcn AS dsch_atn_prov_sk_physcn
      ,admatn.sk_Dim_Clrt_SERsrc AS adm_atn_prov_sk_ser
	  ,admatn.sk_Dim_Physcn AS adm_atn_prov_sk_physcn
	  ,ed.ACUITY_LEVEL_C
	  ,ed.Acuity
	  ,acuity.Msr_Val AS Progression_Level
	  ,ord.sk_Ordr_Dte
	  ,ord.ORDER_PROC_ID
	  ,ord.Ordr_Descr
	  ,ord.sk_Dim_Clrt_EAPrcdr
	  ,ord.Ordr_Dtm
  INTO #ip_accts
  FROM DS_HSDW_Prod.Rptg.vwFact_Pt_Enc_Hsp_Clrt AS hclrt WITH(NOLOCK)
  INNER JOIN DS_HSDW_Prod.Rptg.vwFact_Pt_Enc_Clrt AS clrt WITH(NOLOCK)
  ON hclrt.sk_Fact_Pt_Enc_Clrt = clrt.sk_Fact_Pt_Enc_Clrt
  INNER JOIN DS_HSDW_Prod.Rptg.vwdim_date as adte on hclrt.sk_Adm_Dte = adte.date_key
  INNER JOIN DS_HSDW_Prod.Rptg.vwdim_date as ddte on hclrt.sk_Dsch_Dte = ddte.date_key
  LEFT OUTER JOIN DS_HSDW_Prod.rptg.vwDim_Clrt_Admt_Chrcstc AS admt
  ON admt.sk_Dim_Clrt_Admt_Chrcstc = hclrt.sk_Dim_Clrt_Admt_Chrcstc
  LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Clrt_Disch_Disp AS ddisp ON ddisp.sk_Dim_Clrt_Disch_Disp = hclrt.sk_Dim_Clrt_Disch_Disp
  LEFT OUTER JOIN (SELECT PAT_ENC_CSN_ID
                        , sk_Dim_Clrt_SERsrc
						, sk_Dim_Physcn
						, ROW_NUMBER() OVER (PARTITION BY sk_Fact_Pt_Enc_Clrt ORDER BY Atn_Beg_Dtm DESC, CASE
																										   WHEN Atn_End_Dtm = '1900-01-01' THEN GETDATE()
																										   ELSE Atn_End_Dtm
																									     END DESC) AS 'Atn_Seq'
				   FROM DS_HSDW_Prod.Rptg.vwFact_Pt_Enc_Atn_Prov_All) AS dschatn ON (dschatn.PAT_ENC_CSN_ID = clrt.PAT_ENC_CSN_ID) AND dschatn.Atn_Seq = 1
  LEFT OUTER JOIN (SELECT PAT_ENC_CSN_ID
                        , sk_Dim_Clrt_SERsrc
						, sk_Dim_Physcn
						, ROW_NUMBER() OVER (PARTITION BY sk_Fact_Pt_Enc_Clrt ORDER BY Atn_Beg_Dtm, CASE
																									  WHEN Atn_End_Dtm = '1900-01-01' THEN GETDATE()
																									  ELSE Atn_End_Dtm
																									END) AS 'Atn_Seq'
				   FROM DS_HSDW_Prod.Rptg.vwFact_Pt_Enc_Atn_Prov_All) AS admatn ON (admatn.PAT_ENC_CSN_ID = clrt.PAT_ENC_CSN_ID) AND admatn.Atn_Seq = 1
  LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwFact_Pt_Enc_ED_Clrt_Sumry AS ed ON ed.sk_Fact_Pt_Enc_Clrt = hclrt.sk_Fact_Pt_Enc_Clrt
  LEFT OUTER JOIN (SELECT sk_Fact_Pt_Enc_Clrt
                        , sk_Ordr_Dte
						, Ordr_Dtm
						, ORDER_PROC_ID
						, Ordr_Descr
						, sk_Dim_Clrt_EAPrcdr
						, ROW_NUMBER() OVER (PARTITION BY sk_Fact_Pt_Enc_Clrt ORDER BY Ordr_Dtm DESC) AS 'Ord_Seq'
				   FROM DS_HSDW_Prod.Rptg.vwFact_Ordr_Prcdr
				   WHERE INSTANTIATED_TIME <> '1/1/1900'
				   AND sk_Dim_Clrt_EAPrcdr = 268) ord
  ON (ord.sk_Fact_Pt_Enc_Clrt = hclrt.sk_Fact_Pt_Enc_Clrt) AND ord.Ord_Seq = 1
  LEFT OUTER JOIN (SELECT fsm.sk_Fact_Pt_Enc_Clrt
                        , fsm.Msr_Ent_Dtm
						, fsm.Msr_Val
						, ROW_NUMBER() OVER (PARTITION BY fsm.sk_Fact_Pt_Enc_Clrt ORDER BY fsm.Msr_Rec_Dtm DESC) AS disp_seq
				   FROM DS_HSDW_Prod.Rptg.vwFact_Clrt_Flo_Msr fsm
				   INNER JOIN DS_HSDW_Prod.Rptg.vwDim_Clrt_Flo_GrpRow AS grr ON grr.sk_Dim_Clrt_Flo_GrpRow = fsm.sk_Dim_Clrt_Flo_GrpRow
				   WHERE grr.FLO_MEAS_ID = '305100299'
				   AND fsm.Msr_Val IN ('D','C')) acuity
  ON (acuity.sk_Fact_Pt_Enc_Clrt = hclrt.sk_Fact_Pt_Enc_Clrt) AND acuity.disp_seq = 1
  LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Clrt_DEPt dep
  --ON clrt.sk_Dim_Clrt_DEPt = dep.sk_Dim_Clrt_DEPt
  ON hclrt.sk_Dim_Clrt_DEPt = dep.sk_Dim_Clrt_DEPt
  --INNER JOIN @Department tdep
  --ON dep.DEPARTMENT_ID = tdep.DepartmentId
  WHERE hclrt.ADT_PATIENT_STAT <> 'Hospital Outpatient Visit'
  AND hclrt.ADMIT_CONF_STAT NOT IN ('Canceled')	--Charges are 0.00, in this case may be a pre-admit that was cancelled or pending and never confirmed
  AND (((ddte.day_date >= @strBegindt) AND (ddte.day_date <= @strEnddt)) OR (ddte.date_key = 19000101))
  AND ((adte.day_date >= @strBegindt) AND (adte.day_date <= @strEnddt))

CREATE INDEX idx_ipaccts1 ON #ip_accts (sk_Fact_Pt_Enc_Clrt)

--SELECT *
--FROM #ip_accts
--ORDER BY sk_Fact_Pt_Enc_Clrt

/*  build a temp table of ADT events for the hospital encounter accounts  */							                                                                                                                    -- (i.e. for excluding post-discharge events)
SELECT [PAT_ENC_CSN_ID]
      ,ip.[sk_Fact_Pt_Enc_Clrt]
      ,[sk_Dim_Pt]
      ,[HSP_ACCOUNT_ID]
      ,[AcctNbr_Clrt]
      ,fact.[sk_Dim_Clrt_ADT_Evnt]
	  ,[EVENT_ID]
	  ,dim.ADT_Evnt_Nme
	  ,dep.DEPARTMENT_ID
      ,fact.[sk_Dim_Clrt_DEPt]
	  ,dep.Clrt_DEPt_Nme
      ,[Xfer_in_Event_Id]
      ,[Xfer_Out_Event_Id]
      ,[ADT_In_Dtm]
	  ,CAST(fact.ADT_In_Dtm AS DATE) AS ADT_In_Dt
      ,[sk_ADT_In_Dte]
      ,[sk_ADT_In_Tm]
      ,[ADT_Out_Dtm]
	  ,CAST(fact.ADT_Out_Dtm AS DATE) AS ADT_Out_Dt
      ,[sk_ADT_Out_Dte]
      ,[sk_ADT_Out_Tm]
      ,[Enter_Dtm]
      ,[sk_ADT_Enter_Dte]
      ,[sk_ADT_Enter_Tm]
      ,[Adm_Event_Id]
      ,[Dis_Event_Id]
      ,fact.[sk_Dim_Clrt_Rm]
	  ,rm.Rm_Nme
      ,fact.[sk_Dim_Clrt_Bed]
	  ,bed.Bed_Nme
      ,[Envt_Sub_Nme]
      ,[Fr_Base_Cls]
      ,[To_Base_Cls]
      ,[Labor_Sts]
      ,[sk_Dim_AccountClass]
      ,[sk_Dim_HospitalService]
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
      ,[sk_Dim_BedUnit]
-- Is event department a target department
	  --, CASE WHEN tdep.DepartmentId IS NOT NULL THEN 'Y'
	  --      ELSE 'N'
	  --  END AS Target_Dept
-- Set COVID indicator
	--  , CASE
	--	  WHEN dep.DEPARTMENT_ID IN (
	--10243122, --UVHE 3 SOUTH
	--10243123, --UVHE 4 SOUTH CVICU
	--10243124 --UVHE 5 SOUTH
	--)
	--	  THEN 'COVID'
	--	  --ELSE 'NON-COVID'
	--	  WHEN tdep.DepartmentId IS NOT NULL
	--	  THEN 'NON-COVID'
	--	END AS COVID_IND
-- Set Care Unit Type
 --     , CASE
	--	  WHEN dep.DEPARTMENT_ID IN (
	----10243089, --UVHE 3 NORTH
	--10243123, --UVHE 4 SOUTH CVICU
	--10243035, --UVHE CORONARY CARE
	--10243038, --UVHE MEDICAL ICU
	--10243041, --UVHE NEUR ICU
	--10243046, --UVHE SURG TRAM ICU
	--10243049  --UVHE TCV POST OP
	--)
	--	  THEN 'ICU'
	--	  WHEN dep.DEPARTMENT_ID IN (
	--10243090, --UVHE 5 NORTH
	--10243092, --UVHE 6 NORTH
	--10243096  --UVHE 8 WEST STEM CELL
	--)
	--	  THEN 'IMU'
	--	  WHEN dep.DEPARTMENT_ID IN (
	--10243059  --UVHE 5 EAST
	--)
	--	  THEN 'Psych'
	--	  --ELSE 'Acute'
	--	  WHEN tdep.DepartmentId IS NOT NULL
	--	  THEN 'Acute'
	--	END AS CARE_UNIT_IND
  
  INTO #ip_events

  FROM (SELECT DISTINCT sk_Fact_Pt_Enc_Clrt
					  , adm_enc_sk_phys_adm
					  , enc_sk_physcn
        FROM #ip_accts) ip
  --INNER JOIN DS_HSDW_Prod.Rptg.vwFact_Clrt_ADT adt
  --ON ip.sk_Fact_Pt_Enc_Clrt = adt.sk_Fact_Pt_Enc_Clrt
  INNER JOIN [DS_HSDW_Prod].[Rptg].[vwFact_Clrt_ADT_Census] fact
  ON ip.sk_Fact_Pt_Enc_Clrt = fact.sk_Fact_Pt_Enc_Clrt
  LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Clrt_ADT_Evnt dim
  ON dim.sk_Dim_Clrt_ADT_Evnt = fact.sk_Dim_Clrt_ADT_Evnt
  LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Clrt_DEPt dep
  ON dep.sk_Dim_Clrt_DEPt = fact.sk_Dim_Clrt_DEPt
  LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Clrt_Rm rm
  ON rm.sk_Dim_Clrt_Rm = fact.sk_Dim_Clrt_Rm
  LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Clrt_Bed bed
  ON bed.sk_Dim_Clrt_Bed = fact.sk_Dim_Clrt_Bed
  --LEFT OUTER JOIN @Department tdep
  --ON tdep.DepartmentId = dep.DEPARTMENT_ID
  WHERE dim.ADT_Evnt_Nme <> 'Patient Update'

  --AND fact.PAT_ENC_CSN_ID = 200033376307

CREATE INDEX idx_ip_events1 ON #ip_events (sk_Fact_Pt_Enc_Clrt, PAT_ENC_CSN_ID, EVENT_ID)

--SELECT *
--FROM #ip_events
----WHERE sk_Fact_Pt_Enc_Clrt = 69669618
----ORDER BY sk_Fact_Pt_Enc_Clrt
----       , IN_DTTM
--ORDER BY sk_Fact_Pt_Enc_Clrt
--       --, ADT_In_Dtm
--	   , Seq_Num_in_Enc

/*  build a temp table of transfer-out events for the hospital encounter accounts  */
SELECT xfers.sk_Fact_Pt_Enc_Clrt
     , xfers.PAT_ENC_CSN_ID
	 , xfers.EVENT_ID
	 --, events.ADT_In_Dt AS ADT_In_Dt_Out
	 , events.ADT_In_Dtm AS ADT_In_Dt_Out
	 , events.ADT_Evnt_Nme AS ADT_Evnt_Out_Nme
	 , events.sk_Dim_Clrt_DEPt AS sk_Dim_Clrt_DEPt_Out
	 , events.DEPARTMENT_ID AS DEPARTMENT_ID_Out
	 , events.Clrt_DEPt_Nme AS Clrt_DEPt_Nme_Out
	 , events.Rm_Nme AS Rm_Nme_Out
	 , events.Bed_Nme AS Bed_Nme_Out
	 --, events.COVID_IND AS COVID_IND_Out
	 --, events.CARE_UNIT_IND AS CARE_UNIT_IND_Out
	 --, events.Target_Dept AS Target_Dept_Out

INTO #ip_xfers_out

FROM #ip_events events
INNER JOIN
(
SELECT events.sk_Fact_Pt_Enc_Clrt
     , events.PAT_ENC_CSN_ID
	 , events.EVENT_ID
	 , events.Xfer_Out_Event_Id
FROM #ip_events events
WHERE Xfer_Out_Event_Id > 0
) xfers
ON events.sk_Fact_Pt_Enc_Clrt = xfers.sk_Fact_Pt_Enc_Clrt
AND events.PAT_ENC_CSN_ID = xfers.PAT_ENC_CSN_ID
AND events.EVENT_ID = xfers.Xfer_Out_Event_Id

CREATE INDEX idx_ip_xfers_out ON #ip_xfers_out (sk_Fact_Pt_Enc_Clrt, PAT_ENC_CSN_ID, EVENT_ID)

/*  build a temp table of transfer-in events for the hospital encounter accounts  */
SELECT xfers.sk_Fact_Pt_Enc_Clrt
     , xfers.PAT_ENC_CSN_ID
	 , xfers.EVENT_ID
	 --, events.ADT_In_Dt AS ADT_In_Dt_In
	 , events.ADT_In_Dtm AS ADT_In_Dt_In
	 , events.ADT_Evnt_Nme AS ADT_Evnt_In_Nme
	 , events.sk_Dim_Clrt_DEPt AS sk_Dim_Clrt_DEPt_In
	 , events.DEPARTMENT_ID AS DEPARTMENT_ID_In
	 , events.Clrt_DEPt_Nme AS Clrt_DEPt_Nme_In
	 , events.Rm_Nme AS Rm_Nme_In
	 , events.Bed_Nme AS Bed_Nme_In
	 --, events.COVID_IND AS COVID_IND_In
	 --, events.CARE_UNIT_IND AS CARE_UNIT_IND_In
	 --, events.Target_Dept AS Target_Dept_In

INTO #ip_xfers_in

FROM #ip_events events
INNER JOIN
(
SELECT events.sk_Fact_Pt_Enc_Clrt
     , events.PAT_ENC_CSN_ID
	 , events.EVENT_ID
	 , events.Xfer_In_Event_Id
FROM #ip_events events
WHERE Xfer_In_Event_Id > 0
) xfers
ON events.sk_Fact_Pt_Enc_Clrt = xfers.sk_Fact_Pt_Enc_Clrt
AND events.PAT_ENC_CSN_ID = xfers.PAT_ENC_CSN_ID
AND events.EVENT_ID = xfers.Xfer_In_Event_Id

CREATE INDEX idx_ip_xfers_in ON #ip_xfers_in (sk_Fact_Pt_Enc_Clrt, PAT_ENC_CSN_ID, EVENT_ID)

/*  build a temp table of distinct, countable ADT events for the hospital encounter accounts  */
SELECT events.sk_Fact_Pt_Enc_Clrt
     , events.PAT_ENC_CSN_ID
     , events.EVENT_ID
	 , events.ADT_Evnt_Nme
	 , events.Xfer_in_Event_Id
	 , events.Xfer_Out_Event_Id
	 , events.ADT_In_Dt
	 , events.ADT_In_Dtm
	 , events.ADT_Out_Dt
	 , events.ADT_Out_Dtm
	 , events.Seq_Num_in_Enc
	 , events.sk_Dim_Clrt_DEPt
	 , events.DEPARTMENT_ID
	 , events.Clrt_DEPt_Nme
	 , events.Rm_Nme
	 , events.Bed_Nme
	 --, events.COVID_IND
	 --, events.CARE_UNIT_IND
	 --, events.Target_Dept
     , xfers_out.ADT_In_Dt_Out
	 , xfers_out.ADT_Evnt_Out_Nme
	 , xfers_out.sk_Dim_Clrt_DEPt_Out
	 , xfers_out.DEPARTMENT_ID_Out
	 , xfers_out.Clrt_DEPt_Nme_Out
	 , xfers_out.Rm_Nme_Out
	 , xfers_out.Bed_Nme_Out
	 --, xfers_out.COVID_IND_Out
	 --, xfers_out.CARE_UNIT_IND_Out
	 --, xfers_out.Target_Dept_Out
     , xfers_in.ADT_In_Dt_In
	 , xfers_in.ADT_Evnt_In_Nme
	 , xfers_in.sk_Dim_Clrt_DEPt_In
	 , xfers_in.DEPARTMENT_ID_In
	 , xfers_in.Clrt_DEPt_Nme_In
	 , xfers_in.Rm_Nme_In
	 , xfers_in.Bed_Nme_In
	 --, xfers_in.COVID_IND_In
	 --, xfers_in.CARE_UNIT_IND_In
	 --, xfers_in.Target_Dept_In

INTO #ip_events_countable

FROM #ip_events events
LEFT OUTER JOIN #ip_xfers_out xfers_out
ON xfers_out.sk_Fact_Pt_Enc_Clrt = events.sk_Fact_Pt_Enc_Clrt
AND xfers_out.PAT_ENC_CSN_ID = events.PAT_ENC_CSN_ID
AND xfers_out.EVENT_ID = events.EVENT_ID
LEFT OUTER JOIN #ip_xfers_in xfers_in
ON xfers_in.sk_Fact_Pt_Enc_Clrt = events.sk_Fact_Pt_Enc_Clrt
AND xfers_in.PAT_ENC_CSN_ID = events.PAT_ENC_CSN_ID
AND xfers_in.EVENT_ID = events.EVENT_ID
WHERE
((events.ADT_In_Dt >= @strBegindt) AND (events.ADT_In_Dt <= @strEnddt))

CREATE INDEX idx_ip_events_countable ON #ip_events_countable (sk_Fact_Pt_Enc_Clrt, PAT_ENC_CSN_ID, EVENT_ID)

--SELECT *
--FROM #ip_events_countable
----WHERE sk_Fact_Pt_Enc_Clrt = 69669618
--ORDER BY sk_Fact_Pt_Enc_Clrt
--       --, ADT_In_Dtm
--	   , Seq_Num_in_Enc

/*  build a temp table of reportable (based on event category) ADT events for the hospital encounter accounts  */
SELECT
    sk_Fact_Pt_Enc_Clrt
  , PAT_ENC_CSN_ID
  , EVENT_ID
  , ADT_Evnt_Nme
  , ADT_In_Dt
  , ADT_In_Dtm
  , Seq_Num_in_Enc
-- Assign event category for reportable event
  , CASE
	  WHEN ADT_Evnt_Nme = 'Census'
		--AND Target_Dept = 'Y'
	    THEN 'Daily Census'
	  WHEN ADT_Evnt_Nme = 'Transfer Out'
	    AND Clrt_DEPt_Nme IN
		(
			'P1HE PERIOP', -- 10243080
			'UVBB OPSC', -- 10354900
			'UVHE CARDIAC CATH LAB', -- 10243012
			'UVHE ENDOBRONC PROC', -- 10243911
			'UVHE NEURORADIOLOGY', -- 10243025
			'UVHE PERIOP', -- 10243900
			'UVML ENDOBRONC PROC' -- 10379900
		)
	    --AND (Target_Dept_In IS NOT NULL AND Target_Dept_IN = 'Y')
	    THEN 'OR/IR Admits'
	  WHEN ADT_Evnt_Nme = 'Transfer Out'
	        AND Clrt_DEPt_Nme = 'UVHE EMERGENCY DEPT'
            --AND Target_Dept_IN = 'Y'
	    THEN 'ED Admits'
	  WHEN (
	        ADT_Evnt_Nme = 'Transfer Out'
		    --AND Target_Dept = 'Y'
			AND ((Clrt_DEPt_Nme_In IS NOT NULL) AND (Clrt_DEPt_Nme_In <> Clrt_DEPt_Nme))
            --AND Target_Dept_IN = 'Y'
		   )
		   OR
		   (
	        ADT_Evnt_Nme = 'Admission'
		    --AND Target_Dept = 'Y'
		   )
	    THEN 'Other Admits'
	  WHEN ADT_Evnt_Nme = 'Transfer In'
	    AND ADT_Evnt_Out_Nme = 'Discharge'
		--AND Target_Dept_Out = 'Y'
	    THEN 'Discharge'
	END AS Event_Name
-- Determine event date for reportable event
  , CASE
	  WHEN ADT_Evnt_Nme = 'Census'
		--AND Target_Dept = 'Y'
	    --THEN ADT_In_Dt
	    THEN ADT_In_Dtm
	  WHEN ADT_Evnt_Nme = 'Transfer Out'
	    AND Clrt_DEPt_Nme IN
		(
			'P1HE PERIOP', -- 10243080
			'UVBB OPSC', -- 10354900
			'UVHE CARDIAC CATH LAB', -- 10243012
			'UVHE ENDOBRONC PROC', -- 10243911
			'UVHE NEURORADIOLOGY', -- 10243025
			'UVHE PERIOP', -- 10243900
			'UVML ENDOBRONC PROC' -- 10379900
		)
	    --AND (Target_Dept_In IS NOT NULL AND Target_Dept_IN = 'Y')
	    THEN ADT_In_Dt_In
	  WHEN ADT_Evnt_Nme = 'Transfer Out'
	        AND Clrt_DEPt_Nme = 'UVHE EMERGENCY DEPT'
            --AND Target_Dept_IN = 'Y'
	    THEN ADT_In_Dt_In
	  WHEN ADT_Evnt_Nme = 'Transfer Out'
		   --AND Target_Dept = 'Y'
		   AND ((Clrt_DEPt_Nme_In IS NOT NULL) AND (Clrt_DEPt_Nme_In <> Clrt_DEPt_Nme))
           --AND Target_Dept_IN = 'Y'
		THEN ADT_In_Dt_In
	  WHEN ADT_Evnt_Nme = 'Admission'
		   --AND Target_Dept = 'Y'
	    --THEN ADT_In_Dt
	    THEN ADT_In_Dtm
	  WHEN ADT_Evnt_Nme = 'Transfer In'
	    AND ADT_Evnt_Out_Nme = 'Discharge'
		--AND Target_Dept_Out = 'Y'
	    THEN ADT_In_Dt_Out
	END AS Event_Date
-- Determine COVID indicator for reportable event
 -- , CASE
	--  WHEN ADT_Evnt_Nme = 'Census'
	--	AND Target_Dept = 'Y'
	--    THEN COVID_IND
	--  WHEN ADT_Evnt_Nme = 'Transfer Out'
	--    AND Clrt_DEPt_Nme IN
	--	(
	--		'P1HE PERIOP', -- 10243080
	--		'UVBB OPSC', -- 10354900
	--		'UVHE CARDIAC CATH LAB', -- 10243012
	--		'UVHE ENDOBRONC PROC', -- 10243911
	--		'UVHE NEURORADIOLOGY', -- 10243025
	--		'UVHE PERIOP', -- 10243900
	--		'UVML ENDOBRONC PROC' -- 10379900
	--	)
	--    AND (Target_Dept_In IS NOT NULL AND Target_Dept_IN = 'Y')
	--    THEN COVID_IND_In
	--  WHEN ADT_Evnt_Nme = 'Transfer Out'
	--        AND Clrt_DEPt_Nme = 'UVHE EMERGENCY DEPT'
 --           AND Target_Dept_IN = 'Y'
	--    THEN COVID_IND_In
	--  WHEN ADT_Evnt_Nme = 'Transfer Out'
	--	   AND Target_Dept = 'Y'
	--	   AND ((Clrt_DEPt_Nme_In IS NOT NULL) AND (Clrt_DEPt_Nme_In <> Clrt_DEPt_Nme))
 --          AND Target_Dept_IN = 'Y'
	--	THEN COVID_IND_In
	--  WHEN ADT_Evnt_Nme = 'Admission'
	--	   AND Target_Dept = 'Y'
	--    THEN COVID_IND
	--  WHEN ADT_Evnt_Nme = 'Transfer In'
	--    AND ADT_Evnt_Out_Nme = 'Discharge'
	--	AND Target_Dept_Out = 'Y'
	--    THEN COVID_IND_Out
	--END AS Event_COVID_IND
-- Determine Care Unit Type name for reportable event
 -- , CASE
	--  WHEN ADT_Evnt_Nme = 'Census'
	--	AND Target_Dept = 'Y'
	--    THEN CARE_UNIT_IND
	--  WHEN ADT_Evnt_Nme = 'Transfer Out'
	--    AND Clrt_DEPt_Nme IN
	--	(
	--		'P1HE PERIOP', -- 10243080
	--		'UVBB OPSC', -- 10354900
	--		'UVHE CARDIAC CATH LAB', -- 10243012
	--		'UVHE ENDOBRONC PROC', -- 10243911
	--		'UVHE NEURORADIOLOGY', -- 10243025
	--		'UVHE PERIOP', -- 10243900
	--		'UVML ENDOBRONC PROC' -- 10379900
	--	)
	--    AND (Target_Dept_In IS NOT NULL AND Target_Dept_IN = 'Y')
	--    THEN CARE_UNIT_IND_In
	--  WHEN ADT_Evnt_Nme = 'Transfer Out'
	--        AND Clrt_DEPt_Nme = 'UVHE EMERGENCY DEPT'
 --           AND Target_Dept_IN = 'Y'
	--    THEN CARE_UNIT_IND_In
	--  WHEN ADT_Evnt_Nme = 'Transfer Out'
	--	   AND Target_Dept = 'Y'
	--	   AND ((Clrt_DEPt_Nme_In IS NOT NULL) AND (Clrt_DEPt_Nme_In <> Clrt_DEPt_Nme))
 --          AND Target_Dept_IN = 'Y'
	--	THEN CARE_UNIT_IND_In
	--  WHEN ADT_Evnt_Nme = 'Admission'
	--	   AND Target_Dept = 'Y'
	--    THEN CARE_UNIT_IND
	--  WHEN ADT_Evnt_Nme = 'Transfer In'
	--    AND ADT_Evnt_Out_Nme = 'Discharge'
	--	AND Target_Dept_Out = 'Y'
	--    THEN CARE_UNIT_IND_Out
	--END AS Event_CARE_UNIT_IND
-- Determine department id for reportable event
  , CASE
	  WHEN ADT_Evnt_Nme = 'Census'
		--AND Target_Dept = 'Y'
	    THEN DEPARTMENT_ID
	  WHEN ADT_Evnt_Nme = 'Transfer Out'
	    AND Clrt_DEPt_Nme IN
		(
			'P1HE PERIOP', -- 10243080
			'UVBB OPSC', -- 10354900
			'UVHE CARDIAC CATH LAB', -- 10243012
			'UVHE ENDOBRONC PROC', -- 10243911
			'UVHE NEURORADIOLOGY', -- 10243025
			'UVHE PERIOP', -- 10243900
			'UVML ENDOBRONC PROC' -- 10379900
		)
	    --AND (Target_Dept_In IS NOT NULL AND Target_Dept_IN = 'Y')
	    THEN DEPARTMENT_ID_In
	  WHEN ADT_Evnt_Nme = 'Transfer Out'
	        AND Clrt_DEPt_Nme = 'UVHE EMERGENCY DEPT'
            --AND Target_Dept_IN = 'Y'
	    THEN DEPARTMENT_ID_In
	  WHEN ADT_Evnt_Nme = 'Transfer Out'
		   --AND Target_Dept = 'Y'
		   AND ((Clrt_DEPt_Nme_In IS NOT NULL) AND (Clrt_DEPt_Nme_In <> Clrt_DEPt_Nme))
           --AND Target_Dept_IN = 'Y'
		THEN DEPARTMENT_ID_In
	  WHEN ADT_Evnt_Nme = 'Admission'
		   --AND Target_Dept = 'Y'
	    THEN DEPARTMENT_ID
	  WHEN ADT_Evnt_Nme = 'Transfer In'
	    AND ADT_Evnt_Out_Nme = 'Discharge'
		--AND Target_Dept_Out = 'Y'
	    THEN DEPARTMENT_ID_Out
	END AS Event_DEPARTMENT_ID
-- Determine department name for reportable event
  , CASE
	  WHEN ADT_Evnt_Nme = 'Census'
		--AND Target_Dept = 'Y'
	    THEN Clrt_DEPt_Nme
	  WHEN ADT_Evnt_Nme = 'Transfer Out'
	    AND Clrt_DEPt_Nme IN
		(
			'P1HE PERIOP', -- 10243080
			'UVBB OPSC', -- 10354900
			'UVHE CARDIAC CATH LAB', -- 10243012
			'UVHE ENDOBRONC PROC', -- 10243911
			'UVHE NEURORADIOLOGY', -- 10243025
			'UVHE PERIOP', -- 10243900
			'UVML ENDOBRONC PROC' -- 10379900
		)
	    --AND (Target_Dept_In IS NOT NULL AND Target_Dept_IN = 'Y')
	    THEN Clrt_DEPt_Nme_In
	  WHEN ADT_Evnt_Nme = 'Transfer Out'
	        AND Clrt_DEPt_Nme = 'UVHE EMERGENCY DEPT'
            --AND Target_Dept_IN = 'Y'
	    THEN Clrt_DEPt_Nme_In
	  WHEN ADT_Evnt_Nme = 'Transfer Out'
		   --AND Target_Dept = 'Y'
		   AND ((Clrt_DEPt_Nme_In IS NOT NULL) AND (Clrt_DEPt_Nme_In <> Clrt_DEPt_Nme))
           --AND Target_Dept_IN = 'Y'
		THEN Clrt_DEPt_Nme_In
	  WHEN ADT_Evnt_Nme = 'Admission'
		   --AND Target_Dept = 'Y'
	    THEN Clrt_DEPt_Nme
	  WHEN ADT_Evnt_Nme = 'Transfer In'
	    AND ADT_Evnt_Out_Nme = 'Discharge'
		--AND Target_Dept_Out = 'Y'
	    THEN Clrt_DEPt_Nme_Out
	END AS Event_Clrt_DEPt_Nme
-- Determine room name for reportable event
  , CASE
	  WHEN ADT_Evnt_Nme = 'Census'
		--AND Target_Dept = 'Y'
	    THEN Rm_Nme
	  WHEN ADT_Evnt_Nme = 'Transfer Out'
	    AND Clrt_DEPt_Nme IN
		(
			'P1HE PERIOP', -- 10243080
			'UVBB OPSC', -- 10354900
			'UVHE CARDIAC CATH LAB', -- 10243012
			'UVHE ENDOBRONC PROC', -- 10243911
			'UVHE NEURORADIOLOGY', -- 10243025
			'UVHE PERIOP', -- 10243900
			'UVML ENDOBRONC PROC' -- 10379900
		)
	    --AND (Target_Dept_In IS NOT NULL AND Target_Dept_IN = 'Y')
	    THEN Rm_Nme_In
	  WHEN ADT_Evnt_Nme = 'Transfer Out'
	        AND Clrt_DEPt_Nme = 'UVHE EMERGENCY DEPT'
            --AND Target_Dept_IN = 'Y'
	    THEN Rm_Nme_In
	  WHEN ADT_Evnt_Nme = 'Transfer Out'
		   --AND Target_Dept = 'Y'
		   AND ((Clrt_DEPt_Nme_In IS NOT NULL) AND (Clrt_DEPt_Nme_In <> Clrt_DEPt_Nme))
           --AND Target_Dept_IN = 'Y'
		THEN Rm_Nme_In
	  WHEN ADT_Evnt_Nme = 'Admission'
		   --AND Target_Dept = 'Y'
	    THEN Rm_Nme
	  WHEN ADT_Evnt_Nme = 'Transfer In'
	    AND ADT_Evnt_Out_Nme = 'Discharge'
		--AND Target_Dept_Out = 'Y'
	    THEN Rm_Nme_Out
	END AS Event_Rm_Nme
-- Determine bed name for reportable event
  , CASE
	  WHEN ADT_Evnt_Nme = 'Census'
		--AND Target_Dept = 'Y'
	    THEN Bed_Nme
	  WHEN ADT_Evnt_Nme = 'Transfer Out'
	    AND Clrt_DEPt_Nme IN
		(
			'P1HE PERIOP', -- 10243080
			'UVBB OPSC', -- 10354900
			'UVHE CARDIAC CATH LAB', -- 10243012
			'UVHE ENDOBRONC PROC', -- 10243911
			'UVHE NEURORADIOLOGY', -- 10243025
			'UVHE PERIOP', -- 10243900
			'UVML ENDOBRONC PROC' -- 10379900
		)
	    --AND (Target_Dept_In IS NOT NULL AND Target_Dept_IN = 'Y')
	    THEN Bed_Nme_In
	  WHEN ADT_Evnt_Nme = 'Transfer Out'
	        AND Clrt_DEPt_Nme = 'UVHE EMERGENCY DEPT'
            --AND Target_Dept_IN = 'Y'
	    THEN Bed_Nme_In
	  WHEN ADT_Evnt_Nme = 'Transfer Out'
		   --AND Target_Dept = 'Y'
		   AND ((Clrt_DEPt_Nme_In IS NOT NULL) AND (Clrt_DEPt_Nme_In <> Clrt_DEPt_Nme))
           --AND Target_Dept_IN = 'Y'
		THEN Bed_Nme_In
	  WHEN ADT_Evnt_Nme = 'Admission'
		   --AND Target_Dept = 'Y'
	    THEN Bed_Nme
	  WHEN ADT_Evnt_Nme = 'Transfer In'
	    AND ADT_Evnt_Out_Nme = 'Discharge'
		--AND Target_Dept_Out = 'Y'
	    THEN Bed_Nme_Out
	END AS Event_Bed_Nme

INTO #RptgTemp

FROM #ip_events_countable

/*  build a temp table of reportable event details for the hospital encounter accounts  */
SELECT sk_Fact_Pt_Enc_Clrt,
       PAT_ENC_CSN_ID,
       EVENT_ID,
       ADT_Evnt_Nme,
       ADT_In_Dt,
	   ADT_In_Dtm,
       Seq_Num_in_Enc,
       Event_Name,
       Event_Date,
       --Event_COVID_IND,
       --Event_CARE_UNIT_IND,
	   Event_DEPARTMENT_ID,
       Event_Clrt_DEPt_Nme,
	   Event_Rm_Nme,
	   Event_Bed_Nme,
       ddte.day_of_week_num,
       ddte.day_of_week

INTO #RptgEvents

FROM #RptgTemp
LEFT OUTER JOIN Rptg.vwDim_Date ddte
--ON ddte.day_date = Event_Date
ON ddte.day_date = CAST(CAST(Event_Date AS DATE) AS SMALLDATETIME)
WHERE
Event_Name IS NOT NULL

--CREATE INDEX idx_RptgEvents ON #RptgEvents (Event_Name, Event_COVID_IND, Event_CARE_UNIT_IND, Event_Date)
CREATE INDEX idx_RptgEvents ON #RptgEvents (Event_Name, Event_Date)

SELECT sk_Fact_Pt_Enc_Clrt,
       PAT_ENC_CSN_ID,
       EVENT_ID,
       --ADT_Evnt_Nme,
       --ADT_In_Dt,
       --Seq_Num_in_Enc,
       --Event_Name,
       CASE WHEN Event_Name = 'Discharge' THEN Event_Name ELSE ADT_Evnt_Nme END AS Event_Name,
       Event_Date,
       --Event_COVID_IND,
       --Event_CARE_UNIT_IND,
	   Event_DEPARTMENT_ID,
       Event_Clrt_DEPt_Nme,
	   Event_Rm_Nme,
	   Event_Bed_Nme,
       day_of_week_num,
       day_of_week
FROM #RptgEvents
--ORDER BY sk_Fact_Pt_Enc_Clrt
--       --, ADT_In_Dtm
--	   , Seq_Num_in_Enc
--ORDER BY PAT_ENC_CSN_ID
--       --, ADT_In_Dtm
--	   , Seq_Num_in_Enc
ORDER BY PAT_ENC_CSN_ID
       , Event_Date
	   , Seq_Num_in_Enc
/*
/*  build a temp table containing the reportable event summary for the hospital encounter accounts  */
SELECT Event_Name
     , Event_COVID_IND
	 , Event_CARE_UNIT_IND
	 , Event_Date
	 , COUNT(*) AS Event_Count

INTO #RptgSummary

FROM #RptgEvents
WHERE Event_Date >= '12/10/2020'
GROUP BY Event_Name
       , Event_COVID_IND
	   , Event_CARE_UNIT_IND
	   , Event_Date
ORDER BY Event_Name
       , Event_COVID_IND
	   , Event_CARE_UNIT_IND
	   , Event_Date

SELECT Event_Name,
       Event_COVID_IND,
       Event_CARE_UNIT_IND,
       Event_Date,
       Event_Count
FROM #RptgSummary
ORDER BY Event_Name
       , Event_COVID_IND
	   , Event_CARE_UNIT_IND
	   , Event_Date

SELECT Event_Name
     , Event_COVID_IND
	 , Event_CARE_UNIT_IND
	 , AVG(Event_Count) AS Average_Event_Count
FROM #RptgSummary
GROUP BY Event_Name
       , Event_COVID_IND
	   , Event_CARE_UNIT_IND
ORDER BY Event_Name
       , Event_COVID_IND
	   , Event_CARE_UNIT_IND

/*  build a temp table containing the reportable event summary by day of week for the hospital encounter accounts  */
SELECT Event_Name
     , Event_COVID_IND
	 , Event_CARE_UNIT_IND
	 , day_of_week_num
	 , day_of_week
	 , Event_Date
	 , COUNT(*) AS Event_Count

INTO #RptgSummaryDOW

FROM #RptgEvents
WHERE Event_Date >= '12/10/2020'
GROUP BY Event_Name
       , Event_COVID_IND
	   , Event_CARE_UNIT_IND
	   , day_of_week_num
	   , day_of_week
	   , Event_Date
ORDER BY Event_Name
       , Event_COVID_IND
	   , Event_CARE_UNIT_IND
	   , day_of_week_num
	   , day_of_week
	   , Event_Date

SELECT Event_Name,
       Event_COVID_IND,
       Event_CARE_UNIT_IND,
	   day_of_week_num,
	   day_of_week,
       Event_Date,
       Event_Count
FROM #RptgSummaryDOW
ORDER BY Event_Name
       , Event_COVID_IND
	   , Event_CARE_UNIT_IND
	   , day_of_week_num
	   , day_of_week
	   , Event_Date

SELECT Event_Name
     , Event_COVID_IND
	 , Event_CARE_UNIT_IND
	 , day_of_week_num
	 , day_of_week
	 , AVG(Event_Count) AS Average_Event_Count
FROM #RptgSummaryDOW
GROUP BY Event_Name
       , Event_COVID_IND
	   , Event_CARE_UNIT_IND
	   , day_of_week_num
	   , day_of_week
ORDER BY Event_Name
       , Event_COVID_IND
	   , Event_CARE_UNIT_IND
	   , day_of_week_num
	   , day_of_week
*/
GO


