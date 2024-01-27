USE CLARITY

SELECT appt.[PAT_ENC_CSN_ID]
      --,appt.[UPDATE_DATE]
      ,appt.[CONTACT_DATE] AS APPT_DT
      ,[APPT_DTTM]
      ,appt.[PAT_ID]
	  ,pt.PAT_NAME
	  ,pt.PAT_MRN_ID
      --,appt.[APPT_STATUS_C]
	  ,zcappt.NAME AS [APPT_STATUS]
	  ,prc.PRC_NAME AS VISIT_TYPE
      ,appt.[DEPARTMENT_ID]
	  ,dep.DEPARTMENT_NAME
      ,appt.[PROV_ID]
	  ,ser.PROV_NAME
      --,[PRC_ID]
      --,[APPT_MADE_DTTM]
      --,[APPT_MADE_DATE]
      --,[APPT_BLOCK_C]
	  --,fu.LINE
	  ,fu.DISPOSITION
	  ,fu.DISP_ID
	  ,fu.NUM_OF_UNITS
	  --,fu.UNIT_TYPE_C
	  ,ut.NAME AS UNIT_TYPE
	  ,fu.DISP_DATE
	  ,fu.FREE_TEXT
	  ,fu.PRN_TEXT
      --,[APPT_LENGTH]
      --,[CHECKIN_DTTM]
      --,[CHECKOUT_DTTM]
      --,[ARVL_LIST_REMOVE_DTTM]
      --,[SIGNIN_DTTM]
      --,[PAGED_DTTM]
      --,[ROOMED_DTTM]
      --,[NURSE_LEAVE_DTTM]
      --,[PHYS_ENTER_DTTM]
      --,[VISIT_END_DTTM]
      --,[APPT_ENTRY_USER_ID]
      --,[APPT_CANC_USER_ID]
      --,[APPT_CANC_DTTM]
      --,[APPT_CANC_DATE]
      --,[CANCEL_REASON_C]
      --,[APPT_SERIAL_NUM]
      --,[RESCHED_APPT_CSN_ID]
      --,[REFERRAL_ID]
      --,[ACCOUNT_ID]
      --,[COVERAGE_ID]
      --,[CHARGE_SLIP_NUMBER]
      --,[HSP_ACCOUNT_ID]
      --,[APPT_CONF_STAT_C]
      --,[APPT_CONF_USER_ID]
      --,[APPT_CONF_DTTM]
      --,[CHECK_IN_KIOSK_ID]
      --,[SCHED_FROM_KIOSK_ID]
      --,[CHECK_OUT_KIOSK_ID]
      --,[IP_DOC_CONTACT_CSN]
      --,[WALK_IN_YN]
      --,[SEQUENTIAL_YN]
      --,[CNS_WARNING_OVERRIDDEN_YN]
      --,[SAME_DAY_CANC_YN]
      --,[OVERBOOKED_YN]
      --,[OVERRIDE_YN]
      --,[UNAVAILABLE_TIME_YN]
      --,[REFERRAL_REQ_YN]
      --,[REFERRING_PROV_ID]
      --,[SAME_DAY_YN]
      --,[NUMBER_OF_CALLS]
      --,[CHANGE_CNT]
      --,[JOINT_APPT_YN]
      --,appt.[CM_CT_OWNER_ID]
      --,[PHONE_REM_STAT_C]
      --,[COPAY_DUE]
      --,[COPAY_COLLECTED]
      --,[COPAY_USER_ID]
      --,[FIRST_ROOM_ASSIGN_DTTM]
      --,[BEGIN_CHECKIN_DTTM]
      --,[APPT_ARRIVAL_DTTM]
      --,[APPT_UTC_DTTM]
      --,[APPT_CANC_UTC_DTTM]
      --,[APPT_MADE_UTC_DTTM]
      --,[APPT_SCHED_SOURCE_C]
      --,[PAT_ONLINE_YN]
      --,[ECHKIN_STATUS_C]
      --,[PAT_SCHED_MYC_STAT_C]
      --,[LATE_CANCEL_YN]
  FROM [dbo].[F_SCHED_APPT] appt
  --INNER JOIN dbo.PAT_ENC_FOLLOW_UPS fu
  LEFT OUTER JOIN dbo.PAT_ENC_FOLLOW_UPS fu
  ON appt.PAT_ENC_CSN_ID = fu.PAT_ENC_CSN_ID
  LEFT OUTER JOIN dbo.CLARITY_SER ser
  ON ser.PROV_ID = appt.PROV_ID
  LEFT OUTER JOIN dbo.CLARITY_DEP dep
  ON dep.DEPARTMENT_ID = appt.DEPARTMENT_ID
  LEFT OUTER JOIN dbo.PATIENT pt
  ON pt.PAT_ID = appt.PAT_ID
  LEFT OUTER JOIN dbo.ZC_APPT_STATUS AS zcappt
  ON appt.APPT_STATUS_C = zcappt.APPT_STATUS_C
  LEFT OUTER JOIN dbo.ZC_DISP_UNIT_TYPE ut
  ON ut.DISP_UNIT_TYPE_C = fu.UNIT_TYPE_C
  LEFT OUTER JOIN dbo.CLARITY_PRC prc
  ON prc.PRC_ID = appt.PRC_ID
  WHERE
  appt.APPT_STATUS_C = 2
  AND appt.DEPARTMENT_ID = 10354024
  --AND (ser.PROV_NAME LIKE 'BARCIA%' OR ser.PROV_NAME LIKE 'NORWOOD, V%')
  AND appt.CONTACT_DATE >= '11/1/2018'
  ORDER BY appt.APPT_DTTM