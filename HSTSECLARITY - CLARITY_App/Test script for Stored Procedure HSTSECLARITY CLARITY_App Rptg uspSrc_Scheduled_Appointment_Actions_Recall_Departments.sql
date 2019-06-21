USE [CLARITY_App]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--CREATE TYPE PodsServiceLineType AS TABLE
--( pod_Service_Line VARCHAR(150) PRIMARY KEY);
--GO

DECLARE @StartDate SMALLDATETIME,
        @EndDate SMALLDATETIME,
		@DepartmentGrouperColumn VARCHAR(12),
		@DepartmentGrouperNoValue VARCHAR(25),
		@SelectString NVARCHAR(1000),
		@ParmDefinition NVARCHAR(500),
        --@in_servLine VARCHAR(MAX),
        @in_pods_servLine VARCHAR(MAX)--,
     --   @in_deps VARCHAR(MAX),
     --   @in_depid VARCHAR(MAX),
	    --@in_pods VARCHAR(MAX),
	    --@in_podid VARCHAR(MAX)--,
	    --@in_hubs VARCHAR(MAX),
	    --@in_hubid VARCHAR(MAX),
	    --@in_somdeps VARCHAR(MAX),
	    --@in_somdepid VARCHAR(MAX),
	    --@in_somdivs VARCHAR(MAX),
	    --@in_somdivid VARCHAR(MAX)

--SET @StartDate = '2/1/2019 00:00 AM'
--SET @StartDate = '2/28/2019 00:00 AM'
SET @StartDate = '1/1/2017 00:00 AM'
SET @EndDate = '1/1/2031 00:00 AM'
--SET @StartDate = '4/24/2019 00:00 AM'
--SET @EndDate = '5/23/2019 11:59 PM'

SET @DepartmentGrouperColumn = 'service_line'
--SET @DepartmentGrouperColumn = 'pod_name'

SET @DepartmentGrouperNoValue = '(No Service Line Defined)'
--SET @DepartmentGrouperNoValue = '(No Pod Defined)'

DECLARE @locstartdate SMALLDATETIME,
        @locenddate SMALLDATETIME

SET @locstartdate = @StartDate
SET @locenddate   = @EndDate

SET NOCOUNT ON
/*
DECLARE @ServiceLine TABLE (ServiceLineId SMALLINT)

INSERT INTO @ServiceLine
(
    ServiceLineId
)
VALUES
--(1),--Digestive Health
--(2),--Heart and Vascular
--(3),--Medical Subspecialties
--(4),--Musculoskeletal
--(5),--Neurosciences and Behavioral Health
--(6),--Oncology
--(7),--Ophthalmology
--(8),--Primary Care
--(9),--Surgical Subspecialties
--(10),--Transplant
--(11) --Womens and Childrens
(0)  --(All)
--(1) --Digestive Health
--(1),--Digestive Health
--(2) --Heart and Vascular
*/
DECLARE @ServiceLine TABLE (ServiceLineName VARCHAR(150))

INSERT INTO @ServiceLine
(
    ServiceLineName
)
VALUES
--('(No Service Line Defined)'),
--('Digestive Health'),
--('Heart and Vascular'),
--('Medical Subspecialties'),
--('Musculoskeletal'),
--('Neurosciences and Behavioral Health'),
--('Oncology'),
--('Ophthalmology'),
--('Primary Care'),
--('Surgical Subspecialties'),
--('Transplant'),
--('Womens and Childrens')
('(No Service Line Defined)')
--('Medical Subspecialties')
--('Digestive Health')
--('Womens and Childrens')
;

SELECT @in_pods_servLine = COALESCE(@in_pods_servLine+',' ,'') + CAST(ServiceLineName AS VARCHAR(MAX))
FROM @ServiceLine

