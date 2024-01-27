USE [CLARITY_App]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--ALTER   PROCEDURE [Rptg].[uspSrc_Wound_Service_Providers] (@last_load_date DATETIME = NULL)

----WITH EXECUTE AS OWNER
--AS

DECLARE @last_load_date DATETIME = NULL

SET @last_load_date = '1/1/2021'

/**********************************************************************************************************************
WHAT: Create procedure Rptg.uspSrc_Wound_Service_Providers v3
WHO : Marlene Jones
WHEN: 2/26/2020
WHY : Providers that wrote a Note or Consult since 10/1/2016 on the Wound Service - 189
       updated with current values since last_recorded_time
-----------------------------------------------------------------------------------------------------------------------
Mods:	2/05/2021  Wound/Ostomy/Continence (189) Service to be split into a Wound Service (2300100184) 
		and an Ostomy/Continence Service (2300100185). Li Ni Line 78
		7/08/21 -- LN Replace dbo with .. phrase.
------------------------------------------------------------------------------------------------------------------------
*/

DECLARE @LocstartDate SMALLDATETIME
DECLARE @LocEndDate SMALLDATETIME

SET @LocstartDate = @last_load_date

IF (@last_load_date IS NULL)
    SET @LocstartDate = '10/1/2016'
ELSE
    SET @LocstartDate = @last_load_date

--SET @LocEndDate = CAST(CAST(GETDATE() AS DATE) AS DATETIME)
SET @LocEndDate = CAST('12/31/2022' AS DATETIME)

DECLARE @PROVTEAM TABLE
(
PROV_ID VARCHAR(18),
RECORD_NAME VARCHAR(200)
)

INSERT INTO @PROVTEAM
(
    PROV_ID,
    RECORD_NAME
)
VALUES
 ('105151', -- FLANNAGAN, MOLLY A
  'EGS Team') -- "EGS Team" ID 73
,('126209', -- TSUNG, ALLAN
  'Green Surgery Team') -- "Green Surgery Team" ID 69
,('130914', -- LEVINSKY JR, NICK C
  'Orange Surgery') -- "Orange Surgery" ID 72
,('30272', -- HALLOWELL, PETER
  'Orange Surgery') -- "Orange Surgery" ID 72
,('30284', -- YOUNG, JEFFREY SETH
  'EGS Team') -- "EGS Team" ID 73
,('30317', -- SCHIRMER, BRUCE
  'Orange Surgery') -- "Orange Surgery" ID 72
,('30332', -- BAUER, TODD W
  'Green Surgery Team') -- "Green Surgery Team" ID 69
,('30344', -- CALLAND, JAMES F
  'EGS Team') -- "EGS Team" ID 73
,('34027', -- TACHE-LEON, CARLOS
  'EGS Team') -- "EGS Team" ID 73
,('45837', -- DAVIS, JOHN P
  'EGS Team') -- "EGS Team" ID 73
,('46621', -- SMITH, PHILIP W
  'Red Surgery Team') -- "Red Surgery Team" ID 190
,('46748', -- YANG, ZEQUAN
  'Orange Surgery') -- "Orange Surgery" ID 72
,('51087', -- WILLIAMS, MICHAEL D
  'EGS Team') -- "EGS Team" ID 73
,('56357', -- FASHANDI, ANNA Z
  'Red Surgery Team') -- "Red Surgery Team" ID 190
,('57158', -- ZAYDFUDIM, VICTOR M
  'Green Surgery Team') -- "Green Surgery Team" ID 69
;

DROP TABLE IF EXISTS #consult

SELECT DISTINCT
    --provteam.RECORD_NAME
    CASE WHEN ser.PROV_ID = '46748' AND CAST(hno.CREATE_INSTANT_DTTM AS DATE) <= '12/1/2022' THEN  'EGS Team' ELSE provteam.RECORD_NAME END AS RECORD_NAME -- YANG, ZEQUAN
   ,enc.PAT_ENC_CSN_ID
   ,hno.CREATE_INSTANT_DTTM
   ,CAST(hno.CREATE_INSTANT_DTTM AS DATE) AS CREATE_INSTANT_DT
   ,ser.PROV_ID
   ,ser.PROV_NAME
   ,ser.PROV_TYPE
   ,enc.HOSP_ADMSN_TIME
   ,CAST(enc.HOSP_ADMSN_TIME AS DATE) AS HOSP_ADMSN_DATE
   ,enc.HOSP_DISCH_TIME
   ,CAST(enc.HOSP_DISCH_TIME AS DATE) AS HOSP_DISCH_DATE
   --,los.CALCULATED_LOS
   ,DATEDIFF(MINUTE, enc.HOSP_ADMSN_TIME, enc.HOSP_DISCH_TIME) AS HOSP_LOS
   ,CAST(CAST(DATEDIFF(MINUTE,enc.HOSP_ADMSN_TIME,enc.HOSP_DISCH_TIME) AS NUMERIC(10,3)) / 1440.0 AS NUMERIC(7,2)) AS LOS_Days
   ,enc.HOSP_ADMSN_TYPE_C
   ,zhat.NAME AS HOSP_ADMSN_TYPE_NAME
   --,eta.PROVTEAM_REC_INFO_NAME
   ,nc.AUTHOR_SERVICE_C
   ,hno.IP_NOTE_TYPE_C
   ,zn.NAME AS IP_NOTE_TYPE_NAME
   ,svc.NAME AS AUTHOR_SERVICE_NAME
   ,emp.USER_ID
   --,MAX(hno.CREATE_INSTANT_DTTM) MAX_DTTM
   ,@LocEndDate AS Load_Dte  
