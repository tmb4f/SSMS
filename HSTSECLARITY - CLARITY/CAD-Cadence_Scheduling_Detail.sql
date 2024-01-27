USE CLARITY

DECLARE @p_DateStart SMALLDATETIME, @p_DateEnd SMALLDATETIME

SET @p_DateStart = '7/1/2023'
SET @p_DateEnd = '9/15/2023'

SELECT	TOP (100000)
	ROW_NUMBER				=	ROW_NUMBER() OVER (ORDER BY vsca.APPT_DTTM)
,								vsca.PAT_ENC_CSN_ID    
,	PATIENT_NAME			=   pati.PAT_NAME 
,	PATIENT_MRN				=	idid.IDENTITY_ID 
,	PATIENT_AGE_DOS			=	vpef.PAT_AGE_YEARS_AT_ENC

,	CUR_PCP_NAME			=	csrp.PROV_NAME			
,                               vsca.APPT_DTTM

,	ENCOUNTER_TYPE	        =   zdet.NAME
,   VISIT_TYPE_NAME			=   vsca.PRC_NAME 
,   APPT_STATUS_NAME		=   vsca.APPT_STATUS_NAME
,   APPT_STATUS_RPT_GROUP	=	zaps.TITLE
,	TELEHEALTH_MODE			=	ztem.TITLE
,                               vsca.WALK_IN_YN
,                               vsca.APPT_LENGTH
,                               vsca.APPT_MADE_DTTM
,								PAT_ENC_APPT_NOTES.APPT_NOTE_CONCAT

,   POD					    =   pod.NAME
,							    vsca.LOC_NAME
,	SERV_LINE_DEPT		    =   cdep.RPT_GRP_THIRTY
,							    vsca.DEPT_SPECIALTY_NAME
,   DEPARTMENT_NAME_WID     =   vsca.DEPARTMENT_NAME					+ ' [' + CAST(vsca.DEPARTMENT_ID AS VARCHAR(18)) + ']'
,	HUB					    =   hub.NAME

,	FIN_DIV_NM				=	fin_div.NAME
,	FIN_SUBDIV_NM			=	fin_subdiv.NAME
,	SERV_LINE_PROV			=	cser.RPT_GRP_FIVE
,                               vsca.PROV_NAME_WID               

,	FIN_CLASS_NAME			=	zfic.TITLE
,	PAYOR_NAME				=	cepm.PAYOR_NAME
,	BENEFIT_PLAN_NAME		=	cepp.BENEFIT_PLAN_NAME

,	CANCEL_REASON_NAME_INIT	=	vsca.CANCEL_REASON_NAME				+ ' [' + vsca.CANCEL_INITIATOR +']'
,								paen.CANCEL_REASON_CMT
,                               vsca.APPT_CANC_USER_NAME_WID
,                               vsca.APPT_CANC_DTTM
,                               vsca.CANCEL_LEAD_HOURS
,   LATE_CANCEL_YN          =   CASE    WHEN    vsca.APPT_STATUS_C = 3 -- Canceled
                                            AND vsca.CANCEL_INITIATOR = 'PATIENT'
                                            AND vsca.CANCEL_LEAD_HOURS < 24         THEN 'CANCELED, LATE'
                                        WHEN    vsca.APPT_STATUS_C = 3              THEN 'CANCELED, NOT LATE'
                                                                                    ELSE NULL END

,                               vsca.TIME_TO_ROOM_MINUTES
,                               vsca.TIME_IN_ROOM_MINUTES
,                               vsca.CYCLE_TIME_MINUTES

,	                            pae4.VIS_NEW_TO_SYS_YN        
,	                            pae4.VIS_NEW_TO_SPEC_YN
,	                            pae4.VIS_NEW_TO_LOC_YN
,	                            pae4.VIS_NEW_TO_DEP_YN
,	                            pae4.VIS_NEW_TO_PROV_YN

, 							    vsca.REFERRAL_ID
,	REFERRAL_ENTRY_DATE		=	refe.ENTRY_DATE
,   REFERRAL_CLASS_STATUS   =   zcrefcls.NAME + ' [' + zcrefstat.NAME +']'
,   REFERRAL_TYPE           =   zcreftyp.NAME
,                               vsca.REFERRING_PROV_NAME_WID

