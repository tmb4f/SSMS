USE DS_HSDM_Prod
GO
-- ===========================================
-- Create view vwGPP_Encounters_New
-- ===========================================
--IF EXISTS (SELECT TABLE_NAME 
--	   FROM   INFORMATION_SCHEMA.VIEWS 
--	   WHERE  TABLE_SCHEMA = N'HSDO' AND
--	          TABLE_NAME = N'vwGPP_Encounters_New')
--    DROP VIEW [HSDO].[vwGPP_Encounters_Test]
--GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO
/*
SELECT clrt.ADm_Dt AS Adm_Dt
      ,clrt.Atn_Dr AS Atn_Dr_Prov_Id
	  ,clrt.Atnd_Dr_SMS_ID AS Atn_Dr_SMS_Id
	  ,CASE WHEN dphyscn1.LastName NOT IN ('Invalid','Unk') THEN dphyscn1.LastName
	        WHEN dphyscn2.LastName IS NOT NULL THEN dphyscn2.LastName
	        ELSE clrt.Atn_Dr_LName
	   END AS Atn_Dr_LName
	  ,CASE WHEN dphyscn1.LastName NOT IN ('Invalid','Unk') THEN dphyscn1.FirstName
	        WHEN dphyscn2.LastName IS NOT NULL THEN dphyscn2.FirstName
	        ELSE clrt.Atn_Dr_FName
	   END AS Atn_Dr_FName
	  ,CASE WHEN dphyscn1.LastName NOT IN ('Invalid','Unk') THEN dphyscn1.MI
	        WHEN dphyscn2.LastName IS NOT NULL THEN dphyscn2.MI
	        ELSE clrt.Atn_Dr_MI
	   END AS Atn_Dr_MI
	  ,clrt.Atn_Dr_Type
	  ,clrt.Atn_Dr_Status
	  ,clrt.Atn_Dr_Last_Update_Dt
	  ,clrt.[Source]
	  ,clrt.IO_Flag
	  ,clrt.Sex
	  ,clrt.Birth_Dt
	  ,clrt.Age
	  ,clrt.Age_Group
	  ,clrt.Pt_FName_MI
	  ,clrt.Pt_LName
	  ,clrt.CURR_PT_ADDR1
	  ,clrt.CURR_PT_ADDR2
	  ,clrt.CURR_PT_CITY
	  ,clrt.CURR_PT_STATE
	  ,clrt.CURR_PT_ZIP
	  ,clrt.CURR_PT_PHONE
	  ,clrt.GUAR_FNAME
	  ,clrt.GUAR_MNANE
	  ,clrt.GUAR_LNAME
	  ,clrt.GUAR_ADDR1
	  ,clrt.GUAR_ADDR2
	  ,clrt.GUAR_CITY
	  ,clrt.GUAR_STATE
	  ,clrt.GUAR_ZIP
	  ,clrt.GUAR_PHONE
	  ,clrt.GUAR_TO_PT
	  ,clrt.[Status]
      ,dpt.sk_Dim_Pt
	  ,clrt.load_date_time AS Load_Date_Time
	  ,clrt.Email
	  ,CASE WHEN dphyscn1.sk_Dim_Physcn > 0 THEN dphyscn1.sk_Dim_Physcn
	        WHEN dphyscn2.sk_Dim_Physcn IS NOT NULL AND dphyscn2.sk_Dim_Physcn > 0 THEN dphyscn2.sk_Dim_Physcn
	        ELSE ser.sk_Dim_Physcn
	   END AS sk_Dim_Physcn
FROM [HSDO].[ADT_GPP_Encounters] clrt
LEFT JOIN DS_HSDW_Prod.[Rptg].[vwDim_Clrt_Pt] dpt
ON (dpt.Clrt_PAT_ID = clrt.PAT_ID)
LEFT JOIN DS_HSDW_Prod.[Rptg].[vwDim_Clrt_SERsrc] ser
ON (ser.PROV_ID = clrt.Atn_Dr)
LEFT OUTER JOIN (SELECT sk_Dim_Physcn, LastName, FirstName, MI
                 FROM DS_HSDW_Prod.Rptg.vwDim_Physcn
				 WHERE current_flag = 1) dphyscn1
ON dphyscn1.sk_Dim_Physcn = ser.sk_Dim_Physcn
LEFT OUTER JOIN (SELECT sk_Dim_Physcn, LastName, FirstName, MI, NPINumber
                 FROM DS_HSDW_Prod.Rptg.vwDim_Physcn
				 WHERE current_flag = 1
				 AND ((NPINumber IS NOT NULL) AND (NPINumber <> 'Unknown') AND (CAST(NPINumber AS INTEGER) > 0))) dphyscn2
ON dphyscn2.NPINumber = CAST(ser.NPI AS VARCHAR(10))
--WHERE dpt.sk_Dim_Pt = 389459
ORDER BY Adm_Dt

SELECT edw.[Adm_Dt]
      ,CAST(physcn.PROV_ID AS VARCHAR(30)) AS Atn_Dr_Prov_Id
      ,CAST(edw.[Atn_Dr] AS VARCHAR(30)) AS Atn_Dr_SMS_Id
      ,edw.[Atn_Dr_LName]
      ,edw.[Atn_Dr_FName]
      ,edw.[Atn_Dr_MI]
      ,edw.[Atn_Dr_Type]
      ,edw.[Atn_Dr_Status]
      ,edw.[Atn_Dr_Last_Update_Dt]
      ,edw.[Source]
      ,edw.[IO_Flag]
      ,edw.[Sex]
      ,edw.[Birth_Dt]
      ,edw.[Age]
      ,edw.[Age_Group]
      ,edw.[Pt_FName_MI]
      ,edw.[Pt_LName]
      ,edw.[CURR_PT_ADDR1]
      ,edw.[CURR_PT_ADDR2]
      ,edw.[CURR_PT_CITY]
      ,edw.[CURR_PT_STATE]
      ,edw.[CURR_PT_ZIP]
      ,edw.[CURR_PT_PHONE]
      ,edw.[GUAR_FNAME]
      ,edw.[GUAR_MNAME]
      ,edw.[GUAR_LNAME]
      ,edw.[GUAR_ADDR1]
      ,edw.[GUAR_ADDR2]
      ,edw.[GUAR_CITY]
      ,edw.[GUAR_STATE]
      ,edw.[GUAR_ZIP]
      ,edw.[GUAR_PHONE]
      ,edw.[GUAR_TO_PT]
      ,edw.[Status]
      ,edw.[sk_Dim_Pt]
      ,edw.[Load_Date_Time]
	  ,NULL AS Email
      ,edw.[sk_Dim_Physcn]
  FROM [HSDO].[GPP_Encounters] edw
  LEFT OUTER JOIN (SELECT cso.IDNumber, cso.sk_Dim_Physcn, ser.PROV_ID
                   FROM DS_HSDW_Prod.Rptg.vwDim_Physcn AS cso
                   INNER JOIN DS_HSDW_Prod.rptg.vwDim_Clrt_SERsrc AS ser
	               ON cso.sk_Dim_Physcn = ser.sk_Dim_Physcn
	               AND cso.sk_Dim_Physcn > 0--exclude placeholders
                   WHERE cso.current_flag = 1) physcn--only latest
  ON physcn.sk_Dim_Physcn = edw.sk_Dim_Physcn
--WHERE edw.sk_Dim_Pt = 389459
ORDER BY Adm_Dt
*/
--CREATE VIEW [HSDO].[vwGPP_Encounters_New]
----ALTER VIEW [HSDO].[vwGPP_Encounters_New]
--AS
SELECT rptg.Seq_Value
      ,rptg.sk_Dim_Pt
	  ,rptg.Adm_Dt
	  ,rptg.Seq_Num
      ,rptg.Atn_Dr_Prov_Id
	  ,rptg.Atn_Dr_SMS_Id
	  ,rptg.Atn_Dr_LName
	  ,rptg.Atn_Dr_FName
	  ,rptg.Atn_Dr_MI
	  ,rptg.Atn_Dr_Type
	  ,rptg.Atn_Dr_Status
	  ,rptg.Atn_Dr_Last_Update_Dt
	  ,rptg.[Source]
	  ,rptg.IO_Flag
	  ,rptg.Sex
	  ,rptg.Birth_Dt
	  ,rptg.Age
	  ,rptg.Age_Group
	  ,rptg.Pt_FName_MI
	  ,rptg.Pt_LName
	  ,rptg.CURR_PT_ADDR1
	  ,rptg.CURR_PT_ADDR2
	  ,rptg.CURR_PT_CITY
	  ,rptg.CURR_PT_STATE
	  ,rptg.CURR_PT_ZIP
	  ,rptg.CURR_PT_PHONE
	  ,rptg.GUAR_FNAME
	  ,rptg.GUAR_MNANE
	  ,rptg.GUAR_LNAME
	  ,rptg.GUAR_ADDR1
	  ,rptg.GUAR_ADDR2
	  ,rptg.GUAR_CITY
	  ,rptg.GUAR_STATE
	  ,rptg.GUAR_ZIP
	  ,rptg.GUAR_PHONE
	  ,rptg.GUAR_TO_PT
	  ,rptg.[Status]
      --,rptg.sk_Dim_Pt
	  ,rptg.Load_Date_Time
	  ,rptg.Email
	  ,rptg.sk_Dim_Physcn
