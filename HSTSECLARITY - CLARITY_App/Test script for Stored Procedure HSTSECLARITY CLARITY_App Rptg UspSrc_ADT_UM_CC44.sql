USE [CLARITY_App]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================

/*******************************************************************************************
WHAT:	[Rptg].[UspSrc_ADT_UM_CC44]
WHO :	Utilization Management 
WHEN:	Ad Hoc SSRS
WHY :	Medicare CC44 Billing Edits by UM 
AUTHOR:	Mali Amarasinghe
SPEC:	
--------------------------------------------------------------------------------------------
INPUTS: 	       
			
		
OUTPUTS: 
   	1) SEQUENCE:				File 1 of 1
   	2) FILE NAMING CONVENTION:	SSRS Rpt: CC44
   	3) OUTPUT TYPE:				SSRS
   	4) TRANSFER METHOD:			
   	5) OUTPUT LOCATION:			
   	6) FREQUENCY:				
   	7) QUERY LOOKBACK PERIOD:	
   	8) FILE SPECIFIC NOTES:		
		CC44  are cases with a UM reviewed status of  "INPATIENT ADMISSION CHANGED TO OUTPATIENT"
		Inc44 are cases with a UM reviewed status of  "UM Medicare Provider Liable"
		Non-Covered are cases with a UM reviewed status of  " Medicare- Non Covered Day"
    
--------------------------------------------------------------------------------------------
MODS: 
	02/02/18 - Initial draft created
	
*******************************************************************************************/

--EXEC Clarity_App_Dev.[Rptg].[UspSrc_ADT_UM_CC44] @StartDate='5/1/2017', @EndDate ='5/20/2017'

--ALTER PROCEDURE [Rptg].[UspSrc_ADT_UM_CC44]
--	-- Add the parameters for the stored procedure here
--	@StartDate DATETIME, 
--	@EndDate DATETIME
--AS

DECLARE @StartDate AS DATETIME, @EndDate AS DATETIME

SET @StartDate = '10/1/2020'
SET @EndDate = '12/31/2020'

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

;WITH Src_cc44 AS
(
SELECT cc.ACCT_ID
		,(SELECT TOP 1 lst_atdn.PROV_ID
				FROM CLARITY.dbo.HSP_ATND_PROV lst_atdn
				WHERE lst_atdn.PAT_ENC_CSN_ID=acct.PRIM_ENC_CSN_ID
				ORDER BY ATTEND_TO_DATE DESC
				) 'Lst_Atdn'
				,acct.DISCH_DEPT_ID	'cc44DEPARTMENT_NAME'
				,acct.DISCH_DATE_TIME
				,acct.ACCT_CLASS_HA_C
				,acct.PRIM_ENC_CSN_ID
				,cds.NAME 'Sts'
FROM CLARITY.dbo.HSP_ACCT_COND_HAR cc
	INNER JOIN CLARITY.dbo.HSP_ACCOUNT acct				ON acct.HSP_ACCOUNT_ID=cc.ACCT_ID
	LEFT OUTER JOIN CLARITY.dbo.ZC_COND_CODES_HA cds	ON cds.COND_CODES_HA_C=cc.CONDITION_CODE_C
	
 WHERE cc.CONDITION_CODE_C='44'	
		AND CAST(acct.DISCH_DATE_TIME AS DATE)>=@StartDate
			AND CAST(acct.DISCH_DATE_TIME AS DATE)<=@EndDate
)

