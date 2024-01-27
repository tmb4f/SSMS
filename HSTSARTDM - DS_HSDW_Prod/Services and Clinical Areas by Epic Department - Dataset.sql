USE DS_HSDW_Prod

--DECLARE @in_clinicalareaid VARCHAR(MAX)

--DECLARE @ClinicalArea TABLE (ClinicalAreaId INTEGER)

--INSERT INTO @ClinicalArea
--(
--    ClinicalAreaId
--)
--VALUES
----(147), -- Behavioral Health, Organization (1) - Inpatient Adult, Service (1) - Behavioral Health
----(148), -- Cardiovascular, Organization (1) - Inpatient Adult, Service (2) - Cardiovascular
----(149), -- Medicine, Organization (1) - Inpatient Adult, Service (5) - Medicine
----(150), -- Neuroscience, Organization (1) - Inpatient Adult, Service (6) - Neuroscience
----(151), -- Oncology, Organization (1) - Inpatient Adult, Service (7) - Oncology
----(152), -- Orthopedics, Organization (1) - Inpatient Adult, Service (8) - Orthopedics
----(153), -- Respiratory Therapy, Organization (1) - Inpatient Adult, Service (9) - Respiratory Therapy
----(154), -- Surgical Services, Organization (1) - Inpatient Adult, Service (10) - Surgical Services
----(155), -- Transplant, Organization (1) - Inpatient Adult, Service (11) - Transplant
----(156), -- Womens, Organization (1) - Inpatient Adult, Service (12) - Womens
----(157), -- Emergency Services, Organization (2) - Emergency Services, Service (4) - Emergency Services
----(32), -- General Pediatrics - Birdsong Clinic, Organization (3) - Children's Hospital, Service (1) - General Pediatrics
----(33), -- Northridge Pediatrics, Organization (3) - Children's Hospital, Service (1) - General Pediatrics
----(34), -- Orange Pediatrics, Organization (3) - Children's Hospital, Service (1) - General Pediatrics
----(158), -- NICU, Organization (3) - Children's Hospital, Service (2) - NICU
----(35), -- Developmental Pediatrics, Organization (3) - Children's Hospital, Service (3) - Pediatric Specialties
----(36), -- Pediatric Allergy , Organization (3) - Children's Hospital, Service (3) - Pediatric Specialties
----(37), -- Pediatric Audiology, Organization (3) - Children's Hospital, Service (3) - Pediatric Specialties
----(38), -- Pediatric Cardiac Surgery, Organization (3) - Children's Hospital, Service (3) - Pediatric Specialties
----(39), -- Pediatric Cardiology, Organization (3) - Children's Hospital, Service (3) - Pediatric Specialties
----(40), -- Pediatric Cardiology Tests, Organization (3) - Children's Hospital, Service (3) - Pediatric Specialties
----(41), -- Pediatric Dentistry, Organization (3) - Children's Hospital, Service (3) - Pediatric Specialties
----(42), -- Pediatric Endocrine & Diabetes, Organization (3) - Children's Hospital, Service (3) - Pediatric Specialties
----(43), -- Pediatric General Surgery, Organization (3) - Children's Hospital, Service (3) - Pediatric Specialties
----(44), -- Pediatric Genetics, Organization (3) - Children's Hospital, Service (3) - Pediatric Specialties
----(45), -- Pediatric GI, Organization (3) - Children's Hospital, Service (3) - Pediatric Specialties
----(46), -- Pediatric Hem Onc, Organization (3) - Children's Hospital, Service (3) - Pediatric Specialties
----(47), -- Pediatric Infectious Disease, Organization (3) - Children's Hospital, Service (3) - Pediatric Specialties
----(48), -- Pediatric Infusion, Organization (3) - Children's Hospital, Service (3) - Pediatric Specialties
----(49), -- Pediatric Neurology - Battle Building, Organization (3) - Children's Hospital, Service (3) - Pediatric Specialties
----(50), -- Pediatric Neurology - Primary Care Center, Organization (3) - Children's Hospital, Service (3) - Pediatric Specialties
----(51), -- Pediatric Neurosurgery, Organization (3) - Children's Hospital, Service (3) - Pediatric Specialties
----(52), -- Pediatric Nutrition, Organization (3) - Children's Hospital, Service (3) - Pediatric Specialties
----(53), -- Pediatric Occupational Therapy - Battle Building, Organization (3) - Children's Hospital, Service (3) - Pediatric Specialties
----(54), -- Pediatric Occupational Therapy at Stacey Hall, Organization (3) - Children's Hospital, Service (3) - Pediatric Specialties
----(55), -- Pediatric Orthopaedics, Organization (3) - Children's Hospital, Service (3) - Pediatric Specialties
----(56), -- Pediatric Otolaryngology, Organization (3) - Children's Hospital, Service (3) - Pediatric Specialties
----(57), -- Pediatric Palliative Care, Organization (3) - Children's Hospital, Service (3) - Pediatric Specialties
----(58), -- Pediatric Physical Therapy - Battle Building, Organization (3) - Children's Hospital, Service (3) - Pediatric Specialties
----(59), -- Pediatric Physical Therapy - Stacey Hall, Organization (3) - Children's Hospital, Service (3) - Pediatric Specialties
----(60), -- Pediatric Plastic Surgery, Organization (3) - Children's Hospital, Service (3) - Pediatric Specialties
----(61), -- Pediatric Psychiatry, Organization (3) - Children's Hospital, Service (3) - Pediatric Specialties
----(62), -- Pediatric Pulmonology, Organization (3) - Children's Hospital, Service (3) - Pediatric Specialties
----(63), -- Pediatric Renal , Organization (3) - Children's Hospital, Service (3) - Pediatric Specialties
----(64), -- Pediatric Rheumatology, Organization (3) - Children's Hospital, Service (3) - Pediatric Specialties
----(65), -- Pediatric Speech Pathology, Organization (3) - Children's Hospital, Service (3) - Pediatric Specialties
----(66), -- Pediatric Transplant, Organization (3) - Children's Hospital, Service (3) - Pediatric Specialties
----(67), -- Pediatric Urology, Organization (3) - Children's Hospital, Service (3) - Pediatric Specialties
----(68), -- Teen Health, Organization (3) - Children's Hospital, Service (3) - Pediatric Specialties
----(142), -- Developmental Pediatrics - Emmet Street, Organization (3) - Children's Hospital, Service (3) - Pediatric Specialties
----(160), -- Pediatric Acute Care, Organization (3) - Children's Hospital, Service (4) - Pediatric Acute Care
----(159), -- PICU, Organization (3) - Children's Hospital, Service (6) - PICU
----(145), -- Dialysis, Organization (4) - Medical Center Ambulatory, Service (1) - Dialysis
----(72), -- Allergy, Organization (4) - Medical Center Ambulatory, Service (2) - Medical Subspecialties
----(73), -- COVID Clinics, Organization (4) - Medical Center Ambulatory, Service (2) - Medical Subspecialties
----(74), -- Endocrinology, Organization (4) - Medical Center Ambulatory, Service (2) - Medical Subspecialties
----(75), -- Infectious Disease, Organization (4) - Medical Center Ambulatory, Service (2) - Medical Subspecialties
----(76), -- Nephrology, Organization (4) - Medical Center Ambulatory, Service (2) - Medical Subspecialties
----(77), -- Pulmonary, Organization (4) - Medical Center Ambulatory, Service (2) - Medical Subspecialties
----(78), -- Pulmonary Function Test, Organization (4) - Medical Center Ambulatory, Service (2) - Medical Subspecialties
----(79), -- Rheumatology, Organization (4) - Medical Center Ambulatory, Service (2) - Medical Subspecialties
----(80), -- Womens - Battle Building OB, Organization (4) - Medical Center Ambulatory, Service (2) - Medical Subspecialties
----(81), -- Womens - Northridge Midlife , Organization (4) - Medical Center Ambulatory, Service (2) - Medical Subspecialties
----(82), -- Womens - Northridge OB-GYN, Organization (4) - Medical Center Ambulatory, Service (2) - Medical Subspecialties
----(83), -- Womens - PCC OB-GYN, Organization (4) - Medical Center Ambulatory, Service (2) - Medical Subspecialties
----(84), -- Adult Psychiatry - Northridge, Organization (4) - Medical Center Ambulatory, Service (3) - Primary Care
----(85), -- Behavioral Medicine - Collins Wing, Organization (4) - Medical Center Ambulatory, Service (3) - Primary Care
----(86), -- Child & Family Psychiatric Medicine - Old Ivy Way, Organization (4) - Medical Center Ambulatory, Service (3) - Primary Care
----(87), -- Neurocognitive Assessment Lab - Davis Wing, Organization (4) - Medical Center Ambulatory, Service (3) - Primary Care
----(88), -- Primary and Specialty Care - Crozet, Organization (4) - Medical Center Ambulatory, Service (3) - Primary Care
----(89), -- Primary and Specialty Care - Orange, Organization (4) - Medical Center Ambulatory, Service (3) - Primary Care
----(90), -- Primary and Specialty Care - Pantops, Organization (4) - Medical Center Ambulatory, Service (3) - Primary Care
----(91), -- Primary Care - Colonnades, Organization (4) - Medical Center Ambulatory, Service (3) - Primary Care
----(92), -- Primary Care - Crossroads, Organization (4) - Medical Center Ambulatory, Service (3) - Primary Care
----(93), -- Primary Care - JABA, Organization (4) - Medical Center Ambulatory, Service (3) - Primary Care
----(94), -- Primary Care - Primary Care Center, Organization (4) - Medical Center Ambulatory, Service (3) - Primary Care
----(95), -- Primary Care - Stoney Creek, Organization (4) - Medical Center Ambulatory, Service (3) - Primary Care
----(96), -- Primary Care - UMA, Organization (4) - Medical Center Ambulatory, Service (3) - Primary Care
----(97), -- Primary Care Clinic - UPC, Organization (4) - Medical Center Ambulatory, Service (3) - Primary Care
----(98), -- Psychiatric Medicine - Multi-Story, Organization (4) - Medical Center Ambulatory, Service (3) - Primary Care
----(99), -- The Haven, Organization (4) - Medical Center Ambulatory, Service (3) - Primary Care
----(146), -- Sleep Center, Organization (4) - Medical Center Ambulatory, Service (4) - Sleep Center
----(101), -- Audiology, Organization (4) - Medical Center Ambulatory, Service (5) - Surgical Specialties A
----(102), -- Hand Center, Organization (4) - Medical Center Ambulatory, Service (5) - Surgical Specialties A
----(103), -- Orthopaedics, Organization (4) - Medical Center Ambulatory, Service (5) - Surgical Specialties A
----(104), -- Otolaryngology, Organization (4) - Medical Center Ambulatory, Service (5) - Surgical Specialties A
----(105), -- Pain Management, Organization (4) - Medical Center Ambulatory, Service (5) - Surgical Specialties A
----(106), -- Pelvic Medicine, Organization (4) - Medical Center Ambulatory, Service (5) - Surgical Specialties A
----(107), -- Physical Medicine & Rehabilitation, Organization (4) - Medical Center Ambulatory, Service (5) - Surgical Specialties A
----(108), -- Spine Center, Organization (4) - Medical Center Ambulatory, Service (5) - Surgical Specialties A
----(109), -- Sports Medicine, Organization (4) - Medical Center Ambulatory, Service (5) - Surgical Specialties A
----(110), -- Urology, Organization (4) - Medical Center Ambulatory, Service (5) - Surgical Specialties A
----(111), -- Dentistry, Organization (4) - Medical Center Ambulatory, Service (6) - Surgical Specialties B
----(112), -- Dermatology, Organization (4) - Medical Center Ambulatory, Service (6) - Surgical Specialties B
----(113), -- General Surgery, Organization (4) - Medical Center Ambulatory, Service (6) - Surgical Specialties B
----(114), -- Hyperbaric Medicine, Organization (4) - Medical Center Ambulatory, Service (6) - Surgical Specialties B
----(115), -- Ophthalmology, Organization (4) - Medical Center Ambulatory, Service (6) - Surgical Specialties B
----(116), -- Oral Surgery, Organization (4) - Medical Center Ambulatory, Service (6) - Surgical Specialties B
----(117), -- Plastic Surgery, Organization (4) - Medical Center Ambulatory, Service (6) - Surgical Specialties B
----(118), -- Zion Crossroads, Organization (4) - Medical Center Ambulatory, Service (6) - Surgical Specialties B
----(143), -- Pantops, Organization (4) - Medical Center Ambulatory, Service (6) - Surgical Specialties B
----(144), -- Augusta, Organization (4) - Medical Center Ambulatory, Service (6) - Surgical Specialties B
----(161), -- Continuum Home Health, Organization (5) - Medical Center Operations, Service (1) - Continuum Home Health
----(162), -- Labs, Organization (5) - Medical Center Operations, Service (3) - Labs
----(163), -- Perioperative Services, Organization (5) - Medical Center Operations, Service (4) - Perioperative Services
----(164), -- Pharmacy, Organization (5) - Medical Center Operations, Service (5) - Pharmacy
----(165), -- Radiology, Organization (5) - Medical Center Operations, Service (6) - Radiology
----(166), -- TCH, Organization (5) - Medical Center Operations, Service (7) - TCH
----(167), -- Therapies, Organization (5) - Medical Center Operations, Service (8) - Therapies
----(168), -- Imaging, Organization (5) - Medical Center Operations, Service (9) - Imaging
----(119), -- Community Oncology - Augusta, Organization (6) - Service Lines, Service (1) - Oncology
----(120), -- Community Oncology - Culpeper, Organization (6) - Service Lines, Service (1) - Oncology
----(121), -- Community Oncology - Pantops, Organization (6) - Service Lines, Service (1) - Oncology
----(122), -- Breast Care Center, Organization (6) - Service Lines, Service (1) - Oncology
----(123), -- Moser Radiation Center, Organization (6) - Service Lines, Service (1) - Oncology
----(124), -- Emily Couric Clinical Cancer Center, Organization (6) - Service Lines, Service (1) - Oncology
----(697), -- No Clinical Area Assigned, Organization (6) - Service Lines, Service (1) - Oncology
----(125), -- Alta Vista, Organization (6) - Service Lines, Service (2) - Transplant
----(126), -- Virginia Hospital Center, Organization (6) - Service Lines, Service (2) - Transplant
----(127), -- Haymarket, Organization (6) - Service Lines, Service (2) - Transplant
----(128), -- Lynchburg, Organization (6) - Service Lines, Service (2) - Transplant
----(129), -- Locust Grove, Organization (6) - Service Lines, Service (2) - Transplant
----(130), -- Roanoke, Organization (6) - Service Lines, Service (2) - Transplant
----(131), -- West Complex, Organization (6) - Service Lines, Service (2) - Transplant
----(698), -- No Clinical Area Assigned, Organization (6) - Service Lines, Service (2) - Transplant
----(132), -- Neurology - Primary Care Center, Organization (6) - Service Lines, Service (3) - Neurosciences
----(133), -- Neurosurgery - West Complex, Organization (6) - Service Lines, Service (3) - Neurosciences
----(134), -- Neurosurgery - Fontaine, Organization (6) - Service Lines, Service (3) - Neurosciences
----(135), -- Heart & Vascular - Culpeper, Organization (6) - Service Lines, Service (4) - Heart & Vascular
----(136), -- Heart & Vascular - Northridge, Organization (6) - Service Lines, Service (4) - Heart & Vascular
----(137), -- Heart & Vascular Center - ECCC, Organization (6) - Service Lines, Service (4) - Heart & Vascular
----(138), -- Heart & Vascular Center - Battle Building, Organization (6) - Service Lines, Service (4) - Heart & Vascular
----(139), -- Heart & Vascular Center - Fontaine, Organization (6) - Service Lines, Service (4) - Heart & Vascular
----(140), -- Heart & Vascular Center - Primary Care Center, Organization (6) - Service Lines, Service (4) - Heart & Vascular
----(141), -- Heart & Vascular Center - University Hospital, Organization (6) - Service Lines, Service (4) - Heart & Vascular
----(699), -- No Clinical Area Assigned, Organization (6) - Service Lines, Service (4) - Heart & Vascular
----(5), -- Endocrinology Pantops, Organization (7) - UPG, Service (2) - UPG-Community Division
----(6), -- Neurosurgery Haymarket, Organization (7) - UPG, Service (2) - UPG-Community Division
----(7), -- Radiology Vein and Vascular Care Gainesville, Organization (7) - UPG, Service (2) - UPG-Community Division
----(9), -- Obstetrics and Gynecology a Department of Novant H, Organization (7) - UPG, Service (4) - UPG-CPG Novant Specialty
----(10), -- Orthopedics a Department of Novant Health Health, Organization (7) - UPG, Service (4) - UPG-CPG Novant Specialty
----(11), -- Surgical Services a Department of Novant Health He, Organization (7) - UPG, Service (4) - UPG-CPG Novant Specialty
----(12), -- Pediatric Cardiology Richmond, Organization (7) - UPG, Service (5) - UPG-CPG Specialty
----(13), -- Pediatric Pulmonology Riverside, Organization (7) - UPG, Service (5) - UPG-CPG Specialty
----(14), -- Pediatric Specialty Care Winchester, Organization (7) - UPG, Service (5) - UPG-CPG Specialty
----(15), -- Physical and Occupational Therapy, Organization (7) - UPG, Service (5) - UPG-CPG Specialty
----(30), -- Dermatology Waynesboro, Organization (7) - UPG, Service (5) - UPG-CPG Specialty
----(17), -- Pediatrics Culpeper, Organization (7) - UPG, Service (6) - UPG-RPC North
----(18), -- Primary Care Commonwealth Medical, Organization (7) - UPG, Service (6) - UPG-RPC North
----(19), -- Primary Care Culpeper Family Practice, Organization (7) - UPG, Service (6) - UPG-RPC North
----(20), -- Primary Care Family Care of Culpeper, Organization (7) - UPG, Service (6) - UPG-RPC North
----(21), -- Primary Care Locust Grove, Organization (7) - UPG, Service (6) - UPG-RPC North
----(23), -- Pediatrics Augusta, Organization (7) - UPG, Service (7) - UPG-RPC South
----(24), -- Primary Care Lake Monticello, Organization (7) - UPG, Service (7) - UPG-RPC South
----(25), -- Primary Care Louisa, Organization (7) - UPG, Service (7) - UPG-RPC South
----(26), -- Primary Care Stuarts Draft, Organization (7) - UPG, Service (7) - UPG-RPC South
----(27), -- Pediatrics Harrisonburg, Organization (7) - UPG, Service (7) - UPG-RPC South
----(28), -- Primary Care Riverside, Organization (7) - UPG, Service (7) - UPG-RPC South
----(29), -- Primary Care Waynesboro, Organization (7) - UPG, Service (7) - UPG-RPC South
----(31), -- Pediatric McGaheysville, Organization (7) - UPG, Service (7) - UPG-RPC South
----(100), -- Community Medicine, Organization (8) - Other Ambulatory Services, Service (2) - Community Medicine
----(69), -- Digestive Health - Monroe Lane, Organization (8) - Other Ambulatory Services, Service (4) - Digestive Health
----(70), -- Digestive Health - Primary Care Center, Organization (8) - Other Ambulatory Services, Service (4) - Digestive Health
----(71), -- Digestive Health - University Hospital, Organization (8) - Other Ambulatory Services, Service (4) - Digestive Health
----(999)--, -- No Clinical Area Assigned, Organization (999) - No Organization Assigned, Service (999) - No Service Assigned
--(72), -- Allergy, Organization (4) - Medical Center Ambulatory, Service (2) - Medical Subspecialties
--(73), -- COVID Clinics, Organization (4) - Medical Center Ambulatory, Service (2) - Medical Subspecialties
--(74), -- Endocrinology, Organization (4) - Medical Center Ambulatory, Service (2) - Medical Subspecialties
--(75), -- Infectious Disease, Organization (4) - Medical Center Ambulatory, Service (2) - Medical Subspecialties
--(76), -- Nephrology, Organization (4) - Medical Center Ambulatory, Service (2) - Medical Subspecialties
--(77), -- Pulmonary, Organization (4) - Medical Center Ambulatory, Service (2) - Medical Subspecialties
--(78), -- Pulmonary Function Test, Organization (4) - Medical Center Ambulatory, Service (2) - Medical Subspecialties
--(79), -- Rheumatology, Organization (4) - Medical Center Ambulatory, Service (2) - Medical Subspecialties
--(80), -- Womens - Battle Building OB, Organization (4) - Medical Center Ambulatory, Service (2) - Medical Subspecialties
--(81), -- Womens - Northridge Midlife , Organization (4) - Medical Center Ambulatory, Service (2) - Medical Subspecialties
--(82), -- Womens - Northridge OB-GYN, Organization (4) - Medical Center Ambulatory, Service (2) - Medical Subspecialties
--(83)--, -- Womens - PCC OB-GYN, Organization (4) - Medical Center Ambulatory, Service (2) - Medical Subspecialties
--;

