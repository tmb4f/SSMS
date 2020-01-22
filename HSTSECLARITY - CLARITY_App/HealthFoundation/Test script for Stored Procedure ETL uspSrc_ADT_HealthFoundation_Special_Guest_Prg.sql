USE [CLARITY_App]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
/*******************************************************************************************
WHAT:	uspSrc_ADT_HealthFoundation_Special_Guest_Prg
WHO :	Health Foundation Extract
WHEN:	Daily
WHY :	 
AUTHOR:	Mali Amarasinghe
SPEC:	
--------------------------------------------------------------------------------------------
INPUTS: 	        
	1) Start date- File should sweep back 3 days for production, 3 days for test
		
OUTPUTS: 
   	1) SEQUENCE:				File 1 of 1
   	2) FILE NAMING CONVENTION:	
   	3) OUTPUT TYPE:				DM Table
   	4) TRANSFER METHOD:			
   	5) OUTPUT LOCATION:			
								
   	6) FREQUENCY:				Daily
   	7) QUERY LOOKBACK PERIOD:	past 180 day
   	8) FILE SPECIFIC NOTES:		
								
								
--------------------------------------------------------------------------------------------
MODS: 
	2/10/17 - Initial draft created
	5/26/2017  - Discharge day add 
				SSN removed
	7/7/2017  remove  full name and added first name, middle name and last name for patient and gaurantor
*******************************************************************************************/

--EXEC [ETL].[uspSrc_ADT_HealthFoundation_Special_Guest_Prg] 

--ALTER  PROCEDURE [ETL].[uspSrc_ADT_HealthFoundation_Special_Guest_Prg]

-- Add the parameters for the stored procedure here
		--@Start_Date DATETIME , 
		--@End_Date DATETIME

--AS

/*******GET DATE VALUES for last 24 hrs**********/      



	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	declare @Start_Date DATETIME = null , 
		@End_Date DATETIME = null
	
	--set date parameter
	IF @Start_Date IS NULL
    AND @End_Date IS NULL
    BEGIN
 
        SELECT @Start_Date = CONVERT(DATETIME,CONVERT(VARCHAR(10),DATEADD(dd,-180,GETDATE()),101) + ' 00:00:00'); --last 180 days 
        SELECT  @End_Date   = CONVERT(DATETIME,CONVERT(VARCHAR(10),DATEADD(dd,-1,GETDATE()),101) + ' 23:59:59');
    END;




/*
IF OBJECT_ID('Clarity_App_Dev..HealthFoundation_Special_Guest_Program') IS NOT NULL
DROP TABLE Clarity_App_Dev.dbo.HealthFoundation_Special_Guest_Program

CREATE TABLE Clarity_App_Dev.dbo.HealthFoundation_Special_Guest_Program
								(
								PT_No	NUMERIC (18,0)
								,ADM_Date DATE 
								,Disch_Date DATE --Added per request 5/26/17
								,REL_CD VARCHAR(55)
								,REL_PT_REL VARCHAR(7)
								,Rel_Name	VARCHAR(250)
								,ATN_DR_NAME	VARCHAR(100)
								,REL_ADDR_LINE_1	VARCHAR(255)
								,REL_CITY	VARCHAR(50)
								,REL_STATE	VARCHAR(50)
								,PT_BIRTH_DATE	DATE
								,CENTURY_OF_DOB	SMALLINT
								,MED_REC_NO	 VARCHAR(50)
								,PT_SEX	VARCHAR(1)
								,REL_Zip_Code	VARCHAR(15)
								,HOSP_SVC	VARCHAR(15)
								,REL_Phone	VARCHAR(12)
								--,PT_SSN	VARCHAR(11)  --removed per request 5/26/17
								,Acct_Class	VARCHAR(100)
								,ETL_Guid VARCHAR(70)
								,Load_Dtm DATETIME
								)
*/




--INSERT INTO Clarity_App_Dev.dbo.HealthFoundation_Special_Guest_Program

