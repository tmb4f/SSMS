 USE CLARITY
 GO
 
 DECLARE @p_DateStart DATETIME = '2022-10-01',
 @p_DateEnd DATETIME = '2022-11-10'


SELECT a.MYPT_ID,
a.UA_PERSON_TYPE_C,
pt.NAME AS UA_PERSON_TYPE_NAME,
a.UA_SESSION_NUM,
a.UA_DTTM AS SESSION_DATE,
a.LINE,
p.PAT_ID,
P.PAT_NAME,
p2.PAT_MRN_ID,
a.MYC_UA_TYPE_C,
t.NAME AS MYC_UA_TYPE_NAME,
pcp.PROV_ID AS PRIMARY_CARE_PROVIDER_ID,
pcp.PROV_NAME AS PRIMARY_CARE_PROVIDER,
--MIN (a.UA_DTTM) AS SESSION_DATE,
--MAX(CASE WHEN a.UA_EXTENDED_INFO = 'E-Visit Configuration Loaded' THEN 1 
--	ELSE 0 
--	END) AS EVISIT_START_COUNT,
--MAX(CASE WHEN a.UA_EXTENDED_INFO = 'E-Visit - Submitted' THEN 1 
--	ELSE 0 
--	END) AS EVISIT_SUBMIT_COUNT
a.UA_EXTENDED_INFO

FROM CLARITY.dbo.V_MYC_PT_USER_ACCSS a WITH(NOLOCK) LEFT JOIN --V_MYC_PT_USER_ACCSS (MYC_PT_USER_ACCSS) used for audit tracking of patient actions in mychart, sessions can be grouped using the UA_SESSION_NUM
CLARITY.dbo.ZC_MYC_UA_TYPE t WITH(NOLOCK) ON t.MYC_UA_TYPE_C = a.MYC_UA_TYPE_C LEFT JOIN -- MYC_UA_TYPE_C tracks activity or section user is interacting with, used this join to filter to E-Visits
CLARITY.dbo.ZC_UA_PERSON_TYPE pt WITH(NOLOCK) ON pt.UA_PERSON_TYPE_C = a.UA_PERSON_TYPE_C LEFT JOIN
CLARITY.dbo.MYC_PATIENT p WITH(NOLOCK) ON a.MYPT_ID = p.MYPT_ID LEFT JOIN --MYC_Patient is Patient's Mychart basic info 
CLARITY.dbo.PATIENT p2 WITH(NOLOCK) ON p.PAT_ID = p2.PAT_ID  LEFT JOIN -- You can join a MYC_Patient record to a patient record
CLARITY.dbo.CLARITY_SER pcp ON p2.CUR_PCP_PROV_ID = pcp.PROV_ID -- FInd the patient's PCP
--WHERE
--t.NAME = 'EVisit'
-- Date filter. Expanding the range to catch sessions that are in the range, but partially extend past it. 
AND a.UA_DTTM >= DATEADD(DAY, -1, @p_DateStart) 
AND a.UA_DTTM < DATEADD(DAY, +2, @p_DateEnd) 
--GROUP BY a.UA_SESSION_NUM, a.MYPT_ID, a.MYC_UA_TYPE_C, t.NAME,pcp.PROV_ID, pcp.PROV_NAME, p.PAT_ID, P.PAT_NAME, p2.PAT_MRN_ID
--Further filtering to only include sessions that started within our range.
--HAVING MIN(a.UA_DTTM) >= @p_DateStart AND  
--	   MIN(a.UA_DTTM) <	DATEADD(DAY, +1, @p_DateEnd)
WHERE a.UA_DTTM >= @p_DateStart AND  
	   a.UA_DTTM <	DATEADD(DAY, +1, @p_DateEnd)
--ORDER BY MIN (a.UA_DTTM), P.PAT_NAME
ORDER BY a.MYPT_ID, a.UA_SESSION_NUM, a.LINE, a.UA_DTTM