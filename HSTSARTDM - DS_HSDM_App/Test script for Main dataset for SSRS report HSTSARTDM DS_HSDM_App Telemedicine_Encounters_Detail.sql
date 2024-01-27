USE DS_HSDM_App

DECLARE @Date_Start SMALLDATETIME = NULL
       ,@Date_End SMALLDATETIME = NULL

--DECLARE @TELEMEDICINE_RESOURCES VARCHAR(200) = ''
--                 ,@TELEMEDICINE_PATIENT_LOCATION VARCHAR(200) = ''

--SET @Date_Start = '7/1/2020 00:00 AM'
--SET @Date_End = '11/30/2020 11:59 PM'
--SET @Date_Start = '4/1/2021 00:00 AM'
--SET @Date_Start = '2/25/2022 00:00 AM'
SET @Date_Start = '7/1/2022 00:00 AM'
--SET @Date_End = '4/30/2021 11:59 PM'
--SET @Date_End = '6/30/2021 11:59 PM'
--SET @Date_End = '3/10/2022 11:59 PM'
SET @Date_End = '3/6/2023 11:59 PM'

SET NOCOUNT ON;

IF OBJECT_ID('tempdb..#tm ') IS NOT NULL
DROP TABLE #tm

DECLARE @SL TABLE (ServiceLineId SMALLINT)

INSERT INTO @SL
(
    ServiceLineId
)
VALUES
(0),--(No SL Defined)
(1),--Digestive Health
(2),--Heart and Vascular
(3),--Medical Subspecialties
(4),--Musculoskeletal
(5),--Neurosciences and Behavioral Health
(6),--Oncology
(8),--Primary Care
(9),--Surgical Subspecialties
(10),--Transplant
--(0),--Unknown
(11) --Womens and Childrens
--(0) --(No SL Defined)
--(1) --Digestive Health
--(1),--Digestive Health
--(2) --Heart and Vascular
--(4) --Musculoskeletal
--(5) --Neurosciences and Behavioral Health
;

DECLARE @SOM_DEPARTMENT TABLE (SOMDepartmentId VARCHAR(100))

INSERT INTO @SOM_DEPARTMENT
(
    SOMDepartmentId
)
VALUES
--('0'),--(No SOM Dept Defined)
--('47'),--MD-ANES Anesthesiology
--('51'),--MD-DERM Dermatology
--('53'),--MD-EMED Emergency Medicine
--('55'),--MD-FMED Family Medicine
--('57'),--MD-INMD Internal Medicine
--('100'),--MD-NERS Neurological Surgery
--('137'),--MD-NEUR Neurology
--('141'),--MD-OBGY Ob & Gyn
--('162'),--MD-OPHT Ophthalmology
--('165'),--MD-ORTP Orthopaedic Surgery
--('196'),--MD-OTLY Otolaryngology
--('203'),--MD-PATH Pathology
--('216'),--MD-PEDT Pediatrics
--('259'),--MD-PHMR Phys Med & Rehab
--('261'),--MD-PLSR Plastic Surgery
--('263'),--MD-PSCH Psychiatric Medicine
--('269'),--MD-RADL Radiology
--('294'),--MD-RONC Radiation Oncology
--('296'),--MD-SURG Surgery
--('309') --MD-UROL Urology
('216') --MD-PEDT Pediatrics
--('0') --(No SOM Dept Defined)
--('57') --MD-INMD Internal Medicine
--('296') --MD-SURG Surgery
--('47') --MD-ANES Anesthesiology
;

DECLARE @UPG_PRACTICE_REGION TABLE (UPGPracticeRegionId SMALLINT)

INSERT INTO @UPG_PRACTICE_REGION
(
    UPGPracticeRegionId
)
VALUES
--(0),--(No Region Defined)
--(1),--MC-CPG
--(2),--UPG-Community Division
--(4),--UPG-CPG Novant Specialty
--(5),--UPG-CPG Specialty
--(6),--UPG-RPC North
--(7) --UPG-RPC South
(0) --(No Region Defined)
;

DECLARE @PROV_TYPE TABLE (Provider_Type VARCHAR(40))

INSERT INTO @PROV_TYPE
(
    Provider_Type
)
VALUES
--('(No Prov Type Defined)'),
--('Anesthesiologist'),
--('Clinical Social Worker'),
--('Community Provider'),
--('Counselor'),
--('Doctor of Philosophy'),
--('Fellow'),
--('Financial Counselor'),
--('Genetic Counselor'),
--('Licensed Clinical Social Worker'),
--('Licensed Nurse'),
--('Nurse Practitioner'),
--('Nursing Student'),
--('Occupational Therapist'),
--('Pathologist'),
--('Pharmacist'),
--('Physical Therapist'),
--('Physician'),
--('Physician Assistant'),
--('Psychologist'),
--('Registered Dietitian'),
--('Registered Nurse'),
--('Resident'),
--('Scribe'),
--('Speech and Language Pathologist'),
--('Technician')
--('Physician')
--,('Physician Assistant')
--,('Fellow')
--,('Nurse Practitioner')
('(No Prov Type Defined)')
;

DECLARE @DEPARTMENT TABLE (DepartmentId NUMERIC(18,0))

