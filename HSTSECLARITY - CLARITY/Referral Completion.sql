USE CLARITY

DECLARE	@startdate	SMALLDATETIME
DECLARE	@enddate	SMALLDATETIME

SET @startdate = '7/1/2019'
SET @enddate = '6/6/2022'
/*
   SELECT

   REFERRAL.REFERRAL_ID AS RFL_ID,
   REFERRAL.ENTRY_DATE AS CREATION_DATE,
   REFERRAL.EXP_DATE,
   REFERRAL.RFL_STATUS_C AS REFERRAL_STATUS_C,
   ZC_RFL_STATUS.NAME AS REFERRAL_STATUS_NAME,
   REFERRAL.EXTERNAL_ID_NUM AS EXTERNAL_ID,
   REFERRAL.RFL_CLASS_C AS CLASS,
   ZC_RFL_CLASS.NAME AS CLASS_NAME,
   REFERRAL.RFL_TYPE_C AS TYPE,
   ZC_RFL_TYPE.NAME AS TYPE_NAME,
   REFERRAL.PROV_SPEC_C AS PROV_SPEC,
   ZC_SPECIALTY.NAME AS PROV_SPEC_NAME,
   REFERRAL.REFD_TO_SPEC_C AS DEPT_SPEC,
   ZC_SPECIALTY_DEP.NAME AS DEPT_SPEC_NAME,
   REFERRAL_SOURCE.REF_PROVIDER_ID AS REFERRING_PROV_ID,
   REFERRING_SER.PROV_NAME AS REFERRING_PROV_NAME,
   REFERRAL.REFD_BY_DEPT_ID AS REFERRING_DEPT_ID,
   REFERRING_DEP.DEPARTMENT_NAME AS REFERRING_DEPT_NAME,
   REFERRAL.REFD_BY_LOC_POS_ID AS REFERRING_LOC_ID,
   REFERRING_LOC.LOC_NAME AS REFERRING_LOC_NAME,
   PATIENT.PAT_NAME AS PATIENT_NAME,
   REFERRAL.ACTUAL_NUM_VISITS, 
   REFERRAL_2.AP_CLAIM_COUNT,
   DATE_DIMENSION.WEEK_NUMBER AS WEEK_OF_YEAR,
   DATE_DIMENSION.YEAR_MONTH AS YEAR_MONTH,
   DATE_DIMENSION.CALENDAR_DT AS CALENDAR_DT,
   DATE_DIMENSION.WEEK_BEGIN_DT AS WEEK_BEGIN_DT,
   DATE_DIMENSION.MONTH_BEGIN_DT AS MONTH_BEGIN_DT,
   DATE_DIMENSION.QUARTER_BEGIN_DT AS QUARTER_BEGIN_DT,
   REFERRAL.REFD_TO_DEPT_ID AS DEPARTMENT_ID,
   REFERRAL.SERV_AREA_ID AS SERV_AREA_ID,
   CLARITY_SER.PROV_ID AS REFERRAL_PROV_ID,
   REFERRAL.REFD_TO_LOC_POS_ID AS LOC_ID,
   CLARITY_DEP.DEPARTMENT_NAME AS DEPARTMENT_NAME,
   CLARITY_SA.SERV_AREA_NAME AS SERV_AREA_NAME,
   CLARITY_SER.PROV_NAME AS REFERRAL_PROV_NAME,
   CLARITY_LOC.LOC_NAME AS LOC_NAME,
   AUTH_CHANGE.CHANGE_DATETIME AS AUTH_DATE,
   REFERRAL.SCHED_STATUS_C,
   ZC_SCHED_STATUS.NAME AS SCHED_STATUS_NAME,
   RFL_APPTS.APPT_MADE_DATE,
   RFL_APPTS.APPT_DATE,
   RFL_APPTS.ACTUAL_CNT,

   --CASE
   --   WHEN {?Price Estimate} = 1
   --      THEN PRICE_AVG.PROF_AVG + PRICE_AVG.HSP_AVG
   --   WHEN {?Price Estimate} = 2
   --      THEN PRICE_AVG.PROF_AVG
   --   WHEN {?Price Estimate} = 3
   --      THEN PRICE_AVG.HSP_AVG
   --   ELSE
   --      NULL         
   --END AS PRICE,
   WQ_TBL.WQ_COUNT AS WQ_COUNT,
   DATE_DIMENSION.YEAR_QUARTER AS ENTRY_DATE_YEAR_Q,
   DATE_DIMENSION.MONTHNAME_YEAR AS ENTRY_DATE_MONTH_NAME_YAS
*/
/*
   SELECT

   REFERRAL.REFERRAL_ID,
   REFERRAL.ENTRY_DATE,
   AUTH_CHANGE.CHANGE_DATETIME AS AUTH_DATE,
   REFERRAL.EXP_DATE,
   ZC_RFL_CLASS.NAME AS REFERRAL_CLASS,
   ZC_RFL_TYPE.NAME AS REFERRAL_TYPE,
   REFERRAL.REFD_BY_DEPT_ID AS REFERRING_DEPT_ID,
   REFERRING_DEP.DEPARTMENT_NAME AS REFERRING_DEPT_NAME,
   REFERRAL_SOURCE.REF_PROVIDER_ID AS REFERRING_PROV_ID,
   REFERRING_SER.PROV_NAME AS REFERRING_PROV_NAME,
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
   RFL_APPTS.APPT_MADE_DTTM AS FIRST_APPT_MADE, -- First scheduled appointment datetime
   RFL_APPTS.APPT_DATE AS FIRST_APPT,  -- First scheduled appointment
   RFL_APPTS.COMPLETED_CNT,
   RFL_APPTS.CANCELED_CNT
   --REFERRAL.SCHED_STATUS_C,
   --ZC_SCHED_STATUS.NAME AS SCHED_STATUS_NAME,
   --RFL_APPTS.APPT_MADE_DATE,
   --RFL_APPTS.APPT_DATE,
   --RFL_APPTS.ACTUAL_CNT,

   --CASE
   --   WHEN {?Price Estimate} = 1
   --      THEN PRICE_AVG.PROF_AVG + PRICE_AVG.HSP_AVG
   --   WHEN {?Price Estimate} = 2
   --      THEN PRICE_AVG.PROF_AVG
   --   WHEN {?Price Estimate} = 3
   --      THEN PRICE_AVG.HSP_AVG
   --   ELSE
   --      NULL         
   --END AS PRICE,
   --WQ_TBL.WQ_COUNT AS WQ_COUNT,
   --DATE_DIMENSION.YEAR_QUARTER AS ENTRY_DATE_YEAR_Q,
   --DATE_DIMENSION.MONTHNAME_YEAR AS ENTRY_DATE_MONTH_NAME_YAS    

FROM 
   --(SELECT DISTINCT EPIC_UTIL.EFN_DIN('{?Start Date}') AS START_DATE, EPIC_UTIL.EFN_DIN('{?End Date}') AS END_DATEAS  FROM ZC_YES_NO) AS DATES
   (SELECT DISTINCT EPIC_UTIL.EFN_DIN(@startdate) START_DATE, EPIC_UTIL.EFN_DIN(@enddate) END_DATE FROM ZC_YES_NO) DATES
   INNER JOIN DATE_DIMENSION ON DATE_DIMENSION.CALENDAR_DT BETWEEN DATES.START_DATE AND DATES.END_DATE
   --INNER JOIN REFERRAL ON DATE_DIMENSION.CALENDAR_DT = REFERRAL.ENTRY_DATE
   INNER JOIN REFERRAL ON DATE_DIMENSION.CALENDAR_DT = REFERRAL.EXP_DATE
   --LEFT OUTER JOIN REFERRAL_2 ON REFERRAL.REFERRAL_ID=REFERRAL_2.REFERRAL_ID
   LEFT OUTER JOIN REFERRAL_3 ON REFERRAL.REFERRAL_ID=REFERRAL_3.REFERRAL_ID
   LEFT OUTER JOIN PATIENT ON REFERRAL.PAT_ID = PATIENT.PAT_ID
   --LEFT OUTER JOIN CLARITY_SA ON REFERRAL.SERV_AREA_ID = CLARITY_SA.SERV_AREA_ID
   LEFT OUTER JOIN CLARITY_DEP ON REFERRAL.REFD_TO_DEPT_ID = CLARITY_DEP.DEPARTMENT_ID
   --LEFT OUTER JOIN CLARITY_LOC ON REFERRAL.REFD_TO_LOC_POS_ID = CLARITY_LOC.LOC_ID
   LEFT OUTER JOIN CLARITY_SER ON REFERRAL.REFERRAL_PROV_ID = CLARITY_SER.PROV_ID 
   --LEFT OUTER JOIN REFERRAL_ORDER_ID ON REFERRAL_ORDER_ID.REFERRAL_ID=REFERRAL.REFERRAL_ID AND REFERRAL_ORDER_ID.LINE=1
   --LEFT OUTER JOIN ORDER_PROC ON ORDER_PROC.ORDER_PROC_ID=REFERRAL_ORDER_ID.ORDER_ID
   --LEFT OUTER JOIN ZC_SPECIALTY_DEP ON REFERRAL.REFD_TO_SPEC_C = ZC_SPECIALTY_DEP.SPECIALTY_DEP_C
   LEFT OUTER JOIN ZC_SPECIALTY ON REFERRAL.PROV_SPEC_C = ZC_SPECIALTY.SPECIALTY_C
   LEFT OUTER JOIN ZC_RFL_TYPE ON REFERRAL.RFL_TYPE_C = ZC_RFL_TYPE.RFL_TYPE_C
   LEFT OUTER JOIN ZC_RFL_CLASS ON REFERRAL.RFL_CLASS_C = ZC_RFL_CLASS.RFL_CLASS_C
   LEFT OUTER JOIN ZC_RFL_STATUS ON REFERRAL.RFL_STATUS_C = ZC_RFL_STATUS.RFL_STATUS_C
   LEFT OUTER JOIN REFERRAL_SOURCE ON REFERRAL.REFERRING_PROV_ID = REFERRAL_SOURCE.REFERRING_PROV_ID
   LEFT OUTER JOIN CLARITY_SER AS REFERRING_SER  ON REFERRING_SER.PROV_ID = REFERRAL_SOURCE.REF_PROVIDER_ID
   LEFT OUTER JOIN CLARITY_DEP AS REFERRING_DEP  ON REFERRING_DEP.DEPARTMENT_ID = REFERRAL.REFD_BY_DEPT_ID
   --LEFT OUTER JOIN CLARITY_LOC AS REFERRING_LOC  ON REFERRAL.REFD_BY_LOC_POS_ID = REFERRING_LOC.LOC_ID
   --LEFT OUTER JOIN COVERAGE ON COVERAGE.COVERAGE_ID = REFERRAL.COVERAGE_ID
   LEFT OUTER JOIN
      ( SELECT REFERRAL_ID, CHANGE_DATETIME
         FROM REFERRAL_HIST
         WHERE REFERRAL_HIST.LINE = (	SELECT MAX(RFLHX.LINE) 
                                 FROM REFERRAL_HIST RFLHX
                                 WHERE RFLHX.CHANGE_TYPE_C IN (53,39)
                                 --AND (RFLHX.AUTH_HX_ITEM_VALUE IN {?Authorized Statuses})
                                 AND RFLHX.REFERRAL_ID = REFERRAL_HIST.REFERRAL_ID)) AS AUTH_CHANGE ON AUTH_CHANGE.REFERRAL_ID = REFERRAL.REFERRAL_ID

   LEFT OUTER JOIN
      ( SELECT rh.REFERRAL_ID, rh.LINE, rh.CHANGE_DATE, rh.CHANGE_TYPE_C, rhct.NAME AS CHANGE_TYPE_NAME, rh.CHANGE_USER_ID, emp.NAME AS CHANGE_USER_NAME, rh.PREVIOUS_VALUE, rh.CHANGE_DATETIME
         FROM REFERRAL_HIST rh
         LEFT OUTER JOIN dbo.CLARITY_EMP emp ON emp.USER_ID = rh.CHANGE_USER_ID
         LEFT OUTER JOIN dbo.ZC_RFL_HST_CHG_TYP rhct ON rhct.CHANGE_TYPE_C = rh.CHANGE_TYPE_C
         WHERE rh.LINE = (	SELECT MAX(RFLHX.LINE) 
                                 FROM REFERRAL_HIST RFLHX
                                 LEFT OUTER JOIN dbo.ZC_RFL_HST_CHG_TYP rhct ON rhct.CHANGE_TYPE_C    = RFLHX.CHANGE_TYPE_C
                                 WHERE RFLHX.CHANGE_USER_ID NOT IN ('RFLEOD','RTEUSERIN','CADENCEEOD','KBSQL')
								 AND (rhct.NAME LIKE '%Schedul%' AND rhct.NAME NOT IN ('RFLEOD','CADENCEEOD'))
                                 AND RFLHX.REFERRAL_ID = rh.REFERRAL_ID)) AS SCHED_CHANGE ON SCHED_CHANGE.REFERRAL_ID = REFERRAL.REFERRAL_ID

   --LEFT OUTER JOIN 
   --   ( SELECT RFL.REFERRAL_ID AS RFL_ID,
   --      COUNT(DISTINCT RFL_ENC.PAT_ENC_CSN_ID) AS ACTUAL_CNT,
   --      MIN(RFL_ENC.APPT_MADE_DATE) AS APPT_MADE_DATE, -- First scheduled appointment
   --      MIN(RFL_ENC.CONTACT_DATE) AS APPT_DATE   -- First scheduled appointment
   --      FROM REFERRAL AS RFL 
   --      INNER JOIN V_SCHED_APPT AS RFL_ENC ON RFL_ENC.REFERRAL_ID = RFL.REFERRAL_ID
   --      WHERE RFL_ENC.APPT_STATUS_C IN (1,2,6) OR RFL_ENC.COMPLETED_STATUS_YN='Y'
   --      GROUP BY RFL.REFERRAL_ID) AS RFL_APPTS ON RFL_APPTS.RFL_ID = REFERRAL.REFERRAL_ID
   
   LEFT OUTER JOIN 
      ( SELECT RFL.REFERRAL_ID RFL_ID,
         COUNT(DISTINCT RFL_ENC.PAT_ENC_CSN_ID) ACTUAL_CNT,
         MIN(RFL_ENC.APPT_MADE_DATE) APPT_MADE_DATE, -- First scheduled appointment date
         MIN(RFL_ENC.APPT_MADE_DTTM) APPT_MADE_DTTM, -- First scheduled appointment datetime
         MIN(RFL_ENC.CONTACT_DATE) APPT_DATE,  -- First scheduled appointment
		 SUM(CASE WHEN RFL_ENC.APPT_STATUS_C = 1 THEN 1 ELSE 0 END) SCHEDULED_CNT,
		 SUM(CASE WHEN RFL_ENC.APPT_STATUS_C = 2 THEN 1 ELSE 0 END) COMPLETED_CNT,
		 SUM(CASE WHEN RFL_ENC.APPT_STATUS_C = 3 THEN 1 ELSE 0 END) CANCELED_CNT,
		 SUM(CASE WHEN RFL_ENC.APPT_STATUS_C = 4 THEN 1 ELSE 0 END) NO_SHOW_CNT,
		 SUM(CASE WHEN RFL_ENC.APPT_STATUS_C = 6 THEN 1 ELSE 0 END) ARRIVED_CNT
         FROM REFERRAL RFL
         INNER JOIN V_SCHED_APPT RFL_ENC ON RFL_ENC.REFERRAL_ID = RFL.REFERRAL_ID
         --WHERE RFL_ENC.APPT_STATUS_C IN (1,2,6) OR RFL_ENC.COMPLETED_STATUS_YN='Y' -- Scheduled, Completed, Arrived
         GROUP BY RFL.REFERRAL_ID) RFL_APPTS ON RFL_APPTS.RFL_ID = REFERRAL.REFERRAL_ID

   --LEFT OUTER JOIN
   --   ( SELECT RFL.REFERRAL_ID AS REFERRAL_ID,
   --      COUNT(WQI.ITEM_ID) AS WQ_COUNT 
   --      FROM REFERRAL RFL
   --      INNER JOIN REFERRAL_WQ_ITEMS WQI ON RFL.REFERRAL_ID = WQI.REFERRAL_ID
   --      GROUP BY RFL.REFERRAL_ID) AS WQ_TBL  ON REFERRAL.REFERRAL_ID = WQ_TBL.REFERRAL_ID

   --LEFT OUTER JOIN 
   --  (  SELECT F.PX_ID AS PX_ID, AVG(F.PROF_CHARGE) AS PROF_AVG, AVG(F.HSP_CHARGE) AS HSP_AVGAS 
   --     FROM F_REFERRAL_PRICE F
   --     INNER JOIN V_MONTHSBACK V ON V.MONTHS_BACK = {?Months Back}
   --     WHERE F.ENTRY_DATE > V.MONTH_BEGIN_DT
   --      GROUP BY F.PX_ID) AS PRICE_AVG ON PRICE_AVG.PX_ID = ORDER_PROC.PROC_ID

   --LEFT OUTER JOIN dbo.ZC_SCHED_STATUS AS ZC_SCHED_STATUS ON ZC_SCHED_STATUS.SCHED_STATUS_C = REFERRAL.SCHED_STATUS_C
   
WHERE (REFERRAL_3.AUTH_CERT_YN IS NULL OR REFERRAL_3.AUTH_CERT_YN='N')
      --AND ('-1' IN {?Referral Type} OR REFERRAL.RFL_TYPE_C IN {?Referral Type})
      --AND (-1 IN {?Referring Location} OR REFERRAL.REFD_BY_LOC_POS_ID IN {?Referring Location})
      --AND (-1 IN {?Referring Department} OR REFERRAL.REFD_BY_DEPT_ID IN {?Referring Department})
      AND REFERRAL.REFD_BY_DEPT_ID = 10228012
      --AND ('-1' IN {?Referring Provider} OR REFERRAL_SOURCE.REF_PROVIDER_ID IN {?Referring Provider})
      --AND ('-1' IN {?Referred to Vendor} OR REFERRAL.VENDOR_ID IN {?Referred to Vendor})
      --AND (-1 IN {?Referred to Location} OR REFERRAL.REFD_TO_LOC_POS_ID IN {?Referred to Location})
      --AND (-1 IN {?Referred to Department} OR REFERRAL.REFD_TO_DEPT_ID IN {?Referred to Department})
      --AND REFERRAL.REFD_TO_DEPT_ID = 10211008
      --AND ('-1' IN {?Referred to Department Specialty} OR REFERRAL.REFD_TO_SPEC_C IN {?Referred to Department Specialty})
      --AND ('-1' IN {?Referred to Provider} OR REFERRAL.REFERRAL_PROV_ID IN {?Referred to Provider})
      --AND ('-1' IN {?Referred to Provider Specialty} OR REFERRAL.PROV_SPEC_C IN {?Referred to Provider Specialty})
      --AND ('-1' IN {?Priority} OR REFERRAL.PRIORITY_C IN {?Priority})
      --AND (-1 IN {?Sensitivity} OR REFERRAL.RFL_SENS_C IN {?Sensitivity})
      --AND (-1 IN {?Scheduling Status} OR REFERRAL.SCHED_STATUS_C IN {?Scheduling Status})
      --AND ('-1' IN {?Referral Class} OR REFERRAL.RFL_CLASS_C IN {?Referral Class})
      --AND (-1 IN {?Referral Flags} OR EXISTS (SELECT 1 FROM REFERRAL_FLAGS WHERE REFERRAL_FLAGS.FLAG_C IN {?Referral Flags} AND REFERRAL.REFERRAL_ID = REFERRAL_FLAGS.REFERRAL_ID))
      --AND (-1 IN {?Diagnosis} OR EXISTS (SELECT 1 FROM REFERRAL_DX WHERE REFERRAL_DX.DX_ID IN {?Diagnosis} AND REFERRAL.REFERRAL_ID = REFERRAL_DX.REFERRAL_ID))
      --AND (-1 IN {?Payor} OR REFERRAL.PAYOR_ID IN {?Payor})
      --AND (-1 IN {?Procedure} OR EXISTS (SELECT 1 FROM REFERRAL_ORDER_ID INNER JOIN ORDER_PROC ON REFERRAL_ORDER_ID.ORDER_ID = ORDER_PROC.ORDER_PROC_ID
      --                  WHERE ORDER_PROC.PROC_ID IN {?Procedure} AND REFERRAL.REFERRAL_ID = REFERRAL_ORDER_ID.REFERRAL_ID))
      --AND (-1 IN {?Plan} OR REFERRAL.PLAN_ID IN {?Plan})
      --AND ( (REFERRAL.RFL_CLASS_C IS NULL) OR ({?Include Outgoing Referrals?} = 1) OR (REFERRAL.RFL_CLASS_C <> '3' ))
      --AND (-1 IN {?Coverage Type} OR  COVERAGE.COVERAGE_TYPE_C IN {?Coverage Type})
	  AND REFERRAL.ACTUAL_NUM_VISITS IS NOT NULL

--ORDER BY ENTRY_DATE
--       , REFERRAL.REFERRAL_ID
--ORDER BY CLARITY_DEP.DEPARTMENT_ID
--       , EXP_DATE
--       , REFERRAL.REFERRAL_ID
ORDER BY SCHED_CHANGE.CHANGE_DATETIME
       , REFERRAL.REFERRAL_ID
*/
/*
   SELECT DISTINCT

   REFERRAL.REFERRAL_ID,
   REFERRAL.ENTRY_DATE,
   AUTH_CHANGE.CHANGE_DATETIME AS AUTH_DATE,
   REFERRAL.EXP_DATE,
   ZC_RFL_CLASS.NAME AS REFERRAL_CLASS,
   ZC_RFL_TYPE.NAME AS REFERRAL_TYPE,
   REFERRAL.REFD_BY_DEPT_ID AS REFERRING_DEPT_ID,
   REFERRING_DEP.DEPARTMENT_NAME AS REFERRING_DEPT_NAME,
   REFERRAL_SOURCE.REF_PROVIDER_ID AS REFERRING_PROV_ID,
   REFERRING_SER.PROV_NAME AS REFERRING_PROV_NAME,
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
   RFL_APPTS.APPT_MADE_DTTM AS FIRST_APPT_MADE, -- First scheduled appointment datetime
   RFL_APPTS.APPT_DATE AS FIRST_APPT,  -- First scheduled appointment
   RFL_APPTS.COMPLETED_CNT,
   RFL_APPTS.CANCELED_CNT
   --REFERRAL.SCHED_STATUS_C,
   --ZC_SCHED_STATUS.NAME AS SCHED_STATUS_NAME,
   --RFL_APPTS.APPT_MADE_DATE,
   --RFL_APPTS.APPT_DATE,
   --RFL_APPTS.ACTUAL_CNT,

   --CASE
   --   WHEN {?Price Estimate} = 1
   --      THEN PRICE_AVG.PROF_AVG + PRICE_AVG.HSP_AVG
   --   WHEN {?Price Estimate} = 2
   --      THEN PRICE_AVG.PROF_AVG
   --   WHEN {?Price Estimate} = 3
   --      THEN PRICE_AVG.HSP_AVG
   --   ELSE
   --      NULL         
   --END AS PRICE,
   --WQ_TBL.WQ_COUNT AS WQ_COUNT,
   --DATE_DIMENSION.YEAR_QUARTER AS ENTRY_DATE_YEAR_Q,
   --DATE_DIMENSION.MONTHNAME_YEAR AS ENTRY_DATE_MONTH_NAME_YAS    

FROM 
   ----(SELECT DISTINCT EPIC_UTIL.EFN_DIN('{?Start Date}') AS START_DATE, EPIC_UTIL.EFN_DIN('{?End Date}') AS END_DATEAS  FROM ZC_YES_NO) AS DATES
   --(SELECT DISTINCT EPIC_UTIL.EFN_DIN(@startdate) START_DATE, EPIC_UTIL.EFN_DIN(@enddate) END_DATE FROM ZC_YES_NO) DATES
   --INNER JOIN DATE_DIMENSION ON DATE_DIMENSION.CALENDAR_DT BETWEEN DATES.START_DATE AND DATES.END_DATE
   ----INNER JOIN REFERRAL ON DATE_DIMENSION.CALENDAR_DT = REFERRAL.ENTRY_DATE
   --INNER JOIN REFERRAL ON DATE_DIMENSION.CALENDAR_DT = REFERRAL.EXP_DATE
   REFERRAL
   --LEFT OUTER JOIN REFERRAL_2 ON REFERRAL.REFERRAL_ID=REFERRAL_2.REFERRAL_ID
   LEFT OUTER JOIN REFERRAL_3 ON REFERRAL.REFERRAL_ID=REFERRAL_3.REFERRAL_ID
   LEFT OUTER JOIN PATIENT ON REFERRAL.PAT_ID = PATIENT.PAT_ID
   --LEFT OUTER JOIN CLARITY_SA ON REFERRAL.SERV_AREA_ID = CLARITY_SA.SERV_AREA_ID
   LEFT OUTER JOIN CLARITY_DEP ON REFERRAL.REFD_TO_DEPT_ID = CLARITY_DEP.DEPARTMENT_ID
   --LEFT OUTER JOIN CLARITY_LOC ON REFERRAL.REFD_TO_LOC_POS_ID = CLARITY_LOC.LOC_ID
   LEFT OUTER JOIN CLARITY_SER ON REFERRAL.REFERRAL_PROV_ID = CLARITY_SER.PROV_ID 
   --LEFT OUTER JOIN REFERRAL_ORDER_ID ON REFERRAL_ORDER_ID.REFERRAL_ID=REFERRAL.REFERRAL_ID AND REFERRAL_ORDER_ID.LINE=1
   --LEFT OUTER JOIN ORDER_PROC ON ORDER_PROC.ORDER_PROC_ID=REFERRAL_ORDER_ID.ORDER_ID
   --LEFT OUTER JOIN ZC_SPECIALTY_DEP ON REFERRAL.REFD_TO_SPEC_C = ZC_SPECIALTY_DEP.SPECIALTY_DEP_C
   LEFT OUTER JOIN ZC_SPECIALTY ON REFERRAL.PROV_SPEC_C = ZC_SPECIALTY.SPECIALTY_C
   LEFT OUTER JOIN ZC_RFL_TYPE ON REFERRAL.RFL_TYPE_C = ZC_RFL_TYPE.RFL_TYPE_C
   LEFT OUTER JOIN ZC_RFL_CLASS ON REFERRAL.RFL_CLASS_C = ZC_RFL_CLASS.RFL_CLASS_C
   LEFT OUTER JOIN ZC_RFL_STATUS ON REFERRAL.RFL_STATUS_C = ZC_RFL_STATUS.RFL_STATUS_C
   LEFT OUTER JOIN REFERRAL_SOURCE ON REFERRAL.REFERRING_PROV_ID = REFERRAL_SOURCE.REFERRING_PROV_ID
   LEFT OUTER JOIN CLARITY_SER AS REFERRING_SER  ON REFERRING_SER.PROV_ID = REFERRAL_SOURCE.REF_PROVIDER_ID
   LEFT OUTER JOIN CLARITY_DEP AS REFERRING_DEP  ON REFERRING_DEP.DEPARTMENT_ID = REFERRAL.REFD_BY_DEPT_ID
   --LEFT OUTER JOIN CLARITY_LOC AS REFERRING_LOC  ON REFERRAL.REFD_BY_LOC_POS_ID = REFERRING_LOC.LOC_ID
   --LEFT OUTER JOIN COVERAGE ON COVERAGE.COVERAGE_ID = REFERRAL.COVERAGE_ID
   LEFT OUTER JOIN
      ( SELECT REFERRAL_ID, CHANGE_DATETIME
         FROM REFERRAL_HIST
         WHERE REFERRAL_HIST.LINE = (	SELECT MAX(RFLHX.LINE) 
                                 FROM REFERRAL_HIST RFLHX
                                 WHERE RFLHX.CHANGE_TYPE_C IN (53,39)
                                 --AND (RFLHX.AUTH_HX_ITEM_VALUE IN {?Authorized Statuses})
                                 AND RFLHX.REFERRAL_ID = REFERRAL_HIST.REFERRAL_ID)) AS AUTH_CHANGE ON AUTH_CHANGE.REFERRAL_ID = REFERRAL.REFERRAL_ID

   LEFT OUTER JOIN
      ( SELECT rh.REFERRAL_ID, rh.LINE, rh.CHANGE_DATE, rh.CHANGE_TYPE_C, rhct.NAME AS CHANGE_TYPE_NAME, rh.CHANGE_USER_ID, emp.NAME AS CHANGE_USER_NAME, rh.PREVIOUS_VALUE, rh.CHANGE_DATETIME
         FROM REFERRAL_HIST rh
         LEFT OUTER JOIN dbo.CLARITY_EMP emp ON emp.USER_ID = rh.CHANGE_USER_ID
         LEFT OUTER JOIN dbo.ZC_RFL_HST_CHG_TYP rhct ON rhct.CHANGE_TYPE_C = rh.CHANGE_TYPE_C
         WHERE rh.LINE = (	SELECT MAX(RFLHX.LINE) 
                                 FROM REFERRAL_HIST RFLHX
                                 LEFT OUTER JOIN dbo.ZC_RFL_HST_CHG_TYP rhct ON rhct.CHANGE_TYPE_C    = RFLHX.CHANGE_TYPE_C
                                 WHERE RFLHX.CHANGE_USER_ID NOT IN ('RFLEOD','RTEUSERIN','CADENCEEOD','KBSQL')
								 AND (rhct.NAME LIKE '%Schedul%' AND rhct.NAME NOT IN ('RFLEOD','CADENCEEOD'))
                                 AND RFLHX.REFERRAL_ID = rh.REFERRAL_ID)) AS SCHED_CHANGE ON SCHED_CHANGE.REFERRAL_ID = REFERRAL.REFERRAL_ID

   --LEFT OUTER JOIN 
   --   ( SELECT RFL.REFERRAL_ID AS RFL_ID,
   --      COUNT(DISTINCT RFL_ENC.PAT_ENC_CSN_ID) AS ACTUAL_CNT,
   --      MIN(RFL_ENC.APPT_MADE_DATE) AS APPT_MADE_DATE, -- First scheduled appointment
   --      MIN(RFL_ENC.CONTACT_DATE) AS APPT_DATE   -- First scheduled appointment
   --      FROM REFERRAL AS RFL 
   --      INNER JOIN V_SCHED_APPT AS RFL_ENC ON RFL_ENC.REFERRAL_ID = RFL.REFERRAL_ID
   --      WHERE RFL_ENC.APPT_STATUS_C IN (1,2,6) OR RFL_ENC.COMPLETED_STATUS_YN='Y'
   --      GROUP BY RFL.REFERRAL_ID) AS RFL_APPTS ON RFL_APPTS.RFL_ID = REFERRAL.REFERRAL_ID
   
   LEFT OUTER JOIN 
      ( SELECT RFL.REFERRAL_ID RFL_ID,
         COUNT(DISTINCT RFL_ENC.PAT_ENC_CSN_ID) ACTUAL_CNT,
         MIN(RFL_ENC.APPT_MADE_DATE) APPT_MADE_DATE, -- First scheduled appointment date
         MIN(RFL_ENC.APPT_MADE_DTTM) APPT_MADE_DTTM, -- First scheduled appointment datetime
         MIN(RFL_ENC.CONTACT_DATE) APPT_DATE,  -- First scheduled appointment
		 SUM(CASE WHEN RFL_ENC.APPT_STATUS_C = 1 THEN 1 ELSE 0 END) SCHEDULED_CNT,
		 SUM(CASE WHEN RFL_ENC.APPT_STATUS_C = 2 THEN 1 ELSE 0 END) COMPLETED_CNT,
		 SUM(CASE WHEN RFL_ENC.APPT_STATUS_C = 3 THEN 1 ELSE 0 END) CANCELED_CNT,
		 SUM(CASE WHEN RFL_ENC.APPT_STATUS_C = 4 THEN 1 ELSE 0 END) NO_SHOW_CNT,
		 SUM(CASE WHEN RFL_ENC.APPT_STATUS_C = 6 THEN 1 ELSE 0 END) ARRIVED_CNT
         FROM REFERRAL RFL
         INNER JOIN V_SCHED_APPT RFL_ENC ON RFL_ENC.REFERRAL_ID = RFL.REFERRAL_ID
         --WHERE RFL_ENC.APPT_STATUS_C IN (1,2,6) OR RFL_ENC.COMPLETED_STATUS_YN='Y' -- Scheduled, Completed, Arrived
         GROUP BY RFL.REFERRAL_ID) RFL_APPTS ON RFL_APPTS.RFL_ID = REFERRAL.REFERRAL_ID

   --LEFT OUTER JOIN
   --   ( SELECT RFL.REFERRAL_ID AS REFERRAL_ID,
   --      COUNT(WQI.ITEM_ID) AS WQ_COUNT 
   --      FROM REFERRAL RFL
   --      INNER JOIN REFERRAL_WQ_ITEMS WQI ON RFL.REFERRAL_ID = WQI.REFERRAL_ID
   --      GROUP BY RFL.REFERRAL_ID) AS WQ_TBL  ON REFERRAL.REFERRAL_ID = WQ_TBL.REFERRAL_ID

   --LEFT OUTER JOIN 
   --  (  SELECT F.PX_ID AS PX_ID, AVG(F.PROF_CHARGE) AS PROF_AVG, AVG(F.HSP_CHARGE) AS HSP_AVGAS 
   --     FROM F_REFERRAL_PRICE F
   --     INNER JOIN V_MONTHSBACK V ON V.MONTHS_BACK = {?Months Back}
   --     WHERE F.ENTRY_DATE > V.MONTH_BEGIN_DT
   --      GROUP BY F.PX_ID) AS PRICE_AVG ON PRICE_AVG.PX_ID = ORDER_PROC.PROC_ID

   --LEFT OUTER JOIN dbo.ZC_SCHED_STATUS AS ZC_SCHED_STATUS ON ZC_SCHED_STATUS.SCHED_STATUS_C = REFERRAL.SCHED_STATUS_C
   
WHERE (REFERRAL_3.AUTH_CERT_YN IS NULL OR REFERRAL_3.AUTH_CERT_YN='N')
      --AND ('-1' IN {?Referral Type} OR REFERRAL.RFL_TYPE_C IN {?Referral Type})
      --AND (-1 IN {?Referring Location} OR REFERRAL.REFD_BY_LOC_POS_ID IN {?Referring Location})
      --AND (-1 IN {?Referring Department} OR REFERRAL.REFD_BY_DEPT_ID IN {?Referring Department})
      AND REFERRAL.REFD_BY_DEPT_ID = 10228012
      --AND ('-1' IN {?Referring Provider} OR REFERRAL_SOURCE.REF_PROVIDER_ID IN {?Referring Provider})
      --AND ('-1' IN {?Referred to Vendor} OR REFERRAL.VENDOR_ID IN {?Referred to Vendor})
      --AND (-1 IN {?Referred to Location} OR REFERRAL.REFD_TO_LOC_POS_ID IN {?Referred to Location})
      --AND (-1 IN {?Referred to Department} OR REFERRAL.REFD_TO_DEPT_ID IN {?Referred to Department})
      --AND REFERRAL.REFD_TO_DEPT_ID = 10211008
      --AND ('-1' IN {?Referred to Department Specialty} OR REFERRAL.REFD_TO_SPEC_C IN {?Referred to Department Specialty})
      --AND ('-1' IN {?Referred to Provider} OR REFERRAL.REFERRAL_PROV_ID IN {?Referred to Provider})
      --AND ('-1' IN {?Referred to Provider Specialty} OR REFERRAL.PROV_SPEC_C IN {?Referred to Provider Specialty})
      --AND ('-1' IN {?Priority} OR REFERRAL.PRIORITY_C IN {?Priority})
      --AND (-1 IN {?Sensitivity} OR REFERRAL.RFL_SENS_C IN {?Sensitivity})
      --AND (-1 IN {?Scheduling Status} OR REFERRAL.SCHED_STATUS_C IN {?Scheduling Status})
      --AND ('-1' IN {?Referral Class} OR REFERRAL.RFL_CLASS_C IN {?Referral Class})
      --AND (-1 IN {?Referral Flags} OR EXISTS (SELECT 1 FROM REFERRAL_FLAGS WHERE REFERRAL_FLAGS.FLAG_C IN {?Referral Flags} AND REFERRAL.REFERRAL_ID = REFERRAL_FLAGS.REFERRAL_ID))
      --AND (-1 IN {?Diagnosis} OR EXISTS (SELECT 1 FROM REFERRAL_DX WHERE REFERRAL_DX.DX_ID IN {?Diagnosis} AND REFERRAL.REFERRAL_ID = REFERRAL_DX.REFERRAL_ID))
      --AND (-1 IN {?Payor} OR REFERRAL.PAYOR_ID IN {?Payor})
      --AND (-1 IN {?Procedure} OR EXISTS (SELECT 1 FROM REFERRAL_ORDER_ID INNER JOIN ORDER_PROC ON REFERRAL_ORDER_ID.ORDER_ID = ORDER_PROC.ORDER_PROC_ID
      --                  WHERE ORDER_PROC.PROC_ID IN {?Procedure} AND REFERRAL.REFERRAL_ID = REFERRAL_ORDER_ID.REFERRAL_ID))
      --AND (-1 IN {?Plan} OR REFERRAL.PLAN_ID IN {?Plan})
      --AND ( (REFERRAL.RFL_CLASS_C IS NULL) OR ({?Include Outgoing Referrals?} = 1) OR (REFERRAL.RFL_CLASS_C <> '3' ))
      --AND (-1 IN {?Coverage Type} OR  COVERAGE.COVERAGE_TYPE_C IN {?Coverage Type})
	  AND REFERRAL.ACTUAL_NUM_VISITS IS NOT NULL
	  AND referral.EXP_DATE BETWEEN @startdate AND @enddate

--ORDER BY ENTRY_DATE
--       , REFERRAL.REFERRAL_ID
--ORDER BY CLARITY_DEP.DEPARTMENT_ID
--       , EXP_DATE
--       , REFERRAL.REFERRAL_ID
ORDER BY SCHED_CHANGE.CHANGE_DATETIME
       , REFERRAL.REFERRAL_ID
*/
/*
   SELECT DISTINCT

   REFERRAL.REFD_BY_DEPT_ID AS REFERRING_DEPT_ID,
   REFERRING_DEP.DEPARTMENT_NAME AS REFERRING_DEPT_NAME   

FROM 
   REFERRAL
   LEFT OUTER JOIN REFERRAL_3 ON REFERRAL.REFERRAL_ID=REFERRAL_3.REFERRAL_ID
   LEFT OUTER JOIN CLARITY_DEP AS REFERRING_DEP  ON REFERRING_DEP.DEPARTMENT_ID = REFERRAL.REFD_BY_DEPT_ID
   
WHERE (REFERRAL_3.AUTH_CERT_YN IS NULL OR REFERRAL_3.AUTH_CERT_YN='N')
	  AND REFERRAL.ACTUAL_NUM_VISITS IS NOT NULL
	  AND REFERRAL.REFD_BY_DEPT_ID IS NOT NULL
	  AND REFERRAL.EXP_DATE BETWEEN @startdate AND @enddate

ORDER BY REFERRING_DEP.DEPARTMENT_NAME
*/
/*
	SELECT REFERRAL.REFERRAL_ID
	      ,REFERRAL.EXP_DATE
		  ,REFERRAL.REFD_BY_DEPT_ID
		  ,mdm.epic_department_name
		  ,mdm.service_line
		  ,mdm.PFA_POD as pod_name
    FROM CLARITY.[dbo].[REFERRAL] REFERRAL
    LEFT OUTER JOIN REFERRAL_3 ON REFERRAL.REFERRAL_ID=REFERRAL_3.REFERRAL_ID
    LEFT OUTER JOIN CLARITY_App.Rptg.vwRef_MDM_Location_Master_EpicSvc mdm
    ON REFERRAL.REFD_BY_DEPT_ID = mdm.epic_department_id
   
    WHERE (REFERRAL_3.AUTH_CERT_YN IS NULL OR REFERRAL_3.AUTH_CERT_YN='N')
	      AND REFERRAL.ACTUAL_NUM_VISITS IS NOT NULL
	      AND REFERRAL.REFD_BY_DEPT_ID IS NOT NULL
	      AND REFERRAL.EXP_DATE BETWEEN @startdate AND @enddate

	ORDER BY mdm.epic_department_name
*/

