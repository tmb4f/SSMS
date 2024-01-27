USE [CLARITY_App_Dev]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

DECLARE @StartDate SMALLDATETIME,
        @EndDate SMALLDATETIME,
		@DepartmentGrouperColumn VARCHAR(25),
		@DepartmentGrouperNoValue VARCHAR(30),
		@SelectString NVARCHAR(4000),
		@ParmDefinition NVARCHAR(500),
        @in_transfer_request_group VARCHAR(MAX)

--SET @StartDate = '2/1/2019 00:00 AM'
--SET @StartDate = '2/28/2019 00:00 AM'
SET @StartDate = '1/1/2017 00:00 AM'
SET @EndDate = '1/1/2031 00:00 AM'
--SET @StartDate = '4/24/2019 00:00 AM'
--SET @EndDate = '5/23/2019 11:59 PM'

SET @DepartmentGrouperColumn = 'inpatient_adult_name'
--SET @DepartmentGrouperColumn = 'childrens_name'
--SET @DepartmentGrouperColumn = 'mc_operation_name'
--SET @DepartmentGrouperColumn = 'ambulatory_operation_name'
--SET @DepartmentGrouperColumn = 'serviceline_division_name'

SET @DepartmentGrouperNoValue = '(No Adult Unit Defined)'
--SET @DepartmentGrouperNoValue = '(No Pediatric Unit Defined)'
--SET @DepartmentGrouperNoValue = '(No MC Op Clinic Defined)'
--SET @DepartmentGrouperNoValue = '(No Amb Op Clinic Defined)'
--SET @DepartmentGrouperNoValue = '(No SL Div Clinic Defined)'