INSERT INTO @DEPARTMENT
(
    DepartmentId
)
VALUES
--(0),--All
--(10280004),--AUBL PEDIATRICS, (No SL Defined), UVA Pediatrics Augusta
--(10280004),--AUBL PEDIATRICS, Womens and Childrens, UVA Pediatrics Augusta
--(10280016),--AUBL PEDS DEVELOPMENT, (No SL Defined), UVA Pediatrics Augusta
--(10280016),--AUBL PEDS DEVELOPMENT, Womens and Childrens, UVA Pediatrics Augusta
--(10280005),--AUBL UVA CANC CTR AUG, Oncology, (No UPG PG Defined)
--(10280010),--AUBL UVA PEDS RESP, Womens and Childrens, UVA Pediatric Pulmonology Riverside
--(10280001),--AUBL UVA SPTY CARE, (No SL Defined), UVA Specialty Care Augusta
--(10280015),--AUBL VASCULAR SURGERY, (No SL Defined), UVA Specialty Care Augusta
--(10353003),--AUPN SP CARE ENDO, (No SL Defined), UVA Specialty Care Pinnacle
--(10353001),--AUPN SP CARE NEPH, (No SL Defined), UVA Specialty Care Pinnacle
--(10353002),--AUPN SP CARE PFT, (No SL Defined), UVA Specialty Care Pinnacle
--(10353004),--AUPN SP CARE PULM, (No SL Defined), UVA Specialty Care Pinnacle
--(10353005),--AUPN SP CARE RHEU, (No SL Defined), UVA Specialty Care Pinnacle
--(10353006),--AUPN SP CARE URO, (No SL Defined), UVA Specialty Care Pinnacle
--(10271002),--BRLH NEUROLOGY, (No SL Defined), (No UPG PG Defined)
--(10271002),--BRLH NEUROLOGY, Womens and Childrens, (No UPG PG Defined)
--(10271003),--BRLH PEDS ORTHO, (No SL Defined), (No UPG PG Defined)
--(10271003),--BRLH PEDS ORTHO, Womens and Childrens, (No UPG PG Defined)
--(10205001),--COL COLONNADES MED ASC, Primary Care, (No UPG PG Defined)
--(10390001),--CPBE COMMONWEALTH MED, (No SL Defined), UVA Primary Care Commonwealth Medical
--(10390001),--CPBE COMMONWEALTH MED, Womens and Childrens, UVA Primary Care Commonwealth Medical
--(10390004),--CPBE DERMATOLOGY, (No SL Defined), UVA Primary Care Commonwealth Medical
--(10390004),--CPBE DERMATOLOGY, Womens and Childrens, UVA Primary Care Commonwealth Medical
--(10390005),--CPBE ENDOCRINE, (No SL Defined), UVA Primary Care Commonwealth Medical
--(10275001),--CPBR FAMILY CARE, (No SL Defined), UVA Primary Care Family Care of Culpeper
--(10275001),--CPBR FAMILY CARE, Womens and Childrens, UVA Primary Care Family Care of Culpeper
--(10275002),--CPBR PEDIATRICS, (No SL Defined), UVA Pediatrics Culpeper
--(10275002),--CPBR PEDIATRICS, Womens and Childrens, UVA Pediatrics Culpeper
--(10369001),--CPSA CARDIOLOGY, (No SL Defined), (No UPG PG Defined)
--(10369012),--CPSA VASCULAR SURGERY, (No SL Defined), (No UPG PG Defined)
--(10295005),--CPSE CH CANC CTR, (No SL Defined), (No UPG PG Defined)
--(10295008),--CPSE RAD ONC CL, (No SL Defined), (No UPG PG Defined)
--(10293033),--CPSN UVA NEUROSURGERY, (No SL Defined), UVA Orthopedics a Department of Novant Health UVA Health
--(10293031),--CPSN UVA ORTHO SPINE, (No SL Defined), UVA Orthopedics a Department of Novant Health UVA Health
--(10293029),--CPSN UVA ORTHOPEDICS, (No SL Defined), UVA Orthopedics a Department of Novant Health UVA Health
--(10293026),--CPSN UVA SURG BREAST, (No SL Defined), UVA Surgical Services a Department of Novant Health UVA Health
--(10293027),--CPSN UVA UROLOGY, (No SL Defined), UVA Surgical Services a Department of Novant Health UVA Health
--(10276004),--CPSS PEDIATRICS, (No SL Defined), UVA Pediatrics Culpeper
--(10276004),--CPSS PEDIATRICS, Womens and Childrens, UVA Pediatrics Culpeper
--(10276008),--CPSS UVA OBGYN, (No SL Defined), UVA Obstetrics and Gynecology a Department of Novant Health UVA Health
--(10274001),--CPST FAMILY PRACTICE, (No SL Defined), UVA Primary Care Culpeper Family Practice
--(10274001),--CPST FAMILY PRACTICE, Womens and Childrens, UVA Primary Care Culpeper Family Practice
--(10337001),--CVAB PMR WORKMED, Medical Subspecialties, (No UPG PG Defined)
--(10383001),--CVJD UROLOGY REPROMED, (No SL Defined), (No UPG PG Defined)
--(10341009),--CVPE MED NEPHROLOGY, Primary Care, (No UPG PG Defined)
--(10341004),--CVPE PMR, Primary Care, (No UPG PG Defined)
--(10341007),--CVPE PRIMARY CARE CL, Primary Care, (No UPG PG Defined)
--(10341007),--CVPE PRIMARY CARE CL, Womens and Childrens, (No UPG PG Defined)
--(10341001),--CVPE UVA RHEU PANTOPS, (No SL Defined), UVA Rheumatology Pantops
--(10306004),--CVPJ PLASTIC SURGERY, Oncology, (No UPG PG Defined)
--(10306001),--CVPJ UVA CANC CTR PTP, Oncology, (No UPG PG Defined)
--(10339001),--CVPM MED WESTMINSTER, (No SL Defined), (No UPG PG Defined)
--(10338004),--CVPP BREAST HEM ONC, Oncology, (No UPG PG Defined)
--(10338007),--CVPP BREAST SURG ONC, Oncology, (No UPG PG Defined)
--(10338001),--CVPP OTOLARYNGOLOGY, (No SL Defined), (No UPG PG Defined)
--(10387007),--CVSM PEDIATRICS, (No SL Defined), UVA Primary Care Riverside
--(10387007),--CVSM PEDIATRICS, Womens and Childrens, UVA Primary Care Riverside
--(10387002),--CVSM PEDS RESPIRATORY, (No SL Defined), UVA Pediatric Pulmonology Riverside
--(10387002),--CVSM PEDS RESPIRATORY, Womens and Childrens, UVA Pediatric Pulmonology Riverside
--(10387001),--CVSM PRIMARY CARE, (No SL Defined), UVA Primary Care Riverside
--(10387001),--CVSM PRIMARY CARE, Womens and Childrens, UVA Primary Care Riverside
--(10387008),--CVSM PULMONARY FUNC, Womens and Childrens, UVA Pediatric Pulmonology Riverside
--(10399001),--CVSN ENDOCRINE, (No SL Defined), UVA Endocrinology Pantops
--(10299002),--CVSR ENDOCRINE, (No SL Defined), (No UPG PG Defined)
--(10405001),--CVWK PRIMARY CARE, (No SL Defined), (No UPG PG Defined)
--(99999016),--DOCUMENTATION         , (No SL Defined), (No UPG PG Defined)
--(10210075),--ECCC ENDOCRINE 2 WEST, Oncology, (No UPG PG Defined)
--(10210055),--ECCC ENDOCRINE EAST, Oncology, (No UPG PG Defined)
--(10210035),--ECCC GYN ONC 2 EAST, Oncology, (No UPG PG Defined)
--(10210014),--ECCC HEM ONC 2 EAST, Oncology, (No UPG PG Defined)
--(10210078),--ECCC HEM ONC 2 WEST, Oncology, (No UPG PG Defined)
--(10210001),--ECCC HEM ONC EAST, Oncology, (No UPG PG Defined)
--(10210002),--ECCC HEM ONC WEST, Oncology, (No UPG PG Defined)
--(10210054),--ECCC NEPHROLOGY WEST, Oncology, (No UPG PG Defined)
--(10210030),--ECCC NEURO WEST, Oncology, (No UPG PG Defined)
--(10210032),--ECCC NSURG WEST, Oncology, (No UPG PG Defined)
--(10210026),--ECCC OTO CL EAST, Oncology, (No UPG PG Defined)
--(10210071),--ECCC OTO SPEECH 2 WEST, Oncology, (No UPG PG Defined)
--(10210027),--ECCC OTO SPEECH EAST, Oncology, (No UPG PG Defined)
--(10210073),--ECCC PALLIATIVE 2 WEST, Oncology, (No UPG PG Defined)
--(10210006),--ECCC PALLIATIVE CLINIC, Oncology, (No UPG PG Defined)
--(10210017),--ECCC PSY CL 1FL, Oncology, (No UPG PG Defined)
--(10210060),--ECCC RAD E&M 2 EAST, Oncology, (No UPG PG Defined)
--(10210045),--ECCC RAD E&M CL WEST, Oncology, (No UPG PG Defined)
--(10210018),--ECCC RAD NUC MED CL, Oncology, (No UPG PG Defined)
--(10210018),--ECCC RAD NUC MED CL, Womens and Childrens, (No UPG PG Defined)
--(10210008),--ECCC RAD NUCLEAR, (No SL Defined), (No UPG PG Defined)
--(10210013),--ECCC RAD ONC CLINIC, Oncology, (No UPG PG Defined)
--(10210016),--ECCC SUPPORT SVCS 1FL, Oncology, (No UPG PG Defined)
--(10210022),--ECCC SURG ONC EAST, Oncology, (No UPG PG Defined)
--(10210029),--ECCC SURG ONC WEST, Oncology, (No UPG PG Defined)
--(10210064),--ECCC URGENT SYMPTOM CL, Oncology, (No UPG PG Defined)
--(10210051),--ECCC UROLOGY EAST, Oncology, (No UPG PG Defined)
--(10210052),--ECCC UROLOGY WEST, Oncology, (No UPG PG Defined)
--(10359001),--ECON ECONSULT, (No SL Defined), (No UPG PG Defined)
--(10211006),--F415 ENDOCRINE, Medical Subspecialties, (No UPG PG Defined)
--(10211030),--F415 ENDOCRINE OTO, Surgical Subspecialties, (No UPG PG Defined)
--(10211013),--F415 MED PITUITARY, Medical Subspecialties, (No UPG PG Defined)
--(10211021),--F415 NEUROSURGERY, Neurosciences and Behavioral Health, (No UPG PG Defined)
--(10211010),--F415 NSRG SPINE CTR, Neurosciences and Behavioral Health, (No UPG PG Defined)
--(10211009),--F415 ORTHO HAND CENTER, Musculoskeletal, (No UPG PG Defined)
--(10211009),--F415 ORTHO HAND CENTER, Womens and Childrens, (No UPG PG Defined)
--(10211018),--F415 ORTHO SPINE CTR, Neurosciences and Behavioral Health, (No UPG PG Defined)
--(10211018),--F415 ORTHO SPINE CTR, Womens and Childrens, (No UPG PG Defined)
--(10211005),--F415 OTOLARYNGOLOGY, Surgical Subspecialties, (No UPG PG Defined)
--(10211005),--F415 OTOLARYNGOLOGY, Womens and Childrens, (No UPG PG Defined)
--(10211019),--F415 PMR SPINE CTR, Neurosciences and Behavioral Health, (No UPG PG Defined)
--(10211019),--F415 PMR SPINE CTR, Womens and Childrens, (No UPG PG Defined)
--(10211003),--F415 RHEUMATOLOGY, Medical Subspecialties, (No UPG PG Defined)
--(10211027),--F415 SPEECH AUDIOLOGY, Womens and Childrens, (No UPG PG Defined)
--(10211028),--F415 SPEECH OTO, Musculoskeletal, (No UPG PG Defined)
--(10211028),--F415 SPEECH OTO, Womens and Childrens, (No UPG PG Defined)
--(10211004),--F415 UNIV PHYS, Primary Care, (No UPG PG Defined)
--(10212016),--F500 CARDIOLOGY, Heart and Vascular, (No UPG PG Defined)
--(10212016),--F500 CARDIOLOGY, Womens and Childrens, (No UPG PG Defined)
--(10212018),--F500 CONT PELVIC SGY, Surgical Subspecialties, (No UPG PG Defined)
--(10212019),--F500 ENDOCRINOLOGY, Heart and Vascular, (No UPG PG Defined)
--(10212017),--F500 UROLOGY, Surgical Subspecialties, (No UPG PG Defined)
--(10213003),--F515 OCCUPATIONAL THER, (No SL Defined), UVA Physical and Occupational Therapy
--(10213002),--F515 PHYSICAL THERAPY, (No SL Defined), UVA Physical and Occupational Therapy
--(10213004),--F515 SPEECH NEUROREHAB, (No SL Defined), UVA Physical and Occupational Therapy
--(10214017),--F545 OCCUPATIONAL THER, (No SL Defined), UVA Physical and Occupational Therapy
--(10214002),--F545 ORTHOPAEDICS FL 1, Musculoskeletal, (No UPG PG Defined)
--(10214001),--F545 PAIN MANAGEMENT, Musculoskeletal, (No UPG PG Defined)
--(10214001),--F545 PAIN MANAGEMENT, Womens and Childrens, (No UPG PG Defined)
--(10214003),--F545 PHYSICAL MED&RHB, Musculoskeletal, (No UPG PG Defined)
--(10214003),--F545 PHYSICAL MED&RHB, Womens and Childrens, (No UPG PG Defined)
--(10214016),--F545 PHYSICAL THERAPY, (No SL Defined), UVA Physical and Occupational Therapy
--(10214011),--F545 SPORTS MED FL 1, Musculoskeletal, (No UPG PG Defined)
--(10214011),--F545 SPORTS MED FL 1, Womens and Childrens, (No UPG PG Defined)
--(10214014),--F545 SPORTS MED FL 3, Musculoskeletal, (No UPG PG Defined)
--(10395002),--GAJM RAD CL & VEIN CL, (No SL Defined), UVA Radiology Vein and Vascular Care Gainesville
--(10216006),--HBMA BEH MED, (No SL Defined), UVA Pediatrics Harrisonburg
--(10216006),--HBMA BEH MED, Womens and Childrens, UVA Pediatrics Harrisonburg
--(10216005),--HBMA PEDIATRICS, Womens and Childrens, UVA Pediatrics Harrisonburg
--(10376004),--HYHB NEUROSURGERY, (No SL Defined), UVA Neurosurgery Haymarket
--(10248001),--JABA JEFFERSON ABA, Primary Care, (No UPG PG Defined)
--(10217007),--JPA PSY THERAPY UMA, Primary Care, (No UPG PG Defined)
--(10217002),--JPA SLEEP LAB, Medical Subspecialties, UVA Pediatric Pulmonology Riverside
--(10217002),--JPA SLEEP LAB, Womens and Childrens, UVA Pediatric Pulmonology Riverside
--(10217006),--JPA TOXICOLOGY CL, Womens and Childrens, (No UPG PG Defined)
--(10217003),--JPA UNIV MED ASSOCS, Primary Care, (No UPG PG Defined)
--(10267003),--LBRA PEDS GENETIC, Womens and Childrens, (No UPG PG Defined)
--(10277001),--LGGH WILDERNESS MEDCTR, (No SL Defined), UVA Primary Care Locust Grove
--(10277001),--LGGH WILDERNESS MEDCTR, Womens and Childrens, UVA Primary Care Locust Grove
--(10220001),--LOID MEDICAL ASSOC, (No SL Defined), UVA Primary Care Louisa
--(10220001),--LOID MEDICAL ASSOC, Womens and Childrens, UVA Primary Care Louisa
--(10404001),--MGST PEDIATRICS, (No SL Defined), UVA Pediatric McGaheysville
--(10227002),--MOSR RAD ONC CLINIC, Oncology, (No UPG PG Defined)
--(10208001),--NGCR FAMILY MEDICINE, Primary Care, (No UPG PG Defined)
--(10208001),--NGCR FAMILY MEDICINE, Womens and Childrens, (No UPG PG Defined)
--(10234002),--NLSC FAM MED PSYCH, Primary Care, (No UPG PG Defined)
--(10234002),--NLSC FAM MED PSYCH, Womens and Childrens, (No UPG PG Defined)
--(10234001),--NLSC FAMILY MEDICINE, Primary Care, (No UPG PG Defined)
--(10234001),--NLSC FAMILY MEDICINE, Womens and Childrens, (No UPG PG Defined)
--(10228010),--NRDG ADULT PSYCHIATRY, Neurosciences and Behavioral Health, (No UPG PG Defined)
--(10228007),--NRDG ALLERGY, Medical Subspecialties, (No UPG PG Defined)
--(10228007),--NRDG ALLERGY, Womens and Childrens, (No UPG PG Defined)
--(10228012),--NRDG COMMUNITY MED, (No SL Defined), (No UPG PG Defined)
--(10228012),--NRDG COMMUNITY MED, Womens and Childrens, (No UPG PG Defined)
--(10228003),--NRDG MIDLIFE, Womens and Childrens, (No UPG PG Defined)
--(10228009),--NRDG NUTRITION, (No SL Defined), (No UPG PG Defined)
--(10228009),--NRDG NUTRITION, Womens and Childrens, (No UPG PG Defined)
--(10228026),--NRDG OPHTHALMOLOGY FL2, Surgical Subspecialties, (No UPG PG Defined)
--(10228011),--NRDG PEDIATRICS, Womens and Childrens, (No UPG PG Defined)
--(10228021),--NRDG RAD CL & VEIN CL, (No SL Defined), (No UPG PG Defined)
--(10228001),--NRDG UNIV PHYS WOMEN, Womens and Childrens, (No UPG PG Defined)
--(10229001),--OIVW PSY CHILD&FAMILY, Neurosciences and Behavioral Health, (No UPG PG Defined)
--(10229001),--OIVW PSY CHILD&FAMILY, Womens and Childrens, (No UPG PG Defined)
--(10230009),--ORUL MED CARD, Primary Care, (No UPG PG Defined)
--(10230005),--ORUL MED NEPHROLOGY, Primary Care, (No UPG PG Defined)
--(10230002),--ORUL PEDIATRICS, Womens and Childrens, (No UPG PG Defined)
--(10230012),--ORUL PEDS DEVELOPMENT, Womens and Childrens, (No UPG PG Defined)
--(10230004),--ORUL UNIV PHYSICIANS, Primary Care, (No UPG PG Defined)
--(10377001),--PAMS PRIMARY CARE, (No SL Defined), UVA Primary Care Lake Monticello
--(10377001),--PAMS PRIMARY CARE, Womens and Childrens, UVA Primary Care Lake Monticello
--(10361004),--RMBR PEDS GENETICS CL, (No SL Defined), UVA Pediatric Cardiology Richmond
--(10361004),--RMBR PEDS GENETICS CL, Womens and Childrens, UVA Pediatric Cardiology Richmond
--(10374001),--ROFR KIDNEY TRANSPLANT, (No SL Defined), (No UPG PG Defined)
--(10260003),--RONK UROLOGY PEDS, (No SL Defined), (No UPG PG Defined)
--(10260003),--RONK UROLOGY PEDS, Womens and Childrens, (No UPG PG Defined)
--(10236001),--SDGR FAMILY MEDICINE, (No SL Defined), UVA Primary Care Stuarts Draft
--(10236001),--SDGR FAMILY MEDICINE, Womens and Childrens, UVA Primary Care Stuarts Draft
--(10237001),--TSDE PROSTHETICS/ORTCS, (No SL Defined), (No UPG PG Defined)
--(10261001),--TZCD NEUROLOGY, (No SL Defined), (No UPG PG Defined)
--(10261001),--TZCD NEUROLOGY, Womens and Childrens, (No UPG PG Defined)
--(10279001),--UHMR ATHLETIC TRNG RM, Medical Subspecialties, (No UPG PG Defined)
--(10243917),--UVA ANESTHESIA MD, (No SL Defined), (No UPG PG Defined)
--(99999003),--UVA REG DIETITIANS, (No SL Defined), (No UPG PG Defined)
--(99999002),--UVA SOCIAL WORK, (No SL Defined), (No UPG PG Defined)
--(10354012),--UVBB DEV PEDS CL FL 4, Womens and Childrens, (No UPG PG Defined)
--(10354044),--UVBB DEV PEDS CL FL 5, Womens and Childrens, (No UPG PG Defined)
--(10354049),--UVBB DEV PEDS CL FL 6, Womens and Childrens, (No UPG PG Defined)
--(10354088),--UVBB GEN PEDIATRIC FL4, Womens and Childrens, (No UPG PG Defined)
--(10354019),--UVBB GEN PEDIATRIC FL6, Womens and Childrens, (No UPG PG Defined)
--(10354035),--UVBB MATERNAL FETAL CL, Womens and Childrens, (No UPG PG Defined)
--(10354047),--UVBB MED CARD CONGEN, Womens and Childrens, (No UPG PG Defined)
--(10354037),--UVBB NEUROLOGY PED FL5, Womens and Childrens, (No UPG PG Defined)
--(10354034),--UVBB NEUROSURG PEDS CL, Womens and Childrens, (No UPG PG Defined)
--(10354071),--UVBB NUTRITION FL 5, Womens and Childrens, (No UPG PG Defined)
--(10354031),--UVBB OCCUPTNL THER FL4, Musculoskeletal, (No UPG PG Defined)
--(10354031),--UVBB OCCUPTNL THER FL4, Womens and Childrens, (No UPG PG Defined)
--(10354066),--UVBB OCCUPTNL THER FL5, Womens and Childrens, (No UPG PG Defined)
--(10354901),--UVBB OPSC PRE, (No SL Defined), (No UPG PG Defined)
--(10354028),--UVBB ORTHO PEDS CL, Womens and Childrens, (No UPG PG Defined)
--(10354092),--UVBB OTOL PEDS FL5, Womens and Childrens, (No UPG PG Defined)
--(10354036),--UVBB OTOL PEDS FL6, Womens and Childrens, (No UPG PG Defined)
--(10354090),--UVBB PEDS ALLERGY FL5, Womens and Childrens, (No UPG PG Defined)
--(10354089),--UVBB PEDS ALLERGY FL6, Womens and Childrens, (No UPG PG Defined)
--(10354018),--UVBB PEDS CARD CL FL 6, Womens and Childrens, (No UPG PG Defined)
--(10354043),--UVBB PEDS DIABETES CL, Womens and Childrens, (No UPG PG Defined)
--(10354075),--UVBB PEDS ENDOCRINE F5, Womens and Childrens, (No UPG PG Defined)
--(10354021),--UVBB PEDS ENDOCRINE F6, Womens and Childrens, (No UPG PG Defined)
--(10354014),--UVBB PEDS GASTRO CL, Womens and Childrens, (No UPG PG Defined)
--(10354017),--UVBB PEDS GENETICS CL, Womens and Childrens, (No UPG PG Defined)
--(10354084),--UVBB PEDS HEM ONC, Womens and Childrens, (No UPG PG Defined)
--(10354023),--UVBB PEDS ID CL, Womens and Childrens, (No UPG PG Defined)
--(10354039),--UVBB PEDS NEONATE FL 5, Womens and Childrens, (No UPG PG Defined)
--(10354042),--UVBB PEDS PALLIATIVE, Womens and Childrens, (No UPG PG Defined)
--(10354025),--UVBB PEDS PULM FL6, Womens and Childrens, (No UPG PG Defined)
--(10354024),--UVBB PEDS RENAL CL FL5, Womens and Childrens, (No UPG PG Defined)
--(10354013),--UVBB PEDS RHEUM CL, Womens and Childrens, (No UPG PG Defined)
--(10354016),--UVBB PEDS SURGERY CL, Womens and Childrens, (No UPG PG Defined)
--(10354055),--UVBB PEDS TRANSPLANT, Womens and Childrens, (No UPG PG Defined)
--(10354032),--UVBB PHYSICAL THER FL4, Musculoskeletal, (No UPG PG Defined)
--(10354032),--UVBB PHYSICAL THER FL4, Womens and Childrens, (No UPG PG Defined)
--(10354068),--UVBB PHYSICAL THER FL5, Womens and Childrens, (No UPG PG Defined)
--(10354027),--UVBB PSYCH PEDS CL, Womens and Childrens, (No UPG PG Defined)
--(10354033),--UVBB SPEECH PATH FL 4, Musculoskeletal, (No UPG PG Defined)
--(10354033),--UVBB SPEECH PATH FL 4, Womens and Childrens, (No UPG PG Defined)
--(10354064),--UVBB SPEECH PATH FL 5, Womens and Childrens, (No UPG PG Defined)
--(10354005),--UVBB TEEN YOUNG AD CTR, Womens and Childrens, (No UPG PG Defined)
--(10354029),--UVBB UROLOGY PEDS FL 4, Womens and Childrens, (No UPG PG Defined)
--(10240006),--UVBR BEH MED, Neurosciences and Behavioral Health, (No UPG PG Defined)
--(10240006),--UVBR BEH MED, Womens and Childrens, (No UPG PG Defined)
--(10250001),--UVBR NEUROSURGERY, Neurosciences and Behavioral Health, (No UPG PG Defined)
--(10241002),--UVDV NEUROPSYCH TEST, Neurosciences and Behavioral Health, (No UPG PG Defined)
--(10241001),--UVDV PLASTIC SURGERY, Surgical Subspecialties, (No UPG PG Defined)
--(10241001),--UVDV PLASTIC SURGERY, Womens and Childrens, (No UPG PG Defined)
--(10381002),--UVEC RAD ULTRASOUND, (No SL Defined), (No UPG PG Defined)
--(10243051),--UVHE 3 CENTRAL, Medical Subspecialties, (No UPG PG Defined)
--(10243052),--UVHE 3 EAST, Medical Subspecialties, (No UPG PG Defined)
--(10243053),--UVHE 3 WEST, Medical Subspecialties, (No UPG PG Defined)
--(10243055),--UVHE 4 EAST, Heart and Vascular, (No UPG PG Defined)
--(10243059),--UVHE 5 EAST, Neurosciences and Behavioral Health, (No UPG PG Defined)
--(10243124),--UVHE 5 SOUTH, Medical Subspecialties, (No UPG PG Defined)
--(10243062),--UVHE 6 EAST, Musculoskeletal, (No UPG PG Defined)
--(10243063),--UVHE 6 WEST, Womens and Childrens, (No UPG PG Defined)
--(10243064),--UVHE 7 CENTRAL, Womens and Childrens, (No UPG PG Defined)
--(10243065),--UVHE 7 WEST, Womens and Childrens, (No UPG PG Defined)
--(10243068),--UVHE 8 WEST, Oncology, (No UPG PG Defined)
--(10243012),--UVHE CARDIAC CATH LAB, Heart and Vascular, (No UPG PG Defined)
--(10243112),--UVHE CARDIAC SURGERY, Heart and Vascular, (No UPG PG Defined)
--(10243112),--UVHE CARDIAC SURGERY, Womens and Childrens, (No UPG PG Defined)
--(10243003),--UVHE DIGESTIVE HEALTH, Digestive Health, (No UPG PG Defined)
--(10243911),--UVHE ENDOBRONC PROC, Digestive Health, (No UPG PG Defined)
--(10243020),--UVHE GI MOTILITY, Digestive Health, (No UPG PG Defined)
--(10243038),--UVHE MEDICAL ICU, Medical Subspecialties, (No UPG PG Defined)
--(10243025),--UVHE NEURORADIOLOGY, Womens and Childrens, (No UPG PG Defined)
--(10243044),--UVHE NEWBORN NURSERY, Womens and Childrens, (No UPG PG Defined)
--(10243109),--UVHE PEDS NEONATE NICU, Womens and Childrens, (No UPG PG Defined)
--(10243015),--UVHE RAD ANGIOGRAPHY, (No SL Defined), (No UPG PG Defined)
--(10243030),--UVHE RAD DIAG E&M, (No SL Defined), (No UPG PG Defined)
--(10243030),--UVHE RAD DIAG E&M, Womens and Childrens, (No UPG PG Defined)
--(10243087),--UVHE SURG DIGESTIVE HL, Digestive Health, (No UPG PG Defined)
--(10243126),--UVHE URGENT VIDEO CL, (No SL Defined), (No UPG PG Defined)
--(10243126),--UVHE URGENT VIDEO CL, Womens and Childrens, (No UPG PG Defined)
--(10243104),--UVHE VASC SURG, Heart and Vascular, (No UPG PG Defined)
--(10379900),--UVML ENDOBRONC PROC, Digestive Health, (No UPG PG Defined)
--(10239004),--UVMS BREAST, Oncology, (No UPG PG Defined)
--(10239026),--UVMS ENDO TRANSPLANT, Transplant, (No UPG PG Defined)
--(10239024),--UVMS ID TRANSPLANT, Transplant, (No UPG PG Defined)
--(10239003),--UVMS NEPHROLOGY, Medical Subspecialties, (No UPG PG Defined)
--(10239010),--UVMS PSYCHIATRY, Neurosciences and Behavioral Health, (No UPG PG Defined)
--(10239020),--UVMS SURG TRANSPLANT, Transplant, (No UPG PG Defined)
--(10239015),--UVMS SURGERY, Surgical Subspecialties, (No UPG PG Defined)
--(10239015),--UVMS SURGERY, Womens and Childrens, (No UPG PG Defined)
--(10239019),--UVMS TRANSPLANT KIDNEY, Transplant, (No UPG PG Defined)
--(10239017),--UVMS TRANSPLANT LIVER, Transplant, (No UPG PG Defined)
--(10239018),--UVMS TRANSPLANT LUNG, Transplant, (No UPG PG Defined)
--(10242008),--UVPC CARDIOLOGY, Heart and Vascular, (No UPG PG Defined)
--(10242005),--UVPC DERMATOLOGY, Surgical Subspecialties, (No UPG PG Defined)
--(10242005),--UVPC DERMATOLOGY, Womens and Childrens, (No UPG PG Defined)
--(10242051),--UVPC DIGESTIVE HEALTH, Digestive Health, (No UPG PG Defined)
--(10242012),--UVPC FAMILY MEDICINE, Primary Care, (No UPG PG Defined)
--(10242012),--UVPC FAMILY MEDICINE, Womens and Childrens, (No UPG PG Defined)
--(10242007),--UVPC NEUROLOGY, Neurosciences and Behavioral Health, (No UPG PG Defined)
--(10242007),--UVPC NEUROLOGY, Womens and Childrens, (No UPG PG Defined)
--(10242031),--UVPC NEUROPSYCH, Neurosciences and Behavioral Health, (No UPG PG Defined)
--(10242044),--UVPC NEUROSURGERY, Neurosciences and Behavioral Health, (No UPG PG Defined)
--(10242006),--UVPC OB-GYN, Womens and Childrens, (No UPG PG Defined)
--(10242042),--UVPC PED NEUROPSYCH, Womens and Childrens, (No UPG PG Defined)
--(10242041),--UVPC PEDS NEUROLOGY, Womens and Childrens, (No UPG PG Defined)
--(10242045),--UVPC PSY CL FMED, Primary Care, (No UPG PG Defined)
--(10242045),--UVPC PSY CL FMED, Womens and Childrens, (No UPG PG Defined)
--(10242018),--UVPC PULMONARY, Medical Subspecialties, (No UPG PG Defined)
--(10242001),--UVPC TELEMEDICINE, (No SL Defined), (No UPG PG Defined)
--(10242001),--UVPC TELEMEDICINE, Womens and Childrens, (No UPG PG Defined)
--(10244024),--UVWC ENDOCRINE SURG, Surgical Subspecialties, (No UPG PG Defined)
--(10244016),--UVWC INFECTIOUS DIS, Medical Subspecialties, (No UPG PG Defined)
--(10244016),--UVWC INFECTIOUS DIS, Womens and Childrens, (No UPG PG Defined)
--(10244029),--UVWC OBGYN ID, Medical Subspecialties, (No UPG PG Defined)
--(10244004),--UVWC OPHTHALMOLOGY, Surgical Subspecialties, (No UPG PG Defined)
--(10244026),--UVWC PSYCHIATRY ID, Medical Subspecialties, (No UPG PG Defined)
--(10246005),--WALL ENDO MED FAMILY, Primary Care, (No UPG PG Defined)
--(10246006),--WALL FAM MED PSYCH, Primary Care, (No UPG PG Defined)
--(10246006),--WALL FAM MED PSYCH, Womens and Childrens, (No UPG PG Defined)
--(10246001),--WALL FAMILY MEDICINE, Primary Care, (No UPG PG Defined)
--(10246001),--WALL FAMILY MEDICINE, Womens and Childrens, (No UPG PG Defined)
--(10246004),--WALL MED DH FAM MED, Primary Care, (No UPG PG Defined)
--(10403001),--WARA PRIMARY CARE, (No SL Defined), UVA Primary Care Waynesboro
--(10403001),--WARA PRIMARY CARE, Womens and Childrens, UVA Primary Care Waynesboro
--(10396006),--WCCC PEDS ENDOCRINE CL, (No SL Defined), UVA Pediatric Specialty Care Winchester
--(10396006),--WCCC PEDS ENDOCRINE CL, Womens and Childrens, UVA Pediatric Specialty Care Winchester
--(10256001),--WSRS NEUROLOGY, (No SL Defined), (No UPG PG Defined)
--(10256001),--WSRS NEUROLOGY, Womens and Childrens, (No UPG PG Defined)
--(10348003),--ZCSC CARDIOLOGY, (No SL Defined), UVA Primary and Specialty Care Zion Crossroads
--(10348005),--ZCSC ENDOCRINE, (No SL Defined), UVA Primary and Specialty Care Zion Crossroads
--(10348007),--ZCSC NEPHROLOGY, (No SL Defined), UVA Primary and Specialty Care Zion Crossroads
--(10348008),--ZCSC NEUROLOGY, (No SL Defined), UVA Primary and Specialty Care Zion Crossroads
--(10348023),--ZCSC ORTHO SPINE FL 1, (No SL Defined), UVA Primary and Specialty Care Zion Crossroads
--(10348022),--ZCSC ORTHO SPORTS MED, (No SL Defined), UVA Primary and Specialty Care Zion Crossroads
--(10348027),--ZCSC PEDS ORTHO, Womens and Childrens, UVA Primary and Specialty Care Zion Crossroads
--(10348014),--ZCSC PRIMARY CARE, (No SL Defined), UVA Primary and Specialty Care Zion Crossroads
--(10348014),--ZCSC PRIMARY CARE, Womens and Childrens, UVA Primary and Specialty Care Zion Crossroads
--(10348011),--ZCSC PULMONARY, (No SL Defined), UVA Primary and Specialty Care Zion Crossroads
--(10348040),--ZCSC RAD E&M, (No SL Defined), UVA Primary and Specialty Care Zion Crossroads
--(10348015),--ZCSC UROLOGY, (No SL Defined), UVA Primary and Specialty Care Zion Crossroads
--(10348028) --ZZZZ ZC RX, (No SL Defined), (No UPG PG Defined)
(0) --All
;

