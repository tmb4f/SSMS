USE CLARITY

DECLARE @Date_Start AS SMALLDATETIME
DECLARE @Date_End AS SMALLDATETIME

--SET @Date_Start = '7/1/2020 00:00 AM'
SET @Date_Start = '6/1/2022 00:00 AM'
SET @Date_End = '6/30/2022 00:00 AM'

/*PROV_ID	PROV_NAME
29096	ALFANO, ALAN PETER
67158	AMALFITANO, JOSEPH
56932	ASTHAGIRI, HEATHER L
29097	DIAMOND, PAUL T
41083	GRICE, D. PRESTON
51070	GRICE, DARLINDA M
29094	GYPSON, WARD
74042	HRYVNIAK, DAVID
29087	JENKINS, JEFFREY
56129	KELLEHER, NICOLE C.
68058	LUNSFORD, CHRISTOPHER D
29095	MILLER, SUSAN
116776	MIXON, ALYSSA
64818	REDIESKE, CRYSTON MICHELLE
74043	ROYER, REGAN H
29092	RUBENDALL, DAVID S
90452	SHEPPARD, MICHAEL
46238	SMITH II, GEOFFREY R
71719	WARWICK, MICHAEL D
66781	WEPPNER, JUSTIN L
29073	WILDER, ROBERT*/

;WITH providers AS
(
SELECT
	 ser.PROV_ID
    ,ser.PROV_NAME

	,TRY_CAST(ser.RPT_GRP_SIX AS INT) AS financial_division_id
	,CAST(dvsn.Epic_Financial_Division AS VARCHAR(150)) AS financial_division_name
	,TRY_CAST(ser.RPT_GRP_EIGHT AS INT) AS financial_sub_division_id
	,CAST(dvsn.Epic_Financial_SubDivision AS VARCHAR(150)) AS financial_sub_division_name
	,dvsn.som_group_id
	,dvsn.som_group_name
	,dvsn.Department_ID AS som_department_id
  	,CAST(dvsn.Department AS VARCHAR(150)) AS som_department_name
	,CAST(dvsn.Org_Number AS INT) AS som_division_id
	,CAST(dvsn.Organization AS VARCHAR(150)) AS som_division_name
	,dvsn.som_hs_area_id
	,dvsn.som_hs_area_name

FROM CLARITY.dbo.CLARITY_SER AS ser
                -- -------------------------------------
				LEFT OUTER JOIN
				(
				    SELECT
					    Epic_Financial_Division_Code,
						Epic_Financial_Division,
                        Epic_Financial_Subdivision_Code,
						Epic_Financial_Subdivision,
                        Department,
                        Department_ID,
                        Organization,
                        Org_Number,
                        som_group_id,
                        som_group_name,
						som_hs_area_id,
						som_hs_area_name
					FROM CLARITY_App.Rptg.vwRef_OracleOrg_to_EpicFinancialSubdiv) dvsn
				    ON (CAST(dvsn.Epic_Financial_Division_Code AS INTEGER) = TRY_CAST(ser.RPT_GRP_SIX AS INT)
					    AND CAST(dvsn.Epic_Financial_Subdivision_Code AS INTEGER) = TRY_CAST(ser.RPT_GRP_EIGHT AS INT))
WHERE dvsn.Department_ID = 259 -- MD-PHMR Phys Med & Rehab
)

SELECT
ordenc.VISIT_PROV_ID
,ser.PROV_NAME AS VISIT_PROV_NAME
,ordproc.ORDER_PROC_ID
,ordproc.PAT_ENC_CSN_ID
,ordproc.ORD_CREATR_USER_ID
,emp.NAME AS ORD_CREATR_USER_NAME
,ordproc.ORDERING_DATE
,ordproc.ORDER_TIME
,ordproc.ORDER_TYPE_C
,ordtyp.NAME AS ORDER_TYPE_Name
,ordproc.PROC_ID
,ordeap.PROC_NAME	 AS Order_Proc_Name
,ordproc.ORDER_STATUS_C
,ordstat.NAME	AS ORDER_STATUS_Name
FROM ORDER_PROC ordproc
LEFT OUTER JOIN dbo.PAT_ENC ordenc
ON ordenc.PAT_ENC_CSN_ID = ordproc.PAT_ENC_CSN_ID
INNER JOIN providers providers
ON ordenc.VISIT_PROV_ID = providers.PROV_ID
LEFT JOIN CLARITY_EMP emp
ON emp.USER_ID = ordproc.ORD_CREATR_USER_ID
LEFT JOIN ZC_ORDER_TYPE ordtyp
ON ordproc.ORDER_TYPE_C = ordtyp.ORDER_TYPE_C
LEFT JOIN CLARITY_EAP	ordeap
ON ordproc.PROC_ID = ordeap.PROC_ID
LEFT JOIN ZC_ORDER_STATUS	ordstat
ON ordproc.ORDER_STATUS_C = ordstat.ORDER_STATUS_C
LEFT JOIN dbo.ZC_DISP_ENC_TYPE zdet ON zdet.DISP_ENC_TYPE_C = ordenc.ENC_TYPE_C
LEFT JOIN dbo.CLARITY_DEP dep ON ordenc.DEPARTMENT_ID = dep.DEPARTMENT_ID
LEFT JOIN dbo.CLARITY_SER ser ON ser.PROV_ID = ordenc.VISIT_PROV_ID

WHERE   1=1
    AND (	
			(	ordproc.ORDERING_DATE BETWEEN 	@Date_Start AND @Date_End 
			)		
		)
	AND ordproc.ORDER_TYPE_C = 33
ORDER BY
            ser.PROV_NAME
	    ,   ordproc.ORDERING_DATE
		,   ordproc.ORDER_TIME
		,   ordproc.PAT_ENC_CSN_ID