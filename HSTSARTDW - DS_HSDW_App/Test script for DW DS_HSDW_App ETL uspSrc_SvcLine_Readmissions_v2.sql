USE [DS_HSDW_App]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--ALTER PROCEDURE [ETL].[uspSrc_SvcLine_Readmissions_v2]
--(
--    @startdate SMALLDATETIME = NULL
--   ,@enddate SMALLDATETIME = NULL
--)
--AS
/****************************************************************************************************************************************
WHAT: Create procedure ETL.uspSrc_SvcLine_Readmissions_v2
WHO : Li Jin/Dayna Monaghan/Tom Burgan
WHEN: 1/11/2016
WHY : All cause readmissions mapped to service lines
----------------------------------------------------------------------------------------------------------------------------------------
INFO: 
      INPUTS:	DS_HSDW_Prod.Rptg.vwFact_Pt_Acct_Aggr_NonLag
		        DS_HSDW_Prod.Rptg.vwDim_Bed_Unit_Invision
                DS_HSDW_Prod.Rptg.vwfact_pt_dx
                DS_HSDW_Prod.Rptg.vwdim_dx
                DS_HSDW_Prod.Rptg.vwfact_pt_acct_prmrys
                DS_HSDW_Prod.Rptg.vwDim_Clrt_DEPt
				DS_HSDW_Prod.Rptg.vwDim_Clrt_SERsrc
				DS_HSDW_Prod.rptg.vwDim_Physcn
				DS_HSDW_Prod.Rptg.vwFact_Pt_Trnsplnt_Clrt
				DS_HSDW_Prod.Rptg.vwFact_Pt_Enc_Clrt
				DS_HSDW_Prod.Rptg.vwDim_Date
	            DS_HSDW_App.Rptg.PatientDischargeByService_v2
                  
      OUTPUTS:  DS_HSDW_App.ETL.uspSrc_SvcLine_Readmissions_v2
   
----------------------------------------------------------------------------------------------------------------------------------------
MODS: 	01/12/2016--DRM--Correct reference to the mapping table
		01/12/2016--DRM--Change default dates to be start of previous fiscal year to end of current fiscal year; change stored proc name
		01/15/2016--DRM--Filter out TCH admissions/readmissions
		01/20/2016--DRM--Rework logic, basing population on discharges and looking forward to the next admission
		01/20/2016--DRM--Add SET NOCOUNT ON so no messages interfere when Tableau uses the stored proc
		01/20/2016--DRM--Filter out tot_chg_amt=0.00 and admission is cancelled
		01/21/2016--DRM--Filter out Pending admissions and Hospital Outpatient Visits; return epic department name in final result set
		01/29/2016--DRM--change to Rptg.Balanced_ScoreCard_Mapping table
		02/27/2016--DRM--Join to physician mapping table on discharging physician
		03/07/2016--DRM--Change join to physician mapping table from stage to prod
		06/08/2016--DRM--Create CASE statement to handle finance's service line names
		06/13/2016--DRM--Balanced scorecard mapping table now in Rptg schema
		06/29/2016--DRM--Editing CASE statement for handling finance's version of the service line names to accomodate their changes
		08/04/2016--DRM--Add transplant flag
		09/06/2016--TMB--New spec document, allow same-day hospice transfers, include account adm and dsch dates, diagnoses, and units
		09/08/2016--TMB--Add discharge records to readmission record output, change effective reporting period
		09/12/2016--TMB--Change report date for readmissions to be index discharge date, do not exclude readmission accounts
		                 with a discharge disposition equal to "EXPIRED"
		10/07/2016--TMB--Incude recent admissions without a discharge
		10/11/2016--TMB--Change join to Dim_Clrt_Pt, exclude accounts without a value for MRN_int
		10/19/2016--TMB--Added next_Unit_Nme value '5EAS' to filter
		11/01/2016--TMB--Rework logic for identifying physician service line
		06/22/2017--TMB--Use reporting table HSTSDSSQLDM DS_HSDW_App Rptg.PatientDischargeByService, refactor for service line
		                 attribution
		07/07/2017--TMB--Remove filters on tot_chg_amt and HOSP_ADMSSN_STATS_C
		07/12/2017--TMB--Use view Rptg.vwFact_Pt_Acct_Aggr_NonLag
		08/01/2017--TMB--Use new table HSTSDSSQLDM.DS_HSDW_App.Rptg.PatientDischargeByService_v2; Change to filter on
		                 ADT_PT_CLS (Inpatient, Inpatient Psychiatry); add columns inserted into staging table
		08/17/2017--TMB--Exclude events without an hs_area_id value
		08/24/2017--TMB--Add NewBorn to the ADT_PT_CLS filter
		09/07/2017--TMB--Add 'service_line_id' value to extract
		09/20/2017--TMB--Set fmonth_num, fyear_name, and fyear_num values for event dates with no event count
		09/21/2017--TMB--Set service line value to MDM definition
		11/11/2017--DRM--Change transplant surgery date comparison to pick up transplants occurring on day of admission;
						 remove COALESCE for service_line that uses location when discharging physician is missing or the discharging
						 physician does not have a service line assigned 
		12/12/2017 - BDD - add sk_Fact_Pt_Acct and sk_Fact_Pt_Enc_Clrt to the final data flow
		06/12/2018 - DRM - add UVAID; include dx_prio_nbr of 10001; transplant_pt flag logic; remove logic that sets sub service 
						   line based on patient location and set sub service line for children based on age flag 
		09/20/2018 - DRM - Add flags for planned readmissions based on: always planned procedures, potentially planned procedures where
						   the patient does not have an acute diagnosis, always planned diagnoses;
						   fix to window partition for the next admission columns to include encounter sk for when discharge and admit
						   are on the same date
		09/20/2018 - DRM - Add filter to look at principal diagnosis of the readmission for the acute diagnoses list
		10/05/2018 - DRM - Add descriptions of the diagnoses and procedures to the final output
		11/04/2018 - DRM - Remove duplicates caused by multiple planned diagnosis or procedure codes by reporting one per encounter;
						   add new column to signify planned vs. unplanned so Tableau does not need to evaluate the three 
						   planned/potentially planned columns
		11/06/2018 - DRM - Populate sk_Dim_Pt
		11/14/2017 - DRM - Sub-service lines for neurosciences and behavioral health, tweak of women's and children's to define via division
		07/02/2019 - DRM - Organize query for readability and include source for physician data; create temp tables for exclusions to 
							numerator and denominator; add in digestive health (dh) logic for determining sub-service lines and moving dh
							service line logic into the proc
		07/19/2019 - DRM - sync INSERT to SELECT by adding two columns and removing one from the INSERT statement
		07/20/2019 - DRM - Add join to final SELECT to pull in rev location; order final INSERT and SELECT for readability and aliased 
						   final SELECT columns to match INSERT names: 
							rf.Financial_Division         AS financial_division_id
							rf.Financial_SubDivision      AS financial_sub_division_id
							rf.Financial_SubDivision_Name AS financial_sub_division_name
							loc.LOC_ID					  AS rev_location_id
							loc.REV_LOC_NAME			  AS rev_location
							rf.som_group                  AS som_group_name
							rf.som_department             AS som_department_name
			                rf.som_hs_area_id             AS w_som_hs_area_id
							rf.som_hs_area_name           AS w_som_hs_area_name
		07/23/2019 - DRM - Set readmission columns to NULL for the discharges in #RptgFinal to remove duplicates; readmission data should 
						   appear only with the readmissions in #RptgFinal
		10/08/2019 - DRM - Add logic to ensure the same encounter cannot be used as a readmission of itself
		10/15/2019 - DRM - Remove logic that filters out TCH encounters within 30 days
		12/09/2019 - DRM - When a planned readmission occurs between an index discharge and qualifying readmission, the latter readmission
						   will not count as a readmission to the original index discharge.  It can count as a readmission for the 
						   planned readmission when the planned readmission is an index discharge.
		01/06/2020 - DRM - Changed join for building the Readmission category events between dim_date and #RptgFinalBalancedScorecard to 
						   be an INNER join versus a LEFT.  There should be no date filling since the event is either a readmission or not.
						   Date fill can be done for the discharge events to satisfy Tableau.
		03/01/2020 - DRM - Change planned readmission logic: equal to acute and potentially planned procedure becomes not equal to acute
						   and potentially planned procedure; add email addresses for discharging and readmitting physician; rename
						   next_sk_fact_pt_enc_clrt to readmission_admission_sk_Fact_Pt_Enc_Clrt
		09/14/2020 - HRL - Added Oncology flag
        09/18/2020 - BDD - Fixed fyear columns in the final select to use the outer date table in date fill rows
		11/04/2021 - DM2NB-Add ServiceLine_Division
		10/03/2022 - DM2NB-Add is_valid_patient filter
*****************************************************************************************************************************************/

SET NOCOUNT ON;

--DECLARE @startdate SMALLDATETIME = NULL
--       ,@enddate   SMALLDATETIME = NULL;

	/*testing*/
    DECLARE
        @startdate SMALLDATETIME = '10/1/2019'
       ,@enddate SMALLDATETIME = '10/31/2022';
	/*end testing*/

DECLARE @strIndexDischargeBegindt AS VARCHAR(19);


DECLARE @currdate SMALLDATETIME;

SET @currdate = CAST(CAST(GETDATE() AS DATE) AS SMALLDATETIME);


IF @startdate IS NULL
   AND @enddate IS NULL
    EXEC ETL.usp_Get_Dash_Dates_BalancedScorecard @startdate OUTPUT
                                                 ,@enddate OUTPUT;

---BDD 9/18/2019 per Dayna and data viz, move start date back to give 3 years data, back to a fiscal year start date
SET @startdate = DATEADD(mm, -18, @startdate);


----BDD 08/20/2018
---Special handling in August due to this metric being an additional month in arrears. Can't cut off prior FY in the middle so roll it back a year
IF DATEPART(mm, @currdate) = 8
BEGIN
    SET @startdate = DATEADD(yy, -1, @startdate);
---    SET @enddate = DATEADD(yy, -1, @enddate);
END;
-------------------------------------

-- 30-days prior to reporting period begin date
SET @strIndexDischargeBegindt = DATEADD(DAY, -30, DATEADD(MONTH, DATEDIFF(MONTH, 0, @startdate), 0));

if OBJECT_ID('tempdb..#dh_pat') is not NULL
DROP TABLE #dh_pat

if OBJECT_ID('tempdb..#ip_accts') is not NULL
DROP TABLE #ip_accts

if OBJECT_ID('tempdb..#TCH_discharges') is not NULL
DROP TABLE #TCH_discharges

if OBJECT_ID('tempdb..#prior_30_TCHdc') is not NULL
DROP TABLE #prior_30_TCHdc

if OBJECT_ID('tempdb..#Psych_Admissions') is not NULL
DROP TABLE #Psych_Admissions

if OBJECT_ID('tempdb..#sameday_pysch_adm') is not NULL
DROP TABLE #sameday_pysch_adm

if OBJECT_ID('tempdb..#ip_adm_dxs') is not NULL
DROP TABLE #ip_adm_dxs

if OBJECT_ID('tempdb..#ip_dsch_dxs') is not NULL
DROP TABLE #ip_dsch_dxs

if OBJECT_ID('tempdb..#dsch_enc') is not NULL
DROP TABLE #dsch_enc

if OBJECT_ID('tempdb..#readm_enc') is not NULL
DROP TABLE #readm_enc

if OBJECT_ID('tempdb..#planned_enc') is not NULL
DROP TABLE #planned_enc

if OBJECT_ID('tempdb..#ip_accts_dxs') is not NULL
DROP TABLE #ip_accts_dxs

if OBJECT_ID('tempdb..#RptgFinalBalancedScorecard') is not NULL
DROP TABLE #RptgFinalBalancedScorecard

if OBJECT_ID('tempdb..#RptgFinal') is not NULL
DROP TABLE #RptgFinal

SELECT DISTINCT
       pehc.sk_Fact_Pt_Enc_Clrt
      ,con.Consult_Type
INTO #dh_pat
FROM DS_HSDW_Prod.Rptg.vwFact_Pt_Enc_Hsp_Clrt AS pehc
    INNER JOIN DS_HSDW_Prod.Rptg.vwFact_Pt_Dx AS fpd
        ON pehc.sk_Fact_Pt_Acct = fpd.sk_Fact_Pt_Acct
    INNER JOIN DS_HSDW_Prod.Rptg.vwDim_Dx     AS ddx
        ON fpd.sk_Dim_Dx = ddx.sk_dim_dx
    INNER JOIN
    (
        SELECT DISTINCT
               sk_Fact_Pt_Enc_Clrt
              ,'Liver' AS Consult_Type
        FROM DS_HSDW_Prod.Rptg.vwFact_Ordr_Prcdr
        WHERE Ordr_Descr IN ( 'IP CONSULT TO GI/LIVER', 'CONSULT TO GI/LIVER' )
        UNION
        SELECT DISTINCT
               fop.sk_Fact_Pt_Enc_Clrt
              ,'Luminal' AS Consult_Type
        FROM DS_HSDW_Prod.Rptg.vwFact_Ordr_Prcdr AS fop
        WHERE fop.Ordr_Descr IN ( 'IP CONSULT TO DIGESTIVE HEALTH', 'IP CONSULT GI/LUMINAL', 'IP CONSULT TO GI'
                                 ,'IP CONSULT TO GI/LUMINAL', 'CONSULT TO GI/LUMINAL'
                                )
        EXCEPT
        SELECT DISTINCT
               sk_Fact_Pt_Enc_Clrt
              ,'Luminal'
        FROM DS_HSDW_Prod.Rptg.vwFact_Ordr_Prcdr
        WHERE Ordr_Descr IN ( 'IP CONSULT TO GI/LIVER', 'CONSULT TO GI/LIVER' )
    )                                         AS con
        ON pehc.sk_Fact_Pt_Enc_Clrt = con.sk_Fact_Pt_Enc_Clrt
WHERE fpd.Dx_Clasf_Typ_Nme = 'Final Diagnosis'
      AND
      (
          -----------------/* Liver */-----------------
          /* Hepatocellular Carcinoma */
          ddx.Dx_Cde LIKE 'K70%'
          OR ddx.Dx_Cde LIKE 'K71%'
          OR ddx.Dx_Cde LIKE 'K72%'
          OR ddx.Dx_Cde LIKE 'K73%'
          OR ddx.Dx_Cde LIKE 'K74%'
          OR ddx.Dx_Cde LIKE 'K75%'
          OR ddx.Dx_Cde LIKE 'K76%'
          OR ddx.Dx_Cde LIKE 'K77%'
          OR
          /* Ascites */
          ddx.Dx_Cde = 'I50.9'
          OR ddx.Dx_Cde = 'I89.8'
          OR ddx.Dx_Cde = 'R18.8'
          OR
          /* Spontaneous Bacterial Peritonitis */
          ddx.Dx_Cde = 'K65.2'
          OR ddx.Dx_Cde = 'K65.9'
          OR
          /* Esophageal Varices */
          ddx.Dx_Cde LIKE 'I85%'
          OR
          /* Gastric Varices */
          ddx.Dx_Cde = 'I86.4'
          OR
          /* Hepatocellular Carcinoma */
          ddx.Dx_Cde LIKE 'c22%'
          OR ddx.Dx_Cde = 'Z85.05'
          OR
          -----------------/* Luminal */-----------------
          /* Pancreas */
          ddx.Dx_Cde LIKE 'k85%'
          OR ddx.Dx_Cde LIKE 'k86%'
          OR ddx.Dx_Cde LIKE 'k87%'
          OR ddx.Dx_Cde LIKE 'c25%'
          OR
          /* Inflammatory Bowel Disease */
          ddx.Dx_Cde LIKE 'k50%'
          OR ddx.Dx_Cde LIKE 'k51%'
          OR ddx.Dx_Cde LIKE 'k52%'
          OR
          /* Upper GI Illnesses */
          ddx.Dx_Cde LIKE 'k2%'
          OR ddx.Dx_Cde LIKE 'k30%'
          OR ddx.Dx_Cde LIKE 'k31%'
          OR ddx.Dx_Cde LIKE 'k92%'
          OR ddx.Dx_Cde = 'Q27.33'
          OR
          /* Malabsorption/Diarrhea/Constipation */
          ddx.Dx_Cde LIKE 'k90%'
          OR ddx.Dx_Cde = 'R19.7'
          OR ddx.Dx_Cde LIKE 'k58%'
          OR ddx.Dx_Cde LIKE 'k59%'
      );
	  
/*  build a temp table of all valid, non-TCH, inpatient accounts  */
SELECT DISTINCT
    --PatientDischargeByService_v2 PATIENT DATA
       clrt.PT_LNAME
      ,clrt.PT_FNAME_MI
      ,clrt.BIRTH_DATE
      ,clrt.MRN_int   AS MRN_Clrt
      ,clrt.MRN_int
      ,clrt.sk_Dim_Clrt_Pt

                                                 --PatientDischargeByService_v2 ENCOUNTER DATA AND CHARACTERISTICS
      ,clrt.sk_Adm_Dte
      ,clrt.sk_Dsch_Dte
      ,clrt.adm_date
      ,clrt.dsch_date
      ,clrt.adm_date_time
      ,clrt.dsch_date_time
      ,clrt.sk_Fact_Pt_Enc_Clrt
      ,clrt.sk_Fact_Pt_Acct
      ,clrt.AcctNbr_int
      ,clrt.adm_Fyear_num
      ,clrt.adm_fmonth_num
      ,clrt.adm_FYear_name
      ,clrt.dsch_Fyear_num
      ,clrt.dsch_fmonth_num
      ,clrt.dsch_FYear_name
      ,clrt.dsch_date AS IndexDischarge
      ,clrt.adm_date  AS Admission
      ,clrt.adm_LOC_Nme
      ,clrt.dsch_LOC_Nme
      ,clrt.adm_DEPARTMENT_ID
      ,clrt.dsch_DEPARTMENT_ID
      ,clrt.HOSP_ADMSSN_STATS_C
      ,clrt.ADMIT_CATEGORY_C
      ,clrt.ADMIT_CATEGORY
      ,clrt.ADM_SOURCE
      ,clrt.HOSP_ADMSN_TYPE
      ,clrt.HOSP_ADMSN_STATUS
      ,clrt.ADMIT_CONF_STAT
      ,clrt.ADT_PATIENT_STAT
      ,clrt.adt_pt_cls
      ,clrt.sk_Dim_Clrt_Disch_Disp
      ,clrt.DISCH_DISP_C
      ,clrt.Clrt_Disch_Disp

                                                 --PatientDischargeByService_v2 ENCOUNTER PROVIDER DATA
      ,clrt.adm_enc_provider_id                  --source: vwFact_Pt_Enc_Hsp_Clrt.sk_Adm_SERsrc
      ,clrt.adm_enc_provider_name
      ,clrt.adm_enc_physcn_Service_Line
      ,clrt.adm_enc_sk_phys_adm                  --source: vwFact_Pt_Enc_Hsp_Clrt.sk_Phys_Adm

      ,clrt.enc_sk_physcn                        --sourced via vwFact_Pt_Enc_Clrt.sk_Dim_Physcn

      ,clrt.dsch_enc_provider_id                 --source: vwFact_Pt_Enc_Hsp_Clrt.sk_Dsch_SERsrc
      ,clrt.dsch_enc_provider_name
      ,clrt.dsch_enc_physcn_Service_Line
      ,clrt.adm_atn_prov_provider_id             --source: vwFact_Pt_Enc_Atn_Prov_All.sk_Dim_Clrt_SERsrc, sorted ASC on atn_beg_dtm, atn_end_dtm; PROV_ID
      ,clrt.adm_atn_prov_provider_name
      ,clrt.adm_atn_prov_physcn_Service_Line

                                                 --attribution is "discharging physician" determined by last known attending--
      ,clrt.dsch_atn_prov_provider_id            --source: vwFact_Pt_Enc_Atn_Prov_All.sk_Dim_Clrt_SERsrc, sorted DESC on atn_beg_dtm, atn_end_dtm; PROV_ID
      ,clrt.dsch_atn_prov_provider_name
      ,clrt.dsch_atn_prov_physcn_Service_Line
      ,CASE
           WHEN clrt.dsch_atn_prov_sk_physcn > 0
           THEN clrt.dsch_atn_prov_sk_physcn
           ELSE -999
       END            AS dsch_atn_prov_sk_physcn --added sk 6/27/2019

                                                 --PatientDischargeByService_v2 ADMISSION DEPARTMENT data, source: vwFact_Clrt_ADT, vwRef_MDM_Location_Master_locsvc; logic applied to arrive at true admit dept
      ,clrt.adm_mdm_practice_group_id
      ,clrt.adm_mdm_practice_group_name
      ,clrt.adm_mdm_service_line_id
      ,clrt.adm_mdm_service_line
      ,clrt.adm_mdm_sub_service_line_id
      ,clrt.adm_mdm_sub_service_line
      ,clrt.adm_mdm_opnl_service_id
      ,clrt.adm_mdm_opnl_service_name
      ,clrt.adm_mdm_hs_area_id
      ,clrt.adm_mdm_hs_area_name
      ,clrt.adm_mdm_epic_department
      ,clrt.adm_mdm_epic_department_external

                                                 --PatientDischargeByService_v2 DISCHARGE DEPARTMENT DATA, source: vwFact_Clrt_ADT, vwRef_MDM_Location_Master_locsvc; logic applied to arrive at true discharge dept
      ,clrt.dsch_mdm_practice_group_id
      ,clrt.dsch_mdm_practice_group_name
      ,clrt.dsch_mdm_service_line_id
      ,clrt.dsch_mdm_service_line
      ,clrt.dsch_mdm_sub_service_line_id
      ,clrt.dsch_mdm_sub_service_line
      ,clrt.dsch_mdm_opnl_service_id
      ,clrt.dsch_mdm_opnl_service_name
      ,clrt.dsch_mdm_hs_area_id
      ,clrt.dsch_mdm_hs_area_name
      ,clrt.dsch_mdm_epic_department
      ,clrt.dsch_mdm_epic_department_external
                                                 --vwFact_Pt_Acct_Aggr_NonLag DEPARTMENT DATA
      ,aggr.sk_Adm_Bed_Unit_Inv
      ,adm.UNIT       AS adm_Unit
      ,adm.Unit_Nme   AS adm_Unit_Nme
      ,aggr.sk_Dsch_Bed_Unit_Inv
      ,dsch.UNIT      AS dsch_Unit
      ,dsch.Unit_Nme  AS dsch_Unit_Nme

                                                 --vwFact_Pt_Acct_Aggr_NonLag ENCOUNTER DATA
      ,aggr.sk_Phys_Atn
      ,aggr.sk_Dim_Pt
      ,aggr.FY
      ,aggr.Complete
      ,aggr.LOS
      ,aggr.CMI

                                                 --logic to derive a valid sk_Phys_Atn
      ,CASE
           WHEN
           (
               (aggr.sk_Phys_Atn IS NOT NULL)
               AND (aggr.sk_Phys_Atn > 0)
           )
           THEN aggr.sk_Phys_Atn
           WHEN
           (
               (clrt.adm_enc_sk_phys_adm IS NOT NULL)
               AND (clrt.adm_enc_sk_phys_adm > 0)
           )
           THEN clrt.adm_enc_sk_phys_adm
           ELSE -999
       END            AS derived_sk_Phys_Atn
