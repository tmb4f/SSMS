USE [CLARITY_App]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

----MODS: 	
----		10/5/2022 - JB - Location filtering logic for CH Go Live
----        11/22/20222 - NRM3V - Add default 'UVA-MC' value for @de_control per DataOps

--ALTER PROCEDURE [Rptg].[uspSrc_ED_IP_Consults]
--(
--    @StartDate SMALLDATETIME,
--    @EndDate SMALLDATETIME,
--	@de_control VARCHAR(255) = 'UVA-MC'
----------de_control parameter can have the following values: 		
----------          UVA-MC = UVA Medical Center at Charlottesville, VA		
----------          UVA-HM = Haymarket (part of Community Health) including UVA-HH (Heathcote Health Center)		
----------          UVA-PW = Prince William (part of Community Health)		
----------          UVA-CU = Culpeper (part of Community Health)		
----------          UVA-CH = Community Health (UVA-HM, UVA-PW, UVA-HH, UVA-CU)		
----------          ALL = UVA Health System (includes ALL hospitals)		
----------          UVA-HH = returns no records
--)
--AS

SET NOCOUNT ON;

DECLARE @StartDate SMALLDATETIME;
DECLARE @EndDate SMALLDATETIME;
DECLARE @de_control VARCHAR(255) = 'UVA-MC'

SET @StartDate = '01-01-2021';
SET @EndDate = '05-11-2023';



------for testing only-------
--DECLARE
--	@StartDate SMALLDATETIME = '11/1/2022',
--	@EndDate SMALLDATETIME = '11/21/2022',
--	@de_control VARCHAR(255) = 'UVA-PW,UVA-MC,UVA-HM'


------MDM_REV_LOC_ID is used for location filter to account for non UVA MC locations see @de_control parameter above for more details------
IF OBJECT_ID ('TEMPDB..#MDM_REV_LOC_ID') IS NOT NULL DROP TABLE #MDM_REV_LOC_ID
SELECT 
	DISTINCT 	
	t1.REV_LOC_ID
	,t1.HOSPITAL_CODE
	,t1.DE_HOSPITAL_CODE
	,t1.HOSPITAL_GROUP
INTO #MDM_REV_LOC_ID
FROM	
	[CLARITY_App].[Rptg].[vwRef_MDM_Location_Master_Hospital_Group] t1
WHERE	
	(t1.REV_LOC_ID IS NOT NULL)


SELECT DISTINCT
       pt.PAT_MRN_ID AS 'MRN',
       pt.PAT_NAME AS 'Patient Name',
       pt.BIRTH_DATE AS 'Date of Birth',
       FLOOR(DATEDIFF(DAY, pt.BIRTH_DATE, op.ORDERING_DATE) / 365.25) 'Age at Encounter',
       CASE
           WHEN FLOOR(DATEDIFF(DAY, pt.BIRTH_DATE, op.ORDERING_DATE) / 365.25) <= 14 THEN
               '<14'
           WHEN FLOOR(DATEDIFF(DAY, pt.BIRTH_DATE, op.ORDERING_DATE) / 365.25) >= 15
                AND FLOOR(DATEDIFF(DAY, pt.BIRTH_DATE, op.ORDERING_DATE) / 365.25) <= 17 THEN
               '15-17'
           WHEN FLOOR(DATEDIFF(DAY, pt.BIRTH_DATE, op.ORDERING_DATE) / 365.25) >= 18 THEN
               '18+'
           ELSE
               'Ped'
       END Age_Group,
       op.ORDER_TIME AS 'Consult Ordered Date/Time',
       CAST(op.ORDER_TIME AS DATE) 'Consult Ordered Date',
	   eap.PROC_ID,
	   eap.PROC_CODE,
	   eap.PROC_CAT,
	   eap.PROC_TYPE,
	   eap.PROC_NAME,
       eap.PROC_NAME AS 'Consult',
       nte.NOTE_ID,
	   nte.NOTE_WRITTEN_BY_USER_ID,
       nte.NOTE_WRITTEN_BY_USER,
       nte.NOTE_WRITTEN_BY_USER_TYPE,
	   nte.IP_ACTION_DTTM,
	    odep.DEPARTMENT_NAME,
       cdi.MPI_ID,
       op.DISPLAY_NAME,
       op.ORDER_PROC_ID,
       op.ORDER_STATUS_C,
	   emp.NAME ATTENDING,
       peh.HOSP_ADMSN_TIME AS 'Admit Date/Time',
       peh.HOSP_DISCH_TIME AS 'Discharge Date/Time',
       adt.ADT_DEPARTMENT_NAME AS 'Unit'
	   ,mloc.HOSPITAL_CODE AS Hospital
