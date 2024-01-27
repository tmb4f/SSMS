USE DS_HSDW_Prod

SELECT ids.organization_id,
       orgmap.organization_name,
       ids.service_id,
       svcmap.service_name,
       ids.clinical_area_id,
       camap.clinical_area_name,
       ids.EPIC_DEPARTMENT_ID,
       ids.EPIC_DEPT_NAME,
       ids.EPIC_EXT_NAME,
	   ids.ambulatory_flag,
       ids.EPIC_DEPT_TYPE,
       ids.EPIC_SPCLTY,
       ids.FINANCE_COST_CODE,
       ids.PEOPLESOFT_NAME,
       ids.SERVICE_LINE,
       ids.SUB_SERVICE_LINE,
       ids.OPNL_SERVICE_NAME,
       ids.CORP_SERVICE_LINE,
       ids.RL_LOCATION_BESAFE,
       ids.LOC_ID,
       ids.REV_LOC_NAME,
       ids.A2K3_NAME,
       ids.A2K3_CLINIC_CARE_AREA_DESCRIPTION,
       ids.AMB_PRACTICE_GROUP,
       ids.HS_AREA_ID,
       ids.HS_AREA_NAME,
       ids.TJC_FLAG,
       ids.NDNQI_NAME,
       ids.NHSN_NAME,
       ids.PRACTICE_GROUP_NAME,
       ids.PRESSGANEY_NAME,
       ids.DIVISION_DESC,
       ids.ADMIN_DESC,
       ids.BUSINESS_UNIT,
       ids.RPT_RUN_DT,
       ids.PFA_POD,
       ids.HUB,
       ids.PBB_POD,
       ids.PG_SURVEY_DESIGNATOR,
       ids.UPG_PRACTICE_FLAG,
       ids.UPG_PRACTICE_REGION_NAME,
       ids.UPG_PRACTICE_ID,
       ids.UPG_PRACTICE_NAME
FROM
(
SELECT COALESCE(mapping.organization_id,999) AS organization_id
,COALESCE(mapping.service_id,999) AS service_id
,COALESCE(mapping.clinical_area_id,999) AS clinical_area_id
 ,mdm.EPIC_DEPARTMENT_ID
 ,mdm.EPIC_DEPT_NAME
,mdm.EPIC_EXT_NAME
,mapping.ambulatory_flag
,mapping.childrens_ambulatory_name
,mapping.mc_ambulatory_name
,mapping.ambulatory_operation_name
,mapping.childrens_name
,mapping.serviceline_division_name
,mapping.mc_operation_name
,mapping.inpatient_adult_name
,mdm.EPIC_DEPT_TYPE
,mdm.EPIC_SPCLTY
,mdm.FINANCE_COST_CODE
,mdm.PEOPLESOFT_NAME
,mdm.SERVICE_LINE
,mdm.SUB_SERVICE_LINE
,mdm.OPNL_SERVICE_NAME
,mdm.CORP_SERVICE_LINE
,mdm.RL_LOCATION [RL_LOCATION_BESAFE]
,COALESCE(mdm.LOC_ID,'0')  LOC_ID 
,COALESCE(mdm.REV_LOC_NAME,'Null') REV_LOC_NAME
,mdm.A2K3_NAME
,mdm.A2K3_CLINIC_CARE_AREA_DESCRIPTION
,mdm.AMB_PRACTICE_GROUP
,mdm.HS_AREA_ID
,COALESCE(REPLACE(mdm.HS_AREA_NAME,'upg','Null'),'Null') HS_AREA_NAME  --- some have null string
,mdm.TJC_FLAG
,mdm.NDNQI_NAME
,mdm.NHSN_NAME
,mdm.PRACTICE_GROUP_NAME
,mdm.PRESSGANEY_NAME
,mdm.DIVISION_DESC
,mdm.ADMIN_DESC
,mdm.BUSINESS_UNIT
,mdm.RPT_RUN_DT
,mdm.PFA_POD
,mdm.HUB
,mdm.PBB_POD
,mdm.PG_SURVEY_DESIGNATOR
,mapping.UPG_PRACTICE_FLAG
,mapping.UPG_PRACTICE_REGION_NAME
,mapping.UPG_PRACTICE_ID
,mapping.UPG_PRACTICE_NAME

FROM dbo.Ref_MDM_Location_Master mdm
LEFT JOIN DS_HSDM_App.Mapping.Epic_Dept_Groupers mapping
ON mapping.EPIC_DEPARTMENT_ID = mdm.EPIC_DEPARTMENT_ID
) ids
LEFT JOIN DS_HSDM_App.Mapping.Ref_Organization_Map orgmap
ON orgmap.organization_id = ids.organization_id
LEFT JOIN DS_HSDM_App.Mapping.Ref_Service_Map svcmap
ON svcmap.organization_id = ids.organization_id
AND svcmap.service_id = ids.service_id
LEFT JOIN DS_HSDM_App.Mapping.Ref_Clinical_Area_Map camap
ON camap.clinical_area_id = ids.clinical_area_id
WHERE 1=1
ORDER BY ids.organization_id
                  , ids.service_id
				  , ids.clinical_area_id
				  , ids.EPIC_DEPARTMENT_ID