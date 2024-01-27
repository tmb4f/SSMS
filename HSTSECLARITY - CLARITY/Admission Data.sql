USE CLARITY
GO

IF OBJECT_ID('tempdb..#CSNs ') IS NOT NULL
DROP TABLE #CSNs

IF OBJECT_ID('tempdb..#ADT ') IS NOT NULL
DROP TABLE #ADT

IF OBJECT_ID('tempdb..#REG_HX ') IS NOT NULL
DROP TABLE #REG_HX

IF OBJECT_ID('tempdb..#REG_HX_PIVOT ') IS NOT NULL
DROP TABLE #REG_HX_PIVOT

IF OBJECT_ID('tempdb..#REG_HX_DTTM ') IS NOT NULL
DROP TABLE #REG_HX_DTTM

IF OBJECT_ID('tempdb..#REG_HX_USER_ID ') IS NOT NULL
DROP TABLE #REG_HX_USER_ID

IF OBJECT_ID('tempdb..#STAT_HX_PREADM ') IS NOT NULL
DROP TABLE #STAT_HX_PREADM

SELECT DISTINCT
	 hsp.CONTACT_DATE
	,hsp.PAT_ID
    ,hsp.PAT_ENC_CSN_ID
	,hsp.HSP_ACCOUNT_ID
	,ISNULL(HSP.HOSP_ADMSN_TIME,hsp.EXP_ADMISSION_TIME) 'HOSP_ADMSN_TIME'
	,hsp.ADMIT_CONF_STAT_C
	,zcs.NAME AS ADMIT_CONF_STAT_NAME
	,hsp.ADMIT_SOURCE_C					
	,admsrc.NAME				'POINT_OF_ORIGIN'
	,hsp.HOSP_ADMSN_TYPE_C				
	,admtyp.NAME			'ADMISSION_TYPE'
	,hsp.HOSP_SERV_C				
	,svc.NAME							'SERVICE'
	,hsp.DEPARTMENT_ID
	,dep.DEPARTMENT_NAME				'UNIT'
	,hsp.ACCOMMODATION_C
	,acm.NAME							'ACCOMMODATION_CODE'
	,zcpttyp.NAME						'PATIENT_TYPE'
	,hsp.ADT_PAT_CLASS_C
	,zpc.NAME AS ADT_PAT_CLASS_NAME
	,hsp.ADT_PATIENT_STAT_C
	,zps.NAME AS ADT_PATIENT_STAT_NAME
	,hsp.ED_EPISODE_ID -- IS NOT NULL
	,hsp.ADM_EVENT_ID
	,hsp.LABOR_STATUS_C -- IS NOT NULL
	,CASE WHEN adhx.PAT_ID IS NOT NULL		/* If history record has NULL zip value return NULL, if no history, return current value */
		  THEN adhx.ZIP_HX 
		  ELSE pati.ZIP
	 END									'PAT_ZIP_DOS'

INTO #CSNs

FROM CLARITY.dbo.PAT_ENC_HSP hsp
LEFT OUTER JOIN CLARITY.dbo.ZC_CONF_STAT zcs						ON zcs.ADMIT_CONF_STAT_C = hsp.ADMIT_CONF_STAT_C
LEFT OUTER JOIN CLARITY.dbo.ZC_ADM_SOURCE admsrc			ON hsp.ADMIT_SOURCE_C = admsrc.ADMIT_SOURCE_C 
LEFT OUTER JOIN CLARITY.dbo.ZC_HOSP_ADMSN_TYPE admtyp		ON hsp.HOSP_ADMSN_TYPE_C = admtyp.HOSP_ADMSN_TYPE_C
LEFT OUTER JOIN CLARITY.dbo.ZC_PAT_SERVICE svc				ON hsp.HOSP_SERV_C = svc.HOSP_SERV_C
LEFT OUTER JOIN CLARITY.dbo.CLARITY_DEP dep					ON hsp.DEPARTMENT_ID = dep.DEPARTMENT_ID
LEFT OUTER JOIN CLARITY.dbo.ZC_ACCOMMODATION acm			ON hsp.ACCOMMODATION_C = acm.ACCOMMODATION_C
LEFT OUTER JOIN CLARITY.dbo.PATIENT_TYPE pttyp				ON hsp.PAT_ID	=	pttyp.PAT_ID AND pttyp.LINE = 1
LEFT OUTER JOIN CLARITY.dbo.ZC_PATIENT_TYPE zcpttyp			ON pttyp.PATIENT_TYPE_C = zcpttyp.PATIENT_TYPE_C
LEFT OUTER JOIN CLARITY.dbo.ZC_PAT_CLASS zpc						ON zpc.ADT_PAT_CLASS_C = hsp.ADT_PAT_CLASS_C
LEFT OUTER JOIN CLARITY.dbo.ZC_PAT_STATUS zps						ON zps.ADT_PATIENT_STAT_C = hsp.ADT_PATIENT_STAT_C		
LEFT JOIN	CLARITY.dbo.PATIENT pati												ON	hsp.PAT_ID = pati.PAT_ID
LEFT JOIN	CLARITY.dbo.PAT_ADDR_CHNG_HX adhx						ON	hsp.PAT_ID = adhx.PAT_ID 
	AND	hsp.CONTACT_DATE >= adhx.EFF_START_DATE
	AND hsp.CONTACT_DATE < COALESCE(adhx.EFF_END_DATE, '2099-12-31')
WHERE 1=1
 AND hsp.CONTACT_DATE>='7/1/2020'
 AND hsp.CONTACT_DATE<'3/1/2021'
AND (zcs.NAME NOT IN ('Canceled', 'Pending') OR zcs.NAME IS NULL)
AND zps.NAME <> 'Hospital Outpatient Visit'
ORDER BY hsp.PAT_ENC_CSN_ID

  -- Create index for temp table #CSNs

  CREATE UNIQUE CLUSTERED INDEX IX_CSNs ON #CSNs ([PAT_ENC_CSN_ID])

-- SELECT CONTACT_DATE,
--        PAT_ID,
--        PAT_ENC_CSN_ID,
--        HSP_ACCOUNT_ID,
--        HOSP_ADMSN_TIME,
--        ADMIT_CONF_STAT_C,
--        ADMIT_CONF_STAT_NAME,
--        ADMIT_SOURCE_C,
--        POINT_OF_ORIGIN,
--        HOSP_ADMSN_TYPE_C,
--        ADMISSION_TYPE,
--        HOSP_SERV_C,
--        SERVICE,
--        DEPARTMENT_ID,
--        UNIT,
--        ACCOMMODATION_C,
--        ACCOMMODATION_CODE,
--        PATIENT_TYPE,
--        ADT_PAT_CLASS_C,
--        ADT_PAT_CLASS_NAME,
--        ADT_PATIENT_STAT_C,
--        ADT_PATIENT_STAT_NAME,
--        ED_EPISODE_ID,
--	    ADM_EVENT_ID
-- FROM #CSNs
-- --WHERE PAT_ENC_CSN_ID = 200027430052
-- --WHERE PAT_ID = 'Z83812'

