USE CLARITY

DECLARE @DateType AS CHAR(1)

SET @DateType = '1' -- Creation Date
--SET @DateType = '2' -- Cancellation Date
--SET @DateType = '3' -- Occurrence Date

DECLARE @Date_Start AS SMALLDATETIME
DECLARE @Date_End AS SMALLDATETIME

--SET @Date_Start = '7/1/2020 00:00 AM'
SET @Date_Start = '6/1/2022 00:00 AM'
SET @Date_End = '6/30/2022 00:00 AM'

/*PROV_ID	PROV_NAME
29096	ALFANO, ALAN PETER
67158	AMALFITANO, JOSEPH
56932	ASTHAGIRI, HEATHER L
29097	DIAMOND, PAUL T
41083	GRICE, D. PRESTON
51070	GRICE, DARLINDA M
29094	GYPSON, WARD
74042	HRYVNIAK, DAVID
29087	JENKINS, JEFFREY
56129	KELLEHER, NICOLE C.
68058	LUNSFORD, CHRISTOPHER D
29095	MILLER, SUSAN
116776	MIXON, ALYSSA
64818	REDIESKE, CRYSTON MICHELLE
74043	ROYER, REGAN H
29092	RUBENDALL, DAVID S
90452	SHEPPARD, MICHAEL
46238	SMITH II, GEOFFREY R
71719	WARWICK, MICHAEL D
66781	WEPPNER, JUSTIN L
29073	WILDER, ROBERT*/

;WITH providers AS
(
SELECT
	 ser.PROV_ID
    ,ser.PROV_NAME

	,TRY_CAST(ser.RPT_GRP_SIX AS INT) AS financial_division_id
	,CAST(dvsn.Epic_Financial_Division AS VARCHAR(150)) AS financial_division_name
	,TRY_CAST(ser.RPT_GRP_EIGHT AS INT) AS financial_sub_division_id
	,CAST(dvsn.Epic_Financial_SubDivision AS VARCHAR(150)) AS financial_sub_division_name
	,dvsn.som_group_id
	,dvsn.som_group_name
	,dvsn.Department_ID AS som_department_id
  	,CAST(dvsn.Department AS VARCHAR(150)) AS som_department_name
	,CAST(dvsn.Org_Number AS INT) AS som_division_id
	,CAST(dvsn.Organization AS VARCHAR(150)) AS som_division_name
	,dvsn.som_hs_area_id
	,dvsn.som_hs_area_name

FROM CLARITY.dbo.CLARITY_SER AS ser
                -- -------------------------------------
				LEFT OUTER JOIN
				(
				    SELECT
					    Epic_Financial_Division_Code,
						Epic_Financial_Division,
                        Epic_Financial_Subdivision_Code,
						Epic_Financial_Subdivision,
                        Department,
                        Department_ID,
                        Organization,
                        Org_Number,
                        som_group_id,
                        som_group_name,
						som_hs_area_id,
						som_hs_area_name
					FROM CLARITY_App.Rptg.vwRef_OracleOrg_to_EpicFinancialSubdiv) dvsn
				    ON (CAST(dvsn.Epic_Financial_Division_Code AS INTEGER) = TRY_CAST(ser.RPT_GRP_SIX AS INT)
					    AND CAST(dvsn.Epic_Financial_Subdivision_Code AS INTEGER) = TRY_CAST(ser.RPT_GRP_EIGHT AS INT))
WHERE dvsn.Department_ID = 259 -- MD-PHMR Phys Med & Rehab
)

