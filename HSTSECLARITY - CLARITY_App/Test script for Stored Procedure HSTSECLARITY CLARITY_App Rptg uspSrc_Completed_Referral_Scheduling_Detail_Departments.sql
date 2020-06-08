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
		--@SelectString NVARCHAR(1000),
		--@ParmDefinition NVARCHAR(500),
        @in_pods_servLine VARCHAR(MAX)

SET @StartDate = '7/1/2019 00:00 AM'
SET @EndDate = '3/24/2020 11:59 PM'

SET @DepartmentGrouperColumn = 'service_line'
--SET @DepartmentGrouperColumn = 'pod_name'

SET @DepartmentGrouperNoValue = '(No Service Line Defined)'
--SET @DepartmentGrouperNoValue = '(No Pod Defined)'

--ALTER PROCEDURE [Rptg].[uspSrc_Completed_Referral_Scheduling_Detail_Departments]
--       (
--        @StartDate SMALLDATETIME = NULL,
--        @EndDate SMALLDATETIME = NULL,
--		@DepartmentGrouperColumn VARCHAR(12),
--		@DepartmentGrouperNoValue VARCHAR(25),
--        @in_pods_servLine VARCHAR(MAX)
--	   )
--AS
/****************************************************************************************************************************************
WHAT: Create procedure Rptg.uspSrc_Completed_Referral_Scheduling_Detail_Departments
WHO : Tom Burgan
WHEN: 03/16/2020
WHY : Referral Completion report: Referral departments
----------------------------------------------------------------------------------------------------------------------------------------
INFO:
      INPUTS:   CLARITY_App.ETL.fn_ParmParse
	            CLARITY.dbo.REFERRAL
				CLARITY.dbo.REFERRAL_3
				CLARITY.dbo.CLARITY_DEP
				CLARITY_App.Rptg.vwRef_MDM_Location_Master_EpicSvc

      OUTPUTS:
                CLARITY_App.Rptg.uspSrc_Completed_Referral_Scheduling_Detail_Departments
----------------------------------------------------------------------------------------------------------------------------------------
MODS:     03/16/2020--TMB-- Create new stored procedure
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

SET NOCOUNT ON

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
('Unknown')
;

SELECT @in_pods_servLine = COALESCE(@in_pods_servLine+',' ,'') + CAST(ServiceLineName AS VARCHAR(MAX))
FROM @ServiceLine

--SELECT @in_pods_servLine

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

DECLARE @SelectString NVARCHAR(1000),
		@ParmDefinition NVARCHAR(500)
/*
SET @SelectString = N'
;WITH cte_pods_servLine (pod_Service_Line) AS
(
SELECT Param
FROM CLARITY_App.ETL.fn_ParmParse(@PodServiceLine, '','')
)
SELECT DISTINCT
REFERRAL.REFD_BY_DEPT_ID AS REFERRING_DEPT_ID,
REFERRING_DEP.DEPARTMENT_NAME AS REFERRING_DEPT_NAME
FROM CLARITY.dbo.REFERRAL
LEFT OUTER JOIN CLARITY.dbo.REFERRAL_3
ON REFERRAL.REFERRAL_ID=REFERRAL_3.REFERRAL_ID
LEFT OUTER JOIN CLARITY.dbo.CLARITY_DEP AS REFERRING_DEP
ON REFERRING_DEP.DEPARTMENT_ID = REFERRAL.REFD_BY_DEPT_ID
LEFT OUTER JOIN CLARITY_App.Rptg.vwRef_MDM_Location_Master_EpicSvc mdm
ON REFERRAL.REFD_BY_DEPT_ID = mdm.epic_department_id
WHERE (REFERRAL_3.AUTH_CERT_YN IS NULL OR REFERRAL_3.AUTH_CERT_YN=''N'')
AND REFERRAL.ACTUAL_NUM_VISITS IS NOT NULL
AND REFERRAL.REFD_BY_DEPT_ID IS NOT NULL
AND (REFERRAL.EXP_DATE >= @CompletedStartDate AND REFERRAL.EXP_DATE <= @CompletedEndDate)
AND COALESCE(mdm.' + @DepartmentGrouperColumn + ',''' + @DepartmentGrouperNoValue + ''') IN (SELECT pod_Service_Line FROM cte_pods_servLine)
ORDER BY REFERRING_DEP.DEPARTMENT_NAME';
*/
SET @SelectString = N'
;WITH cte_pods_servLine (pod_Service_Line) AS
(
SELECT Param
FROM CLARITY_App.ETL.fn_ParmParse(@PodServiceLine, '','')
)
SELECT DISTINCT
mdm.epic_department_id AS REFERRING_DEPT_ID,
mdm.epic_department_name AS REFERRING_DEPT_NAME
FROM CLARITY.dbo.REFERRAL
LEFT OUTER JOIN CLARITY.dbo.REFERRAL_3
ON REFERRAL.REFERRAL_ID=REFERRAL_3.REFERRAL_ID
LEFT OUTER JOIN CLARITY.dbo.CLARITY_DEP AS REFERRING_DEP
ON REFERRING_DEP.DEPARTMENT_ID = REFERRAL.REFD_BY_DEPT_ID
LEFT OUTER JOIN CLARITY_App.Rptg.vwRef_MDM_Location_Master_EpicSvc mdm
ON REFERRAL.REFD_BY_DEPT_ID = mdm.epic_department_id
WHERE (REFERRAL_3.AUTH_CERT_YN IS NULL OR REFERRAL_3.AUTH_CERT_YN=''N'')
AND REFERRAL.ACTUAL_NUM_VISITS IS NOT NULL
AND mdm.epic_department_id IS NOT NULL
AND (REFERRAL.EXP_DATE >= @CompletedStartDate AND REFERRAL.EXP_DATE <= @CompletedEndDate)
AND COALESCE(mdm.' + @DepartmentGrouperColumn + ',''' + @DepartmentGrouperNoValue + ''') IN (SELECT pod_Service_Line FROM cte_pods_servLine)
ORDER BY mdm.epic_department_name';

