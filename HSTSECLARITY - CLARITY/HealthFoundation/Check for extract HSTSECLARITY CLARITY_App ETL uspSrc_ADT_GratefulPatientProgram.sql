USE [CLARITY_App]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('tempdb..#gpp ') IS NOT NULL
DROP TABLE #gpp

	DECLARE @StartDate DATETIME;
	DECLARE @EndDate DATETIME;

			--SET  @StartDate= DATEADD(yy,-5,DATEADD(yy, DATEDIFF(yy,0,getdate()), 0)); --last five years
			--SET  @EndDate	=CONVERT(DATETIME,CONVERT(VARCHAR(10),DATEADD(dd,-1,GETDATE()),101) + ' 23:59:59'); --Yesterday

			SET  @StartDate= '3/1/2019 00:00:00';
			SET  @EndDate	='4/30/2019 23:59:59';
/*******QUERY TO GET LAST ENCOUNTER*********************/
/*
;WITH Lenc_cte AS 
(
SELECT 
	hsp.PAT_ID 'Pat_ID'
	,hsp.VISIT_PROV_ID 'Prov_ID'
	,MAX(hsp.PAT_ENC_DATE_REAL) 'Cntc_Dt'
FROM  CLARITY.dbo.PAT_ENC hsp		--ON hsp.PAT_ENC_CSN_ID = enc.PAT_ENC_CSN_ID

WHERE
(
(hsp.CONTACT_DATE >=@StartDate		AND		hsp.CONTACT_DATE<@EndDate)
				OR 
				(hsp.HOSP_ADMSN_TIME  >=@StartDate	AND		hsp.HOSP_ADMSN_TIME <@EndDate)
)
AND
(hsp.PAT_ID = 'Z2153030')

GROUP BY hsp.PAT_ID,hsp.VISIT_PROV_ID
)
*/
;WITH enc_cte AS 
(
SELECT 
	hsp.PAT_ID 'Pat_ID'
   ,hsp.PAT_ENC_CSN_ID
FROM  CLARITY.dbo.PAT_ENC hsp		--ON hsp.PAT_ENC_CSN_ID = enc.PAT_ENC_CSN_ID

WHERE
(
(hsp.CONTACT_DATE >=@StartDate		AND		hsp.CONTACT_DATE<@EndDate)
				OR 
				(hsp.HOSP_ADMSN_TIME  >=@StartDate	AND		hsp.HOSP_ADMSN_TIME <@EndDate)
)
AND
(hsp.PAT_ID = 'Z2153030')
)
/**********************************************/

/******Atn_Dr_Last_Update_Dt************/
/*
,lst_cte AS 
(
SELECT 
	 enc.PAT_ID, 
	 enc.PAT_ENC_CSN_ID 'last_encounter'
	 ,enc.HSP_ACCOUNT_ID 'Hsp_Acct'
	 ,CASE WHEN enc.HOSP_ADMSN_TIME IS NULL
		THEN enc.CONTACT_DATE  --for Outpatient
		ELSE enc.HOSP_ADMSN_TIME  --for Inpatient
		END 'Adm_Dt'
	--,enc.CONTACT_DATE 'Contact_Dt'
	--,enc.HOSP_ADMSN_TIME 'Adm_Dt'
	,enc.VISIT_PROV_ID 'Prov_ID'
	,enc.ACCOUNT_ID 'Guar_ID'
	,enc.ENC_TYPE_C
FROM Lenc_cte
	INNER JOIN CLARITY.dbo.PAT_ENC enc		ON enc.PAT_ID = Lenc_cte.Pat_ID
										AND enc.VISIT_PROV_ID=Lenc_cte.Prov_ID
 										AND Lenc_cte.Cntc_Dt=enc.PAT_ENC_DATE_REAL
	--INNER JOIN CLARITY.dbo.PAT_ENC enc		ON enc.PAT_ID = Lenc_cte.Pat_ID

)
*/
,lst_cte AS 
(
SELECT 
	 enc.PAT_ID, 
	 enc.PAT_ENC_CSN_ID 'encounter'
	 ,enc.HSP_ACCOUNT_ID 'Hsp_Acct'
	 ,CASE WHEN enc.HOSP_ADMSN_TIME IS NULL
		THEN enc.CONTACT_DATE  --for Outpatient
		ELSE enc.HOSP_ADMSN_TIME  --for Inpatient
		END 'Adm_Dt'
	--,enc.CONTACT_DATE 'Contact_Dt'
	--,enc.HOSP_ADMSN_TIME 'Adm_Dt'
	,enc.VISIT_PROV_ID 'Prov_ID'
	,enc.ACCOUNT_ID 'Guar_ID'
	,enc.ENC_TYPE_C
FROM enc_cte
	INNER JOIN CLARITY.dbo.PAT_ENC enc		ON enc.PAT_ID = enc_cte.Pat_ID
	                                    AND enc.PAT_ENC_CSN_ID = enc_cte.PAT_ENC_CSN_ID

)
/************************************************************/



