USE DS_HSDM_App

IF OBJECT_ID('tempdb..#ed_overall_mean ') IS NOT NULL
DROP TABLE #ed_overall_mean

IF OBJECT_ID('tempdb..#clinic_willing_to_recommend ') IS NOT NULL
DROP TABLE #clinic_willing_to_recommend

IF OBJECT_ID('tempdb..#inpatient_overall_rating ') IS NOT NULL
DROP TABLE #inpatient_overall_rating

IF OBJECT_ID('tempdb..#ancsvcs_concern_for_privacy ') IS NOT NULL
DROP TABLE #ancsvcs_concern_for_privacy

IF OBJECT_ID('tempdb..#pharma_new_medication_purpose ') IS NOT NULL
DROP TABLE #pharma_new_medication_purpose

IF OBJECT_ID('tempdb..#oascahps_2nd_floor_surgery ') IS NOT NULL
DROP TABLE #oascahps_2nd_floor_surgery

IF OBJECT_ID('tempdb..#oascahps_outpatient_surgery ') IS NOT NULL
DROP TABLE #oascahps_outpatient_surgery

IF OBJECT_ID('tempdb..#pharma_new_medication_side_effects ') IS NOT NULL
DROP TABLE #pharma_new_medication_side_effects

IF OBJECT_ID('tempdb..#inpatient_phlebotomy_cipher_health_score ') IS NOT NULL
DROP TABLE #inpatient_phlebotomy_cipher_health_score

IF OBJECT_ID('tempdb..#ancsvcs_response_to_concern ') IS NOT NULL
DROP TABLE #ancsvcs_response_to_concern

IF OBJECT_ID('tempdb..#ancsvcs_sensitivity_to_needs ') IS NOT NULL
DROP TABLE #ancsvcs_sensitivity_to_needs

IF OBJECT_ID('tempdb..#ancsvcs_pulmonary_function_labs ') IS NOT NULL
DROP TABLE #ancsvcs_pulmonary_function_labs

IF OBJECT_ID('tempdb..#ancsvcs_sleep_disorder_center ') IS NOT NULL
DROP TABLE #ancsvcs_sleep_disorder_center

IF OBJECT_ID('tempdb..#outpatient_phlebotomy_cipher_health_score ') IS NOT NULL
DROP TABLE #outpatient_phlebotomy_cipher_health_score

IF OBJECT_ID('tempdb..#envofcare_quality_of_food ') IS NOT NULL
DROP TABLE #envofcare_quality_of_food

IF OBJECT_ID('tempdb..#envofcare_practice_cleanliness ') IS NOT NULL
DROP TABLE #envofcare_practice_cleanliness

IF OBJECT_ID('tempdb..#envofcare_room_cleanliness ') IS NOT NULL
DROP TABLE #envofcare_room_cleanliness

IF OBJECT_ID('tempdb..#behavhlth_op_overall_mean ') IS NOT NULL
DROP TABLE #behavhlth_op_overall_mean

IF OBJECT_ID('tempdb..#behavhlth_ip_overall_mean ') IS NOT NULL
DROP TABLE #behavhlth_ip_overall_mean

IF OBJECT_ID('tempdb..#ltach_overall_mean ') IS NOT NULL
DROP TABLE #ltach_overall_mean

IF OBJECT_ID('tempdb..#txancsvcs_overall_mean ') IS NOT NULL
DROP TABLE #txancsvcs_overall_mean

IF OBJECT_ID('tempdb..#therapies_admin_score ') IS NOT NULL
DROP TABLE #therapies_admin_score

IF OBJECT_ID('tempdb..#cgcahps_recommend_office ') IS NOT NULL
DROP TABLE #cgcahps_recommend_office

IF OBJECT_ID('tempdb..#oascahps_uvhe_facility_rating ') IS NOT NULL
DROP TABLE #oascahps_uvhe_facility_rating

IF OBJECT_ID('tempdb..#oascahps_uvml_facility_rating ') IS NOT NULL
DROP TABLE #oascahps_uvml_facility_rating

IF OBJECT_ID('tempdb..#oascahps_facility_rating ') IS NOT NULL
DROP TABLE #oascahps_facility_rating

