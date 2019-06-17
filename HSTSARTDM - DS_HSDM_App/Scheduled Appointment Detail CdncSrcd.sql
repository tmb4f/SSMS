USE [DS_HSDM_App]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

DECLARE @strBegindt AS VARCHAR(19), 
	    @strEnddt AS VARCHAR(19)

SET @strBegindt = '6/7/2019 00:00:00'
SET @strEnddt = '12/31/2019 23:59:59'

-- =====================================================================================
-- Create procedure uspSrc_Infectious_Diseases_Clinic_Appointments
-- =====================================================================================
/*
IF EXISTS (SELECT 1
    FROM INFORMATION_SCHEMA.ROUTINES 
    WHERE ROUTINE_SCHEMA='Rptg'
    AND ROUTINE_TYPE='PROCEDURE'
    AND ROUTINE_NAME='uspSrc_Infectious_Diseases_Clinic_Appointments')
   DROP PROCEDURE Rptg.[uspSrc_Infectious_Diseases_Clinic_Appointments]
GO
*/

--ALTER PROCEDURE [Rptg].[uspSrc_Infectious_Diseases_Clinic_Appointments]
----ALTER PROCEDURE [Rptg].[uspSrc_Infectious_Diseases_Clinic_Appointments]
--(
--	@strBegindt AS VARCHAR(19) = NULL, 
--	@strEnddt AS VARCHAR(19) = NULL )

--AS
/*********************************************************************************************
WHAT: Create procedure as data source for Infectious Disease clinic activity detail reporting.
WHO : Tom Burgan
WHEN: 2/9/2018

WHY :
----------------------------------------------------------------------------------------------
INFO:
INPUTS:
		 DS_HSDM_Prod
		    Rptg.VwPatient_Scheduling_CdncSrcd

		 DS_HSDW_Prod
			Rptg.vwDim_Date
            Rptg.vwFact_Pt_Enc_Clrt
			Rptg.vwFact_Pt_Enc_Clrt_Appt_Note
            Rptg.vwFact_Pt_Insrnc
			Rptg.vwDim_Insrnc_Pln_Pyr
			Rptg.vwDim_Clrt_SERsrc
			Rptg.vwDim_Physcn
			Rptg.vwDim_Patient
OUTPUTS:
		 DS_HSDM_App.Rptg.uspSrc_Infectious_Diseases_Clinic_Appointments
----------------------------------------------------------------------------------------------
MODS:
  2/9/2018 - New Build
************************************************************************************/
--
SET NOCOUNT ON

IF OBJECT_ID('tempdb..#ScheduledAppointment ') IS NOT NULL
DROP TABLE #ScheduledAppointment

IF OBJECT_ID('tempdb..#Scheduled_Appts_With_Patient_Detail ') IS NOT NULL
DROP TABLE #Scheduled_Appts_With_Patient_Detail

IF OBJECT_ID('tempdb..#RptgTemp ') IS NOT NULL
DROP TABLE #RptgTemp

--Set date variables
IF @strBegindt IS NULL
	OR LEN(@strBegindt) = 0
    -- last 7 days
	SET @strBegindt = CONVERT(VARCHAR(8), GETDATE()- 6, 112) + ' 00:00:00'
ELSE
	SET @strBegindt = CONVERT(VARCHAR(8), CAST(@strBegindt AS DATETIME), 112) + ' 00:00:00'


IF @strEnddt  IS NULL OR LEN(@strEnddt) = 0
	---- today
	Set @strEnddt = CONVERT(VARCHAR(8), GETDATE(), 112) + ' 23:59:59'
ELSE
	SET @strEnddt = CONVERT(VARCHAR(8), CAST(@strEnddt AS DATETIME), 112) + ' 23:59:59'