----ORDER BY CONTACT_DATE
----                   ,PAT_ENC_CSN_ID
----ORDER BY ADT_PAT_CLASS_NAME
----                   --,ADT_PATIENT_STAT_NAME
----                   ,CONTACT_DATE
----                   ,PAT_ENC_CSN_ID
--ORDER BY PAT_ENC_CSN_ID

SELECT [EVENT_ID]
      ,adt.[EVENT_TYPE_C]
	  ,zet.NAME AS EVENT_TYPE_NAME
      ,[EVENT_SUBTYPE_C]
      ,adt.[DEPARTMENT_ID]
	  ,dep.DEPARTMENT_NAME AS DEPARTMENT_NAME
      ,[ROOM_ID]
      ,[ROOM_CSN_ID]
      ,[BED_ID]
      ,[BED_CSN_ID]
      ,[BED_STATUS_C]
      ,[EFFECTIVE_TIME]
      ,[PAT_ID]
      ,[PAT_ENC_DATE_REAL]
      ,CSNs.[PAT_ENC_CSN_ID]
      ,[EVENT_TIME]
      ,[USER_ID]
      ,[PAT_CLASS_C]
	  ,zpc.NAME AS ADM_PAT_CLASS_NAME
      ,[PAT_SERVICE_C]
	  ,svc.NAME AS ADM_PAT_SERVICE_NAME
      ,[PAT_LVL_OF_CARE_C]
      ,[DELETE_TIME]
      ,[CANC_EVENT_ID]
      ,[XFER_EVENT_ID]
      ,[SWAP_EVENT_ID]
      ,[COMMENTS]
      ,[REASON_C]
      ,[ACCOMMODATION_C]
      ,[ACCOM_REASON_C]
      ,CSNs.[ADM_EVENT_ID]
      ,[DIS_EVENT_ID]
      ,adt.[CM_PHY_OWNER_ID]
      ,adt.[CM_LOG_OWNER_ID]
      ,[ALT_EVENT_TYPE_C]
      ,[ORIG_EVENT_TIME]
      ,[PREV_UPD_EVNT_TIME]
      ,[ORIG_EFF_TIME]
      ,[PREV_UPD_EFF_TIME]
      ,[XFER_IN_EVENT_ID]
      ,[NEXT_OUT_EVENT_ID]
      ,[LAST_IN_EVENT_ID]
      ,[STATUS_OF_BED_C]
      ,[EVT_CANCEL_USER_ID]
      ,[BASE_PAT_CLASS_C]
      ,[PREV_EVENT_ID]
      ,[SEQ_NUM_IN_ENC]
      ,[SEQ_NUM_IN_BED_MIN]
      ,[CANCEL_REASON_C]
      ,[OUT_EVENT_TYPE_C]
      ,[IN_EVENT_TYPE_C]
      ,[FROM_BASE_CLASS_C]
      ,[TO_BASE_CLASS_C]
      ,[LABOR_STATUS_C]
      ,[FIRST_IP_IN_IP_YN]
      ,[ORDER_ID]
      ,[SOURCE_LOC_EVNT_ID]
      ,[EVNT_REVIEW_C]
      ,[REVIEW_DTTM]
      ,[REVIEW_USER_ID]
      ,[LOA_REASON_C]
      ,[ORIGINAL_EVENT_ID]
      ,[ACTION_SOURCE_C]

  INTO #ADT

  FROM
  (
  SELECT DISTINCT
	PAT_ENC_CSN_ID
   ,ADM_EVENT_ID
  FROM #CSNs
  ) CSNs
  INNER JOIN [CLARITY].[dbo].[CLARITY_ADT] adt
  ON CSNs.ADM_EVENT_ID = adt.EVENT_ID
  LEFT OUTER JOIN [CLARITY].[dbo].ZC_EVENT_TYPE zet
  ON zet.EVENT_TYPE_C = adt.EVENT_TYPE_C
  LEFT OUTER JOIN [CLARITY].[dbo].CLARITY_DEP dep
  ON dep.DEPARTMENT_ID = adt.DEPARTMENT_ID
  LEFT OUTER JOIN CLARITY.dbo.ZC_PAT_SERVICE svc
  ON svc.HOSP_SERV_C = adt.PAT_SERVICE_C
  LEFT OUTER JOIN CLARITY.dbo.ZC_PAT_CLASS zpc
  ON zpc.ADT_PAT_CLASS_C = adt.PAT_CLASS_C

  -- Create index for temp table #ADT

  CREATE UNIQUE CLUSTERED INDEX IX_ADT ON #ADT ([PAT_ENC_CSN_ID], [ADM_EVENT_ID])

 -- SELECT EVENT_ID,
 --        EVENT_TYPE_C,
 --        EVENT_TYPE_NAME,
 --        EVENT_SUBTYPE_C,
 --        DEPARTMENT_ID,
 --        DEPARTMENT_NAME,
 --        ROOM_ID,
 --        ROOM_CSN_ID,
 --        BED_ID,
 --        BED_CSN_ID,
 --        BED_STATUS_C,
 --        EFFECTIVE_TIME,
 --        PAT_ID,
 --        PAT_ENC_DATE_REAL,
 --        PAT_ENC_CSN_ID,
 --        EVENT_TIME,
 --        USER_ID,
 --        PAT_CLASS_C,
	--	 ADM_PAT_CLASS_NAME,
 --        PAT_SERVICE_C,
 --        ADM_PAT_SERVICE_NAME,
 --        PAT_LVL_OF_CARE_C,
 --        DELETE_TIME,
 --        CANC_EVENT_ID,
 --        XFER_EVENT_ID,
 --        SWAP_EVENT_ID,
 --        COMMENTS,
 --        REASON_C,
 --        ACCOMMODATION_C,
 --        ACCOM_REASON_C,
 --        ADM_EVENT_ID,
 --        DIS_EVENT_ID,
 --        CM_PHY_OWNER_ID,
 --        CM_LOG_OWNER_ID,
 --        ALT_EVENT_TYPE_C,
 --        ORIG_EVENT_TIME,
 --        PREV_UPD_EVNT_TIME,
 --        ORIG_EFF_TIME,
 --        PREV_UPD_EFF_TIME,
 --        XFER_IN_EVENT_ID,
 --        NEXT_OUT_EVENT_ID,
 --        LAST_IN_EVENT_ID,
 --        STATUS_OF_BED_C,
 --        EVT_CANCEL_USER_ID,
 --        BASE_PAT_CLASS_C,
 --        PREV_EVENT_ID,
 --        SEQ_NUM_IN_ENC,
 --        SEQ_NUM_IN_BED_MIN,
 --        CANCEL_REASON_C,
 --        OUT_EVENT_TYPE_C,
 --        IN_EVENT_TYPE_C,
 --        FROM_BASE_CLASS_C,
 --        TO_BASE_CLASS_C,
 --        LABOR_STATUS_C,
 --        FIRST_IP_IN_IP_YN,
 --        ORDER_ID,
 --        SOURCE_LOC_EVNT_ID,
 --        EVNT_REVIEW_C,
 --        REVIEW_DTTM,
 --        REVIEW_USER_ID,
 --        LOA_REASON_C,
 --        ORIGINAL_EVENT_ID,
 --        ACTION_SOURCE_C
 -- FROM #ADT
 ----WHERE PAT_ID = 'Z83812'
 ----WHERE PAT_ENC_CSN_ID = 200027430052
 -- ORDER BY PAT_ENC_CSN_ID
 --                   , ADM_EVENT_ID
		
  SELECT
         reg_hx.REG_HX_EVENT_ID
        ,reg_hx.CSN
		,reg_hx.DTTM
		,reg_hx.USER_ID
		,reg_hx.REG_HX_EVENT_C
        ,reg_hx.[First]
		,reg_hx.[Last]

  INTO #REG_HX

  FROM
  (			
  SELECT --TOP 50
         rhx.REG_HX_EVENT_ID
        ,rhx.REG_HX_OPEN_PAT_CSN 'CSN'
		,rhx.REG_HX_INST_UTC_DTTM 'DTTM'
		,rhx.REG_HX_USER_ID 'USER_ID'
		,rhx.REG_HX_EVENT_C
		--,zrhet.NAME AS REG_HX_EVENT_NAME
        ,FIRST_VALUE(Rhx.REG_HX_EVENT_ID) OVER (PARTITION BY Rhx.REG_HX_OPEN_PAT_CSN ORDER BY Rhx.REG_HX_INST_UTC_DTTM, Rhx.REG_HX_EVENT_ID) AS [First]
		,LAST_VALUE(Rhx.REG_HX_EVENT_ID) OVER (PARTITION BY Rhx.REG_HX_OPEN_PAT_CSN ORDER BY Rhx.REG_HX_INST_UTC_DTTM, Rhx.REG_HX_EVENT_ID RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) AS [Last]
		,ROW_NUMBER() OVER (PARTITION BY rhx.REG_HX_OPEN_PAT_CSN, rhx.REG_HX_EVENT_C ORDER BY rhx.REG_HX_INST_UTC_DTTM DESC, Rhx.REG_HX_EVENT_ID DESC) 'RNo'
		--,emp.NAME

  FROM
  (
  SELECT DISTINCT
	PAT_ENC_CSN_ID
   ,ADM_EVENT_ID
  FROM #CSNs
  ) CSNs
  INNER JOIN CLARITY.dbo.REG_HX Rhx
  ON CSNs.PAT_ENC_CSN_ID = Rhx.REG_HX_OPEN_PAT_CSN
  ) reg_hx
  WHERE reg_hx.REG_HX_EVENT_ID = [First]
  OR reg_hx.REG_HX_EVENT_ID = [Last]
  OR ((reg_hx.REG_HX_EVENT_C IN (20,35,37)) AND reg_hx.RNo = 1) -- Hospital Account Created, Hospital Account Verified, Benefits Verified For Encounter
  ORDER BY CSN
                    , REG_HX_EVENT_ID

  -- Create index for temp table #REG_HX

  CREATE UNIQUE CLUSTERED INDEX IX_REG_HX ON #REG_HX (CSN, REG_HX_EVENT_ID)

  --SELECT *
  --FROM #REG_HX
  --ORDER BY CSN
		--			 ,REG_HX_EVENT_C
		--			 ,DTTM
		--			 ,REG_HX_EVENT_ID

