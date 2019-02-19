USE [DS_HSODS_Prod]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =================================================================
-- Create procedure uspSrc_PatientDischargeByService_v2
-- =================================================================
--IF EXISTS (SELECT 1
--    FROM INFORMATION_SCHEMA.ROUTINES 
--    WHERE ROUTINE_SCHEMA='Rptg'
--    AND ROUTINE_TYPE='PROCEDURE'
--    AND ROUTINE_NAME='uspSrc_PatientDischargeByService_v2')
--   DROP PROCEDURE Rptg.uspSrc_PatientDischargeByService_v2
--GO

--CREATE PROCEDURE [Rptg].[uspSrc_PatientDischargeByService_v2]
ALTER PROCEDURE [Rptg].[uspSrc_PatientDischargeByService_v2]
(
	@Manual AS VARCHAR(1) = NULL )
	
--WITH EXECUTE AS OWNER
AS

/*******************************************************************************************
WHAT:	[Rptg].[uspSrc_PatientDischargeByService_v2]	

WHO :	Tom Burgan
WHEN:	08/08/2016
WHY :	Patient readmissions
--------------------------------------------------------------------------------------------
INFO:	
	INPUTS:
	        Rptg.vwFact_Pt_Enc_Hsp_Clrt
			Rptg.vwFact_Pt_Enc_Clrt
            Rptg.vwDim_Date
			Rptg.vwDim_Clrt_Admt_Chrcstc
			Rptg.vwDim_Clrt_Disch_Disp
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
			HSTSDSODSSQL.DS_HSODS_Prod.[Rptg].[uspSrc_PatientDischargeByService_v2]
   
--------------------------------------------------------------------------------------------
MODS:
		08/08/2016 - usp created
		09/13/2016 - add logic to include service line designation from Dim_Physcn table
		09/20/2016 - include recent admissions without a discharge; exclde pre-admits
		09/29/2016 - expand window for reportable index discharges and readmissions
		05/22/2017 - change service line mapping table to view vwRef_MDM_Location_Master_locsvc
		06/14/2017 - add Observation patients, add MDM attributes
		06/27/2017 - add Post-Procedure encounters
		07/27/2017 - remove/edit filters for patient class, admit status, admit category;
		             add new sources for attending provider, discharge disposition;
					 add columns for new attending provider, discharge disposition,
					  patient class, patient status, admit confirmation status, acuity,
					  progression level, and discharge order time
		08/16/2017 - remove encounters with only a discharge ADT event
*******************************************************************************************/


DECLARE @CurrentFyear_num AS INTEGER
DECLARE @PreviousFyear_num AS INTEGER
DECLARE @strBegindt AS SMALLDATETIME
DECLARE @strEnddt AS SMALLDATETIME
DECLARE @strDschBegindt AS VARCHAR(19)

SET @CurrentFyear_num = (
	SELECT Fyear_num
	FROM Rptg.vwDim_Date ddte
	WHERE (CONVERT(VARCHAR(10), GETDATE(), 101) = CONVERT(VARCHAR(10), ddte.day_date, 101))
)

SET @PreviousFyear_num = @CurrentFyear_num - 1

-- First day of previous fiscal year
--SET @strBegindt = '7/1/' + CONVERT(VARCHAR(4),@PreviousFyear_num-1) + ' 00:00:00'
---BDD 7/17/2018 changed to go an extra year back in July for balanced scorecard year over year reporting
IF DATEPART(mm,GETDATE()) IN (7,8)
SET @strBegindt = '1/1/' + CONVERT(VARCHAR(4),@PreviousFyear_num-2) + ' 00:00:00'
ELSE
SET @strBegindt = '1/1/' + CONVERT(VARCHAR(4),@PreviousFyear_num-1) + ' 00:00:00'


-- Last day of current fiscal year
SET @strEnddt = DATEADD(MINUTE,-1,'7/1/' + CONVERT(VARCHAR(4),@CurrentFyear_num) + ' 00:00:00')

-- 30-days prior to reporting period begin date
SET @strDschBegindt = DATEADD(DAY, -30, DATEADD(MONTH, DATEDIFF(MONTH,0,@strBegindt), 0))


