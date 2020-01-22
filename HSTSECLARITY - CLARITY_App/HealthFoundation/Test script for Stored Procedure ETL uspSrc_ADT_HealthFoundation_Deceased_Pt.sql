USE [CLARITY_App]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************************************
WHAT:	ADT_HF_Deceased_Pt
WHO :	Health Foundation
WHEN:	Daily
WHY :	Extracts all deceased patients 
AUTHOR:	Mali Amarasinghe
SPEC:	Epic SharePoint-http://hstsproject1/PMO/EpicPhase2_SystemImplementation/
--------------------------------------------------------------------------------------------
INPUTS: 	        
			CLARITY.dbo.PATIENT_4 
			CLARITY.dbo.PATIENT
		
OUTPUTS: 
   	1) SEQUENCE:				File 1 of 1
   	2) FILE NAMING CONVENTION:	
   	3) OUTPUT TYPE:				TABLE 
   	4) TRANSFER METHOD:			sFTP
   	5) OUTPUT LOCATION:			HSTSDWWSQLDM. ADT_HealthFoundation_Deceased_Pt
									(
											PAT_ID VARCHAR(18) 
											,ETL_Guid VARCHAR(50)
											,Load_Dtm DATETIME
									)
   	6) FREQUENCY:				Daily
   	7) QUERY LOOKBACK PERIOD:	previous day
   	8) FILE SPECIFIC NOTES:		PAT_LIVING_STAT_C=2 --deceased


    
--------------------------------------------------------------------------------------------
MODS: 
	01/26/17 - Initial draft created
	03/02/17	-	set parameterized variables 
	07/01/2017 --remove date parameter, table will be truncated and upload everyday with all the data in the system -Mali Amarasinghe
*******************************************************************************************/


--EXEC [ETL].[uspSrc_ADT_HealthFoundation_Deceased_Pt]

--ALTER PROCEDURE [ETL].[uspSrc_ADT_HealthFoundation_Deceased_Pt]
	-- Add the parameters for the stored procedure here
	--@StartDate DATETIME, 
	--@EndDate   DATETIME


--AS


	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--set date parameter
	--IF @Startdate IS NULL
   -- AND @Enddate IS NULL
    --BEGIN
/* DECLARE @StartDate DATETIME,
		 @EndDate DATETIME;


         SELECT @StartDate = CONVERT(DATETIME,CONVERT(VARCHAR(10),DATEADD(dd,-365,GETDATE()),101) + ' 00:00:00'); --set to last 1000 days for testing
        SELECT  @EndDate   = CONVERT(DATETIME,CONVERT(VARCHAR(10),DATEADD(dd,-1,GETDATE()),101) + ' 23:59:59'); --Today
   
	*/
    -- Insert statements for procedure here

	/*
IF OBJECT_ID('Clarity_App_Dev..ADT_HealthFoundation_Deceased_Pt') IS NOT NULL
DROP TABLE Clarity_App_Dev.dbo.ADT_HealthFoundation_Deceased_Pt

CREATE TABLE Clarity_App_Dev.dbo.ADT_HealthFoundation_Deceased_Pt
	(
			PAT_ID VARCHAR(18) 
			,ETL_Guid VARCHAR(50)
			,Load_Dtm DATETIME
	)

*/

--INSERT INTO CLARITY_App_Dev.dbo.ADT_HealthFoundation_Deceased_Pt

SELECT pt.PAT_ID 
		,CAST('uspScr_ADT_HealthFoundation_Deceased_Pt' AS VARCHAR(50)) 'ETL_Guid'
		,GETDATE() 'Load_Dtm'
		
FROM CLARITY.dbo.PATIENT_4 pt
		INNER JOIN CLARITY.dbo.PATIENT pt1			ON pt1.PAT_ID = pt.PAT_ID
		
WHERE pt.PAT_LIVING_STAT_C=2 --deceased
		AND pt1.RECORD_STATE_C IS NULL  --not inactive or deleted
		AND (pt.DEATH_DT_INACC_YN IS NULL OR pt.DEATH_DT_INACC_YN<>'2')  --No
		/*AND 
			(pt.DEATH_DATA_IMPORT_DATE>=@StartDate		AND pt.DEATH_DATA_IMPORT_DATE<=@EndDate
				OR 
				pt1.DEATH_DATE>=@StartDate		AND pt1.DEATH_DATE<=@EndDate)*/




GO