--SELECT @in_pods_servLine
/*
DECLARE @Pod TABLE (PodId VARCHAR(100))

INSERT INTO @Pod
(
    PodId
)
VALUES
--('1'),--Cancer
--('2'),--Musculoskeletal
--('3'),--Primary Care
--('4'),--Surgical Procedural Specialties
--('5'),--Transplant
--('6'),--Medical Specialties
--('7'),--Radiology
--('8'),--Heart and Vascular Center
--('9'),--Neurosciences and Psychiatry
--('10'),--Women's and Children's
--('12'),--CPG
--('13'),--UVA Community Cancer POD
--('14'),--Digestive Health
--('15'),--Ophthalmology
--('16') --Community Medicine
('0') --(All)
--('1') --Cancer
--('1'), --Cancer
--('10') --Women's and Children's
;
*/
/*
DECLARE @Pod TABLE (PodName VARCHAR(100))

INSERT INTO @Pod
(
    PodName
)
VALUES
--('(No Pod Defined)'),
--('Cancer'),
--('Musculoskeletal'),
--('Primary Care'),
--('Surgical Procedural Specialties'),
--('Transplant'),
--('Medical Specialties'),
--('Radiology'),
--('Heart and Vascular Center'),
--('Neurosciences and Psychiatry'),
--('Women''s and Children''s'),
--('CPG'),
--('UVA Community Cancer POD'),
--('Digestive Health'),
--('Ophthalmology'),
--('Community Medicine')
--('Medical Specialties')
('Digestive Health')
;

SELECT @in_pods_servLine = COALESCE(@in_pods_servLine+',' ,'') + CAST(PodName AS VARCHAR(MAX))
FROM @Pod

--SELECT @in_pods_servLine
*/
-- =========================================================
-- Author:		Tom Burgan
-- Create date: 03/25/2019
-- Description:	No Show Rate Data Portal SSRS export script
-- =========================================================
--------------------------------------------------------------------------------------------------------------------------
--MODS: 	
--         03/25/2019 - Tom		-- create stored procedure
--         03/27/2019 - Tom     -- use w_service_line_id, w_opnl_service_id for service line parameter
--         04/05/2019 - TMB     -- add APPT_MADE_DTTM, BUSINESS_UNIT, Prov_Typ, and new wrapper columns to extract
--         04/18/2019 - TMB     -- add logic for SOM Department and SOM Division report parameters
--************************************************************************************************************************
--ALTER PROCEDURE [Rptg].[uspSrc_AmbOpt_NoShowRate_SSRS_Download]
--    @StartDate SMALLDATETIME,
--    @EndDate SMALLDATETIME,
--    @in_servLine VARCHAR(MAX),
--    @in_deps VARCHAR(MAX),
--    @in_depid VARCHAR(MAX),
--	@in_pods VARCHAR(MAX),
--	@in_podid VARCHAR(MAX),
--	@in_hubs VARCHAR(MAX),
--	@in_hubid VARCHAR(MAX),
--    @in_somdeps VARCHAR(MAX),
--	@in_somdepid VARCHAR(MAX),
--	@in_somdivs VARCHAR(MAX),
--	@in_somdivid VARCHAR(MAX)
--AS
--DECLARE @tab_pods_servLine TABLE
--(
--    pod_Service_Line VARCHAR(150)
--);

--DECLARE @tab_pods_servLine PodsServiceLineType;

--INSERT INTO @tab_pods_servLine
--SELECT Param
--FROM ETL.fn_ParmParse(@in_pods_servLine, ',');