--INSERT INTO [Clarity_App_Dev].[dbo].[ADT_GPP_Encounters]

SELECT DISTINCT  --without distinct, results multiple rows becasue diagnosis code in multiple line
	--lst_cte.Hsp_Acct  'Acct'
	--,CAST(idx.IDENTITY_ID AS VARCHAR(12))  'MRN'
	lst_cte.Adm_Dt  'Adm_Dt'
	,lst_cte.encounter 'PAT_ENC_CSN_ID'
	,CAST(ser.PROV_ID AS VARCHAR(30)) 'Atn_Dr'
	,CAST(serid.SMS_ID AS VARCHAR(30)) 'Atn_Dr_SMS_ID'
	,CAST(CASE                
	       WHEN CHARINDEX(',',ser.PROV_NAME) > 2 THEN
	         CASE 
	           WHEN CHARINDEX(' JR', SUBSTRING(ser.PROV_NAME,1, CHARINDEX(',', ser.PROV_NAME)-1)) > 2 THEN
	             LTRIM(SUBSTRING(ser.PROV_NAME,1, CHARINDEX(' JR', SUBSTRING(ser.PROV_NAME,1, CHARINDEX(',', ser.PROV_NAME)-1))-1))
	           WHEN CHARINDEX(' SR', SUBSTRING(ser.PROV_NAME,1, CHARINDEX(',', ser.PROV_NAME)-1)) > 2 THEN
	             LTRIM(SUBSTRING(ser.PROV_NAME,1, CHARINDEX(' SR', SUBSTRING(ser.PROV_NAME,1, CHARINDEX(',', ser.PROV_NAME)-1))-1))
	           WHEN CHARINDEX(' I', SUBSTRING(ser.PROV_NAME,1, CHARINDEX(',', ser.PROV_NAME)-1)) > 2 THEN
	             LTRIM(SUBSTRING(ser.PROV_NAME,1, CHARINDEX(' I', SUBSTRING(ser.PROV_NAME,1, CHARINDEX(',', ser.PROV_NAME)-1))-1))
	              ELSE LTRIM(SUBSTRING(ser.PROV_NAME, 1, CHARINDEX(',',ser.PROV_NAME)-1))
	         END
	       ELSE LTRIM(ser.PROV_NAME)
	     END AS VARCHAR(25))                               AS Atn_Dr_LName
	    ,CAST (CASE
	       WHEN CHARINDEX(',',ser.PROV_NAME) > 2 THEN
	         CASE
	           WHEN CHARINDEX(' ', SUBSTRING(ser.PROV_NAME, CHARINDEX(',',ser.PROV_NAME)+2, LEN(ser.PROV_NAME))) > 2 THEN
	             LTRIM(SUBSTRING(ser.PROV_NAME,CHARINDEX(',',ser.PROV_NAME)+1,CHARINDEX(' ', SUBSTRING(ser.PROV_NAME, CHARINDEX(',',ser.PROV_NAME)+2, LEN(ser.PROV_NAME)))))
	           ELSE LTRIM(SUBSTRING(ser.PROV_NAME, CHARINDEX(',',ser.PROV_NAME)+1, LEN(ser.PROV_NAME)))
	         END
	       ELSE ''
	     END AS VARCHAR(25))                                AS Atn_Dr_FName
	    ,CAST(CASE
	       WHEN CHARINDEX(',',ser.PROV_NAME) > 2 THEN -- found lastname, now look for space in first name to split middle name out
	         CASE
	           WHEN CHARINDEX(' ', SUBSTRING(ser.PROV_NAME, CHARINDEX(',',ser.PROV_NAME)+2, LEN(ser.PROV_NAME))) > 2 THEN 
	             LTRIM(SUBSTRING(SUBSTRING(ser.PROV_NAME, CHARINDEX(',',ser.PROV_NAME)+2, LEN(ser.PROV_NAME)), 
	                       CHARINDEX(' ', SUBSTRING(ser.PROV_NAME, CHARINDEX(',',ser.PROV_NAME)+2, LEN(ser.PROV_NAME)))+1,
	                       LEN(ser.PROV_NAME)))
	         ELSE ''
	       END  
	       ELSE ''
	      END AS VARCHAR(25))                               AS Atn_Dr_MI
	 
	
	,CAST(ser.PROV_TYPE AS VARCHAR(30))'Atn_Dr_Type'
	,COALESCE(CAST(ser.ACTIVE_STATUS AS VARCHAR(25)),'NA') 'Atn_Dr_Status'
	,ser2.INSTANT_OF_UPDATE_DTTM 'Atn_Dr_Last_Update_Dt'
	,typ.NAME 'Source_Name'
	,typ.TITLE 'Source_Title'
	,CAST(typ.ABBR AS VARCHAR(4)) 'Source'
	,CASE WHEN acc.ACCT_BASECLS_HA_C ='1'
			THEN 'I'
			ELSE CASE WHEN acc.ACCT_BASECLS_HA_C ='2'
			THEN 'O' END 
			END 'IO_Flag'
	,CAST(sex.ABBR AS CHAR(1)) 'SEX'
	,pt.BIRTH_DATE'Birth_Dt'
	,CAST(DATEDIFF (YEAR, pt.BIRTH_DATE, COALESCE(lst_cte.Adm_Dt,0) )AS SMALLINT) 'Age'
	,CASE WHEN DATEDIFF (YEAR, pt.BIRTH_DATE, lst_cte.Adm_Dt) >17
			THEN 'ADULT'
			ELSE 'PED'
		END 'Age_Group'
	,CONCAT(CAST(pt.PAT_FIRST_NAME AS VARCHAR(28)),' ',LEFT(pt.PAT_MIDDLE_NAME,1)) 'Pt_FName_MI'
	,CAST(pt.PAT_LAST_NAME AS VARCHAR(30)) 'Pt_LName'
	,CAST(ad1.ADDRESS AS VARCHAR(20))   'CURR_Pt_Addr1'
	,COALESCE(CAST(ad2.ADDRESS AS VARCHAR(20)),'NA') 'CURR_Pt_Addr2'
	,CAST (pt.CITY AS VARCHAR(15)) 'CURR_Pt_City'
	,CAST(st.ABBR AS VARCHAR(2)) 'CURR_PT_STATE'
	,CAST(pt.ZIP AS VARCHAR(5)) 'CURR_PT_ZIP'
	,COALESCE(CAST(pt.HOME_PHONE AS VARCHAR(15)),'NA') 'CURR_Pt_PHONE'	
	-- Split ser.Prov_Nme into Last name and First name by comma, remove JR,SR,I
	 ,CAST(CASE
	       WHEN CHARINDEX(',',gacc.ACCOUNT_NAME) > 2 THEN
	         CASE
	           WHEN CHARINDEX(' ', SUBSTRING(gacc.ACCOUNT_NAME, CHARINDEX(',',gacc.ACCOUNT_NAME)+2, LEN(gacc.ACCOUNT_NAME))) > 2 THEN
	             LTRIM(SUBSTRING(gacc.ACCOUNT_NAME,CHARINDEX(',',gacc.ACCOUNT_NAME)+1,CHARINDEX(' ', SUBSTRING(gacc.ACCOUNT_NAME, CHARINDEX(',',gacc.ACCOUNT_NAME)+2, LEN(gacc.ACCOUNT_NAME)))))
	           ELSE LTRIM(SUBSTRING(gacc.ACCOUNT_NAME, CHARINDEX(',',gacc.ACCOUNT_NAME)+1, LEN(gacc.ACCOUNT_NAME)))
	         END
	       ELSE ''
	     END AS VARCHAR(30))                               AS GUAR_FName
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
	      END AS VARCHAR(30) )                             AS GUAR_MName
	,CAST(CASE                
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
	     END AS VARCHAR(30))                           AS GUAR_LName
	   
	    
	,CAST(gacc.BILLING_ADDRESS_1 AS VARCHAR(20)) 'GUAR_ADDR1'
	,CAST (gacc.BILLING_ADDRESS_2 AS VARCHAR(20)) 'GUAR_ADDR2'
	,CAST (gacc.CITY AS VARCHAR(15)) 'GUAR_CITY'
	,CAST(guarst.ABBR AS VARCHAR (2)) 'GUAR_STATE'
	,CAST(gacc.ZIP AS VARCHAR (5)) 'GUAR_ZIP'
	,CAST (gacc.HOME_PHONE AS VARCHAR(15)) 'GUAR_PHONE'
	,CAST (rel.ABBR AS VARCHAR(1)) 'GAUR_TO_PT'
	,CAST(CASE WHEN pt4.PAT_LIVING_STAT_C='2' 
			THEN 'D' 
			ELSE '' END  AS VARCHAR(1))'Status'
	,CAST(pt.EMAIL_ADDRESS AS VARCHAR(30)) 'Email'
	,CAST(pt.PAT_ID AS VARCHAR(20)) 'PAT_ID'
	,GETDATE() 'Load_Date_Time'
