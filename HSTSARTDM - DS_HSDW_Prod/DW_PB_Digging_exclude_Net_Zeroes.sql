USE DS_HSDW_Prod
GO

------------------------------------
DECLARE @Begin_Svc_Date AS int
DECLARE @End_Svc_Date AS int
SET @Begin_Svc_Date = 20210501 
SET @End_Svc_Date = 20210531

DECLARE @Provider AS varchar(40)
SET @Provider = 'bauer, todd%'  -- the % sign is a wild card so you don't have to provide the name exactly as it's stored in the database
-----------------------------------

SELECT  upg.TX_ID
     --, upg.sk_Post_Dte
	 , pdt.day_date AS POST_DATE

     --, upg.sk_Svc_Dte
	 , sdt.day_date AS SVC_DATE

     --, upg.sk_Dim_Clrt_SERsrc
	 , ser.PROV_ID
	 , ser.Prov_Nme AS PROVIDER_NAME

  --   , upg.sk_Dim_Clrt_Pt
	 , pt.PAT_NAME AS PATIENT_NAME

     , upg.HAR
     --, upg.sk_Fact_HospitalAccount
     --, upg.Svc_PROV_ID

     , upg.BA_Financial_Divions_ID
     , upg.MRN
     , upg.PtAgeAtDos
     , upg.Bill_Area_ID

     --, upg.sk_Dim_Clrt_DEPt
	 , dep.DEPARTMENT_ID AS DEPT_ID
	 , dep.Clrt_DEPt_Nme AS DEPARTMENT_NAME
	 , dep.Clrt_DEPt_Abbrv AS DEPARTMENT

     --, upg.sk_Dim_Clrt_LOCtn
	 , loc.LOC_ID
	 , loc.LOC_Nme AS LOCATION_NAME
	 , loc.LOC_Abbrv AS LOCATION

     , upg.Chrg_CptCode AS CHARGE_CPT
     , coalesce(upg.CPT_ModAll,'') AS CPT_MOD
	 , left(upg.Chrg_CptCode,5) AS CPT_CODE
	 , cpt.CPT_Nme AS CPT_DESCRIPTION

     , upg.POS_In_Out
     , upg.POS_Type

     , net_zeroes.CHG_QTY
     , net_zeroes.CHG_RVU_WORK
     , net_zeroes.CHG_RVU_TOTAL
     , net_zeroes.TBA_CREDITS_WORK
     , net_zeroes.TBA_CREDITS_TOTAL

FROM rptg.vwFact_UPG_Bill_Dtl_Clrt AS upg
INNER JOIN Rptg.vwDim_Date AS pdt
	ON pdt.date_key = upg.sk_Post_Dte
INNER JOIN Rptg.vwDim_Date AS sdt
	ON sdt.date_key = upg.sk_Svc_Dte
INNER JOIN rptg.vwDim_Clrt_SERsrc AS ser
	ON ser.sk_Dim_Clrt_SERsrc = upg.sk_Dim_Clrt_SERsrc
INNER JOIN Rptg.vwDim_Clrt_DEPt AS dep
	ON dep.sk_Dim_Clrt_DEPt = upg.sk_Dim_Clrt_DEPt
INNER JOIN Rptg.vwDim_Clrt_LOCtn AS loc
	ON loc.sk_Dim_Clrt_LOCtn = upg.sk_Dim_Clrt_LOCtn
INNER JOIN rptg.vwDim_CPT AS cpt
	ON cpt.CPT_cde = left(upg.Chrg_CptCode,5)
INNER JOIN rptg.vwDim_clrt_pt AS pt
	ON pt.sk_Dim_Clrt_Pt = upg.sk_Dim_Clrt_Pt

-- weed out transactions that net to zero
INNER JOIN 
	(
	SELECT upg2.TX_ID
	 , SUM(upg2.Charge_Quantity) AS CHG_QTY
     , SUM(upg2.Charge_RVU_Work) AS CHG_RVU_WORK
     , SUM(upg2.Charge_RVU_Total) AS CHG_RVU_TOTAL
     , SUM(upg2.TBA_Credits_Work) AS TBA_CREDITS_WORK
     , SUM(upg2.TBA_Credits_Total) AS TBA_CREDITS_TOTAL
	FROM rptg.vwFact_UPG_Bill_Dtl_Clrt AS upg2
	WHERE 1=1
		AND upg2.sk_Svc_Dte BETWEEN @Begin_Svc_Date AND @End_Svc_Date
	GROUP BY upg2.Tx_ID      
	) AS net_zeroes
		ON net_zeroes.Tx_ID = upg.Tx_ID

WHERE 1=1
	AND upg.sk_Svc_Dte BETWEEN @Begin_Svc_Date AND @End_Svc_Date
	AND ser.Prov_Nme LIKE @Provider
	AND net_zeroes.CHG_QTY <> 0
ORDER BY upg.Tx_ID