--SELECT @in_clinicalareaid = COALESCE(@in_clinicalareaid+',' ,'') + CAST(ClinicalAreaId AS VARCHAR(MAX))
--FROM @ClinicalArea

--SELECT @in_clinicalareaid

--DECLARE @ClinicalAreaNew TABLE (
--	[clinical_area_id] [int] NOT NULL)

--INSERT INTO @ClinicalAreaNew
--(
--    clinical_area_id
--)
--SELECT Param AS clinical_area_id FROM ETL.fn_ParmParse(@in_clinicalareaid, ',')

--SELECT * FROM @ClinicalAreaNew

--SELECT ids.organization_id,
--       orgmap.organization_name,
--       ids.service_id,
--       svcmap.service_name,
--       ids.clinical_area_id,
--       camap.clinical_area_name,
--       ids.EPIC_DEPARTMENT_ID,
--       ids.EPIC_DEPT_NAME,
--       ids.EPIC_EXT_NAME,
--	   ids.ambulatory_flag,
--       ids.EPIC_DEPT_TYPE,
--       ids.EPIC_SPCLTY,
--       ids.FINANCE_COST_CODE,
--       ids.PEOPLESOFT_NAME,
--       ids.SERVICE_LINE,
--       ids.SUB_SERVICE_LINE,
--       ids.OPNL_SERVICE_NAME,
--       ids.CORP_SERVICE_LINE,
--       ids.RL_LOCATION_BESAFE,
--       ids.LOC_ID,
--       ids.REV_LOC_NAME,
--       ids.A2K3_NAME,
--       ids.A2K3_CLINIC_CARE_AREA_DESCRIPTION,
--       ids.HS_AREA_ID,
--       ids.HS_AREA_NAME,
--       ids.TJC_FLAG,
--       ids.NDNQI_NAME,
--       ids.NHSN_NAME,
--       ids.PRESSGANEY_NAME,
--       ids.DIVISION_DESC,
--       ids.ADMIN_DESC,
--       ids.BUSINESS_UNIT,
--       ids.RPT_RUN_DT,
--       ids.PFA_POD,
--       ids.HUB,
--       ids.PBB_POD,
--       ids.PG_SURVEY_DESIGNATOR,
--       ids.UPG_PRACTICE_FLAG,
--       ids.UPG_PRACTICE_REGION_NAME,
--       ids.UPG_PRACTICE_ID,
--       ids.UPG_PRACTICE_NAME,
--	   ids.childrens_flag
--FROM
--(
--SELECT COALESCE(mapping.organization_id,999) AS organization_id
--,COALESCE(mapping.service_id,999) AS service_id
--,COALESCE(mapping.clinical_area_id,999) AS clinical_area_id
-- ,mdm.EPIC_DEPARTMENT_ID
-- ,mdm.EPIC_DEPT_NAME
--,mdm.EPIC_EXT_NAME
--,mapping.ambulatory_flag
--,mapping.childrens_flag
--,mapping.childrens_ambulatory_name
--,mapping.mc_ambulatory_name
--,mapping.ambulatory_operation_name
--,mapping.childrens_name
--,mapping.serviceline_division_name
--,mapping.mc_operation_name
--,mapping.inpatient_adult_name
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
--,mapping.UPG_PRACTICE_FLAG
--,mapping.UPG_PRACTICE_REGION_NAME
--,mapping.UPG_PRACTICE_ID
--,mapping.UPG_PRACTICE_NAME

--FROM dbo.Ref_MDM_Location_Master mdm
--LEFT JOIN DS_HSDM_App.Mapping.Epic_Dept_Groupers mapping
--ON mapping.EPIC_DEPARTMENT_ID = mdm.EPIC_DEPARTMENT_ID
--INNER JOIN @ClinicalAreaNew clinicalarea
--ON mapping.clinical_area_id = clinicalarea.clinical_area_id
--) ids
--LEFT JOIN DS_HSDM_App.Mapping.Ref_Organization_Map orgmap
--ON orgmap.organization_id = ids.organization_id
--LEFT JOIN DS_HSDM_App.Mapping.Ref_Service_Map svcmap
--ON svcmap.organization_id = ids.organization_id
--AND svcmap.service_id = ids.service_id
--LEFT JOIN DS_HSDM_App.Mapping.Ref_Clinical_Area_Map camap
--ON camap.clinical_area_id = ids.clinical_area_id
--WHERE 1=1
--ORDER BY ids.organization_id
--                  , ids.service_id
--				  , ids.clinical_area_id
--				  , ids.EPIC_DEPARTMENT_ID
				  
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
(46), -- Clinical Area (53) - Pediatric Therapies, Service (3) - Pediatric Specialties, Organization (3) - Children's Hospital
(48), -- Clinical Area (55) - Pediatric Orthopaedics, Service (3) - Pediatric Specialties, Organization (3) - Children's Hospital
(49), -- Clinical Area (56) - Pediatric Otolaryngology, Service (3) - Pediatric Specialties, Organization (3) - Children's Hospital
(50), -- Clinical Area (57) - Pediatric Palliative Care, Service (3) - Pediatric Specialties, Organization (3) - Children's Hospital
(53), -- Clinical Area (60) - Pediatric Plastic Surgery, Service (3) - Pediatric Specialties, Organization (3) - Children's Hospital
(54), -- Clinical Area (61) - Pediatric Psychiatry, Service (3) - Pediatric Specialties, Organization (3) - Children's Hospital
(55), -- Clinical Area (62) - Pediatric Pulmonology, Service (3) - Pediatric Specialties, Organization (3) - Children's Hospital
(56), -- Clinical Area (63) - Pediatric Renal , Service (3) - Pediatric Specialties, Organization (3) - Children's Hospital
(57), -- Clinical Area (64) - Pediatric Rheumatology, Service (3) - Pediatric Specialties, Organization (3) - Children's Hospital
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
(105), -- Clinical Area (112) - Dermatology, Service (2) - Medical Subspecialties, Organization (4) - Medical Center Ambulatory
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
(106), -- Clinical Area (113) - General Surgery, Service (6) - Surgical Specialties B, Organization (4) - Medical Center Ambulatory
(107), -- Clinical Area (114) - Hyperbaric Medicine, Service (6) - Surgical Specialties B, Organization (4) - Medical Center Ambulatory
(108), -- Clinical Area (115) - Ophthalmology, Service (6) - Surgical Specialties B, Organization (4) - Medical Center Ambulatory
(109), -- Clinical Area (116) - Oral Surgery, Service (6) - Surgical Specialties B, Organization (4) - Medical Center Ambulatory
(110), -- Clinical Area (117) - Plastic Surgery, Service (6) - Surgical Specialties B, Organization (4) - Medical Center Ambulatory
(111), -- Clinical Area (118) - Zion Crossroads, Service (6) - Surgical Specialties B, Organization (4) - Medical Center Ambulatory
(136), -- Clinical Area (143) - Pantops Rheumatology, Service (6) - Surgical Specialties B, Organization (4) - Medical Center Ambulatory
(137), -- Clinical Area (144) - Augusta, Service (6) - Surgical Specialties B, Organization (4) - Medical Center Ambulatory
(101), -- Clinical Area (108) - Spine Program, Service (7) - Spine Program, Organization (4) - Medical Center Ambulatory
(77), -- Clinical Area (84) - Adult Psychiatry - Northridge, Service (8) - Behavioral Health, Organization (4) - Medical Center Ambulatory
(78), -- Clinical Area (85) - Behavioral Medicine - Collins Wing, Service (8) - Behavioral Health, Organization (4) - Medical Center Ambulatory
(79), -- Clinical Area (86) - Child & Family Psychiatric Medicine - Old Ivy Way, Service (8) - Behavioral Health, Organization (4) - Medical Center Ambulatory
(80), -- Clinical Area (87) - Neurocognitive Assessment Lab - Davis Wing, Service (8) - Behavioral Health, Organization (4) - Medical Center Ambulatory
(91), -- Clinical Area (98) - Psychiatric Medicine - Multi-Story, Service (8) - Behavioral Health, Organization (4) - Medical Center Ambulatory
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
(116), -- Clinical Area (123) - Radiation Oncology, Service (1) - Oncology, Organization (6) - Service Lines
(117), -- Clinical Area (124) - Emily Couric Clinical Cancer Center, Service (1) - Oncology, Organization (6) - Service Lines
(162), -- Clinical Area (697) - No Clinical Area Assigned, Service (1) - Oncology, Organization (6) - Service Lines
(174), -- Clinical Area (175) - Infusion - Augusta, Service (1) - Oncology, Organization (6) - Service Lines
(175), -- Clinical Area (176) - Infusion - Culpeper, Service (1) - Oncology, Organization (6) - Service Lines
(176), -- Clinical Area (177) - Infusion - ECCCC, Service (1) - Oncology, Organization (6) - Service Lines
(177), -- Clinical Area (178) - Infusion - Pantops, Service (1) - Oncology, Organization (6) - Service Lines
(118), -- Clinical Area (125) - Transplant - Kidney, Service (2) - Transplant, Organization (6) - Service Lines
(119), -- Clinical Area (126) - Transplant - Liver Outreach, Service (2) - Transplant, Organization (6) - Service Lines
(120), -- Clinical Area (127) - Transplant - Liver, Service (2) - Transplant, Organization (6) - Service Lines
(121), -- Clinical Area (128) - Transplant - Lung, Service (2) - Transplant, Organization (6) - Service Lines
(122), -- Clinical Area (129) - Transplant - Consult Services, Service (2) - Transplant, Organization (6) - Service Lines
(123), -- Clinical Area (130) - Transplant - Kidney and Liver Surgery, Service (2) - Transplant, Organization (6) - Service Lines
(124), -- Clinical Area (131) - Transplant - Kidney and Liver Surgery Outreach, Service (2) - Transplant, Organization (6) - Service Lines
(163), -- Clinical Area (179) - Transplant - Kidney Outreach, Service (2) - Transplant, Organization (6) - Service Lines
(125), -- Clinical Area (132) - Neurology - Primary Care Center, Service (3) - Neurosciences, Organization (6) - Service Lines
(126), -- Clinical Area (133) - Neurosurgery - West Complex, Service (3) - Neurosciences, Organization (6) - Service Lines
(127), -- Clinical Area (134) - Neurosurgery - Fontaine, Service (3) - Neurosciences, Organization (6) - Service Lines
(168), -- Clinical Area (171) - Neurology - Field Clinics, Service (3) - Neurosciences, Organization (6) - Service Lines
(169), -- Clinical Area (172) - Neurosurgery - Field Clinics, Service (3) - Neurosciences, Organization (6) - Service Lines
(128), -- Clinical Area (135) - Heart & Vascular Center - Vascular Lab, Service (4) - Heart & Vascular, Organization (6) - Service Lines
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
(172), -- Clinical Area (32) - Pediatrics Fall Hill/Fredericksburg, Service (2) - UPG-Community Division, Organization (7) - UPG
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
--(21)--, -- Clinical Area (28) - Primary Care Riverside, Service (7) - UPG-RPC South, Organization (7) - UPG
--(75)--, -- Clinical Area (82) - Womens - Northridge OB-GYN, Service (2) - Medical Subspecialties, Organization (4) - Medical Center Ambulatory
;

