USE DS_HSDW_Prod

IF OBJECT_ID('tempdb..#adt ') IS NOT NULL
DROP TABLE #adt

IF OBJECT_ID('tempdb..#summary ') IS NOT NULL
DROP TABLE #summary

SET NOCOUNT ON;
	
SELECT 	 pt.MRN_int as [MRN]				
,adt.sk_Fact_Pt_Enc_Clrt					
,adt.seq					
,ev.ADT_Evnt_Ttle					
,dept.DEPARTMENT_ID					
,dept.Clrt_DEPt_Nme
,mdm.inpatient_adult_flag
,mdm.childrens_flag				
,adt.sk_Beg_Dte					
,adt.sk_Beg_Tm					
,adt.OUT_DTTM					
,adt.Pt_Days

INTO #adt			
						
FROM [DS_HSDW_Prod].[Rptg].[vwFact_Clrt_ADT] adt					
					
--join ( SELECT 	 distinct  adt.sk_Fact_Pt_Enc_Clrt as [Encounter]						
INNER JOIN ( SELECT 	 distinct  adt.sk_Fact_Pt_Enc_Clrt as [Encounter]				
					
				FROM [DS_HSDW_Prod].[Rptg].[vwFact_Clrt_ADT] adt	
					
				left outer join[DS_HSDW_Prod].[Rptg].[vwDim_Clrt_DEPt] dept	
				on adt.sk_Dim_Clrt_DEPt = dept.sk_Dim_Clrt_DEPt	
					
				left outer join [DS_HSDW_Prod].[Rptg].[vwFact_Pt_Enc_Clrt] pt	
				on adt.sk_Fact_Pt_Enc_Clrt = pt.sk_Fact_Pt_Enc_Clrt	
					
				--where Left(adt.sk_Beg_Dte,6) = Left(convert(char,Dateadd(m,-1,Getdate()) ,112),6)	
				--where Left(adt.sk_Beg_Dte,6) = 201804	
				where Left(adt.sk_Beg_Dte,6) BETWEEN 202101 AND 202103	
				--and dept.DEPARTMENT_ID in ('10243043','10243100')	-- PICU
				and adt.sk_Dim_Clrt_ADT_Evnt in ('1','3') -- admission or transfer in	
				)list on adt.sk_Fact_Pt_Enc_Clrt = list.Encounter	
								
left outer join[DS_HSDW_Prod].[Rptg].[vwDim_Clrt_DEPt] dept					
on adt.sk_Dim_Clrt_DEPt = dept.sk_Dim_Clrt_DEPt					
					
left outer join [DS_HSDW_Prod].[Rptg].[vwFact_Pt_Enc_Clrt] pt					
on adt.sk_Fact_Pt_Enc_Clrt = pt.sk_Fact_Pt_Enc_Clrt					
					
left outer join [DS_HSDW_Prod].[Rptg].[vwDim_Clrt_ADT_Evnt] ev					
on adt.sk_Dim_Clrt_ADT_Evnt=ev.sk_Dim_Clrt_ADT_Evnt			
					
left outer join [DS_HSDW_Prod].[Rptg].[vwRef_MDM_Supplemental] mdm					
on dept.DEPARTMENT_ID=mdm.EPIC_DEPARTMENT_ID

WHERE dept.Clrt_DEPt_Nme <> 'Unknown'
AND dept.Clrt_DEPt_Nme <> 'UVHE EMERGENCY DEPT'
AND ((mdm.inpatient_adult_flag = 1) OR (mdm.childrens_flag = 1))
AND adt.sk_Beg_Dte BETWEEN 20210101 AND 20210331
						
--order by pt.MRN_int 					
--,adt.sk_Fact_Pt_Enc_Clrt					
--,adt.seq						
order by adt.sk_Beg_Dte
,dept.DEPARTMENT_ID
,pt.MRN_int 					
,adt.sk_Fact_Pt_Enc_Clrt					
,adt.seq

SELECT DEPARTMENT_ID AS Department_Id
              ,Clrt_DEPt_Nme AS Department_Name
			  ,COUNT(*) AS [Admissons/Tranfers In]
			  ,MIN(Pt_Days) AS Minimum_Patient_Days
			  ,MAX(Pt_Days) AS Maximum_Patient_Days
			  ,CAST(ROUND(AVG(CAST(Pt_Days AS FLOAT)),1) AS NUMERIC(4,1)) AS Average_Patient_Days

INTO #summary

FROM #adt
GROUP BY DEPARTMENT_ID
                   ,Clrt_DEPt_Nme
ORDER BY Clrt_DEPt_Nme

SELECT *
FROM #summary
ORDER BY Department_Name