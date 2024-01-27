USE [DS_HSDM_App]
GO

-- ===========================================
-- Create table Rptg.GC_Bridge_Plan_Reg_WQ
-- ===========================================
IF EXISTS (SELECT TABLE_NAME 
	       FROM   INFORMATION_SCHEMA.TABLES
	       WHERE  TABLE_SCHEMA = N'Rptg' AND
	              TABLE_NAME = N'GC_Bridge_Plan_Reg_WQ')
   DROP TABLE [Rptg].[GC_Bridge_Plan_Reg_WQ]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Rptg].[GC_Bridge_Plan_Reg_WQ](
	[IDENTITY_ID] [varchar](100) NULL,
	[REG_HX_AFF_PAT_CSN] NUMERIC(18,0) NULL,
	[HSP_ACCOUNT_ID] NUMERIC(18,0) NULL,
	[REG_HX_INST_UTC_DTTM] DATETIME NULL,
	[CONTACT_DATE] DATETIME NULL,
	[REG_HX_AFF_WQ_ID] [varchar](18) NULL,
	[WORKQUEUE_NAME] [varchar](200) NULL,
	[REG_HX_AFF_RULE_ID] VARCHAR(18) NULL,
	[RULE_NAME] VARCHAR(254) NULL
) ON [PRIMARY]
GO

GRANT DELETE, INSERT, SELECT, UPDATE ON [Rptg].[GC_Bridge_Plan_Reg_WQ] TO [HSCDOM\Decision Support]
GO