INTO #ip_accts
FROM DS_HSDW_App.Rptg.PatientDischargeByService_v2               AS clrt
    INNER JOIN DS_HSDW_Prod.Rptg.vwDim_Patient                   AS vdp
        ON vdp.sk_Dim_Pt = clrt.sk_Dim_Pt
    LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwFact_Pt_Acct_Aggr_NonLag AS aggr
        ON aggr.sk_Fact_Pt_Acct = clrt.sk_Fact_Pt_Acct
    LEFT OUTER JOIN
    (
        SELECT sk_Dim_Bed_Unit_Inv
              ,UNIT
              ,Unit_Nme
        FROM DS_HSDW_Prod.Rptg.vwDim_Bed_Unit_Invision
        WHERE sk_Dim_Bed_Unit_Inv > 0
    )                                                            AS adm
        ON aggr.sk_Adm_Bed_Unit_Inv = adm.sk_Dim_Bed_Unit_Inv
    LEFT OUTER JOIN
    (
        SELECT sk_Dim_Bed_Unit_Inv
              ,UNIT
              ,Unit_Nme
        FROM DS_HSDW_Prod.Rptg.vwDim_Bed_Unit_Invision
        WHERE sk_Dim_Bed_Unit_Inv > 0
    )                                                            AS dsch
        ON aggr.sk_Dsch_Bed_Unit_Inv = dsch.sk_Dim_Bed_Unit_Inv
WHERE clrt.adt_pt_cls IN ( 'Inpatient', 'Inpatient Psychiatry', 'Newborn' ) --inpatients
      AND
      (
          LEFT(clrt.adm_mdm_epic_department, 2) <> 'TC'
          OR clrt.adm_mdm_epic_department IS NULL
      ) --no TCH
      AND NOT (
                  (clrt.ADMIT_CATEGORY_C = 5) -- Inpatient Pre-admit with no discharge date
                  AND (aggr.sk_Dsch_Dte = 19000101)
              )
      AND
      (
          (clrt.dsch_date >= @strIndexDischargeBegindt) -- Discharge dates with possible readmissions in the reporting period
          OR
          (
              (clrt.sk_Dsch_Dte = 19000101) -- include admissions without a discharge
              AND
              (
                  (clrt.adm_date >= @strIndexDischargeBegindt)
                  AND (clrt.adm_date <= CAST(@enddate AS DATE))
              )
          )
      )
      AND clrt.MRN_int > 0
      AND vdp.IS_VALID_PAT_YN = 'Y';

--table of TCH discharges for determining readmissions within 30 days of a TCH encounter discharge
SELECT TCHdc.MRN_int
      ,TCHdc.dsch_date
INTO #TCH_discharges
FROM DS_HSDW_App.Rptg.PatientDischargeByService_v2 AS TCHdc
WHERE (
          TCHdc.adt_pt_cls = 'TCH Inpatient'
          OR LEFT(TCHdc.adm_mdm_epic_department, 2) = 'TC'
      );

--encounters with a prior TCH discharge within 30 days-not to be counted as a readmission
SELECT DISTINCT
       iab.MRN_int
      ,iab.sk_Fact_Pt_Acct
      ,iab.sk_Fact_Pt_Enc_Clrt
      ,iab.adt_pt_cls
      ,iab.Admission
      ,iab.IndexDischarge
INTO #prior_30_TCHdc
FROM #ip_accts                 AS iab
    INNER JOIN #TCH_discharges AS td
        ON td.MRN_int = iab.MRN_int
           AND td.dsch_date <= iab.adm_date
           AND DATEDIFF(DAY, td.dsch_date, iab.adm_date) <= 30
ORDER BY iab.MRN_int
        ,iab.sk_Fact_Pt_Acct;

--table of admissions to uvhe 5 east;		   
SELECT psychadm.MRN_int
      ,psychadm.IndexAdmission
      ,psychadm.adt_pt_cls
      ,psychadm.adm_mdm_epic_department
INTO #Psych_Admissions
FROM DS_HSDW_App.Rptg.PatientDischargeByService_v2 AS psychadm
WHERE psychadm.adm_mdm_epic_department = 'uvhe 5 east';

--encounters with a same discharge to 5 east-not to be counted as a discharge
SELECT DISTINCT
       iab.MRN_int
      ,iab.sk_Fact_Pt_Acct
      ,iab.sk_Fact_Pt_Enc_Clrt
      ,iab.Admission
      ,iab.IndexDischarge
      ,pa.adt_pt_cls
      ,pa.adm_mdm_epic_department
INTO #sameday_pysch_adm
FROM #ip_accts                   AS iab
    INNER JOIN #Psych_Admissions AS pa
        ON pa.MRN_int = iab.MRN_int
           AND CAST(iab.IndexDischarge AS DATE) = CAST(pa.IndexAdmission AS DATE);

--
--	Admission Diagnosis
--
SELECT DISTINCT
       ddx.Dx_Cde
      ,ddx.Dx_Cde_Dotless
      ,ddx.Dx_Nme
      ,fdx.sk_Fact_Pt_Acct
      ,accts.AcctNbr_int
      ,fdx.Dx_Clasf_cde
      ,fdx.Dx_Prio_Nbr
INTO #ip_adm_dxs
FROM DS_HSDW_Prod.Rptg.vwFact_Pt_Dx            AS fdx WITH (NOLOCK)
    INNER JOIN #ip_accts                       AS accts
        ON accts.sk_Fact_Pt_Acct = fdx.sk_Fact_Pt_Acct
    LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Dx AS ddx WITH (NOLOCK)
        ON fdx.sk_Dim_Dx = ddx.sk_dim_dx
WHERE fdx.Dx_Clasf_cde = 'DA'
      AND fdx.Dx_Prio_Nbr IN ( 1, 10001 );

--
--	Discharge Diagnosis
--
SELECT DISTINCT
       ddx.Dx_Cde
      ,ddx.Dx_Cde_Dotless
      ,ddx.Dx_Nme
      ,prim.sk_Fact_Pt_Acct
      ,accts.AcctNbr_int
INTO #ip_dsch_dxs
FROM DS_HSDW_Prod.Rptg.vwFact_Pt_Acct_Prmrys   AS prim WITH (NOLOCK)
    INNER JOIN #ip_accts                       AS accts
        ON accts.sk_Fact_Pt_Acct = prim.sk_Fact_Pt_Acct
           AND accts.FY = prim.FY
    LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Dx AS ddx WITH (NOLOCK)
        ON prim.sk_Prmry_Dx = ddx.sk_dim_dx
WHERE prim.sk_Prmry_Dx > 100;


/* build a temp table of all encounters valid for a discharge -excludes same day psych, expired disposition discharges, CMS exclusions of the index discharge */
SELECT i.sk_Fact_Pt_Enc_Clrt
INTO #dsch_enc
FROM #ip_accts                         AS i
    LEFT OUTER JOIN #sameday_pysch_adm AS spa
        ON spa.sk_Fact_Pt_Enc_Clrt = i.sk_Fact_Pt_Enc_Clrt
    -- ----------------------------
    -- Identify CMS admission exclusions
    -- ----------------------------
    OUTER APPLY
( --planned_dxs
    SELECT TOP (1)
           vdx.sk_Fact_Pt_Acct
          ,vdx.FY
          ,vdx.sk_Dim_Dx
          ,vdx.Dx_Prio_Nbr
          ,vdx.Dx_Clasf_cde
          ,vdx.Dx_Clasf_Typ_Nme
          ,vdx.sk_Crt_Dte
          ,vdx.sk_Eff_Dte
          ,vdx.DX_DRG_IND
          ,vdx.Dx_POA_Nme
          ,vdx.Dx_POA_Cde
          ,vdx.source_system
          ,vdx.Dx_ICD
          ,vdx.icd_seq
          ,vddx.Dx_Cde
          ,vddx.Dx_Cde_Dotless
          ,vddx.Dx_Nme
          ,vddx.sk_Dx_Grp
          ,vddx.Dx_Grp_Cde
          ,vddx.Dx_Grp_Nme
          ,vddx.sk_Ref_ICD10_Dx_Chapter
          ,vddx.Dx_ICD10_Chptr
          ,vddx.Dx_ICD10_Block_Title
    FROM DS_HSDW_Prod.Rptg.vwFact_Pt_Dx                  AS vdx
        INNER JOIN DS_HSDW_Prod.Rptg.vwDim_Dx            AS vddx
            ON vddx.sk_dim_dx = vdx.sk_Dim_Dx
        INNER JOIN Rptg.Ref_ICD10_Visits_For_Readmission AS vdxr
            ON vddx.Dx_Cde_Dotless = vdxr.ICD10CMCODE
    WHERE vdx.sk_Fact_Pt_Acct = i.sk_Fact_Pt_Acct
          AND vdx.Dx_Clasf_cde IN ( 'DF', 'DE' )
          AND vdx.Dx_Prio_Nbr IN ( 10001, 1 )
    ORDER BY vdx.Dx_Prio_Nbr
)                                      AS cms_visit_dxs
WHERE i.Clrt_Disch_Disp NOT IN ( 'Expired', 'Expired in Medical Facility', '5 East Psych', 'Critical Access Hospital'
                                ,'Federal Hospital', 'Left Against Medical Advice', 'Short Term Hospital'
                               )
      AND spa.sk_Fact_Pt_Enc_Clrt IS NULL --not in the same day psych table
      AND i.IndexDischarge <> '1/1/1900' --must have a discharge date
      AND cms_visit_dxs.sk_Fact_Pt_Acct IS NULL --not one of the CMS exclusions: primary psych dx, rehab, med trmt of cancer
;



/* build a temp table of all accounts valid for a readmission -excludes readmission within 30 days of a TCH discharge and planned readmissions */
SELECT r.PT_LNAME
      ,r.PT_FNAME_MI
      ,r.BIRTH_DATE
      ,r.MRN_Clrt
      ,r.MRN_int
      ,r.sk_Dim_Clrt_Pt
      ,r.sk_Adm_Dte
      ,r.sk_Dsch_Dte
      ,r.adm_date
      ,r.dsch_date
      ,r.adm_date_time
      ,r.dsch_date_time
      ,r.sk_Fact_Pt_Enc_Clrt
      ,r.sk_Fact_Pt_Acct
      ,r.AcctNbr_int
      ,r.adm_Fyear_num
      ,r.adm_fmonth_num
      ,r.adm_FYear_name
      ,r.dsch_Fyear_num
      ,r.dsch_fmonth_num
      ,r.dsch_FYear_name
      ,r.IndexDischarge
      ,r.Admission
      ,r.adm_LOC_Nme
      ,r.dsch_LOC_Nme
      ,r.adm_DEPARTMENT_ID
      ,r.dsch_DEPARTMENT_ID
      ,r.HOSP_ADMSSN_STATS_C
      ,r.ADMIT_CATEGORY_C
      ,r.ADMIT_CATEGORY
      ,r.ADM_SOURCE
      ,r.HOSP_ADMSN_TYPE
      ,r.HOSP_ADMSN_STATUS
      ,r.ADMIT_CONF_STAT
      ,r.ADT_PATIENT_STAT
      ,r.adt_pt_cls
      ,r.sk_Dim_Clrt_Disch_Disp
      ,r.DISCH_DISP_C
      ,r.Clrt_Disch_Disp
      ,r.adm_enc_provider_id
      ,r.adm_enc_provider_name
      ,r.adm_enc_physcn_Service_Line
      ,r.adm_enc_sk_phys_adm
      ,r.enc_sk_physcn
      ,r.dsch_enc_provider_id
      ,r.dsch_enc_provider_name
      ,r.dsch_enc_physcn_Service_Line
      ,r.adm_atn_prov_provider_id
      ,r.adm_atn_prov_provider_name
      ,r.adm_atn_prov_physcn_Service_Line
      ,r.dsch_atn_prov_provider_id
      ,r.dsch_atn_prov_provider_name
      ,r.dsch_atn_prov_physcn_Service_Line
      ,r.dsch_atn_prov_sk_physcn
      ,r.adm_mdm_practice_group_id
      ,r.adm_mdm_practice_group_name
      ,r.adm_mdm_service_line_id
      ,r.adm_mdm_service_line
      ,r.adm_mdm_sub_service_line_id
      ,r.adm_mdm_sub_service_line
      ,r.adm_mdm_opnl_service_id
      ,r.adm_mdm_opnl_service_name
      ,r.adm_mdm_hs_area_id
      ,r.adm_mdm_hs_area_name
      ,r.adm_mdm_epic_department
      ,r.adm_mdm_epic_department_external
      ,r.dsch_mdm_practice_group_id
      ,r.dsch_mdm_practice_group_name
      ,r.dsch_mdm_service_line_id
      ,r.dsch_mdm_service_line
      ,r.dsch_mdm_sub_service_line_id
      ,r.dsch_mdm_sub_service_line
      ,r.dsch_mdm_opnl_service_id
      ,r.dsch_mdm_opnl_service_name
      ,r.dsch_mdm_hs_area_id
      ,r.dsch_mdm_hs_area_name
      ,r.dsch_mdm_epic_department
      ,r.dsch_mdm_epic_department_external
      ,r.sk_Adm_Bed_Unit_Inv
      ,r.adm_Unit
      ,r.adm_Unit_Nme
      ,r.sk_Dsch_Bed_Unit_Inv
      ,r.dsch_Unit
      ,r.dsch_Unit_Nme
      ,r.sk_Phys_Atn
      ,r.sk_Dim_Pt
      ,r.FY
      ,r.Complete
      ,r.LOS
      ,r.CMI
      ,r.derived_sk_Phys_Atn
      ,r.always_planned_procedure
      ,r.always_planned_diagnosis
      ,r.potential_planned_procedure
      ,r.planned_procedure