DECLARE @ENCOUNTER_STATUS TABLE (EncounterStatusCategory VARCHAR(100))

INSERT INTO @ENCOUNTER_STATUS
(
    EncounterStatusCategory
)
VALUES
--('(No Enc Status Defined)'),
--('Complete'),
--('In Progress'),
--('Invalid'),
--('Possible')
('(No Enc Status Defined)')
;

DECLARE @EVENT_TYPE TABLE (EventType VARCHAR(100))

INSERT INTO @EVENT_TYPE
(
    EventType
)
VALUES
--('(No Event Type Defined)'),
--('Circleback'),
--('Contracted Telemedicine Scheduled'),
--('DTC Prof Remote Scheduled'),
--('DTC Telemedicine Scheduled'),
--('EConsult'),
--('Other'),
--('Virtual Urgent Care')
('(No Event Type Defined)')
;

DECLARE @COMM_TYPE TABLE (CommunicationType VARCHAR(100))

INSERT INTO @COMM_TYPE
(
    CommunicationType
)
VALUES
--('(No Communication Type Defined)'),
--('EConsult'),
--('Phone'),
--('Phone or Video'),
--('Video')
('(No Communication Type Defined)')
;

--DECLARE @ServiceLine TABLE (ServiceLineName VARCHAR(150))