SELECT DISTINCT
   --CAST('Completed Referral' AS VARCHAR(50)) AS event_type,
   CAST('Referral' AS VARCHAR(50)) AS event_type,
   --1 AS event_count,
   REFERRAL.ENTRY_DATE AS event_date,
   --REFERRAL.EXP_DATE AS event_date,
   REFERRAL.EXP_DATE,
   date_dim.fmonth_num,
   date_dim.Fyear_num,
   date_dim.FYear_name,
   CAST(LEFT(DATENAME(MM, date_dim.day_date), 3) + ' ' + CAST(DAY(date_dim.day_date) AS VARCHAR(2)) AS VARCHAR(10)) AS report_period,
   CAST(CAST(date_dim.day_date AS DATE) AS SMALLDATETIME) AS report_date,
   REFERRAL.REFERRAL_ID,
   REFERRAL.ENTRY_DATE,
   AUTH_CHANGE.CHANGE_DATETIME AS AUTH_DATE,
   ZC_RFL_CLASS.NAME AS REFERRAL_CLASS,
   ZC_RFL_TYPE.NAME AS REFERRAL_TYPE,
   prc.PRC_NAME,
   --REFERRAL.PRIM_LOC_ID AS REFERRING_LOC_ID, 
   LOC_FROM.LOC_NAME AS REFERRING_LOCATION,
   REFERRAL.REFD_BY_DEPT_ID,-- AS epic_department_id,
   REFERRING_DEP.DEPARTMENT_NAME AS REFD_BY_DEPT_NAME,--epic_department_name,
   CAST(PATIENT.PAT_MRN_ID AS INTEGER) AS person_id,
   PATIENT.PAT_NAME AS person_name,
   REFERRAL_SOURCE.REF_PROVIDER_ID AS REFERRING_PROVIDER_ID,--provider_id,
   REFERRING_SER.PROV_NAME AS REFERRING_PROVIDER_NAME,--provider_name,
   --REFERRAL.REFD_BY_DEPT_ID AS REFERRING_DEPT_ID,
   --REFERRING_DEP.DEPARTMENT_NAME AS REFERRING_DEPT_NAME,
   --REFERRAL_SOURCE.REF_PROVIDER_ID AS REFERRING_PROV_ID,
   --REFERRING_SER.PROV_NAME AS REFERRING_PROV_NAME,
   --REFERRAL.REFD_TO_LOC_POS_ID AS REFD_TO_LOC_ID,
   ISNULL(REFD_TO_LOC.LOC_NAME, 'Unknown') AS REFD_TO_LOCATION,
   CLARITY_DEP.DEPARTMENT_ID AS REFERRED_TO_DEPT_ID,
   CLARITY_DEP.DEPARTMENT_NAME AS REFERRED_TO_DEPT_NAME,
   CLARITY_SER.PROV_ID AS REFERRED_TO_PROV_ID,
   CLARITY_SER.PROV_NAME AS REFERRED_TO_PROV_NAME,
   ZC_SPECIALTY.NAME AS REFERRED_TO_PROV_SPEC,
   PATIENT.PAT_NAME AS PATIENT_NAME,
   SCHED_CHANGE.CHANGE_DATETIME AS RFL_CHANGE_DTTM,
   --SCHED_CHANGE.CHANGE_TYPE_C AS RFL_CHANGE_TYPE_C,
   SCHED_CHANGE.CHANGE_TYPE_NAME AS RFL_CHANGE_TYPE,
   --SCHED_CHANGE.CHANGE_USER_ID AS RFL_CHANGE_USER_ID,
   SCHED_CHANGE.CHANGE_USER_NAME AS RFL_CHANGE_USER,
   SCHED_CHANGE.PREVIOUS_VALUE AS RFL_CHANGE_TEXT,
   --RFL_APPTS.PRC_ID,
   RFL_APPTS.ACTUAL_CNT AS SCHEDULED_VISITS,
   RFL_APPTS.APPT_MADE_DTTM AS FIRST_APPT_MADE, -- First scheduled appointment datetime
   RFL_APPTS.APPT_DATE AS FIRST_APPT,  -- First scheduled appointment
   RFL_APPTS.COMPLETED_CNT,
   RFL_APPTS.CANCELED_CNT   

