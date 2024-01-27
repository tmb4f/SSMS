USE DS_HSDW_Prod
-- ====================================
-- Create view VwPidxPatient_Deceased
-- ====================================
--IF EXISTS (SELECT TABLE_NAME 
--	   FROM   INFORMATION_SCHEMA.VIEWS 
--	   WHERE  TABLE_NAME = N'VwPidxPatient_Deceased')
--    DROP VIEW VwPidxPatient_Deceased
--GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

--CREATE VIEW Rptg.VwPidxPatient_Deceased
--AS
--SELECT [sk_Dim_Pt] AS 'SK_DIM_PT'
--     , [MED_REC_DISPLAY] AS 'MRN'
--  FROM [dbo].[Dim_Pt] WITH(NOLOCK)
--  WHERE [PT_DEATH_IND] = 'Y'
SELECT [sk_Dim_Pt] AS 'SK_DIM_PT'
     , CAST([MRN_display] AS VARCHAR(7)) AS 'MRN'
	 --, [UpDte_Dtm]
  FROM [Rptg].[vwDim_Patient] WITH(NOLOCK)
  WHERE [Deceased] = 'Y'
  ORDER BY UpDte_Dtm
GO
-- ========================================================
-- Grant permissions to object Rptg.VwPidxPatient_Deceased
-- ========================================================
--GRANT SELECT
--    ON OBJECT::Rptg.VwPidxPatient_Deceased
--    TO [HSCDOM\DS_Deceased]
--GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
