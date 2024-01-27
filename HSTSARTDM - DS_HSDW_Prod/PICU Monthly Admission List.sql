					
SELECT 	 pt.MRN_int as [MRN]				
,adt.sk_Fact_Pt_Enc_Clrt					
,adt.seq					
,ev.ADT_Evnt_Ttle					
,dept.DEPARTMENT_ID					
,dept.Clrt_DEPt_Nme					
,adt.sk_Beg_Dte					
,adt.sk_Beg_Tm					
,adt.OUT_DTTM					
,adt.Pt_Days					
					
					
FROM [DS_HSDW_Prod].[Rptg].[vwFact_Clrt_ADT] adt					
					
join ( SELECT 	 distinct  adt.sk_Fact_Pt_Enc_Clrt as [Encounter]				
					
				FROM [DS_HSDW_Prod].[Rptg].[vwFact_Clrt_ADT] adt	
					
				left outer join[DS_HSDW_Prod].[Rptg].[vwDim_Clrt_DEPt] dept	
				on adt.sk_Dim_Clrt_DEPt = dept.sk_Dim_Clrt_DEPt	
					
				left outer join [DS_HSDW_Prod].[Rptg].[vwFact_Pt_Enc_Clrt] pt	
				on adt.sk_Fact_Pt_Enc_Clrt = pt.sk_Fact_Pt_Enc_Clrt	
					
				where Left(adt.sk_Beg_Dte,6) = Left(convert(char,Dateadd(m,-1,Getdate()) ,112),6)	
				--where Left(adt.sk_Beg_Dte,6) = 201804	
				and dept.DEPARTMENT_ID in ('10243043','10243100')	-- PICU
				and adt.sk_Dim_Clrt_ADT_Evnt in ('1','3') -- admission or transfer in	
				)list on adt.sk_Fact_Pt_Enc_Clrt = list.Encounter	
					
					
					
left outer join[DS_HSDW_Prod].[Rptg].[vwDim_Clrt_DEPt] dept					
on adt.sk_Dim_Clrt_DEPt = dept.sk_Dim_Clrt_DEPt					
					
left outer join [DS_HSDW_Prod].[Rptg].[vwFact_Pt_Enc_Clrt] pt					
on adt.sk_Fact_Pt_Enc_Clrt = pt.sk_Fact_Pt_Enc_Clrt					
					
left outer join [DS_HSDW_Prod].[Rptg].[vwDim_Clrt_ADT_Evnt] ev					
on adt.sk_Dim_Clrt_ADT_Evnt=ev.sk_Dim_Clrt_ADT_Evnt					
					
					
order by pt.MRN_int 					
,adt.sk_Fact_Pt_Enc_Clrt					
,adt.seq	