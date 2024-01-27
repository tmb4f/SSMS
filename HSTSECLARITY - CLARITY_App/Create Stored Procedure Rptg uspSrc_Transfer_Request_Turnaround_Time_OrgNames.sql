USE [CLARITY_App]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Rptg].[uspSrc_Transfer_Request_Turnaround_Time_OrgNames]
       (
        @StartDate SMALLDATETIME = NULL,
        @EndDate SMALLDATETIME = NULL,
		@DepartmentGrouperColumn VARCHAR(25),
		@DepartmentGrouperNoValue VARCHAR(30)
	   )
AS
/****************************************************************************************************************************************
WHAT: Create procedure Rptg.uspSrc_Transfer_Request_Turnaround_Time_OrgNames
WHO : Tom Burgan
WHEN: 08/20/2021
WHY : Transfer request turnaround time: Request origin organizational groups
----------------------------------------------------------------------------------------------------------------------------------------
INFO:
      INPUTS:   CLARITY.dbo.PEND_ACTION
				CLARITY.dbo.CLARITY_DEP
				CLARITY.dbo.CLARITY_ADT
				CLARITY_App.Rptg.vwRef_MDM_Location_Master_EpicSvc
				CLARITY_App.Rptg.vwRef_MDM_Supplemental

      OUTPUTS:
                CLARITY_App.Rptg.uspSrc_Transfer_Request_Turnaround_Time_OrgNames
----------------------------------------------------------------------------------------------------------------------------------------
MODS:     08/20/2021--TMB-- Create new stored procedure
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

  IF 1 = 2
     BEGIN
       SELECT CAST(0 AS INTEGER) AS Sort, 
              CAST('' AS VARCHAR(100)) AS [NAME]
     END;

DECLARE @locstartdate SMALLDATETIME,
        @locenddate SMALLDATETIME

SET @locstartdate = @StartDate
SET @locenddate   = @EndDate

DECLARE @SelectString NVARCHAR(MAX),
		@ParmDefinition NVARCHAR(500)

-- Build the SELECT statement.

SET @SelectString = N'SELECT DISTINCT 1 AS Sort, names.' + @DepartmentGrouperColumn + ' AS NAME
FROM
(
	SELECT mdm_supp.inpatient_adult_name
		, mdm_supp.childrens_name
		, mdm_supp.mc_operation_name
		, mdm_supp.ambulatory_operation_name
		, mdm_supp.serviceline_division_name
		, pnd.REQUEST_TIME
		, adt.EFFECTIVE_TIME
	FROM CLARITY.dbo.PEND_ACTION pnd
	LEFT OUTER JOIN CLARITY.dbo.CLARITY_DEP dep
	ON dep.DEPARTMENT_ID = pnd.UNIT_ID
	LEFT OUTER JOIN CLARITY.dbo.CLARITY_ADT adt
	ON pnd.LINKED_EVENT_ID = adt.EVENT_ID
	INNER JOIN CLARITY.dbo.CLARITY_ADT adtprv
	ON adtprv.EVENT_ID = adt.XFER_EVENT_ID
	INNER JOIN CLARITY.dbo.CLARITY_DEP prvdep
	ON adtprv.DEPARTMENT_ID = prvdep.DEPARTMENT_ID
	LEFT OUTER JOIN CLARITY_App.Rptg.vwRef_MDM_Location_Master_EpicSvc orlocsvc
	ON orlocsvc.epic_department_id = prvdep.DEPARTMENT_ID
	LEFT OUTER JOIN CLARITY_App.Rptg.vwRef_MDM_Supplemental mdm_supp
	ON mdm_supp.EPIC_DEPARTMENT_ID = orlocsvc.epic_department_id
	WHERE pnd.PEND_REQ_STATUS_C IS NOT NULL
	AND adt.EVENT_SUBTYPE_C <> 2
) names

WHERE (names.REQUEST_TIME >= @RequestStartDate
AND names.REQUEST_TIME < @RequestEndDate)
AND (names.EFFECTIVE_TIME >= @RequestStartDate
AND names.EFFECTIVE_TIME < @RequestEndDate)
AND names.' + @DepartmentGrouperColumn + ' IS NOT NULL UNION ALL SELECT 2, ''' + @DepartmentGrouperNoValue + ''' ORDER BY 1,2';

PRINT @SelectString

-- Build the parameter definition clause.

SET @ParmDefinition = N'@RequestStartDate SMALLDATETIME, @RequestEndDate SMALLDATETIME';

-- Execute dynamically built SQL statement.

EXECUTE sp_executesql @SelectString, @ParmDefinition, @RequestStartDate=@locstartdate, @RequestEndDate=@locenddate;

GO