INTO #readm_enc
FROM
( -- r
    SELECT i.PT_LNAME
          ,i.PT_FNAME_MI
          ,i.BIRTH_DATE
          ,i.MRN_Clrt
          ,i.MRN_int
          ,i.sk_Dim_Clrt_Pt
          ,i.sk_Adm_Dte
          ,i.sk_Dsch_Dte
          ,i.adm_date
          ,i.dsch_date
          ,i.adm_date_time
          ,i.dsch_date_time
          ,i.sk_Fact_Pt_Enc_Clrt
          ,i.sk_Fact_Pt_Acct
          ,i.AcctNbr_int
          ,i.adm_Fyear_num
          ,i.adm_fmonth_num
          ,i.adm_FYear_name
          ,i.dsch_Fyear_num
          ,i.dsch_fmonth_num
          ,i.dsch_FYear_name
          ,i.IndexDischarge
          ,i.Admission
          ,i.adm_LOC_Nme
          ,i.dsch_LOC_Nme
          ,i.adm_DEPARTMENT_ID
          ,i.dsch_DEPARTMENT_ID
          ,i.HOSP_ADMSSN_STATS_C
          ,i.ADMIT_CATEGORY_C
          ,i.ADMIT_CATEGORY
          ,i.ADM_SOURCE
          ,i.HOSP_ADMSN_TYPE
          ,i.HOSP_ADMSN_STATUS
          ,i.ADMIT_CONF_STAT
          ,i.ADT_PATIENT_STAT
          ,i.adt_pt_cls
          ,i.sk_Dim_Clrt_Disch_Disp
          ,i.DISCH_DISP_C
          ,i.Clrt_Disch_Disp
          ,i.adm_enc_provider_id
          ,i.adm_enc_provider_name
          ,i.adm_enc_physcn_Service_Line
          ,i.adm_enc_sk_phys_adm
          ,i.enc_sk_physcn
          ,i.dsch_enc_provider_id
          ,i.dsch_enc_provider_name
          ,i.dsch_enc_physcn_Service_Line
          ,i.adm_atn_prov_provider_id
          ,i.adm_atn_prov_provider_name
          ,i.adm_atn_prov_physcn_Service_Line
          ,i.dsch_atn_prov_provider_id
          ,i.dsch_atn_prov_provider_name
          ,i.dsch_atn_prov_physcn_Service_Line
          ,i.dsch_atn_prov_sk_physcn
          ,i.adm_mdm_practice_group_id
          ,i.adm_mdm_practice_group_name
          ,i.adm_mdm_service_line_id
          ,i.adm_mdm_service_line
          ,i.adm_mdm_sub_service_line_id
          ,i.adm_mdm_sub_service_line
          ,i.adm_mdm_opnl_service_id
          ,i.adm_mdm_opnl_service_name
          ,i.adm_mdm_hs_area_id
          ,i.adm_mdm_hs_area_name
          ,i.adm_mdm_epic_department
          ,i.adm_mdm_epic_department_external
          ,i.dsch_mdm_practice_group_id
          ,i.dsch_mdm_practice_group_name
          ,i.dsch_mdm_service_line_id
          ,i.dsch_mdm_service_line
          ,i.dsch_mdm_sub_service_line_id
          ,i.dsch_mdm_sub_service_line
          ,i.dsch_mdm_opnl_service_id
          ,i.dsch_mdm_opnl_service_name
          ,i.dsch_mdm_hs_area_id
          ,i.dsch_mdm_hs_area_name
          ,i.dsch_mdm_epic_department
          ,i.dsch_mdm_epic_department_external
          ,i.sk_Adm_Bed_Unit_Inv
          ,i.adm_Unit
          ,i.adm_Unit_Nme
          ,i.sk_Dsch_Bed_Unit_Inv
          ,i.dsch_Unit
          ,i.dsch_Unit_Nme
          ,i.sk_Phys_Atn
          ,i.sk_Dim_Pt
          ,i.FY
          ,i.Complete
          ,i.LOS
          ,i.CMI
          ,i.derived_sk_Phys_Atn
          ,CASE
               WHEN planned_pcs.sk_Fact_Pt_Acct IS NOT NULL
               THEN 1
               ELSE 0
           END AS always_planned_procedure
          ,CASE
               WHEN planned_dxs.logic = 'always planned'
               THEN 1
               ELSE 0
           END AS always_planned_diagnosis
          ,CASE
               WHEN planned_dxs.logic = 'acute'
                    AND potential_pcs.sk_Fact_Pt_Acct IS NOT NULL
               THEN 1
               ELSE 0
           END AS potential_planned_procedure
          ,CASE
               WHEN potential_pcs.sk_Fact_Pt_Acct IS NOT NULL
               THEN 1
               ELSE 0
           END AS planned_procedure
    FROM #ip_accts AS i
        --LEFT OUTER JOIN #prior_30_TCHdc AS pth ON pth.sk_Fact_Pt_Enc_Clrt = i.sk_Fact_Pt_Enc_Clrt
        -- ----------------------------
        -- Identify always planned procedures
        -- ----------------------------

        LEFT OUTER JOIN
        ( --planned_pcs
            SELECT --TOP (1)
                prc.sk_Fact_Pt_Acct
               ,prc.FY
               ,prc.sk_Dim_Prcdr
               ,prc.sk_Dim_CPT
               ,prc.Prcdr_Prio_Nbr
               ,dprc.Prcdr_Cde
               ,dprc.Prcdr_ICD
               ,dprc.Prcdr_Cde_Dotless
               ,dprc.Prcdr_Nme
               ,dprc.sk_Prcdr_Fmly
               ,dprc.Prcdr_Fmly_Cde
               ,dprc.Prcdr_Fmly_Nme
               ,dprc.sk_Prcdr_Grp
               ,dprc.Prcdr_Grp_Cde
               ,dprc.Prcdr_Grp_Nme
               ,dprc.sk_Ref_ICD10_Prcdr_Classf
               ,dprc.Prcdr_ICD10_Classf_1_Nme
               ,dprc.sk_Ref_ICD10_Prcdr_Classf_2
               ,dprc.Prcdr_ICD10_Classf_2_Nme
               ,prc.sk_Prcdr_Dte
               ,prc.sk_Dim_Physcn
               ,prc.source_system
            FROM DS_HSDW_Prod.Rptg.vwFact_Pt_Prcdr              AS prc
                INNER JOIN DS_HSDW_Prod.Rptg.vwDim_Prcdr        AS dprc
                    ON dprc.sk_Dim_Prcdr = prc.sk_Dim_Prcdr
                INNER JOIN #ip_accts                            AS ia
                    ON ia.sk_Fact_Pt_Acct = prc.sk_Fact_Pt_Acct
                INNER JOIN Rptg.Ref_ICD10_Procs_For_Readmission AS prcr
                    ON dprc.Prcdr_Cde_Dotless = prcr.ICD10PCSCODE
            WHERE prcr.logic = 'always planned'
        --ORDER BY       prc.sk_Prcdr_Dte DESC
        )          AS planned_pcs
            ON planned_pcs.sk_Fact_Pt_Acct = i.sk_Fact_Pt_Acct
        -- ----------------------------
        -- Identify always planned diagnoses
        -- ----------------------------

        LEFT OUTER JOIN
        ( --planned_dxs
            SELECT --TOP (1)
                dx.sk_Fact_Pt_Acct
               ,dx.FY
               ,dx.sk_Dim_Dx
               ,dx.Dx_Prio_Nbr
               ,dx.Dx_Clasf_cde
               ,dx.Dx_Clasf_Typ_Nme
               ,dx.sk_Crt_Dte
               ,dx.sk_Eff_Dte
               ,dx.DX_DRG_IND
               ,dx.Dx_POA_Nme
               ,dx.Dx_POA_Cde
               ,dx.source_system
               ,dx.Dx_ICD
               ,dx.icd_seq
               ,ddx.Dx_Cde
               ,ddx.Dx_Cde_Dotless
               ,ddx.Dx_Nme
               ,ddx.sk_Dx_Grp
               ,ddx.Dx_Grp_Cde
               ,ddx.Dx_Grp_Nme
               ,ddx.sk_Ref_ICD10_Dx_Chapter
               ,ddx.Dx_ICD10_Chptr
               ,ddx.Dx_ICD10_Block_Title
               ,dxr.logic
            FROM DS_HSDW_Prod.Rptg.vwFact_Pt_Dx                 AS dx
                INNER JOIN DS_HSDW_Prod.Rptg.vwDim_Dx           AS ddx
                    ON ddx.sk_dim_dx = dx.sk_Dim_Dx
                INNER JOIN #ip_accts                            AS ia2
                    ON ia2.sk_Fact_Pt_Acct = dx.sk_Fact_Pt_Acct
                INNER JOIN Rptg.Ref_ICD10_Diags_For_Readmission AS dxr
                    ON ddx.Dx_Cde_Dotless = dxr.ICD10CMCODE
            WHERE dx.Dx_Clasf_cde IN ( 'DF', 'DE' )
                  --AND            dxr.logic = 'always planned'
                  AND dx.Dx_Prio_Nbr IN ( 10001, 1 )
        --ORDER BY       dx.Dx_Prio_Nbr
        )          AS planned_dxs
            ON planned_dxs.sk_Fact_Pt_Acct = i.sk_Fact_Pt_Acct

        -- ----------------------------
        -- Identify potentially planned procedures
        -- ----------------------------

        LEFT OUTER JOIN
        ( --potential_pcs
            SELECT pprc.sk_Fact_Pt_Acct
                  ,pprc.FY
                  ,pprc.sk_Dim_Prcdr
                  ,pprc.sk_Dim_CPT
                  ,pprc.Prcdr_Prio_Nbr
                  ,dpprc.Prcdr_Cde
                  ,dpprc.Prcdr_ICD
                  ,dpprc.Prcdr_Cde_Dotless
                  ,dpprc.Prcdr_Nme
                  ,dpprc.sk_Prcdr_Fmly
                  ,dpprc.Prcdr_Fmly_Cde
                  ,dpprc.Prcdr_Fmly_Nme
                  ,dpprc.sk_Prcdr_Grp
                  ,dpprc.Prcdr_Grp_Cde
                  ,dpprc.Prcdr_Grp_Nme
                  ,dpprc.sk_Ref_ICD10_Prcdr_Classf
                  ,dpprc.Prcdr_ICD10_Classf_1_Nme
                  ,dpprc.sk_Ref_ICD10_Prcdr_Classf_2
                  ,dpprc.Prcdr_ICD10_Classf_2_Nme
                  ,pprc.sk_Prcdr_Dte
                  ,pprc.sk_Dim_Physcn
                  ,pprc.source_system
            FROM DS_HSDW_Prod.Rptg.vwFact_Pt_Prcdr              AS pprc
                INNER JOIN DS_HSDW_Prod.Rptg.vwDim_Prcdr        AS dpprc
                    ON dpprc.sk_Dim_Prcdr = pprc.sk_Dim_Prcdr
                INNER JOIN #ip_accts                            AS ia3
                    ON ia3.sk_Fact_Pt_Acct = pprc.sk_Fact_Pt_Acct
                INNER JOIN Rptg.Ref_ICD10_Procs_For_Readmission AS pprcr
                    ON dpprc.Prcdr_Cde_Dotless = pprcr.ICD10PCSCODE
            WHERE pprcr.logic = 'potentially planned'
        --ORDER BY       pprc.sk_Prcdr_Dte DESC
        )          AS potential_pcs
            ON potential_pcs.sk_Fact_Pt_Acct = i.sk_Fact_Pt_Acct

--WHERE               pth.sk_Fact_Pt_Enc_Clrt IS NULL --no prior TCH within 30 days
) AS r
WHERE r.always_planned_procedure = 0
      AND r.always_planned_diagnosis = 0
      AND r.potential_planned_procedure = 0
      AND r.planned_procedure = 0;

--planned readmissions, used to exclude, per CMS rules, readmissions occurring after a planned readmission within thirty days of the earlier index discharge
SELECT r.PT_LNAME
      ,r.PT_FNAME_MI
      ,r.BIRTH_DATE
      ,r.MRN_Clrt
      ,r.MRN_int
      ,r.sk_Dim_Clrt_Pt
      ,r.sk_Adm_Dte
      ,r.sk_Dsch_Dte
      ,r.adm_date
      ,r.dsch_date
      ,r.adm_date_time
      ,r.dsch_date_time
      ,r.sk_Fact_Pt_Enc_Clrt
      ,r.sk_Fact_Pt_Acct
      ,r.AcctNbr_int
      ,r.adm_Fyear_num
      ,r.adm_fmonth_num
      ,r.adm_FYear_name
      ,r.dsch_Fyear_num
      ,r.dsch_fmonth_num
      ,r.dsch_FYear_name
      ,r.IndexDischarge
      ,r.Admission
      ,r.adm_LOC_Nme
      ,r.dsch_LOC_Nme
      ,r.adm_DEPARTMENT_ID
      ,r.dsch_DEPARTMENT_ID
      ,r.HOSP_ADMSSN_STATS_C
      ,r.ADMIT_CATEGORY_C
      ,r.ADMIT_CATEGORY
      ,r.ADM_SOURCE
      ,r.HOSP_ADMSN_TYPE
      ,r.HOSP_ADMSN_STATUS
      ,r.ADMIT_CONF_STAT
      ,r.ADT_PATIENT_STAT
      ,r.adt_pt_cls
      ,r.sk_Dim_Clrt_Disch_Disp
      ,r.DISCH_DISP_C
      ,r.Clrt_Disch_Disp
      ,r.adm_enc_provider_id
      ,r.adm_enc_provider_name
      ,r.adm_enc_physcn_Service_Line
      ,r.adm_enc_sk_phys_adm
      ,r.enc_sk_physcn
      ,r.dsch_enc_provider_id
      ,r.dsch_enc_provider_name
      ,r.dsch_enc_physcn_Service_Line
      ,r.adm_atn_prov_provider_id
      ,r.adm_atn_prov_provider_name
      ,r.adm_atn_prov_physcn_Service_Line
      ,r.dsch_atn_prov_provider_id
      ,r.dsch_atn_prov_provider_name
      ,r.dsch_atn_prov_physcn_Service_Line
      ,r.dsch_atn_prov_sk_physcn
      ,r.adm_mdm_practice_group_id
      ,r.adm_mdm_practice_group_name
      ,r.adm_mdm_service_line_id
      ,r.adm_mdm_service_line
      ,r.adm_mdm_sub_service_line_id
      ,r.adm_mdm_sub_service_line
      ,r.adm_mdm_opnl_service_id
      ,r.adm_mdm_opnl_service_name
      ,r.adm_mdm_hs_area_id
      ,r.adm_mdm_hs_area_name
      ,r.adm_mdm_epic_department
      ,r.adm_mdm_epic_department_external
      ,r.dsch_mdm_practice_group_id
      ,r.dsch_mdm_practice_group_name
      ,r.dsch_mdm_service_line_id
      ,r.dsch_mdm_service_line
      ,r.dsch_mdm_sub_service_line_id
      ,r.dsch_mdm_sub_service_line
      ,r.dsch_mdm_opnl_service_id
      ,r.dsch_mdm_opnl_service_name
      ,r.dsch_mdm_hs_area_id
      ,r.dsch_mdm_hs_area_name
      ,r.dsch_mdm_epic_department
      ,r.dsch_mdm_epic_department_external
      ,r.sk_Adm_Bed_Unit_Inv
      ,r.adm_Unit
      ,r.adm_Unit_Nme
      ,r.sk_Dsch_Bed_Unit_Inv
      ,r.dsch_Unit
      ,r.dsch_Unit_Nme
      ,r.sk_Phys_Atn
      ,r.sk_Dim_Pt
      ,r.FY
      ,r.Complete
      ,r.LOS
      ,r.CMI
      ,r.derived_sk_Phys_Atn
      ,r.always_planned_procedure
      ,r.always_planned_diagnosis
      ,r.potential_planned_procedure
      ,r.planned_procedure
INTO #planned_enc
FROM
( -- r
    SELECT i.PT_LNAME
          ,i.PT_FNAME_MI
          ,i.BIRTH_DATE
          ,i.MRN_Clrt
          ,i.MRN_int
          ,i.sk_Dim_Clrt_Pt
          ,i.sk_Adm_Dte
          ,i.sk_Dsch_Dte
          ,i.adm_date
          ,i.dsch_date
          ,i.adm_date_time
          ,i.dsch_date_time
          ,i.sk_Fact_Pt_Enc_Clrt
          ,i.sk_Fact_Pt_Acct
          ,i.AcctNbr_int
          ,i.adm_Fyear_num
          ,i.adm_fmonth_num
          ,i.adm_FYear_name
          ,i.dsch_Fyear_num
          ,i.dsch_fmonth_num
          ,i.dsch_FYear_name
          ,i.IndexDischarge
          ,i.Admission
          ,i.adm_LOC_Nme
          ,i.dsch_LOC_Nme
          ,i.adm_DEPARTMENT_ID
          ,i.dsch_DEPARTMENT_ID
          ,i.HOSP_ADMSSN_STATS_C
          ,i.ADMIT_CATEGORY_C
          ,i.ADMIT_CATEGORY
          ,i.ADM_SOURCE
          ,i.HOSP_ADMSN_TYPE
          ,i.HOSP_ADMSN_STATUS
          ,i.ADMIT_CONF_STAT
          ,i.ADT_PATIENT_STAT
          ,i.adt_pt_cls
          ,i.sk_Dim_Clrt_Disch_Disp
          ,i.DISCH_DISP_C
          ,i.Clrt_Disch_Disp
          ,i.adm_enc_provider_id
          ,i.adm_enc_provider_name
          ,i.adm_enc_physcn_Service_Line
          ,i.adm_enc_sk_phys_adm
          ,i.enc_sk_physcn
          ,i.dsch_enc_provider_id
          ,i.dsch_enc_provider_name
          ,i.dsch_enc_physcn_Service_Line
          ,i.adm_atn_prov_provider_id
          ,i.adm_atn_prov_provider_name
          ,i.adm_atn_prov_physcn_Service_Line
          ,i.dsch_atn_prov_provider_id
          ,i.dsch_atn_prov_provider_name
          ,i.dsch_atn_prov_physcn_Service_Line
          ,i.dsch_atn_prov_sk_physcn
          ,i.adm_mdm_practice_group_id
          ,i.adm_mdm_practice_group_name
          ,i.adm_mdm_service_line_id
          ,i.adm_mdm_service_line
          ,i.adm_mdm_sub_service_line_id
          ,i.adm_mdm_sub_service_line
          ,i.adm_mdm_opnl_service_id
          ,i.adm_mdm_opnl_service_name
          ,i.adm_mdm_hs_area_id
          ,i.adm_mdm_hs_area_name
          ,i.adm_mdm_epic_department
          ,i.adm_mdm_epic_department_external
          ,i.dsch_mdm_practice_group_id
          ,i.dsch_mdm_practice_group_name
          ,i.dsch_mdm_service_line_id
          ,i.dsch_mdm_service_line
          ,i.dsch_mdm_sub_service_line_id
          ,i.dsch_mdm_sub_service_line
          ,i.dsch_mdm_opnl_service_id
          ,i.dsch_mdm_opnl_service_name
          ,i.dsch_mdm_hs_area_id
          ,i.dsch_mdm_hs_area_name
          ,i.dsch_mdm_epic_department
          ,i.dsch_mdm_epic_department_external
          ,i.sk_Adm_Bed_Unit_Inv
          ,i.adm_Unit
          ,i.adm_Unit_Nme
          ,i.sk_Dsch_Bed_Unit_Inv
          ,i.dsch_Unit
          ,i.dsch_Unit_Nme
          ,i.sk_Phys_Atn
          ,i.sk_Dim_Pt
          ,i.FY
          ,i.Complete
          ,i.LOS
          ,i.CMI
          ,i.derived_sk_Phys_Atn
          ,CASE
               WHEN planned_pcs.sk_Fact_Pt_Acct IS NOT NULL
               THEN 1
               ELSE 0
           END AS always_planned_procedure
          ,CASE
               WHEN planned_dxs.logic = 'always planned'
               THEN 1
               ELSE 0
           END AS always_planned_diagnosis
          ,CASE
               WHEN planned_dxs.logic <> 'acute'
                    AND potential_pcs.sk_Fact_Pt_Acct IS NOT NULL
               THEN 1
               ELSE 0
           END AS potential_planned_procedure
          ,CASE
               WHEN potential_pcs.sk_Fact_Pt_Acct IS NOT NULL
               THEN 1
               ELSE 0
           END AS planned_procedure
    FROM #ip_accts AS i
        --LEFT OUTER JOIN #prior_30_TCHdc AS pth ON pth.sk_Fact_Pt_Enc_Clrt = i.sk_Fact_Pt_Enc_Clrt
        -- ----------------------------
        -- Identify always planned procedures
        -- ----------------------------

        LEFT OUTER JOIN
        ( --planned_pcs
            SELECT --TOP (1)
                prc.sk_Fact_Pt_Acct
               ,prc.FY
               ,prc.sk_Dim_Prcdr
               ,prc.sk_Dim_CPT
               ,prc.Prcdr_Prio_Nbr
               ,dprc.Prcdr_Cde
               ,dprc.Prcdr_ICD
               ,dprc.Prcdr_Cde_Dotless
               ,dprc.Prcdr_Nme
               ,dprc.sk_Prcdr_Fmly
               ,dprc.Prcdr_Fmly_Cde
               ,dprc.Prcdr_Fmly_Nme
               ,dprc.sk_Prcdr_Grp
               ,dprc.Prcdr_Grp_Cde
               ,dprc.Prcdr_Grp_Nme
               ,dprc.sk_Ref_ICD10_Prcdr_Classf
               ,dprc.Prcdr_ICD10_Classf_1_Nme
               ,dprc.sk_Ref_ICD10_Prcdr_Classf_2
               ,dprc.Prcdr_ICD10_Classf_2_Nme
               ,prc.sk_Prcdr_Dte
               ,prc.sk_Dim_Physcn
               ,prc.source_system
            FROM DS_HSDW_Prod.Rptg.vwFact_Pt_Prcdr              AS prc
                INNER JOIN DS_HSDW_Prod.Rptg.vwDim_Prcdr        AS dprc
                    ON dprc.sk_Dim_Prcdr = prc.sk_Dim_Prcdr
                INNER JOIN #ip_accts                            AS ia
                    ON ia.sk_Fact_Pt_Acct = prc.sk_Fact_Pt_Acct
                INNER JOIN Rptg.Ref_ICD10_Procs_For_Readmission AS prcr
                    ON dprc.Prcdr_Cde_Dotless = prcr.ICD10PCSCODE
            WHERE prcr.logic = 'always planned'
        --ORDER BY       prc.sk_Prcdr_Dte DESC
        )          AS planned_pcs
            ON planned_pcs.sk_Fact_Pt_Acct = i.sk_Fact_Pt_Acct
        -- ----------------------------
        -- Identify always planned diagnoses
        -- ----------------------------

        LEFT OUTER JOIN
        ( --planned_dxs
            SELECT --TOP (1)
                dx.sk_Fact_Pt_Acct
               ,dx.FY
               ,dx.sk_Dim_Dx
               ,dx.Dx_Prio_Nbr
               ,dx.Dx_Clasf_cde
               ,dx.Dx_Clasf_Typ_Nme
               ,dx.sk_Crt_Dte
               ,dx.sk_Eff_Dte
               ,dx.DX_DRG_IND
               ,dx.Dx_POA_Nme
               ,dx.Dx_POA_Cde
               ,dx.source_system
               ,dx.Dx_ICD
               ,dx.icd_seq
               ,ddx.Dx_Cde
               ,ddx.Dx_Cde_Dotless
               ,ddx.Dx_Nme
               ,ddx.sk_Dx_Grp
               ,ddx.Dx_Grp_Cde
               ,ddx.Dx_Grp_Nme
               ,ddx.sk_Ref_ICD10_Dx_Chapter
               ,ddx.Dx_ICD10_Chptr
               ,ddx.Dx_ICD10_Block_Title
               ,dxr.logic
            FROM DS_HSDW_Prod.Rptg.vwFact_Pt_Dx                 AS dx
                INNER JOIN DS_HSDW_Prod.Rptg.vwDim_Dx           AS ddx
                    ON ddx.sk_dim_dx = dx.sk_Dim_Dx
                INNER JOIN #ip_accts                            AS ia2
                    ON ia2.sk_Fact_Pt_Acct = dx.sk_Fact_Pt_Acct
                INNER JOIN Rptg.Ref_ICD10_Diags_For_Readmission AS dxr
                    ON ddx.Dx_Cde_Dotless = dxr.ICD10CMCODE
            WHERE dx.Dx_Clasf_cde IN ( 'DF', 'DE' )
                  --AND            dxr.logic = 'always planned'
                  AND dx.Dx_Prio_Nbr IN ( 10001, 1 )
        --ORDER BY       dx.Dx_Prio_Nbr
        )          AS planned_dxs
            ON planned_dxs.sk_Fact_Pt_Acct = i.sk_Fact_Pt_Acct

        -- ----------------------------
        -- Identify potentially planned procedures
        -- ----------------------------

        LEFT OUTER JOIN
        ( --potential_pcs
            SELECT pprc.sk_Fact_Pt_Acct
                  ,pprc.FY
                  ,pprc.sk_Dim_Prcdr
                  ,pprc.sk_Dim_CPT
                  ,pprc.Prcdr_Prio_Nbr
                  ,dpprc.Prcdr_Cde
                  ,dpprc.Prcdr_ICD
                  ,dpprc.Prcdr_Cde_Dotless
                  ,dpprc.Prcdr_Nme
                  ,dpprc.sk_Prcdr_Fmly
                  ,dpprc.Prcdr_Fmly_Cde
                  ,dpprc.Prcdr_Fmly_Nme
                  ,dpprc.sk_Prcdr_Grp
                  ,dpprc.Prcdr_Grp_Cde
                  ,dpprc.Prcdr_Grp_Nme
                  ,dpprc.sk_Ref_ICD10_Prcdr_Classf
                  ,dpprc.Prcdr_ICD10_Classf_1_Nme
                  ,dpprc.sk_Ref_ICD10_Prcdr_Classf_2
                  ,dpprc.Prcdr_ICD10_Classf_2_Nme
                  ,pprc.sk_Prcdr_Dte
                  ,pprc.sk_Dim_Physcn
                  ,pprc.source_system
            FROM DS_HSDW_Prod.Rptg.vwFact_Pt_Prcdr              AS pprc
                INNER JOIN DS_HSDW_Prod.Rptg.vwDim_Prcdr        AS dpprc
                    ON dpprc.sk_Dim_Prcdr = pprc.sk_Dim_Prcdr
                INNER JOIN #ip_accts                            AS ia3
                    ON ia3.sk_Fact_Pt_Acct = pprc.sk_Fact_Pt_Acct
                INNER JOIN Rptg.Ref_ICD10_Procs_For_Readmission AS pprcr
                    ON dpprc.Prcdr_Cde_Dotless = pprcr.ICD10PCSCODE
            WHERE pprcr.logic = 'potentially planned'
        )          AS potential_pcs
            ON potential_pcs.sk_Fact_Pt_Acct = i.sk_Fact_Pt_Acct
) AS r
WHERE r.always_planned_procedure = 1
      OR r.always_planned_diagnosis = 1
      OR r.potential_planned_procedure = 1
      OR r.planned_procedure = 1;



