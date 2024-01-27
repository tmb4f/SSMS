USE DS_HSDM_App_Dev

DECLARE @in_organizationid VARCHAR(MAX)

DECLARE @Organization TABLE (OrganizationId INTEGER)

INSERT INTO @Organization
(
    OrganizationId
)
VALUES
(1), -- Inpatient Adult
(2), -- Emergency Services
(3), -- Children's Hospital
(4), -- Medical Center Ambulatory
(5), -- Medical Center OPERATIONS
(6), -- Service Lines
(7), -- UPG
(8), -- Other Ambulatory Services
(999)--, -- No Organization Assigned
--(4)--, -- Medical Center Ambulatory
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

SELECT DISTINCT ids.sk_Ref_Service_Map, [service].[service_name]
FROM
(
	SELECT DISTINCT [organization].organization_id, COALESCE([service].sk_Ref_Service_Map, 43) AS sk_Ref_Service_Map
	FROM DS_HSDM_App_Dev.Mapping.Ref_Service_Map [service]
	INNER JOIN @OrganizationNew organization
	ON [service].organization_id = organization.organization_id
) ids
LEFT OUTER JOIN DS_HSDM_App_Dev.Mapping.Ref_Service_Map [service]
ON [service].sk_Ref_Service_Map = ids.sk_Ref_Service_Map
ORDER BY 1,2;