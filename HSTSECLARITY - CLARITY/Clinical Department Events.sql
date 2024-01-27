USE CLARITY
-- Select First Event

  DECLARE @StartDate DATETIME,
          @EndDate DATETIME

--  SET @StartDate = CONVERT(DATETIME,CONVERT(VARCHAR(10),DATEADD(dd,-16,GETDATE()),101) + ' 00:00:00')
--  SET @EndDate   = CONVERT(DATETIME,CONVERT(VARCHAR(10),DATEADD(dd,0,GETDATE()),101) + ' 02:00:00')
--;

SET @StartDate = '7/1/2020 00:00 AM'
SET @EndDate = '7/1/2022 00:00 AM'

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
--WHERE dvsn.Department_ID = 259 -- MD-PHMR Phys Med & Rehab
)

--SELECT *
--FROM providers

 --  SELECT
 --    hsp.PAT_ENC_CSN_ID      AS Visit_Number
	--,ev.EVENT_PROV_ID
	--,providers.PROV_ID
	--,providers.PROV_NAME
	--,ev.EVENT_TYPE
	--,ev.EVENT_TYPE
	--,ev.EVENT_STATUS_NAME
	--,ev.EVENT_DISPLAY_NAME
 -- FROM dbo.ED_IEV_EVENT_INFO      AS ev WITH (NOLOCK)
 -- INNER JOIN providers ON ev.EVENT_PROV_ID = providers.PROV_ID
 -- INNER JOIN dbo.ED_IEV_PAT_INFO  AS patenc WITH (NOLOCK) ON ev.EVENT_ID            = patenc.EVENT_ID
 -- INNER JOIN dbo.PAT_ENC_HSP      AS hsp WITH (NOLOCK)    ON  patenc.PAT_ENC_CSN_ID = hsp.PAT_ENC_CSN_ID
 -- --WHERE ev.EVENT_STATUS_C IS  NULL
 -- -- AND hsp.HSP_ACCOUNT_ID IS NOT NULL
 -- -- AND ev.EVENT_TIME BETWEEN @StartDate AND @EndDate
 -- WHERE
 --   ev.EVENT_TIME BETWEEN @StartDate AND @EndDate
	--ORDER BY ev.EVENT_DISPLAY_NAME

   SELECT DISTINCT
	 ev.EVENT_TYPE
	,ev.EVENT_DISPLAY_NAME
  FROM dbo.ED_IEV_EVENT_INFO      AS ev WITH (NOLOCK)
  INNER JOIN providers ON ev.EVENT_PROV_ID = providers.PROV_ID
  --INNER JOIN dbo.ED_IEV_PAT_INFO  AS patenc WITH (NOLOCK) ON ev.EVENT_ID            = patenc.EVENT_ID
  --INNER JOIN dbo.PAT_ENC_HSP      AS hsp WITH (NOLOCK)    ON  patenc.PAT_ENC_CSN_ID = hsp.PAT_ENC_CSN_ID
  --WHERE ev.EVENT_STATUS_C IS  NULL
  -- AND hsp.HSP_ACCOUNT_ID IS NOT NULL
  -- AND ev.EVENT_TIME BETWEEN @StartDate AND @EndDate
  WHERE
    ev.EVENT_TIME BETWEEN @StartDate AND @EndDate
	ORDER BY ev.EVENT_DISPLAY_NAME
