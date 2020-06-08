USE [CLARITY_App]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

DECLARE @StartDate SMALLDATETIME,
        @EndDate SMALLDATETIME,
		@DepartmentGrouperColumn VARCHAR(12),
		@DepartmentGrouperNoValue VARCHAR(25)

--SET @StartDate = NULL
--SET @EndDate = NULL
--SET @StartDate = '2/1/2019 00:00 AM'
--SET @StartDate = '2/28/2019 00:00 AM'
--SET @StartDate = '1/1/2017 00:00 AM'
--SET @EndDate = '1/1/2031 00:00 AM'
SET @StartDate = '7/1/2019 00:00 AM'
SET @EndDate = '3/23/2020 11:59 PM'

SET @DepartmentGrouperColumn = 'service_line'
--SET @DepartmentGrouperColumn = 'pod_name'

SET @DepartmentGrouperNoValue = '(No Service Line Defined)'
--SET @DepartmentGrouperNoValue = '(No Pod Defined)'

--CREATE PROCEDURE [Rptg].[uspSrc_Completed_Referral_Scheduling_Detail_ServiceLinesPods]
--       (
--        @StartDate SMALLDATETIME = NULL,
--        @EndDate SMALLDATETIME = NULL,
--		@DepartmentGrouperColumn VARCHAR(12),
--		@DepartmentGrouperNoValue VARCHAR(25)
--	   )
--AS
/****************************************************************************************************************************************
WHAT: Create procedure Rptg.uspSrc_Completed_Referral_Scheduling_Detail_ServiceLinesPods
WHO : Tom Burgan
WHEN: 03/16/2020
WHY : Referral Completion report: Referral departments
----------------------------------------------------------------------------------------------------------------------------------------
INFO:
      INPUTS:   CLARITY.dbo.REFERRAL
	            CLARITY_App.Rptg.vwRef_MDM_Location_Master_EpicSvc

      OUTPUTS:
                CLARITY_App.Rptg.uspSrc_Completed_Referral_Scheduling_Detail_ServiceLinesPods
----------------------------------------------------------------------------------------------------------------------------------------
MODS:     03/16/2020--TMB-- Create new stored procedure
*****************************************************************************************************************************************/

  SET NOCOUNT ON;

---------------------------------------------------
---Default referral expiration date range is the current FYTD
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

--SELECT @locstartdate, @locenddate

DECLARE @SelectString NVARCHAR(1000),
		@ParmDefinition NVARCHAR(500)

-- Build the SELECT statement.

SET @SelectString = N'SELECT DISTINCT 1 AS Sort, evnts.' + @DepartmentGrouperColumn + ' AS NAME
FROM
(
	SELECT REFERRAL.REFERRAL_ID
	      ,REFERRAL.EXP_DATE
		  ,REFERRAL.REFD_BY_DEPT_ID
		  ,mdm.service_line
		  ,mdm.PFA_POD
    FROM CLARITY.[dbo].[REFERRAL] REFERRAL
    LEFT OUTER JOIN CLARITY_App.Rptg.vwRef_MDM_Location_Master_EpicSvc mdm
    ON REFERRAL.REFD_BY_DEPT_ID = mdm.epic_department_id
) evnts

WHERE (evnts.EXP_DATE >= @CompletedStartDate
AND evnts.EXP_DATE <= @CompletedEndDate) AND evnts.' + @DepartmentGrouperColumn + ' IS NOT NULL UNION ALL SELECT 2, ''' + @DepartmentGrouperNoValue + ''' ORDER BY 1,2';
SET @ParmDefinition = N'@CompletedStartDate SMALLDATETIME, @CompletedEndDate SMALLDATETIME';
EXECUTE sp_executesql @SelectString, @ParmDefinition, @CompletedStartDate=@locstartdate, @CompletedEndDate=@locenddate;

GO

/*
SET @SelectString = N'SELECT DISTINCT 1 AS Sort, evnts.' + @DepartmentGrouperColumn + ' AS NAME
FROM
(
	SELECT ssa.ACTION_ID
	      ,ssa.RECALL_DT
		  ,ssapd.DEP_ID
		  ,mdm.service_line
		  ,mdm.PFA_POD
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
*/