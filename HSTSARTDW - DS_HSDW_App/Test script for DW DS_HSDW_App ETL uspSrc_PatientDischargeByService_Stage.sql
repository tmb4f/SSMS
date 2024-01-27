--USE [DS_HSDW_App]
USE DS_HSDW_Prod
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--ALTER PROCEDURE [ETL].[uspSrc_PatientDischargeByService_Stage]
--AS

/*******************************************************************************************
Proc to stage DS_HSDW_Prod data set for Patient Discharge by Service table used in Readmissions metric.
Stage will be done each evening after the DS_HSDW_Prod database is refreshed so that the hourly runs
on the next day do not have to keep thrashing at the DM.DS_HSDW_Prod database all day long to return the identical results
Stage version created 
		Bryan Dunn
		07/23/2020

Adapted from the original [Rptg].[uspSrc_PatientDischargeByService_v2] By	Tom Burgan
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
			HSTSDSSQLDM.DS_HSDM_Prod.[Rptg].[uspSrc_PatientDischargeByService_v2]
   
--------------------------------------------------------------------------------------------
MODS:
		08/08/2016 - usp created
		09/13/2016 - add logic to include service line designation from Dim_Physcn table
		09/20/2016 - include recent admissions without a discharge; exclde pre-admits
		09/29/2016 - expand window for reportable index dishcarges and readmissions
		05/22/2017 - change service line mapping table to view vwRef_MDM_Location_Master_locsvc
		06/13/2017 - add Observation patients, add MDM attributes
		06/27/2017 - add Post-Procedure encounters
		07/27/2017 - remove/edit filters for patient class, admit status, admit category;
		             add new sources for attending provider, discharge disposition;
					 add columns for new attending provider, discharge disposition,
					  patient class, patient status, admit confirmation status, acuity,
					  progression level, and discharge order time
		08/02/2017 - use vwDim_Patient for patient names and birth dates
		08/16/2017 - exclude ADT events with an effective date time after the discharge
		              event date time; filter out duplicate ADT "events"; select earliest
					  date time for an ADT event
		08/17/2017 - correct the logic that identifies the discharge detail

		07/23/2020 BDD - convert to a staging proc to be run on the DW server
*******************************************************************************************/


DECLARE @CurrentFyear_num AS INTEGER
DECLARE @PreviousFyear_num AS INTEGER
DECLARE @strBegindt AS SMALLDATETIME
DECLARE @strEnddt AS SMALLDATETIME
DECLARE @strDschBegindt AS VARCHAR(19)

SET @CurrentFyear_num = (
	SELECT Fyear_num
	FROM DS_HSDW_Prod.Rptg.vwDim_Date ddte
	WHERE (CONVERT(VARCHAR(10), GETDATE(), 101) = CONVERT(VARCHAR(10), ddte.day_date, 101))
)

SET @PreviousFyear_num = @CurrentFyear_num - 1

-- First day of previous fiscal year
--SET @strBegindt = '7/1/' + CONVERT(VARCHAR(4),@PreviousFyear_num-1) + ' 00:00:00'
---BDD 7/17/2018 changed to go an extra year back in July for balanced scorecard year over year reporting
IF DATEPART(mm,GETDATE()) in (7,8)
SET @strBegindt = '7/1/' + CONVERT(VARCHAR(4),@PreviousFyear_num-4) + ' 00:00:00'
ELSE
SET @strBegindt = '7/1/' + CONVERT(VARCHAR(4),@PreviousFyear_num-3) + ' 00:00:00'

-- Last day of current fiscal year
SET @strEnddt = DATEADD(MINUTE,-1,'7/1/' + CONVERT(VARCHAR(4),@CurrentFyear_num) + ' 00:00:00')

-- 30-days prior to reporting period begin date
SET @strDschBegindt = DATEADD(DAY, -30, DATEADD(MONTH, DATEDIFF(MONTH,0,@strBegindt), 0))

-- First day of a previous month
--SET @strBegindt = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 3, 0) + ' 00:00'

-- Yesterday
--SET @strEnddt = DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()) - 1, 0) + ' 23:59'

--SET @strBegindt = '10/1/2020 00:00'
----SET @strEnddt = '12/31/2020 23:59'
--SET @strEnddt = '1/13/2021 23:59'

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

--if OBJECT_ID('tempdb..#ip_adm_events') is not NULL
--DROP TABLE #ip_adm_events

--if OBJECT_ID('tempdb..#ip_disch_events') is not NULL
--DROP TABLE #ip_disch_events

if OBJECT_ID('tempdb..#RptgTemp ') is not null
Drop table #RptgTemp

if OBJECT_ID('tempdb..#RptgEvents ') is not null
Drop table #RptgEvents

if OBJECT_ID('tempdb..#RptgSummary') is not null
Drop table #RptgSummary

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
  --LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Clrt_DEPt dep
  ----ON clrt.sk_Dim_Clrt_DEPt = dep.sk_Dim_Clrt_DEPt
  --ON hclrt.sk_Dim_Clrt_DEPt = dep.sk_Dim_Clrt_DEPt
  --INNER JOIN @Department tdep
  --ON dep.DEPARTMENT_ID = tdep.DepartmentId
  WHERE hclrt.ADT_PATIENT_STAT <> 'Hospital Outpatient Visit'
  AND hclrt.ADMIT_CONF_STAT NOT IN ('Canceled')	--Charges are 0.00, in this case may be a pre-admit that was cancelled or pending and never confirmed
  --AND   ((ddte.day_date >= @strDschBegindt) -- find previous discharges for these 30-day admissions
	 --    OR ((ddte.date_key = 19000101)     -- include admissions without a discharge
		--     AND ((adte.day_date >= @strDschBegindt)
		--	      AND (adte.day_date <= CAST(@strEnddt AS DATE)))))
  AND (((ddte.day_date >= @strBegindt) AND (ddte.day_date <= @strEnddt)) OR (ddte.date_key = 19000101))
  AND ((adte.day_date >= @strBegindt) AND (adte.day_date <= @strEnddt))
--  AND dep.DEPARTMENT_ID IN (
--10243051, --UVHE 3 CENTRAL
--10243052, --UVHE 3 EAST
--10243089, --UVHE 3 NORTH
--10243122, --UVHE 3 SOUTH
--10243053, --UVHE 3 WEST
--10243054, --UVHE 4 CENTRAL CV
--10243110, --UVHE 4 CENTRAL TXP
--10243055, --UVHE 4 EAST
----10243091, --UVHE 4 NORTH
--10243123, --UVHE 4 SOUTH CVICU
--10243057, --UVHE 4 WEST
--10243058, --UVHE 5 CENTRAL
--10243059, --UVHE 5 EAST
--10243090, --UVHE 5 NORTH
--10243124, --UVHE 5 SOUTH
--10243060, --UVHE 5 WEST
--10243061, --UVHE 6 CENTRAL
--10243062, --UVHE 6 EAST
--10243092, --UVHE 6 NORTH
--10243063, --UVHE 6 WEST
----10243064, --UVHE 7 CENTRAL
----10243108, --UVHE 7 CIMU
----10243093, --UVHE 7 NORTH
----10243113, --UVHE 7 NORTH OB
----10243065, --UVHE 7 WEST
----10243103, --UVHE 7NORTH ACUTE
----10243094, --UVHE 8 NORTH OB
----10243068, --UVHE 8 WEST
--10243115, --UVHE 8 NORTH ONC
--10243096, --UVHE 8 WEST STEM CELL
--10243035, --UVHE CORONARY CARE
----10243037, --UVHE LABOR & DELIVERY
----10243038, --UVHE MEDICAL ICU
--10243041, --UVHE NEUR ICU
--10243046, --UVHE SURG TRAM ICU
--10243049  --UVHE TCV POST OP
--)
AND hclrt.PAT_ENC_CSN_ID = 200047323543