SELECT @in_skrefclinicalareamap = COALESCE(@in_skrefclinicalareamap+',' ,'') + CAST(sk_Ref_Clinical_Area_Map AS VARCHAR(MAX))
FROM @ClinicalArea

--SELECT @in_skrefclinicalareamap

DECLARE @ClinicalAreaNew TABLE (
	[sk_Ref_Clinical_Area_Map] [int] NOT NULL)

INSERT INTO @ClinicalAreaNew
(
    sk_Ref_Clinical_Area_Map
)
SELECT Param AS sk_Ref_Clinical_Area_Map FROM ETL.fn_ParmParse(@in_skrefclinicalareamap, ',')

--SELECT * FROM @ClinicalAreaNew

--SELECT DISTINCT mdm.EPIC_DEPARTMENT_ID, COALESCE(grouper.sk_Ref_Clinical_Area_Map,165) AS sk_Ref_Clinical_Area_Map
--FROM DS_HSDW_Prod.dbo.Ref_MDM_Location_Master mdm
--LEFT JOIN DS_HSDM_App.Mapping.Epic_Dept_Groupers grouper
--ON grouper.EPIC_DEPARTMENT_ID = mdm.EPIC_DEPARTMENT_ID
--INNER JOIN @ClinicalAreaNew clinicalarea
--ON grouper.sk_Ref_Clinical_Area_Map = clinicalarea.sk_Ref_Clinical_Area_Map
--ORDER BY mdm.EPIC_DEPARTMENT_ID

--SELECT DISTINCT mapping.EPIC_DEPARTMENT_ID, mapping.sk_Ref_Clinical_Area_Map, clinical_area.clinical_area_id, clinical_area.clinical_area_name, COALESCE(clinical_area.sk_Ref_Service_Map, 43) AS sk_Ref_Service_Map
--FROM
--(
--SELECT DISTINCT mdm.EPIC_DEPARTMENT_ID, COALESCE(grouper.sk_Ref_Clinical_Area_Map,165) AS sk_Ref_Clinical_Area_Map
--FROM DS_HSDW_Prod.dbo.Ref_MDM_Location_Master mdm
--LEFT JOIN DS_HSDM_App.Mapping.Epic_Dept_Groupers grouper
--ON grouper.EPIC_DEPARTMENT_ID = mdm.EPIC_DEPARTMENT_ID
--INNER JOIN @ClinicalAreaNew clinicalarea
--ON grouper.sk_Ref_Clinical_Area_Map = clinicalarea.sk_Ref_Clinical_Area_Map
--) mapping
--INNER JOIN DS_HSDM_App.Mapping.Ref_Clinical_Area_Map clinical_area
--ON mapping.sk_Ref_Clinical_Area_Map = clinical_area.sk_Ref_Clinical_Area_Map
--ORDER BY mapping.EPIC_DEPARTMENT_ID

