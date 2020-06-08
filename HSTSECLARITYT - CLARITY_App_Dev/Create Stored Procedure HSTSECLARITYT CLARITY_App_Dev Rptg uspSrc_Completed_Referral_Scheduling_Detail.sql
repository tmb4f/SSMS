USE [CLARITY_App_Dev]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Rptg].[uspSrc_Completed_Referral_Scheduling_Detail]
       (
        @StartDate SMALLDATETIME = NULL,
        @EndDate SMALLDATETIME = NULL,
		@DepartmentGrouperColumn VARCHAR(12),
		@DepartmentGrouperNoValue VARCHAR(25),
        @in_pods_servLine VARCHAR(MAX),
        @in_depid VARCHAR(MAX)
	   )
AS
BEGIN
SET FMTONLY OFF;
/****************************************************************************************************************************************
WHAT: Create procedure Rptg.uspSrc_Completed_Referral_Scheduling_Detail
WHO : Tom Burgan
WHEN: 03/20/2020
WHY : Referral Completion report
----------------------------------------------------------------------------------------------------------------------------------------
INFO:
      INPUTS:   CLARITY_App_Dev.Rptg.fn_ParmParse
	            CLARITY.dbo.REFERRAL
                CLARITY.dbo.REFERRAL_3
				CLARITY.dbo.PATIENT
				CLARITY.dbo.CLARITY_DEP
				CLARITY.dbo.CLARITY_SER
				CLARITY.dbo.ZC_SPECIALTY
				CLARITY.dbo.ZC_RFL_TYPE
				CLARITY.dbo.ZC_RFL_CLASS
				CLARITY.dbo.ZC_RFL_STATUS
				CLARITY.dbo.REFERRAL_SOURCE
				CLARITY.dbo.REFERRAL_HIST
                CLARITY.dbo.CLARITY_EMP
				CLARITY.dbo.ZC_RFL_HST_CHG_TYP
				CLARITY.dbo.V_SCHED_APPT
				CLARITY_App.Rptg.vwDim_Date
                CLARITY_App.Rptg.vwRef_MDM_Location_Master_EpicSvc

      OUTPUTS:
                CLARITY_App.Rptg.uspSrc_Completed_Referral_Scheduling_Detail
----------------------------------------------------------------------------------------------------------------------------------------
MODS:     03/20/2020--TMB-- Create new stored procedure
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
        SET @EndDate = CAST(CAST(DATEADD(DAY, -1, @CurrDate) AS DATE) AS SMALLDATETIME);
      END;
----------------------------------------------------

DECLARE @locstartdate SMALLDATETIME,
        @locenddate SMALLDATETIME

SET @locstartdate = @StartDate
SET @locenddate   = @EndDate

DECLARE @SelectString NVARCHAR(MAX),
		@ParmDefinition NVARCHAR(500)

SET @SelectString = N';WITH cte_pods_servLine (pod_Service_Line)
AS
(
SELECT Param FROM CLARITY_App_Dev.Rptg.fn_ParmParse(@PodServiceLine, '','')
)
,cte_depid (DepartmentId)
AS
(
SELECT Param FROM CLARITY_App_Dev.Rptg.fn_ParmParse(@DepartmentId, '','')
)
SELECT DISTINCT
   CAST(''Completed Referral'' AS VARCHAR(50)) AS event_type,
   1 AS event_count,
   REFERRAL.EXP_DATE AS event_date,
   date_dim.fmonth_num,
   date_dim.Fyear_num,
   date_dim.FYear_name,
   CAST(LEFT(DATENAME(MM, date_dim.day_date), 3) + '' '' + CAST(DAY(date_dim.day_date) AS VARCHAR(2)) AS VARCHAR(10)) AS report_period,
   CAST(CAST(date_dim.day_date AS DATE) AS SMALLDATETIME) AS report_date,
   REFERRAL.REFD_BY_DEPT_ID AS epic_department_id,
   REFERRING_DEP.DEPARTMENT_NAME AS epic_department_name,
   CAST(PATIENT.PAT_MRN_ID AS INTEGER) AS person_id,
   PATIENT.PAT_NAME AS person_name,
   REFERRAL_SOURCE.REF_PROVIDER_ID AS provider_id,
   REFERRING_SER.PROV_NAME AS provider_name,
   REFERRAL.REFERRAL_ID,
   REFERRAL.ENTRY_DATE,
   AUTH_CHANGE.CHANGE_DATETIME AS AUTH_DATE,
   ZC_RFL_CLASS.NAME AS REFERRAL_CLASS,
   ZC_RFL_TYPE.NAME AS REFERRAL_TYPE,
   CLARITY_DEP.DEPARTMENT_ID AS REFERRED_TO_DEPT_ID,
   CLARITY_DEP.DEPARTMENT_NAME AS REFERRED_TO_DEPT_NAME,
   CLARITY_SER.PROV_ID AS REFERRED_TO_PROV_ID,
   CLARITY_SER.PROV_NAME AS REFERRED_TO_PROV_NAME,
   ZC_SPECIALTY.NAME AS REFERRED_TO_PROV_SPEC,
   PATIENT.PAT_NAME AS PATIENT_NAME,
   SCHED_CHANGE.CHANGE_DATETIME AS RFL_CHANGE_DTTM,
   SCHED_CHANGE.CHANGE_TYPE_NAME AS RFL_CHANGE_TYPE,
   SCHED_CHANGE.CHANGE_USER_ID AS RFL_CHANGE_USER_ID,
   SCHED_CHANGE.CHANGE_USER_NAME AS RFL_CHANGE_USER,
   SCHED_CHANGE.PREVIOUS_VALUE AS RFL_CHANGE_TEXT,
   RFL_APPTS.ACTUAL_CNT AS SCHEDULED_VISITS,
   RFL_APPTS.APPT_MADE_DTTM AS FIRST_APPT_MADE,
   RFL_APPTS.APPT_DATE AS FIRST_APPT,
   RFL_APPTS.COMPLETED_CNT,
   RFL_APPTS.CANCELED_CNT,
   mdm.service_line_id,
   mdm.service_line,
   mdm.POD_ID,
   mdm.PFA_POD 

FROM 
   CLARITY.dbo.REFERRAL
   LEFT OUTER JOIN CLARITY.dbo.REFERRAL_3 ON REFERRAL.REFERRAL_ID=REFERRAL_3.REFERRAL_ID
   LEFT OUTER JOIN CLARITY.dbo.PATIENT ON REFERRAL.PAT_ID = PATIENT.PAT_ID
   LEFT OUTER JOIN CLARITY.dbo.CLARITY_DEP ON REFERRAL.REFD_TO_DEPT_ID = CLARITY_DEP.DEPARTMENT_ID
   LEFT OUTER JOIN CLARITY.dbo.CLARITY_SER ON REFERRAL.REFERRAL_PROV_ID = CLARITY_SER.PROV_ID 
   LEFT OUTER JOIN CLARITY.dbo.ZC_SPECIALTY ON REFERRAL.PROV_SPEC_C = ZC_SPECIALTY.SPECIALTY_C
   LEFT OUTER JOIN CLARITY.dbo.ZC_RFL_TYPE ON REFERRAL.RFL_TYPE_C = ZC_RFL_TYPE.RFL_TYPE_C
   LEFT OUTER JOIN CLARITY.dbo.ZC_RFL_CLASS ON REFERRAL.RFL_CLASS_C = ZC_RFL_CLASS.RFL_CLASS_C
   LEFT OUTER JOIN CLARITY.dbo.ZC_RFL_STATUS ON REFERRAL.RFL_STATUS_C = ZC_RFL_STATUS.RFL_STATUS_C
   LEFT OUTER JOIN CLARITY.dbo.REFERRAL_SOURCE ON REFERRAL.REFERRING_PROV_ID = REFERRAL_SOURCE.REFERRING_PROV_ID
   LEFT OUTER JOIN CLARITY.dbo.CLARITY_SER AS REFERRING_SER  ON REFERRING_SER.PROV_ID = REFERRAL_SOURCE.REF_PROVIDER_ID
   LEFT OUTER JOIN CLARITY.dbo.CLARITY_DEP AS REFERRING_DEP  ON REFERRING_DEP.DEPARTMENT_ID = REFERRAL.REFD_BY_DEPT_ID
   LEFT OUTER JOIN
      ( SELECT REFERRAL_ID, CHANGE_DATETIME
         FROM CLARITY.dbo.REFERRAL_HIST
         WHERE REFERRAL_HIST.LINE = (	SELECT MAX(RFLHX.LINE) 
                                 FROM CLARITY.dbo.REFERRAL_HIST RFLHX
                                 WHERE RFLHX.CHANGE_TYPE_C IN (53,39)
                                 AND RFLHX.REFERRAL_ID = REFERRAL_HIST.REFERRAL_ID)) AS AUTH_CHANGE ON AUTH_CHANGE.REFERRAL_ID = REFERRAL.REFERRAL_ID

   LEFT OUTER JOIN
      ( SELECT rh.REFERRAL_ID, rh.LINE, rh.CHANGE_DATE, rh.CHANGE_TYPE_C, rhct.NAME AS CHANGE_TYPE_NAME, rh.CHANGE_USER_ID, emp.NAME AS CHANGE_USER_NAME, rh.PREVIOUS_VALUE, rh.CHANGE_DATETIME
         FROM CLARITY.dbo.REFERRAL_HIST rh
         LEFT OUTER JOIN CLARITY.dbo.CLARITY_EMP emp ON emp.USER_ID = rh.CHANGE_USER_ID
         LEFT OUTER JOIN CLARITY.dbo.ZC_RFL_HST_CHG_TYP rhct ON rhct.CHANGE_TYPE_C = rh.CHANGE_TYPE_C
         WHERE rh.LINE = (	SELECT MAX(RFLHX.LINE) 
                                 FROM CLARITY.dbo.REFERRAL_HIST RFLHX
                                 LEFT OUTER JOIN CLARITY.dbo.ZC_RFL_HST_CHG_TYP rhct ON rhct.CHANGE_TYPE_C    = RFLHX.CHANGE_TYPE_C
                                 WHERE RFLHX.CHANGE_USER_ID NOT IN (''RFLEOD'',''RTEUSERIN'',''CADENCEEOD'',''KBSQL'')
								 AND (rhct.NAME LIKE ''%Schedul%'' AND rhct.NAME NOT IN (''RFLEOD'',''CADENCEEOD''))
                                 AND RFLHX.REFERRAL_ID = rh.REFERRAL_ID)) AS SCHED_CHANGE ON SCHED_CHANGE.REFERRAL_ID = REFERRAL.REFERRAL_ID
   
   LEFT OUTER JOIN 
      ( SELECT RFL.REFERRAL_ID RFL_ID,
         COUNT(DISTINCT RFL_ENC.PAT_ENC_CSN_ID) ACTUAL_CNT,
         MIN(RFL_ENC.APPT_MADE_DATE) APPT_MADE_DATE,
         MIN(RFL_ENC.APPT_MADE_DTTM) APPT_MADE_DTTM,
         MIN(RFL_ENC.CONTACT_DATE) APPT_DATE,
		 SUM(CASE WHEN RFL_ENC.APPT_STATUS_C = 1 THEN 1 ELSE 0 END) SCHEDULED_CNT,
		 SUM(CASE WHEN RFL_ENC.APPT_STATUS_C = 2 THEN 1 ELSE 0 END) COMPLETED_CNT,
		 SUM(CASE WHEN RFL_ENC.APPT_STATUS_C = 3 THEN 1 ELSE 0 END) CANCELED_CNT,
		 SUM(CASE WHEN RFL_ENC.APPT_STATUS_C = 4 THEN 1 ELSE 0 END) NO_SHOW_CNT,
		 SUM(CASE WHEN RFL_ENC.APPT_STATUS_C = 6 THEN 1 ELSE 0 END) ARRIVED_CNT
         FROM CLARITY.dbo.REFERRAL RFL
         INNER JOIN CLARITY.dbo.V_SCHED_APPT RFL_ENC ON RFL_ENC.REFERRAL_ID = RFL.REFERRAL_ID
         GROUP BY RFL.REFERRAL_ID) RFL_APPTS ON RFL_APPTS.RFL_ID = REFERRAL.REFERRAL_ID
   LEFT OUTER JOIN
    (
	    SELECT day_date,
               fmonth_num,
               Fyear_num,
               FYear_name
        FROM CLARITY_App.Rptg.vwDim_Date
    ) date_dim
	ON (date_dim.day_date = CAST(REFERRAL.EXP_DATE AS SMALLDATETIME))
    LEFT OUTER JOIN CLARITY_App.Rptg.vwRef_MDM_Location_Master_EpicSvc mdm
    ON REFERRAL.REFD_BY_DEPT_ID = mdm.epic_department_id
   
WHERE (REFERRAL_3.AUTH_CERT_YN IS NULL OR REFERRAL_3.AUTH_CERT_YN=''N'')
      AND REFERRAL.ACTUAL_NUM_VISITS IS NOT NULL
	  AND (REFERRAL.EXP_DATE >= @CompletedStartDate AND REFERRAL.EXP_DATE <= @CompletedEndDate)
      AND (COALESCE(mdm.' + @DepartmentGrouperColumn + ',''' + @DepartmentGrouperNoValue + ''') IN (SELECT pod_Service_Line FROM cte_pods_servLine)) AND (REFERRAL.REFD_BY_DEPT_ID IN (SELECT DepartmentId FROM cte_depid))

ORDER BY SCHED_CHANGE.CHANGE_DATETIME
       , REFERRAL.REFERRAL_ID';
SET @ParmDefinition = N'@CompletedStartDate SMALLDATETIME, @CompletedEndDate SMALLDATETIME, @PodServiceLine VARCHAR(MAX), @DepartmentId VARCHAR(MAX)';
EXECUTE sp_executesql @SelectString, @ParmDefinition, @CompletedStartDate=@locstartdate, @CompletedEndDate=@locenddate, @PodServiceLine=@in_pods_servLine, @DepartmentId=@in_depid;
END
GO