,   APPT_BLOCK_NAME			=   COALESCE(vsca.APPT_BLOCK_NAME, 'Unblocked') 
,   SLOT_OVERBOOKED_YN      =   COALESCE(vsca.OVERBOOKED_YN, 'N')
,   SLOT_OVERRIDE_YN        =   COALESCE(vsca.OVERRIDE_YN, 'N')
,   SLOT_UNAVAILABLE_YN     =   COALESCE(vsca.UNAVAILABLE_TIME_YN, 'N')

,                               vsca.APPT_SERIAL_NUM
,                               vsca.RESCHED_APPT_CSN_ID
,                               vsca.APPT_ENTRY_USER_NAME_WID

,								r.Tag_Names

FROM CLARITY..V_SCHED_APPT	vsca
    INNER JOIN  CLARITY..PATIENT				pati					ON vsca.PAT_ID = pati.PAT_ID   
	INNER JOIN	CLARITY..VALID_PATIENT			vapa					ON vsca.PAT_ID = vapa.PAT_ID
	INNER JOIN  CLARITY..IDENTITY_ID			idid					ON vsca.PAT_ID = idid.PAT_ID AND idid.IDENTITY_TYPE_ID = 14
    INNER JOIN  CLARITY..PAT_ENC                paen					ON vsca.PAT_ENC_CSN_ID = paen.PAT_ENC_CSN_ID    
    INNER JOIN  CLARITY..PAT_ENC_4              pae4					ON vsca.PAT_ENC_CSN_ID = pae4.PAT_ENC_CSN_ID
    INNER JOIN  CLARITY..PAT_ENC_6				pae6					ON vsca.PAT_ENC_CSN_ID = pae6.PAT_ENC_CSN_ID
	INNER JOIN	CLARITY_App.dbo.Dim_Date		dida					ON vsca.CONTACT_DATE = dida.day_date
	
	LEFT JOIN	CLARITY..V_PAT_ENC_FACT			vpef					ON vsca.PAT_ENC_CSN_ID = vpef.PAT_ENC_CSN_ID	

    LEFT JOIN   CLARITY..CLARITY_SER			cser					ON vsca.prov_id = cser.prov_id
    LEFT JOIN	CLARITY..CLARITY_SER			csrp					ON pati.CUR_PCP_PROV_ID = csrp.PROV_ID
	LEFT JOIN   CLARITY..CLARITY_DEP			cdep					ON vsca.department_id = cdep.DEPARTMENT_ID    
	LEFT JOIN   CLARITY..ZC_DISP_ENC_TYPE       zdet					ON paen.ENC_TYPE_C = zdet.DISP_ENC_TYPE_C    
    LEFT JOIN	CLARITY..ZC_TELEHEALTH_MODE		ztem					ON pae6.TELEHEALTH_MODE_C = ztem.TELEHEALTH_MODE_C

	LEFT JOIN   CLARITY..ZC_DEP_RPT_GRP_6		pod						ON cdep.RPT_GRP_SIX = pod.RPT_GRP_SIX
    LEFT JOIN   CLARITY..ZC_DEP_RPT_GRP_7		hub						ON cdep.RPT_GRP_SEVEN = hub.RPT_GRP_SEVEN
	LEFT JOIN	CLARITY..ZC_SER_RPT_GRP_6		fin_div					ON cser.RPT_GRP_SIX = fin_div.RPT_GRP_SIX
	LEFT JOIN	CLARITY..ZC_SER_RPT_GRP_8		fin_subdiv				ON cser.RPT_GRP_EIGHT = fin_subdiv.RPT_GRP_EIGHT
    
	LEFT JOIN   CLARITY..REFERRAL				refe					ON vsca.REFERRAL_ID = refe.REFERRAL_ID
    LEFT JOIN   CLARITY..ZC_RFL_CLASS			zcrefcls				ON refe.RFL_CLASS_C = zcrefcls.RFL_CLASS_C
    LEFT JOIN   CLARITY..ZC_RFL_STATUS          zcrefstat				ON refe.RFL_STATUS_C = zcrefstat.RFL_STATUS_C
    LEFT JOIN   CLARITY..ZC_RFL_TYPE            zcreftyp				ON refe.RFL_TYPE_C = zcreftyp.RFL_TYPE_C
    
	LEFT JOIN	CLARITY..COVERAGE				cove					ON vsca.COVERAGE_ID = cove.COVERAGE_ID
	LEFT JOIN	CLARITY..CLARITY_EPP			cepp					ON cove.PLAN_ID = cepp.BENEFIT_PLAN_ID
	LEFT JOIN	CLARITY..CLARITY_EPM			cepm					ON cove.PAYOR_ID = cepm.PAYOR_ID
	LEFT JOIN	CLARITY..ZC_FIN_CLASS			zfic					ON cepm.FINANCIAL_CLASS = zfic.FIN_CLASS_C
	
    LEFT JOIN   (   SELECT  PAT_ENC_CSN_ID
                        ,   STUFF((  SELECT  ', ' + LTRIM(RTRIM(APPT_NOTE))
                                     FROM CLARITY.dbo.PAT_ENC_APPT_NOTES innr
                                     WHERE	PAT_ENC_APPT_NOTES.PAT_ENC_CSN_ID = innr.PAT_ENC_CSN_ID
										AND APPT_NOTE <> ''
										AND APPT_NOTE IS NOT NULL
									 ORDER BY LINE
                                     FOR XML PATH ('')
                                     ), 1, 2, '') AS APPT_NOTE_CONCAT
                    FROM CLARITY..PAT_ENC_APPT_NOTES                    
                    GROUP BY PAT_ENC_CSN_ID)        PAT_ENC_APPT_NOTES      ON vsca.PAT_ENC_CSN_ID = PAT_ENC_APPT_NOTES.PAT_ENC_CSN_ID
	
    LEFT JOIN   (
	SELECT
	e.PAT_ENC_CSN_ID,
	--r.REQUEST_ID,
	--r.CREATED_DATE,
	--prc.PRC_NAME,
	--rm.NAME AS REQUEST_METHOD, 
	--rs.NAME AS REQUEST_SOURCE, 
	--cd.DEPARTMENT_NAME AS REQUEST_CREATION_DEPARTMENT,  
	--rd.DEPARTMENT_NAME AS REQUEST_RESPONSIBLE_DEPARTMENT,
	--r.REFERRAL_ID,
	--sd.NAME AS DEPT_SPECIALTY,
	--dt.DTREE_NAME,
	--dt.DTREE_LAST_APPLIED_UTC_DTTM,
	--dt.DiagnosisAnswer,
	--ars.NAME AS Request_Status_Name,
	--s.NAME AS ScheduledStatus,
	tags.Tag_Names,
	ROW_NUMBER() OVER (PARTITION BY l.PAT_ENC_CSN_ID ORDER BY dt.DiagnosisAnswer DESC, dt.DTREE_NAME DESC, tags.Tag_Names DESC, r.REQUEST_ID) AS rownum -- described in 2023/03/27 MOD above. will only pull record if rownum = 1
	FROM
	CLARITY.dbo.V_SCHED_APPT e INNER JOIN
--One Team wave mapping table. 
	CLARITY_App.Stage.AmbOpt_OneTeam_Departments od ON e.DEPARTMENT_ID = od.DEPARTMENT_ID LEFT JOIN 
	CLARITY.dbo.APPT_REQ_APPT_LINKS l ON e.PAT_ENC_CSN_ID = l.PAT_ENC_CSN_ID LEFT JOIN
	CLARITY.dbo.ZC_APPT_REQ_LINK_STATUS s ON s.LINK_STATUS_C = l.LINK_STATUS_C LEFT JOIN
	CLARITY.dbo.APPT_REQUEST r ON l.REQUEST_ID = r.REQUEST_ID LEFT JOIN
	--Questionnaire logic to get Decision Tree information
		( SELECT t.REQUEST_ID,
			dt.FORM_NAME AS DTREE_NAME, 
			t.DTREE_LAST_APPLIED_UTC_DTTM,
			ac.NAME AS DiagnosisAnswer,
			ROW_NUMBER() OVER (PARTITION BY t.REQUEST_ID ORDER BY t.LINE DESC, CASE WHEN ac.NAME IS NULL THEN 0 ELSE 1 END DESC ) AS rownum
			FROM CLARITY.dbo.APPT_REQ_COMPLETED_TREES t LEFT JOIN
			CLARITY.dbo.DTREE_ANSWER a ON a.DTREE_ANSWER_ID = t.DTREE_ANSWER_ID LEFT JOIN
			CLARITY.dbo.CL_QFORM dt ON dt.FORM_ID = a.DTREE_ID LEFT JOIN --Was DECISION_TREE_INFO in TEST
			(SELECT qa.ANSWER_ID, qa.QUEST_ID,  qa.QUEST_ANSWER, qa.QUEST_DATE_REAL
			FROM CLARITY.dbo.CL_QANSWER_QA qa LEFT JOIN 
			CLARITY.dbo.CL_QQUEST qq ON qq.QUEST_ID = qa.QUEST_ID
			WHERE
			qq.QUEST_NAME LIKE '%WHAT IS YOUR SYMPTOM OR DIAGNOSIS%' OR 
			qq.QUEST_NAME LIKE '%What is your reason for return%' OR 
			qq.QUEST_NAME LIKE '%UVA CAD URO SYMPTOM OR DIAGNOSIS%' OR 
			qq.QUEST_NAME LIKE '%UVA CAD URO REASON FOR RETURN VISIT%' OR
			qq.QUEST_NAME LIKE '%REASON FOR VISIT%' OR 
			qq.QUEST_NAME LIKE '%What is the patient’s diagnosis or chief complaint%' OR --Wave 2
			qq.QUEST_NAME LIKE '%What good are you scheduling for%' OR -- Wave 2 
			qq.QUEST_NAME LIKE '%procedure is being requested%' OR -- Wave 3
			qq.QUEST_NAME LIKE '%What is the reason for return%' -- Wave 3
			) qa ON qa.ANSWER_ID = a.DTREE_ANSWER_ID
			LEFT OUTER JOIN CLARITY.dbo.CL_QQUEST_OVTM ov ON qa.QUEST_ID = ov.QUEST_ID
								AND qa.QUEST_DATE_REAL = ov.CONTACT_DATE_REAL
			LEFT OUTER JOIN CLARITY.dbo.ALL_CATEGORIES ac ON ov.RESP_INI = ac.INI 
									AND ov.RESP_ITEM = ac.ITEM 
										AND qa.QUEST_ANSWER = ac.VALUE_C 
											AND ov.RESP_TYPE_C = 7
	) dt ON dt.REQUEST_ID = r.REQUEST_ID AND dt.rownum = 1 LEFT JOIN 
	CLARITY.dbo.ZC_APPT_REQ_STATUS ars ON ars.STATUS_C = r.STATUS_C LEFT JOIN 
	CLARITY.dbo.CLARITY_PRC prc ON r.PRIMARY_PRC_ID = prc.PRC_ID LEFT JOIN 
	CLARITY.dbo.ZC_APPT_REQ_METHOD rm ON rm.REQUEST_METHOD_C = r.REQUEST_METHOD_C LEFT JOIN 
	CLARITY.dbo.ZC_APPT_REQ_SOURCE rs ON rs.REQUEST_SOURCE_C = r.REQUEST_SOURCE_C LEFT JOIN
	CLARITY.dbo.CLARITY_DEP cd ON cd.DEPARTMENT_ID = r.CREATION_DEPARTMENT_ID LEFT JOIN 
	CLARITY.dbo.CLARITY_DEP rd ON rd.DEPARTMENT_ID = r.RESPONSIBLE_DEPARTMENT_ID LEFT JOIN
	CLARITY.dbo.ZC_SPECIALTY_DEP sd ON sd.SPECIALTY_DEP_C = r.DEPT_SPECIALTY_C  LEFT JOIN
	--Merging tags together to put into 1 record
	(
		SELECT rt.REQUEST_ID,
		STRING_AGG (CONVERT(NVARCHAR(MAX),at.NAME), ',') AS Tag_Names 
		FROM CLARITY.dbo.APPT_REQ_TAGS rt INNER JOIN
		CLARITY.dbo.ZC_APPOINTMENT_TAG AT ON AT.APPOINTMENT_TAG_C = rt.APPOINTMENT_TAG_C
		GROUP BY rt.REQUEST_ID
	) tags ON tags.REQUEST_ID = r.REQUEST_ID
	WHERE CONVERT(DATE,e.APPT_MADE_DTTM) BETWEEN @p_DateStart AND @p_DateEnd
) r
ON r.PAT_ENC_CSN_ID = vsca.PAT_ENC_CSN_ID AND r.rownum = 1

	INNER JOIN	(	SELECT APPT_STATUS_C, TITLE
					FROM CLARITY..ZC_APPT_STATUS
					UNION ALL SELECT 0, 'OTHER')	zaps			ON	(CASE    
																					WHEN	vsca.RESCHED_APPT_CSN_ID IS NOT NULL						THEN 105				-- Reschedule 
							    													WHEN    vsca.APPT_STATUS_C IN (3,105)                               THEN 3					-- Canceled 
																					WHEN    vsca.APPT_STATUS_C = 1 
																						AND vsca.CONTACT_DATE  >= DATEADD(DAY,-3,GETDATE())             THEN 1					-- Scheduled 
																					WHEN    (   (	vsca.APPT_STATUS_C = 1 
																								AND vsca.SIGNIN_DTTM IS NOT NULL) 
																							OR  vsca.APPT_STATUS_C IN (2, 6, 102))                      THEN 2					-- Completed 
																					WHEN	vsca.APPT_STATUS_C = 4	
																							OR  (   vsca.APPT_STATUS_C = 1 
																								AND vsca.CONTACT_DATE   < DATEADD(DAY,-3,GETDATE()))	THEN 4					-- No Show 
																					WHEN    vsca.APPT_STATUS_C IN (5, 7)                                THEN 5					-- Left without seen 
																					WHEN    vsca.APPT_STATUS_C IN (101, 103, 104, 106, 17000)           THEN 0					-- UNION Value to list for 'Other'
																										                                                ELSE 0 END	)	=	zaps.APPT_STATUS_C

