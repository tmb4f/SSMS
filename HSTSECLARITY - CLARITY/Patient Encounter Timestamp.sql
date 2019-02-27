USE [CLARITY_App]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

DECLARE @StartDate SMALLDATETIME = NULL
       ,@EndDate SMALLDATETIME = NULL

SET @StartDate = '7/1/2018 00:00:00'
--SET @StartDate = '11/10/2018 00:00:00'
--SET @EndDate = '11/28/2018 00:00:00'

--ALTER PROCEDURE [Rptg].[uspSrc_iQueue_Outpatient_Daily]
--       (
--        @StartDate SMALLDATETIME = NULL
--       ,@EndDate SMALLDATETIME = NULL)
--AS
/****************************************************************************************************************************************
WHAT: Create procedure Rptg.uspSrc_iQueue_Outpatient_Daily
WHO : Tom Burgan
WHEN: 11/13/2018
WHY : Daily feed of patient flow data for Ambulatory Optimization iQueue project
----------------------------------------------------------------------------------------------------------------------------------------
INFO:
      INPUTS:   dbo.V_SCHED_APPT
	            dbo.PAT_ENC
				dbo.CLARITY_DEP
				dbo.MAR_ADMIN_INFO
				dbo.ZC_MAR_RSLT
				dbo.ZC_MED_DURATION_UN
				dbo.ZC_MED_UNIT
				dbo.ZC_MAR_RSN
				dbo.PAT_ENC
				dbo.CLARITY_EMP
				dbo.CLARITY_DEP
				dbo.ORDER_MED
				dbo.CLARITY_MEDICATION
				dbo.ZC_INFUSION_TYPE
				dbo.ZC_MAR_ADMIN_TYPE
				dbo.PAT_ENC_HSP
				dbo.PATIENT
				dbo.IP_FLWSHT_REC
				dbo.IP_FLWSHT_MEAS
				dbo.IP_FLO_GP_DATA
				dbo.IP_FLT_DATA

  Temp tables :
                #ClinicPatient
				#ScheduledAppointmentReason
                #ScheduledAppointment
                #ScheduledAppointmentPlus
                #ScheduledAppointmentLinked
                #ScheduledClinicAppointment
                #FLT
                #FLM
                #FLTPIVOT
                #FLMSummary
                #ScheduledInfusionAppointmentDetail
                #RptgTemp

      OUTPUTS:
                CLARITY_App.Stage.iQueue_Infusion_Extract
----------------------------------------------------------------------------------------------------------------------------------------
MODS:     11/13/2018--TMB-- Create new stored procedure
*****************************************************************************************************************************************/

  SET NOCOUNT ON;

  --SELECT @StartDate, @EndDate

---------------------------------------------------
---Default date range is the prior day up to the following two months
  DECLARE @CurrDate SMALLDATETIME;

  SET @CurrDate = CAST(CAST(GETDATE() AS DATE) AS SMALLDATETIME);

  IF @StartDate IS NULL
      BEGIN
          -- Yesterday's date
          SET @StartDate = CAST(CAST(DATEADD(DAY, -1, @CurrDate) AS DATE) AS SMALLDATETIME)
          + CAST(CAST('00:00:00' AS TIME) AS SMALLDATETIME);
      END;
  IF @EndDate IS NULL
      BEGIN
          -- End of month, six months ahead from current date
          SET @EndDate = CAST(EOMONTH(@CurrDate, 6) AS SMALLDATETIME)
          + CAST(CAST('23:59:59' AS TIME) AS SMALLDATETIME);
      END;
----------------------------------------------------

IF OBJECT_ID('tempdb..#ClinicPatient ') IS NOT NULL
DROP TABLE #ClinicPatient

IF OBJECT_ID('tempdb..#ScheduledAppointmentReason ') IS NOT NULL
DROP TABLE #ScheduledAppointmentReason

IF OBJECT_ID('tempdb..#ScheduledAppointment ') IS NOT NULL
DROP TABLE #ScheduledAppointment

IF OBJECT_ID('tempdb..#ScheduledAppointmentPlus ') IS NOT NULL
DROP TABLE #ScheduledAppointmentPlus

IF OBJECT_ID('tempdb..#ScheduledAppointmentLinked ') IS NOT NULL
DROP TABLE #ScheduledAppointmentLinked

IF OBJECT_ID('tempdb..#ScheduledClinicAppointment ') IS NOT NULL
DROP TABLE #ScheduledClinicAppointment

IF OBJECT_ID('tempdb..#ScheduledClinicAppointmentUnpivot ') IS NOT NULL
DROP TABLE #ScheduledClinicAppointmentUnpivot

IF OBJECT_ID('tempdb..#FLT ') IS NOT NULL
DROP TABLE #FLT

IF OBJECT_ID('tempdb..#FLM ') IS NOT NULL
DROP TABLE #FLM

IF OBJECT_ID('tempdb..#FLTFLM ') IS NOT NULL
DROP TABLE #FLTFLM

IF OBJECT_ID('tempdb..#FLTPIVOT ') IS NOT NULL
DROP TABLE #FLTPIVOT

IF OBJECT_ID('tempdb..#FLMSummary ') IS NOT NULL
DROP TABLE #FLMSummary

IF OBJECT_ID('tempdb..#ScheduledClinicAppointmentDetail ') IS NOT NULL
DROP TABLE #ScheduledClinicAppointmentDetail

