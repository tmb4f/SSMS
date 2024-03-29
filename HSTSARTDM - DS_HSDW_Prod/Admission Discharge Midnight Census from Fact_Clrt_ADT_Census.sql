/****** Script for SelectTopNRows command from SSMS  ******/
SELECT [EVENT_ID]
      ,[PAT_ENC_CSN_ID]
      ,[sk_Fact_Pt_Enc_Clrt]
      ,[sk_Dim_Pt]
      ,[HSP_ACCOUNT_ID]
      ,[AcctNbr_Clrt]
      ,[ADT_In_Dtm]
      ,[sk_ADT_In_Dte]
      ,[sk_ADT_In_Tm]
      ,[ADT_Out_Dtm]
      ,[sk_ADT_Out_Dte]
      ,[sk_ADT_Out_Tm]
      ,[Enter_Dtm]
      ,[sk_ADT_Enter_Dte]
      ,[sk_ADT_Enter_Tm]
      ,[Adm_Event_Id]
      ,[Dis_Event_Id]
      ,[Xfer_in_Event_Id]
      ,[Xfer_Out_Event_Id]
      ,[sk_Dim_Clrt_DEPt]
      ,[sk_Dim_Clrt_Rm]
      ,[sk_Dim_Clrt_Bed]
      ,[Envt_Sub_Nme]
      ,[Fr_Base_Cls]
      ,[To_Base_Cls]
      ,[Labor_Sts]
      ,[sk_Dim_AccountClass]
      ,[sk_Dim_HospitalService]
      ,adt.[sk_Dim_Clrt_ADT_Evnt]
	  ,evnt.ADT_Evnt_Nme
      ,[sk_ADT_Evnt_In]
      ,[sk_ADT_Evnt_Out]
      ,[Seq_Num_in_Enc]
      ,[Seq_Num_in_Bed_Min]
      ,[Admit]
      ,[Discharge]
      ,[Pt_Days]
      ,[Occ_Minutes]
      ,adt.[Load_Dtm]
      ,[ETL_GUID]
      ,[UpDte_Dtm]
      ,[sk_Dim_BedUnit]
  FROM [DS_HSDW_Prod].[Rptg].[vwFact_Clrt_ADT_Census] adt
  LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Clrt_ADT_Evnt evnt
  ON evnt.sk_Dim_Clrt_ADT_Evnt = adt.sk_Dim_Clrt_ADT_Evnt
  WHERE adt.sk_Dim_Clrt_ADT_Evnt IN (1,2,6)
  ORDER BY sk_ADT_In_Dte
                    , adt.PAT_ENC_CSN_ID