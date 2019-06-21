USE [CLARITY_App_Dev]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

DECLARE @StartDate SMALLDATETIME,
        @EndDate SMALLDATETIME,
		@DepartmentGrouperColumn VARCHAR(12),
		@DepartmentGrouperNoValue VARCHAR(25)

SET @StartDate = NULL
SET @EndDate = NULL
--SET @StartDate = '2/1/2019 00:00 AM'
--SET @StartDate = '2/28/2019 00:00 AM'
--SET @StartDate = '1/1/2017 00:00 AM'
--SET @EndDate = '1/1/2031 00:00 AM'
--SET @StartDate = '4/24/2019 00:00 AM'
--SET @EndDate = '5/23/2019 11:59 PM'

--SET @DepartmentGrouperColumn = 'service_line'
SET @DepartmentGrouperColumn = 'pod_name'

--SET @DepartmentGrouperNoValue = '(No Service Line Defined)'
SET @DepartmentGrouperNoValue = '(No Pod Defined)'

--ALTER PROCEDURE [Rptg].[uspSrc_Scheduled_Appointment_Actions_Recall_ServiceLinesPods]
--       (
--        @StartDate SMALLDATETIME = NULL,
--        @EndDate SMALLDATETIME = NULL,
--		@DepartmentGrouperColumn VARCHAR(12),
--		@DepartmentGrouperNoValue VARCHAR(25)
--	   )
--AS
/****************************************************************************************************************************************
WHAT: Create procedure Rptg.uspSrc_Scheduled_Appointment_Actions_Recall_ServiceLinesPods
WHO : Tom Burgan
WHEN: 06/21/2019
WHY : Recall appointment action service lines/pods
----------------------------------------------------------------------------------------------------------------------------------------
INFO:
      INPUTS:   CLARITY.dbo.CL_SSA
				CLARITY.dbo.CL_SSA_PROV_DEPT
				CLARITY_App.Rptg.vwRef_MDM_Location_Master_EpicSvc

      OUTPUTS:
                CLARITY_App.Rptg.uspSrc_Scheduled_Appointment_Actions_Recall_ServiceLinesPods
----------------------------------------------------------------------------------------------------------------------------------------
MODS:     06/21/2019--TMB-- Create new stored procedure
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

-- Build the SELECT statement.

SET @SelectString = N'SELECT DISTINCT 1 AS Sort, evnts.' + @DepartmentGrouperColumn + ' AS NAME
FROM
(
	SELECT ssa.ACTION_ID
	      ,ssa.RECALL_DT
		  ,ssapd.DEP_ID
		  ,mdm.service_line
		  ,mdm.PFA_POD as pod_name
    FROM CLARITY.[dbo].[CL_SSA] ssa
	LEFT OUTER JOIN
	(
	    SELECT DISTINCT
		       pd.[ACTION_ID]
	          ,pd.DEP_ID
        FROM CLARITY.[dbo].[CL_SSA_PROV_DEPT] pd
    ) ssapd
    ON ssapd.ACTION_ID = ssa.ACTION_ID
    LEFT OUTER JOIN CLARITY_App.Rptg.vwRef_MDM_Location_Master_EpicSvc mdm
    ON ssapd.DEP_ID = mdm.epic_department_id
) evnts

WHERE (evnts.RECALL_DT >= @RecallStartDate
AND evnts.RECALL_DT <= @RecallEndDate) AND evnts.' + @DepartmentGrouperColumn + ' IS NOT NULL UNION ALL SELECT 2, ''' + @DepartmentGrouperNoValue + ''' ORDER BY 1,2';

-- Build the parameter definition clause.

SET @ParmDefinition = N'@RecallStartDate SMALLDATETIME, @RecallEndDate SMALLDATETIME';

-- Execute dynamically built SQL statement.

EXECUTE sp_executesql @SelectString, @ParmDefinition, @RecallStartDate=@locstartdate, @RecallEndDate=@locenddate;

GO


