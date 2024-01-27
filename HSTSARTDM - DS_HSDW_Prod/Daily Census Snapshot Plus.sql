USE DS_HSDW_Prod

SELECT census.[EVENT_ID]
      ,ddte.year_num
      ,[As of]
      ,[EVENT_TYPE_C]
      ,[ADT_PATIENT_STAT]
      ,[sk_Adm_Dte]
      ,[HOSP_ADMSN_TYPE_C]
      ,[HOSP_ADMSN_TYPE]
      ,[sk_Dsch_Dte]
      ,census.[DEPARTMENT_ID]
      ,census.[Clrt_DEPt_Nme]
      ,[IN_DTTM]
      ,[next_IN_DTTM]
      ,census.[PAT_ENC_CSN_ID]
      ,[ADMIT_CONF_STAT]
      ,[adt_pt_cls]
      ,census.[MRN_Clrt]
      ,[Load_Dtm_ODS]
      ,[Load_Dtm_ARTdw]	 																 
		--,SER.PROV_ID
		--,SER.Prov_Nme
		,SER2.PROV_ID AS admPROV_ID
		,SER2.Prov_Nme AS admProv_Nme
		,SER3.PROV_ID AS currPROV_ID
		,SER3.Prov_Nme AS currProv_Nme
		,adt.sk_Dim_HospitalService
		,hs.HospitalService_Descr
  FROM [DS_HSDW_Prod].[Rptg].[Census_Yesterday_Snapshots] AS census

--INNER JOIN DS_HSDW_Prod.Rptg.vwFact_Pt_Enc_Clrt		AS  PE		ON PE.PAT_ENC_CSN_ID=census.PAT_ENC_CSN_ID
LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwFact_Pt_Enc_Clrt		AS  PE		ON PE.PAT_ENC_CSN_ID=census.PAT_ENC_CSN_ID
--LEFT JOIN DS_HSDW_Prod.Rptg.vwDim_Clrt_SERsrc		AS  SER		ON SER.sk_Dim_Clrt_SERsrc=pe.sk_Dim_Clrt_SERsrc
  LEFT OUTER JOIN (SELECT PAT_ENC_CSN_ID
                        , sk_Dim_Clrt_SERsrc
						, sk_Dim_Physcn
						, ROW_NUMBER() OVER (PARTITION BY sk_Fact_Pt_Enc_Clrt ORDER BY Atn_Beg_Dtm, CASE
																									  WHEN Atn_End_Dtm = '1900-01-01' THEN GETDATE()
																									  ELSE Atn_End_Dtm
																									END) AS 'Atn_Seq'
				   FROM DS_HSDW_Prod.Rptg.vwFact_Pt_Enc_Atn_Prov_All) AS admatn ON (admatn.PAT_ENC_CSN_ID = census.PAT_ENC_CSN_ID) AND admatn.Atn_Seq = 1
LEFT JOIN DS_HSDW_Prod.Rptg.vwDim_Clrt_SERsrc		AS  SER2		ON SER2.sk_Dim_Clrt_SERsrc=admatn.sk_Dim_Clrt_SERsrc
  LEFT OUTER JOIN (SELECT PAT_ENC_CSN_ID
                        , sk_Dim_Clrt_SERsrc
						, sk_Dim_Physcn
						, ROW_NUMBER() OVER (PARTITION BY sk_Fact_Pt_Enc_Clrt ORDER BY Atn_Beg_Dtm DESC, CASE
																										   WHEN Atn_End_Dtm = '1900-01-01' THEN GETDATE()
																										   ELSE Atn_End_Dtm
																									     END DESC) AS 'Atn_Seq'
				   FROM DS_HSDW_Prod.Rptg.vwFact_Pt_Enc_Atn_Prov_All) AS dschatn ON (dschatn.PAT_ENC_CSN_ID = census.PAT_ENC_CSN_ID) AND dschatn.Atn_Seq = 1
LEFT JOIN DS_HSDW_Prod.Rptg.vwDim_Clrt_SERsrc		AS  SER3		ON SER3.sk_Dim_Clrt_SERsrc=dschatn.sk_Dim_Clrt_SERsrc
INNER JOIN DS_HSDW_Prod.Rptg.vwDim_Clrt_Pt  AS  PT		ON PT.Clrt_PAT_ID=PE.PAT_ID
LEFT JOIN DS_HSDW_Prod.Rptg.vwDim_Clrt_DEPt 	AS  DEP		ON DEP.DEPARTMENT_ID=census.DEPARTMENT_ID
LEFT JOIN DS_HSDW_Prod.Rptg.vwFact_Clrt_ADT_Census adt ON  adt.EVENT_ID = census.EVENT_ID
LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_HospitalService hs ON hs.sk_Dim_HospitalService = adt.sk_Dim_HospitalService
LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Date ddte	ON ddte.day_date = census.[As of]

WHERE census.DEPARTMENT_ID = 10243040 -- UVHE NEWBORN ICU
AND ddte.year_num IN (2022, 2023)

ORDER BY census.[As of], census.IN_DTTM
--ORDER BY census.EVENT_ID, census.[As of], census.IN_DTTM