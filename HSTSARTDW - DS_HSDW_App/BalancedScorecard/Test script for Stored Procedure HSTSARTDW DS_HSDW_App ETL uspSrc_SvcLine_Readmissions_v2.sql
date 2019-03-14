USE [DS_HSDW_App]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

DECLARE @startdate AS SMALLDATETIME;
DECLARE @enddate AS SMALLDATETIME;
SET @startdate = NULL
SET @enddate = NULL

--ALTER PROCEDURE [ETL].[uspSrc_SvcLine_Readmissions_v2] (@startdate SMALLDATETIME = NULL, @enddate SMALLDATETIME = NULL)
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
*****************************************************************************************************************************************/

SET NOCOUNT ON;

--DECLARE @startdate SMALLDATETIME = NULL, @enddate SMALLDATETIME = NULL;
--DECLARE @startdate SMALLDATETIME='7/1/2017',
--@enddate SMALLDATETIME='5/1/2018'

DECLARE @strIndexDischargeBegindt AS VARCHAR(19);


DECLARE @currdate SMALLDATETIME;

SET @currdate = CAST(CAST(GETDATE() AS DATE) AS SMALLDATETIME);


IF  @startdate IS NULL
AND @enddate IS NULL
    EXEC ETL.usp_Get_Dash_Dates_BalancedScorecard @startdate OUTPUT, @enddate OUTPUT;


----BDD 08/20/2018
---Special handling in August due to this metric being an additional month in arrears. Can't cut off prior FY in the middle so roll it back a year
IF DATEPART(mm, @currdate) = 8
BEGIN
    SET @startdate = DATEADD(yy, -1, @startdate);
    SET @enddate = DATEADD(yy, -1, @enddate);
END;
-------------------------------------

-- 30-days prior to reporting period begin date
SET @strIndexDischargeBegindt = DATEADD(DAY, -30, DATEADD(MONTH, DATEDIFF(MONTH, 0, @startdate), 0));

if OBJECT_ID('tempdb..#ip_accts') is not NULL
DROP TABLE #ip_accts

if OBJECT_ID('tempdb..#ip_dxs') is not NULL
DROP TABLE #ip_dxs

if OBJECT_ID('tempdb..#ip_adm_dxs') is not NULL
DROP TABLE #ip_adm_dxs

if OBJECT_ID('tempdb..#ip_prim_dxs') is not NULL
DROP TABLE #ip_prim_dxs

if OBJECT_ID('tempdb..#ip_dsch_dxs') is not NULL
DROP TABLE #ip_dsch_dxs

if OBJECT_ID('tempdb..#ip_accts_dxs') is not NULL
DROP TABLE #ip_accts_dxs

if OBJECT_ID('tempdb..#ip_accts_discharges') is not NULL
DROP TABLE #ip_accts_discharges

if OBJECT_ID('tempdb..#RptgFinalBalancedScorecard') is not NULL
DROP TABLE #RptgFinalBalancedScorecard

if OBJECT_ID('tempdb..#RptgFinal') is not NULL
DROP TABLE #RptgFinal

/*  build a temp table of all valid, non-TCH, inpatient accounts  */
SELECT              DISTINCT
                    clrt.sk_Adm_Dte
                   ,clrt.sk_Dsch_Dte
                   ,clrt.sk_Fact_Pt_Enc_Clrt
                   ,clrt.sk_Fact_Pt_Acct
                   ,clrt.AcctNbr_int
                   ,clrt.PT_LNAME
                   ,clrt.PT_FNAME_MI
                   ,clrt.BIRTH_DATE
                   ,clrt.MRN_int   AS MRN_Clrt
                   ,aggr.FY
                   ,clrt.adm_Fyear_num
                   ,clrt.adm_fmonth_num
                   ,clrt.adm_FYear_name
                   ,clrt.dsch_Fyear_num
                   ,clrt.dsch_fmonth_num
                   ,clrt.dsch_FYear_name
                   ,clrt.MRN_int
                   ,aggr.Complete
                   ,aggr.LOS
                   ,aggr.CMI
                   ,clrt.dsch_date AS IndexDischarge
                   ,clrt.adm_date  AS Admission
                   ,clrt.sk_Dim_Clrt_Pt
                   ,aggr.sk_Dim_Pt
                   ,aggr.sk_Adm_Bed_Unit_Inv
                   ,aggr.sk_Dsch_Bed_Unit_Inv
                   ,adm.UNIT       AS adm_Unit
                   ,dsch.UNIT      AS dsch_Unit
                   ,adm.Unit_Nme   AS adm_Unit_Nme
                   ,dsch.Unit_Nme  AS dsch_Unit_Nme
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
                   ,clrt.adm_enc_provider_id
                   ,clrt.adm_enc_provider_name
                   ,clrt.dsch_enc_provider_id
                   ,clrt.dsch_enc_provider_name
                   ,clrt.adm_atn_prov_provider_id
                   ,clrt.adm_atn_prov_provider_name
                   ,clrt.dsch_atn_prov_provider_id
                   ,clrt.dsch_atn_prov_provider_name
                   ,clrt.adm_enc_sk_phys_adm
                   ,clrt.enc_sk_physcn
                   ,aggr.sk_Phys_Atn
                   ,CASE
                        WHEN ((aggr.sk_Phys_Atn IS NOT NULL) AND (aggr.sk_Phys_Atn > 0))
                        THEN aggr.sk_Phys_Atn
                        WHEN ((clrt.adm_enc_sk_phys_adm IS NOT NULL) AND (clrt.adm_enc_sk_phys_adm > 0))
                        THEN clrt.adm_enc_sk_phys_adm
                        ELSE -999
                    END            AS derived_sk_Phys_Atn
                   ,clrt.adm_date
                   ,clrt.dsch_date
                   ,clrt.adm_date_time
                   ,clrt.dsch_date_time
                   ,clrt.sk_Dim_Clrt_Disch_Disp
                   ,clrt.DISCH_DISP_C
                   ,clrt.Clrt_Disch_Disp
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
                   ,clrt.adm_enc_physcn_Service_Line
                   ,clrt.adm_atn_prov_physcn_Service_Line
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
                   ,clrt.dsch_enc_physcn_Service_Line
                   ,clrt.dsch_atn_prov_physcn_Service_Line
INTO                #ip_accts
FROM                DS_HSDW_App.Rptg.PatientDischargeByService_v2 AS clrt
    LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwFact_Pt_Acct_Aggr_NonLag  AS aggr ON aggr.sk_Fact_Pt_Acct = clrt.sk_Fact_Pt_Acct

    LEFT OUTER JOIN
                    (
                        SELECT sk_Dim_Bed_Unit_Inv, UNIT, Unit_Nme
                        FROM   DS_HSDW_Prod.Rptg.vwDim_Bed_Unit_Invision
                        WHERE  sk_Dim_Bed_Unit_Inv > 0
                    )                                             AS adm ON aggr.sk_Adm_Bed_Unit_Inv = adm.sk_Dim_Bed_Unit_Inv

    LEFT OUTER JOIN
                    (
                        SELECT sk_Dim_Bed_Unit_Inv, UNIT, Unit_Nme
                        FROM   DS_HSDW_Prod.Rptg.vwDim_Bed_Unit_Invision
                        WHERE  sk_Dim_Bed_Unit_Inv > 0
                    )                                             AS dsch ON aggr.sk_Dsch_Bed_Unit_Inv = dsch.sk_Dim_Bed_Unit_Inv
--WHERE               clrt.adt_pt_cls IN ( 'Inpatient', 'Inpatient Psychiatry', 'Newborn' ) --inpatients
--AND                 (LEFT(clrt.adm_mdm_epic_department, 2) <> 'TC' OR clrt.adm_mdm_epic_department IS NULL) --no TCH
WHERE               (LEFT(clrt.adm_mdm_epic_department, 2) <> 'TC' OR clrt.adm_mdm_epic_department IS NULL) --no TCH
AND                 NOT (   (clrt.ADMIT_CATEGORY_C = 5)
                     AND    -- Inpatient Pre-admit
                            (aggr.sk_Dsch_Dte = 19000101)
                        )
AND
                    ((  clrt.dsch_date >= @strIndexDischargeBegindt) -- Discharge dates with possible readmissions in the reporting period
                  OR
                   ((  clrt.sk_Dsch_Dte = 19000101) -- include admissions without a discharge
                AND ((clrt.adm_date >= @strIndexDischargeBegindt) AND (clrt.adm_date <= CAST(@enddate AS DATE)))
                   )
                    )
AND                 aggr.MRN_int > 0;

--
--	Admission Diagnosis
--
SELECT              DISTINCT
                    ddx.Dx_Cde, ddx.Dx_Cde_Dotless, ddx.Dx_Nme, fdx.sk_Fact_Pt_Acct, accts.AcctNbr_int, fdx.Dx_Clasf_cde, fdx.Dx_Prio_Nbr
INTO                #ip_adm_dxs
FROM                DS_HSDW_Prod.Rptg.vwFact_Pt_Dx AS fdx WITH (NOLOCK)
    INNER JOIN      #ip_accts                      AS accts ON accts.sk_Fact_Pt_Acct = fdx.sk_Fact_Pt_Acct

    LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Dx     AS ddx WITH (NOLOCK) ON fdx.sk_Dim_Dx = ddx.sk_dim_dx
WHERE               fdx.Dx_Clasf_cde = 'DA'
AND                 fdx.Dx_Prio_Nbr IN ( 1, 10001 );

--
--	Discharge Diagnosis
--
SELECT              DISTINCT
                    ddx.Dx_Cde, ddx.Dx_Cde_Dotless, ddx.Dx_Nme, prim.sk_Fact_Pt_Acct, accts.AcctNbr_int
INTO                #ip_dsch_dxs
FROM                DS_HSDW_Prod.Rptg.vwFact_Pt_Acct_Prmrys AS prim WITH (NOLOCK)
    INNER JOIN      #ip_accts                               AS accts ON  accts.sk_Fact_Pt_Acct = prim.sk_Fact_Pt_Acct
                                                                     AND accts.FY = prim.FY

    LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Dx              AS ddx WITH (NOLOCK) ON prim.sk_Prmry_Dx = ddx.sk_dim_dx
WHERE               prim.sk_Prmry_Dx > 100;

