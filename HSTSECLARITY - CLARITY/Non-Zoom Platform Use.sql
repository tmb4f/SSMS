USE CLARITY

SELECT vvvs.[RECORD_ID] AS Video_Visit_Record_Id
      ,vvvs.[PAT_ENC_CSN_ID] AS Enc_CSN,
	  enc.CONTACT_DATE AS Enc_Contact_Date,
	  enc.APPT_TIME AS Enc_DTTM,
	  --enc.APPT_PRC_ID AS PROC_ID,
	  prc.PRC_NAME AS Enc_Prc_Name,
	  --,action.RECORD_ID,
       --action.CM_PHY_OWNER_ID,
       --action.CM_LOG_OWNER_ID,
       action.LINE AS Video_Visit_Action_Seq,
       --action.VV_ACTION_C,
	   zvva.NAME AS Video_Visit_Action_Name,
	   CLARITY.EPIC_UTIL.EFN_UTC_TO_LOCAL(action.ACTION_INST_UTC_DTTM) AS Video_Visit_Action_DTTM,
       action.VV_USER_ID AS Video_Visit_Action_User_Id, -- User Ids of video visit participants
	   emp.NAME AS Video_Visit_Action_User_Name,
	   emp.SYSTEM_LOGIN AS Video_Visit_Action_User_Login,
	   empr.DEFAULT_USER_ROLE AS Video_Visit_Action_User_Default_Role,
	   empd.EMAIL AS Video_Visit_Action_User_Email,
	   emp.PROV_ID AS Video_Visit_Action_User_Prov_Id,
       vvvs.[PAT_ID] AS Video_Visit_Patient_Id
	   ,pt.PAT_NAME AS Video_Visit_Patient_Name
      ,[ENC_PROV_ID] AS Enc_Prov_Id
	  ,ser.PROV_NAME AS Enc_Prov_Name
      ,[ENC_DEPARTMENT_ID] AS Enc_Department_Id,
	  dep.DEPARTMENT_NAME AS Enc_Department_Name,
	  dep.SPECIALTY AS Enc_Department_Specialty,
	  ztm.NAME AS Enc_Telehealth_Mode,
	  zdet.NAME AS Enc_Type_Name,
      enc.[APPT_STATUS_C],
	  zas.NAME AS APPT_STATUS_NAME,
	  --pt.SEX,
	  --pt.SEX_C,
	  zs.NAME AS Gender,
	  --zgi.NAME AS GENDER_IDENTITY_NAME,
	  pt.PAT_MRN_ID AS MRN,
	  --pt.ETHNIC_GROUP_C,
	  --zeg.NAME AS ETHNIC_GROUP_NAME,
	  zpr.NAME AS Race,
	  FLOOR((CAST(enc.CONTACT_DATE AS INTEGER)
                                        - CAST(pt.BIRTH_DATE AS INTEGER)
                                       ) / 365.25
                                      ) AS Age,
       action.VV_MYPT_ID AS Video_Visit_MyChart_Account_Id,
       --action.VV_USER_ROLE_C,
	   zvur.NAME AS Video_Visit_User_Role,
       action.VV_MEMBER_ID AS Video_Visit_Member_Id,
       --action.CAMERA_DEVICE_ID,
       action.VV_EXTERNAL_VENDOR AS Video_Visit_External_Vendor
      -- action.ACTION_INST_UTC_DTTM,
      -- --action.BROWSER_C,
      -- --action.OPERATING_SYSTEM_C,
      -- action.HARDWARE_TEST_STATUS,
      -- --action.ACTION_COMMENTS,
      -- action.CLIENT_APP_C,
      -- --action.BROWSER_VERSION,
      -- --action.OS_VERSION,
      -- --action.VIDEO_DEVICE,
      -- --action.PHONE_NUMBER,
      -- action.EMAIL_ADDRESS--,
      -- --action.ACTION_CSN_ID
      --,vvvs.[EFFECTIVE_DATE_DT]
      --,[ENC_REV_LOC_ID]
      --,[ENC_SERV_AREA_ID]
      --,[ENC_PRC_VT_ID]
      ,[SUCCESSFUL_CONNECT_YN]
      ,[ATTEMPTED_CONNECT_CNT]
      ,[MYPT_CONNECT_CNT]
      --,[PAT_QUEUE_CNT]
      --,[PAT_HARDWARE_FAILURE_CNT]
      --,[DISP_ENC_TYPE_C]
      --,[PAT_QUEUE_JOIN_UTC_DTTM]
      --,[PROV_JOIN_UTC_DTTM]
      --,[DURATION_PAT_TO_PROV_JOIN]
      --,[LEN_IN_SECONDS]
      --,[ON_DEMAND_VIDEO_VISIT_C]
      --,[SCHED_BY_PAT_ONLINE_YN]
      --,[MYCH_WEB_CONNECT_CNT]
      --,[MYCH_MOBILE_CONNECT_CNT]
      --,[MYCH_BEDSIDE_CONNECT_CNT]
      --,[HYPERSPACE_CONNECT_CNT]
      --,[EC_LINK_CONNECT_CNT]
      --,[HAIKU_CONNECT_CNT]
      --,[ROVER_CONNECT_CNT]
      --,[CAMERA_FAILURES_CNT]
      --,[MICROPHONE_FAILURES_CNT]
      --,[SPEAKER_FAILURES_CNT]
      --,[NETWORK_FAILURE_CNT]
      --,[LATE_START_SECONDS]
      --,[IS_INPATIENT_YN]
      --,[CONNCTD_PARTIES_NUM]
      --,[CANTO_CONNECT_CNT]
      --,[DIRECT_LINK_CONNECT_CNT]
      --,[DI_PHYS_MOBILE_CONNECT_CNT]
      --,[PAT_CLIENT_APP_TARGET_C]
      --,[PROV_CLIENT_APP_TARGET_C]
      --,[GENERIC_FAILURE_COUNT]
      --,[PROV_HARDWARE_FAILURE_CNT]
      --,[SUCCESSFUL_VISIT_YN]
      --,[MYCH_OUTPATIENT_VISIT_YN]
      --,[MYCH_INPATIENT_VISIT_YN]
      --,[DIRECT_LINK_PROV_CONNECT_CNT]
      --,[GROUP_LINK]
  FROM [CLARITY].[dbo].[V_VIDEO_VISIT_STATS] vvvs
  INNER JOIN CLARITY.dbo.PAT_ENC enc
  ON vvvs.PAT_ENC_CSN_ID = enc.PAT_ENC_CSN_ID
  LEFT OUTER JOIN CLARITY.dbo.PAT_ENC_6 enc6
  ON enc6.PAT_ENC_CSN_ID = enc.PAT_ENC_CSN_ID
  LEFT OUTER JOIN CLARITY.dbo.[AUDITED_VIDEO_ACTIONS] [action]
  ON action.RECORD_ID = vvvs.RECORD_ID
  LEFT OUTER JOIN CLARITY.dbo.ZC_APPT_STATUS zas
  ON zas.APPT_STATUS_C = enc.APPT_STATUS_C
  LEFT OUTER JOIN CLARITY.dbo.ZC_VIDEO_VISIT_ACTION zvva
  ON zvva.VIDEO_VISIT_ACTION_C = [action].VV_ACTION_C
  LEFT OUTER JOIN CLARITY.dbo.ZC_VV_USER_ROLE zvur
  ON zvur.USER_ROLE_C = [action].VV_USER_ROLE_C
  LEFT OUTER JOIN CLARITY.dbo.CLARITY_EMP emp
  ON emp.USER_ID = [action].VV_USER_ID
  LEFT OUTER JOIN
  (
  SELECT *
  FROM CLARITY.dbo.CLARITY_EMP_ROLE
  WHERE LINE = 1
  ) empr
  ON empr.USER_ID = emp.USER_ID
  LEFT OUTER JOIN CLARITY.dbo.CLARITY_EMP_DEMO empd
  ON empd.USER_ID = emp.USER_ID
  LEFT OUTER JOIN CLARITY.dbo.CLARITY_SER ser
  ON ser.PROV_ID = vvvs.ENC_PROV_ID
  LEFT OUTER JOIN CLARITY.dbo.CLARITY_DEP dep
  ON dep.DEPARTMENT_ID = vvvs.ENC_DEPARTMENT_ID
  LEFT OUTER JOIN CLARITY.dbo.CLARITY_PRC prc
  ON prc.PRC_ID = enc.APPT_PRC_ID
  LEFT OUTER JOIN CLARITY.dbo.ZC_TELEHEALTH_MODE ztm
  ON ztm.TELEHEALTH_MODE_C = enc6.TELEHEALTH_MODE_C
  LEFT OUTER JOIN CLARITY.dbo.PATIENT pt
  ON pt.PAT_ID = vvvs.PAT_ID
  LEFT OUTER JOIN CLARITY.dbo.PATIENT_4 pt4
  ON pt4.PAT_ID = vvvs.PAT_ID
  LEFT OUTER JOIN CLARITY.dbo.ZC_SEX zs
  ON zs.RCPT_MEM_SEX_C = pt.SEX_C
  LEFT OUTER JOIN CLARITY.dbo.ZC_DISP_ENC_TYPE zdet
  ON zdet.DISP_ENC_TYPE_C = enc.ENC_TYPE_C
  LEFT OUTER JOIN CLARITY.dbo.ZC_GENDER_IDENTITY zgi
  ON zgi.GENDER_IDENTITY_C = pt4.GENDER_IDENTITY_C
  LEFT OUTER JOIN CLARITY.dbo.ZC_ETHNIC_GROUP zeg
  ON zeg.ETHNIC_GROUP_C = pt.ETHNIC_GROUP_C
  LEFT JOIN CLARITY.dbo.PATIENT_RACE pr ON enc.PAT_ID = pr.PAT_ID
	AND pr.LINE = 1
  LEFT JOIN CLARITY.dbo.ZC_PATIENT_RACE zpr ON pr.PATIENT_RACE_C = zpr.PATIENT_RACE_C

  WHERE enc.CONTACT_DATE >= '6/1/2022' AND enc.CONTACT_DATE < '9/26/2022'
  AND vvvs.ATTEMPTED_CONNECT_CNT > 0
  --AND vvvs.PAT_ENC_CSN_ID = 200050666630
  --AND vvvs.PAT_ENC_CSN_ID = 200051890727
  --AND vvvs.PAT_ENC_CSN_ID IN (200050666630,200050665377,200050661365)
  --AND  zas.NAME = 'Completed'
  
  ORDER BY vvvs.PAT_ENC_CSN_ID, vvvs.RECORD_ID, action.LINE
  --ORDER BY enc.CONTACT_DATE, vvvs.PAT_ENC_CSN_ID, vvvs.RECORD_ID, action.LINE