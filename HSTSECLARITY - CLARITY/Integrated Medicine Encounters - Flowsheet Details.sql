USE CLARITY

SELECT
     IDENTITY_ID
   , RECORDED_DATE
   --, [1480] AS R_ORT_PAIN_QUALITY_ADDITIONAL_READING
   , [3531] AS R_UVA_IP_PAIN_DESCRIPTORS
   , [3541] AS R_UVA_PAIN_ASSESSMENT
   , [13498] AS R_INCORPORATING_PHYSICAL_ACTIVITY_INTO_LIFESTYLE
   , [301090] AS R_UVA_PAIN_BODY_LOCATION_1
   , [400290] AS R_HAVE_PAIN_NOW
   --, [2100700014] AS R_UVA_ID_HEPC_DEPRESSION_LIFE_HAD_BEEN_A_FAILURE
   --, [2100700028] AS R_UVA_ID_HEPC_DEPRESSION_ENJOYED_LIFE
   , [2103700557] AS R_UVA_AMB_GAD7_SCORE_NERVOUS_ANXIOUS_ON_EDGE
   , [2103700585] AS R_UVA_AMB_GAD7_SCORE_CONTROL_WORRYING
   , [2103700586] AS R_UVA_AMB_GAD7_SCORE_WORRYING_ABOUT_DIF_THINGS
   , [2103700587] AS R_UVA_AMB_GAD7_SCORE_TROUBLE_RELAXING
   , [2103700588] AS R_UVA_AMB_GAD7_SCORE_RESTLESS_CANT_SIT_STILL
   , [2103700589] AS R_UVA_AMB_GAD7_SCORE_EASILY_ANNOYED_IRRITABLE
   , [2103700757] AS R_UVA_AMB_GAD7_SCORE_AFRAID
   , [2103700758] AS R_UVA_AMB_GAD7_TOTAL_SCORE
   , [2103700759] AS R_UVA_AMB_GAD7_SCORE_HOW_DIFFICULT_ARE_PROBLEMS
   , [2103701436] AS R_UVA_AMB_BEWELL_MONTHLY_PAIN_LIFE_IMPACT
   --, [2104500752] AS R_UVA_AMB_QUALITY_LIFE
   , [3040100009] AS R_UVA_PAIN_TYPE_1
   , [3050000397] AS R_UVA_PAIN_RATING_SCALE_1
   --, [3050300600] AS R_UVA_KOOS_SCORE_LIFESTYLE_MODIFICATION
   --, [3050300603] AS R_UVA_KOOS_SCORE_QUALITY_OF_LIFE_SCORE
   , [3050600047] AS R_UVA_IP_AMB_HOD_DEPRESSION_SCREEN_PHQ_2_SCORE
   , [3050600180] AS R_UVA_IP_AMB_HOD_DEPRESSION_SCREEN_HOW_DIFFICULT_ARE_PROBLEMS
   --, [3050800468] AS R_UVA_PROMIS_29_CHORES
   --, [3050800469] AS R_UVA_PROMIS_29_STAIRS
   --, [3050800470] AS R_UVA_PROMIS_29_WALK
   --, [3050800471] AS R_UVA_PROMIS_29_ERRANDS
   --, [3050800472] AS R_UVA_PROMIS_29_FEARFUL
   --, [3050800473] AS R_UVA_PROMIS_29_FOCUS
   --, [3050800474] AS R_UVA_PROMIS_29_WORRIES
   --, [3050800475] AS R_UVA_PROMIS_29_UNEASY
   --, [3050800476] AS R_UVA_PROMIS_29_WORTHLESS
   --, [3050800477] AS R_UVA_PROMIS_29_HELPLESS
   --, [3050800478] AS R_UVA_PROMIS_29_DEPRESSED
   --, [3050800479] AS R_UVA_PROMIS_29_HOPELESS
   --, [3050800480] AS R_UVA_PROMIS_29_FATIGUED
   --, [3050800481] AS R_UVA_PROMIS_29_STARTING_TASK
   --, [3050800482] AS R_UVA_PROMIS_29_RUN_DOWN
   --, [3050800483] AS R_UVA_PROMIS_29_AVERAGE_FATIGUED
   --, [3050800484] AS R_UVA_PROMIS_29_SLEEP_QUALITY
   --, [3050800485] AS R_UVA_PROMIS_29_SLEEP_REFRESHING
   --, [3050800486] AS R_UVA_PROMIS_29_SLEEP_PROBLEM
   --, [3050800487] AS R_UVA_PROMIS_29_FALLING_ASLEEP
   --, [3050800488] AS R_UVA_PROMIS_29_LEISURE_ACTIVITIES
   --, [3050800489] AS R_UVA_PROMIS_29_FAMILY_ACTIVITIES
   --, [3050800490] AS R_UVA_PROMIS_29_WORK
   --, [3050800491] AS R_UVA_PROMIS_29_ALL_ACTIVITIES
   --, [3050800492] AS R_UVA_PROMIS_29_PAIN_DAY_TO_DAY
   --, [3050800493] AS R_UVA_PROMIS_29_PAIN_WORK
   --, [3050800494] AS R_UVA_PROMIS_29_PAIN_SOCIAL
   --, [3050800495] AS R_UVA_PROMIS_29_PAIN_CHORES
   --, [3050800496] AS R_UVA_PROMIS_29_PAIN_1_10
   --, [3050800503] AS R_UVA_PROMIS_29_V2_PHYSICAL_FUNCTION_RAW
   --, [3050800504] AS R_UVA_PROMIS_29_V2_ANXIETY_RAW
   --, [3050800505] AS R_UVA_PROMIS_29_V2_DEPRESSION_RAW
   --, [3050800506] AS R_UVA_PROMIS_29_V2_FATIGUE_RAW
   --, [3050800507] AS R_UVA_PROMIS_29_V2_SLEEP_DISTURBANCE_RAW
   --, [3050800508] AS R_UVA_PROMIS_29_V2_SOCIAL_ROLES_RAW
   --, [3050800509] AS R_UVA_PROMIS_29_V2_PAIN_INTERFERENCE_RAW
   --, [3050800517] AS R_UVA_PROMIS_29_V2_PHYSICAL_FUNCTION_T_SCORE
   --, [3050800518] AS R_UVA_PROMIS_29_V2_ANXIETY_T_SCORE
   --, [3050800519] AS R_UVA_PROMIS_29_V2_DEPRESSION_T_SCORE
   --, [3050800520] AS R_UVA_PROMIS_29_V2_FATIGUE_T_SCORE
   --, [3050800521] AS R_UVA_PROMIS_29_V2_SLEEP_DISTURBANCE_T_SCORE
   --, [3050800522] AS R_UVA_PROMIS_29_V2_SOCIAL_ROLES_T_SCORE
   --, [3050800523] AS R_UVA_PROMIS_29_V2_PAIN_INTERFERENCE_T_SCORE
   , [305100278] AS R_UVA_CARD_HOME_ASSIST_LITTLE_INTEREST_OR_PLEASURE_IN_DOING_THINGS
   , [305100279] AS R_UVA_CARD_HOME_ASSIST_FEELING_DOWN_DEPRESSED
   , [305100280] AS R_UVA_CARD_HOME_ASSIST_TROUBLE_FALLING_ASLEEP
   , [305100281] AS R_UVA_CARD_HOME_ASSIST_TIRED_OR_NO_ENERGY
   , [305100282] AS R_UVA_CARD_HOME_ASSIST_POOR_APPETITE_OR_OVEREATING
   , [305100283] AS R_UVA_CARD_HOME_ASSIST_FEELING_BAD_ABOUT_SELF
   , [305100284] AS R_UVA_CARD_HOME_ASSIST_TROUBLE_CONCENTRATING
   , [305100285] AS R_UVA_CARD_HOME_ASSIST_SLOW_MOVING_OR_SPEAKING
   , [305100286] AS R_UVA_CARD_HOME_ASSIST_THINKING_OF_HURTING_SELF
   , [305100287] AS R_UVA_CARD_HOME_ASSIST_DEPRESSION_SCORE
   , [4403000020] AS R_UVA_PHQ9_SEVERITY_SCORE
  FROM
  (SELECT IDENTITY_ID
        , RECORDED_DATE
		, FLO_MEAS_ID
		, SUBSTRING(MEAS_VALUE,1,100) AS MEAS_VALUE
   FROM
  (
  SELECT DISTINCT
     pat.PAT_ID
	,pat.IDENTITY_ID
    ,flt.RECORDED_DATE
    ,flt.RECORDED_TIME
	,flt.FLT_ID
    ,flt.FLO_MEAS_ID
    ,ROW_NUMBER() OVER (PARTITION BY pat.PAT_ID, flt.RECORDED_DATE, flt.FLO_MEAS_ID ORDER BY flt.RECORDED_TIME DESC) AS SeqNbr
	,flt.FLO_MEAS_NAME
	,flt.DISP_NAME
	,flt.TEMPLATE_NAME
    ,flt.MEAS_VALUE
  FROM (
  SELECT DISTINCT
     PAT_ENC.PAT_ID
    ,CAST(PAT_ENC.APPT_TIME AS DATE) AS [Appt date]
	,PAT_ENC.APPT_TIME
    ,IDENTITY_ID.IDENTITY_ID --MRN
  FROM [dbo].[PAT_ENC] PAT_ENC
  INNER JOIN dbo.PATIENT PATIENT 
  ON PAT_ENC.PAT_ID = PATIENT.PAT_ID
  LEFT OUTER JOIN dbo.CLARITY_DEP CLARITY_DEP		
  ON PAT_ENC.DEPARTMENT_ID = CLARITY_DEP.DEPARTMENT_ID
  LEFT OUTER JOIN dbo.CLARITY_SER CLARITY_SER				
  ON PAT_ENC.VISIT_PROV_ID = CLARITY_SER.PROV_ID
  LEFT OUTER JOIN dbo.IDENTITY_ID IDENTITY_ID			
  ON IDENTITY_ID.PAT_ID = PAT_ENC.PAT_ID AND IDENTITY_ID.IDENTITY_TYPE_ID = 14
  WHERE
  (PAT_ENC.APPT_TIME IS NOT NULL AND PAT_ENC.APPT_TIME >= '7/1/2017 00:00:00')
  AND CLARITY_SER.PROV_NAME LIKE 'WAY, D%'
  ) pat
  INNER JOIN (SELECT
                 fr.PAT_ID
                ,CAST(fm.RECORDED_TIME AS DATE) AS RECORDED_DATE
                ,fm.RECORDED_TIME
                ,fm.MEAS_VALUE
                ,fm.FLT_ID
                ,fm.FLO_MEAS_ID
				,gp.FLO_MEAS_NAME
				,gp.DISP_NAME
	            ,ft.TEMPLATE_NAME
                ,fr.INPATIENT_DATA_ID
            FROM dbo.IP_FLWSHT_REC        AS fr WITH (NOLOCK)
            INNER JOIN dbo.IP_FLWSHT_MEAS AS fm WITH (NOLOCK) ON fr.FSD_ID      = fm.FSD_ID
            INNER JOIN dbo.IP_FLO_GP_DATA AS gp WITH (NOLOCK) ON fm.FLO_MEAS_ID = gp.FLO_MEAS_ID
		    LEFT OUTER JOIN dbo.IP_FLT_DATA ft WITH (NOLOCK) ON ft.TEMPLATE_ID = fm.FLT_ID
/*
TEMPLATE_ID	TEMPLATE_NAME	INT_FLO_MEAS_ID	FLT_ID	FLO_MEAS_NAME
2103700001	T UVA BEWELL INTAKE	2103701436	2103700001	R UVA AMB BEWELL MONTHLY PAIN LIFE IMPACT
3050300548	UVA (KOOS) KNEE INJURY AND OSTEOARTHRITIS OUTCOME SCORE (KOOS)	3050300600	3050300548	R UVA KOOS SCORE LIFESTYLE MODIFICATION
3050300548	UVA (KOOS) KNEE INJURY AND OSTEOARTHRITIS OUTCOME SCORE (KOOS)	3050300603	3050300548	R UVA KOOS SCORE QUALITY OF LIFE SCORE
2100800146	UVA AMB DEMP DSME RECORD	13498	2100800146	R INCORPORATING PHYSICAL ACTIVITY INTO LIFESTYLE
2104500007	UVA AMB PROMIS 10	2104500752	2104500007	R UVA AMB QUALITY LIFE
TEMPLATE_ID	TEMPLATE_NAME	INT_FLO_MEAS_ID	FLT_ID	FLO_MEAS_NAME	FLO_ROW_NAME	DISP_NAME
139	AMB ORT ASSESSMENT: MULTIPLE READINGS	1480	139	R ORT PAIN QUALITY: ADDITIONAL READING	NULL	Quality of Pain
2103700001	T UVA BEWELL INTAKE	2103701436	2103700001	R UVA AMB BEWELL MONTHLY PAIN LIFE IMPACT	NULL	How has the pain you have experienced in the last month affected your life?
3050300548	UVA (KOOS) KNEE INJURY AND OSTEOARTHRITIS OUTCOME SCORE (KOOS)	3050300600	3050300548	R UVA KOOS SCORE LIFESTYLE MODIFICATION	NULL	2.  How have you modified your lifestyle to avoid potentially damaging activities to your knee?	NULL	2
3050300548	UVA (KOOS) KNEE INJURY AND OSTEOARTHRITIS OUTCOME SCORE (KOOS)	3050300603	3050300548	R UVA KOOS SCORE QUALITY OF LIFE SCORE	NULL	Quality of LIfe Score	NULL	15
2100800146	UVA AMB DEMP DSME RECORD	13498	2100800146	R INCORPORATING PHYSICAL ACTIVITY INTO LIFESTYLE	NULL	Incorporating physical activity into lifestyle
2104500007	UVA AMB PROMIS 10	2104500752	2104500007	R UVA AMB QUALITY LIFE	NULL	In general, would you say your quality of life is:
2100700002	UVA ID HEPATITIS C DEPRESSION SCREENING	2100700014	2100700002	R UVA ID HEPC DEPRESSION LIFE HAD BEEN A FAILURE	NULL	I thought my life had been a failure
2100700002	UVA ID HEPATITIS C DEPRESSION SCREENING	2100700028	2100700002	R UVA ID HEPC DEPRESSION ENJOYED LIFE	NULL	I enjoyed life

3050800459	UVA PROMIS 29 V2	3050800468	3050800459	R UVA PROMIS 29 CHORES	NULL	Are you able to do chores such as vacuuming or yard work?
3050800459	UVA PROMIS 29 V2	3050800469	3050800459	R UVA PROMIS 29 STAIRS	NULL	Are you able to go up and down stairs at a normal pace?
3050800459	UVA PROMIS 29 V2	3050800470	3050800459	R UVA PROMIS 29 WALK	NULL	Are you able to go for a walk of at least 15 minutes?
3050800459	UVA PROMIS 29 V2	3050800471	3050800459	R UVA PROMIS 29 ERRANDS	NULL	Are you able to run errands and shop?
3050800459	UVA PROMIS 29 V2	3050800472	3050800459	R UVA PROMIS 29 FEARFUL	NULL	I felt fearful
3050800459	UVA PROMIS 29 V2	3050800473	3050800459	R UVA PROMIS 29 FOCUS	NULL	I found it hard to focus on anything other than my anxiety
3050800459	UVA PROMIS 29 V2	3050800474	3050800459	R UVA PROMIS 29 WORRIES	NULL	My worries overwhelmed me
3050800459	UVA PROMIS 29 V2	3050800475	3050800459	R UVA PROMIS 29 UNEASY	NULL	I felt uneasy
3050800459	UVA PROMIS 29 V2	3050800476	3050800459	R UVA PROMIS 29 WORTHLESS	NULL	I felt worthless
3050800459	UVA PROMIS 29 V2	3050800477	3050800459	R UVA PROMIS 29 HELPLESS	NULL	I felt helpless
3050800459	UVA PROMIS 29 V2	3050800478	3050800459	R UVA PROMIS 29 DEPRESSED	NULL	I felt depressed
3050800459	UVA PROMIS 29 V2	3050800479	3050800459	R UVA PROMIS 29 HOPELESS	NULL	I felt hopeless
3050800459	UVA PROMIS 29 V2	3050800480	3050800459	R UVA PROMIS 29 FATIGUED	NULL	I feel fatigued
3050800459	UVA PROMIS 29 V2	3050800481	3050800459	R UVA PROMIS 29 STARTING TASK	NULL	I have trouble starting things because I am tired
3050800459	UVA PROMIS 29 V2	3050800482	3050800459	R UVA PROMIS 29 RUN-DOWN	NULL	How run-down did you feel on average?
3050800459	UVA PROMIS 29 V2	3050800483	3050800459	R UVA PROMIS 29 AVERAGE FATIGUED	NULL	How fatigued were you on average?
3050800459	UVA PROMIS 29 V2	3050800484	3050800459	R UVA PROMIS 29 SLEEP QUALITY	NULL	My sleep quality was
3050800459	UVA PROMIS 29 V2	3050800485	3050800459	R UVA PROMIS 29 SLEEP REFRESHING	NULL	My sleep was refreshing
3050800459	UVA PROMIS 29 V2	3050800486	3050800459	R UVA PROMIS 29 SLEEP PROBLEM	NULL	I had a problem with my sleep
3050800459	UVA PROMIS 29 V2	3050800487	3050800459	R UVA PROMIS 29 FALLING ASLEEP	NULL	I had difficulty falling asleep
3050800459	UVA PROMIS 29 V2	3050800488	3050800459	R UVA PROMIS 29 LEISURE ACTIVITIES	NULL	I have trouble doing all of my regular leisure activities with others
3050800459	UVA PROMIS 29 V2	3050800489	3050800459	R UVA PROMIS 29 FAMILY ACTIVITIES	NULL	I have trouble doing all of the family activities that I want to do
3050800459	UVA PROMIS 29 V2	3050800490	3050800459	R UVA PROMIS 29 WORK	NULL	I have trouble doing all of my usual work (include work at home)
3050800459	UVA PROMIS 29 V2	3050800491	3050800459	R UVA PROMIS 29 ALL ACTIVITIES	NULL	I have trouble doing all of the activities with friends that I want to do
3050800459	UVA PROMIS 29 V2	3050800492	3050800459	R UVA PROMIS 29 PAIN DAY TO DAY	NULL	How much did pain interfere with your day to day activities?
3050800459	UVA PROMIS 29 V2	3050800493	3050800459	R UVA PROMIS 29 PAIN WORK	NULL	How much did pain interfere with work around the home?
3050800459	UVA PROMIS 29 V2	3050800494	3050800459	R UVA PROMIS 29 PAIN SOCIAL	NULL	How much did pain interfere with your ability to participate in social activities?
3050800459	UVA PROMIS 29 V2	3050800495	3050800459	R UVA PROMIS 29 PAIN CHORES	NULL	How much did pain interfere with your household chores?
3050800459	UVA PROMIS 29 V2	3050800496	3050800459	R UVA PROMIS 29 PAIN 1-10	NULL	How would you rate your pain on average?
3050800459	UVA PROMIS 29 V2	3050800503	3050800459	R UVA PROMIS 29 V2 PHYSICAL FUNCTION RAW	NULL	Raw Score
3050800459	UVA PROMIS 29 V2	3050800504	3050800459	R UVA PROMIS 29 V2 ANXIETY RAW	NULL	Raw Score
3050800459	UVA PROMIS 29 V2	3050800505	3050800459	R UVA PROMIS 29 V2 DEPRESSION RAW	NULL	Raw Score
3050800459	UVA PROMIS 29 V2	3050800506	3050800459	R UVA PROMIS 29 V2 FATIGUE RAW	NULL	Raw Score
3050800459	UVA PROMIS 29 V2	3050800507	3050800459	R UVA PROMIS 29 V2 SLEEP DISTURBANCE RAW	NULL	Raw Score
3050800459	UVA PROMIS 29 V2	3050800508	3050800459	R UVA PROMIS 29 V2 SOCIAL ROLES RAW	NULL	Raw Score
3050800459	UVA PROMIS 29 V2	3050800509	3050800459	R UVA PROMIS 29 V2 PAIN INTERFERENCE RAW	NULL	Raw Score
3050800459	UVA PROMIS 29 V2	3050800517	3050800459	R UVA PROMIS 29 V2 PHYSICAL FUNCTION T- SCORE	NULL	Physical Function t-Scale Score
3050800459	UVA PROMIS 29 V2	3050800518	3050800459	R UVA PROMIS 29 V2 ANXIETY T- SCORE	NULL	Anxiety t-Scale Score
3050800459	UVA PROMIS 29 V2	3050800519	3050800459	R UVA PROMIS 29 V2 DEPRESSION T- SCORE	NULL	Depression t-Scale Score
3050800459	UVA PROMIS 29 V2	3050800520	3050800459	R UVA PROMIS 29 V2 FATIGUE T- SCORE	NULL	Fatigue t-Scale Score
3050800459	UVA PROMIS 29 V2	3050800521	3050800459	R UVA PROMIS 29 V2 SLEEP DISTURBANCE T- SCORE	NULL	Sleep Disturbance t-Scale Score
3050800459	UVA PROMIS 29 V2	3050800522	3050800459	R UVA PROMIS 29 V2 SOCIAL ROLES T- SCORE	NULL	Social Roles t-Scale Score
3050800459	UVA PROMIS 29 V2	3050800523	3050800459	R UVA PROMIS 29 V2 PAIN INTERFERENCE T- SCORE	NULL	Pain Interference t-Scale Score

479	UVA IP AMB HOD DEPRESSION SCREENING	4403000020	479	R UVA PHQ9 SEVERITY SCORE	NULL	PHQ-9 Depression Severity
2100300004	UVA AMB VITALS SIMPLE	3531	2100300004	R UVA IP PAIN DESCRIPTORS	NULL	Pain Descriptors 1
2100300004	UVA AMB VITALS SIMPLE	301090	2100300004	R UVA PAIN BODY LOCATION 1	NULL	Pain Location
2100300004	UVA AMB VITALS SIMPLE	3040100009	2100300004	R UVA PAIN TYPE 1	NULL	Pain Type
*/
            WHERE
			      (fm.FLO_MEAS_ID IN (
                            '1480', -- R ORT PAIN QUALITY: ADDITIONAL READING,Quality of Pain
							'3531', -- R UVA IP PAIN DESCRIPTORS,Pain Descriptors 1
                            '3541', -- R UVA PAIN ASSESSMENT,Pain Scale Used
                            '13498', -- R INCORPORATING PHYSICAL ACTIVITY INTO LIFESTYLE,Incorporating physical activity into lifestyle
							'301090', -- R UVA PAIN BODY LOCATION 1	NULL,Pain Location
                            '400290', -- R HAVE PAIN NOW,Patient Currently in Pain
                            '2100700014', -- R UVA ID HEPC DEPRESSION LIFE HAD BEEN A FAILURE,I thought my life had been a failure
                            '2100700028', -- R UVA ID HEPC DEPRESSION ENJOYED LIFE,I enjoyed life
                            '2103700557', -- R UVA AMB GAD7 SCORE NERVOUS ANXIOUS ON EDGE,1. Feeling nervous, anxious or on edge
                            '2103700585', -- R UVA AMB GAD7 SCORE CONTROL WORRYING,2. Not being able to stop or control worrying
                            '2103700586', -- R UVA AMB GAD7 SCORE WORRYING ABOUT DIF THINGS,3. Worrying too much about different things
                            '2103700587', -- R UVA AMB GAD7 SCORE TROUBLE RELAXING,4. Trouble relaxing
                            '2103700588', -- R UVA AMB GAD7 SCORE RESTLESS CANT SIT STILL,5. Being so restless that it is hard to sit still
                            '2103700589', -- R UVA AMB GAD7 SCORE EASILY ANNOYED IRRITABLE,6. Becoming easily annoyed or irritable
                            '2103700757', -- R UVA AMB GAD7 SCORE AFRAID,7. Feeling afraid as if something awful might happen
                            '2103700758', -- R UVA AMB GAD7 TOTAL SCORE,For office coding: Total Score
                            '2103700759', -- R UVA AMB GAD7 SCORE HOW DIFFICULT ARE PROBLEMS,8. If you checked off any problems, how difficult have these problems made it for you to do your work, take care of things at home, or get along with other people?
                            '2103701436', -- R UVA AMB BEWELL MONTHLY PAIN LIFE IMPACT,How has the pain you have experienced in the last month affected your life?
                            '2104500752', -- R UVA AMB QUALITY LIFE,In general, would you say your quality of life is:
							'3040100009', -- R UVA PAIN TYPE 1,Pain Type
                            '3050000397', -- R UVA PAIN RATING SCALE 1,Pain Rating
                            '3050300600', -- R UVA KOOS SCORE LIFESTYLE MODIFICATION,2.  How have you modified your lifestyle to avoid potentially damaging activities to your knee?
                            '3050300603', -- R UVA KOOS SCORE QUALITY OF LIFE SCORE,Quality of LIfe Score
                            '3050600047', -- R UVA IP AMB HOD DEPRESSION SCREEN - PHQ 2 SCORE,PHQ 2 Score (If 3 or more, fill out the PHQ-9 questions below)
                            '3050600180', -- R UVA IP AMB HOD DEPRESSION SCREEN - HOW DIFFICULT ARE PROBLEMS,10 - If you checked off any problems, how difficult have these problems made it for you to do your work, take care of things at home, or get along with other people?
							'3050800468', -- R UVA PROMIS 29 CHORES,Are you able to do chores such as vacuuming or yard work?
							'3050800469', -- R UVA PROMIS 29 STAIRS,Are you able to go up and down stairs at a normal pace?
							'3050800470', -- R UVA PROMIS 29 WALK,Are you able to go for a walk of at least 15 minutes?
							'3050800471', -- R UVA PROMIS 29 ERRANDS,Are you able to run errands and shop?
							'3050800472', -- R UVA PROMIS 29 FEARFUL,I felt fearful
							'3050800473', -- R UVA PROMIS 29 FOCUS,I found it hard to focus on anything other than my anxiety
							'3050800474', -- R UVA PROMIS 29 WORRIES,My worries overwhelmed me
							'3050800475', -- R UVA PROMIS 29 UNEASY,I felt uneasy
							'3050800476', -- R UVA PROMIS 29 WORTHLESS,I felt worthless
							'3050800477', -- R UVA PROMIS 29 HELPLESS,I felt helpless
							'3050800478', -- R UVA PROMIS 29 DEPRESSED,I felt depressed
							'3050800479', -- R UVA PROMIS 29 HOPELESS,I felt hopeless
							'3050800480', -- R UVA PROMIS 29 FATIGUED,I feel fatigued
							'3050800481', -- R UVA PROMIS 29 STARTING TASK,I have trouble starting things because I am tired
							'3050800482', -- R UVA PROMIS 29 RUN-DOWN,How run-down did you feel on average?
							'3050800483', -- R UVA PROMIS 29 AVERAGE FATIGUED,How fatigued were you on average?
							'3050800484', -- R UVA PROMIS 29 SLEEP QUALITY,My sleep quality was
							'3050800485', -- R UVA PROMIS 29 SLEEP REFRESHING,My sleep was refreshing
							'3050800486', -- R UVA PROMIS 29 SLEEP PROBLEM,I had a problem with my sleep
							'3050800487', -- R UVA PROMIS 29 FALLING ASLEEP,I had difficulty falling asleep
							'3050800488', -- R UVA PROMIS 29 LEISURE ACTIVITIES,I have trouble doing all of my regular leisure activities with others
							'3050800489', -- R UVA PROMIS 29 FAMILY ACTIVITIES,I have trouble doing all of the family activities that I want to do
							'3050800490', -- R UVA PROMIS 29 WORK,I have trouble doing all of my usual work (include work at home)
							'3050800491', -- R UVA PROMIS 29 ALL ACTIVITIES,I have trouble doing all of the activities with friends that I want to do
							'3050800492', -- R UVA PROMIS 29 PAIN DAY TO DAY,How much did pain interfere with your day to day activities?
							'3050800493', -- R UVA PROMIS 29 PAIN WORK,How much did pain interfere with work around the home?
							'3050800494', -- R UVA PROMIS 29 PAIN SOCIAL,How much did pain interfere with your ability to participate in social activities?
							'3050800495', -- R UVA PROMIS 29 PAIN CHORES,How much did pain interfere with your household chores?
							'3050800496', -- R UVA PROMIS 29 PAIN 1-10,How would you rate your pain on average?
							'3050800503', -- R UVA PROMIS 29 V2 PHYSICAL FUNCTION RAW,Raw Score
							'3050800504', -- R UVA PROMIS 29 V2 ANXIETY RAW,Raw Score
							'3050800505', -- R UVA PROMIS 29 V2 DEPRESSION RAW,Raw Score
							'3050800506', -- R UVA PROMIS 29 V2 FATIGUE RAW,Raw Score
							'3050800507', -- R UVA PROMIS 29 V2 SLEEP DISTURBANCE RAW,Raw Score
							'3050800508', -- R UVA PROMIS 29 V2 SOCIAL ROLES RAW,Raw Score
							'3050800509', -- R UVA PROMIS 29 V2 PAIN INTERFERENCE RAW,Raw Score
							'3050800517', -- R UVA PROMIS 29 V2 PHYSICAL FUNCTION T- SCORE,Physical Function t-Scale Score
							'3050800518', -- R UVA PROMIS 29 V2 ANXIETY T- SCORE,Anxiety t-Scale Score
							'3050800519', -- R UVA PROMIS 29 V2 DEPRESSION T- SCORE,Depression t-Scale Score
							'3050800520', -- R UVA PROMIS 29 V2 FATIGUE T- SCORE,Fatigue t-Scale Score
							'3050800521', -- R UVA PROMIS 29 V2 SLEEP DISTURBANCE T- SCORE,Sleep Disturbance t-Scale Score
							'3050800522', -- R UVA PROMIS 29 V2 SOCIAL ROLES T- SCORE,Social Roles t-Scale Score
							'3050800523', -- R UVA PROMIS 29 V2 PAIN INTERFERENCE T- SCORE,Pain Interference t-Scale Score
                            '305100278', -- R UVA CARD HOME ASSIST - LITTLE INTEREST OR PLEASURE IN DOING THINGS,1 - In the last two weeks, have you had little interest or pleasure in doing things
                            '305100279', -- R UVA CARD HOME ASSIST - FEELING DOWN, DEPRESSED,2 - In the last two weeks, have you been feeling down, depressed or hopeless?
                            '305100280', -- R UVA CARD HOME ASSIST - TROUBLE FALLING ASLEEP,3 - Trouble falling or staying asleep or sleeping too much?
                            '305100281', -- R UVA CARD HOME ASSIST - TIRED OR NO ENERGY,4 - Feeling tired or having little energy
                            '305100282', -- R UVA CARD HOME ASSIST - POOR APPETITE OR OVEREATING,5 - Poor appetite or overeating
                            '305100283', -- R UVA CARD HOME ASSIST - FEELING BAD ABOUT SELF,6 - Feeling bad about self, are a failure, or have let self/family down
                            '305100284', -- R UVA CARD HOME ASSIST - TROUBLE CONCENTRATING,7 - Trouble concentrating on things like the newspaper or TV
                            '305100285', -- R UVA CARD HOME ASSIST - SLOW MOVING OR SPEAKIND,8 - Moving or speaking noticeably slower or restless/fidgety more than usual
                            '305100286', -- R UVA CARD HOME ASSIST - THINKING OF HURTING SELF,9 - Thoughts that you would be better off dead or of hurting self in some way
                            '305100287', -- R UVA CARD HOME ASSIST - DEPRESSION SCORE,Total Depression Score
							'4403000020' -- R UVA PHQ9 SEVERITY SCORE,PHQ-9 Depression Severity
				                     )
			      )
				  AND fm.MEAS_VALUE IS NOT NULL
             ) flt
  ON pat.PAT_ID = flt.PAT_ID) FLT
  WHERE SeqNbr = 1) FlwSht
  PIVOT
  (
  MAX(MEAS_VALUE)
  FOR FLO_MEAS_ID IN (
                            [1480], -- R ORT PAIN QUALITY: ADDITIONAL READING,Quality of Pain
							[3531], -- R UVA IP PAIN DESCRIPTORS,Pain Descriptors 1
                            [3541], -- R UVA PAIN ASSESSMENT,Pain Scale Used
                            [13498], -- R INCORPORATING PHYSICAL ACTIVITY INTO LIFESTYLE,Incorporating physical activity into lifestyle
							[301090], -- R UVA PAIN BODY LOCATION 1	NULL,Pain Location
                            [400290], -- R HAVE PAIN NOW,Patient Currently in Pain
                            [2100700014], -- R UVA ID HEPC DEPRESSION LIFE HAD BEEN A FAILURE,I thought my life had been a failure
                            [2100700028], -- R UVA ID HEPC DEPRESSION ENJOYED LIFE,I enjoyed life]
                            [2103700557], -- R UVA AMB GAD7 SCORE NERVOUS ANXIOUS ON EDGE,1. Feeling nervous, anxious or on edge
                            [2103700585], -- R UVA AMB GAD7 SCORE CONTROL WORRYING,2. Not being able to stop or control worrying
                            [2103700586], -- R UVA AMB GAD7 SCORE WORRYING ABOUT DIF THINGS,3. Worrying too much about different things
                            [2103700587], -- R UVA AMB GAD7 SCORE TROUBLE RELAXING,4. Trouble relaxing
                            [2103700588], -- R UVA AMB GAD7 SCORE RESTLESS CANT SIT STILL,5. Being so restless that it is hard to sit still
                            [2103700589], -- R UVA AMB GAD7 SCORE EASILY ANNOYED IRRITABLE,6. Becoming easily annoyed or irritable
                            [2103700757], -- R UVA AMB GAD7 SCORE AFRAID,7. Feeling afraid as if something awful might happen
                            [2103700758], -- R UVA AMB GAD7 TOTAL SCORE,For office coding: Total Score
                            [2103700759], -- R UVA AMB GAD7 SCORE HOW DIFFICULT ARE PROBLEMS,8. If you checked off any problems, how difficult have these problems made it for you to do your work, take care of things at home, or get along with other people?
							[2103701436], -- R UVA AMB BEWELL MONTHLY PAIN LIFE IMPACT,How has the pain you have experienced in the last month affected your life?
                            [2104500752], -- R UVA AMB QUALITY LIFE,In general, would you say your quality of life is:
							[3040100009], -- R UVA PAIN TYPE 1,Pain Type
                            [3050000397], -- R UVA PAIN RATING SCALE 1,Pain Rating
							[3050300600], -- R UVA KOOS SCORE LIFESTYLE MODIFICATION,2.  How have you modified your lifestyle to avoid potentially damaging activities to your knee?
                            [3050300603], -- R UVA KOOS SCORE QUALITY OF LIFE SCORE,Quality of LIfe Score
                            [3050600047], -- R UVA IP AMB HOD DEPRESSION SCREEN - PHQ 2 SCORE,PHQ 2 Score (If 3 or more, fill out the PHQ-9 questions below)
                            [3050600180], -- R UVA IP AMB HOD DEPRESSION SCREEN - HOW DIFFICULT ARE PROBLEMS,10 - If you checked off any problems, how difficult have these problems made it for you to do your work, take care of things at home, or get along with other people?
							[3050800468], -- R UVA PROMIS 29 CHORES,Are you able to do chores such as vacuuming or yard work?
							[3050800469], -- R UVA PROMIS 29 STAIRS,Are you able to go up and down stairs at a normal pace?
							[3050800470], -- R UVA PROMIS 29 WALK,Are you able to go for a walk of at least 15 minutes?
							[3050800471], -- R UVA PROMIS 29 ERRANDS,Are you able to run errands and shop?
							[3050800472], -- R UVA PROMIS 29 FEARFUL,I felt fearful
							[3050800473], -- R UVA PROMIS 29 FOCUS,I found it hard to focus on anything other than my anxiety
							[3050800474], -- R UVA PROMIS 29 WORRIES,My worries overwhelmed me
							[3050800475], -- R UVA PROMIS 29 UNEASY,I felt uneasy
							[3050800476], -- R UVA PROMIS 29 WORTHLESS,I felt worthless
							[3050800477], -- R UVA PROMIS 29 HELPLESS,I felt helpless
							[3050800478], -- R UVA PROMIS 29 DEPRESSED,I felt depressed
							[3050800479], -- R UVA PROMIS 29 HOPELESS,I felt hopeless
							[3050800480], -- R UVA PROMIS 29 FATIGUED,I feel fatigued
							[3050800481], -- R UVA PROMIS 29 STARTING TASK,I have trouble starting things because I am tired
							[3050800482], -- R UVA PROMIS 29 RUN-DOWN,How run-down did you feel on average?
							[3050800483], -- R UVA PROMIS 29 AVERAGE FATIGUED,How fatigued were you on average?
							[3050800484], -- R UVA PROMIS 29 SLEEP QUALITY,My sleep quality was
							[3050800485], -- R UVA PROMIS 29 SLEEP REFRESHING,My sleep was refreshing
							[3050800486], -- R UVA PROMIS 29 SLEEP PROBLEM,I had a problem with my sleep
							[3050800487], -- R UVA PROMIS 29 FALLING ASLEEP,I had difficulty falling asleep
							[3050800488], -- R UVA PROMIS 29 LEISURE ACTIVITIES,I have trouble doing all of my regular leisure activities with others
							[3050800489], -- R UVA PROMIS 29 FAMILY ACTIVITIES,I have trouble doing all of the family activities that I want to do
							[3050800490], -- R UVA PROMIS 29 WORK,I have trouble doing all of my usual work (include work at home)
							[3050800491], -- R UVA PROMIS 29 ALL ACTIVITIES,I have trouble doing all of the activities with friends that I want to do
							[3050800492], -- R UVA PROMIS 29 PAIN DAY TO DAY,How much did pain interfere with your day to day activities?
							[3050800493], -- R UVA PROMIS 29 PAIN WORK,How much did pain interfere with work around the home?
							[3050800494], -- R UVA PROMIS 29 PAIN SOCIAL,How much did pain interfere with your ability to participate in social activities?
							[3050800495], -- R UVA PROMIS 29 PAIN CHORES,How much did pain interfere with your household chores?
							[3050800496], -- R UVA PROMIS 29 PAIN 1-10,How would you rate your pain on average?
							[3050800503], -- R UVA PROMIS 29 V2 PHYSICAL FUNCTION RAW,Raw Score
							[3050800504], -- R UVA PROMIS 29 V2 ANXIETY RAW,Raw Score
							[3050800505], -- R UVA PROMIS 29 V2 DEPRESSION RAW,Raw Score
							[3050800506], -- R UVA PROMIS 29 V2 FATIGUE RAW,Raw Score
							[3050800507], -- R UVA PROMIS 29 V2 SLEEP DISTURBANCE RAW,Raw Score
							[3050800508], -- R UVA PROMIS 29 V2 SOCIAL ROLES RAW,Raw Score
							[3050800509], -- R UVA PROMIS 29 V2 PAIN INTERFERENCE RAW,Raw Score
							[3050800517], -- R UVA PROMIS 29 V2 PHYSICAL FUNCTION T- SCORE,Physical Function t-Scale Score
							[3050800518], -- R UVA PROMIS 29 V2 ANXIETY T- SCORE,Anxiety t-Scale Score
							[3050800519], -- R UVA PROMIS 29 V2 DEPRESSION T- SCORE,Depression t-Scale Score
							[3050800520], -- R UVA PROMIS 29 V2 FATIGUE T- SCORE,Fatigue t-Scale Score
							[3050800521], -- R UVA PROMIS 29 V2 SLEEP DISTURBANCE T- SCORE,Sleep Disturbance t-Scale Score
							[3050800522], -- R UVA PROMIS 29 V2 SOCIAL ROLES T- SCORE,Social Roles t-Scale Score
							[3050800523], -- R UVA PROMIS 29 V2 PAIN INTERFERENCE T- SCORE,Pain Interference t-Scale Score
                            [305100278], -- R UVA CARD HOME ASSIST - LITTLE INTEREST OR PLEASURE IN DOING THINGS,1 - In the last two weeks, have you had little interest or pleasure in doing things
                            [305100279], -- R UVA CARD HOME ASSIST - FEELING DOWN, DEPRESSED,2 - In the last two weeks, have you been feeling down, depressed or hopeless?
                            [305100280], -- R UVA CARD HOME ASSIST - TROUBLE FALLING ASLEEP,3 - Trouble falling or staying asleep or sleeping too much?
                            [305100281], -- R UVA CARD HOME ASSIST - TIRED OR NO ENERGY,4 - Feeling tired or having little energy
                            [305100282], -- R UVA CARD HOME ASSIST - POOR APPETITE OR OVEREATING,5 - Poor appetite or overeating
                            [305100283], -- R UVA CARD HOME ASSIST - FEELING BAD ABOUT SELF,6 - Feeling bad about self, are a failure, or have let self/family down
                            [305100284], -- R UVA CARD HOME ASSIST - TROUBLE CONCENTRATING,7 - Trouble concentrating on things like the newspaper or TV
                            [305100285], -- R UVA CARD HOME ASSIST - SLOW MOVING OR SPEAKIND,8 - Moving or speaking noticeably slower or restless/fidgety more than usual
                            [305100286], -- R UVA CARD HOME ASSIST - THINKING OF HURTING SELF,9 - Thoughts that you would be better off dead or of hurting self in some way
                            [305100287], -- R UVA CARD HOME ASSIST - DEPRESSION SCORE,Total Depression Score
							[4403000020] -- R UVA PHQ9 SEVERITY SCORE,PHQ-9 Depression Severity
			         )
  ) AS PivotTable
  ORDER BY PivotTable.IDENTITY_ID
         , PivotTable.RECORDED_DATE