--SELECT *
--FROM providers
--ORDER BY providers.PROV_NAME
/*
SELECT enc.*
,ser.PROV_NAME AS VISIT_PROV_NAME
,   zdet.NAME AS ENC_TYPE_NAME
,   dep.DEPARTMENT_NAME
,   prc.PRC_NAME AS Visit_Type
,   zces.NAME AS CALCULATED_ENC_STAT_NAME
,   rfl.ENTRY_DATE
,   rfl.RFL_TYPE_C
,   zrt.NAME AS RFL_TYPE_NAME
,   rfl.RSN_FOR_RFL_C
,   zrfr.NAME AS RSN_FOR_RFL_NAME
,   rfl.RFL_CLASS_C
,   zrc.NAME AS RFL_CLASS_NAME
,   rfl.REFERRAL_PROV_ID
,   rflser.PROV_NAME AS REFERRAL_PROV_NAME
,   rfl. REFD_BY_DEPT_ID
,   rfldep.DEPARTMENT_NAME AS REFD_BY_DEPT_NAME
FROM dbo.PAT_ENC enc
INNER JOIN providers providers
ON enc.VISIT_PROV_ID = providers.PROV_ID
INNER JOIN dbo.REFERRAL rfl ON enc.REFERRAL_ID = rfl.REFERRAL_ID
LEFT JOIN dbo.ZC_DISP_ENC_TYPE zdet ON zdet.DISP_ENC_TYPE_C = enc.ENC_TYPE_C
LEFT JOIN dbo.CLARITY_DEP dep ON enc.DEPARTMENT_ID = dep.DEPARTMENT_ID
LEFT JOIN dbo.CLARITY_SER ser ON ser.PROV_ID = enc.VISIT_PROV_ID
LEFT JOIN dbo.CLARITY_PRC prc ON prc.PRC_ID = enc.APPT_PRC_ID
LEFT JOIN dbo.ZC_CALCULATED_ENC_STAT zces ON zces.CALCULATED_ENC_STAT_C = enc.CALCULATED_ENC_STAT_C
LEFT JOIN dbo.ZC_RFL_TYPE zrt ON zrt.RFL_TYPE_C = rfl.RFL_TYPE_C
LEFT JOIN dbo.ZC_RSN_FOR_RFL zrfr ON zrfr.RSN_FOR_RFL_C = rfl.RSN_FOR_RFL_C
LEFT JOIN dbo.ZC_RFL_CLASS zrc ON zrc.RFL_CLASS_C = rfl.RFL_CLASS_C
LEFT JOIN dbo.CLARITY_SER rflser ON rflser.PROV_ID = rfl.REFERRAL_PROV_ID
LEFT JOIN dbo.CLARITY_DEP rfldep ON rfldep.DEPARTMENT_ID = rfl.REFD_BY_DEPT_ID
--FROM ORDER_PROC ordproc
--LEFT OUTER JOIN dbo.PAT_ENC ordenc
--ON ordenc.PAT_ENC_CSN_ID = ordproc.PAT_ENC_CSN_ID
--LEFT JOIN CLARITY_EMP emp
--ON emp.USER_ID = ordproc.ORD_CREATR_USER_ID
--LEFT JOIN ZC_ORDER_TYPE ordtyp
--ON ordproc.ORDER_TYPE_C = ordtyp.ORDER_TYPE_C
--LEFT JOIN CLARITY_EAP	ordeap
--ON ordproc.PROC_ID = ordeap.PROC_ID
--LEFT JOIN ZC_ORDER_STATUS	ordstat
--ON ordproc.ORDER_STATUS_C = ordstat.ORDER_STATUS_C
--LEFT JOIN dbo.ZC_DISP_ENC_TYPE zdet ON zdet.DISP_ENC_TYPE_C = ordenc.ENC_TYPE_C
--LEFT JOIN dbo.CLARITY_DEP dep ON ordenc.DEPARTMENT_ID = dep.DEPARTMENT_ID
--LEFT JOIN dbo.CLARITY_SER ser ON ser.PROV_ID = ordenc.VISIT_PROV_ID

--LEFT JOIN dbo.ORDER_PROC_2 ordproc2 ON ordproc2.ORDER_PROC_ID = ordproc.ORDER_PROC_ID

--LEFT JOIN dbo.PAT_ENC refenc ON refenc.REFERRAL_ID = ordproc2.REFERRAL_ID AND refenc.APPT_TIME > ordproc.ORDER_TIME

--LEFT JOIN dbo.CLARITY_DEP dep2 ON refenc.DEPARTMENT_ID = dep2.DEPARTMENT_ID

WHERE   1=1
    AND (	
			(	enc.CONTACT_DATE BETWEEN 	@Date_Start AND @Date_End 
			)		
		)
	AND enc.CALCULATED_ENC_STAT_C = 2 -- Complete
	AND enc.REFERRAL_ID IS NOT NULL
--ORDER BY
--            ser.PROV_NAME
--        ,   enc.CONTACT_DATE
--		,   enc.PAT_ENC_CSN_ID
ORDER BY
            zdet.NAME
        ,   ser.PROV_NAME
        ,   enc.CONTACT_DATE
		,   enc.PAT_ENC_CSN_ID
*/
SELECT
dep.DEPARTMENT_NAME
,dephsp.DEPARTMENT_NAME AS DEPARTMENT_NAME_HSP
,ordenc.VISIT_PROV_ID
,ser.PROV_NAME AS VISIT_PROV_NAME
,ordproc.ORDER_PROC_ID
,ordproc.FUTURE_OR_STAND
,ordproc.PAT_ENC_CSN_ID
,ordproc.PAT_ID
,pat.PAT_NAME
,ordproc.ORD_CREATR_USER_ID
,emp.NAME AS ORD_CREATR_USER_NAME
,ordproc.ORDERING_DATE
,ordproc.ORDER_TIME
--,ordproc.CHRG_DROPPED_TIME
,ordproc.ORDER_TYPE_C
,ordtyp.NAME AS ORDER_TYPE_Name
,ordproc.PROC_CODE
,ordproc.PROC_ID
,ordeap.PROC_NAME	 AS Order_Proc_Name
,ordproc.ORDER_STATUS_C
,ordstat.NAME	AS ORDER_STATUS_Name
,ordproc.PROC_BGN_TIME
,ordproc.PROC_END_TIME
,ordproc.PROC_START_TIME
,ordproc.PROC_ENDING_TIME
,   ordproc2.REFERRAL_ID AS Referral_Order_Id
,   ordproc2.REFD_TO_PROV_ID AS Provider_Referred_To
,   ordproc2.REFG_FACILITY_ID AS Referring_Facility_Id
,   ordproc2.LAST_STAND_PERF_DT
,   ordproc2.LAST_STAND_PERF_TM
,   ordproc2.LAST_RESULT_UPD_TM
--,   dep2.DEPARTMENT_NAME AS Referred_DEPARTMENT_NAME
--,   rfl.REFERRAL_PROV_ID
--,   rfl.REFD_TO_DEPT_ID
--,   rfl.REFERRING_PROV_ID
--,   rfl.REFD_BY_DEPT_ID
--,   refenc.APPT_MADE_DATE
--,   refenc.APPT_TIME
,   ordenc.ENC_TYPE_C
,   ordenc.ENC_TYPE_TITLE
,   zdet.NAME AS ENC_TYPE_NAME
,   ordenc.DEPARTMENT_ID AS ordenc_DEPARTMENT_ID
,   ordenchsp.HSP_ACCOUNT_ID
,   ordenchsp.DEPARTMENT_ID AS ordenchsp_DEPARTMENT_ID
,   ordenc.APPT_TIME AS ordenc_APPT_TIME
,   ordenc.CHECKIN_TIME
,   ordenc.CHECKOUT_TIME
,   ordenc.EFFECTIVE_DATE_DTTM
FROM ORDER_PROC ordproc
LEFT OUTER JOIN dbo.PAT_ENC ordenc
ON ordenc.PAT_ENC_CSN_ID = ordproc.PAT_ENC_CSN_ID
LEFT OUTER JOIN dbo.PAT_ENC_HSP ordenchsp
ON ordencHSP.PAT_ENC_CSN_ID = ordproc.PAT_ENC_CSN_ID
--INNER JOIN providers providers
--ON ordenc.VISIT_PROV_ID = providers.PROV_ID
LEFT JOIN CLARITY_EMP emp
ON emp.USER_ID = ordproc.ORD_CREATR_USER_ID
LEFT JOIN ZC_ORDER_TYPE ordtyp
ON ordproc.ORDER_TYPE_C = ordtyp.ORDER_TYPE_C
LEFT JOIN CLARITY_EAP	ordeap
ON ordproc.PROC_ID = ordeap.PROC_ID
LEFT JOIN ZC_ORDER_STATUS	ordstat
ON ordproc.ORDER_STATUS_C = ordstat.ORDER_STATUS_C
LEFT JOIN dbo.ZC_DISP_ENC_TYPE zdet ON zdet.DISP_ENC_TYPE_C = ordenc.ENC_TYPE_C
LEFT JOIN dbo.CLARITY_DEP dep ON ordenc.DEPARTMENT_ID = dep.DEPARTMENT_ID
LEFT JOIN dbo.CLARITY_DEP dephsp ON ordenchsp.DEPARTMENT_ID = dephsp.DEPARTMENT_ID
LEFT JOIN dbo.CLARITY_SER ser ON ser.PROV_ID = ordenc.VISIT_PROV_ID
LEFT JOIN dbo.PATIENT pat ON pat.PAT_ID = ordproc.PAT_ID

LEFT JOIN dbo.ORDER_PROC_2 ordproc2 ON ordproc2.ORDER_PROC_ID = ordproc.ORDER_PROC_ID

--LEFT JOIN dbo.PAT_ENC refenc ON refenc.REFERRAL_ID = ordproc2.REFERRAL_ID AND refenc.APPT_TIME > ordproc.ORDER_TIME

--LEFT JOIN dbo.CLARITY_DEP dep2 ON refenc.DEPARTMENT_ID = dep2.DEPARTMENT_ID

--LEFT JOIN dbo.REFERRAL rfl ON rfl.REFERRAL_ID = ordproc2.REFERRAL_ID

--INNER JOIN providers providers
--ON ordproc2.REFD_TO_PROV_ID = providers.PROV_ID

WHERE   1=1
    AND (	
			(	ordproc.ORDERING_DATE BETWEEN 	@Date_Start AND @Date_End 
			)		
		)
	--AND ordproc.ORDER_TYPE_C = 33
	--AND ordproc.ORDER_TYPE_C NOT IN (7,8,41,22,26,9,10) -- Labs, Outpatient Referral, PR Charge, Charge, Point of Care Testing, Diet, Nursing
	AND ordproc.ORDER_TYPE_C = 12
	--AND ordeap.PROC_NAME LIKE '%CONSULT%'
  --AND ordproc.PROC_ID = 126815 -- PMR EMG STUDY/CONSULT
  AND ordproc.PROC_ID = 351 -- CONSULT TO PHYSICAL MEDICINE REHAB
  AND ordproc.ORDER_STATUS_C <> 4 -- Cancelled
  AND ordproc.FUTURE_OR_STAND = 'S'