,Src_inc44 AS
(
SELECT har.HSP_ACCOUNT_ID
		,(SELECT TOP 1 lst_atdn.PROV_ID
				FROM CLARITY.dbo.HSP_ATND_PROV lst_atdn
				WHERE lst_atdn.PAT_ENC_CSN_ID=har.PRIM_ENC_CSN_ID
				ORDER BY ATTEND_TO_DATE DESC
				) 'Lst_Atdn'
		,har.DISCH_DEPT_ID	'incDEPARTMENT_NAME'
		,har.DISCH_DATE_TIME
		,har.ACCT_CLASS_HA_C
		,har.PRIM_ENC_CSN_ID
		,sts.NAME'Sts'
FROM CLARITY.dbo.HSP_ACCOUNT har							--ON enc.PAT_ENC_CSN_ID = har.PRIM_ENC_CSN_ID
	LEFT OUTER JOIN CLARITY.dbo.referral_cvg_auth rauth					ON rauth.REFERRAL_ID =har.ASSOC_AUTHCERT_ID AND rauth.AUTH_CERT_CVG_ID = har.COVERAGE_ID
	LEFT OUTER JOIN CLARITY.dbo.REFERRAL_CVG  rlf						ON rauth.REFERRAL_ID = rlf.REFERRAL_ID AND rlf.CVG_ID = har.COVERAGE_ID													
	LEFT OUTER JOIN CLARITY.dbo.COVERAGE c								ON rlf.CVG_ID = c.COVERAGE_ID
	LEFT OUTER JOIN CLARITY.dbo.RFL_CVG_DEN_RSN_C denrsn				ON denrsn.REFERRAL_ID=rauth.REFERRAL_ID
	LEFT OUTER JOIN CLARITY.dbo.ZC_PRE_CERT_STATUS sts							ON sts.PRE_CERT_STATUS_C = rauth.PRE_CERT_STATUS_C
WHERE CAST(har.DISCH_DATE_TIME AS DATE)>=@StartDate
			AND CAST(har.DISCH_DATE_TIME AS DATE)<=@EndDate
			AND rauth.PRE_CERT_STATUS_C='310227'
)

,Src_Ncvr AS
(
SELECT har.HSP_ACCOUNT_ID
		,(SELECT TOP 1 lst_atdn.PROV_ID
				FROM CLARITY.dbo.HSP_ATND_PROV lst_atdn
				WHERE lst_atdn.PAT_ENC_CSN_ID=har.PRIM_ENC_CSN_ID
				ORDER BY ATTEND_TO_DATE DESC
				) 'Lst_Atdn'
		,har.DISCH_DEPT_ID	'NcvrDEPARTMENT_NAME'
		,har.DISCH_DATE_TIME
		,har.ACCT_CLASS_HA_C
		,har.PRIM_ENC_CSN_ID
		,rsn.NAME'Sts'
FROM CLARITY.dbo.HSP_ACCOUNT har							--ON enc.PAT_ENC_CSN_ID = har.PRIM_ENC_CSN_ID
	LEFT OUTER JOIN CLARITY.dbo.referral_cvg_auth rauth					ON rauth.REFERRAL_ID =har.ASSOC_AUTHCERT_ID AND rauth.AUTH_CERT_CVG_ID = har.COVERAGE_ID
	LEFT OUTER JOIN CLARITY.dbo.REFERRAL_CVG  rlf						ON rauth.REFERRAL_ID = rlf.REFERRAL_ID AND rlf.CVG_ID = har.COVERAGE_ID													
	LEFT OUTER JOIN CLARITY.dbo.COVERAGE c								ON rlf.CVG_ID = c.COVERAGE_ID
	LEFT OUTER JOIN CLARITY.dbo.RFL_CVG_DEN_RSN_C denrsn				ON denrsn.REFERRAL_ID=rauth.REFERRAL_ID
	LEFT OUTER JOIN CLARITY.dbo.ZC_DENIED_REASON rsn							ON rsn.DENIED_REASON_C = denrsn.DENIED_REASON_C
WHERE CAST(har.DISCH_DATE_TIME AS DATE)>=@StartDate
			AND CAST(har.DISCH_DATE_TIME AS DATE)<=@EndDate
			AND denrsn.DENIED_REASON_C='31013'
)

SELECT Src_cc44.*
		,COALESCE(phs.Service_Line, 'No Value specified') 'Service_Line'
		,dep.DEPARTMENT_NAME
		,prov.PROV_NAME
		,prov.PROV_TYPE
		,prov.PROV_ID
		,ser.NPI
		,dte.fmonth_num
		,dte.month_name
		,cls.NAME 'Acct_Class'
		,'CC44' 'CC'