/*
SELECT DISTINCT  --without distinct, results multiple rows becasue diagnosis code in multiple line
	CAST(ser.PROV_ID AS VARCHAR(30)) 'Atn_Dr'
	,CAST(serid.SMS_ID AS VARCHAR(30)) 'Atn_Dr_SMS_ID'
	,CAST(CASE                
	       WHEN CHARINDEX(',',ser.PROV_NAME) > 2 THEN
	         CASE 
	           WHEN CHARINDEX(' JR', SUBSTRING(ser.PROV_NAME,1, CHARINDEX(',', ser.PROV_NAME)-1)) > 2 THEN
	             LTRIM(SUBSTRING(ser.PROV_NAME,1, CHARINDEX(' JR', SUBSTRING(ser.PROV_NAME,1, CHARINDEX(',', ser.PROV_NAME)-1))-1))
	           WHEN CHARINDEX(' SR', SUBSTRING(ser.PROV_NAME,1, CHARINDEX(',', ser.PROV_NAME)-1)) > 2 THEN
	             LTRIM(SUBSTRING(ser.PROV_NAME,1, CHARINDEX(' SR', SUBSTRING(ser.PROV_NAME,1, CHARINDEX(',', ser.PROV_NAME)-1))-1))
	           WHEN CHARINDEX(' I', SUBSTRING(ser.PROV_NAME,1, CHARINDEX(',', ser.PROV_NAME)-1)) > 2 THEN
	             LTRIM(SUBSTRING(ser.PROV_NAME,1, CHARINDEX(' I', SUBSTRING(ser.PROV_NAME,1, CHARINDEX(',', ser.PROV_NAME)-1))-1))
	              ELSE LTRIM(SUBSTRING(ser.PROV_NAME, 1, CHARINDEX(',',ser.PROV_NAME)-1))
	         END
	       ELSE LTRIM(ser.PROV_NAME)
	     END AS VARCHAR(25))                               AS Atn_Dr_LName
	    ,CAST (CASE
	       WHEN CHARINDEX(',',ser.PROV_NAME) > 2 THEN
	         CASE
	           WHEN CHARINDEX(' ', SUBSTRING(ser.PROV_NAME, CHARINDEX(',',ser.PROV_NAME)+2, LEN(ser.PROV_NAME))) > 2 THEN
	             LTRIM(SUBSTRING(ser.PROV_NAME,CHARINDEX(',',ser.PROV_NAME)+1,CHARINDEX(' ', SUBSTRING(ser.PROV_NAME, CHARINDEX(',',ser.PROV_NAME)+2, LEN(ser.PROV_NAME)))))
	           ELSE LTRIM(SUBSTRING(ser.PROV_NAME, CHARINDEX(',',ser.PROV_NAME)+1, LEN(ser.PROV_NAME)))
	         END
	       ELSE ''
	     END AS VARCHAR(25))                                AS Atn_Dr_FName
	    ,CAST(CASE
	       WHEN CHARINDEX(',',ser.PROV_NAME) > 2 THEN -- found lastname, now look for space in first name to split middle name out
	         CASE
	           WHEN CHARINDEX(' ', SUBSTRING(ser.PROV_NAME, CHARINDEX(',',ser.PROV_NAME)+2, LEN(ser.PROV_NAME))) > 2 THEN 
	             LTRIM(SUBSTRING(SUBSTRING(ser.PROV_NAME, CHARINDEX(',',ser.PROV_NAME)+2, LEN(ser.PROV_NAME)), 
	                       CHARINDEX(' ', SUBSTRING(ser.PROV_NAME, CHARINDEX(',',ser.PROV_NAME)+2, LEN(ser.PROV_NAME)))+1,
	                       LEN(ser.PROV_NAME)))
	         ELSE ''
	       END  
	       ELSE ''
	      END AS VARCHAR(25))                               AS Atn_Dr_MI
	 
	
	,CAST(ser.PROV_TYPE AS VARCHAR(30))'Atn_Dr_Type'
	,COALESCE(CAST(ser.ACTIVE_STATUS AS VARCHAR(25)),'NA') 'Atn_Dr_Status'
	,ser2.INSTANT_OF_UPDATE_DTTM 'Atn_Dr_Last_Update_Dt'
	,GETDATE() 'Load_Date_Time'
*/
INTO #gpp

