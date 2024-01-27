USE DS_HSDM_App_Dev

DECLARE @in_organizationid VARCHAR(MAX),
                  @in_skrefservicemap VARCHAR(MAX)

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

DECLARE @Service TABLE (sk_Ref_Service_Map INTEGER)

INSERT INTO @Service
(
    sk_Ref_Service_Map
)
VALUES
--(2), -- Service (1) - Behavioral Health, Organization (1) - Inpatient Adult
--(3), -- Service (2) - Cardiovascular, Organization (1) - Inpatient Adult
--(4), -- Service (5) - Medicine, Organization (1) - Inpatient Adult
--(5), -- Service (6) - Neuroscience, Organization (1) - Inpatient Adult
--(6), -- Service (7) - Oncology, Organization (1) - Inpatient Adult
--(7), -- Service (8) - Orthopedics, Organization (1) - Inpatient Adult
--(8), -- Service (9) - Respiratory Therapy, Organization (1) - Inpatient Adult
--(9), -- Service (10) - Surgical Services, Organization (1) - Inpatient Adult
--(10), -- Service (11) - Transplant, Organization (1) - Inpatient Adult
--(11), -- Service (12) - Womens, Organization (1) - Inpatient Adult
--(12), -- Service (4) - Emergency Services, Organization (2) - Emergency Services
--(16), -- Service (1) - General Pediatrics, Organization (3) - Children's Hospital
--(13), -- Service (2) - NICU, Organization (3) - Children's Hospital
--(17), -- Service (3) - Pediatric Specialties, Organization (3) - Children's Hospital
--(15), -- Service (4) - Pediatric Acute Care, Organization (3) - Children's Hospital
--(14), -- Service (6) - PICU, Organization (3) - Children's Hospital
--(18), -- Service (1) - Dialysis, Organization (4) - Medical Center Ambulatory
--(19), -- Service (2) - Medical Subspecialties, Organization (4) - Medical Center Ambulatory
--(20), -- Service (3) - Primary Care, Organization (4) - Medical Center Ambulatory
--(21), -- Service (4) - Sleep Center, Organization (4) - Medical Center Ambulatory
--(22), -- Service (5) - Surgical Specialties A, Organization (4) - Medical Center Ambulatory
--(23), -- Service (6) - Surgical Specialties B, Organization (4) - Medical Center Ambulatory
--(44), -- Service (7) - Spine Program, Organization (4) - Medical Center Ambulatory
--(24), -- Service (1) - Continuum Home Health, Organization (5) - Medical Center Operations
--(25), -- Service (3) - Labs, Organization (5) - Medical Center Operations
--(26), -- Service (4) - Perioperative Services, Organization (5) - Medical Center Operations
--(27), -- Service (5) - Pharmacy, Organization (5) - Medical Center Operations
--(28), -- Service (6) - Radiology, Organization (5) - Medical Center Operations
--(29), -- Service (7) - TCH, Organization (5) - Medical Center Operations
--(30), -- Service (8) - Therapies, Organization (5) - Medical Center Operations
--(31), -- Service (9) - Imaging, Organization (5) - Medical Center Operations
--(32), -- Service (1) - Oncology, Organization (6) - Service Lines
--(33), -- Service (2) - Transplant, Organization (6) - Service Lines
--(34), -- Service (3) - Neurosciences, Organization (6) - Service Lines
--(35), -- Service (4) - Heart & Vascular, Organization (6) - Service Lines
--(36), -- Service (2) - UPG-Community Division, Organization (7) - UPG
--(37), -- Service (4) - UPG-CPG Specialty Culpeper, Organization (7) - UPG
--(38), -- Service (5) - UPG-CPG Specialty, Organization (7) - UPG
--(39), -- Service (6) - UPG-RPC North, Organization (7) - UPG
--(40), -- Service (7) - UPG-RPC South, Organization (7) - UPG
--(41), -- Service (2) - Northridge Community Medicine, Organization (8) - Other Ambulatory Services
--(42), -- Service (4) - Digestive Health, Organization (8) - Other Ambulatory Services
--(45), -- Service (6) - Culpeper Heart & Vascular, Organization (8) - Other Ambulatory Services
--(46), -- Service (8) - Pantops Otolaryngology, Organization (8) - Other Ambulatory Services
--(43)--, -- Service (999) - No Service Assigned, Organization (999) - No Organization Assigned
(18), -- Service (1) - Dialysis, Organization (4) - Medical Center Ambulatory
(19), -- Service (2) - Medical Subspecialties, Organization (4) - Medical Center Ambulatory
(20), -- Service (3) - Primary Care, Organization (4) - Medical Center Ambulatory
(21), -- Service (4) - Sleep Center, Organization (4) - Medical Center Ambulatory
(22), -- Service (5) - Surgical Specialties A, Organization (4) - Medical Center Ambulatory
(23), -- Service (6) - Surgical Specialties B, Organization (4) - Medical Center Ambulatory
(44)--, -- Service (7) - Spine Program, Organization (4) - Medical Center Ambulatory
;

SELECT @in_skrefservicemap = COALESCE(@in_skrefservicemap+',' ,'') + CAST(sk_Ref_Service_Map AS VARCHAR(MAX))
FROM @Service

SELECT @in_skrefservicemap

--DELETE FROM @Organization

DECLARE @OrganizationNew TABLE (
	[organization_id] [int] NOT NULL)

INSERT INTO @OrganizationNew
(
    organization_id
)
SELECT Param AS organization_id FROM ETL.fn_ParmParse(@in_organizationid, ',')

DECLARE @ServiceNew TABLE (
	[sk_Ref_Service_Map] INTEGER NOT NULL)

INSERT INTO @ServiceNew
(
    [sk_Ref_Service_Map]
)
SELECT Param AS [sk_Ref_Service_Map] FROM ETL.fn_ParmParse(@in_skrefservicemap, ',')

SELECT DISTINCT ids.sk_Ref_Clinical_Area_Map, clinical_area.clinical_area_name
FROM
(
	SELECT DISTINCT [service].sk_Ref_Service_Map, COALESCE(clinical_area.sk_Ref_Clinical_Area_Map,165) AS sk_Ref_Clinical_Area_Map
	FROM DS_HSDM_App_Dev.Mapping.Ref_Clinical_Area_Map clinical_area
	INNER JOIN @ServiceNew [service]
	ON clinical_area.sk_Ref_Service_Map = [service].sk_Ref_Service_Map
) ids
INNER JOIN DS_HSDM_App_Dev.Mapping.Ref_Clinical_Area_Map clinical_area
ON ids.sk_Ref_Clinical_Area_Map = clinical_area.sk_Ref_Clinical_Area_Map
ORDER BY 1;