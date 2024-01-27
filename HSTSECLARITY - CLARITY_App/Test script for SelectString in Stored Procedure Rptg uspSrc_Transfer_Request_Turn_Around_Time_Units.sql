USE [CLARITY_App]
GO

 DECLARE @startdate AS SMALLDATETIME = NULL
 DECLARE @enddate AS SMALLDATETIME = NULL

---------------------------------------------------
 ----get default Balanced Scorecard date range
 IF @startdate IS NULL AND @enddate IS NULL
    EXEC etl.usp_Get_Dash_Dates_BalancedScorecard @startdate OUTPUT, @enddate OUTPUT
----------------------------------------------------


DECLARE @locstartdate SMALLDATETIME,
        @locenddate SMALLDATETIME

SET @locstartdate = @startdate
SET @locenddate   = @enddate

SELECT DISTINCT prvdep.DEPARTMENT_ID, prvdep.DEPARTMENT_NAME, mdm_supp.inpatient_adult_name, mdm_supp.childrens_name, mdm_supp.mc_operation_name, mdm_supp.ambulatory_operation_name, mdm_supp.serviceline_division_name FROM CLARITY.dbo.PEND_ACTION pnd LEFT OUTER JOIN CLARITY.dbo.CLARITY_DEP dep ON dep.DEPARTMENT_ID = pnd.UNIT_ID LEFT OUTER JOIN CLARITY.dbo.CLARITY_ADT adt ON pnd.LINKED_EVENT_ID = adt.EVENT_ID INNER JOIN CLARITY.dbo.CLARITY_ADT adtprv ON adtprv.EVENT_ID = adt.XFER_EVENT_ID INNER JOIN CLARITY.dbo.CLARITY_DEP prvdep ON adtprv.DEPARTMENT_ID = prvdep.DEPARTMENT_ID LEFT OUTER JOIN CLARITY_App.Rptg.vwRef_MDM_Location_Master_EpicSvc orlocsvc ON orlocsvc.epic_department_id = prvdep.DEPARTMENT_ID LEFT OUTER JOIN CLARITY_App.Rptg.vwRef_MDM_Supplemental mdm_supp ON mdm_supp.EPIC_DEPARTMENT_ID = orlocsvc.epic_department_id WHERE pnd.PEND_REQ_STATUS_C IS NOT NULL AND adt.EVENT_SUBTYPE_C <> 2	AND (pnd.REQUEST_TIME >= @locstartdate AND pnd.REQUEST_TIME < @locenddate) AND (adt.EFFECTIVE_TIME >= @locstartdate AND adt.EFFECTIVE_TIME < @locenddate)