/*  build a temp table of all valid, non-TCH, inpatient accounts with diagnoses with next admission data  */
--DROP TABLE IF EXISTS #ip_accts_dxs_bsc;
SELECT --PATIENT
    accts.PT_LNAME
   ,accts.PT_FNAME_MI
   ,accts.BIRTH_DATE
   ,dim_pt.Clrt_Sex                             AS gender
   ,accts.MRN_Clrt
   ,accts.MRN_int
   ,accts.sk_Dim_Clrt_Pt
   ,accts.sk_Dim_Pt
   --ENCOUNTER
   ,accts.sk_Adm_Dte
   ,accts.sk_Dsch_Dte
   ,accts.sk_Fact_Pt_Enc_Clrt
   ,accts.sk_Fact_Pt_Acct
   ,accts.AcctNbr_int
   ,accts.FY
   ,accts.adm_Fyear_num
   ,accts.adm_fmonth_num
   ,accts.adm_FYear_name
   ,accts.dsch_Fyear_num
   ,accts.dsch_fmonth_num
   ,accts.dsch_FYear_name
   ,accts.Complete
   ,accts.LOS
   ,accts.CMI
   ,accts.IndexDischarge
   ,accts.Admission
   ,accts.HOSP_ADMSSN_STATS_C
   ,accts.ADMIT_CATEGORY_C
   ,accts.ADMIT_CATEGORY
   ,accts.ADM_SOURCE
   ,accts.HOSP_ADMSN_TYPE
   ,accts.HOSP_ADMSN_STATUS
   ,accts.ADMIT_CONF_STAT
   ,accts.ADT_PATIENT_STAT
   ,accts.adt_pt_cls
   ,accts.Clrt_Disch_Disp
   ,adxs.dx_cde                                 AS adm_dx_cde
   ,adxs.dx_nme                                 AS adm_dx_nme
   ,ddxs.dx_cde                                 AS dsch_dx_cde
   ,ddxs.dx_nme                                 AS dsch_dx_nme
   --DEPARTMENT
   ,accts.sk_Adm_Bed_Unit_Inv
   ,accts.sk_Dsch_Bed_Unit_Inv
   ,accts.adm_LOC_Nme
   ,accts.dsch_LOC_Nme
   ,accts.adm_DEPARTMENT_ID
   ,accts.dsch_DEPARTMENT_ID
   ,admdep.Clrt_DEPt_Nme                        AS adm_Clrt_DEPt_Nme
   ,dschdep.Clrt_DEPt_Nme                       AS dsch_Clrt_DEPt_Nme
   ,CASE
        WHEN
        (
            (accts.adm_Unit IS NOT NULL)
            AND (accts.adm_Unit <> 'NA')
        )
        THEN accts.adm_Unit
        WHEN
        (
            (accts.adm_Unit IS NOT NULL)
            AND (accts.adm_Unit = 'NA')
            AND
            (
                (accts.adm_DEPARTMENT_ID IS NOT NULL)
                AND (accts.adm_DEPARTMENT_ID >= 0)
            )
        )
        THEN admdep.Clrt_DEPt_Nme
        WHEN
        (
            (accts.adm_Unit IS NULL)
            AND
            (
                (accts.adm_DEPARTMENT_ID IS NOT NULL)
                AND (accts.adm_DEPARTMENT_ID >= 0)
            )
        )
        THEN admdep.Clrt_DEPt_Nme
        ELSE NULL
    END                                         AS adm_Unit
   ,CASE
        WHEN
        (
            (accts.adm_Unit_Nme IS NOT NULL)
            AND (accts.adm_Unit_Nme <> 'Unknown')
        )
        THEN accts.adm_Unit_Nme
        WHEN
        (
            (accts.adm_Unit_Nme IS NOT NULL)
            AND (accts.adm_Unit_Nme = 'Unknown')
            AND
            (
                (accts.adm_DEPARTMENT_ID IS NOT NULL)
                AND (accts.adm_DEPARTMENT_ID >= 0)
            )
        )
        THEN admdep.Clrt_DEPt_Ext_Nme
        WHEN
        (
            (accts.adm_Unit_Nme IS NULL)
            AND
            (
                (accts.adm_DEPARTMENT_ID IS NOT NULL)
                AND (accts.adm_DEPARTMENT_ID >= 0)
            )
        )
        THEN admdep.Clrt_DEPt_Ext_Nme
        ELSE NULL
    END                                         AS adm_Unit_Nme
   ,CASE
        WHEN
        (
            (accts.dsch_Unit IS NOT NULL)
            AND (accts.dsch_Unit <> 'NA')
        )
        THEN accts.dsch_Unit
        WHEN
        (
            (accts.dsch_Unit IS NOT NULL)
            AND (accts.dsch_Unit = 'NA')
            AND
            (
                (accts.dsch_DEPARTMENT_ID IS NOT NULL)
                AND (accts.dsch_DEPARTMENT_ID >= 0)
            )
        )
        THEN dschdep.Clrt_DEPt_Nme
        WHEN
        (
            (accts.dsch_Unit IS NULL)
            AND
            (
                (accts.dsch_DEPARTMENT_ID IS NOT NULL)
                AND (accts.dsch_DEPARTMENT_ID >= 0)
            )
        )
        THEN dschdep.Clrt_DEPt_Nme
        ELSE NULL
    END                                         AS dsch_Unit
   ,CASE
        WHEN
        (
            (accts.dsch_Unit_Nme IS NOT NULL)
            AND (accts.dsch_Unit_Nme <> 'Unknown')
        )
        THEN accts.dsch_Unit_Nme
        WHEN
        (
            (accts.dsch_Unit_Nme IS NOT NULL)
            AND (accts.dsch_Unit_Nme = 'Unknown')
            AND
            (
                (accts.dsch_DEPARTMENT_ID IS NOT NULL)
                AND (accts.dsch_DEPARTMENT_ID >= 0)
            )
        )
        THEN dschdep.Clrt_DEPt_Ext_Nme
        WHEN
        (
            (accts.dsch_Unit_Nme IS NULL)
            AND
            (
                (accts.dsch_DEPARTMENT_ID IS NOT NULL)
                AND (accts.dsch_DEPARTMENT_ID >= 0)
            )
        )
        THEN dschdep.Clrt_DEPt_Ext_Nme
        ELSE NULL
    END                                         AS dsch_Unit_Nme
   --PROVIDER
   ,CASE
        WHEN accts.adm_atn_prov_provider_id IS NOT NULL
        THEN accts.adm_atn_prov_provider_id
        WHEN accts.adm_enc_provider_id IS NOT NULL
             AND accts.adm_enc_provider_id <> 'Unknown'
        THEN accts.adm_enc_provider_id
        WHEN accts.derived_sk_Phys_Atn <> -999
        THEN ser.PROV_ID
        ELSE 'Unknown'
    END                                         AS adm_provider_id
   ,CASE
        WHEN accts.adm_atn_prov_provider_id IS NOT NULL
        THEN accts.adm_atn_prov_provider_name
        WHEN accts.adm_enc_provider_id IS NOT NULL
             AND accts.adm_enc_provider_id <> 'Unknown'
        THEN accts.adm_enc_provider_name
        WHEN accts.derived_sk_Phys_Atn <> -999
        THEN ser.Prov_Nme
        ELSE 'Unknown'
    END                                         AS adm_provider_name
   ,CASE
        WHEN accts.adm_atn_prov_provider_id IS NOT NULL
        THEN accts.adm_atn_prov_physcn_Service_Line
        WHEN accts.adm_enc_provider_id IS NOT NULL
             AND accts.adm_enc_provider_id <> 'Unknown'
        THEN accts.adm_enc_physcn_Service_Line
        WHEN accts.derived_sk_Phys_Atn <> -999
        THEN phys.Service_Line
        ELSE 'Unknown'
    END                                         AS adm_physcn_service_line
   ,CASE
        WHEN accts.sk_Dsch_Dte = 19000101
        THEN 'Unknown'
        WHEN accts.dsch_atn_prov_provider_id IS NOT NULL
        THEN accts.dsch_atn_prov_provider_id
        ELSE 'Unknown'
    END                                         AS dsch_provider_id
   ,CASE
        WHEN accts.sk_Dsch_Dte = 19000101
        THEN 'Unknown'
        WHEN accts.dsch_atn_prov_provider_id IS NOT NULL
        THEN accts.dsch_atn_prov_provider_name
        ELSE 'Unknown'
    END                                         AS dsch_provider_name
   --new columns 6/27/2019 based on dsch_atn_prov_sk_physcn, including SOM
   ,physsvc.hs_area_id                          AS dsch_physcn_hs_area_id
   ,physsvc.hs_area_name                        AS dsch_physcn_hs_area_name
   ,physsvc.Service_Line_ID                     AS dsch_physcn_service_line_id
   ,physsvc.Service_Line                        AS dsch_physcn_service_line
   ,physsvc.Opnl_Service_Line_ID                AS dsch_physcn_opnl_service_line_id
   ,physsvc.Opnl_Service_Line                   AS dsch_physcn_opnl_service_line
   ,physsvc.som_hs_area_id                      AS dsch_physcn_som_hs_area_id
   ,physsvc.som_hs_area_name                    AS dsch_physcn_som_hs_area_name
   ,physsvc.SOM_Group_ID                        AS dsch_physcn_som_group_id
   ,physsvc.SOM_Group                           AS dsch_physcn_som_group
   ,physsvc.SOM_department_id                   AS dsch_physcn_som_department_id
   ,physsvc.SOM_department                      AS dsch_physcn_som_department
   ,physsvc.SOM_division_5                      AS dsch_physcn_som_division_id
   ,physsvc.SOM_division_name                   AS dsch_physcn_som_division_name
   ,physsvc.SOM_division_name_id                AS dsch_physcn_som_division_name_id
   ,physsvc.Clrt_Financial_Division             AS dsch_physcn_financial_division
   ,physsvc.Clrt_Financial_Division_Name        AS dsch_physcn_financial_division_name
   ,physsvc.Clrt_Financial_SubDivision          AS dsch_physcn_financial_subdivision
   ,physsvc.Clrt_Financial_SubDivision_Name     AS dsch_physcn_financial_subdivision_name
   ,physsvc.sk_Dim_Physcn                       AS dsch_physcn_sk_Dim_Physcn
   ,physsvc.UVaID                               AS dsch_physcn_UVaID
   --end new columns

   ,accts.adm_enc_sk_phys_adm
   ,accts.enc_sk_physcn
   ,accts.sk_Phys_Atn
   ,accts.derived_sk_Phys_Atn
   --ADMISSION DEPARTMENT MAPPINGS
   ,accts.adm_mdm_practice_group_id
   ,accts.adm_mdm_practice_group_name
   ,accts.adm_mdm_service_line_id
   ,accts.adm_mdm_service_line
   ,accts.adm_mdm_sub_service_line_id
   ,accts.adm_mdm_sub_service_line
   ,accts.adm_mdm_opnl_service_id
   ,accts.adm_mdm_opnl_service_name
   ,accts.adm_mdm_hs_area_id
   ,accts.adm_mdm_hs_area_name
   ,accts.adm_mdm_epic_department
   ,accts.adm_mdm_epic_department_external
   --DISCHARGE DEPARTMENT MAPPINGS
   ,accts.dsch_mdm_practice_group_id
   ,accts.dsch_mdm_practice_group_name
   ,accts.dsch_mdm_service_line_id
   ,accts.dsch_mdm_service_line
   ,accts.dsch_mdm_sub_service_line_id
   ,accts.dsch_mdm_sub_service_line
   ,accts.dsch_mdm_opnl_service_id
   ,accts.dsch_mdm_opnl_service_name
   ,accts.dsch_mdm_hs_area_id
   ,accts.dsch_mdm_hs_area_name
   ,accts.dsch_mdm_epic_department
   ,accts.dsch_mdm_epic_department_external
   --NEXT ADMISSION data
   ,readm_enc.sk_Adm_Dte                        AS next_sk_Adm_Dte
   ,readm_enc.sk_Dsch_Dte                       AS next_sk_Dsch_Dte
   ,readm_enc.sk_Fact_Pt_Enc_Clrt               AS next_sk_Fact_Pt_Enc_Clrt
   ,readm_enc.AcctNbr_int                       AS next_AcctNbr_int
   ,readm_enc.adm_Fyear_num                     AS next_adm_Fyear_num
   ,readm_enc.adm_fmonth_num                    AS next_adm_fmonth_num
   ,readm_enc.adm_FYear_name                    AS next_adm_FYear_name
   ,readm_enc.dsch_Fyear_num                    AS next_dsch_fyear_num
   ,readm_enc.dsch_fmonth_num                   AS next_dsch_fmonth_num
   ,readm_enc.dsch_FYear_name                   AS next_dsch_fYear_name
   ,readm_enc.IndexDischarge                    AS next_IndexDischarge
   ,readm_enc.Admission                         AS next_Admission
   ,readm_enc.sk_Adm_Bed_Unit_Inv               AS next_sk_Adm_Bed_Unit_Inv
   ,readm_enc.sk_Dsch_Bed_Unit_Inv              AS next_sk_Dsch_Bed_Unit_Inv
   ,readm_enc.adm_Unit                          AS next_adm_Unit
   ,readm_enc.adm_Unit_Nme                      AS next_adm_Unit_Nme
   ,readm_enc.adm_LOC_Nme                       AS next_adm_LOC_Nme
   ,readm_enc.dsch_LOC_Nme                      AS next_dsch_LOC_Nme
   ,readm_enc.adm_DEPARTMENT_ID                 AS next_adm_DEPARTMENT_ID
   ,readm_enc.dsch_DEPARTMENT_ID                AS next_dsch_DEPARTMENT_ID
   ,readm_admdep.Clrt_DEPt_Nme                  AS next_adm_Clrt_DEPt_Nme
   ,readm_dschdep.Clrt_DEPt_Nme                 AS next_dsch_Clrt_DEPt_Nme
   ,readm_enc.HOSP_ADMSSN_STATS_C               AS next_HOSP_ADMSSN_STATS_C
   ,readm_enc.ADMIT_CATEGORY_C                  AS next_ADMIT_CATEGORY_C
   ,readm_enc.ADMIT_CATEGORY                    AS next_ADMIT_CATEGORY
   ,readm_enc.ADM_SOURCE                        AS next_ADM_SOURCE
   ,readm_enc.HOSP_ADMSN_TYPE                   AS next_HOSP_ADMSN_TYPE
   ,readm_enc.HOSP_ADMSN_STATUS                 AS next_HOSP_ADMSN_STATUS
   ,readm_enc.ADMIT_CONF_STAT                   AS next_ADMIT_CONF_STAT
   ,readm_enc.ADT_PATIENT_STAT                  AS next_ADT_PATIENT_STAT
   ,readm_enc.adt_pt_cls                        AS next_adt_pt_cls
   ,CASE
        WHEN readm_enc.adm_atn_prov_provider_id IS NOT NULL
        THEN readm_enc.adm_atn_prov_provider_id
        WHEN readm_enc.adm_enc_provider_id IS NOT NULL
             AND readm_enc.adm_enc_provider_id <> 'Unknown'
        THEN readm_enc.adm_enc_provider_id
        WHEN readm_enc.derived_sk_Phys_Atn <> -999
        THEN readm_ser.PROV_ID
        ELSE 'Unknown'
    END                                         AS next_adm_provider_id
   ,CASE
        WHEN readm_enc.adm_atn_prov_provider_id IS NOT NULL
        THEN readm_enc.adm_atn_prov_provider_name
        WHEN readm_enc.adm_enc_provider_id IS NOT NULL
             AND readm_enc.adm_enc_provider_id <> 'Unknown'
        THEN readm_enc.adm_enc_provider_name
        WHEN readm_enc.derived_sk_Phys_Atn <> -999
        THEN readm_ser.Prov_Nme
        ELSE 'Unknown'
    END                                         AS next_adm_provider_name
   ,CASE
        WHEN readm_enc.sk_Dsch_Dte = 19000101
        THEN 'Unknown'
        WHEN readm_enc.dsch_atn_prov_provider_id IS NOT NULL
        THEN readm_enc.dsch_atn_prov_provider_id
        ELSE 'Unknown'
    END                                         AS next_dsch_provider_id
   ,CASE
        WHEN readm_enc.sk_Dsch_Dte = 19000101
        THEN 'Unknown'
        WHEN readm_enc.dsch_atn_prov_provider_id IS NOT NULL
        THEN readm_enc.dsch_atn_prov_provider_name
        ELSE 'Unknown'
    END                                         AS next_dsch_provider_name
   ,readm_enc.adm_enc_sk_phys_adm               AS next_adm_enc_sk_phys_adm
   ,readm_enc.enc_sk_physcn                     AS next_enc_sk_physcn
   ,readm_enc.sk_Phys_Atn                       AS next_sk_Phys_Atn
   ,readm_enc.derived_sk_Phys_Atn               AS next_derived_sk_Phys_Atn
   ,readm_enc.adm_mdm_practice_group_id         AS next_adm_mdm_practice_group_id
   ,readm_enc.adm_mdm_practice_group_name       AS next_adm_mdm_practice_group_name
   ,readm_enc.adm_mdm_service_line_id           AS next_adm_mdm_service_line_id
   ,readm_enc.adm_mdm_service_line              AS next_adm_mdm_service_line
   ,readm_enc.adm_mdm_sub_service_line_id       AS next_adm_mdm_sub_service_line_id
   ,readm_enc.adm_mdm_sub_service_line          AS next_adm_mdm_sub_service_line
   ,readm_enc.adm_mdm_opnl_service_id           AS next_adm_mdm_opnl_service_id
   ,readm_enc.adm_mdm_opnl_service_name         AS next_adm_mdm_opnl_service_name
   ,readm_enc.adm_mdm_hs_area_id                AS next_adm_mdm_hs_area_id
   ,readm_enc.adm_mdm_hs_area_name              AS next_adm_mdm_hs_area_name
   ,readm_enc.adm_mdm_epic_department           AS next_adm_mdm_epic_department
   ,readm_enc.adm_mdm_epic_department_external  AS next_adm_mdm_epic_department_external
   ,CASE
        WHEN readm_enc.adm_atn_prov_provider_id IS NOT NULL
        THEN readm_enc.adm_atn_prov_physcn_Service_Line
        WHEN readm_enc.adm_enc_provider_id IS NOT NULL
             AND readm_enc.adm_enc_provider_id <> 'Unknown'
        THEN readm_enc.adm_enc_physcn_Service_Line
        WHEN readm_enc.derived_sk_Phys_Atn <> -999
        THEN readm_phys.Service_Line
        ELSE 'Unknown'
    END                                         AS next_adm_physcn_service_line
   ,readm_enc.dsch_mdm_practice_group_id        AS next_dsch_mdm_practice_group_id
   ,readm_enc.dsch_mdm_practice_group_name      AS next_dsch_mdm_practice_group_name
   ,readm_enc.dsch_mdm_service_line_id          AS next_dsch_mdm_service_line_id
   ,readm_enc.dsch_mdm_service_line             AS next_dsch_mdm_service_line
   ,readm_enc.dsch_mdm_sub_service_line_id      AS next_dsch_mdm_sub_service_line_id
   ,readm_enc.dsch_mdm_sub_service_line         AS next_dsch_mdm_sub_service_line
   ,readm_enc.dsch_mdm_opnl_service_id          AS next_dsch_mdm_opnl_service_id
   ,readm_enc.dsch_mdm_opnl_service_name        AS next_dsch_mdm_opnl_service_name
   ,readm_enc.dsch_mdm_hs_area_id               AS next_dsch_mdm_hs_area_id
   ,readm_enc.dsch_mdm_hs_area_name             AS next_dsch_mdm_hs_area_name
   ,readm_enc.dsch_mdm_epic_department          AS next_dsch_mdm_epic_department
   ,readm_enc.dsch_mdm_epic_department_external AS next_dsch_mdm_epic_department_external
   ,readm_physsvc.Service_Line_ID               AS next_dsch_physcn_service_line_id
   ,readm_physsvc.Service_Line                  AS next_dsch_physcn_service_line
   ,readm_adxs.dx_cde                           AS next_adm_dx_cde
   ,readm_adxs.dx_nme                           AS next_adm_dx_nme
