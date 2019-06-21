USE [CLARITY_App]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Rptg].[uspSrc_Scheduled_Appointment_Actions_Recall_ServiceLinesPods]
       (
        @StartDate SMALLDATETIME = NULL,
        @EndDate SMALLDATETIME = NULL,
		@DepartmentGrouperColumn VARCHAR(12),
		@DepartmentGrouperNoValue VARCHAR(25)
	   )
AS
/****************************************************************************************************************************************
WHAT: Create procedure Rptg.uspSrc_Scheduled_Appointment_Actions_Recall_ServiceLinesPods
WHO : Tom Burgan
WHEN: 06/19/2019
WHY : Recall appointment action service lines/pods
----------------------------------------------------------------------------------------------------------------------------------------
INFO:
      INPUTS:   CLARITY.dbo.CL_SSA
				CLARITY.dbo.CL_SSA_PROV_DEPT
				CLARITY_App.Rptg.vwRef_MDM_Location_Master_EpicSvc

      OUTPUTS:
                CLARITY_App.Rptg.uspSrc_Scheduled_Appointment_Actions_Recall_ServiceLinesPods
----------------------------------------------------------------------------------------------------------------------------------------
MODS:     06/19/2019--TMB-- Create new stored procedure
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
    LEFT OUTER JOIN Rptg.vwRef_MDM_Location_Master_EpicSvc mdm
    ON ssapd.DEP_ID = mdm.epic_department_id
) evnts

WHERE (evnts.RECALL_DT >= @RecallStartDate
AND evnts.RECALL_DT <= @RecallEndDate) AND evnts.' + @DepartmentGrouperColumn + ' IS NOT NULL UNION ALL SELECT 2, ''' + @DepartmentGrouperNoValue + ''' ORDER BY 1,2';

-- Build the parameter definition clause.

SET @ParmDefinition = N'@RecallStartDate SMALLDATETIME, @RecallEndDate SMALLDATETIME';

-- Execute dynamically built SQL statement.

EXECUTE sp_executesql @SelectString, @ParmDefinition, @RecallStartDate=@locstartdate, @RecallEndDate=@locenddate;

GO


