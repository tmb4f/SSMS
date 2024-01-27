USE [DS_HSDM_App_Dev]
GO

IF EXISTS (SELECT 1 
    FROM INFORMATION_SCHEMA.TABLES 
    WHERE TABLE_SCHEMA='ETL'
    AND TABLE_TYPE='BASE TABLE' 
    AND TABLE_NAME='LD_Census')
   DROP TABLE ETL.LD_Census
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [ETL].[LD_Census](
    [CENSUS_DT] [DATE] NULL
  , [CENSUS_TM_INT] [INT] NULL
  , [CENSUS_TM] [TIME] NULL
  , [COUNT_1] [VARCHAR](50) NULL
  , [COUNT_2] [VARCHAR](50) NULL
  , [COUNT_3] [VARCHAR](50) NULL
  , [COUNT_4] [VARCHAR](50) NULL
  , [COUNT_5] [VARCHAR](50) NULL
  , [COUNT_6] [VARCHAR](50) NULL
  , [COUNT_7] [VARCHAR](50) NULL
  , [COUNT_8] [VARCHAR](50) NULL
  , [COUNT_9] [VARCHAR](50) NULL
) ON [PRIMARY]
GO

--ALTER TABLE [ETL].[Kronos_Census] ADD DEFAULT (GETDATE()) FOR [Load_Dtm]
--GO

GRANT ALTER, DELETE, INSERT, SELECT, UPDATE ON [ETL].[LD_Census] TO [HSCDOM\Decision Support]
GO

SET ANSI_PADDING OFF
GO