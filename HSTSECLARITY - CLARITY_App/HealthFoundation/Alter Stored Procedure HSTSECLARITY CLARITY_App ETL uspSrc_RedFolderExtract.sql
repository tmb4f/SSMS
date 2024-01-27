USE [CLARITY_App]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Mali Amarasinghe
-- Create date: 01/26/2017
-- Description:	Red Folder Patients with a Risk Management indicator
-- Edits:
--				03/03/2022 TMB - Change Billing Indicator Codes identifying Red Folder patients
--					181 – Risk Management – Hold Ins PB/HB & Guarantor Statement  (account level)
--					270 – Risk Management – Hold Guarantor Statement this HAR (account level) 
--					564 – Risk Management  - Hold ALL Guarantor Statements (guarantor level)
--					494 – Risk Management – Hold ALL PB/HB HARs & Guarantor Statements (guarantor level) 
--
-- =============================================
--EXEC  [ETL].[uspSrc_RedFolderExtract] 

ALTER PROCEDURE [ETL].[uspSrc_RedFolderExtract] 
	-- Add the parameters for the stored procedure here
	--@StartDate DATETIME,-- = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-3, 0), 
	--@EndDate DATETIME -- = GETDATE()
AS

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

DECLARE @Startdate DATE  = NULL;
DECLARE @Enddate DATE = NULL;
    
 
        SET @StartDate  = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-3, 0);
        SET @EndDate = DATEADD(dd,-1,GETDATE());
 
  
   -- END;
	
    -- Insert statements for procedure here
/*	
IF OBJECT_ID('Clarity_App_Dev..ADT_Red_Folder_Extract') IS NOT NULL
DROP TABLE CLARITY_App_Dev.dbo.ADT_Red_Folder_Extract 

CREATE TABLE Clarity_App_Dev.dbo.ADT_Red_Folder_Extract
(
Acc_Id INT
,MRN INT
,Bill_Indc_Date DATETIME
,ETL_Guid VARCHAR(55)
,Load_Dtm DATETIME
)

INSERT INTO Clarity_App_Dev.dbo.ADT_Red_Folder_Extract */
SELECT ind.ACCT_ID 'Acc_id'
		,CAST(idx.IDENTITY_ID AS VARCHAR(50)) AS  MRN                    ----BDD 10/11/2018 cast for epic upgrade
		,ind.BILL_INDC_INSTANT 'Bill_Indc_Date'
		,'Rptg.uspSrc.Red_Folder_Extract' 'ETL_Guid'
		,GETDATE() 'Load_Dtm'

FROM [CLARITY].dbo.HSP_ACCT_BILL_IND ind
		INNER JOIN [CLARITY].dbo.PAT_ENC_HSP hsp		ON ind.ACCT_ID= hsp.HSP_ACCOUNT_ID
		INNER JOIN [CLARITY].dbo.IDENTITY_ID idx		ON idx.PAT_ID = hsp.PAT_ID

WHERE ind.BILL_IND_C IN (181,270,494,564)  --Risk Management, Stop Bill ind
		AND(ind.BILL_INDC_INSTANT>=@StartDate AND ind.BILL_INDC_INSTANT<=@EndDate)
		AND idx.IDENTITY_TYPE_ID=14

GO