/*  build a temp table of all valid, non-TCH, inpatient and observation accounts  */
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
      ,CASE
	     WHEN hclrt.[MRN_int] = 0 THEN clrt.MRN_Clrt
		 ELSE hclrt.[MRN_int]
	   END AS MRN_int
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
	  ,CAST(NULL AS INT) AS dsch_atn_prov_sk_ser
	  ,CAST(NULL AS INT) AS dsch_atn_prov_sk_physcn
	  ,CAST(NULL AS INT) AS adm_atn_prov_sk_ser
	  ,CAST(NULL AS INT) AS adm_atn_prov_sk_physcn
	  ,CAST(NULL AS SMALLINT) AS ACUITY_LEVEL_C
	  ,CAST(NULL AS VARCHAR(254)) AS Acuity
	  ,acuity.Msr_Val AS Progression_Level
	  ,ord.sk_Ordr_Dte
	  ,ord.ORDER_PROC_ID
	  ,ord.Ordr_Descr
	  ,ord.sk_Dim_Clrt_EAPrcdr
	  ,ord.Ordr_Dtm
  INTO #ip_accts
  FROM Rptg.vwFact_Pt_Enc_Hsp_Clrt AS hclrt WITH(NOLOCK)
  INNER JOIN Rptg.vwFact_Pt_Enc_Clrt AS clrt WITH(NOLOCK)
  ON hclrt.sk_Fact_Pt_Enc_Clrt = clrt.sk_Fact_Pt_Enc_Clrt
  INNER JOIN Rptg.vwdim_date as adte on hclrt.sk_Adm_Dte = adte.date_key
  INNER JOIN Rptg.vwdim_date as ddte on hclrt.sk_Dsch_Dte = ddte.date_key
  LEFT OUTER JOIN Rptg.vwDim_Clrt_Admt_Chrcstc AS admt
  ON admt.sk_Dim_Clrt_Admt_Chrcstc = hclrt.sk_Dim_Clrt_Admt_Chrcstc
  LEFT OUTER JOIN dbo.Dim_Clrt_Disch_Disp AS ddisp ON ddisp.sk_Dim_Clrt_Disch_Disp = hclrt.sk_Dim_Clrt_Disch_Disp
  LEFT OUTER JOIN (SELECT sk_Fact_Pt_Enc_Clrt
                        , sk_Ordr_Dte
						, Ordr_Dtm
						, ORDER_PROC_ID
						, Ordr_Descr
						, sk_Dim_Clrt_EAPrcdr
						, ROW_NUMBER() OVER (PARTITION BY sk_Fact_Pt_Enc_Clrt ORDER BY Ordr_Dtm DESC) AS 'Ord_Seq'
				   FROM Rptg.vwFact_Ordr_Prcdr
				   WHERE INSTANTIATED_TIME <> '1/1/1900'
				   AND sk_Dim_Clrt_EAPrcdr = 268) ord
  ON (ord.sk_Fact_Pt_Enc_Clrt = hclrt.sk_Fact_Pt_Enc_Clrt) AND ord.Ord_Seq = 1
  LEFT OUTER JOIN (SELECT fsm.sk_Fact_Pt_Enc_Clrt
                        , fsm.Msr_Ent_Dtm
						, fsm.Msr_Val
						, ROW_NUMBER() OVER (PARTITION BY fsm.sk_Fact_Pt_Enc_Clrt ORDER BY fsm.Msr_Rec_Dtm DESC) AS disp_seq
				   FROM Rptg.vwFact_Clrt_Flo_Msr fsm
				   INNER JOIN Rptg.vwDim_Clrt_Flo_GrpRow AS grr	ON grr.sk_Dim_Clrt_Flo_GrpRow = fsm.sk_Dim_Clrt_Flo_GrpRow
				   WHERE grr.FLO_MEAS_ID = '305100299'
				   AND fsm.Msr_Val IN ('D','C')) acuity
  ON (acuity.sk_Fact_Pt_Enc_Clrt = hclrt.sk_Fact_Pt_Enc_Clrt) AND acuity.disp_seq = 1
  WHERE hclrt.ADT_PATIENT_STAT <> 'Hospital Outpatient Visit'
  AND hclrt.ADMIT_CONF_STAT NOT IN ('Canceled')	--Charges are 0.00, in this case may be a pre-admit that was cancelled or pending and never confirmed
  AND   ((ddte.day_date >= @strDschBegindt) -- find previous discharges for these 30-day admissions
	     OR ((ddte.date_key = 19000101)     -- include admissions without a discharge
		     AND ((adte.day_date >= @strDschBegindt)
			      AND (adte.day_date <= CAST(@strEnddt AS DATE)))))