--/*
--
--	FYTD Emergency PressGaney.twbx
--
--	ED PATIENT EXPERIENCE
--	OVERALL MEAN
--
SELECT [event_type]
      ,[event_count]
      ,[event_date]
      ,[event_id]
      ,[event_category]
      ,[epic_department_id]
      ,[epic_department_name]
      ,[epic_department_name_external]
      ,[fmonth_num]
      ,[fyear_num]
      ,[fyear_name]
      ,[report_period]
      ,[report_date]
      ,[peds]
      ,[transplant]
      ,[age_flag]
      ,[sk_Dim_Pt]
      ,[person_birth_date]
      ,[person_gender]
      ,[person_id]
      ,[person_name]
      ,[practice_group_id]
      ,[practice_group_name]
      ,[provider_id]
      ,[provider_name]
      ,[service_line_id]
      ,[service_line]
      ,[sub_service_line_id]
      ,[sub_service_line]
      ,[opnl_service_id]
      ,[opnl_service_name]
      ,[hs_area_id]
      ,[hs_area_name]
      ,[w_department_id]
      ,[w_department_name]
      ,[w_department_name_external]
      ,[w_opnl_service_id]
      ,[w_opnl_service_name]
      ,[w_practice_group_id]
      ,[w_practice_group_name]
      ,[w_service_line_id]
      ,[w_service_line_name]
      ,[w_sub_service_line_id]
      ,[w_sub_service_line_name]
      ,[w_report_period]
      ,[w_report_date]
      ,[w_hs_area_id]
      ,[w_hs_area_name]
      ,[overall_mean]
      ,[Load_Dtm]
  INTO #ed_overall_mean
  FROM [DS_HSDM_App].[TabRptg].[Dash_BalancedScorecard_Emergency_PressGaney_Tiles]
  WHERE [event_type] = 'Emergency-Press Ganey'
  AND w_hs_area_id = 1
  AND event_date BETWEEN '7/1/2019 00:00 AM' AND '5/31/2020 11:59 PM'

  SELECT *
  FROM #ed_overall_mean
  ORDER BY event_date

  --SELECT SUM(event_count) AS N
  --     , SUM(total_overall) AS total_overall
  --     , AVG(overall_mean) AS ED_OVERALL_MEAN_ACTUAL_FY19
	 --  , SUM(total_overall) / CAST(SUM(event_count) AS NUMERIC(9,3)) AS ED_OVERALL_MEAN_ACTUAL_FY19_COMP
  --FROM #ed_overall_mean

  --SELECT w_service_line_id
  --     , w_service_line_name
	 --  , AVG(overall_mean) AS ED_OVERALL_MEAN_ACTUAL_FY19
  --FROM #ed_overall_mean
  --GROUP BY w_service_line_id
  --       , w_service_line_name
  --ORDER BY w_service_line_id
  --       , w_service_line_name
--*/
/*
--
--	FYTD Recommend Office CGCAHPS_BSC.twbx
--
--	CLINIC PATIENT EXPERIENCE
--	WILLING TO RECOMMEND
--
  SELECT
      tile.[event_type]
      ,tile.[event_count]
      ,tile.[event_date]
      ,tile.[event_id]
      ,tile.[event_category]
      ,tile.[epic_department_id]
      ,tile.[epic_department_name]
      ,tile.[epic_department_name_external]
      ,tile.[fmonth_num]
      ,tile.[fyear_num]
      ,tile.[fyear_name]
      ,tile.[report_period]
      ,tile.[report_date]
      ,tile.[peds]
      ,tile.[transplant]
      ,tile.[sk_Dim_Pt]
      ,tile.[sk_Fact_Pt_Acct]
      ,tile.[sk_Fact_Pt_Enc_Clrt]
      ,tile.[person_birth_date]
      ,tile.[person_gender]
      ,tile.[person_id]
      ,tile.[person_name]
      ,tile.[practice_group_id]
      ,tile.[practice_group_name]
      ,tile.[provider_id]
      ,tile.[provider_name]
      ,tile.[service_line_id]
      ,tile.[service_line]
      ,tile.[sub_service_line_id]
      ,tile.[sub_service_line]
      ,tile.[opnl_service_id]
      ,tile.[opnl_service_name]
      ,tile.[corp_service_line_id]
      ,tile.[corp_service_line_name]
      ,tile.[hs_area_id]
      ,tile.[hs_area_name]
      ,tile.[pod_id]
      ,tile.[pod_name]
      ,tile.[hub_id]
      ,tile.[hub_name]
      ,tile.[w_department_id]
      ,tile.[w_department_name]
      ,tile.[w_department_name_external]
      ,tile.[w_practice_group_id]
      ,tile.[w_practice_group_name]
      ,tile.[w_service_line_id]
      ,tile.[w_service_line_name]
      ,tile.[w_sub_service_line_id]
      ,tile.[w_sub_service_line_name]
      ,tile.[w_opnl_service_id]
      ,tile.[w_opnl_service_name]
      ,tile.[w_corp_service_line_id]
      ,tile.[w_corp_service_line_name]
      ,tile.[w_report_period]
      ,tile.[w_report_date]
      ,tile.[w_hs_area_id]
      ,tile.[w_hs_area_name]
      ,tile.[w_pod_id]
      ,tile.[w_pod_name]
      ,tile.[w_hub_id]
      ,tile.[w_hub_name]
      ,tile.[sk_Dim_PG_Question]
      ,tile.[PG_Question_Variable]
      ,tile.[PG_Question_Text]
      ,tile.[sk_Dim_Physcn]
      ,tile.[Load_Dtm]      ,ptdim.Sex
      ,ptdim.Gender_Identity_Name
      ,ptdim.Sexual_Orientation_Name_Current
      ,ptdim.Sex_Asgn_at_Birth_Name
      ,ptdim.FirstRace
      ,ptdim.Ethnicity
      ,ptdim.PreferredLanguage
      ,[Reporting_Period_Enddate] = (SELECT MAX([Reporting_Period_Enddate]) FROM 
       etl.Data_Portal_Metrics_Master WHERE [sk_Data_Portal_Metrics_Master] = 9)
	  ,CASE WHEN [event_category] = 'Yes, definitely' THEN 1 ELSE 0 END AS x_is_9_or_10_answer
	  ,CASE WHEN [event_category] = 'Yes, definitely' THEN tile.event_count ELSE 0 END AS x_is_9_or_10_count

  INTO #clinic_willing_to_recommend

  FROM 
      [DS_HSDM_App].[TabRptg].[Dash_BalancedScorecard_CGCAHPSRecommendProv_Tiles]tile 
LEFT JOIN DS_HSDW_Prod.Rptg.vwDim_Patient ptdim on tile.sk_Dim_Pt = ptdim.sk_Dim_Pt

WHERE
   tile. [event_type] = 'Outpatient-CGCAHPS'
   AND w_hs_area_id = 1
   AND event_date BETWEEN '7/1/2018 00:00 AM' AND '6/30/2019 11:59 PM'

  SELECT *
  FROM #clinic_willing_to_recommend
  ORDER BY event_date

  SELECT SUM(x_is_9_or_10_count) AS x_is_9_or_10_count
       , SUM(event_count) AS event_count
       , CAST(SUM(x_is_9_or_10_count) AS NUMERIC(10,3)) / CAST(SUM(event_count) AS NUMERIC(10,3)) AS x_score
  FROM #clinic_willing_to_recommend

  SELECT w_service_line_id
       , w_service_line_name
       , SUM(x_is_9_or_10_count) AS x_is_9_or_10_count
       , SUM(event_count) AS event_count
       , CAST(SUM(x_is_9_or_10_count) AS NUMERIC(10,3)) / CAST(SUM(event_count) AS NUMERIC(10,3)) AS x_score
  FROM #clinic_willing_to_recommend
  GROUP BY w_service_line_id
         , w_service_line_name
  ORDER BY w_service_line_id
         , w_service_line_name
*/
/*
--
--	FYTD Inpatient HCAHPS Top Box Score.twbx
--
--	INPATIENT EXPERIENCE
--	OVERALL RATING
--
SELECT tile. [event_type]
      ,tile.[event_count]
      ,tile.[event_date]
      ,tile.[event_id]
      ,tile.[event_category]
      ,tile.[epic_department_id]
      ,tile.[epic_department_name]
      ,tile.[epic_department_name_external]
      ,tile.[fmonth_num]
      ,tile.[fyear_num]
      ,tile.[fyear_name]
      ,tile.[report_period]
      ,tile.[report_date]
      ,tile.[peds]
      ,tile.[transplant]
      ,tile.[sk_Dim_Pt]
      ,tile.[person_birth_date]
      ,tile.[person_gender]
      ,tile.[person_id]
      ,tile.[person_name]
      ,tile.[practice_group_id]
      ,tile.[practice_group_name]
      ,tile.[provider_id]
      ,tile.[provider_name]
      ,tile.[service_line_id]
      ,tile.[service_line]
      ,tile.[sub_service_line_id]
      ,tile.[sub_service_line]
      ,tile.[opnl_service_id]
      ,tile.[opnl_service_name]
      ,tile.[hs_area_id]
      ,tile.[hs_area_name]
      ,tile.[w_department_id]
      ,tile.[w_department_name]
      ,tile.[w_department_name_external]
      ,tile.[w_opnl_service_id]
      ,tile.[w_opnl_service_name]
      ,tile.[w_practice_group_id]
      ,tile.[w_practice_group_name]
      ,tile.[w_service_line_id]
      ,tile.[w_service_line_name]
      ,tile.[w_sub_service_line_id]
      ,tile.[w_sub_service_line_name]
      ,tile.[w_report_period]
      ,tile.[w_report_date]
      ,tile.[w_hs_area_id]
      ,tile.[w_hs_area_name]
      ,tile.[Load_Dtm]
      ,ptdim.Sex
      ,ptdim.Gender_Identity_Name
      ,ptdim.Sexual_Orientation_Name_Current
      ,ptdim.Sex_Asgn_at_Birth_Name
      ,ptdim.FirstRace
      ,ptdim.Ethnicity
      ,ptdim.PreferredLanguage
      ,[Reporting_Period_Enddate] = (SELECT MAX([Reporting_Period_Enddate]) FROM 
       etl.Data_Portal_Metrics_Master WHERE [sk_Data_Portal_Metrics_Master] = 8)
	  ,CASE WHEN [event_category] = '10-Best possible' or [event_category] = '9' THEN 1 ELSE 0 END AS x_is_9_or_10_answer
	  ,CASE WHEN [event_category] = '10-Best possible' or [event_category] = '9' THEN tile.event_count ELSE 0 END AS x_is_9_or_10_count

  INTO #inpatient_overall_rating

  FROM 
      [DS_HSDM_App].[TabRptg].[Dash_BalancedScorecard_HCAHPS_Tiles] tile 
LEFT JOIN DS_HSDW_Prod.Rptg.vwDim_Patient ptdim on tile.sk_Dim_Pt = ptdim.sk_Dim_Pt

WHERE
   tile. [event_type] = 'Inpatient-HCAHPS'
   AND w_hs_area_id = 1
   AND event_date BETWEEN '7/1/2018 00:00 AM' AND '6/30/2019 11:59 PM'

  SELECT *
  FROM #inpatient_overall_rating
  ORDER BY event_date

  SELECT SUM(x_is_9_or_10_count) AS x_is_9_or_10_count
       , SUM(event_count) AS event_count
       , CAST(SUM(x_is_9_or_10_count) AS NUMERIC(10,3)) / CAST(SUM(event_count) AS NUMERIC(10,3)) AS x_score
  FROM #inpatient_overall_rating

  SELECT w_service_line_id
       , w_service_line_name
       , SUM(x_is_9_or_10_count) AS x_is_9_or_10_count
       , SUM(event_count) AS event_count
       , CAST(SUM(x_is_9_or_10_count) AS NUMERIC(10,3)) / CAST(SUM(event_count) AS NUMERIC(10,3)) AS x_score
  FROM #inpatient_overall_rating
  GROUP BY w_service_line_id
         , w_service_line_name
  ORDER BY w_service_line_id
         , w_service_line_name
*/
/*
--
--	FYTD Concern for privacy.twbx
--
--	CONCERN FOR PRIVACY
--	PATIENT EXPERIENCE SCORE
--
		 SELECT
       [event_type]
      ,[sk_dim_pg_question]
      ,[event_count]
      ,[event_date]
      ,[event_id]
      ,[event_category]
      ,[score]  
      ,[epic_department_id]
      ,[epic_department_name]
      ,[epic_department_name_external]
      ,[fmonth_num]
      ,[fyear_num]
      ,[fyear_name]
      ,[report_period]
      ,[report_date]
      ,[peds]
      ,[transplant]
      ,[sk_Dim_Pt]
      ,[person_birth_date]
      ,[person_gender]
      ,[person_id]
      ,[person_name]
      ,[practice_group_id]
      ,[practice_group_name]
      ,[provider_id]
      ,[provider_name]
      ,[service_line_id]
      ,[service_line]
      ,[sub_service_line_id]
      ,[sub_service_line]
      ,[opnl_service_id]
      ,[opnl_service_name]
      ,[hs_area_id]
      ,[hs_area_name]
      ,[w_department_id]
      ,[w_department_name]
      ,[w_department_name_external]
      ,CASE WHEN [peds] = 0 AND [transplant] = 0 THEN 6 ELSE NULL END AS [w_opnl_service_id]
      ,CASE WHEN [peds] = 0 AND [transplant] = 0 THEN 'RADIOLOGY' ELSE NULL END AS [w_opnl_service_name]
      ,[w_practice_group_id]
      ,[w_practice_group_name]
      ,[w_service_line_id]
      ,[w_service_line_name]
      ,[w_sub_service_line_id]
      ,[w_sub_service_line_name]
      ,[w_report_period]
      ,[w_report_date]
      ,[w_hs_area_id]
      ,[w_hs_area_name]
      ,[Load_Dtm]
      ,[Reporting_Period_Enddate] = (SELECT MAX([Reporting_Period_Enddate]) FROM 
      etl.Data_Portal_Metrics_Master WHERE [sk_Data_Portal_Metrics_Master] = 71)

INTO #ancsvcs_concern_for_privacy

FROM
    [DS_HSDM_App].[TabRptg].[Dash_BalancedScorecard_PatStatAncSvcs_Tiles]
WHERE (sk_dim_pg_question = '157' OR sk_dim_pg_question IS NULL)
AND (epic_department_id IN
			(
 '10210007'
,'10210008'
,'10210009'
,'10210011'
,'10210018'
,'10210023'
,'10211020'
,'10211021'
,'10214001'
,'10214010'
,'10226001'
,'10228008'
,'10228019'
,'10228021'
,'10228024'
,'10230003'
,'10239007'
,'10239014'
,'10243015'
,'10243016'
,'10243017'
,'10243018'
,'10243019'
,'10243021'
,'10243025'
,'10243030'
,'10243084'
,'10244020'
,'10354001'
,'10354003'
,'10381001'
,'10381002'
,'10381003'
,'10381004'
				)
    OR epic_department_id IS NULL)
   AND w_hs_area_id = 1
   AND CASE WHEN [peds] = 0 AND [transplant] = 0 THEN 6 ELSE NULL END = 6
   AND event_date BETWEEN '7/1/2018 00:00 AM' AND '6/30/2019 11:59 PM'

  SELECT *
  FROM #ancsvcs_concern_for_privacy
  ORDER BY event_date

  SELECT SUM(Score) AS score
       , SUM(event_count) AS event_count
       , CAST(SUM(Score) AS NUMERIC(10,3)) / CAST(SUM(event_count) AS NUMERIC(10,3)) AS x_score
  FROM #ancsvcs_concern_for_privacy

  SELECT w_opnl_service_id
       , w_opnl_service_name
       , SUM(Score) AS score
       , SUM(event_count) AS event_count
       , CAST(SUM(Score) AS NUMERIC(10,3)) / CAST(SUM(event_count) AS NUMERIC(10,3)) AS x_score
  FROM #ancsvcs_concern_for_privacy
  GROUP BY w_opnl_service_id
         , w_opnl_service_name
  ORDER BY w_opnl_service_id
         , w_opnl_service_name
*/
/*
--
--	FYTD New Medication Purpose.twbx
--
--	EXPLAIN NEW MED
--	INPATIENT HCAHPS SCORE
--
SELECT
       [event_type]
      ,[sk_dim_pg_question]
      ,[event_count]
      ,[event_date]
      ,[event_id]
      ,[event_category]
      ,[epic_department_id]
      ,[epic_department_name]
      ,[epic_department_name_external]
      ,[fmonth_num]
      ,[fyear_num]
      ,[fyear_name]
      ,[report_period]
      ,[report_date]
      ,[peds]
      ,[transplant]
      ,[sk_Dim_Pt]
      ,[person_birth_date]
      ,[person_gender]
      ,[person_id]
      ,[person_name]
      ,[practice_group_id]
      ,[practice_group_name]
      ,[provider_id]
      ,[provider_name]
      ,[service_line_id]
      ,[service_line]
      ,[sub_service_line_id]
      ,[sub_service_line]
      ,[opnl_service_id]
      ,[opnl_service_name]
      ,[hs_area_id]
      ,[hs_area_name]
      ,[w_department_id]
      ,[w_department_name]
      ,[w_department_name_external]
      ,5 AS [w_opnl_service_id]
      ,[w_opnl_service_name]
      ,[w_practice_group_id]
      ,[w_practice_group_name]
      ,[w_service_line_id]
      ,[w_service_line_name]
      ,[w_sub_service_line_id]
      ,[w_sub_service_line_name]
      ,[w_report_period]
      ,[w_report_date]
      ,[w_hs_area_id]
      ,[w_hs_area_name]
      ,[Load_Dtm]
      ,[Reporting_Period_Enddate] = (SELECT MAX([Reporting_Period_Enddate]) FROM 
      etl.Data_Portal_Metrics_Master WHERE [sk_Data_Portal_Metrics_Master] = 82)
	  ,CASE WHEN [event_category] = 'Always' THEN 1 ELSE 0 END AS x_is_topbox_answer
	  ,CASE WHEN [event_category] = 'Always' THEN event_count ELSE 0 END AS x_topbox_count

  INTO #pharma_new_medication_purpose

  FROM
    [DS_HSDM_App].[TabRptg].[Dash_BalancedScorecard_PatStatPharma_Tiles]
WHERE
(sk_dim_pg_question = 112 OR sk_dim_pg_question IS NULL) AND
(epic_department_id IN
    (
        '10243062', -- 6EAS
	'10243055', -- 4EAS
	'10243051', -- 3CEN
	'10243053', -- 3WES
	'10243052', -- 3EAS
	'10243054', -- 4CEN
	'10243057', -- 4WES
	'10243060' -- 5WES
    )
OR epic_department_id IS NULL)
   AND w_hs_area_id = 1
   AND event_date BETWEEN '7/1/2018 00:00 AM' AND '6/30/2019 11:59 PM'
   AND peds = 0
   AND transplant = 0

  SELECT *
  FROM #pharma_new_medication_purpose
  ORDER BY event_date

  SELECT SUM(x_topbox_count) AS x_topbox_count
       , SUM(event_count) AS event_count
       , CAST(SUM(x_topbox_count) AS NUMERIC(10,3)) / CAST(SUM(event_count) AS NUMERIC(10,3)) AS x_score
  FROM #pharma_new_medication_purpose

  SELECT w_opnl_service_id
       , w_opnl_service_name
       , SUM(x_topbox_count) AS x_topbox_count
       , SUM(event_count) AS event_count
       , CAST(SUM(x_topbox_count) AS NUMERIC(10,3)) / CAST(SUM(event_count) AS NUMERIC(10,3)) AS x_score
  FROM #pharma_new_medication_purpose
  GROUP BY w_opnl_service_id
         , w_opnl_service_name
  ORDER BY w_opnl_service_id
         , w_opnl_service_name
*/
/*
--
--	FYTD OAS CAHPS Second Floor Surgery.twbx
--
--	2ND FLOOR SURGERY
--	OAS CAHPS SCORE
--
SELECT [event_type]
      ,[event_count]
      ,[event_date]
      ,[event_id]
      ,[event_category]
      ,[epic_department_id]
      ,[epic_department_name]
      ,[epic_department_name_external]
      ,[fmonth_num]
      ,[fyear_num]
      ,[fyear_name]
      ,[report_period]
      ,[report_date]
      ,[peds]
      ,[transplant]
      ,[sk_Dim_Pt]
      ,[person_birth_date]
      ,[person_gender]
      ,[person_id]
      ,[person_name]
      ,[practice_group_id]
      ,[practice_group_name]
      ,[provider_id]
      ,[provider_name]
      ,[service_line_id]
      ,[service_line]
      ,[sub_service_line_id]
      ,[sub_service_line]
      ,[opnl_service_id]
      ,[opnl_service_name]
      ,[hs_area_id]
      ,[hs_area_name]
      ,[w_department_id]
      ,[w_department_name]
      ,[w_department_name_external]
      ,[w_opnl_service_id]
      ,[w_opnl_service_name]
      ,[w_practice_group_id]
      ,[w_practice_group_name]
      ,[w_service_line_id]
      ,[w_service_line_name]
      ,[w_sub_service_line_id]
      ,[w_sub_service_line_name]
      ,[w_report_period]
      ,[w_report_date]
      ,[w_hs_area_id]
      ,[w_hs_area_name]
      ,[sk_Dim_PG_Question]
      ,[Load_Dtm]
      ,[Reporting_Period_Enddate] = (SELECT MAX([Reporting_Period_Enddate]) FROM 
      etl.Data_Portal_Metrics_Master WHERE [sk_Data_Portal_Metrics_Master] = 84)
	  ,CAST(event_category AS NUMERIC(10,4)) AS Score

  INTO #oascahps_2nd_floor_surgery

  FROM 
      [DS_HSDM_App].[TabRptg].[Dash_BalancedScorecard_PatStatAmbSurg_Tiles]
  WHERE
      ([epic_department_id] = '10243900' OR epic_department_id IS NULL)
   AND w_hs_area_id = 1
   AND opnl_service_id = 4
   AND event_date BETWEEN '7/1/2018 00:00 AM' AND '6/30/2019 11:59 PM'

  SELECT *
  FROM #oascahps_2nd_floor_surgery
  ORDER BY event_date

  SELECT AVG(Score) AS x_score
  FROM #oascahps_2nd_floor_surgery
*/
/*
--
--	FYTD OAS CAHPS Outpatient Surgery.twbx
--
--	OUTPATIENT SURGERY
--	OAS CAHPS SCORE
--
SELECT [event_type]
      ,[event_count]
      ,[event_date]
      ,[event_id]
      ,[event_category]
      ,[epic_department_id]
      ,[epic_department_name]
      ,[epic_department_name_external]
      ,[fmonth_num]
      ,[fyear_num]
      ,[fyear_name]
      ,[report_period]
      ,[report_date]
      ,[peds]
      ,[transplant]
      ,[sk_Dim_Pt]
      ,[person_birth_date]
      ,[person_gender]
      ,[person_id]
      ,[person_name]
      ,[practice_group_id]
      ,[practice_group_name]
      ,[provider_id]
      ,[provider_name]
      ,[service_line_id]
      ,[service_line]
      ,[sub_service_line_id]
      ,[sub_service_line]
      ,[opnl_service_id]
      ,[opnl_service_name]
      ,[hs_area_id]
      ,[hs_area_name]
      ,[w_department_id]
      ,[w_department_name]
      ,[w_department_name_external]
      ,[w_opnl_service_id]
      ,[w_opnl_service_name]
      ,[w_practice_group_id]
      ,[w_practice_group_name]
      ,[w_service_line_id]
      ,[w_service_line_name]
      ,[w_sub_service_line_id]
      ,[w_sub_service_line_name]
      ,[w_report_period]
      ,[w_report_date]
      ,[w_hs_area_id]
      ,[w_hs_area_name]
      ,[sk_Dim_PG_Question]
      ,[Load_Dtm]
      ,[Reporting_Period_Enddate] = (SELECT MAX([Reporting_Period_Enddate]) FROM 
      etl.Data_Portal_Metrics_Master WHERE [sk_Data_Portal_Metrics_Master] = 85)
	  ,CAST(event_category AS NUMERIC(10,4)) AS Score

  INTO #oascahps_outpatient_surgery

  FROM 
      [DS_HSDM_App].[TabRptg].[Dash_BalancedScorecard_PatStatAmbSurg_Tiles]
  WHERE
      ([epic_department_id] = '10354900' OR epic_department_id IS NULL)
   AND w_hs_area_id = 1
   AND opnl_service_id = 4
   AND event_date BETWEEN '7/1/2018 00:00 AM' AND '6/30/2019 11:59 PM'

  SELECT *
  FROM #oascahps_outpatient_surgery
  ORDER BY event_date

  SELECT AVG(Score) AS x_score
  FROM #oascahps_outpatient_surgery
*/
/*
--
--	FYTD New Medication Side Effects.twbx
--
--	EXPLAIN SIDE EFFECTS
--	INPATIENT HCAHPS SCORE
--
SELECT
       [event_type]
      ,[sk_dim_pg_question]
      ,[event_count]
      ,[event_date]
      ,[event_id]
      ,[event_category]
      ,[epic_department_id]
      ,[epic_department_name]
      ,[epic_department_name_external]
      ,[fmonth_num]
      ,[fyear_num]
      ,[fyear_name]
      ,[report_period]
      ,[report_date]
      ,[peds]
      ,[transplant]
      ,[sk_Dim_Pt]
      ,[person_birth_date]
      ,[person_gender]
      ,[person_id]
      ,[person_name]
      ,[practice_group_id]
      ,[practice_group_name]
      ,[provider_id]
      ,[provider_name]
      ,[service_line_id]
      ,[service_line]
      ,[sub_service_line_id]
      ,[sub_service_line]
      ,[opnl_service_id]
      ,[opnl_service_name]
      ,[hs_area_id]
      ,[hs_area_name]
      ,[w_department_id]
      ,[w_department_name]
      ,[w_department_name_external]
      ,5 AS [w_opnl_service_id]
      ,[w_opnl_service_name]
      ,[w_practice_group_id]
      ,[w_practice_group_name]
      ,[w_service_line_id]
      ,[w_service_line_name]
      ,[w_sub_service_line_id]
      ,[w_sub_service_line_name]
      ,[w_report_period]
      ,[w_report_date]
      ,[w_hs_area_id]
      ,[w_hs_area_name]
      ,[Load_Dtm]
      ,[Reporting_Period_Enddate] = (SELECT MAX([Reporting_Period_Enddate]) FROM 
      etl.Data_Portal_Metrics_Master WHERE [sk_Data_Portal_Metrics_Master] = 89)
	  ,CASE WHEN [event_category] = 'Always' THEN 1 ELSE 0 END AS x_is_topbox_answer
	  ,CASE WHEN [event_category] = 'Always' THEN event_count ELSE 0 END AS x_topbox_count

  INTO #pharma_new_medication_side_effects

  FROM
    [DS_HSDM_App].[TabRptg].[Dash_BalancedScorecard_PatStatPharma_Tiles]
WHERE
(sk_dim_pg_question = 110 OR sk_dim_pg_question IS NULL) AND
(epic_department_id IN
    (
        '10243062', -- 6EAS
	'10243055', -- 4EAS
	'10243051', -- 3CEN
	'10243053', -- 3WES
	'10243052', -- 3EAS
	'10243054', -- 4CEN
	'10243057', -- 4WES
	'10243060' -- 5WES
    )
OR epic_department_id IS NULL)
   AND event_date BETWEEN '7/1/2018 00:00 AM' AND '6/30/2019 11:59 PM'
   AND peds = 0
   AND transplant = 0

  SELECT *
  FROM #pharma_new_medication_side_effects
  ORDER BY event_date

  SELECT SUM(x_topbox_count) AS x_topbox_count
       , SUM(event_count) AS event_count
       , CAST(SUM(x_topbox_count) AS NUMERIC(10,3)) / CAST(SUM(event_count) AS NUMERIC(10,3)) AS x_score
  FROM #pharma_new_medication_side_effects

  SELECT w_opnl_service_id
       , w_opnl_service_name
       , SUM(x_topbox_count) AS x_topbox_count
       , SUM(event_count) AS event_count
       , CAST(SUM(x_topbox_count) AS NUMERIC(10,3)) / CAST(SUM(event_count) AS NUMERIC(10,3)) AS x_score
  FROM #pharma_new_medication_side_effects
  GROUP BY w_opnl_service_id
         , w_opnl_service_name
  ORDER BY w_opnl_service_id
         , w_opnl_service_name
*/
/*
--
--	FYTD IP Phlebotomy Patient Experience.twbx
--
--	PHLEBOTOMY IP
--	CIPHER HEALTH SCORE
--
SELECT [event_type]
      ,[event_count]
      ,[event_date]
      ,[event_id]
      ,[event_category]
      ,[epic_department_id]
      ,[epic_department_name]
      ,[epic_department_name_external]
      ,[fmonth_num]
      ,[fyear_num]
      ,[fyear_name]
      ,[report_period]
      ,[report_date]
      ,[peds]
      ,[transplant]
      ,[sk_Dim_Pt]
      ,[person_birth_date]
      ,[person_gender]
      ,[person_id]
      ,[person_name]
      ,[practice_group_id]
      ,[practice_group_name]
      ,[provider_id]
      ,[provider_name]
      ,[service_line_id]
      ,[service_line]
      ,[sub_service_line_id]
      ,[sub_service_line]
      ,[opnl_service_id]
      ,[opnl_service_name]
      ,[hs_area_id]
      ,[hs_area_name]
      ,[w_department_id]
      ,[w_department_name]
      ,[w_department_name_external]
      ,[w_opnl_service_id]
      ,[w_opnl_service_name]
      ,[w_practice_group_id]
      ,[w_practice_group_name]
      ,[w_service_line_id]
      ,[w_service_line_name]
      ,[w_sub_service_line_id]
      ,[w_sub_service_line_name]
      ,[w_report_period]
      ,[w_report_date]
      ,[w_hs_area_id]
      ,[w_hs_area_name]
      ,[Score]
      ,[Load_Dtm]
      ,[Reporting_Period_Enddate] = (SELECT MAX([Reporting_Period_Enddate]) FROM 
      etl.Data_Portal_Metrics_Master WHERE [sk_Data_Portal_Metrics_Master] = 90)

  INTO #inpatient_phlebotomy_cipher_health_score

  FROM 
      [DS_HSDM_App].[TabRptg].[Dash_BalancedScorecard_PhlebotomySurvey_Tiles]
  WHERE 
      (event_category = 'Inpatient' OR event_category IS NULL)
   AND w_hs_area_id = 1
   AND w_opnl_service_id = 3
   AND event_date BETWEEN '7/1/2018 00:00 AM' AND '6/30/2019 11:59 PM'

  SELECT *
  FROM #inpatient_phlebotomy_cipher_health_score
  ORDER BY event_date

  SELECT SUM(Score) AS score
       , SUM(event_count) AS event_count
       , CAST(SUM(Score) AS NUMERIC(10,3)) / CAST(SUM(event_count) AS NUMERIC(10,3)) AS x_score
  FROM #inpatient_phlebotomy_cipher_health_score

  SELECT w_opnl_service_id
       , w_opnl_service_name
       , SUM(Score) AS score
       , SUM(event_count) AS event_count
       , CAST(SUM(Score) AS NUMERIC(10,3)) / CAST(SUM(event_count) AS NUMERIC(10,3)) AS x_score
  FROM #inpatient_phlebotomy_cipher_health_score
  GROUP BY w_opnl_service_id
         , w_opnl_service_name
  ORDER BY w_opnl_service_id
         , w_opnl_service_name
*/
/*
--
--	FYTD Responsive to concern.twbx
--
--	RESPONSE TO CONCERN
--	PATIENT EXPERIENCE SCORE
--
SELECT
       [event_type]
      ,[sk_dim_pg_question]
      ,[event_count]
      ,[event_date]
      ,[event_id]
      ,[event_category]
      ,[score]  
      ,[epic_department_id]
      ,[epic_department_name]
      ,[epic_department_name_external]
      ,[fmonth_num]
      ,[fyear_num]
      ,[fyear_name]
      ,[report_period]
      ,[report_date]
      ,[peds]
      ,[transplant]
      ,[sk_Dim_Pt]
      ,[person_birth_date]
      ,[person_gender]
      ,[person_id]
      ,[person_name]
      ,[practice_group_id]
      ,[practice_group_name]
      ,[provider_id]
      ,[provider_name]
      ,[service_line_id]
      ,[service_line]
      ,[sub_service_line_id]
      ,[sub_service_line]
      ,[opnl_service_id]
      ,[opnl_service_name]
      ,[hs_area_id]
      ,[hs_area_name]
      ,[w_department_id]
      ,[w_department_name]
      ,[w_department_name_external]
      ,CASE WHEN [peds] = 0 AND [transplant] = 0 THEN 6 ELSE NULL END AS [w_opnl_service_id]
      ,CASE WHEN [peds] = 0 AND [transplant] = 0 THEN 'RADIOLOGY' ELSE NULL END AS [w_opnl_service_name]
      ,[w_practice_group_id]
      ,[w_practice_group_name]
      ,[w_service_line_id]
      ,[w_service_line_name]
      ,[w_sub_service_line_id]
      ,[w_sub_service_line_name]
      ,[w_report_period]
      ,[w_report_date]
      ,[w_hs_area_id]
      ,[w_hs_area_name]
      ,[Load_Dtm]
      ,[Reporting_Period_Enddate] = (SELECT MAX([Reporting_Period_Enddate]) FROM 
      etl.Data_Portal_Metrics_Master WHERE [sk_Data_Portal_Metrics_Master] = 91)

INTO #ancsvcs_response_to_concern

FROM
    [DS_HSDM_App].[TabRptg].[Dash_BalancedScorecard_PatStatAncSvcs_Tiles]
WHERE (sk_dim_pg_question = '159' OR sk_dim_pg_question IS NULL) AND
(epic_department_id IN
			(
 '10210007'
,'10210008'
,'10210009'
,'10210011'
,'10210018'
,'10210023'
,'10211020'
,'10211021'
,'10214001'
,'10214010'
,'10226001'
,'10228008'
,'10228019'
,'10228021'
,'10228024'
,'10230003'
,'10239007'
,'10239014'
,'10243015'
,'10243016'
,'10243017'
,'10243018'
,'10243019'
,'10243021'
,'10243025'
,'10243030'
,'10243084'
,'10244020'
,'10354001'
,'10354003'
,'10381001'
,'10381002'
,'10381003'
,'10381004'

				)
    OR epic_department_id IS NULL)
   AND w_hs_area_id = 1
   AND CASE WHEN [peds] = 0 AND [transplant] = 0 THEN 6 ELSE NULL END = 6
   AND event_date BETWEEN '7/1/2018 00:00 AM' AND '6/30/2019 11:59 PM'

  SELECT *
  FROM #ancsvcs_response_to_concern
  ORDER BY event_date

  SELECT SUM(Score) AS score
       , SUM(event_count) AS event_count
       , CAST(SUM(Score) AS NUMERIC(10,3)) / CAST(SUM(event_count) AS NUMERIC(10,3)) AS x_score
  FROM #ancsvcs_response_to_concern

  SELECT w_opnl_service_id
       , w_opnl_service_name
       , SUM(Score) AS score
       , SUM(event_count) AS event_count
       , CAST(SUM(Score) AS NUMERIC(10,3)) / CAST(SUM(event_count) AS NUMERIC(10,3)) AS x_score
  FROM #ancsvcs_response_to_concern
  GROUP BY w_opnl_service_id
         , w_opnl_service_name
  ORDER BY w_opnl_service_id
         , w_opnl_service_name
*/
/*
--
--	FYTD Sensitivity to Needs.twbx
--
--	SENSITIVITY TO NEEDS
--	PATIENT EXPERIENCE SCORE
--
SELECT
       [event_type]
      ,[sk_dim_pg_question]
      ,[event_count]
      ,[event_date]
      ,[event_id]
      ,[event_category]
      ,[score]  
      ,[epic_department_id]
      ,[epic_department_name]
      ,[epic_department_name_external]
      ,[fmonth_num]
      ,[fyear_num]
      ,[fyear_name]
      ,[report_period]
      ,[report_date]
      ,[peds]
      ,[transplant]
      ,[sk_Dim_Pt]
      ,[person_birth_date]
      ,[person_gender]
      ,[person_id]
      ,[person_name]
      ,[practice_group_id]
      ,[practice_group_name]
      ,[provider_id]
      ,[provider_name]
      ,[service_line_id]
      ,[service_line]
      ,[sub_service_line_id]
      ,[sub_service_line]
      ,[opnl_service_id]
      ,[opnl_service_name]
      ,[hs_area_id]
      ,[hs_area_name]
      ,[w_department_id]
      ,[w_department_name]
      ,[w_department_name_external]
      ,CASE WHEN [peds] = 0 AND [transplant] = 0 THEN 6 ELSE NULL END AS [w_opnl_service_id]
      ,CASE WHEN [peds] = 0 AND [transplant] = 0 THEN 'RADIOLOGY' ELSE NULL END AS [w_opnl_service_name]
      ,[w_practice_group_id]
      ,[w_practice_group_name]
      ,[w_service_line_id]
      ,[w_service_line_name]
      ,[w_sub_service_line_id]
      ,[w_sub_service_line_name]
      ,[w_report_period]
      ,[w_report_date]
      ,[w_hs_area_id]
      ,[w_hs_area_name]
      ,[Load_Dtm]
      ,[Reporting_Period_Enddate] = (SELECT MAX([Reporting_Period_Enddate]) FROM 
      etl.Data_Portal_Metrics_Master WHERE [sk_Data_Portal_Metrics_Master] = 100)

INTO #ancsvcs_sensitivity_to_needs

FROM
    [DS_HSDM_App].[TabRptg].[Dash_BalancedScorecard_PatStatAncSvcs_Tiles]
WHERE (sk_dim_pg_question = '158' OR sk_dim_pg_question IS NULL) AND
(epic_department_id IN
			(
 '10210007'
,'10210008'
,'10210009'
,'10210011'
,'10210018'
,'10210023'
,'10211020'
,'10211021'
,'10214001'
,'10214010'
,'10226001'
,'10228008'
,'10228019'
,'10228021'
,'10228024'
,'10230003'
,'10239007'
,'10239014'
,'10243015'
,'10243016'
,'10243017'
,'10243018'
,'10243019'
,'10243021'
,'10243025'
,'10243030'
,'10243084'
,'10244020'
,'10354001'
,'10354003'
,'10381001'
,'10381002'
,'10381003'
,'10381004'
				)
    OR epic_department_id IS NULL)
   AND w_hs_area_id = 1
   AND CASE WHEN [peds] = 0 AND [transplant] = 0 THEN 6 ELSE NULL END = 6
   AND event_date BETWEEN '7/1/2018 00:00 AM' AND '6/30/2019 11:59 PM'

  SELECT *
  FROM #ancsvcs_sensitivity_to_needs
  ORDER BY event_date

  SELECT SUM(Score) AS score
       , SUM(event_count) AS event_count
       , CAST(SUM(Score) AS NUMERIC(10,3)) / CAST(SUM(event_count) AS NUMERIC(10,3)) AS x_score
  FROM #ancsvcs_sensitivity_to_needs

  SELECT w_opnl_service_id
       , w_opnl_service_name
       , SUM(Score) AS score
       , SUM(event_count) AS event_count
       , CAST(SUM(Score) AS NUMERIC(10,3)) / CAST(SUM(event_count) AS NUMERIC(10,3)) AS x_score
  FROM #ancsvcs_sensitivity_to_needs
  GROUP BY w_opnl_service_id
         , w_opnl_service_name
  ORDER BY w_opnl_service_id
         , w_opnl_service_name
*/
/*
--
--	FYTD Pulmonary Function Labs.twbx
--
--	PULMONARY FUNCTION
--	PRESS GANEY SCORE
--
SELECT
       [event_type]
      ,[sk_dim_pg_question]
      ,[event_count]
      ,[event_date]
      ,[event_id]
      ,[event_category]
      ,[score]
      ,[epic_department_id]
      ,[epic_department_name]
      ,[epic_department_name_external]
      ,[fmonth_num]
      ,[fyear_num]
      ,[fyear_name]
      ,[report_period]
      ,[report_date]
      ,[peds]
      ,[transplant]
      ,[sk_Dim_Pt]
      ,[person_birth_date]
      ,[person_gender]
      ,[person_id]
      ,[person_name]
      ,[practice_group_id]
      ,[practice_group_name]
      ,[provider_id]
      ,[provider_name]
      ,[service_line_id]
      ,[service_line]
      ,[sub_service_line_id]
      ,[sub_service_line]
      ,[opnl_service_id]
      ,[opnl_service_name]
      ,[hs_area_id]
      ,[hs_area_name]
      ,[w_department_id]
      ,[w_department_name]
      ,[w_department_name_external]
      ,CASE WHEN [peds] = 0 AND [transplant] = 0 THEN 7 ELSE NULL END  AS [w_opnl_service_id]
      ,CASE WHEN [peds] = 0 AND [transplant] = 0 THEN 'THERAPIES' ELSE NULL END AS [w_opnl_service_name]
      ,[w_practice_group_id]
      ,[w_practice_group_name]
      ,[w_service_line_id]
      ,[w_service_line_name]
      ,[w_sub_service_line_id]
      ,[w_sub_service_line_name]
      ,[w_report_period]
      ,[w_report_date]
      ,[w_hs_area_id]
      ,[w_hs_area_name]
      ,[Load_Dtm]
      ,[Reporting_Period_Enddate] = (SELECT MAX([Reporting_Period_Enddate]) FROM
      etl.Data_Portal_Metrics_Master WHERE [sk_Data_Portal_Metrics_Master] = 121)

INTO #ancsvcs_pulmonary_function_labs

FROM
    [DS_HSDM_App].[TabRptg].[Dash_BalancedScorecard_PatStatAncSvcs_Tiles]
WHERE
    ([epic_department_id] IN
    (
	'10353002',
	'10348012',
        '10242019',
	'10244018',
	'10242019',
	'10354007'
    )
   OR epic_department_id IS NULL)
AND (sk_dim_pg_question IN ( '148','149','150','151','152','1075') OR sk_dim_pg_question IS NULL)
   AND w_hs_area_id = 1
   AND CASE WHEN [peds] = 0 AND [transplant] = 0 THEN 7 ELSE NULL END = 7
   AND event_date BETWEEN '7/1/2018 00:00 AM' AND '6/30/2019 11:59 PM'

  SELECT *
  FROM #ancsvcs_pulmonary_function_labs
  ORDER BY event_date

  SELECT SUM(Score) AS score
       , SUM(event_count) AS event_count
       , CAST(SUM(Score) AS NUMERIC(10,3)) / CAST(SUM(event_count) AS NUMERIC(10,3)) AS x_score
  FROM #ancsvcs_pulmonary_function_labs

  SELECT w_opnl_service_id
       , w_opnl_service_name
       , SUM(Score) AS score
       , SUM(event_count) AS event_count
       , CAST(SUM(Score) AS NUMERIC(10,3)) / CAST(SUM(event_count) AS NUMERIC(10,3)) AS x_score
  FROM #ancsvcs_pulmonary_function_labs
  GROUP BY w_opnl_service_id
         , w_opnl_service_name
  ORDER BY w_opnl_service_id
         , w_opnl_service_name
*/
/*
--
--	FYTD Sleep Disorder Center.twbx
--
--	SLEEP DISORDER CENTER
--	PRESS GANEY SCORE
--
SELECT
       [event_type]
      ,[sk_dim_pg_question]
      ,[event_count]
      ,[event_date]
      ,[event_id]
      ,[event_category]
      ,[score]
      ,[epic_department_id]
      ,[epic_department_name]
      ,[epic_department_name_external]
      ,[fmonth_num]
      ,[fyear_num]
      ,[fyear_name]
      ,[report_period]
      ,[report_date]
      ,[peds]
      ,[transplant]
      ,[sk_Dim_Pt]
      ,[person_birth_date]
      ,[person_gender]
      ,[person_id]
      ,[person_name]
      ,[practice_group_id]
      ,[practice_group_name]
      ,[provider_id]
      ,[provider_name]
      ,[service_line_id]
      ,[service_line]
      ,[sub_service_line_id]
      ,[sub_service_line]
      ,[opnl_service_id]
      ,[opnl_service_name]
      ,[hs_area_id]
      ,[hs_area_name]
      ,[w_department_id]
      ,[w_department_name]
      ,[w_department_name_external]
      ,CASE WHEN [peds] = 0 AND [transplant] = 0 THEN 7 ELSE NULL END AS [w_opnl_service_id]
      ,CASE WHEN [peds] = 0 AND [transplant] = 0 THEN 'THERAPIES' ELSE NULL END AS [w_opnl_service_name]
      ,[w_practice_group_id]
      ,[w_practice_group_name]
      ,[w_service_line_id]
      ,[w_service_line_name]
      ,[w_sub_service_line_id]
      ,[w_sub_service_line_name]
      ,[w_report_period]
      ,[w_report_date]
      ,[w_hs_area_id]
      ,[w_hs_area_name]
      ,[Load_Dtm]
      ,[Reporting_Period_Enddate] = (SELECT MAX([Reporting_Period_Enddate]) FROM
      etl.Data_Portal_Metrics_Master WHERE [sk_Data_Portal_Metrics_Master] = 122)

  INTO #ancsvcs_sleep_disorder_center

  FROM
    [DS_HSDM_App].[TabRptg].[Dash_BalancedScorecard_PatStatAncSvcs_Tiles]
  WHERE
    ([epic_department_id] = '10217002' OR epic_department_id IS NULL)
AND (sk_dim_pg_question IN ('148','149','150','151','152','1075') OR sk_dim_pg_question IS NULL)
AND (sk_dim_pg_question IN ( '148','149','150','151','152','1075') OR sk_dim_pg_question IS NULL)
   AND w_hs_area_id = 1
   AND CASE WHEN [peds] = 0 AND [transplant] = 0 THEN 7 ELSE NULL END = 7
   AND event_date BETWEEN '7/1/2018 00:00 AM' AND '6/30/2019 11:59 PM'

  SELECT *
  FROM #ancsvcs_sleep_disorder_center
  ORDER BY event_date

  SELECT SUM(Score) AS score
       , SUM(event_count) AS event_count
       , CAST(SUM(Score) AS NUMERIC(10,3)) / CAST(SUM(event_count) AS NUMERIC(10,3)) AS x_score
  FROM #ancsvcs_sleep_disorder_center

  SELECT w_opnl_service_id
       , w_opnl_service_name
       , SUM(Score) AS score
       , SUM(event_count) AS event_count
       , CAST(SUM(Score) AS NUMERIC(10,3)) / CAST(SUM(event_count) AS NUMERIC(10,3)) AS x_score
  FROM #ancsvcs_sleep_disorder_center
  GROUP BY w_opnl_service_id
         , w_opnl_service_name
  ORDER BY w_opnl_service_id
         , w_opnl_service_name
*/
/*
--
--	FYTD OP Phlebotomy Patient Experience.twbx
--
--	PHLEBOTOMY OP
--	CIPHER HEALTH SCORE
--
SELECT [event_type]
      ,[event_count]
      ,[event_date]
      ,[event_id]
      ,[event_category]
      ,[epic_department_id]
      ,[epic_department_name]
      ,[epic_department_name_external]
      ,[fmonth_num]
      ,[fyear_num]
      ,[fyear_name]
      ,[report_period]
      ,[report_date]
      ,[peds]
      ,[transplant]
      ,[sk_Dim_Pt]
      ,[person_birth_date]
      ,[person_gender]
      ,[person_id]
      ,[person_name]
      ,[practice_group_id]
      ,[practice_group_name]
      ,[provider_id]
      ,[provider_name]
      ,[service_line_id]
      ,[service_line]
      ,[sub_service_line_id]
      ,[sub_service_line]
      ,[opnl_service_id]
      ,[opnl_service_name]
      ,[hs_area_id]
      ,[hs_area_name]
      ,[w_department_id]
      ,[w_department_name]
      ,[w_department_name_external]
      ,[w_opnl_service_id]
      ,[w_opnl_service_name]
      ,[w_practice_group_id]
      ,[w_practice_group_name]
      ,[w_service_line_id]
      ,[w_service_line_name]
      ,[w_sub_service_line_id]
      ,[w_sub_service_line_name]
      ,[w_report_period]
      ,[w_report_date]
      ,[w_hs_area_id]
      ,[w_hs_area_name]
      ,[Score]
      ,[Load_Dtm]
      ,[Reporting_Period_Enddate] = (SELECT MAX([Reporting_Period_Enddate]) FROM 
      etl.Data_Portal_Metrics_Master WHERE [sk_Data_Portal_Metrics_Master] = 126)

  INTO #outpatient_phlebotomy_cipher_health_score

  FROM 
      [DS_HSDM_App].[TabRptg].[Dash_BalancedScorecard_PhlebotomySurvey_Tiles]
  WHERE 
      (event_category = 'Outpatient' OR event_category IS NULL)
   AND w_hs_area_id = 1
   AND w_opnl_service_id = 3
   AND event_date BETWEEN '7/1/2018 00:00 AM' AND '6/30/2019 11:59 PM'

  SELECT *
  FROM #outpatient_phlebotomy_cipher_health_score
  ORDER BY event_date

  SELECT SUM(Score) AS score
       , SUM(event_count) AS event_count
       , CAST(SUM(Score) AS NUMERIC(10,3)) / CAST(SUM(event_count) AS NUMERIC(10,3)) AS x_score
  FROM #outpatient_phlebotomy_cipher_health_score

  SELECT w_opnl_service_id
       , w_opnl_service_name
       , SUM(Score) AS score
       , SUM(event_count) AS event_count
       , CAST(SUM(Score) AS NUMERIC(10,3)) / CAST(SUM(event_count) AS NUMERIC(10,3)) AS x_score
  FROM #outpatient_phlebotomy_cipher_health_score
  GROUP BY w_opnl_service_id
         , w_opnl_service_name
  ORDER BY w_opnl_service_id
         , w_opnl_service_name
*/
/*
--
--	FYTD Quality of Food.twbx
--
--	QUALITY OF FOOD
--	INPATIENT HCAHPS SCORE
--
SELECT [event_type]
      ,[event_count]
      ,[event_date]
      ,[event_id]
      ,[event_category]
      ,[epic_department_id]
      ,[epic_department_name]
      ,[epic_department_name_external]
      ,[fmonth_num]
      ,[fyear_num]
      ,[fyear_name]
      ,[report_period]
      ,[report_date]
      ,[peds]
      ,[transplant]
      ,[sk_Dim_Pt]
      ,[person_birth_date]
      ,[person_gender]
      ,[person_id]
      ,[person_name]
      ,[practice_group_id]
      ,[practice_group_name]
      ,[provider_id]
      ,[provider_name]
      ,[service_line_id]
      ,[service_line]
      ,'Environment of Care' AS corp_service_line
      ,1 AS corp_service_line_id
      ,[sub_service_line_id]
      ,[sub_service_line]
      ,[opnl_service_id]
      ,[opnl_service_name]
      ,[hs_area_id]
      ,[hs_area_name]
      ,[w_department_id]
      ,[w_department_name]
      ,[w_department_name_external]
      ,[w_opnl_service_id]
      ,[w_opnl_service_name]
      ,[w_practice_group_id]
      ,[w_practice_group_name]
      ,[w_service_line_id]
      ,[w_service_line_name]
      ,'Environment of Care' AS w_corp_service_line
      ,'1' AS w_corp_service_line_id
      ,[w_sub_service_line_id]
      ,[w_sub_service_line_name]
      ,[w_report_period]
      ,[w_report_date]
      ,[w_hs_area_id]
      ,[w_hs_area_name]
      ,[sk_Dim_PG_Question]
      ,[UNIT]
      ,[Load_Dtm]
      ,[event_score]
      ,[Reporting_Period_Enddate] = (SELECT MAX([Reporting_Period_Enddate]) FROM
      etl.Data_Portal_Metrics_Master WHERE [sk_Data_Portal_Metrics_Master] = 129)

  INTO #envofcare_quality_of_food

  FROM 
      [DS_HSDM_App].[TabRptg].[Dash_BalancedScorecard_PatSat_HCAHPS_EnvofCare_Tiles]
  WHERE 
      (sk_Dim_PG_Question IN ('85','1103') OR sk_Dim_PG_Question IS NULL)
   AND w_hs_area_id = 1
   AND event_date BETWEEN '7/1/2018 00:00 AM' AND '6/30/2019 11:59 PM'
   AND peds = 0
   AND transplant = 0

  SELECT *
  FROM #envofcare_quality_of_food
  ORDER BY event_date

  SELECT SUM(event_score) AS x_numerator
       , SUM(event_count) AS event_count
       , CAST(SUM(event_score) AS NUMERIC(10,3)) / CAST(SUM(event_count) AS NUMERIC(10,3)) AS x_score
  FROM #envofcare_quality_of_food

  SELECT w_corp_service_line_id
       , w_corp_service_line
       , SUM(event_score) AS x_numerator
       , SUM(event_count) AS event_count
       , CAST(SUM(event_score) AS NUMERIC(10,3)) / CAST(SUM(event_count) AS NUMERIC(10,3)) AS x_score
  FROM #envofcare_quality_of_food
  GROUP BY w_corp_service_line_id
         , w_corp_service_line
  ORDER BY w_corp_service_line_id
         , w_corp_service_line
*/
/*
--
--	FYTD Outpatient Cleanliness.twbx
--
--	PRACTICE CLEANLINESS
--	OUTPATIENT CGCAHPS SCORE
--
SELECT [event_type]
      ,[event_count]
      ,[event_date]
      ,[event_id]
      ,[event_category]
      ,[epic_department_id]
      ,[epic_department_name]
      ,[epic_department_name_external]
      ,[fmonth_num]
      ,[fyear_num]
      ,[fyear_name]
      ,[report_period]
      ,[report_date]
      ,[peds]
      ,[transplant]
      ,[sk_Dim_Pt]
      ,[sk_Fact_Pt_Acct]
      ,[sk_Fact_Pt_Enc_Clrt]
      ,[person_birth_date]
      ,[person_gender]
      ,[person_id]
      ,[person_name]
      ,[practice_group_id]
      ,[practice_group_name]
      ,[provider_id]
      ,[provider_name]
      ,[service_line_id]
      ,[service_line]
      ,[sub_service_line_id]
      ,[sub_service_line]
      ,[opnl_service_id]
      ,[opnl_service_name]
      ,CASE WHEN [event_count] = 1 THEN 1 ELSE NULL END  AS [corp_service_line_id]
      ,CASE WHEN [event_count] = 1 THEN 'Environment of Care' ELSE NULL END AS [corp_service_line_name]
      ,[hs_area_id]
      ,[hs_area_name]
      ,[w_department_id]
      ,[w_department_name]
      ,[w_department_name_external]
      ,[w_practice_group_id]
      ,[w_practice_group_name]
      ,[w_service_line_id]
      ,[w_service_line_name]
      ,[w_sub_service_line_id]
      ,[w_sub_service_line_name]
      ,[w_opnl_service_id]
      ,[w_opnl_service_name]
      ,CASE WHEN [event_count] = 1 THEN 1 ELSE NULL END AS [w_corp_service_line_id]
      ,CASE WHEN [event_count] = 1 THEN 'Environment of Care' ELSE NULL END AS [w_corp_service_line_name]
      ,[w_report_period]
      ,[w_report_date]
      ,[w_hs_area_id]
      ,[w_hs_area_name]
      ,[sk_Dim_PG_Question]
      ,[Load_Dtm]
      ,[event_score]
      ,[Reporting_Period_Enddate] = (SELECT MAX([Reporting_Period_Enddate]) FROM
      etl.Data_Portal_Metrics_Master WHERE [sk_Data_Portal_Metrics_Master] = 130)

  INTO #envofcare_practice_cleanliness

  FROM 
      [DS_HSDM_App].[TabRptg].Dash_BalancedScorecard_PatSat_CGCAHPS_EnvofCare_Tiles
  WHERE 
      (sk_Dim_PG_Question IN ('1848') OR sk_Dim_PG_Question IS NULL)
   AND w_hs_area_id = 1
   AND event_date BETWEEN '7/1/2018 00:00 AM' AND '6/30/2019 11:59 PM'
   AND peds = 0
   AND transplant = 0

  SELECT *
  FROM #envofcare_practice_cleanliness
  ORDER BY event_date

  SELECT SUM(event_score) AS x_numerator
       , SUM(event_count) AS event_count
       , CAST(SUM(event_score) AS NUMERIC(10,3)) / CAST(SUM(event_count) AS NUMERIC(10,3)) AS x_score
  FROM #envofcare_practice_cleanliness

  SELECT w_corp_service_line_id
       , w_corp_service_line_name
       , SUM(event_score) AS x_numerator
       , SUM(event_count) AS event_count
       , CAST(SUM(event_score) AS NUMERIC(10,3)) / CAST(SUM(event_count) AS NUMERIC(10,3)) AS x_score
  FROM #envofcare_practice_cleanliness
  GROUP BY w_corp_service_line_id
         , w_corp_service_line_name
  ORDER BY w_corp_service_line_id
         , w_corp_service_line_name
*/
/*
--
--	FYTD HCAHPS Cleanliness.twbx
--
--	ROOM CLEANLINESS
--	INPATIENT HCAHPS SCORE
--
SELECT [event_type]
      ,[event_count]
      ,[event_date]
      ,[event_id]
      ,[event_category]
      ,[epic_department_id]
      ,[epic_department_name]
      ,[epic_department_name_external]
      ,[fmonth_num]
      ,[fyear_num]
      ,[fyear_name]
      ,[report_period]
      ,[report_date]
      ,[peds]
      ,[transplant]
      ,[sk_Dim_Pt]
      ,[person_birth_date]
      ,[person_gender]
      ,[person_id]
      ,[person_name]
      ,[practice_group_id]
      ,[practice_group_name]
      ,[provider_id]
      ,[provider_name]
      ,[service_line_id]
      ,[service_line]
      ,'Environment of Care' AS corp_service_line
      ,'1' AS corp_service_line_id
      ,[sub_service_line_id]
      ,[sub_service_line]
      ,[opnl_service_id]
      ,[opnl_service_name]
      ,[hs_area_id]
      ,[hs_area_name]
      ,[w_department_id]
      ,[w_department_name]
      ,[w_department_name_external]
      ,[w_opnl_service_id]
      ,[w_opnl_service_name]
      ,[w_practice_group_id]
      ,[w_practice_group_name]
      ,[w_service_line_id]
      ,[w_service_line_name]
      ,'Environment of Care' AS w_corp_service_line
      ,'1' AS w_corp_service_line_id
      ,[w_sub_service_line_id]
      ,[w_sub_service_line_name]
      ,[w_report_period]
      ,[w_report_date]
      ,[w_hs_area_id]
      ,[w_hs_area_name]
      ,[sk_Dim_PG_Question]
      ,[UNIT]
      ,[Load_Dtm]
      ,[event_score]
      ,[Reporting_Period_Enddate] = (SELECT MAX([Reporting_Period_Enddate]) FROM
      etl.Data_Portal_Metrics_Master WHERE [sk_Data_Portal_Metrics_Master] = 131)

  INTO #envofcare_room_cleanliness

  FROM 
      [DS_HSDM_App].[TabRptg].[Dash_BalancedScorecard_PatSat_HCAHPS_EnvofCare_Tiles]
  WHERE 
      (sk_Dim_PG_Question IN ('92','1121') OR sk_Dim_PG_Question IS NULL)
   AND w_hs_area_id = 1
   AND event_date BETWEEN '7/1/2018 00:00 AM' AND '6/30/2019 11:59 PM'
   AND peds = 0
   AND transplant = 0

  SELECT *
  FROM #envofcare_room_cleanliness
  ORDER BY event_date

  SELECT SUM(event_score) AS x_numerator
       , SUM(event_count) AS event_count
       , CAST(SUM(event_score) AS NUMERIC(10,3)) / CAST(SUM(event_count) AS NUMERIC(10,3)) AS x_score
  FROM #envofcare_room_cleanliness

  SELECT w_corp_service_line_id
       , w_corp_service_line
       , SUM(event_score) AS x_numerator
       , SUM(event_count) AS event_count
       , CAST(SUM(event_score) AS NUMERIC(10,3)) / CAST(SUM(event_count) AS NUMERIC(10,3)) AS x_score
  FROM #envofcare_room_cleanliness
  GROUP BY w_corp_service_line_id
         , w_corp_service_line
  ORDER BY w_corp_service_line_id
         , w_corp_service_line
*/
/*
--
--	FYTD OP Behavioral Hlth PressGaney.twbx
--
--	BEHAVIORAL OVERALL
--	OP BEHAV HEALTH SCORE
--
SELECT [event_type]
      ,[event_count]
      ,[event_date]
      ,[event_id]
      ,[event_category]
      ,[epic_department_id]
      ,[epic_department_name]
      ,[epic_department_name_external]
      ,[fmonth_num]
      ,[fyear_num]
      ,[fyear_name]
      ,[report_period]
      ,[report_date]
      ,[peds]
      ,[transplant]
      ,[sk_Dim_Pt]
      ,[sk_Fact_Pt_Acct]
      ,[sk_Fact_Pt_Enc_Clrt]
      ,[person_birth_date]
      ,[person_gender]
      ,[person_id]
      ,[person_name]
      ,[practice_group_id]
      ,[practice_group_name]
      ,[provider_id]
      ,[provider_name]
      ,[service_line_id]
      ,[service_line]
      ,[sub_service_line_id]
      ,[sub_service_line]
      ,[opnl_service_id]
      ,[opnl_service_name]
      ,[corp_service_line_id]
      ,[corp_service_line_name]
      ,[hs_area_id]
      ,[hs_area_name]
      ,[w_department_id]
      ,[w_department_name]
      ,[w_department_name_external]
      ,[w_practice_group_id]
      ,[w_practice_group_name]
      ,[w_service_line_id]
      ,[w_service_line_name]
      ,[w_sub_service_line_id]
      ,[w_sub_service_line_name]
      ,[w_opnl_service_id]
      ,[w_opnl_service_name]
      ,[w_corp_service_line_id]
      ,[w_corp_service_line_name]
      ,[w_report_period]
      ,[w_report_date]
      ,[w_hs_area_id]
      ,[w_hs_area_name]
      ,[overall_mean]
      ,[Load_Dtm]
      ,[Reporting_Period_Enddate] = (SELECT MAX([Reporting_Period_Enddate]) FROM 
       etl.Data_Portal_Metrics_Master WHERE [sk_Data_Portal_Metrics_Master] = 201)

  INTO #behavhlth_op_overall_mean

  FROM
       [DS_HSDM_App].[TabRptg].[Dash_BalancedScorecard_BehavioralHealthPressGaney_Tiles]
  WHERE
       [event_type] = 'Outpatient Behavioral Health'
  AND w_hs_area_id = 1
  AND w_service_line_id = 5
  AND event_date BETWEEN '7/1/2018 00:00 AM' AND '6/30/2019 11:59 PM'

  SELECT *
  FROM #behavhlth_op_overall_mean
  ORDER BY event_date
*/
/*
--
--	FYTD IP Behavioral Hlth PressGaney.twbx
--
--	BEHAVIORAL OVERALL
--	IP BEHAV HEALTH SCORE
--
SELECT [event_type]
      ,[event_count]
      ,[event_date]
      ,[event_id]
      ,[event_category]
      ,[epic_department_id]
      ,[epic_department_name]
      ,[epic_department_name_external]
      ,[fmonth_num]
      ,[fyear_num]
      ,[fyear_name]
      ,[report_period]
      ,[report_date]
      ,[peds]
      ,[transplant]
      ,[sk_Dim_Pt]
      ,[sk_Fact_Pt_Acct]
      ,[sk_Fact_Pt_Enc_Clrt]
      ,[person_birth_date]
      ,[person_gender]
      ,[person_id]
      ,[person_name]
      ,[practice_group_id]
      ,[practice_group_name]
      ,[provider_id]
      ,[provider_name]
      ,[service_line_id]
      ,[service_line]
      ,[sub_service_line_id]
      ,[sub_service_line]
      ,[opnl_service_id]
      ,[opnl_service_name]
      ,[corp_service_line_id]
      ,[corp_service_line_name]
      ,[hs_area_id]
      ,[hs_area_name]
      ,[w_department_id]
      ,[w_department_name]
      ,[w_department_name_external]
      ,[w_practice_group_id]
      ,[w_practice_group_name]
      ,[w_service_line_id]
      ,[w_service_line_name]
      ,[w_sub_service_line_id]
      ,[w_sub_service_line_name]
      ,[w_opnl_service_id]
      ,[w_opnl_service_name]
      ,[w_corp_service_line_id]
      ,[w_corp_service_line_name]
      ,[w_report_period]
      ,[w_report_date]
      ,[w_hs_area_id]
      ,[w_hs_area_name]
      ,[overall_mean]
      ,[Load_Dtm]
      ,[Reporting_Period_Enddate] = (SELECT MAX([Reporting_Period_Enddate]) FROM 
       etl.Data_Portal_Metrics_Master WHERE [sk_Data_Portal_Metrics_Master] = 202)

  INTO #behavhlth_ip_overall_mean

  FROM
       [DS_HSDM_App].[TabRptg].[Dash_BalancedScorecard_BehavioralHealthPressGaney_Tiles]
  WHERE
       [event_type] = 'Inpatient Behavioral Health'
  AND event_date BETWEEN '7/1/2018 00:00 AM' AND '6/30/2019 11:59 PM'

  SELECT *
  FROM #behavhlth_ip_overall_mean
  ORDER BY event_date
*/
/*
--
--	FYTD Overall Mean LTACH Score.twbx
--
--	TCH OVERALL
--	LTACH SCORE
--
SELECT [event_type]
      ,[event_count]
      ,[event_date]
      ,[event_id]
      ,[event_category]
      ,[epic_department_id]
      ,[epic_department_name]
      ,[epic_department_name_external]
      ,[fmonth_num]
      ,[fyear_num]
      ,[fyear_name]
      ,[report_period]
      ,[report_date]
      ,[peds]
      ,[transplant]
      ,[sk_Dim_Pt]
      ,[sk_Fact_Pt_Acct]
      ,[sk_Fact_Pt_Enc_Clrt]
      ,[person_birth_date]
      ,[person_gender]
      ,[person_id]
      ,[person_name]
      ,[practice_group_id]
      ,[practice_group_name]
      ,[provider_id]
      ,[provider_name]
      ,[service_line_id]
      ,[service_line]
      ,[sub_service_line_id]
      ,[sub_service_line]
      ,[opnl_service_id]
      ,[opnl_service_name]
      ,[corp_service_line_id]
      ,[corp_service_line_name]
      ,[hs_area_id]
      ,[hs_area_name]
      ,[w_department_id]
      ,[w_department_name]
      ,[w_department_name_external]
      ,[w_practice_group_id]
      ,[w_practice_group_name]
      ,[w_service_line_id]
      ,[w_service_line_name]
      ,[w_sub_service_line_id]
      ,[w_sub_service_line_name]
      ,[w_opnl_service_id]
      ,[w_opnl_service_name]
      ,[w_corp_service_line_id]
      ,[w_corp_service_line_name]
      ,[w_report_period]
      ,[w_report_date]
      ,[w_hs_area_id]
      ,[w_hs_area_name]
      ,[overall_mean]
      ,[Load_Dtm]
      ,[Reporting_Period_Enddate] = (SELECT MAX([Reporting_Period_Enddate]) FROM 
       etl.Data_Portal_Metrics_Master WHERE [sk_Data_Portal_Metrics_Master] = 210)

  INTO #ltach_overall_mean

  FROM
       [DS_HSDM_App].[TabRptg].[Dash_BalancedScorecard_OverallMeanLTACHScore_Tiles]
  WHERE event_date BETWEEN '7/1/2018 00:00 AM' AND '6/30/2019 11:59 PM'
  --AND w_hs_area_id = 5

  SELECT *
  FROM #ltach_overall_mean
  ORDER BY event_date
*/
/*
SELECT [event_type]
      ,[event_count]
      ,[event_date]
      ,[event_id]
      ,[event_category]
      ,[epic_department_id]
      ,[epic_department_name]
      ,[epic_department_name_external]
      ,[fmonth_num]
      ,[fyear_num]
      ,[fyear_name]
      ,[report_period]
      ,[report_date]
      ,[peds]
      ,[transplant]
      ,[sk_Dim_Pt]
      ,[sk_Fact_Pt_Acct]
      ,[sk_Fact_Pt_Enc_Clrt]
      ,[person_birth_date]
      ,[person_gender]
      ,[person_id]
      ,[person_name]
      ,[practice_group_id]
      ,[practice_group_name]
      ,[provider_id]
      ,[provider_name]
      ,[service_line_id]
      ,[service_line]
      ,[sub_service_line_id]
      ,[sub_service_line]
      ,[opnl_service_id]
      ,[opnl_service_name]
      ,[corp_service_line_id]
      ,[corp_service_line_name]
      ,[hs_area_id]
      ,[hs_area_name]
      ,[w_department_id]
      ,[w_department_name]
      ,[w_department_name_external]
      ,[w_practice_group_id]
      ,[w_practice_group_name]
      ,[w_service_line_id]
      ,[w_service_line_name]
      ,[w_sub_service_line_id]
      ,[w_sub_service_line_name]
      ,[w_opnl_service_id]
      ,[w_opnl_service_name]
      ,[w_corp_service_line_id]
      ,[w_corp_service_line_name]
      ,[w_report_period]
      ,[w_report_date]
      ,[w_hs_area_id]
      ,[w_hs_area_name]
      ,[overall_mean]
      ,[Load_Dtm]
      ,[Reporting_Period_Enddate] = (SELECT MAX([Reporting_Period_Enddate]) FROM 
       etl.Data_Portal_Metrics_Master WHERE [sk_Data_Portal_Metrics_Master] = 228)

  INTO #txancsvcs_overall_mean

  FROM
       [DS_HSDM_App].[TabRptg].[Dash_BalancedScorecard_OverallMeanTransplantAncSvcsScore_Tiles]
  WHERE event_date BETWEEN '7/1/2018 00:00 AM' AND '6/30/2019 11:59 PM'

  SELECT *
  FROM #txancsvcs_overall_mean
  ORDER BY event_date
*/
/*
--
--	FYTD Therapies Administered Patient Satisfaction.twbx
--
--	THERAPIES
--	SURVEY SCORE
--
SELECT 
       [event_type]
      ,[event_count]
      ,[event_date]
      ,[event_id]
      ,[event_category]
      ,[epic_department_id]
      ,[epic_department_name]
      ,[epic_department_name_external]
      ,[fmonth_num]
      ,[fyear_num]
      ,[fyear_name]
      ,[report_period]
      ,[report_date]
      ,[peds]
      ,[transplant]
      ,[sk_Dim_Pt]
      ,[person_birth_date]
      ,[person_gender]
      ,[person_id]
      ,[person_name]
      ,[practice_group_id]
      ,[practice_group_name]
      ,[provider_id]
      ,[provider_name]
      ,[service_line_id]
      ,[service_line]
      ,[sub_service_line_id]
      ,[sub_service_line]
      ,[opnl_service_id]
      ,[opnl_service_name]
      ,[hs_area_id]
      ,[hs_area_name]
      ,[w_department_id]
      ,[w_department_name]
      ,[w_department_name_external]
      ,[w_opnl_service_id]
      ,[w_opnl_service_name]
      ,[w_practice_group_id]
      ,[w_practice_group_name]
      ,[w_service_line_id]
      ,[w_service_line_name]
      ,[w_sub_service_line_id]
      ,[w_sub_service_line_name]
      ,[w_report_period]
      ,[w_report_date]
      ,[w_hs_area_id]
      ,[w_hs_area_name]
      ,[Descr]
      ,[Month_name]
      ,[cmonth_num]
      ,[Score]
      ,[Score_Target]
      ,[Score_Stretch]
      ,[Load_Dtm]
      ,[Reporting_Period_Enddate] = (SELECT MAX([Reporting_Period_Enddate]) FROM
      etl.Data_Portal_Metrics_Master WHERE [sk_Data_Portal_Metrics_Master] = 101)

INTO #therapies_admin_score

FROM 
    [DS_HSDM_App].[TabRptg].[Dash_BalancedScorecard_PreComputed_TherapyAdminPatSat_Tiles]
WHERE

 event_type = 'Therapies Admin Pt Sat'
   AND w_hs_area_id = 1
   AND w_opnl_service_id = 7
   AND event_date BETWEEN '7/1/2018 00:00 AM' AND '6/30/2019 11:59 PM'

  SELECT *
  FROM #therapies_admin_score
  ORDER BY event_date

  SELECT SUM(Score) AS score
       , SUM(event_count) AS event_count
       , CAST(SUM(Score) AS NUMERIC(10,3)) / CAST(SUM(event_count) AS NUMERIC(10,3)) AS x_score
  FROM #therapies_admin_score

  SELECT w_opnl_service_id
       , w_opnl_service_name
       , SUM(Score) AS score
       , SUM(event_count) AS event_count
       , CAST(SUM(Score) AS NUMERIC(10,3)) / CAST(SUM(event_count) AS NUMERIC(10,3)) AS x_score
  FROM #therapies_admin_score
  GROUP BY w_opnl_service_id
         , w_opnl_service_name
  ORDER BY w_opnl_service_id
         , w_opnl_service_name
*/
/*
--
--	FYTD Recommend Office CGCAHPS.twbx
--
--	Recommend Office
--	CGCAHPS Score
--
SELECT
      [event_type]
      ,[event_count]
      ,[event_date]
      ,[event_id]
      ,[event_category]
      ,[epic_department_id]
      ,[epic_department_name]
      ,[epic_department_name_external]
      ,[fmonth_num]
      ,[fyear_num]
      ,[fyear_name]
      ,[report_period]
      ,[report_date]
      ,[peds]
      ,[transplant]
      ,[sk_Dim_Pt]
      ,[sk_Fact_Pt_Acct]
      ,[sk_Fact_Pt_Enc_Clrt]
      ,[person_birth_date]
      ,[person_gender]
      ,[person_id]
      ,[person_name]
      ,[provider_id]
      ,[provider_name]
      ,[w_pod_id]
      ,[w_pod_name]
      ,[w_hub_id]
      ,[w_hub_name]
      ,[w_department_id]
      ,[w_department_name]
      ,[w_department_name_external]
      ,[w_practice_group_id]
      ,[w_practice_group_name]
      ,[w_service_line_id]
      ,[w_service_line_name]
      ,[w_sub_service_line_id]
      ,[w_sub_service_line_name]
      ,[w_opnl_service_id]
      ,[w_opnl_service_name]
      ,[w_corp_service_line_id]
      ,[w_corp_service_line_name]
      ,[w_report_period]
      ,[w_report_date]
      ,[w_hs_area_id]
      ,[w_hs_area_name]
      ,[sk_Dim_Physcn]
      ,[Load_Dtm]
      ,[w_financial_division_id]
      ,[w_financial_division_name]
      ,[w_financial_sub_division_id]
      ,[w_financial_sub_division_name]
      ,[w_rev_location_id]
      ,[w_rev_location]
      ,[w_som_group_id]
      ,[w_som_group_name]
      ,[w_som_department_id]
      ,[w_som_department_name]
      ,[w_som_division_id]
      ,[w_som_division_name]
      ,[w_som_hs_area_id]
      ,[w_som_hs_area_name]
  ,[Reporting_Period_Enddate] = (SELECT MAX([Reporting_Period_Enddate]) FROM 
       etl.Data_Portal_Metrics_Master WHERE [sk_Data_Portal_Metrics_Master] = 193)
	  ,CASE WHEN [event_category] = 'Yes, definitely' THEN event_count ELSE 0 END AS x_numerator

INTO #cgcahps_recommend_office

FROM
    [DS_HSDM_App].[TabRptg].[Dash_AmbOpt_CGCAHPSRecommendProvOffice_Tiles]
   WHERE event_date BETWEEN '7/1/2018 00:00 AM' AND '6/30/2019 11:59 PM'
   AND w_hs_area_id = 1

  SELECT *
  FROM #cgcahps_recommend_office
  ORDER BY event_date

  SELECT SUM(x_numerator) AS x_numerator
       , SUM(event_count) AS event_count
       , CAST(SUM(x_numerator) AS NUMERIC(10,3)) / CAST(SUM(event_count) AS NUMERIC(10,3)) AS x_rate
  FROM #cgcahps_recommend_office

  SELECT w_service_line_id
       , w_service_line_name
       , SUM(x_numerator) AS x_numerator
       , SUM(event_count) AS event_count
       , CAST(SUM(x_numerator) AS NUMERIC(10,3)) / CAST(SUM(event_count) AS NUMERIC(10,3)) AS x_rate
  FROM #cgcahps_recommend_office
  GROUP BY w_service_line_id
         , w_service_line_name
  ORDER BY w_service_line_id
         , w_service_line_name
*/
/*
--
--	FYTD GI UVHE OAS CAHPS.twbx
--
--	Facility Rating
--  UVHE OAS CAHPS Score
--
SELECT
       [event_type]
      ,[event_count]
      ,[event_date]
      ,[event_id]
      ,[event_category]
      ,[epic_department_id]
      ,[epic_department_name]
      ,[epic_department_name_external]
      ,[fmonth_num]
      ,[fyear_num]
      ,[fyear_name]
      ,[report_period]
      ,[report_date]
      ,[peds]
      ,[transplant]
      ,[sk_Dim_Pt]
      ,[sk_Fact_Pt_Acct]
      ,[sk_Fact_Pt_Enc_Clrt]
      ,[person_birth_date]
      ,[person_gender]
      ,[person_id]
      ,[person_name]
      ,[practice_group_id]
      ,[practice_group_name]
      ,[provider_id]
      ,[provider_name]
      ,[service_line_id]
      ,[service_line]
      ,[sub_service_line_id]
      ,[sub_service_line]
      ,[opnl_service_id]
      ,[opnl_service_name]
      ,[corp_service_line_id]
      ,[corp_service_line_name]
      ,[hs_area_id]
      ,[hs_area_name]
      ,[pod_id]
      ,[pod_name]
      ,[hub_id]
      ,[hub_name]
      ,[financial_division_id]
      ,[financial_division_name]
      ,[financial_sub_division_id]
      ,[financial_sub_division_name]
      ,[rev_location_id]
      ,[rev_location]
      ,[som_group_id]
      ,[som_group_name]
      ,[som_department_id]
      ,[som_department_name]
      ,[som_division_id]
      ,[som_division_name]
      ,[w_department_id]
      ,[w_department_name]
      ,[w_department_name_external]
      ,[w_practice_group_id]
      ,[w_practice_group_name]
      ,[w_service_line_id]
      ,[w_service_line_name]
      ,[w_sub_service_line_id]
      ,[w_sub_service_line_name]
      ,[w_opnl_service_id]
      ,[w_opnl_service_name]
      ,[w_corp_service_line_id]
      ,[w_corp_service_line_name]
      ,[w_report_period]
      ,[w_report_date]
      ,[w_hs_area_id]
      ,[w_hs_area_name]
      ,[w_pod_id]
      ,[w_pod_name]
      ,[w_hub_id]
      ,[w_hub_name]
      ,[w_financial_division_id]
      ,[w_financial_division_name]
      ,[w_financial_sub_division_id]
      ,[w_financial_sub_division_name]
      ,[w_rev_location_id]
      ,[w_rev_location]
      ,[w_som_group_id]
      ,[w_som_group_name]
      ,[w_som_department_id]
      ,[w_som_department_name]
      ,[w_som_division_id]
      ,[w_som_division_name]
      ,[w_som_hs_area_id]
      ,[w_som_hs_area_name]
      ,[sk_Dim_Physcn]
      ,[oncology]
      ,[Load_Dtm]
      ,[Reporting_Period_Enddate] = (SELECT MAX([Reporting_Period_Enddate]) FROM
        etl.Data_Portal_Metrics_Master WHERE [sk_Data_Portal_Metrics_Master] = 255)
	  ,CAST([event_category] AS NUMERIC(10,3)) * 100.0 AS x_score

INTO #oascahps_uvhe_facility_rating

FROM [DS_HSDM_App].[TabRptg].Dash_DigestiveHealth_PatSatEndoscopy_Tiles
WHERE event_type = 'GI UVHE OAS CAHPS'
   AND w_hs_area_id = 1
   AND w_department_id = 10243911
   AND event_date BETWEEN '7/1/2018 00:00 AM' AND '6/30/2019 11:59 PM'

  SELECT *
  FROM #oascahps_uvhe_facility_rating
  ORDER BY event_date

  SELECT AVG(x_score) AS x_score
  FROM #oascahps_uvhe_facility_rating
*/
/*
--
--	FYTD GI UVML OAS CAHPS.twbx
--
--	Facility Rating
--  UVML OAS CAHPS Score
--
SELECT       
       [event_type]
      ,[event_count]
      ,[event_date]
      ,[event_id]
      ,[event_category]
      ,[epic_department_id]
      ,[epic_department_name]
      ,[epic_department_name_external]
      ,[fmonth_num]
      ,[fyear_num]
      ,[fyear_name]
      ,[report_period]
      ,[report_date]
      ,[peds]
      ,[transplant]
      ,[sk_Dim_Pt]
      ,[sk_Fact_Pt_Acct]
      ,[sk_Fact_Pt_Enc_Clrt]
      ,[person_birth_date]
      ,[person_gender]
      ,[person_id]
      ,[person_name]
      ,[practice_group_id]
      ,[practice_group_name]
      ,[provider_id]
      ,[provider_name]
      ,[service_line_id]
      ,[service_line]
      ,[sub_service_line_id]
      ,[sub_service_line]
      ,[opnl_service_id]
      ,[opnl_service_name]
      ,[corp_service_line_id]
      ,[corp_service_line_name]
      ,[hs_area_id]
      ,[hs_area_name]
      ,[pod_id]
      ,[pod_name]
      ,[hub_id]
      ,[hub_name]
      ,[financial_division_id]
      ,[financial_division_name]
      ,[financial_sub_division_id]
      ,[financial_sub_division_name]
      ,[rev_location_id]
      ,[rev_location]
      ,[som_group_id]
      ,[som_group_name]
      ,[som_department_id]
      ,[som_department_name]
      ,[som_division_id]
      ,[som_division_name]
      ,[w_department_id]
      ,[w_department_name]
      ,[w_department_name_external]
      ,[w_practice_group_id]
      ,[w_practice_group_name]
      ,[w_service_line_id]
      ,[w_service_line_name]
      ,[w_sub_service_line_id]
      ,[w_sub_service_line_name]
      ,[w_opnl_service_id]
      ,[w_opnl_service_name]
      ,[w_corp_service_line_id]
      ,[w_corp_service_line_name]
      ,[w_report_period]
      ,[w_report_date]
      ,[w_hs_area_id]
      ,[w_hs_area_name]
      ,[w_pod_id]
      ,[w_pod_name]
      ,[w_hub_id]
      ,[w_hub_name]
      ,[w_financial_division_id]
      ,[w_financial_division_name]
      ,[w_financial_sub_division_id]
      ,[w_financial_sub_division_name]
      ,[w_rev_location_id]
      ,[w_rev_location]
      ,[w_som_group_id]
      ,[w_som_group_name]
      ,[w_som_department_id]
      ,[w_som_department_name]
      ,[w_som_division_id]
      ,[w_som_division_name]
      ,[w_som_hs_area_id]
      ,[w_som_hs_area_name]
      ,[sk_Dim_Physcn]
      ,[oncology]
      ,[Load_Dtm]
      ,[Reporting_Period_Enddate] = (SELECT MAX([Reporting_Period_Enddate]) FROM
        etl.Data_Portal_Metrics_Master WHERE [sk_Data_Portal_Metrics_Master] = 256)
	  ,CAST([event_category] AS NUMERIC(10,3)) * 100.0 AS x_score

  INTO #oascahps_uvml_facility_rating

    FROM [DS_HSDM_App].[TabRptg].[Dash_DigestiveHealth_PatSatEndoscopy_Tiles]WHERE [event_type] = 'GI UVML OAS CAHPS'
   AND w_hs_area_id = 1
   AND event_date BETWEEN '7/1/2018 00:00 AM' AND '6/30/2019 11:59 PM'

  SELECT *
  FROM #oascahps_uvml_facility_rating
  ORDER BY event_date

  SELECT AVG(x_score) AS x_score
  FROM #oascahps_uvml_facility_rating
*/
/*
--
--	FYTD GI UVHE UVML OAS CAHPS.twbx
--
--	FACILITY RATING 0-10
--  OAS CAHPS SCORE
--
SELECT       
       [event_type]
      ,[event_count]
      ,[event_date]
      ,[event_id]
      ,[event_category]
      ,[epic_department_id]
      ,[epic_department_name]
      ,[epic_department_name_external]
      ,[fmonth_num]
      ,[fyear_num]
      ,[fyear_name]
      ,[report_period]
      ,[report_date]
      ,[peds]
      ,[transplant]
      ,[sk_Dim_Pt]
      ,[sk_Fact_Pt_Acct]
      ,[sk_Fact_Pt_Enc_Clrt]
      ,[person_birth_date]
      ,[person_gender]
      ,[person_id]
      ,[person_name]
      ,[practice_group_id]
      ,[practice_group_name]
      ,[provider_id]
      ,[provider_name]
      ,[service_line_id]
      ,[service_line]
      ,[sub_service_line_id]
      ,[sub_service_line]
      ,[opnl_service_id]
      ,[opnl_service_name]
      ,[corp_service_line_id]
      ,[corp_service_line_name]
      ,[hs_area_id]
      ,[hs_area_name]
      ,[pod_id]
      ,[pod_name]
      ,[hub_id]
      ,[hub_name]
      ,[financial_division_id]
      ,[financial_division_name]
      ,[financial_sub_division_id]
      ,[financial_sub_division_name]
      ,[rev_location_id]
      ,[rev_location]
      ,[som_group_id]
      ,[som_group_name]
      ,[som_department_id]
      ,[som_department_name]
      ,[som_division_id]
      ,[som_division_name]
      ,[w_department_id]
      ,[w_department_name]
      ,[w_department_name_external]
      ,[w_practice_group_id]
      ,[w_practice_group_name]
      ,[w_service_line_id]
      ,[w_service_line_name]
      ,[w_sub_service_line_id]
      ,[w_sub_service_line_name]
      ,[w_opnl_service_id]
      ,[w_opnl_service_name]
      ,[w_corp_service_line_id]
      ,[w_corp_service_line_name]
      ,[w_report_period]
      ,[w_report_date]
      ,[w_hs_area_id]
      ,[w_hs_area_name]
      ,[w_pod_id]
      ,[w_pod_name]
      ,[w_hub_id]
      ,[w_hub_name]
      ,[w_financial_division_id]
      ,[w_financial_division_name]
      ,[w_financial_sub_division_id]
      ,[w_financial_sub_division_name]
      ,[w_rev_location_id]
      ,[w_rev_location]
      ,[w_som_group_id]
      ,[w_som_group_name]
      ,[w_som_department_id]
      ,[w_som_department_name]
      ,[w_som_division_id]
      ,[w_som_division_name]
      ,[w_som_hs_area_id]
      ,[w_som_hs_area_name]
      ,[sk_Dim_Physcn]
      ,[oncology]
      ,[Load_Dtm]
      ,[Reporting_Period_Enddate] = (SELECT MAX([Reporting_Period_Enddate]) FROM
        etl.Data_Portal_Metrics_Master WHERE [sk_Data_Portal_Metrics_Master] = 257)
	  ,CAST([event_category] AS NUMERIC(10,3)) * 100.0 AS x_score

  INTO #oascahps_facility_rating

  FROM [DS_HSDM_App].[TabRptg].[Dash_DigestiveHealth_PatSatEndoscopy_Tiles]
  WHERE [event_type] = 'GI UVML UVHE OAS CAHPS'
   AND w_hs_area_id = 1
   AND event_date BETWEEN '7/1/2018 00:00 AM' AND '6/30/2019 11:59 PM'

  SELECT *
  FROM #oascahps_facility_rating
  ORDER BY event_date

  SELECT AVG(x_score) AS x_score
  FROM #oascahps_facility_rating
*/