SELECT
       ra.[Med_Rec_No]
	  ,CAST(ra.[Med_Rec_No] AS INT) AS MRN_int
      ,ra.[Appt_Start_Date_Time]
	  ,ddte.date_key AS [Appt_Start_Date]
      ,CAST(SUBSTRING(CONVERT(VARCHAR(19),ra.[Appt_Start_Date_Time],20),12,2) +
            SUBSTRING(CONVERT(VARCHAR(19),ra.[Appt_Start_Date_Time],20),15,2) AS INTEGER) AS [Appt_Start_Time]
	  ,ddte.day_date AS [Appt_Date]
	  ,ddte.year_num AS [Appt_Date_Year]
	  ,ddte.month_num AS [Appt_Date_Month]
	  ,ddte.month_name AS [Appt_Date_Month_Name]
	  ,ddte.day_of_week_num AS [Appt_Day_Of_Week]
      ,DATEADD(MINUTE, ra.APPT_LENGTH, ra.appt_start_date_time) AS [Appt_Stop_Date_Time]
	  --,CASE
	  --   WHEN ((note.Appt_Note LIKE '04%') OR
   --            (note.Appt_Note LIKE '%04%') OR
   --            (note.Appt_Note LIKE '%04') OR
   --            (ins.Insrnc_Pyr_Nme LIKE 'RYAN%')) THEN '04'
		 --WHEN ((note.Appt_Note LIKE '05%') OR
   --            (note.Appt_Note LIKE '%05%') OR
   --            (note.Appt_Note LIKE '%05')) THEN '05'
		 --ELSE NULL
	  -- END AS Appt_Comment_Prefix
	  ,ra.POD
	  ,ra.HUB
	  ,ra.DEPARTMENT_ID
	  ,ra.DEPT_ABBREVIATION
	  ,ra.DEPARTMENT_NAME
	  ,ra.LOC_ID
	  ,ra.LOC_NAME
	  ,ra.VISIT_TYPE_ID
	  ,ra.VISIT_TYPE_NAME
	  ,ra.ENC_TYPE
	  ,ra.APPT_STATUS_C
	  ,ra.APPT_STATUS_NAME
      ,ra.[Appt_Status_Date]
	  ,ra.PATIENT_SEEN
	  ,ra.PATIENT_NO_SHOW
	  ,CASE WHEN ra.APPT_STATUS_C = 1 THEN 1 ELSE 0 END AS SCHEDULED
	  ,ra.APPT_CANC_DTTM
	  ,ra.Appt_Last_Modified_ID
	  ,ra.Appt_Last_Modified_Name
	  ,ra.APPT_MADE_DTTM
	  ,ra.APPT_ENTRY_USER_ID
	  ,ra.CREATOR_NAME
	  ,ra.PAT_ENC_CSN_ID
	  ,ra.PROV_ID
	  ,ra.PROV_NAME
	  ,prov.LastName
	  ,prov.FirstName
	  ,prov.MI
	  ,ra.CANCEL_REASON
	  ,ra.APPT_STATUS_REASON_AUDIT
	  --,note.Appt_Note
	  --,ins.Insrnc_Pyr_Nme
INTO #ScheduledAppointment
FROM DS_HSDM_Prod.Rptg.VwPatient_Scheduling_CdncSrcd ra
INNER JOIN DS_HSDW_Prod.Rptg.vwDim_Date ddte
ON ddte.day_date = CAST(CAST(ra.Appt_Start_Date_Time AS DATE) AS SMALLDATETIME)
INNER JOIN DS_HSDW_Prod.Rptg.vwFact_Pt_Enc_Clrt enc
ON ra.PAT_ENC_CSN_ID = enc.PAT_ENC_CSN_ID
--LEFT OUTER JOIN (SELECT PAT_ENC_CSN_ID, Appt_Note
--                 FROM DS_HSDW_Prod.Rptg.vwFact_Pt_Enc_Clrt_Appt_Note
--				 WHERE ((Appt_Note LIKE '%04%')
--				        OR (Appt_Note LIKE '%05%')
--				        OR (Appt_Note LIKE '%A68%'))) note
--ON note.PAT_ENC_CSN_ID = ra.PAT_ENC_CSN_ID
--LEFT OUTER JOIN (SELECT fins.sk_Fact_Pt_Acct, dpyr.Insrnc_Pyr_Nme
--                 FROM DS_HSDW_Prod.Rptg.vwFact_Pt_Insrnc fins
--                 LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Insrnc_Pln_Pyr dpyr
--                 ON dpyr.sk_Dim_Insrnc_Pln_Pyr = fins.sk_Dim_Insrnc_Pln_Pyr
--				 WHERE dpyr.Insrnc_Pyr_Nme LIKE 'ryan%') ins
--ON ins.sk_Fact_Pt_Acct = enc.sk_Fact_Pt_Acct
LEFT OUTER JOIN (SELECT ser.PROV_ID
                      , ser.sk_Dim_Physcn
					  , dphys.LastName
					  , dphys.FirstName
					  , dphys.mi
                 FROM DS_HSDW_Prod.Rptg.vwDim_Clrt_SERsrc ser
				 LEFT OUTER JOIN (SELECT sk_Dim_Physcn
				                        ,FirstName
										,LastName
										,MI
				                  FROM DS_HSDW_Prod.Rptg.vwDim_Physcn
								  WHERE current_flag = 1) dphys
				 ON dphys.sk_Dim_Physcn = ser.sk_Dim_Physcn) prov
