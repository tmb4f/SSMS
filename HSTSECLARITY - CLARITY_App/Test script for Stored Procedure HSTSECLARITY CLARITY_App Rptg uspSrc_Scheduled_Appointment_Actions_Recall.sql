USE [CLARITY_App]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

DECLARE @StartDate SMALLDATETIME,
        @EndDate SMALLDATETIME,
		@DepartmentGrouperColumn VARCHAR(12),
		@DepartmentGrouperNoValue VARCHAR(25),
		@InsertIntoString NVARCHAR(1000),
		@SelectString NVARCHAR(4000),
		@ParmDefinition NVARCHAR(500),
        @in_pods_servLine VARCHAR(MAX),
        @in_depid VARCHAR(MAX)

--SET @StartDate = '1/1/2017 00:00 AM'
--SET @EndDate = '1/1/2031 00:00 AM'
SET @StartDate = '7/1/2020 00:00 AM'
SET @EndDate = '7/1/2021 00:00 AM'

SET @DepartmentGrouperColumn = 'service_line'
--SET @DepartmentGrouperColumn = 'pod_name'

SET @DepartmentGrouperNoValue = '(No Service Line Defined)'
--SET @DepartmentGrouperNoValue = '(No Pod Defined)'

--CREATE PROCEDURE [Rptg].[uspSrc_Scheduled_Appointment_Actions_Recall]
--       (
--        @StartDate SMALLDATETIME = NULL,
--        @EndDate SMALLDATETIME = NULL,
--		@DepartmentGrouperColumn VARCHAR(12),
--		@DepartmentGrouperNoValue VARCHAR(25),
--        @in_pods_servLine VARCHAR(MAX),
--        @in_depid VARCHAR(MAX)
--	   )
--AS
/****************************************************************************************************************************************
WHAT: Create procedure Rptg.uspSrc_Scheduled_Appointment_Actions_Recall
WHO : Tom Burgan
WHEN: 06/18/2019
WHY : Recall appointment action report
----------------------------------------------------------------------------------------------------------------------------------------
INFO:
      INPUTS:   CLARITY_App.ETL.fn_ParmParse
				CLARITY.dbo.CL_SSA
				CLARITY_App.Rptg.vwDim_Date
				CLARITY.dbo.PATIENT
				CLARITY.dbo.CL_SSA_RECALL_HX
				CLARITY.dbo.CLARITY_EMP
				CLARITY.dbo.CL_SSA_PROV_DEPT
				CLARITY.dbo.CLARITY_SER
				CLARITY.dbo.CLARITY_DEP
				CLARITY_App.Rptg.vwRef_MDM_Location_Master_EpicSvc

      OUTPUTS:
                CLARITY_App.Rptg.uspSrc_Scheduled_Appointment_Actions_Recall
----------------------------------------------------------------------------------------------------------------------------------------
MODS:     06/18/2019--TMB-- Create new stored procedure
*****************************************************************************************************************************************/

  SET NOCOUNT ON;

---------------------------------------------------
---Default recall date range is the current FY
  DECLARE @CurrDate SMALLDATETIME;

  SET @CurrDate = CAST(CAST(GETDATE() AS DATE) AS SMALLDATETIME);
    
  IF @StartDate IS NULL
      BEGIN
		SET @StartDate=CASE WHEN DATEPART(mm, @CurrDate)<7 
 	                        THEN CAST('07/01/'+CAST(DATEPART(yy, @CurrDate)-1 AS CHAR(4)) AS SMALLDATETIME)
                            ELSE CAST('07/01/'+CAST(DATEPART(yy, @CurrDate) AS CHAR(4)) AS SMALLDATETIME)
                       END;
	  END;

  IF @EndDate IS NULL
      BEGIN
		SET @EndDate=CASE WHEN DATEPART(mm, @CurrDate)<7 
 	                        THEN CAST('06/30/'+CAST(DATEPART(yy, @CurrDate) AS CHAR(4)) AS SMALLDATETIME)
                            ELSE CAST('06/30/'+CAST(DATEPART(yy, @CurrDate)+1 AS CHAR(4)) AS SMALLDATETIME)
                     END;
      END;