--SELECT DISTINCT ca.EPIC_DEPARTMENT_ID, ca.sk_Ref_Clinical_Area_Map, ca.clinical_area_id, ca.clinical_area_name, ca.sk_Ref_Service_Map, [service].service_id, [service].[service_name], COALESCE([service].organization_id,999) AS organization_id
--FROM
--(
--SELECT DISTINCT mapping.EPIC_DEPARTMENT_ID, mapping.sk_Ref_Clinical_Area_Map, clinical_area.clinical_area_id, clinical_area.clinical_area_name, COALESCE(clinical_area.sk_Ref_Service_Map, 43) AS sk_Ref_Service_Map
--FROM
--(
--SELECT DISTINCT mdm.EPIC_DEPARTMENT_ID, COALESCE(grouper.sk_Ref_Clinical_Area_Map,165) AS sk_Ref_Clinical_Area_Map
--FROM DS_HSDW_Prod.dbo.Ref_MDM_Location_Master mdm
--LEFT JOIN DS_HSDM_App.Mapping.Epic_Dept_Groupers grouper
--ON grouper.EPIC_DEPARTMENT_ID = mdm.EPIC_DEPARTMENT_ID
--INNER JOIN @ClinicalAreaNew clinicalarea
--ON grouper.sk_Ref_Clinical_Area_Map = clinicalarea.sk_Ref_Clinical_Area_Map
--) mapping
--INNER JOIN DS_HSDM_App.Mapping.Ref_Clinical_Area_Map clinical_area
--ON mapping.sk_Ref_Clinical_Area_Map = clinical_area.sk_Ref_Clinical_Area_Map
--) ca
--INNER JOIN DS_HSDM_App.Mapping.Ref_Service_Map [service]
--ON ca.sk_Ref_Service_Map = [service].sk_Ref_Service_Map
--ORDER BY ca.EPIC_DEPARTMENT_ID

--SELECT DISTINCT ids.EPIC_DEPARTMENT_ID, ids.sk_Ref_Clinical_Area_Map, ids.clinical_area_id, ids.clinical_area_name, ids.sk_Ref_Service_Map, ids.service_id, ids.[service_name], ids.organization_id, organization.organization_name
--FROM
--(
--SELECT DISTINCT ca.EPIC_DEPARTMENT_ID, ca.sk_Ref_Clinical_Area_Map, ca.clinical_area_id, ca.clinical_area_name, ca.sk_Ref_Service_Map, [service].service_id, [service].[service_name], COALESCE([service].organization_id,999) AS organization_id
--FROM
--(
--SELECT DISTINCT mapping.EPIC_DEPARTMENT_ID, mapping.sk_Ref_Clinical_Area_Map, clinical_area.clinical_area_id, clinical_area.clinical_area_name, COALESCE(clinical_area.sk_Ref_Service_Map, 43) AS sk_Ref_Service_Map
--FROM
--(
--SELECT DISTINCT mdm.EPIC_DEPARTMENT_ID, COALESCE(grouper.sk_Ref_Clinical_Area_Map,165) AS sk_Ref_Clinical_Area_Map
--FROM DS_HSDW_Prod.dbo.Ref_MDM_Location_Master mdm
--LEFT JOIN DS_HSDM_App.Mapping.Epic_Dept_Groupers grouper
--ON grouper.EPIC_DEPARTMENT_ID = mdm.EPIC_DEPARTMENT_ID
--INNER JOIN @ClinicalAreaNew clinicalarea
--ON grouper.sk_Ref_Clinical_Area_Map = clinicalarea.sk_Ref_Clinical_Area_Map
--) mapping
--INNER JOIN DS_HSDM_App.Mapping.Ref_Clinical_Area_Map clinical_area
--ON mapping.sk_Ref_Clinical_Area_Map = clinical_area.sk_Ref_Clinical_Area_Map
--) ca
--INNER JOIN DS_HSDM_App.Mapping.Ref_Service_Map [service]
--ON ca.sk_Ref_Service_Map = [service].sk_Ref_Service_Map
--) ids
--LEFT JOIN DS_HSDM_App.Mapping.Ref_Organization_Map organization
--ON organization.organization_id = ids.organization_id
--ORDER BY ids.EPIC_DEPARTMENT_ID