--WHERE	
--			vsca.CONTACT_DATE >= '2017-07-01'
	
--	AND		(   (   @p_DateType					=   1
--				AND vsca.CONTACT_DATE   >=	@p_DateStart
--	            AND vsca.CONTACT_DATE   <=	@p_DateEnd
--				)
--            OR  (	@p_DateType					=   2
--				AND vsca.APPT_MADE_DATE >=	@p_DateStart
--	            AND vsca.APPT_MADE_DATE <=	@p_DateEnd
--				)
--            OR  (   @p_DateType					=   3
--				AND vsca.APPT_CANC_DATE >=	@p_DateStart
--	            AND vsca.APPT_CANC_DATE <=	@p_DateEnd
--			)   )

--	AND		(	(	@p_Type BETWEEN 1 AND 4
--				AND vsca.DEPARTMENT_ID	IN  (SELECT value FROM STRING_SPLIT(@p_Value,','))
--				)
--			OR	(	@p_Type BETWEEN 5 AND 8
--				AND	vsca.PROV_ID		IN  (SELECT value FROM STRING_SPLIT(@p_Value,','))
--			)	)
	
--	AND		zaps.APPT_STATUS_C IN (SELECT value FROM STRING_SPLIT(@p_ApptStatus,','))	

--	AND		vapa.IS_VALID_PAT_YN = 'Y'