SELECT
	CSN
   ,DTTM
   ,USER_ID
   ,Reg_Hx_Event

INTO #REG_HX_PIVOT

FROM
(
SELECT
	CSN
   ,DTTM
   ,USER_ID
   ,'First_Reg_Event' AS Reg_Hx_Event
FROM #REG_HX
WHERE REG_HX_EVENT_ID = [First]
UNION ALL
SELECT
	CSN
   ,DTTM
   ,USER_ID
   ,'Last_Reg_Event' AS Reg_Hx_Event
FROM #REG_HX
WHERE REG_HX_EVENT_ID = [Last]
UNION ALL
SELECT
	CSN
   ,DTTM
   ,USER_ID
   ,'Hospital_Account_Created' AS Reg_Hx_Event
FROM #REG_HX
WHERE REG_HX_EVENT_C = 20
UNION ALL
SELECT
	CSN
   ,DTTM
   ,USER_ID
   ,'Hospital_Account_Verified' AS Reg_Hx_Event
FROM #REG_HX
WHERE REG_HX_EVENT_C = 35
UNION ALL
SELECT
	CSN
   ,DTTM
   ,USER_ID
   ,'Benefits_Verified_For_Encounter' AS Reg_Hx_Event
FROM #REG_HX
WHERE REG_HX_EVENT_C = 37
) reg_hx_pvt
ORDER BY CSN
                  , Reg_Hx_Event

  -- Create index for temp table #REG_HX_PIVOT

  CREATE UNIQUE CLUSTERED INDEX IX_REG_HX_PIVOT ON #REG_HX_PIVOT (CSN, Reg_Hx_Event)

--SELECT *
--FROM #REG_HX_PIVOT
--ORDER BY CSN

SELECT CSN
			  ,First_Reg_Event AS First_Reg_Event_DTTM
			  ,Last_Reg_Event AS Last_Reg_Event_DTTM
			  ,Hospital_Account_Created AS Hospital_Account_Created_DTTM
			  ,Hospital_Account_Verified AS Hospital_Account_Verified_DTTM
			  ,Benefits_Verified_For_Encounter AS Benefits_Verified_For_Encounter_DTTM

INTO #REG_HX_DTTM

