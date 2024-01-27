USE [DS_HSDW_App_Dev]
GO

-- ===========================================
-- Create table Rptg.MD2561data
-- ===========================================
IF EXISTS (SELECT TABLE_NAME 
	       FROM   INFORMATION_SCHEMA.TABLES
	       WHERE  TABLE_SCHEMA = N'Rptg' AND
	              TABLE_NAME = N'MD2561data')
   DROP TABLE [Rptg].[MD2561data]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [Rptg].[MD2561data](
	[SVC_CDE] [VARCHAR](20) NULL,
	[CLIENT_ID] [VARCHAR](20) NULL,
	[BARCODE] [VARCHAR](20) NULL
) ON [PRIMARY]
GO

GRANT DELETE, INSERT, SELECT, UPDATE ON [Rptg].[MD2561data] TO [HSCDOM\Decision Support]
GO