-- Build the SELECT statement.
--SET @SelectString = N'SELECT DISTINCT epic_department_id AS DEPARTMENT_ID, mdm.epic_department_name_external AS DEPARTMENT_NAME FROM CLARITY.[dbo].[CL_SSA] ssa INNER JOIN CLARITY.[dbo].[CL_SSA_PROV_DEPT] pd ON ssa.ACTION_ID = pd.ACTION_ID LEFT OUTER JOIN CLARITY.dbo.CLARITY_DEP dep ON dep.DEPARTMENT_ID = pd.DEP_ID LEFT OUTER JOIN Rptg.vwRef_MDM_Location_Master_EpicSvc mdm ON pd.DEP_ID = mdm.epic_department_id WHERE 1=1 AND (ssa.RECALL_DT >= @RecallStartDate AND ssa.RECALL_DT <= @RecallEndDate)';
--SET @SelectString = N'SELECT DISTINCT epic_department_id AS DEPARTMENT_ID, mdm.epic_department_name_external AS DEPARTMENT_NAME FROM CLARITY.[dbo].[CL_SSA] ssa INNER JOIN CLARITY.[dbo].[CL_SSA_PROV_DEPT] pd ON ssa.ACTION_ID = pd.ACTION_ID LEFT OUTER JOIN CLARITY.dbo.CLARITY_DEP dep ON dep.DEPARTMENT_ID = pd.DEP_ID LEFT OUTER JOIN Rptg.vwRef_MDM_Location_Master_EpicSvc mdm ON pd.DEP_ID = mdm.epic_department_id WHERE 1=1 AND (ssa.RECALL_DT >= @RecallStartDate AND ssa.RECALL_DT <= @RecallEndDate) AND COALESCE(' + @DepartmentGrouperColumn + ',''' + @DepartmentGrouperNoValue + ''') IN (SELECT pod_Service_Line FROM (@PodServiceLine)) ORDER BY DEPARTMENT_NAME';
SET @SelectString = N';WITH cte_pods_servLine (pod_Service_Line) AS (SELECT Param FROM ETL.fn_ParmParse(@PodServiceLine, '','')) SELECT DISTINCT mdm.epic_department_id AS DEPARTMENT_ID, mdm.epic_department_name_external AS DEPARTMENT_NAME FROM CLARITY.[dbo].[CL_SSA] ssa INNER JOIN CLARITY.[dbo].[CL_SSA_PROV_DEPT] pd ON ssa.ACTION_ID = pd.ACTION_ID LEFT OUTER JOIN CLARITY.dbo.CLARITY_DEP dep ON dep.DEPARTMENT_ID = pd.DEP_ID LEFT OUTER JOIN Rptg.vwRef_MDM_Location_Master_EpicSvc mdm ON pd.DEP_ID = mdm.epic_department_id WHERE 1=1 AND mdm.epic_department_id IS NOT NULL AND (ssa.RECALL_DT >= @RecallStartDate AND ssa.RECALL_DT <= @RecallEndDate) AND COALESCE(' + @DepartmentGrouperColumn + ',''' + @DepartmentGrouperNoValue + ''') IN (SELECT pod_Service_Line FROM cte_pods_servLine) ORDER BY DEPARTMENT_NAME';
--SET @ParmDefinition = N'@RecallStartDate SMALLDATETIME, @RecallEndDate SMALLDATETIME, @PodServiceLine TABLE';
--SET @ParmDefinition = N'@RecallStartDate SMALLDATETIME, @RecallEndDate SMALLDATETIME, @PodServiceLine PodsServiceLineType';
SET @ParmDefinition = N'@RecallStartDate SMALLDATETIME, @RecallEndDate SMALLDATETIME, @PodServiceLine VARCHAR(MAX)';
--SELECT @locstartdate, @locenddate, @SelectString, @ParmDefinition
--EXECUTE sp_executesql @SelectString, @ParmDefinition, @RecallStartDate=@locstartdate, @RecallEndDate=@locenddate, @PodServiceLine=@tab_pods_servLine;
EXECUTE sp_executesql @SelectString, @ParmDefinition, @RecallStartDate=@locstartdate, @RecallEndDate=@locenddate, @PodServiceLine=@in_pods_servLine;
/*
       /* Build the name of the table. */  
       SUBSTRING( DATENAME(mm, @PrmOrderDate), 1, 3) +  
       CAST(DATEPART(yy, @PrmOrderDate) AS CHAR(4) ) +  
       'Sales' +  
       /* Build a VALUES clause. */  
       ' VALUES (@InsOrderID, @InsCustID, @InsOrdDate,' +  
       ' @InsOrdMonth, @InsDelDate)'
*/
/*
SELECT DISTINCT
	   epic_department_id AS DEPARTMENT_ID,
	   mdm.epic_department_name_external AS DEPARTMENT_NAME
FROM CLARITY.[dbo].[CL_SSA] ssa
INNER JOIN CLARITY.[dbo].[CL_SSA_PROV_DEPT] pd
ON ssa.ACTION_ID = pd.ACTION_ID
LEFT OUTER JOIN CLARITY.dbo.CLARITY_DEP dep
ON dep.DEPARTMENT_ID = pd.DEP_ID
LEFT OUTER JOIN Rptg.vwRef_MDM_Location_Master_EpicSvc mdm
ON pd.DEP_ID = mdm.epic_department_id
WHERE 1=1
AND (ssa.RECALL_DT >= @locstartdate
     AND ssa.RECALL_DT <= @locenddate)
WHERE 1=1 AND COALESCE(" & Parameters!DepartmentGrouperColumn.Value & ",'" & Parameters!DepartmentGrouperNoValue.Value & "') IN (@PodServiceLine) ORDER BY dep.Clrt_DEPt_Nme;
(COALESCE(evnts.service_line_id, evnts.opnl_service_id) IN (SELECT Service_Line_Id FROM @tab_servLine))
SELECT
       event_date,
       event_type, -- 'Appointment'
	   event_category, -- NULL
       event_count, -- 1
       fyear_num,
       Load_Dtm,
       hs_area_name,
       COALESCE(w_service_line_id, w_opnl_service_id, w_corp_service_line_id) service_line_id,
       COALESCE(w_service_line_name, w_opnl_service_name, w_corp_service_line_name) Service_Line,
	   w_pod_id,
	   w_pod_name,
	   w_hub_id,
	   w_hub_name,
       w_department_id,
       w_department_name,
       w_department_name_external,
       peds,
       transplant,
       person_id,
       provider_id,
	   enc.PAT_ENC_CSN_ID,
	   acct.AcctNbr_int,
	   CASE WHEN appt_event_Canceled = 0 OR appt_event_Canceled_Late = 1 OR (appt_event_Provider_Canceled = 1 AND Cancel_Lead_Days <= 45) THEN 1 ELSE 0 END AS [Appt],
	   CASE WHEN (appt_event_No_Show = 1 OR appt_event_Canceled_Late = 1) THEN 1 ELSE 0 END AS [No Show],
	   APPT_STATUS_FLAG,
	   APPT_DTTM,
	   CANCEL_REASON_C,
	   CANCEL_REASON_NAME,
	   CANCEL_INITIATOR,
	   CANCEL_LEAD_HOURS,
	   Cancel_Lead_Days,
	   APPT_CANC_DTTM,
	   APPT_MADE_DATE,
	   appt_event_No_Show,
	   appt_event_Canceled_Late,
	   appt_event_Scheduled,
	   appt_event_Provider_Canceled,
	   appt_event_Completed,
	   appt_event_Arrived,
	   PHONE_REM_STAT_NAME,
	   APPT_MADE_DTTM,
	   BUSINESS_UNIT,
	   Prov_Typ,
	   w_rev_location_id,
	   w_rev_location,
	   w_som_department_id,
	   w_som_department_name,
	   w_financial_division_id,
	   w_financial_division_name,
	   w_financial_sub_division_id,
	   w_financial_sub_division_name,
	   w_som_division_id,
	   w_som_division_name
FROM [DS_HSDM_App].[TabRptg].[Dash_AmbOpt_ScheduledAppointmentMetric_Tiles] tabrptg
LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwFact_Pt_Enc_Clrt enc
ON enc.sk_Fact_Pt_Enc_Clrt = tabrptg.sk_Fact_Pt_Enc_Clrt
LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwFact_Pt_Acct_Aggr acct
ON acct.sk_Fact_Pt_Acct = tabrptg.sk_Fact_Pt_Acct
WHERE 1 = 1
      AND event_date >= @StartDate
      AND event_date <= @EndDate
	  AND ((event_count = 1)
           AND (appt_event_Canceled = 0 OR appt_event_Canceled_Late = 1 OR (appt_event_Provider_Canceled = 1 AND Cancel_Lead_Days <= 45)))
      AND
      (
          0 IN
          (
              SELECT epic_department_id FROM @tab_deps
          )
          OR epic_department_id IN
             (
                 SELECT epic_department_id FROM @tab_deps
             )
      )
      AND
      (
          0 IN
          (
              SELECT epic_department_id FROM @tab_depid
          )
          OR epic_department_id IN
             (
                 SELECT epic_department_id FROM @tab_depid
             )
      )
      AND
      (
          0 IN
          (
              SELECT pod_id FROM @tab_pods
          )
          OR pod_id IN
             (
                 SELECT pod_id FROM @tab_pods
             )
      )
      AND
      (
          0 IN
          (
              SELECT pod_id FROM @tab_podid
          )
          OR pod_id IN
             (
                 SELECT pod_id FROM @tab_podid
             )
      )
      AND
      (
          0 IN
          (
              SELECT hub_id FROM @tab_hubs
          )
          OR hub_id IN
             (
                 SELECT hub_id FROM @tab_hubs
             )
      )
      AND
      (
          0 IN
          (
              SELECT hub_id FROM @tab_hubid
          )
          OR hub_id IN
             (
                 SELECT hub_id FROM @tab_hubid
             )
      )
      AND
      (
          0 IN
          (
              SELECT Service_Line_Id FROM @tab_servLine
          )
          OR COALESCE(w_service_line_id, w_opnl_service_id) IN
             (
                 SELECT Service_Line_Id FROM @tab_servLine
             )
      )
      AND
      (
          0 IN
          (
              SELECT som_department_id FROM @tab_somdeps
          )
          OR som_department_id IN
             (
                 SELECT som_department_id FROM @tab_somdeps
             )
      )
      AND
      (
          0 IN
          (
              SELECT som_department_id FROM @tab_somdepid
          )
          OR som_department_id IN
             (
                 SELECT som_department_id FROM @tab_somdepid
             )
      )
      AND
      (
          0 IN
          (
              SELECT som_division_id FROM @tab_somdivs
          )
          OR som_division_id IN
             (
                 SELECT som_division_id FROM @tab_somdivs
             )
      )
      AND
      (
          0 IN
          (
              SELECT som_division_id FROM @tab_somdivid
          )
          OR som_division_id IN
             (
                 SELECT som_division_id FROM @tab_somdivid
             )
      )--;

ORDER BY [No Show] DESC
--ORDER BY event_date
--ORDER BY w_hub_id
--       , epic_department_name_external
--       , event_date
*/
GO