FROM
(
SELECT CSN
              ,DTTM
			  ,Reg_Hx_Event
FROM #REG_HX_PIVOT
) AS pivoted PIVOT (MAX(DTTM) FOR Reg_Hx_Event IN (First_Reg_Event,Last_Reg_Event,Hospital_Account_Created,Hospital_Account_Verified,Benefits_Verified_For_Encounter))
AS dttm
ORDER BY CSN

  -- Create index for temp table #REG_HX_DTTM

  CREATE UNIQUE CLUSTERED INDEX IX_REG_HX_DTTM ON #REG_HX_DTTM (CSN)

SELECT CSN
			  ,First_Reg_Event AS First_Reg_Event_USER_ID
			  ,Last_Reg_Event AS Last_Reg_Event_USER_ID
			  ,Hospital_Account_Created AS Hospital_Account_Created_USER_ID
			  ,Hospital_Account_Verified AS Hospital_Account_Verified_USER_ID
			  ,Benefits_Verified_For_Encounter AS Benefits_Verified_For_Encounter_USER_ID

INTO #REG_HX_USER_ID

FROM
(
SELECT CSN
              ,USER_ID
			  ,Reg_Hx_Event
FROM #REG_HX_PIVOT
) AS pivoted PIVOT (MAX(USER_ID) FOR Reg_Hx_Event IN (First_Reg_Event,Last_Reg_Event,Hospital_Account_Created,Hospital_Account_Verified,Benefits_Verified_For_Encounter))
AS userid
ORDER BY CSN

  -- Create index for temp table #REG_HX_USER_ID

  CREATE UNIQUE CLUSTERED INDEX IX_REG_HX_USER_ID ON #REG_HX_USER_ID (CSN)

  SELECT hx.PAT_ENC_CSN_ID,
         hx.UPDATE_USER_ID,
         hx.UPDATE_TIME

  INTO #STAT_HX_PREADM

  FROM
  (
  SELECT DISTINCT
	PAT_ENC_CSN_ID
  FROM #CSNs
  ) CSNs
  INNER JOIN
  (
  SELECT sthx.PAT_ENC_CSN_ID
              ,sthx.UPDATE_USER_ID
			  ,sthx.UPDATE_TIME
			  ,sthx.UPDATED_ENC_STAT_C
			  ,sthx.UPDATED_CONF_STAT_C
		      ,ROW_NUMBER() OVER (PARTITION BY sthx.PAT_ENC_CSN_ID ORDER BY sthx.UPDATE_TIME) 'RNo'
  FROM CLARITY.dbo.PAT_ENC_STAT_HX sthx
  WHERE sthx.UPDATED_ENC_STAT_C = 1 -- Preadmission
  ) hx
  ON CSNs.PAT_ENC_CSN_ID = hx.PAT_ENC_CSN_ID
  LEFT OUTER JOIN CLARITY.dbo.ZC_CONF_STAT zcs						ON zcs.ADMIT_CONF_STAT_C = hx.UPDATED_CONF_STAT_C
  LEFT OUTER JOIN CLARITY.dbo.ZC_PAT_STATUS zps					ON zps.ADT_PATIENT_STAT_C = hx.UPDATED_ENC_STAT_C
  WHERE hx.RNo = 1
  ORDER BY hx.PAT_ENC_CSN_ID

  -- Create index for temp table #STAT_HX_PREADM

  CREATE UNIQUE CLUSTERED INDEX IX_STAT_HX_PREADM ON #STAT_HX_PREADM (PAT_ENC_CSN_ID)

SELECT  DISTINCT
	 CSNs.CONTACT_DATE
	,idx.IDENTITY_ID	'MRN'
	,CSNs.PAT_ENC_CSN_ID
	,CSNs.HSP_ACCOUNT_ID

	,CSNs.HOSP_ADMSN_TIME

	,CASE
		WHEN CSNs.ED_EPISODE_ID IS NOT NULL THEN 'ED'
		WHEN CSNs.LABOR_STATUS_C IS NOT NULL THEN 'L&D'
		ELSE hx.ADM_EVENT
	 END AS ADM_EVENT

	,CSNs.ADT_PAT_CLASS_NAME
	,CSNs.ADT_PATIENT_STAT_NAME

	,adt.ADM_PAT_CLASS_NAME
	,adt.ADM_PAT_SERVICE_NAME
	 
--Scheduling
    ,hx.UPDATE_TIME			'PRE_ADMISSION_CREATED'
    ,hx.UPDATE_USER_ID		'PRE_ADMISSION_CREATED_USER_ID'
	,hx.UPDATE_USER_NAME 'PRE_ADMISSION_CREATED_USER'
	,scdemp.SYSTEM_LOGIN 'SCHEDULING_USER_LOGIN'
	,scdemp.USER_NAME 'SCHEDULING_USER'
	,scdemp.DEFAULT_USER_ROLE 'SCHEDULING_USER_ROLE'
	,scdemp.TEMPLATE_NAME 'SCHEDULING_TEMPLATE_NAME'

--Registration	   
	,reg.USER_ID						'REGISTRATION_STARTED_USER_ID'	   
	,reg.USER_NAME						'REGISTRATION_STARTED_USER'
	,reg.SYSTEM_LOGIN 'REGISTRATION_STARTED_USER_LOGIN'
	,reg.DEFAULT_USER_ROLE 'REGISTRATION_STARTED_USER_ROLE'
	,reg.TEMPLATE_NAME 'REGISTRATION_STARTED_TEMPLATE_NAME'
	,regdttm.First_Reg_Event_DTTM	'REG_START_TIME' --UTC TIME NEED TO CONVERT
	,regdttm.Last_Reg_Event_DTTM	'REG_END_TIME'

--coverage Verification	
    ,cvgvrx.LAST_VERIF_USER_ID			'BENEFIT_VERIFIED_USER_ID'
	,cvgvrx.NAME 'BENEFIT_VERIFIED_USER'
	,cvgvrxemp.SYSTEM_LOGIN 'BENEFIT_VERIFIED_USER_LOGIN'
	,cvgvrxemp.DEFAULT_USER_ROLE 'BENEFIT_VERIFIED_USER_ROLE'
	,cvgvrxemp.TEMPLATE_NAME 'BENEFIT_VERIFIED_TEMPLATE_NAME'
	,cvgvrx.LAST_STAT_CHNG_DTTM			'BENEFIT_VERIFIED_DATE'

