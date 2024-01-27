USE DS_HSDW_Prod

--DECLARE @ClinicalArea TABLE (
--	[sk_Ref_Clinical_Area_Map] [int] NOT NULL)

--INSERT INTO @ClinicalArea
--(
--    sk_Ref_Clinical_Area_Map
--)
--SELECT Param AS sk_Ref_Clinical_Area_Map FROM ETL.fn_ParmParse(@in_skrefclinicalareamap, ',')

SELECT DISTINCT
 org.organization_id
,org.organization_name
,org.service_id
,org.[service_name]
,org.clinical_area_id
,org.clinical_area_name
,mdm.EPIC_DEPARTMENT_ID
,mdm.EPIC_DEPT_NAME
,mdm.EPIC_EXT_NAME
,grouper.ambulatory_flag
,grouper.childrens_flag
,grouper.childrens_ambulatory_name
,grouper.mc_ambulatory_name
,grouper.ambulatory_operation_name
,grouper.childrens_name
,grouper.serviceline_division_name
,grouper.mc_operation_name
,grouper.inpatient_adult_name
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
,grouper.UPG_PRACTICE_FLAG
,grouper.UPG_PRACTICE_REGION_NAME
,grouper.UPG_PRACTICE_ID
,grouper.UPG_PRACTICE_NAME
,mdm.[HOSPITAL_CODE]
,mdm.[LOC_RPT_GRP_NINE_NAME]
,grouper.community_health_flag

FROM
(
SELECT DISTINCT ids.EPIC_DEPARTMENT_ID, ids.sk_Ref_Clinical_Area_Map, ids.clinical_area_id, ids.clinical_area_name, ids.sk_Ref_Service_Map, ids.service_id, ids.[service_name], ids.organization_id, organization.organization_name
FROM
(
SELECT DISTINCT ca.EPIC_DEPARTMENT_ID, ca.sk_Ref_Clinical_Area_Map, ca.clinical_area_id, ca.clinical_area_name, ca.sk_Ref_Service_Map, [service].service_id, [service].[service_name], COALESCE([service].organization_id,999) AS organization_id
FROM
(
SELECT DISTINCT mapping.EPIC_DEPARTMENT_ID, mapping.sk_Ref_Clinical_Area_Map, clinical_area.clinical_area_id, clinical_area.clinical_area_name, COALESCE(clinical_area.sk_Ref_Service_Map, 43) AS sk_Ref_Service_Map
FROM
(
SELECT DISTINCT mdm.EPIC_DEPARTMENT_ID, COALESCE(grouper.sk_Ref_Clinical_Area_Map,165) AS sk_Ref_Clinical_Area_Map
FROM DS_HSDW_Prod.dbo.Ref_MDM_Location_Master mdm
LEFT JOIN DS_HSDM_App.Mapping.Epic_Dept_Groupers grouper
ON grouper.EPIC_DEPARTMENT_ID = mdm.EPIC_DEPARTMENT_ID
--INNER JOIN @ClinicalArea clinicalarea
--ON grouper.sk_Ref_Clinical_Area_Map = clinicalarea.sk_Ref_Clinical_Area_Map
) mapping
INNER JOIN DS_HSDM_App.Mapping.Ref_Clinical_Area_Map clinical_area
ON mapping.sk_Ref_Clinical_Area_Map = clinical_area.sk_Ref_Clinical_Area_Map
) ca
INNER JOIN DS_HSDM_App.Mapping.Ref_Service_Map [service]
ON ca.sk_Ref_Service_Map = [service].sk_Ref_Service_Map
) ids
LEFT JOIN DS_HSDM_App.Mapping.Ref_Organization_Map organization
ON organization.organization_id = ids.organization_id
) org
LEFT OUTER JOIN DS_HSDW_Prod.dbo.Ref_MDM_Location_Master mdm
ON mdm.EPIC_DEPARTMENT_ID = org.EPIC_DEPARTMENT_ID
LEFT JOIN DS_HSDM_App.Mapping.Epic_Dept_Groupers grouper
ON grouper.epic_department_id = org.EPIC_DEPARTMENT_ID
--ORDER BY org.organization_id
--                  , org.service_id
--				  , org.clinical_area_id
--				  , mdm.EPIC_DEPARTMENT_ID;
--ORDER BY mdm.EPIC_DEPARTMENT_ID
--                  , org.organization_id
--                  , org.service_id
--				  , org.clinical_area_id;
ORDER BY mdm.EPIC_DEPT_NAME
                  , org.organization_id
                  , org.service_id
				  , org.clinical_area_id;