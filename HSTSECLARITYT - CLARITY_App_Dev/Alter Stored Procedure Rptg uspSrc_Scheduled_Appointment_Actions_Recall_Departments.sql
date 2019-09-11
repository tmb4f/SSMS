USE [CLARITY_App_Dev]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [Rptg].[uspSrc_Scheduled_Appointment_Actions_Recall_Departments]
       (
        @StartDate SMALLDATETIME = NULL,
        @EndDate SMALLDATETIME = NULL,
		@DepartmentGrouperColumn VARCHAR(12),
		@DepartmentGrouperNoValue VARCHAR(25),
        @in_pods_servLine VARCHAR(MAX)
	   )
AS
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
          07/08/2019--TMB-- Added alias to dynamic column name
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

DECLARE @SelectString NVARCHAR(1000),
		@ParmDefinition NVARCHAR(500)

SET @SelectString = N';WITH cte_pods_servLine (pod_Service_Line) AS (SELECT Param FROM CLARITY_App_Dev.Rptg.fn_ParmParse(@PodServiceLine, '','')) SELECT DISTINCT mdm.epic_department_id AS DEPARTMENT_ID, mdm.epic_department_name AS DEPARTMENT_NAME FROM CLARITY.[dbo].[CL_SSA] ssa INNER JOIN CLARITY.[dbo].[CL_SSA_PROV_DEPT] pd ON ssa.ACTION_ID = pd.ACTION_ID LEFT OUTER JOIN CLARITY.dbo.CLARITY_DEP dep ON dep.DEPARTMENT_ID = pd.DEP_ID LEFT OUTER JOIN CLARITY_App.Rptg.vwRef_MDM_Location_Master_EpicSvc mdm ON pd.DEP_ID = mdm.epic_department_id WHERE 1=1 AND mdm.epic_department_id IS NOT NULL AND (ssa.RECALL_DT >= @RecallStartDate AND ssa.RECALL_DT <= @RecallEndDate) AND COALESCE(mdm.' + @DepartmentGrouperColumn + ',''' + @DepartmentGrouperNoValue + ''') IN (SELECT pod_Service_Line FROM cte_pods_servLine) ORDER BY DEPARTMENT_NAME';
SET @ParmDefinition = N'@RecallStartDate SMALLDATETIME, @RecallEndDate SMALLDATETIME, @PodServiceLine VARCHAR(MAX)';

EXECUTE sp_executesql @SelectString, @ParmDefinition, @RecallStartDate=@locstartdate, @RecallEndDate=@locenddate, @PodServiceLine=@in_pods_servLine;

GO