SELECT  
		hsp.HSP_ACCOUNT_ID 'PT_No' 
		,CONVERT(VARCHAR(10),hsp.HOSP_ADMSN_TIME,101) 'ADM_Date'
		,CONVERT(VARCHAR(10),hsp.HOSP_DISCH_TIME,101) 'Disch_Date'
		,CAST('PT ADD' AS VARCHAR(55)) 'REL_CD'
		,CAST('' AS VARCHAR(7)) 'REL_PT_REL'
		--,pt.PAT_NAME 'Rel_Name'
		,CAST(pt.PAT_LAST_NAME AS VARCHAR(100)) AS 'Rel_LastName'
		,CAST(pt.PAT_FIRST_NAME AS VARCHAR(100)) AS 'Rel_FirstName'
		,CAST(pt.PAT_MIDDLE_NAME AS VARCHAR(100)) AS 'Rel_MiddleName'
		 
		,(SELECT TOP 1 ser.PROV_NAME
					FROM CLARITY.dbo.HSP_ATND_PROV prov
					LEFT OUTER JOIN CLARITY.dbo.CLARITY_SER ser				ON prov.PROV_ID=ser.PROV_ID
							WHERE hsp.PAT_ENC_CSN_ID= prov.PAT_ENC_CSN_ID
							ORDER BY ABS(DATEDIFF(dd,prov.ATTEND_FROM_DATE,GETDATE()))	)'ATN_DR_NAME'
		,CASE WHEN ad.line =1
				THEN ad.ADDRESS
				END 'REL_ADDR_LINE_1'
		,pt.CITY 'REL_CITY'
		,st.NAME 'REL_STATE'
		,CONVERT(VARCHAR(10), pt.BIRTH_DATE,101) 'PT_BIRTH_DATE'
		,CONVERT(VARCHAR(2),DATEADD(y,1000,pt.BIRTH_DATE),111)+1 'CENTURY_OF_DOB'
		,idx.IDENTITY_ID 'MED_REC_NO'
		,CAST(sex.ABBR AS VARCHAR(1)) AS 'PT_SEX'
		,CAST(pt.ZIP AS VARCHAR(15)) 'REL_Zip_Code'
		,CAST(hsv.ABBR AS VARCHAR(15)) 'HOSP_SVC'
		,CAST(pt.HOME_PHONE AS VARCHAR(12)) 'REL_Phone'
		--,cast(pt.SSN as varchar(11)) 'PT_SSN'
	--	,ha.NAME'BaseClass'
		,CAST(haact.NAME AS VARCHAR(100)) 'Acct_Class'
		,'[HSCDOM\GHA4R].[uspSrc_HealthFoundation_Special_Guest_Prg]' 'ETL_Guid'
		,GETDATE() 'Load_Dtm'

FROM CLARITY.dbo.PATIENT pt
		INNER JOIN CLARITY.dbo.PAT_ENC_HSP hsp					ON hsp.PAT_ID = pt.PAT_ID
		INNER JOIN CLARITY.dbo.HSP_ACCOUNT acc					ON acc.HSP_ACCOUNT_ID = hsp.HSP_ACCOUNT_ID
		INNER JOIN CLARITY.dbo.PAT_ADDRESS ad					ON ad.PAT_ID = pt.PAT_ID
		INNER JOIN CLARITY.dbo.ZC_STATE st						ON st.STATE_C = pt.STATE_C
		INNER JOIN CLARITY.dbo.IDENTITY_ID idx					ON idx.PAT_ID = pt.PAT_ID
		LEFT OUTER JOIN CLARITY.dbo.ZC_SEX sex					ON pt.SEX_C=sex.RCPT_MEM_SEX_C
		INNER JOIN CLARITY.dbo.ZC_PAT_SERVICE		hsv			ON hsv.HOSP_SERV_C = hsp.HOSP_SERV_C
		INNER JOIN CLARITY.dbo.ZC_ACCT_CLASS_HA haact			ON haact.ACCT_CLASS_HA_C= acc.ACCT_CLASS_HA_C

		
WHERE ADT_PAT_CLASS_C<>'102' --not outpatient
		AND idx.IDENTITY_TYPE_ID='14'
		AND hsp.PVT_HSP_ENC_C <>'1' -- NOT Private encounter
		AND hsp.HOSP_ADMSN_TIME>=@Start_Date AND hsp.HOSP_ADMSN_TIME<=@End_Date
		
--ORDER BY hsp.HSP_ACCOUNT_ID

UNION ALL