--SELECT DISTINCT mdm.EPIC_DEPARTMENT_ID, org.clinical_area_id, org.clinical_area_name, org.service_id, org.service_name, org.organization_id, org.organization_name
--FROM
--(
--SELECT DISTINCT ids.EPIC_DEPARTMENT_ID, ids.sk_Ref_Clinical_Area_Map, ids.clinical_area_id, ids.clinical_area_name, ids.sk_Ref_Service_Map, ids.service_id, ids.[service_name], ids.organization_id, organization.organization_name
--FROM
--(
--SELECT DISTINCT ca.EPIC_DEPARTMENT_ID, ca.sk_Ref_Clinical_Area_Map, ca.clinical_area_id, ca.clinical_area_name, ca.sk_Ref_Service_Map, [service].service_id, [service].[service_name], COALESCE([service].organization_id,999) AS organization_id
--FROM
--(
--SELECT DISTINCT mapping.EPIC_DEPARTMENT_ID, mapping.sk_Ref_Clinical_Area_Map, clinical_area.clinical_area_id, clinical_area.clinical_area_name, COALESCE(clinical_area.sk_Ref_Service_Map, 43) AS sk_Ref_Service_Map
--FROM
--(
--SELECT DISTINCT mdm.EPIC_DEPARTMENT_ID, COALESCE(grouper.sk_Ref_Clinical_Area_Map,165) AS sk_Ref_Clinical_Area_Map
--FROM DS_HSDW_Prod.dbo.Ref_MDM_Location_Master mdm
--LEFT JOIN DS_HSDM_App.Mapping.Epic_Dept_Groupers grouper
--ON grouper.EPIC_DEPARTMENT_ID = mdm.EPIC_DEPARTMENT_ID
--INNER JOIN @ClinicalAreaNew clinicalarea
--ON grouper.sk_Ref_Clinical_Area_Map = clinicalarea.sk_Ref_Clinical_Area_Map
--) mapping
--INNER JOIN DS_HSDM_App.Mapping.Ref_Clinical_Area_Map clinical_area
--ON mapping.sk_Ref_Clinical_Area_Map = clinical_area.sk_Ref_Clinical_Area_Map
--) ca
--INNER JOIN DS_HSDM_App.Mapping.Ref_Service_Map [service]
--ON ca.sk_Ref_Service_Map = [service].sk_Ref_Service_Map
--) ids
--LEFT JOIN DS_HSDM_App.Mapping.Ref_Organization_Map organization
--ON organization.organization_id = ids.organization_id
--) org
--LEFT OUTER JOIN DS_HSDW_Prod.dbo.Ref_MDM_Location_Master mdm
--ON mdm.EPIC_DEPARTMENT_ID = org.EPIC_DEPARTMENT_ID
--LEFT JOIN DS_HSDM_App.Mapping.Epic_Dept_Groupers grouper
--ON grouper.sk_Ref_Clinical_Area_Map = org.sk_Ref_Clinical_Area_Map
--ORDER BY mdm.EPIC_DEPARTMENT_ID

