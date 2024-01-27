USE CLARITY

IF OBJECT_ID('tempdb..#cte ') IS NOT NULL
DROP TABLE #cte

IF OBJECT_ID('tempdb..#pdbs ') IS NOT NULL
DROP TABLE #pdbs;

WITH cte AS (

SELECT	
		paeh.PAT_ID
	,	paeh.PAT_ENC_CSN_ID
	,	paeh.CONTACT_DATE	

--Admit
	,	zads.TITLE					AS ADMIT_SOURCE
	,	paeh.ADT_PAT_CLASS_C
	,	paeh.HOSP_ADMSN_TIME
	,	zcsa.TITLE					AS ADMIT_CONF_STAT
	,	paeh.ADM_EVENT_ID
	
--Discharge
	,	paeh.HOSP_DISCH_TIME
	,	zcsd.TITLE					AS DISCH_CONF_STAT
	,	paeh.DIS_EVENT_ID	

--DEPs
	,	cada.DEPARTMENT_ID			AS DEP_ADMIT
	,	cdpa.DEPARTMENT_NAME		AS DEP_ADMIT_NAME
	,	paeh.DEPARTMENT_ID			AS DEP_ENC_CURRENT
	,	cdep.DEPARTMENT_NAME		AS DEP_ENC_CURRENT_NAME

--Other attributes
	,	zpac.TITLE					AS ADT_PAT_CLASS		--INPATIENT, OBSERVATION, ROUTINE POST PROCEDURE
	,	hbcm.BASE_CLASS_MAP_C
	,	zhat.TITLE					AS HOSP_ADMSN_TYPE
	,	paeh.ADT_PATIENT_STAT_C
	,	zpas.TITLE					AS ADT_PATIENT_STAT
	
FROM	PAT_ENC_HSP		paeh
			LEFT JOIN CLARITY_ADT			cada	ON paeh.ADM_EVENT_ID = cada.EVENT_ID			
			LEFT JOIN ZC_ADM_SOURCE			zads	ON paeh.ADMIT_SOURCE_C = zads.ADMIT_SOURCE_C
			LEFT JOIN ZC_PAT_CLASS			zpac	ON paeh.ADT_PAT_CLASS_C = zpac.ADT_PAT_CLASS_C
			LEFT JOIN HSD_BASE_CLASS_MAP	hbcm	ON paeh.ADT_PAT_CLASS_C = hbcm.ACCT_CLASS_MAP_C
			LEFT JOIN ZC_HOSP_ADMSN_TYPE	zhat	ON paeh.HOSP_ADMSN_TYPE_C = zhat.HOSP_ADMSN_TYPE_C
			LEFT JOIN ZC_CONF_STAT			zcsa	ON paeh.ADMIT_CONF_STAT_C = zcsa.ADMIT_CONF_STAT_C
			LEFT JOIN ZC_CONF_STAT			zcsd	ON paeh.ADMIT_CONF_STAT_C = zcsd.ADMIT_CONF_STAT_C
			LEFT JOIN CLARITY_DEP			cdep	ON paeh.DEPARTMENT_ID = cdep.DEPARTMENT_ID
			LEFT JOIN CLARITY_DEP			cdpa	ON cada.DEPARTMENT_ID = cdpa.DEPARTMENT_ID
			LEFT JOIN ZC_PAT_STATUS			zpas	ON paeh.ADT_PATIENT_STAT_C = zpas.ADT_PATIENT_STAT_C
				
WHERE	1=1		
	
	AND	(	hbcm.BASE_CLASS_MAP_C = 1					--1=IP, 2=OP
		OR	paeh.ADT_PAT_CLASS_C IN (104,105)			--104=OBSERVATION, 105=POST PROCEDURE
		)

--Admits
	AND (	(	paeh.ADMIT_CONF_STAT_C IN (1,4)			--1=Conf, 2=Pend, 3=Canc, 4=Comp
			--AND	paeh.HOSP_ADMSN_TIME >= '2020-09-01' 
			--AND paeh.HOSP_ADMSN_TIME <	'2021-01-01'
			AND	paeh.HOSP_ADMSN_TIME >= '2021-01-01' 
			AND paeh.HOSP_ADMSN_TIME <	'2021-02-06'
			)

--Discharges
		OR	(	paeh.DISCH_CONF_STAT_C IN (1,4)			--1=Conf, 2=Pend, 3=Canc, 4=Comp
			--AND	paeh.HOSP_DISCH_TIME >= '2020-09-01' 
			--AND paeh.HOSP_DISCH_TIME <	'2021-01-01'
			AND	paeh.HOSP_DISCH_TIME >= '2021-01-01' 
			AND paeh.HOSP_DISCH_TIME <	'2021-02-06'
			)
		)
)

SELECT	*
--INTO #cte
FROM	cte
--WHERE cte.ADT_PAT_CLASS NOT IN ('TCH INPATIENT','NEWBORN','INPATIENT PSYCHIATRY','HOSPICE INPATIENT')
--AND cte.adt_patient_stat NOT IN ('HOSPITAL OUTPATIENT VISIT')
ORDER BY cte.HOSP_ADMSN_TIME
--ORDER BY cte.PAT_ENC_CSN_ID

/*
SELECT [PAT_ENC_CSN_ID]
      ,[adt_pt_cls]
      ,[ADMIT_CONF_STAT]
      ,[ADT_PATIENT_STAT]
      ,[adm_date]
      ,[dsch_date]
      ,[adm_date_time]
      ,[dsch_date_time]
      ,[adm_time]
      ,[dsch_time]
      ,[sk_Fact_Pt_Enc_Clrt]
      ,[sk_Fact_Pt_Acct]
      ,[AcctNbr_int]
      ,[sk_Dim_Clrt_Pt]
      ,[adm_Fyear_num]
      ,[dsch_Fyear_num]
      ,[adm_fmonth_num]
      ,[dsch_fmonth_num]
      ,[adm_FYear_name]
      ,[dsch_FYear_name]
      ,[MRN_int]
      ,[sk_Adm_Dte]
      ,[sk_Dsch_Dte]
      ,[IndexAdmission]
      ,[sk_Dim_Pt]
      ,[adm_enc_sk_phys_adm]
      ,[adm_mdm_practice_group_id]
      ,[adm_mdm_practice_group_name]
      ,[adm_mdm_service_line_id]
      ,[adm_mdm_service_line]
      ,[adm_mdm_sub_service_line_id]
      ,[adm_mdm_sub_service_line]
      ,[adm_mdm_opnl_service_id]
      ,[adm_mdm_opnl_service_name]
      ,[adm_mdm_hs_area_id]
      ,[adm_mdm_hs_area_name]
      ,[adm_mdm_epic_department]
      ,[adm_mdm_epic_department_external]
      ,[adm_ADT_Evnt_Nme]
      ,[adm_Clrt_DEPt_Nme]
      ,[adm_DEPARTMENT_ID]
      ,[adm_Rm_Nme]
      ,[adm_Bed_Nme]
      ,[adm_LOC_Nme]
      ,[dsch_mdm_practice_group_id]
      ,[dsch_mdm_practice_group_name]
      ,[dsch_mdm_service_line_id]
      ,[dsch_mdm_service_line]
      ,[dsch_mdm_sub_service_line_id]
      ,[dsch_mdm_sub_service_line]
      ,[dsch_mdm_opnl_service_id]
      ,[dsch_mdm_opnl_service_name]
      ,[dsch_mdm_hs_area_id]
      ,[dsch_mdm_hs_area_name]
      ,[dsch_mdm_epic_department]
      ,[dsch_mdm_epic_department_external]
      ,[dsch_ADT_Evnt_Nme]
      ,[dsch_Clrt_DEPt_Nme]
      ,[dsch_DEPARTMENT_ID]
      ,[dsch_Rm_Nme]
      ,[dsch_Bed_Nme]
      ,[dsch_LOC_Nme]
      ,[HOSP_ADMSSN_STATS_C]
      ,[ADMIT_CATEGORY_C]
      ,[ADMIT_CATEGORY]
      ,[ADM_SOURCE]
      ,[HOSP_ADMSN_TYPE]
      ,[HOSP_ADMSN_STATUS]
      ,[adm_enc_sk_ser]
      ,[dsch_enc_sk_ser]
      ,[adm_enc_provider_id]
      ,[dsch_enc_provider_id]
      ,[adm_enc_provider_name]
      ,[dsch_enc_provider_name]
      ,[enc_sk_physcn]
      ,[adm_enc_physcn_Service_Line]
      ,[dsch_enc_physcn_Service_Line]
      ,[adm_atn_prov_sk_ser]
      ,[dsch_atn_prov_sk_ser]
      ,[adm_atn_prov_provider_id]
      ,[dsch_atn_prov_provider_id]
      ,[adm_atn_prov_provider_name]
      ,[dsch_atn_prov_provider_name]
      ,[adm_atn_prov_sk_physcn]
      ,[dsch_atn_prov_sk_physcn]
      ,[adm_atn_prov_physcn_Service_Line]
      ,[dsch_atn_prov_physcn_Service_Line]
      ,[sk_Dim_Clrt_Disch_Disp]
      ,[DISCH_DISP_C]
      ,[Clrt_Disch_Disp]
      ,[acuity_level_cde]
      ,[acuity_descr]
      ,[progression_level]
      ,[dsch_ord_date_time]
      ,[PT_FNAME_MI]
      ,[PT_LNAME]
      ,[BIRTH_DATE]
      ,[ETL_guid]
      ,[Load_Dte]
  FROM [DS_HSDW_App].[Rptg].[PatientDischargeByService_v2]
  WHERE ((sk_Adm_Dte BETWEEN 20200901 AND 20210101)
  OR (sk_Dsch_Dte BETWEEN 20200901 AND 20210101))
  AND adt_pt_cls IN ('Inpatient','Post Procedure','Observation')
  ORDER BY PAT_ENC_CSN_ID
  */