--HAR Verification	
	,harvrx.LAST_VERIF_USER_ID			'HAR_VERIFIED_USER_ID'
	,harvrx.NAME 'HAR_VERIFIED_USER'
	,harvrxemp.SYSTEM_LOGIN 'HAR_VERIFIED_USER_LOGIN'
	,harvrxemp.DEFAULT_USER_ROLE 'HAR_VERIFIED_USER _ROLE'
	,harvrxemp.TEMPLATE_NAME 'HAR_VERIFIED_TEMPLATE_NAME'
	,harvrx.LAST_STAT_CHNG_DTTM			'HAR_VERIFIED_DATE'

--Admission	
	,admhx.UPDATE_USER_ID				'ADMISSION_CONFIRMED_USER_ID'
	,admhx.NAME 'ADMISSION_CONFIRMED_USER'
	,admemp.SYSTEM_LOGIN 'ADMISSION_CONFIRMED_USER_LOGIN'
	,admemp.DEFAULT_USER_ROLE 'ADMISSION_CONFIRMED_USER_ROLE'
	,admemp.TEMPLATE_NAME 'ADMISSION_CONFIRMED_TEMPLATE_NAME'
	,admhx.UPDATE_TIME					'ADMISSION_CONFIRMED_DTTM'

--Hospital Account Created	admhx
	,hac.USER_ID				'Hospital_Account_Created_USER_ID'
	,hac.USER_NAME  'Hospital_Account_Created_USER'
	,hac.SYSTEM_LOGIN 'Hospital_Account_Created_USER_LOGIN'
	,hac.DEFAULT_USER_ROLE 'Hospital_Account_Created_USER_ROLE'
	,hac.TEMPLATE_NAME 'Hospital_Account_Created_TEMPLATE_NAME'
	,regdttm.Hospital_Account_Created_DTTM			'Hospital_Account_Created_DTTM'

--Hospital Account Verified	
	,hav.USER_ID				'Hospital_Account_Verified_USER_ID'
	,hav.USER_NAME  'Hospital_Account_Verified_USER'
	,hav.SYSTEM_LOGIN 'Hospital_Account_Verified_USER_LOGIN'
	,hav.DEFAULT_USER_ROLE 'Hospital_Account_Verified_USER_ROLE'
	,hav.TEMPLATE_NAME 'Hospital_Account_Verified_TEMPLATE_NAME'
	,regdttm.Hospital_Account_Verified_DTTM			'Hospital_Account_Verified_DTTM'

--Benefits Verified for Encounter
	,bve.USER_ID				'Benefits_Verified_For_Encounter_USER_ID'
	,bve.USER_NAME  'Benefits_Verified_For_Encounter_USER'
	,bve.SYSTEM_LOGIN 'Benefits_Verified_For_Encounter_USER_LOGIN'
	,bve.DEFAULT_USER_ROLE 'Benefits_Verified_For_Encounter_USER_ROLE'
	,bve.TEMPLATE_NAME 'Benefits_Verified_For_Encounter_TEMPLATE_NAME'
	,regdttm.Benefits_Verified_For_Encounter_DTTM			'Benefits_Verified_For_Encounter_DTTM'

--Point of Origin'
	,CSNs.ADMIT_SOURCE_C					
	,CSNs.POINT_OF_ORIGIN

--Planned/Unplanned admission
	,CSNs.HOSP_ADMSN_TYPE_C				
	,CSNs.ADMISSION_TYPE

--Service
	,CSNs.HOSP_SERV_C				
	,CSNs.SERVICE

--Unit
	,CSNs.DEPARTMENT_ID
	,CSNs.UNIT

--Accommodation Code
	,CSNs.ACCOMMODATION_C
	,CSNs.ACCOMMODATION_CODE

--Patient Type
	,CSNs.PATIENT_TYPE

--Authi/Cert Status
	,rfl.PRE_CERT_STATUS_C
	,certsts.NAME						'AUTHCERT_STATUS'
	,har.ASSOC_AUTHCERT_ID				-- added syg2d 2021.04.14

--Coverage Info	
	,epm.PAYOR_NAME
	,epp.BENEFIT_PLAN_NAME

--MSPQ
	,mspq.MSP_STATUS_C					
	,zcmsp.NAME							'MSPQ_COMPLETION'

--Documents Insurance Waiver	
	,dcswv.DOC_STAT_C					'INSURANCE_WAIVER_STATUS_C'
	,zcwvst.NAME						'INSURANCE_WAIVER_STATUS'
	,dcswv.RECV_BY_USER_ID				'INSURANCE_WAIVER_COLLECTED_USER_ID'
	,dcswv.NAME 'INSURANCE_WAIVER_COLLECTED_USER'
	,dcswv.DOC_RECV_TIME				'INSURANCE_WAIVER_COLLECTED_DTTM'
	
--Documents Medicare Msg
	,dcsmc.DOC_STAT_C					'MEDICARE_MSG_STATUS_C'
	,zcmcst.NAME						'MEDICARE_MSG_STATUS'
	,dcsmc.RECV_BY_USER_ID				'MEDICARE_MSG_COLLECTED_USER ID'
	,dcsmc.NAME 	'MEDICARE_MSG_COLLECTED_USER'
	,dcsmc.DOC_RECV_TIME				'MEDICARE_MSG_COLLECTED_DTTM'

--Documents Admission Notification
	,dcsadm.DOC_STAT_C					'ADMISSION_NOTICE_STATUS_C'
	,zcadmst.NAME						'ADMISSION_NOTICE_STATUS'
	,dcsadm.RECV_BY_USER_ID				'ADMISSION_NOTICE_COLLECTED_USER_ID'
	,dcsadm.NAME 'ADMISSION_NOTICE_COLLECTED_USER'
	,dcsadm.DOC_RECV_TIME				'ADMISSION_NOTICE_COLLECTED_DTTM'

--RTE
	,rte.RTE_RESP_STATUS_C
	,zcrtest.NAME						'RTE_RESPONSE_STATUS'
	,rte.RTE_TRIGGER_USER_ID 'RTE_TRIGGER_USER_ID'
	,rte.NAME 'RTE_TRIGGER_USER'
	,rte.RTE_SENT_TRUE_DTTM

--MyChart
	,myc.MYCHART_STATUS_C
	,zcmyc.NAME							'MYCHART_STATUS'

--Payments
	,enc.COPAY_DUE
	,enc.COPAY_COLLECTED
	,slfpmt.AMOUNT_PAID					'SELF_PAYMENT_AMOUNT'

--Cancellations
	,enc.APPT_CANCEL_DATE
	,enc.APPT_CANC_USER_ID
	,enc.CANCEL_REASON_C
	,cnlrsn.NAME						'CANCEL_REASON'

--Patient demographics at encounter
	,CSNs.PAT_ZIP_DOS