FROM Src_cc44
		INNER JOIN CLARITY.dbo.CLARITY_SER_2 ser				ON Src_cc44.Lst_Atdn =ser.PROV_ID
		INNER JOIN CLARITY.dbo.CLARITY_SER prov					ON prov.PROV_ID = ser.PROV_ID
		INNER JOIN (SELECT phy.NPINumber
					,MAX(phy.lastupdate) 'Last_update'
					,MAX(phy.Service_Line)'Service_Line'
					FROM clarity_app.dbo.Dim_Physcn phy
					GROUP BY phy.NPINumber) phs				ON   CAST(ser.NPI AS VARCHAR(15) )=phs.NPINumber
		INNER JOIN CLARITY.dbo.CLARITY_DEP dep							ON Src_cc44.cc44DEPARTMENT_NAME=dep.DEPARTMENT_ID
		INNER JOIN CLARITY_App.dbo.Dim_Date dte					ON CAST(Src_cc44.DISCH_DATE_TIME AS DATE) = CAST(dte.day_date AS DATE)
		INNER JOIN CLARITY.dbo.ZC_ACCT_CLASS_HA cls						ON cls.ACCT_CLASS_HA_C = Src_cc44.ACCT_CLASS_HA_C
UNION 
SELECT Src_inc44.*
		,COALESCE(phs.Service_Line, 'No Value specified') 'Service_Line'
		,dep.DEPARTMENT_NAME
		,prov.PROV_NAME
		,prov.PROV_TYPE
		,prov.PROV_ID
		,ser.NPI
		,dte.fmonth_num
		,dte.month_name
		,cls.NAME 'Acct_Class'
		,'INC44' 'CC'
FROM Src_inc44
		INNER JOIN CLARITY.dbo.CLARITY_SER_2 ser				ON Src_inc44.Lst_Atdn =ser.PROV_ID
		INNER JOIN CLARITY.dbo.CLARITY_SER prov					ON prov.PROV_ID = ser.PROV_ID
		INNER JOIN (SELECT phy.NPINumber
					,MAX(phy.lastupdate) 'Last_update'
					,MAX(phy.Service_Line)'Service_Line'
					FROM clarity_app.dbo.Dim_Physcn phy
					GROUP BY phy.NPINumber) phs				ON   CAST(ser.NPI AS VARCHAR(15) )=phs.NPINumber
		INNER JOIN CLARITY.dbo.CLARITY_DEP dep							ON Src_inc44.incDEPARTMENT_NAME=dep.DEPARTMENT_ID
		INNER JOIN CLARITY_App.dbo.Dim_Date dte					ON CAST(Src_inc44.DISCH_DATE_TIME AS DATE) = CAST(dte.day_date AS DATE)
		INNER JOIN CLARITY.dbo.ZC_ACCT_CLASS_HA cls						ON cls.ACCT_CLASS_HA_C = Src_inc44.ACCT_CLASS_HA_C
UNION
SELECT Src_Ncvr.*
		,COALESCE(phs.Service_Line, 'No Value specified') 'Service_Line'
		,dep.DEPARTMENT_NAME
		,prov.PROV_NAME
		,prov.PROV_TYPE
		,prov.PROV_ID
		,ser.NPI
		,dte.fmonth_num
		,dte.month_name
		,cls.NAME 'Acct_Class'
		,'Non-Covered'	'CC'
FROM Src_Ncvr
		INNER JOIN CLARITY.dbo.CLARITY_SER_2 ser				ON Src_Ncvr.Lst_Atdn =ser.PROV_ID
		INNER JOIN CLARITY.dbo.CLARITY_SER prov					ON prov.PROV_ID = ser.PROV_ID
		INNER JOIN (SELECT phy.NPINumber
					,MAX(phy.lastupdate) 'Last_update'
					,MAX(phy.Service_Line)'Service_Line'
					FROM clarity_app.dbo.Dim_Physcn phy
					GROUP BY phy.NPINumber) phs				ON   CAST(ser.NPI AS VARCHAR(15) )=phs.NPINumber
		INNER JOIN CLARITY.dbo.CLARITY_DEP dep							ON Src_Ncvr.NcvrDEPARTMENT_NAME=dep.DEPARTMENT_ID
		INNER JOIN CLARITY_App.dbo.Dim_Date dte					ON CAST(Src_Ncvr.DISCH_DATE_TIME AS DATE) = CAST(dte.day_date AS DATE)
		INNER JOIN CLARITY.dbo.ZC_ACCT_CLASS_HA cls						ON cls.ACCT_CLASS_HA_C = Src_Ncvr.ACCT_CLASS_HA_C		

--ORDER BY Src_cc44.DISCH_DATE_TIME	
--ORDER BY Src_cc44.ACCT_ID, prov.PROV_NAME, Src_cc44.DISCH_DATE_TIME	
ORDER BY prov.PROV_NAME, Src_cc44.DISCH_DATE_TIME	
 
GO