SELECT DISTINCT
 org.organization_id
,org.organization_name
,org.service_id
,org.[service_name]
,org.sk_Ref_Clinical_Area_Map
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
--,mdm.RL_LOCATION [RL_LOCATION_BESAFE]
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
--FROM DS_HSDW_Prod.dbo.Ref_MDM_Location_Master mdm
--LEFT JOIN DS_HSDM_App.Mapping.Epic_Dept_Groupers grouper
--ON grouper.EPIC_DEPARTMENT_ID = mdm.EPIC_DEPARTMENT_ID
FROM DS_HSDM_App.Mapping.Epic_Dept_Groupers grouper
LEFT JOIN DS_HSDW_Prod.dbo.Ref_MDM_Location_Master mdm
ON mdm.EPIC_DEPARTMENT_ID = grouper.EPIC_DEPARTMENT_ID
INNER JOIN @ClinicalAreaNew clinicalarea
ON grouper.sk_Ref_Clinical_Area_Map = clinicalarea.sk_Ref_Clinical_Area_Map
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
--LEFT OUTER JOIN DS_HSDW_Prod.dbo.Ref_MDM_Location_Master mdm
--ON mdm.EPIC_DEPARTMENT_ID = org.EPIC_DEPARTMENT_ID
--LEFT JOIN DS_HSDM_App.Mapping.Epic_Dept_Groupers grouper
----ON grouper.sk_Ref_Clinical_Area_Map = org.sk_Ref_Clinical_Area_Map
--ON grouper.epic_department_id = org.EPIC_DEPARTMENT_ID
LEFT JOIN DS_HSDM_App.Mapping.Epic_Dept_Groupers grouper
--ON grouper.sk_Ref_Clinical_Area_Map = org.sk_Ref_Clinical_Area_Map
ON grouper.epic_department_id = org.EPIC_DEPARTMENT_ID
LEFT JOIN DS_HSDW_Prod.dbo.Ref_MDM_Location_Master mdm
ON mdm.EPIC_DEPARTMENT_ID = org.EPIC_DEPARTMENT_ID
--ORDER BY org.organization_id
--                  , org.service_id
--				  , org.clinical_area_id
--				  , mdm.EPIC_DEPARTMENT_ID;
ORDER BY mdm.EPIC_DEPARTMENT_ID;