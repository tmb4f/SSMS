USE DS_HSDW_Prod

--SELECT DISTINCT ids.organization_id,
--       orgmap.organization_name
--FROM
--(
--SELECT COALESCE(mapping.organization_id,999) AS organization_id
--FROM dbo.Ref_MDM_Location_Master mdm
--LEFT JOIN DS_HSDM_App.Mapping.Epic_Dept_Groupers mapping
--ON mapping.EPIC_DEPARTMENT_ID = mdm.EPIC_DEPARTMENT_ID
--) ids
--LEFT JOIN DS_HSDM_App.Mapping.Ref_Organization_Map orgmap
--ON orgmap.organization_id = ids.organization_id
--WHERE 1=1
--ORDER BY ids.organization_id

SELECT DISTINCT ids.organization_id, organization.organization_name
FROM
(
SELECT DISTINCT ca.sk_Ref_Service_Map, COALESCE([service].organization_id,999) AS organization_id
FROM
(
SELECT DISTINCT mapping.sk_Ref_Clinical_Area_Map, COALESCE(clinical_area.sk_Ref_Service_Map, 43) AS sk_Ref_Service_Map
FROM
(
SELECT DISTINCT mdm.EPIC_DEPARTMENT_ID, COALESCE(grouper.sk_Ref_Clinical_Area_Map,165) AS sk_Ref_Clinical_Area_Map
FROM DS_HSDW_Prod.dbo.Ref_MDM_Location_Master mdm
LEFT JOIN DS_HSDM_App.Mapping.Epic_Dept_Groupers grouper
ON grouper.EPIC_DEPARTMENT_ID = mdm.EPIC_DEPARTMENT_ID
) mapping
INNER JOIN DS_HSDM_App.Mapping.Ref_Clinical_Area_Map clinical_area
ON mapping.sk_Ref_Clinical_Area_Map = clinical_area.sk_Ref_Clinical_Area_Map
) ca
INNER JOIN DS_HSDM_App.Mapping.Ref_Service_Map [service]
ON ca.sk_Ref_Service_Map = [service].sk_Ref_Service_Map
) ids
LEFT JOIN DS_HSDM_App.Mapping.Ref_Organization_Map organization
ON organization.organization_id = ids.organization_id
WHERE 1=1
ORDER BY ids.organization_id;