WHERE	
			vsca.CONTACT_DATE   >=	@p_DateStart
	        AND vsca.CONTACT_DATE   <=	@p_DateEnd
	AND		vapa.IS_VALID_PAT_YN = 'Y'
	--AND vsca.DEPARTMENT_ID = 10217003 -- JPA UNIV MED ASSOCS
	AND vsca.DEPARTMENT_ID = 10419013 -- 	OCIR ORTHO SPINE

--ORDER BY vsca.APPT_DTTM
ORDER BY vsca.PAT_ENC_CSN_ID

--OPTION (RECOMPILE)
/*
--SELECT	TOP (100000)
SELECT
	ROW_NUMBER				=	ROW_NUMBER() OVER (ORDER BY V_SCHED_APPT.APPT_DTTM)
,								V_SCHED_APPT.PAT_ENC_CSN_ID    
,	PATIENT_NAME			=   PATIENT.PAT_NAME 
,	PATIENT_MRN				=	IDENTITY_ID.IDENTITY_ID 
,	PATIENT_AGE_DOS			=	CASE    WHEN DATEADD(YEAR, DATEDIFF (YEAR, PATIENT.BIRTH_DATE, CAST(V_SCHED_APPT.APPT_DTTM AS DATE)), PATIENT.BIRTH_DATE) > CAST(V_SCHED_APPT.APPT_DTTM AS DATE)
											THEN DATEDIFF(YEAR, PATIENT.BIRTH_DATE, CAST(V_SCHED_APPT.APPT_DTTM AS DATE)) - 1
                                            ELSE DATEDIFF(YEAR, PATIENT.BIRTH_DATE, CAST(V_SCHED_APPT.APPT_DTTM AS DATE))
                                        END
,								V_PAT_FACT.CUR_PCP_NAME
,                               V_SCHED_APPT.APPT_DTTM

,	ENCOUNTER_TYPE	        =   ZC_DISP_ENC_TYPE.  NAME
,   VISIT_TYPE_NAME			=   V_SCHED_APPT.      PRC_NAME 
,   APPT_STATUS_NAME		=   V_SCHED_APPT.      APPT_STATUS_NAME
,   APPT_STATUS_RPT_GROUP	=	ZC_APPT_STATUS.	TITLE
,                               V_SCHED_APPT.      WALK_IN_YN
,                               V_SCHED_APPT.      APPT_LENGTH
,                               V_SCHED_APPT.      APPT_MADE_DTTM
,								PAT_ENC_APPT_NOTES.APPT_NOTE_CONCAT

,   POD					    =   pod.               NAME
,							    V_SCHED_APPT.      LOC_NAME
,	SERV_LINE_DEPT		    =   CLARITY_DEP.       RPT_GRP_THIRTY
,							    V_SCHED_APPT.      DEPT_SPECIALTY_NAME
,   DEPARTMENT_NAME_WID     =   V_SCHED_APPT.      DEPARTMENT_NAME					+ ' [' + CAST(V_SCHED_APPT.DEPARTMENT_ID AS VARCHAR(18)) + ']'
,	HUB					    =   hub.               NAME

,	FIN_DIV_NM				=	fin_div.           NAME
,	FIN_SUBDIV_NM			=	fin_subdiv.        NAME
,	SERV_LINE_PROV			=	CLARITY_SER.	   RPT_GRP_FIVE
,                               V_SCHED_APPT.      PROV_NAME_WID               

,	                            coverage.          FIN_CLASS_NAME
,	                            coverage.          PAYOR_NAME
,	                            coverage.          BENEFIT_PLAN_NAME

,	CANCEL_REASON_NAME_INIT	=	V_SCHED_APPT.	   CANCEL_REASON_NAME				+ ' [' + V_SCHED_APPT.CANCEL_INITIATOR +']'
,								PAT_ENC.		   CANCEL_REASON_CMT
,                               V_SCHED_APPT.      APPT_CANC_USER_NAME_WID
,                               V_SCHED_APPT.      APPT_CANC_DTTM
,                               V_SCHED_APPT.      CANCEL_LEAD_HOURS
,   LATE_CANCEL_YN          =   CASE    WHEN    V_SCHED_APPT.APPT_STATUS_C = 3 -- Canceled
                                            AND V_SCHED_APPT.CANCEL_INITIATOR = 'PATIENT'
                                            AND V_SCHED_APPT.CANCEL_LEAD_HOURS < 24         THEN 'CANCELED, LATE'
                                        WHEN    V_SCHED_APPT.APPT_STATUS_C = 3              THEN 'CANCELED, NOT LATE'
                                                                                            ELSE NULL END

,                               V_SCHED_APPT.      TIME_TO_ROOM_MINUTES
,                               V_SCHED_APPT.      TIME_IN_ROOM_MINUTES
,                               V_SCHED_APPT.      CYCLE_TIME_MINUTES

,                               V_SCHED_APPT.      ACCOUNT_ID
,                               V_SCHED_APPT.      COPAY_DUE
,                               V_SCHED_APPT.      COPAY_COLLECTED
,                               V_SCHED_APPT.      COPAY_USER_NAME_WID

,	                            PAT_ENC_4.         VIS_NEW_TO_SYS_YN        
,	                            PAT_ENC_4.         VIS_NEW_TO_SPEC_YN
,	                            PAT_ENC_4.         VIS_NEW_TO_LOC_YN
,	                            PAT_ENC_4.         VIS_NEW_TO_DEP_YN
,	                            PAT_ENC_4.         VIS_NEW_TO_PROV_YN

, 							    V_SCHED_APPT.REFERRAL_ID
,	REFERRAL_ENTRY_DATE		=	referral.ENTRY_DATE
,   REFERRAL_CLASS_STATUS   =   zcrefcls.NAME + ' [' + zcrefstat.NAME +']'
,   REFERRAL_TYPE           =   zcreftyp.          NAME
,                               V_SCHED_APPT.      REFERRING_PROV_NAME_WID

,   APPT_BLOCK_NAME			=   COALESCE(V_SCHED_APPT.APPT_BLOCK_NAME, 'Unblocked') 
,   SLOT_OVERBOOKED_YN      =   COALESCE(V_SCHED_APPT.OVERBOOKED_YN, 'N')
,   SLOT_OVERRIDE_YN        =   COALESCE(V_SCHED_APPT.OVERRIDE_YN, 'N')
,   SLOT_UNAVAILABLE_YN     =   COALESCE(V_SCHED_APPT.UNAVAILABLE_TIME_YN, 'N')

,                               V_SCHED_APPT.      APPT_SERIAL_NUM
,                               V_SCHED_APPT.      RESCHED_APPT_CSN_ID
,                               V_SCHED_APPT.      APPT_ENTRY_USER_NAME_WID

FROM CLARITY.dbo.V_SCHED_APPT
    INNER JOIN  CLARITY.dbo.                        PATIENT                 ON V_SCHED_APPT.PAT_ID = PATIENT.PAT_ID   
    INNER JOIN	CLARITY.dbo.						V_PAT_FACT				ON V_SCHED_APPT.PAT_ID = V_PAT_FACT.PAT_ID
	INNER JOIN  CLARITY.dbo.                        IDENTITY_ID             ON V_SCHED_APPT.PAT_ID = IDENTITY_ID.PAT_ID AND IDENTITY_ID.IDENTITY_TYPE_ID = 14
    INNER JOIN  CLARITY.dbo.                        PAT_ENC                 ON V_SCHED_APPT.PAT_ENC_CSN_ID = PAT_ENC.PAT_ENC_CSN_ID    
    INNER JOIN  CLARITY.dbo.                        PAT_ENC_4               ON V_SCHED_APPT.PAT_ENC_CSN_ID = PAT_ENC_4.PAT_ENC_CSN_ID
    INNER JOIN	CLARITY_App.dbo.                    Dim_Date                ON V_SCHED_APPT.CONTACT_DATE = Dim_Date.day_date

    LEFT JOIN   CLARITY.dbo.                        CLARITY_SER             ON V_SCHED_APPT.prov_id = CLARITY_SER.prov_id
    LEFT JOIN   CLARITY.dbo.                        CLARITY_DEP             ON V_SCHED_APPT.department_id = CLARITY_DEP.DEPARTMENT_ID    
	LEFT JOIN   CLARITY.dbo.                        ZC_DISP_ENC_TYPE        ON PAT_ENC.ENC_TYPE_C = ZC_DISP_ENC_TYPE.DISP_ENC_TYPE_C    
    
	LEFT JOIN   CLARITY.dbo.ZC_DEP_RPT_GRP_6        AS pod                  ON CLARITY_DEP.RPT_GRP_SIX = pod.RPT_GRP_SIX
    LEFT JOIN   CLARITY.dbo.ZC_DEP_RPT_GRP_7        AS hub                  ON CLARITY_DEP.RPT_GRP_SEVEN = hub.RPT_GRP_SEVEN
	LEFT JOIN	CLARITY.dbo.ZC_SER_RPT_GRP_6        AS fin_div				ON CLARITY_SER.RPT_GRP_SIX = fin_div.RPT_GRP_SIX
	LEFT JOIN	CLARITY.dbo.ZC_SER_RPT_GRP_8        AS fin_subdiv			ON CLARITY_SER.RPT_GRP_EIGHT = fin_subdiv.RPT_GRP_EIGHT
    
	LEFT JOIN   CLARITY.dbo.						REFERRAL				ON V_SCHED_APPT.REFERRAL_ID = REFERRAL.REFERRAL_ID
    LEFT JOIN   CLARITY.dbo.ZC_RFL_CLASS            AS zcrefcls             ON referral.RFL_CLASS_C = zcrefcls.RFL_CLASS_C
    LEFT JOIN   CLARITY.dbo.ZC_RFL_STATUS           AS zcrefstat            ON referral.RFL_STATUS_C = zcrefstat.RFL_STATUS_C
    LEFT JOIN   CLARITY.dbo.ZC_RFL_TYPE             AS zcreftyp             ON referral.RFL_TYPE_C = zcreftyp.RFL_TYPE_C
    
	LEFT JOIN   CLARITY.dbo.V_COVERAGE_PAYOR_PLAN   AS coverage             ON  V_SCHED_APPT.COVERAGE_ID = coverage.COVERAGE_ID
                                                                            AND (   (V_SCHED_APPT.CONTACT_DATE >= coverage.EFF_DATE )
                                                                                AND	(V_SCHED_APPT.CONTACT_DATE <= coverage.TERM_DATE)    ) 
																			
    LEFT JOIN   (   SELECT  PAT_ENC_CSN_ID
                        ,   STUFF((  SELECT  ', ' + LTRIM(RTRIM(APPT_NOTE))
                                     FROM CLARITY.dbo.PAT_ENC_APPT_NOTES innr
                                     WHERE	PAT_ENC_APPT_NOTES.PAT_ENC_CSN_ID = innr.PAT_ENC_CSN_ID
										AND APPT_NOTE <> ''
										AND APPT_NOTE IS NOT NULL
									 ORDER BY LINE
                                     FOR XML PATH ('')
                                     ), 1, 2, '') AS APPT_NOTE_CONCAT
                    FROM CLARITY.dbo.PAT_ENC_APPT_NOTES                    
                    GROUP BY PAT_ENC_CSN_ID)        PAT_ENC_APPT_NOTES      ON V_SCHED_APPT.PAT_ENC_CSN_ID = PAT_ENC_APPT_NOTES.PAT_ENC_CSN_ID

	INNER JOIN	(	SELECT APPT_STATUS_C, TITLE
					FROM CLARITY.dbo.ZC_APPT_STATUS
					UNION ALL SELECT 0, 'OTHER')	ZC_APPT_STATUS			ON	(CASE    
																					WHEN	V_SCHED_APPT.RESCHED_APPT_CSN_ID IS NOT NULL						THEN 105				-- Reschedule 
							    													WHEN    V_SCHED_APPT.APPT_STATUS_C IN (3,105)                               THEN 3					-- Canceled 
																					WHEN    V_SCHED_APPT.APPT_STATUS_C = 1 
																						AND V_SCHED_APPT.CONTACT_DATE  >= DATEADD(DAY,-3,GETDATE())             THEN 1					-- Scheduled 
																					WHEN    (   (	V_SCHED_APPT.APPT_STATUS_C = 1 
																								AND SIGNIN_DTTM IS NOT NULL) 
																							OR  V_SCHED_APPT.APPT_STATUS_C IN (2, 6, 102))                      THEN 2					-- Completed 
																					WHEN	V_SCHED_APPT.APPT_STATUS_C = 4	
																							OR  (   V_SCHED_APPT.APPT_STATUS_C = 1 
																								AND V_SCHED_APPT.CONTACT_DATE   < DATEADD(DAY,-3,GETDATE()))	THEN 4					-- No Show 
																					WHEN    V_SCHED_APPT.APPT_STATUS_C IN (5, 7)                                THEN 5					-- Left without seen 
																					WHEN    V_SCHED_APPT.APPT_STATUS_C IN (101, 103, 104, 106, 17000)           THEN 0					-- UNION Value to list for 'Other'
																										                                                        ELSE 0 END	)	=		ZC_APPT_STATUS.APPT_STATUS_C

--WHERE	
--			V_SCHED_APPT.CONTACT_DATE >= '2017-07-01'
	
--	AND		(   (   @p_DateType					=   1
--				AND V_SCHED_APPT.CONTACT_DATE   >=	@p_DateStart
--	            AND V_SCHED_APPT.CONTACT_DATE   <=	@p_DateEnd
--				)
--            OR  (	@p_DateType					=   2
--				AND V_SCHED_APPT.APPT_MADE_DATE >=	@p_DateStart
--	            AND V_SCHED_APPT.APPT_MADE_DATE <=	@p_DateEnd
--				)
--            OR  (   @p_DateType					=   3
--				AND V_SCHED_APPT.APPT_CANC_DATE >=	@p_DateStart
--	            AND V_SCHED_APPT.APPT_CANC_DATE <=	@p_DateEnd
--			)   )

--	AND		(	(	@p_Type BETWEEN 1 AND 4
--				AND V_SCHED_APPT.DEPARTMENT_ID	IN  (SELECT value FROM STRING_SPLIT(@p_Value,','))
--				)
--			OR	(	@p_Type BETWEEN 5 AND 8
--				AND	V_SCHED_APPT.PROV_ID		IN  (SELECT value FROM STRING_SPLIT(@p_Value,','))
--			)	)
	
--	AND		ZC_APPT_STATUS.APPT_STATUS_C IN (SELECT value FROM STRING_SPLIT(@p_ApptStatus,','))	

--	AND		V_PAT_FACT.IS_VALID_PAT_YN = 'Y'

WHERE	
			V_SCHED_APPT.CONTACT_DATE   >=	'2022-01-02'
	        AND V_SCHED_APPT.CONTACT_DATE   <=	'2022-01-08'
	AND		V_PAT_FACT.IS_VALID_PAT_YN = 'Y'

ORDER BY V_SCHED_APPT.APPT_DTTM
*/
