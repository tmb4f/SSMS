USE [CLARITY_App]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--DECLARE @Enter_Start_Period VARCHAR(10) ,
--    @Enter_End_Period VARCHAR(10)

--SET @Enter_Start_Period = '4/1/2021'
--SET @Enter_End_Period = '4/30/2021'

ALTER PROCEDURE [ETL].[uspSrc_ADT_PressGaney_OASCAHPS]
    @Enter_Start_Period VARCHAR(10) ,            --    Uses the Epic function to convert dates and use relative 'mb-1', 'me-1', etc. values
    @Enter_End_Period VARCHAR(10)

AS
/*******************************************************************************************
WHAT   : Press Ganey - All outpatient procedure encounters

WHO    : Patient Experience Office
WHEN   : Quarterly
WHY    : Press Ganey Survey
AUTHOR : Mali Amarasinghe
SPEC   :
--------------------------------------------------------------------------------------------
INPUTS:

OUTPUTS:
       1) SEQUENCE:                File 1 of 4 (1 of 1 in SQL)
       2) FILE NAMING CONVENTION:  UVA_2561_OASCAHPS_Monthly_mmddyyyy
       3) OUTPUT TYPE:             space delimited csv
       4) TRANSFER METHOD:         sFTP
       5) OUTPUT LOCATION:         Press Ganey

       6) FREQUENCY:               Monthly
       7) QUERY LOOKBACK PERIOD:   T-1    (Today-1 days)
       8) FILE SPECIFIC NOTES:

MODS:
    01/18/2018 - WDR4F Bill Reed New Build
    01/23/2018 - WDR4F Bill Reed replace commas with ^ in pat_name, ADDRESS, Prov_name, Primary_dx,
                 GUAR_Address, GUAR_ADDR1, GUAR_ADDR2
    04/16/2018 - WDR4F - REPLACE changes the size of the field to 8000. Added a CAST to truncate the size to the actual size
	05/25/2018 - Mali -- Add columns --SMS ID (field 27), Service line (82) and DeptID_Name (83)
	06/14/2018 - Mali -- PROV_NAME format change to first name, last name
	11/16/2018 - Add ERAS Flag
				- remove '," from Gauranter name
	02/06/2019 - Update ERAS flag to look at Pat_Link_ID (PAT_ID) instead of the CSN
	07/09/2019 - First Name Field changed to Add Prefered name if avaialble
	07/07/2020 - Press Ganey Spec Update
					remove the State Regulated and No Publicity patient types
					may retain the fields themselves
    02/18/2021 - Mali A. Add Cancelled procedure filter
	05/05/2021 - Tom B. Add Race and Ethnicity
	05/06/2021 - Tom B. Per a request from Data Ops, restore columns fill05 and fill06
---------------------------------------------------------------------------------------------------

**********************************************************************************************/

  -- SET NOCOUNT ON added to prevent extra result sets from
  -- interfering with SELECT statements.

  SET NOCOUNT ON;

  DECLARE @Start_Date DATETIME = CLARITY.EPIC_UTIL.EFN_DIN(@Enter_Start_Period);
  DECLARE @End_Date   DATETIME = DATEADD(DAY,1,CLARITY.EPIC_UTIL.EFN_DIN(@Enter_End_Period));  -- Add 1 to date entered and use < in WHERE to catch all of the upper bound of date

  -- Date parameters for clarity date function : T-7  = Today - 7 days
  --                                             mb-1 = Previous month begin date
  --                                             me-1 = Previous month end date
  --
        SELECT DISTINCT
    --'AV**'
    CASE WHEN (ordep.DEPARTMENT_ID = '10243037'
            AND hsp.ADT_PAT_CLASS_C NOT IN ('101','108')) -- Inpatient , Inpatient Surgery
            THEN 'AS0201'
            ELSE dsgn.NAME
    END                                                          AS 'designator'
    ,'2561'                                                      AS 'UVA_Code'
    ,'01'                                                        AS 'O1'
    --,orlg.SURGERY_DATE
    ,COALESCE(hsp.ADT_PAT_CLASS_C,  zcsrgclass.ABBR)                                      AS 'Patient_Class'

    ,CASE WHEN procCat.PROC_CAT_NAME = 'CV ELECTROPHYSIO ORDERABLES'
       THEN '10243013'                                                                 -- Electrophysiology
       ELSE loc.OR_DEPARTMENT_ID
     END                                                         AS 'Department ID'

    ,CASE WHEN procCat.PROC_CAT_NAME = 'CV ELECTROPHYSIO ORDERABLES'
       THEN 'Electrophysiology'
       ELSE ordep.EXTERNAL_NAME
     END                                                         AS 'Department_External_Name'
    ,CAST(REPLACE(pt.PAT_NAME,',','^') AS VARCHAR(200))          AS 'PAT_NAME'
    ,pt.PAT_LAST_NAME
    ,COALESCE(pt3.PREFERRED_NAME,pt.PAT_FIRST_NAME)				AS 'PAT_PREF_FIRST_NAME'
    ,COALESCE(pt.PAT_MIDDLE_NAME,'')                             AS 'Pt_Middle_Name'
    ,CAST(REPLACE(adrs.ADDRESS,',','^') AS VARCHAR(3500))        AS 'ADDRESS'
    ,pt.CITY
    ,ste.ABBR
    ,pt.ZIP
    ,CAST(REPLACE(pt.HOME_PHONE,'-','') AS VARCHAR(8000))        AS 'Phone'
    ,COALESCE(pt.COUNTY_C,'')                                    AS 'Pt_County'
    ,CONVERT(VARCHAR(10),pt.BIRTH_DATE,101)                      AS 'Date_of_Birth'
    ,DATEDIFF(YEAR,pt.BIRTH_DATE,orlg.SURGERY_DATE)              AS 'Age'              ---check the best time to use
    ,pt.SEX_C
    ,sx.ABBR                                                     AS 'SEX'
    ,ISNULL(CAST(enc.COVERAGE_ID AS VARCHAR(10)), '')            AS 'Coverage_ID'
    ,idx.IDENTITY_ID
    ,enc.HSP_ACCOUNT_ID
    ,enc.PAT_ENC_CSN_ID
    ,hsp.HOSP_SERV_C
    --,enc.VISIT_PROV_ID
    --  ,CAST(REPLACE(prov.PROV_NAME,',','^') AS VARCHAR(200))       AS 'PROV_NAME'
	,CONCAT(
	CAST (CASE
	       WHEN CHARINDEX(',',prov.PROV_NAME) > 2 THEN
	         CASE
	           WHEN CHARINDEX(' ', SUBSTRING(prov.PROV_NAME, CHARINDEX(',',prov.PROV_NAME)+2, LEN(prov.PROV_NAME))) > 2 THEN
	             LTRIM(SUBSTRING(prov.PROV_NAME,CHARINDEX(',',prov.PROV_NAME)+1,CHARINDEX(' ', SUBSTRING(prov.PROV_NAME, CHARINDEX(',',prov.PROV_NAME)+2, LEN(prov.PROV_NAME)))))
	           ELSE LTRIM(SUBSTRING(prov.PROV_NAME, CHARINDEX(',',prov.PROV_NAME)+1, LEN(prov.PROV_NAME)))
	         END
	       ELSE ''
	     END AS VARCHAR(25))                               -- AS Atn_Dr_FName
		 ,' '
	    ,CAST(CASE
	       WHEN CHARINDEX(',',prov.PROV_NAME) > 2 THEN -- found lastname, now look for space in first name to split middle name out
	         CASE
	           WHEN CHARINDEX(' ', SUBSTRING(prov.PROV_NAME, CHARINDEX(',',prov.PROV_NAME)+2, LEN(prov.PROV_NAME))) > 2 THEN
	             LTRIM(SUBSTRING(SUBSTRING(prov.PROV_NAME, CHARINDEX(',',prov.PROV_NAME)+2, LEN(prov.PROV_NAME)),
	                       CHARINDEX(' ', SUBSTRING(prov.PROV_NAME, CHARINDEX(',',prov.PROV_NAME)+2, LEN(prov.PROV_NAME)))+1,
	                       LEN(prov.PROV_NAME)))
	         ELSE ''
	       END
	       ELSE ''
	      END AS VARCHAR(25))                              -- AS Atn_Dr_MI
		  ,' '
	,CAST(CASE
	       WHEN CHARINDEX(',',prov.PROV_NAME) > 2 THEN
	         CASE
	           WHEN CHARINDEX(' JR', SUBSTRING(prov.PROV_NAME,1, CHARINDEX(',', prov.PROV_NAME)-1)) > 2 THEN
	             LTRIM(SUBSTRING(prov.PROV_NAME,1, CHARINDEX(' JR', SUBSTRING(prov.PROV_NAME,1, CHARINDEX(',', prov.PROV_NAME)-1))-1))
	           WHEN CHARINDEX(' SR', SUBSTRING(prov.PROV_NAME,1, CHARINDEX(',', prov.PROV_NAME)-1)) > 2 THEN
	             LTRIM(SUBSTRING(prov.PROV_NAME,1, CHARINDEX(' SR', SUBSTRING(prov.PROV_NAME,1, CHARINDEX(',', prov.PROV_NAME)-1))-1))
	           WHEN CHARINDEX(' I', SUBSTRING(prov.PROV_NAME,1, CHARINDEX(',', prov.PROV_NAME)-1)) > 2 THEN
	             LTRIM(SUBSTRING(prov.PROV_NAME,1, CHARINDEX(' I', SUBSTRING(prov.PROV_NAME,1, CHARINDEX(',', prov.PROV_NAME)-1))-1))
	              ELSE LTRIM(SUBSTRING(prov.PROV_NAME, 1, CHARINDEX(',',prov.PROV_NAME)-1))
	         END
	       ELSE LTRIM(prov.PROV_NAME)
	     END AS VARCHAR(25))                              -- AS Atn_Dr_LName
		  )														AS 'PROV_NAME'
    ,sms.IDENTITY_ID                                             AS 'SMS_ID'
    ,ser.NPI
    ,CAST(REPLACE(COALESCE(edg.DX_NAME,''),',','^') AS VARCHAR(200)) AS 'Primary_Dx'
    ,COALESCE(icd1.CODE,'')                                      AS 'icd1'
    ,COALESCE(icd2.CODE,'')                                      AS 'icd2'
    ,COALESCE(icd3.CODE,'')                                      AS 'icd3'
    ,COALESCE(icd4.CODE,'')                                      AS 'icd4'
    ,COALESCE(icd5.CODE,'')                                      AS 'icd5'
    ,COALESCE(icd6.CODE,'')                                      AS 'icd6'
    ,COALESCE(cpt1.CPT_CODE,'')                                  AS 'cpt1'
    ,COALESCE(cpt2.CPT_CODE,'')                                  AS 'cpt2'
    ,COALESCE(cpt3.CPT_CODE,'')                                  AS 'cpt3'
    ,COALESCE(cpt4.CPT_CODE,'')                                  AS 'cpt4'
    ,COALESCE(cpt5.CPT_CODE,'')                                  AS 'cpt5'
    ,COALESCE(cpt6.CPT_CODE,'')                                  AS 'cpt6'
    ,CASE WHEN pt4.PAT_LIVING_STAT_C = '2'
            THEN 'Y'
            ELSE ''
     END                                                         AS 'deceased pat'
   ,''															  AS 'do not contact'
   ---Removed 07/07/2020 per press ganey spec update
 /*   ,CASE WHEN enc5.SURVEY_OPT_OUT_YN IS NULL   THEN 'N'
            WHEN typ.PATIENT_TYPE_C = '31014'   THEN 'N'
            WHEN hsp2.SURVEY_OPT_OUT_YN ='N'    THEN 'N'
            ELSE 'Y'
     END                                                         AS 'do not contact'
*/
    ,cvg.FIN_CLASS                                               AS 'fin class'
    --,COALESCE(CONVERT(VARCHAR(10),enc.DISCHARGE_DATE_DT,101),CONVERT(VARCHAR(10),orlg.SURGERY_DATE,101)) 'Discharge Dt'
    ,CONVERT(VARCHAR(10),orlg.SURGERY_DATE,101)                  AS 'Discharge Dt'
    ,COALESCE(hsp.DISCH_DISP_C,'')                               AS 'discharge_disposition'
    ,COALESCE(dischdep.DEPARTMENT_NAME,dep.DEPARTMENT_NAME,'')   AS 'discharge_unit'
    --,orlg.DISCHARGE_TO_C
    ,'1'     /*los.LENGTH_OF_STAY_DAYS*/                         AS 'los'
    ,'2'                                                         AS 'icu txf'
    --,acct.FINAL_DRG_ID'DRG'
    ,COALESCE(drg.MPI_ID,'')                                     AS 'Ms_DRG'
    ,CONVERT(VARCHAR(10),orlg.SURGERY_DATE,101)                  AS 'Appt_Date'
    ,CASE WHEN (typ.PATIENT_TYPE_C = '3' OR pt.EMPLOYER_ID = '1000')
            THEN 'U'
            ELSE ''
     END                                                         AS 'UVA_Employee'
    ,COALESCE(ser1.SPECIALTY_C,'')                               AS 'Specialty_C'
    ,COALESCE(pt.LANGUAGE_C,'')                                  AS 'Language'
    ,COALESCE(hsp.ADMIt_SOURCE_C,'')                             AS 'point of origin'
    ,ISNULL(CAST(hsp.disch_code_C AS VARCHAR(2)),'')             AS 'discharge code'
    ,'10'                                                        AS 'hsp.SERV_AREA_ID'
    --,hsp.ADT_SERV_AREA_ID
    ,COALESCE(CAST(REPLACE(pt.GUARDIAN_NAME,',','^')AS VARCHAR(200)) ,'')                 AS 'Guardian_Nm'  --CAST(REPLACE(pt.PAT_NAME,',','^') AS VARCHAR(200))
    ,CAST(REPLACE(CONCAT(emcnt.GUARDIAN_ADDR_LN_1,emcnt.GUARDIAN_ADDR_LN_2),',','^') AS VARCHAR(100)) AS 'GUAR_Address'
    ,COALESCE(CONVERT(VARCHAR(10),hsp.inp_adm_date,101),'')      AS 'First_IP_ADM'
    --,hsp.bed_id
    ,COALESCE(bd.Bed,'')                                         AS 'Bed'
    ,COALESCE(pt.EMAIL_ADDRESS,'')                               AS 'Email'
    ,''															 AS 'fill01'
    ,CONVERT(VARCHAR(5),CAST(hsp.HOSP_ADMSN_TIME AS TIME))       AS 'Admit_Time'
    ,CONVERT(VARCHAR(5),CAST(hsp.hosp_disch_time AS TIME))       AS 'Discharge_Time'
    ,COALESCE(ordep.RPT_GRP_SEVEN,'')                            AS 'HUB'
    ,CASE WHEN hsp.ed_episode_id IS NOT NULL
                THEN 'Y'
                ELSE 'N'
     END                                                         AS 'ED Patient'
    ,''                                                          AS 'ED event day of week admission'
    ,''                                                          AS 'ED Event hour of week admission'
    ,COALESCE(enc.PCP_PROV_ID,'')                                AS 'Primary_Care_Provider'
    ,COALESCE(orlg.PRIMARY_PHYS_ID,'')                           AS 'Prov_ID'
    ,COALESCE(anes.ANESTH_STAFF_ID,'')                           AS 'Anesth_ID'              -- enc.ORDERING_PROV_ID -- 'or log
    ,CASE WHEN prov.PROV_TYPE = 'Resident'
            THEN 'Y'
            ELSE ''
     END                                                         AS 'Is resident'
    ,mrst.ABBR                                                   AS 'MARITAL_STATUS'
    ,CAST(REPLACE(hspact.GUAR_ADDR_1,',','^') AS VARCHAR(120))   AS 'GUAR_Addr1'
    ,CAST(REPLACE(COALESCE(hspact.GUAR_ADDR_2,''),',','^') AS VARCHAR(120)) AS 'Guar_Addr_2'
    ,hspact.GUAR_CITY                                            AS 'Guar_City'
    --,acct.GUAR_STATE_C
    ,st.ABBR                                                     AS 'Guar_State'
    ,hspact.GUAR_ZIP                                             AS 'Guar_Zip'
  --  ,enc.HSP_ACCOUNT_ID                                          AS 'Account_ID'
  --  ,''                                                          AS 'fill01'
    ,CASE WHEN procCat.PROC_CAT_NAME = 'CV ELECTROPHYSIO ORDERABLES'
       THEN 'Heart and Vascular'                                 -- Electrophysiology
       ELSE ordep.RPT_GRP_THIRTY
     END                                                         AS 'Service_Line'
    ,CASE WHEN procCat.PROC_CAT_NAME = 'CV ELECTROPHYSIO ORDERABLES'
       THEN '10243013 - Electrophysiology'
       ELSE CONCAT(ordep.DEPARTMENT_ID,'-',ordep.DEPARTMENT_NAME)
     END                                                         AS 'DepID_DepName'
    ,ISNULL(LEFT(eplnk.NAME,4),'')								 AS 'ERAS'
    --,zcrc.NAME													 AS 'RACE'
    --,ethnc.NAME                                                  AS 'ETHNICITY'
    ,zcrc.NAME													 AS 'fill05'
    ,ethnc.NAME                                                  AS 'fill06'
    ,''                                                          AS 'fill07'
    ,''                                                          AS 'fill08'
    ,''                                                          AS 'fill09'
    ,''                                                          AS 'fill10'
    ,''                                                          AS 'fill11'
    ,''                                                          AS 'fill12'
    ,''                                                          AS 'fill13'
    ,''                                                          AS 'fill14'
    ,''                                                          AS 'fill15'
    ,''                                                          AS 'fill16'
    ,''                                                          AS 'fill17'
    ,''                                                          AS 'fill18'
    ,''                                                          AS 'fill19'
    ,''                                                          AS 'fill20'
	,''                                                          AS 'fill21'
    ,''                                                          AS 'fill22'
    ,'$'                                                         AS 'Dollar_sign'


  FROM CLARITY.dbo.OR_LOG                 AS orlg
   LEFT OUTER JOIN CLARITY.dbo.V_LOG_BASED lgb							ON lgb.LOG_ID=orlg.LOG_ID
  LEFT OUTER JOIN CLARITY.dbo.PAT_OR_ADM_LINK lnk						ON lnk.LOG_ID = lgb.LOG_ID
  LEFT OUTER JOIN  CLARITY.dbo.PAT_ENC AS enc							ON enc.PAT_ENC_CSN_ID=lnk.PAT_ENC_CSN_ID
  LEFT OUTER JOIN CLARITY.dbo.PAT_ENC_HSP AS hsp						ON hsp.PAT_ENC_CSN_ID   = enc.PAT_ENC_CSN_ID
  LEFT OUTER JOIN CLARITY.dbo.PAT_ENC_HSP_2    AS hsp2					ON hsp.PAT_ENC_CSN_ID   = hsp2.PAT_ENC_CSN_ID
  LEFT OUTER JOIN CLARITY.dbo.CLARITY_DEP AS dep						ON dep.DEPARTMENT_ID    = enc.DEPARTMENT_ID
  LEFT OUTER JOIN CLARITY.dbo.OR_LOC      AS LOC						ON orlg.LOC_ID   = LOC.LOC_ID
  LEFT OUTER JOIN CLARITY.dbo.CLARITY_DEP AS ordep						ON loc.OR_DEPARTMENT_ID = ordep.DEPARTMENT_ID
  LEFT OUTER JOIN CLARITY.dbo.PATIENT     AS pt							ON orlg.PAT_ID           = pt.PAT_ID
  LEFT OUTER JOIN (SELECT PAT_ID,ADDRESS
                   FROM CLARITY.dbo.PAT_ADDRESS
                   WHERE LINE = '1')      AS adrs                ON adrs.PAT_ID          = pt.PAT_ID
  LEFT OUTER JOIN CLARITY.dbo.ZC_STATE    AS ste                 ON ste.STATE_C          = pt.STATE_C
  LEFT OUTER JOIN (SELECT *
                   FROM CLARITY.dbo.IDENTITY_ID
                   WHERE IDENTITY_TYPE_ID = '14' ) AS idx        ON idx.PAT_ID           = orlg.PAT_ID
  LEFT OUTER JOIN CLARITY.dbo.CLARITY_SER_2        AS ser        ON ser.PROV_ID          = orlg.PRIMARY_PHYS_ID
  LEFT OUTER JOIN (SELECT *
                   FROM CLARITY.dbo.CLARITY_SER_SPEC
                   WHERE LINE = '1')       AS ser1               ON ser.PROV_ID          = ser1.PROV_ID
  LEFT OUTER JOIN CLARITY.dbo.CLARITY_SER  AS prov               ON ser.PROV_ID          = prov.PROV_ID
  LEFT OUTER JOIN CLARITY.dbo.ZC_SPECIALTY AS spcty              ON spcty.SPECIALTY_C    = ser1.SPECIALTY_C
  LEFT OUTER JOIN CLARITY.dbo.PATIENT_4    AS pt4                ON pt.PAT_ID            = pt4.PAT_ID
  LEFT OUTER JOIN CLARITY.dbo.ZC_SEX       AS sx                 ON sx.RCPT_MEM_SEX_C    = pt.SEX_C
  LEFT OUTER JOIN (SELECT *
                   FROM CLARITY.dbo.PAT_ENC_DX
                   WHERE PRIMARY_DX_YN = 'Y')               AS dx       ON dx.PAT_ENC_CSN_ID    = enc.PAT_ENC_CSN_ID
  LEFT OUTER JOIN CLARITY.dbo.CLARITY_EDG                   AS edg      ON dx.DX_ID             = edg.DX_ID
  LEFT OUTER JOIN (SELECT dx.*,icd10.CODE
                   FROM CLARITY.dbo.PAT_ENC_DX              AS dx
                   INNER JOIN CLARITY.dbo.EDG_CURRENT_ICD10 AS icd10    ON icd10.DX_ID           = dx.DX_ID
                   WHERE dx.LINE = '1' AND icd10.LINE = '1'
                   ) AS icd1                                            ON icd1.PAT_ENC_CSN_ID   = enc.PAT_ENC_CSN_ID
  LEFT OUTER JOIN (SELECT dx.*,icd10.CODE
                   FROM CLARITY.dbo.PAT_ENC_DX              AS dx
                   INNER JOIN CLARITY.dbo.EDG_CURRENT_ICD10 AS icd10    ON icd10.DX_ID = dx.DX_ID
                   WHERE dx.LINE = '2' AND icd10.LINE = '1'
                   ) AS icd2                                            ON icd2.PAT_ENC_CSN_ID   = enc.PAT_ENC_CSN_ID
  LEFT OUTER JOIN (SELECT dx.*,icd10.CODE
                   FROM CLARITY.dbo.PAT_ENC_DX              AS dx
                   INNER JOIN CLARITY.dbo.EDG_CURRENT_ICD10 AS icd10    ON icd10.DX_ID = dx.DX_ID
                   WHERE dx.LINE = '3' AND icd10.LINE = '1'
                   ) AS icd3                                            ON icd3.PAT_ENC_CSN_ID   = enc.PAT_ENC_CSN_ID
  LEFT OUTER JOIN (SELECT dx.DX_ID,icd10.CODE,dx.PAT_ENC_CSN_ID
                   FROM CLARITY.dbo.PAT_ENC_DX              AS dx
                   INNER JOIN CLARITY.dbo.EDG_CURRENT_ICD10 AS icd10    ON icd10.DX_ID = dx.DX_ID
                   WHERE dx.LINE = '4' AND icd10.LINE = '1'
                   ) AS icd4                                            ON icd4.PAT_ENC_CSN_ID   = enc.PAT_ENC_CSN_ID
  LEFT OUTER JOIN (SELECT dx.*,icd10.CODE
                   FROM CLARITY.dbo.PAT_ENC_DX              AS dx
                   INNER JOIN CLARITY.dbo.EDG_CURRENT_ICD10 AS icd10    ON icd10.DX_ID = dx.DX_ID
                   WHERE dx.LINE = '5' AND icd10.LINE = '1'
                   ) AS icd5                                            ON icd5.PAT_ENC_CSN_ID   = enc.PAT_ENC_CSN_ID
  LEFT OUTER JOIN (SELECT dx.*,icd10.CODE
                   FROM CLARITY.dbo.PAT_ENC_DX              AS dx
                   INNER JOIN CLARITY.dbo.EDG_CURRENT_ICD10 AS icd10    ON icd10.DX_ID = dx.DX_ID
                   WHERE dx.LINE = '6' AND icd10.LINE = '1'
                   ) AS icd6                                            ON icd6.PAT_ENC_CSN_ID   = enc.PAT_ENC_CSN_ID
  LEFT OUTER JOIN (SELECT *
                   FROM Clarity.dbo.HSP_ACCT_CPT_CODES
                   WHERE LINE = 1)               AS cpt1                ON cpt1.HSP_ACCOUNT_ID   = enc.HSP_ACCOUNT_ID
  LEFT OUTER JOIN (SELECT *
                   FROM Clarity.dbo.HSP_ACCT_CPT_CODES
                   WHERE LINE = 2)               AS cpt2                ON cpt2.HSP_ACCOUNT_ID   = enc.HSP_ACCOUNT_ID
  LEFT OUTER JOIN (SELECT *
                   FROM Clarity.dbo.HSP_ACCT_CPT_CODES
                   WHERE LINE = 3)               AS cpt3                ON cpt3.HSP_ACCOUNT_ID   = enc.HSP_ACCOUNT_ID
  LEFT OUTER JOIN (SELECT *
                   FROM Clarity.dbo.HSP_ACCT_CPT_CODES
                   WHERE LINE = 4)               AS cpt4                ON cpt4.HSP_ACCOUNT_ID   = enc.HSP_ACCOUNT_ID
  LEFT OUTER JOIN (SELECT *
                   FROM Clarity.dbo.HSP_ACCT_CPT_CODES
                   WHERE LINE = 5)               AS cpt5                ON cpt5.HSP_ACCOUNT_ID   = enc.HSP_ACCOUNT_ID
  LEFT OUTER JOIN (SELECT *
                   FROM Clarity.dbo.HSP_ACCT_CPT_CODES
                   WHERE LINE = 6)               AS cpt6                ON cpt6.HSP_ACCOUNT_ID   = enc.HSP_ACCOUNT_ID
  LEFT OUTER JOIN CLARITY.dbo.PAT_ENC_5          AS enc5                ON enc.PAT_ENC_CSN_ID    = enc5.PAT_ENC_CSN_ID
  LEFT OUTER JOIN CLARITY.dbo.LENGTH_OF_STAY     AS los                 ON los.PAT_ENC_CSN_ID    = enc.PAT_ENC_CSN_ID
  LEFT OUTER JOIN (SELECT *
                   FROM CLARITY.dbo.HSP_ACCOUNT AS hsp
                   WHERE hsp.BILL_DRG_IDTYPE_ID = '290') AS acct        ON acct.HSP_ACCOUNT_ID   = enc.HSP_ACCOUNT_ID --317:2018
  LEFT OUTER JOIN (SELECT *
                   FROM CLARITY.dbo.CLARITY_DRG_MPI_ID
                   WHERE MPI_ID_TYPE = '290')    AS drg                 ON drg.DRG_ID            = acct.FINAL_DRG_ID
  LEFT OUTER JOIN CLARITY.dbo.PATIENT_TYPE       AS typ                 ON pt.PAT_ID             = typ.PAT_ID
  LEFT OUTER JOIN CLARITY.dbo.EMERGENCY_CONTACTS AS emcnt               ON emcnt.PAT_ID          = pt.PAT_ID
  LEFT OUTER JOIN CLARITY.dbo.CLARITY_DEP        AS dischdep            ON acct.DISCH_DEPT_ID    = dischdep.DEPARTMENT_ID
  --LEFT OUTER JOIN CLARITY.dbo.CLARITY_DEP      AS orlocdep            ON loc.OR_DEPARTMENT_ID  = orlocdep.DEPARTMENT_ID
  --LEFT OUTER JOIN CLARITY.dbo.ZC_DEP_RPT_GRP_7 AS hub                 ON hub.RPT_GRP_SEVEN     = orlocdep.RPT_GRP_SEVEN
  LEFT OUTER JOIN CLARITY.dbo.ZC_MARITAL_STATUS  AS mrst                ON pt.MARITAL_STATUS_C   = mrst.MARITAL_STATUS_C
  LEFT OUTER JOIN CLARITY.dbo.ZC_DEP_RPT_GRP_20  AS dsgn                ON dsgn.RPT_GRP_TWENTY_C = ordep.RPT_GRP_TWENTY_C
  LEFT OUTER JOIN (SELECT*
                   FROM CLARITY.dbo.OR_CASE_ANES_STAF
                   WHERE ANESTH_ROLE_C = '10')   AS anes                ON orlg.CASE_ID            = anes.OR_CASE_ID
  LEFT OUTER JOIN CLARITY.dbo.CLARITY_SER        AS rom                 ON rom.PROV_ID             = orlg.ROOM_ID
  LEFT OUTER JOIN CLARITY.dbo.CLARITY_EAP        AS EAP                 ON lgb.PRIMARY_PROCEDURE_ID = eap.REL_PREF_CARD_ID
  LEFT JOIN CLARITY.dbo.ZC_DFLT_ORDER_TYPE       AS OrdType             ON EAP.DFLT_ORDER_TYPE_C   = OrdType.DFLT_ORDER_TYPE_C
  LEFT JOIN CLARITY.dbo.EDP_PROC_CAT_INFO        AS ProcCat             ON proccat.PROC_CAT_ID     = EAP.PROC_CAT_ID
  LEFT OUTER JOIN CLARITY.dbo.PAT_ACCT_CVG       AS cvg                 ON cvg.ACCOUNT_ID          = enc.ACCOUNT_ID
  --LEFT OUTER JOIN CLARITY.dbo.F_LOG_BASED lb ON orlg.LOG_ID = LB.LOG_ID
  LEFT OUTER JOIN (SELECT bed.BED_ID
                   ,MAX(bed.BED_LABEL)           AS 'Bed'
                   ,MAX(bed.BED_CONT_DATE_REAL)  AS 'last_update'
                   FROM CLARITY.dbo.CLARITY_BED  AS bed
                   GROUP BY bed.BED_ID)          AS bd                  ON hsp.bed_id              = bd.BED_ID
  LEFT OUTER JOIN CLARITY.dbo.HSP_ACCOUNT        AS hspact              ON hspact.HSP_ACCOUNT_ID   = enc.HSP_ACCOUNT_ID
  LEFT OUTER JOIN CLARITY.dbo.ZC_STATE           AS st                  ON hspact.GUAR_STATE_C     = st.STATE_C
  LEFT OUTER JOIN CLARITY.dbo.IDENTITY_SER_ID	 AS sms					ON orlg.PRIMARY_PHYS_ID		=sms.PROV_ID AND sms.IDENTITY_TYPE_ID='6'
  LEFT OUTER JOIN CLARITY.dbo.PAT_SURG_DATA ptsrg						ON ptsrg.PAT_ENC_CSN_ID=enc.PAT_ENC_CSN_ID
  LEFT OUTER JOIN CLARITY.dbo.ZC_CS_SURG_CASE_CLASS zcsrgclass			ON zcsrgclass.CS_SURG_CASE_CLASS_C = ptsrg.CS_SURG_CASE_CLASS_C

 LEFT OUTER JOIN  (SELECT ep1.PAT_ENC_CSN_ID
						--,ep2.PAT_LINK_ID
						,ep2.*
					FROM CLARITY.dbo.EPISODE_LINK ep1
					INNER JOIN 	CLARITY.dbo.EPISODE ep2	 			ON ep1.EPISODE_ID=ep2.EPISODE_ID
					WHERE ep2.STATUS_C='1'--active
					AND ep2.NAME LIKE 'ERAS%') AS eplnk				ON eplnk.PAT_LINK_ID=enc.PAT_ID


--Add Prefered Name if available 07-09-2019 --Mali A.
	LEFT OUTER JOIN CLARITY.dbo.PATIENT_3 pt3						ON pt.PAT_ID=pt3.PAT_ID

--Add Cancelled procedure filter 02/18/2021 Mali A. 
	LEFT OUTER JOIN CLARITY.dbo.OR_LOG_ALL_PROC allprc				ON allprc.LOG_ID = orlg.LOG_ID

--Add Race 05/05/2021 Tom B
LEFT OUTER JOIN CLARITY.dbo.PATIENT_RACE rc							ON pt.PAT_ID = rc.PAT_ID
LEFT OUTER JOIN CLARITY.dbo.ZC_PATIENT_RACE zcrc					ON rc.PATIENT_RACE_C = zcrc.PATIENT_RACE_C

--Add Ethnicity 05/05/2021 Tom B
LEFT OUTER JOIN CLARITY.dbo.ZC_ETHNIC_GROUP ethnc					ON pt.ETHNIC_GROUP_C = ethnc.ETHNIC_GROUP_C


  WHERE 1=1
    AND orlg.SURGERY_DATE >= @Start_Date AND orlg.SURGERY_DATE < @End_Date
                  AND orlg.LOG_TYPE_C = '0'  /*ONLY SURGERY LOGS - NOT PROCEDURE LOGS */
      /**********************/
    AND COALESCE(hsp.ADT_PAT_CLASS_C,  zcsrgclass.ABBR) NOT IN ('101','111','124','126','107','108','109','103','112','125','IP') --Not Inpatient,Organ donar (UNOS), TCH Inpatient, Inpatient Psychiatry, NewBorn, Surgery Admit-IP, Specimen, HomeHealth, Psychiatric Therapeis
    AND COALESCE(hsp.DISCH_DISP_C,'') NOT IN ('2','9','66','21','5','70','61')        --Short Term Hospital,Admitted as an Inpatient,Critical Access Hospital,Discharge or Transfer to Court/Law Enforcement, Discharged to Other Facility, Discharged to Another Type of Institution,Swing Bed
                                                                           --Expired, Expired at Home, Expired in Medical Facility, Expired - Place Unknown (,'20','40','41','42') --removed 12/29/2017
    AND DATEDIFF(YEAR,pt.BIRTH_DATE,orlg.SURGERY_DATE) > 17
    AND (pt.COUNTRY_C IS NULL OR pt.COUNTRY_C = '1')
      AND (typ.PATIENT_TYPE_C NOT IN ('6','31014') OR typ.PATIENT_TYPE_C IS NULL)     --Prisnor, VIP --removed 12/29/2017, Added Back 07/07/2020
      AND ordep.DEPARTMENT_ID NOT IN ('10210017','10240002','10354027','10217007','10244026','10228010','10246006','10229001','10206001','10239010','10242045','10243037')
      AND COALESCE(hsp2.SURVEY_OPT_OUT_YN,'N') = 'N'


--Add Cancelled procedure filter 02/18/2021 Mali A.
	AND allprc.OR_PROC_ID <> '1071007588' --Cancelled Procedure


  ORDER BY enc.PAT_ENC_CSN_ID
GO