--ALTER PROCEDURE [Rptg].[uspSrc_Transfer_Request_Turn_Around_Time_Units]
--       (
--        @StartDate SMALLDATETIME = NULL,
--        @EndDate SMALLDATETIME = NULL,
--		@DepartmentGrouperColumn VARCHAR(25),
--		@DepartmentGrouperNoValue VARCHAR(30),
--        @in_transfer_request_group VARCHAR(MAX)
--	   )
--AS
/****************************************************************************************************************************************
WHAT: Create procedure Rptg.uspSrc_Transfer_Request_Turn_Around_Time_Units
WHO : Tom Burgan
WHEN: 08/05/2021
WHY : Transfer request turn-around time: Request origin units
----------------------------------------------------------------------------------------------------------------------------------------
INFO:
      INPUTS:   CLARITY_App_Dev.Rptg.fn_ParmParse
				CLARITY.dbo.PEND_ACTION
				CLARITY.dbo.CLARITY_DEP
				CLARITY.dbo.CLARITY_ADT
				CLARITY_App.Rptg.vwRef_MDM_Location_Master_EpicSvc
				CLARITY_App.Rptg.vwRef_MDM_Supplemental mdm_supp

      OUTPUTS:
                CLARITY_App_Dev.Rptg.uspSrc_Transfer_Request_Turn_Around_Time_Units
----------------------------------------------------------------------------------------------------------------------------------------
MODS:     08/05/2021--TMB-- Create new stored procedure
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

DECLARE @InpatientAdult TABLE (InpatientAdultName VARCHAR(150))

INSERT INTO @InpatientAdult
(
    InpatientAdultName
)
VALUES
--('(No Adult Unit Defined)'),
--('Behavioral Health'), -- 1
--('Cardiovascular'), -- 2
--('Emergency Services'), -- 4
--('Medicine'), -- 5
--('Neuroscience'), -- 6
--('Oncology'), -- 7
--('Orthopedics'), -- 8
--('Respiratory Therapy'), -- 9
--('Surgical Services'), -- 10
--('Transplant'), -- 11
--('Womens') -- 12
('Surgical Services')--, -- 10
;

SELECT @in_transfer_request_group = COALESCE(@in_transfer_request_group+',' ,'') + CAST(InpatientAdultName AS VARCHAR(MAX))
FROM @InpatientAdult

--SELECT @in_transfer_request_group

DECLARE @Childrens TABLE (ChildrensName VARCHAR(150))

INSERT INTO @Childrens
(
    ChildrensName
)
VALUES
--('(No Pediatric Unit Defined)'),
('Battle Building'), -- 1
('NICU'), -- 2
('Northridge Pediatrics'), -- 3
('Orange Pediatrics'), -- 7
('Other Pediatrics'), -- 5
('Pediatric Acute Care'), -- 4
('PICU') -- 6
;

--SELECT @in_transfer_request_group = COALESCE(@in_transfer_request_group+',' ,'') + CAST(ChildrensName AS VARCHAR(MAX))
--FROM @Childrens

--SELECT @in_transfer_request_group

DECLARE @MCOperation TABLE (MCOperationName VARCHAR(150))

INSERT INTO @MCOperation
(
    MCOperationName
)
VALUES
--('(No MC Op Clinic Defined)'),
('Continuum'), -- 1
('Labs'), -- 3
('Perioperative Services'), -- 4
('Pharmacy'), -- 5
('Radiology'), -- 6
('TCH'), -- 7
('Therapies')--, -- 8
;

--SELECT @in_transfer_request_group = COALESCE(@in_transfer_request_group+',' ,'') + CAST(MCOperationName AS VARCHAR(MAX))
--FROM @MCOperation

--SELECT @in_transfer_request_group

DECLARE @AmbulatoryOperation TABLE (AmbulatoryOperationName VARCHAR(150))

INSERT INTO @AmbulatoryOperation
(
    AmbulatoryOperationName
)
VALUES
--('(No Amb Op Clinic Defined)'),
('Behavioral Health'), -- 1
('Community Medicine'), -- 2
('Dialysis'), -- 3
('Digestive Health'), -- 4
('MC Outreach Clinics'), -- 5
('Medical Subspecialties'), -- 6
('Musculoskeletal'), -- 7
('Primary Care'), -- 8
('Pulmonary Function Test'), -- 12
('Sleep Center'), -- 13
('Spine Center'), -- 14
('Surgical Subspecialties'), -- 9
('Womens')--, -- 10
;

--SELECT @in_transfer_request_group = COALESCE(@in_transfer_request_group+',' ,'') + CAST(AmbulatoryOperationName AS VARCHAR(MAX))
--FROM @AmbulatoryOperation

--SELECT @in_transfer_request_group

DECLARE @ServiceLineDivision TABLE (ServiceLineDivisionName VARCHAR(150))

INSERT INTO @ServiceLineDivision
(
    ServiceLineDivisionName
)
VALUES
--('(No SL Div Clinic Defined)'),
('Heart & Vascular'), -- 4
('Neurosciences'), -- 3
('Oncology'), -- 1
('Transplant')--, -- 2
;

--SELECT @in_transfer_request_group = COALESCE(@in_transfer_request_group+',' ,'') + CAST(ServiceLineDivisionName AS VARCHAR(MAX))
--FROM @ServiceLineDivision

--SELECT @in_transfer_request_group

DECLARE @locstartdate SMALLDATETIME,
        @locenddate SMALLDATETIME

SET @locstartdate = @StartDate
SET @locenddate   = @EndDate

--DECLARE @SelectString NVARCHAR(4000),
--		@ParmDefinition NVARCHAR(500)

SET @SelectString = N';WITH cte_transfer_request_group (transfer_request_group) AS (SELECT Param FROM CLARITY_App_Dev.Rptg.fn_ParmParse(@TransferRequestGroup, '','')) SELECT DISTINCT prvdep.DEPARTMENT_ID, prvdep.DEPARTMENT_NAME FROM CLARITY.dbo.PEND_ACTION pnd LEFT OUTER JOIN CLARITY.dbo.CLARITY_DEP dep ON dep.DEPARTMENT_ID = pnd.UNIT_ID LEFT OUTER JOIN CLARITY.dbo.CLARITY_ADT adt ON pnd.LINKED_EVENT_ID = adt.EVENT_ID INNER JOIN CLARITY.dbo.CLARITY_ADT adtprv ON adtprv.EVENT_ID = adt.XFER_EVENT_ID INNER JOIN CLARITY.dbo.CLARITY_DEP prvdep ON adtprv.DEPARTMENT_ID = prvdep.DEPARTMENT_ID LEFT OUTER JOIN CLARITY_App.Rptg.vwRef_MDM_Location_Master_EpicSvc orlocsvc ON orlocsvc.epic_department_id = prvdep.DEPARTMENT_ID LEFT OUTER JOIN CLARITY_App.Rptg.vwRef_MDM_Supplemental mdm_supp ON mdm_supp.EPIC_DEPARTMENT_ID = orlocsvc.epic_department_id WHERE 1=1 AND pnd.PEND_REQ_STATUS_C IS NOT NULL AND adt.EVENT_SUBTYPE_C <> 2	 AND (pnd.REQUEST_TIME >= @RequestStartDate AND pnd.REQUEST_TIME < @RequestEndDate) AND (adt.EFFECTIVE_TIME >= @RequestStartDate AND adt.EFFECTIVE_TIME < @RequestEndDate) AND COALESCE(mdm_supp.' + @DepartmentGrouperColumn + ',''' + @DepartmentGrouperNoValue + ''') IN (SELECT transfer_request_group FROM cte_transfer_request_group) ORDER BY DEPARTMENT_NAME';
SET @ParmDefinition = N'@RequestStartDate SMALLDATETIME, @RequestEndDate SMALLDATETIME, @TransferRequestGroup VARCHAR(MAX)';

EXECUTE sp_executesql @SelectString, @ParmDefinition, @RequestStartDate=@locstartdate, @RequestEndDate=@locenddate, @TransferRequestGroup=@in_transfer_request_group;

GO
