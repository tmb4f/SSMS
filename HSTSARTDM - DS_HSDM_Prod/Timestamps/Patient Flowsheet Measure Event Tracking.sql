USE DS_HSDM_Prod

SELECT DISTINCT
          fm.CY,
          fm.sk_Fact_Pt_Enc_Clrt,
		  enc.PAT_ENC_CSN_ID,
          fm.sk_Dim_Pt_TmStmp,
		  fm.sk_Cont_Dte,
		  fm.Event_Timestamp,
          fm.[Msr_Rec_Dtm],
		  dfm.TmStmp_Descr,
		  dep.DEPARTMENT_ID,
		  dep.Clrt_DEPt_Nme
 FROM DS_HSDM_Prod.PtTmstmp.Fact_Pt_TmStmp fm WITH(NOLOCK)
 INNER JOIN DS_HSDM_Prod.Rptg.vwFact_Pt_Enc_Clrt enc
 ON enc.sk_Fact_Pt_Enc_Clrt = fm.sk_Fact_Pt_Enc_Clrt
 LEFT OUTER JOIN DS_HSDM_Prod.PtTmstmp.Dim_Pt_TmStmp dfm
 ON dfm.sk_Dim_Pt_TmStmp = fm.sk_Dim_Pt_TmStmp
 LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Clrt_DEPt dep
 ON dep.sk_Dim_Clrt_DEPt = enc.sk_Dim_Clrt_DEPt
 WHERE (fm.sk_Cont_Dte BETWEEN 20200701 AND 20210125)
 AND dep.Clrt_DEPt_Nme = 'UVHE CARDIAC SURGERY'
 ORDER BY dep.Clrt_DEPt_Nme
        , enc.PAT_ENC_CSN_ID
        , fm.Event_Timestamp