/*  build a temp table of all valid, non-TCH, inpatient accounts with diagnoses  */
SELECT              accts.sk_Adm_Dte
                   ,accts.sk_Dsch_Dte
                   ,accts.sk_Fact_Pt_Enc_Clrt
                   ,accts.sk_Fact_Pt_Acct
                   ,accts.AcctNbr_int
                   ,accts.PT_LNAME
                   ,accts.PT_FNAME_MI
                   ,accts.BIRTH_DATE
                   ,accts.MRN_Clrt
                   ,accts.FY
                   ,accts.adm_Fyear_num
                   ,accts.adm_fmonth_num
                   ,accts.adm_FYear_name
                   ,accts.dsch_Fyear_num
                   ,accts.dsch_fmonth_num
                   ,accts.dsch_FYear_name
                   ,accts.MRN_int
                   ,accts.Complete
                   ,accts.LOS
                   ,accts.CMI
                   ,accts.IndexDischarge
                   ,accts.Admission
                   ,accts.sk_Dim_Clrt_Pt
                   ,accts.sk_Dim_Pt
                   ,accts.sk_Adm_Bed_Unit_Inv
                   ,accts.sk_Dsch_Bed_Unit_Inv
                   ,CASE
                        WHEN ((accts.adm_Unit IS NOT NULL) AND (accts.adm_Unit <> 'NA'))
                        THEN accts.adm_Unit
                        WHEN
                           (   (  accts.adm_Unit IS NOT NULL)
                        AND    (accts.adm_Unit = 'NA')
                        AND    ((accts.adm_DEPARTMENT_ID IS NOT NULL) AND (accts.adm_DEPARTMENT_ID >= 0))
                           )
                        THEN admdep.Clrt_DEPt_Nme
                        WHEN
                           ((  accts.adm_Unit IS NULL)
                        AND ((accts.adm_DEPARTMENT_ID IS NOT NULL) AND (accts.adm_DEPARTMENT_ID >= 0))
                           )
                        THEN admdep.Clrt_DEPt_Nme
                        ELSE NULL
                    END                   AS adm_Unit
                   ,CASE
                        WHEN ((accts.adm_Unit_Nme IS NOT NULL) AND (accts.adm_Unit_Nme <> 'Unknown'))
                        THEN accts.adm_Unit_Nme
                        WHEN
                           (   (  accts.adm_Unit_Nme IS NOT NULL)
                        AND    (accts.adm_Unit_Nme = 'Unknown')
                        AND    ((accts.adm_DEPARTMENT_ID IS NOT NULL) AND (accts.adm_DEPARTMENT_ID >= 0))
                           )
                        THEN admdep.Clrt_DEPt_Ext_Nme
                        WHEN
                           ((  accts.adm_Unit_Nme IS NULL)
                        AND ((accts.adm_DEPARTMENT_ID IS NOT NULL) AND (accts.adm_DEPARTMENT_ID >= 0))
                           )
                        THEN admdep.Clrt_DEPt_Ext_Nme
                        ELSE NULL
                    END                   AS adm_Unit_Nme
                   ,CASE
                        WHEN ((accts.dsch_Unit IS NOT NULL) AND (accts.dsch_Unit <> 'NA'))
                        THEN accts.dsch_Unit
                        WHEN
                           (   (  accts.dsch_Unit IS NOT NULL)
                        AND    (accts.dsch_Unit = 'NA')
                        AND    ((accts.dsch_DEPARTMENT_ID IS NOT NULL) AND (accts.dsch_DEPARTMENT_ID >= 0))
                           )
                        THEN dschdep.Clrt_DEPt_Nme
                        WHEN
                           ((  accts.dsch_Unit IS NULL)
                        AND ((accts.dsch_DEPARTMENT_ID IS NOT NULL) AND (accts.dsch_DEPARTMENT_ID >= 0))
                           )
                        THEN dschdep.Clrt_DEPt_Nme
                        ELSE NULL
                    END                   AS dsch_Unit
                   ,CASE
                        WHEN ((accts.dsch_Unit_Nme IS NOT NULL) AND (accts.dsch_Unit_Nme <> 'Unknown'))
                        THEN accts.dsch_Unit_Nme
                        WHEN
                           (   (  accts.dsch_Unit_Nme IS NOT NULL)
                        AND    (accts.dsch_Unit_Nme = 'Unknown')
                        AND    ((accts.dsch_DEPARTMENT_ID IS NOT NULL) AND (accts.dsch_DEPARTMENT_ID >= 0))
                           )
                        THEN dschdep.Clrt_DEPt_Ext_Nme
                        WHEN
                           ((  accts.dsch_Unit_Nme IS NULL)
                        AND ((accts.dsch_DEPARTMENT_ID IS NOT NULL) AND (accts.dsch_DEPARTMENT_ID >= 0))
                           )
                        THEN dschdep.Clrt_DEPt_Ext_Nme
                        ELSE NULL
                    END                   AS dsch_Unit_Nme
                   ,accts.adm_LOC_Nme
                   ,accts.dsch_LOC_Nme
                   ,accts.adm_DEPARTMENT_ID
                   ,accts.dsch_DEPARTMENT_ID
                   ,accts.HOSP_ADMSSN_STATS_C
                   ,accts.ADMIT_CATEGORY_C
                   ,accts.ADMIT_CATEGORY
                   ,accts.ADM_SOURCE
                   ,accts.HOSP_ADMSN_TYPE
                   ,accts.HOSP_ADMSN_STATUS
                   ,accts.ADMIT_CONF_STAT
                   ,accts.ADT_PATIENT_STAT
                   ,accts.adt_pt_cls
                   ,CASE
                        WHEN accts.adm_atn_prov_provider_id IS NOT NULL
                        THEN accts.adm_atn_prov_provider_id
                        WHEN accts.adm_enc_provider_id IS NOT NULL
                        AND  accts.adm_enc_provider_id <> 'Unknown'
                        THEN accts.adm_enc_provider_id
                        WHEN accts.derived_sk_Phys_Atn <> -999
                        THEN ser.PROV_ID
                        ELSE 'Unknown'
                    END                   AS adm_provider_id
                   ,CASE
                        WHEN accts.adm_atn_prov_provider_id IS NOT NULL
                        THEN accts.adm_atn_prov_provider_name
                        WHEN accts.adm_enc_provider_id IS NOT NULL
                        AND  accts.adm_enc_provider_id <> 'Unknown'
                        THEN accts.adm_enc_provider_name
                        WHEN accts.derived_sk_Phys_Atn <> -999
                        THEN ser.Prov_Nme
                        ELSE 'Unknown'
                    END                   AS adm_provider_name
                   ,CASE
                        WHEN accts.adm_atn_prov_provider_id IS NOT NULL
                        THEN accts.adm_atn_prov_physcn_Service_Line
                        WHEN accts.adm_enc_provider_id IS NOT NULL
                        AND  accts.adm_enc_provider_id <> 'Unknown'
                        THEN accts.adm_enc_physcn_Service_Line
                        WHEN accts.derived_sk_Phys_Atn <> -999
                        THEN phys.Service_Line
                        ELSE 'Unknown'
                    END                   AS adm_physcn_service_line
                   ,CASE
                        WHEN accts.sk_Dsch_Dte = 19000101
                        THEN 'Unknown'
                        WHEN accts.dsch_atn_prov_provider_id IS NOT NULL
                        THEN accts.dsch_atn_prov_provider_id
                        WHEN accts.dsch_enc_provider_id IS NOT NULL
                        AND  accts.dsch_enc_provider_id <> 'Unknown'
                        THEN accts.dsch_enc_provider_id
                        WHEN accts.derived_sk_Phys_Atn <> -999
                        THEN ser.PROV_ID
                        ELSE 'Unknown'
                    END                   AS dsch_provider_id
                   ,CASE
                        WHEN accts.sk_Dsch_Dte = 19000101
                        THEN 'Unknown'
                        WHEN accts.dsch_atn_prov_provider_id IS NOT NULL
                        THEN accts.dsch_atn_prov_provider_name
                        WHEN accts.dsch_enc_provider_id IS NOT NULL
                        AND  accts.dsch_enc_provider_id <> 'Unknown'
                        THEN accts.dsch_enc_provider_name
                        WHEN accts.derived_sk_Phys_Atn <> -999
                        THEN ser.Prov_Nme
                        ELSE 'Unknown'
                    END                   AS dsch_provider_name
                   ,CASE
                        WHEN physsvc.Service_Line_ID IS NULL
                        THEN CAST(NULL AS INTEGER)
                        ELSE CAST(physsvc.Service_Line_ID AS INTEGER)
                    END                   AS dsch_physcn_service_line_id
                   ,CASE
                        WHEN physsvc.Service_Line IS NULL
                        THEN CAST(NULL AS VARCHAR(150))
                        ELSE physsvc.Service_Line
                    END                   AS dsch_physcn_service_line
                   ,accts.adm_enc_sk_phys_adm
                   ,accts.enc_sk_physcn
                   ,accts.sk_Phys_Atn
                   ,accts.derived_sk_Phys_Atn
                   ,accts.Clrt_Disch_Disp
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
                   ,admdep.Clrt_DEPt_Nme  AS adm_Clrt_DEPt_Nme
                   ,dschdep.Clrt_DEPt_Nme AS dsch_Clrt_DEPt_Nme
                   ,adxs.dx_cde           AS adm_dx_cde
                   ,adxs.dx_nme           AS adm_dx_nme
                   ,ddxs.dx_cde           AS dsch_dx_cde
                   ,ddxs.dx_nme           AS dsch_dx_nme
INTO                #ip_accts_dxs
FROM                #ip_accts                            AS accts
    LEFT OUTER JOIN #ip_adm_dxs                          AS adxs ON adxs.sk_Fact_Pt_Acct = accts.sk_Fact_Pt_Acct

    LEFT OUTER JOIN #ip_dsch_dxs                         AS ddxs ON ddxs.sk_Fact_Pt_Acct = accts.sk_Fact_Pt_Acct

    LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Clrt_DEPt    AS admdep ON admdep.DEPARTMENT_ID = accts.adm_DEPARTMENT_ID

    LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Clrt_DEPt    AS dschdep ON dschdep.DEPARTMENT_ID = accts.dsch_DEPARTMENT_ID

    LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Clrt_SERsrc  AS ser ON ser.sk_Dim_Physcn = accts.derived_sk_Phys_Atn

    LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Physcn       AS phys ON phys.sk_Dim_Physcn = accts.derived_sk_Phys_Atn

    LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwRef_Service_Line AS physsvc ON physsvc.Physician_Roster_Name = CASE
                                                                                                           WHEN
                                                                                                              (   (  accts.dsch_atn_prov_provider_id IS NOT NULL)
                                                                                                           AND    (accts.dsch_atn_prov_physcn_Service_Line IS NOT NULL)
                                                                                                              )
                                                                                                           THEN accts.dsch_atn_prov_physcn_Service_Line
                                                                                                           --WHEN accts.dsch_enc_provider_id IS NOT NULL AND accts.dsch_enc_provider_id <> 'Unknown' THEN accts.dsch_enc_physcn_Service_Line
                                                                                                           --WHEN accts.derived_sk_Phys_Atn <> -999 THEN phys.Service_Line
                                                                                                           ELSE 'No Value Specified'
                                                                                                       END;
SELECT	MRN_int
      , sk_Adm_Dte
	  , sk_Dsch_Dte
	  , adm_DEPARTMENT_ID
	  , dsch_DEPARTMENT_ID
	  , ADT_PATIENT_STAT
	  , adt_pt_cls
	  , HOSP_ADMSN_TYPE
	  , HOSP_ADMSN_STATUS
FROM #ip_accts_dxs
ORDER BY MRN_int
       , sk_Adm_Dte
	   , sk_Dsch_Dte
/*
/*  build a temp table of all valid inpatient discharges for the reporting month  */
SELECT sk_Adm_Dte
      ,sk_Dsch_Dte
      ,sk_Fact_Pt_Enc_Clrt
      ,sk_Fact_Pt_Acct
      ,AcctNbr_int
      ,PT_LNAME
      ,PT_FNAME_MI
      ,BIRTH_DATE
      ,MRN_Clrt
      ,FY
      ,adm_Fyear_num
      ,adm_fmonth_num
      ,adm_FYear_name
      ,dsch_Fyear_num
      ,dsch_fmonth_num
      ,dsch_FYear_name
      ,MRN_int
      ,Complete
      ,LOS
      ,CMI
      ,IndexDischarge
      ,Admission
      ,sk_Dim_Clrt_Pt
      ,sk_Dim_Pt
      ,sk_Adm_Bed_Unit_Inv
      ,sk_Dsch_Bed_Unit_Inv
      ,adm_Unit
      ,adm_Unit_Nme
      ,dsch_Unit
      ,dsch_Unit_Nme
      ,adm_LOC_Nme
      ,dsch_LOC_Nme
      ,adm_DEPARTMENT_ID
      ,dsch_DEPARTMENT_ID
      ,HOSP_ADMSSN_STATS_C
      ,ADMIT_CATEGORY_C
      ,ADMIT_CATEGORY
      ,ADM_SOURCE
      ,HOSP_ADMSN_TYPE
      ,HOSP_ADMSN_STATUS
      ,ADMIT_CONF_STAT
      ,ADT_PATIENT_STAT
      ,adt_pt_cls
      ,adm_provider_id
      ,adm_provider_name
      ,adm_physcn_service_line
      ,dsch_provider_id
      ,dsch_provider_name
      ,dsch_physcn_service_line_id
      ,dsch_physcn_service_line
      ,adm_enc_sk_phys_adm
      ,enc_sk_physcn
      ,sk_Phys_Atn
      ,derived_sk_Phys_Atn
      ,Clrt_Disch_Disp
      ,adm_mdm_practice_group_id
      ,adm_mdm_practice_group_name
      ,adm_mdm_service_line_id
      ,adm_mdm_service_line
      ,adm_mdm_sub_service_line_id
      ,adm_mdm_sub_service_line
      ,adm_mdm_opnl_service_id
      ,adm_mdm_opnl_service_name
      ,adm_mdm_hs_area_id
      ,adm_mdm_hs_area_name
      ,adm_mdm_epic_department
      ,adm_mdm_epic_department_external
      ,dsch_mdm_practice_group_id
      ,dsch_mdm_practice_group_name
      ,dsch_mdm_service_line_id
      ,dsch_mdm_service_line
      ,dsch_mdm_sub_service_line_id
      ,dsch_mdm_sub_service_line
      ,dsch_mdm_opnl_service_id
      ,dsch_mdm_opnl_service_name
      ,dsch_mdm_hs_area_id
      ,dsch_mdm_hs_area_name
      ,dsch_mdm_epic_department
      ,dsch_mdm_epic_department_external
      ,adm_Clrt_DEPt_Nme
      ,dsch_Clrt_DEPt_Nme
      ,adm_dx_cde
      ,adm_dx_nme
      ,dsch_dx_cde
      ,dsch_dx_nme
INTO   #ip_accts_discharges
FROM   #ip_accts_dxs
WHERE  IndexDischarge >= @startdate
AND    IndexDischarge < @enddate -- Discharge dates within reporting period
AND    Clrt_Disch_Disp NOT IN ( 'Expired', 'Expired in Medical Facility' );

--create final dataset excluding the same day admissions to psych which are considered transfers
SELECT   final.sk_Adm_Dte
        ,final.sk_Dsch_Dte
        ,final.sk_Fact_Pt_Enc_Clrt
        ,final.sk_Fact_Pt_Acct
        ,final.sk_Dim_Pt
        ,final.AcctNbr_int
        ,final.PT_LNAME
        ,final.PT_FNAME_MI
        ,final.BIRTH_DATE
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
        ,final.dsch_physcn_service_line_id
        ,final.dsch_physcn_service_line
        ,final.adm_dx_cde
        ,final.adm_dx_nme
        ,final.dsch_dx_cde
        ,final.dsch_dx_nme
        ,final.next_sk_Adm_Dte
        ,final.next_sk_Dsch_Dte
        ,final.next_sk_Fact_Pt_Enc_Clrt
        ,final.next_sk_Fact_Pt_Acct
        ,final.next_AcctNbr_int
        ,final.next_adm_Fyear_num
        ,final.next_adm_fmonth_num
        ,final.next_adm_FYear_name
        ,final.next_dsch_fyear_num
        ,final.next_dsch_fmonth_num
        ,final.next_dsch_fYear_name
        ,final.next_IndexDischarge
        ,final.next_Admission
        ,final.next_sk_Adm_Bed_Unit_Inv
        ,final.next_sk_Dsch_Bed_Unit_Inv
        ,final.next_adm_Unit
        ,final.next_adm_Unit_Nme
        ,final.next_adm_LOC_Nme
        ,final.next_dsch_LOC_Nme
        ,final.next_adm_DEPARTMENT_ID
        ,final.next_dsch_DEPARTMENT_ID
        ,final.next_adm_Clrt_DEPt_Nme
        ,final.next_dsch_Clrt_DEPt_Nme
        ,final.next_HOSP_ADMSSN_STATS_C
        ,final.next_ADMIT_CATEGORY_C
        ,final.next_ADMIT_CATEGORY
        ,final.next_ADM_SOURCE
        ,final.next_HOSP_ADMSN_TYPE
        ,final.next_HOSP_ADMSN_STATUS
        ,final.next_ADMIT_CONF_STAT
        ,final.next_ADT_PATIENT_STAT
        ,final.next_adt_pt_cls
        ,final.next_adm_provider_id
        ,final.next_adm_provider_name
        ,final.next_dsch_provider_id
        ,final.next_dsch_provider_name
        ,final.next_adm_enc_sk_phys_adm
        ,final.next_enc_sk_physcn
        ,final.next_sk_Phys_Atn
        ,final.next_derived_sk_Phys_Atn
        ,final.next_adm_mdm_practice_group_id
        ,final.next_adm_mdm_practice_group_name
        ,final.next_adm_mdm_service_line_id
        ,final.next_adm_mdm_service_line
        ,final.next_adm_mdm_sub_service_line_id
        ,final.next_adm_mdm_sub_service_line
        ,final.next_adm_mdm_opnl_service_id
        ,final.next_adm_mdm_opnl_service_name
        ,final.next_adm_mdm_hs_area_id
        ,final.next_adm_mdm_hs_area_name
        ,final.next_adm_mdm_epic_department
        ,final.next_adm_mdm_epic_department_external
        ,final.next_adm_physcn_service_line
        ,final.next_dsch_mdm_practice_group_id
        ,final.next_dsch_mdm_practice_group_name
        ,final.next_dsch_mdm_service_line_id
        ,final.next_dsch_mdm_service_line
        ,final.next_dsch_mdm_sub_service_line_id
        ,final.next_dsch_mdm_sub_service_line
        ,final.next_dsch_mdm_opnl_service_id
        ,final.next_dsch_mdm_opnl_service_name
        ,final.next_dsch_mdm_hs_area_id
        ,final.next_dsch_mdm_hs_area_name
        ,final.next_dsch_mdm_epic_department
        ,final.next_dsch_mdm_epic_department_external
        ,final.next_dsch_physcn_service_line_id
        ,final.next_dsch_physcn_service_line
        ,final.next_adm_dx_cde
        ,final.next_adm_dx_nme
        ,final.Duration
INTO     #RptgFinalBalancedScorecard
FROM
         ( --final
             --calculate duration and pull in admitting unit of the next admission
             SELECT  main.sk_Adm_Dte
                    ,main.sk_Dsch_Dte
                    ,main.sk_Fact_Pt_Enc_Clrt
                    ,main.sk_Fact_Pt_Acct
                    ,main.sk_Dim_Pt
                    ,main.AcctNbr_int
                    ,main.PT_LNAME
                    ,main.PT_FNAME_MI
                    ,main.BIRTH_DATE
                    ,main.MRN_Clrt
                    ,main.adm_Fyear_num
                    ,main.adm_fmonth_num
                    ,main.adm_FYear_name
                    ,main.dsch_Fyear_num
                    ,main.dsch_fmonth_num
                    ,main.dsch_FYear_name
                    ,main.IndexDischarge
                    ,main.Admission
                    ,main.sk_Adm_Bed_Unit_Inv
                    ,main.sk_Dsch_Bed_Unit_Inv
                    ,main.adm_Unit
                    ,main.adm_Unit_Nme
                    ,main.dsch_Unit
                    ,main.dsch_Unit_Nme
                    ,main.adm_LOC_Nme
                    ,main.dsch_LOC_Nme
                    ,main.adm_DEPARTMENT_ID
                    ,main.dsch_DEPARTMENT_ID
                    ,main.adm_Clrt_DEPt_Nme
                    ,main.dsch_Clrt_DEPt_Nme
                    ,main.HOSP_ADMSSN_STATS_C
                    ,main.ADMIT_CATEGORY_C
                    ,main.ADMIT_CATEGORY
                    ,main.ADM_SOURCE
                    ,main.HOSP_ADMSN_TYPE
                    ,main.HOSP_ADMSN_STATUS
                    ,main.ADMIT_CONF_STAT
                    ,main.ADT_PATIENT_STAT
                    ,main.adt_pt_cls
                    ,main.adm_provider_id
                    ,main.adm_provider_name
                    ,main.dsch_provider_id
                    ,main.dsch_provider_name
                    ,main.adm_enc_sk_phys_adm
                    ,main.enc_sk_physcn
                    ,main.sk_Phys_Atn
                    ,main.derived_sk_Phys_Atn
                    ,main.Clrt_Disch_Disp
                    ,main.adm_mdm_practice_group_id
                    ,main.adm_mdm_practice_group_name
                    ,main.adm_mdm_service_line_id
                    ,main.adm_mdm_service_line
                    ,main.adm_mdm_sub_service_line_id
                    ,main.adm_mdm_sub_service_line
                    ,main.adm_mdm_opnl_service_id
                    ,main.adm_mdm_opnl_service_name
                    ,main.adm_mdm_hs_area_id
                    ,main.adm_mdm_hs_area_name
                    ,main.adm_mdm_epic_department
                    ,main.adm_mdm_epic_department_external
                    ,main.adm_physcn_service_line
                    ,main.dsch_mdm_practice_group_id
                    ,main.dsch_mdm_practice_group_name
                    ,main.dsch_mdm_service_line_id
                    ,main.dsch_mdm_service_line
                    ,main.dsch_mdm_sub_service_line_id
                    ,main.dsch_mdm_sub_service_line
                    ,main.dsch_mdm_opnl_service_id
                    ,main.dsch_mdm_opnl_service_name
                    ,main.dsch_mdm_hs_area_id
                    ,main.dsch_mdm_hs_area_name
                    ,main.dsch_mdm_epic_department
                    ,main.dsch_mdm_epic_department_external
                    ,main.dsch_physcn_service_line_id
                    ,main.dsch_physcn_service_line
                    ,main.adm_dx_cde
                    ,main.adm_dx_nme
                    ,main.dsch_dx_cde
                    ,main.dsch_dx_nme
                    ,main.next_sk_Adm_Dte
                    ,main.next_sk_Dsch_Dte
                    ,main.next_sk_Fact_Pt_Enc_Clrt
                    ,main.next_sk_Fact_Pt_Acct
                    ,main.next_AcctNbr_int
                    ,main.next_adm_Fyear_num
                    ,main.next_adm_fmonth_num
                    ,main.next_adm_FYear_name
                    ,main.next_dsch_fyear_num
                    ,main.next_dsch_fmonth_num
                    ,main.next_dsch_fYear_name
                    ,main.next_IndexDischarge
                    ,main.next_Admission
                    ,main.next_sk_Adm_Bed_Unit_Inv
                    ,main.next_sk_Dsch_Bed_Unit_Inv
                    ,main.next_adm_Unit
                    ,main.next_adm_Unit_Nme
                    ,main.next_adm_LOC_Nme
                    ,main.next_dsch_LOC_Nme
                    ,main.next_adm_DEPARTMENT_ID
                    ,main.next_dsch_DEPARTMENT_ID
                    ,main.next_adm_Clrt_DEPt_Nme
                    ,main.next_dsch_Clrt_DEPt_Nme
                    ,main.next_HOSP_ADMSSN_STATS_C
                    ,main.next_ADMIT_CATEGORY_C
                    ,main.next_ADMIT_CATEGORY
                    ,main.next_ADM_SOURCE
                    ,main.next_HOSP_ADMSN_TYPE
                    ,main.next_HOSP_ADMSN_STATUS
                    ,main.next_ADMIT_CONF_STAT
                    ,main.next_ADT_PATIENT_STAT
                    ,main.next_adt_pt_cls
                    ,main.next_adm_provider_id
                    ,main.next_adm_provider_name
                    ,main.next_dsch_provider_id
                    ,main.next_dsch_provider_name
                    ,main.next_adm_enc_sk_phys_adm
                    ,main.next_enc_sk_physcn
                    ,main.next_sk_Phys_Atn
                    ,main.next_derived_sk_Phys_Atn
                    ,main.next_adm_mdm_practice_group_id
                    ,main.next_adm_mdm_practice_group_name
                    ,main.next_adm_mdm_service_line_id
                    ,main.next_adm_mdm_service_line
                    ,main.next_adm_mdm_sub_service_line_id
                    ,main.next_adm_mdm_sub_service_line
                    ,main.next_adm_mdm_opnl_service_id
                    ,main.next_adm_mdm_opnl_service_name
                    ,main.next_adm_mdm_hs_area_id
                    ,main.next_adm_mdm_hs_area_name
                    ,main.next_adm_mdm_epic_department
                    ,main.next_adm_mdm_epic_department_external
                    ,main.next_adm_physcn_service_line
                    ,main.next_dsch_mdm_practice_group_id
                    ,main.next_dsch_mdm_practice_group_name
                    ,main.next_dsch_mdm_service_line_id
                    ,main.next_dsch_mdm_service_line
                    ,main.next_dsch_mdm_sub_service_line_id
                    ,main.next_dsch_mdm_sub_service_line
                    ,main.next_dsch_mdm_opnl_service_id
                    ,main.next_dsch_mdm_opnl_service_name
                    ,main.next_dsch_mdm_hs_area_id
                    ,main.next_dsch_mdm_hs_area_name
                    ,main.next_dsch_mdm_epic_department
                    ,main.next_dsch_mdm_epic_department_external
                    ,main.next_dsch_physcn_service_line_id
                    ,main.next_dsch_physcn_service_line
                    ,main.next_adm_dx_cde
                    ,main.next_adm_dx_nme
                    ,DATEDIFF(DAY, main.IndexDischarge, main.next_Admission) AS Duration
             FROM
                     ( --main
                         --determine next admission
                         SELECT ia.sk_Adm_Dte
                               ,ia.sk_Dsch_Dte
                               ,ia.sk_Fact_Pt_Enc_Clrt
                               ,ia.sk_Fact_Pt_Acct
                               ,ia.sk_Dim_Pt
                               ,ia.AcctNbr_int
                               ,ia.PT_LNAME
                               ,ia.PT_FNAME_MI
                               ,ia.BIRTH_DATE
                               ,ia.MRN_Clrt
                               ,ia.MRN_int
                               ,ia.adm_Fyear_num
                               ,ia.adm_fmonth_num
                               ,ia.adm_FYear_name
                               ,ia.dsch_Fyear_num
                               ,ia.dsch_fmonth_num
                               ,ia.dsch_FYear_name
                               ,ia.IndexDischarge
                               ,ia.Admission
                               ,ia.sk_Adm_Bed_Unit_Inv
                               ,ia.sk_Dsch_Bed_Unit_Inv
                               ,ia.adm_Unit
                               ,ia.adm_Unit_Nme
                               ,ia.dsch_Unit
                               ,ia.dsch_Unit_Nme
                               ,ia.adm_LOC_Nme
                               ,ia.dsch_LOC_Nme
                               ,ia.adm_DEPARTMENT_ID
                               ,ia.dsch_DEPARTMENT_ID
                               ,ia.adm_Clrt_DEPt_Nme
                               ,ia.dsch_Clrt_DEPt_Nme
                               ,ia.HOSP_ADMSSN_STATS_C
                               ,ia.ADMIT_CATEGORY_C
                               ,ia.ADMIT_CATEGORY
                               ,ia.ADM_SOURCE
                               ,ia.HOSP_ADMSN_TYPE
                               ,ia.HOSP_ADMSN_STATUS
                               ,ia.ADMIT_CONF_STAT
                               ,ia.ADT_PATIENT_STAT
                               ,ia.adt_pt_cls
                               ,ia.adm_provider_id
                               ,ia.adm_provider_name
                               ,ia.dsch_provider_id
                               ,ia.dsch_provider_name
                               ,ia.adm_enc_sk_phys_adm
                               ,ia.enc_sk_physcn
                               ,ia.sk_Phys_Atn
                               ,ia.derived_sk_Phys_Atn
                               ,ia.Clrt_Disch_Disp
                               ,ia.adm_mdm_practice_group_id
                               ,ia.adm_mdm_practice_group_name
                               ,ia.adm_mdm_service_line_id
                               ,ia.adm_mdm_service_line
                               ,ia.adm_mdm_sub_service_line_id
                               ,ia.adm_mdm_sub_service_line
                               ,ia.adm_mdm_opnl_service_id
                               ,ia.adm_mdm_opnl_service_name
                               ,ia.adm_mdm_hs_area_id
                               ,ia.adm_mdm_hs_area_name
                               ,ia.adm_mdm_epic_department
                               ,ia.adm_mdm_epic_department_external
                               ,ia.adm_physcn_service_line
                               ,ia.dsch_mdm_practice_group_id
                               ,ia.dsch_mdm_practice_group_name
                               ,ia.dsch_mdm_service_line_id
                               ,ia.dsch_mdm_service_line
                               ,ia.dsch_mdm_sub_service_line_id
                               ,ia.dsch_mdm_sub_service_line
                               ,ia.dsch_mdm_opnl_service_id
                               ,ia.dsch_mdm_opnl_service_name
                               ,ia.dsch_mdm_hs_area_id
                               ,ia.dsch_mdm_hs_area_name
                               ,ia.dsch_mdm_epic_department
                               ,ia.dsch_mdm_epic_department_external
                               ,ia.dsch_physcn_service_line_id
                               ,ia.dsch_physcn_service_line
                               ,ia.adm_dx_cde
                               ,ia.adm_dx_nme
                               ,ia.dsch_dx_cde
                               ,ia.dsch_dx_nme
                               ,LEAD(ia.sk_Adm_Dte) OVER (PARTITION BY ia.MRN_int ORDER BY ia.sk_Adm_Dte, ia.sk_Fact_Pt_Enc_Clrt)                        AS next_sk_Adm_Dte
                               ,LEAD(ia.sk_Dsch_Dte) OVER (PARTITION BY ia.MRN_int ORDER BY ia.sk_Adm_Dte, ia.sk_Fact_Pt_Enc_Clrt)                       AS next_sk_Dsch_Dte
                               ,LEAD(ia.sk_Fact_Pt_Acct) OVER (PARTITION BY ia.MRN_int ORDER BY ia.sk_Adm_Dte, ia.sk_Fact_Pt_Enc_Clrt)                   AS next_sk_Fact_Pt_Acct
                               ,LEAD(ia.sk_Fact_Pt_Enc_Clrt) OVER (PARTITION BY ia.MRN_int ORDER BY ia.sk_Adm_Dte, ia.sk_Fact_Pt_Enc_Clrt)               AS next_sk_Fact_Pt_Enc_Clrt
                               ,LEAD(ia.AcctNbr_int) OVER (PARTITION BY ia.MRN_int ORDER BY ia.sk_Adm_Dte, ia.sk_Fact_Pt_Enc_Clrt)                       AS next_AcctNbr_int
                               ,LEAD(ia.adm_Fyear_num) OVER (PARTITION BY ia.MRN_int ORDER BY ia.sk_Adm_Dte, ia.sk_Fact_Pt_Enc_Clrt)                     AS next_adm_Fyear_num
                               ,LEAD(ia.adm_fmonth_num) OVER (PARTITION BY ia.MRN_int ORDER BY ia.sk_Adm_Dte, ia.sk_Fact_Pt_Enc_Clrt)                    AS next_adm_fmonth_num
                               ,LEAD(ia.adm_FYear_name) OVER (PARTITION BY ia.MRN_int ORDER BY ia.sk_Adm_Dte, ia.sk_Fact_Pt_Enc_Clrt)                    AS next_adm_FYear_name
                               ,LEAD(ia.dsch_Fyear_num) OVER (PARTITION BY ia.MRN_int ORDER BY ia.sk_Adm_Dte, ia.sk_Fact_Pt_Enc_Clrt)                    AS next_dsch_fyear_num
                               ,LEAD(ia.dsch_fmonth_num) OVER (PARTITION BY ia.MRN_int ORDER BY ia.sk_Adm_Dte, ia.sk_Fact_Pt_Enc_Clrt)                   AS next_dsch_fmonth_num
                               ,LEAD(ia.dsch_FYear_name) OVER (PARTITION BY ia.MRN_int ORDER BY ia.sk_Adm_Dte, ia.sk_Fact_Pt_Enc_Clrt)                   AS next_dsch_fYear_name
                               ,LEAD(ia.IndexDischarge) OVER (PARTITION BY ia.MRN_int ORDER BY ia.sk_Adm_Dte, ia.sk_Fact_Pt_Enc_Clrt)                    AS next_IndexDischarge
                               ,LEAD(ia.Admission) OVER (PARTITION BY ia.MRN_int ORDER BY ia.sk_Adm_Dte, ia.sk_Fact_Pt_Enc_Clrt)                         AS next_Admission
                               ,LEAD(ia.sk_Adm_Bed_Unit_Inv) OVER (PARTITION BY ia.MRN_int ORDER BY ia.sk_Adm_Dte, ia.sk_Fact_Pt_Enc_Clrt)               AS next_sk_Adm_Bed_Unit_Inv
                               ,LEAD(ia.sk_Dsch_Bed_Unit_Inv) OVER (PARTITION BY ia.MRN_int ORDER BY ia.sk_Adm_Dte, ia.sk_Fact_Pt_Enc_Clrt)              AS next_sk_Dsch_Bed_Unit_Inv
                               ,LEAD(ia.adm_Unit) OVER (PARTITION BY ia.MRN_int ORDER BY ia.sk_Adm_Dte, ia.sk_Fact_Pt_Enc_Clrt)                          AS next_adm_Unit
                               ,LEAD(ia.adm_Unit_Nme) OVER (PARTITION BY ia.MRN_int ORDER BY ia.sk_Adm_Dte, ia.sk_Fact_Pt_Enc_Clrt)                      AS next_adm_Unit_Nme
                               ,LEAD(ia.adm_LOC_Nme) OVER (PARTITION BY ia.MRN_int ORDER BY ia.sk_Adm_Dte, ia.sk_Fact_Pt_Enc_Clrt)                       AS next_adm_LOC_Nme
                               ,LEAD(ia.dsch_LOC_Nme) OVER (PARTITION BY ia.MRN_int ORDER BY ia.sk_Adm_Dte, ia.sk_Fact_Pt_Enc_Clrt)                      AS next_dsch_LOC_Nme
                               ,LEAD(ia.adm_DEPARTMENT_ID) OVER (PARTITION BY ia.MRN_int ORDER BY ia.sk_Adm_Dte, ia.sk_Fact_Pt_Enc_Clrt)                 AS next_adm_DEPARTMENT_ID
                               ,LEAD(ia.dsch_DEPARTMENT_ID) OVER (PARTITION BY ia.MRN_int ORDER BY ia.sk_Adm_Dte, ia.sk_Fact_Pt_Enc_Clrt)                AS next_dsch_DEPARTMENT_ID
                               ,LEAD(ia.adm_Clrt_DEPt_Nme) OVER (PARTITION BY ia.MRN_int ORDER BY ia.sk_Adm_Dte, ia.sk_Fact_Pt_Enc_Clrt)                 AS next_adm_Clrt_DEPt_Nme
                               ,LEAD(ia.dsch_Clrt_DEPt_Nme) OVER (PARTITION BY ia.MRN_int ORDER BY ia.sk_Adm_Dte, ia.sk_Fact_Pt_Enc_Clrt)                AS next_dsch_Clrt_DEPt_Nme
                               ,LEAD(ia.HOSP_ADMSSN_STATS_C) OVER (PARTITION BY ia.MRN_int ORDER BY ia.sk_Adm_Dte, ia.sk_Fact_Pt_Enc_Clrt)               AS next_HOSP_ADMSSN_STATS_C
                               ,LEAD(ia.ADMIT_CATEGORY_C) OVER (PARTITION BY ia.MRN_int ORDER BY ia.sk_Adm_Dte, ia.sk_Fact_Pt_Enc_Clrt)                  AS next_ADMIT_CATEGORY_C
                               ,LEAD(ia.ADMIT_CATEGORY) OVER (PARTITION BY ia.MRN_int ORDER BY ia.sk_Adm_Dte, ia.sk_Fact_Pt_Enc_Clrt)                    AS next_ADMIT_CATEGORY
                               ,LEAD(ia.ADM_SOURCE) OVER (PARTITION BY ia.MRN_int ORDER BY ia.sk_Adm_Dte, ia.sk_Fact_Pt_Enc_Clrt)                        AS next_ADM_SOURCE
                               ,LEAD(ia.HOSP_ADMSN_TYPE) OVER (PARTITION BY ia.MRN_int ORDER BY ia.sk_Adm_Dte, ia.sk_Fact_Pt_Enc_Clrt)                   AS next_HOSP_ADMSN_TYPE
                               ,LEAD(ia.HOSP_ADMSN_STATUS) OVER (PARTITION BY ia.MRN_int ORDER BY ia.sk_Adm_Dte, ia.sk_Fact_Pt_Enc_Clrt)                 AS next_HOSP_ADMSN_STATUS
                               ,LEAD(ia.ADMIT_CONF_STAT) OVER (PARTITION BY ia.MRN_int ORDER BY ia.sk_Adm_Dte, ia.sk_Fact_Pt_Enc_Clrt)                   AS next_ADMIT_CONF_STAT
                               ,LEAD(ia.ADT_PATIENT_STAT) OVER (PARTITION BY ia.MRN_int ORDER BY ia.sk_Adm_Dte, ia.sk_Fact_Pt_Enc_Clrt)                  AS next_ADT_PATIENT_STAT
                               ,LEAD(ia.adt_pt_cls) OVER (PARTITION BY ia.MRN_int ORDER BY ia.sk_Adm_Dte, ia.sk_Fact_Pt_Enc_Clrt)                        AS next_adt_pt_cls
                               ,LEAD(ia.adm_provider_id) OVER (PARTITION BY ia.MRN_int ORDER BY ia.sk_Adm_Dte, ia.sk_Fact_Pt_Enc_Clrt)                   AS next_adm_provider_id
                               ,LEAD(ia.adm_provider_name) OVER (PARTITION BY ia.MRN_int ORDER BY ia.sk_Adm_Dte, ia.sk_Fact_Pt_Enc_Clrt)                 AS next_adm_provider_name
                               ,LEAD(ia.dsch_provider_id) OVER (PARTITION BY ia.MRN_int ORDER BY ia.sk_Adm_Dte, ia.sk_Fact_Pt_Enc_Clrt)                  AS next_dsch_provider_id
                               ,LEAD(ia.dsch_provider_name) OVER (PARTITION BY ia.MRN_int ORDER BY ia.sk_Adm_Dte, ia.sk_Fact_Pt_Enc_Clrt)                AS next_dsch_provider_name
                               ,LEAD(ia.adm_enc_sk_phys_adm) OVER (PARTITION BY ia.MRN_int ORDER BY ia.sk_Adm_Dte, ia.sk_Fact_Pt_Enc_Clrt)               AS next_adm_enc_sk_phys_adm
                               ,LEAD(ia.enc_sk_physcn) OVER (PARTITION BY ia.MRN_int ORDER BY ia.sk_Adm_Dte, ia.sk_Fact_Pt_Enc_Clrt)                     AS next_enc_sk_physcn
                               ,LEAD(ia.sk_Phys_Atn) OVER (PARTITION BY ia.MRN_int ORDER BY ia.sk_Adm_Dte, ia.sk_Fact_Pt_Enc_Clrt)                       AS next_sk_Phys_Atn
                               ,LEAD(ia.derived_sk_Phys_Atn) OVER (PARTITION BY ia.MRN_int ORDER BY ia.sk_Adm_Dte, ia.sk_Fact_Pt_Enc_Clrt)               AS next_derived_sk_Phys_Atn
                               ,LEAD(ia.adm_mdm_practice_group_id) OVER (PARTITION BY ia.MRN_int ORDER BY ia.sk_Adm_Dte, ia.sk_Fact_Pt_Enc_Clrt)         AS next_adm_mdm_practice_group_id
                               ,LEAD(ia.adm_mdm_practice_group_name) OVER (PARTITION BY ia.MRN_int ORDER BY ia.sk_Adm_Dte, ia.sk_Fact_Pt_Enc_Clrt)       AS next_adm_mdm_practice_group_name
                               ,LEAD(ia.adm_mdm_service_line_id) OVER (PARTITION BY ia.MRN_int ORDER BY ia.sk_Adm_Dte, ia.sk_Fact_Pt_Enc_Clrt)           AS next_adm_mdm_service_line_id
                               ,LEAD(ia.adm_mdm_service_line) OVER (PARTITION BY ia.MRN_int ORDER BY ia.sk_Adm_Dte, ia.sk_Fact_Pt_Enc_Clrt)              AS next_adm_mdm_service_line
                               ,LEAD(ia.adm_mdm_sub_service_line_id) OVER (PARTITION BY ia.MRN_int ORDER BY ia.sk_Adm_Dte, ia.sk_Fact_Pt_Enc_Clrt)       AS next_adm_mdm_sub_service_line_id
                               ,LEAD(ia.adm_mdm_sub_service_line) OVER (PARTITION BY ia.MRN_int ORDER BY ia.sk_Adm_Dte, ia.sk_Fact_Pt_Enc_Clrt)          AS next_adm_mdm_sub_service_line
                               ,LEAD(ia.adm_mdm_opnl_service_id) OVER (PARTITION BY ia.MRN_int ORDER BY ia.sk_Adm_Dte, ia.sk_Fact_Pt_Enc_Clrt)           AS next_adm_mdm_opnl_service_id
                               ,LEAD(ia.adm_mdm_opnl_service_name) OVER (PARTITION BY ia.MRN_int ORDER BY ia.sk_Adm_Dte, ia.sk_Fact_Pt_Enc_Clrt)         AS next_adm_mdm_opnl_service_name
                               ,LEAD(ia.adm_mdm_hs_area_id) OVER (PARTITION BY ia.MRN_int ORDER BY ia.sk_Adm_Dte, ia.sk_Fact_Pt_Enc_Clrt)                AS next_adm_mdm_hs_area_id
                               ,LEAD(ia.adm_mdm_hs_area_name) OVER (PARTITION BY ia.MRN_int ORDER BY ia.sk_Adm_Dte, ia.sk_Fact_Pt_Enc_Clrt)              AS next_adm_mdm_hs_area_name
                               ,LEAD(ia.adm_mdm_epic_department) OVER (PARTITION BY ia.MRN_int ORDER BY ia.sk_Adm_Dte, ia.sk_Fact_Pt_Enc_Clrt)           AS next_adm_mdm_epic_department
                               ,LEAD(ia.adm_mdm_epic_department_external) OVER (PARTITION BY ia.MRN_int ORDER BY ia.sk_Adm_Dte, ia.sk_Fact_Pt_Enc_Clrt)  AS next_adm_mdm_epic_department_external
                               ,LEAD(ia.adm_physcn_service_line) OVER (PARTITION BY ia.MRN_int ORDER BY ia.sk_Adm_Dte, ia.sk_Fact_Pt_Enc_Clrt)           AS next_adm_physcn_service_line
                               ,LEAD(ia.dsch_mdm_practice_group_id) OVER (PARTITION BY ia.MRN_int ORDER BY ia.sk_Adm_Dte, ia.sk_Fact_Pt_Enc_Clrt)        AS next_dsch_mdm_practice_group_id
                               ,LEAD(ia.dsch_mdm_practice_group_name) OVER (PARTITION BY ia.MRN_int ORDER BY ia.sk_Adm_Dte, ia.sk_Fact_Pt_Enc_Clrt)      AS next_dsch_mdm_practice_group_name
                               ,LEAD(ia.dsch_mdm_service_line_id) OVER (PARTITION BY ia.MRN_int ORDER BY ia.sk_Adm_Dte, ia.sk_Fact_Pt_Enc_Clrt)          AS next_dsch_mdm_service_line_id
                               ,LEAD(ia.dsch_mdm_service_line) OVER (PARTITION BY ia.MRN_int ORDER BY ia.sk_Adm_Dte, ia.sk_Fact_Pt_Enc_Clrt)             AS next_dsch_mdm_service_line
                               ,LEAD(ia.dsch_mdm_sub_service_line_id) OVER (PARTITION BY ia.MRN_int ORDER BY ia.sk_Adm_Dte, ia.sk_Fact_Pt_Enc_Clrt)      AS next_dsch_mdm_sub_service_line_id
                               ,LEAD(ia.dsch_mdm_sub_service_line) OVER (PARTITION BY ia.MRN_int ORDER BY ia.sk_Adm_Dte, ia.sk_Fact_Pt_Enc_Clrt)         AS next_dsch_mdm_sub_service_line
                               ,LEAD(ia.dsch_mdm_opnl_service_id) OVER (PARTITION BY ia.MRN_int ORDER BY ia.sk_Adm_Dte, ia.sk_Fact_Pt_Enc_Clrt)          AS next_dsch_mdm_opnl_service_id
                               ,LEAD(ia.dsch_mdm_opnl_service_name) OVER (PARTITION BY ia.MRN_int ORDER BY ia.sk_Adm_Dte, ia.sk_Fact_Pt_Enc_Clrt)        AS next_dsch_mdm_opnl_service_name
                               ,LEAD(ia.dsch_mdm_hs_area_id) OVER (PARTITION BY ia.MRN_int ORDER BY ia.sk_Adm_Dte, ia.sk_Fact_Pt_Enc_Clrt)               AS next_dsch_mdm_hs_area_id
                               ,LEAD(ia.dsch_mdm_hs_area_name) OVER (PARTITION BY ia.MRN_int ORDER BY ia.sk_Adm_Dte, ia.sk_Fact_Pt_Enc_Clrt)             AS next_dsch_mdm_hs_area_name
                               ,LEAD(ia.dsch_mdm_epic_department) OVER (PARTITION BY ia.MRN_int ORDER BY ia.sk_Adm_Dte, ia.sk_Fact_Pt_Enc_Clrt)          AS next_dsch_mdm_epic_department
                               ,LEAD(ia.dsch_mdm_epic_department_external) OVER (PARTITION BY ia.MRN_int ORDER BY ia.sk_Adm_Dte, ia.sk_Fact_Pt_Enc_Clrt) AS next_dsch_mdm_epic_department_external
                               ,LEAD(ia.dsch_physcn_service_line_id) OVER (PARTITION BY ia.MRN_int ORDER BY ia.sk_Adm_Dte, ia.sk_Fact_Pt_Enc_Clrt)       AS next_dsch_physcn_service_line_id
                               ,LEAD(ia.dsch_physcn_service_line) OVER (PARTITION BY ia.MRN_int ORDER BY ia.sk_Adm_Dte, ia.sk_Fact_Pt_Enc_Clrt)          AS next_dsch_physcn_service_line
                               ,LEAD(ia.adm_dx_cde) OVER (PARTITION BY ia.MRN_int ORDER BY ia.sk_Adm_Dte, ia.sk_Fact_Pt_Enc_Clrt)                        AS next_adm_dx_cde
                               ,LEAD(ia.adm_dx_nme) OVER (PARTITION BY ia.MRN_int ORDER BY ia.sk_Adm_Dte, ia.sk_Fact_Pt_Enc_Clrt)                        AS next_adm_dx_nme
                         FROM   #ip_accts_dxs AS ia
                     ) AS main
             WHERE   DATEDIFF(DAY, main.IndexDischarge, main.next_Admission)
             BETWEEN 0 AND 30
         ) AS final
