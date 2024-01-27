/*
Purpose: 
Operational Owner:  Tom Beck, Finance
Created for CHARTIS .  
Jaimie Meyer
Engagement Manager
The Chartis Group
Cell: 231.818.1381 
jmeyer@chartis.com
www.chartis.com
====================================
MODS
initial draft 2021.07.12 - syg2d
=====================================
To confirm  columns you would need

•	ESI (Emergency Severity Index)  level which is a scale of 1-5. – this is the Level of Care we were looking for
•	Chief Complaint – Complaint patient provides on arrival to ED for the patient’s ED Visit
•	Diagnosis – Provider’s diagnosis for patient
•	Contact Date  - will you please provide a definition of this date? I see below it may vary from ED admit/ED arrival
•	1st arrival to ED time<military format> - time patient arrives at the ED
•	Triage In – time patient enters room for triage <military format>, if available
•	Triage Out – time patient leaves triage <military format>, if available
•	In Room (or In Treatment) – time patient enters ED room <military format>, if available
•	Exam by Provider – First time stamp a Qualified Medical Provider sees the patient <military format>, if available
•	Disposition Time – Time stamp Provider documents disposition <military format>, if available
•	Admit Decision – Time when all documentation is completed the patient needs to be admitted to the hospital <military format>, if available
•	Discharge Decision – time when all documentation is completed and the patient can be discharged <military format>, if available
•	IP Bed Assignment – time when an admitted patient is assigned a bed on a nursing unit <military format>, if available
•	IP Bed Ready – time when an admitted patient’s bed/room is ready for the patient to be transferred to <military format>, if available
•	Depart – time patient leaves the ED <military format>, if available
•	Time Admitted Patient arrives to Admitted Location – time admitted patient arrives to place of admission (time stamp may only be available in bed monitoring system) <military format>, if available
•	admit time<military format> replaced with above detail
•	and ED departure time (and/or ED LOS) <military format> replaced with above detail

F_ED_ENCOUNTERS 
* Subsquery fields prefixed by TBL_
*Separate Date/time fields.  Time in Military
** do not send any patient specific fields
*/

SELECT
--=== for testing only
	--F_ED_ENCOUNTERS.PAT_ID, F_ED_ENCOUNTERS.ADT_ARRIVAL_DATE, F_ED_ENCOUNTERS.PAT_ENC_CSN_ID,
	--CASE WHEN TBL_ED_TIMES.ED_Decision_to_Admit IS NOT  NULL THEN 'IP' ELSE 'OP' END [cls],
	
-----  end testing
  [EMERGENCY SEVERITY INDEX]= COALESCE(F_ED_ENCOUNTERS.ACUITY_LEVEL_C,'')													--•	ESI (Emergency Severity Index)  level which is a scale of 1-5. – this is the Level of Care we were looking for -- ACUITY_LEVEL_C