--SELECT DISTINCT
--   ser.PROV_ID
--   ,ser.PROV_NAME

INTO #consult

FROM CLARITY..PAT_ENC_HSP AS enc WITH (NOLOCK)
INNER JOIN CLARITY..HNO_INFO hno WITH (NOLOCK)
   ON hno.PAT_ENC_CSN_ID = enc.PAT_ENC_CSN_ID

LEFT JOIN CLARITY..V_NOTE_CHARACTERISTICS nc WITH (NOLOCK)
  ON nc.NOTE_ID = hno.NOTE_ID

LEFT JOIN CLARITY..ZC_NOTE_TYPE_IP zn WITH (NOLOCK)
  ON hno.IP_NOTE_TYPE_C = zn.TYPE_IP_C
 
LEFT JOIN CLARITY..ZC_NOTE_PURPOSE znp WITH (NOLOCK)
  ON hno.NOTE_PURPOSE_C = znp.NOTE_PURPOSE_C

LEFT JOIN CLARITY..CLARITY_EMP emp WITH (NOLOCK)
  ON hno.CURRENT_AUTHOR_ID = emp.USER_ID

LEFT JOIN CLARITY..CLARITY_SER AS ser WITH (NOLOCK)
  ON emp.PROV_ID = ser.PROV_ID

LEFT JOIN CLARITY..ZC_CLINICAL_SVC svc WITH (NOLOCK)
  ON nc.AUTHOR_SERVICE_C = svc.CLINICAL_SVC_C

LEFT JOIN CLARITY..ZC_NOTE_STATUS ns WITH (NOLOCK)
  ON ns.NOTE_STATUS_C = nc.NOTE_STATUS_C

LEFT JOIN CLARITY.Rptg.VwPAT_ADT_LOCATION_HX adt_n WITH (NOLOCK)
  ON adt_n.PAT_ENC_CSN = enc.PAT_ENC_CSN_ID
     AND nc.NOTE_FILE_DTTM
     BETWEEN adt_n.IN_DTTM AND adt_n.OUT_DTTM

LEFT JOIN CLARITY.dbo.ZC_HOSP_ADMSN_TYPE zhat
ON zhat.HOSP_ADMSN_TYPE_C = enc.HOSP_ADMSN_TYPE_C

--LEFT JOIN
--(
--	SELECT DISTINCT 
--	     eta.TEAM_AUDIT_ID
--		,ptri.RECORD_NAME AS PROVTEAM_REC_INFO_NAME
--		--,eta.PAT_ID
--		,eta.PAT_ENC_CSN_ID
--	FROM CLARITY..EPT_TEAM_AUDIT eta
--    LEFT OUTER JOIN CLARITY..PROVTEAM_REC_INFO ptri
--	ON eta.TEAM_AUDIT_ID = ptri.ID
--	WHERE 1 = 1
--        AND eta.TEAM_AUDIT_ID IN (69,72,73,190) -- Green Surgery Team, Orange Surgery, EGS Team, Red Surgery Team
--) eta
--ON eta.PAT_ENC_CSN_ID = enc.PAT_ENC_CSN_ID

LEFT OUTER JOIN @PROVTEAM provteam
ON provteam.PROV_ID = ser.PROV_ID

--LEFT OUTER JOIN CLARITY..V_PAT_ENC_CALCULATED_LOS los
--ON los.PAT_ENC_CSN_ID = enc.PAT_ENC_CSN_ID