FROM 
   REFERRAL
   LEFT OUTER JOIN REFERRAL_3 ON REFERRAL.REFERRAL_ID=REFERRAL_3.REFERRAL_ID
   LEFT OUTER JOIN PATIENT ON REFERRAL.PAT_ID = PATIENT.PAT_ID
   LEFT OUTER JOIN CLARITY_DEP ON REFERRAL.REFD_TO_DEPT_ID = CLARITY_DEP.DEPARTMENT_ID
   LEFT OUTER JOIN CLARITY_SER ON REFERRAL.REFERRAL_PROV_ID = CLARITY_SER.PROV_ID 
   LEFT OUTER JOIN ZC_SPECIALTY ON REFERRAL.PROV_SPEC_C = ZC_SPECIALTY.SPECIALTY_C
   LEFT OUTER JOIN ZC_RFL_TYPE ON REFERRAL.RFL_TYPE_C = ZC_RFL_TYPE.RFL_TYPE_C
   LEFT OUTER JOIN ZC_RFL_CLASS ON REFERRAL.RFL_CLASS_C = ZC_RFL_CLASS.RFL_CLASS_C
   LEFT OUTER JOIN ZC_RFL_STATUS ON REFERRAL.RFL_STATUS_C = ZC_RFL_STATUS.RFL_STATUS_C
   LEFT OUTER JOIN	CLARITY_LOC				LOC_FROM				ON  REFERRAL.PRIM_LOC_ID				= LOC_FROM.LOC_ID
   LEFT OUTER JOIN	CLARITY_LOC						REFD_TO_LOC						ON REFERRAL.REFD_TO_LOC_POS_ID				= REFD_TO_LOC.LOC_ID
   LEFT OUTER JOIN REFERRAL_SOURCE ON REFERRAL.REFERRING_PROV_ID = REFERRAL_SOURCE.REFERRING_PROV_ID
   LEFT OUTER JOIN CLARITY_SER AS REFERRING_SER  ON REFERRING_SER.PROV_ID = REFERRAL_SOURCE.REF_PROVIDER_ID
																																	AND REFERRING_SER.STAFF_RESOURCE_C = '1' -- Person
   LEFT OUTER JOIN CLARITY_DEP AS REFERRING_DEP  ON REFERRING_DEP.DEPARTMENT_ID = REFERRAL.REFD_BY_DEPT_ID
   LEFT OUTER JOIN
      ( SELECT REFERRAL_ID, CHANGE_DATETIME
         FROM REFERRAL_HIST
         WHERE REFERRAL_HIST.LINE = (	SELECT MAX(RFLHX.LINE) 
                                 FROM REFERRAL_HIST RFLHX
                                 WHERE RFLHX.CHANGE_TYPE_C IN (53,39)
                                 AND RFLHX.REFERRAL_ID = REFERRAL_HIST.REFERRAL_ID)) AS AUTH_CHANGE ON AUTH_CHANGE.REFERRAL_ID = REFERRAL.REFERRAL_ID

   LEFT OUTER JOIN
      ( SELECT rh.REFERRAL_ID, rh.LINE, rh.CHANGE_DATE, rh.CHANGE_TYPE_C, rhct.NAME AS CHANGE_TYPE_NAME, rh.CHANGE_USER_ID, emp.NAME AS CHANGE_USER_NAME, rh.PREVIOUS_VALUE, rh.CHANGE_DATETIME
         FROM REFERRAL_HIST rh
         LEFT OUTER JOIN dbo.CLARITY_EMP emp ON emp.USER_ID = rh.CHANGE_USER_ID
         LEFT OUTER JOIN dbo.ZC_RFL_HST_CHG_TYP rhct ON rhct.CHANGE_TYPE_C = rh.CHANGE_TYPE_C
         WHERE rh.LINE = (	SELECT MAX(RFLHX.LINE) 
                                 FROM REFERRAL_HIST RFLHX
                                 LEFT OUTER JOIN dbo.ZC_RFL_HST_CHG_TYP rhct ON rhct.CHANGE_TYPE_C    = RFLHX.CHANGE_TYPE_C
                                 WHERE RFLHX.CHANGE_USER_ID NOT IN ('RFLEOD','RTEUSERIN','CADENCEEOD','KBSQL')
								 AND (rhct.NAME LIKE '%Schedul%' AND rhct.NAME NOT IN ('RFLEOD','CADENCEEOD'))
                                 AND RFLHX.REFERRAL_ID = rh.REFERRAL_ID)) AS SCHED_CHANGE ON SCHED_CHANGE.REFERRAL_ID = REFERRAL.REFERRAL_ID
   
   LEFT OUTER JOIN 
      ( SELECT RFL.REFERRAL_ID RFL_ID,
         COUNT(DISTINCT RFL_ENC.PAT_ENC_CSN_ID) ACTUAL_CNT,
         MIN(RFL_ENC.APPT_MADE_DATE) APPT_MADE_DATE, -- First scheduled appointment date
         MIN(RFL_ENC.APPT_MADE_DTTM) APPT_MADE_DTTM, -- First scheduled appointment datetime
         MIN(RFL_ENC.CONTACT_DATE) APPT_DATE,  -- First scheduled appointment
		 MIN(RFL_ENC.PRC_ID) PRC_ID,
		 SUM(CASE WHEN RFL_ENC.APPT_STATUS_C = 1 THEN 1 ELSE 0 END) SCHEDULED_CNT,
		 SUM(CASE WHEN RFL_ENC.APPT_STATUS_C = 2 THEN 1 ELSE 0 END) COMPLETED_CNT,
		 SUM(CASE WHEN RFL_ENC.APPT_STATUS_C = 3 THEN 1 ELSE 0 END) CANCELED_CNT,
		 SUM(CASE WHEN RFL_ENC.APPT_STATUS_C = 4 THEN 1 ELSE 0 END) NO_SHOW_CNT,
		 SUM(CASE WHEN RFL_ENC.APPT_STATUS_C = 6 THEN 1 ELSE 0 END) ARRIVED_CNT
         FROM REFERRAL RFL
         INNER JOIN V_SCHED_APPT RFL_ENC ON RFL_ENC.REFERRAL_ID = RFL.REFERRAL_ID
         --WHERE RFL_ENC.APPT_STATUS_C IN (1,2,6) OR RFL_ENC.COMPLETED_STATUS_YN='Y' -- Scheduled, Completed, Arrived
         GROUP BY RFL.REFERRAL_ID) RFL_APPTS ON RFL_APPTS.RFL_ID = REFERRAL.REFERRAL_ID
	LEFT OUTER JOIN CLARITY_PRC prc
	ON prc.PRC_ID = RFL_APPTS.PRC_ID
    LEFT OUTER JOIN
    (
	    SELECT day_date,
               fmonth_num,
               Fyear_num,
               FYear_name
        FROM CLARITY_App.Rptg.vwDim_Date
    ) date_dim
	--ON (date_dim.day_date = CAST(REFERRAL.EXP_DATE AS SMALLDATETIME))
	ON (date_dim.day_date = CAST(REFERRAL.ENTRY_DATE AS SMALLDATETIME))
   
WHERE (REFERRAL_3.AUTH_CERT_YN IS NULL OR REFERRAL_3.AUTH_CERT_YN='N')
      --AND REFERRAL.REFD_BY_DEPT_ID = 10228012
      --AND REFERRAL.REFD_TO_DEPT_ID = 10242041 -- UVPC PEDS NEUROLOGY
      AND REFERRAL.REFD_TO_DEPT_ID = 10242005 -- UVPC DERMATOLOGY
	  --AND REFERRAL.ACTUAL_NUM_VISITS IS NOT NULL
	  --AND referral.EXP_DATE BETWEEN @startdate AND @enddate
	  AND referral.ENTRY_DATE BETWEEN @startdate AND @enddate
	  AND prc.PRC_NAME LIKE '%MOHS%'

--ORDER BY SCHED_CHANGE.CHANGE_DATETIME
--       , REFERRAL.REFERRAL_ID

ORDER BY REFERRAL.REFERRAL_ID, SCHED_CHANGE.CHANGE_DATETIME