SELECT  
		hsp.HSP_ACCOUNT_ID 'PT_No'
		,CONVERT(VARCHAR(10),hsp.HOSP_ADMSN_TIME,101) 'ADM_Date'
		,CONVERT(VARCHAR(10),hsp.HOSP_DISCH_TIME,101) 'Disch_Date'
		,'PT GAR' 'REL_CD'
		,rsp.ABBR 'REL_PT_REL'
		--,gacc.ACCOUNT_NAME 'Rel_Name'
		/**Script to seperate out first, middle and last name from full name********/
		 /********this Scrip use provider name from clarity_ser**************/
		 
		 
		 ,CAST(	 CASE                -- Split ser.Prov_Nme into Last name and First name by comma, remove JR,SR,I
		       WHEN CHARINDEX(',',gacc.ACCOUNT_NAME) > 2 THEN
		         CASE 
		           WHEN CHARINDEX(' JR', SUBSTRING(gacc.ACCOUNT_NAME,1, CHARINDEX(',', gacc.ACCOUNT_NAME)-1)) > 2 THEN
		             LTRIM(SUBSTRING(gacc.ACCOUNT_NAME,1, CHARINDEX(' JR', SUBSTRING(gacc.ACCOUNT_NAME,1, CHARINDEX(',', gacc.ACCOUNT_NAME)-1))-1))
		           WHEN CHARINDEX(' SR', SUBSTRING(gacc.ACCOUNT_NAME,1, CHARINDEX(',', gacc.ACCOUNT_NAME)-1)) > 2 THEN
		             LTRIM(SUBSTRING(gacc.ACCOUNT_NAME,1, CHARINDEX(' SR', SUBSTRING(gacc.ACCOUNT_NAME,1, CHARINDEX(',', gacc.ACCOUNT_NAME)-1))-1))
		           WHEN CHARINDEX(' I', SUBSTRING(gacc.ACCOUNT_NAME,1, CHARINDEX(',', gacc.ACCOUNT_NAME)-1)) > 2 THEN
		             LTRIM(SUBSTRING(gacc.ACCOUNT_NAME,1, CHARINDEX(' I', SUBSTRING(gacc.ACCOUNT_NAME,1, CHARINDEX(',', gacc.ACCOUNT_NAME)-1))-1))
		              ELSE LTRIM(SUBSTRING(gacc.ACCOUNT_NAME, 1, CHARINDEX(',',gacc.ACCOUNT_NAME)-1))
		         END
		       ELSE LTRIM(gacc.ACCOUNT_NAME)
		     END AS VARCHAR(100))                                 AS Rel_Last_Name
		    ,CAST( CASE
		       WHEN CHARINDEX(',',gacc.ACCOUNT_NAME) > 2 THEN
		         CASE
		           WHEN CHARINDEX(' ', SUBSTRING(gacc.ACCOUNT_NAME, CHARINDEX(',',gacc.ACCOUNT_NAME)+2, LEN(gacc.ACCOUNT_NAME))) > 2 THEN
		             LTRIM(SUBSTRING(gacc.ACCOUNT_NAME,CHARINDEX(',',gacc.ACCOUNT_NAME)+1,CHARINDEX(' ', SUBSTRING(gacc.ACCOUNT_NAME, CHARINDEX(',',gacc.ACCOUNT_NAME)+2, LEN(gacc.ACCOUNT_NAME)))))
		           ELSE LTRIM(SUBSTRING(gacc.ACCOUNT_NAME, CHARINDEX(',',gacc.ACCOUNT_NAME)+1, LEN(gacc.ACCOUNT_NAME)))
		         END
		       ELSE ''
		     END  AS VARCHAR(100))                               AS Rel_First_Name
		    ,CAST(CASE
		       WHEN CHARINDEX(',',gacc.ACCOUNT_NAME) > 2 THEN -- found lastname, now look for space in first name to split middle name out
		         CASE
		           WHEN CHARINDEX(' ', SUBSTRING(gacc.ACCOUNT_NAME, CHARINDEX(',',gacc.ACCOUNT_NAME)+2, LEN(gacc.ACCOUNT_NAME))) > 2 THEN 
		             LTRIM(SUBSTRING(SUBSTRING(gacc.ACCOUNT_NAME, CHARINDEX(',',gacc.ACCOUNT_NAME)+2, LEN(gacc.ACCOUNT_NAME)), 
		                       CHARINDEX(' ', SUBSTRING(gacc.ACCOUNT_NAME, CHARINDEX(',',gacc.ACCOUNT_NAME)+2, LEN(gacc.ACCOUNT_NAME)))+1,
		                       LEN(gacc.ACCOUNT_NAME)))
		         ELSE ''
		       END  
		       ELSE ''
		      END AS VARCHAR(100))                             AS Rel_Middle_name
		 
		,(SELECT TOP 1 ser.PROV_NAME 
					FROM CLARITY.dbo.HSP_ATND_PROV prov
						LEFT OUTER JOIN CLARITY.dbo.CLARITY_SER ser				ON prov.PROV_ID=ser.PROV_ID
							WHERE hsp.PAT_ENC_CSN_ID= prov.PAT_ENC_CSN_ID
							ORDER BY ABS(DATEDIFF(dd,prov.ATTEND_FROM_DATE,GETDATE()))	)'ATN_DR_NAME'
	 
	
		,gacc.BILLING_ADDRESS_1 'REL_ADDR_LINE_1'
		,gacc.CITY 'REL_CITY'
		,st.NAME 'REL_STATE'
		,CONVERT(VARCHAR(10), pt.BIRTH_DATE,101)'PT_BIRTH_DATE'
		,CONVERT(VARCHAR(2),DATEADD(y,1000,pt.BIRTH_DATE),111)+1 'CENTURE_OF_DOB'
		,idx.IDENTITY_ID 'MED_REC_NO'
		,CAST(sex.ABBR AS VARCHAR(1)) AS 'PT_SEX'
		,CAST(gacc.ZIP AS VARCHAR(15)) 'REL_Zip_Code'
		,CAST(hsv.ABBR AS VARCHAR(15)) 'HOSP_SVC'
		,CAST(gacc.HOME_PHONE AS VARCHAR(12)) 'REL_Phone'
		--,cast(pt.SSN as varchar(11)) 'PT_SSN'
		--,ha.NAME'BaseClass'
		,CAST(haact.NAME AS VARCHAR(100)) 'Acct_Class'
		,CAST('[HSCDOM\GHA4R].[uspSrc_HealthFoundation_Special_Guest_Prg]' AS VARCHAR(70)) 'ETL_Guid'
		,GETDATE() 'Load_Dtm'