SET @ParmDefinition = N'@CompletedStartDate SMALLDATETIME, @CompletedEndDate SMALLDATETIME, @PodServiceLine VARCHAR(MAX)';

--SELECT @SelectString

EXECUTE sp_executesql @SelectString, @ParmDefinition, @CompletedStartDate=@locstartdate, @CompletedEndDate=@locenddate, @PodServiceLine=@in_pods_servLine;

GO

/*
SET @SelectString = N'
;WITH cte_pods_servLine (pod_Service_Line) AS
(
SELECT Param
FROM CLARITY_App.ETL.fn_ParmParse(@PodServiceLine, '','')
)
SELECT DISTINCT
mdm.epic_department_id AS DEPARTMENT_ID,
mdm.epic_department_name AS DEPARTMENT_NAME
FROM CLARITY.[dbo].[CL_SSA] ssa
INNER JOIN CLARITY.[dbo].[CL_SSA_PROV_DEPT] pd
ON ssa.ACTION_ID = pd.ACTION_ID
LEFT OUTER JOIN CLARITY.dbo.CLARITY_DEP dep
ON dep.DEPARTMENT_ID = pd.DEP_ID
LEFT OUTER JOIN CLARITY_App.Rptg.vwRef_MDM_Location_Master_EpicSvc mdm
ON pd.DEP_ID = mdm.epic_department_id
WHERE 1=1
AND mdm.epic_department_id IS NOT NULL
AND (ssa.RECALL_DT >= @RecallStartDate
     AND ssa.RECALL_DT <= @RecallEndDate)
AND COALESCE(mdm.' + @DepartmentGrouperColumn + ',''' + @DepartmentGrouperNoValue + ''') IN (SELECT pod_Service_Line FROM cte_pods_servLine)
ORDER BY DEPARTMENT_NAME';
*/