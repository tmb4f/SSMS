USE DS_HSDM_Prod
GO

-- ===========================================
-- Alter view vwGPP_Encounters_Test
-- ===========================================

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

IF OBJECT_ID('tempdb..#gpp ') IS NOT NULL
DROP TABLE #gpp

--ALTER VIEW [HSDO].[vwGPP_Encounters_Test]
--AS
SELECT rptg.Adm_Dt
      ,rptg.Atn_Dr_Prov_Id
	  ,rptg.Atn_Dr_SMS_Id
	  ,rptg.Atn_Dr_LName
	  ,rptg.Atn_Dr_FName
	  ,rptg.Atn_Dr_MI
	  ,rptg.Atn_Dr_Type
	  ,rptg.Atn_Dr_Status
	  ,rptg.Atn_Dr_Last_Update_Dt
	  ,rptg.Atn_Dr_Financial_Division_Name
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
      ,rptg.sk_Dim_Pt
	  ,rptg.Load_Date_Time
	  ,rptg.Email
	  ,rptg.sk_Dim_Physcn

INTO #gpp

FROM (
SELECT gpp.*
      ,ROW_NUMBER() OVER(PARTITION BY gpp.sk_Dim_Physcn, gpp.sk_Dim_Pt ORDER BY gpp.Adm_Dt DESC) Seq_Num
FROM (
SELECT clrt.ADm_Dt AS Adm_Dt
      ,clrt.Atn_Dr AS Atn_Dr_Prov_Id
	  --,CAST(NULL AS INTEGER) AS Atn_Dr_SMS_Id
	  ,CASE
	     WHEN ((clrt.Atnd_Dr_SMS_ID IS NOT NULL) AND (ISNUMERIC(clrt.Atnd_Dr_SMS_ID) = 1)) THEN CAST(clrt.Atnd_Dr_SMS_ID AS INTEGER)
		 ELSE CAST(NULL AS INTEGER)
	   END AS Atn_Dr_SMS_Id
	  ,dphyscn.LastName AS Atn_Dr_LName
	  ,dphyscn.FirstName AS Atn_Dr_FName
	  ,dphyscn.MI AS Atn_Dr_MI
	  ,clrt.Atn_Dr_Type
	  ,clrt.Atn_Dr_Status
	  ,clrt.Atn_Dr_Last_Update_Dt
	  ,ser.Financial_Division_Name AS Atn_Dr_Financial_Division_Name
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
	  ,ser.sk_Dim_Physcn
FROM [HSDO].[ADT_GPP_Encounters] clrt
LEFT JOIN DS_HSDW_Prod.[Rptg].[vwDim_Clrt_Pt] dpt
ON (dpt.Clrt_PAT_ID = clrt.PAT_ID)
LEFT JOIN DS_HSDW_Prod.[Rptg].[vwDim_Clrt_SERsrc] ser
ON (ser.PROV_ID = clrt.Atn_Dr)
LEFT OUTER JOIN (SELECT sk_Dim_Physcn, LastName, FirstName, MI
                 FROM DS_HSDW_Prod.Rptg.vwDim_Physcn
				 WHERE current_flag = 1) dphyscn
ON dphyscn.sk_Dim_Physcn = ser.sk_Dim_Physcn
UNION ALL
SELECT [Adm_Dt]
      --,CAST(NULL AS VARCHAR(30)) AS Atn_Dr_Prov_Id
      ,CAST(physcn.PROV_ID AS VARCHAR(30)) AS Atn_Dr_Prov_Id
      ,[Atn_Dr] AS Atn_Dr_SMS_Id
      ,[Atn_Dr_LName]
      ,[Atn_Dr_FName]
      ,[Atn_Dr_MI]
      ,[Atn_Dr_Type]
      ,[Atn_Dr_Status]
      ,[Atn_Dr_Last_Update_Dt]
	  ,physcn.Financial_Division_Name AS Atn_Dr_Financial_Division_Name
      ,[Source]
      ,[IO_Flag]
      ,edw.[Sex]
      ,[Birth_Dt]
      ,[Age]
      ,[Age_Group]
      ,[Pt_FName_MI]
      ,[Pt_LName]
      ,[CURR_PT_ADDR1]
      ,[CURR_PT_ADDR2]
      ,[CURR_PT_CITY]
      ,[CURR_PT_STATE]
      ,[CURR_PT_ZIP]
      ,[CURR_PT_PHONE]
      ,[GUAR_FNAME]
      ,[GUAR_MNAME]
      ,[GUAR_LNAME]
      ,[GUAR_ADDR1]
      ,[GUAR_ADDR2]
      ,[GUAR_CITY]
      ,[GUAR_STATE]
      ,[GUAR_ZIP]
      ,[GUAR_PHONE]
      ,[GUAR_TO_PT]
      ,[Status]
      ,edw.[sk_Dim_Pt]
      ,[Load_Date_Time]
	  ,NULL AS Email
      ,edw.[sk_Dim_Physcn]
  FROM [HSDO].[GPP_Encounters] edw
  LEFT OUTER JOIN (SELECT cso.IDNumber, cso.sk_Dim_Physcn, ser.PROV_ID, ser.Financial_Division_Name
                   FROM DS_HSDW_Prod.Rptg.vwDim_Physcn AS cso
                   INNER JOIN DS_HSDW_Prod.rptg.vwDim_Clrt_SERsrc AS ser
	               ON cso.sk_Dim_Physcn = ser.sk_Dim_Physcn
	               AND cso.sk_Dim_Physcn > 0--exclude placeholders
                   WHERE cso.current_flag = 1) physcn--only latest
  ON physcn.sk_Dim_Physcn = edw.sk_Dim_Physcn
) gpp
) rptg
WHERE rptg.Seq_Num = 1