ON prov.PROV_ID = ra.PROV_ID
--************************************************************
--*           D E F A U L T  C L A U S E
--************************************************************
WHERE ISNUMERIC(ra.Med_Rec_No) = 1 AND
(ra.DEPARTMENT_ID = 10354019) AND
((ra.[Appt_Start_Date_Time] >= @strBegindt) AND
 (ra.[Appt_Start_Date_Time] <= @strEnddt)) AND
(ra.APPT_STATUS_C = 1) -- Scheduled

 --SELECT *
 --FROM #ScheduledAppointment
 --ORDER BY APPT_STATUS_NAME

SELECT id.Med_Rec_No
      ,id.Appt_Date
      ,CASE
         WHEN SUBSTRING(CONVERT(VARCHAR(24),id.Appt_Start_Date_Time,113),13,1) IN ('0') THEN
              SUBSTRING(CONVERT(VARCHAR(24),id.Appt_Start_Date_Time,113),14,4)
         WHEN SUBSTRING(CONVERT(VARCHAR(24),id.Appt_Start_Date_Time,113),13,1) NOT IN ('0') THEN
              SUBSTRING(CONVERT(VARCHAR(24),id.Appt_Start_Date_Time,113),13,5)
       END AS Appt_Time
	  ,id.Appt_Date_Year
	  ,id.Appt_Date_Month
	  ,id.Appt_Date_Month_Name
	  ,id.Appt_Start_Time AS Appt_Date_Time
      ,id.APPT_STATUS_NAME AS [Appt_Status]
	  ,id.PATIENT_SEEN AS [Attended]
      ,id.PATIENT_NO_SHOW AS [No Show]
	  ,id.SCHEDULED AS Scheduled
	  ,dpt.LastName AS [Patient_Last_Name]
      ,dpt.FirstName + ' ' + RTRIM(COALESCE(CASE WHEN dpt.MiddleName = 'Unknown' THEN NULL ELSE dpt.MiddleName END,'')) AS [Patient_First_Name]
	  ,dpt.Ethnicity AS [Patient_Ethnicity]
	  ,dpt.FirstRace AS [Patient Race]
	  ,dpt.SEX AS [Patient_Gender]
      ,DATEDIFF(YY, dpt.BirthDate, id.Appt_Date) - 
        CASE 
          WHEN((MONTH(dpt.BirthDate)*100 + DAY(dpt.BirthDate)) >
               (MONTH(id.Appt_Date)*100 + DAY(id.Appt_Date))) THEN 1
          ELSE 0
        END AS Age
	  ,id.VISIT_TYPE_NAME
	  ,id.ENC_TYPE
	  ,id.POD
	  ,id.HUB
	  ,id.DEPARTMENT_NAME
	  ,id.LOC_NAME
	  --,id.Appt_Comment_Prefix
	  --,id.Appt_Note AS [Appt_Comment]
	  ,dpt.BirthDate AS [Patient_Birth_Date]
	  ,dpt.Address_Line1 AS [Patient_Address_1]
	  ,dpt.Addres_Line2 AS [Patient_Address_2]
	  ,dpt.City AS [Patient_City]
	  ,dpt.StateOrProvince AS [Patient_State]
	  ,dpt.PostalCode AS [Patient_Zipcode]
	  --,id.Insrnc_Pyr_Nme
	  ,id.PAT_ENC_CSN_ID
	  ,id.PROV_ID
	  ,id.PROV_NAME
	  ,id.LastName AS [Provider Last Name]
	  ,id.FirstName AS [Provider First Name]
	  ,id.mi AS [Provider MI]
	  ,dpt.PreferredLanguage AS [Patient_Language]
INTO #Scheduled_Appts_With_Patient_Detail
FROM #ScheduledAppointment id
LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Patient dpt
ON dpt.MRN_int = id.MRN_int
  --************************************************************
  --*           D E F A U L T  C L A U S E
  --************************************************************
--WHERE id.Appt_Comment_Prefix IN ('04','05')
WHERE (DATEDIFF(YY, dpt.BirthDate, id.Appt_Date) - 
        CASE 
          WHEN((MONTH(dpt.BirthDate)*100 + DAY(dpt.BirthDate)) >
               (MONTH(id.Appt_Date)*100 + DAY(id.Appt_Date))) THEN 1
          ELSE 0
        END >= 18) AND
dpt.BirthDate <> '1900-01-01'

SELECT S.*
	--,'Rptg.uspSrc_Infectious_Diseases_Clinic_Appointments' AS [ETL_guid]
	, GETDATE() AS Load_Dte
 INTO #RptgTemp FROM
 (
 SELECT [PAT_ENC_CSN_ID] AS [PAT_ENC_CSN_ID] 
       ,[Med_Rec_No] AS [MRN]
       ,[Patient_Birth_Date] AS [Pt Birth Date]
       ,[Appt_Date] AS [Appt Date]
       ,[Appt_Time] AS [Appt Time]
	   ,[Appt_Date_Time] AS [Appt Date Time]
       ,[Appt_Status] AS [Appt Status]
       --,[Attended]
       --,[No Show]
	   ,[appts].[Scheduled]
       ,[Patient_Last_Name] AS [Pt Last Name]
       ,[Patient_First_Name] AS [Pt First Name MI]
       ,[Patient_Ethnicity] AS [Pt Ethnicity]
	   ,[appts].[Patient Race] AS [Pt Race]
       ,[Patient_Language] AS [Pt Language]
       ,[Patient_Gender] AS [Pt Gender]
       ,[Age]
	   ,VISIT_TYPE_NAME AS [Visit Type]
	   ,ENC_TYPE AS [Encounter Type]
	   ,POD
	   ,HUB
	   ,DEPARTMENT_NAME AS [Department Name]
	   ,LOC_NAME AS [Location Name]
	   ,PROV_ID AS [Provider Id]
	   ,PROV_NAME AS [Provider]
	   ,[Provider Last Name]
	   ,[Provider First Name]
	   ,[Provider MI]
	   --,[Appt_Comment_Prefix] AS [Appt Descr Prefix]
    --   ,[Appt_Comment] AS [Appt Descr]
       ,[Patient_Address_1] AS [Pt Addr 1]
       ,[Patient_Address_2] AS [Pt Addr 2]
       ,[Patient_City] AS [Pt City]
       ,[Patient_State] AS [Pt State]
       ,[Patient_Zipcode] AS [Pt Zipcode]
	   --,[Insrnc_Pyr_Nme] AS [Ins]
       ,[Appt_Date_Year]
       ,[Appt_Date_Month]
       ,[Appt_Date_Month_Name]
 FROM #Scheduled_Appts_With_Patient_Detail appts
) S

SELECT   *
FROM #RptgTemp
--************************************************************
--*           D E F A U L T  C L A U S E
--************************************************************
ORDER BY [Appt Date]
        ,[Appt Date Time]
        ,[MRN]

GO


