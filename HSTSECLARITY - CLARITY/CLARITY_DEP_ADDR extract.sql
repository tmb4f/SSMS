/****** Script for SelectTopNRows command from SSMS  ******/
SELECT DISTINCT
       dep.[DEPARTMENT_ID]
      ,[DEPARTMENT_NAME]
      ,[DEPT_ABBREVIATION]
      ,[SPECIALTY]
	  ,mdm.REV_LOC_NAME
	  ,mdm.HOSPITAL_CODE
	  ,mdm.LOC_RPT_GRP_NINE_NAME
	  ,mdm.HOSPITAL_GROUP
	  ,addr.ADDRESS
      --,[REV_LOC_ID]
      --,[DEP_GROUP]
      --,[GL_PREFIX]
      ,[RPT_GRP_ONE]
      ,[RPT_GRP_TWO]
      --,[RPT_GRP_THREE]
      --,[RPT_GRP_FOUR]
      --,[RPT_GRP_FIVE]
      --,[RPT_GRP_SIX]
      --,[RPT_GRP_SEVEN]
      --,[RPT_GRP_EIGHT]
      --,[RPT_GRP_NINE]
      --,[RPT_GRP_TEN]
      --,[ADT_PARENT_ID]
      --,[SERV_AREA_ID]
      --,[SPECIALTY_DEP_C]
      --,[LICENSED_BEDS]
      --,[MASTER_POOL_ID]
      --,[MASTER_POOL_NAME]
      --,[COVERING_POOL_ID]
      --,[COVERING_POOL_NAME]
      --,[FLASH_CARD_PRT_ROU]
      --,[NUM_FLASH_CARDS]
      --,[CTRL_SHEET_ROU]
      --,[NUM_CONTROL_SHEETS]
      --,[ADT_UNIT_TYPE_C]
      ----,[CM_PHY_OWNER_ID]
      ----,[CM_LOG_OWNER_ID]
      --,[RPT_GRP_ELEVEN_C]
      --,[RPT_GRP_TWELVE_C]
      --,[RPT_GRP_THIRTEEN_C]
      --,[RPT_GRP_FOURTEEN_C]
      --,[RPT_GRP_FIFTEEN_C]
      --,[RPT_GRP_SIXTEEN_C]
      --,[RPT_GRP_SEVNTEEN_C]
      --,[RPT_GRP_EIGHTEEN_C]
      --,[RPT_GRP_NINETEEN_C]
      --,[RPT_GRP_TWENTY_C]
      --,[DFLT_PHARMACY_ID]
      --,[CENTER_C]
      --,[RECORD_STATUS]
      --,[OUTPAT_DUP_INT_STR]
      --,[INPAT_DUP_INT_STR]
      --,[RX_LOGON_PHR_ID]
      --,[RX_CHARGE_ADMIN_YN]
      --,[MAR_LABEL_PRNTR_ID]
      --,[ALLOW_AUTO_FUT_YN]
      --,[DEF_COE_ORD_MOD_C]
      --,[ORD_MOD_OP_CAP]
      --,[ORD_MOD_IP_CAP]
      --,[IP_MED_PREF_ID]
      --,[MR_HSB_LINK_USER]
      --,[COST_CENTER_ID]
      --,[REQ_ADM_HAR_MCH_YN]
      --,[USE_HAR_REC_YN]
      --,[HAR_DEF_ACT_TYPE_C]
      --,[COPAY_WAIVE_C]
      --,[IGNOR_DSP_PATXFR_YN]
      --,[PROMPT_REDIR_YN]
      --,[PROMPT_DYS_CHK_C]
      --,[PROMPT_MSG_TEXT_C]
      --,[NEAREST_PROC_TIME]
      --,[NEAREST_PROC_TIME_C]
      --,[DEP_ED_TYPE_C]
      --,[SCHD_INTRP_AUTO_YN]
      --,[RPT_GRP_TWENTYONE]
      --,[RPT_GRP_TWENTYTWO]
      --,[RPT_GRP_TWENTYTHREE]
      --,[RPT_GRP_TWENTYFOUR]
      --,[RPT_GRP_TWENTYFIVE]
      --,[RPT_GRP_TWENTYSIX]
      --,[RPT_GRP_TWENTYSEVEN]
      --,[RPT_GRP_TWENTYEIGHT]
      --,[RPT_GRP_TWENTYNINE]
      --,[RPT_GRP_THIRTY]
      --,[RPT_GRP_THIRTYONE_C]
      --,[RPT_GRP_THIRTYTWO_C]
      --,[RPT_GRP_TRTYTHREE_C]
      --,[RPT_GRP_TRTYFOUR_C]
      --,[RPT_GRP_TRTYFIVE_C]
      --,[RPT_GRP_THIRTYSIX_C]
      --,[RPT_GRP_TRTYSEVEN_C]
      --,[RPT_GRP_TRTYEIGHT_C]
      --,[RPT_GRP_TRTYNINE_C]
      --,[RPT_GRP_FOURTY_C]
      --,[REVERIFY_ORDERS_YN]
      --,[PPL_DEPT_YN]
      ,[EXTERNAL_NAME]
      ,[PHONE_NUMBER]
      --,[OR_UNIT_TYPE_C]
      --,[BED_COLUMN_INFO_ID]
      --,[IS_PERIOP_DEP_YN]
      --,[TX_PLAN_REL_CATS_ID]
      --,[FACILITY_C]
      --,[INPATIENT_DEPT_YN]
      --,[CARE_AREA_C]
      --,[RESTRICTED_DEPT_YN]
      --,[PHYSICAL_LOC_C]
      --,[LAG_TIME]
      --,[AUTO_PROMPT_CNTR_YN]
      --,[CLM_ALT_NAME]
      --,[CLM_ALT_CITY]
      --,[CLM_ALT_STATE_C]
      --,[CLM_ALT_ZIP]
      --,[CLM_ALT_PHONE]
  FROM [CLARITY].[dbo].[CLARITY_DEP] dep
  LEFT OUTER JOIN [CLARITY_App].Rptg.vwRef_MDM_Location_Master_Hospital_Group mdm
  ON mdm.EPIC_DEPARTMENT_ID = dep.DEPARTMENT_ID
  LEFT OUTER JOIN
  (
	SELECT *
	FROM [CLARITY].[dbo].[CLARITY_DEP_ADDR]
	WHERE LINE = 1
  ) addr
  ON addr.DEPARTMENT_ID = dep.DEPARTMENT_ID
  --WHERE dep.DEPt_Rec_Sts = 'Active'
  WHERE dep.DEPARTMENT_ID > 8
  ORDER BY dep.DEPARTMENT_ID