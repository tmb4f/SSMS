USE DS_HSDM_App_Dev

DECLARE @in_skrefclinicalareamap VARCHAR(MAX)

DECLARE @ClinicalArea TABLE (sk_Ref_Clinical_Area_Map INTEGER)

INSERT INTO @ClinicalArea
(
    sk_Ref_Clinical_Area_Map
)
VALUES
(140), -- Clinical Area (147) - Behavioral Health, Service (1) - Behavioral Health, Organization (1) - Inpatient Adult
(141), -- Clinical Area (148) - Cardiovascular, Service (2) - Cardiovascular, Organization (1) - Inpatient Adult
(142), -- Clinical Area (149) - Medicine, Service (5) - Medicine, Organization (1) - Inpatient Adult
(143), -- Clinical Area (150) - Neuroscience, Service (6) - Neuroscience, Organization (1) - Inpatient Adult
(144), -- Clinical Area (151) - Oncology, Service (7) - Oncology, Organization (1) - Inpatient Adult
(145), -- Clinical Area (152) - Orthopedics, Service (8) - Orthopedics, Organization (1) - Inpatient Adult
(146), -- Clinical Area (153) - Respiratory Therapy, Service (9) - Respiratory Therapy, Organization (1) - Inpatient Adult
(147), -- Clinical Area (154) - Surgical Services, Service (10) - Surgical Services, Organization (1) - Inpatient Adult
(148), -- Clinical Area (155) - Transplant, Service (11) - Transplant, Organization (1) - Inpatient Adult
(149), -- Clinical Area (156) - Womens, Service (12) - Womens, Organization (1) - Inpatient Adult
(150), -- Clinical Area (157) - Emergency Services, Service (4) - Emergency Services, Organization (2) - Emergency Services
(25), -- Clinical Area (32) - Battle General Pediatrics, Service (1) - General Pediatrics, Organization (3) - Children's Hospital
(26), -- Clinical Area (33) - Northridge Pediatrics, Service (1) - General Pediatrics, Organization (3) - Children's Hospital
(27), -- Clinical Area (34) - Orange Pediatrics, Service (1) - General Pediatrics, Organization (3) - Children's Hospital
(151), -- Clinical Area (158) - NICU, Service (2) - NICU, Organization (3) - Children's Hospital
(28), -- Clinical Area (35) - Developmental Pediatrics, Service (3) - Pediatric Specialties, Organization (3) - Children's Hospital
(29), -- Clinical Area (36) - Pediatric Allergy , Service (3) - Pediatric Specialties, Organization (3) - Children's Hospital
(30), -- Clinical Area (37) - Pediatric Audiology, Service (3) - Pediatric Specialties, Organization (3) - Children's Hospital
(31), -- Clinical Area (38) - Pediatric Cardiac Surgery, Service (3) - Pediatric Specialties, Organization (3) - Children's Hospital
(32), -- Clinical Area (39) - Pediatric Cardiology, Service (3) - Pediatric Specialties, Organization (3) - Children's Hospital
(34), -- Clinical Area (41) - Pediatric Dentistry, Service (3) - Pediatric Specialties, Organization (3) - Children's Hospital
(35), -- Clinical Area (42) - Pediatric Endocrine & Diabetes, Service (3) - Pediatric Specialties, Organization (3) - Children's Hospital
(36), -- Clinical Area (43) - Pediatric General Surgery, Service (3) - Pediatric Specialties, Organization (3) - Children's Hospital
(37), -- Clinical Area (44) - Pediatric Genetics, Service (3) - Pediatric Specialties, Organization (3) - Children's Hospital
(38), -- Clinical Area (45) - Pediatric GI, Service (3) - Pediatric Specialties, Organization (3) - Children's Hospital
(39), -- Clinical Area (46) - Pediatric Hem Onc, Service (3) - Pediatric Specialties, Organization (3) - Children's Hospital
(40), -- Clinical Area (47) - Pediatric Infectious Disease, Service (3) - Pediatric Specialties, Organization (3) - Children's Hospital
(41), -- Clinical Area (48) - Pediatric Infusion, Service (3) - Pediatric Specialties, Organization (3) - Children's Hospital
(42), -- Clinical Area (49) - Pediatric Neurology - Battle Building, Service (3) - Pediatric Specialties, Organization (3) - Children's Hospital
(43), -- Clinical Area (50) - Pediatric Neurology - Primary Care Center, Service (3) - Pediatric Specialties, Organization (3) - Children's Hospital
(44), -- Clinical Area (51) - Pediatric Neurosurgery, Service (3) - Pediatric Specialties, Organization (3) - Children's Hospital
(45), -- Clinical Area (52) - Pediatric Nutrition, Service (3) - Pediatric Specialties, Organization (3) - Children's Hospital
(46), -- Clinical Area (53) - Pediatric Occupational Therapy, Service (3) - Pediatric Specialties, Organization (3) - Children's Hospital
(48), -- Clinical Area (55) - Pediatric Orthopaedics, Service (3) - Pediatric Specialties, Organization (3) - Children's Hospital
(49), -- Clinical Area (56) - Pediatric Otolaryngology, Service (3) - Pediatric Specialties, Organization (3) - Children's Hospital
(50), -- Clinical Area (57) - Pediatric Palliative Care, Service (3) - Pediatric Specialties, Organization (3) - Children's Hospital
(51), -- Clinical Area (58) - Pediatric Physical Therapy, Service (3) - Pediatric Specialties, Organization (3) - Children's Hospital
(53), -- Clinical Area (60) - Pediatric Plastic Surgery, Service (3) - Pediatric Specialties, Organization (3) - Children's Hospital
(54), -- Clinical Area (61) - Pediatric Psychiatry, Service (3) - Pediatric Specialties, Organization (3) - Children's Hospital
(55), -- Clinical Area (62) - Pediatric Pulmonology, Service (3) - Pediatric Specialties, Organization (3) - Children's Hospital
(56), -- Clinical Area (63) - Pediatric Renal , Service (3) - Pediatric Specialties, Organization (3) - Children's Hospital
(57), -- Clinical Area (64) - Pediatric Rheumatology, Service (3) - Pediatric Specialties, Organization (3) - Children's Hospital
(58), -- Clinical Area (65) - Pediatric Speech Pathology, Service (3) - Pediatric Specialties, Organization (3) - Children's Hospital
(59), -- Clinical Area (66) - Pediatric Transplant, Service (3) - Pediatric Specialties, Organization (3) - Children's Hospital
(60), -- Clinical Area (67) - Pediatric Urology, Service (3) - Pediatric Specialties, Organization (3) - Children's Hospital
(61), -- Clinical Area (68) - Teen Health, Service (3) - Pediatric Specialties, Organization (3) - Children's Hospital
(153), -- Clinical Area (160) - Pediatric Acute Care, Service (4) - Pediatric Acute Care, Organization (3) - Children's Hospital
(152), -- Clinical Area (159) - PICU, Service (6) - PICU, Organization (3) - Children's Hospital
(138), -- Clinical Area (145) - Dialysis, Service (1) - Dialysis, Organization (4) - Medical Center Ambulatory
(65), -- Clinical Area (72) - Allergy, Service (2) - Medical Subspecialties, Organization (4) - Medical Center Ambulatory
(66), -- Clinical Area (73) - COVID Clinics, Service (2) - Medical Subspecialties, Organization (4) - Medical Center Ambulatory
(67), -- Clinical Area (74) - Endocrinology, Service (2) - Medical Subspecialties, Organization (4) - Medical Center Ambulatory
(68), -- Clinical Area (75) - Infectious Disease, Service (2) - Medical Subspecialties, Organization (4) - Medical Center Ambulatory
(69), -- Clinical Area (76) - Nephrology, Service (2) - Medical Subspecialties, Organization (4) - Medical Center Ambulatory
(70), -- Clinical Area (77) - Pulmonary, Service (2) - Medical Subspecialties, Organization (4) - Medical Center Ambulatory
(71), -- Clinical Area (78) - Pulmonary Function Test, Service (2) - Medical Subspecialties, Organization (4) - Medical Center Ambulatory
(72), -- Clinical Area (79) - Rheumatology, Service (2) - Medical Subspecialties, Organization (4) - Medical Center Ambulatory
(73), -- Clinical Area (80) - Womens - Battle Building OB, Service (2) - Medical Subspecialties, Organization (4) - Medical Center Ambulatory
(74), -- Clinical Area (81) - Womens - Northridge Midlife , Service (2) - Medical Subspecialties, Organization (4) - Medical Center Ambulatory
(75), -- Clinical Area (82) - Womens - Northridge OB-GYN, Service (2) - Medical Subspecialties, Organization (4) - Medical Center Ambulatory
(76), -- Clinical Area (83) - Womens - PCC OB-GYN, Service (2) - Medical Subspecialties, Organization (4) - Medical Center Ambulatory
(77), -- Clinical Area (84) - Adult Psychiatry - Northridge, Service (3) - Primary Care, Organization (4) - Medical Center Ambulatory
(78), -- Clinical Area (85) - Behavioral Medicine - Collins Wing, Service (3) - Primary Care, Organization (4) - Medical Center Ambulatory
(79), -- Clinical Area (86) - Child & Family Psychiatric Medicine - Old Ivy Way, Service (3) - Primary Care, Organization (4) - Medical Center Ambulatory
(80), -- Clinical Area (87) - Neurocognitive Assessment Lab - Davis Wing, Service (3) - Primary Care, Organization (4) - Medical Center Ambulatory
(81), -- Clinical Area (88) - Primary and Specialty Care - Crozet, Service (3) - Primary Care, Organization (4) - Medical Center Ambulatory
(82), -- Clinical Area (89) - Primary and Specialty Care - Orange, Service (3) - Primary Care, Organization (4) - Medical Center Ambulatory
(83), -- Clinical Area (90) - Primary and Specialty Care - Pantops, Service (3) - Primary Care, Organization (4) - Medical Center Ambulatory
(84), -- Clinical Area (91) - Primary Care - Colonnades, Service (3) - Primary Care, Organization (4) - Medical Center Ambulatory
(85), -- Clinical Area (92) - Primary Care - Crossroads, Service (3) - Primary Care, Organization (4) - Medical Center Ambulatory
(86), -- Clinical Area (93) - Primary Care - JABA, Service (3) - Primary Care, Organization (4) - Medical Center Ambulatory
(87), -- Clinical Area (94) - Primary Care - Primary Care Center, Service (3) - Primary Care, Organization (4) - Medical Center Ambulatory
(88), -- Clinical Area (95) - Primary Care - Stoney Creek, Service (3) - Primary Care, Organization (4) - Medical Center Ambulatory
(89), -- Clinical Area (96) - Primary Care - UMA, Service (3) - Primary Care, Organization (4) - Medical Center Ambulatory
(90), -- Clinical Area (97) - Primary Care - UPC, Service (3) - Primary Care, Organization (4) - Medical Center Ambulatory
(91), -- Clinical Area (98) - Psychiatric Medicine - Multi-Story, Service (3) - Primary Care, Organization (4) - Medical Center Ambulatory
(92), -- Clinical Area (99) - Primary Care - The Haven, Service (3) - Primary Care, Organization (4) - Medical Center Ambulatory
(139), -- Clinical Area (146) - Sleep Center, Service (4) - Sleep Center, Organization (4) - Medical Center Ambulatory
(95), -- Clinical Area (102) - Hand Center, Service (5) - Surgical Specialties A, Organization (4) - Medical Center Ambulatory
(96), -- Clinical Area (103) - Orthopaedics, Service (5) - Surgical Specialties A, Organization (4) - Medical Center Ambulatory
(98), -- Clinical Area (105) - Pain Management, Service (5) - Surgical Specialties A, Organization (4) - Medical Center Ambulatory
(99), -- Clinical Area (106) - Pelvic Medicine, Service (5) - Surgical Specialties A, Organization (4) - Medical Center Ambulatory
(100), -- Clinical Area (107) - Physical Medicine & Rehabilitation, Service (5) - Surgical Specialties A, Organization (4) - Medical Center Ambulatory
(102), -- Clinical Area (109) - Sports Medicine, Service (5) - Surgical Specialties A, Organization (4) - Medical Center Ambulatory
(103), -- Clinical Area (110) - Urology, Service (5) - Surgical Specialties A, Organization (4) - Medical Center Ambulatory
(94), -- Clinical Area (101) - Audiology, Service (6) - Surgical Specialties B, Organization (4) - Medical Center Ambulatory
(97), -- Clinical Area (104) - Otolaryngology, Service (6) - Surgical Specialties B, Organization (4) - Medical Center Ambulatory
(104), -- Clinical Area (111) - Dentistry, Service (6) - Surgical Specialties B, Organization (4) - Medical Center Ambulatory
(105), -- Clinical Area (112) - Dermatology, Service (6) - Surgical Specialties B, Organization (4) - Medical Center Ambulatory
(106), -- Clinical Area (113) - General Surgery, Service (6) - Surgical Specialties B, Organization (4) - Medical Center Ambulatory
(107), -- Clinical Area (114) - Hyperbaric Medicine, Service (6) - Surgical Specialties B, Organization (4) - Medical Center Ambulatory
(108), -- Clinical Area (115) - Ophthalmology, Service (6) - Surgical Specialties B, Organization (4) - Medical Center Ambulatory
(109), -- Clinical Area (116) - Oral Surgery, Service (6) - Surgical Specialties B, Organization (4) - Medical Center Ambulatory
(110), -- Clinical Area (117) - Plastic Surgery, Service (6) - Surgical Specialties B, Organization (4) - Medical Center Ambulatory
(111), -- Clinical Area (118) - Zion Crossroads, Service (6) - Surgical Specialties B, Organization (4) - Medical Center Ambulatory
(136), -- Clinical Area (143) - Pantops Rheumatology, Service (6) - Surgical Specialties B, Organization (4) - Medical Center Ambulatory
(137), -- Clinical Area (144) - Augusta, Service (6) - Surgical Specialties B, Organization (4) - Medical Center Ambulatory
(101), -- Clinical Area (108) - Spine Program, Service (7) - Spine Program, Organization (4) - Medical Center Ambulatory
(154), -- Clinical Area (161) - Continuum Home Health, Service (1) - Continuum Home Health, Organization (5) - Medical Center Operations
(155), -- Clinical Area (162) - Labs, Service (3) - Labs, Organization (5) - Medical Center Operations
(156), -- Clinical Area (163) - Perioperative Services, Service (4) - Perioperative Services, Organization (5) - Medical Center Operations
(157), -- Clinical Area (164) - Pharmacy, Service (5) - Pharmacy, Organization (5) - Medical Center Operations
(158), -- Clinical Area (165) - Radiology, Service (6) - Radiology, Organization (5) - Medical Center Operations
(159), -- Clinical Area (166) - TCH, Service (7) - TCH, Organization (5) - Medical Center Operations
(160), -- Clinical Area (167) - Therapies, Service (8) - Therapies, Organization (5) - Medical Center Operations
(161), -- Clinical Area (168) - Imaging, Service (9) - Imaging, Organization (5) - Medical Center Operations
(112), -- Clinical Area (119) - Community Oncology - Augusta, Service (1) - Oncology, Organization (6) - Service Lines
(113), -- Clinical Area (120) - Community Oncology - Culpeper, Service (1) - Oncology, Organization (6) - Service Lines
(114), -- Clinical Area (121) - Community Oncology - Pantops, Service (1) - Oncology, Organization (6) - Service Lines
(115), -- Clinical Area (122) - Breast Care Center, Service (1) - Oncology, Organization (6) - Service Lines
(116), -- Clinical Area (123) - Moser Radiation Center, Service (1) - Oncology, Organization (6) - Service Lines
(117), -- Clinical Area (124) - Emily Couric Clinical Cancer Center, Service (1) - Oncology, Organization (6) - Service Lines
(162), -- Clinical Area (697) - No Clinical Area Assigned, Service (1) - Oncology, Organization (6) - Service Lines
(118), -- Clinical Area (125) - Alta Vista, Service (2) - Transplant, Organization (6) - Service Lines
(119), -- Clinical Area (126) - Virginia Hospital Center, Service (2) - Transplant, Organization (6) - Service Lines
(120), -- Clinical Area (127) - Haymarket, Service (2) - Transplant, Organization (6) - Service Lines
(121), -- Clinical Area (128) - Lynchburg, Service (2) - Transplant, Organization (6) - Service Lines
(122), -- Clinical Area (129) - Locust Grove, Service (2) - Transplant, Organization (6) - Service Lines
(123), -- Clinical Area (130) - Roanoke, Service (2) - Transplant, Organization (6) - Service Lines
(124), -- Clinical Area (131) - West Complex, Service (2) - Transplant, Organization (6) - Service Lines
(163), -- Clinical Area (698) - No Clinical Area Assigned, Service (2) - Transplant, Organization (6) - Service Lines
(125), -- Clinical Area (132) - Neurology - Primary Care Center, Service (3) - Neurosciences, Organization (6) - Service Lines
(126), -- Clinical Area (133) - Neurosurgery - West Complex, Service (3) - Neurosciences, Organization (6) - Service Lines
(127), -- Clinical Area (134) - Neurosurgery - Fontaine, Service (3) - Neurosciences, Organization (6) - Service Lines
(168), -- Clinical Area (171) - Neurology - Field Clinics, Service (3) - Neurosciences, Organization (6) - Service Lines
(169), -- Clinical Area (172) - Neurosurgery - Field Clinics, Service (3) - Neurosciences, Organization (6) - Service Lines
(128), -- Clinical Area (135) - Heart & Vascular - Vascular Lab, Service (4) - Heart & Vascular, Organization (6) - Service Lines
(129), -- Clinical Area (136) - Heart & Vascular Center - Stress, Service (4) - Heart & Vascular, Organization (6) - Service Lines
(130), -- Clinical Area (137) - Heart & Vascular Center - Device, Service (4) - Heart & Vascular, Organization (6) - Service Lines
(131), -- Clinical Area (138) - Heart & Vascular Center - Cardiology, Service (4) - Heart & Vascular, Organization (6) - Service Lines
(132), -- Clinical Area (139) - Heart & Vascular Center - ECG, Service (4) - Heart & Vascular, Organization (6) - Service Lines
(133), -- Clinical Area (140) - Heart & Vascular Center - Echo, Service (4) - Heart & Vascular, Organization (6) - Service Lines
(166), -- Clinical Area (169) - Heart & Vascular Center - Invasive Cardiology, Service (4) - Heart & Vascular, Organization (6) - Service Lines
(167), -- Clinical Area (170) - Heart & Vascular Center - CV Surgery, Service (4) - Heart & Vascular, Organization (6) - Service Lines
(1), -- Clinical Area (5) - Endocrinology Pantops, Service (2) - UPG-Community Division, Organization (7) - UPG
(2), -- Clinical Area (6) - Neurosurgery Haymarket, Service (2) - UPG-Community Division, Organization (7) - UPG
(3), -- Clinical Area (7) - Radiology Vein and Vascular Care Gainesville, Service (2) - UPG-Community Division, Organization (7) - UPG
(172), -- Clinical Area (32) - Pediatrics Fall Hill, Service (2) - UPG-Community Division, Organization (7) - UPG
(173), -- Clinical Area (33) - Lynchburg Dialysis and Nephrology, Service (2) - UPG-Community Division, Organization (7) - UPG
(4), -- Clinical Area (9) - Ob & Gyn, a Dept of UVA Culpeper MC, Service (4) - UPG-CPG Specialty Culpeper, Organization (7) - UPG
(5), -- Clinical Area (10) - Orthopedics, a Dept of UVA Culpeper MC, Service (4) - UPG-CPG Specialty Culpeper, Organization (7) - UPG
(6), -- Clinical Area (11) - Surgical Care, a Dept of UVA Culpeper MC, Service (4) - UPG-CPG Specialty Culpeper, Organization (7) - UPG
(7), -- Clinical Area (12) - Pediatric Cardiology Richmond, Service (5) - UPG-CPG Specialty, Organization (7) - UPG
(8), -- Clinical Area (13) - Pediatric Pulmonology Riverside, Service (5) - UPG-CPG Specialty, Organization (7) - UPG
(9), -- Clinical Area (14) - Pediatric Specialty Care Winchester, Service (5) - UPG-CPG Specialty, Organization (7) - UPG
(10), -- Clinical Area (15) - Physical and Occupational Therapy, Service (5) - UPG-CPG Specialty, Organization (7) - UPG
(23), -- Clinical Area (30) - Dermatology Waynesboro, Service (5) - UPG-CPG Specialty, Organization (7) - UPG
(11), -- Clinical Area (17) - Pediatrics Culpeper, Service (6) - UPG-RPC North, Organization (7) - UPG
(12), -- Clinical Area (18) - Primary Care Commonwealth Medical, Service (6) - UPG-RPC North, Organization (7) - UPG
(13), -- Clinical Area (19) - Primary Care Culpeper Family Practice, Service (6) - UPG-RPC North, Organization (7) - UPG
(14), -- Clinical Area (20) - Primary Care Family Care of Culpeper, Service (6) - UPG-RPC North, Organization (7) - UPG
(15), -- Clinical Area (21) - Primary Care Locust Grove, Service (6) - UPG-RPC North, Organization (7) - UPG
(16), -- Clinical Area (23) - Pediatrics Augusta, Service (7) - UPG-RPC South, Organization (7) - UPG
(17), -- Clinical Area (24) - Primary Care Lake Monticello, Service (7) - UPG-RPC South, Organization (7) - UPG
(18), -- Clinical Area (25) - Primary Care Louisa, Service (7) - UPG-RPC South, Organization (7) - UPG
(19), -- Clinical Area (26) - Primary Care Stuarts Draft, Service (7) - UPG-RPC South, Organization (7) - UPG
(20), -- Clinical Area (27) - Pediatrics Harrisonburg, Service (7) - UPG-RPC South, Organization (7) - UPG
(21), -- Clinical Area (28) - Primary Care Riverside, Service (7) - UPG-RPC South, Organization (7) - UPG
(22), -- Clinical Area (29) - Primary Care Waynesboro, Service (7) - UPG-RPC South, Organization (7) - UPG
(24), -- Clinical Area (31) - Pediatrics McGaheysville, Service (7) - UPG-RPC South, Organization (7) - UPG
(93), -- Clinical Area (100) - Northridge Community Medicine, Service (2) - Northridge Community Medicine, Organization (8) - Other Ambulatory Services
(62), -- Clinical Area (69) - Digestive Health - Monroe Lane, Service (4) - Digestive Health, Organization (8) - Other Ambulatory Services
(63), -- Clinical Area (70) - Digestive Health - Primary Care Center, Service (4) - Digestive Health, Organization (8) - Other Ambulatory Services
(64), -- Clinical Area (71) - Digestive Health - University Hospital, Service (4) - Digestive Health, Organization (8) - Other Ambulatory Services
(170), -- Clinical Area (173) - Culpeper Heart & Vascular, Service (6) - Culpeper Heart & Vascular, Organization (8) - Other Ambulatory Services
(171), -- Clinical Area (174) - Pantops Otolaryngology, Service (8) - Pantops Otolaryngology, Organization (8) - Other Ambulatory Services
(165)--, -- Clinical Area (999) - No Clinical Area Assigned, Service (999) - No Service Assigned, Organization (999) - No Organization Assigned
--(65), -- Clinical Area (72) - Allergy, Service (2) - Medical Subspecialties, Organization (4) - Medical Center Ambulatory
--(66), -- Clinical Area (73) - COVID Clinics, Service (2) - Medical Subspecialties, Organization (4) - Medical Center Ambulatory
--(67), -- Clinical Area (74) - Endocrinology, Service (2) - Medical Subspecialties, Organization (4) - Medical Center Ambulatory
--(68), -- Clinical Area (75) - Infectious Disease, Service (2) - Medical Subspecialties, Organization (4) - Medical Center Ambulatory
--(69), -- Clinical Area (76) - Nephrology, Service (2) - Medical Subspecialties, Organization (4) - Medical Center Ambulatory
--(70), -- Clinical Area (77) - Pulmonary, Service (2) - Medical Subspecialties, Organization (4) - Medical Center Ambulatory
--(71), -- Clinical Area (78) - Pulmonary Function Test, Service (2) - Medical Subspecialties, Organization (4) - Medical Center Ambulatory
--(72), -- Clinical Area (79) - Rheumatology, Service (2) - Medical Subspecialties, Organization (4) - Medical Center Ambulatory
--(73), -- Clinical Area (80) - Womens - Battle Building OB, Service (2) - Medical Subspecialties, Organization (4) - Medical Center Ambulatory
--(74), -- Clinical Area (81) - Womens - Northridge Midlife , Service (2) - Medical Subspecialties, Organization (4) - Medical Center Ambulatory
--(75), -- Clinical Area (82) - Womens - Northridge OB-GYN, Service (2) - Medical Subspecialties, Organization (4) - Medical Center Ambulatory
--(76)--, -- Clinical Area (83) - Womens - PCC OB-GYN, Service (2) - Medical Subspecialties, Organization (4) - Medical Center Ambulatory
;

SELECT @in_skrefclinicalareamap = COALESCE(@in_skrefclinicalareamap+',' ,'') + CAST(sk_Ref_Clinical_Area_Map AS VARCHAR(MAX))
FROM @ClinicalArea

SELECT @in_skrefclinicalareamap

DECLARE @ClinicalAreaNew TABLE (
	[sk_Ref_Clinical_Area_Map] [int] NOT NULL)

INSERT INTO @ClinicalAreaNew
(
    sk_Ref_Clinical_Area_Map
)
SELECT Param AS sk_Ref_Clinical_Area_Map FROM ETL.fn_ParmParse(@in_skrefclinicalareamap, ',')

SELECT * FROM @ClinicalAreaNew


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
LEFT JOIN Mapping.Epic_Dept_Groupers grouper
ON grouper.EPIC_DEPARTMENT_ID = mdm.EPIC_DEPARTMENT_ID
INNER JOIN @ClinicalAreaNew clinicalarea
ON grouper.sk_Ref_Clinical_Area_Map = clinicalarea.sk_Ref_Clinical_Area_Map
) mapping
INNER JOIN Mapping.Ref_Clinical_Area_Map clinical_area
ON mapping.sk_Ref_Clinical_Area_Map = clinical_area.sk_Ref_Clinical_Area_Map
) ca
INNER JOIN Mapping.Ref_Service_Map [service]
ON ca.sk_Ref_Service_Map = [service].sk_Ref_Service_Map
) ids
LEFT JOIN DS_HSDM_App_Dev.Mapping.Ref_Organization_Map organization
ON organization.organization_id = ids.organization_id
) org
LEFT OUTER JOIN DS_HSDW_Prod.dbo.Ref_MDM_Location_Master mdm
ON mdm.EPIC_DEPARTMENT_ID = org.EPIC_DEPARTMENT_ID
LEFT JOIN Mapping.Epic_Dept_Groupers grouper
ON grouper.sk_Ref_Clinical_Area_Map = org.sk_Ref_Clinical_Area_Map
ORDER BY org.organization_id
                  , org.service_id
				  , org.clinical_area_id
				  , mdm.EPIC_DEPARTMENT_ID;

--SELECT ca.sk_Ref_Clinical_Area_Map,
--       ca.organization_id,
--       orgmap.organization_name,
--       ca.service_id,
--       svcmap.service_name,
--       ca.clinical_area_id,
--       camap.clinical_area_name,
--       ca.EPIC_DEPARTMENT_ID,
--       ca.EPIC_DEPT_NAME,
--       ca.EPIC_EXT_NAME,
--	   ca.ambulatory_flag,
--       ca.EPIC_DEPT_TYPE,
--       ca.EPIC_SPCLTY,
--       ca.FINANCE_COST_CODE,
--       ca.PEOPLESOFT_NAME,
--       ca.SERVICE_LINE,
--       ca.SUB_SERVICE_LINE,
--       ca.OPNL_SERVICE_NAME,
--       ca.CORP_SERVICE_LINE,
--       ca.RL_LOCATION_BESAFE,
--       ca.LOC_ID,
--       ca.REV_LOC_NAME,
--       ca.A2K3_NAME,
--       ca.A2K3_CLINIC_CARE_AREA_DESCRIPTION,
--       ca.HS_AREA_ID,
--       ca.HS_AREA_NAME,
--       ca.TJC_FLAG,
--       ca.NDNQI_NAME,
--       ca.NHSN_NAME,
--       ca.PRESSGANEY_NAME,
--       ca.DIVISION_DESC,
--       ca.ADMIN_DESC,
--       ca.BUSINESS_UNIT,
--       ca.RPT_RUN_DT,
--       ca.PFA_POD,
--       ca.HUB,
--       ca.PBB_POD,
--       ca.PG_SURVEY_DESIGNATOR,
--       ca.UPG_PRACTICE_FLAG,
--       ca.UPG_PRACTICE_REGION_NAME,
--       ca.UPG_PRACTICE_ID,
--       ca.UPG_PRACTICE_NAME,
--	   ca.childrens_flag
--FROM
--(
--SELECT
--       mapping.sk_Ref_Clinical_Area_Map,
--	   clinical_area.clinical_area_id,
--	   clinical_area.clinical_area_name,
--	   clinical_area.sk_Ref_Service_Map
--       --mapping.organization_id,
--       --orgmap.organization_name,
--       --mapping.service_id,
--       --svcmap.service_name,
--       --mapping.clinical_area_id,
--       --camap.clinical_area_name,
--       mapping.EPIC_DEPARTMENT_ID,
--       mapping.EPIC_DEPT_NAME,
--       mapping.EPIC_EXT_NAME,
--	   mapping.ambulatory_flag,
--       mapping.EPIC_DEPT_TYPE,
--       mapping.EPIC_SPCLTY,
--       mapping.FINANCE_COST_CODE,
--       mapping.PEOPLESOFT_NAME,
--       mapping.SERVICE_LINE,
--       mapping.SUB_SERVICE_LINE,
--       mapping.OPNL_SERVICE_NAME,
--       mapping.CORP_SERVICE_LINE,
--       mapping.RL_LOCATION_BESAFE,
--       mapping.LOC_ID,
--       mapping.REV_LOC_NAME,
--       mapping.A2K3_NAME,
--       mapping.A2K3_CLINIC_CARE_AREA_DESCRIPTION,
--       mapping.HS_AREA_ID,
--       mapping.HS_AREA_NAME,
--       mapping.TJC_FLAG,
--       mapping.NDNQI_NAME,
--       mapping.NHSN_NAME,
--       mapping.PRESSGANEY_NAME,
--       mapping.DIVISION_DESC,
--       mapping.ADMIN_DESC,
--       mapping.BUSINESS_UNIT,
--       mapping.RPT_RUN_DT,
--       mapping.PFA_POD,
--       mapping.HUB,
--       mapping.PBB_POD,
--       mapping.PG_SURVEY_DESIGNATOR,
--       mapping.UPG_PRACTICE_FLAG,
--       mapping.UPG_PRACTICE_REGION_NAME,
--       mapping.UPG_PRACTICE_ID,
--       mapping.UPG_PRACTICE_NAME,
--	   mapping.childrens_flag
--FROM
--(
--SELECT COALESCE(grouper.sk_Ref_Clinical_Area_Map,165) AS sk_Ref_Clinical_Area_Map
----,COALESCE(grouper.service_id,999) AS service_id
----,COALESCE(grouper.clinical_area_id,999) AS clinical_area_id
-- ,mdm.EPIC_DEPARTMENT_ID
-- ,mdm.EPIC_DEPT_NAME
--,mdm.EPIC_EXT_NAME
--,grouper.ambulatory_flag
--,grouper.childrens_flag
--,grouper.childrens_ambulatory_name
--,grouper.mc_ambulatory_name
--,grouper.ambulatory_operation_name
--,grouper.childrens_name
--,grouper.serviceline_division_name
--,grouper.mc_operation_name
--,grouper.inpatient_adult_name
--,mdm.EPIC_DEPT_TYPE
--,mdm.EPIC_SPCLTY
--,mdm.FINANCE_COST_CODE
--,mdm.PEOPLESOFT_NAME
--,mdm.SERVICE_LINE
--,mdm.SUB_SERVICE_LINE
--,mdm.OPNL_SERVICE_NAME
--,mdm.CORP_SERVICE_LINE
--,mdm.RL_LOCATION [RL_LOCATION_BESAFE]
--,COALESCE(mdm.LOC_ID,'0')  LOC_ID 
--,COALESCE(mdm.REV_LOC_NAME,'Null') REV_LOC_NAME
--,mdm.A2K3_NAME
--,mdm.A2K3_CLINIC_CARE_AREA_DESCRIPTION
--,mdm.AMB_PRACTICE_GROUP
--,mdm.HS_AREA_ID
--,COALESCE(REPLACE(mdm.HS_AREA_NAME,'upg','Null'),'Null') HS_AREA_NAME  --- some have null string
--,mdm.TJC_FLAG
--,mdm.NDNQI_NAME
--,mdm.NHSN_NAME
--,mdm.PRACTICE_GROUP_NAME
--,mdm.PRESSGANEY_NAME
--,mdm.DIVISION_DESC
--,mdm.ADMIN_DESC
--,mdm.BUSINESS_UNIT
--,mdm.RPT_RUN_DT
--,mdm.PFA_POD
--,mdm.HUB
--,mdm.PBB_POD
--,mdm.PG_SURVEY_DESIGNATOR
--,grouper.UPG_PRACTICE_FLAG
--,grouper.UPG_PRACTICE_REGION_NAME
--,grouper.UPG_PRACTICE_ID
--,grouper.UPG_PRACTICE_NAME

--FROM DS_HSDW_Prod.dbo.Ref_MDM_Location_Master mdm
--LEFT JOIN DS_HSDM_App_Dev.Mapping.Epic_Dept_Groupers grouper
--ON grouper.EPIC_DEPARTMENT_ID = mdm.EPIC_DEPARTMENT_ID
--INNER JOIN @ClinicalAreaNew clinicalarea
--ON grouper.sk_Ref_Clinical_Area_Map = clinicalarea.sk_Ref_Clinical_Area_Map
--) mapping
--INNER JOIN Mapping.Ref_Clinical_Area_Map clinical_area
--ON mapping.sk_Ref_Clinical_Area_Map = clinical_area.sk_Ref_Clinical_Area_Map
--) ca
--INNER JOIN Mapping.Ref_Service_Map [service]
--ON ca.sk_Ref_Service_Map = [service].sk_Ref_Service_Map
--) ids
--LEFT JOIN DS_HSDM_App_Dev.Mapping.Ref_Organization_Map organization
--ON organization.organization_id = ids.organization_id
--INNER JOIN @ClinicalAreaNew clinicalarea
--ON mapping.sk_Ref_Clinical_Area_Map = clinicalarea.sk_Ref_Clinical_Area_Map
--) ids
--LEFT JOIN DS_HSDM_App_Dev.Mapping.Ref_Organization_Map orgmap
--ON orgmap.organization_id = ids.organization_id
--LEFT JOIN DS_HSDM_App_Dev.Mapping.Ref_Service_Map svcmap
--ON svcmap.organization_id = ids.organization_id
--AND svcmap.service_id = ids.service_id
--LEFT JOIN DS_HSDM_App_Dev.Mapping.Ref_Clinical_Area_Map camap
--ON camap.clinical_area_id = ids.clinical_area_id
--WHERE 1=1
--ORDER BY ids.organization_id
--                  , ids.service_id
--				  , ids.clinical_area_id
--				  , ids.EPIC_DEPARTMENT_ID;