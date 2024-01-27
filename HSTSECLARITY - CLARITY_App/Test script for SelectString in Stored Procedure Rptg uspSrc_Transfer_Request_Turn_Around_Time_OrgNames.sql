USE [CLARITY_App]
GO

 DECLARE @StartDate AS SMALLDATETIME = NULL
 DECLARE @EndDate AS SMALLDATETIME = NULL

SET @StartDate = '1/1/2017 00:00 AM'
SET @EndDate = '1/1/2031 00:00 AM'

  SET NOCOUNT ON;

---------------------------------------------------
---Default request date range is the current FY
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

SELECT DISTINCT mdm_supp.inpatient_adult_name, mdm_supp.childrens_name, mdm_supp.mc_operation_name, mdm_supp.ambulatory_operation_name, mdm_supp.serviceline_division_name FROM CLARITY.dbo.PEND_ACTION pnd LEFT OUTER JOIN CLARITY.dbo.CLARITY_DEP dep ON dep.DEPARTMENT_ID = pnd.UNIT_ID LEFT OUTER JOIN CLARITY.dbo.CLARITY_ADT adt ON pnd.LINKED_EVENT_ID = adt.EVENT_ID INNER JOIN CLARITY.dbo.CLARITY_ADT adtprv ON adtprv.EVENT_ID = adt.XFER_EVENT_ID INNER JOIN CLARITY.dbo.CLARITY_DEP prvdep ON adtprv.DEPARTMENT_ID = prvdep.DEPARTMENT_ID LEFT OUTER JOIN CLARITY_App.Rptg.vwRef_MDM_Location_Master_EpicSvc orlocsvc ON orlocsvc.epic_department_id = prvdep.DEPARTMENT_ID LEFT OUTER JOIN CLARITY_App.Rptg.vwRef_MDM_Supplemental mdm_supp ON mdm_supp.EPIC_DEPARTMENT_ID = orlocsvc.epic_department_id WHERE pnd.PEND_REQ_STATUS_C IS NOT NULL AND adt.EVENT_SUBTYPE_C <> 2	AND (pnd.REQUEST_TIME >= @locstartdate AND pnd.REQUEST_TIME < @locenddate) AND (adt.EFFECTIVE_TIME >= @locstartdate AND adt.EFFECTIVE_TIME < @locenddate)