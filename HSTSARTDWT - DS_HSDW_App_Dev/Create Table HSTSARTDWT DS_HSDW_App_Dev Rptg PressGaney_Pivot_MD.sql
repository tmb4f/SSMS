USE [DS_HSDW_App_Dev]
GO

-- ===========================================
-- Create table Rptg.PressGaney_Pivot_MD
-- ===========================================
IF EXISTS (SELECT TABLE_NAME 
	       FROM   INFORMATION_SCHEMA.TABLES
	       WHERE  TABLE_SCHEMA = N'Rptg' AND
	              TABLE_NAME = N'PressGaney_Pivot_MD')
   DROP TABLE [Rptg].[PressGaney_Pivot_MD]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [Rptg].[PressGaney_Pivot_MD](
	[SURVEY_ID] [VARCHAR](20) NULL,
	[RECDATE] [SMALLDATETIME] NULL,
	[ITCSN] [VARCHAR](20) NULL,
	[ITSERVTY] [VARCHAR](20) NULL,
	[CG_26CL] [VARCHAR](20) NULL,
	[O4] [VARCHAR](20) NULL
) ON [PRIMARY]
GO

GRANT DELETE, INSERT, SELECT, UPDATE ON [Rptg].[PressGaney_Pivot_MD] TO [HSCDOM\Decision Support]
GO