--INSERT INTO @ServiceLine
--(
--    ServiceLineName
--)
--VALUES
----('Digestive Health'),
----('Heart and Vascular'),
----('Medical Subspecialties'),
----('Musculoskeletal'),
----('Neurosciences and Behavioral Health'),
----('Oncology'),
----('Ophthalmology'),
----('Primary Care'),
----('Surgical Subspecialties'),
----('Transplant'),
----('Womens and Childrens')
----('Medical Subspecialties')
--('Digestive Health')
----('Womens and Childrens')
--;

--DECLARE @StaffResource TABLE (Resource_Type VARCHAR(8))

--INSERT INTO @StaffResource
--(
--    Resource_Type
--)
--VALUES
-- ('Person')
--,('Resource')
-- --('Person')
-- --('Resource)
--;

--DECLARE @Provider TABLE (ProviderId VARCHAR(18))

--INSERT INTO @Provider
--(
--    ProviderId
--)
--VALUES
-- --('28813') -- FISHER, JOSEPH D
-- --('1300563') -- ARTH INF
-- --('41806') -- NORTHRIDGE DEXA
-- --('1301100') -- CT6
-- --('82262') -- CT APPOINTMENT ERC
-- --('40758') -- PAYNE, PATRICIA
-- --('73571') -- LEEDS, JOSEPH THOMAS
-- --,('29303') -- KALANTARI, KAMBIZ
-- --('73725') -- ROSS, BUERLEIN
-- --('41013') -- MANN, JAMES A
-- ('85744') -- CORBETT, SUSAN
--;

--DECLARE @SOMDivision TABLE (SOMDivisionId int)

--INSERT INTO @SOMDivision
--(
--    SOMDivisionId
--)
--VALUES
--(0)--,--(All)
----(14),--40445 MD-MICR Microbiology
----(22),--40450 MD-MPHY Mole Phys & Biophysics
----(30),--40415 MD-PBHS Public Health Sciences Admin
----(48),--40700 MD-ANES Anesthesiology
----(50),--40705 MD-DENT Dentistry
----(52),--40710 MD-DERM Dermatology
----(54),--40715 MD-EMED Emergency Medicine
----(56),--40720 MD-FMED Family Medicine
----(58),--40725 MD-INMD Int Med, Admin
----(60),--40730 MD-INMD Allergy
----(66),--40735 MD-INMD CV Medicine
----(68),--40745 MD-INMD Endocrinology
----(72),--40755 MD-INMD Gastroenterology
----(74),--40760 MD-INMD Gen, Geri, Pall, Hosp
----(76),--40761 MD-INMD Hospital Medicine
----(80),--40770 MD-INMD Hem/Onc
----(82),--40771 MD-INMD Community Oncology
----(84),--40775 MD-INMD Infectious Dis
----(86),--40780 MD-INMD Nephrology
----(88),--40785 MD-INMD Pulmonary
----(90),--40790 MD-INMD Rheumatology
----(98),--40746 MD-INMD Advanced Diabetes Mgt
----(101),--40800 MD-NERS Admin
----(111),--40820 MD-NERS CV Disease
----(113),--40830 MD-NERS Deg Spinal Dis
----(115),--40835 MD-NERS Gamma Knife
----(119),--40816 MD-NERS Minimally Invasive Spine
----(121),--40840 MD-NERS Multiple Neuralgia
----(123),--40825 MD-NERS Neuro-Onc
----(127),--40810 MD-NERS Pediatric
----(129),--40849 MD-NERS Pediatric Pituitary
----(131),--40806 MD-NERS Radiosurgery
----(138),--40850 MD-NEUR Neurology
----(142),--40860 MD-OBGY Ob & Gyn, Admin
----(144),--40865 MD-OBGY Gyn Oncology
----(146),--40870 MD-OBGY Maternal Fetal Med
----(148),--40875 MD-OBGY Reprod Endo/Infertility
----(150),--40880 MD-OBGY Midlife Health
----(152),--40885 MD-OBGY Northridge
----(154),--40890 MD-OBGY Primary Care Center
----(156),--40895 MD-OBGY Gyn Specialties
----(158),--40897 MD-OBGY Midwifery
----(163),--40900 MD-OPHT Ophthalmology
----(166),--40910 MD-ORTP Ortho Surg, Admin
----(168),--40915 MD-ORTP Adult Reconst
----(178),--40930 MD-ORTP Foot/Ankle
----(184),--40940 MD-ORTP Pediatric Ortho
----(188),--40950 MD-ORTP Spine
----(190),--40955 MD-ORTP Sports Med
----(192),--40960 MD-ORTP Hand Surgery
----(194),--40961 MD-ORTP Trauma
----(197),--40970 MD-OTLY Oto, Admin
----(201),--40980 MD-OTLY Audiology
----(208),--41005 MD-PATH Surgical Path
----(210),--41010 MD-PATH Clinical Pathology
----(212),--41015 MD-PATH Neuropathology
----(214),--41017 MD-PATH Research
----(219),--41025 MD-PEDT Pediatrics, Admin
----(223),--41035 MD-PEDT Cardiology
----(225),--41040 MD-PEDT Critical Care
----(227),--41045 MD-PEDT Developmental
----(229),--41050 MD-PEDT Endocrinology
----(233),--41056 MD-PEDT Bariatrics
----(237),--41058 MD-PEDT Adolescent Medicine
----(239),--41060 MD-PEDT Gastroenterology
----(241),--41065 MD-PEDT General Pediatrics
----(243),--41070 MD-PEDT Genetics
----(245),--41075 MD-PEDT Hematology
----(249),--41085 MD-PEDT Infectious Diseases
----(251),--41090 MD-PEDT Neonatology
----(253),--41095 MD-PEDT Nephrology
----(257),--41105 MD-PEDT Pulmonary
----(260),--41130 MD-PHMR Phys Med & Rehab
----(262),--41140 MD-PLSR Plastic Surgery
----(264),--41120 MD-PSCH Psychiatry and NB Sciences
----(270),--41160 MD-RADL Radiology, Admin
----(272),--41161 MD-RADL Community Division
----(274),--41165 MD-RADL Angio/Interv
----(276),--41166 MD-RADL Non-Invasive Cardio
----(278),--41170 MD-RADL Breast Imaging
----(280),--41175 MD-RADL Thoracoabdominal
----(282),--41180 MD-RADL Musculoskeletal
----(284),--41185 MD-RADL Neuroradiology
----(286),--41186 MD-RADL Interventional Neuroradiology (INR)
----(288),--41190 MD-RADL Nuclear Medicine
----(290),--41195 MD-RADL Pediatric Rad
----(295),--41150 MD-RONC Radiation Oncology
----(297),--41210 MD-SURG Surgery, Admin
----(310),--41250 MD-UROL Urology, Admin
----(314),--41255 MD-UROL Urology, General
----(327),--40480 MD-CDBT Ctr for Diabetes Tech
----(331),--40530 MD-CPHG Ctr for Public Health Genomics
----(373),--40204 MD-DMED School of Medicine Adm
----(435),--40230 MD-DMED Curriculum
----(435),--40250 MD-DMED Clin Performance Dev
----(435),--40265 MD-DMED Med Ed Chief of Staff
--;

DECLARE @TelemedicineResource TABLE
(
	Encounter_CSN NUMERIC(18,0) NOT NULL
   ,Prov_Index SMALLINT NOT NULL
   ,Prov VARCHAR(18) NULL
   ,Prov_Pool VARCHAR(200) NULL
   ,INDEX c CLUSTERED (Encounter_CSN,Prov_Index)
   ,INDEX n NONCLUSTERED (Encounter_CSN, Prov_Pool)
);

INSERT INTO @TelemedicineResource
(
    Encounter_CSN,
    Prov_Index,
    Prov,
    Prov_Pool
)
SELECT Encounter_CSN,
       1,
       Prov_1,
       Prov_1_Pool
FROM [DS_HSDM_App].[Stage].[Telemedicine_Encounters_Providers]
WHERE Prov_1_Pool IS NOT NULL AND Prov_1_Pool IN ('TELEMEDICINE RESOURCES','TELEMEDICINE PATIENT LOCATION');
INSERT INTO @TelemedicineResource
(
    Encounter_CSN,
    Prov_Index,
    Prov,
    Prov_Pool
)
SELECT Encounter_CSN,
       2,
       Prov_2,
       Prov_2_Pool
FROM [DS_HSDM_App].[Stage].[Telemedicine_Encounters_Providers]
WHERE Prov_2_Pool IS NOT NULL AND Prov_2_Pool IN ('TELEMEDICINE RESOURCES','TELEMEDICINE PATIENT LOCATION');
INSERT INTO @TelemedicineResource
(
    Encounter_CSN,
    Prov_Index,
    Prov,
    Prov_Pool
)
SELECT Encounter_CSN,
       3,
       Prov_3,
       Prov_3_Pool
FROM [DS_HSDM_App].[Stage].[Telemedicine_Encounters_Providers]
WHERE Prov_3_Pool IS NOT NULL AND Prov_3_Pool IN ('TELEMEDICINE RESOURCES','TELEMEDICINE PATIENT LOCATION');
INSERT INTO @TelemedicineResource
(
    Encounter_CSN,
    Prov_Index,
    Prov,
    Prov_Pool
)
SELECT Encounter_CSN,
       4,
       Prov_4,
       Prov_4_Pool
FROM [DS_HSDM_App].[Stage].[Telemedicine_Encounters_Providers]
WHERE Prov_4_Pool IS NOT NULL AND Prov_4_Pool IN ('TELEMEDICINE RESOURCES','TELEMEDICINE PATIENT LOCATION');
INSERT INTO @TelemedicineResource
(
    Encounter_CSN,
    Prov_Index,
    Prov,
    Prov_Pool
)
SELECT Encounter_CSN,
       5,
       Prov_5,
       Prov_5_Pool
FROM [DS_HSDM_App].[Stage].[Telemedicine_Encounters_Providers]
WHERE Prov_5_Pool IS NOT NULL AND Prov_5_Pool IN ('TELEMEDICINE RESOURCES','TELEMEDICINE PATIENT LOCATION');

SELECT DISTINCT
       TMED.[sk_Dash_Telemedicine_Encounters_Tiles]
      ,TMED.[event_type]
      ,TMED.[event_count]
      ,TMED.[event_date]
      ,TMED.[event_id]
      ,TMED.[event_category]
      ,TMED.[epic_department_id]
      ,TMED.[epic_department_name]
      ,TMED.[epic_department_name_external]
      ,TMED.[fmonth_num]
      ,TMED.[fyear_num]
      ,TMED.[fyear_name]
      ,TMED.[report_period]
      ,TMED.[report_date]
      ,TMED.[peds]
      ,TMED.[transplant]
      ,TMED.[oncology]
      ,TMED.[sk_Dim_Pt]
      ,TMED.[sk_Fact_Pt_Acct]
      ,TMED.[sk_Fact_Pt_Enc_Clrt]
      ,TMED.[person_birth_date]
      ,TMED.[person_gender]
      ,TMED.[person_id]
      ,TMED.[person_name]
      ,TMED.[practice_group_id]
      ,TMED.[practice_group_name]
      ,TMED.[provider_id]
      ,TMED.[provider_name]
      ,TMED.[sk_dim_physcn]
      ,TMED.[service_line_id]
      ,TMED.[service_line]
      ,TMED.[sub_service_line_id]
      ,TMED.[sub_service_line]
      ,TMED.[opnl_service_id]
      ,TMED.[opnl_service_name]
      ,TMED.[corp_service_line_id]
      ,TMED.[corp_service_line_name]
      ,TMED.[hs_area_id]
      ,TMED.[hs_area_name]
      ,TMED.[financial_division_id]
      ,TMED.[financial_division_name]
      ,TMED.[financial_sub_division_id]
      ,TMED.[financial_sub_division_name]
      ,TMED.[rev_location_id]
      ,TMED.[rev_location]
      ,TMED.[som_group_id]
      ,TMED.[som_group_name]
      ,TMED.[som_department_id]
      ,TMED.[som_department_name]
      ,TMED.[som_division_id]
      ,TMED.[som_division_name]
      ,TMED.[w_department_id]
      ,TMED.[w_department_name]
      ,TMED.[w_department_name_external]
      ,TMED.[w_practice_group_id]
      ,TMED.[w_practice_group_name]
      ,TMED.[w_service_line_id]
      ,TMED.[w_service_line_name]
      ,TMED.[w_sub_service_line_id]
      ,TMED.[w_sub_service_line_name]
      ,TMED.[w_opnl_service_id]
      ,TMED.[w_opnl_service_name]
      ,TMED.[w_corp_service_line_id]
      ,TMED.[w_corp_service_line_name]
      ,TMED.[w_report_period]
      ,TMED.[w_report_date]
      ,TMED.[w_hs_area_id]
      ,TMED.[w_hs_area_name]
      ,TMED.[w_financial_division_id]
      ,TMED.[w_financial_division_name]
      ,TMED.[w_financial_sub_division_id]
      ,TMED.[w_financial_sub_division_name]
      ,TMED.[w_rev_location_id]
      ,TMED.[w_rev_location]
      ,TMED.[w_som_group_id]
      ,TMED.[w_som_group_name]
      ,TMED.[w_som_department_id]
      ,TMED.[w_som_department_name]
      ,TMED.[w_som_division_id]
      ,TMED.[w_som_division_name]
      ,TMED.[pod_id]
      ,TMED.[pod_name]
      ,TMED.[hub_id]
      ,TMED.[hub_name]
      ,TMED.[w_pod_id]
      ,TMED.[w_pod_name]
      ,TMED.[w_hub_id]
      ,TMED.[w_hub_name]
      ,TMED.[w_som_hs_area_id]
      ,TMED.[w_som_hs_area_name]
      ,TMED.[w_upg_practice_flag]
      ,TMED.[w_upg_practice_region_id]
      ,TMED.[w_upg_practice_region_name]
      ,TMED.[w_upg_practice_id]
      ,TMED.[w_upg_practice_name]
      ,TMED.[Epic_Department_Specialty]
      ,TMED.[Encounter_CSN]
      ,TMED.[Encounter_Status_Category]
      ,TMED.[Encounter_Status]
      ,TMED.[Communication_Type]
      ,TMED.[Visit_Type]
	  --,APPTS.PRC_NAME
      ,TMED.[Encounter_Type]
      ,TMED.[Event_Date_Within_Nightly_Processing]
      ,TMED.[Prov_Specialty]
      ,TMED.[Prov_Type]
      ,TMED.[Prov_Resource_Type]
      ,TMED.[Smartdata_Element]
      ,TMED.[Smartphrase_ID]
      ,TMED.[Smartphrase_Name]
      ,TMED.[HB_HAR]
      ,TMED.[PB_HAR]
      ,TMED.[Guarantor] 
      ,TMED.[MyChart_Status]
      ,TMED.[Visit_Coverage]
      ,DATEDIFF(YEAR, PAT.BIRTH_DATE, TMED.Event_Date) - CASE WHEN CONVERT(char(5), PAT.BIRTH_DATE, 1) > CONVERT(char(5), TMED.Event_Date, 1) THEN 1 ELSE 0 END AS Age_at_Encounter
      ,CAST(PATVW.FirstRace AS VARCHAR(300))																		AS Race
      ,CAST(PATVW.Ethnicity AS VARCHAR(254))																		AS Ethnicity
      ,CAST(PATVW.PreferredLanguage AS VARCHAR(254))																	AS Preferred_Language
      ,TMED.[Postal_Code]
      ,TMED.[County]
      ,TMED.[StateorProvince]
      ,TMED.[Country]
      ,CAST(TMED.Appt_Note AS VARCHAR(1000))																		AS Appt_Note
      ,PROV_1.Prov_Nme																					AS Appt_Provider_1
      --,PROVS.Prov_1_Pool																				AS Appt_Provider_1_Pool
      ,PROV_2.Prov_Nme																					AS Appt_Provider_2
      --,PROVS.Prov_2_Pool																				AS Appt_Provider_2_Pool
      ,PROV_3.Prov_Nme																					AS Appt_Provider_3
      --,PROVS.Prov_3_Pool																				AS Appt_Provider_3_Pool
      ,PROV_4.Prov_Nme																					AS Appt_Provider_4
      --,PROVS.Prov_4_Pool																				AS Appt_Provider_4_Pool
      ,PROV_5.Prov_Nme																					AS Appt_Provider_5
      --,PROVS.Prov_5_Pool																				AS Appt_Provider_5_Pool
	  ,LEFT(tr.Telemedicine_Resources, LEN(tr.Telemedicine_Resources) - 1) AS Telemedicine_Resources
	  ,LEFT(tpl.Telemedicine_Patient_Location, LEN(tpl.Telemedicine_Patient_Location) - 1) AS Telemedicine_Patient_Location
	  ,TMED.Telehealth_Mode_Name
	  ,TMED.UVaID
	  ,TMED.CANCEL_REASON_NAME
      ,TMED.EMPlye_Nme
      ,TMED.EMPlye_Systm_Login	

INTO #tm

FROM	TabRptg.Dash_Telemedicine_Encounters_Tiles   			AS	TMED
LEFT JOIN	DS_HSDW_Prod.dbo.Dim_Clrt_Pt				AS	PAT	ON PAT.MRN_int=TMED.Person_ID AND PAT.Pt_Rec_Merged_Out<>1
LEFT JOIN	DS_HSDW_Prod.Rptg.vwDim_Patient	  			AS	PATVW	ON PATVW.sk_Dim_Pt=TMED.sk_Dim_Pt	
LEFT JOIN 	DS_HSDM_App.Stage.Telemedicine_Encounters_Providers 	AS 	PROVS 	ON PROVS.Encounter_CSN=TMED.Encounter_CSN
--LEFT JOIN 	DS_HSDM_App.Stage.Scheduled_Appointment 	AS 	APPTS 	ON APPTS.PAT_ENC_CSN_ID=TMED.Encounter_CSN
LEFT JOIN	DS_HSDW_Prod.dbo.Dim_Clrt_SERsrc			AS  	PROV_1	ON PROV_1.PROV_ID=PROVS.PROV_1
LEFT JOIN	DS_HSDW_Prod.dbo.Dim_Clrt_SERsrc			AS  	PROV_2	ON PROV_2.PROV_ID=PROVS.PROV_2
LEFT JOIN	DS_HSDW_Prod.dbo.Dim_Clrt_SERsrc			AS  	PROV_3	ON PROV_3.PROV_ID=PROVS.PROV_3
LEFT JOIN	DS_HSDW_Prod.dbo.Dim_Clrt_SERsrc			AS  	PROV_4	ON PROV_4.PROV_ID=PROVS.PROV_4
LEFT JOIN	DS_HSDW_Prod.dbo.Dim_Clrt_SERsrc			AS  	PROV_5	ON PROV_5.PROV_ID=PROVS.PROV_5
LEFT JOIN
(
SELECT DISTINCT
    tmenc.Encounter_CSN
    , (SELECT ser.Prov_Nme + ',' AS [text()]
        FROM @TelemedicineResource res
        LEFT JOIN	DS_HSDW_Prod.dbo.Dim_Clrt_SERsrc	 ser
		ON ser.PROV_ID = res.Prov
		WHERE res.Encounter_CSN = tmenc.Encounter_CSN AND res.Prov_Pool = 'TELEMEDICINE RESOURCES'
		FOR XML PATH ('')
	) AS Telemedicine_Resources
FROM @TelemedicineResource tmenc
) tr
ON tr.Encounter_CSN = TMED.Encounter_CSN
LEFT JOIN
(
SELECT DISTINCT
    tmenc.Encounter_CSN
    , (SELECT ser.Prov_Nme + ',' AS [text()]
        FROM @TelemedicineResource res
        LEFT JOIN	DS_HSDW_Prod.dbo.Dim_Clrt_SERsrc	 ser
		ON ser.PROV_ID = res.Prov
		WHERE res.Encounter_CSN = tmenc.Encounter_CSN AND res.Prov_Pool = 'TELEMEDICINE PATIENT LOCATION'
		FOR XML PATH ('')
	) AS Telemedicine_Patient_Location
FROM @TelemedicineResource tmenc
) tpl
ON tpl.Encounter_CSN = TMED.Encounter_CSN

WHERE 1=1
AND		event_date >=	@Date_Start
AND 		event_date <=	@Date_End
AND     EXISTS(SELECT COALESCE(ServiceLineId,0) FROM @SL WHERE ServiceLineId = service_line_id)
--AND		COALESCE(service_line_id,0) IN (@SL)
--AND     EXISTS(SELECT COALESCE(UPGPracticeRegionId,0) FROM @UPG_PRACTICE_REGION WHERE UPGPracticeRegionId = w_upg_practice_region_id)
--AND		COALESCE(w_upg_practice_region_id,0) in (@UPG_PRACTICE_REGION)
--AND     EXISTS(SELECT COALESCE(SOMDepartmentId,'0') FROM @SOM_DEPARTMENT WHERE SOMDepartmentId = som_department_id)
--AND		COALESCE(som_department_id,0) IN (@SOM_DEPARTMENT)
--AND     EXISTS(SELECT COALESCE(DepartmentId,0) FROM @DEPARTMENT WHERE DepartmentId = Epic_Department_ID)
--AND		COALESCE(Epic_Department_ID,0) IN (@DEPARTMENT)
--AND     EXISTS(SELECT COALESCE(Provider_Type,'(No Prov Type Defined)') FROM @PROV_TYPE WHERE Provider_Type = Prov_Type)
--AND		COALESCE(Prov_Type,'(No Prov Type Defined)') IN (@PROV_TYPE)
--AND     EXISTS(SELECT COALESCE(EventType,'(No Event Type Defined)') FROM @EVENT_TYPE WHERE EventType = event_type)
--AND		COALESCE(event_type,'(No Event Type Defined)') IN (@EVENT_TYPE)
--AND     EXISTS(SELECT COALESCE(CommunicationType,'(No Communication Type Defined)') FROM @COMM_TYPE WHERE CommunicationType = Communication_Type)
--AND		COALESCE(Communication_Type,'(No Event Type Defined)') IN (@COMM_TYPE)
--AND     EXISTS(SELECT COALESCE(EncounterStatusCategory,'(No Enc Status Defined)') FROM @ENCOUNTER_STATUS WHERE EncounterStatusCategory = Encounter_Status_Category)
--AND		COALESCE(Encounter_Status_Category,'(No Enc Status Defined)') IN (@ENCOUNTER_STATUS)

SELECT
       --TMED.sk_Dash_Telemedicine_Encounters_Tiles,
       TMED.event_type,
       --TMED.event_count,
       TMED.event_date,
       TMED.event_id,
       TMED.event_category,
       TMED.epic_department_id,
       TMED.epic_department_name,
       TMED.epic_department_name_external,
       TMED.fmonth_num,
       TMED.fyear_num,
       TMED.fyear_name,
       TMED.report_period,
       TMED.report_date,
       --TMED.peds,
       --TMED.transplant,
       --TMED.oncology,
       --TMED.sk_Dim_Pt,
       --TMED.sk_Fact_Pt_Acct,
       --TMED.sk_Fact_Pt_Enc_Clrt,
       TMED.person_birth_date,
       TMED.person_gender,
       TMED.person_id,
       TMED.person_name,
       --TMED.practice_group_id,
       --TMED.practice_group_name,
       TMED.provider_id,
       TMED.provider_name,
       --TMED.sk_dim_physcn,
       TMED.service_line_id,
       TMED.service_line,
       --TMED.sub_service_line_id,
       --TMED.sub_service_line,
       --TMED.opnl_service_id,
       --TMED.opnl_service_name,
       --TMED.corp_service_line_id,
       --TMED.corp_service_line_name,
       TMED.hs_area_id,
       TMED.hs_area_name,
       TMED.financial_division_id,
       TMED.financial_division_name,
       TMED.financial_sub_division_id,
       TMED.financial_sub_division_name,
       TMED.rev_location_id,
       TMED.rev_location,
       TMED.som_group_id,
       TMED.som_group_name,
       TMED.som_department_id,
       TMED.som_department_name,
       TMED.som_division_id,
       TMED.som_division_name,
       --TMED.w_department_id,
       --TMED.w_department_name,
       --TMED.w_department_name_external,
       --TMED.w_practice_group_id,
       --TMED.w_practice_group_name,
       --TMED.w_service_line_id,
       --TMED.w_service_line_name,
       --TMED.w_sub_service_line_id,
       --TMED.w_sub_service_line_name,
       --TMED.w_opnl_service_id,
       --TMED.w_opnl_service_name,
       --TMED.w_corp_service_line_id,
       --TMED.w_corp_service_line_name,
       TMED.w_report_period,
       TMED.w_report_date,
       --TMED.w_hs_area_id,
       --TMED.w_hs_area_name,
       --TMED.w_financial_division_id,
       --TMED.w_financial_division_name,
       --TMED.w_financial_sub_division_id,
       --TMED.w_financial_sub_division_name,
       --TMED.w_rev_location_id,
       --TMED.w_rev_location,
       --TMED.w_som_group_id,
       --TMED.w_som_group_name,
       --TMED.w_som_department_id,
       --TMED.w_som_department_name,
       --TMED.w_som_division_id,
       --TMED.w_som_division_name,
       TMED.pod_id,
       TMED.pod_name,
       TMED.hub_id,
       TMED.hub_name,
       --TMED.w_pod_id,
       --TMED.w_pod_name,
       --TMED.w_hub_id,
       --TMED.w_hub_name,
       TMED.w_som_hs_area_id,
       TMED.w_som_hs_area_name,
       --TMED.w_upg_practice_flag,
       --TMED.w_upg_practice_region_id,
       --TMED.w_upg_practice_region_name,
       --TMED.w_upg_practice_id,
       --TMED.w_upg_practice_name,
       TMED.Epic_Department_Specialty,
       TMED.Encounter_CSN,
       TMED.Encounter_Status_Category,
       TMED.Encounter_Status,
       TMED.Communication_Type,
       TMED.Visit_Type,
	   --TMED.PRC_NAME,
       TMED.Encounter_Type,
       TMED.Event_Date_Within_Nightly_Processing,
       TMED.Prov_Specialty,
       TMED.Prov_Type,
       TMED.Prov_Resource_Type,
       TMED.Smartdata_Element,
       TMED.Smartphrase_ID,
       TMED.Smartphrase_Name,
       TMED.HB_HAR,
       TMED.PB_HAR,
       TMED.Guarantor,
       TMED.MyChart_Status,
       TMED.Visit_Coverage,
       TMED.Age_at_Encounter,
       TMED.Race,
       TMED.Ethnicity,
       TMED.Preferred_Language,
       TMED.Postal_Code,
       TMED.County,
       TMED.StateorProvince,
       TMED.Country,
       TMED.Appt_Note,
       TMED.Appt_Provider_1,
       TMED.Appt_Provider_2,
       TMED.Appt_Provider_3,
       TMED.Appt_Provider_4,
       TMED.Appt_Provider_5,
       TMED.Telemedicine_Resources,
       TMED.Telemedicine_Patient_Location,
	   TMED.Telehealth_Mode_Name,
	   TMED.UVaID,
	   TMED.CANCEL_REASON_NAME,
	   TMED.EMPlye_Nme,
	   TMED.EMPlye_Systm_Login	
FROM #tm TMED
--WHERE
--Appt_Provider_1 = 'TELEMEDICINE CONFERENCE ROOM'
--AND Appt_Provider_2 = 'TELEMEDICINE LOCATION NOT NEEDED'
--AND Appt_Provider_3 = 'TELEMEDICINE PATIENT HOME'
--WHERE Appt_Provider_1 = 'TELEMEDICINE LOCATION NOT NEEDED'
--AND Appt_Provider_2 = 'TELEMEDICINE PATIENT HOME'
--WHERE Appt_Provider_1 LIKE 'TELEMEDICINE%'
--OR Appt_Provider_2 LIKE 'TELEMEDICINE%'
--OR Appt_Provider_3 LIKE 'TELEMEDICINE%'
--TMED.Encounter_Status_Category = 'Complete'
--TMED.financial_division_id = 67000

--SELECT DISTINCT
--	tm.Appt_Provider
--FROM
--(
----SELECT DISTINCT
----	Appt_Provider_1 AS Appt_Provider
----FROM #tm
----UNION ALL
--SELECT DISTINCT
--	Appt_Provider_2 AS Appt_Provider
--FROM #tm
--UNION ALL
--SELECT DISTINCT
--	Appt_Provider_3 AS Appt_Provider
--FROM #tm
--UNION ALL
--SELECT DISTINCT
--	Appt_Provider_4 AS Appt_Provider
--FROM #tm
--UNION ALL
--SELECT DISTINCT
--	Appt_Provider_5 AS Appt_Provider
--FROM #tm
--) tm
--ORDER BY tm.Appt_Provider

--ORDER BY TMED.event_id
--ORDER BY PROV_1.Prov_Nme DESC
--       , TMED.event_id
--ORDER BY PROV_1.Prov_Nme DESC
--ORDER BY Appt_Provider_1 DESC
--ORDER BY provider_name
--ORDER BY Appt_Provider_1
--       , Appt_Provider_2
--	   , Appt_Provider_3
--ORDER BY provider_name
--       , Appt_Provider_1
--       , Appt_Provider_2
--	   , Appt_Provider_3
--ORDER BY TMED.epic_department_id
--       , TMED.event_date
ORDER BY TMED.event_date

--SELECT DISTINCT
--       TMED.epic_department_id,
--       TMED.epic_department_name,
--       TMED.epic_department_name_external
--FROM #tm TMED
--WHERE
--TMED.financial_division_id = 67000
--ORDER BY TMED.epic_department_id

--SELECT
--       TMED.PRC_NAME
--	,  COUNT(*) AS PRC_NAME_COUNT
--FROM #tm TMED
--WHERE
----TMED.financial_division_id = 67000
--TMED.epic_department_id IN (10228010
--,10229001
--,10239010
--,10240006
--,10241002
--,10242007
--,10243059)
--AND TMED.Prov_Type = 'Resident'
--GROUP BY TMED.PRC_NAME
--ORDER BY TMED.PRC_NAME