/*  build a temp table of ADT events for the hospital encounter accounts  */
SELECT distinct ip.sk_Fact_Pt_Enc_Clrt
	  ,ip.adm_enc_sk_phys_adm
	  ,ip.enc_sk_physcn
      ,adt.sk_Dim_Clrt_ADT_Evnt
      ,adt.sk_Dim_Clrt_DEPt
      ,adt.sk_Dim_Clrt_Rm
      ,adt.sk_Dim_Clrt_Bed
	  ,adt.sk_Dim_Clrt_LOCtn
	  ,adt.sk_Beg_Dte
	  ,adt.sk_Beg_Tm
	  ,adt.sk_End_Dte
	  ,adt.sk_End_Tm
	  ,adt.IN_DTTM
	  ,adt.OUT_DTTM
	  ,seq
      ,ROW_NUMBER() OVER (PARTITION BY ip.sk_Fact_Pt_Enc_Clrt
                          ORDER BY adt.IN_DTTM, adt.OUT_DTTM) AS AdmSeq
      ,ROW_NUMBER() OVER (PARTITION BY ip.sk_Fact_Pt_Enc_Clrt
                          ORDER BY adt.IN_DTTM DESC, adt.OUT_DTTM DESC) AS DschSeq
  INTO #ip_events
  FROM (SELECT DISTINCT sk_Fact_Pt_Enc_Clrt
					  , adm_enc_sk_phys_adm
					  , enc_sk_physcn
        FROM #ip_accts) ip
  INNER JOIN Rptg.vwFact_Clrt_ADT adt
  ON ip.sk_Fact_Pt_Enc_Clrt = adt.sk_Fact_Pt_Enc_Clrt

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
             , seq
             , AdmSeq
			 , DschSeq
			 , sk_Dim_Clrt_ADT_Evnt
			 , sk_Dim_Clrt_DEPt
			 , sk_Dim_Clrt_Rm
			 , sk_Dim_Clrt_Bed
			 , sk_Dim_Clrt_LOCtn
			 , adm_enc_sk_phys_adm
			 , enc_sk_physcn
        FROM #ip_events
		WHERE NOT ((sk_Dim_Clrt_ADT_Evnt = 2) -- Discharge
		           AND (AdmSeq = 1) -- Encounter ADT event datetime order
				   AND (DschSeq = 1)) -- Encounter ADT event datetime descending order
	   ) ip_events
  LEFT OUTER JOIN rptg.vwDim_Clrt_ADT_Evnt dadt
  ON ip_events.sk_Dim_Clrt_ADT_Evnt = dadt.sk_Dim_Clrt_ADT_Evnt
  LEFT OUTER JOIN rptg.vwDim_Clrt_DEPt dep
  ON ip_events.sk_Dim_Clrt_DEPt = dep.sk_Dim_Clrt_DEPt
  LEFT OUTER JOIN rptg.vwDim_Clrt_Rm rm
  ON ip_events.sk_Dim_Clrt_Rm = rm.sk_Dim_Clrt_Rm
  LEFT OUTER JOIN rptg.vwDim_Clrt_Bed bed
  ON ip_events.sk_Dim_Clrt_Bed = bed.sk_Dim_Clrt_Bed
  LEFT OUTER JOIN rptg.vwDim_Clrt_LOCtn loc
  ON ip_events.sk_Dim_Clrt_LOCtn = loc.sk_Dim_Clrt_LOCtn
  LEFT OUTER JOIN [Rptg].[vwRef_MDM_Location_Master_locsvc] AS bscm
  ON dep.DEPARTMENT_ID = bscm.[EPIC_DEPARTMENT_ID]
  LEFT OUTER JOIN (SELECT sk_Dim_Physcn, Service_Line
                   FROM [DS_HSODS_Prod].[dbo].[Dim_Physcn]
				   WHERE current_flag = 1) AS physcn
  ON ip_events.adm_enc_sk_phys_adm = physcn.sk_Dim_Physcn
  WHERE ip_events.AdmSeq = 1