, [ED FIRST CHIEF COMPLAINT]= COALESCE(CL_RSN_FOR_VISIT.REASON_VISIT_NAME,'')												--•	Chief Complaint – Complaint patient provides on arrival to ED for the patient’s ED Visit
, [PRIMARY ED DIAGNOSIS]	= COALESCE(TBL_ED_DX.DX_NAME,'')																--•	Diagnosis – Provider’s diagnosis for patient
, [FIRST ARRIVAL DATE]		= COALESCE(CONVERT(VARCHAR(10),F_ED_ENCOUNTERS.ADT_ARRIVAL_DATE,101),'')
, [FIRST ARRIVAL_TIME]		= COALESCE(CONVERT(VARCHAR(5),CAST(F_ED_ENCOUNTERS.ADT_ARRIVAL_DTTM			AS TIME), 108),'') 	--•	1st arrival to ED time<military format> - time patient arrives at the ED
, [TRIAGE IN DATE]			= COALESCE(CONVERT(VARCHAR(10),TBL_ED_TIMES.Triage_Started,101),'')								--•	Triage In – time patient enters room for triage <military format>, if available		
, [TRIAGE IN TIME]			= COALESCE(CONVERT(VARCHAR(5),CAST(TBL_ED_TIMES.Triage_Started				AS TIME),108),'')	
, [TRIAGE OUT DATE]			= COALESCE(CONVERT(VARCHAR(10),TBL_ED_TIMES.Triage_Completed,101),'')							--•	Triage Out – time patient leaves triage <military format>, if available
, [TRIAGE OUT TIME]			= COALESCE(CONVERT(VARCHAR(5),CAST(TBL_ED_TIMES.Triage_Completed			AS TIME),108),'')
, [IN ROOM DATE]			= COALESCE(CONVERT(VARCHAR(10),TBL_ED_TIMES.Patient_roomed_in_ED,101),'')						--•	In Room (or In Treatment) – time patient enters ED room <military format>, if available
, [IN ROOM TIME]			= COALESCE(CONVERT(VARCHAR(5),CAST(TBL_ED_TIMES.Patient_roomed_in_ED		AS TIME), 108),'') 
, [EXAM BY PROVIDER DATE]	= COALESCE(CONVERT(VARCHAR(10),TBL_FIRST_ATTND_TIME.First_Attending_Time,101),'')				--•	Exam by Provider – First time stamp a Qualified Medical Provider sees the patient <military format>, if available
, [EXAM BY PROVIDER TIME]	= COALESCE(CONVERT(VARCHAR(5),CAST(TBL_FIRST_ATTND_TIME.First_Attending_Time AS TIME), 108),'')	
, [DISPOSITION DATE]		= COALESCE(CONVERT(VARCHAR(10),F_ED_ENCOUNTERS.ED_DISPOSITION_DTTM	,101),'')					--•	Disposition Time – Time stamp Provider documents disposition <military format>, if available
, [DISPOSITION TIME]		= COALESCE(CONVERT(VARCHAR(5),CAST(F_ED_ENCOUNTERS.ED_DISPOSITION_DTTM		AS TIME), 108),'')
, [ADMIT DECISION DATE]		= COALESCE(CONVERT(VARCHAR(10),TBL_ED_TIMES.ED_Decision_to_Admit	,101),'')					--•	Admit Decision – Time when all documentation is completed the patient needs to be admitted to the hospital <military format>, if available
, [ADMIT DECISION TIME]		= COALESCE(CONVERT(VARCHAR(5),CAST(TBL_ED_TIMES.ED_Decision_to_Admit		AS TIME), 108),'')	
, [DISCHAGE DECISION DATE]	= COALESCE(CONVERT(VARCHAR(10),F_ED_ENCOUNTERS.HOSPITAL_DISCHARGE_DTTM,101),'')					--•	Discharge Decision – time when all documentation is completed and the patient can be discharged <military format>, if available
, [DISCHAGE DECISION TIME]	= COALESCE(CONVERT(VARCHAR(5),CAST(F_ED_ENCOUNTERS.HOSPITAL_DISCHARGE_DTTM	AS TIME), 108),'')	
, [IP BED ASSIGN DATE]		= COALESCE(CONVERT(VARCHAR(10),TBL_BED.Bed_Assign_Time	,101),'')								--•	IP Bed Assignment – time when an admitted patient is assigned a bed on a nursing unit <military format>, if available
, [IP BED ASSIGN TIME]		= COALESCE(CONVERT(VARCHAR(5),CAST(TBL_BED.Bed_Assign_Time					AS TIME), 108),'')
, [IP BED READY DATE]		= COALESCE(CONVERT(VARCHAR(10),TBL_BED_TIMES.First_BedReady_Dttm	,101),'')					--•	IP Bed Ready – time when an admitted patient’s bed/room is ready for the patient to be transferred to <military format>, if available
, [IP BED READY TIME]		= COALESCE(CONVERT(VARCHAR(5),CAST(TBL_BED_TIMES.First_BedReady_Dttm		AS TIME), 108),'')	
, [DEPART ED DATE]			= COALESCE(CONVERT(VARCHAR(10),F_ED_ENCOUNTERS.ED_DEPARTURE_DTTM	,101),'')					--•	Depart – time patient leaves the ED <military format>, if available
, [DEPART ED TIME]			= COALESCE(CONVERT(VARCHAR(5),CAST(F_ED_ENCOUNTERS.ED_DEPARTURE_DTTM		AS TIME), 108),'')	
, [IP ADMIT ARRIVAL DATE]	= COALESCE(CONVERT(VARCHAR(10),TBL_FIRST_DEP.First_Arrival_Time	,101),'')						--•	Time Admitted Patient arrives to Admitted Location – time admitted patient arrives to place of admission (time stamp may only be available in bed monitoring system) <military format>, if available
, [IP ADMIT ARRIVAL TIME]	= COALESCE(CONVERT(VARCHAR(5),CAST(TBL_FIRST_DEP.First_Arrival_Time			AS TIME), 108),'')