--,zos.NAME					AS 'Order Status'
--,zrfc.NAME					AS 'Reason for Cancel'
FROM CLARITY.dbo.ORDER_PROC AS op
    INNER JOIN CLARITY.dbo.PATIENT AS pt
        ON pt.PAT_ID = op.PAT_ID
    INNER JOIN CLARITY.dbo.CLARITY_EAP AS eap
        ON eap.PROC_ID = op.PROC_ID
    INNER JOIN CLARITY.dbo.PAT_ENC_HSP AS peh
        ON peh.PAT_ENC_CSN_ID = op.PAT_ENC_CSN_ID
		LEFT OUTER JOIN CLARITY.dbo.ORDER_PROC_2 AS op2
        ON op2.ORDER_PROC_ID = op.ORDER_PROC_ID
		LEFT OUTER JOIN CLARITY.dbo.ORDER_PROC_3 AS op3 ON op3.ORDER_ID = op.ORDER_PROC_ID
		LEFT OUTER JOIN CLARITY.dbo.CLARITY_EMP emp ON emp.USER_ID = op3.STAT_COMP_USER_ID
    LEFT OUTER JOIN CLARITY.dbo.CLARITY_DEP AS odep
        ON odep.DEPARTMENT_ID = op2.PAT_LOC_ID
	-----Adding location filtering logic for CH Go Live 09/2022-----
	LEFT OUTER JOIN  #MDM_REV_LOC_ID mloc ON	mloc.REV_LOC_ID = odep.REV_LOC_ID
    LEFT OUTER JOIN CLARITY.dbo.CL_DEP_ID AS cdi
        ON cdi.DEPARTMENT_ID = odep.DEPARTMENT_ID
           AND cdi.MPI_ID_TYPE_ID = '272'
    LEFT JOIN CLARITY.dbo.V_PAT_ADT_LOCATION_HX AS adt
        ON peh.PAT_ENC_CSN_ID = adt.PAT_ENC_CSN
           AND (op.ORDERING_DATE
           BETWEEN adt.IN_DTTM AND adt.OUT_DTTM
               )
    LEFT JOIN CLARITY.dbo.ZC_ORDER_STATUS AS zos
        ON zos.ORDER_STATUS_C = op.ORDER_STATUS_C
    LEFT JOIN CLARITY.dbo.ZC_REASON_FOR_CANC AS zrfc
        ON zrfc.REASON_FOR_CANC_C = op.REASON_FOR_CANC_C
   LEFT OUTER JOIN    -- 03/20/2019 Added this logic to capture the note related data
    (
        SELECT cno.CONSULT_ORDER_ID,
               cno.NOTE_ID,
			   ned.IP_ACTION_USER_ID AS NOTE_WRITTEN_BY_USER_ID,
               emp.NAME NOTE_WRITTEN_BY_USER,
               ser.PROV_TYPE NOTE_WRITTEN_BY_USER_TYPE,
               ned.LINE,
               ned.IP_ACTION_DTTM ,
               ROW_NUMBER() OVER (PARTITION BY cno.CONSULT_ORDER_ID
                                  ORDER BY ned.LINE,
                                           ned.IP_ACTION_DTTM
                                 ) rn
        FROM CLARITY.dbo.HNO_CONSULT_ORD_ID AS cno
            LEFT OUTER JOIN CLARITY.dbo.HNO_INFO AS hin
                ON hin.NOTE_ID = cno.NOTE_ID
            LEFT OUTER JOIN CLARITY.dbo.NOTE_EDIT_TRAIL AS ned
                ON ned.NOTE_ID = cno.NOTE_ID
                   --AND ned.LINE = 2  -- Psych Resident who documented the consult 
                   -- AND ned.ACTION_NOTE_STAT_C IS NOT NULL   -- RedCap 731
            LEFT OUTER JOIN CLARITY.dbo.CLARITY_EMP AS emp
                ON emp.USER_ID = ned.IP_ACTION_USER_ID
            LEFT OUTER JOIN CLARITY.dbo.CLARITY_SER AS ser
                ON ser.PROV_ID = emp.PROV_ID
        WHERE ned.IP_ACTION_ON_NOTE_C = 2
    ) AS nte
        ON nte.CONSULT_ORDER_ID = op.ORDER_PROC_ID
           AND nte.rn = 1
--WHERE eap.PROC_CODE IN ( 'CON91', 'CON53', 'CON90','CON220' )
--	  --CON91 - IP CONSULT TO PEDIATRIC PSYCHOLOGY -- ql4g 10/06/2022
--      --CON53 - IP CONSULT TO PSYCHIATRY
--      --CON90 - IP CONSULT TO PEDIATRIC PSYCHIATRY
--	  --CON220  - CONSULT TO BEHAVIORAL MED (PHD)
WHERE nte.NOTE_WRITTEN_BY_USER_ID IN (
'732',
'75224',
'53948',
'1363',
'83391',
'1206',
'50760',
'1254',
'1273',
'45345',
'48142',
'47340',
'3873',
'82667')

      AND op.INSTANTIATED_TIME IS NOT NULL
      AND op.ORDERING_DATE >= @StartDate
      AND op.ORDERING_DATE < DATEADD(DAY, 1, @EndDate)
      AND op.ORDER_STATUS_C <> 4 -- NOT CANCELLED
	   --------LOCATION FILTERING FOR CH GO LIVE------
	 -- AND 
		--COALESCE(mloc.HOSPITAL_CODE,'UVA-MC') IN
		--(
		--	SELECT VALUE 
		--	FROM 
		--	STRING_SPLIT (@de_control,',')
		--)
ORDER BY pt.PAT_MRN_ID;

GO