/*  build a temp table of discharge events for the inpatient accounts  */
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
		           , seq
                   , AdmSeq
			       , DschSeq
			       , sk_Dim_Clrt_ADT_Evnt
			       , sk_Dim_Clrt_DEPt
			       , sk_Dim_Clrt_Rm
			       , sk_Dim_Clrt_Bed
			       , sk_Dim_Clrt_LOCtn
			       , adm_enc_sk_phys_adm
			       , enc_sk_physcn
              FROM #ip_events
		      WHERE NOT ((sk_Dim_Clrt_ADT_Evnt = 2) -- Discharge
		                 AND (AdmSeq = 1) -- Encounter ADT event datetime order
				         AND (DschSeq = 1)) -- Encounter ADT event datetime descending order
	         ) ip_events
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
						            , seq
                                    , AdmSeq
			                        , DschSeq
			                        , sk_Dim_Clrt_ADT_Evnt
			                        , sk_Dim_Clrt_DEPt
			                        , sk_Dim_Clrt_Rm
			                        , sk_Dim_Clrt_Bed
			                        , sk_Dim_Clrt_LOCtn
			                        , adm_enc_sk_phys_adm
			                        , enc_sk_physcn
                               FROM #ip_events
		                       WHERE NOT ((sk_Dim_Clrt_ADT_Evnt = 2) -- Discharge
		                                  AND (AdmSeq = 1) -- Encounter ADT event datetime order
				                          AND (DschSeq = 1)) -- Encounter ADT event datetime descending order
	                          ) ip
                         LEFT OUTER JOIN rptg.vwDim_Clrt_ADT_Evnt dadt
                         ON ip.sk_Dim_Clrt_ADT_Evnt = dadt.sk_Dim_Clrt_ADT_Evnt
                         LEFT OUTER JOIN rptg.vwDim_Clrt_DEPt dep
                         ON ip.sk_Dim_Clrt_DEPt = dep.sk_Dim_Clrt_DEPt
                         LEFT OUTER JOIN rptg.vwDim_Clrt_Rm rm
                         ON ip.sk_Dim_Clrt_Rm = rm.sk_Dim_Clrt_Rm
                         LEFT OUTER JOIN rptg.vwDim_Clrt_Bed bed
                         ON ip.sk_Dim_Clrt_Bed = bed.sk_Dim_Clrt_Bed
                         LEFT OUTER JOIN rptg.vwDim_Clrt_LOCtn loc
                         ON ip.sk_Dim_Clrt_LOCtn = loc.sk_Dim_Clrt_LOCtn
                         LEFT OUTER JOIN [Rptg].[vwRef_MDM_Location_Master_locsvc] AS bscm
                         ON dep.DEPARTMENT_ID = bscm.[EPIC_DEPARTMENT_ID]
                         LEFT OUTER JOIN (SELECT sk_Dim_Physcn, Service_Line
                                          FROM [DS_HSODS_Prod].[dbo].[Dim_Physcn]
				                          WHERE current_flag = 1) AS physcn
                         ON ip.enc_sk_physcn = physcn.sk_Dim_Physcn) dsch_events
        ON ip_events.sk_Fact_Pt_Enc_Clrt = dsch_events.sk_Fact_Pt_Enc_Clrt) dsch
WHERE dsch.DschSeq = 1
AND dsch.sk_Dim_Clrt_ADT_Evnt = 2 -- Discharge

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
	   ,CAST(NULL AS VARCHAR(18)) AS adm_atn_prov_provider_id
	   ,CAST(NULL AS VARCHAR(18)) AS dsch_atn_prov_provider_id
	   ,CAST(NULL AS VARCHAR(200)) AS adm_atn_prov_provider_name
	   ,CAST(NULL AS VARCHAR(200)) AS dsch_atn_prov_provider_name
	   ,ip.adm_atn_prov_sk_physcn
	   ,ip.dsch_atn_prov_sk_physcn
	   ,CAST(NULL AS VARCHAR(150)) AS adm_atn_prov_physcn_Service_Line
	   ,CAST(NULL AS VARCHAR(150)) AS dsch_atn_prov_physcn_Service_Line
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
	   ,dpt.FIRSTNAME + ' ' + RTRIM(COALESCE(CASE WHEN dpt.MIDDLENAME = 'Unknown' THEN NULL ELSE dpt.MIDDLENAME END,'')) AS PT_FNAME_MI
	   ,dpt.LASTNAME AS PT_LNAME
	   ,dpt.BIRTH_DATE
  FROM #ip_accts ip
  LEFT OUTER JOIN #ip_adm_events adm
  ON ip.sk_Fact_Pt_Enc_Clrt = adm.sk_Fact_Pt_Enc_Clrt
  LEFT OUTER JOIN #ip_disch_events dsch
  ON ip.sk_Fact_Pt_Enc_Clrt = dsch.sk_Fact_Pt_Enc_Clrt
  LEFT OUTER JOIN dbo.Dim_Clrt_Pt dpt
  ON (dpt.sk_Dim_Clrt_Pt = ip.sk_Dim_Clrt_Pt)
  LEFT OUTER JOIN rptg.vwDim_Clrt_SERsrc AS adm_enc_ser WITH(NOLOCK) ON adm_enc_ser.sk_Dim_Clrt_SERsrc = ip.adm_enc_sk_ser
  LEFT OUTER JOIN rptg.vwDim_Clrt_SERsrc AS dsch_enc_ser WITH(NOLOCK) ON dsch_enc_ser.sk_Dim_Clrt_SERsrc = ip.dsch_enc_sk_ser
  WHERE ((adm.sk_Fact_Pt_Enc_Clrt IS NOT NULL) OR (dsch.sk_Fact_Pt_Enc_Clrt IS NOT NULL))
) Rpt

----Determine if run is automated or manual
IF @Manual IS NULL	   
	BEGIN
		--Truncate Table DS_HSDM_Prod. Rptg.ACO_DEP_52WK		   
		--Insert Into DS_HSDM_Prod.Rptg.ACO_DEP_52WK
		SELECT * FROM #RptgTemp
		ORDER BY sk_Fact_Pt_Enc_Clrt 
	END 
ELSE
	SELECT * FROM #RptgTemp
	ORDER BY sk_Fact_Pt_Enc_Clrt


GO