SELECT *
FROM #gpp
WHERE sk_Dim_Pt = 10480505

--SELECT Atn_Dr_SMS_Id, Atn_Dr_Type, IO_Flag, sk_Dim_Physcn, Atn_Dr_Prov_Id, Atn_Dr_LName, Atn_Dr_FName, Atn_Dr_MI, Atn_Dr_Status, DEPT
--FROM
--(
--SELECT Adm_Dt, Atn_Dr_SMS_Id, ROW_NUMBER() OVER (PARTITION BY Atn_Dr_SMS_Id ORDER BY Adm_Dt DESC) AS Adm_Seq, Atn_Dr_Type, IO_Flag, sk_Dim_Physcn, Atn_Dr_Prov_Id, Atn_Dr_LName, Atn_Dr_FName, Atn_Dr_MI, Atn_Dr_Status, Atn_Dr_Financial_Division_Name AS DEPT
----FROM #gpp
--FROM [DS_HSDM_Prod].[HSDO].[vwGPP_Encounters_New]
--WHERE        (sk_Dim_Physcn <> - 1)
--) enc
--WHERE enc.Adm_Seq = 1
--ORDER BY Atn_Dr_Type, Atn_Dr_LName, Atn_Dr_FName, Atn_Dr_MI

--SELECT  DISTINCT sk_Dim_Physcn, Atn_Dr_Prov_Id, Atn_Dr_SMS_Id, Atn_Dr_LName, Atn_Dr_FName, Atn_Dr_MI, Atn_Dr_Type, Atn_Dr_Status, Atn_Dr_Financial_Division_Name AS DEPT
--FROM            #gpp
----WHERE        (Atn_Dr_Type = 'Physician') AND (IO_Flag = 'I' OR
----                         IO_Flag = 'O') AND (sk_Dim_Physcn <> - 1)
--WHERE        (sk_Dim_Physcn <> - 1)
----GROUP BY sk_Dim_Physcn, Atn_Dr_Prov_Id, Atn_Dr_SMS_Id, Atn_Dr_LName, Atn_Dr_FName, Atn_Dr_MI, Atn_Dr_Type, Atn_Dr_Status, Atn_Dr_Financial_Division_Name
----ORDER BY sk_Dim_Physcn, Atn_Dr_Prov_Id, Atn_Dr_SMS_Id, Atn_Dr_LName, Atn_Dr_FName, Atn_Dr_MI, Atn_Dr_Type, Atn_Dr_Status, Atn_Dr_Financial_Division_Name
--ORDER BY Atn_Dr_LName, Atn_Dr_FName, Atn_Dr_MI, sk_Dim_Physcn, Atn_Dr_Prov_Id, Atn_Dr_SMS_Id, Atn_Dr_Type, Atn_Dr_Status, Atn_Dr_Financial_Division_Name

--SELECT *
----SELECT DISTINCT
----	rptg.Atn_Dr_LName
----   ,rptg.Atn_Dr_FName
----   ,rptg.Atn_Dr_MI
----   ,ddte.Fyear_num AS adm_fy_num
----   ,ddte.fmonth_num AS adm_fmonth_num
----   ,rptg.Atn_Dr_Type
----   ,rptg.sk_Dim_Physcn
--FROM #gpp rptg
--LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Date ddte
--ON ddte.day_date = CAST(rptg.Adm_Dt AS SMALLDATETIME)
--WHERE 
----ORDER BY rptg.Atn_Dr_Prov_Id
----                  , rptg.Adm_Dt
----ORDER BY rptg.sk_Dim_Physcn
--ORDER BY rptg.Atn_Dr_LName, rptg.Atn_Dr_FName, rptg.Atn_Dr_MI, ddte.Fyear_num, ddte.fmonth_num, rptg.Atn_Dr_Type, rptg.sk_Dim_Physcn
GO

-- ================================================================
-- Grant permissions to object HSDO.vwGPP_Encounters_Test
-- ================================================================
--GRANT SELECT
--    ON OBJECT::HSDO.vwGPP_Encounters_Test
--    TO [HSCDOM\DS_Deceased]
--GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO
