USE [DS_HSDM_App]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

--ALTER PROCEDURE [Rptg].[uspSrc_Readmissions_Registry]
--(
--    @StartDate SMALLDATETIME,
--    @EndDate SMALLDATETIME,
--    @in_serv VARCHAR(MAX),
--	@Discharges_yn INT
--)
--AS

	/*testing*/
    DECLARE
        @StartDate SMALLDATETIME = '10/1/2019'
       ,@EndDate SMALLDATETIME = '10/31/2022';
	/*end testing*/

SET NOCOUNT ON;

--DECLARE @tab_serv TABLE
--(
--    Service_Line_ID NUMERIC(18)
--);
--INSERT INTO @tab_serv
--SELECT Param
--FROM DS_HSDM_App.ETL.fn_ParmParse(@in_serv, ',');

-- TEMP TABLE to store Readmissions (including prior years)

IF OBJECT_ID('tempdb..#dwreadm ') IS NOT NULL
DROP TABLE #dwreadm

SELECT event_type,
       event_count,
       event_date,
       event_id,
       event_category,
       event_location,
       epic_department_id,
       epic_department_name,
       epic_department_name_external,
       fmonth_num,
       fyear_num,
       fyear_name,
       report_period,
       report_date,
       peds,
       transplant,
       sk_Dim_Pt,
       sk_Fact_Pt_Acct,
       sk_Fact_Pt_Enc_Clrt,
       person_birth_date,
       person_gender,
       person_id,
       person_name,
       practice_group_id,
       practice_group_name,
       provider_id,
       provider_name,
       service_line_id,
       service_line,
       sub_service_line_id,
       sub_service_line,
       opnl_service_id,
       opnl_service_name,
       hs_area_id,
       hs_area_name,
       w_department_id,
       w_department_name,
       w_department_name_external,
       w_opnl_service_id,
       w_opnl_service_name,
       w_practice_group_id,
       w_practice_group_name,
       w_service_line_id,
       w_service_line_name,
       w_sub_service_line_id,
       w_sub_service_line_name,
       w_report_period,
       w_report_date,
       w_hs_area_id,
       w_hs_area_name,
       locsvc_service_line_id,
       locsvc_service_line,
       service_line_loc,
       discharging_provider_id,
       discharging_provider_name,
       Discharging_MD,
       Discharging_Unit,
       Discharging_Unit_Name,
       index_admission_event_date,
       index_admission_HOSP_ADMSSN_STATS_C,
       index_admission_ADMIT_CATEGORY_C,
       index_admission_ADMIT_CATEGORY,
       index_admission_ADM_SOURCE,
       index_admission_HOSP_ADMSN_TYPE,
       index_admission_HOSP_ADMSN_STATUS,
       index_admission_ADMIT_CONF_STAT,
       index_admission_ADT_PATIENT_STAT,
       index_admission_adt_pt_cls,
       index_discharge_event_date,
       Discharge_Dx,
       Discharge_Dx_Name,
       readm_fmonth_num,
       readm_fyear_name,
       readm_fyear_num,
       readmission_event_location,
       readm_practice_group_id,
       readm_practice_group_name,
       readm_locsvc_service_line_id,
       readm_locsvc_service_line,
       readm_sub_service_line_id,
       readm_sub_service_line,
       readm_opnl_service_id,
       readm_opnl_service_name,
       readm_hs_area_id,
       readm_hs_area_name,
       readm_epic_department_id,
       readm_epic_department_name,
       readm_epic_department_name_external,
       readmission_provider_id,
       readmission_provider_name,
       readmission_service_line_loc,
       Readmission_MD,
       readmission_service_line,
       Readmission_Unit,
       Readmission_Unit_Name,
       readmission_admission_event_date,
       readmission_admission_HOSP_ADMSSN_STATS_C,
       readmission_admission_ADMIT_CATEGORY_C,
       readmission_admission_ADMIT_CATEGORY,
       readmission_admission_ADM_SOURCE,
       readmission_admission_HOSP_ADMSN_TYPE,
       readmission_admission_HOSP_ADMSN_STATUS,
       readmission_admission_ADMIT_CONF_STAT,
       readmission_admission_ADT_PATIENT_STAT,
       readmission_admission_adt_pt_cls,
       readmission_discharge_event_date,
       Readmission_Dx,
       Readmission_Dx_Name,
      readmission_admission_sk_Fact_Pt_Enc_Clrt next_sk_Fact_Pt_Enc_Clrt,
       Planned_Readmission,
       Load_Dtm
INTO #dwreadm
FROM DS_HSDM_App.Rptg.Dash_BalancedScorecard_Readmissions_PriorYears -- Prior years Readmissions
WHERE COALESCE(readmission_admission_event_date,event_date) >= @StartDate
      AND COALESCE(readmission_admission_event_date,event_date) < DATEADD(DAY, 1, @EndDate)
      AND event_count = 1
      --AND
      --(
      --    100 IN
      --    (
      --        SELECT Service_Line_ID FROM @tab_serv
      --    )
      --    OR w_service_line_id IN
      --       (
      --           SELECT Service_Line_ID FROM @tab_serv
      --       )
      --)
UNION ALL
SELECT event_type,
       event_count,
       event_date,
       event_id,
       event_category,
       event_location,
       epic_department_id,
       epic_department_name,
       epic_department_name_external,
       fmonth_num,
       fyear_num,
       fyear_name,
       report_period,
       report_date,
       peds,
       transplant,
       sk_Dim_Pt,
       sk_Fact_Pt_Acct,
       sk_Fact_Pt_Enc_Clrt,
       person_birth_date,
       person_gender,
       person_id,
       person_name,
       practice_group_id,
       practice_group_name,
       provider_id,
       provider_name,
       service_line_id,
       service_line,
       sub_service_line_id,
       sub_service_line,
       opnl_service_id,
       opnl_service_name,
       hs_area_id,
       hs_area_name,
       w_department_id,
       w_department_name,
       w_department_name_external,
       w_opnl_service_id,
       w_opnl_service_name,
       w_practice_group_id,
       w_practice_group_name,
       w_service_line_id,
       w_service_line_name,
       w_sub_service_line_id,
       w_sub_service_line_name,
       w_report_period,
       w_report_date,
       w_hs_area_id,
       w_hs_area_name,
       locsvc_service_line_id,
       locsvc_service_line,
       service_line_loc,
       discharging_provider_id,
       discharging_provider_name,
       Discharging_MD,
       Discharging_Unit,
       Discharging_Unit_Name,
       index_admission_event_date,
       index_admission_HOSP_ADMSSN_STATS_C,
       index_admission_ADMIT_CATEGORY_C,
       index_admission_ADMIT_CATEGORY,
       index_admission_ADM_SOURCE,
       index_admission_HOSP_ADMSN_TYPE,
       index_admission_HOSP_ADMSN_STATUS,
       index_admission_ADMIT_CONF_STAT,
       index_admission_ADT_PATIENT_STAT,
       index_admission_adt_pt_cls,
       index_discharge_event_date,
       Discharge_Dx,
       Discharge_Dx_Name,
       readm_fmonth_num,
       readm_fyear_name,
       readm_fyear_num,
       readmission_event_location,
       readm_practice_group_id,
       readm_practice_group_name,
       readm_locsvc_service_line_id,
       readm_locsvc_service_line,
       readm_sub_service_line_id,
       readm_sub_service_line,
       readm_opnl_service_id,
       readm_opnl_service_name,
       readm_hs_area_id,
       readm_hs_area_name,
       readm_epic_department_id,
       readm_epic_department_name,
       readm_epic_department_name_external,
       readmission_provider_id,
       readmission_provider_name,
       readmission_service_line_loc,
       Readmission_MD,
       readmission_service_line,
       Readmission_Unit,
       Readmission_Unit_Name,
       readmission_admission_event_date,
       readmission_admission_HOSP_ADMSSN_STATS_C,
       readmission_admission_ADMIT_CATEGORY_C,
       readmission_admission_ADMIT_CATEGORY,
       readmission_admission_ADM_SOURCE,
       readmission_admission_HOSP_ADMSN_TYPE,
       readmission_admission_HOSP_ADMSN_STATUS,
       readmission_admission_ADMIT_CONF_STAT,
       readmission_admission_ADT_PATIENT_STAT,
       readmission_admission_adt_pt_cls,
       readmission_discharge_event_date,
       Readmission_Dx,
       Readmission_Dx_Name,
      readmission_admission_sk_Fact_Pt_Enc_Clrt next_sk_Fact_Pt_Enc_Clrt,
       Planned_Readmission,
       Load_Dtm
FROM DS_HSDM_App.TabRptg.Dash_BalancedScorecard_Readmissions_Tiles
WHERE COALESCE(readmission_admission_event_date,event_date) >= @StartDate
      AND COALESCE(readmission_admission_event_date,event_date) < DATEADD(DAY, 1, @EndDate)
      AND event_count = 1
      --AND
      --(
      --    100 IN
      --    (
      --        SELECT Service_Line_ID FROM @tab_serv
      --    )
      --    OR w_service_line_id IN
      --       (
      --           SELECT Service_Line_ID FROM @tab_serv
      --       )
      --);

SELECT readm.event_type,
       readm.event_count,
       readm.event_date,
       readm.index_admission_event_date,
       readm.index_discharge_event_date,
       readm.readmission_admission_event_date,
       readm.readmission_discharge_event_date,
       --readm.event_id,
       --readm.event_category,
       readm.event_location,
       readm.epic_department_id,
       readm.epic_department_name,
       readm.epic_department_name_external,
       readm.readmission_event_location,
       readm.readm_epic_department_id,
       readm.readm_epic_department_name,
       readm.readm_epic_department_name_external,
       readm.index_admission_adt_pt_cls,
       readm.Discharge_Dx,
       readm.Discharge_Dx_Name,
       readm.readmission_admission_adt_pt_cls,
       readm.Readmission_Dx,
       readm.Readmission_Dx_Name,
       readm.fmonth_num,
       readm.fyear_num,
       readm.fyear_name,
       readm.report_period,
       readm.report_date,
       readm.peds,
       readm.transplant,
       readm.sk_Dim_Pt,
       readm.sk_Fact_Pt_Acct,
       readm.sk_Fact_Pt_Enc_Clrt,
       readm.person_birth_date,
       readm.person_gender,
       readm.person_id,
       readm.person_name,
       pt.PreferredLanguage,
       --readm.practice_group_id,
       --readm.practice_group_name,
       readm.provider_id,
       readm.provider_name,
       readm.service_line_id,
       readm.service_line,
       readm.sub_service_line_id,
       readm.sub_service_line,
       readm.opnl_service_id,
       readm.opnl_service_name,
       readm.hs_area_id,
       readm.hs_area_name,
       readm.w_department_id,
       readm.w_department_name,
       readm.w_department_name_external,
       readm.w_opnl_service_id,
       readm.w_opnl_service_name,
       --readm.w_practice_group_id,
       --readm.w_practice_group_name,
       readm.w_service_line_id,
       readm.w_service_line_name,
       readm.w_sub_service_line_id,
       readm.w_sub_service_line_name,
       readm.w_report_period,
       readm.w_report_date,
       readm.w_hs_area_id,
       readm.w_hs_area_name,
       readm.locsvc_service_line_id,
       readm.locsvc_service_line,
       readm.service_line_loc,
       readm.discharging_provider_id,
       readm.discharging_provider_name,
       readm.Discharging_MD,
       readm.Discharging_Unit,
       readm.Discharging_Unit_Name,
       --readm.index_admission_HOSP_ADMSSN_STATS_C,
       --readm.index_admission_ADMIT_CATEGORY_C,
       --readm.index_admission_ADMIT_CATEGORY,
       readm.index_admission_ADM_SOURCE,
       readm.index_admission_HOSP_ADMSN_TYPE,
       --readm.index_admission_HOSP_ADMSN_STATUS,
       readm.index_admission_ADMIT_CONF_STAT,
       readm.index_admission_ADT_PATIENT_STAT,
       readm.readm_fmonth_num,
       readm.readm_fyear_name,
       readm.readm_fyear_num,
       --readm.readm_practice_group_id,
       --readm.readm_practice_group_name,
       readm.readm_locsvc_service_line_id,
       readm.readm_locsvc_service_line,
       readm.readm_sub_service_line_id,
       readm.readm_sub_service_line,
       readm.readm_opnl_service_id,
       readm.readm_opnl_service_name,
       readm.readm_hs_area_id,
       readm.readm_hs_area_name,
       readm.readmission_provider_id,
       readm.readmission_provider_name,
       readm.readmission_service_line_loc,
       readm.Readmission_MD,
       readm.readmission_service_line,
       readm.Readmission_Unit,
       readm.Readmission_Unit_Name,
       --readm.readmission_admission_HOSP_ADMSSN_STATS_C,
       --readm.readmission_admission_ADMIT_CATEGORY_C,
       --readm.readmission_admission_ADMIT_CATEGORY,
       readm.readmission_admission_ADM_SOURCE,
       readm.readmission_admission_HOSP_ADMSN_TYPE,
       readm.readmission_admission_HOSP_ADMSN_STATUS,
       readm.readmission_admission_ADMIT_CONF_STAT,
       readm.readmission_admission_ADT_PATIENT_STAT,
       readm.next_sk_Fact_Pt_Enc_Clrt,
       readm.Planned_Readmission,
       readm.Load_Dtm--,
       --pt.sk_Dim_Pt,
       --pt.sk_Dim_Clrt_Pt,
       --pt.Load_Dtm,
       --pt.UpDte_Dtm,
       --pt.MRN_int,
       --pt.MRN_display,
       --pt.PAT_ID,
       --pt.Pt_Rec_Merged_Out,
       --pt.Epic_Patient,
       --pt.Patient_Status,
       --pt.Registration_Type,
       --pt.Registration_Status,
       --pt.LAST_ACCESS_DATE,
       --pt.sk_PCP_SERsrc,
       --pt.sk_PCP_Physcn,
       --pt.Encounters,
       --pt.BirthDate,
       --pt.Name,
       --pt.FirstName,
       --pt.MiddleName,
       --pt.LastName,
       --pt.Deceased,
       --pt.DeathDate,
       --pt.Sex,
       --pt.Ethnicity,
       --pt.MaritalStatus,
       --pt.Religion,
       --pt.FirstRace,
       --pt.SecondRace,
       --pt.ThirdRace,
       --pt.FourthRace,
       --pt.FifthRace,
       --pt.MultiRacial,
       --pt.Ssn,
       --pt.Address_Line1,
       --pt.Addres_Line2,
       --pt.City,
       --pt.County,
       --pt.StateOrProvince,
       --pt.Country,
       --pt.PostalCode,
       --pt.HomePhoneNumber,
       --pt.WorkPhoneNumber,
       --pt.EnterpriseId,
       --pt.SmokingStatus,
       --pt.PrimaryFinancialClass,
       --pt.HighestLevelOfEducation,
       --pt.Restricted,
       --pt.Test,
       --pt.PREV_MRN_1,
       --pt.PREV_MRN_2,
       --pt.PREV_MRN_3,
       --pt.Preferred_Name,
       --pt.Gender_Identity_Name,
       --pt.Sexual_Orientation_Name_Current,
       --pt.Sex_Asgn_at_Birth_Name,
       --pt.IS_VALID_PAT_YN,
       --pt.CompID
FROM #dwreadm readm
LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Patient pt
ON pt.sk_Dim_Pt = readm.sk_Dim_Pt
WHERE event_type = 'Readmission'
ORDER BY event_date

	  -- # Temp table to store Visit Metrics
	
--SELECT vstSet.sk_Dim_Pt,
--       SUM(vstSet.[Follow-up Visits]) 'Follow-up Visits',
--       MAX(vstSet.Outpatient_Contact_Date) Last_Outpatient_Contact_Date
--INTO #visits
--FROM
--(
--    SELECT DISTINCT
--           dtset.sk_Dim_Pt,
--           COUNT(DISTINCT (CASE
--                               WHEN dtset.sk_Dim_Clrt_Enc_Typ = 66 THEN
--                                   dtset.sk_Fact_Pt_Enc_Clrt
--                               ELSE
--                                   NULL
--                           END
--                          )
--                ) 'Follow-up Visits',
--           (CASE
--                WHEN dtset.ADT_PAT_CLASS_C = '102' THEN
--                    dtset.Contact_Date
--            END
--           ) Outpatient_Contact_Date
--    FROM
--    (
--        SELECT DISTINCT
--               hsp.sk_Fact_Pt_Acct,
--               hsp.sk_Dim_Pt,
--               hsp.sk_Fact_Pt_Enc_Clrt,
--               hsp.sk_Dim_Clrt_Enc_Typ,
--               ptcls.ADT_PAT_CLASS_C,
--               ptcls.Pt_Cls_Nme,
--               dd.day_date Contact_Date,
--               prc.Prc_Nme,
--               prc.PRC_ID,
--               prc.Prc_Rec_Typ,
--               sts.APPT_STATUS_C,
--               sts.Appt_Sts_Nme,
--               ROW_NUMBER() OVER (PARTITION BY hsp.sk_Fact_Pt_Acct ORDER BY dd.day_date) rn
--        FROM #dwreadm AS rptf
--            INNER JOIN DS_HSDW_Prod.Rptg.vwFact_Pt_Enc_Clrt AS hsp
--                ON hsp.sk_Fact_Pt_Acct = rptf.sk_Fact_Pt_Acct
--            LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Clrt_Pt_Cls AS ptcls
--                ON ptcls.sk_Dim_Clrt_Pt_Cls = hsp.sk_Dim_Clrt_Pt_Cls
--            LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Date AS dd
--                ON dd.date_key = hsp.sk_Cont_Dte
--            LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Clrt_Prc AS prc
--                ON prc.sk_Dim_Clrt_Prc = hsp.sk_Dim_Clrt_Prc
--            LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Clrt_Appt_Sts AS sts
--                ON sts.sk_Dim_Clrt_Appt_Sts = hsp.sk_Dim_Clrt_Appt_Sts
--        WHERE 1 = 1
--              AND hsp.Adm_Dtm >= DATEADD(
--                                            YEAR,
--                                            -1,
--                                            IIF(rptf.index_admission_event_date = '19000101',
--                                                NULL,
--                                                rptf.index_admission_event_date)
--                                        )
--              AND hsp.Adm_Dtm <= rptf.index_admission_event_date
--    ) AS dtset
--    GROUP BY dtset.sk_Fact_Pt_Acct,
--             dtset.sk_Dim_Pt,
--             dtset.ADT_PAT_CLASS_C,
--             dtset.Prc_Nme,
--             dtset.APPT_STATUS_C,
--             dtset.Contact_Date
--) AS vstSet
--GROUP BY vstSet.sk_Dim_Pt;
----Temp Table to store Events like transfers, ICU Admits
--SELECT hsp.sk_Fact_Pt_Enc_Clrt,
--       hsp.sk_Dim_pt,
--       COUNT(DISTINCT CASE
--                          WHEN cadt.EVENT_TYPE_C = 1
--                               AND dep.ICU_Dept_YN = 'Y' THEN
--                              adt.EVENT_ID
--                          ELSE
--                              NULL
--                      END
--            ) ICU_Admits,
--       COUNT(DISTINCT CASE
--                          WHEN cadt.EVENT_TYPE_C = 3 THEN
--                              adt.EVENT_ID
--                          ELSE
--                              NULL
--                      END
--            ) Internal_Transfers
--INTO #events
----dd.day_date ADMISSION,
----cadt.ADT_Evnt_Nme,
----cadt.EVENT_TYPE_C,
----dep.Clrt_DEPt_Nme, dep.ICU_Dept_YN
--FROM DS_HSDW_Prod.Rptg.vwFact_Clrt_ADT AS adt
--    INNER JOIN #dwreadm AS rpt
--        ON rpt.sk_Fact_Pt_Enc_Clrt = adt.sk_Fact_Pt_Enc_Clrt
--    LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Clrt_ADT_Evnt AS cadt
--        ON cadt.sk_Dim_Clrt_ADT_Evnt = adt.sk_Dim_Clrt_ADT_Evnt
--    LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Clrt_DEPt AS dep
--        ON dep.sk_Dim_Clrt_DEPt = adt.sk_Dim_Clrt_DEPt
--    LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwFact_Pt_Enc_Hsp_Clrt AS hsp
--        ON hsp.sk_Fact_Pt_Enc_Clrt = adt.sk_Fact_Pt_Enc_Clrt
--    LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Date AS dd
--        ON dd.date_key = hsp.sk_Adm_Dte
--WHERE 1 = 1
--      AND dd.day_date >= DATEADD(
--                                    YEAR,
--                                    -1,
--                                    IIF(rpt.index_admission_event_date = '19000101',
--                                        NULL,
--                                        rpt.index_admission_event_date)
--                                )
--      AND dd.day_date <= rpt.index_admission_event_date
--GROUP BY hsp.sk_Fact_Pt_Enc_Clrt,
--         hsp.MRN_Clrt,
--         hsp.sk_Dim_pt;