CREATE INDEX idx_ipaccts1 ON #ip_accts (sk_Fact_Pt_Enc_Clrt)

--SELECT *
--FROM #ip_accts
--ORDER BY sk_Fact_Pt_Enc_Clrt

/*  build a temp table of ADT events for the hospital encounter accounts  */
--SELECT distinct ip.sk_Fact_Pt_Enc_Clrt
--	  ,ip.adm_enc_sk_phys_adm
--	  ,ip.enc_sk_physcn
--      ,adt.sk_Dim_Clrt_ADT_Evnt
--      ,adt.sk_Dim_Clrt_DEPt
--      ,adt.sk_Dim_Clrt_Rm
--      ,adt.sk_Dim_Clrt_Bed
--	  ,adt.sk_Dim_Clrt_LOCtn
--	  ,adt.sk_Beg_Dte
--	  ,adt.sk_Beg_Tm
--	  ,adt.sk_End_Dte
--	  ,adt.sk_End_Tm
--	  ,adt.IN_DTTM
--	  ,adt.OUT_DTTM
--	  ,seq
--	  ,adt.Post_Disch_Evnt
--      ,ROW_NUMBER() OVER (PARTITION BY ip.sk_Fact_Pt_Enc_Clrt
--                          ORDER BY adt.IN_DTTM, adt.OUT_DTTM) AS AdmSeq -- For determining first ADT event for an encounter, may not be an admission
--      ,ROW_NUMBER() OVER (PARTITION BY ip.sk_Fact_Pt_Enc_Clrt
--                          ORDER BY adt.IN_DTTM DESC, adt.OUT_DTTM DESC) AS DschSeq -- For determining the last ADT event for an encounter, may not be a discharge
--      ,ROW_NUMBER() OVER (PARTITION BY ip.sk_Fact_Pt_Enc_Clrt, adt.sk_Dim_Clrt_ADT_Evnt, adt.sk_Dim_Clrt_DEPt,
--	                                   adt.sk_Dim_Clrt_Rm, adt.sk_Dim_Clrt_Bed, adt.sk_Dim_Clrt_LOCtn, adt.sk_Beg_Dte,
--									   adt.sk_Beg_Tm, adt.sk_End_Dte, adt.sk_End_Tm, adt.IN_DTTM, adt.OUT_DTTM
--                          ORDER BY adt.seq) AS EventSeq -- To help identify duplicate ADT events, exluding "seq" value
--      ,ROW_NUMBER() OVER (PARTITION BY ip.sk_Fact_Pt_Enc_Clrt, adt.sk_Dim_Clrt_ADT_Evnt, adt.Post_Disch_Evnt
--                          ORDER BY adt.seq) AS PostDischEventSeq -- To help identify the initial discharge event when an encounter has multiple discharge dates
--      ,LAST_VALUE(adt.seq) OVER (PARTITION BY ip.sk_Fact_Pt_Enc_Clrt
--                                 ORDER BY adt.Post_Disch_Evnt, adt.seq ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS PostDschSeqLast -- To help identify the discharge event for an encounter
--								                                                                                                                    -- (i.e. for excluding post-discharge events)
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
      ,[sk_Dim_Clrt_Rm]
      ,[sk_Dim_Clrt_Bed]
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
	  --, CASE WHEN tdep.DepartmentId IS NOT NULL THEN 'Y'
	  , CASE WHEN dep.DEPARTMENT_ID IS NOT NULL THEN 'Y'
	        ELSE 'N'
	    END AS Target_Dept
	  , CASE
		  WHEN dep.DEPARTMENT_ID IN (
	10243122, --UVHE 3 SOUTH
	10243123, --UVHE 4 SOUTH CVICU
	10243124 --UVHE 5 SOUTH
	)
		  THEN 'COVID'
		  --ELSE 'NON-COVID'
		  --WHEN tdep.DepartmentId IS NOT NULL
		  WHEN dep.DEPARTMENT_ID IS NOT NULL
		  THEN 'NON-COVID'
		END AS COVID_IND
      , CASE
		  WHEN dep.DEPARTMENT_ID IN (
	10243089, --UVHE 3 NORTH
	10243123, --UVHE 4 SOUTH CVICU
	10243035, --UVHE CORONARY CARE
	10243038, --UVHE MEDICAL ICU
	10243041, --UVHE NEUR ICU
	10243046, --UVHE SURG TRAM ICU
	10243049  --UVHE TCV POST OP
	)
		  THEN 'ICU'
		  WHEN dep.DEPARTMENT_ID IN (
	10243090, --UVHE 5 NORTH
	10243092, --UVHE 6 NORTH
	10243096  --UVHE 8 WEST STEM CELL
	)
		  THEN 'IMU'
		  WHEN dep.DEPARTMENT_ID IN (
	10243059  --UVHE 5 EAST
	)
		  THEN 'Psych'
		  --ELSE 'Acute'
		  --WHEN tdep.DepartmentId IS NOT NULL
		  WHEN dep.DEPARTMENT_ID IS NOT NULL
		  THEN 'Acute'
		END AS CARE_UNIT_IND
  
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
  --LEFT OUTER JOIN @Department tdep
  --ON tdep.DepartmentId = dep.DEPARTMENT_ID
  --WHERE sk_Fact_Pt_Enc_Clrt = 70093881
  --AND dim.ADT_Evnt_Nme <> 'Patient Update'
  WHERE dim.ADT_Evnt_Nme <> 'Patient Update'
  --WHERE dim.ADT_Evnt_Nme = 'Census'

--CREATE INDEX idx_ip_events1 ON #ip_events (sk_Fact_Pt_Enc_Clrt)
--CREATE INDEX idx_ip_events1 ON #ip_events (sk_Fact_Pt_Enc_Clrt, ADT_Evnt_Nme, ADT_In_Dtm )
CREATE INDEX idx_ip_events1 ON #ip_events (sk_Fact_Pt_Enc_Clrt, PAT_ENC_CSN_ID, EVENT_ID)

--SELECT *
--FROM #ip_events
----WHERE sk_Fact_Pt_Enc_Clrt = 69669618
----ORDER BY sk_Fact_Pt_Enc_Clrt
----       , IN_DTTM
--ORDER BY sk_Fact_Pt_Enc_Clrt
--       --, ADT_In_Dtm
--	   , Seq_Num_in_Enc

/*  build a temp table of transfer events for the hospital encounter accounts  */
SELECT xfers.sk_Fact_Pt_Enc_Clrt
     , xfers.PAT_ENC_CSN_ID
	 , xfers.EVENT_ID
	 , events.ADT_In_Dt AS ADT_In_Dt_Out
	 , events.ADT_Evnt_Nme AS ADT_Evnt_Out_Nme
	 , events.sk_Dim_Clrt_DEPt AS sk_Dim_Clrt_DEPt_Out
	 , events.Clrt_DEPt_Nme AS Clrt_DEPt_Nme_Out
	 , events.COVID_IND AS COVID_IND_Out
	 , events.CARE_UNIT_IND AS CARE_UNIT_IND_Out
	 , events.Target_Dept AS Target_Dept_Out
	 --, CASE WHEN tdep.DepartmentId IS NOT NULL THEN 'Y'
	 --       ELSE 'N'
	 --  END AS Target_Dept_Out

INTO #ip_xfers_out

FROM #ip_events events
--LEFT OUTER JOIN @Department tdep
--ON tdep.DepartmentId = events.DEPARTMENT_ID
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

/*  build a temp table of transfer events for the hospital encounter accounts  */
SELECT xfers.sk_Fact_Pt_Enc_Clrt
     , xfers.PAT_ENC_CSN_ID
	 , xfers.EVENT_ID
	 , events.ADT_In_Dt AS ADT_In_Dt_In
	 , events.ADT_Evnt_Nme AS ADT_Evnt_In_Nme
	 , events.sk_Dim_Clrt_DEPt AS sk_Dim_Clrt_DEPt_In
	 , events.Clrt_DEPt_Nme AS Clrt_DEPt_Nme_In
	 , events.COVID_IND AS COVID_IND_In
	 , events.CARE_UNIT_IND AS CARE_UNIT_IND_In
	 , events.Target_Dept AS Target_Dept_In
	 --, CASE WHEN tdep.DepartmentId IS NOT NULL THEN 'Y'
	 --       ELSE 'N'
	 --  END AS Target_Dept_In

INTO #ip_xfers_in

FROM #ip_events events
--LEFT OUTER JOIN @Department tdep
--ON tdep.DepartmentId = events.DEPARTMENT_ID
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
	 , events.COVID_IND
	 , events.CARE_UNIT_IND
	 --, CASE WHEN tdep.DepartmentId IS NOT NULL THEN 'Y'
	 --       ELSE 'N'
	 --  END AS Target_Dept 
	 , events.Target_Dept 
--	 , CASE
--	     WHEN events.DEPARTMENT_ID IN (
--10243051, --UVHE 3 CENTRAL
--10243052, --UVHE 3 EAST
--10243089, --UVHE 3 NORTH
--10243122, --UVHE 3 SOUTH
--10243053, --UVHE 3 WEST
--10243054, --UVHE 4 CENTRAL CV
--10243110, --UVHE 4 CENTRAL TXP
--10243055, --UVHE 4 EAST
----10243091, --UVHE 4 NORTH
--10243123, --UVHE 4 SOUTH CVICU
--10243057, --UVHE 4 WEST
--10243058, --UVHE 5 CENTRAL
--10243059, --UVHE 5 EAST
--10243090, --UVHE 5 NORTH
--10243124, --UVHE 5 SOUTH
--10243060, --UVHE 5 WEST
--10243061, --UVHE 6 CENTRAL
--10243062, --UVHE 6 EAST
--10243092, --UVHE 6 NORTH
--10243063, --UVHE 6 WEST
----10243064, --UVHE 7 CENTRAL
----10243108, --UVHE 7 CIMU
----10243093, --UVHE 7 NORTH
----10243113, --UVHE 7 NORTH OB
----10243065, --UVHE 7 WEST
----10243103, --UVHE 7NORTH ACUTE
----10243094, --UVHE 8 NORTH OB
----10243068, --UVHE 8 WEST
--10243115, --UVHE 8 NORTH ONC
--10243096, --UVHE 8 WEST STEM CELL
--10243035, --UVHE CORONARY CARE
----10243037, --UVHE LABOR & DELIVERY
----10243038, --UVHE MEDICAL ICU
--10243041, --UVHE NEUR ICU
--10243046, --UVHE SURG TRAM ICU
--10243049  --UVHE TCV POST OP
--)
--         THEN 'Y'
--		 ELSE 'N'
--	   END AS Target_Dept
     , xfers_out.ADT_In_Dt_Out
	 , xfers_out.ADT_Evnt_Out_Nme
	 , xfers_out.sk_Dim_Clrt_DEPt_Out
	 , xfers_out.Clrt_DEPt_Nme_Out
	 , xfers_out.COVID_IND_Out
	 , xfers_out.CARE_UNIT_IND_Out
	 , xfers_out.Target_Dept_Out
     , xfers_in.ADT_In_Dt_In
	 , xfers_in.ADT_Evnt_In_Nme
	 , xfers_in.sk_Dim_Clrt_DEPt_In
	 , xfers_in.Clrt_DEPt_Nme_In
	 , xfers_in.COVID_IND_In
	 , xfers_in.CARE_UNIT_IND_In
	 , xfers_in.Target_Dept_In
	 --, ddte.day_of_week_num
	 --, ddte.day_of_week
--	 , CASE
--		WHEN events.DEPARTMENT_ID IN (
--10243122, --UVHE 3 SOUTH
--10243123, --UVHE 4 SOUTH CVICU
--10243124 --UVHE 5 SOUTH
--)
--        THEN 'COVID'
--		ELSE 'NON-COVID'
--	  END AS COVID_IND
--	 , CASE
--	    WHEN events.DEPARTMENT_ID IN (
--10243089, --UVHE 3 NORTH
--10243123, --UVHE 4 SOUTH CVICU
--10243035, --UVHE CORONARY CARE
--10243038, --UVHE MEDICAL ICU
--10243041, --UVHE NEUR ICU
--10243046, --UVHE SURG TRAM ICU
--10243049  --UVHE TCV POST OP
--)
--        THEN 'ICU'
--	    WHEN events.DEPARTMENT_ID IN (
--10243090, --UVHE 5 NORTH
--10243092, --UVHE 6 NORTH
--10243096  --UVHE 8 WEST STEM CELL
--)
--        THEN 'IMU'
--	    WHEN events.DEPARTMENT_ID IN (
--10243059  --UVHE 5 EAST
--)
--        THEN 'Psych'
--		ELSE 'Acute'
--	  END AS CARE_UNIT_IND

INTO #ip_events_countable

FROM #ip_events events
--LEFT OUTER JOIN @Department tdep
--ON tdep.DepartmentId = events.DEPARTMENT_ID
LEFT OUTER JOIN #ip_xfers_out xfers_out
ON xfers_out.sk_Fact_Pt_Enc_Clrt = events.sk_Fact_Pt_Enc_Clrt
AND xfers_out.PAT_ENC_CSN_ID = events.PAT_ENC_CSN_ID
AND xfers_out.EVENT_ID = events.EVENT_ID
LEFT OUTER JOIN #ip_xfers_in xfers_in
ON xfers_in.sk_Fact_Pt_Enc_Clrt = events.sk_Fact_Pt_Enc_Clrt
AND xfers_in.PAT_ENC_CSN_ID = events.PAT_ENC_CSN_ID
AND xfers_in.EVENT_ID = events.EVENT_ID
--LEFT OUTER JOIN Rptg.vwDim_Date ddte
--ON ddte.day_date = events.ADT_In_Dt
WHERE
--events.DEPARTMENT_ID IN (
--10243051, --UVHE 3 CENTRAL
--10243052, --UVHE 3 EAST
--10243089, --UVHE 3 NORTH
--10243122, --UVHE 3 SOUTH
--10243053, --UVHE 3 WEST
--10243054, --UVHE 4 CENTRAL CV
--10243110, --UVHE 4 CENTRAL TXP
--10243055, --UVHE 4 EAST
----10243091, --UVHE 4 NORTH
--10243123, --UVHE 4 SOUTH CVICU
--10243057, --UVHE 4 WEST
--10243058, --UVHE 5 CENTRAL
--10243059, --UVHE 5 EAST
--10243090, --UVHE 5 NORTH
--10243124, --UVHE 5 SOUTH
--10243060, --UVHE 5 WEST
--10243061, --UVHE 6 CENTRAL
--10243062, --UVHE 6 EAST
--10243092, --UVHE 6 NORTH
--10243063, --UVHE 6 WEST
----10243064, --UVHE 7 CENTRAL
----10243108, --UVHE 7 CIMU
----10243093, --UVHE 7 NORTH
----10243113, --UVHE 7 NORTH OB
----10243065, --UVHE 7 WEST
----10243103, --UVHE 7NORTH ACUTE
----10243094, --UVHE 8 NORTH OB
--10243068, --UVHE 8 WEST
--10243115, --UVHE 8 NORTH ONC
--10243096, --UVHE 8 WEST STEM CELL
--10243035, --UVHE CORONARY CARE
----10243037, --UVHE LABOR & DELIVERY
--10243038, --UVHE MEDICAL ICU
--10243041, --UVHE NEUR ICU
--10243046, --UVHE SURG TRAM ICU
--10243049  --UVHE TCV POST OP
--)
--AND ((ddte.day_date >= @strBegindt) AND (ddte.day_date <= @strEnddt))
--((ddte.day_date >= @strBegindt) AND (ddte.day_date <= @strEnddt))
((events.ADT_In_Dt >= @strBegindt) AND (events.ADT_In_Dt <= @strEnddt))

CREATE INDEX idx_ip_events_countable ON #ip_events_countable (sk_Fact_Pt_Enc_Clrt, PAT_ENC_CSN_ID, EVENT_ID)

--SELECT *
--FROM #ip_events_countable
----WHERE sk_Fact_Pt_Enc_Clrt = 69669618
--ORDER BY sk_Fact_Pt_Enc_Clrt
--       --, ADT_In_Dtm
--	   , Seq_Num_in_Enc

SELECT
  --  COVID_IND
  --, CARE_UNIT_IND
  --, sk_Fact_Pt_Enc_Clrt
    sk_Fact_Pt_Enc_Clrt
  , PAT_ENC_CSN_ID
  , EVENT_ID
  , ADT_Evnt_Nme
  , ADT_In_Dt
  , Seq_Num_in_Enc
  , CASE
	  WHEN ADT_Evnt_Nme = 'Census'
		AND Target_Dept = 'Y'
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
	    AND (Target_Dept_In IS NOT NULL AND Target_Dept_IN = 'Y')
	    THEN 'OR/IR Admits'
	  WHEN ADT_Evnt_Nme = 'Transfer Out'
	        AND Clrt_DEPt_Nme = 'UVHE EMERGENCY DEPT'
            AND Target_Dept_IN = 'Y'
	    THEN 'ED Admits'
	  WHEN (
	        ADT_Evnt_Nme = 'Transfer Out'
		    AND Target_Dept = 'Y'
			AND ((Clrt_DEPt_Nme_In IS NOT NULL) AND (Clrt_DEPt_Nme_In <> Clrt_DEPt_Nme))
            AND Target_Dept_IN = 'Y'
		   )
		   OR
		   (
	        ADT_Evnt_Nme = 'Admission'
		    AND Target_Dept = 'Y'
		   )
	    THEN 'Other Admits'
	  WHEN ADT_Evnt_Nme = 'Transfer In'
	    AND ADT_Evnt_Out_Nme = 'Discharge'
		AND Target_Dept_Out = 'Y'
	    THEN 'Discharge'
	END AS Event_Name
  , CASE
	  WHEN ADT_Evnt_Nme = 'Census'
		AND Target_Dept = 'Y'
	    THEN ADT_In_Dt
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
	    AND (Target_Dept_In IS NOT NULL AND Target_Dept_IN = 'Y')
	    THEN ADT_In_Dt_In
	  WHEN ADT_Evnt_Nme = 'Transfer Out'
	        AND Clrt_DEPt_Nme = 'UVHE EMERGENCY DEPT'
            AND Target_Dept_IN = 'Y'
	    THEN ADT_In_Dt_In
	  WHEN ADT_Evnt_Nme = 'Transfer Out'
		   AND Target_Dept = 'Y'
		   AND ((Clrt_DEPt_Nme_In IS NOT NULL) AND (Clrt_DEPt_Nme_In <> Clrt_DEPt_Nme))
           AND Target_Dept_IN = 'Y'
		THEN ADT_In_Dt_In
	  WHEN ADT_Evnt_Nme = 'Admission'
		   AND Target_Dept = 'Y'
	    THEN ADT_In_Dt
	  WHEN ADT_Evnt_Nme = 'Transfer In'
	    AND ADT_Evnt_Out_Nme = 'Discharge'
		AND Target_Dept_Out = 'Y'
	    THEN ADT_In_Dt_Out
	END AS Event_Date
  , CASE
	  WHEN ADT_Evnt_Nme = 'Census'
		AND Target_Dept = 'Y'
	    THEN COVID_IND
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
	    AND (Target_Dept_In IS NOT NULL AND Target_Dept_IN = 'Y')
	    THEN COVID_IND_In
	  WHEN ADT_Evnt_Nme = 'Transfer Out'
	        AND Clrt_DEPt_Nme = 'UVHE EMERGENCY DEPT'
            AND Target_Dept_IN = 'Y'
	    THEN COVID_IND_In
	  WHEN ADT_Evnt_Nme = 'Transfer Out'
		   AND Target_Dept = 'Y'
		   AND ((Clrt_DEPt_Nme_In IS NOT NULL) AND (Clrt_DEPt_Nme_In <> Clrt_DEPt_Nme))
           AND Target_Dept_IN = 'Y'
		THEN COVID_IND_In
	  WHEN ADT_Evnt_Nme = 'Admission'
		   AND Target_Dept = 'Y'
	    THEN COVID_IND
	  WHEN ADT_Evnt_Nme = 'Transfer In'
	    AND ADT_Evnt_Out_Nme = 'Discharge'
		AND Target_Dept_Out = 'Y'
	    THEN COVID_IND_Out
	END AS Event_COVID_IND
  , CASE
	  WHEN ADT_Evnt_Nme = 'Census'
		AND Target_Dept = 'Y'
	    THEN CARE_UNIT_IND
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
	    AND (Target_Dept_In IS NOT NULL AND Target_Dept_IN = 'Y')
	    THEN CARE_UNIT_IND_In
	  WHEN ADT_Evnt_Nme = 'Transfer Out'
	        AND Clrt_DEPt_Nme = 'UVHE EMERGENCY DEPT'
            AND Target_Dept_IN = 'Y'
	    THEN CARE_UNIT_IND_In
	  WHEN ADT_Evnt_Nme = 'Transfer Out'
		   AND Target_Dept = 'Y'
		   AND ((Clrt_DEPt_Nme_In IS NOT NULL) AND (Clrt_DEPt_Nme_In <> Clrt_DEPt_Nme))
           AND Target_Dept_IN = 'Y'
		THEN CARE_UNIT_IND_In
	  WHEN ADT_Evnt_Nme = 'Admission'
		   AND Target_Dept = 'Y'
	    THEN CARE_UNIT_IND
	  WHEN ADT_Evnt_Nme = 'Transfer In'
	    AND ADT_Evnt_Out_Nme = 'Discharge'
		AND Target_Dept_Out = 'Y'
	    THEN CARE_UNIT_IND_Out
	END AS Event_CARE_UNIT_IND
  , CASE
	  WHEN ADT_Evnt_Nme = 'Census'
		AND Target_Dept = 'Y'
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
	    AND (Target_Dept_In IS NOT NULL AND Target_Dept_IN = 'Y')
	    THEN Clrt_DEPt_Nme_In
	  WHEN ADT_Evnt_Nme = 'Transfer Out'
	        AND Clrt_DEPt_Nme = 'UVHE EMERGENCY DEPT'
            AND Target_Dept_IN = 'Y'
	    THEN Clrt_DEPt_Nme_In
	  WHEN ADT_Evnt_Nme = 'Transfer Out'
		   AND Target_Dept = 'Y'
		   AND ((Clrt_DEPt_Nme_In IS NOT NULL) AND (Clrt_DEPt_Nme_In <> Clrt_DEPt_Nme))
           AND Target_Dept_IN = 'Y'
		THEN Clrt_DEPt_Nme_In
	  WHEN ADT_Evnt_Nme = 'Admission'
		   AND Target_Dept = 'Y'
	    THEN Clrt_DEPt_Nme
	  WHEN ADT_Evnt_Nme = 'Transfer In'
	    AND ADT_Evnt_Out_Nme = 'Discharge'
		AND Target_Dept_Out = 'Y'
	    THEN Clrt_DEPt_Nme_Out
	END AS Event_Clrt_DEPt_Nme

INTO #RptgTemp

FROM #ip_events_countable

SELECT sk_Fact_Pt_Enc_Clrt,
       PAT_ENC_CSN_ID,
       EVENT_ID,
       ADT_Evnt_Nme,
       ADT_In_Dt,
       Seq_Num_in_Enc,
       Event_Name,
       Event_Date,
       Event_COVID_IND,
       Event_CARE_UNIT_IND,
       Event_Clrt_DEPt_Nme,
       ddte.day_of_week_num,
       ddte.day_of_week

INTO #RptgEvents

FROM #RptgTemp
LEFT OUTER JOIN Rptg.vwDim_Date ddte
ON ddte.day_date = Event_Date
WHERE
--sk_Fact_Pt_Enc_Clrt = 69669618
--AND Event_Name IS NOT NULL
Event_Name IS NOT NULL
--ORDER BY sk_Fact_Pt_Enc_Clrt
--       --, ADT_In_Dtm
--	   , Seq_Num_in_Enc
ORDER BY PAT_ENC_CSN_ID
       --, ADT_In_Dtm
	   , Seq_Num_in_Enc

SELECT Event_Name
     , Event_COVID_IND
	 , Event_CARE_UNIT_IND
	 , Event_Date
	 , COUNT(*) AS Event_Count

INTO #RptgSummary

FROM #RptgEvents
GROUP BY Event_Name
       , Event_COVID_IND
	   , Event_CARE_UNIT_IND
	   , Event_Date
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

/*
/* ED/OR/IR Transfers Out */
10243026	UVHE EMERGENCY DEPT
10243080	P1HE PERIOP
10354900	UVBB OPSC
10243012	UVHE CARDIAC CATH LAB
10243911	UVHE ENDOBRONC PROC
10243025	UVHE NEURORADIOLOGY
10243900	UVHE PERIOP
10379900	UVML ENDOBRONC PROC
*/
/*
SELECT COVID_IND AS Covid_Ind
     , CARE_UNIT_IND AS Care_Unit_Ind
	 , DEPARTMENT_ID AS Department_Id
	 , Clrt_DEPt_Nme AS Department
	 , day_of_week_num AS Day_Of_Week_Num
	 , day_of_week AS Day_Of_Week
	 , ADT_In_Dt AS Census_Date
	 , COUNT(*) AS Census
FROM #ip_events_countable
GROUP BY COVID_IND
       , CARE_UNIT_IND
	   , DEPARTMENT_ID
	   , Clrt_DEPt_Nme
	   , day_of_week_num
	   , day_of_week
	   , ADT_In_Dt
--ORDER BY COVID_IND
--       , CARE_UNIT_IND
--	   , DEPARTMENT_ID
--	   , Clrt_DEPt_Nme
--	   , day_of_week_num
--	   , day_of_week
--	   , ADT_In_Dt
ORDER BY COVID_IND
       , CARE_UNIT_IND
	   , DEPARTMENT_ID
	   , Clrt_DEPt_Nme
	   , ADT_In_Dt

/*  build a temp table of admission events for the hospital encounter accounts  */
SELECT distinct ip_events.sk_Fact_Pt_Enc_Clrt
      ,bscm.practice_group_id AS adm_mdm_practice_group_id
      ,bscm.practice_group_name AS adm_mdm_practice_group_name
      ,bscm.service_line_id AS adm_mdm_service_line_id
      ,bscm.service_line AS adm_mdm_service_line
      ,bscm.sub_service_line_id AS adm_mdm_sub_service_line_id
      ,bscm.sub_service_line AS adm_mdm_sub_service_line
      ,bscm.opnl_service_id AS adm_mdm_opnl_service_id
      ,bscm.opnl_service_name AS adm_mdm_opnl_service_name
	  ,bscm.hs_area_id AS adm_mdm_hs_area_id
	  ,bscm.hs_area_name AS adm_mdm_hs_area_name
	  ,bscm.epic_department_name AS adm_mdm_epic_department
	  ,bscm.epic_department_name_external AS adm_mdm_epic_department_external
	  ,physcn.Service_Line AS adm_enc_physician_service
	  ,dadt.ADT_Evnt_Nme AS adm_ADT_Evnt_Nme
	  ,dep.Clrt_DEPt_Nme AS adm_Clrt_DEPt_Nme
	  ,dep.DEPARTMENT_ID AS adm_DEPARTMENT_ID
	  ,rm.Rm_Nme AS adm_Rm_Nme
	  ,bed.Bed_Nme AS adm_Bed_Nme
	  ,loc.LOC_Nme AS adm_LOC_Nme
	  ,ip_events.AdmSeq AS adm_AdmSeq
	  ,ip_events.DschSeq AS adm_DschSeq
  INTO #ip_adm_events
  FROM (SELECT sk_Fact_Pt_Enc_Clrt
             , AdmSeq
			 , DschSeq
			 , sk_Dim_Clrt_ADT_Evnt
			 , sk_Dim_Clrt_DEPt
			 , sk_Dim_Clrt_Rm
			 , sk_Dim_Clrt_Bed
			 , sk_Dim_Clrt_LOCtn
			 , adm_enc_sk_phys_adm
        FROM #ip_events
        WHERE seq <= PostDschSeqLast
		AND EventSeq = 1) ip_events
  LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Clrt_ADT_Evnt dadt
  ON ip_events.sk_Dim_Clrt_ADT_Evnt = dadt.sk_Dim_Clrt_ADT_Evnt
  LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Clrt_DEPt dep
  ON ip_events.sk_Dim_Clrt_DEPt = dep.sk_Dim_Clrt_DEPt
  LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Clrt_Rm rm
  ON ip_events.sk_Dim_Clrt_Rm = rm.sk_Dim_Clrt_Rm
  LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Clrt_Bed bed
  ON ip_events.sk_Dim_Clrt_Bed = bed.sk_Dim_Clrt_Bed
  LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Clrt_LOCtn loc
  ON ip_events.sk_Dim_Clrt_LOCtn = loc.sk_Dim_Clrt_LOCtn
  LEFT OUTER JOIN [DS_HSDW_Prod].[Rptg].[vwRef_MDM_Location_Master_locsvc] AS bscm
  ON dep.DEPARTMENT_ID = bscm.[EPIC_DEPARTMENT_ID]
  LEFT OUTER JOIN (SELECT sk_Dim_Physcn, Service_Line
                   FROM [DS_HSDW_Prod].[Rptg].[vwDim_Physcn]
				   WHERE current_flag = 1) AS physcn
  ON ip_events.adm_enc_sk_phys_adm = physcn.sk_Dim_Physcn
  WHERE ip_events.AdmSeq = 1

CREATE INDEX idx_ip_adm_events1 ON #ip_adm_events (sk_Fact_Pt_Enc_Clrt)


/*  build a temp table of discharge events for the hospital encounter accounts  */
SELECT distinct dsch.sk_Fact_Pt_Enc_Clrt
      ,dsch.prev_mdm_practice_group_id AS dsch_mdm_practice_group_id
	  ,dsch.prev_mdm_practice_group_name AS dsch_mdm_practice_group_name
	  ,dsch.prev_mdm_service_line_id AS dsch_mdm_service_line_id
	  ,dsch.prev_mdm_service_line AS dsch_mdm_service_line
	  ,dsch.prev_mdm_sub_service_line_id AS dsch_mdm_sub_service_line_id
	  ,dsch.prev_mdm_sub_service_line AS dsch_mdm_sub_service_line
	  ,dsch.prev_mdm_opnl_service_id AS dsch_mdm_opnl_service_id
	  ,dsch.prev_mdm_opnl_service_name AS dsch_mdm_opnl_service_name
	  ,dsch.prev_mdm_hs_area_id AS dsch_mdm_hs_area_id
	  ,dsch.prev_mdm_hs_area_name AS dsch_mdm_hs_area_name
	  ,dsch.prev_mdm_epic_department AS dsch_mdm_epic_department
	  ,dsch.prev_mdm_epic_department_external AS dsch_mdm_epic_department_external
	  ,dsch.prev_enc_physician_service AS dsch_enc_physician_service
	  ,dsch.prev_ADT_Evnt_Nme AS dsch_ADT_Evnt_Nme
	  ,dsch.prev_Clrt_DEPt_Nme AS dsch_Clrt_DEPt_Nme
	  ,dsch.prev_DEPARTMENT_ID AS dsch_DEPARTMENT_ID
	  ,dsch.prev_Rm_Nme AS dsch_Rm_Nme
	  ,dsch.prev_Bed_Nme AS dsch_Bed_Nme
	  ,dsch.prev_LOC_Nme AS dsch_LOC_Nme
	  ,dsch.prev_AdmSeq AS dsch_AdmSeq
	  ,dsch.prev_DschSeq AS dsch_DschSeq
  INTO #ip_disch_events
  FROM (SELECT ip_events.sk_Fact_Pt_Enc_Clrt
              ,dsch_events.mdm_practice_group_id
			  ,dsch_events.mdm_practice_group_name
			  ,dsch_events.mdm_service_line_id
			  ,dsch_events.mdm_service_line
			  ,dsch_events.mdm_sub_service_line_id
			  ,dsch_events.mdm_sub_service_line
			  ,dsch_events.mdm_opnl_service_id
			  ,dsch_events.mdm_opnl_service_name
			  ,dsch_events.mdm_hs_area_id
			  ,dsch_events.mdm_hs_area_name
			  ,dsch_events.mdm_epic_department
			  ,dsch_events.mdm_epic_department_external
			  ,dsch_events.enc_physician_service
			  ,dsch_events.sk_Dim_Clrt_ADT_Evnt
			  ,dsch_events.ADT_Evnt_Nme
			  ,dsch_events.Clrt_DEPt_Nme
			  ,dsch_events.DEPARTMENT_ID
			  ,dsch_events.Rm_Nme
			  ,dsch_events.Bed_Nme
			  ,dsch_events.LOC_Nme
			  ,dsch_events.seq
			  ,dsch_events.AdmSeq
			  ,dsch_events.DschSeq
              ,dsch_events.prev_mdm_practice_group_id
			  ,dsch_events.prev_mdm_practice_group_name
			  ,dsch_events.prev_mdm_service_line_id
			  ,dsch_events.prev_mdm_service_line
			  ,dsch_events.prev_mdm_sub_service_line_id
			  ,dsch_events.prev_mdm_sub_service_line
			  ,dsch_events.prev_mdm_opnl_service_id
			  ,dsch_events.prev_mdm_opnl_service_name
			  ,dsch_events.prev_mdm_hs_area_id
			  ,dsch_events.prev_mdm_hs_area_name
			  ,dsch_events.prev_mdm_epic_department
			  ,dsch_events.prev_mdm_epic_department_external
			  ,dsch_events.prev_enc_physician_service
			  ,dsch_events.prev_ADT_Evnt_Nme
			  ,dsch_events.prev_Clrt_DEPt_Nme
			  ,dsch_events.prev_DEPARTMENT_ID
			  ,dsch_events.prev_Rm_Nme
			  ,dsch_events.prev_Bed_Nme
			  ,dsch_events.prev_LOC_Nme
			  ,dsch_events.prev_seq
			  ,dsch_events.prev_AdmSeq
			  ,dsch_events.prev_DschSeq
        FROM (SELECT sk_Fact_Pt_Enc_Clrt
                   , AdmSeq
			       , DschSeq
			       , sk_Dim_Clrt_ADT_Evnt
			       , sk_Dim_Clrt_DEPt
			       , sk_Dim_Clrt_Rm
			       , sk_Dim_Clrt_Bed
			       , sk_Dim_Clrt_LOCtn
			       , adm_enc_sk_phys_adm
              FROM #ip_events
              WHERE EventSeq = 1 -- Exclude duplicate ADT event records
			  AND (((sk_Dim_Clrt_ADT_Evnt = 2) AND (seq <= PostDschSeqLast) AND (PostDischEventSeq = 1)) OR -- First non-post discharge "Discharge" event
				   ((sk_Dim_Clrt_ADT_Evnt <> 2) AND (seq < PostDschSeqLast)))) ip_events -- All other non-post-discharge, non-"Discharge" events
        LEFT OUTER JOIN (SELECT sk_Fact_Pt_Enc_Clrt
		                       ,bscm.practice_group_id AS mdm_practice_group_id
                               ,bscm.practice_group_name AS mdm_practice_group_name
                               ,bscm.service_line_id AS mdm_service_line_id
                               ,bscm.service_line AS mdm_service_line
                               ,bscm.sub_service_line_id AS mdm_sub_service_line_id
                               ,bscm.sub_service_line AS mdm_sub_service_line
                               ,bscm.opnl_service_id AS mdm_opnl_service_id
                               ,bscm.opnl_service_name AS mdm_opnl_service_name
	                           ,bscm.hs_area_id AS mdm_hs_area_id
	                           ,bscm.hs_area_name AS mdm_hs_area_name
							   ,bscm.epic_department_name AS mdm_epic_department
							   ,bscm.epic_department_name_external AS mdm_epic_department_external
							   ,physcn.Service_Line AS enc_physician_service
			                   ,ip.sk_Dim_Clrt_ADT_Evnt
					           ,dadt.ADT_Evnt_Nme AS ADT_Evnt_Nme
					           ,dep.Clrt_DEPt_Nme AS Clrt_DEPt_Nme
					           ,dep.DEPARTMENT_ID AS DEPARTMENT_ID
					           ,rm.Rm_Nme AS Rm_Nme
					           ,bed.Bed_Nme AS Bed_Nme
					           ,loc.LOC_Nme AS LOC_Nme
							   ,ip.seq
							   ,ip.DschSeq
							   ,ip.AdmSeq
					           ,LEAD(bscm.practice_group_id) OVER (PARTITION BY ip.sk_Fact_Pt_Enc_Clrt ORDER BY DschSeq) AS prev_mdm_practice_group_id
					           ,LEAD(bscm.practice_group_name) OVER (PARTITION BY ip.sk_Fact_Pt_Enc_Clrt ORDER BY DschSeq) AS prev_mdm_practice_group_name
					           ,LEAD(bscm.service_line_id) OVER (PARTITION BY ip.sk_Fact_Pt_Enc_Clrt ORDER BY DschSeq) AS prev_mdm_service_line_id
					           ,LEAD(bscm.service_line) OVER (PARTITION BY ip.sk_Fact_Pt_Enc_Clrt ORDER BY DschSeq) AS prev_mdm_service_line
					           ,LEAD(bscm.sub_service_line_id) OVER (PARTITION BY ip.sk_Fact_Pt_Enc_Clrt ORDER BY DschSeq) AS prev_mdm_sub_service_line_id
					           ,LEAD(bscm.sub_service_line) OVER (PARTITION BY ip.sk_Fact_Pt_Enc_Clrt ORDER BY DschSeq) AS prev_mdm_sub_service_line
					           ,LEAD(bscm.opnl_service_id) OVER (PARTITION BY ip.sk_Fact_Pt_Enc_Clrt ORDER BY DschSeq) AS prev_mdm_opnl_service_id
					           ,LEAD(bscm.opnl_service_name) OVER (PARTITION BY ip.sk_Fact_Pt_Enc_Clrt ORDER BY DschSeq) AS prev_mdm_opnl_service_name
					           ,LEAD(bscm.hs_area_id) OVER (PARTITION BY ip.sk_Fact_Pt_Enc_Clrt ORDER BY DschSeq) AS prev_mdm_hs_area_id
					           ,LEAD(bscm.hs_area_name) OVER (PARTITION BY ip.sk_Fact_Pt_Enc_Clrt ORDER BY DschSeq) AS prev_mdm_hs_area_name
					           ,LEAD(bscm.epic_department_name) OVER (PARTITION BY ip.sk_Fact_Pt_Enc_Clrt ORDER BY DschSeq) AS prev_mdm_epic_department
					           ,LEAD(bscm.epic_department_name_external) OVER (PARTITION BY ip.sk_Fact_Pt_Enc_Clrt ORDER BY DschSeq) AS prev_mdm_epic_department_external
					           ,LEAD(physcn.Service_Line) OVER (PARTITION BY ip.sk_Fact_Pt_Enc_Clrt ORDER BY DschSeq) AS prev_enc_physician_service
					           ,LEAD(dadt.ADT_Evnt_Nme) OVER (PARTITION BY ip.sk_Fact_Pt_Enc_Clrt ORDER BY DschSeq) AS prev_ADT_Evnt_Nme
					           ,LEAD(dep.Clrt_DEPt_Nme) OVER (PARTITION BY ip.sk_Fact_Pt_Enc_Clrt ORDER BY DschSeq) AS prev_Clrt_DEPt_Nme
					           ,LEAD(dep.DEPARTMENT_ID) OVER (PARTITION BY ip.sk_Fact_Pt_Enc_Clrt ORDER BY DschSeq) AS prev_DEPARTMENT_ID
					           ,LEAD(rm.Rm_Nme) OVER (PARTITION BY ip.sk_Fact_Pt_Enc_Clrt ORDER BY DschSeq) AS prev_Rm_Nme
					           ,LEAD(bed.Bed_Nme) OVER (PARTITION BY ip.sk_Fact_Pt_Enc_Clrt ORDER BY DschSeq) AS prev_Bed_Nme
					           ,LEAD(loc.LOC_Nme) OVER (PARTITION BY ip.sk_Fact_Pt_Enc_Clrt ORDER BY DschSeq) AS prev_LOC_Nme
					           ,LEAD(ip.seq) OVER (PARTITION BY ip.sk_Fact_Pt_Enc_Clrt ORDER BY DschSeq) AS prev_seq
					           ,LEAD(ip.AdmSeq) OVER (PARTITION BY ip.sk_Fact_Pt_Enc_Clrt ORDER BY DschSeq) AS prev_AdmSeq
					           ,LEAD(ip.DschSeq) OVER (PARTITION BY ip.sk_Fact_Pt_Enc_Clrt ORDER BY DschSeq) AS prev_DschSeq
                         FROM (SELECT sk_Fact_Pt_Enc_Clrt
                                    , AdmSeq
			                        , DschSeq
			                        , sk_Dim_Clrt_ADT_Evnt
			                        , sk_Dim_Clrt_DEPt
			                        , sk_Dim_Clrt_Rm
			                        , sk_Dim_Clrt_Bed
			                        , sk_Dim_Clrt_LOCtn
			                        , adm_enc_sk_phys_adm
									, seq
									, enc_sk_physcn
                               FROM #ip_events
                               WHERE EventSeq = 1 -- Exclude duplicate ADT event records
			                   AND (((sk_Dim_Clrt_ADT_Evnt = 2) AND (seq <= PostDschSeqLast) AND (PostDischEventSeq = 1)) OR -- First non-post discharge "Discharge" event
				                    ((sk_Dim_Clrt_ADT_Evnt <> 2) AND (seq < PostDschSeqLast)))) ip -- All other non-post-discharge, non-"Discharge" events
                         LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Clrt_ADT_Evnt dadt
                         ON ip.sk_Dim_Clrt_ADT_Evnt = dadt.sk_Dim_Clrt_ADT_Evnt
                         LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Clrt_DEPt dep
                         ON ip.sk_Dim_Clrt_DEPt = dep.sk_Dim_Clrt_DEPt
                         LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Clrt_Rm rm
                         ON ip.sk_Dim_Clrt_Rm = rm.sk_Dim_Clrt_Rm
                         LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Clrt_Bed bed
                         ON ip.sk_Dim_Clrt_Bed = bed.sk_Dim_Clrt_Bed
                         LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Clrt_LOCtn loc
                         ON ip.sk_Dim_Clrt_LOCtn = loc.sk_Dim_Clrt_LOCtn
                         LEFT OUTER JOIN [DS_HSDW_Prod].[Rptg].[vwRef_MDM_Location_Master_locsvc] AS bscm
                         ON dep.DEPARTMENT_ID = bscm.[EPIC_DEPARTMENT_ID]
                         LEFT OUTER JOIN (SELECT sk_Dim_Physcn, Service_Line
                                          FROM [DS_HSDW_Prod].[Rptg].[vwDim_Physcn]
				                          WHERE current_flag = 1) AS physcn
                         ON ip.enc_sk_physcn = physcn.sk_Dim_Physcn) dsch_events
        ON ip_events.sk_Fact_Pt_Enc_Clrt = dsch_events.sk_Fact_Pt_Enc_Clrt) dsch
WHERE dsch.sk_Dim_Clrt_ADT_Evnt = 2 -- Discharge

SELECT Rpt.*
     , 'Rptg.uspSrc_PatientDischargeByService_v2' AS [ETL_guid]
	 , GETDATE() AS Load_Dte
 INTO #RptgTemp FROM
 (
 SELECT PAT_ENC_CSN_ID
       ,ip.sk_Fact_Pt_Enc_Clrt
       ,sk_Fact_Pt_Acct
       ,AcctNbr_int
	   ,ip.sk_Dim_Clrt_Pt
	   ,ip.adm_Fyear_num
	   ,ip.dsch_Fyear_num
	   ,ip.adm_fmonth_num
	   ,ip.dsch_fmonth_num
	   ,ip.adm_FYear_name
	   ,ip.dsch_FYear_name
       ,ip.MRN_int
       ,sk_Adm_Dte
       ,sk_Dsch_Dte
       ,IndexAdmission
	   ,ip.sk_Dim_Pt
	   ,ip.adm_enc_sk_phys_adm
	   ,adm_date
	   ,dsch_date
       ,adm_date_time
       ,dsch_date_time
	   ,ip.adm_time
	   ,ip.dsch_time
       ,adm.adm_mdm_practice_group_id
	   ,adm.adm_mdm_practice_group_name
	   ,adm.adm_mdm_service_line_id
	   ,adm.adm_mdm_service_line
	   ,adm.adm_mdm_sub_service_line_id
	   ,adm.adm_mdm_sub_service_line
	   ,adm.adm_mdm_opnl_service_id
	   ,adm.adm_mdm_opnl_service_name
	   ,adm.adm_mdm_hs_area_id
	   ,adm.adm_mdm_hs_area_name
	   ,adm.adm_mdm_epic_department
	   ,adm.adm_mdm_epic_department_external
	   ,adm.adm_ADT_Evnt_Nme
	   ,adm.adm_Clrt_DEPt_Nme
	   ,adm.adm_DEPARTMENT_ID
	   ,adm.adm_Rm_Nme
	   ,adm.adm_Bed_Nme
	   ,adm.adm_LOC_Nme
       ,dsch.dsch_mdm_practice_group_id
	   ,dsch.dsch_mdm_practice_group_name
	   ,dsch.dsch_mdm_service_line_id
	   ,dsch.dsch_mdm_service_line
	   ,dsch.dsch_mdm_sub_service_line_id
	   ,dsch.dsch_mdm_sub_service_line
	   ,dsch.dsch_mdm_opnl_service_id
	   ,dsch.dsch_mdm_opnl_service_name
	   ,dsch.dsch_mdm_hs_area_id
	   ,dsch.dsch_mdm_hs_area_name
	   ,dsch.dsch_mdm_epic_department
	   ,dsch.dsch_mdm_epic_department_external
	   ,dsch.dsch_ADT_Evnt_Nme
	   ,dsch.dsch_Clrt_DEPt_Nme
	   ,dsch.dsch_DEPARTMENT_ID
	   ,dsch.dsch_Rm_Nme
	   ,dsch.dsch_Bed_Nme
	   ,dsch.dsch_LOC_Nme
	   ,HOSP_ADMSSN_STATS_C
	   ,ADMIT_CATEGORY_C
	   ,ADMIT_CATEGORY
	   ,ADM_SOURCE
	   ,HOSP_ADMSN_TYPE
	   ,HOSP_ADMSN_STATUS
	   ,ip.adm_enc_sk_ser
	   ,ip.dsch_enc_sk_ser
	   ,adm_enc_ser.PROV_ID AS adm_enc_provider_id
	   ,dsch_enc_ser.PROV_ID AS dsch_enc_provider_id
	   ,adm_enc_ser.Prov_Nme AS adm_enc_provider_name
	   ,dsch_enc_ser.Prov_Nme AS dsch_enc_provider_name
	   ,ip.enc_sk_physcn
	   ,adm.adm_enc_physician_service AS adm_enc_physcn_Service_Line
	   ,dsch.dsch_enc_physician_service AS dsch_enc_physcn_Service_Line
	   ,ip.adm_atn_prov_sk_ser
	   ,ip.dsch_atn_prov_sk_ser
	   ,adm_atn_prov_ser.PROV_ID AS adm_atn_prov_provider_id
	   ,dsch_atn_prov_ser.PROV_ID AS dsch_atn_prov_provider_id
	   ,adm_atn_prov_ser.Prov_Nme AS adm_atn_prov_provider_name
	   ,dsch_atn_prov_ser.Prov_Nme AS dsch_atn_prov_provider_name
	   ,ip.adm_atn_prov_sk_physcn
	   ,ip.dsch_atn_prov_sk_physcn
	   ,adm_atn_prov_physcn.Service_Line AS adm_atn_prov_physcn_Service_Line
	   ,dsch_atn_prov_physcn.Service_Line AS dsch_atn_prov_physcn_Service_Line
	   ,ip.adt_pt_cls
	   ,ip.ADMIT_CONF_STAT
	   ,ip.ADT_PATIENT_STAT
	   ,ip.sk_Dim_Clrt_Disch_Disp
	   ,ip.DISCH_DISP_C
	   ,Clrt_Disch_Disp
	   ,ACUITY_LEVEL_C AS acuity_level_cde
	   ,Acuity AS acuity_descr
	   ,Progression_Level AS progression_level
	   ,Ordr_Dtm AS dsch_ord_date_time
	   ,dpat.FirstName + ' ' + RTRIM(COALESCE(CASE WHEN dpat.MiddleName = 'Unknown' THEN NULL ELSE dpat.MiddleName END,'')) AS PT_FNAME_MI
	   ,dpat.LastName AS PT_LNAME
	   ,dpat.BirthDate AS BIRTH_DATE
  FROM #ip_accts ip
  LEFT OUTER JOIN #ip_adm_events adm
  ON ip.sk_Fact_Pt_Enc_Clrt = adm.sk_Fact_Pt_Enc_Clrt
  LEFT OUTER JOIN #ip_disch_events dsch
  ON ip.sk_Fact_Pt_Enc_Clrt = dsch.sk_Fact_Pt_Enc_Clrt
  LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Patient dpat
  ON dpat.sk_Dim_Clrt_Pt = ip.sk_Dim_Clrt_Pt
  LEFT OUTER JOIN DS_HSDW_Prod.rptg.vwDim_Clrt_SERsrc AS adm_enc_ser WITH(NOLOCK) ON adm_enc_ser.sk_Dim_Clrt_SERsrc = ip.adm_enc_sk_ser
  LEFT OUTER JOIN DS_HSDW_Prod.rptg.vwDim_Clrt_SERsrc AS dsch_enc_ser WITH(NOLOCK) ON dsch_enc_ser.sk_Dim_Clrt_SERsrc = ip.dsch_enc_sk_ser
  LEFT OUTER JOIN DS_HSDW_Prod.rptg.vwDim_Clrt_SERsrc AS adm_atn_prov_ser WITH(NOLOCK) ON adm_atn_prov_ser.sk_Dim_Clrt_SERsrc = ip.adm_atn_prov_sk_ser
  LEFT OUTER JOIN DS_HSDW_Prod.rptg.vwDim_Clrt_SERsrc AS dsch_atn_prov_ser WITH(NOLOCK) ON dsch_atn_prov_ser.sk_Dim_Clrt_SERsrc = ip.dsch_atn_prov_sk_ser
  LEFT OUTER JOIN (SELECT sk_Dim_Physcn, Service_Line
                   FROM [DS_HSDW_Prod].[Rptg].[vwDim_Physcn]
				   WHERE current_flag = 1) AS adm_atn_prov_physcn
  ON ip.adm_atn_prov_sk_physcn = adm_atn_prov_physcn.sk_Dim_Physcn
  LEFT OUTER JOIN (SELECT sk_Dim_Physcn, Service_Line
                   FROM [DS_HSDW_Prod].[Rptg].[vwDim_Physcn]
				   WHERE current_flag = 1) AS dsch_atn_prov_physcn
  ON ip.dsch_atn_prov_sk_physcn = dsch_atn_prov_physcn.sk_Dim_Physcn
) Rpt





SELECT * FROM #RptgTemp
		ORDER BY sk_Fact_Pt_Enc_Clrt
*/

GO