FROM
#CSNs CSNs
INNER JOIN CLARITY.dbo.IDENTITY_ID idx						ON CSNs.PAT_ID = idx.PAT_ID
LEFT OUTER JOIN
(
SELECT sthx.PAT_ENC_CSN_ID,
       sthx.UPDATE_USER_ID,
	   emp.NAME AS UPDATE_USER_NAME,
       sthx.UPDATE_TIME,
	   'Preadmission' AS ADM_EVENT
FROM  #STAT_HX_PREADM sthx
LEFT OUTER JOIN CLARITY.dbo.CLARITY_EMP emp
ON emp.USER_ID = sthx.UPDATE_USER_ID
) hx																							ON hx.PAT_ENC_CSN_ID = CSNs.PAT_ENC_CSN_ID
LEFT OUTER JOIN
(
SELECT reguser.CSN
              ,reguser.First_Reg_Event_USER_ID AS USER_ID
              ,emp.NAME AS USER_NAME
			  ,emp.SYSTEM_LOGIN
			  ,emprl.DEFAULT_USER_ROLE
			  ,tmp.NAME AS TEMPLATE_NAME
FROM #REG_HX_USER_ID reguser
LEFT OUTER JOIN CLARITY.dbo.CLARITY_EMP emp
ON emp.USER_ID = reguser.First_Reg_Event_USER_ID
INNER JOIN CLARITY.dbo.CLARITY_EMP_ROLE emprl			ON emp.USER_ID = emprl.USER_ID AND LINE ='1'  --ONLY PRIMARY USER ROLE 
INNER JOIN CLARITY.dbo.CLARITY_EMP tmp					ON emp.LNK_SEC_TEMPLT_ID = tmp.USER_ID
) reg
ON reg.CSN = CSNs.PAT_ENC_CSN_ID
LEFT OUTER JOIN
(
SELECT reguser.CSN
              ,reguser.First_Reg_Event_DTTM
              ,reguser.Last_Reg_Event_DTTM
			  ,reguser.Hospital_Account_Created_DTTM
			  ,reguser.Hospital_Account_Verified_DTTM
			  ,reguser.Benefits_Verified_For_Encounter_DTTM
FROM #REG_HX_DTTM reguser
) regdttm
ON regdttm.CSN = CSNs.PAT_ENC_CSN_ID
LEFT OUTER JOIN
(
SELECT reguser.CSN
              ,reguser.Hospital_Account_Created_USER_ID AS USER_ID
              ,emp.NAME AS USER_NAME
			  ,emp.SYSTEM_LOGIN
			  ,emprl.DEFAULT_USER_ROLE
			  ,tmp.NAME AS TEMPLATE_NAME
FROM #REG_HX_USER_ID reguser
LEFT OUTER JOIN CLARITY.dbo.CLARITY_EMP emp
ON emp.USER_ID = reguser.Hospital_Account_Created_USER_ID
INNER JOIN CLARITY.dbo.CLARITY_EMP_ROLE emprl			ON emp.USER_ID = emprl.USER_ID AND LINE ='1'  --ONLY PRIMARY USER ROLE 
INNER JOIN CLARITY.dbo.CLARITY_EMP tmp					ON emp.LNK_SEC_TEMPLT_ID = tmp.USER_ID
) hac
ON hac.CSN = CSNs.PAT_ENC_CSN_ID
LEFT OUTER JOIN
(
SELECT reguser.CSN
              ,reguser.Hospital_Account_Verified_USER_ID AS USER_ID
              ,emp.NAME AS USER_NAME
			  ,emp.SYSTEM_LOGIN
			  ,emprl.DEFAULT_USER_ROLE
			  ,tmp.NAME AS TEMPLATE_NAME
FROM #REG_HX_USER_ID reguser
LEFT OUTER JOIN CLARITY.dbo.CLARITY_EMP emp
ON emp.USER_ID = reguser.Hospital_Account_Verified_USER_ID
INNER JOIN CLARITY.dbo.CLARITY_EMP_ROLE emprl			ON emp.USER_ID = emprl.USER_ID AND LINE ='1'  --ONLY PRIMARY USER ROLE 
INNER JOIN CLARITY.dbo.CLARITY_EMP tmp					ON emp.LNK_SEC_TEMPLT_ID = tmp.USER_ID
) hav
ON hav.CSN = CSNs.PAT_ENC_CSN_ID
LEFT OUTER JOIN
(
SELECT reguser.CSN
              ,reguser.Benefits_Verified_For_Encounter_USER_ID AS USER_ID
              ,emp.NAME AS USER_NAME
			  ,emp.SYSTEM_LOGIN
			  ,emprl.DEFAULT_USER_ROLE
			  ,tmp.NAME AS TEMPLATE_NAME
FROM #REG_HX_USER_ID reguser
LEFT OUTER JOIN CLARITY.dbo.CLARITY_EMP emp
ON emp.USER_ID = reguser.Benefits_Verified_For_Encounter_USER_ID
INNER JOIN CLARITY.dbo.CLARITY_EMP_ROLE emprl			ON emp.USER_ID = emprl.USER_ID AND LINE ='1'  --ONLY PRIMARY USER ROLE 
INNER JOIN CLARITY.dbo.CLARITY_EMP tmp					ON emp.LNK_SEC_TEMPLT_ID = tmp.USER_ID
) bve
ON bve.CSN = CSNs.PAT_ENC_CSN_ID
--SCHEDULING USER
LEFT OUTER JOIN (
					SELECT 
						 emp.USER_ID
						 ,emp.SYSTEM_LOGIN
						 ,EMP.NAME		'USER_NAME'
						 ,emp.LNK_SEC_TEMPLT_ID
						 ,tmp.NAME		'TEMPLATE_NAME'
						 ,emprl.DEFAULT_USER_ROLE
						 FROM CLARITY.dbo.CLARITY_EMP emp
						 INNER JOIN CLARITY.dbo.CLARITY_EMP_ROLE emprl			ON emp.USER_ID = emprl.USER_ID AND LINE ='1'  --ONLY PRIMARY USER ROLE 
						 INNER JOIN CLARITY.dbo.CLARITY_EMP tmp					ON emp.LNK_SEC_TEMPLT_ID = tmp.USER_ID
			    )scdemp														ON reg.USER_ID = scdemp.USER_ID