----Temp table dx used to determine Charlson Score  

--SELECT DISTINCT
--       *
--INTO #dx
--FROM
--(
--    SELECT [sk_dim_dx],
--           [MI],
--           [CHF],
--           [PVD],
--           [CVD],
--           [DEM],
--           [CPD],
--           [RHM],
--           [PEP],
--           [MLD],
--           [DNC],
--           [DWC],
--           [PLE],
--           [REN],
--           [CAN],
--           [LIV],
--           [MET],
--           [HIV]
--    FROM [DS_HSDW_Prod].Rptg.[VwRef_Dx_Cmbdty_10]
--) AS d
--    UNPIVOT
--    (
--        vals
--        FOR conds IN ([MI], [CHF], [PVD], [CVD], [DEM], [CPD], [RHM], [PEP], [MLD], [DNC], [DWC], [PLE], [REN], [CAN],
--                      [LIV], [MET], [HIV]
--                     )
--    ) AS pv
--WHERE vals > 0
--UNION
--SELECT *
--FROM
--(
--    SELECT [sk_dim_dx],
--           [MI],
--           [CHF],
--           [PVD],
--           [CVD],
--           [DEM],
--           [CPD],
--           [RHM],
--           [PEP],
--           [MLD],
--           [DNC],
--           [DWC],
--           [PLE],
--           [REN],
--           [CAN],
--           [LIV],
--           [MET],
--           [HIV]
--    FROM [DS_HSDW_Prod].Rptg.[vwRef_Dx_Cmbdty]
--) AS d
--    UNPIVOT
--    (
--        vals
--        FOR conds IN ([MI], [CHF], [PVD], [CVD], [DEM], [CPD], [RHM], [PEP], [MLD], [DNC], [DWC], [PLE], [REN], [CAN],
--                      [LIV], [MET], [HIV]
--                     )
--    ) AS pv
--WHERE vals > 0;


---- MAIN DATA
--SELECT aggr.MRN_int 'Person_Id',
--       dwreadm.event_type,
--       dwreadm.event_date,
--	   dwreadm.event_count,
--       dwreadm.person_name,
--       readm.sk_Fact_Pt_Enc_Clrt,
--       dwreadm.w_service_line_id,                        --new 01/22/2019
--       dwreadm.w_service_line_name,                      --new 01/22/2019

--       dwreadm.service_line_loc 'Service Line by Location',
--       dwreadm.service_line_id 'Service line ID of discharge attending',
--       dwreadm.service_line 'Service line of discharge attending',
--       dwreadm.w_hs_area_name,
--       dwreadm.fyear_num,
--      DATEPART(MONTH,dwreadm.event_date) fmonth_num,
--       dser.Financial_Division_Name Discharge_Attending_Division,
--       dser.Financial_SubDivision_Name Discharge_Attending_SubDivision,
--       dwreadm.Discharging_Unit_Name,
--       dwreadm.epic_department_id,
--       dwreadm.epic_department_name,
--       dwreadm.provider_id,
--       dwreadm.provider_name,
--       ser.Prov_Nme PCP,
--       pt.Clrt_Sex Gender,
--       readm.PAT_AGE_YEARS_AT_ADMISSION,
--       readm.Pat_Ethnicity,
--       readm.Pat_Race,
--       readm.PAT_POSTAL_CODE,
--       readm.Patient_Class,
--       dwreadm.readm_fmonth_num,
--       dwreadm.readm_fyear_name,
--       dwreadm.readm_fyear_num,
--       dwreadm.readm_hs_area_name,
--       dwreadm.readm_epic_department_name_external,
--       dwreadm.readmission_service_line_loc,
--       dwreadm.readmission_service_line,
--       dwreadm.Readmission_Unit_Name,
--       dwreadm.readmission_admission_adt_pt_cls,
--	   dwreadm.Discharge_Dx,
--	   dwreadm.Discharge_Dx_Name,
--       dwreadm.Readmission_Dx,
--       dwreadm.Readmission_Dx_Name,
--       dwreadm.next_sk_Fact_Pt_Enc_Clrt,
--       dwreadm.Planned_Readmission,
--       MAX(dwreadm.index_admission_event_date) index_admission_event_date,
--       MAX(dwreadm.index_discharge_event_date) index_discharge_event_date,
--       MAX(dwreadm.readmission_admission_event_date) readmission_admission_event_date,
--       MAX(dwreadm.readmission_discharge_event_date) readmission_discharge_event_date,
--       MAX(dwreadm.index_admission_ADM_SOURCE) index_admission_ADM_SOURCE,
--       MAX(dwreadm.index_admission_HOSP_ADMSN_TYPE) index_admission_HOSP_ADMSN_TYPE,
--       MAX(dwreadm.index_admission_HOSP_ADMSN_STATUS) index_admission_HOSP_ADMSN_STATUS,
--       MAX(dwreadm.readmission_admission_ADM_SOURCE) readmission_admission_ADM_SOURCE,
--       MAX(dwreadm.readmission_admission_HOSP_ADMSN_TYPE) readmission_admission_HOSP_ADMSN_TYPE,
--       MAX(dwreadm.readmission_admission_HOSP_ADMSN_STATUS) readmission_admission_HOSP_ADMSN_STATUS,
--       dwreadm.readmission_provider_id,                  --new 01/22/2019
--       dwreadm.readmission_provider_name,                -- new 01/22/2019
--       serv.Hsptl_Svc_Dscr Hospital_Service,
--       bill.Billg_Fin_Cls_Cat_Nme 'Financial Class',
--       pyr.Insrnc_Pln_Nme 'Primary_Payor_Name',
--       aggr.LOS,
--       aggr.ICU_Pt_Days,
--       readm.MOST_RECENT_BMI,
--       readm.MOST_RECENT_SYSTOLIC,
--       readm.MOST_RECENT_DIASTOLIC,
--       (
--           SELECT DISTINCT
--                  '; ' + prd.OR_Prcdr_Nme
--           FROM DS_HSDW_Prod.Rptg.vwSurgicalCaseFact_Ext AS srg
--               LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_OR_Prcdr AS prd
--                   ON prd.sk_Dim_OR_Prcdr = srg.PrimarySurgicalProcedureKey
--           WHERE srg.HospitalEncounterKey = readm.sk_Fact_Pt_Enc_Clrt
--                 AND prd.OR_Prcdr_Nme IS NOT NULL
--           FOR XML PATH('')
--       ) PRIMARY_OR_PROCEDURE,
--       readm.NUM_HOSPITAL_ENC 'Inpatient_Admits',
--       readm.X_OFC_VIST_NUM 'Outpatient_Admits',
--       readm.NUM_ED_VISITS 'Num_ED_Admits',
--       readm.X_HH_VISIT_NUM 'Num_HomeHealth_Visits',
--       readm.X_NO_SHOW_NUM 'Num_NoShow_Visits',
--       (vis.[Follow-up Visits]) 'Follow-up Visits',
--       (vis.Last_Outpatient_Contact_Date) Last_Outpatient_Contact_Date,
--       drg.DRG_Cde,
--       drg.DRG_Dscr,
--       readm.ADMISSION_DX_CODE_LIST,
--       readm.PRINCIPAL_PROBLEM_DX_CODE_LIST,
--       aggr.AcctNbr_int,
--       aggr.Tot_Cst,
--       aggr.tot_chg_amt,
--       (ev.ICU_Admits) ICU_Admits,
--       (ev.Internal_Transfers) Internal_Transfers,
--       phy.DisplayName Attending_Physician,
--       COUNT(DISTINCT phy.sk_Dim_Physcn) Number_of_Attending,
--       readm.PRESENT_ON_ADMSN_DX_CODE_LIST,
--       uhcenc.COMPLICATIONSFLAG,
--       readm.HOSPITAL_ACQUIRED_DX_CODE_LIST,
--       readm.NUM_ACTIVE_MEDICATION_ORDERS,
--       readm.NUM_DISCHARGE_RX,
--       readm.X_ACTIVE_ALLERGY_COUNT,
--       COUNT(DISTINCT sk_Fact_Pt_Infection) Infections,
--       (aria.RiskScore) aria_score,
--       COUNT(DISTINCT elc.sk_Category) Elixhauser_Score, -- DISTINCT number OF Categories 
--       (g.totalscore) Charlson_Score,
--       rgs.ADULT_PALLIATIVE_CARE_REGISTRY_UVA,
--       readm.MEMBER_OF_DIABETES_REGISTRY,
--       readm.MEMBER_OF_OBESITY_REGISTRY,
--       CASE
--           WHEN readm.X_MBR_CANC_RGSTRY_YN = 'Y' THEN
--               1
--           WHEN readm.X_MBR_CANC_RGSTRY_YN = 'N' THEN
--               0
--           ELSE
--               NULL
--       END X_MBR_CANC_RGSTRY_YN,                         -- Updated 01/22/2019
--       readm.MEMBER_OF_COPD_REGISTRY,
--       readm.MEMBER_OF_CHF_REGISTRY,
--       readm.MEMBER_OF_CAD_REGISTRY,
--       readm.X_FIRST_HB1AC,
--       readm.X_IP_FIRST_WBC,
--       readm.X_FIRST_HEMATOCRIT,
--       readm.X_FIRST_MCV,
--       readm.X_FIRST_PLATELET,
--       readm.X_FIRST_GLUCOSE,                            -- updated 02152019
--       readm.X_FIRST_SODIUM,
--       readm.X_FIRST_POTASSIUM,
--       readm.X_FIRST_BUN,
--       readm.X_FIRST_CREATININE,
--       readm.X_FIRST_CO2,
--       readm.X_FIRST_BILIRUBIN,
--       readm.X_FIRST_ALBUMIN,
--       readm.X_FIRST_ALT,
--       readm.X_FIRST_AST,
--       readm.X_FIRST_ALKPHOS,
--       readm.X_FIRST_CRP,
--       readm.X_FIRST_SED_RATE,
--       readm.X_FIRST_LIPASE,
--       readm.X_FIRST_CA199,
--       readm.X_FIRST_AFP,
--       readm.X_FIRST_CEA,
--       readm.X_FIRST_INR,
--       readm.X_FIRST_PTT,
--       readm.X_FIRST_FIBRINOGEN,
--       readm.X_FIRST_LACTIC_ACID,
--       readm.X_LAST_HB1AC,
--       readm.X_IP_LAST_WBC,
--       readm.X_LAST_MCV,
--       readm.X_LAST_PLATELET,
--       readm.X_LAST_GLUCOSE,                             -- updated 02152019
--       readm.X_LAST_SODIUM,
--       readm.X_LAST_POTASSIUM,
--       readm.X_LAST_BUN,
--       readm.X_LAST_CREATININE,
--       readm.X_LAST_CO2,
--       readm.X_LAST_BILIRUBIN,
--       readm.X_LAST_ALBUMIN,
--       readm.X_LAST_ALT,
--       readm.X_LAST_AST,
--       readm.X_LAST_ALKPHOS,
--       readm.X_LAST_CRP,
--       readm.X_LAST_SED_RATE,
--       readm.X_LAST_LIPASE,
--       readm.X_LAST_CA199,
--       readm.X_LAST_AFP,
--       readm.X_LAST_CEA,
--       readm.X_LAST_INR,
--       readm.X_LAST_PTT,
--       readm.X_LAST_FIBRINOGEN,
--       readm.X_LAST_LACTIC_ACID 		INTO #main

--FROM DS_HSDW_Prod.Rptg.vwFact_Pt_ReadmissionRegistry AS readm -- Registry Table from CLARITY
--    INNER JOIN #dwreadm AS dwreadm
--        ON dwreadm.sk_Fact_Pt_Enc_Clrt = readm.sk_Fact_Pt_Enc_Clrt
--    --AND dwreadm.event_type = 'Readmission' -- Only Readmission event type
--    LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Clrt_Pt AS pt
--        ON pt.sk_Dim_Pt = readm.sk_Dim_Pt
--    LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwFact_Pt_Acct_Aggr AS aggr
--        ON aggr.sk_Fact_Pt_Acct = dwreadm.sk_Fact_Pt_Acct
--    LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Clrt_SERsrc AS ser
--        ON ser.PROV_ID = readm.PAT_PCP_PROV_ID
--    LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Clrt_SERsrc AS dser
--        ON dser.PROV_ID = dwreadm.discharging_provider_id
--    LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_DRG AS drg
--        ON drg.sk_Dim_DRG = aggr.sk_MS_DRG
--    LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwSurgicalCaseFact_Ext AS srg
--        ON srg.HospitalEncounterKey = dwreadm.sk_Fact_Pt_Enc_Clrt
--    LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_OR_Prcdr AS prd
--        ON prd.sk_Dim_OR_Prcdr = srg.PrimarySurgicalProcedureKey
--    LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwFact_Pt_Insrnc AS ins
--        ON ins.sk_Fact_Pt_Acct = dwreadm.sk_Fact_Pt_Acct
--           AND ins.Insrnc_Prio = '1'
--    LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Insrnc_Pln_Pyr AS pyr
--        ON pyr.sk_Dim_Insrnc_Pln_Pyr = ins.sk_Dim_Insrnc_Pln_Pyr
--           AND pyr.Source_system = aggr.Source_System
--    LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Billg_Fin_Cls AS bill
--        ON bill.sk_Dim_Billg_Fin_Cls = aggr.sk_Dim_Billg_Fin_Cls
--    LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Hsptl_Svc AS serv
--        ON serv.Hsptl_Svc_Cde = readm.HOSPITAL_SERVICE_C
--           AND serv.Source_System = 'Epic'
--    LEFT OUTER JOIN #visits AS vis
--        ON vis.sk_Dim_Pt = dwreadm.sk_Dim_Pt
--    LEFT OUTER JOIN #events AS ev
--        ON ev.sk_Fact_Pt_Enc_Clrt = dwreadm.sk_Fact_Pt_Enc_Clrt
--    LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Physcn AS phy
--        ON phy.sk_Dim_Physcn = aggr.sk_Phys_Atn
--    LEFT OUTER JOIN [DS_HSDW_Prod].[Rptg].[vwUHC_Encounter] AS uhcenc
--        ON uhcenc.ENCOUNTERID = aggr.AcctNbr_int
--    LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwFact_Pt_Infection AS inf
--        ON inf.sk_Dim_Clrt_Pt = pt.sk_Dim_Clrt_Pt
--           AND inf.INF_RSV_PL_TIME = '1900-01-01 00:00:00.000'
--    LEFT OUTER JOIN -- Latest Aria Score
--    (
--        SELECT sk_Dim_Pt,
--               MRN,
--               RiskScore,
--               RiskLevel,
--               rprtDate,
--               ROW_NUMBER() OVER (PARTITION BY sk_Dim_Pt ORDER BY rprtDate DESC) rn
--        FROM [DS_HSDW_Prod].Rptg.vwRef_ARIAEMR_All
--    ) AS aria
--        ON aria.sk_Dim_Pt = readm.sk_Dim_Pt
--           AND aria.rn = 1
--    LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Dx AS ddx
--        ON ddx.Dx_Cde = dwreadm.Readmission_Dx
--    LEFT OUTER JOIN [DS_HSDM_Prod].[CMS].[Elixhauser_Conditions] AS elmp -- Basic Elixhauser Score
--        ON elmp.Dx = ddx.Dx_Cde_Dotless
--    LEFT OUTER JOIN [DS_HSDM_Prod].[CMS].[Elixhauser_Categories] AS elc
--        ON elc.sk_Category = elmp.sk_Category
--    LEFT OUTER JOIN -- Join  the dx Temp table to calculate Charlson Score
--    (
--        SELECT DISTINCT
--               a.sk_Dim_Pt,
--               a.index_admission_event_date,
--               SUM(score) AS totalscore
--        FROM
--        (
--            SELECT DISTINCT
--                   t.sk_Dim_Pt,
--                   t.index_admission_event_date,
--                   CASE
--                       WHEN
--                       (
--                           d.conds = 'MET'
--                           OR d.conds = 'HIV'
--                       ) THEN
--                           6
--                       WHEN (d.conds = 'LIV') THEN
--                           3
--                       WHEN
--                       (
--                           d.conds = 'DWC'
--                           OR d.conds = 'PLE'
--                           OR d.conds = 'REN'
--                           OR d.conds = 'CAN'
--                       ) THEN
--                           2
--                       ELSE
--                           1
--                   END AS score,
--                   d.conds
--            FROM #dwreadm AS t
--                JOIN DS_HSDW_Prod.Rptg.vwFact_Pt_Acct_Aggr AS a
--                    ON t.sk_Dim_Pt = a.sk_Dim_Pt
--                JOIN DS_HSDW_Prod.Rptg.vwFact_Pt_Dx AS dx
--                    ON dx.sk_Fact_Pt_Acct = a.sk_Fact_Pt_Acct
--                JOIN DS_HSDW_Prod.Rptg.vwDim_Date AS da
--                    ON da.date_key = dx.sk_Crt_Dte
--                       AND DATEDIFF(DAY, da.day_date, t.index_admission_event_date)
--                       BETWEEN 0 AND 365
--                JOIN DS_HSDW_Prod.Rptg.vwDim_Dx AS x
--                    ON x.sk_dim_dx = dx.sk_Dim_Dx
--                JOIN #dx AS d
--                    ON d.sk_dim_dx = x.sk_dim_dx
--        ) AS a
--        GROUP BY a.sk_Dim_Pt,
--                 a.index_admission_event_date
--    ) AS g
--        ON g.sk_Dim_Pt = readm.sk_Dim_Pt
--           AND g.index_admission_event_date = dwreadm.index_admission_event_date
--    LEFT OUTER JOIN [DS_HSDW_Prod].[Rptg].[VwFact_Pt_Clrt_Rgstry_Pivot] AS rgs
--        ON rgs.sk_Dim_Clrt_Pt = pt.sk_Dim_Clrt_Pt
--WHERE 1 = 1
--GROUP BY aggr.MRN_int,
--         dwreadm.event_date,
--dwreadm.event_count,
--         dwreadm.person_name,
--         dwreadm.event_type,
--         readm.sk_Fact_Pt_Enc_Clrt,
--         dwreadm.service_line_loc,
--         dwreadm.service_line,
--         dwreadm.w_hs_area_name,
--         dwreadm.fyear_num,
--         dwreadm.fmonth_num,
--         dser.Financial_Division_Name,
--         dser.Financial_SubDivision_Name,
--         dwreadm.w_service_line_id,         --new 01/22/2019
--         dwreadm.w_service_line_name,       --new 01/22/2019
--         dwreadm.service_line_id,
--         dwreadm.epic_department_id,
--         dwreadm.provider_id,
--         dwreadm.Discharging_Unit_Name,
--         dwreadm.epic_department_name,
--         dwreadm.provider_name,
--         dwreadm.readmission_provider_id,   --new
--         dwreadm.readmission_provider_name, -- new
--         dwreadm.readm_fmonth_num,
--         dwreadm.readm_fyear_name,
--         dwreadm.readm_fyear_num,
--         dwreadm.readm_hs_area_name,
--         dwreadm.readm_epic_department_name_external,
--         dwreadm.readmission_service_line_loc,
--         dwreadm.readmission_service_line,
--         dwreadm.Readmission_Unit_Name,
--         dwreadm.readmission_admission_adt_pt_cls,
--         dwreadm.Readmission_Dx,
--         dwreadm.Readmission_Dx_Name,
--		 dwreadm.Discharge_Dx,
--	   dwreadm.Discharge_Dx_Name,
--         dwreadm.next_sk_Fact_Pt_Enc_Clrt,
--         dwreadm.Planned_Readmission,
--         ser.Prov_Nme,
--         pt.Clrt_Sex,
--         readm.PAT_AGE_YEARS_AT_ADMISSION,
--         readm.Pat_Ethnicity,
--         readm.Pat_Race,
--         readm.PAT_POSTAL_CODE,
--         (vis.[Follow-up Visits]),
--         (vis.Last_Outpatient_Contact_Date),
--         (ev.ICU_Admits),
--         (ev.Internal_Transfers),
--         readm.Patient_Class,
--         serv.Hsptl_Svc_Dscr,
--         bill.Billg_Fin_Cls_Cat_Nme,
--         pyr.Insrnc_Pln_Nme,
--         aggr.LOS,
--         aggr.ICU_Pt_Days,
--         readm.MOST_RECENT_BMI,
--         readm.MOST_RECENT_SYSTOLIC,
--         readm.MOST_RECENT_DIASTOLIC,
--         readm.NUM_HOSPITAL_ENC,
--         readm.X_OFC_VIST_NUM,
--         readm.NUM_ED_VISITS,
--         readm.X_HH_VISIT_NUM,
--         readm.X_NO_SHOW_NUM,
--         drg.DRG_Cde,
--         drg.DRG_Dscr,
--         readm.ADMISSION_DX_CODE_LIST,
--         readm.PRINCIPAL_PROBLEM_DX_CODE_LIST,
--         aggr.AcctNbr_int,
--         aggr.Tot_Cst,
--         aggr.tot_chg_amt,
--         aria.RiskScore,
--         g.totalscore,
--         phy.DisplayName,
--         readm.PRESENT_ON_ADMSN_DX_CODE_LIST,
--         uhcenc.COMPLICATIONSFLAG,
--         readm.HOSPITAL_ACQUIRED_DX_CODE_LIST,
--         readm.NUM_ACTIVE_MEDICATION_ORDERS,
--         readm.NUM_DISCHARGE_RX,
--         readm.X_ACTIVE_ALLERGY_COUNT,
--         rgs.ADULT_PALLIATIVE_CARE_REGISTRY_UVA,
--         readm.MEMBER_OF_DIABETES_REGISTRY,
--         readm.MEMBER_OF_OBESITY_REGISTRY,
--         readm.X_MBR_CANC_RGSTRY_YN,
--         readm.MEMBER_OF_COPD_REGISTRY,
--         readm.MEMBER_OF_CHF_REGISTRY,
--         readm.MEMBER_OF_CAD_REGISTRY,
--         readm.X_FIRST_HB1AC,
--         readm.X_IP_FIRST_WBC,
--         readm.X_FIRST_HEMATOCRIT,
--         readm.X_FIRST_MCV,
--         readm.X_FIRST_PLATELET,
--         readm.X_FIRST_GLUCOSE,             -- updated 02152019
--         readm.X_FIRST_SODIUM,
--         readm.X_FIRST_POTASSIUM,
--         readm.X_FIRST_BUN,
--         readm.X_FIRST_CREATININE,
--         readm.X_FIRST_CO2,
--         readm.X_FIRST_BILIRUBIN,
--         readm.X_FIRST_ALBUMIN,
--         readm.X_FIRST_ALT,
--         readm.X_FIRST_AST,
--         readm.X_FIRST_ALKPHOS,
--         readm.X_FIRST_CRP,
--         readm.X_FIRST_SED_RATE,
--         readm.X_FIRST_LIPASE,
--         readm.X_FIRST_CA199,
--         readm.X_FIRST_AFP,
--         readm.X_FIRST_CEA,
--         readm.X_FIRST_INR,
--         readm.X_FIRST_PTT,
--         readm.X_FIRST_FIBRINOGEN,
--         readm.X_FIRST_LACTIC_ACID,
--         readm.X_LAST_HB1AC,
--         readm.X_IP_LAST_WBC,
--         readm.X_LAST_MCV,
--         readm.X_LAST_PLATELET,
--         readm.X_LAST_GLUCOSE,              -- updated 02152019
--         readm.X_LAST_SODIUM,
--         readm.X_LAST_POTASSIUM,
--         readm.X_LAST_BUN,
--         readm.X_LAST_CREATININE,
--         readm.X_LAST_CO2,
--         readm.X_LAST_BILIRUBIN,
--         readm.X_LAST_ALBUMIN,
--         readm.X_LAST_ALT,
--         readm.X_LAST_AST,
--         readm.X_LAST_ALKPHOS,
--         readm.X_LAST_CRP,
--         readm.X_LAST_SED_RATE,
--         readm.X_LAST_LIPASE,
--         readm.X_LAST_CA199,
--         readm.X_LAST_AFP,
--         readm.X_LAST_CEA,
--         readm.X_LAST_INR,
--         readm.X_LAST_PTT,
--         readm.X_LAST_FIBRINOGEN,
--         readm.X_LAST_LACTIC_ACID
--ORDER BY index_admission_event_date


--SELECT fin.Person_Id
--, fin.event_count
--     , fin.event_type
--     , fin.event_date
--     , fin.person_name
--     , fin.sk_Fact_Pt_Enc_Clrt
--     , fin.w_service_line_id
--     , fin.w_service_line_name
--     , fin.[Service Line by Location]
--     , fin.[Service line ID of discharge attending]
--     , fin.[Service line of discharge attending]
--     , fin.w_hs_area_name
--     , fin.fyear_num
--     , fin.fmonth_num
--     , fin.Discharge_Attending_Division
--     , fin.Discharge_Attending_SubDivision
--     , fin.Discharging_Unit_Name
--     , fin.epic_department_id
--     , fin.epic_department_name
--     , fin.provider_id
--     , fin.provider_name
--     , fin.PCP
--     , fin.Gender
--     , fin.PAT_AGE_YEARS_AT_ADMISSION
--     , fin.Pat_Ethnicity
--     , fin.Pat_Race
--     , fin.PAT_POSTAL_CODE
--     , fin.Patient_Class
--     , fin.readm_fmonth_num
--     , fin.readm_fyear_name
--     , fin.readm_fyear_num
--     , fin.readm_hs_area_name
--     , fin.readm_epic_department_name_external
--     , fin.readmission_service_line_loc
--     , fin.readmission_service_line
--     , fin.Readmission_Unit_Name
--     , fin.readmission_admission_adt_pt_cls
--     , fin.Discharge_Dx
--     , fin.Discharge_Dx_Name
--     , fin.Readmission_Dx
--     , fin.Readmission_Dx_Name
--     , fin.next_sk_Fact_Pt_Enc_Clrt
--     , fin.Planned_Readmission
--     , fin.index_admission_event_date
--     , fin.index_discharge_event_date
--     , fin.readmission_admission_event_date
--     , fin.readmission_discharge_event_date
--     , fin.index_admission_ADM_SOURCE
--     , fin.index_admission_HOSP_ADMSN_TYPE
--     , fin.index_admission_HOSP_ADMSN_STATUS
--     , fin.readmission_admission_ADM_SOURCE
--     , fin.readmission_admission_HOSP_ADMSN_TYPE
--     , fin.readmission_admission_HOSP_ADMSN_STATUS
--     , fin.readmission_provider_id
--     , fin.readmission_provider_name
--     , fin.Hospital_Service
--     , fin.[Financial Class]
--     , fin.Primary_Payor_Name
--     , fin.LOS
--     , fin.ICU_Pt_Days
--     , fin.MOST_RECENT_BMI
--     , fin.MOST_RECENT_SYSTOLIC
--     , fin.MOST_RECENT_DIASTOLIC
--     , fin.PRIMARY_OR_PROCEDURE
--     , fin.Inpatient_Admits
--     , fin.Outpatient_Admits
--     , fin.Num_ED_Admits
--     , fin.Num_HomeHealth_Visits
--     , fin.Num_NoShow_Visits
--     , fin.[Follow-up Visits]
--     , fin.Last_Outpatient_Contact_Date
--     , fin.DRG_Cde
--     , fin.DRG_Dscr
--     , fin.ADMISSION_DX_CODE_LIST
--     , fin.PRINCIPAL_PROBLEM_DX_CODE_LIST
--     , fin.AcctNbr_int
--     , fin.Tot_Cst
--     , fin.tot_chg_amt
--     , fin.ICU_Admits
--     , fin.Internal_Transfers
--     , fin.Attending_Physician
--     , fin.Number_of_Attending
--     , fin.PRESENT_ON_ADMSN_DX_CODE_LIST
--     , fin.COMPLICATIONSFLAG
--     , fin.HOSPITAL_ACQUIRED_DX_CODE_LIST
--     , fin.NUM_ACTIVE_MEDICATION_ORDERS
--     , fin.NUM_DISCHARGE_RX
--     , fin.X_ACTIVE_ALLERGY_COUNT
--     , fin.Infections
--     , fin.aria_score
--     , fin.Elixhauser_Score
--     , fin.Charlson_Score
--     , fin.ADULT_PALLIATIVE_CARE_REGISTRY_UVA
--     , fin.MEMBER_OF_DIABETES_REGISTRY
--     , fin.MEMBER_OF_OBESITY_REGISTRY
--     , fin.X_MBR_CANC_RGSTRY_YN
--     , fin.MEMBER_OF_COPD_REGISTRY
--     , fin.MEMBER_OF_CHF_REGISTRY
--     , fin.MEMBER_OF_CAD_REGISTRY
--     , fin.X_FIRST_HB1AC
--     , fin.X_IP_FIRST_WBC
--     , fin.X_FIRST_HEMATOCRIT
--     , fin.X_FIRST_MCV
--     , fin.X_FIRST_PLATELET
--     , fin.X_FIRST_GLUCOSE
--     , fin.X_FIRST_SODIUM
--     , fin.X_FIRST_POTASSIUM
--     , fin.X_FIRST_BUN
--     , fin.X_FIRST_CREATININE
--     , fin.X_FIRST_CO2
--     , fin.X_FIRST_BILIRUBIN
--     , fin.X_FIRST_ALBUMIN
--     , fin.X_FIRST_ALT
--     , fin.X_FIRST_AST
--     , fin.X_FIRST_ALKPHOS
--     , fin.X_FIRST_CRP
--     , fin.X_FIRST_SED_RATE
--     , fin.X_FIRST_LIPASE
--     , fin.X_FIRST_CA199
--     , fin.X_FIRST_AFP
--     , fin.X_FIRST_CEA
--     , fin.X_FIRST_INR
--     , fin.X_FIRST_PTT
--     , fin.X_FIRST_FIBRINOGEN
--     , fin.X_FIRST_LACTIC_ACID
--     , fin.X_LAST_HB1AC
--     , fin.X_IP_LAST_WBC
--     , fin.X_LAST_MCV
--     , fin.X_LAST_PLATELET
--     , fin.X_LAST_GLUCOSE
--     , fin.X_LAST_SODIUM
--     , fin.X_LAST_POTASSIUM
--     , fin.X_LAST_BUN
--     , fin.X_LAST_CREATININE
--     , fin.X_LAST_CO2
--     , fin.X_LAST_BILIRUBIN
--     , fin.X_LAST_ALBUMIN
--     , fin.X_LAST_ALT
--     , fin.X_LAST_AST
--     , fin.X_LAST_ALKPHOS
--     , fin.X_LAST_CRP
--     , fin.X_LAST_SED_RATE
--     , fin.X_LAST_LIPASE
--     , fin.X_LAST_CA199
--     , fin.X_LAST_AFP
--     , fin.X_LAST_CEA
--     , fin.X_LAST_INR
--     , fin.X_LAST_PTT
--     , fin.X_LAST_FIBRINOGEN
--     , fin.X_LAST_LACTIC_ACID	 FROM (
--SELECT mn.Person_Id,
--mn.event_count,
--       mn.event_type,
--       mn.event_date,
--       mn.person_name,
--       mn.sk_Fact_Pt_Enc_Clrt,
--       mn.w_service_line_id,
--       mn.w_service_line_name,
--       mn.[Service Line by Location],
--       mn.[Service line ID of discharge attending],
--       mn.[Service line of discharge attending],
--       mn.w_hs_area_name,
--       mn.fyear_num,
--       mn.fmonth_num,
--       mn.Discharge_Attending_Division,
--       mn.Discharge_Attending_SubDivision,
--       mn.Discharging_Unit_Name,
--       mn.epic_department_id,
--       mn.epic_department_name,
--       mn.provider_id,
--       mn.provider_name,
--       mn.PCP,
--       mn.Gender,
--       mn.PAT_AGE_YEARS_AT_ADMISSION,
--       mn.Pat_Ethnicity,
--       mn.Pat_Race,
--       mn.PAT_POSTAL_CODE,
--       mn.Patient_Class,
--       mn.readm_fmonth_num,
--       mn.readm_fyear_name,
--       mn.readm_fyear_num,
--       mn.readm_hs_area_name,
--       mn.readm_epic_department_name_external,
--       mn.readmission_service_line_loc,
--       mn.readmission_service_line,
--       mn.Readmission_Unit_Name,
--       mn.readmission_admission_adt_pt_cls,
--       mn.Discharge_Dx,
--       mn.Discharge_Dx_Name,
--       mn.Readmission_Dx,
--       mn.Readmission_Dx_Name,
--       mn.next_sk_Fact_Pt_Enc_Clrt,
--       mn.Planned_Readmission,
--       mn.index_admission_event_date,
--       mn.index_discharge_event_date,
--       mn.readmission_admission_event_date,
--       mn.readmission_discharge_event_date,
--       mn.index_admission_ADM_SOURCE,
--       mn.index_admission_HOSP_ADMSN_TYPE,
--       mn.index_admission_HOSP_ADMSN_STATUS,
--       mn.readmission_admission_ADM_SOURCE,
--       mn.readmission_admission_HOSP_ADMSN_TYPE,
--       mn.readmission_admission_HOSP_ADMSN_STATUS,
--       mn.readmission_provider_id,
--       mn.readmission_provider_name,
--       mn.Hospital_Service,
--       mn.[Financial Class],
--       mn.Primary_Payor_Name,
--       mn.LOS,
--       mn.ICU_Pt_Days,
--       mn.MOST_RECENT_BMI,
--       mn.MOST_RECENT_SYSTOLIC,
--       mn.MOST_RECENT_DIASTOLIC,
--       mn.PRIMARY_OR_PROCEDURE,
--       mn.Inpatient_Admits,
--       mn.Outpatient_Admits,
--       mn.Num_ED_Admits,
--       mn.Num_HomeHealth_Visits,
--       mn.Num_NoShow_Visits,
--       mn.[Follow-up Visits],
--       mn.Last_Outpatient_Contact_Date,
--       mn.DRG_Cde,
--       mn.DRG_Dscr,
--       mn.ADMISSION_DX_CODE_LIST,
--       mn.PRINCIPAL_PROBLEM_DX_CODE_LIST,
--       mn.AcctNbr_int,
--       mn.Tot_Cst,
--       mn.tot_chg_amt,
--       mn.ICU_Admits,
--       mn.Internal_Transfers,
--       mn.Attending_Physician,
--       mn.Number_of_Attending,
--       mn.PRESENT_ON_ADMSN_DX_CODE_LIST,
--       mn.COMPLICATIONSFLAG,
--       mn.HOSPITAL_ACQUIRED_DX_CODE_LIST,
--       mn.NUM_ACTIVE_MEDICATION_ORDERS,
--       mn.NUM_DISCHARGE_RX,
--       mn.X_ACTIVE_ALLERGY_COUNT,
--       mn.Infections,
--       mn.aria_score,
--       mn.Elixhauser_Score,
--       mn.Charlson_Score,
--       mn.ADULT_PALLIATIVE_CARE_REGISTRY_UVA,
--       mn.MEMBER_OF_DIABETES_REGISTRY,
--       mn.MEMBER_OF_OBESITY_REGISTRY,
--       mn.X_MBR_CANC_RGSTRY_YN,
--       mn.MEMBER_OF_COPD_REGISTRY,
--       mn.MEMBER_OF_CHF_REGISTRY,
--       mn.MEMBER_OF_CAD_REGISTRY,
--       mn.X_FIRST_HB1AC,
--       mn.X_IP_FIRST_WBC,
--       mn.X_FIRST_HEMATOCRIT,
--       mn.X_FIRST_MCV,
--       mn.X_FIRST_PLATELET,
--       mn.X_FIRST_GLUCOSE,
--       mn.X_FIRST_SODIUM,
--       mn.X_FIRST_POTASSIUM,
--       mn.X_FIRST_BUN,
--       mn.X_FIRST_CREATININE,
--       mn.X_FIRST_CO2,
--       mn.X_FIRST_BILIRUBIN,
--       mn.X_FIRST_ALBUMIN,
--       mn.X_FIRST_ALT,
--       mn.X_FIRST_AST,
--       mn.X_FIRST_ALKPHOS,
--       mn.X_FIRST_CRP,
--       mn.X_FIRST_SED_RATE,
--       mn.X_FIRST_LIPASE,
--       mn.X_FIRST_CA199,
--       mn.X_FIRST_AFP,
--       mn.X_FIRST_CEA,
--       mn.X_FIRST_INR,
--       mn.X_FIRST_PTT,
--       mn.X_FIRST_FIBRINOGEN,
--       mn.X_FIRST_LACTIC_ACID,
--       mn.X_LAST_HB1AC,
--       mn.X_IP_LAST_WBC,
--       mn.X_LAST_MCV,
--       mn.X_LAST_PLATELET,
--       mn.X_LAST_GLUCOSE,
--       mn.X_LAST_SODIUM,
--       mn.X_LAST_POTASSIUM,
--       mn.X_LAST_BUN,
--       mn.X_LAST_CREATININE,
--       mn.X_LAST_CO2,
--       mn.X_LAST_BILIRUBIN,
--       mn.X_LAST_ALBUMIN,
--       mn.X_LAST_ALT,
--       mn.X_LAST_AST,
--       mn.X_LAST_ALKPHOS,
--       mn.X_LAST_CRP,
--       mn.X_LAST_SED_RATE,
--       mn.X_LAST_LIPASE,
--       mn.X_LAST_CA199,
--       mn.X_LAST_AFP,
--       mn.X_LAST_CEA,
--       mn.X_LAST_INR,
--       mn.X_LAST_PTT,
--       mn.X_LAST_FIBRINOGEN,
--       mn.X_LAST_LACTIC_ACID FROM #main mn
--	   WHERE mn.event_type = 'Readmission'
--	   UNION ALL 
--	   SELECT dsc.Person_Id
--	      , dsc.event_count
--            , dsc.event_type
--            , dsc.event_date
         
--            , dsc.person_name
--            , dsc.sk_Fact_Pt_Enc_Clrt
--            , dsc.w_service_line_id
--            , dsc.w_service_line_name
--            , dsc.[Service Line by Location]
--            , dsc.[Service line ID of discharge attending]
--            , dsc.[Service line of discharge attending]
--            , dsc.w_hs_area_name
--            , dsc.fyear_num
--            , dsc.fmonth_num
--            , dsc.Discharge_Attending_Division
--            , dsc.Discharge_Attending_SubDivision
--            , dsc.Discharging_Unit_Name
--            , dsc.epic_department_id
--            , dsc.epic_department_name
--            , dsc.provider_id
--            , dsc.provider_name
--            , dsc.PCP
--            , dsc.Gender
--            , dsc.PAT_AGE_YEARS_AT_ADMISSION
--            , dsc.Pat_Ethnicity
--            , dsc.Pat_Race
--            , dsc.PAT_POSTAL_CODE
--            , dsc.Patient_Class
--            , dsc.readm_fmonth_num
--            , dsc.readm_fyear_name
--            , dsc.readm_fyear_num
--            , dsc.readm_hs_area_name
--            , dsc.readm_epic_department_name_external
--            , dsc.readmission_service_line_loc
--            , dsc.readmission_service_line
--            , dsc.Readmission_Unit_Name
--            , dsc.readmission_admission_adt_pt_cls
--            , dsc.Discharge_Dx
--            , dsc.Discharge_Dx_Name
--            , dsc.Readmission_Dx
--            , dsc.Readmission_Dx_Name
--            , dsc.next_sk_Fact_Pt_Enc_Clrt
--            , dsc.Planned_Readmission
--            , dsc.index_admission_event_date
--            , dsc.index_discharge_event_date
--            , dsc.readmission_admission_event_date
--            , dsc.readmission_discharge_event_date
--            , dsc.index_admission_ADM_SOURCE
--            , dsc.index_admission_HOSP_ADMSN_TYPE
--            , dsc.index_admission_HOSP_ADMSN_STATUS
--            , dsc.readmission_admission_ADM_SOURCE
--            , dsc.readmission_admission_HOSP_ADMSN_TYPE
--            , dsc.readmission_admission_HOSP_ADMSN_STATUS
--            , dsc.readmission_provider_id
--            , dsc.readmission_provider_name
--            , dsc.Hospital_Service
--            , dsc.[Financial Class]
--            , dsc.Primary_Payor_Name
--            , dsc.LOS
--            , dsc.ICU_Pt_Days
--            , dsc.MOST_RECENT_BMI
--            , dsc.MOST_RECENT_SYSTOLIC
--            , dsc.MOST_RECENT_DIASTOLIC
--            , dsc.PRIMARY_OR_PROCEDURE
--            , dsc.Inpatient_Admits
--            , dsc.Outpatient_Admits
--            , dsc.Num_ED_Admits
--            , dsc.Num_HomeHealth_Visits
--            , dsc.Num_NoShow_Visits
--            , dsc.[Follow-up Visits]
--            , dsc.Last_Outpatient_Contact_Date
--            , dsc.DRG_Cde
--            , dsc.DRG_Dscr
--            , dsc.ADMISSION_DX_CODE_LIST
--            , dsc.PRINCIPAL_PROBLEM_DX_CODE_LIST
--            , dsc.AcctNbr_int
--            , dsc.Tot_Cst
--            , dsc.tot_chg_amt
--            , dsc.ICU_Admits
--            , dsc.Internal_Transfers
--            , dsc.Attending_Physician
--            , dsc.Number_of_Attending
--            , dsc.PRESENT_ON_ADMSN_DX_CODE_LIST
--            , dsc.COMPLICATIONSFLAG
--            , dsc.HOSPITAL_ACQUIRED_DX_CODE_LIST
--            , dsc.NUM_ACTIVE_MEDICATION_ORDERS
--            , dsc.NUM_DISCHARGE_RX
--            , dsc.X_ACTIVE_ALLERGY_COUNT
--            , dsc.Infections
--            , dsc.aria_score
--            , dsc.Elixhauser_Score
--            , dsc.Charlson_Score
--            , dsc.ADULT_PALLIATIVE_CARE_REGISTRY_UVA
--            , dsc.MEMBER_OF_DIABETES_REGISTRY
--            , dsc.MEMBER_OF_OBESITY_REGISTRY
--            , dsc.X_MBR_CANC_RGSTRY_YN
--            , dsc.MEMBER_OF_COPD_REGISTRY
--            , dsc.MEMBER_OF_CHF_REGISTRY
--            , dsc.MEMBER_OF_CAD_REGISTRY
--            , dsc.X_FIRST_HB1AC
--            , dsc.X_IP_FIRST_WBC
--            , dsc.X_FIRST_HEMATOCRIT
--            , dsc.X_FIRST_MCV
--            , dsc.X_FIRST_PLATELET
--            , dsc.X_FIRST_GLUCOSE
--            , dsc.X_FIRST_SODIUM
--            , dsc.X_FIRST_POTASSIUM
--            , dsc.X_FIRST_BUN
--            , dsc.X_FIRST_CREATININE
--            , dsc.X_FIRST_CO2
--            , dsc.X_FIRST_BILIRUBIN
--            , dsc.X_FIRST_ALBUMIN
--            , dsc.X_FIRST_ALT
--            , dsc.X_FIRST_AST
--            , dsc.X_FIRST_ALKPHOS
--            , dsc.X_FIRST_CRP
--            , dsc.X_FIRST_SED_RATE
--            , dsc.X_FIRST_LIPASE
--            , dsc.X_FIRST_CA199
--            , dsc.X_FIRST_AFP
--            , dsc.X_FIRST_CEA
--            , dsc.X_FIRST_INR
--            , dsc.X_FIRST_PTT
--            , dsc.X_FIRST_FIBRINOGEN
--            , dsc.X_FIRST_LACTIC_ACID
--            , dsc.X_LAST_HB1AC
--            , dsc.X_IP_LAST_WBC
--            , dsc.X_LAST_MCV
--            , dsc.X_LAST_PLATELET
--            , dsc.X_LAST_GLUCOSE
--            , dsc.X_LAST_SODIUM
--            , dsc.X_LAST_POTASSIUM
--            , dsc.X_LAST_BUN
--            , dsc.X_LAST_CREATININE
--            , dsc.X_LAST_CO2
--            , dsc.X_LAST_BILIRUBIN
--            , dsc.X_LAST_ALBUMIN
--            , dsc.X_LAST_ALT
--            , dsc.X_LAST_AST
--            , dsc.X_LAST_ALKPHOS
--            , dsc.X_LAST_CRP
--            , dsc.X_LAST_SED_RATE
--            , dsc.X_LAST_LIPASE
--            , dsc.X_LAST_CA199
--            , dsc.X_LAST_AFP
--            , dsc.X_LAST_CEA
--            , dsc.X_LAST_INR
--            , dsc.X_LAST_PTT
--            , dsc.X_LAST_FIBRINOGEN
--            , dsc.X_LAST_LACTIC_ACID FROM #main dsc WHERE dsc.event_type = 'Discharge'
--			AND dsc.event_count = 1
--			AND dsc.sk_Fact_Pt_Enc_Clrt NOT IN (
--	  SELECT DISTINCT t.sk_Fact_Pt_Enc_Clrt FROM ( SELECT ROW_NUMBER() OVER(PARTITION BY ds.sk_Fact_Pt_Enc_Clrt ORDER BY ds.event_type)rn ,ds.Person_Id,
--              ds.event_type,
--              ds.event_date,
--              ds.person_name,
--              ds.sk_Fact_Pt_Enc_Clrt,
--              ds.w_service_line_id,
--              ds.w_service_line_name,
--              ds.[Service Line by Location],
--              ds.[Service line ID of discharge attending],
--              ds.[Service line of discharge attending],
--              ds.w_hs_area_name,
--              ds.fyear_num,
--              ds.fmonth_num,
--              ds.Discharge_Attending_Division,
--              ds.Discharge_Attending_SubDivision,
--              ds.Discharging_Unit_Name,
--              ds.epic_department_id,
--              ds.epic_department_name,
--              ds.provider_id,
--              ds.provider_name,
--              ds.PCP,
--              ds.Gender,
--              ds.PAT_AGE_YEARS_AT_ADMISSION,
--              ds.Pat_Ethnicity,
--              ds.Pat_Race,
--              ds.PAT_POSTAL_CODE,
--              ds.Patient_Class,
--              ds.readm_fmonth_num,
--              ds.readm_fyear_name,
--              ds.readm_fyear_num,
--              ds.readm_hs_area_name,
--              ds.readm_epic_department_name_external,
--              ds.readmission_service_line_loc,
--              ds.readmission_service_line,
--              ds.Readmission_Unit_Name,
--              ds.readmission_admission_adt_pt_cls,
--              ds.Discharge_Dx,
--              ds.Discharge_Dx_Name,
--              ds.Readmission_Dx,
--              ds.Readmission_Dx_Name,
--              ds.next_sk_Fact_Pt_Enc_Clrt,
--              ds.Planned_Readmission,
--              ds.index_admission_event_date,
--              ds.index_discharge_event_date,
--              ds.readmission_admission_event_date,
--              ds.readmission_discharge_event_date,
--              ds.index_admission_ADM_SOURCE,
--              ds.index_admission_HOSP_ADMSN_TYPE,
--              ds.index_admission_HOSP_ADMSN_STATUS,
--              ds.readmission_admission_ADM_SOURCE,
--              ds.readmission_admission_HOSP_ADMSN_TYPE,
--              ds.readmission_admission_HOSP_ADMSN_STATUS,
--              ds.readmission_provider_id,
--              ds.readmission_provider_name,
--              ds.Hospital_Service,
--              ds.[Financial Class],
--              ds.Primary_Payor_Name,
--              ds.LOS,
--              ds.ICU_Pt_Days,
--              ds.MOST_RECENT_BMI,
--              ds.MOST_RECENT_SYSTOLIC,
--              ds.MOST_RECENT_DIASTOLIC,
--              ds.PRIMARY_OR_PROCEDURE,
--              ds.Inpatient_Admits,
--              ds.Outpatient_Admits,
--              ds.Num_ED_Admits,
--              ds.Num_HomeHealth_Visits,
--              ds.Num_NoShow_Visits,
--              ds.[Follow-up Visits],
--              ds.Last_Outpatient_Contact_Date,
--              ds.DRG_Cde,
--              ds.DRG_Dscr,
--              ds.ADMISSION_DX_CODE_LIST,
--              ds.PRINCIPAL_PROBLEM_DX_CODE_LIST,
--              ds.AcctNbr_int,
--              ds.Tot_Cst,
--              ds.tot_chg_amt,
--              ds.ICU_Admits,
--              ds.Internal_Transfers,
--              ds.Attending_Physician,
--              ds.Number_of_Attending,
--              ds.PRESENT_ON_ADMSN_DX_CODE_LIST,
--              ds.COMPLICATIONSFLAG,
--              ds.HOSPITAL_ACQUIRED_DX_CODE_LIST,
--              ds.NUM_ACTIVE_MEDICATION_ORDERS,
--              ds.NUM_DISCHARGE_RX,
--              ds.X_ACTIVE_ALLERGY_COUNT,
--              ds.Infections,
--              ds.aria_score,
--              ds.Elixhauser_Score,
--              ds.Charlson_Score,
--              ds.ADULT_PALLIATIVE_CARE_REGISTRY_UVA,
--              ds.MEMBER_OF_DIABETES_REGISTRY,
--              ds.MEMBER_OF_OBESITY_REGISTRY,
--              ds.X_MBR_CANC_RGSTRY_YN,
--              ds.MEMBER_OF_COPD_REGISTRY,
--              ds.MEMBER_OF_CHF_REGISTRY,
--              ds.MEMBER_OF_CAD_REGISTRY,
--              ds.X_FIRST_HB1AC,
--              ds.X_IP_FIRST_WBC,
--              ds.X_FIRST_HEMATOCRIT,
--              ds.X_FIRST_MCV,
--              ds.X_FIRST_PLATELET,
--              ds.X_FIRST_GLUCOSE,
--              ds.X_FIRST_SODIUM,
--              ds.X_FIRST_POTASSIUM,
--              ds.X_FIRST_BUN,
--              ds.X_FIRST_CREATININE,
--              ds.X_FIRST_CO2,
--              ds.X_FIRST_BILIRUBIN,
--              ds.X_FIRST_ALBUMIN,
--              ds.X_FIRST_ALT,
--              ds.X_FIRST_AST,
--              ds.X_FIRST_ALKPHOS,
--              ds.X_FIRST_CRP,
--              ds.X_FIRST_SED_RATE,
--              ds.X_FIRST_LIPASE,
--              ds.X_FIRST_CA199,
--              ds.X_FIRST_AFP,
--              ds.X_FIRST_CEA,
--              ds.X_FIRST_INR,
--              ds.X_FIRST_PTT,
--              ds.X_FIRST_FIBRINOGEN,
--              ds.X_FIRST_LACTIC_ACID,
--              ds.X_LAST_HB1AC,
--              ds.X_IP_LAST_WBC,
--              ds.X_LAST_MCV,
--              ds.X_LAST_PLATELET,
--              ds.X_LAST_GLUCOSE,
--              ds.X_LAST_SODIUM,
--              ds.X_LAST_POTASSIUM,
--              ds.X_LAST_BUN,
--              ds.X_LAST_CREATININE,
--              ds.X_LAST_CO2,
--              ds.X_LAST_BILIRUBIN,
--              ds.X_LAST_ALBUMIN,
--              ds.X_LAST_ALT,
--              ds.X_LAST_AST,
--              ds.X_LAST_ALKPHOS,
--              ds.X_LAST_CRP,
--              ds.X_LAST_SED_RATE,
--              ds.X_LAST_LIPASE,
--              ds.X_LAST_CA199,
--              ds.X_LAST_AFP,
--              ds.X_LAST_CEA,
--              ds.X_LAST_INR,
--              ds.X_LAST_PTT,
--              ds.X_LAST_FIBRINOGEN,
--              ds.X_LAST_LACTIC_ACID FROM #main ds
--	   WHERE 1=1) t WHERE t.rn >1
--	   )) fin
--	   WHERE fin.event_type = CASE WHEN @Discharges_yn = 0 THEN 'Readmission' ELSE fin.event_type END 

	   --ORDER BY fin.sk_Fact_Pt_Enc_Clrt
GO


