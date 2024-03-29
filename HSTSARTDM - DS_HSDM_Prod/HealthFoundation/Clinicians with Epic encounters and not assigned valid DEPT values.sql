USE DS_HSDM_Prod

--SELECT [ADm_Dt]
--      ,[Atn_Dr]
--	  ,ser.sk_Dim_Physcn
--	  ,physcn.sk_Dim_Physcn AS Dim_Physcn_sk_Dim_Physcn
--	  ,physcn.IDNumber
--	  ,physcn.current_flag
--	  ,physcn.DEPT
--      ,[Atn_Dr_LName]
--      ,[Atn_Dr_FName]
--      ,[Atn_Dr_MI]
--      ,[Atn_Dr_Type]
--      ,[Atn_Dr_Status]
--      ,[Atn_Dr_Last_Update_Dt]
--      ,[Source]
--      ,[IO_Flag]
--      ,[Sex]
--      ,[Birth_Dt]
--      ,[Age]
--      ,[Age_Group]
--      ,[Pt_FName_MI]
--      ,[Pt_LName]
--      ,[CURR_PT_ADDR1]
--      ,[CURR_PT_ADDR2]
--      ,[CURR_PT_CITY]
--      ,[CURR_PT_STATE]
--      ,[CURR_PT_ZIP]
--      ,[CURR_PT_PHONE]
--      ,[GUAR_FNAME]
--      ,[GUAR_MNANE]
--      ,[GUAR_LNAME]
--      ,[GUAR_ADDR1]
--      ,[GUAR_ADDR2]
--      ,[GUAR_CITY]
--      ,[GUAR_STATE]
--      ,[GUAR_ZIP]
--      ,[GUAR_PHONE]
--      ,[GUAR_TO_PT]
--      ,enc.[Status]
--      ,enc.[Email]
--      ,[PAT_ID]
--      ,[load_date_time]
--      ,[Atnd_Dr_SMS_ID]
--  FROM [HSDO].[ADT_GPP_Encounters] enc
--  LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Clrt_SERsrc ser
--  ON ser.PROV_ID = enc.Atn_Dr
--  LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Physcn physcn
--  ON physcn.sk_Dim_Physcn = ser.sk_Dim_Physcn
--  WHERE (physcn.current_flag = 1) AND (physcn.sk_Dim_Physcn > 0) AND (physcn.DEPT IN ('Unknown', 'NA', 'Clinical Practice Group_UPG', 'Clinical Practice Group_u', 'Invalid', 'No Value Specified'))
--  ORDER BY enc.Atn_Dr_LName, enc.Atn_Dr_FName, enc.Atn_Dr_MI, enc.ADm_Dt

  

SELECT DISTINCT
      -- [ADm_Dt]
      --,[Atn_Dr]
       [Atn_Dr]
	  ,ser.sk_Dim_Physcn
	  --,physcn.sk_Dim_Physcn AS Dim_Physcn_sk_Dim_Physcn
	  ,physcn.IDNumber
	  ,physcn.current_flag
	  ,physcn.DEPT
      ,[Atn_Dr_LName]
      ,[Atn_Dr_FName]
      ,[Atn_Dr_MI]
      ,[Atn_Dr_Type]
      ,[Atn_Dr_Status]
      ,[Atn_Dr_Last_Update_Dt]
      --,[Source]
      --,[IO_Flag]
      --,[Sex]
      --,[Birth_Dt]
      --,[Age]
      --,[Age_Group]
      --,[Pt_FName_MI]
      --,[Pt_LName]
      --,[CURR_PT_ADDR1]
      --,[CURR_PT_ADDR2]
      --,[CURR_PT_CITY]
      --,[CURR_PT_STATE]
      --,[CURR_PT_ZIP]
      --,[CURR_PT_PHONE]
      --,[GUAR_FNAME]
      --,[GUAR_MNANE]
      --,[GUAR_LNAME]
      --,[GUAR_ADDR1]
      --,[GUAR_ADDR2]
      --,[GUAR_CITY]
      --,[GUAR_STATE]
      --,[GUAR_ZIP]
      --,[GUAR_PHONE]
      --,[GUAR_TO_PT]
      --,enc.[Status]
      --,enc.[Email]
      --,[PAT_ID]
      --,[load_date_time]
      ,[Atnd_Dr_SMS_ID]
  FROM [HSDO].[ADT_GPP_Encounters] enc
  LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Clrt_SERsrc ser
  ON ser.PROV_ID = enc.Atn_Dr
  LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwDim_Physcn physcn
  ON physcn.sk_Dim_Physcn = ser.sk_Dim_Physcn
  WHERE (physcn.current_flag = 1) AND (physcn.sk_Dim_Physcn > 0) AND (physcn.DEPT IN ('Unknown', 'NA', 'Clinical Practice Group_UPG', 'Clinical Practice Group_u', 'Invalid', 'No Value Specified'))
  --ORDER BY enc.Atn_Dr_LName, enc.Atn_Dr_FName, enc.Atn_Dr_MI, enc.ADm_Dt
  ORDER BY enc.Atn_Dr_LName, enc.Atn_Dr_FName, enc.Atn_Dr_MI