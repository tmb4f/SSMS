USE CLARITY

-- LEV are Patient Events:      Event Template records store details about each event template that can be used to record an event in Hyperspace, including the event's name, abbreviation, and template class. Each template record defines the events that can be recorded and, unlike event records, is not patient-specific. Examples of template records include assigning a bed, placing an order, and printing a patient's After Visit Summary (AVS).
-- IEV are Appointment Events:  Events records store information about the events that are recorded for each patient, including the date and time at which each event was recorded, the user who recorded each event, and the event type of each event. Each type of event that can occur has a corresponding event template (LEV) record.

DROP TABLE IF EXISTS #CSNs

--Get Sample
--SELECT TOP 100 PAT_ENC_CSN_ID
SELECT DISTINCT
    PAT_ENC_CSN_ID
   ,DEPARTMENT_ID
   ,DEPARTMENT_NAME
    INTO #CSNs
FROM V_SCHED_APPT 
WHERE   1=1
    --AND LOC_ID = '10354'
    --AND DEPARTMENT_ID = '10354014'
	AND DEPARTMENT_ID IN (
	10379001
,10379900
,10242051
,10242052
,10243003
,10243087
,10243121
,10243911
)
    --AND PROV_ID = '8'
    AND CONTACT_DATE BETWEEN '2023-7-1' AND '2023-8-17'
    AND APPT_STATUS_C = 2
;

--Get V_SCHED_APPT Details for sample
--SELECT vsa.* 
--FROM V_SCHED_APPT vsa
--    INNER JOIN #CSNs csn   ON vsa.PAT_ENC_CSN_ID = csn.PAT_ENC_CSN_ID
--ORDER BY CONTACT_DATE
--;

--Get Event Details for sample
WITH cte AS (
SELECT --TOP 100
      loc.LOC_NAME
	, csns.DEPARTMENT_ID
	, csns.DEPARTMENT_NAME
    , ievpat.       PAT_ID
    , ievpat.       PAT_ENC_CSN_ID
    , ievpat.       TYPE_ID             AS TYPE_ID_pat                      -- Type of event template, joins to template
    , ievpat.       EVENT_ID            AS EVENT_ID_pat

    , ievevent.     EVENT_TYPE          AS EVENT_TYPE_iev                   -- Also joins to template
    , ievevent.     EVENT_ID            AS EVENT_ID_iev
    , ievevent.     EVENT_DISPLAY_NAME  AS EVENT_DISPLAY_NAME_iev
    , ievevent.     LINE                AS LINE_iev                
    , ievevent.     EVENT_TIME          AS EVENT_TIME_iev 
	, emp.NAME AS EMP_NAME
	, emp.PROV_ID AS EMP_PROV_ID
	, ser.PROV_NAME

    , templt_iev.   RECORD_ID           AS RECORD_ID_iev
    , templt_iev.   RECORD_NAME         AS RECORD_NAME_iev
    , templt_iev.   EVENT_NAME          AS EVENT_NAME_iev
    --, templt_iev.   DISPLAY_NAME        AS DISPLAY_NAME_iev

    , levclass_iev. EVT_TMPLT_CLASS_C   AS EVT_TMPLT_CLASS_C_iev
    , zcclass_iev.  NAME                AS EVT_TMPLT_CLASS_C_name_iev

    , templt_pat.   RECORD_ID           AS RECORD_ID_pat
    , templt_pat.   RECORD_NAME         AS RECORD_NAME_pat
    , templt_pat.   EVENT_NAME          AS EVENT_NAME_pat
    --, templt_pat.   DISPLAY_NAME        AS DISPLAY_NAME_pat

    , levclass_pat. EVT_TMPLT_CLASS_C   AS EVT_TMPLT_CLASS_C_pat
    , zcclass_pat.  NAME                AS EVT_TMPLT_CLASS_C_name_pat
                                       
        
FROM  ED_IEV_PAT_INFO       ievpat
    LEFT JOIN ED_IEV_EVENT_INFO     ievevent            ON  ievpat.EVENT_ID     =   ievevent.EVENT_ID            
    LEFT JOIN ED_EVENT_TMPL_INFO    templt_iev          ON                          ievevent.EVENT_TYPE         =  templt_iev.RECORD_ID  --IEV.30
    LEFT JOIN ED_LEV_EVENT_INFO		levclass_iev        ON                                                         templt_iev.RECORD_ID     =   levclass_iev.RECORD_ID
	LEFT JOIN ZC_EVT_TMPLT_CLASS	zcclass_iev		    ON                                                                                      levclass_iev.EVT_TMPLT_CLASS_C	= zcclass_iev.EVT_TMPLT_CLASS_C
    LEFT JOIN ED_EVENT_TMPL_INFO    templt_pat          ON  ievpat.TYPE_ID                                      =  templt_pat.RECORD_ID  --IEV.31
    LEFT JOIN ED_LEV_EVENT_INFO		levclass_pat        ON                                                         templt_pat.RECORD_ID     =   levclass_pat.RECORD_ID
    LEFT JOIN ZC_EVT_TMPLT_CLASS	zcclass_pat	        ON                                                                                      levclass_pat.EVT_TMPLT_CLASS_C	= zcclass_pat.EVT_TMPLT_CLASS_C
	LEFT JOIN CLARITY_EMP emp ON emp.USER_ID = ievevent.EVENT_USER_ID
	LEFT JOIN CLARITY_SER ser ON ser.PROV_ID = emp.PROV_ID
	LEFT JOIN CLARITY_LOC loc ON loc.LOC_ID = ievevent.LOCATION_ID
   
    INNER JOIN #CSNs                csns                ON ievpat.PAT_ENC_CSN_ID = csns.PAT_ENC_CSN_ID
       
WHERE 1=1
--AND levclass_iev.EVT_TMPLT_CLASS_C IN (30, 56009)     -- For Type='Physician In'
--AND ievpat.PAT_ENC_CSN_ID = '200003589799'
AND ievevent.EVENT_DISPLAY_NAME LIKE '%Room%'
--AND ievevent.EVENT_TYPE IN ('601', '602', '40000') -- Start Rooming, Done Rooming, Assign to Room
)

--------------------    Query 1
/*
SELECT
        cte.DEPARTMENT_ID
    ,   cte.DEPARTMENT_NAME
    ,   PAT_ID
    ,   PAT_ENC_CSN_ID
    ,   EVENT_TYPE_iev
    ,   EVENT_DISPLAY_NAME_iev
	,   cte.EMP_NAME
    ,   LINE_iev
    ,   EVENT_TIME_iev
    ,   TYPE_ID_pat
    ,   EVENT_ID_pat
    ,   EVT_TMPLT_CLASS_C_iev
    ,   EVT_TMPLT_CLASS_C_name_iev
	,  cte.EMP_PROV_ID
	,  cte.PROV_NAME
    ,   cte.EVT_TMPLT_CLASS_C_pat
    ,   EVT_TMPLT_CLASS_C_name_pat
FROM cte
--ORDER BY
--        PAT_ID
--    ,   PAT_ENC_CSN_ID
--    ,   EVENT_TIME_iev
--    ,   EVENT_ID_pat
--    ,   LINE_iev
ORDER BY
        cte.DEPARTMENT_NAME
    ,   PAT_ID
    ,   PAT_ENC_CSN_ID
    ,   EVENT_TIME_iev
    ,   EVENT_ID_pat
    ,   LINE_iev
*/

SELECT DISTINCT
	cte.EVENT_TYPE_iev,
    cte.EVENT_DISPLAY_NAME_iev
FROM cte
ORDER BY cte.EVENT_TYPE_iev

;