FROM CLARITY.dbo.PATIENT pt
		INNER JOIN CLARITY.dbo.PAT_ENC_HSP hsp					ON hsp.PAT_ID = pt.PAT_ID
		INNER JOIN CLARITY.dbo.HSP_ACCOUNT acc					ON acc.HSP_ACCOUNT_ID = hsp.HSP_ACCOUNT_ID
		INNER JOIN CLARITY.dbo.PAT_ADDRESS ad					ON ad.PAT_ID = pt.PAT_ID
		INNER JOIN CLARITY.dbo.IDENTITY_ID idx					ON idx.PAT_ID = pt.PAT_ID
		LEFT OUTER JOIN CLARITY.dbo.ZC_SEX sex					ON acc.GUAR_SEX_C=sex.RCPT_MEM_SEX_C
		INNER JOIN CLARITY.dbo.ACCOUNT gacc						ON gacc.ACCOUNT_ID=acc.GUARANTOR_ID
		LEFT OUTER JOIN CLARITY.dbo.ACCT_GUAR_PAT_INFO guar		ON guar.ACCOUNT_ID = gacc.ACCOUNT_ID
		INNER JOIN CLARITY.dbo.ZC_STATE st						ON st.STATE_C = gacc.STATE_C
		INNER JOIN CLARITY.dbo.ZC_GUAR_REL_TO_PAT rsp			ON guar.GUAR_REL_TO_PAT_C=rsp.GUAR_REL_TO_PAT_C
		INNER JOIN CLARITY.dbo.ZC_PAT_SERVICE		hsv			ON hsv.HOSP_SERV_C = hsp.HOSP_SERV_C
		LEFT OUTER JOIN CLARITY.dbo.CLARITY_SER ser				ON hsp.ADMISSION_PROV_ID=ser.PROV_ID
		INNER JOIN CLARITY.dbo.ZC_ACCT_CLASS_HA haact			ON haact.ACCT_CLASS_HA_C= acc.ACCT_CLASS_HA_C


WHERE hsp.ADT_PAT_CLASS_C<>'102' --not outpatient//include any patient in a bed
		AND idx.IDENTITY_TYPE_ID='14'
		AND hsp.PVT_HSP_ENC_C <>'1' -- NOT a Private encounter
		AND gacc.IS_ACTIVE = 'Y' --active at the time of extract
		AND hsp.HOSP_ADMSN_TIME>=@Start_Date AND hsp.HOSP_ADMSN_TIME<=@End_Date
	
	--ORDER BY hsp.HSP_ACCOUNT_ID,REL_PT_REL	


	


GO