INTO #ip_accts_dxs
FROM #ip_accts                                              AS accts
    INNER JOIN #dsch_enc                                    AS de
        ON de.sk_Fact_Pt_Enc_Clrt = accts.sk_Fact_Pt_Enc_Clrt
    LEFT OUTER JOIN #ip_adm_dxs                             AS adxs
        ON adxs.sk_Fact_Pt_Acct = accts.sk_Fact_Pt_Acct
    LEFT OUTER JOIN #ip_dsch_dxs                            AS ddxs
        ON ddxs.sk_Fact_Pt_Acct = accts.sk_Fact_Pt_Acct
    LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Clrt_DEPt       AS admdep WITH (NOLOCK)
        ON admdep.DEPARTMENT_ID = accts.adm_DEPARTMENT_ID
    LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Clrt_DEPt       AS dschdep WITH (NOLOCK)
        ON dschdep.DEPARTMENT_ID = accts.dsch_DEPARTMENT_ID
    LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Clrt_SERsrc     AS ser WITH (NOLOCK)
        ON ser.sk_Dim_Physcn = accts.derived_sk_Phys_Atn
    LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Physcn          AS phys WITH (NOLOCK)
        ON phys.sk_Dim_Physcn = accts.derived_sk_Phys_Atn
    LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwRef_Physcn_Combined AS physsvc
        ON physsvc.sk_Dim_Physcn = accts.dsch_atn_prov_sk_physcn
    LEFT OUTER JOIN #readm_enc                              AS readm_enc
        ON readm_enc.sk_Dim_Pt = accts.sk_Dim_Pt
           AND readm_enc.adm_date_time >= accts.IndexDischarge
           AND readm_enc.sk_Fact_Pt_Enc_Clrt <> accts.sk_Fact_Pt_Enc_Clrt
    LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Clrt_DEPt       AS readm_admdep WITH (NOLOCK)
        ON readm_admdep.DEPARTMENT_ID = readm_enc.adm_DEPARTMENT_ID
    LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Clrt_DEPt       AS readm_dschdep WITH (NOLOCK)
        ON readm_dschdep.DEPARTMENT_ID = readm_enc.dsch_DEPARTMENT_ID
    LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Clrt_SERsrc     AS readm_ser WITH (NOLOCK)
        ON readm_ser.sk_Dim_Physcn = readm_enc.derived_sk_Phys_Atn
    LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Physcn          AS readm_phys WITH (NOLOCK)
        ON readm_phys.sk_Dim_Physcn = readm_enc.derived_sk_Phys_Atn
    LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwRef_Physcn_Combined AS readm_physsvc
        ON readm_physsvc.sk_Dim_Physcn = readm_enc.dsch_atn_prov_sk_physcn
    LEFT OUTER JOIN #ip_adm_dxs                             AS readm_adxs
        ON readm_adxs.sk_Fact_Pt_Acct = readm_enc.sk_Fact_Pt_Acct
    LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Clrt_Pt         AS dim_pt
        ON dim_pt.MRN_Clrt = accts.MRN_Clrt;

--calc duration between index discharge and first occurring readmission 
SELECT DISTINCT
       final.sk_Adm_Dte
      ,final.sk_Dsch_Dte
      ,final.sk_Fact_Pt_Enc_Clrt
      ,final.sk_Fact_Pt_Acct
      ,final.AcctNbr_int
      ,final.PT_LNAME
      ,final.PT_FNAME_MI
      ,final.BIRTH_DATE
      ,final.gender
      ,final.sk_Dim_Pt
      ,final.MRN_Clrt
      ,final.adm_Fyear_num
      ,final.adm_fmonth_num
      ,final.adm_FYear_name
      ,final.dsch_Fyear_num
      ,final.dsch_fmonth_num
      ,final.dsch_FYear_name
      ,final.IndexDischarge
      ,final.Admission
      ,final.sk_Adm_Bed_Unit_Inv
      ,final.sk_Dsch_Bed_Unit_Inv
      ,final.adm_Unit
      ,final.adm_Unit_Nme
      ,final.dsch_Unit
      ,final.dsch_Unit_Nme
      ,final.adm_LOC_Nme
      ,final.dsch_LOC_Nme
      ,final.adm_DEPARTMENT_ID
      ,final.dsch_DEPARTMENT_ID
      ,final.adm_Clrt_DEPt_Nme
      ,final.dsch_Clrt_DEPt_Nme
      ,final.HOSP_ADMSSN_STATS_C
      ,final.ADMIT_CATEGORY_C
      ,final.ADMIT_CATEGORY
      ,final.ADM_SOURCE
      ,final.HOSP_ADMSN_TYPE
      ,final.HOSP_ADMSN_STATUS
      ,final.ADMIT_CONF_STAT
      ,final.ADT_PATIENT_STAT
      ,final.adt_pt_cls
      ,final.adm_provider_id
      ,final.adm_provider_name
      ,final.dsch_provider_id
      ,final.dsch_provider_name
      ,final.adm_enc_sk_phys_adm
      ,final.enc_sk_physcn
      ,final.sk_Phys_Atn
      ,final.derived_sk_Phys_Atn
      ,final.Clrt_Disch_Disp
      ,final.adm_mdm_practice_group_id
      ,final.adm_mdm_practice_group_name
      ,final.adm_mdm_service_line_id
      ,final.adm_mdm_service_line
      ,final.adm_mdm_sub_service_line_id
      ,final.adm_mdm_sub_service_line
      ,final.adm_mdm_opnl_service_id
      ,final.adm_mdm_opnl_service_name
      ,final.adm_mdm_hs_area_id
      ,final.adm_mdm_hs_area_name
      ,final.adm_mdm_epic_department
      ,final.adm_mdm_epic_department_external
      ,final.adm_physcn_service_line
      ,final.dsch_mdm_practice_group_id
      ,final.dsch_mdm_practice_group_name
      ,final.dsch_mdm_service_line_id
      ,final.dsch_mdm_service_line
      ,final.dsch_mdm_sub_service_line_id
      ,final.dsch_mdm_sub_service_line
      ,final.dsch_mdm_opnl_service_id
      ,final.dsch_mdm_opnl_service_name
      ,final.dsch_mdm_hs_area_id
      ,final.dsch_mdm_hs_area_name
      ,final.dsch_mdm_epic_department
      ,final.dsch_mdm_epic_department_external
      ,final.dsch_physcn_hs_area_id
      ,final.dsch_physcn_hs_area_name
      ,final.dsch_physcn_service_line_id
      ,final.dsch_physcn_service_line
      ,final.dsch_physcn_opnl_service_line_id
      ,final.dsch_physcn_opnl_service_line
      ,final.dsch_physcn_som_hs_area_id
      ,final.dsch_physcn_som_hs_area_name
      ,final.dsch_physcn_som_group_id
      ,final.dsch_physcn_som_group
      ,final.dsch_physcn_som_department_id
      ,final.dsch_physcn_som_department
      ,final.dsch_physcn_som_division_id
      ,final.dsch_physcn_som_division_name
      ,final.dsch_physcn_som_division_name_id
      ,final.dsch_physcn_financial_division
      ,final.dsch_physcn_financial_division_name
      ,final.dsch_physcn_financial_subdivision
      ,final.dsch_physcn_financial_subdivision_name
      ,final.dsch_physcn_sk_Dim_Physcn
      ,final.dsch_physcn_UVaID
      ,final.adm_dx_cde
      ,final.adm_dx_nme
      ,final.dsch_dx_cde
      ,final.dsch_dx_nme
      ,FIRST_VALUE(final.next_sk_Adm_Dte) OVER (PARTITION BY final.sk_Fact_Pt_Enc_Clrt
                                                ORDER BY final.next_Admission
                                                ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                               )                                     AS next_sk_Adm_Dte
      ,FIRST_VALUE(final.next_sk_Dsch_Dte) OVER (PARTITION BY final.sk_Fact_Pt_Enc_Clrt
                                                 ORDER BY final.next_Admission
                                                 ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                                )                                    AS next_sk_Dsch_Dte
      ,FIRST_VALUE(final.next_sk_Fact_Pt_Enc_Clrt) OVER (PARTITION BY final.sk_Fact_Pt_Enc_Clrt
                                                         ORDER BY final.next_Admission
                                                         ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                                        )                            AS next_sk_Fact_Pt_Enc_Clrt
      ,FIRST_VALUE(final.next_AcctNbr_int) OVER (PARTITION BY final.sk_Fact_Pt_Enc_Clrt
                                                 ORDER BY final.next_Admission
                                                 ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                                )                                    AS next_AcctNbr_int
      ,FIRST_VALUE(final.next_adm_Fyear_num) OVER (PARTITION BY final.sk_Fact_Pt_Enc_Clrt
                                                   ORDER BY final.next_Admission
                                                   ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                                  )                                  AS next_adm_Fyear_num
      ,FIRST_VALUE(final.next_adm_fmonth_num) OVER (PARTITION BY final.sk_Fact_Pt_Enc_Clrt
                                                    ORDER BY final.next_Admission
                                                    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                                   )                                 AS next_adm_fmonth_num
      ,FIRST_VALUE(final.next_adm_FYear_name) OVER (PARTITION BY final.sk_Fact_Pt_Enc_Clrt
                                                    ORDER BY final.next_Admission
                                                    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                                   )                                 AS next_adm_FYear_name
      ,FIRST_VALUE(final.next_dsch_fyear_num) OVER (PARTITION BY final.sk_Fact_Pt_Enc_Clrt
                                                    ORDER BY final.next_Admission
                                                    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                                   )                                 AS next_dsch_fyear_num
      ,FIRST_VALUE(final.next_dsch_fmonth_num) OVER (PARTITION BY final.sk_Fact_Pt_Enc_Clrt
                                                     ORDER BY final.next_Admission
                                                     ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                                    )                                AS next_dsch_fmonth_num
      ,FIRST_VALUE(final.next_dsch_fYear_name) OVER (PARTITION BY final.sk_Fact_Pt_Enc_Clrt
                                                     ORDER BY final.next_Admission
                                                     ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                                    )                                AS next_dsch_fYear_name
      ,FIRST_VALUE(final.next_IndexDischarge) OVER (PARTITION BY final.sk_Fact_Pt_Enc_Clrt
                                                    ORDER BY final.next_Admission
                                                    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                                   )                                 AS next_IndexDischarge
      ,FIRST_VALUE(final.next_Admission) OVER (PARTITION BY final.sk_Fact_Pt_Enc_Clrt
                                               ORDER BY final.next_Admission
                                               ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                              )                                      AS next_Admission
      ,FIRST_VALUE(final.next_sk_Adm_Bed_Unit_Inv) OVER (PARTITION BY final.sk_Fact_Pt_Enc_Clrt
                                                         ORDER BY final.next_Admission
                                                         ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                                        )                            AS next_sk_Adm_Bed_Unit_Inv
      ,FIRST_VALUE(final.next_sk_Dsch_Bed_Unit_Inv) OVER (PARTITION BY final.sk_Fact_Pt_Enc_Clrt
                                                          ORDER BY final.next_Admission
                                                          ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                                         )                           AS next_sk_Dsch_Bed_Unit_Inv
      ,FIRST_VALUE(final.next_adm_Unit) OVER (PARTITION BY final.sk_Fact_Pt_Enc_Clrt
                                              ORDER BY final.next_Admission
                                              ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                             )                                       AS next_adm_Unit
      ,FIRST_VALUE(final.next_adm_Unit_Nme) OVER (PARTITION BY final.sk_Fact_Pt_Enc_Clrt
                                                  ORDER BY final.next_Admission
                                                  ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                                 )                                   AS next_adm_Unit_Nme
      ,FIRST_VALUE(final.next_adm_LOC_Nme) OVER (PARTITION BY final.sk_Fact_Pt_Enc_Clrt
                                                 ORDER BY final.next_Admission
                                                 ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                                )                                    AS next_adm_LOC_Nme
      ,FIRST_VALUE(final.next_dsch_LOC_Nme) OVER (PARTITION BY final.sk_Fact_Pt_Enc_Clrt
                                                  ORDER BY final.next_Admission
                                                  ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                                 )                                   AS next_dsch_LOC_Nme
      ,FIRST_VALUE(final.next_adm_DEPARTMENT_ID) OVER (PARTITION BY final.sk_Fact_Pt_Enc_Clrt
                                                       ORDER BY final.next_Admission
                                                       ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                                      )                              AS next_adm_DEPARTMENT_ID
      ,FIRST_VALUE(final.next_dsch_DEPARTMENT_ID) OVER (PARTITION BY final.sk_Fact_Pt_Enc_Clrt
                                                        ORDER BY final.next_Admission
                                                        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                                       )                             AS next_dsch_DEPARTMENT_ID
      ,FIRST_VALUE(final.next_adm_Clrt_DEPt_Nme) OVER (PARTITION BY final.sk_Fact_Pt_Enc_Clrt
                                                       ORDER BY final.next_Admission
                                                       ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                                      )                              AS next_adm_Clrt_DEPt_Nme
      ,FIRST_VALUE(final.next_dsch_Clrt_DEPt_Nme) OVER (PARTITION BY final.sk_Fact_Pt_Enc_Clrt
                                                        ORDER BY final.next_Admission
                                                        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                                       )                             AS next_dsch_Clrt_DEPt_Nme
      ,FIRST_VALUE(final.next_HOSP_ADMSSN_STATS_C) OVER (PARTITION BY final.sk_Fact_Pt_Enc_Clrt
                                                         ORDER BY final.next_Admission
                                                         ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                                        )                            AS next_HOSP_ADMSSN_STATS_C
      ,FIRST_VALUE(final.next_ADMIT_CATEGORY_C) OVER (PARTITION BY final.sk_Fact_Pt_Enc_Clrt
                                                      ORDER BY final.next_Admission
                                                      ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                                     )                               AS next_ADMIT_CATEGORY_C
      ,FIRST_VALUE(final.next_ADMIT_CATEGORY) OVER (PARTITION BY final.sk_Fact_Pt_Enc_Clrt
                                                    ORDER BY final.next_Admission
                                                    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                                   )                                 AS next_ADMIT_CATEGORY
      ,FIRST_VALUE(final.next_ADM_SOURCE) OVER (PARTITION BY final.sk_Fact_Pt_Enc_Clrt
                                                ORDER BY final.next_Admission
                                                ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                               )                                     AS next_ADM_SOURCE
      ,FIRST_VALUE(final.next_HOSP_ADMSN_TYPE) OVER (PARTITION BY final.sk_Fact_Pt_Enc_Clrt
                                                     ORDER BY final.next_Admission
                                                     ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                                    )                                AS next_HOSP_ADMSN_TYPE
      ,FIRST_VALUE(final.next_HOSP_ADMSN_STATUS) OVER (PARTITION BY final.sk_Fact_Pt_Enc_Clrt
                                                       ORDER BY final.next_Admission
                                                       ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                                      )                              AS next_HOSP_ADMSN_STATUS
      ,FIRST_VALUE(final.next_ADMIT_CONF_STAT) OVER (PARTITION BY final.sk_Fact_Pt_Enc_Clrt
                                                     ORDER BY final.next_Admission
                                                     ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                                    )                                AS next_ADMIT_CONF_STAT
      ,FIRST_VALUE(final.next_ADT_PATIENT_STAT) OVER (PARTITION BY final.sk_Fact_Pt_Enc_Clrt
                                                      ORDER BY final.next_Admission
                                                      ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                                     )                               AS next_ADT_PATIENT_STAT
      ,FIRST_VALUE(final.next_adt_pt_cls) OVER (PARTITION BY final.sk_Fact_Pt_Enc_Clrt
                                                ORDER BY final.next_Admission
                                                ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                               )                                     AS next_adt_pt_cls
      ,FIRST_VALUE(final.next_adm_provider_id) OVER (PARTITION BY final.sk_Fact_Pt_Enc_Clrt
                                                     ORDER BY final.next_Admission
                                                     ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                                    )                                AS next_adm_provider_id
      ,FIRST_VALUE(final.next_adm_provider_name) OVER (PARTITION BY final.sk_Fact_Pt_Enc_Clrt
                                                       ORDER BY final.next_Admission
                                                       ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                                      )                              AS next_adm_provider_name
      ,FIRST_VALUE(final.next_dsch_provider_id) OVER (PARTITION BY final.sk_Fact_Pt_Enc_Clrt
                                                      ORDER BY final.next_Admission
                                                      ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                                     )                               AS next_dsch_provider_id
      ,FIRST_VALUE(final.next_dsch_provider_name) OVER (PARTITION BY final.sk_Fact_Pt_Enc_Clrt
                                                        ORDER BY final.next_Admission
                                                        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                                       )                             AS next_dsch_provider_name
      ,FIRST_VALUE(final.next_adm_enc_sk_phys_adm) OVER (PARTITION BY final.sk_Fact_Pt_Enc_Clrt
                                                         ORDER BY final.next_Admission
                                                         ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                                        )                            AS next_adm_enc_sk_phys_adm
      ,FIRST_VALUE(final.next_enc_sk_physcn) OVER (PARTITION BY final.sk_Fact_Pt_Enc_Clrt
                                                   ORDER BY final.next_Admission
                                                   ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                                  )                                  AS next_enc_sk_physcn
      ,FIRST_VALUE(final.next_sk_Phys_Atn) OVER (PARTITION BY final.sk_Fact_Pt_Enc_Clrt
                                                 ORDER BY final.next_Admission
                                                 ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                                )                                    AS next_sk_Phys_Atn
      ,FIRST_VALUE(final.next_derived_sk_Phys_Atn) OVER (PARTITION BY final.sk_Fact_Pt_Enc_Clrt
                                                         ORDER BY final.next_Admission
                                                         ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                                        )                            AS next_derived_sk_Phys_Atn
      ,FIRST_VALUE(final.next_adm_mdm_practice_group_id) OVER (PARTITION BY final.sk_Fact_Pt_Enc_Clrt
                                                               ORDER BY final.next_Admission
                                                               ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                                              )                      AS next_adm_mdm_practice_group_id
      ,FIRST_VALUE(final.next_adm_mdm_practice_group_name) OVER (PARTITION BY final.sk_Fact_Pt_Enc_Clrt
                                                                 ORDER BY final.next_Admission
                                                                 ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                                                )                    AS next_adm_mdm_practice_group_name
      ,FIRST_VALUE(final.next_adm_mdm_service_line_id) OVER (PARTITION BY final.sk_Fact_Pt_Enc_Clrt
                                                             ORDER BY final.next_Admission
                                                             ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                                            )                        AS next_adm_mdm_service_line_id
      ,FIRST_VALUE(final.next_adm_mdm_service_line) OVER (PARTITION BY final.sk_Fact_Pt_Enc_Clrt
                                                          ORDER BY final.next_Admission
                                                          ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                                         )                           AS next_adm_mdm_service_line
      ,FIRST_VALUE(final.next_adm_mdm_sub_service_line_id) OVER (PARTITION BY final.sk_Fact_Pt_Enc_Clrt
                                                                 ORDER BY final.next_Admission
                                                                 ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                                                )                    AS next_adm_mdm_sub_service_line_id
      ,FIRST_VALUE(final.next_adm_mdm_sub_service_line) OVER (PARTITION BY final.sk_Fact_Pt_Enc_Clrt
                                                              ORDER BY final.next_Admission
                                                              ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                                             )                       AS next_adm_mdm_sub_service_line
      ,FIRST_VALUE(final.next_adm_mdm_opnl_service_id) OVER (PARTITION BY final.sk_Fact_Pt_Enc_Clrt
                                                             ORDER BY final.next_Admission
                                                             ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                                            )                        AS next_adm_mdm_opnl_service_id
      ,FIRST_VALUE(final.next_adm_mdm_opnl_service_name) OVER (PARTITION BY final.sk_Fact_Pt_Enc_Clrt
                                                               ORDER BY final.next_Admission
                                                               ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                                              )                      AS next_adm_mdm_opnl_service_name
      ,FIRST_VALUE(final.next_adm_mdm_hs_area_id) OVER (PARTITION BY final.sk_Fact_Pt_Enc_Clrt
                                                        ORDER BY final.next_Admission
                                                        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                                       )                             AS next_adm_mdm_hs_area_id
      ,FIRST_VALUE(final.next_adm_mdm_hs_area_name) OVER (PARTITION BY final.sk_Fact_Pt_Enc_Clrt
                                                          ORDER BY final.next_Admission
                                                          ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                                         )                           AS next_adm_mdm_hs_area_name
      ,FIRST_VALUE(final.next_adm_mdm_epic_department) OVER (PARTITION BY final.sk_Fact_Pt_Enc_Clrt
                                                             ORDER BY final.next_Admission
                                                             ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                                            )                        AS next_adm_mdm_epic_department
      ,FIRST_VALUE(final.next_adm_mdm_epic_department_external) OVER (PARTITION BY final.sk_Fact_Pt_Enc_Clrt
                                                                      ORDER BY final.next_Admission
                                                                      ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                                                     )               AS next_adm_mdm_epic_department_external
      ,FIRST_VALUE(final.next_adm_physcn_service_line) OVER (PARTITION BY final.sk_Fact_Pt_Enc_Clrt
                                                             ORDER BY final.next_Admission
                                                             ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                                            )                        AS next_adm_physcn_service_line
      ,FIRST_VALUE(final.next_dsch_mdm_practice_group_id) OVER (PARTITION BY final.sk_Fact_Pt_Enc_Clrt
                                                                ORDER BY final.next_Admission
                                                                ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                                               )                     AS next_dsch_mdm_practice_group_id
      ,FIRST_VALUE(final.next_dsch_mdm_practice_group_name) OVER (PARTITION BY final.sk_Fact_Pt_Enc_Clrt
                                                                  ORDER BY final.next_Admission
                                                                  ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                                                 )                   AS next_dsch_mdm_practice_group_name
      ,FIRST_VALUE(final.next_dsch_mdm_service_line_id) OVER (PARTITION BY final.sk_Fact_Pt_Enc_Clrt
                                                              ORDER BY final.next_Admission
                                                              ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                                             )                       AS next_dsch_mdm_service_line_id
      ,FIRST_VALUE(final.next_dsch_mdm_service_line) OVER (PARTITION BY final.sk_Fact_Pt_Enc_Clrt
                                                           ORDER BY final.next_Admission
                                                           ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                                          )                          AS next_dsch_mdm_service_line
      ,FIRST_VALUE(final.next_dsch_mdm_sub_service_line_id) OVER (PARTITION BY final.sk_Fact_Pt_Enc_Clrt
                                                                  ORDER BY final.next_Admission
                                                                  ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                                                 )                   AS next_dsch_mdm_sub_service_line_id
      ,FIRST_VALUE(final.next_dsch_mdm_sub_service_line) OVER (PARTITION BY final.sk_Fact_Pt_Enc_Clrt
                                                               ORDER BY final.next_Admission
                                                               ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                                              )                      AS next_dsch_mdm_sub_service_line
      ,FIRST_VALUE(final.next_dsch_mdm_opnl_service_id) OVER (PARTITION BY final.sk_Fact_Pt_Enc_Clrt
                                                              ORDER BY final.next_Admission
                                                              ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                                             )                       AS next_dsch_mdm_opnl_service_id
      ,FIRST_VALUE(final.next_dsch_mdm_opnl_service_name) OVER (PARTITION BY final.sk_Fact_Pt_Enc_Clrt
                                                                ORDER BY final.next_Admission
                                                                ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                                               )                     AS next_dsch_mdm_opnl_service_name
      ,FIRST_VALUE(final.next_dsch_mdm_hs_area_id) OVER (PARTITION BY final.sk_Fact_Pt_Enc_Clrt
                                                         ORDER BY final.next_Admission
                                                         ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                                        )                            AS next_dsch_mdm_hs_area_id
      ,FIRST_VALUE(final.next_dsch_mdm_hs_area_name) OVER (PARTITION BY final.sk_Fact_Pt_Enc_Clrt
                                                           ORDER BY final.next_Admission
                                                           ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                                          )                          AS next_dsch_mdm_hs_area_name
      ,FIRST_VALUE(final.next_dsch_mdm_epic_department) OVER (PARTITION BY final.sk_Fact_Pt_Enc_Clrt
                                                              ORDER BY final.next_Admission
                                                              ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                                             )                       AS next_dsch_mdm_epic_department
      ,FIRST_VALUE(final.next_dsch_mdm_epic_department_external) OVER (PARTITION BY final.sk_Fact_Pt_Enc_Clrt
                                                                       ORDER BY final.next_Admission
                                                                       ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                                                      )              AS next_dsch_mdm_epic_department_external
      ,FIRST_VALUE(final.next_dsch_physcn_service_line_id) OVER (PARTITION BY final.sk_Fact_Pt_Enc_Clrt
                                                                 ORDER BY final.next_Admission
                                                                 ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                                                )                    AS next_dsch_physcn_service_line_id
      ,FIRST_VALUE(final.next_dsch_physcn_service_line) OVER (PARTITION BY final.sk_Fact_Pt_Enc_Clrt
                                                              ORDER BY final.next_Admission
                                                              ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                                             )                       AS next_dsch_physcn_service_line
      ,FIRST_VALUE(final.next_adm_dx_cde) OVER (PARTITION BY final.sk_Fact_Pt_Enc_Clrt
                                                ORDER BY final.next_Admission
                                                ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                               )                                     AS next_adm_dx_cde
      ,FIRST_VALUE(final.next_adm_dx_nme) OVER (PARTITION BY final.sk_Fact_Pt_Enc_Clrt
                                                ORDER BY final.next_Admission
                                                ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                               )                                     AS next_adm_dx_nme
      ,FIRST_VALUE(DATEDIFF(DAY, final.IndexDischarge, final.next_Admission)) OVER (PARTITION BY final.sk_Fact_Pt_Enc_Clrt
                                                                                    ORDER BY final.next_Admission
                                                                                    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
                                                                                   ) AS Duration