----------------------------------------------------

DECLARE @locstartdate SMALLDATETIME,
        @locenddate SMALLDATETIME

SET @locstartdate = @StartDate
SET @locenddate   = @EndDate

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
--('(No Service Line Defined)')
--('Medical Subspecialties')
--('Digestive Health')
('Womens and Childrens')
--('Ophthalmology')
;

SELECT @in_pods_servLine = COALESCE(@in_pods_servLine+',' ,'') + CAST(ServiceLineName AS VARCHAR(MAX))
FROM @ServiceLine

--SELECT @in_pods_servLine

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

--SELECT @in_pods_servLine = COALESCE(@in_pods_servLine+',' ,'') + CAST(PodName AS VARCHAR(MAX))
--FROM @Pod

--SELECT @in_pods_servLine

IF OBJECT_ID('tempdb..#RecallDepartment') IS NOT NULL DROP TABLE tempdb..#RecallDepartment

CREATE TABLE #RecallDepartment (DepartmentId NUMERIC(18,0))

SET @InsertIntoString = N';WITH cte_pods_servLine (pod_Service_Line) AS (SELECT Param FROM ETL.fn_ParmParse(@PodServiceLine, '','')) INSERT INTO #RecallDepartment SELECT DISTINCT mdm.epic_department_id AS DepartmentId FROM CLARITY.[dbo].[CL_SSA] ssa INNER JOIN CLARITY.[dbo].[CL_SSA_PROV_DEPT] pd ON ssa.ACTION_ID = pd.ACTION_ID LEFT OUTER JOIN CLARITY.dbo.CLARITY_DEP dep ON dep.DEPARTMENT_ID = pd.DEP_ID LEFT OUTER JOIN Rptg.vwRef_MDM_Location_Master_EpicSvc mdm ON pd.DEP_ID = mdm.epic_department_id WHERE 1=1 AND mdm.epic_department_id IS NOT NULL AND (ssa.RECALL_DT >= @RecallStartDate AND ssa.RECALL_DT <= @RecallEndDate) AND COALESCE(' + @DepartmentGrouperColumn + ',''' + @DepartmentGrouperNoValue + ''') IN (SELECT pod_Service_Line FROM cte_pods_servLine) ORDER BY DepartmentId';
SET @ParmDefinition = N'@RecallStartDate SMALLDATETIME, @RecallEndDate SMALLDATETIME, @PodServiceLine VARCHAR(MAX)';
EXECUTE sp_executesql @InsertIntoString, @ParmDefinition, @RecallStartDate=@locstartdate, @RecallEndDate=@locenddate, @PodServiceLine=@in_pods_servLine;

DECLARE @Department TABLE (DepartmentId NUMERIC(18,0))

INSERT INTO @Department
(
    DepartmentId
)
SELECT DepartmentId
FROM #RecallDepartment
WHERE DepartmentId IN
 (10354013 --	UVBB PEDS RHEUM CL
 ,10354014 --	UVBB PEDS GASTRO CL
 ,10354016 --	UVBB PEDS SURGERY CL
 ,10354017 --	UVBB PEDS GENETICS CL
 )
;

SELECT @in_depid = COALESCE(@in_depid+',' ,'') + CAST(DepartmentId AS VARCHAR(MAX))
FROM @Department

--SELECT @in_depid
/*
SET @SelectString = N';WITH cte_pods_servLine (pod_Service_Line) AS (SELECT Param FROM ETL.fn_ParmParse(@PodServiceLine, '','')) SELECT DISTINCT mdm.epic_department_id AS DEPARTMENT_ID, mdm.epic_department_name_external AS DEPARTMENT_NAME FROM CLARITY.[dbo].[CL_SSA] ssa INNER JOIN CLARITY.[dbo].[CL_SSA_PROV_DEPT] pd ON ssa.ACTION_ID = pd.ACTION_ID LEFT OUTER JOIN CLARITY.dbo.CLARITY_DEP dep ON dep.DEPARTMENT_ID = pd.DEP_ID LEFT OUTER JOIN Rptg.vwRef_MDM_Location_Master_EpicSvc mdm ON pd.DEP_ID = mdm.epic_department_id WHERE 1=1 AND mdm.epic_department_id IS NOT NULL AND (ssa.RECALL_DT >= @RecallStartDate AND ssa.RECALL_DT <= @RecallEndDate) AND COALESCE(' + @DepartmentGrouperColumn + ',''' + @DepartmentGrouperNoValue + ''') IN (SELECT pod_Service_Line FROM cte_pods_servLine) ORDER BY DEPARTMENT_NAME';
SET @ParmDefinition = N'@RecallStartDate SMALLDATETIME, @RecallEndDate SMALLDATETIME, @PodServiceLine VARCHAR(MAX)';
EXECUTE sp_executesql @SelectString, @ParmDefinition, @RecallStartDate=@locstartdate, @RecallEndDate=@locenddate, @PodServiceLine=@in_pods_servLine;
*/
SET @SelectString = N';WITH cte_pods_servLine (pod_Service_Line)
AS
(
SELECT Param FROM ETL.fn_ParmParse(@PodServiceLine, '','')
)
,cte_depid (DepartmentId)
AS
(
SELECT Param FROM ETL.fn_ParmParse(@DepartmentId, '','')
)
SELECT CAST(''Recall Action'' AS VARCHAR(50)) AS event_type,
       1 AS event_count,
	   evnts.RECALL_DT AS event_date,
       evnts.fmonth_num,
       evnts.Fyear_num,
       evnts.FYear_name,
       CAST(LEFT(DATENAME(MM, evnts.day_date), 3) + '' '' + CAST(DAY(evnts.day_date) AS VARCHAR(2)) AS VARCHAR(10)) AS report_period,
       CAST(CAST(evnts.day_date AS DATE) AS SMALLDATETIME) AS report_date,
       evnts.POD_ID AS pod_id,
       evnts.PFA_POD AS pod_name,
       evnts.DEP_ID AS epic_department_id,
       evnts.epic_department_name,
       evnts.epic_department_name_external,
       CAST(evnts.PAT_MRN_ID AS INTEGER) AS person_id,
       evnts.PAT_NAME AS person_name,
       evnts.PROV_ID AS provider_id,
       evnts.PROV_NAME AS provider_name,
       evnts.service_line_id,
       evnts.service_line,
	   evnts.ACTION_ID,
	   evnts.RECALL_EXPIRE_DT,
	   evnts.RECALL_NOTIF_DATE,
	   evnts.REC_STAT_HX_INST,
	   evnts.REC_STAT_HX_EMP_NAME,
	   evnts.LINE

FROM
(
	SELECT ssa.[ACTION_ID]
		  ,ssa.[PAT_ID]
		  ,ssa.[RECALL_EXPIRE_DT]
		  ,ssa.[RECALL_NOTIF_DATE]
		  ,ssa.RECALL_DT
		  ,date_dim.day_date
		  ,date_dim.fmonth_num
		  ,date_dim.Fyear_num
		  ,date_dim.FYear_name
		  ,pat.PAT_NAME
		  ,pat.PAT_MRN_ID
		  ,ssahx.REC_STAT_HX_INST
		  ,ssahx.REC_STAT_HX_EMP_NAME
		  ,ssapd.LINE
		  ,ssapd.PROV_ID
		  ,ssapd.PROV_NAME
		  ,ssapd.DEP_ID
		  ,mdm.epic_department_name
		  ,mdm.epic_department_name_external
		  ,mdm.service_line_id
		  ,mdm.service_line
		  ,mdm.POD_ID
		  ,mdm.PFA_POD
    FROM CLARITY.[dbo].[CL_SSA] ssa
    LEFT OUTER JOIN
    (
	    SELECT day_date,
               fmonth_num,
               Fyear_num,
               FYear_name
        FROM Rptg.vwDim_Date
    ) date_dim
	ON (date_dim.day_date = CAST(ssa.RECALL_DT AS SMALLDATETIME))
    LEFT OUTER JOIN CLARITY.dbo.PATIENT pat
    ON pat.PAT_ID = ssa.PAT_ID
	LEFT OUTER JOIN
	(   SELECT hx.[ACTION_ID]
              ,hx.[REC_STAT_HX_INST]
              ,hx.[REC_STAT_HX_EMP_ID]
	          ,emp.NAME AS [REC_STAT_HX_EMP_NAME]
        FROM CLARITY.[dbo].[CL_SSA_RECALL_HX] hx
        LEFT OUTER JOIN CLARITY.dbo.CLARITY_EMP emp
        ON emp.USER_ID = hx.REC_STAT_HX_EMP_ID
	    WHERE hx.RECALL_STAT_HX_C = 10
	) ssahx
	ON ssahx.ACTION_ID = ssa.ACTION_ID
	LEFT OUTER JOIN
	(
	    SELECT pd.[ACTION_ID]
              ,pd.[LINE]
	          ,pd.PROV_ID
	          ,ser.PROV_NAME
	          ,pd.DEP_ID
        FROM CLARITY.[dbo].[CL_SSA_PROV_DEPT] pd
        LEFT OUTER JOIN CLARITY.dbo.CLARITY_SER ser
        ON ser.PROV_ID = pd.PROV_ID
        LEFT OUTER JOIN CLARITY.dbo.CLARITY_DEP dep
        ON dep.DEPARTMENT_ID = pd.DEP_ID
        WHERE pd.LINE = 1
        OR (pd.LINE > 1 AND pd.PROV_ID IS NOT NULL)
    ) ssapd
    ON ssapd.ACTION_ID = ssa.ACTION_ID
    LEFT OUTER JOIN Rptg.vwRef_MDM_Location_Master_EpicSvc mdm
    ON ssapd.DEP_ID = mdm.epic_department_id
) evnts

WHERE (evnts.RECALL_DT >= @RecallStartDate
AND evnts.RECALL_DT <= @RecallEndDate) AND (COALESCE(' + @DepartmentGrouperColumn + ',''' + @DepartmentGrouperNoValue + ''') IN (SELECT pod_Service_Line FROM cte_pods_servLine)) AND (evnts.DEP_ID IN (SELECT DepartmentId FROM cte_depid))
ORDER BY evnts.DEP_ID, evnts.RECALL_DT';
SET @ParmDefinition = N'@RecallStartDate SMALLDATETIME, @RecallEndDate SMALLDATETIME, @PodServiceLine VARCHAR(MAX), @DepartmentId VARCHAR(MAX)';
EXECUTE sp_executesql @SelectString, @ParmDefinition, @RecallStartDate=@locstartdate, @RecallEndDate=@locenddate, @PodServiceLine=@in_pods_servLine, @DepartmentId=@in_depid;
/*
SELECT CAST('Recall Action' AS VARCHAR(50)) AS event_type,
       1 AS event_count,
       --evnts.day_date AS event_date,
	   evnts.RECALL_DT AS event_date,
       evnts.fmonth_num,
       evnts.Fyear_num,
       evnts.FYear_name,
       CAST(LEFT(DATENAME(MM, evnts.day_date), 3) + ' ' + CAST(DAY(evnts.day_date) AS VARCHAR(2)) AS VARCHAR(10)) AS report_period,
       CAST(CAST(evnts.day_date AS DATE) AS SMALLDATETIME) AS report_date,
       evnts.POD_ID AS pod_id,
       evnts.PFA_POD AS pod_name,
       evnts.DEP_ID AS epic_department_id,
       evnts.epic_department_name,
       evnts.epic_department_name_external,
       CAST(evnts.PAT_MRN_ID AS INTEGER) AS person_id,
       evnts.PAT_NAME AS person_name,
       evnts.PROV_ID AS provider_id,
       evnts.PROV_NAME AS provider_name,
       evnts.service_line_id,
       evnts.service_line,
	   evnts.ACTION_ID,
	   evnts.RECALL_EXPIRE_DT,
	   evnts.RECALL_NOTIF_DATE,
	   evnts.REC_STAT_HX_INST,
	   evnts.REC_STAT_HX_EMP_NAME,
	   evnts.LINE

FROM
(
	SELECT ssa.[ACTION_ID]
		  ,ssa.[PAT_ID]
		  ,ssa.[RECALL_EXPIRE_DT]
		  ,ssa.[RECALL_NOTIF_DATE]
		  ,ssa.RECALL_DT
		  ,date_dim.day_date
		  ,date_dim.fmonth_num
		  ,date_dim.Fyear_num
		  ,date_dim.FYear_name
		  ,pat.PAT_NAME
		  ,pat.PAT_MRN_ID
		  ,ssahx.REC_STAT_HX_INST
		  ,ssahx.REC_STAT_HX_EMP_NAME
		  ,ssapd.LINE
		  ,ssapd.PROV_ID
		  ,ssapd.PROV_NAME
		  ,ssapd.DEP_ID
		  ,mdm.epic_department_name
		  ,mdm.epic_department_name_external
		  ,mdm.service_line_id
		  ,mdm.service_line
		  ,mdm.POD_ID
		  ,mdm.PFA_POD
    FROM CLARITY.[dbo].[CL_SSA] ssa
    LEFT OUTER JOIN
    (
	    SELECT day_date,
               fmonth_num,
               Fyear_num,
               FYear_name
        FROM Rptg.vwDim_Date
    ) date_dim
	ON (date_dim.day_date = CAST(ssa.RECALL_DT AS SMALLDATETIME))
    LEFT OUTER JOIN CLARITY.dbo.PATIENT pat
    ON pat.PAT_ID = ssa.PAT_ID
	LEFT OUTER JOIN
	(   SELECT hx.[ACTION_ID]
              ,hx.[REC_STAT_HX_INST]
              ,hx.[REC_STAT_HX_EMP_ID]
	          ,emp.NAME AS [REC_STAT_HX_EMP_NAME]
        FROM CLARITY.[dbo].[CL_SSA_RECALL_HX] hx
        LEFT OUTER JOIN CLARITY.dbo.CLARITY_EMP emp
        ON emp.USER_ID = hx.REC_STAT_HX_EMP_ID
	    WHERE hx.RECALL_STAT_HX_C = 10
	) ssahx
	ON ssahx.ACTION_ID = ssa.ACTION_ID
	LEFT OUTER JOIN
	(
	    SELECT pd.[ACTION_ID]
              ,pd.[LINE]
	          ,pd.PROV_ID
	          ,ser.PROV_NAME
	          ,pd.DEP_ID
        FROM CLARITY.[dbo].[CL_SSA_PROV_DEPT] pd
        LEFT OUTER JOIN CLARITY.dbo.CLARITY_SER ser
        ON ser.PROV_ID = pd.PROV_ID
        LEFT OUTER JOIN CLARITY.dbo.CLARITY_DEP dep
        ON dep.DEPARTMENT_ID = pd.DEP_ID
        WHERE pd.LINE = 1
        OR (pd.LINE > 1 AND pd.PROV_ID IS NOT NULL)
    ) ssapd
    ON ssapd.ACTION_ID = ssa.ACTION_ID
    LEFT OUTER JOIN Rptg.vwRef_MDM_Location_Master_EpicSvc mdm
    ON ssapd.DEP_ID = mdm.epic_department_id
) evnts

--WHERE evnts.day_date >= @locstartdate
--      AND evnts.day_date < @locenddate
WHERE evnts.RECALL_DT >= @locstartdate
      AND evnts.RECALL_DT <= @locenddate

--ORDER BY evnts.day_date;
ORDER BY evnts.RECALL_DT;
*/
GO