FROM (
SELECT seq.*
      ,ROW_NUMBER() OVER(PARTITION BY seq.Seq_Value, seq.sk_Dim_Pt ORDER BY seq.Adm_Dt DESC) Seq_Num
FROM (
SELECT gpp.*
      ,CASE WHEN gpp.sk_Dim_Physcn <= 0 AND gpp.Atn_Dr_SMS_Id IS NOT NULL THEN CAST(gpp.Atn_Dr_SMS_Id AS VARCHAR(30))
			WHEN gpp.sk_Dim_Physcn <= 0 AND gpp.Atn_Dr_SMS_Id IS NULL THEN CAST(gpp.Atn_Dr_Prov_Id AS VARCHAR(30))
		    ELSE CAST(gpp.sk_Dim_Physcn AS VARCHAR(30))
	   END AS Seq_Value
FROM (
SELECT clrt.ADm_Dt AS Adm_Dt
      ,clrt.Atn_Dr AS Atn_Dr_Prov_Id
	  ,clrt.Atnd_Dr_SMS_ID AS Atn_Dr_SMS_Id
	  ,CASE WHEN dphyscn1.LastName NOT IN ('Invalid','Unk') THEN dphyscn1.LastName
	        WHEN dphyscn2.LastName IS NOT NULL THEN dphyscn2.LastName
	        ELSE clrt.Atn_Dr_LName
	   END AS Atn_Dr_LName
	  ,CASE WHEN dphyscn1.LastName NOT IN ('Invalid','Unk') THEN dphyscn1.FirstName
	        WHEN dphyscn2.LastName IS NOT NULL THEN dphyscn2.FirstName
	        ELSE clrt.Atn_Dr_FName
	   END AS Atn_Dr_FName
	  ,CASE WHEN dphyscn1.LastName NOT IN ('Invalid','Unk') THEN dphyscn1.MI
	        WHEN dphyscn2.LastName IS NOT NULL THEN dphyscn2.MI
	        ELSE clrt.Atn_Dr_MI
	   END AS Atn_Dr_MI
	  ,clrt.Atn_Dr_Type
	  ,clrt.Atn_Dr_Status
	  ,clrt.Atn_Dr_Last_Update_Dt
	  ,clrt.[Source]
	  ,clrt.IO_Flag
	  ,clrt.Sex
	  ,clrt.Birth_Dt
	  ,clrt.Age
	  ,clrt.Age_Group
	  ,clrt.Pt_FName_MI
	  ,clrt.Pt_LName
	  ,clrt.CURR_PT_ADDR1
	  ,clrt.CURR_PT_ADDR2
	  ,clrt.CURR_PT_CITY
	  ,clrt.CURR_PT_STATE
	  ,clrt.CURR_PT_ZIP
	  ,clrt.CURR_PT_PHONE
	  ,clrt.GUAR_FNAME
	  ,clrt.GUAR_MNANE
	  ,clrt.GUAR_LNAME
	  ,clrt.GUAR_ADDR1
	  ,clrt.GUAR_ADDR2
	  ,clrt.GUAR_CITY
	  ,clrt.GUAR_STATE
	  ,clrt.GUAR_ZIP
	  ,clrt.GUAR_PHONE
	  ,clrt.GUAR_TO_PT
	  ,clrt.[Status]
      ,dpt.sk_Dim_Pt
	  ,clrt.load_date_time AS Load_Date_Time
	  ,clrt.Email
	  ,CASE WHEN dphyscn1.sk_Dim_Physcn > 0 THEN dphyscn1.sk_Dim_Physcn
	        WHEN dphyscn2.sk_Dim_Physcn IS NOT NULL AND dphyscn2.sk_Dim_Physcn > 0 THEN dphyscn2.sk_Dim_Physcn
	        ELSE ser.sk_Dim_Physcn
	   END AS sk_Dim_Physcn
FROM [HSDO].[ADT_GPP_Encounters] clrt
LEFT JOIN DS_HSDW_Prod.[Rptg].[vwDim_Clrt_Pt] dpt
ON (dpt.Clrt_PAT_ID = clrt.PAT_ID)
LEFT JOIN DS_HSDW_Prod.[Rptg].[vwDim_Clrt_SERsrc] ser
ON (ser.PROV_ID = clrt.Atn_Dr)
LEFT OUTER JOIN (SELECT sk_Dim_Physcn, LastName, FirstName, MI
                 FROM DS_HSDW_Prod.Rptg.vwDim_Physcn
				 WHERE current_flag = 1) dphyscn1
ON dphyscn1.sk_Dim_Physcn = ser.sk_Dim_Physcn
LEFT OUTER JOIN (SELECT sk_Dim_Physcn, LastName, FirstName, MI, NPINumber
                 FROM DS_HSDW_Prod.Rptg.vwDim_Physcn
				 WHERE current_flag = 1
				 AND ((NPINumber IS NOT NULL) AND (NPINumber <> 'Unknown') AND (CAST(NPINumber AS INTEGER) > 0))) dphyscn2
ON dphyscn2.NPINumber = CAST(ser.NPI AS VARCHAR(10))
--WHERE dpt.sk_Dim_Pt = 389459
UNION ALL
SELECT edw.[Adm_Dt]
      ,CAST(physcn.PROV_ID AS VARCHAR(30)) AS Atn_Dr_Prov_Id
      ,CAST(edw.[Atn_Dr] AS VARCHAR(30)) AS Atn_Dr_SMS_Id
      ,edw.[Atn_Dr_LName]
      ,edw.[Atn_Dr_FName]
      ,edw.[Atn_Dr_MI]
      ,edw.[Atn_Dr_Type]
      ,edw.[Atn_Dr_Status]
      ,edw.[Atn_Dr_Last_Update_Dt]
      ,edw.[Source]
      ,edw.[IO_Flag]
      ,edw.[Sex]
      ,edw.[Birth_Dt]
      ,edw.[Age]
      ,edw.[Age_Group]
      ,edw.[Pt_FName_MI]
      ,edw.[Pt_LName]
      ,edw.[CURR_PT_ADDR1]
      ,edw.[CURR_PT_ADDR2]
      ,edw.[CURR_PT_CITY]
      ,edw.[CURR_PT_STATE]
      ,edw.[CURR_PT_ZIP]
      ,edw.[CURR_PT_PHONE]
      ,edw.[GUAR_FNAME]
      ,edw.[GUAR_MNAME]
      ,edw.[GUAR_LNAME]
      ,edw.[GUAR_ADDR1]
      ,edw.[GUAR_ADDR2]
      ,edw.[GUAR_CITY]
      ,edw.[GUAR_STATE]
      ,edw.[GUAR_ZIP]
      ,edw.[GUAR_PHONE]
      ,edw.[GUAR_TO_PT]
      ,edw.[Status]
      ,edw.[sk_Dim_Pt]
      ,edw.[Load_Date_Time]
	  ,NULL AS Email
      ,edw.[sk_Dim_Physcn]
  FROM [HSDO].[GPP_Encounters] edw
  LEFT OUTER JOIN (SELECT cso.IDNumber, cso.sk_Dim_Physcn, ser.PROV_ID
                   FROM DS_HSDW_Prod.Rptg.vwDim_Physcn AS cso
                   INNER JOIN DS_HSDW_Prod.rptg.vwDim_Clrt_SERsrc AS ser
	               ON cso.sk_Dim_Physcn = ser.sk_Dim_Physcn
	               AND cso.sk_Dim_Physcn > 0--exclude placeholders
                   WHERE cso.current_flag = 1) physcn--only latest
  ON physcn.sk_Dim_Physcn = edw.sk_Dim_Physcn
  --WHERE edw.sk_Dim_Pt = 389459
) gpp
) seq
) rptg
--WHERE rptg.Seq_Num = 1

--ORDER BY rptg.Seq_Num, rptg.Adm_Dt
ORDER BY rptg.sk_Dim_Pt, rptg.Seq_Num, rptg.Adm_Dt
GO

-- ================================================================
-- Grant permissions to object HSDO.vwGPP_Encounters_New
-- ================================================================
--GRANT SELECT
--    ON OBJECT::HSDO.vwGPP_Encounters_New
--    TO [HSCDOM\DS_Deceased]
--GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO
