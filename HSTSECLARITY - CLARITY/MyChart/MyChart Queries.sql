 /*
This query was used to get information on failed password resets and login attempts for HIT Managers
*/

 USE CLARITY
 GO

SELECT p.mypt_id AS MyChartID, 
p.PAT_ID AS PatientID, 
--p.MYC_STATUS_C,  
p.LAST_LOGIN_TIME,
p.LAST_ACCESS_TIME,
p.LAST_PW_CHANGE AS Last_PW_Change, 
p.FORCE_PWD_CHG_YN AS Force_PW_Change, 
ISNULL(p.NUM_FAILED_LOGINS,0) Failed_Logins_Since_Last_Login,
p.FAIL_PWD_RST_TRY AS Failed_PW_Resets_Since_Login, 
r.RESET_ATTEMPTS AS Failed_Reset_Attempts_Prev_Year, 
ISNULL(l.FAILED_LOGINS,0) AS Failed_Logins_Prev_Year,
ISNULL(pr.PWD_REQTS_PASSED, 0) AS PW_Requirement_Passed
FROM CLARITY.dbo.MYC_PATIENT p INNER JOIN  --MYC_Patient is Patient's Mychart basic info 
	(SELECT r.WPR_ID, COUNT (*) AS RESET_ATTEMPTS
		FROM clarity.dbo.MYC_PAT_FLD_PWD_RS r --Table that tracks failed password resets
		WHERE r.FAIL_PWD_RST_DTTM BETWEEN '2021-10-01' AND GETDATE()
		GROUP BY r.WPR_ID
	)r ON r.WPR_ID = p.MYPT_ID LEFT JOIN

	(SELECT WPR_ID, COUNT(*) AS FAILED_LOGINS
		FROM clarity.dbo.MYC_PAT_FLD_LOGIN -- Table that Tracks failed logins
		WHERE FAILED_LOGIN_I_DTTM BETWEEN '2021-10-01' AND GETDATE()
	  GROUP BY WPR_ID
	 ) l ON l.WPR_ID = p.MYPT_ID LEFT JOIN 

	(SELECT MYPT_ID, COUNT(*) AS PWD_REQTS_PASSED 
		FROM clarity.dbo.MYC_PWD_REQTS_PASSED --Table that tracks if the user passed the password requirements 
		WHERE SITE_ID = 1
		GROUP BY MYPT_ID
	)pr ON pr.MYPT_ID = p.MYPT_ID



/*
This was used to show HIT managers the uptick in MyChart Usage starting in September 
*/

SELECT YEAR(START_DTTM) AS 
YEAR, MONTH(START_DTTM) AS MONTH,  
COUNT(*) AS TOTAL_MONTHLY_SESSIONS,
COUNT(DISTINCT MYPT_ID) UNIQUE_USER_LOGINS, 
COUNT(DISTINCT PAT_ID) UNIQUE_PATIENT_LOGINS, -- If they have a Pat_ID, it's a patient
COUNT(DISTINCT CASE WHEN PAT_ID IS NULL THEN MYPT_ID
	ELSE NULL END) AS UNIQUE_NON_PATIENT_LOGINS,
SUM(CASE WHEN PAT_ID IS NULL THEN 1
	ELSE 0 END) AS NON_PATIENT_SESSIONS
FROM CLARITY.dbo.V_MYC_SESSIONS WITH (NOLOCK) --V_MYC_SESSIONS gives generalized session information
WHERE START_DTTM >= '2021-10-01'
GROUP BY YEAR(START_DTTM), MONTH(START_DTTM)
ORDER BY YEAR(START_DTTM), MONTH(START_DTTM)
 
 
 
 
 /*
 This query was used to look for sessions that used the E-Visit functionallty in MyChart for a given range
 */
 
 USE CLARITY
 GO
 
 DECLARE @p_DateStart DATETIME = '2022-10-01',
 @p_DateEnd DATETIME = '2022-11-10'


SELECT a.MYPT_ID,
p.PAT_ID,
P.PAT_NAME,
p2.PAT_MRN_ID,
a.MYC_UA_TYPE_C,
t.NAME,
a.UA_SESSION_NUM,
pcp.PROV_ID AS PRIMARY_CARE_PROVIDER_ID,
pcp.PROV_NAME AS PRIMARY_CARE_PROVIDER,
MIN (a.UA_DTTM) AS SESSION_DATE,
MAX(CASE WHEN a.UA_EXTENDED_INFO = 'E-Visit Configuration Loaded' THEN 1 
	ELSE 0 
	END) AS EVISIT_START_COUNT,
MAX(CASE WHEN a.UA_EXTENDED_INFO = 'E-Visit - Submitted' THEN 1 
	ELSE 0 
	END) AS EVISIT_SUBMIT_COUNT

FROM CLARITY.dbo.V_MYC_PT_USER_ACCSS a WITH(NOLOCK) LEFT JOIN --V_MYC_PT_USER_ACCSS (MYC_PT_USER_ACCSS) used for audit tracking of patient actions in mychart, sessions can be grouped using the UA_SESSION_NUM
CLARITY.dbo.ZC_MYC_UA_TYPE t WITH(NOLOCK) ON t.MYC_UA_TYPE_C = a.MYC_UA_TYPE_C LEFT JOIN -- MYC_UA_TYPE_C tracks activity or section user is interacting with, used this join to filter to E-Visits
CLARITY.dbo.MYC_PATIENT p WITH(NOLOCK) ON a.MYPT_ID = p.MYPT_ID LEFT JOIN --MYC_Patient is Patient's Mychart basic info 
CLARITY.dbo.PATIENT p2 WITH(NOLOCK) ON p.PAT_ID = p2.PAT_ID  LEFT JOIN -- You can join a MYC_Patient record to a patient record
CLARITY.dbo.CLARITY_SER pcp ON p2.CUR_PCP_PROV_ID = pcp.PROV_ID -- FInd the patient's PCP
WHERE
t.NAME = 'EVisit'
-- Date filter. Expanding the range to catch sessions that are in the range, but partially extend past it. 
AND a.UA_DTTM >= DATEADD(DAY, -1, @p_DateStart) 
AND a.UA_DTTM < DATEADD(DAY, +2, @p_DateEnd) 
GROUP BY a.UA_SESSION_NUM, a.MYPT_ID, a.MYC_UA_TYPE_C, t.NAME,pcp.PROV_ID, pcp.PROV_NAME, p.PAT_ID, P.PAT_NAME, p2.PAT_MRN_ID
--Further filtering to only include sessions that started within our range.
HAVING MIN(a.UA_DTTM) >= @p_DateStart AND  
	   MIN(a.UA_DTTM) <	DATEADD(DAY, +1, @p_DateEnd)
ORDER BY MIN (a.UA_DTTM), P.PAT_NAME