INTO #RptgFinalBalancedScorecard
FROM #ip_accts_dxs AS final;


--final UNION of all readmissions and discharges with standard columns
SELECT *
INTO #RptgFinal
FROM
(
    /* list readmission records to be used to determine numerator */
    SELECT DISTINCT
           CAST(NULL AS VARCHAR(150))                                                                                       AS event_category
          ,CAST('Readmission' AS VARCHAR(50))                                                                               AS event_type
          ,date_dim.day_date                                                                                                AS event_date           -- index discharge date
          ,ISNULL(rp.dsch_fmonth_num, date_dim.fmonth_num)                                                                  AS fmonth_num           -- index discharge date
          ,ISNULL(rp.dsch_FYear_name, date_dim.FYear_name)                                                                  AS fyear_name           -- index discharge date
          ,ISNULL(rp.dsch_Fyear_num, date_dim.Fyear_num)                                                                    AS fyear_num            -- index discharge date
          ,CAST(COALESCE(rp.dsch_Clrt_DEPt_Nme, 'Unknown') AS VARCHAR(254))                                                 AS event_location       -- index discharge location
          ,rp.MRN_Clrt                                                                                                      AS person_id
          ,CAST(RTRIM(rp.PT_LNAME) + ', ' + LTRIM(rp.PT_FNAME_MI) AS VARCHAR(200))                                          AS person_name
          ,rp.BIRTH_DATE                                                                                                    AS person_birth_date
          ,rp.sk_Dim_Pt
          ,rp.gender                                                                                                        AS person_gender

                                                                                                                                                    ---BDD 12/12/2017 added below 2 sks
          ,rp.sk_Fact_Pt_Acct
          ,rp.sk_Fact_Pt_Enc_Clrt
                                                                                                                                                    ------
                                                                                                                                                    -- -----------------------------------------------------------------------------------------
                                                                                                                                                    -- Calculated Fields - Index Discharge
                                                                                                                                                    -- -----------------------------------------------------------------------------------------
          ,CASE
               WHEN rp.sk_Adm_Dte IS NULL
               THEN 0
               ELSE 1
           END                                                                                                              AS event_count
          ,CAST(LEFT(DATENAME(MM, date_dim.day_date), 3) + ' ' + CAST(DAY(date_dim.day_date) AS VARCHAR(2)) AS VARCHAR(10)) AS report_period
          ,CAST(date_dim.day_date AS SMALLDATETIME)                                                                         AS report_date
                                                                                                                                                    -- ------------------------------------
                                                                                                                                                    -- MDM Fields - Index Discharge
                                                                                                                                                    -- ------------------------------------
          ,rp.dsch_mdm_practice_group_id                                                                                    AS practice_group_id
          ,rp.dsch_mdm_practice_group_name                                                                                  AS practice_group_name
          ,rp.dsch_mdm_service_line_id                                                                                      AS locsvc_service_line_id
          ,rp.dsch_mdm_service_line                                                                                         AS locsvc_service_line
                                                                                                                                                    /*rename to prefix loc_*/
          ,rp.dsch_mdm_sub_service_line_id                                                                                  AS loc_sub_service_line_id
          ,rp.dsch_mdm_sub_service_line                                                                                     AS loc_sub_service_line
          ,rp.dsch_mdm_opnl_service_id                                                                                      AS loc_opnl_service_id
          ,rp.dsch_mdm_opnl_service_name                                                                                    AS loc_opnl_service_name
          ,rp.dsch_mdm_hs_area_id                                                                                           AS loc_hs_area_id
          ,rp.dsch_mdm_hs_area_name                                                                                         AS loc_hs_area_name
                                                                                                                                                    /*end rename*/
          ,rp.dsch_DEPARTMENT_ID                                                                                            AS epic_department_id
          ,rp.dsch_mdm_epic_department                                                                                      AS epic_department_name
          ,rp.dsch_mdm_epic_department_external                                                                             AS epic_department_name_external
          ,rp.dsch_provider_id                                                                                              AS provider_id
          ,rp.dsch_provider_name                                                                                            AS provider_name
                                                                                                                                                    -- ------------------------------------
                                                                                                                                                    -- Service line - Index Discharge
                                                                                                                                                    -- ------------------------------------
          ,rp.dsch_mdm_service_line                                                                                         AS service_line_loc
          ,rp.dsch_provider_name                                                                                            AS Discharging_MD
                                                                                                                                                    /*new columns based on discharging attending only*/
          ,rp.dsch_physcn_hs_area_id                                                                                        AS hs_area_id
          ,rp.dsch_physcn_hs_area_name                                                                                      AS hs_area_name
          ,rp.dsch_physcn_service_line_id                                                                                   AS service_line_id
          ,rp.dsch_physcn_service_line                                                                                      AS service_line
          ,rp.dsch_physcn_opnl_service_line_id                                                                              AS opnl_service_id
          ,rp.dsch_physcn_opnl_service_line                                                                                 AS opnl_service_name
          ,rp.dsch_physcn_som_hs_area_id                                                                                    AS som_hs_area_id
          ,rp.dsch_physcn_som_hs_area_name                                                                                  AS som_hs_area_name
          ,rp.dsch_physcn_som_group_id                                                                                      AS som_group_id
          ,rp.dsch_physcn_som_group                                                                                         AS som_group
          ,rp.dsch_physcn_som_department_id                                                                                 AS som_department_id
          ,rp.dsch_physcn_som_department                                                                                    AS som_department
          ,rp.dsch_physcn_som_division_id                                                                                   AS som_division_id
          ,rp.dsch_physcn_som_division_name                                                                                 AS som_division_name
          ,rp.dsch_physcn_som_division_name_id                                                                              AS som_division_name_id
          ,rp.dsch_physcn_financial_division                                                                                AS financial_division
          ,rp.dsch_physcn_financial_division_name                                                                           AS financial_division_name
          ,rp.dsch_physcn_financial_subdivision                                                                             AS financial_subdivision
          ,rp.dsch_physcn_financial_subdivision_name                                                                        AS financial_subdivision_name
          ,rp.dsch_physcn_sk_Dim_Physcn                                                                                     AS sk_Dim_physcn
          ,rp.dsch_physcn_UVaID                                                                                             AS UVaID
                                                                                                                                                    /*end new columns*/
          ,rp.dsch_Unit                                                                                                     AS Discharging_Unit
          ,rp.dsch_Unit_Nme                                                                                                 AS Discharging_Unit_Name
          ,rp.Admission                                                                                                     AS index_admission_event_date
                                                                                                                                                    -- ------------------------------------
          ,rp.HOSP_ADMSSN_STATS_C                                                                                           AS index_admission_HOSP_ADMSSN_STATS_C
          ,rp.ADMIT_CATEGORY_C                                                                                              AS index_admission_ADMIT_CATEGORY_C
          ,rp.ADMIT_CATEGORY                                                                                                AS index_admission_ADMIT_CATEGORY
          ,rp.ADM_SOURCE                                                                                                    AS index_admission_ADM_SOURCE
          ,rp.HOSP_ADMSN_TYPE                                                                                               AS index_admission_HOSP_ADMSN_TYPE
          ,rp.HOSP_ADMSN_STATUS                                                                                             AS index_admission_HOSP_ADMSN_STATUS
          ,rp.ADMIT_CONF_STAT                                                                                               AS index_admission_ADMIT_CONF_STAT
          ,rp.ADT_PATIENT_STAT                                                                                              AS index_admission_ADT_PATIENT_STAT
          ,rp.adt_pt_cls                                                                                                    AS index_admission_adt_pt_cls
                                                                                                                                                    -- ------------------------------------
          ,rp.IndexDischarge                                                                                                AS index_discharge_event_date
          ,rp.dsch_dx_cde                                                                                                   AS Discharge_Dx
          ,rp.dsch_dx_nme                                                                                                   AS Discharge_Dx_Name
          ,rp.next_adm_fmonth_num                                                                                           AS readm_fmonth_num     -- Readmission date
          ,rp.next_adm_FYear_name                                                                                           AS readm_fyear_name     -- Readmission date
          ,rp.next_adm_Fyear_num                                                                                            AS readm_fyear_num      -- Readmission date
          ,COALESCE(rp.next_adm_Clrt_DEPt_Nme, 'Unknown')                                                                   AS readm_event_location -- Readmission location
                                                                                                                                                    -- ------------------------------------
                                                                                                                                                    -- MDM Fields - Readmission
                                                                                                                                                    -- ------------------------------------
          ,rp.next_adm_mdm_practice_group_id                                                                                AS readm_practice_group_id
          ,rp.next_adm_mdm_practice_group_name                                                                              AS readm_practice_group_name
          ,rp.next_adm_mdm_service_line_id                                                                                  AS readm_locsvc_service_line_id
          ,rp.next_adm_mdm_service_line                                                                                     AS readm_locsvc_service_line
          ,rp.next_adm_mdm_sub_service_line_id                                                                              AS readm_sub_service_line_id
          ,rp.next_adm_mdm_sub_service_line                                                                                 AS readm_sub_service_line
          ,rp.next_adm_mdm_opnl_service_id                                                                                  AS readm_opnl_service_id
          ,rp.next_adm_mdm_opnl_service_name                                                                                AS readm_opnl_service_name
          ,rp.next_adm_mdm_hs_area_id                                                                                       AS readm_hs_area_id
          ,rp.next_adm_mdm_hs_area_name                                                                                     AS readm_hs_area_name
          ,rp.next_adm_DEPARTMENT_ID                                                                                        AS readm_epic_department_id
          ,rp.next_adm_mdm_epic_department                                                                                  AS readm_epic_department_name
          ,rp.next_adm_mdm_epic_department_external                                                                         AS readm_epic_department_name_external
          ,rp.next_adm_provider_id                                                                                          AS readm_provider_id
          ,rp.next_adm_provider_name                                                                                        AS readm_provider_name
                                                                                                                                                    -- ------------------------------------
                                                                                                                                                    -- Service line - Readmission
                                                                                                                                                    -- ------------------------------------
          ,rp.next_adm_mdm_service_line                                                                                     AS readm_service_line_loc
          ,rp.next_adm_provider_name                                                                                        AS Readmission_MD
          ,rp.next_adm_physcn_service_line                                                                                  AS readm_service_line
          ,rp.next_adm_Unit                                                                                                 AS Readmission_Unit
          ,rp.next_adm_Unit_Nme                                                                                             AS Readmission_Unit_Name
          ,rp.next_Admission                                                                                                AS readmission_admission_event_date
                                                                                                                                                    -- ------------------------------------
          ,rp.next_HOSP_ADMSSN_STATS_C                                                                                      AS readmission_admission_HOSP_ADMSSN_STATS_C
          ,rp.next_ADMIT_CATEGORY_C                                                                                         AS readmission_admission_ADMIT_CATEGORY_C
          ,rp.next_ADMIT_CATEGORY                                                                                           AS readmission_admission_ADMIT_CATEGORY
          ,rp.next_ADM_SOURCE                                                                                               AS readmission_admission_ADM_SOURCE
          ,rp.next_HOSP_ADMSN_TYPE                                                                                          AS readmission_admission_HOSP_ADMSN_TYPE
          ,rp.next_HOSP_ADMSN_STATUS                                                                                        AS readmission_admission_HOSP_ADMSN_STATUS
          ,rp.next_ADMIT_CONF_STAT                                                                                          AS readmission_admission_ADMIT_CONF_STAT
          ,rp.next_ADT_PATIENT_STAT                                                                                         AS readmission_admission_ADT_PATIENT_STAT
          ,rp.next_adt_pt_cls                                                                                               AS readmission_admission_adt_pt_cls
          ,rp.next_sk_Fact_Pt_Enc_Clrt
                                                                                                                                                    -- ------------------------------------
          ,rp.next_IndexDischarge                                                                                           AS readmission_discharge_event_date
          ,rp.next_adm_dx_cde                                                                                               AS Readmission_Dx
          ,rp.next_adm_dx_nme                                                                                               AS Readmission_Dx_Name
          ,CAST(CASE
                    WHEN FLOOR((CAST(date_dim.day_date AS INTEGER) - CAST(rp.BIRTH_DATE AS INTEGER)) / 365.25) < 18
                    THEN 1
                    ELSE 0
                END AS SMALLINT)                                                                                            AS peds
          ,CAST(CASE
                    WHEN tx.PAT_ENC_CSN_ID IS NOT NULL
                    THEN 1
                    ELSE 0
                END AS SMALLINT)                                                                                            AS transplant
          ,CAST(CASE
                    WHEN tx_pts.sk_Dim_Clrt_Pt IS NOT NULL
                    THEN 1
                    ELSE 0
                END AS SMALLINT)                                                                                            AS transplant_pt
    FROM DS_HSDW_Prod.Rptg.vwDim_Date AS date_dim WITH (NOLOCK)
        INNER JOIN
        (
            SELECT r.*
            FROM #RptgFinalBalancedScorecard AS r
                LEFT OUTER JOIN #planned_enc AS pe
                    ON pe.sk_Dim_Pt = r.sk_Dim_Pt
                       AND pe.Admission
                       BETWEEN r.IndexDischarge AND r.next_Admission
            WHERE r.dsch_physcn_hs_area_id IS NOT NULL
                  AND r.Duration <= 30
                  AND pe.Admission IS NULL
        )                             AS rp
            ON date_dim.date_key = rp.sk_Dsch_Dte
        -- -------------------------------------
        -- Identify transplant encounter
        -- -------------------------------------

        LEFT OUTER JOIN
        (
            SELECT fpec.PAT_ENC_CSN_ID
                  ,txsurg.day_date AS transplant_surgery_dt
                  ,fpec.Adm_Dtm
                  ,fpec.sk_Fact_Pt_Enc_Clrt
                  ,fpec.sk_Fact_Pt_Acct
                  ,fpec.sk_Dim_Clrt_Pt
                  ,fpec.sk_Dim_Pt
            FROM DS_HSDW_Prod.Rptg.VwFact_Pt_Trnsplnt_Clrt      AS fptc WITH (NOLOCK)
                INNER JOIN DS_HSDW_Prod.Rptg.vwFact_Pt_Enc_Clrt AS fpec WITH (NOLOCK)
                    ON fptc.sk_Dim_Clrt_Pt = fpec.sk_Dim_Clrt_Pt
                INNER JOIN DS_HSDW_Prod.Rptg.vwDim_Date         AS txsurg WITH (NOLOCK)
                    ON fptc.sk_Tx_Surg_Dt = txsurg.date_key
            WHERE txsurg.day_date
                  BETWEEN CAST(fpec.Adm_Dtm AS DATE) AND fpec.Dsch_Dtm
                  AND txsurg.day_date <> '1900-01-01 00:00:00'
        )                             AS tx
            ON rp.sk_Fact_Pt_Acct = tx.sk_Fact_Pt_Acct

        -- -----------------------------------------
        -- Identify transplant patients by episode--
        -- -----------------------------------------

        LEFT OUTER JOIN
        (
            SELECT fce.sk_Fact_Clrt_Epsd
                  ,fce.sk_Dim_Clrt_Pt
                  ,dp.MRN_int
                  ,dp.PAT_ID
                  ,epsdst.day_date AS EpisodeStartDate
                  ,CASE
                       WHEN fce.sk_Epsd_End_Dte = '19000101'
                       THEN DATEADD(DAY, 7, GETDATE())
                       ELSE epsded.day_date
                   END             AS EpisodeEndDate
                  ,fce.Epsd_ID
                  ,fce.Sts_Nme
                  ,fce.Epsd_Nme
            FROM DS_HSDW_Prod.dbo.Fact_Clrt_Epsd        AS fce
                INNER JOIN DS_HSDW_Prod.dbo.Dim_Patient AS dp
                    ON dp.sk_Dim_Clrt_Pt = fce.sk_Dim_Clrt_Pt
                INNER JOIN DS_HSDW_Prod.dbo.Dim_Date    AS epsdst
                    ON fce.sk_Epsd_Strt_Dte = epsdst.date_key
                INNER JOIN DS_HSDW_Prod.dbo.Dim_Date    AS epsded
                    ON fce.sk_Epsd_End_Dte = epsded.date_key
            WHERE fce.Epsd_Def_Nme = 'Transplant'
                  AND fce.sk_Dim_Clrt_Pt <> 0
        )                             AS tx_pts
            ON rp.MRN_Clrt = tx_pts.MRN_int
               AND rp.Admission
               BETWEEN tx_pts.EpisodeStartDate AND tx_pts.EpisodeEndDate
    WHERE date_dim.day_date >= @startdate
          AND date_dim.day_date < @enddate
    UNION ALL
    /* list discharge records to be used to determine denominator */
    SELECT DISTINCT
           CAST(NULL AS VARCHAR(150))                                                                                       AS event_category
          ,CAST('Discharge' AS VARCHAR(50))                                                                                 AS event_type
          ,date_dim.day_date                                                                                                AS event_date           -- index discharge date
          ,ISNULL(ad.dsch_fmonth_num, date_dim.fmonth_num)                                                                  AS fmonth_num           -- index discharge date
          ,ISNULL(ad.dsch_FYear_name, date_dim.FYear_name)                                                                  AS fyear_name           -- index discharge date
          ,ISNULL(ad.dsch_Fyear_num, date_dim.Fyear_num)                                                                    AS fyear_num            -- index discharge date
          ,CAST(COALESCE(ad.dsch_Clrt_DEPt_Nme, 'Unknown') AS VARCHAR(254))                                                 AS event_location       -- index discharge location
          ,ad.MRN_Clrt                                                                                                      AS person_id
          ,CAST(RTRIM(ad.PT_LNAME) + ', ' + LTRIM(ad.PT_FNAME_MI) AS VARCHAR(200))                                          AS person_name
          ,ad.BIRTH_DATE                                                                                                    AS person_birth_date
          ,ad.sk_Dim_Pt
          ,ad.gender                                                                                                        AS person_gender

                                                                                                                                                    ---BDD 12/12/2017 added below 2 sks
          ,ad.sk_Fact_Pt_Acct
          ,ad.sk_Fact_Pt_Enc_Clrt
                                                                                                                                                    ------
                                                                                                                                                    -- -----------------------------------------------------------------------------------------
                                                                                                                                                    -- Calculated Fields - Index Discharge
                                                                                                                                                    -- -----------------------------------------------------------------------------------------
          ,CASE
               WHEN ad.sk_Adm_Dte IS NULL
               THEN 0
               ELSE 1
           END                                                                                                              AS event_count
          ,CAST(LEFT(DATENAME(MM, date_dim.day_date), 3) + ' ' + CAST(DAY(date_dim.day_date) AS VARCHAR(2)) AS VARCHAR(10)) AS report_period
          ,CAST(date_dim.day_date AS SMALLDATETIME)                                                                         AS report_date
                                                                                                                                                    -- ------------------------------------
                                                                                                                                                    -- MDM Fields - Index Discharge
                                                                                                                                                    -- ------------------------------------
          ,ad.dsch_mdm_practice_group_id                                                                                    AS practice_group_id
          ,ad.dsch_mdm_practice_group_name                                                                                  AS practice_group_name
          ,ad.dsch_mdm_service_line_id                                                                                      AS locsvc_service_line_id
          ,ad.dsch_mdm_service_line                                                                                         AS locsvc_service_line
                                                                                                                                                    /*rename to prefix loc_*/
          ,ad.dsch_mdm_sub_service_line_id                                                                                  AS loc_sub_service_line_id
          ,ad.dsch_mdm_sub_service_line                                                                                     AS loc_sub_service_line
          ,ad.dsch_mdm_opnl_service_id                                                                                      AS loc_opnl_service_id
          ,ad.dsch_mdm_opnl_service_name                                                                                    AS loc_opnl_service_name
          ,ad.dsch_mdm_hs_area_id                                                                                           AS loc_hs_area_id
          ,ad.dsch_mdm_hs_area_name                                                                                         AS loc_hs_area_name
                                                                                                                                                    /*end rename*/
          ,ad.dsch_DEPARTMENT_ID                                                                                            AS epic_department_id
          ,ad.dsch_mdm_epic_department                                                                                      AS epic_department_name
          ,ad.dsch_mdm_epic_department_external                                                                             AS epic_department_name_external
          ,ad.dsch_provider_id                                                                                              AS provider_id
          ,ad.dsch_provider_name                                                                                            AS provider_name
                                                                                                                                                    -- ------------------------------------
                                                                                                                                                    -- Service line - Index Discharge
                                                                                                                                                    -- ------------------------------------
          ,ad.dsch_mdm_service_line                                                                                         AS service_line_loc
          ,ad.dsch_provider_name                                                                                            AS Discharging_MD
                                                                                                                                                    /*new columns based on discharging attending only*/
          ,ad.dsch_physcn_hs_area_id                                                                                        AS hs_area_id
          ,ad.dsch_physcn_hs_area_name                                                                                      AS hs_area_name
          ,ad.dsch_physcn_service_line_id                                                                                   AS service_line_id
          ,ad.dsch_physcn_service_line                                                                                      AS service_line
          ,ad.dsch_physcn_opnl_service_line_id                                                                              AS opnl_service_id
          ,ad.dsch_physcn_opnl_service_line                                                                                 AS opnl_service_name
          ,ad.dsch_physcn_som_hs_area_id                                                                                    AS som_hs_area_id
          ,ad.dsch_physcn_som_hs_area_name                                                                                  AS som_hs_area_name
          ,ad.dsch_physcn_som_group_id                                                                                      AS som_group_id
          ,ad.dsch_physcn_som_group                                                                                         AS som_group
          ,ad.dsch_physcn_som_department_id                                                                                 AS som_department_id
          ,ad.dsch_physcn_som_department                                                                                    AS som_department
          ,ad.dsch_physcn_som_division_id                                                                                   AS som_division_id
          ,ad.dsch_physcn_som_division_name                                                                                 AS som_division_name
          ,ad.dsch_physcn_som_division_name_id                                                                              AS som_division_name_id
          ,ad.dsch_physcn_financial_division                                                                                AS financial_division
          ,ad.dsch_physcn_financial_division_name                                                                           AS financial_division_name
          ,ad.dsch_physcn_financial_subdivision                                                                             AS financial_subdivision
          ,ad.dsch_physcn_financial_subdivision_name                                                                        AS financial_subdivision_name
          ,ad.dsch_physcn_sk_Dim_Physcn                                                                                     AS sk_Dim_physcn
          ,ad.dsch_physcn_UVaID                                                                                             AS UVaID
                                                                                                                                                    /*end new columns*/
          ,ad.dsch_Unit                                                                                                     AS Discharging_Unit
          ,ad.dsch_Unit_Nme                                                                                                 AS Discharging_Unit_Name
          ,ad.Admission                                                                                                     AS index_admission_event_date
                                                                                                                                                    -- ------------------------------------
          ,ad.HOSP_ADMSSN_STATS_C                                                                                           AS index_admission_HOSP_ADMSSN_STATS_C
          ,ad.ADMIT_CATEGORY_C                                                                                              AS index_admission_ADMIT_CATEGORY_C
          ,ad.ADMIT_CATEGORY                                                                                                AS index_admission_ADMIT_CATEGORY
          ,ad.ADM_SOURCE                                                                                                    AS index_admission_ADM_SOURCE
          ,ad.HOSP_ADMSN_TYPE                                                                                               AS index_admission_HOSP_ADMSN_TYPE
          ,ad.HOSP_ADMSN_STATUS                                                                                             AS index_admission_HOSP_ADMSN_STATUS
          ,ad.ADMIT_CONF_STAT                                                                                               AS index_admission_ADMIT_CONF_STAT
          ,ad.ADT_PATIENT_STAT                                                                                              AS index_admission_ADT_PATIENT_STAT
          ,ad.adt_pt_cls                                                                                                    AS index_admission_adt_pt_cls
                                                                                                                                                    -- ------------------------------------
          ,ad.IndexDischarge                                                                                                AS index_discharge_event_date
          ,ad.dsch_dx_cde                                                                                                   AS Discharge_Dx
          ,ad.dsch_dx_nme                                                                                                   AS Discharge_Dx_Name
          ,NULL                                                                                                             AS readm_fmonth_num     -- Readmission date
          ,NULL                                                                                                             AS readm_fyear_name     -- Readmission date
          ,NULL                                                                                                             AS readm_fyear_num      -- Readmission date
          ,NULL                                                                                                             AS readm_event_location -- Readmission location
                                                                                                                                                    -- ------------------------------------
                                                                                                                                                    -- MDM Fields - Readmission
                                                                                                                                                    -- ------------------------------------
          ,NULL                                                                                                             AS readm_practice_group_id
          ,NULL                                                                                                             AS readm_practice_group_name
          ,NULL                                                                                                             AS readm_locsvc_service_line_id
          ,NULL                                                                                                             AS readm_locsvc_service_line
          ,NULL                                                                                                             AS readm_sub_service_line_id
          ,NULL                                                                                                             AS readm_sub_service_line
          ,NULL                                                                                                             AS readm_opnl_service_id
          ,NULL                                                                                                             AS readm_opnl_service_name
          ,NULL                                                                                                             AS readm_hs_area_id
          ,NULL                                                                                                             AS readm_hs_area_name
          ,NULL                                                                                                             AS readm_epic_department_id
          ,NULL                                                                                                             AS readm_epic_department_name
          ,NULL                                                                                                             AS readm_epic_department_name_external
          ,NULL                                                                                                             AS readm_provider_id
          ,NULL                                                                                                             AS readm_provider_name
                                                                                                                                                    -- ------------------------------------
                                                                                                                                                    -- Service line - Readmission
                                                                                                                                                    -- ------------------------------------
          ,NULL                                                                                                             AS readm_service_line_loc
          ,NULL                                                                                                             AS Readmission_MD
          ,NULL                                                                                                             AS readm_service_line
          ,NULL                                                                                                             AS Readmission_Unit
          ,NULL                                                                                                             AS Readmission_Unit_Name
          ,NULL                                                                                                             AS readmission_admission_event_date
                                                                                                                                                    -- ------------------------------------
          ,NULL                                                                                                             AS readmission_admission_HOSP_ADMSSN_STATS_C
          ,NULL                                                                                                             AS readmission_admission_ADMIT_CATEGORY_C
          ,NULL                                                                                                             AS readmission_admission_ADMIT_CATEGORY
          ,NULL                                                                                                             AS readmission_admission_ADM_SOURCE
          ,NULL                                                                                                             AS readmission_admission_HOSP_ADMSN_TYPE
          ,NULL                                                                                                             AS readmission_admission_HOSP_ADMSN_STATUS
          ,NULL                                                                                                             AS readmission_admission_ADMIT_CONF_STAT
          ,NULL                                                                                                             AS readmission_admission_ADT_PATIENT_STAT
          ,NULL                                                                                                             AS readmission_admission_adt_pt_cls
          ,NULL
                                                                                                                                                    -- ------------------------------------
          ,NULL                                                                                                             AS readmission_discharge_event_date
          ,NULL                                                                                                             AS Readmission_Dx
          ,NULL                                                                                                             AS Readmission_Dx_Name
          ,CAST(CASE
                    WHEN FLOOR((CAST(date_dim.day_date AS INTEGER) - CAST(ad.BIRTH_DATE AS INTEGER)) / 365.25) < 18
                    THEN 1
                    ELSE 0
                END AS SMALLINT)                                                                                            AS peds
          ,CAST(CASE
                    WHEN tx.PAT_ENC_CSN_ID IS NOT NULL
                    THEN 1
                    ELSE 0
                END AS SMALLINT)                                                                                            AS transplant
          ,CAST(CASE
                    WHEN tx_pts.sk_Dim_Clrt_Pt IS NOT NULL
                    THEN 1
                    ELSE 0
                END AS SMALLINT)                                                                                            AS transplant_pts
    FROM DS_HSDW_Prod.Rptg.vwDim_Date AS date_dim WITH (NOLOCK)
        LEFT OUTER JOIN
        (
            SELECT *
            FROM #ip_accts_dxs
            WHERE NOT (
                          (dsch_physcn_hs_area_id IS NULL)
                          AND (IndexDischarge < @currdate)
                      )
        )                             AS ad
            ON date_dim.date_key = ad.sk_Dsch_Dte
        -- -------------------------------------
        -- Identify transplant encounter
        -- -------------------------------------

        LEFT OUTER JOIN
        (
            SELECT fpec.PAT_ENC_CSN_ID
                  ,txsurg.day_date AS transplant_surgery_dt
                  ,fpec.Adm_Dtm
                  ,fpec.sk_Fact_Pt_Enc_Clrt
                  ,fpec.sk_Fact_Pt_Acct
                  ,fpec.sk_Dim_Clrt_Pt
                  ,fpec.sk_Dim_Pt
            FROM DS_HSDW_Prod.Rptg.VwFact_Pt_Trnsplnt_Clrt      AS fptc WITH (NOLOCK)
                INNER JOIN DS_HSDW_Prod.Rptg.vwFact_Pt_Enc_Clrt AS fpec WITH (NOLOCK)
                    ON fptc.sk_Dim_Clrt_Pt = fpec.sk_Dim_Clrt_Pt
                INNER JOIN DS_HSDW_Prod.Rptg.vwDim_Date         AS txsurg WITH (NOLOCK)
                    ON fptc.sk_Tx_Surg_Dt = txsurg.date_key
            WHERE txsurg.day_date
                  BETWEEN CAST(fpec.Adm_Dtm AS DATE) AND fpec.Dsch_Dtm
                  AND txsurg.day_date <> '1900-01-01 00:00:00'
        )                             AS tx
            ON ad.sk_Fact_Pt_Acct = tx.sk_Fact_Pt_Acct

        -- -----------------------------------------
        -- Identify transplant patients by episode--
        -- -----------------------------------------

        LEFT OUTER JOIN
        (
            SELECT fce.sk_Fact_Clrt_Epsd
                  ,fce.sk_Dim_Clrt_Pt
                  ,dp.MRN_int
                  ,dp.PAT_ID
                  ,epsdst.day_date AS EpisodeStartDate
                  ,CASE
                       WHEN fce.sk_Epsd_End_Dte = '19000101'
                       THEN DATEADD(DAY, 7, GETDATE())
                       ELSE epsded.day_date
                   END             AS EpisodeEndDate
                  ,fce.Epsd_ID
                  ,fce.Sts_Nme
                  ,fce.Epsd_Nme
            FROM DS_HSDW_Prod.dbo.Fact_Clrt_Epsd        AS fce
                INNER JOIN DS_HSDW_Prod.dbo.Dim_Patient AS dp
                    ON dp.sk_Dim_Clrt_Pt = fce.sk_Dim_Clrt_Pt
                INNER JOIN DS_HSDW_Prod.dbo.Dim_Date    AS epsdst
                    ON fce.sk_Epsd_Strt_Dte = epsdst.date_key
                INNER JOIN DS_HSDW_Prod.dbo.Dim_Date    AS epsded
                    ON fce.sk_Epsd_End_Dte = epsded.date_key
            WHERE fce.Epsd_Def_Nme = 'Transplant'
                  AND fce.sk_Dim_Clrt_Pt <> 0
        )                             AS tx_pts
            ON ad.MRN_Clrt = tx_pts.MRN_int
               AND ad.Admission
               BETWEEN tx_pts.EpisodeStartDate AND tx_pts.EpisodeEndDate
    WHERE date_dim.day_date >= @startdate
          AND date_dim.day_date < @enddate
) AS tmp;