WHERE    (
             (
                 ((  final.next_adm_Unit_Nme IS NULL)
               OR
                  (   (  final.next_adm_Unit_Nme IS NOT NULL)
               AND    (final.next_adm_Unit_Nme NOT IN ( '5 east', '5 East', '5EAS', '5 EAST', 'UVHE 5 EAST' ))
                  )
                 )
          AND    (final.Duration BETWEEN 0 AND 30)
             ) --don't count same day admissions to psych
       OR
             (   (  final.next_adm_Unit_Nme IN ( '5 east', '5 East', '5EAS', '5 EAST', 'UVHE 5 EAST' ))
          AND    (final.Duration BETWEEN 1 AND 30)
             ) --count admission to psych if duration > 0
         )
AND      (final.Clrt_Disch_Disp NOT IN ( 'Expired', 'Expired in Medical Facility' )) --exclude readmission event records having an
--index discharge disposition of 'Expired'
ORDER BY final.MRN_Clrt, final.sk_Adm_Dte;

SELECT *
INTO   #RptgFinal
FROM
       (
           /* list readmission records to be used to determine numerator */
           SELECT              DISTINCT
                               CAST(NULL AS VARCHAR(150))                                                                                       AS event_category
                              ,CAST('Readmission' AS VARCHAR(50))                                                                               AS event_type
                              ,date_dim.day_date                                                                                                AS event_date -- index discharge date
                              ,CASE WHEN rp.dsch_fmonth_num IS NULL THEN date_dim.fmonth_num ELSE rp.dsch_fmonth_num END                        AS fmonth_num -- index discharge date
                              ,CASE WHEN rp.dsch_FYear_name IS NULL THEN date_dim.FYear_name ELSE rp.dsch_FYear_name END                        AS fyear_name -- index discharge date
                              ,CASE WHEN rp.dsch_Fyear_num IS NULL THEN date_dim.Fyear_num ELSE rp.dsch_Fyear_num END                           AS fyear_num -- index discharge date
                              ,CAST(COALESCE(rp.dsch_Clrt_DEPt_Nme, 'Unknown') AS VARCHAR(254))                                                 AS event_location -- index discharge location
                              ,rp.MRN_Clrt                                                                                                      AS person_id
                              ,CAST(RTRIM(rp.PT_LNAME) + ', ' + LTRIM(rp.PT_FNAME_MI) AS VARCHAR(200))                                          AS person_name
                              ,rp.BIRTH_DATE                                                                                                    AS person_birth_date
                              ---BDD 12/12/2017 added below 2 sks
                              ,rp.sk_Fact_Pt_Acct
                              ,rp.sk_Fact_Pt_Enc_Clrt
                              ------
                              ,rp.sk_Dim_Pt
                              -- -----------------------------------------------------------------------------------------
                              -- Calculated Fields
                              -- -----------------------------------------------------------------------------------------
                              ,CASE WHEN rp.sk_Adm_Dte IS NULL THEN 0 ELSE 1 END                                                                AS event_count
                              ,CAST(LEFT(DATENAME(MM, date_dim.day_date), 3) + ' ' + CAST(DAY(date_dim.day_date) AS VARCHAR(2)) AS VARCHAR(10)) AS report_period
                              ,CAST(date_dim.day_date AS SMALLDATETIME)                                                                         AS report_date
                              -- ------------------------------------
                              -- MDM Fields - Index Discharge
                              -- ------------------------------------
                              ,rp.dsch_mdm_practice_group_id                                                                                    AS practice_group_id
                              ,rp.dsch_mdm_practice_group_name                                                                                  AS practice_group_name
                              ,rp.dsch_mdm_service_line_id                                                                                      AS locsvc_service_line_id
                              ,rp.dsch_mdm_service_line                                                                                         AS locsvc_service_line
                              ,CASE
                                   WHEN FLOOR((CAST(date_dim.day_date AS INTEGER) - CAST(rp.BIRTH_DATE AS INTEGER)) / 365.25) < 18
                                   THEN 1
                                   WHEN FLOOR((CAST(date_dim.day_date AS INTEGER) - CAST(rp.BIRTH_DATE AS INTEGER)) / 365.25) >= 18
                                   AND  rp.dsch_physcn_service_line_id = 11
                                   THEN 3
                                   ELSE NULL
                               END                                                                                                              AS sub_service_line_id
                              --,rp.dsch_mdm_sub_service_line_id AS sub_service_line_id
                              ,CASE
                                   WHEN FLOOR((CAST(date_dim.day_date AS INTEGER) - CAST(rp.BIRTH_DATE AS INTEGER)) / 365.25) < 18
                                   THEN 'Children'
                                   WHEN FLOOR((CAST(date_dim.day_date AS INTEGER) - CAST(rp.BIRTH_DATE AS INTEGER)) / 365.25) >= 18
                                   AND  rp.dsch_physcn_service_line_id = 11
                                   THEN 'Women'
                                   ELSE NULL
                               END                                                                                                              AS sub_service_line
                              --,rp.dsch_mdm_sub_service_line AS sub_service_line
                              ,rp.dsch_mdm_opnl_service_id                                                                                      AS opnl_service_id
                              ,rp.dsch_mdm_opnl_service_name                                                                                    AS opnl_service_name
                              ,rp.dsch_mdm_hs_area_id                                                                                           AS hs_area_id
                              ,rp.dsch_mdm_hs_area_name                                                                                         AS hs_area_name
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
                              --,rp.dsch_physcn_service_line_id AS service_line_id
                              ,CASE WHEN rp.dsch_physcn_service_line IS NOT NULL THEN rp.dsch_physcn_service_line_id ELSE 0 END                 AS service_line_id
                              --,rp.dsch_physcn_service_line AS service_line
                              ,COALESCE(rp.dsch_physcn_service_line, 'No Value Specified')                                                      AS service_line
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
                              ,rp.next_adm_fmonth_num                                                                                           AS readm_fmonth_num -- Readmission date
                              ,rp.next_adm_FYear_name                                                                                           AS readm_fyear_name -- Readmission date
                              ,rp.next_adm_Fyear_num                                                                                            AS readm_fyear_num -- Readmission date
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
                              -- ------------------------------------
                              ,rp.next_IndexDischarge                                                                                           AS readmission_discharge_event_date
                              ,rp.next_adm_dx_cde                                                                                               AS Readmission_Dx
                              ,rp.next_adm_dx_nme                                                                                               AS Readmission_Dx_Name
                              ,rp.next_sk_Fact_Pt_Acct
                              ,rp.next_sk_Fact_Pt_Enc_Clrt
                              ,CASE
                                   WHEN FLOOR((CAST(date_dim.day_date AS INTEGER) - CAST(rp.BIRTH_DATE AS INTEGER)) / 365.25) < 18
                                   THEN 1
                                   ELSE 0
                               END                                                                                                              AS peds
                              ,CASE WHEN tx.PAT_ENC_CSN_ID IS NOT NULL THEN 1 ELSE 0 END                                                        AS transplant
                              ,CAST(CASE WHEN tx_pts.PAT_ID IS NOT NULL THEN 1 ELSE 0 END AS SMALLINT)                                          AS transplant_pt
                              ,CASE WHEN planned_pcs.sk_Fact_Pt_Acct IS NOT NULL THEN 1 ELSE 0 END                                              AS always_planned_procedure
                              ,CASE WHEN planned_pcs.sk_Fact_Pt_Acct IS NOT NULL THEN planned_pcs.Prcdr_Cde_Dotless ELSE NULL END               AS always_planned_proc_cde
                              ,CASE WHEN planned_pcs.sk_Fact_Pt_Acct IS NOT NULL THEN planned_pcs.Prcdr_Nme ELSE NULL END                       AS always_planned_proc_nme

                              ,CASE WHEN planned_dxs.sk_Fact_Pt_Acct IS NOT NULL THEN 1 ELSE 0 END                                              AS always_planned_diagnosis
                              ,CASE WHEN planned_dxs.sk_Fact_Pt_Acct IS NOT NULL THEN planned_dxs.Dx_Cde_Dotless ELSE NULL END                  AS always_planned_dx_cde
                              ,CASE WHEN planned_dxs.sk_Fact_Pt_Acct IS NOT NULL THEN planned_dxs.Dx_Nme ELSE NULL END                          AS always_planned_dx_nme
                              ,CASE
                                   WHEN acute_dx.sk_Fact_Pt_Acct IS NULL
                                   AND  potential_pcs.sk_Fact_Pt_Acct IS NOT NULL
                                   THEN 1
                                   ELSE 0
                               END                                                                                                              AS potential_planned_procedure
                              ,CASE
                                   WHEN acute_dx.sk_Fact_Pt_Acct IS NULL
                                   AND  potential_pcs.sk_Fact_Pt_Acct IS NOT NULL
                                   THEN potential_pcs.Prcdr_Cde_Dotless
                                   ELSE NULL
                               END                                                                                                              AS potential_planned_proc_cde
                              ,CASE
                                   WHEN acute_dx.sk_Fact_Pt_Acct IS NULL
                                   AND  potential_pcs.sk_Fact_Pt_Acct IS NOT NULL
                                   THEN potential_pcs.Prcdr_Nme
                                   ELSE NULL
                               END                                                                                                              AS potential_planned_proc_nme
           FROM                DS_HSDW_Prod.Rptg.vwDim_Date                                                      AS date_dim
               LEFT OUTER JOIN (SELECT * FROM #RptgFinalBalancedScorecard WHERE dsch_mdm_hs_area_id IS NOT NULL) AS rp ON date_dim.date_key = rp.sk_Dsch_Dte
               -- ----------------------------
               -- Identify always planned procedures
               -- ----------------------------
               OUTER APPLY
                               ( --planned_pcs
                                   SELECT         TOP (1)
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
                                   FROM           DS_HSDW_Prod.Rptg.vwFact_Pt_Prcdr    AS prc
                                       INNER JOIN DS_HSDW_Prod.Rptg.vwDim_Prcdr        AS dprc ON dprc.sk_Dim_Prcdr = prc.sk_Dim_Prcdr

                                       INNER JOIN Rptg.Ref_ICD10_Procs_For_Readmission AS prcr ON dprc.Prcdr_Cde_Dotless = prcr.ICD10PCSCODE
                                   WHERE          prc.sk_Fact_Pt_Acct = rp.next_sk_Fact_Pt_Acct
                                   AND            prcr.logic = 'always planned'
                                   ORDER BY       prc.sk_Prcdr_Dte DESC
                               )                                                                                 AS planned_pcs
               -- ----------------------------
               -- Identify always planned diagnoses
               -- ----------------------------
               OUTER APPLY
                               ( --planned_dxs
                                   SELECT         TOP (1)
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
                                   FROM           DS_HSDW_Prod.Rptg.vwFact_Pt_Dx       AS dx
                                       INNER JOIN DS_HSDW_Prod.Rptg.vwDim_Dx           AS ddx ON ddx.sk_dim_dx = dx.sk_Dim_Dx

                                       INNER JOIN Rptg.Ref_ICD10_Diags_For_Readmission AS dxr ON ddx.Dx_Cde_Dotless = dxr.ICD10CMCODE
                                   WHERE          dx.sk_Fact_Pt_Acct = rp.next_sk_Fact_Pt_Acct
                                   AND            dx.Dx_Clasf_cde IN ( 'DF', 'DE' )
                                   AND            dxr.logic = 'always planned'
                                   ORDER BY       dx.Dx_Prio_Nbr
                               ) AS planned_dxs
               -- ----------------------------
               -- Identify accounts where diagnosis is on acute list
               -- ----------------------------
               OUTER APPLY
                               ( --acute_dx
                                   SELECT         TOP (1)
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
                                   FROM           DS_HSDW_Prod.Rptg.vwFact_Pt_Dx       AS dx
                                       INNER JOIN DS_HSDW_Prod.Rptg.vwDim_Dx           AS ddx ON ddx.sk_dim_dx = dx.sk_Dim_Dx

                                       INNER JOIN Rptg.Ref_ICD10_Diags_For_Readmission AS dxr ON ddx.Dx_Cde_Dotless = dxr.ICD10CMCODE
                                   WHERE          dx.sk_Fact_Pt_Acct = rp.next_sk_Fact_Pt_Acct
                                   AND            dx.Dx_Clasf_cde IN ( 'DF', 'DE' )
                                   AND            dxr.logic = 'acute diagnosis'
                                   AND            dx.Dx_Prio_Nbr IN ( 10001, 1 )
                                   ORDER BY       dx.Dx_Prio_Nbr
                               ) AS acute_dx
               -- ----------------------------
               -- Identify potentially planned procedures
               -- ----------------------------
               OUTER APPLY
                               ( --potential_pcs
                                   SELECT         TOP (1)
                                                  pprc.sk_Fact_Pt_Acct
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
                                   FROM           DS_HSDW_Prod.Rptg.vwFact_Pt_Prcdr    AS pprc
                                       INNER JOIN DS_HSDW_Prod.Rptg.vwDim_Prcdr        AS dpprc ON dpprc.sk_Dim_Prcdr = pprc.sk_Dim_Prcdr

                                       INNER JOIN Rptg.Ref_ICD10_Procs_For_Readmission AS pprcr ON dpprc.Prcdr_Cde_Dotless = pprcr.ICD10PCSCODE
                                   WHERE          pprc.sk_Fact_Pt_Acct = rp.next_sk_Fact_Pt_Acct
                                   AND            pprcr.logic = 'potentially planned'
                                   ORDER BY       pprc.sk_Prcdr_Dte DESC
                               ) AS potential_pcs

               -- -------------------------------------
               -- Identify transplant encounter
               -- -------------------------------------
               LEFT OUTER JOIN
                               (
                                   SELECT         fpec.PAT_ENC_CSN_ID
                                                 ,txsurg.day_date AS transplant_surgery_dt
                                                 ,fpec.Adm_Dtm
                                                 ,fpec.sk_Fact_Pt_Enc_Clrt
                                                 ,fpec.sk_Fact_Pt_Acct
                                                 ,fpec.sk_Dim_Clrt_Pt
                                                 ,fpec.sk_Dim_Pt
                                   FROM           DS_HSDW_Prod.Rptg.VwFact_Pt_Trnsplnt_Clrt AS fptc
                                       INNER JOIN DS_HSDW_Prod.Rptg.vwFact_Pt_Enc_Clrt      AS fpec ON fptc.sk_Dim_Clrt_Pt = fpec.sk_Dim_Clrt_Pt

                                       INNER JOIN DS_HSDW_Prod.Rptg.vwDim_Date              AS txsurg ON fptc.sk_Tx_Surg_Dt = txsurg.date_key
                                   WHERE          txsurg.day_date
                                   BETWEEN CAST(fpec.Adm_Dtm AS DATE) AND fpec.Dsch_Dtm
                                   AND            txsurg.day_date <> '1900-01-01 00:00:00'
                               ) AS tx ON rp.sk_Fact_Pt_Acct = tx.sk_Fact_Pt_Acct
               -- -----------------------------------------
               -- Identify transplant patients by episode--
               -- -----------------------------------------

               LEFT OUTER JOIN
                               (
                                   SELECT         fce.sk_Fact_Clrt_Epsd
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
                                   FROM           DS_HSDW_Prod.dbo.Fact_Clrt_Epsd AS fce
                                       INNER JOIN DS_HSDW_Prod.dbo.Dim_Patient    AS dp ON dp.sk_Dim_Clrt_Pt = fce.sk_Dim_Clrt_Pt

                                       INNER JOIN DS_HSDW_Prod.dbo.Dim_Date       AS epsdst ON fce.sk_Epsd_Strt_Dte = epsdst.date_key

                                       INNER JOIN DS_HSDW_Prod.dbo.Dim_Date       AS epsded ON fce.sk_Epsd_End_Dte = epsded.date_key
                                   WHERE          fce.Epsd_Def_Nme = 'Transplant'
                                   AND            fce.sk_Dim_Clrt_Pt <> 0
                               ) AS tx_pts ON  rp.MRN_Clrt = tx_pts.MRN_int
                                           AND rp.Admission
                                           BETWEEN tx_pts.EpisodeStartDate AND tx_pts.EpisodeEndDate

           WHERE               date_dim.day_date >= @startdate
           AND                 date_dim.day_date < @enddate

           UNION ALL
           /* list discharge records to be used to determine denominator */
           SELECT DISTINCT
                  CAST(NULL AS VARCHAR(150))                                                                                       AS event_category
                 ,CAST('Discharge' AS VARCHAR(50))                                                                                 AS event_type
                 ,date_dim.day_date                                                                                                AS event_date -- discharge date
                 ,CASE WHEN ad.dsch_fmonth_num IS NULL THEN date_dim.fmonth_num ELSE ad.dsch_fmonth_num END                        AS fmonth_num -- discharge date
                 ,CASE WHEN ad.dsch_FYear_name IS NULL THEN date_dim.FYear_name ELSE ad.dsch_FYear_name END                        AS fyear_name -- discharge date
                 ,CASE WHEN ad.dsch_Fyear_num IS NULL THEN date_dim.Fyear_num ELSE ad.dsch_Fyear_num END                           AS fyear_num -- discharge date
                 ,CAST(COALESCE(ad.dsch_Clrt_DEPt_Nme, 'Unknown') AS VARCHAR(254))                                                 AS event_location -- discharge location
                 ,ad.MRN_Clrt                                                                                                      AS person_id
                 ,CAST(RTRIM(ad.PT_LNAME) + ', ' + LTRIM(ad.PT_FNAME_MI) AS VARCHAR(200))                                          AS person_name
                 ,ad.BIRTH_DATE                                                                                                    AS person_birth_date

                 ---BDD 12/12/2017 added below 2 sks
                 ,ad.sk_Fact_Pt_Acct
                 ,ad.sk_Fact_Pt_Enc_Clrt
                 ------
                 ,ad.sk_Dim_Pt
                 -- -----------------------------------------------------------------------------------------
                 -- Calculated Fields - Discharge
                 -- -----------------------------------------------------------------------------------------
                 ,CASE WHEN ad.sk_Adm_Dte IS NULL THEN 0 ELSE 1 END                                                                AS event_count
                 ,CAST(LEFT(DATENAME(MM, date_dim.day_date), 3) + ' ' + CAST(DAY(date_dim.day_date) AS VARCHAR(2)) AS VARCHAR(10)) AS report_period
                 ,CAST(date_dim.day_date AS SMALLDATETIME)                                                                         AS report_date
                 -- ------------------------------------
                 -- MDM Fields - Discharge
                 -- ------------------------------------
                 ,ad.dsch_mdm_practice_group_id                                                                                    AS practice_group_id
                 ,ad.dsch_mdm_practice_group_name                                                                                  AS practice_group_name
                 ,ad.dsch_mdm_service_line_id                                                                                      AS locsvc_service_line_id
                 ,ad.dsch_mdm_service_line                                                                                         AS locsvc_service_line
                 ,ad.dsch_mdm_sub_service_line_id                                                                                  AS sub_service_line_id
                 ,ad.dsch_mdm_sub_service_line                                                                                     AS sub_service_line
                 ,ad.dsch_mdm_opnl_service_id                                                                                      AS opnl_service_id
                 ,ad.dsch_mdm_opnl_service_name                                                                                    AS opnl_service_name
                 ,ad.dsch_mdm_hs_area_id                                                                                           AS hs_area_id
                 ,ad.dsch_mdm_hs_area_name                                                                                         AS hs_area_name
                 ,ad.dsch_DEPARTMENT_ID                                                                                            AS epic_department_id
                 ,ad.dsch_mdm_epic_department                                                                                      AS epic_department_name
                 ,ad.dsch_mdm_epic_department_external                                                                             AS epic_department_name_external
                 ,ad.dsch_provider_id                                                                                              AS provider_id
                 ,ad.dsch_provider_name                                                                                            AS provider_name
                 -- ------------------------------------
                 -- Service line - Discharge
                 -- ------------------------------------
                 ,ad.dsch_mdm_service_line                                                                                         AS service_line_loc
                 ,ad.dsch_provider_name                                                                                            AS Discharging_MD
                 --,ad.dsch_physcn_service_line_id AS service_line_id
                 ,CASE WHEN ad.dsch_physcn_service_line IS NOT NULL THEN ad.dsch_physcn_service_line_id ELSE 0 END                 AS service_line_id
                 --,ad.dsch_physcn_service_line AS service_line
                 ,COALESCE(ad.dsch_physcn_service_line, 'No Value Specified')                                                      AS service_line
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
                 ,CAST(NULL AS SMALLDATETIME)                                                                                      AS index_discharge_event_date
                 ,ad.dsch_dx_cde                                                                                                   AS Discharge_Dx
                 ,ad.dsch_dx_nme                                                                                                   AS Discharge_Dx_Name
                 ,CAST(NULL AS INTEGER)                                                                                            AS readm_fmonth_num
                 ,CAST(NULL AS VARCHAR(10))                                                                                        AS readm_fyear_name
                 ,CAST(NULL AS INTEGER)                                                                                            AS readm_fyear_num
                 ,CAST(NULL AS VARCHAR(254))                                                                                       AS readm_event_location
                 -- ------------------------------------
                 -- MDM Fields - Readmission
                 -- ------------------------------------
                 ,CAST(NULL AS INTEGER)                                                                                            AS readm_practice_group_id
                 ,CAST(NULL AS VARCHAR(150))                                                                                       AS readm_practice_group_name
                 ,CAST(NULL AS INTEGER)                                                                                            AS readm_locsvc_service_line_id
                 ,CAST(NULL AS VARCHAR(150))                                                                                       AS readm_locsvc_service_line
                 ,CAST(NULL AS INTEGER)                                                                                            AS readm_sub_service_line_id
                 ,CAST(NULL AS VARCHAR(150))                                                                                       AS readm_sub_service_line
                 ,CAST(NULL AS INTEGER)                                                                                            AS readm_opnl_service_id
                 ,CAST(NULL AS VARCHAR(150))                                                                                       AS readm_opnl_service_name
                 ,CAST(NULL AS SMALLINT)                                                                                           AS readm_hs_area_id
                 ,CAST(NULL AS VARCHAR(150))                                                                                       AS readm_hs_area_name
                 ,CAST(NULL AS NUMERIC(18, 0))                                                                                     AS readm_epic_department_id
                 ,CAST(NULL AS VARCHAR(255))                                                                                       AS readm_epic_department_name
                 ,CAST(NULL AS VARCHAR(255))                                                                                       AS readm_epic_department_name_external
                 ,CAST(NULL AS VARCHAR(18))                                                                                        AS readm_provider_id
                 ,CAST(NULL AS VARCHAR(200))                                                                                       AS readm_provider_name
                 -- ------------------------------------
                 -- Service line - Readmission
                 -- ------------------------------------
                 ,CAST(NULL AS VARCHAR(150))                                                                                       AS readm_service_line_loc
                 ,CAST(NULL AS VARCHAR(200))                                                                                       AS Readmission_MD
                 ,CAST(NULL AS VARCHAR(150))                                                                                       AS readm_service_line
                 ,CAST(NULL AS VARCHAR(255))                                                                                       AS Readmission_Unit
                 ,CAST(NULL AS VARCHAR(255))                                                                                       AS Readmission_Unit_Name
                 ,CAST(NULL AS SMALLDATETIME)                                                                                      AS readmission_admission_event_date
                 -- ------------------------------------
                 ,CAST(NULL AS VARCHAR(66))                                                                                        AS readmission_admission_HOSP_ADMSSN_STATS_C
                 ,CAST(NULL AS SMALLINT)                                                                                           AS readmission_admission_ADMIT_CATEGORY_C
                 ,CAST(NULL AS VARCHAR(254))                                                                                       AS readmission_admission_ADMIT_CATEGORY
                 ,CAST(NULL AS VARCHAR(254))                                                                                       AS readmission_admission_ADM_SOURCE
                 ,CAST(NULL AS VARCHAR(254))                                                                                       AS readmission_admission_HOSP_ADMSN_TYPE
                 ,CAST(NULL AS VARCHAR(254))                                                                                       AS readmission_admission_HOSP_ADMSN_STATUS
                 ,CAST(NULL AS VARCHAR(254))                                                                                       AS readmission_admission_ADMIT_CONF_STAT
                 ,CAST(NULL AS VARCHAR(254))                                                                                       AS readmission_admission_ADT_PATIENT_STAT
                 ,CAST(NULL AS VARCHAR(254))                                                                                       AS readmission_admission_adt_pt_cls
                 -- ------------------------------------
                 ,CAST(NULL AS SMALLDATETIME)                                                                                      AS readmission_discharge_event_date
                 ,CAST(NULL AS VARCHAR(20))                                                                                        AS Readmission_Dx
                 ,CAST(NULL AS VARCHAR(255))                                                                                       AS Readmission_Dx_Name
                 ,CAST(NULL AS INT)                                                                                                AS next_sk_Fact_Pt_Enc_Clrt
                 ,CAST(NULL AS INT)                                                                                                AS next_sk_Fact_Pt_Acct
                 ,CASE
                      WHEN FLOOR((CAST(date_dim.day_date AS INTEGER) - CAST(ad.BIRTH_DATE AS INTEGER)) / 365.25) < 18
                      THEN 1
                      ELSE 0
                  END                                                                                                              AS peds
                 ,CASE WHEN tx.PAT_ENC_CSN_ID IS NOT NULL THEN 1 ELSE 0 END                                                        AS transplant
                 ,CAST(CASE WHEN tx_pts.PAT_ID IS NOT NULL THEN 1 ELSE 0 END AS SMALLINT)                                          AS transplant_pt
                 ,CAST(NULL AS INT)                                                                                                AS always_planned_procedure
                 ,CAST(NULL AS VARCHAR(20))                                                                                        AS always_planned_proc_cde
                 ,CAST(NULL AS VARCHAR(255))                                                                                       AS always_planned_proc_nme
                 ,CAST(NULL AS INT)                                                                                                AS always_planned_diagnosis
                 ,CAST(NULL AS VARCHAR(20))                                                                                        AS always_planned_dx_cde
                 ,CAST(NULL AS VARCHAR(255))                                                                                       AS always_planned_dx_nme
                 ,CAST(NULL AS INT)                                                                                                AS potential_planned_procedure
                 ,CAST(NULL AS VARCHAR(20))                                                                                        AS potential_planned_proc_cde
                 ,CAST(NULL AS VARCHAR(255))                                                                                       AS potential_planned_proc_nme
           FROM   DS_HSDW_Prod.Rptg.vwDim_Date AS date_dim
               LEFT OUTER JOIN
                  (
                      SELECT *
                      FROM   #ip_accts_discharges
                      WHERE  NOT ((dsch_mdm_hs_area_id IS NULL) AND (IndexDischarge < @currdate))
                  )                            AS ad ON date_dim.date_key = ad.sk_Dsch_Dte
               -- -------------------------------------
               -- Identify transplant encounter
               -- -------------------------------------

               LEFT OUTER JOIN
                  (
                      SELECT         fpec.PAT_ENC_CSN_ID
                                    ,txsurg.day_date AS transplant_surgery_dt
                                    ,fpec.Adm_Dtm
                                    ,fpec.sk_Fact_Pt_Enc_Clrt
                                    ,fpec.sk_Fact_Pt_Acct
                                    ,fpec.sk_Dim_Clrt_Pt
                                    ,fpec.sk_Dim_Pt
                      FROM           DS_HSDW_Prod.Rptg.VwFact_Pt_Trnsplnt_Clrt AS fptc
                          INNER JOIN DS_HSDW_Prod.Rptg.vwFact_Pt_Enc_Clrt      AS fpec ON fptc.sk_Dim_Clrt_Pt = fpec.sk_Dim_Clrt_Pt

                          INNER JOIN DS_HSDW_Prod.Rptg.vwDim_Date              AS txsurg ON fptc.sk_Tx_Surg_Dt = txsurg.date_key
                      WHERE          txsurg.day_date
                      BETWEEN CAST(fpec.Adm_Dtm AS DATE) AND fpec.Dsch_Dtm
                      AND            txsurg.day_date <> '1900-01-01 00:00:00'
                  )                            AS tx ON ad.sk_Fact_Pt_Acct = tx.sk_Fact_Pt_Acct
               -- -----------------------------------------
               -- Identify transplant patients by episode--
               -- -----------------------------------------

               LEFT OUTER JOIN
                  (
                      SELECT         fce.sk_Fact_Clrt_Epsd
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
                      FROM           DS_HSDW_Prod.dbo.Fact_Clrt_Epsd AS fce
                          INNER JOIN DS_HSDW_Prod.dbo.Dim_Patient    AS dp ON dp.sk_Dim_Clrt_Pt = fce.sk_Dim_Clrt_Pt

                          INNER JOIN DS_HSDW_Prod.dbo.Dim_Date       AS epsdst ON fce.sk_Epsd_Strt_Dte = epsdst.date_key

                          INNER JOIN DS_HSDW_Prod.dbo.Dim_Date       AS epsded ON fce.sk_Epsd_End_Dte = epsded.date_key
                      WHERE          fce.Epsd_Def_Nme = 'Transplant'
                      AND            fce.sk_Dim_Clrt_Pt <> 0
                  )                            AS tx_pts ON  ad.MRN_Clrt = tx_pts.MRN_int
                                                         AND ad.Admission
                                                         BETWEEN tx_pts.EpisodeStartDate AND tx_pts.EpisodeEndDate

           WHERE  date_dim.day_date >= @startdate
           AND    date_dim.day_date < @enddate

       ) AS tmp;

/*--------------------------------------------------*/
----do the insert here. Proc presupposes that the Stage table
---- was truncated in the SSIS package
--INSERT INTO Stage.Balscore_Dash_Readmissions
--    (event_category
--    ,event_type
--    ,event_date
--    ,fmonth_num
--    ,fyear_name
--    ,fyear_num
--    ,event_location
--    ,person_id
--    ,person_name
--    ,person_birth_date
--    ,sk_Dim_Pt
--    ---BDD 12/12/2017           
--    ,sk_Fact_Pt_Acct
--    ,sk_Fact_Pt_Enc_Clrt
--    ------
--    ,event_count
--    ,report_period
--    ,report_date
--    ,practice_group_id
--    ,practice_group_name
--    ,locsvc_service_line_id
--    ,locsvc_service_line
--    ,sub_service_line_id
--    ,sub_service_line
--    ,opnl_service_id
--    ,opnl_service_name
--    ,hs_area_id
--    ,hs_area_name
--    ,epic_department_id
--    ,epic_department_name
--    ,epic_department_name_external
--    ,provider_id
--    ,provider_name
--    ,dschphydp.UVaID --new 06/14/18
--    ,service_line_loc
--    ,Discharging_MD
--    ,service_line_id
--    ,service_line
--    ,Discharging_Unit
--    ,Discharging_Unit_Name
--    ,index_admission_event_date
--    ,index_admission_HOSP_ADMSSN_STATS_C
--    ,index_admission_ADMIT_CATEGORY_C
--    ,index_admission_ADMIT_CATEGORY
--    ,index_admission_ADM_SOURCE
--    ,index_admission_HOSP_ADMSN_TYPE
--    ,index_admission_HOSP_ADMSN_STATUS
--    ,index_admission_ADMIT_CONF_STAT
--    ,index_admission_ADT_PATIENT_STAT
--    ,index_admission_adt_pt_cls
--    ,index_discharge_event_date
--    ,Discharge_Dx
--    ,Discharge_Dx_Name
--    ,readm_fmonth_num
--    ,readm_fyear_name
--    ,readm_fyear_num
--    ,readm_event_location
--    ,readm_practice_group_id
--    ,readm_practice_group_name
--    ,readm_locsvc_service_line_id
--    ,readm_locsvc_service_line
--    ,readm_sub_service_line_id
--    ,readm_sub_service_line
--    ,readm_opnl_service_id
--    ,readm_opnl_service_name
--    ,readm_hs_area_id
--    ,readm_hs_area_name
--    ,readm_epic_department_id
--    ,readm_epic_department_name
--    ,readm_epic_department_name_external
--    ,readm_provider_id
--    ,readm_provider_name
--    ,readm_UVaID --new 06/14/18
--    ,readm_service_line_loc
--    ,Readmission_MD
--    ,readm_service_line
--    ,Readmission_Unit
--    ,Readmission_Unit_Name
--    ,readmission_admission_event_date
--    ,readmission_admission_HOSP_ADMSSN_STATS_C
--    ,readmission_admission_ADMIT_CATEGORY_C
--    ,readmission_admission_ADMIT_CATEGORY
--    ,readmission_admission_ADM_SOURCE
--    ,readmission_admission_HOSP_ADMSN_TYPE
--    ,readmission_admission_HOSP_ADMSN_STATUS
--    ,readmission_admission_ADMIT_CONF_STAT
--    ,readmission_admission_ADT_PATIENT_STAT
--    ,readmission_admission_adt_pt_cls
--    ,readmission_discharge_event_date
--    ,Readmission_Dx
--    ,Readmission_Dx_Name
--    ,next_sk_Fact_Pt_Enc_Clrt --new 06/14/18
--    ,peds
--    ,transplant
--    ,transplant_pt

--    ,always_planned_procedure

--    ,always_planned_proc_cde
--    ,always_planned_proc_nme

--    ,always_planned_diagnosis

--    ,always_planned_dx_cde
--    ,always_planned_dx_nme

--    ,potential_planned_procedure

--    ,potential_planned_proc_cde
--    ,potential_planned_proc_nme
--    ,Planned_Readmission)
--SELECT              DISTINCT
--                    rf.event_category
--                   ,rf.event_type
--                   ,rf.event_date
--                   ,rf.fmonth_num
--                   ,rf.fyear_name
--                   ,rf.fyear_num
--                   ,rf.event_location
--                   ,rf.person_id
--                   ,rf.person_name
--                   ,rf.person_birth_date
--                   ,rf.sk_Dim_Pt
--                   ,rf.sk_Fact_Pt_Acct
--                   ,rf.sk_Fact_Pt_Enc_Clrt
--                   ,rf.event_count
--                   ,rf.report_period
--                   ,rf.report_date
--                   ,rf.practice_group_id
--                   ,rf.practice_group_name
--                   ,rf.locsvc_service_line_id
--                   ,rf.locsvc_service_line
--				   --,rf.sub_service_line_id
--				   --,rf.sub_service_line
--                   ,CASE WHEN rf.Sub_Service_Line_ID IS NULL OR rf.sub_service_line_id = 0 THEN rssl.Sub_Service_Line_ID ELSE rf.Sub_Service_Line_ID END AS Sub_Service_Line_ID
--                   ,CASE WHEN rf.Sub_Service_Line_ID IS NULL OR rf.sub_service_line_id = 0 THEN rssl.Sub_Service_Line ELSE rf.Sub_Service_Line END AS Sub_Service_Line
--                   ,CASE WHEN rf.service_line_id =0 THEN rf.opnl_service_id ELSE 0 END AS opnl_service_id
--                   ,CASE WHEN rf.service_line_id =0 THEN rf.opnl_service_name ELSE 'Unknown' END AS opnl_service_name
--                   ,rf.hs_area_id
--                   ,rf.hs_area_name
--                   ,rf.epic_department_id
--                   ,rf.epic_department_name
--                   ,rf.epic_department_name_external
--                   ,rf.provider_id
--                   ,rf.provider_name
--                   ,dschphydp.UVaID
--                   ,rf.service_line_loc
--                   ,rf.Discharging_MD
--                   ,rf.service_line_id
--                   ,rf.service_line
--                   ,rf.Discharging_Unit
--                   ,rf.Discharging_Unit_Name
--                   ,rf.index_admission_event_date
--                   ,rf.index_admission_HOSP_ADMSSN_STATS_C
--                   ,rf.index_admission_ADMIT_CATEGORY_C
--                   ,rf.index_admission_ADMIT_CATEGORY
--                   ,rf.index_admission_ADM_SOURCE
--                   ,rf.index_admission_HOSP_ADMSN_TYPE
--                   ,rf.index_admission_HOSP_ADMSN_STATUS
--                   ,rf.index_admission_ADMIT_CONF_STAT
--                   ,rf.index_admission_ADT_PATIENT_STAT
--                   ,rf.index_admission_adt_pt_cls
--                   ,rf.index_discharge_event_date
--                   ,rf.Discharge_Dx
--                   ,rf.Discharge_Dx_Name
--                   ,rf.readm_fmonth_num
--                   ,rf.readm_fyear_name
--                   ,rf.readm_fyear_num
--                   ,rf.readm_event_location
--                   ,rf.readm_practice_group_id
--                   ,rf.readm_practice_group_name
--                   ,rf.readm_locsvc_service_line_id
--                   ,rf.readm_locsvc_service_line
--                   ,rf.readm_sub_service_line_id
--                   ,rf.readm_sub_service_line
--                   ,rf.readm_opnl_service_id
--                   ,rf.readm_opnl_service_name
--                   ,rf.readm_hs_area_id
--                   ,rf.readm_hs_area_name
--                   ,rf.readm_epic_department_id
--                   ,rf.readm_epic_department_name
--                   ,rf.readm_epic_department_name_external
--                   ,rf.readm_provider_id
--                   ,rf.readm_provider_name
--                   ,admphydp.UVaID                           AS readm_UVaID
--                   ,rf.readm_service_line_loc
--                   ,rf.Readmission_MD
--                   ,rf.readm_service_line
--                   ,rf.Readmission_Unit
--                   ,rf.Readmission_Unit_Name
--                   ,rf.readmission_admission_event_date
--                   ,rf.readmission_admission_HOSP_ADMSSN_STATS_C
--                   ,rf.readmission_admission_ADMIT_CATEGORY_C
--                   ,rf.readmission_admission_ADMIT_CATEGORY
--                   ,rf.readmission_admission_ADM_SOURCE
--                   ,rf.readmission_admission_HOSP_ADMSN_TYPE
--                   ,rf.readmission_admission_HOSP_ADMSN_STATUS
--                   ,rf.readmission_admission_ADMIT_CONF_STAT
--                   ,rf.readmission_admission_ADT_PATIENT_STAT
--                   ,rf.readmission_admission_adt_pt_cls
--                   ,rf.readmission_discharge_event_date
--                   ,rf.Readmission_Dx
--                   ,rf.Readmission_Dx_Name
--                   ,rf.next_sk_Fact_Pt_Enc_Clrt
--                   ,rf.peds
--                   ,rf.transplant
--                   ,rf.transplant_pt
--                   ,rf.always_planned_procedure
--                   ,rf.always_planned_proc_cde
--                   ,rf.always_planned_proc_nme
--                   ,rf.always_planned_diagnosis
--                   ,rf.always_planned_dx_cde
--                   ,rf.always_planned_dx_nme
--                   ,rf.potential_planned_procedure
--                   ,rf.potential_planned_proc_cde
--                   ,rf.potential_planned_proc_nme
--                   ,CASE
--                        WHEN rf.always_planned_procedure = 1
--                        OR   rf.always_planned_diagnosis = 1
--                        OR   rf.potential_planned_procedure = 1
--                        THEN 1
--                        ELSE 0
--                    END                                      AS Planned_Readmission
--FROM                #RptgFinal AS rf
--    --joins to bring in UVaID
--    LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Clrt_SERsrc      AS admphyclrt ON rf.readm_provider_id = admphyclrt.PROV_ID

--    LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Physcn           AS admphydp ON admphydp.sk_Dim_Physcn = admphyclrt.sk_Dim_Physcn

--    LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Clrt_SERsrc      AS dschphyclrt ON rf.provider_id = dschphyclrt.PROV_ID

--    LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Physcn           AS dschphydp ON dschphydp.sk_Dim_Physcn = dschphyclrt.sk_Dim_Physcn

--    LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwRef_Sub_Service_Line AS rssl ON CASE
--                                                                            WHEN dschphydp.Service_Line = 'Neurosciences & Behavioral Health'
--																			AND (dschphydp.Division LIKE 'neuro%'
--																			OR dschphydp.Division= 'Critical Care Medicine')
--                                                                            THEN 'Neurosciences'
--                                                                            WHEN  dschphydp.Service_Line = 'Neurosciences & Behavioral Health'
--																			AND (dschphydp.Division LIKE 'psy%'
--																			OR dschphydp.Division='Developmental Pediatrics')
--                                                                            THEN 'Behavioral Health'
--																			WHEN dschphydp.Service_Line ='Women''s & Children''s'
--																			AND (dschphydp.Division LIKE '%maternal%'
--																			OR dschphydp.Division LIKE '%fertil%'
--																			OR dschphydp.Division LIKE '%gyn%'
--																			OR dschphydp.Division = 'family medicine rpc')
--																			THEN 'Women'
--																			WHEN dschphydp.Service_Line ='Women''s & Children''s'
--																			AND (dschphydp.Division LIKE '%ped%'
--																			OR dschphydp.Division LIKE '%natal%'
--																			OR dschphydp.Division LIKE '%genetics%'
--																			OR dschphydp.Division = 'transplant surgery')
--																			THEN 'Children'
--                                                                            ELSE dschphydp.Division
--                                                                        END = rssl.Sub_Service_Line

--ORDER BY            rf.event_type, rf.event_date;

     SELECT 
	        event_type
           ,event_date
           ,event_location
           ,person_id
           ,report_period
           ,report_date
           ,locsvc_service_line_id
           ,locsvc_service_line
           ,epic_department_id
           ,epic_department_name
           ,provider_id
           ,provider_name
           ,service_line_loc
           ,Discharging_MD
           ,service_line_id
           ,service_line

	 FROM #RptgFinal
	 WHERE event_count = 1
     ORDER BY event_type
             ,event_date
			 ,person_id
*/
GO