/*
  -- Select event date/times based on EVENT_TYPE

  SELECT pat.PAT_MRN_ID,
     Visit_Number
	,ed.ADT_ARRIVAL_DTTM
    ,MIN(Departure_Dt)                       AS Departure_Dt
    ,MIN(Ready_for_ReEval_Dt)                AS Ready_for_ReEval_Dt
    ,MIN(AMA_Disposition_Dt)                 AS AMA_Disposition_Dt
    ,MIN(LWBS_Disposition_Dt)                AS LWBS_Disposition_Dt
    ,MIN(Eloped_Disposition_Dt)              AS Eloped_Disposition_Dt
    ,MIN(SHE_Disposition_Dt)                 AS SHE_Disposition_Dt
    ,MIN(SANE_Disposition_Dt)                AS SANE_Disposition_Dt
    ,MIN(LWBD_Disposition_Dt)                AS LWBD_Disposition_Dt
    ,MIN(Admit_Disposition_Dt)               AS Admit_Disposition_Dt
    ,MIN(Discharge_Disposition_Dt)           AS Discharge_Disposition_Dt
    ,MIN(Transferred_Disposition_Dt)         AS Transferred_Disposition_Dt
    ,MIN(Deceased_Disposition_Dt)            AS Deceased_Disposition_Dt
    ,MIN(Sent_to_LD_Disposition_Dt)          AS Sent_to_LD_Disposition_Dt
    ,MIN(RegError_Disposition_Dt)            AS RegError_Disposition_Dt
    ,MIN(Boarder_Dt)                         AS Boarder_Dt
    ,MIN(Observation_Dt)                     AS Observation_Dt
    ,MIN(Dismiss_Dt)                         AS Dismiss_Dt
    ,MIN(Cardiology_Called_Dt)               AS Cardiology_Called_Dt
    ,MIN(Cardiology_ReCalled_Dt)             AS Cardiology_ReCalled_Dt
    ,MIN(Cardiology_Responded_Dt)            AS Cardiology_Responded_Dt
    ,MIN(Cardiology_in_ED_Dt)                AS Cardiology_in_ED_Dt
    ,MIN(Cardiology_Consult_Complete_Dt)     AS Cardiology_Consult_Complete_Dt
    ,MIN(MICU_Called_Dt)                     AS MICU_Called_Dt
    ,MIN(MICU_ReCalled_Dt)                   AS MICU_ReCalled_Dt
    ,MIN(MICU_Responded_Dt)                  AS MICU_Responded_Dt
    ,MIN(MICU_in_ED_Dt)                      AS MICU_in_ED_Dt
    ,MIN(MICU_Consult_Complete_Dt)           AS MICU_Consult_Complete_Dt
    ,MIN(Neurology_Called_Dt)                AS Neurology_Called_Dt
    ,MIN(Neurology_ReCalled_Dt)              AS Neurology_ReCalled_Dt
    ,MIN(Neurology_Responded_Dt)             AS Neurology_Responded_Dt
    ,MIN(Neurology_in_ED_Dt)                 AS Neurology_in_ED_Dt
    ,MIN(Neurology_Consult_Complete_Dt)      AS Neurology_Consult_Complete_Dt
    ,MIN(Ortho_Called_Dt)                    AS Ortho_Called_Dt
    ,MIN(Ortho_ReCalled_Dt)                  AS Ortho_ReCalled_Dt
    ,MIN(Ortho_Responded_Dt)                 AS Ortho_Responded_Dt
    ,MIN(Ortho_in_ED_Dt)                     AS Ortho_in_ED_Dt
    ,MIN(Ortho_Consult_Complete_Dt)          AS Ortho_Consult_Complete_Dt
    ,MIN(Other_Called_Dt)                    AS Other_Called_Dt
    ,MIN(Other_ReCalled_Dt)                  AS Other_ReCalled_Dt
    ,MIN(Other_Responded_Dt)                 AS Other_Responded_Dt
    ,MIN(Other_in_ED_Dt)                     AS Other_in_ED_Dt
    ,MIN(Other_Consult_Complete_Dt)          AS Other_Consult_Complete_Dt
    ,MIN(Otolaryngology_Called_Dt)           AS Otolaryngology_Called_Dt
    ,MIN(Otolaryngology_ReCalled_Dt)         AS Otolaryngology_ReCalled_Dt
    ,MIN(Otolaryngology_Responded_Dt)        AS Otolaryngology_Responded_Dt
    ,MIN(Otolaryngology_in_ED_Dt)            AS Otolaryngology_in_ED_Dt
    ,MIN(Otolaryngology_Consult_Complete_Dt) AS Otolaryngology_Consult_Complete_Dt
    ,MIN(Psychiatry_Called_Dt)               AS Psychiatry_Called_Dt
    ,MIN(Psychiatry_ReCalled_Dt)             AS Psychiatry_ReCalled_Dt
    ,MIN(Psychiatry_Responded_Dt)            AS Psychiatry_Responded_Dt
    ,MIN(Psychiatry_in_ED_Dt)                AS Psychiatry_in_ED_Dt
    ,MIN(Psychiatry_Consult_Complete_Dt)     AS Psychiatry_Consult_Complete_Dt
    ,MIN(Surgery_Called_Dt)                  AS Surgery_Called_Dt
    ,MIN(Surgery_ReCalled_Dt)                AS Surgery_ReCalled_Dt
    ,MIN(Surgery_Responded_Dt)               AS Surgery_Responded_Dt
    ,MIN(Surgery_in_ED_Dt)                   AS Surgery_in_ED_Dt
    ,MIN(Surgery_Consult_Complete_Dt)        AS Surgery_Consult_Complete_Dt
    ,MIN(Toxicology_Called_Dt)               AS Toxicology_Called_Dt
    ,MIN(Toxicology_Recalled_Dt)             AS Toxicology_Recalled_Dt
    ,MIN(Toxicology_Responded_Dt)            AS Toxicology_Responded_Dt
    ,MIN(Toxicology_in_ED_Dt)                AS Toxicology_in_ED_Dt
    ,MIN(Toxicology_Consult_Complete_Dt)     AS Toxicology_Consult_Complete_Dt
    ,MIN(PreAdmit_Disposition_Dt)            AS PreAdmit_Disposition_Dt
    ,MIN(Registration_Dt)                    AS Registration_Dt
    ,MIN(Triage_Start_Dt)                    AS Triage_Start_Dt
    ,MIN(Triage_End_Dt)                      AS Triage_End_Dt
    ,MIN(Patient_Roomed_Dt)                  AS Patient_Roomed_Dt
    ,MIN(Admit_to_OBS_Disposition_Dt)        AS Admit_to_OBS_Disposition_Dt
    ,MIN(Went_to_Floor_Dt)                   AS Went_to_Floor_Dt
    ,MIN(Neurosurgery_Called_Dt)             AS Neurosurgery_Called_Dt
    ,MIN(Neurosurgery_ReCalled_Dt)           AS Neurosurgery_ReCalled_Dt
    ,MIN(Neurosurgery_Responded_Dt)          AS Neurosurgery_Responded_Dt
    ,MIN(Neurosurgery_in_ED_Dt)              AS Neurosurgery_in_ED_Dt
    ,MIN(Neurosurgery_Consult_Complete_Dt)   AS Neurosurgery_Consult_Complete_Dt
    ,MIN(Plastics_Called_Dt)                 AS Plastics_Called_Dt
    ,MIN(Plastics_ReCalled_Dt)               AS Plastics_ReCalled_Dt
    ,MIN(Plastics_Responded_Dt)              AS Plastics_Responded_Dt
    ,MIN(Plastics_in_ED_Dt)                  AS Plastics_in_ED_Dt
    ,MIN(Plastics_Consult_Complete_Dt)       AS Plastics_Consult_Complete_Dt
    ,MIN(Peds_Surgery_Called_Dt)             AS Peds_Surgery_Called_Dt
    ,MIN(Peds_Surgery_ReCalled_Dt)           AS Peds_Surgery_ReCalled_Dt
    ,MIN(Peds_Surgery_Responded_Dt)          AS Peds_Surgery_Responded_Dt
    ,MIN(Peds_Surgery_In_ED_Dt)              AS Peds_Surgery_In_ED_Dt
    ,MIN(Peds_Surgery_Consult_Complete_Dt)   AS Peds_Surgery_Consult_Complete_Dt
    ,MIN(CCU_Called_Dt)                      AS CCU_Called_Dt
    ,MIN(CCU_ReCalled_Dt)                    AS CCU_ReCalled_Dt
    ,MIN(CCU_Responded_Dt)                   AS CCU_Responded_Dt
    ,MIN(CCU_In_ED_Dt)                       AS CCU_In_ED_Dt
    ,MIN(CCU_Consult_Complete_Dt)            AS CCU_Consult_Complete_Dt
    ,MIN(OBGYN_Called_Dt)                    AS OBGYN_Called_Dt
    ,MIN(OBGYN_ReCalled_Dt)                  AS OBGYN_ReCalled_Dt
    ,MIN(OBGYN_Responded_Dt)                 AS OBGYN_Responded_Dt
    ,MIN(OBGYN_In_ED_Dt)                     AS OBGYN_In_ED_Dt
    ,MIN(OBGYN_Consult_Complete_Dt)          AS OBGYN_Consult_Complete_Dt
    ,MIN(Trauma_Called_Dt)                   AS Trauma_Called_Dt
    ,MIN(Trauma_ReCalled_Dt)                 AS Trauma_ReCalled_Dt
    ,MIN(Trauma_Responded_Dt)                AS Trauma_Responded_Dt
    ,MIN(Trauma_In_ED_Dt)                    AS Trauma_In_ED_Dt
    ,MIN(Trauma_Consult_Complete_Dt)         AS Trauma_Consult_Complete_Dt
  FROM
  (
   SELECT
     hsp.PAT_ENC_CSN_ID      AS Visit_Number
    ,CASE WHEN ev.EVENT_TYPE = '95'         THEN ev.EVENT_TIME END  AS Departure_Dt
    ,CASE WHEN ev.EVENT_TYPE = '1602050004' THEN ev.EVENT_TIME END  AS Ready_for_ReEval_Dt
    ,CASE WHEN ev.EVENT_TYPE = '16022201'   THEN ev.EVENT_TIME END  AS AMA_Disposition_Dt
    ,CASE WHEN ev.EVENT_TYPE = '1602220101' THEN ev.EVENT_TIME END  AS LWBS_Disposition_Dt
    ,CASE WHEN ev.EVENT_TYPE = '1602220102' THEN ev.EVENT_TIME END  AS Eloped_Disposition_Dt
    ,CASE WHEN ev.EVENT_TYPE = '1602220103' THEN ev.EVENT_TIME END  AS SHE_Disposition_Dt
    ,CASE WHEN ev.EVENT_TYPE = '1602220104' THEN ev.EVENT_TIME END  AS SANE_Disposition_Dt
    ,CASE WHEN ev.EVENT_TYPE = '1602220106' THEN ev.EVENT_TIME END  AS LWBD_Disposition_Dt
    ,CASE WHEN ev.EVENT_TYPE = '1061222'    THEN ev.EVENT_TIME END  AS Admit_Disposition_Dt
    ,CASE WHEN ev.EVENT_TYPE = '1060222'    THEN ev.EVENT_TIME END  AS Discharge_Disposition_Dt
    ,CASE WHEN ev.EVENT_TYPE = '1062222'    THEN ev.EVENT_TIME END  AS Transferred_Disposition_Dt
    ,CASE WHEN ev.EVENT_TYPE = '1601224'    THEN ev.EVENT_TIME END  AS Deceased_Disposition_Dt
    ,CASE WHEN ev.EVENT_TYPE = '245'        THEN ev.EVENT_TIME END  AS Sent_to_LD_Disposition_Dt
    ,CASE WHEN ev.EVENT_TYPE = '1602220105' THEN ev.EVENT_TIME END  AS RegError_Disposition_Dt
    ,CASE WHEN ev.EVENT_TYPE = '106222'     THEN ev.EVENT_TIME END  AS Boarder_Dt
    ,CASE WHEN ev.EVENT_TYPE = '1602220201' THEN ev.EVENT_TIME END  AS Observation_Dt
    ,CASE WHEN ev.EVENT_TYPE = '75'         THEN ev.EVENT_TIME END  AS Dismiss_Dt
    ,CASE WHEN ev.EVENT_TYPE = '250'        THEN ev.EVENT_TIME END  AS Cardiology_Called_Dt
    ,CASE WHEN ev.EVENT_TYPE = '252'        THEN ev.EVENT_TIME END  AS Cardiology_ReCalled_Dt
    ,CASE WHEN ev.EVENT_TYPE = '253'        THEN ev.EVENT_TIME END  AS Cardiology_Responded_Dt
    ,CASE WHEN ev.EVENT_TYPE = '251'        THEN ev.EVENT_TIME END  AS Cardiology_in_ED_Dt
    ,CASE WHEN ev.EVENT_TYPE = '16025103'   THEN ev.EVENT_TIME END  AS Cardiology_Consult_Complete_Dt
    ,CASE WHEN ev.EVENT_TYPE = '16025004'   THEN ev.EVENT_TIME END  AS MICU_Called_Dt
    ,CASE WHEN ev.EVENT_TYPE = '16025204'   THEN ev.EVENT_TIME END  AS MICU_ReCalled_Dt
    ,CASE WHEN ev.EVENT_TYPE = '16025303'   THEN ev.EVENT_TIME END  AS MICU_Responded_Dt
    ,CASE WHEN ev.EVENT_TYPE = '16025104'   THEN ev.EVENT_TIME END  AS MICU_in_ED_Dt
    ,CASE WHEN ev.EVENT_TYPE = '1602510401' THEN ev.EVENT_TIME END  AS MICU_Consult_Complete_Dt
    ,CASE WHEN ev.EVENT_TYPE = '258'        THEN ev.EVENT_TIME END  AS Neurology_Called_Dt
    ,CASE WHEN ev.EVENT_TYPE = '260'        THEN ev.EVENT_TIME END  AS Neurology_ReCalled_Dt
    ,CASE WHEN ev.EVENT_TYPE = '261'        THEN ev.EVENT_TIME END  AS Neurology_Responded_Dt
    ,CASE WHEN ev.EVENT_TYPE = '259'        THEN ev.EVENT_TIME END  AS Neurology_in_ED_Dt
    ,CASE WHEN ev.EVENT_TYPE = '16025903'   THEN ev.EVENT_TIME END  AS Neurology_Consult_Complete_Dt
    ,CASE WHEN ev.EVENT_TYPE = '262'        THEN ev.EVENT_TIME END  AS Ortho_Called_Dt
    ,CASE WHEN ev.EVENT_TYPE = '264'        THEN ev.EVENT_TIME END  AS Ortho_ReCalled_Dt
    ,CASE WHEN ev.EVENT_TYPE = '265'        THEN ev.EVENT_TIME END  AS Ortho_Responded_Dt
    ,CASE WHEN ev.EVENT_TYPE = '263'        THEN ev.EVENT_TIME END  AS Ortho_in_ED_Dt
    ,CASE WHEN ev.EVENT_TYPE = '16026303'   THEN ev.EVENT_TIME END  AS Ortho_Consult_Complete_Dt
    ,CASE WHEN ev.EVENT_TYPE = '266'        THEN ev.EVENT_TIME END  AS Other_Called_Dt
    ,CASE WHEN ev.EVENT_TYPE = '268'        THEN ev.EVENT_TIME END  AS Other_ReCalled_Dt
    ,CASE WHEN ev.EVENT_TYPE = '269'        THEN ev.EVENT_TIME END  AS Other_Responded_Dt
    ,CASE WHEN ev.EVENT_TYPE = '267'        THEN ev.EVENT_TIME END  AS Other_in_ED_Dt
    ,CASE WHEN ev.EVENT_TYPE = '16026703'   THEN ev.EVENT_TIME END  AS Other_Consult_Complete_Dt
    ,CASE WHEN ev.EVENT_TYPE = '16025006'   THEN ev.EVENT_TIME END  AS Otolaryngology_Called_Dt
    ,CASE WHEN ev.EVENT_TYPE = '16025206'   THEN ev.EVENT_TIME END  AS Otolaryngology_ReCalled_Dt
    ,CASE WHEN ev.EVENT_TYPE = '16025306'   THEN ev.EVENT_TIME END  AS Otolaryngology_Responded_Dt
    ,CASE WHEN ev.EVENT_TYPE = '16025406'   THEN ev.EVENT_TIME END  AS Otolaryngology_in_ED_Dt
    ,CASE WHEN ev.EVENT_TYPE = '16025106'   THEN ev.EVENT_TIME END  AS Otolaryngology_Consult_Complete_Dt
    ,CASE WHEN ev.EVENT_TYPE = '16025002'   THEN ev.EVENT_TIME END  AS Psychiatry_Called_Dt
    ,CASE WHEN ev.EVENT_TYPE = '16025202'   THEN ev.EVENT_TIME END  AS Psychiatry_ReCalled_Dt
    ,CASE WHEN ev.EVENT_TYPE = '16025302'   THEN ev.EVENT_TIME END  AS Psychiatry_Responded_Dt
    ,CASE WHEN ev.EVENT_TYPE = '16025102'   THEN ev.EVENT_TIME END  AS Psychiatry_in_ED_Dt
    ,CASE WHEN ev.EVENT_TYPE = '1602510201' THEN ev.EVENT_TIME END  AS Psychiatry_Consult_Complete_Dt
    ,CASE WHEN ev.EVENT_TYPE = '278'        THEN ev.EVENT_TIME END  AS Surgery_Called_Dt
    ,CASE WHEN ev.EVENT_TYPE = '280'        THEN ev.EVENT_TIME END  AS Surgery_ReCalled_Dt
    ,CASE WHEN ev.EVENT_TYPE = '281'        THEN ev.EVENT_TIME END  AS Surgery_Responded_Dt
    ,CASE WHEN ev.EVENT_TYPE = '279'        THEN ev.EVENT_TIME END  AS Surgery_in_ED_Dt
    ,CASE WHEN ev.EVENT_TYPE = '16027903'   THEN ev.EVENT_TIME END  AS Surgery_Consult_Complete_Dt
    ,CASE WHEN ev.EVENT_TYPE = '16025007'   THEN ev.EVENT_TIME END  AS Toxicology_Called_Dt
    ,CASE WHEN ev.EVENT_TYPE = '16025207'   THEN ev.EVENT_TIME END  AS Toxicology_Recalled_Dt
    ,CASE WHEN ev.EVENT_TYPE = '16025307'   THEN ev.EVENT_TIME END  AS Toxicology_Responded_Dt
    ,CASE WHEN ev.EVENT_TYPE = '16025107'   THEN ev.EVENT_TIME END  AS Toxicology_in_ED_Dt
    ,CASE WHEN ev.EVENT_TYPE = '1602510701' THEN ev.EVENT_TIME END  AS Toxicology_Consult_Complete_Dt
    ,CASE WHEN ev.EVENT_TYPE = '1601100002' THEN ev.EVENT_TIME END  AS PreAdmit_Disposition_Dt
    ,CASE WHEN ev.EVENT_TYPE = '220'        THEN ev.EVENT_TIME END  AS Registration_Dt
    ,CASE WHEN ev.EVENT_TYPE = '205'        THEN ev.EVENT_TIME END  AS Triage_Start_Dt
    ,CASE WHEN ev.EVENT_TYPE = '210'        THEN ev.EVENT_TIME END  AS Triage_End_Dt
    ,CASE WHEN ev.EVENT_TYPE = '55'         THEN ev.EVENT_TIME END  AS Patient_Roomed_Dt
    ,CASE WHEN ev.EVENT_TYPE = '1601223'    THEN ev.EVENT_TIME END  AS Admit_to_OBS_Disposition_Dt
    ,CASE WHEN ev.EVENT_TYPE = '1601060055' THEN ev.EVENT_TIME END  AS Went_to_Floor_Dt
    ,CASE WHEN ev.EVENT_TYPE = '16025001'   THEN ev.EVENT_TIME END  AS Neurosurgery_Called_Dt
    ,CASE WHEN ev.EVENT_TYPE = '16026403'   THEN ev.EVENT_TIME END  AS Neurosurgery_ReCalled_Dt
    ,CASE WHEN ev.EVENT_TYPE = '16026503'   THEN ev.EVENT_TIME END  AS Neurosurgery_Responded_Dt
    ,CASE WHEN ev.EVENT_TYPE = '16025101'   THEN ev.EVENT_TIME END  AS Neurosurgery_in_ED_Dt
    ,CASE WHEN ev.EVENT_TYPE = '16026307'   THEN ev.EVENT_TIME END  AS Neurosurgery_Consult_Complete_Dt
    ,CASE WHEN ev.EVENT_TYPE = '16025005'   THEN ev.EVENT_TIME END  AS Plastics_Called_Dt
    ,CASE WHEN ev.EVENT_TYPE = '15025205'   THEN ev.EVENT_TIME END  AS Plastics_ReCalled_Dt
    ,CASE WHEN ev.EVENT_TYPE = '16025305'   THEN ev.EVENT_TIME END  AS Plastics_Responded_Dt
    ,CASE WHEN ev.EVENT_TYPE = '16025105'   THEN ev.EVENT_TIME END  AS Plastics_in_ED_Dt
    ,CASE WHEN ev.EVENT_TYPE = '16026306'   THEN ev.EVENT_TIME END  AS Plastics_Consult_Complete_Dt
    ,CASE WHEN ev.EVENT_TYPE = '16026202'   THEN ev.EVENT_TIME END  AS Peds_Surgery_Called_Dt
    ,CASE WHEN ev.EVENT_TYPE = '16026402'   THEN ev.EVENT_TIME END  AS Peds_Surgery_ReCalled_Dt
    ,CASE WHEN ev.EVENT_TYPE = '16026502'   THEN ev.EVENT_TIME END  AS Peds_Surgery_Responded_Dt
    ,CASE WHEN ev.EVENT_TYPE = '1600025903' THEN ev.EVENT_TIME END  AS Peds_Surgery_In_ED_Dt
    ,CASE WHEN ev.EVENT_TYPE = '16026305'   THEN ev.EVENT_TIME END  AS Peds_Surgery_Consult_Complete_Dt
    ,CASE WHEN ev.EVENT_TYPE = '1600025801' THEN ev.EVENT_TIME END  AS CCU_Called_Dt
    ,CASE WHEN ev.EVENT_TYPE = '1600026001' THEN ev.EVENT_TIME END  AS CCU_ReCalled_Dt
    ,CASE WHEN ev.EVENT_TYPE = '1600026101' THEN ev.EVENT_TIME END  AS CCU_Responded_Dt
    ,CASE WHEN ev.EVENT_TYPE = '1600025901' THEN ev.EVENT_TIME END  AS CCU_In_ED_Dt
    ,CASE WHEN ev.EVENT_TYPE = '1602830301' THEN ev.EVENT_TIME END  AS CCU_Consult_Complete_Dt
    ,CASE WHEN ev.EVENT_TYPE = '160258'     THEN ev.EVENT_TIME END  AS OBGYN_Called_Dt
    ,CASE WHEN ev.EVENT_TYPE = '160260'     THEN ev.EVENT_TIME END  AS OBGYN_ReCalled_Dt
    ,CASE WHEN ev.EVENT_TYPE = '160261'     THEN ev.EVENT_TIME END  AS OBGYN_Responded_Dt
    ,CASE WHEN ev.EVENT_TYPE = '160259'     THEN ev.EVENT_TIME END  AS OBGYN_In_ED_Dt
    ,CASE WHEN ev.EVENT_TYPE = '16028303'   THEN ev.EVENT_TIME END  AS OBGYN_Consult_Complete_Dt
    ,CASE WHEN ev.EVENT_TYPE = '1600025802' THEN ev.EVENT_TIME END  AS Trauma_Called_Dt
    ,CASE WHEN ev.EVENT_TYPE = '1600026002' THEN ev.EVENT_TIME END  AS Trauma_ReCalled_Dt
    ,CASE WHEN ev.EVENT_TYPE = '1600026102' THEN ev.EVENT_TIME END  AS Trauma_Responded_Dt
    ,CASE WHEN ev.EVENT_TYPE = '1600025902' THEN ev.EVENT_TIME END  AS Trauma_In_ED_Dt
    ,CASE WHEN ev.EVENT_TYPE = '1602830302' THEN ev.EVENT_TIME END  AS Trauma_Consult_Complete_Dt
  FROM dbo.ED_IEV_EVENT_INFO      AS ev WITH (NOLOCK)
  INNER JOIN dbo.ED_IEV_PAT_INFO  AS patenc WITH (NOLOCK) ON ev.EVENT_ID            = patenc.EVENT_ID
  INNER JOIN dbo.PAT_ENC_HSP      AS hsp WITH (NOLOCK)    ON  patenc.PAT_ENC_CSN_ID = hsp.PAT_ENC_CSN_ID
  WHERE ev.EVENT_STATUS_C IS  NULL
   AND hsp.HSP_ACCOUNT_ID IS NOT NULL
   AND ev.EVENT_TIME BETWEEN @StartDate AND @EndDate
   AND ev.EVENT_TYPE IN ('55','75','95',
                         '205','210','220','245','250','251',
                         '252','253','258','259','260','261',
                         '262','263','264','265','266','267',
                         '268','269','278','279','280','281',
                         '106222','160258','160259',
                         '160260','160261',
                         '1060222','1061222','1062222','1601223',
                         '1601224',
                         '15025205','16022201','16025001','16025002',
                         '16025004','16025005','16025006','16025007',
                         '16025101','16025102','16025103','16025104',
                         '16025105','16025106','16025107','16025202',
                         '16025204','16025206','16025207','16025302',
                         '16025303','16025305','16025306','16025307',
                         '16025406','16025903','16026202','16026303',
                         '16026305','16026306','16026307','16026402',
                         '16026403','16026502','16026503','16026703',
                         '16027903','16028303',
                         '1600025801','1600025802','1600025901',
                         '1600025902','1600025903','1600026001',
                         '1600026002','1600026101','1600026102',
                         '1601060055','1601100002','1602050004',
                         '1602220101','1602220102','1602220103',
                         '1602220104','1602220105','1602220106',
                         '1602220201','1602510201','1602510401',
                         '1602510701','1602830301','1602830302')
 ) AS A
 INNER JOIN dbo.F_ED_ENCOUNTERS ed ON ed.PAT_ENC_CSN_ID = A.Visit_Number
 INNER JOIN dbo.PATIENT pat ON pat.PAT_ID = ed.PAT_ID
 GROUP BY pat.PAT_MRN_ID,Visit_Number, ed.ADT_ARRIVAL_DTTM
 ORDER BY ed.ADT_ARRIVAL_DTTM
 */