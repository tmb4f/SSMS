USE [CLARITY_App]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Rptg].[uspSrc_Transfer_Request_Turnaround_Time_Units]
       (
        @StartDate SMALLDATETIME = NULL,
        @EndDate SMALLDATETIME = NULL,
		@DepartmentGrouperColumn VARCHAR(25),
		@DepartmentGrouperNoValue VARCHAR(30),
        @in_transfer_request_group VARCHAR(MAX)
	   )
AS
/****************************************************************************************************************************************
WHAT: Create procedure Rptg.uspSrc_Transfer_Request_Turnaround_Time_Units
WHO : Tom Burgan
WHEN: 08/20/2021
WHY : Transfer request turn-around time: Request origin units
----------------------------------------------------------------------------------------------------------------------------------------
INFO:
      INPUTS:   CLARITY_App.ETL.fn_ParmParse
				CLARITY.dbo.PEND_ACTION
				CLARITY.dbo.CLARITY_DEP
				CLARITY.dbo.CLARITY_ADT
				CLARITY_App.Rptg.vwRef_MDM_Location_Master_EpicSvc
				CLARITY_App.Rptg.vwRef_MDM_Supplemental mdm_supp

      OUTPUTS:
                CLARITY_App.Rptg.uspSrc_Transfer_Request_Turnaround_Time_Units
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

DECLARE @locstartdate SMALLDATETIME,
        @locenddate SMALLDATETIME

SET @locstartdate = @StartDate
SET @locenddate   = @EndDate

DECLARE @SelectString NVARCHAR(4000),
		@ParmDefinition NVARCHAR(500)

SET @SelectString = N';WITH cte_transfer_request_group (transfer_request_group) AS (SELECT Param FROM CLARITY_App.ETL.fn_ParmParse(@TransferRequestGroup, '','')) SELECT DISTINCT prvdep.DEPARTMENT_ID, prvdep.DEPARTMENT_NAME FROM CLARITY.dbo.PEND_ACTION pnd LEFT OUTER JOIN CLARITY.dbo.CLARITY_DEP dep ON dep.DEPARTMENT_ID = pnd.UNIT_ID LEFT OUTER JOIN CLARITY.dbo.CLARITY_ADT adt ON pnd.LINKED_EVENT_ID = adt.EVENT_ID INNER JOIN CLARITY.dbo.CLARITY_ADT adtprv ON adtprv.EVENT_ID = adt.XFER_EVENT_ID INNER JOIN CLARITY.dbo.CLARITY_DEP prvdep ON adtprv.DEPARTMENT_ID = prvdep.DEPARTMENT_ID LEFT OUTER JOIN CLARITY_App.Rptg.vwRef_MDM_Location_Master_EpicSvc orlocsvc ON orlocsvc.epic_department_id = prvdep.DEPARTMENT_ID LEFT OUTER JOIN CLARITY_App.Rptg.vwRef_MDM_Supplemental mdm_supp ON mdm_supp.EPIC_DEPARTMENT_ID = orlocsvc.epic_department_id WHERE 1=1 AND pnd.PEND_REQ_STATUS_C IS NOT NULL AND adt.EVENT_SUBTYPE_C <> 2	 AND (pnd.REQUEST_TIME >= @RequestStartDate AND pnd.REQUEST_TIME < @RequestEndDate) AND (adt.EFFECTIVE_TIME >= @RequestStartDate AND adt.EFFECTIVE_TIME < @RequestEndDate) AND COALESCE(mdm_supp.' + @DepartmentGrouperColumn + ',''' + @DepartmentGrouperNoValue + ''') IN (SELECT transfer_request_group FROM cte_transfer_request_group) ORDER BY DEPARTMENT_NAME';
SET @ParmDefinition = N'@RequestStartDate SMALLDATETIME, @RequestEndDate SMALLDATETIME, @TransferRequestGroup VARCHAR(MAX)';

EXECUTE sp_executesql @SelectString, @ParmDefinition, @RequestStartDate=@locstartdate, @RequestEndDate=@locenddate, @TransferRequestGroup=@in_transfer_request_group;

GO