IF OBJECT_ID('tempdb..#RptgTemp ') IS NOT NULL
DROP TABLE #RptgTemp

  -- Create temp table #ClinicPatient with PAT_ID and Appt date

  SELECT DISTINCT
     pa.PAT_ID
    ,CAST(pa.[APPT_DTTM] AS DATE) AS [Appt date]
  INTO #ClinicPatient
  FROM [CLARITY].[dbo].[V_SCHED_APPT] AS pa
  WHERE
  (pa.[APPT_DTTM] >= @StartDate AND pa.[APPT_DTTM] <= @EndDate)
   --AND (pa.DEPARTMENT_ID IN (10210002 -- ECCC HEM ONC WEST
   --                         ,10210030 -- ECCC NEURO WEST
			--				,10243003 -- UVHE DIGESTIVE HEALTH
			--				,10243087 -- UVHE SURG DIGESTIVE HL
			--				,10244023 -- UVWC MED GI CL
			--				)
	   --)
   --AND (pa.DEPARTMENT_ID IN (10243087 -- UVHE SURG DIGESTIVE HL
			--				,10244023 -- UVWC MED GI CL
			--				)
	  -- )
   AND pa.DEPARTMENT_ID = 10244004
   --AND pa.PAT_ID = 'Z91574'
   --AND CAST(pa.APPT_DTTM AS DATE) = '2/6/2019'

  -- Create index for temp table #ClinicPatient

  CREATE UNIQUE CLUSTERED INDEX IX_ClinicPaitent ON #ClinicPatient ([PAT_ID], [Appt date])

  -- Create temp table #ScheduledAppointmentReason

  SELECT PAT_ENC_RSN_VISIT.PAT_ENC_CSN_ID
       , CL_RSN_FOR_VISIT.REASON_VISIT_NAME AS ENC_REASON_NAME
	   , PAT_ENC_RSN_VISIT.LINE
  INTO #ScheduledAppointmentReason
  FROM (SELECT DISTINCT
			PAT_ID
        FROM #ClinicPatient) ClinicPatient
  INNER JOIN CLARITY.dbo.PAT_ENC_RSN_VISIT PAT_ENC_RSN_VISIT	ON ClinicPatient.PAT_ID = PAT_ENC_RSN_VISIT.PAT_ID
  LEFT OUTER JOIN CLARITY.dbo.CL_RSN_FOR_VISIT CL_RSN_FOR_VISIT ON CL_RSN_FOR_VISIT.REASON_VISIT_ID = PAT_ENC_RSN_VISIT.ENC_REASON_ID
  ORDER BY PAT_ENC_RSN_VISIT.PAT_ENC_CSN_ID
         , PAT_ENC_RSN_VISIT.LINE

  -- Create index for temp table #ScheduledAppointmentReason

  CREATE UNIQUE CLUSTERED INDEX IX_ScheduledAppointmentReason ON #ScheduledAppointmentReason (PAT_ENC_CSN_ID, LINE)

  -- Create temp table #ScheduledAppointment

  SELECT
     pa.PAT_ID
    --,CAST(CAST(pa.[APPT_DTTM]           AS DATE)	AS DATETIME)          AS [Appointment Date]
    ,CAST(CAST(pa.[APPT_DTTM]           AS DATE)	AS DATETIME)          AS [APPT_DATE]
    --,CAST(pa.[APPT_DTTM]           AS SMALLDATETIME) AS [APPT_DTTM]
    ,pa.[APPT_DTTM]
    ,ROW_NUMBER() OVER (PARTITION BY pa.PAT_ID, CAST(pa.[APPT_DTTM] AS DATE) ORDER BY pa.[APPT_DTTM]) AS SeqNbr
    ,pa.PAT_ENC_CSN_ID                               AS [PAT_ENC_CSN_ID_unhashed]
	,HASHBYTES('SHA2_256',CAST(enc.PAT_ENC_CSN_ID AS VARCHAR(18))) AS [PAT_ENC_CSN_ID]
	,pa.DEPARTMENT_ID
    ,dep.DEPARTMENT_NAME                             AS [DEPARTMENT_NAME]
    ,pa.DEPT_SPECIALTY_NAME                          AS [DEPT_SPECIALTY_NAME]
    ,pa.PRC_NAME                                     AS [PRC_NAME]
	,encrsn.ENC_REASON_NAME
    ,pa.APPT_LENGTH                                  AS [APPT_LENGTH]
    ,pa.APPT_STATUS_C
    ,ZC_APPT_STATUS.NAME                             AS [APPT_STATUS_NAME]
    --,CAST(pa.CHECKIN_DTTM          AS SMALLDATETIME) AS [CHECKIN_DTTM]
    ,pa.CHECKIN_DTTM
    --,CAST(pa.ARVL_LIST_REMOVE_DTTM AS SMALLDATETIME) AS [ARVL_LIST_REMOVE_DTTM]
    ,pa.ARVL_LIST_REMOVE_DTTM
    ,CAST(pa.APPT_MADE_DATE        AS DATE)          AS [APPT_MADE_DATE]
    ,pa.APPT_MADE_DTTM                               AS [APPT_MADE_DTTM]
    ,CAST(pa.APPT_CANC_DATE        AS DATE)          AS [APPT_CANC_DATE]
    ,LAG(pa.[APPT_STATUS_C]) OVER (PARTITION BY pa.PAT_ID, CAST(pa.[APPT_DTTM] AS DATE) ORDER BY pa.[APPT_DTTM], pa.PAT_ENC_CSN_ID) AS [Previous APPT_STATUS_C]
    ,enc.INPATIENT_DATA_ID
    ,ROW_NUMBER() OVER (ORDER BY pa.PAT_ID, CAST(pa.[APPT_DTTM] AS DATE), pa.[APPT_DTTM]) AS RecordId

  --
  -- Additional timestamps
  --
    ,pa.SIGNIN_DTTM
	,pa.PAGED_DTTM
	,pa.BEGIN_CHECKIN_DTTM
	,pa.ROOMED_DTTM
	,pa.FIRST_ROOM_ASSIGN_DTTM
	,pa.NURSE_LEAVE_DTTM
	,pa.PHYS_ENTER_DTTM
	,pa.VISIT_END_DTTM
	,pa.CHECKOUT_DTTM
	,pa.TIME_TO_ROOM_MINUTES --diff between check in time and roomed time (earliest of the ARVL_LIST_REMOVE_DTTM, ROOMED_DTTM, and FIRST_ROOM_ASSIGN_DTTM)
	,pa.TIME_IN_ROOM_MINUTES --diff between roomed time and appointment end time (earlier of the CHECKOUT_DTTM and VISIT_END_DTTM)
	,pa.CYCLE_TIME_MINUTES	 --diff between the check-in time and the appointment end time.
	,pa.APPT_CANC_DTTM
	
	,CASE
	  WHEN enc.ENC_TYPE_C IN (				-- FACE TO FACE UVA DEFINED ENCOUNTER TYPES
			                  '1001'			--Anti-coag visit
			                 ,'50'			--Appointment
			                 ,'213'			--Dentistry Visit
			                 ,'2103500001'	--Home Visit
			                 ,'3'			--Hospital Encounter
			                 ,'108'			--Immunization
			                 ,'1201'			--Initial Prenatal
			                 ,'101'			--Office Visit
			                 ,'2100700001'	--Office Visit / FC
			                 ,'1003'			--Procedure visit
			                 ,'1200'			--Routine Prenatal
			                 ) THEN 1
      ELSE 0
	 END AS F2F_Flag
	,REFERRAL.ENTRY_DATE
	,REFERRAL_HIST.CHANGE_DATE
	,CLARITY_SER.PROV_NAME
	,fpa.UPDATE_DATE
	,PATIENT.PAT_MRN_ID

  INTO #ScheduledAppointment
  FROM [CLARITY].[dbo].[V_SCHED_APPT]     AS pa
  INNER JOIN #ClinicPatient               AS inf   ON pa.PAT_ID = inf.PAT_ID AND CAST(pa.[APPT_DTTM] AS DATE) = inf.[Appt Date]
  LEFT OUTER JOIN [CLARITY].[dbo].[F_SCHED_APPT]	AS fpa	ON fpa.PAT_ENC_CSN_ID = pa.PAT_ENC_CSN_ID
  LEFT OUTER JOIN CLARITY.dbo.PAT_ENC     AS enc   ON enc.PAT_ENC_CSN_ID = pa.PAT_ENC_CSN_ID
  LEFT OUTER JOIN CLARITY.dbo.CLARITY_DEP AS dep   ON pa.DEPARTMENT_ID   = dep.DEPARTMENT_ID
  LEFT OUTER JOIN CLARITY.dbo.CLARITY_SER AS CLARITY_SER   ON pa.PROV_ID = CLARITY_SER.PROV_ID
  LEFT OUTER JOIN (SELECT DISTINCT
                          rsn.PAT_ENC_CSN_ID
                        , (SELECT COALESCE(MAX(rsnt.ENC_REASON_NAME),'')  + '|' AS [text()]
		                   FROM #ScheduledAppointmentReason rsnt
						   WHERE rsnt.PAT_ENC_CSN_ID = rsn.PAT_ENC_CSN_ID
		                   GROUP BY rsnt.PAT_ENC_CSN_ID
				                  , rsnt.LINE
	                       FOR XML PATH ('')) AS ENC_REASON_NAME
                   FROM #ScheduledAppointmentReason AS rsn)	AS encrsn	ON encrsn.PAT_ENC_CSN_ID = enc.PAT_ENC_CSN_ID
  LEFT OUTER JOIN CLARITY.dbo.REFERRAL    AS REFERRAL      ON REFERRAL.REFERRAL_ID = pa.REFERRAL_ID
  LEFT OUTER JOIN (SELECT REFERRAL_ID, CHANGE_DATE
				   FROM CLARITY.dbo.REFERRAL_HIST
				   WHERE CHANGE_TYPE_C = 1) AS REFERRAL_HIST    ON REFERRAL_HIST.REFERRAL_ID = REFERRAL.REFERRAL_ID
  LEFT OUTER JOIN CLARITY.dbo.ZC_APPT_STATUS	AS ZC_APPT_STATUS	ON ZC_APPT_STATUS.APPT_STATUS_C = enc.APPT_STATUS_C
  LEFT OUTER JOIN CLARITY.dbo.PATIENT           AS PATIENT          ON PATIENT.PAT_ID = pa.PAT_ID

  -- Create index for temp table #ScheduledAppointment

  CREATE UNIQUE CLUSTERED INDEX IX_ScheduledAppointment ON #ScheduledAppointment ([PAT_ID], [APPT_DATE], RecordId)

  -- Create temp table #ScheduledAppointmentPlus

  SELECT
     pa.PAT_ENC_CSN_ID
	,pa.PAT_ENC_CSN_ID_unhashed
    ,pa.DEPARTMENT_NAME
    ,pa.DEPT_SPECIALTY_NAME
    ,pa.PRC_NAME
	,pa.ENC_REASON_NAME
    ,pa.APPT_LENGTH
    ,pa.APPT_STATUS_C
    ,pa.APPT_STATUS_NAME
    ,pa.[APPT_DATE]
    ,pa.[APPT_DTTM]
    ,pa.SeqNbr
    ,pa.RecordId
    ,CASE WHEN pa.[Previous APPT_STATUS_C] IN (3,4,5) THEN
           (SELECT MAX(sa.RecordId) FROM #ScheduledAppointment AS sa
                WHERE sa.RecordId < pa.RecordId
                AND sa.PAT_ID = pa.PAT_ID
                AND sa.[APPT_DATE] = pa.[APPT_DATE]
                AND sa.[APPT_STATUS_C] IN (1,2,6)) -- (Scheduled,Completed,Arrived)
          ELSE pa.RecordId - 1
     END                                AS [Previous RecordId]
    ,pa.CHECKIN_DTTM
    ,pa.ARVL_LIST_REMOVE_DTTM
    ,pa.APPT_MADE_DATE
	,pa.APPT_MADE_DTTM
    ,pa.APPT_CANC_DATE
    ,pa.[Previous APPT_STATUS_C]
    ,pa.PAT_ID
    ,pa.INPATIENT_DATA_ID
    ,pa.DEPARTMENT_ID

    ,pa.SIGNIN_DTTM
	,pa.PAGED_DTTM
	,pa.BEGIN_CHECKIN_DTTM
	,pa.ROOMED_DTTM
	,pa.FIRST_ROOM_ASSIGN_DTTM
	,pa.NURSE_LEAVE_DTTM
	,pa.PHYS_ENTER_DTTM
	,pa.VISIT_END_DTTM
	,pa.CHECKOUT_DTTM
	,pa.TIME_TO_ROOM_MINUTES
	,pa.TIME_IN_ROOM_MINUTES
	,pa.CYCLE_TIME_MINUTES
	,pa.APPT_CANC_DTTM
	,pa.F2F_Flag
	,pa.ENTRY_DATE
	,pa.CHANGE_DATE
	,pa.PROV_NAME
	,pa.UPDATE_DATE
	,pa.PAT_MRN_ID

  INTO #ScheduledAppointmentPlus
  FROM #ScheduledAppointment     AS pa

  -- Create index for temp table #ScheduledAppointmentPlus

  CREATE UNIQUE CLUSTERED INDEX IX_ScheduledAppointmentPlus ON #ScheduledAppointmentPlus ([PAT_ID], [APPT_DATE], [RecordId], [Previous RecordId])

  -- Create temp table #ScheduledAppointmentLinked

  SELECT
     apptplus.PAT_ENC_CSN_ID
	,apptplus.PAT_ENC_CSN_ID_unhashed
    ,apptplus.DEPARTMENT_NAME
	,apptplus.DEPT_SPECIALTY_NAME
    ,apptplus.PRC_NAME
	,apptplus.ENC_REASON_NAME
    ,apptplus.APPT_LENGTH
    ,apptplus.APPT_STATUS_C
    ,apptplus.APPT_STATUS_NAME
    ,apptplus.[APPT_DATE]
    ,apptplus.[APPT_DTTM]
    ,apptplus.CHECKIN_DTTM
    ,apptplus.ARVL_LIST_REMOVE_DTTM
    ,apptplus.APPT_MADE_DATE
	,apptplus.APPT_MADE_DTTM
    ,apptplus.APPT_CANC_DATE
    ,CASE WHEN ((apptplus.SeqNbr = 1) OR ((apptplus.SeqNbr > 1) AND (apptplus.[Previous RecordId] IS NULL))) THEN NULL
          ELSE appt.PAT_ENC_CSN_ID
     END AS [Previous PAT_ENC_CSN_ID]
    ,CASE WHEN ((apptplus.SeqNbr = 1) OR ((apptplus.SeqNbr > 1) AND (apptplus.[Previous RecordId] IS NULL))) THEN NULL
          ELSE appt.PAT_ENC_CSN_ID_unhashed
     END AS [Previous PAT_ENC_CSN_ID_unhashed]
    ,CASE WHEN ((apptplus.SeqNbr = 1) OR ((apptplus.SeqNbr > 1) AND (apptplus.[Previous RecordId] IS NULL))) THEN NULL
          ELSE appt.[APPT_DTTM]
     END AS [Previous Appointment Time]
    ,CASE WHEN ((apptplus.SeqNbr = 1) OR ((apptplus.SeqNbr > 1) AND (apptplus.[Previous RecordId] IS NULL))) THEN NULL
          ELSE appt.APPT_LENGTH
     END AS [Previous APPT_LENGTH]
    ,apptplus.PAT_ID
    ,apptplus.INPATIENT_DATA_ID
    ,apptplus.DEPARTMENT_ID

    ,apptplus.SIGNIN_DTTM
	,apptplus.PAGED_DTTM
	,apptplus.BEGIN_CHECKIN_DTTM
	,apptplus.ROOMED_DTTM
	,apptplus.FIRST_ROOM_ASSIGN_DTTM
	,apptplus.NURSE_LEAVE_DTTM
	,apptplus.PHYS_ENTER_DTTM
	,apptplus.VISIT_END_DTTM
	,apptplus.CHECKOUT_DTTM
	,apptplus.TIME_TO_ROOM_MINUTES
	,apptplus.TIME_IN_ROOM_MINUTES
	,apptplus.CYCLE_TIME_MINUTES
	,apptplus.APPT_CANC_DTTM
	,apptplus.F2F_Flag
	,apptplus.ENTRY_DATE
	,apptplus.CHANGE_DATE
	,apptplus.PROV_NAME
	,apptplus.UPDATE_DATE
	,apptplus.PAT_MRN_ID

  INTO #ScheduledAppointmentLinked
  FROM #ScheduledAppointmentPlus        AS apptplus
  LEFT OUTER JOIN #ScheduledAppointment AS appt ON appt.RecordId = apptplus.[Previous RecordId]

  -- Create index for temp table #ScheduledAppointmentLinked

  CREATE UNIQUE CLUSTERED INDEX IX_ScheduledAppointmentLinked ON #ScheduledAppointmentLinked ([PAT_ID], [PAT_ENC_CSN_ID_unhashed], [APPT_DTTM])

  -- Create temp table #ScheduledClinicAppointment

  SELECT
     pa.PAT_ENC_CSN_ID
	,pa.PAT_ENC_CSN_ID_unhashed
    ,pa.DEPARTMENT_NAME
    ,pa.DEPT_SPECIALTY_NAME
    ,pa.PRC_NAME
	,pa.ENC_REASON_NAME
    ,pa.APPT_LENGTH
    ,pa.APPT_STATUS_C
    ,pa.APPT_STATUS_NAME
    ,pa.[APPT_DATE]
    ,pa.[APPT_DTTM]
    ,pa.CHECKIN_DTTM
    ,pa.ARVL_LIST_REMOVE_DTTM
    ,pa.APPT_MADE_DATE
	,pa.APPT_MADE_DTTM
    ,pa.APPT_CANC_DATE
    ,pa.[Previous PAT_ENC_CSN_ID]
	,pa.[Previous PAT_ENC_CSN_ID_unhashed]
    ,pa.[Previous Appointment Time]
    ,pa.[Previous APPT_LENGTH]
    ,pa.PAT_ID
    ,pa.INPATIENT_DATA_ID
    ,pa.DEPARTMENT_ID

    ,pa.SIGNIN_DTTM
	,pa.PAGED_DTTM
	,pa.BEGIN_CHECKIN_DTTM
	,pa.ROOMED_DTTM
	,pa.FIRST_ROOM_ASSIGN_DTTM
	,pa.NURSE_LEAVE_DTTM
	,pa.PHYS_ENTER_DTTM
	,pa.VISIT_END_DTTM
	,pa.CHECKOUT_DTTM
	,pa.TIME_TO_ROOM_MINUTES
	,pa.TIME_IN_ROOM_MINUTES
	,pa.CYCLE_TIME_MINUTES
	,pa.APPT_CANC_DTTM
	,pa.F2F_Flag
	,pa.ENTRY_DATE
	,pa.CHANGE_DATE
	,pa.PROV_NAME
	,pa.UPDATE_DATE
	,pa.PAT_MRN_ID

  INTO #ScheduledClinicAppointment
  FROM #ScheduledAppointmentLinked AS pa
  WHERE
  --pa.DEPARTMENT_ID IN (10210002,10210030,10243003)
  --(pa.DEPARTMENT_ID IN (10210002 -- ECCC HEM ONC WEST
  --                     ,10210030 -- ECCC NEURO WEST
		--		       ,10243003 -- UVHE DIGESTIVE HEALTH
		--			   ,10243087 -- UVHE SURG DIGESTIVE HL
		--			   ,10244023 -- UVWC MED GI CL
		--			   )
  --)
  pa.DEPARTMENT_ID = 10244004
  --AND pa.PAT_ID = 'Z91574'
  --AND CAST(pa.APPT_DTTM AS DATE) = '2/6/2019'

  -- Create index for temp table #ScheduledClinicAppointment

  --CREATE UNIQUE CLUSTERED INDEX IX_ScheduledClinicAppointment ON #ScheduledClinicAppointment ([PAT_ID], [PAT_ENC_CSN_ID_unhashed], [APPT_DTTM])
  CREATE UNIQUE CLUSTERED INDEX IX_ScheduledClinicAppointment ON #ScheduledClinicAppointment ([PAT_ENC_CSN_ID_unhashed])

  --SELECT *
  --FROM #ScheduledClinicAppointment
  --ORDER BY PAT_ENC_CSN_ID_unhashed

  SELECT UnpivotTable.PAT_ENC_CSN_ID_unhashed
       , Appt.DEPARTMENT_NAME
	   , Appt.PRC_NAME
	   , Appt.APPT_LENGTH
	   , Appt.APPT_STATUS_NAME
	   , Appt.PAT_ID
	   , Appt.DEPARTMENT_ID
	   , Appt.PROV_NAME
	   , Appt.TIME_TO_ROOM_MINUTES
	   , Appt.TIME_IN_ROOM_MINUTES
	   , Appt.CYCLE_TIME_MINUTES
	   , Appt.INPATIENT_DATA_ID
	   , Appt.APPT_MADE_DTTM
	   , Appt.APPT_DATE
	   , Appt.PAT_MRN_ID
       , UnpivotTable.[Event]
	   , UnpivotTable.[Timestamp]
  INTO #ScheduledClinicAppointmentUnpivot
  FROM
  (
  SELECT PAT_ENC_CSN_ID_unhashed
       , APPT_DTTM
	   , CHECKIN_DTTM
	   , ARVL_LIST_REMOVE_DTTM
	   , SIGNIN_DTTM
	   , BEGIN_CHECKIN_DTTM
	   , ROOMED_DTTM
	   , FIRST_ROOM_ASSIGN_DTTM
	   , NURSE_LEAVE_DTTM
	   , PHYS_ENTER_DTTM
	   , VISIT_END_DTTM
	   , CHECKOUT_DTTM
  FROM #ScheduledClinicAppointment
  ) TmStmp
  UNPIVOT
  (
		[Timestamp]
		FOR [Event] IN (APPT_DTTM, CHECKIN_DTTM, ARVL_LIST_REMOVE_DTTM, SIGNIN_DTTM, BEGIN_CHECKIN_DTTM, ROOMED_DTTM, FIRST_ROOM_ASSIGN_DTTM, NURSE_LEAVE_DTTM, PHYS_ENTER_DTTM, VISIT_END_DTTM, CHECKOUT_DTTM)
  ) AS UnpivotTable
  INNER JOIN #ScheduledClinicAppointment Appt
  ON Appt.PAT_ENC_CSN_ID_unhashed = UnpivotTable.PAT_ENC_CSN_ID_unhashed

  -- Create index for temp table #ScheduledClinicAppointmentUnpivot

  CREATE UNIQUE CLUSTERED INDEX IX_ScheduledClinicAppointmentUnpivot ON #ScheduledClinicAppointmentUnpivot ([PAT_ENC_CSN_ID_unhashed], [Event], [Timestamp])

  --SELECT *
  --FROM #ScheduledClinicAppointmentUnpivot
  --ORDER BY PAT_ENC_CSN_ID_unhashed
  --       , [Timestamp]
           
  -- Create temp table #FLT

  SELECT DISTINCT
     appt.PAT_ENC_CSN_ID_unhashed
    ,appt.PAT_ID
    ,appt.INPATIENT_DATA_ID
    ,flt.RECORDED_TIME
    ,LEFT(CONVERT(VARCHAR(8), flt.RECORDED_TIME, 108), 5) AS [RECORDED_TIME_Txt]
	,flt.FLT_ID
    ,flt.FLO_MEAS_ID
	,flt.FLO_MEAS_NAME
	,flt.DISP_NAME
	,flt.TEMPLATE_NAME
    ,flt.MEAS_VALUE
    ,ROW_NUMBER() OVER (PARTITION BY appt.PAT_ID, appt.[PAT_ENC_CSN_ID_unhashed], flt.FLT_ID ORDER BY flt.RECORDED_TIME) AS SeqNbr
  INTO #FLT
  FROM (SELECT DISTINCT
               [PAT_ENC_CSN_ID_unhashed]
             , PAT_ID
             , INPATIENT_DATA_ID
        FROM #ScheduledClinicAppointment) appt
  INNER JOIN (SELECT
                 fr.PAT_ID
                ,fm.RECORDED_TIME
                ,fm.MEAS_VALUE
                ,CASE WHEN fm.FLT_ID IN ('2100300004','31010','31000') THEN '2100300004' ELSE fm.FLT_ID END AS FLT_ID
                ,fm.FLO_MEAS_ID
				,gp.FLO_MEAS_NAME
				,gp.DISP_NAME
	            ,ft.TEMPLATE_NAME
                ,fr.INPATIENT_DATA_ID
            FROM CLARITY.dbo.IP_FLWSHT_REC        AS fr WITH (NOLOCK)
            INNER JOIN CLARITY.dbo.IP_FLWSHT_MEAS AS fm WITH (NOLOCK) ON fr.FSD_ID      = fm.FSD_ID
            INNER JOIN CLARITY.dbo.IP_FLO_GP_DATA AS gp WITH (NOLOCK) ON fm.FLO_MEAS_ID = gp.FLO_MEAS_ID
		    LEFT OUTER JOIN CLARITY.dbo.IP_FLT_DATA ft WITH (NOLOCK) ON ft.TEMPLATE_ID = fm.FLT_ID
            WHERE
			      (fm.FLO_MEAS_ID IN ('2103800002','2103800003') -- T UVA AMB PATIENT UNDERSTANDING AVS
                   AND fm.MEAS_VALUE = 'Yes')
				  OR
			      (fm.FLO_MEAS_ID IN ('3506','3507') -- AMB PATIENT VERIFIED
                   AND fm.MEAS_VALUE = 'Yes')
				  OR
			      (fm.FLT_ID IN ('2100300004','31010','31000')) -- UVA AMB VITALS SIMPLE, UVA IP VITALS ICU, UVA IP VITALS SIMPLE
             ) flt
  ON appt.INPATIENT_DATA_ID = flt.INPATIENT_DATA_ID

  -- Create index for temp table #FLT

  CREATE UNIQUE CLUSTERED INDEX IX_FLT ON #FLT (PAT_ENC_CSN_ID_unhashed, FLT_ID, SeqNbr)

  --SELECT *
  --FROM #FLT
  --ORDER BY RECORDED_TIME

  -- Create temp table #FLM

  SELECT DISTINCT
     appt.[PAT_ENC_CSN_ID_unhashed]
    ,appt.PAT_ID
    ,appt.INPATIENT_DATA_ID
    ,flm.RECORDED_TIME
    ,LEFT(CONVERT(VARCHAR(8), flm.RECORDED_TIME, 108), 5) AS [RECORDED_TIME_Txt]
	,flm.FLT_ID
    ,flm.FLO_MEAS_ID
	,flm.FLO_MEAS_NAME
	,flm.DISP_NAME
	,flm.TEMPLATE_NAME
    ,COALESCE(flm.MEAS_VALUE,'NA') AS MEAS_VALUE
    ,ROW_NUMBER() OVER (PARTITION BY appt.PAT_ID, appt.[PAT_ENC_CSN_ID_unhashed], flm.FLO_MEAS_ID ORDER BY flm.RECORDED_TIME) AS SeqNbrAsc
    ,ROW_NUMBER() OVER (PARTITION BY appt.PAT_ID, appt.[PAT_ENC_CSN_ID_unhashed], flm.FLO_MEAS_ID ORDER BY flm.RECORDED_TIME DESC) AS SeqNbrDesc
	,COUNT(flm.MEAS_VALUE) over(partition by appt.PAT_ID, appt.[PAT_ENC_CSN_ID_unhashed], flm.FLO_MEAS_ID) as Meas_Count
	,COUNT(*) over(partition by appt.PAT_ID, appt.[PAT_ENC_CSN_ID_unhashed], COALESCE(flm.MEAS_VALUE,'NA'), flm.MEAS_VALUE) as Meas_Value_Count
  INTO #FLM
  FROM (SELECT DISTINCT
               [PAT_ENC_CSN_ID_unhashed]
             , PAT_ID
             , INPATIENT_DATA_ID
        FROM #ScheduledClinicAppointment) appt
  INNER JOIN (SELECT
                 fr.PAT_ID
                ,fm.RECORDED_TIME
                ,fm.MEAS_VALUE
				,fm.FLT_ID
                ,fm.FLO_MEAS_ID
				,gp.FLO_MEAS_NAME
				,gp.DISP_NAME
				,ft.TEMPLATE_NAME
                ,fr.INPATIENT_DATA_ID
            FROM CLARITY.dbo.IP_FLWSHT_REC        AS fr WITH (NOLOCK)
            INNER JOIN CLARITY.dbo.IP_FLWSHT_MEAS AS fm WITH (NOLOCK) ON fr.FSD_ID      = fm.FSD_ID
            INNER JOIN CLARITY.dbo.IP_FLO_GP_DATA AS gp WITH (NOLOCK) ON fm.FLO_MEAS_ID = gp.FLO_MEAS_ID
		    LEFT OUTER JOIN CLARITY.dbo.IP_FLT_DATA ft WITH (NOLOCK) ON ft.TEMPLATE_ID = fm.FLT_ID
            WHERE
			      (fm.FLO_MEAS_ID ='4143') -- T UVA PATIENT TRACKING - R UVA AMB PATIENT ROOM
				  OR
			      (fm.FLO_MEAS_ID = '4147') -- T UVA PATIENT TRACKING - R UVA AMB PATIENT TRACK VERSION 2
             ) flm
  ON appt.INPATIENT_DATA_ID = flm.INPATIENT_DATA_ID

  -- Create index for temp table #FLM

  --CREATE UNIQUE CLUSTERED INDEX IX_FLM ON #FLM ([Appointment ID], FLO_MEAS_ID, MEAS_VALUE, RECORDED_TIME)
  --CREATE NONCLUSTERED INDEX IX_FLM ON #FLM ([Appointment ID], FLO_MEAS_ID, MEAS_VALUE, RECORDED_TIME)

  --SELECT *
  --FROM #FLM
  --ORDER BY RECORDED_TIME

  -- Create temp table #FLTFLM

  SELECT
     FlwSht.PAT_ENC_CSN_ID_unhashed
    ,FlwSht.PAT_ID
    ,FlwSht.INPATIENT_DATA_ID
    ,FlwSht.RECORDED_TIME
    ,FlwSht.RECORDED_TIME_Txt
	,FlwSht.FLT_ID
    ,FlwSht.FLO_MEAS_ID
	,FlwSht.FLO_MEAS_NAME
	,FlwSht.DISP_NAME
	,FlwSht.TEMPLATE_NAME
    ,FlwSht.MEAS_VALUE
	--,FLTFLM_Name
    ,Appt.DEPARTMENT_NAME
	,Appt.PRC_NAME
	,Appt.APPT_LENGTH
	,Appt.APPT_STATUS_NAME
	,Appt.DEPARTMENT_ID
	,Appt.PROV_NAME
	,Appt.TIME_TO_ROOM_MINUTES
	,Appt.TIME_IN_ROOM_MINUTES
	,Appt.CYCLE_TIME_MINUTES
	,Appt.APPT_MADE_DTTM
	,Appt.APPT_DATE
	,Appt.PAT_MRN_ID
  INTO #FLTFLM
  FROM
  (SELECT PAT_ENC_CSN_ID_unhashed
        , PAT_ID
		, INPATIENT_DATA_ID
		, RECORDED_TIME
		, RECORDED_TIME_Txt
        , FLT_ID
		, FLO_MEAS_ID
		, FLO_MEAS_NAME
		, DISP_NAME
		, TEMPLATE_NAME
		, MEAS_VALUE
    --    , CASE FLT_ID
		  --  WHEN '2100000001' THEN 'AMB PATIENT VERIFIED'
    --        WHEN '2103800001' THEN 'T UVA AMB PATIENT UNDERSTANDING AVS'
    --        WHEN '2100300004' THEN 'UVA AMB VITALS SIMPLE'
		  --END AS FLTFLM_Name
   FROM #FLT
   WHERE SeqNbr = 1
   UNION ALL
   SELECT PAT_ENC_CSN_ID_unhashed
        , PAT_ID
		, INPATIENT_DATA_ID
		, RECORDED_TIME
		, RECORDED_TIME_Txt
        , FLT_ID
		, FLO_MEAS_ID
		, FLO_MEAS_NAME
		, DISP_NAME
		, TEMPLATE_NAME
		, MEAS_VALUE
      --  , CASE FLO_MEAS_ID
		    --WHEN '4143' THEN 'T UVA  PATIENT TRACKING R UVA AMB PATIENT ROOM'
		    --WHEN '4147' THEN 'T UVA  PATIENT TRACKING R UVA AMB PATIENT TRACK VERSION 2'
	     -- END AS FLTFLM_Name
   FROM #FLM) FlwSht
   INNER JOIN #ScheduledClinicAppointment Appt
   ON Appt.INPATIENT_DATA_ID = FlwSht.INPATIENT_DATA_ID

  -- Create index for temp table #FLTPIVOT

  --CREATE UNIQUE CLUSTERED INDEX IX_FLTPIVOT ON #FLTPIVOT (PAT_ENC_CSN_ID_unhashed)

  --SELECT *
  --FROM #FLTFLM
  --ORDER BY RECORDED_TIME

  -- Create temp table #FLTPIVOT

  --SELECT
  --   PAT_ID
  -- , [PAT_ENC_CSN_ID_unhashed]
  -- , [2100000001] AS [AMB PATIENT VERIFIED]
  -- , [2103800001] AS [T UVA AMB PATIENT UNDERSTANDING AVS]
  -- , [2100300004] AS [UVA AMB VITALS SIMPLE]
  --INTO #FLTPIVOT
  --FROM
  --(SELECT PAT_ID
  --      , [PAT_ENC_CSN_ID_unhashed]
  --      , FLT_ID
		--, RECORDED_TIME
  -- FROM #FLT
  -- WHERE SeqNbr = 1) FlwSht
  --PIVOT
  --(
  --MAX(RECORDED_TIME)
  --FOR FLT_ID IN ([2100000001] -- AMB PATIENT VERIFIED
		--	   , [2103800001] -- T UVA AMB PATIENT UNDERSTANDING AVS
		--	   , [2100300004] -- UVA AMB VITALS SIMPLE
		--	    )
  --) AS PivotTable

  -- Create index for temp table #FLTPIVOT

  --CREATE UNIQUE CLUSTERED INDEX IX_FLTPIVOT ON #FLTPIVOT (PAT_ENC_CSN_ID_unhashed)
  
  -- Create temp table #FLMSummary

  --SELECT PAT_ID
  --     , PAT_ENC_CSN_ID_unhashed
	 --  , (SELECT MAX(flmt.MEAS_VALUE) + '|' AS [text()]
		--  FROM #FLM flmt
		--  WHERE flmt.PAT_ID = flm.PAT_ID
		--  AND flmt.PAT_ENC_CSN_ID_unhashed = flm.PAT_ENC_CSN_ID_unhashed
		--  AND flmt.FLO_MEAS_ID = '4143'
		--  GROUP BY flmt.RECORDED_TIME
	 --     FOR XML PATH ('')
	 --    ) AS Patient_Room
	 --  , (SELECT LEFT(CONVERT(VARCHAR(19),MAX(flmt.RECORDED_TIME),120),16)  + '|' AS [text()]
		--  FROM #FLM flmt
		--  WHERE flmt.PAT_ID = flm.PAT_ID
		--  AND flmt.PAT_ENC_CSN_ID_unhashed = flm.PAT_ENC_CSN_ID_unhashed
		--  AND flmt.FLO_MEAS_ID = '4143'
		--  GROUP BY flmt.FLO_MEAS_ID
		--         , flmt.RECORDED_TIME
	 --     FOR XML PATH ('')
	 --    ) AS Patient_Room_Recorded_DtTm
	 --  , (SELECT MAX(flmt.MEAS_VALUE) + '|' AS [text()]
		--  FROM #FLM flmt
		--  WHERE flmt.PAT_ID = flm.PAT_ID
		--  AND flmt.PAT_ENC_CSN_ID_unhashed = flm.PAT_ENC_CSN_ID_unhashed
		--  AND flmt.FLO_MEAS_ID = '4147'
		--  GROUP BY flmt.RECORDED_TIME
	 --     FOR XML PATH ('')
	 --    ) AS Patient_Track
	 --  , (SELECT LEFT(CONVERT(VARCHAR(19),MAX(flmt.RECORDED_TIME),120),16)  + '|' AS [text()]
		--  FROM #FLM flmt
		--  WHERE flmt.PAT_ID = flm.PAT_ID
		--  AND flmt.PAT_ENC_CSN_ID_unhashed = flm.PAT_ENC_CSN_ID_unhashed
		--  AND flmt.FLO_MEAS_ID = '4147'
		--  GROUP BY flmt.FLO_MEAS_ID
		--         , flmt.RECORDED_TIME
	 --     FOR XML PATH ('')
	 --    ) AS Patient_Track_Recorded_DtTm
  --INTO #FLMSummary
  --FROM #FLM flm
  --GROUP BY PAT_ID
  --       , PAT_ENC_CSN_ID_unhashed

  -- Create index for temp table #FLMSummary

  --CREATE UNIQUE CLUSTERED INDEX IX_FLMSummary ON #FLMSummary (PAT_ID, PAT_ENC_CSN_ID_unhashed)

  -- Create temp table #ScheduledClinicAppointmentDetail

 -- SELECT
 --    pa.PAT_ID
 --   ,pa.PAT_ENC_CSN_ID
	--,pa.PAT_ENC_CSN_ID_unhashed
 --   ,pa.DEPARTMENT_NAME
 --   ,pa.DEPT_SPECIALTY_NAME
 --   ,pa.PRC_NAME
	--,pa.ENC_REASON_NAME
 --   ,pa.APPT_LENGTH
 --   ,pa.APPT_STATUS_C
 --   ,pa.APPT_STATUS_NAME
 --   ,pa.[APPT_DATE]
 --   ,pa.[APPT_DTTM]
 --   ,pa.CHECKIN_DTTM
	--,flm.Patient_Room
	--,flm.Patient_Room_Recorded_DtTm
	--,flm.Patient_Track
	--,flm.Patient_Track_Recorded_DtTm
 --   ,pa.ARVL_LIST_REMOVE_DTTM
 --   ,CAST(flt.[AMB PATIENT VERIFIED] AS SMALLDATETIME) AS [AMB PATIENT VERIFIED]
 --   ,CAST(flt.[T UVA AMB PATIENT UNDERSTANDING AVS] AS SMALLDATETIME) AS [T UVA AMB PATIENT UNDERSTANDING AVS]
 --   ,CAST(flt.[UVA AMB VITALS SIMPLE] AS SMALLDATETIME) AS [UVA AMB VITALS SIMPLE]
 --   ,pa.APPT_MADE_DATE
	--,pa.APPT_MADE_DTTM
 --   ,pa.APPT_CANC_DATE
 --   ,pa.[Previous PAT_ENC_CSN_ID]
	--,pa.[Previous PAT_ENC_CSN_ID_unhashed]
 --   ,pa.[Previous Appointment Time]
 --   ,pa.[Previous APPT_LENGTH]
 --   ,pa.INPATIENT_DATA_ID
 --   ,pa.DEPARTMENT_ID
 --   ,pa.SIGNIN_DTTM
	--,pa.PAGED_DTTM
	--,pa.BEGIN_CHECKIN_DTTM
	--,pa.ROOMED_DTTM
	--,pa.FIRST_ROOM_ASSIGN_DTTM
	--,pa.NURSE_LEAVE_DTTM
	--,pa.PHYS_ENTER_DTTM
	--,pa.VISIT_END_DTTM
	--,pa.CHECKOUT_DTTM
	--,pa.TIME_TO_ROOM_MINUTES
	--,pa.TIME_IN_ROOM_MINUTES
	--,pa.CYCLE_TIME_MINUTES
	--,pa.APPT_CANC_DTTM
	--,pa.F2F_Flag
	--,pa.ENTRY_DATE
	--,pa.CHANGE_DATE
	--,pa.PROV_NAME
	--,pa.UPDATE_DATE
 -- INTO #ScheduledClinicAppointmentDetail
 -- FROM #ScheduledClinicAppointment AS pa
 -- LEFT OUTER JOIN (SELECT PAT_ID
 --                       , PAT_ENC_CSN_ID_unhashed
	--					, Patient_Room
	--					, Patient_Room_Recorded_DtTm
	--					, Patient_Track
	--					, Patient_Track_Recorded_DtTm
 --                  FROM #FLMSummary) flm
 -- ON ((flm.PAT_ID = pa.PAT_ID) AND (flm.PAT_ENC_CSN_ID_unhashed = pa.PAT_ENC_CSN_ID_unhashed))
 -- LEFT OUTER JOIN (SELECT [PAT_ENC_CSN_ID_unhashed]
 --                       , [AMB PATIENT VERIFIED]
 --                       , [T UVA AMB PATIENT UNDERSTANDING AVS]
	--					, [UVA AMB VITALS SIMPLE]
 --                  FROM #FLTPIVOT) flt
 -- ON flt.[PAT_ENC_CSN_ID_unhashed] = pa.[PAT_ENC_CSN_ID_unhashed]

  SELECT
     pa.PAT_ID
	,pa.PAT_ENC_CSN_ID_unhashed
    ,pa.DEPARTMENT_NAME
    ,pa.PRC_NAME
    ,pa.APPT_LENGTH
    ,pa.APPT_STATUS_NAME
    ,pa.INPATIENT_DATA_ID
    ,pa.DEPARTMENT_ID
	,pa.TIME_TO_ROOM_MINUTES
	,pa.TIME_IN_ROOM_MINUTES
	,pa.CYCLE_TIME_MINUTES
	,pa.PROV_NAME
	,pa.APPT_MADE_DTTM
	,pa.APPT_DATE
	,pa.PAT_MRN_ID
	,pa.[Event] AS [Timestamp]
	,pa.RECORDED_TIME
  INTO #ScheduledClinicAppointmentDetail
  FROM
  (
  SELECT PAT_ID
	    ,PAT_ENC_CSN_ID_unhashed
        ,DEPARTMENT_NAME
        ,PRC_NAME
        ,APPT_LENGTH
        ,APPT_STATUS_NAME
        ,INPATIENT_DATA_ID
        ,DEPARTMENT_ID
	    ,TIME_TO_ROOM_MINUTES
	    ,TIME_IN_ROOM_MINUTES
	    ,CYCLE_TIME_MINUTES
	    ,PROV_NAME
		,APPT_MADE_DTTM
		,APPT_DATE
		,PAT_MRN_ID
		,[Event]
		,[Timestamp] AS RECORDED_TIME
  FROM #ScheduledClinicAppointmentUnpivot
  WHERE APPT_STATUS_NAME = 'Completed'
  UNION ALL
  SELECT PAT_ID
	    ,PAT_ENC_CSN_ID_unhashed
        ,DEPARTMENT_NAME
        ,PRC_NAME
        ,APPT_LENGTH
        ,APPT_STATUS_NAME
        ,INPATIENT_DATA_ID
        ,DEPARTMENT_ID
	    ,TIME_TO_ROOM_MINUTES
	    ,TIME_IN_ROOM_MINUTES
	    ,CYCLE_TIME_MINUTES
	    ,PROV_NAME
		,APPT_MADE_DTTM
		,APPT_DATE
		,PAT_MRN_ID
		,DISP_NAME + ' ' + MEAS_VALUE AS [Event]
		,RECORDED_TIME
  FROM #FLTFLM
  WHERE #FLTFLM.FLO_MEAS_ID IN ('4143','4147')
  ) pa

  --SELECT *
  --FROM #ScheduledClinicAppointmentDetail
  ----ORDER BY PAT_ID
  ----       , PAT_ENC_CSN_ID_unhashed
  --ORDER BY PAT_ID
  --       , PAT_ENC_CSN_ID_unhashed
		-- , RECORDED_TIME

  -- Create temp table #RptgTemp

  SELECT
     [MRN]
	,[PAT_ENC_CSN_ID]
    ,[DEPARTMENT_NAME]
	,[PROV_NAME]
	,[PRC_NAME]
	,[APPT_LENGTH]
	,[APPT_STATUS_NAME]
	,[APPT_MADE_DTTM]
	,[APPT_DATE]
	,[TIME_TO_ROOM_MINUTES]
	,[TIME_IN_ROOM_MINUTES]
	,[CYCLE_TIME_MINUTES]
	,[Timestamp]
	,[RECORDED_TIME]
    --,'Rptg.uspSrc_iQueue_Outpatient_Daily' AS [ETL_guid]
    ,GETDATE()                             AS Load_Dte
  INTO #RptgTemp FROM
   (
    SELECT
	   pa.PAT_MRN_ID AS [MRN]
      ,pa.PAT_ENC_CSN_ID_unhashed AS [PAT_ENC_CSN_ID]
      ,[DEPARTMENT_NAME]
	  ,[PROV_NAME]
	  ,[PRC_NAME]
	  ,[APPT_LENGTH]
	  ,[APPT_STATUS_NAME]
	  ,[APPT_MADE_DTTM]
	  ,[APPT_DATE]
	  ,[TIME_TO_ROOM_MINUTES]
	  ,[TIME_IN_ROOM_MINUTES]
	  ,[CYCLE_TIME_MINUTES]
	  ,[Timestamp]
	  ,[RECORDED_TIME]
    FROM #ScheduledClinicAppointmentDetail AS pa
   ) A

  SELECT *
  FROM #RptgTemp
  ORDER BY MRN
         , APPT_DATE
		 , RECORDED_TIME

  -- Put contents of temp table #RptgTemp into db table

  --INSERT INTO CLARITY_App.Stage.iQueue_Infusion_Extract
  --            ([Appointment ID],[Unit Name],[Visit Type],[Appointment Type],[Expected Duration],[Appointment Status],
  --             [APPT_DTTM],[Check-in Time],[Chair Time],[First Med Start],[Last Med Stop],
  --             [BCN INFUSION NURSE ASSIGNMENT],[T UVA AMB PATIENT UNDERSTANDING AVS],[Appointment Made Date],[Cancel Date],[Linked Appointment Flag],
  --             [Clinic Appointment Time],[Clinic Appointment Length],[Treatment Plan],[Treatment Plan Provider],
		--	   [Intake Time],[Check-out Time],[ETL_guid],[Load_Dte])

  --SELECT
  --  [Appointment ID]
  -- ,[Unit Name]
  -- ,[Visit Type]
  -- ,[Appointment Type]
  -- ,[Expected Duration]
  -- ,[Appointment Status]
  -- ,[APPT_DTTM]
  -- ,[Check-in Time]
  -- ,[Intake Time]
  -- ,[Check-out Time]
  -- ,[Chair Time]
  -- ,[First Med Start]
  -- ,[Last Med Stop]
  -- ,[BCN INFUSION NURSE ASSIGNMENT]
  -- ,[T UVA AMB PATIENT UNDERSTANDING AVS]
  -- ,[Appointment Made Date]
  -- ,[Cancel Date]
  -- ,[Linked Appointment Flag]
  -- ,[Clinic Appointment Time]
  -- ,[Clinic Appointment Length]
  -- ,SUBSTRING(ISNULL(RTRIM([Treatment Plan]),'|'),1,200)         AS [Treatment Plan]
  -- ,SUBSTRING(ISNULL(RTRIM([Treatment Plan Provider]),'|'),1,18) AS [Treatment Plan Provider]
  -- ,[ETL_guid]
  -- ,[Load_Dte]
  --FROM #RptgTemp
  --ORDER BY [APPT_DTTM]

  --SELECT
  --  --ISNULL(CONVERT(VARCHAR(254),[PAT_ENC_CSN_ID]),'')					AS [PAT_ENC_CSN_ID]
  --  ISNULL(CONVERT(VARCHAR(256),[PAT_ENC_CSN_ID],2),'')					AS [PAT_ENC_CSN_ID]
  -- ,ISNULL(CONVERT(VARCHAR(254),[DEPARTMENT_NAME]),'')					AS [DEPARTMENT_NAME]
  -- ,ISNULL(CONVERT(VARCHAR(200),[PROV_NAME]),'')						AS [PROV_NAME]
  -- ,ISNULL(CONVERT(VARCHAR(19),[APPT_DTTM],121),'')						AS [APPT_DTTM]
  -- ,ISNULL(CONVERT(VARCHAR(254),LEFT([ENC_REASON_NAME],LEN([ENC_REASON_NAME])-1)),'')			AS [ENC_REASON_NAME]
  -- ,ISNULL(CONVERT(VARCHAR(254),[PRC_NAME]),'')							AS [PRC_NAME]
  -- ,ISNULL(CONVERT(VARCHAR(18),[APPT_LENGTH]),'')						AS [APPT_LENGTH]
  -- ,ISNULL(CONVERT(VARCHAR(254),[APPT_STATUS_NAME]),'')					AS [APPT_STATUS_NAME]
  -- ,ISNULL(CONVERT(VARCHAR(19),[APPT_MADE_DTTM],121),'')				AS [APPT_MADE_DTTM]
  -- ,ISNULL(CONVERT(VARCHAR(19),[APPT_CANC_DTTM],121),'')				AS [APPT_CANC_DTTM]
  -- ,ISNULL(CONVERT(VARCHAR(19),[UPDATE_DATE],121),'')					AS [UPDATE_DATE]
  -- ,ISNULL(CONVERT(VARCHAR(19),[SIGNIN_DTTM],121),'')					AS [SIGNIN_DTTM]
  -- ,ISNULL(CONVERT(VARCHAR(19),[BEGIN_CHECKIN_DTTM],121),'')			AS [BEGIN_CHECKIN_DTTM]
  -- ,ISNULL(CONVERT(VARCHAR(19),[CHECKIN_DTTM],121),'')					AS [CHECKIN_DTTM]
  -- ,ISNULL(CONVERT(VARCHAR(254),LEFT([Patient_Room],LEN([Patient_Room])-1)),'')					AS [Patient_Room]
  -- ,ISNULL(CONVERT(VARCHAR(254),LEFT([Patient_Room_Recorded_DtTm],LEN([Patient_Room_Recorded_DtTm])-1)),'')					AS [Patient_Room_Recorded_DtTm]
  -- ,ISNULL(CONVERT(VARCHAR(254),LEFT([Patient_Track],LEN([Patient_Track])-1)),'')				AS [Patient_Track]
  -- ,ISNULL(CONVERT(VARCHAR(254),LEFT([Patient_Track_Recorded_DtTm],LEN([Patient_Track_Recorded_DtTm])-1)),'')				AS [Patient_Track_Recorded_DtTm]
  -- ,ISNULL(CONVERT(VARCHAR(19),[ARVL_LIST_REMOVE_DTTM],121),'')			AS [ARVL_LIST_REMOVE_DTTM]
  -- ,ISNULL(CONVERT(VARCHAR(19),[AMB PATIENT VERIFIED],121),'')			AS [AMB PATIENT VERIFIED]
  -- ,ISNULL(CONVERT(VARCHAR(19),[UVA AMB VITALS SIMPLE],121),'')			AS [UVA AMB VITALS SIMPLE]
  -- ,ISNULL(CONVERT(VARCHAR(19),[ROOMED_DTTM],121),'')					AS [ROOMED_DTTM]
  -- ,ISNULL(CONVERT(VARCHAR(19),[NURSE_LEAVE_DTTM],121),'')				AS [NURSE_LEAVE_DTTM]
  -- ,ISNULL(CONVERT(VARCHAR(19),[PHYS_ENTER_DTTM],121),'')				AS [PHYS_ENTER_DTTM]
  -- ,ISNULL(CONVERT(VARCHAR(19),[T UVA AMB PATIENT UNDERSTANDING AVS],121),'')					AS [T UVA AMB PATIENT UNDERSTANDING AVS]
  -- ,ISNULL(CONVERT(VARCHAR(19),[VISIT_END_DTTM],121),'')				AS [VISIT_END_DTTM]
  -- ,ISNULL(CONVERT(VARCHAR(19),[CHECKOUT_DTTM],121),'')					AS [CHECKOUT_DTTM]
  -- ,ISNULL(CONVERT(VARCHAR(18),[TIME_TO_ROOM_MINUTES]),'')				AS [TIME_TO_ROOM_MINUTES]
  -- ,ISNULL(CONVERT(VARCHAR(18),[TIME_IN_ROOM_MINUTES]),'')				AS [TIME_IN_ROOM_MINUTES]
  -- ,ISNULL(CONVERT(VARCHAR(18),[CYCLE_TIME_MINUTES]),'')				AS [CYCLE_TIME_MINUTES]
  -- ,[ETL_guid]
  -- ,CONVERT(VARCHAR(19),[Load_Dte],121) AS [Load_Dte]
  --FROM #RptgTemp
  ----WHERE [APPT_STATUS_NAME] IN ('Arrived','Completed')
  ----ORDER BY [APPT_DTTM]
  ----ORDER BY CAST([APPT_DTTM] AS DATE)
  ----       , APPT_STATUS_NAME
  --ORDER BY DEPARTMENT_NAME
  --       , APPT_DTTM

GO