--FROM CLARITY.dbo.CLARITY_SER ser
--			INNER JOIN lst_cte								ON lst_cte.Prov_ID = ser.PROV_ID
--			INNER JOIN CLARITY.dbo.PATIENT pt						ON pt.PAT_ID = lst_cte.PAT_ID
--			INNER JOIN CLARITY.dbo.clarity_ser_2 ser2					ON ser2.PROV_ID = ser.PROV_ID
FROM lst_cte
            LEFT OUTER JOIN CLARITY.dbo.CLARITY_SER ser                 ON ser.PROV_ID = lst_cte.Prov_ID
			LEFT OUTER JOIN CLARITY.dbo.PATIENT pt						ON pt.PAT_ID = lst_cte.PAT_ID
			LEFT OUTER JOIN CLARITY.dbo.clarity_ser_2 ser2					ON ser2.PROV_ID = ser.PROV_ID
			--INNER JOIN dbo.IDENTITY_ID idx					ON pt.PAT_ID=idx.PAT_ID
			LEFT OUTER JOIN CLARITY.dbo.ZC_DISP_ENC_TYPE typ		ON typ.DISP_ENC_TYPE_C=lst_cte.ENC_TYPE_C
			LEFT OUTER JOIN CLARITY.dbo.ZC_SEX sex					ON pt.SEX_C=sex.RCPT_MEM_SEX_C	
			LEFT OUTER JOIN CLARITY.dbo.ZC_STATE st						ON st.STATE_C = pt.STATE_C
			LEFT OUTER JOIN CLARITY.dbo.PAT_ADDRESS ad1					ON ad1.PAT_ID = pt.PAT_ID
																			 AND ad1.line=1
			LEFT OUTER JOIN CLARITY.dbo.PAT_ADDRESS ad2					ON ad2.PAT_ID = pt.PAT_ID
																			 AND ad2.line=2
			LEFT OUTER JOIN CLARITY.dbo.ACCOUNT gacc						ON lst_cte.Guar_ID=gacc.ACCOUNT_ID
			
			LEFT OUTER JOIN CLARITY.dbo.ZC_STATE guarst				ON gacc.STATE_C =guarst.STATE_C															
			LEFT OUTER JOIN CLARITY.dbo.HSP_ACCOUNT acc				ON acc.HSP_ACCOUNT_ID = lst_cte.Hsp_Acct
			LEFT OUTER JOIN CLARITY.dbo.ZC_ACCT_BASECLS_HA bcls		ON bcls.ACCT_BASECLS_HA_C = acc.ACCT_BASECLS_HA_C
			LEFT OUTER JOIN CLARITY.dbo.ACCOUNT_STATUS	accst		ON lst_cte.Hsp_Acct= accst.ACCOUNT_ID 
			LEFT OUTER JOIN CLARITY.dbo.HSP_ACCT_DX_LIST dx			ON lst_cte.Hsp_Acct=dx.HSP_ACCOUNT_ID
																--AND dx.line=1
			LEFT OUTER JOIN CLARITY.dbo.CLARITY_EDG edg				ON edg.DX_ID=dx.DX_ID
			LEFT OUTER JOIN CLARITY.dbo.ACCOUNT_FPL_INFO fpl		ON lst_cte.Hsp_Acct = fpl.ACCOUNT_ID
			LEFT OUTER JOIN clarity_App.Rptg.ADT_Red_Folder_Extract Rd				ON rd.Acc_ID=acc.HSP_ACCOUNT_ID
			LEFT OUTER JOIN CLARITY.dbo.PATIENT_4 pt4				ON pt.PAT_ID=pt4.PAT_ID
			LEFT OUTER JOIN CLARITY.dbo.ACCT_GUAR_PAT_INFO rship	ON rship.ACCOUNT_ID = gacc.ACCOUNT_ID
			LEFT OUTER JOIN CLARITY.dbo.ZC_GUAR_REL_TO_PAT rel		ON rel.GUAR_REL_TO_PAT_C = rship.GUAR_REL_TO_PAT_C
			LEFT OUTER JOIN (SELECT idxser.IDENTITY_ID 'SMS_ID'
			,idxser.PROV_ID
								FROM CLARITY.dbo.IDENTITY_SER_ID idxser
								WHERE  idxser.IDENTITY_TYPE_ID  ='6') serid		ON serid.PROV_ID=ser.PROV_ID