/*--------------------------------------------------*/
----do the insert here. Proc presupposes that the Stage table
---- was truncated in the SSIS package
--INSERT INTO Stage.Balscore_Dash_Readmissions
--(
--    event_category
--   ,event_type
--   ,event_date
--   ,fmonth_num
--   ,fyear_name
--   ,fyear_num
--   ,event_location
--   ,person_id
--   ,person_name
--   ,person_birth_date
--   ,sk_Dim_Pt
--   ,sk_Fact_Pt_Acct
--   ,sk_Fact_Pt_Enc_Clrt
--   ,event_count
--   ,report_period
--   ,report_date
--   ,practice_group_id
--   ,practice_group_name
--   ,locsvc_service_line_id
--   ,locsvc_service_line
--   ,sub_service_line_id
--   ,sub_service_line
--   ,opnl_service_id
--   ,opnl_service_name
--   ,hs_area_id
--   ,hs_area_name
--   ,epic_department_id
--   ,epic_department_name
--   ,epic_department_name_external
--   ,provider_id
--   ,provider_name
--   ,service_line_loc
--   ,Discharging_MD
--   ,service_line_id
--   ,service_line
--   ,Discharging_Unit
--   ,Discharging_Unit_Name
--   ,index_admission_event_date
--   ,index_admission_HOSP_ADMSSN_STATS_C
--   ,index_admission_ADMIT_CATEGORY_C
--   ,index_admission_ADMIT_CATEGORY
--   ,index_admission_ADM_SOURCE
--   ,index_admission_HOSP_ADMSN_TYPE
--   ,index_admission_HOSP_ADMSN_STATUS
--   ,index_admission_ADMIT_CONF_STAT
--   ,index_admission_ADT_PATIENT_STAT
--   ,index_admission_adt_pt_cls
--   ,index_discharge_event_date
--   ,Discharge_Dx
--   ,Discharge_Dx_Name
--   ,readm_fmonth_num
--   ,readm_fyear_name
--   ,readm_fyear_num
--   ,readm_event_location
--   ,readm_practice_group_id
--   ,readm_practice_group_name
--   ,readm_locsvc_service_line_id
--   ,readm_locsvc_service_line
--   ,readm_sub_service_line_id
--   ,readm_sub_service_line
--   ,readm_opnl_service_id
--   ,readm_opnl_service_name
--   ,readm_hs_area_id
--   ,readm_hs_area_name
--   ,readm_epic_department_id
--   ,readm_epic_department_name
--   ,readm_epic_department_name_external
--   ,readm_provider_id
--   ,readm_provider_name
--   ,readm_service_line_loc
--   ,Readmission_MD
--   ,readm_service_line
--   ,Readmission_Unit
--   ,Readmission_Unit_Name
--   ,readmission_admission_event_date
--   ,readmission_admission_HOSP_ADMSSN_STATS_C
--   ,readmission_admission_ADMIT_CATEGORY_C
--   ,readmission_admission_ADMIT_CATEGORY
--   ,readmission_admission_ADM_SOURCE
--   ,readmission_admission_HOSP_ADMSN_TYPE
--   ,readmission_admission_HOSP_ADMSN_STATUS
--   ,readmission_admission_ADMIT_CONF_STAT
--   ,readmission_admission_ADT_PATIENT_STAT
--   ,readmission_admission_adt_pt_cls
--   ,readmission_discharge_event_date
--   ,Readmission_Dx
--   ,Readmission_Dx_Name
--   ,peds
--   ,transplant
--   ,UVaID
--   ,discharging_md_email                      --added 03/01/2020
--   ,readm_UVaID
--   ,readm_md_email                            -- added 03/01/2020
--   ,readmission_admission_sk_Fact_Pt_Enc_Clrt --03/01/2020 change from next_sk_fact_pt_enc_clrt
--   ,transplant_pt
--   ,financial_division_id
--   ,financial_division_name
--   ,financial_sub_division_id
--   ,financial_sub_division_name
--   ,rev_location_id
--   ,rev_location
--   ,loc_hs_area_id
--   ,loc_hs_area_name
--   ,readm_sk_dim_physcn
--   ,sk_Dim_Physcn
--   ,som_group_id
--   ,som_group_name
--   ,som_department_id
--   ,som_department_name
--   ,som_division_id
--   ,som_division_name
--   ,w_som_hs_area_id
--   ,w_som_hs_area_name
--   ,person_gender
--   ,Oncology                                  -- new on 09/14/2020
--   ,ServiceLine_Division                      --DM2NB 11/042021
--)
SELECT DISTINCT
       rf.event_category
      ,rf.event_type
      ,rf.event_date
      ,rf.fmonth_num
      ,rf.fyear_name
      ,rf.fyear_num
      ,rf.event_location
      ,rf.person_id
      ,rf.person_name
      ,rf.person_birth_date
      ,rf.sk_Dim_Pt
      ,rf.sk_Fact_Pt_Acct
      ,rf.sk_Fact_Pt_Enc_Clrt
      ,rf.event_count
      ,rf.report_period
      ,rf.report_date
      ,rf.practice_group_id
      ,rf.practice_group_name
      ,rf.locsvc_service_line_id
      ,rf.locsvc_service_line
      /* SUB-SL ID Attribution */

      ,CAST(CASE --when age < 18 and not a TCH  patient set sub-SL id 1, children

                WHEN rf.peds = 1
                     AND ((
                              rf.index_admission_adt_pt_cls <> 'TCH Inpatient'
                              OR LEFT(rf.Discharging_Unit_Name, 2) <> 'TC'
                          )
                         )
                     AND rf.sk_Fact_Pt_Enc_Clrt = nicu.sk_Fact_Pt_Enc_Clrt
                THEN 6 -- NICU sub service line


                WHEN rf.peds = 1
                     AND ((
                              rf.index_admission_adt_pt_cls <> 'TCH Inpatient'
                              OR LEFT(rf.Discharging_Unit_Name, 2) <> 'TC'
                          )
                         )
                THEN 1 --Children sub service line

                WHEN --when age >= 18 and male and WCSL and not a TCH patient set sub-SL id to 1, children
      rf.peds = 0
      AND rf.service_line_id = 11
      AND rf.person_gender = 'Male'
                THEN 1
                WHEN --when age >= 18 and not a TCH  patient set sub-SL id to 3, women
      rf.peds = 0
      AND rf.service_line_id = 11
      AND rf.person_gender = 'Female'
                THEN 3 --Women sub service line

                WHEN --Digestive Health
      rf.peds = 0
      AND rf.service_line_id = 1
      AND rf.provider_id IN ( '34044', '84410', '30288' )
                THEN 7 --Colorectal service line

                WHEN --Digestive Health
      rf.peds = 0
      AND
      (
          rf.service_line_id = 1
          OR rf.service_line_id = 3
          OR rf.service_line_id = 8
      )
      AND dp.Consult_Type = 'Liver'
                THEN 8 --Liver service line

                WHEN --Digestive Health
      rf.peds = 0
      AND
      (
          rf.service_line_id = 1
          OR rf.service_line_id = 3
          OR rf.service_line_id = 8
      )
      AND dp.Consult_Type = 'Luminal'
                THEN 9 --Luminal service line

                WHEN rf.service_line_id = 5 --Neurosciences & Behavioral Health
                     AND rf.som_department IN ( 'MD-NEUR Neurology', 'MD-NERS Neurological Surgery' )
                THEN 5 --Neurosciences
                WHEN rf.service_line_id = 5 --Neurosciences & Behavioral Health
                     AND rf.som_department = 'MD-PSCH Psychiatric Medicine'
                THEN 4 --Behavioral Health

                ELSE NULL
            END AS INT)              AS sub_service_line_id
      /* SUB-SL ID End */

      /* SUB-SL ID Attribution */
      ,CAST(CASE --when age < 18 and not a TCH  patient set sub-SL id 1, children

                WHEN rf.peds = 1
                     AND ((
                              rf.index_admission_adt_pt_cls <> 'TCH Inpatient'
                              OR LEFT(rf.Discharging_Unit_Name, 2) <> 'TC'
                          )
                         )
                     AND rf.sk_Fact_Pt_Enc_Clrt = nicu.sk_Fact_Pt_Enc_Clrt
                THEN 'NICU'
                WHEN rf.peds = 1
                     AND ((
                              rf.index_admission_adt_pt_cls <> 'TCH Inpatient'
                              OR LEFT(rf.Discharging_Unit_Name, 2) <> 'TC'
                          )
                         )
                THEN 'Children'
                WHEN --when age >= 18 and male and WCSL and not a TCH patient set sub-SL id to 1, children
      rf.peds = 0
      AND rf.service_line_id = 11
      AND rf.person_gender = 'Male'
                THEN 'Children'
                WHEN --when age >= 18 and not a TCH  patient set sub-SL id to 3, women
      rf.peds = 0
      AND rf.service_line_id = 11
      AND rf.person_gender = 'Female'
                THEN 'Women'
                WHEN --Digestive Health
      rf.peds = 0
      AND rf.service_line_id = 1
      AND rf.provider_id IN ( '34044', '84410', '30288' )
                THEN 'Colorectal'
                WHEN --Digestive Health
      rf.peds = 0
      AND
      (
          rf.service_line_id = 1
          OR rf.service_line_id = 3
          OR rf.service_line_id = 8
      )
      AND dp.Consult_Type = 'Liver'
                THEN 'Liver'
                WHEN --Digestive Health
      rf.peds = 0
      AND
      (
          rf.service_line_id = 1
          OR rf.service_line_id = 3
          OR rf.service_line_id = 8
      )
      AND dp.Consult_Type = 'Luminal'
                THEN 'Luminal'
                WHEN rf.service_line_id = 5 --Neurosciences & Behavioral Health
                     AND rf.som_department IN ( 'MD-NEUR Neurology', 'MD-NERS Neurological Surgery' )
                THEN 'Neurosciences'
                WHEN rf.service_line_id = 5 --Neurosciences & Behavioral Health
                     AND rf.som_department = 'MD-PSCH Psychiatric Medicine'
                THEN 'Behavioral Health'
                ELSE NULL
            END AS VARCHAR(150))     AS sub_service_line
      /* SUB-SL End */
      ,rf.opnl_service_id
      ,rf.opnl_service_name
      ,rf.hs_area_id
      ,rf.hs_area_name
      ,rf.epic_department_id
      ,rf.epic_department_name
      ,rf.epic_department_name_external
      ,rf.provider_id
      ,rf.provider_name
      ,rf.service_line_loc
      ,rf.Discharging_MD
      ,CAST(CASE --when age < 18 and not a TCH  patient set SL id to 11,womens and childrens
                WHEN rf.peds = 1
                     AND ((
                              rf.index_admission_adt_pt_cls <> 'TCH Inpatient'
                              OR LEFT(rf.Discharging_Unit_Name, 2) <> 'TC'
                          )
                         )
                THEN 11 --womens and childrens
                WHEN --when TCH patient set SL id to NULL
      ((
           rf.index_admission_adt_pt_cls = 'TCH Inpatient'
           OR LEFT(rf.Discharging_Unit_Name, 2) = 'TC'
       )
      )
                THEN NULL
                WHEN
                (
                    rf.sk_Fact_Pt_Enc_Clrt = dp.sk_Fact_Pt_Enc_Clrt
                    AND
                    (
                        rf.service_line_id = 3
                        OR rf.service_line_id = 8
                    )
                ) --3-med sub, 8-primary care
                THEN 1  --digestive health
                ELSE rf.service_line_id
            END AS INT)              AS Service_Line_ID
      ,CAST(CASE --when age < 18 and not a TCH  patient set SL id to 11,womens and childrens
                WHEN rf.peds = 1
                     AND ((
                              rf.index_admission_adt_pt_cls <> 'TCH Inpatient'
                              OR LEFT(rf.Discharging_Unit_Name, 2) <> 'TC'
                          )
                         )
                THEN 'Womens and Childrens'
                WHEN --when TCH patient set SL id to NULL
      ((
           rf.index_admission_adt_pt_cls = 'TCH Inpatient'
           OR LEFT(rf.Discharging_Unit_Name, 2) = 'TC'
       )
      )
                THEN NULL
                WHEN
                (
                    rf.sk_Fact_Pt_Enc_Clrt = dp.sk_Fact_Pt_Enc_Clrt
                    AND
                    (
                        rf.service_line_id = 3
                        OR rf.service_line_id = 8
                    )
                ) --3-med sub, 8-primary care
                THEN 'Digestive Health'
                ELSE rf.service_line
            END AS VARCHAR(150))     AS Service_Line
      ,rf.Discharging_Unit
      ,rf.Discharging_Unit_Name
      ,rf.index_admission_event_date
      ,rf.index_admission_HOSP_ADMSSN_STATS_C
      ,rf.index_admission_ADMIT_CATEGORY_C
      ,rf.index_admission_ADMIT_CATEGORY
      ,rf.index_admission_ADM_SOURCE
      ,rf.index_admission_HOSP_ADMSN_TYPE
      ,rf.index_admission_HOSP_ADMSN_STATUS
      ,rf.index_admission_ADMIT_CONF_STAT
      ,rf.index_admission_ADT_PATIENT_STAT
      ,rf.index_admission_adt_pt_cls
      ,rf.index_discharge_event_date
      ,rf.Discharge_Dx
      ,rf.Discharge_Dx_Name
      ,rf.readm_fmonth_num
      ,rf.readm_fyear_name
      ,rf.readm_fyear_num
      ,rf.readm_event_location
      ,rf.readm_practice_group_id
      ,rf.readm_practice_group_name
      ,rf.readm_locsvc_service_line_id
      ,rf.readm_locsvc_service_line
      ,rf.readm_sub_service_line_id
      ,rf.readm_sub_service_line
      ,rf.readm_opnl_service_id
      ,rf.readm_opnl_service_name
      ,rf.readm_hs_area_id
      ,rf.readm_hs_area_name
      ,rf.readm_epic_department_id
      ,rf.readm_epic_department_name
      ,rf.readm_epic_department_name_external
      ,rf.readm_provider_id
      ,rf.readm_provider_name
      ,rf.readm_service_line_loc
      ,rf.Readmission_MD
      ,rf.readm_service_line
      ,rf.Readmission_Unit
      ,rf.Readmission_Unit_Name
      ,rf.readmission_admission_event_date
      ,rf.readmission_admission_HOSP_ADMSSN_STATS_C
      ,rf.readmission_admission_ADMIT_CATEGORY_C
      ,rf.readmission_admission_ADMIT_CATEGORY
      ,rf.readmission_admission_ADM_SOURCE
      ,rf.readmission_admission_HOSP_ADMSN_TYPE
      ,rf.readmission_admission_HOSP_ADMSN_STATUS
      ,rf.readmission_admission_ADMIT_CONF_STAT
      ,rf.readmission_admission_ADT_PATIENT_STAT
      ,rf.readmission_admission_adt_pt_cls
      ,rf.readmission_discharge_event_date
      ,rf.Readmission_Dx
      ,rf.Readmission_Dx_Name
      ,rf.peds
      ,rf.transplant
      ,rf.UVaID
      ,CASE
           WHEN rf.UVaID IS NULL
           THEN NULL
           ELSE CONCAT(rf.UVaID, '@hscmail.mcc.virginia.edu')
       END                           AS discharging_md_email
      ,admphys.UVaID                 AS readm_UVaID
      ,CASE
           WHEN admphys.UVaID IS NULL
           THEN NULL
           ELSE CONCAT(admphys.UVaID, '@hscmail.mcc.virginia.edu')
       END                           AS readm_md_email
      ,rf.next_sk_Fact_Pt_Enc_Clrt   AS readmission_admission_sk_Fact_Pt_Enc_Clrt
      ,rf.transplant_pt
      ,rf.financial_division         AS financial_division_id
      ,rf.financial_division_name
      ,rf.financial_subdivision      AS financial_sub_division_id
      ,rf.financial_subdivision_name AS financial_sub_division_name
      ,loc.LOC_ID                    AS rev_location_id
      ,loc.REV_LOC_NAME              AS rev_location
      ,rf.loc_hs_area_id
      ,rf.loc_hs_area_name
      ,admphys.sk_Dim_Physcn         AS readm_sk_dim_physcn
      ,rf.sk_Dim_physcn
      ,rf.som_group_id
      ,rf.som_group                  AS som_group_name
      ,rf.som_department_id
      ,rf.som_department             AS som_department_name
      ,rf.som_division_id
      ,rf.som_division_name
      ,rf.som_hs_area_id             AS w_som_hs_area_id
      ,rf.som_hs_area_name           AS w_som_hs_area_name
      ,rf.person_gender
      ,CAST(CASE
                WHEN prov_team.PAT_ENC_CSN_ID IS NOT NULL
                THEN 1
                ELSE 0
            END AS SMALLINT)         AS oncology
      ,vrpc.ServiceLine_Division
