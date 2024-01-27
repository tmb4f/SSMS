USE DS_HSDM_App

IF OBJECT_ID('tempdb..#appt ') IS NOT NULL
DROP TABLE #appt

SELECT [sk_Stage_Scheduled_Appointment]
      ,[PAT_ENC_CSN_ID]
      ,appt.[PAT_ID]
      ,[PAT_NAME]
      ,[IDENTITY_ID]
      ,[MYCHART_STATUS_C]
      ,[MYCHART_STATUS_NAME]
      ,[VIS_NEW_TO_SYS_YN]
      ,[VIS_NEW_TO_DEP_YN]
      ,[VIS_NEW_TO_PROV_YN]
      ,[APPT_SERIAL_NUM]
      ,[RESCHED_APPT_CSN_ID]
      ,[PRC_ID]
      ,[PRC_NAME]
      ,[APPT_BLOCK_C]
      ,[APPT_BLOCK_NAME]
      ,[APPT_LENGTH]
      ,[APPT_STATUS_C]
      ,[APPT_STATUS_NAME]
      ,[APPT_CONF_STAT_C]
      ,[CANCEL_LEAD_HOURS]
      ,[CANCEL_INITIATOR]
      ,[COMPLETED_STATUS_YN]
      ,[SAME_DAY_YN]
      ,[SAME_DAY_CANC_YN]
      ,[CANCEL_REASON_C]
      ,[CANCEL_REASON_NAME]
      ,[WALK_IN_YN]
      ,[OVERBOOKED_YN]
      ,[OVERRIDE_YN]
      ,[UNAVAILABLE_TIME_YN]
      ,[CHANGE_CNT]
      ,[JOINT_APPT_YN]
      ,[PHONE_REM_STAT_C]
      ,[PHONE_REM_STAT_NAME]
      ,[CONTACT_DATE]
      ,[APPT_MADE_DATE]
      ,[APPT_CANC_DATE]
      ,[APPT_CONF_DTTM]
      ,[APPT_DTTM]
      ,[SIGNIN_DTTM]
      ,[PAGED_DTTM]
      ,[BEGIN_CHECKIN_DTTM]
      ,[CHECKIN_DTTM]
      ,[ARVL_LIST_REMOVE_DTTM]
      ,[ROOMED_DTTM]
      ,[FIRST_ROOM_ASSIGN_DTTM]
      ,[NURSE_LEAVE_DTTM]
      ,[PHYS_ENTER_DTTM]
      ,[VISIT_END_DTTM]
      ,[CHECKOUT_DTTM]
      ,[TIME_TO_ROOM_MINUTES]
      ,[TIME_IN_ROOM_MINUTES]
      ,[CYCLE_TIME_MINUTES]
      ,[REFERRING_PROV_ID]
      ,[REFERRING_PROV_NAME_WID]
      ,[PROV_ID]
      ,[PROV_NAME_WID]
      ,[RPT_GRP_FIVE]
      ,[APPT_ENTRY_USER_ID]
      ,[APPT_ENTRY_USER_NAME_WID]
      ,[PROV_NAME]
      ,[PAYOR_ID]
      ,[PAYOR_NAME]
      ,[BENEFIT_PLAN_ID]
      ,[BENEFIT_PLAN_NAME]
      ,[FIN_CLASS_NAME]
      ,[DO_NOT_BILL_INS_YN]
      ,[SELF_PAY_VISIT_YN]
      ,[HSP_ACCOUNT_ID]
      ,[ACCOUNT_ID]
      ,[COPAY_DUE]
      ,[COPAY_COLLECTED]
      ,[COPAY_USER_ID]
      ,[COPAY_USER_NAME_WID]
      ,[DEPARTMENT_ID]
      ,[DEPARTMENT_NAME]
      ,[DEPT_ABBREVIATION]
      ,[RPT_GRP_THIRTY]
      ,[RPT_GRP_SIX]
      ,[RPT_GRP_SEVEN]
      ,[DEPT_SPECIALTY_C]
      ,[DEPT_SPECIALTY_NAME]
      ,[CENTER_C]
      ,[CENTER_NAME]
      ,[LOC_ID]
      ,[LOC_NAME]
      ,[SERV_AREA_ID]
      ,[APPT_STATUS_FLAG]
      ,appt.[Load_Dtm]
      ,appt.[sk_Dim_Pt]
      ,[sk_Fact_Pt_Enc_Clrt]
      ,[sk_Fact_Pt_Acct]
      ,[VIS_NEW_TO_SPEC_YN]
      ,[VIS_NEW_TO_SERV_AREA_YN]
      ,[VIS_NEW_TO_LOC_YN]
      ,[REFERRAL_ID]
      ,[ENTRY_DATE]
      ,[RFL_STATUS_NAME]
      ,[RFL_TYPE_NAME]
      ,[PROV_SPECIALTY_C]
      ,[PROV_SPECIALTY_NAME]
      ,[APPT_DT]
      ,[ENC_TYPE_C]
      ,[ENC_TYPE_TITLE]
      ,[APPT_CONF_STAT_NAME]
      ,[ZIP]
      ,[SER_RPT_GRP_SIX]
      ,[SER_RPT_GRP_EIGHT]
      ,[F2F_Flag]
      ,[APPT_CANC_DTTM]
      ,[APPT_CANC_USER_ID]
      ,[APPT_CANC_USER_NAME_WID]
      ,[APPT_CONF_USER_ID]
      ,[APPT_CONF_USER_NAME]
      ,[CHANGE_DATE]
      ,[APPT_MADE_DTTM]
      ,[UPDATE_DATE]
      ,[BILL_PROV_YN]
      ,[PROV_TYPE_OT_NAME]
      ,[PAT_SCHED_MYC_STAT_C]
      ,[PAT_SCHED_MYC_STAT_NAME]
	  ,CASE WHEN tm.[Communication_Type] IS NOT NULL THEN 1 ELSE 0 END AS [Telemedicine]
	  ,o.organization_name
	  ,s.service_name
	  ,c.clinical_area_name

INTO #appt

FROM [DS_HSDM_App].[Stage].[Scheduled_Appointment] appt
LEFT OUTER JOIN DS_HSDM_App.Mapping.Epic_Dept_Groupers g
ON g.epic_department_id = appt.DEPARTMENT_ID
LEFT OUTER JOIN DS_HSDM_App.Mapping.Ref_Clinical_Area_Map c
ON c.sk_Ref_Clinical_Area_Map = g.sk_Ref_Clinical_Area_Map
LEFT OUTER JOIN DS_HSDM_App.Mapping.Ref_Service_Map s
ON s.sk_Ref_Service_Map = c.sk_Ref_Service_Map
LEFT OUTER JOIN DS_HSDM_App.Mapping.Ref_Organization_Map o
ON o.organization_id = s.organization_id
LEFT OUTER JOIN (SELECT Encounter_CSN, Communication_Type FROM [TabRptg].[Dash_Telemedicine_Encounters_Tiles]) tm
ON tm.[Encounter_CSN] = appt.PAT_ENC_CSN_ID
                LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Patient AS pat
                    ON pat.sk_Dim_Pt = appt.sk_Dim_Pt
  WHERE APPT_DT >= '2022-01-02'
	        AND APPT_DT <=	'2022-01-08'
			AND pat.IS_VALID_PAT_YN = 'Y'
			AND appt.ENC_TYPE_C NOT IN ('2505','2506')

			SELECT *
			FROM #appt
  ORDER BY APPT_DTTM
  