FROM					 CLARITY..F_ED_ENCOUNTERS		F_ED_ENCOUNTERS

		 LEFT OUTER JOIN CLARITY..CL_RSN_FOR_VISIT		CL_RSN_FOR_VISIT         ON F_ED_ENCOUNTERS.FIRST_CHIEF_COMPLAINT_ID = CL_RSN_FOR_VISIT.REASON_VISIT_ID

		 LEFT OUTER JOIN ( -- adopted from CDW extract
				 SELECT PAT_ENC_CSN_ID CSN, MAX(PAT_ENC_DX.DX_ID) DX_ID, MAX(CLARITY_EDG.CURRENT_ICD10_LIST)[DX_CODE], MAX(CLARITY_EDG.DX_NAME)DX_NAME
                 FROM   CLARITY..PAT_ENC_DX PAT_ENC_DX
				 INNER JOIN CLARITY..CLARITY_EDG CLARITY_EDG ON CLARITY_EDG.DX_ID = PAT_ENC_DX.DX_ID
                 WHERE PAT_ENC_DX.DX_ID IS NOT NULL 
                   AND PAT_ENC_DX.PRIMARY_DX_YN = 'Y'
                   AND PAT_ENC_DX.DX_ED_YN = 'Y'
                 GROUP BY PAT_ENC_CSN_ID
				) TBL_ED_DX      ON F_ED_ENCOUNTERS.PAT_ENC_CSN_ID = TBL_ED_DX.CSN

		LEFT OUTER JOIN (  -- adopted from patient ed summary previous stored  proc
				SELECT 
					  ED_IEV_PAT_INFO.PAT_ENC_CSN_ID
					, MIN(CASE WHEN ED_IEV_EVENT_INFO.EVENT_TYPE = '55'				THEN ED_IEV_EVENT_INFO.EVENT_TIME   END   ) AS [Patient_roomed_in_ED]
					, MIN(CASE WHEN ED_IEV_EVENT_INFO.EVENT_TYPE = '205'			THEN ED_IEV_EVENT_INFO.EVENT_TIME   END   ) AS [Triage_Started]
					, MIN(CASE WHEN ED_IEV_EVENT_INFO.EVENT_TYPE = '210'			THEN ED_IEV_EVENT_INFO.EVENT_TIME   END   ) AS [Triage_Completed]
					, MIN(CASE WHEN ED_IEV_EVENT_INFO.EVENT_TYPE = ('236')			THEN ED_IEV_EVENT_INFO.EVENT_TIME   END   ) AS [Bed_Assigned]
					, MAX(CASE WHEN ED_IEV_EVENT_INFO.EVENT_TYPE = '1601100002'		THEN ED_IEV_EVENT_INFO.EVENT_TIME   END   ) AS [ED_Decision_to_Admit]
					, MIN(CASE WHEN ED_IEV_EVENT_INFO.EVENT_TYPE IN ('172', '70')	THEN ED_IEV_EVENT_INFO.EVENT_TIME   END	  ) AS [Patient_Transferred]
				FROM  CLARITY..ED_IEV_PAT_INFO					ED_IEV_PAT_INFO
					  INNER JOIN CLARITY.dbo.ED_IEV_EVENT_INFO  ED_IEV_EVENT_INFO ON ED_IEV_EVENT_INFO.EVENT_ID = ED_IEV_PAT_INFO.EVENT_ID
				WHERE 1=1
					  AND   ED_IEV_EVENT_INFO.EVENT_TYPE IN ('55', '205', '210', '236', '1601100002', '70', '172')
				GROUP BY	ED_IEV_PAT_INFO.PAT_ENC_CSN_ID
				)TBL_ED_TIMES  ON F_ED_ENCOUNTERS.PAT_ENC_CSN_ID = TBL_ED_TIMES.PAT_ENC_CSN_ID

		LEFT OUTER JOIN ( -- adopted from CDW extract EdVisitFact
				 SELECT PAT_ENC_HSP.PAT_ENC_CSN_ID CSN, MIN(COALESCE(HSP_ATND_PROV.ATTEND_FROM_DATE, PAT_ENC_HSP.HOSP_ADMSN_TIME)) First_Attending_Time
                 FROM   CLARITY..PAT_ENC_HSP				PAT_ENC_HSP
					    INNER JOIN CLARITY..HSP_ATND_PROV	HSP_ATND_PROV  ON PAT_ENC_HSP.PAT_ENC_CSN_ID = HSP_ATND_PROV.PAT_ENC_CSN_ID
                 WHERE  PAT_ENC_HSP.ED_EPISODE_ID     IS NOT NULL
                   AND (PAT_ENC_HSP.ADMIT_CONF_STAT_C IS NULL OR PAT_ENC_HSP.ADMIT_CONF_STAT_C NOT IN (2, 3))
                   AND HSP_ATND_PROV.ED_ATTEND_YN = 'Y'
                 GROUP BY PAT_ENC_HSP.PAT_ENC_CSN_ID
				 ) TBL_FIRST_ATTND_TIME 									ON F_ED_ENCOUNTERS.PAT_ENC_CSN_ID = TBL_FIRST_ATTND_TIME.CSN

		LEFT OUTER JOIN (
				 SELECT CLARITY_ADT.PAT_ENC_CSN_ID CSN, MIN(PEND_ACTION.ASSIGNED_TIME) Bed_Assign_Time, MIN(PEND_ACTION.REQUEST_TIME) BEDREQUESTEDTIME
                 FROM CLARITY..CLARITY_ADT	CLARITY_ADT
                   INNER JOIN CLARITY..CLARITY_DEP   CLARITY_DEP	ON CLARITY_ADT.DEPARTMENT_ID = CLARITY_DEP.DEPARTMENT_ID
                   INNER JOIN CLARITY..PEND_ACTION   PEND_ACTION	ON CLARITY_ADT.EVENT_ID      = PEND_ACTION.LINKED_EVENT_ID
                  WHERE CLARITY_ADT.EVENT_TYPE_C = 3
                    AND NULLIF(1, CLARITY_DEP.ADT_UNIT_TYPE_C) IS NOT NULL
                    AND PEND_ACTION.COMPLETED_YN = 'Y'	
                  GROUP BY CLARITY_ADT.PAT_ENC_CSN_ID
				  ) TBL_BED													ON F_ED_ENCOUNTERS.PAT_ENC_CSN_ID = TBL_BED.CSN
      
		LEFT OUTER JOIN ( 
				SELECT PEND_ACTION.PAT_ENC_CSN_ID, MIN(BED_PLAN_HX.PEND_ID)[PEND_ID], MIN( CASE WHEN BED_PLAN_HX.UPDATE_TYPE_C = 12 THEN BED_PLAN_HX.UPDATE_INST_LOCAL_DTTM ELSE NULL END ) First_BedReady_Dttm
				FROM CLARITY..BED_PLAN_HX				BED_PLAN_HX
					INNER JOIN CLARITY..PEND_ACTION		PEND_ACTION			ON PEND_ACTION.PEND_ID = BED_PLAN_HX.PEND_ID
                WHERE PEND_ACTION.PEND_EVENT_TYPE_C IN ( 1, 3 )
						AND PEND_ACTION.PEND_REQ_STATUS_C IS NOT NULL
						AND UPDATE_TYPE_C = 12
						AND BED_PLAN_HX.LINE =  
										(SELECT MIN(BED_PLAN_HX_min.LINE)
										FROM CLARITY..BED_PLAN_HX				BED_PLAN_HX_min
											INNER JOIN CLARITY..PEND_ACTION	PEND_ACTION_min ON pend_action_min.PEND_ID=BED_PLAN_HX_min.PEND_ID
										WHERE PEND_ACTION_min.PEND_EVENT_TYPE_C IN ( 1, 3 )
										AND PEND_ACTION_min.PEND_REQ_STATUS_C IS NOT NULL
										AND BED_PLAN_HX_min.UPDATE_TYPE_C = 12
										AND PEND_ACTION_min.PAT_ENC_CSN_ID = PEND_ACTION.PAT_ENC_CSN_ID)									
						GROUP BY PEND_ACTION.PAT_ENC_CSN_ID
				)TBL_BED_TIMES												ON F_ED_ENCOUNTERS.PAT_ENC_CSN_ID= TBL_BED_TIMES.PAT_ENC_CSN_ID

		LEFT OUTER JOIN (
				SELECT CLARITY_ADT.PAT_ENC_CSN_ID CSN, 
                      CLARITY_ADT.DEPARTMENT_ID DEPARTMENTID, 
                      CLARITY_ADT.EFFECTIVE_TIME First_Arrival_Time,
					  CLARITY_DEP.ADT_UNIT_TYPE_C,
					  clarity_adt.EVENT_TYPE_C,
					  clarity_adt.XFER_EVENT_ID,
					  clarity_adt.NEXT_OUT_EVENT_ID,
                      ROW_NUMBER() OVER(PARTITION BY CLARITY_ADT.PAT_ENC_CSN_ID ORDER BY CLARITY_ADT.EFFECTIVE_TIME, CLARITY_ADT.EVENT_ID) RANKING
                 FROM CLARITY..CLARITY_ADT					CLARITY_ADT
						INNER JOIN CLARITY..CLARITY_DEP		CLARITY_DEP		ON CLARITY_ADT.DEPARTMENT_ID = CLARITY_DEP.DEPARTMENT_ID
						INNER JOIN CLARITY..CLARITY_BED		CLARITY_BED		ON CLARITY_BED.BED_CSN_ID	 = CLARITY_ADT.BED_CSN_ID AND CLARITY_BED.CENSUS_INCLUSN_YN = 'Y'
                 WHERE 1=1
					AND CLARITY_ADT.EVENT_TYPE_C = 3
					AND  (CLARITY_DEP.ADT_UNIT_TYPE_C <>1  OR CLARITY_DEP.ADT_UNIT_TYPE_C IS NULL) -- emergency dept
					AND CLARITY_ADT.EVENT_SUBTYPE_C <> 2
				  ) TBL_FIRST_DEP											ON F_ED_ENCOUNTERS.PAT_ENC_CSN_ID = TBL_FIRST_DEP.CSN      AND TBL_FIRST_DEP.RANKING = 1

WHERE	F_ED_ENCOUNTERS.ED_EPISODE_ID IS NOT NULL --ed visits ONLY
		 --AND F_ED_ENCOUNTERS.ADT_ARRIVAL_DATE  >= '1/1/2020'
		 AND F_ED_ENCOUNTERS.ADT_ARRIVAL_DATE  >= '12/1/2021'
		 --AND F_ED_ENCOUNTERS.ADT_ARRIVAL_DATE <= '12/31/2020'
		 AND F_ED_ENCOUNTERS.ADT_ARRIVAL_DATE <= '12/31/2021'
	ORDER BY F_ED_ENCOUNTERS.pat_id, F_ED_ENCOUNTERS.PAT_ENC_CSN_ID
