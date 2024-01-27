 USE DS_HSDM_App_Dev

--SELECT mdm.EPIC_DEPARTMENT_ID, mdm.EPIC_DEPT_NAME, mapping.sk_Ref_Clinical_Area_Map, clinical_area.clinical_area_id, clinical_area.clinical_area_name, clinical_area.sk_Ref_Service_Map, [service].service_id, [service].[service_name], [service].organization_id
--SELECT DISTINCT [service].organization_id,
--[service].service_id,
--clinical_area.sk_Ref_Service_Map,
--'(' + CAST(clinical_area.sk_Ref_Service_Map AS VARCHAR(3)) + '), -- Service (' + CAST([service].[service_id] AS VARCHAR(3)) + ') - ' + [service].[service_name] + ', Organization (' + CAST([service].organization_id AS VARCHAR(3)) + ') - ' + organization.organization_name AS string
SELECT DISTINCT [service].organization_id,
[service].service_id,
clinical_area.sk_Ref_Clinical_Area_Map,
'(' + CAST(clinical_area.sk_Ref_Clinical_Area_Map AS VARCHAR(3)) + '), -- Clinical Area (' + CAST(clinical_area.clinical_area_id AS VARCHAR(3)) + ') - ' + clinical_area.clinical_area_name + ', Service (' + CAST([service].[service_id] AS VARCHAR(3)) + ') - ' + [service].[service_name] + ', Organization (' + CAST([service].organization_id AS VARCHAR(3)) + ') - ' + organization.organization_name AS string
FROM DS_HSDW_Prod.dbo.Ref_MDM_Location_Master mdm
LEFT JOIN Mapping.Epic_Dept_Groupers mapping
ON mapping.EPIC_DEPARTMENT_ID = mdm.EPIC_DEPARTMENT_ID
INNER JOIN Mapping.Ref_Clinical_Area_Map clinical_area
ON mapping.sk_Ref_Clinical_Area_Map = clinical_area.sk_Ref_Clinical_Area_Map
INNER JOIN Mapping.Ref_Service_Map [service]
ON clinical_area.sk_Ref_Service_Map = [service].sk_Ref_Service_Map
INNER JOIN Mapping.Ref_Organization_Map organization
ON [service].organization_id = organization.organization_id
--ORDER BY mdm.EPIC_DEPARTMENT_ID
--ORDER BY organization.organization_id
--ORDER BY [service].organization_id, [service].service_id, clinical_area.sk_Ref_Service_Map
ORDER BY [service].organization_id, [service].service_id, clinical_area.sk_Ref_Clinical_Area_Map