--WHERE nc.AUTHOR_SERVICE_C IN ('189', '2300100184', '2300100185') -- Wound Service Note or Consults
WHERE
--(ser.PROV_NAME LIKE '%Tsung%'
--OR ser.PROV_NAME LIKE '%Bauer%'
--OR ser.PROV_NAME LIKE '%Zaydfudim%'
--OR ser.PROV_NAME LIKE '%Hallowell%'
--OR ser.PROV_NAME LIKE '%Schirmer%'
--OR ser.PROV_NAME LIKE '%Levinsky%'
--OR ser.PROV_NAME LIKE '%Yang%'
--OR ser.PROV_NAME LIKE '%Leon%'
--OR ser.PROV_NAME LIKE '%Flannagan%'
--OR ser.PROV_NAME LIKE '%Davis%'
--OR ser.PROV_NAME LIKE '%Young%'
--OR ser.PROV_NAME LIKE '%Williams%'
--OR ser.PROV_NAME LIKE '%Calland%'
--OR ser.PROV_NAME LIKE '%Smith%'
--OR ser.PROV_NAME LIKE '%Fashandi%'
--)
--AND 
--(ser.PROV_ID IN ('126209','57158','30272','30317','130914','46748','34027','105151','45837','30284','51087','30344','46621','56357','30332'))
(ser.PROV_ID IN
(
 '105151' -- FLANNAGAN, MOLLY A
,'126209' -- TSUNG, ALLAN
,'130914' -- LEVINSKY JR, NICK C
,'30272' -- HALLOWELL, PETER
,'30284' -- YOUNG, JEFFREY SETH
,'30317' -- SCHIRMER, BRUCE
,'30332' -- BAUER, TODD W
,'30344' -- CALLAND, JAMES F
,'34027' -- TACHE-LEON, CARLOS
,'45837' -- DAVIS, JOHN P
,'46621' -- SMITH, PHILIP W
,'46748' -- YANG, ZEQUAN
,'51087' -- WILLIAMS, MICHAEL D
,'56357' -- FASHANDI, ANNA Z
,'57158' -- ZAYDFUDIM, VICTOR M
)
)
      --AND hno.IP_NOTE_TYPE_C IN ( '1', '2' ) -- Progress Notes, Consults
      AND hno.IP_NOTE_TYPE_C = '2'  -- Consults
      AND hno.CREATE_INSTANT_DTTM
      BETWEEN @LocstartDate AND @LocEndDate
-- 10/1/2016 when Wound LDA was revamped
--GROUP BY nc.AUTHOR_SERVICE_C
--        ,hno.IP_NOTE_TYPE_C
--        ,zn.NAME
--        ,svc.NAME
--        ,emp.USER_ID
--        ,ser.PROV_ID
--        ,ser.PROV_NAME
--        ,ser.PROV_TYPE

SELECT RECORD_NAME AS Provider_Team,
       --PAT_ENC_CSN_ID AS CSN,
       PAT_ENC_CSN_ID AS Consult_Order_Encounter_CSN,
       CREATE_INSTANT_DT AS Consult_Note_Create_Date,
       CREATE_INSTANT_DTTM AS Consult_Note_Create_Time,
	   PROV_NAME AS Consult_Note_Author,
       --HOSP_LOS AS Encounter_LOS,
       --LOS_Days AS Encounter_LOS_Days,
       AUTHOR_SERVICE_NAME AS Consult_Note_Author_Service
FROM #consult
--ORDER BY MAX_DTTM DESC
--ORDER BY enc.PAT_ENC_CSN_ID, hno.CREATE_INSTANT_DTTM
--ORDER BY ser.PROV_ID
--ORDER BY provteam.RECORD_NAME, enc.PAT_ENC_CSN_ID, hno.CREATE_INSTANT_DTTM, ser.PROV_NAME
--ORDER BY CASE WHEN PROV_ID = '46748' AND CAST(hno.CREATE_INSTANT_DTTM AS DATE) <= '12/1/2022' THEN  'EGS Team' ELSE provteam.RECORD_NAME END, enc.PAT_ENC_CSN_ID, hno.CREATE_INSTANT_DTTM, ser.PROV_NAME
ORDER BY RECORD_NAME, PAT_ENC_CSN_ID, CREATE_INSTANT_DTTM, PROV_NAME

SELECT DISTINCT
	   RECORD_NAME AS Provider_Team,
       PAT_ENC_CSN_ID AS Consult_Order_Encounter_CSN,
	   HOSP_ADMSN_DATE AS Consult_Order_Encounter_Admsn_Date,
	   HOSP_DISCH_DATE Consult_Order_Encounter_Disch_Date,
       HOSP_LOS AS Encounter_LOS,
       LOS_Days AS Encounter_LOS_Days
FROM #consult
--ORDER BY MAX_DTTM DESC
--ORDER BY enc.PAT_ENC_CSN_ID, hno.CREATE_INSTANT_DTTM
--ORDER BY ser.PROV_ID
--ORDER BY provteam.RECORD_NAME, enc.PAT_ENC_CSN_ID, hno.CREATE_INSTANT_DTTM, ser.PROV_NAME
--ORDER BY CASE WHEN PROV_ID = '46748' AND CAST(hno.CREATE_INSTANT_DTTM AS DATE) <= '12/1/2022' THEN  'EGS Team' ELSE provteam.RECORD_NAME END, enc.PAT_ENC_CSN_ID, hno.CREATE_INSTANT_DTTM, ser.PROV_NAME
ORDER BY RECORD_NAME, PAT_ENC_CSN_ID, HOSP_ADMSN_DATE

GO