--BENEFIT/COVERAGE VERIFICATION 
LEFT OUTER JOIN (
					SELECT  
						vrxcvg.VERIF_RECORD_IDNT
						,vrxcvg.LAST_STAT_CHNG_DTTM
						,vrxcvg.LAST_VERIF_USER_ID
						,vrxcvg.VERIF_STATUS_C
						,vrxcvg.NEXT_REVIEW_DATE
						,vrxcvg.VERIF_CONFRM_ID
						,vrxcvg.RECORD_CREATION_DT
						,vrxcvg.enc_CSN
						,emp.NAME
					 FROM  CLARITY.dbo.VERIFICATION vrxcvg
					 LEFT OUTER JOIN CLARITY.dbo.CLARITY_EMP emp ON emp.USER_ID = vrxcvg.LAST_VERIF_USER_ID
					 WHERE 1=1
						 AND vrxcvg.VERIFICATION_TYPE_C ='8' --ENCOUNTER BENEFIT VERIFICATION
						 AND vrxcvg.VERIF_STATUS_C IN ('1','12','13','23','26','6','8') --VERIFIED STATUS

					)cvgvrx									ON CSNs.PAT_ENC_CSN_ID = cvgvrx.ENC_CSN
--COVERAGE VERIFICATION
LEFT OUTER JOIN (
					SELECT 
						 emp.USER_ID
						 ,emp.SYSTEM_LOGIN
						 ,EMP.NAME		'USER_NAME'
						 ,emp.LNK_SEC_TEMPLT_ID
						 ,tmp.NAME		'TEMPLATE_NAME'
						 ,emprl.DEFAULT_USER_ROLE
						 FROM CLARITY.dbo.CLARITY_EMP emp
						 INNER JOIN CLARITY.dbo.CLARITY_EMP_ROLE emprl			ON emp.USER_ID = emprl.USER_ID AND LINE ='1'  --ONLY PRIMARY USER ROLE 
						 INNER JOIN CLARITY.dbo.CLARITY_EMP tmp					ON emp.LNK_SEC_TEMPLT_ID = tmp.USER_ID
			    )cvgvrxemp														ON cvgvrx.LAST_VERIF_USER_ID = cvgvrxemp.USER_ID
--HOSPITAL ACCOUNT VERIFICATION 
LEFT OUTER JOIN (
					SELECT  
						vrxhar.VERIF_RECORD_IDNT
						,vrxhar.LAST_STAT_CHNG_DTTM
						,vrxhar.LAST_VERIF_USER_ID
						,vrxhar.VERIF_STATUS_C
						,vrxhar.NEXT_REVIEW_DATE
						,vrxhar.VERIF_CONFRM_ID
						,vrxhar.RECORD_CREATION_DT
						,emp.NAME
					 FROM  CLARITY.dbo.VERIFICATION vrxhar
					 LEFT OUTER JOIN CLARITY.dbo.CLARITY_EMP emp ON emp.USER_ID = vrxhar.LAST_VERIF_USER_ID
					 WHERE 1=1
						 AND vrxhar.VERIFICATION_TYPE_C ='4' --HOSPITAL ACCOUNT
						 AND vrxhar.VERIF_STATUS_C IN ('1','12','13','23','26','6','8') --VERIFIED STATUS

					)harvrx									ON CSNs.HSP_ACCOUNT_ID = harvrx.VERIF_RECORD_IDNT 
																AND CSNs.HOSP_ADMSN_TIME>=harvrx.LAST_STAT_CHNG_DTTM
																AND CAST(CSNs.HOSP_ADMSN_TIME AS DATE)<=CAST(harvrx.NEXT_REVIEW_DATE AS DATE)
--HAR VERIFICATION
LEFT OUTER JOIN (
					SELECT 
						 emp.USER_ID
						 ,emp.SYSTEM_LOGIN
						 ,EMP.NAME		'USER_NAME'
						 ,emp.LNK_SEC_TEMPLT_ID
						 ,tmp.NAME		'TEMPLATE_NAME'
						 ,emprl.DEFAULT_USER_ROLE
						 FROM CLARITY.dbo.CLARITY_EMP emp
						 INNER JOIN CLARITY.dbo.CLARITY_EMP_ROLE emprl			ON emp.USER_ID = emprl.USER_ID AND LINE ='1'  --ONLY PRIMARY USER ROLE 
						 INNER JOIN CLARITY.dbo.CLARITY_EMP tmp					ON emp.LNK_SEC_TEMPLT_ID = tmp.USER_ID
			    )harvrxemp														ON harvrx.LAST_VERIF_USER_ID = harvrxemp.USER_ID
--ADMISSION 
LEFT OUTER JOIN (
				SELECT hx.*, emp.NAME, ROW_NUMBER() OVER (PARTITION BY hx.PAT_ENC_CSN_ID ORDER BY hx.UPDATE_TIME DESC) 'RNo' --LAST UPDATED RECORD	
				FROM CLARITY.dbo.PAT_ENC_STAT_HX hx	
				LEFT OUTER JOIN CLARITY.dbo.CLARITY_EMP emp ON emp.USER_ID = hx.UPDATE_USER_ID			
				WHERE 1=1
				AND hx.UPDATED_CONF_STAT_C ='1' --CONFIRMED
				AND hx.UPDATED_ENC_STAT_C IN ('2','6') --ADMISSIONS /HOV
				)admhx											ON admhx.PAT_ENC_CSN_ID = CSNs.PAT_ENC_CSN_ID AND admhx.RNo='1'
--ADMISSION CONFIRMATION
LEFT OUTER JOIN (
					SELECT 
						 emp.USER_ID
						 ,emp.SYSTEM_LOGIN
						 ,EMP.NAME		'USER_NAME'
						 ,emp.LNK_SEC_TEMPLT_ID
						 ,tmp.NAME		'TEMPLATE_NAME'
						 ,emprl.DEFAULT_USER_ROLE
						 FROM CLARITY.dbo.CLARITY_EMP emp
						 INNER JOIN CLARITY.dbo.CLARITY_EMP_ROLE emprl			ON emp.USER_ID = emprl.USER_ID AND LINE ='1'  --ONLY PRIMARY USER ROLE 
						 INNER JOIN CLARITY.dbo.CLARITY_EMP tmp					ON emp.LNK_SEC_TEMPLT_ID = tmp.USER_ID
			    )admemp														ON admhx.UPDATE_USER_ID = admemp.USER_ID
INNER JOIN CLARITY.dbo.PAT_ENC enc							ON CSNs.PAT_ENC_CSN_ID = enc.PAT_ENC_CSN_ID
--AUTH/CERT
-- 2021.04.14 - syg2d
LEFT OUTER JOIN CLARITY.dbo.HSP_ACCOUNT			har			ON	har.HSP_ACCOUNT_ID		= enc.HSP_ACCOUNT_ID	-- added syg2d 2021.04.14
LEFT OUTER JOIN CLARITY.dbo.REFERRAL_CVG_AUTH		rfl			ON	har.COVERAGE_ID			= rfl.AUTH_CERT_CVG_ID	-- added syg2d 2021.04.14
																and har.ASSOC_AUTHCERT_ID	= rfl.REFERRAL_ID		-- added syg2d 2021.04.14
