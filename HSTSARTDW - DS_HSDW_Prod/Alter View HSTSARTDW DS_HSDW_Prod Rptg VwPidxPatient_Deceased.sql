USE DS_HSDW_Prod

-- ====================================
-- Alter view VwPidxPatient_Deceased
-- ====================================

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

ALTER VIEW Rptg.VwPidxPatient_Deceased
AS
SELECT [sk_Dim_Pt] AS 'SK_DIM_PT'
     , CAST([MRN_display] AS VARCHAR(7)) AS 'MRN'
  FROM [Rptg].[vwDim_Patient] WITH(NOLOCK)
  WHERE [Deceased] = 'Y'
GO
-- ========================================================
-- Grant permissions to object Rptg.VwPidxPatient_Deceased
-- ========================================================
GRANT SELECT
    ON OBJECT::Rptg.VwPidxPatient_Deceased
    TO [HSCDOM\DS_Deceased]
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO
