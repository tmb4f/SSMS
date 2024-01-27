USE [DS_HSDM_App_Dev]
GO

IF EXISTS (SELECT 1 
    FROM INFORMATION_SCHEMA.TABLES 
    WHERE TABLE_SCHEMA='ETL'
    AND TABLE_TYPE='BASE TABLE' 
    AND TABLE_NAME='Kronos_Census')
   DROP TABLE ETL.Kronos_Census
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [ETL].[Kronos_Census](
    [EPIC_DEPARTMENT_ID] [VARCHAR](8) NULL
  , [EPIC_DEPARTMENT_NAME] [VARCHAR](254) NULL
  , [CENSUS] [INT] NULL
  , [CENSUS_DTTM] [DATETIME] NULL
  , [Load_Dtm] SMALLDATETIME NOT NULL
) ON [PRIMARY]
GO

ALTER TABLE [ETL].[Kronos_Census] ADD DEFAULT (GETDATE()) FOR [Load_Dtm]
GO

GRANT ALTER, DELETE, INSERT, SELECT, UPDATE ON [ETL].[Kronos_Census] TO [HSCDOM\Decision Support]
GO

SET ANSI_PADDING OFF
GO