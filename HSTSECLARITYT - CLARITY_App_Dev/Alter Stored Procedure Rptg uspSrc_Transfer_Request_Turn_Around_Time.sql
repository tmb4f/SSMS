USE [CLARITY_App_Dev]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [Rptg].[uspSrc_Transfer_Request_Turn_Around_Time]
       (
        @StartDate SMALLDATETIME = NULL,
        @EndDate SMALLDATETIME = NULL,
		@DepartmentGrouperColumn VARCHAR(25),
		@DepartmentGrouperNoValue VARCHAR(30),
        --@in_transfer_request_group VARCHAR(MAX),
        @in_depid VARCHAR(MAX)
	   )
AS
/****************************************************************************************************************************************
WHAT: Create procedure Rptg.uspSrc_Transfer_Request_Turn_Around_Time
WHO : Tom Burgan
WHEN: 08/17/2021
WHY : Transfer request turn-around time report
----------------------------------------------------------------------------------------------------------------------------------------
INFO:
      INPUTS:   CLARITY.dbo.HSP_ATND_PROV
				CLARITY.dbo.CLARITY_SER
				CLARITY_App.Rptg.vwRef_MDM_Location_Master
				CLARITY.dbo.PEND_ACTION
				CLARITY.dbo.PAT_ENC_HSP
				CLARITY.dbo.CLARITY_DEP
				CLARITY.dbo.CLARITY_BED
				CLARITY.dbo.CLARITY_ADT
				CLARITY.dbo.ZC_PAT_CLASS
				CLARITY.dbo.ORDER_PROC
				CLARITY.dbo.IDENTITY_ID
				CLARITY.dbo.PATIENT
				CLARITY.dbo.ZC_SEX
				CLARITY.dbo.IDENTITY_SER_ID
				CLARITY_App.dbo.Dim_Physcn
				CLARITY_App.Rptg.vwDim_Date
				CLARITY_App.Rptg.vwRef_MDM_Supplemental

      OUTPUTS:
                CLARITY_App_Dev.Rptg.uspSrc_Transfer_Request_Turn_Around_Time
----------------------------------------------------------------------------------------------------------------------------------------
MODS:     08/17/2021--TMB-- Create new stored procedure
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

DECLARE @SelectString NVARCHAR(MAX),
		          @ParmDefinition NVARCHAR(500)

SET @SelectString = ';WITH cte_depid (DepartmentId)
AS
(
SELECT Param FROM CLARITY_App_Dev.Rptg.fn_ParmParse(@DepartmentId, '','')
)
SELECT
   CAST(''Transfer'' AS VARCHAR(50)) AS event_type,
   CASE WHEN (transfers.occupied_date IS NOT NULL AND transfers.inpt_unit_flag = 1) 
		   THEN 1
		   ELSE 0
	   END AS event_count,
	   transfers.occupied_date AS event_date,
       date_dim.fmonth_num,
       date_dim.Fyear_num,
       date_dim.FYear_name,
       CAST(LEFT(DATENAME(MM, date_dim.day_date), 3) + '' '' + CAST(DAY(date_dim.day_date) AS VARCHAR(2)) AS VARCHAR(10)) AS report_period,
       CAST(CAST(date_dim.day_date AS DATE) AS SMALLDATETIME) AS report_date,
	   mdm_supp.' + @DepartmentGrouperColumn + ' AS org_group,
       transfers.origin_dept_id epic_department_id,
       transfers.origin_dept as epic_department_name,
	   transfers.origin_dept_ext_name as epic_department_name_external,
       transfers.BIRTH_DATE AS person_birth_date,
       transfers.Sex AS person_gender,
       CAST(transfers.MRN AS INTEGER) AS person_id,
       transfers.PAT_NAME AS person_name,
	   transfers.ord_auth_phys_prov_id AS provider_id,
	   transfers.ord_auth_phys AS provider_name,
       transfers.assigned_dept_id,
       transfers.assigned_dept,
       transfers.assigned_dept_ext_name,
       transfers.assigned_bed,
       transfers.transfer_order_written_date,
	   transfers.REQUEST_TIME,
       transfers.bed_request_date,
       transfers.bed_assigned_date,
       transfers.occupied_date,
       transfers.occupied_dept_id,
       transfers.occupied_dept,
       transfers.occupied_dept_ext_name,
       transfers.occupied_bed,
       transfers.inpt_unit_flag,
	   DATEDIFF(n, transfers.REQUEST_TIME, transfers.occupied_date) AS turnaround_time,
	   ordatn.PROV_ID AS ord_atn_phys_prov_id,
	   ordatn.PROV_NAME AS ord_atn_phys,
	   transfers.occ_atn_phys,
	   transfers.adt_class,
	   transfers.hsp_class
FROM
(
	SELECT DISTINCT
					  hsp.PAT_ENC_CSN_ID
					 ,hsp.HSP_ACCOUNT_ID
					 ,CAST(idx.IDENTITY_ID AS VARCHAR(50)) AS MRN
					 ,hsp.PAT_ID
					 ,pt.PAT_NAME
					 ,pt.BIRTH_DATE
					 ,sx.NAME AS Sex
					 ,adt.PAT_CLASS_C
					 ,cls.NAME AS adt_class
					 ,hsp.ADT_PAT_CLASS_C
					 ,hcls.NAME AS hsp_class
					 ,prvdep.DEPARTMENT_ID AS origin_dept_id
					 ,prvdep.DEPARTMENT_NAME AS origin_dept
					 ,prvdep.EXTERNAL_NAME AS origin_dept_ext_name
					 ,dep.DEPARTMENT_ID AS assigned_dept_id
					 ,dep.DEPARTMENT_NAME AS assigned_dept
					 ,dep.EXTERNAL_NAME AS assigned_dept_ext_name
					 ,bed.BED_LABEL AS assigned_bed
					 ,prc.ORDER_INST AS transfer_order_written_date
					 ,pnd.REQUEST_TIME
					 ,CAST(CAST(pnd.REQUEST_TIME AS DATE) AS SMALLDATETIME) AS bed_request_date
					 ,YEAR(pnd.REQUEST_TIME) AS bed_request_year
					 ,DATENAME(MONTH, pnd.REQUEST_TIME) AS bed_request_month
					 ,DATENAME(dw, pnd.REQUEST_TIME) AS bed_request_day
					 ,pnd.ASSIGNED_TIME AS bed_assigned_date
					 ,adt.EFFECTIVE_TIME AS occupied_date
					 ,CAST(CAST(adt.EFFECTIVE_TIME AS DATE) AS SMALLDATETIME) AS occupied_date_date
					 ,occdpt.DEPARTMENT_ID AS occupied_dept_id
					 ,occdpt.DEPARTMENT_NAME AS occupied_dept
					 ,occdpt.EXTERNAL_NAME AS occupied_dept_ext_name
					 ,occbed.BED_LABEL AS occupied_bed
					 ,pndatn.PROV_ID AS occ_atn_phys_prov_id
					 ,pndatn.PROV_NAME AS occ_atn_phys
					 ,ophys.Service_Line AS occ_atn_phys_sl
					 ,ordauth.PROV_ID AS ord_auth_phys_prov_id
					 ,ordauth.PROV_NAME AS ord_auth_phys
					 ,rphys.Service_Line AS ord_auth_phys_sl
					 ,(SELECT TOP 1
						  ser.PROV_ID
						FROM
						  CLARITY.dbo.HSP_ATND_PROV prov
						INNER JOIN CLARITY.dbo.CLARITY_SER ser ON ser.PROV_ID = prov.PROV_ID
						WHERE
						  adt.PAT_ENC_CSN_ID = prov.PAT_ENC_CSN_ID
						  AND prc.ORDER_INST >= prov.ATTEND_FROM_DATE
						  AND prc.ORDER_INST < (CASE WHEN prov.ATTEND_TO_DATE IS NULL THEN GETDATE() ELSE prov.ATTEND_TO_DATE END)
						ORDER BY
						  ABS(DATEDIFF(dd, prov.ATTEND_FROM_DATE,
									   prc.ORDER_INST)
							 )
					    ) AS ord_atn_phys
					   ,CASE WHEN ((prvdep.DEPARTMENT_ID IN (
								   SELECT  EPIC_DEPARTMENT_ID
										FROM  CLARITY_App.Rptg.vwRef_MDM_Location_Master
										WHERE  EPIC_DEPT_TYPE = ''IN PATIENT''))
								 AND (occdpt.DEPARTMENT_ID IN (
									   SELECT  EPIC_DEPARTMENT_ID
										FROM  CLARITY_App.Rptg.vwRef_MDM_Location_Master
										WHERE  EPIC_DEPT_TYPE = ''IN PATIENT'')))
						THEN 1
						ELSE 0
					  END AS inpt_unit_flag
					FROM
					  CLARITY.dbo.PEND_ACTION pnd
					LEFT OUTER JOIN CLARITY.dbo.PAT_ENC_HSP hsp ON pnd.PAT_ENC_CSN_ID = hsp.PAT_ENC_CSN_ID
					LEFT OUTER JOIN CLARITY.dbo.CLARITY_DEP dep ON dep.DEPARTMENT_ID = pnd.UNIT_ID
					LEFT OUTER JOIN CLARITY.dbo.CLARITY_BED bed ON bed.BED_ID = pnd.BED_ID
					LEFT OUTER JOIN CLARITY.dbo.CLARITY_ADT adt ON pnd.LINKED_EVENT_ID = adt.EVENT_ID
					LEFT OUTER JOIN CLARITY.dbo.ZC_PAT_CLASS cls ON cls.ADT_PAT_CLASS_C = adt.PAT_CLASS_C
					LEFT OUTER JOIN CLARITY.dbo.ZC_PAT_CLASS hcls ON hcls.ADT_PAT_CLASS_C = hsp.ADT_PAT_CLASS_C
					LEFT OUTER JOIN CLARITY.dbo.CLARITY_DEP occdpt ON adt.DEPARTMENT_ID = occdpt.DEPARTMENT_ID
					LEFT OUTER JOIN CLARITY.dbo.CLARITY_BED occbed ON adt.BED_ID = occbed.BED_ID
					LEFT OUTER JOIN CLARITY.dbo.ORDER_PROC prc ON pnd.ADT_ORDER_ID = prc.ORDER_PROC_ID
					INNER JOIN CLARITY.dbo.IDENTITY_ID idx ON idx.PAT_ID = adt.PAT_ID
					INNER JOIN CLARITY.dbo.CLARITY_ADT adtprv ON adtprv.EVENT_ID = adt.XFER_EVENT_ID
					INNER JOIN CLARITY.dbo.CLARITY_DEP prvdep ON adtprv.DEPARTMENT_ID = prvdep.DEPARTMENT_ID
					LEFT OUTER JOIN CLARITY.dbo.PATIENT pt ON pt.PAT_ID = hsp.PAT_ID
					LEFT OUTER JOIN CLARITY.dbo.ZC_SEX sx ON sx.RCPT_MEM_SEX_C = pt.SEX_C
					LEFT OUTER JOIN CLARITY.dbo.CLARITY_SER pndatn ON pndatn.PROV_ID = pnd.PEND_ATND_PROV_ID
					LEFT OUTER JOIN CLARITY.dbo.CLARITY_SER ordauth ON ordauth.PROV_ID = prc.AUTHRZING_PROV_ID
					LEFT OUTER JOIN CLARITY.dbo.IDENTITY_SER_ID seridoc ON pndatn.PROV_ID = seridoc.PROV_ID AND seridoc.IDENTITY_TYPE_ID = 6
					LEFT OUTER JOIN CLARITY_App.dbo.Dim_Physcn ophys ON TRY_CONVERT(INT, seridoc.IDENTITY_ID) = ophys.IDNumber AND ophys.current_flag = 1
					LEFT OUTER JOIN CLARITY.dbo.IDENTITY_SER_ID seridor ON ordauth.PROV_ID = seridor.PROV_ID AND seridor.IDENTITY_TYPE_ID = 6
					LEFT OUTER JOIN CLARITY_App.dbo.Dim_Physcn rphys ON TRY_CONVERT(INT, seridor.IDENTITY_ID) = rphys.IDNumber AND rphys.current_flag = 1
					WHERE
					  pnd.PEND_REQ_STATUS_C IS NOT NULL --all bed requests
					  AND dep.RECORD_STATUS IS NULL
					  AND adt.EVENT_SUBTYPE_C <> 2	-- Canceled
					  AND dep.DEPARTMENT_NAME IS NOT NULL
					  AND idx.IDENTITY_TYPE_ID = 14
					  AND (pnd.REQUEST_TIME >= @RequestStartDate
						   AND pnd.REQUEST_TIME < @RequestEndDate)
					  AND (adt.EFFECTIVE_TIME >= @RequestStartDate
						   AND adt.EFFECTIVE_TIME < @RequestEndDate)
					) transfers
LEFT OUTER JOIN CLARITY.dbo.CLARITY_SER ordatn ON ordatn.PROV_ID = transfers.ord_atn_phys
LEFT OUTER JOIN CLARITY_App.Rptg.vwDim_Date date_dim ON date_dim.day_date = transfers.bed_request_date
LEFT OUTER JOIN CLARITY_App.Rptg.vwRef_MDM_Supplemental mdm_supp ON mdm_supp.EPIC_DEPARTMENT_ID = transfers.origin_dept_id
WHERE (transfers.origin_dept_id IN (SELECT DepartmentId FROM cte_depid))
ORDER BY transfers.origin_dept_id, transfers.bed_request_date';
SET @ParmDefinition = N'@RequestStartDate SMALLDATETIME, @RequestEndDate SMALLDATETIME, @DepartmentId VARCHAR(MAX)';
EXECUTE sp_executesql @SelectString, @ParmDefinition, @RequestStartDate=@locstartdate, @RequestEndDate=@locenddate, @DepartmentId=@in_depid;

GO

GRANT EXECUTE, VIEW DEFINITION ON [Rptg].[uspSrc_Transfer_Request_Turn_Around_Time] to [HSCDOM\Decision Support]
GO


