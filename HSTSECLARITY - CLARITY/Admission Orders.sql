/****** Script for SelectTopNRows command from SSMS  ******/
SELECT [ORDER_PROC_ID]
      ,[PAT_ID]
      ,[PAT_ENC_DATE_REAL]
      ,[PAT_ENC_CSN_ID]
      ,[RESULT_LAB_ID]
      ,[ORDERING_DATE]
      ,ord.[ORDER_TYPE_C]
	  ,zot.NAME AS ORDER_TYPE_NAME
      ,[PROC_ID]
      ,[PROC_CODE]
      ,[DESCRIPTION]
      ,ord.ORDER_CLASS_C
	  ,zoc.NAME AS ORDER_CLASS_NAME
      ,[AUTHRZING_PROV_ID]
      ,[ABNORMAL_YN]
      ,[BILLING_PROV_ID]
      ,[COSIGNER_USER_ID]
      ,[ORD_CREATR_USER_ID]
      ,[LAB_STATUS_C]
      ,ord.[ORDER_STATUS_C]
	  ,zos.NAME AS ORDER_STATUS_NAME
      ,[MODIFIER1_ID]
      ,[MODIFIER2_ID]
      ,[MODIFIER3_ID]
      ,[MODIFIER4_ID]
      ,[QUANTITY]
      ,[REASON_FOR_CANC_C]
      ,[FUTURE_OR_STAND]
      ,[STANDING_EXP_DATE]
      ,[FUT_EXPECT_COMP_DT]
      ,[STANDING_OCCURS]
      ,[STAND_ORIG_OCCUR]
      ,[RESULT_TYPE]
      ,[REFERRING_PROV_ID]
      ,[REFD_TO_LOC_ID]
      ,[REFD_TO_SPECLTY_C]
      ,[REQUESTED_SPEC_C]
      ,[RFL_PRIORITY]
      ,[RFL_CLASS_C]
      ,[RFL_TYPE_C]
      ,[RSN_FOR_RFL_C]
      ,[RFL_NUM_VIS]
      ,[RFL_EXPIRE_DT]
      ,[INTERFACE_STAT_C]
      ,[CPT_CODE]
      ,[UPDATE_DATE]
      ,[SERV_AREA_ID]
      ,[ABN_NOTE_ID]
      ,[RADIOLOGY_STATUS_C]
      ,[INT_STUDY_C]
      ,[INT_STUDY_USER_ID]
      ,[TECHNOLOGIST_ID]
      ,[FILMS_USED]
      ,[FILM_SIZE_C]
      ,[NUMBER_OF_REPEATS]
      ,[DOSE]
      ,[PROC_BGN_TIME]
      ,[PROC_END_TIME]
      ,[RIS_TRANS_ID]
      ,[ORDER_INST]
      ,[DISPLAY_NAME]
      ,[HV_HOSPITALIST_YN]
      ,[PROV_STATUS]
      ,[ORDER_PRIORITY_C]
      ,[CHRG_DROPPED_TIME]
      ,[PANEL_PROC_ID]
      ,[COSIGNER_AUTH_TIME]
      ,[COSIGNED_USER_ID]
      ,[STAND_INTERVAL]
      ,[DISCRETE_INTERVAL]
      ,[INSTANTIATED_TIME]
      ,[INSTNTOR_USER_ID]
      ,[DEPT_REF_PROV_ID]
      ,[SPECIALTY_DEP_C]
      ,[ORDERING_MODE]
      ,[SPECIMEN_TYPE_C]
      ,[SPECIMEN_SOURCE_C]
      ,[ORDER_TIME]
      ,[RESULT_TIME]
      ,[REVIEW_TIME]
      ,[IS_PENDING_ORD_YN]
      ,[PROC_START_TIME]
      ,[PROBLEM_LIST_ID]
      ,[RSLTS_INTERPRETER]
      ,[PROC_ENDING_TIME]
      ,ord.[CM_PHY_OWNER_ID]
      ,ord.[CM_LOG_OWNER_ID]
      ,[SPECIFIED_FIRST_TM]
      ,[SCHED_START_TM]
      ,[SESSION_KEY]
      ,[PROC_PERF_DEPT_ID]
      ,[PROC_PERF_PROV_ID]
      ,[PROC_PAT_CLASS_C]
      ,[PROC_LATERALITY_C]
      ,[PROC_POSSIBLE_YN]
      ,[PROC_DATE]
      ,[LABCORP_BILL_TYPE_C]
      ,[LABCORP_CLIENT_ID]
      ,[LABCORP_CONTROL_NUM]
      ,[NO_CHG_RSN_C]
      ,[MRK_RSLT_MSG_IMP_YN]
      ,[CHNG_ORDER_PROC_ID]
      ,[REC_ARCHIVED_YN]
	  ,orda.*
  FROM [CLARITY].[dbo].[ORDER_PROC] ord
  LEFT OUTER JOIN CLARITY.dbo.ZC_ORDER_TYPE zot
  ON zot.ORDER_TYPE_C = ord.ORDER_TYPE_C
  LEFT OUTER JOIN CLARITY.dbo.ZC_ORDER_CLASS zoc
  ON zoc.ORDER_CLASS_C = ord.ORDER_CLASS_C
  LEFT OUTER JOIN CLARITY.dbo.ZC_ORDER_STATUS zos
  ON zos.ORDER_STATUS_C = ord.ORDER_STATUS_C
  LEFT OUTER JOIN CLARITY.dbo.ORDER_APPT_INFO orda
  ON orda.ORDER_ID =ord.ORDER_PROC_ID
  WHERE ORDER_PROC_ID = 320465842