FROM #RptgFinal             AS rf

    -- NICU--for determining sub-service
    LEFT OUTER JOIN
    (
        SELECT DISTINCT
               pehc.sk_Fact_Pt_Enc_Clrt
        FROM DS_HSDW_Prod.Rptg.vwFact_Pt_Enc_Hsp_Clrt          AS pehc
            INNER JOIN DS_HSDW_Prod.Rptg.vwFact_Pt_Enc_Clrt    AS pec
                ON pehc.sk_Fact_Pt_Enc_Clrt = pec.sk_Fact_Pt_Enc_Clrt
            INNER JOIN DS_HSDW_Prod.Rptg.vwFact_Clrt_ADT       AS adt
                ON pehc.sk_Fact_Pt_Enc_Clrt = adt.sk_Fact_Pt_Enc_Clrt
            INNER JOIN DS_HSDW_Prod.Rptg.vwDim_Date            AS ddte
                ON pehc.sk_Dsch_Dte = ddte.date_key
            INNER JOIN DS_HSDW_Prod.Rptg.vwDim_Patient         AS patient
                ON pec.sk_Dim_Clrt_Pt = patient.sk_Dim_Clrt_Pt
            INNER JOIN DS_HSDW_Prod.Rptg.vwDim_Clrt_Disch_Disp AS cdd
                ON pehc.sk_Dim_Clrt_Disch_Disp = cdd.sk_Dim_Clrt_Disch_Disp
            INNER JOIN #RptgFinalBalancedScorecard             AS rs
                ON rs.sk_Fact_Pt_Enc_Clrt = pehc.sk_Fact_Pt_Enc_Clrt
        WHERE adt.sk_Dim_Clrt_DEPt = 392 -- UVHE NEWBORN ICU
              AND FLOOR((CAST(ddte.day_date AS INTEGER) - CAST(CAST(patient.BirthDate AS DATETIME) AS INTEGER))) < 28
              AND cdd.sk_Dim_Clrt_Disch_Disp NOT IN ( '1', '7', '12', '26', '31', '33' )
    )                       AS nicu
        ON rf.sk_Fact_Pt_Enc_Clrt = nicu.sk_Fact_Pt_Enc_Clrt

    --digestive health for determining sub-service

    LEFT OUTER JOIN #dh_pat AS dp
        ON dp.sk_Fact_Pt_Enc_Clrt = rf.sk_Fact_Pt_Enc_Clrt

    -- ------------------------------------
    -- First prov team
    -- ------------------------------------
    OUTER APPLY
(
    SELECT prteam.sk_Fact_Pt_Enc_Clrt
          ,prteam.PAT_ENC_CSN_ID
          ,prteam.Team_LINE
          ,prteam.sk_Dim_Clrt_Prov_Team
          ,team.RECORD_NAME
          ,prteam.ID
          ,prteam.Team_Action
          ,prteam.PRIMARYTEAM_AUDI_YN
          ,prteam.sk_Dim_Clrt_EMPlye
          ,prteam.TEAM_AUDIT_INSTANT
          ,prteam.Load_Dtm
          ,prteam.UpDte_Dtm
    FROM DS_HSDW_Prod.dbo.Fact_Clrt_EPT_TEAM_AUDIT            AS prteam
        INNER JOIN DS_HSDW_Prod.Rptg.vwDim_Clrt_EMPlye        AS emp
            ON emp.sk_Dim_Clrt_EMPlye = prteam.sk_Dim_Clrt_EMPlye
        INNER JOIN DS_HSDW_Prod.Rptg.vwDim_Clrt_SERsrc        AS ser
            ON emp.EMPlye_PROV_ID = ser.PROV_ID
        INNER JOIN DS_HSDW_Prod.dbo.Dim_Clrt_Prov_Team_Record AS team
            ON prteam.ID = team.ID
    WHERE prteam.Team_LINE = 1
          AND prteam.PRIMARYTEAM_AUDI_YN = 'Y' --first primary prov team
          AND team.RECORD_NAME LIKE 'hem%onc%' --oncology teams
          AND prteam.sk_Fact_Pt_Enc_Clrt = rf.sk_Fact_Pt_Enc_Clrt
)                           AS prov_team


    --for sk and uvaid of admitting physician for the readmission

    LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Clrt_SERsrc                AS admser
        ON rf.readm_provider_id = admser.PROV_ID
    LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwRef_Physcn_Combined            AS admphys
        ON admphys.sk_Dim_Physcn = admser.sk_Dim_Physcn
    LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwRef_MDM_Location_Master_locsvc AS loc
        ON loc.epic_department_id = rf.epic_department_id
    LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwRef_Physcn_Combined            AS vrpc
        ON rf.provider_id = vrpc.PROV_ID
ORDER BY rf.event_type
        ,rf.event_date;

GO


