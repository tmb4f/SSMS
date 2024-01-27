USE [CLARITY_App]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--ALTER PROCEDURE [Rptg].[uspLoad_EpicStatusBoard]
--(
-- @strBegindt AS VARCHAR(19) = NULL
-- ,@strEnddt AS VARCHAR(19) = NULL
-- ,@Manual AS VARCHAR(1) = NULL
--)
----WITH EXECUTE AS OWNER
--AS
/*******************************************************************************************
WHAT:	Epic status Board  - Populate Rptg Table in DM - default date range BOLY
WHO :	Marlene Jones
WHEN:	3/3/2016
WHY :	FOR SSIS Package - USER may USE SSRS OR Rptg.vw - TBD 
NOTE:   Written FOR Clarity - original TSQL - Joanne Casey
--------------------------------------------------------------------------------------------
MODS: 
	    BDD 03/09/2016 - altered for SSIS run from Clarity_App database
		JSC 10/16/2018 - subtring MRN for Epic 2018
		JSC 03/20/2019 - removed order by 
************************************************************************************/

SET NOCOUNT ON 

-- Declare needed variables:
DECLARE @strBegindt as varchar(19) = NULL, @strEnddt as varchar(19) = NULL, @Manual varchar(11) = NULL
SET @strBegindt = NULL
SET @strEnddt = NULL
SET @Manual = NULL
--Set date variables

IF @strBegindt IS NULL OR LEN(@strBegindt) = 0
	-- last x days
		--SET @strBegindt = CONVERT(VARCHAR(8), GETDATE()- 8, 112) + ' 00:00:00'
	-- Beginning of Previous month
		--SET @strBegindt = CONVERT(VARCHAR(8), DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0), 112) + ' 00:00:00'
	-- Beginning of Previous Year
		SET @strBegindt = CONVERT(VARCHAR(8), DATEADD(YEAR, DATEDIFF(YEAR, 0, GETDATE())-1, 0), 112) + ' 00:00:00'
ELSE
	SET @strBegindt = CONVERT(VARCHAR(8), CAST(@strBegindt AS DATETIME), 112) + ' 00:00:00'


IF @strEnddt  IS NULL OR LEN(@strEnddt) = 0
	---- today
		SET @strEnddt = CONVERT(VARCHAR(8), GETDATE(), 112) + ' 23:59:59'
	-- End of Previous month
		--SET @strEnddt = CONVERT(VARCHAR(8), DATEADD(MONTH, DATEDIFF(MONTH, -1, GETDATE())-1, -1), 112) + ' 23:59:59'
ELSE
	SET @strEnddt = CONVERT(VARCHAR(8), CAST(@strEnddt AS DATETIME), 112) + ' 23:59:59'


DECLARE @dteBegindt AS SMALLDATETIME = NULL, @dteEnddt AS SMALLDATETIME = NULL
SET @dteBegindt = CAST(@strBegindt AS SMALLDATETIME)
SET @dteEnddt = CAST(@strEnddt AS SMALLDATETIME) 


--Print 'Begin: ' + @strBegindt
--Print 'End:   ' + @strEnddt
--20150206 00:00:00
--20150209 23:59:59


SELECT CONVERT(VARCHAR(25),pt.PAT_MRN_ID) AS PAT_MRN_ID
	,pt.PAT_LAST_NAME			
	,pt.PAT_FIRST_NAME				
	,CONVERT(VARCHAR(10), pt.BIRTH_DATE, 110) [BIRTH_DATE]	
	,einf.EVENT_TYPE [EVENT_TYPE_ID]		
	,einf.EVENT_ID					
	,einf.EVENT_DISPLAY_NAME		
	,einf.EVENT_CMT					
	,CAST(pe.APPT_TIME AS SMALLDATETIME) [APPT_TIME]					
	,CAST(einf.EVENT_TIME AS SMALLDATETIME)	[EVENT_TIME]
	,CAST(einf.EVENT_RECORD_TIME AS SMALLDATETIME) [EVENT_RECORD_TIME]
	,dep.DEPARTMENT_ID
	,dep.DEPARTMENT_NAME
	,servisit.PROV_ID			
	,servisit.PROV_NAME	
	,ENC_TYPE_C [ENC_TYPE_ID]			
	,ztype.NAME	[ENC_TYPE]
	,emp.USER_ID [EMP_ID]				
	,emp.NAME [EMP_NAME]						
	,ptype.NAME [EMP_ROLE]
	,pe.PAT_ID						
	,pe.PAT_ENC_CSN_ID				
FROM CLARITY.dbo.ED_IEV_EVENT_INFO einf	
INNER JOIN CLARITY.dbo.ED_IEV_PAT_INFO pinf			ON einf.EVENT_ID = pinf.EVENT_ID
INNER JOIN CLARITY.dbo.PAT_ENC pe					ON pinf.PAT_ENC_CSN_ID = pe.PAT_ENC_CSN_ID
INNER JOIN CLARITY.dbo.PATIENT pt					ON pinf.pat_id = pt.PAT_ID
INNER JOIN CLARITY.dbo.CLARITY_DEP dep				ON pe.DEPARTMENT_ID = dep.DEPARTMENT_ID
INNER JOIN CLARITY.dbo.ZC_DISP_ENC_TYPE ztype		ON ztype.DISP_ENC_TYPE_C = pe.ENC_TYPE_C
INNER JOIN CLARITY.dbo.CLARITY_EMP emp				ON einf.EVENT_USER_ID = emp.USER_ID
LEFT JOIN  CLARITY.dbo.CLARITY_SER ser				ON emp.PROV_ID = ser.PROV_ID
LEFT JOIN  CLARITY.dbo.CLARITY_SER servisit			ON pe.VISIT_PROV_ID = servisit.PROV_ID
LEFT JOIN  CLARITY.dbo.ZC_PROV_TYPE ptype			ON ser.PROVIDER_TYPE_C = ptype.PROV_TYPE_C
WHERE 
	pe.APPT_TIME BETWEEN @dteBegindt AND @dteEnddt
	AND (ztype.NAME NOT LIKE 'Erroneous%')
	AND (pe.APPT_TIME IS NOT NULL)
	AND (einf.EVENT_DISPLAY_NAME IS NOT NULL)

ORDER BY PAT_MRN_ID,
         APPT_TIME,
		 PAT_ENC_CSN_ID,
		 EVENT_TIME



/*  ---BDD 3/7/2016 changed for running from the Clarity server within an SSIS package
	----Determine if run is automated or manual
	IF @Manual IS NULL	   
		BEGIN
			TRUNCATE TABLE Rptg.EpicStatusBoard
			INSERT INTO Rptg.EpicStatusBoard
			SELECT * FROM #RptgTemp 			
		END 
	ELSE
*/









GO