--ORDER BY 
--		    ordproc.ORDERING_DATE
--		,   ordproc.ORDER_TIME
--		,    ordproc.PAT_ENC_CSN_ID
--ORDER BY
--            ser.PROV_NAME
--	    ,   ordproc.ORDERING_DATE
--		,   ordproc.ORDER_TIME
--		,   ordproc.PAT_ENC_CSN_ID
--ORDER BY
--            ordeap.PROC_NAME
--        ,   COALESCE(dep.DEPARTMENT_NAME, dephsp.DEPARTMENT_NAME, NULL)
--        ,   ser.PROV_NAME
--	    ,   ordproc.ORDERING_DATE
--		,   ordproc.ORDER_TIME
--		,   ordproc.PAT_ENC_CSN_ID
ORDER BY
            pat.PAT_NAME
        ,   ordeap.PROC_NAME
        ,   COALESCE(dep.DEPARTMENT_NAME, dephsp.DEPARTMENT_NAME, NULL)
        ,   ser.PROV_NAME
	    ,   ordproc.ORDERING_DATE
		,   ordproc.ORDER_TIME
		,   ordproc.PAT_ENC_CSN_ID

/*
SELECT 
    pat.    PAT_MRN_ID
,   pat.    PAT_NAME
,   appt.   APPT_MADE_DTTM
,   appt.   APPT_DTTM
,   appt.   APPT_STATUS_NAME
,   appt.   APPT_SERIAL_NUM
,   appt.   PAT_ENC_CSN_ID

,   ord.	ORDER_PROC_ID
,   ordproc.ORD_CREATR_USER_ID
,   emp.NAME AS ORD_CREATR_USER_NAME
,	ordproc.PAT_ENC_CSN_ID		AS order_CSN_ID

--,   ordenc.ENC_TYPE_C
--,   ordenc.ENC_TYPE_TITLE
--,   zdet.NAME AS ENC_TYPE_NAME
--,   ordenc.DEPARTMENT_ID AS ordenc_DEPARTMENT_ID
--,   ordenc.APPT_TIME AS ordenc_APPT_TIME
--,   ordenc.CHECKIN_TIME
--,   ordenc.CHECKOUT_TIME
--,   ordenc.EFFECTIVE_DATE_DTTM

,	ordproc.ORDERING_DATE
,   ordproc.ORDER_TIME
,	ordproc.ORDER_TYPE_C
,	ordtyp.	NAME				AS ORDER_TYPE_Name
--,	ordproc.PROC_ID
,	ordproc.PROC_CODE
,	ordeap.	PROC_NAME			AS Order_Proc_Name
,	ordproc.ORDER_STATUS_C
,	ordstat.NAME				AS ORDER_STATUS_Name
--,   ordproc.PROC_BGN_TIME
--,   ordproc.PROC_END_TIME
--,   ordproc.PROC_ENDING_TIME
,	ordproc.UPDATE_DATE
--,	quest.	ORD_QUEST_RESP		AS Scheduling_Status
,   ORDER_RESULTS.RESULT_DATE
,   ORDER_RESULTS.RESULT_STATUS_C
,   ORDER_RESULTS.RESULT_TIME
,   ZC_RESULT_STATUS.NAME AS ZC_RESULT_STATUS_NAME
,  ORDER_RES_COMMENT.RESULTS_CMT
,  ORDER_RESULTS.PAT_ENC_CSN_ID AS results_CSN_ID

,   appt.   RESCHED_APPT_CSN_ID
,           CASE    WHEN appt.RESCHED_APPT_CSN_ID IS NOT NULL THEN 'Y' ELSE 'N' END AS Rescheduled_Flag
,   appt.   DEPARTMENT_ID
,   appt.   DEPARTMENT_NAME
,   appt.   JOINT_APPT_YN
,   appt.   CENTER_NAME
,   appt.   PROV_NAME_WID
,   appt.   PRC_NAME                    AS Visit_Type_Name
,   appt.   SAME_DAY_YN
,   appt.   APPT_ENTRY_USER_ID
,   appt.   APPT_ENTRY_USER_NAME_WID
,   appt.   APPT_BLOCK_NAME
,   appt.   APPT_LENGTH
,   appt.   CANCEL_REASON_NAME
,   appt.   CANCEL_INITIATOR
,	appt.	APPT_CANC_DTTM
,   appt.   SAME_DAY_CANC_YN
,   appt.   REFERRING_PROV_NAME_WID
,   appt.   ACCOUNT_ID
,   appt.   HSP_ACCOUNT_ID
,   appt.   APPT_CONF_STAT_NAME
,   appt.   IP_DOC_CONTACT_CSN

,   enc.LINE
,   enc.PROV_START_TIME
,   enc.STAFF_RESOURCE
,   enc.ProviderGroup
,   enc.ProviderType

FROM V_SCHED_APPT   appt
    INNER JOIN providers ON appt.PROV_ID = providers.PROV_ID
    INNER JOIN (SELECT DISTINCT appt.PAT_ENC_CSN_ID, appt.LINE, appt.PROV_START_TIME, ser.STAFF_RESOURCE, physcn.ProviderGroup, physcn.ProviderType
	            FROM CLARITY.dbo.PAT_ENC_APPT appt
                LEFT OUTER JOIN CLARITY.dbo.clarity_ser ser     ON ser.PROV_ID = appt.PROV_ID
                LEFT OUTER JOIN CLARITY.dbo.CLARITY_EMP emp     ON emp.USER_ID = ser.USER_ID
                LEFT OUTER JOIN (SELECT UVaID, ProviderGroup, ProviderType
                                 FROM CLARITY_App.dbo.Dim_Physcn
				                 WHERE current_flag = 1) physcn ON physcn.UVaID = emp.SYSTEM_LOGIN) enc ON appt.PAT_ENC_CSN_ID = enc.PAT_ENC_CSN_ID
    LEFT JOIN CLARITY_SER       ser     ON appt.PROV_ID = ser.PROV_ID
    LEFT JOIN ORD_APPT_SRL_NUM  ord     ON appt.APPT_SERIAL_NUM = ord.APPTS_SCHEDULED				--ORD.156          -- Use ASN not CSN because it looks like the Order is only associated with original appt
	LEFT JOIN ORDER_PROC		ordproc	ON ord.ORDER_PROC_ID = ordproc.ORDER_PROC_ID
    LEFT JOIN PATIENT           pat     ON appt.PAT_ID = pat.PAT_ID
	LEFT JOIN CLARITY_EAP		ordeap	ON ordproc.PROC_ID = ordeap.PROC_ID
	LEFT JOIN ZC_ORDER_STATUS	ordstat	ON ordproc.ORDER_STATUS_C = ordstat.ORDER_STATUS_C
	LEFT JOIN ZC_ORDER_TYPE		ordtyp	ON ordproc.ORDER_TYPE_C = ordtyp.ORDER_TYPE_C
	--LEFT JOIN ORD_SPEC_QUEST	quest	ON ordproc.ORDER_PROC_ID =	quest.ORDER_ID
	--								AND								quest.ORD_QUEST_ID = '105777'
	LEFT JOIN CLARITY_EMP emp ON emp.USER_ID = ordproc.ORD_CREATR_USER_ID
	LEFT JOIN ORDER_RESULTS  ORDER_RESULTS WITH(NOLOCK)ON ordproc.ORDER_PROC_ID = ORDER_RESULTS.ORDER_PROC_ID
	LEFT JOIN CLARITY.DBO.ZC_RESULT_STATUS  ZC_RESULT_STATUS WITH(NOLOCK)ON ORDER_RESULTS.RESULT_STATUS_C = ZC_RESULT_STATUS.RESULT_STATUS_C
	LEFT JOIN CLARITY.DBO.ORDER_RES_COMMENT  ORDER_RES_COMMENT ON ORDER_RESULTS.ORDER_PROC_ID = ORDER_RES_COMMENT.ORDER_ID AND ORDER_RESULTS.LINE = ORDER_RES_COMMENT.LINE

	--LEFT JOIN PAT_ENC ordenc ON ordenc.PAT_ENC_CSN_ID = ordproc.PAT_ENC_CSN_ID

	--LEFT JOIN dbo.ZC_DISP_ENC_TYPE zdet ON zdet.DISP_ENC_TYPE_C = ordenc.ENC_TYPE_C
	
	--LEFT JOIN dbo.ORDER_INSTANTIATED ordinst	ON ordproc.ORDER_PROC_ID = ordinst.ORDER_ID
	
            
WHERE   1=1
    --AND DEPARTMENT_ID IN
    --    ( 10210007        , 10211016        , 10211001        , 10211015
    --    , 10211017        , 10214012        , 10214005        , 10214006
    --    , 10214007        , 10214008        , 10228008        , 10221005
    --    , 10221003        , 10221004        , 10221009        , 10221008
    --    , 10221006        , 10354001        , 10381003        , 10381004
    --    , 10381002        , 10243016        , 10243017        , 10243084
    --    , 10243019        , 10243021        , 10239007        , 10348016
    --    , 10348020        , 10348017        , 10348018		  , 10354003)
  --  AND (	
		--	(	appt.APPT_MADE_DATE	BETWEEN		@Date_Start 		AND 	@Date_End 
		--	AND @DateType = 1)
		--OR	(	appt.APPT_CANC_DATE	BETWEEN		@Date_Start 		AND 	@Date_End 
		--	AND @DateType = 2)
		--OR	(	appt.CONTACT_DATE	BETWEEN		@Date_Start 		AND 	@Date_End 
		--	AND @DateType = 3)		
		--)
    AND (	
			(	appt.CONTACT_DATE	BETWEEN		@Date_Start 		AND 	@Date_End 
			)		
		)
	AND ord.ORDER_PROC_ID IS NOT NULL
	AND ordproc.ORDER_TYPE_C IS NOT NULL
	AND ordproc.ORDER_TYPE_C <> 8
 --	AND   appt.DEPARTMENT_ID		IN (@Department)
	--AND ( pat.PAT_MRN_ID        = @MRN      OR  @MRN IS NULL)
 --   AND ( appt.PAT_ENC_CSN_ID   = @Enc_CSN  OR	@Enc_CSN IS NULL)
	--AND ( appt.APPT_SERIAL_NUM  = @Appt_ASN OR	@Appt_ASN IS NULL)

--ORDER BY appt.PAT_ID
--       , appt.PAT_ENC_CSN_ID
--	   , enc.LINE
ORDER BY 
		    ordproc.ORDERING_DATE
		,   ordproc.ORDER_TIME
		,    appt.PAT_ENC_CSN_ID
*/