USE DS_HSDW_Prod

DECLARE @in_organizationid VARCHAR(MAX)

DECLARE @Organization TABLE (OrganizationId INTEGER)

INSERT INTO @Organization
(
    OrganizationId
)
VALUES
--(1), -- Inpatient Adult
--(2), -- Emergency Services
--(3), -- Children's Hospital
--(4), -- Medical Center Ambulatory
--(5), -- Medical Center OPERATIONS
--(6), -- Service Lines
--(7), -- UPG
--(8), -- Other Ambulatory Services
--(999)--, -- No Organization Assigned
(4)--, -- Medical Center Ambulatory
;

SELECT @in_organizationid = COALESCE(@in_organizationid+',' ,'') + CAST(OrganizationId AS VARCHAR(MAX))
FROM @Organization

SELECT @in_organizationid

--DELETE FROM @Organization

DECLARE @OrganizationNew TABLE (
	[organization_id] [int] NOT NULL)

INSERT INTO @OrganizationNew
(
    organization_id
)
SELECT Param AS organization_id FROM ETL.fn_ParmParse(@in_organizationid, ',')

--SELECT DISTINCT id.organization_id, id.service_id, id.service_name
--FROM
--(
--SELECT DISTINCT organization.organization_id, organization.service_name
--FROM
--(
--	SELECT DISTINCT COALESCE(mapping.organization_id, 999) AS organization_id, COALESCE(mapping.service_name, 'No Service Assigned') AS service_name
--	FROM DS_HSDM_App.Mapping.Epic_Dept_Groupers mapping
--	INNER JOIN @OrganizationNew organization
--	ON mapping.organization_id = organization.organization_id
--) organization
--) name
--LEFT OUTER JOIN DS_HSDM_App.Mapping.Ref_Service_Map id
--ON name.organization_id = id.organization_id
--AND id.service_name = name.service_name
--ORDER BY 1,2

SELECT DISTINCT ids.sk_Ref_Service_Map, [service].[service_name]
FROM
(
	SELECT DISTINCT [organization].organization_id, COALESCE([service].sk_Ref_Service_Map, 43) AS sk_Ref_Service_Map
	FROM DS_HSDM_App.Mapping.Ref_Service_Map [service]
	INNER JOIN @OrganizationNew organization
	ON [service].organization_id = organization.organization_id
) ids
LEFT OUTER JOIN DS_HSDM_App.Mapping.Ref_Service_Map [service]
ON [service].sk_Ref_Service_Map = ids.sk_Ref_Service_Map
ORDER BY 1,2;
