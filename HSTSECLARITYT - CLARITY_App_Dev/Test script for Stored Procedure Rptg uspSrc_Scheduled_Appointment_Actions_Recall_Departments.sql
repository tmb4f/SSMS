USE [CLARITY_App_Dev]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

DECLARE @StartDate SMALLDATETIME,
        @EndDate SMALLDATETIME,
		@DepartmentGrouperColumn VARCHAR(12),
		@DepartmentGrouperNoValue VARCHAR(25),
		@SelectString NVARCHAR(1000),
		@ParmDefinition NVARCHAR(500),
        @in_pods_servLine VARCHAR(MAX)

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

--CREATE PROCEDURE [Rptg].[uspSrc_Scheduled_Appointment_Actions_Recall_Departments]
--       (
--        @StartDate SMALLDATETIME = NULL,
--        @EndDate SMALLDATETIME = NULL,
--		@DepartmentGrouperColumn VARCHAR(12),
--		@DepartmentGrouperNoValue VARCHAR(25),
--        @in_pods_servLine VARCHAR(MAX)
--	   )
--AS
/****************************************************************************************************************************************
WHAT: Create procedure Rptg.uspSrc_Scheduled_Appointment_Actions_Recall_Departments
WHO : Tom Burgan
WHEN: 06/21/2019
WHY : Recall appointment action report: Recall departments
----------------------------------------------------------------------------------------------------------------------------------------
INFO:
      INPUTS:   CLARITY_App.ETL.fn_ParmParse
				CLARITY.dbo.CL_SSA
				CLARITY.dbo.CLARITY_DEP
				CLARITY_App.Rptg.vwRef_MDM_Location_Master_EpicSvc

      OUTPUTS:
                CLARITY_App_Dev.Rptg.uspSrc_Scheduled_Appointment_Actions_Recall_Departments
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
--('Womens and Childrens')
('Primary Care')
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
--('Digestive Health')
('Primary Care')
;

--SELECT @in_pods_servLine = COALESCE(@in_pods_servLine+',' ,'') + CAST(PodName AS VARCHAR(MAX))
--FROM @Pod

--SELECT @in_pods_servLine

DECLARE @locstartdate SMALLDATETIME,
        @locenddate SMALLDATETIME

SET @locstartdate = @StartDate
SET @locenddate   = @EndDate

SET @SelectString = N';WITH cte_pods_servLine (pod_Service_Line) AS (SELECT Param FROM CLARITY_App_Dev.Rptg.fn_ParmParse(@PodServiceLine, '','')) SELECT DISTINCT mdm.epic_department_id AS DEPARTMENT_ID, mdm.epic_department_name AS DEPARTMENT_NAME FROM CLARITY.[dbo].[CL_SSA] ssa INNER JOIN CLARITY.[dbo].[CL_SSA_PROV_DEPT] pd ON ssa.ACTION_ID = pd.ACTION_ID LEFT OUTER JOIN CLARITY.dbo.CLARITY_DEP dep ON dep.DEPARTMENT_ID = pd.DEP_ID LEFT OUTER JOIN CLARITY_App.Rptg.vwRef_MDM_Location_Master_EpicSvc mdm ON pd.DEP_ID = mdm.epic_department_id WHERE 1=1 AND mdm.epic_department_id IS NOT NULL AND (ssa.RECALL_DT >= @RecallStartDate AND ssa.RECALL_DT <= @RecallEndDate) AND COALESCE(' + @DepartmentGrouperColumn + ',''' + @DepartmentGrouperNoValue + ''') IN (SELECT pod_Service_Line FROM cte_pods_servLine) ORDER BY DEPARTMENT_NAME';
SET @ParmDefinition = N'@RecallStartDate SMALLDATETIME, @RecallEndDate SMALLDATETIME, @PodServiceLine VARCHAR(MAX)';

EXECUTE sp_executesql @SelectString, @ParmDefinition, @RecallStartDate=@locstartdate, @RecallEndDate=@locenddate, @PodServiceLine=@in_pods_servLine;

GO