--LEFT OUTER JOIN CLARITY.dbo.REFERRAL_CVG_AUTH		rfl			ON	ENC.COVERAGE_ID = rfl.AUTH_CERT_CVG_ID			-- commented out syg2d 2021.04.14
--																and ENC.REFERRAL_ID = RFL.REFERRAL_ID				-- commented out syg2d 2021.04.14
LEFT OUTER JOIN CLARITY.dbo.ZC_PRE_CERT_STATUS certsts		ON rfl.PRE_CERT_STATUS_C = certsts.PRE_CERT_STATUS_C
LEFT OUTER JOIN CLARITY.dbo.COVERAGE cvg					ON enc.COVERAGE_ID = cvg.COVERAGE_ID
LEFT OUTER JOIN CLARITY.dbo.CLARITY_EPM epm					ON cvg.PAYOR_ID = epm.PAYOR_ID
LEFT OUTER JOIN CLARITY.dbo.CLARITY_EPP epp					ON cvg.PLAN_ID = epp.BENEFIT_PLAN_ID
--MSPQ
LEFT OUTER JOIN CLARITY.dbo.PAT_ENC_MSP mspq				ON mspq.PAT_ENC_CSN_ID = CSNs.PAT_ENC_CSN_ID
LEFT OUTER JOIN CLARITY.dbo.ZC_MSP_COMPLETION zcmsp			ON mspq.MSP_STATUS_C = zcmsp.MSP_COMPLETION_C
--DOCUMENTS 
--Insurance Waiver Form
LEFT OUTER JOIN (
				SELECT  doc.*, emp.NAME
					FROM CLARITY.dbo.DOC_INFORMATION doc
					LEFT OUTER JOIN CLARITY.dbo.CLARITY_EMP emp ON emp.USER_ID = doc.RECV_BY_USER_ID
					WHERE doc.DOC_INFO_TYPE_C IN ('204100014') --Insurance Waiver Form
					)dcswv									ON CSNs.PAT_ENC_CSN_ID = dcswv.DOC_CSN
--Important Message from Medicare
LEFT OUTER JOIN (
				SELECT  doc.*, emp.NAME
					FROM CLARITY.dbo.DOC_INFORMATION doc
					LEFT OUTER JOIN CLARITY.dbo.CLARITY_EMP emp ON emp.USER_ID = doc.RECV_BY_USER_ID
					WHERE doc.DOC_INFO_TYPE_C IN ('204100012') -- Important Message from Medicare
					)dcsmc									ON CSNs.PAT_ENC_CSN_ID = dcsmc.DOC_CSN
--Notice of Admission
LEFT OUTER JOIN (
				SELECT  doc.*, emp.NAME
					FROM CLARITY.dbo.DOC_INFORMATION doc
					LEFT OUTER JOIN CLARITY.dbo.CLARITY_EMP emp ON emp.USER_ID = doc.RECV_BY_USER_ID
					WHERE doc.DOC_INFO_TYPE_C IN ('310100001')--Notice of Admission
					)dcsadm									ON CSNs.PAT_ENC_CSN_ID = dcsadm.DOC_CSN
LEFT OUTER JOIN CLARITY.dbo.ZC_DOC_STAT zcwvst				ON dcswv.DOC_STAT_C = zcwvst.DOC_STAT_C
LEFT OUTER JOIN CLARITY.dbo.ZC_DOC_STAT zcmcst				ON dcsmc.DOC_STAT_C = zcmcst.DOC_STAT_C
LEFT OUTER JOIN CLARITY.dbo.ZC_DOC_STAT zcadmst				ON dcsadm.DOC_STAT_C = zcadmst.DOC_STAT_C
--RTE
LEFT OUTER JOIN (
					SELECT 
					rte1.PAT_ID
					,rte1.RTE_PAYOR_ID
					,rte1.RTE_PLAN_ID
					,rte1.RTE_RESP_STATUS_C
					,rte1.RTE_ACTION_C
					,rte1.RTE_SENT_TRUE_DTTM
					,rte1.RTE_RCVD_TRUE_DTTM
					,hno.RTE_TRIGGER_USER_ID
					,emp.NAME

					FROM CLARITY.dbo.RTE_PATIENT_QUERY rte1
					INNER JOIN CLARITY.dbo.HNO_INFO hno		ON 	rte1.RTE_HNO_ID = hno.NOTE_ID
					LEFT OUTER JOIN CLARITY.dbo.CLARITY_EMP emp ON emp.USER_ID = hno.RTE_TRIGGER_USER_ID
					WHERE 1=1
					AND rte1.RTE_PAYOR_ID IS NOT NULL
				)rte										ON rte.PAT_ID = CSNs.PAT_ID AND CAST(CSNs.HOSP_ADMSN_TIME AS DATE) =CAST(rte.RTE_SENT_TRUE_DTTM AS DATE)
LEFT OUTER JOIN CLARITY.dbo.ZC_RTE_RESP_STATUS zcrtest		ON rte.RTE_RESP_STATUS_C = zcrtest.RTE_RESP_STATUS_C
--MYCHART STATUS
LEFT OUTER JOIN CLARITY.dbo.PATIENT_MYC myc					ON CSNs.PAT_ID = myc.PAT_ID
LEFT OUTER JOIN CLARITY.dbo.ZC_MYCHART_STATUS zcmyc			ON myc.MYCHART_STATUS_C = zcmyc.MYCHART_STATUS_C
--SELF PAYMENT 
LEFT OUTER JOIN CLARITY.dbo.PAT_ENC_SELF_PMT slfpmt			ON enc.PAT_ENC_CSN_ID = slfpmt.PAT_ENC_CSN_ID
LEFT OUTER JOIN CLARITY.dbo.ZC_CANCEL_REASON cnlrsn			ON enc.CANCEL_REASON_C = cnlrsn.CANCEL_REASON_C
LEFT OUTER JOIN #ADT adt				ON adt.PAT_ENC_CSN_ID = CSNs.PAT_ENC_CSN_ID AND adt.ADM_EVENT_ID = CSNs.ADM_EVENT_ID
 WHERE 1=1
 AND idx.IDENTITY_TYPE_ID = '14' -- MRN
ORDER BY CSNs.PAT_ENC_CSN_ID
GO
 