/*
WHERE ser.PROV_TYPE <>'Resource'
		--AND idx.IDENTITY_TYPE_ID='14'
	
		AND (
				ISNULL(acc.ACCT_FIN_CLASS_C,1)<> '3' --K: Medicaid
					OR (
						ISNULL(acc.ACCT_SLFPYST_HA_C,1)<>'5'  -- 1,2,4,5,6,7,8: Bad Debt
					--indegent care flag***************
					OR (fpl.FPL_STATUS_CODE_C NOT IN ('34','36','38','40','42') --verified 100%;95%;80%;55%;30% respectively- fpl assistance  for indegent care
									AND (fpl.FPL_EFF_DATE >=@StartDate AND fpl.FPL_EFF_DATE <@EndDate))
					OR ISNULL(accst.ACCOUNT_STATUS_C,1) <>'105'   --legal ; 3: collection ??
						)
				)

	AND (
				
						(DATEDIFF (YEAR, pt.BIRTH_DATE, lst_cte.Adm_Dt) >18 
								AND 
										(	edg.ICD9_CODE IS NULL 
										OR edg.ICD9_CODE NOT IN ('078.1','795.8','V08','V27.1','V27.3','V27.4','V27.6','V27.7') 
										OR edg.ICD9_CODE NOT BETWEEN '042' AND '044.9' 
										OR edg.ICD9_CODE NOT BETWEEN '054.10' AND '054.19' 
										OR edg.ICD9_CODE NOT BETWEEN '079.51' AND '079.53' 
										OR edg.ICD9_CODE NOT BETWEEN '090.0' AND '099.9' 
										OR edg.ICD9_CODE NOT BETWEEN '279.10' AND '279.19' 
										OR edg.ICD9_CODE NOT BETWEEN '632' AND '639.99' 
										)
						)
				
			
						OR
		
						(DATEDIFF (YEAR, pt.BIRTH_DATE, lst_cte.Adm_Dt) <=18
								AND 
										(	edg.ICD9_CODE IS NULL
										OR  edg.ICD9_CODE NOT BETWEEN '640.0'   AND '676.94' 
										OR	edg.ICD9_CODE NOT BETWEEN 'V22.0'   AND 'V25.9'
										OR  edg.ICD9_CODE NOT BETWEEN '042'	    AND '044.9' 
										OR  edg.ICD9_CODE NOT BETWEEN '054.10'  AND '054.19' 
										OR  edg.ICD9_CODE NOT BETWEEN '079.51'  AND '079.53'
										OR  edg.ICD9_CODE NOT BETWEEN '090.0'   AND '099.9' 
										OR  edg.ICD9_CODE NOT BETWEEN '279.10'  AND '279.19' 
										OR  edg.ICD9_CODE NOT BETWEEN '632'     AND '639.99' 
										OR  edg.ICD9_CODE NOT IN ('078.1','795.8','V08','V27.1','V27.3','V27.4','V27.6','V27.7') 
										)
						)
				)
			
				AND rd.Acc_ID IS NULL --not in red folder extract
				--AND SUBSTRING(CAST(CASE                
	   --    WHEN CHARINDEX(',',ser.PROV_NAME) > 2 THEN
	   --      CASE 
	   --        WHEN CHARINDEX(' JR', SUBSTRING(ser.PROV_NAME,1, CHARINDEX(',', ser.PROV_NAME)-1)) > 2 THEN
	   --          LTRIM(SUBSTRING(ser.PROV_NAME,1, CHARINDEX(' JR', SUBSTRING(ser.PROV_NAME,1, CHARINDEX(',', ser.PROV_NAME)-1))-1))
	   --        WHEN CHARINDEX(' SR', SUBSTRING(ser.PROV_NAME,1, CHARINDEX(',', ser.PROV_NAME)-1)) > 2 THEN
	   --          LTRIM(SUBSTRING(ser.PROV_NAME,1, CHARINDEX(' SR', SUBSTRING(ser.PROV_NAME,1, CHARINDEX(',', ser.PROV_NAME)-1))-1))
	   --        WHEN CHARINDEX(' I', SUBSTRING(ser.PROV_NAME,1, CHARINDEX(',', ser.PROV_NAME)-1)) > 2 THEN
	   --          LTRIM(SUBSTRING(ser.PROV_NAME,1, CHARINDEX(' I', SUBSTRING(ser.PROV_NAME,1, CHARINDEX(',', ser.PROV_NAME)-1))-1))
	   --           ELSE LTRIM(SUBSTRING(ser.PROV_NAME, 1, CHARINDEX(',',ser.PROV_NAME)-1))
	   --      END
	   --    ELSE LTRIM(ser.PROV_NAME)
	   --  END AS VARCHAR(25)),1,1) = 'K'
	   --AND pt.PAT_ID = 'Z553246'
*/
SELECT *
FROM #gpp

--ORDER BY 	Atn_Dr_LName, Atn_Dr_FName, Adm_Dt
--ORDER BY 	Atn_Dr_LName, Atn_Dr_FName
--ORDER BY 	Adm_Dt
ORDER BY 	PAT_ID, Adm_Dt
/****************************************************************************************/





GO


