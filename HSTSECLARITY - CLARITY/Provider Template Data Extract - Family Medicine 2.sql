USE [CLARITY_App]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('tempdb..#util ') IS NOT NULL
DROP TABLE #util

IF OBJECT_ID('tempdb..#datetable ') IS NOT NULL
DROP TABLE #datetable

IF OBJECT_ID('tempdb..#avail ') IS NOT NULL
DROP TABLE #avail

IF OBJECT_ID('tempdb..#schdtmpl ') IS NOT NULL
DROP TABLE #schdtmpl

IF OBJECT_ID('tempdb..#availtmpl ') IS NOT NULL
DROP TABLE #availtmpl

IF OBJECT_ID('tempdb..#avail_block ') IS NOT NULL
DROP TABLE #avail_block

--IF OBJECT_ID('tempdb..#avail_aggr ') IS NOT NULL
--DROP TABLE #avail_aggr

--IF OBJECT_ID('tempdb..#booked_blocks ') IS NOT NULL
--DROP TABLE #booked_blocks

--IF OBJECT_ID('tempdb..#used_blocks ') IS NOT NULL
--DROP TABLE #used_blocks

--IF OBJECT_ID('tempdb..#tmpl_booked_blocks ') IS NOT NULL
--DROP TABLE #tmpl_booked_blocks

--IF OBJECT_ID('tempdb..#tmpl_used_blocks ') IS NOT NULL
--DROP TABLE #tmpl_used_blocks

IF OBJECT_ID('tempdb..#tmpl_avail_blocks ') IS NOT NULL
DROP TABLE #tmpl_avail_blocks

IF OBJECT_ID('tempdb..#tmpl_avail_blocks_aggr ') IS NOT NULL
DROP TABLE #tmpl_avail_blocks_aggr

IF OBJECT_ID('tempdb..#tmpl_avail_blocks_summ ') IS NOT NULL
DROP TABLE #tmpl_avail_blocks_summ

--IF OBJECT_ID('tempdb..#booked_appts ') IS NOT NULL
--DROP TABLE #booked_appts

--IF OBJECT_ID('tempdb..#booked_appts_aggr ') IS NOT NULL
--DROP TABLE #booked_appts_aggr

--IF OBJECT_ID('tempdb..#tmpl_avail_blocks_booked ') IS NOT NULL
--DROP TABLE #tmpl_avail_blocks_booked

--IF OBJECT_ID('tempdb..#sched_appts ') IS NOT NULL
--DROP TABLE #sched_appts

--IF OBJECT_ID('tempdb..#RptgTmp ') IS NOT NULL
--DROP TABLE #RptgTmp

--IF OBJECT_ID('tempdb..#RptgTmpStats ') IS NOT NULL
--DROP TABLE #RptgTmpStats

--IF OBJECT_ID('tempdb..#RptgTmp2 ') IS NOT NULL
--DROP TABLE #RptgTmp2

--IF OBJECT_ID('tempdb..#tmpl_booked_appts ') IS NOT NULL
--DROP TABLE #tmpl_booked_appts

--IF OBJECT_ID('tempdb..#tmpl ') IS NOT NULL
--DROP TABLE #tmpl

DECLARE @startdate SMALLDATETIME = NULL, 
        @enddate SMALLDATETIME = NULL

--SET @startdate = '12/1/2022 00:00 AM'
--SET @startdate = '7/1/2023 00:00 AM'
--SET @enddate = '9/20/2023 11:59 PM'
SET @startdate = '7/1/2021 00:00 AM'
--SET @enddate = '12/2/2022 11:59 PM'
--SET @enddate = '8/31/2023 11:59 PM'
--SET @enddate = '9/1/2023 11:59 PM'
SET @enddate = '10/1/2023 11:59 PM'
--SET @enddate = '7/1/2021 11:59 PM'

/*
Hierarchy											SPECIALTY								7
Hierarchy Values								ORTHOPEDIC SURGERY		27
Department/  Fin. Subdivision			CPSN UVA ORTHO SPINE		10293031
Provider											SINGLA, ANUJ						62069
*/
/*
Hierarchy											FINANCIAL DIVISION				8
Hierarchy Values								Family Medicine						48000
Department/  Fin. Subdivision			FAM: Family Medicine				4800001
Provider											LOCKMAN, ANDREW             28837
*/

--DECLARE @HierarchySelect TABLE (ID INTEGER, LABEL VARCHAR(20))
DECLARE @HierarchySelect TABLE (ID VARCHAR(50), LABEL VARCHAR(20))

INSERT INTO @HierarchySelect
(
    ID,
    LABEL
)
--DEPARTMENT BASED SELECTIONS
SELECT	'1' AS ID,			'ORGANIZATION NAME'	 AS LABEL	
	UNION ALL 
SELECT	'2',			'SERVICE AREA NAME'		
	UNION ALL 
SELECT	'3',			'CLINICAL AREA NAME'		
	UNION ALL 
SELECT	'4',			'POD'		
	UNION ALL 
SELECT	'5',			'SERVICE LINE'
    UNION ALL
SELECT  '6',          'LOCATION'
	UNION ALL
SELECT  '7',          'SPECIALTY'
	UNION ALL
SELECT '8',			'FINANCIAL DIVISION'

DECLARE @Hierarchy NVARCHAR(MAX)

SET @Hierarchy = 
(
SELECT STRING_AGG(CONVERT(NVARCHAR(MAX), ISNULL(HierarchySelect.ID,'N/A')), ',') AS csv
FROM (SELECT TOP 1 ID FROM @HierarchySelect ORDER BY NEWID()) HierarchySelect
);

--SET @Hierarchy = '7' -- SPECIALTY
SET @Hierarchy = '8' -- FINANCIAL DIVISION

SELECT value AS ID, [@HierarchySelect].LABEL FROM STRING_SPLIT(@Hierarchy,',') Hierarchy LEFT OUTER JOIN @HierarchySelect ON [@HierarchySelect].ID = Hierarchy.value

DECLARE @HierarchyLookup VARCHAR(50)

SET @HierarchyLookup = @Hierarchy

--DECLARE @HierarchyValuesSelect TABLE (Sort INTEGER, ID VARCHAR(200), LABEL VARCHAR(200))
DECLARE @HierarchyValuesSelect TABLE (Sort INTEGER, ID VARCHAR(50), LABEL VARCHAR(200))

INSERT INTO @HierarchyValuesSelect
(
    Sort,
    ID,
    LABEL
)

SELECT HierarchyValues.Sort, HierarchyValues.ID, UPPER(HierarchyValues.LABEL) AS LABEL
FROM
(
	SELECT DISTINCT 1 AS Sort
		--,o.organization_id AS ID
		,CAST(o.organization_id AS VARCHAR(50)) AS ID
		,o.organization_name AS LABEL
	FROM CLARITY_App.[Mapping].Ref_Organization_Map o WITH (NOLOCK) INNER JOIN
	CLARITY_App.[Mapping].Ref_Service_Map s WITH (NOLOCK)  ON s.organization_id = o.organization_id INNER JOIN
	CLARITY_App.[Mapping].Ref_Clinical_Area_Map c WITH (NOLOCK)  ON c.sk_Ref_Service_Map = s.sk_Ref_Service_Map INNER JOIN
	CLARITY_App.[Mapping].Epic_Dept_Groupers g WITH (NOLOCK)   ON g.sk_Ref_Clinical_Area_Map = c.sk_Ref_Clinical_Area_Map
	WHERE 1=1
	--AND 1 IN (SELECT value AS ID FROM STRING_SPLIT(@Hierarchy,','))--@HierarchyLookup = 1
	AND @HierarchyLookup = 1
	AND g.ambulatory_flag = 1

UNION ALL

	SELECT DISTINCT 1
		,CAST(s.sk_Ref_Service_Map AS VARCHAR(50))
		,o.organization_name + ': ' + s.service_name
	FROM CLARITY_App.[Mapping].Ref_Service_Map s WITH (NOLOCK)  INNER JOIN
	CLARITY_APP.mapping.Ref_Organization_Map o WITH (NOLOCK)  ON o.organization_id = s.organization_id INNER JOIN
	CLARITY_App.[Mapping].Ref_Clinical_Area_Map c WITH (NOLOCK)  ON c.sk_Ref_Service_Map = s.sk_Ref_Service_Map INNER JOIN
	CLARITY_App.[Mapping].Epic_Dept_Groupers g WITH (NOLOCK)   ON g.sk_Ref_Clinical_Area_Map = c.sk_Ref_Clinical_Area_Map
	WHERE 1=1
	--AND 2 IN (SELECT value AS ID FROM STRING_SPLIT(@Hierarchy,','))--@HierarchyLookup  = 2 
	AND @HierarchyLookup = 2
	AND  g.ambulatory_flag = 1

UNION ALL

	SELECT DISTINCT 1
	,CAST(c.clinical_area_id AS VARCHAR(50)) 
	,c.clinical_area_name
	FROM CLARITY_App.[Mapping].Ref_Clinical_Area_Map c WITH (NOLOCK)  INNER JOIN
	CLARITY_App.[Mapping].Epic_Dept_Groupers g WITH (NOLOCK)  ON g.sk_Ref_Clinical_Area_Map = c.sk_Ref_Clinical_Area_Map
	--WHERE 3 IN (SELECT value AS ID FROM STRING_SPLIT(@Hierarchy,','))--@HierarchyLookup  = 3
	WHERE @HierarchyLookup = 3
	AND  g.ambulatory_flag = 1

UNION ALL

	SELECT DISTINCT		1               
        ,   CAST(six.RPT_GRP_SIX AS VARCHAR(50))     
        ,	six.NAME            
    FROM CLARITY.dbo.ZC_DEP_RPT_GRP_6 six WITH (NOLOCK)   INNER JOIN
	CLARITY.dbo.CLARITY_DEP dep WITH (NOLOCK)  ON dep.RPT_GRP_SIX = six.RPT_GRP_SIX INNER JOIN
	CLARITY_App.[Mapping].Epic_Dept_Groupers g WITH (NOLOCK)  ON g.epic_department_id = dep.DEPARTMENT_ID
    WHERE 1=1
	--AND 4 IN (SELECT value AS ID FROM STRING_SPLIT(@Hierarchy,','))--@HierarchyLookup  = 4
	AND @HierarchyLookup = 4
	AND g.ambulatory_flag = 1
    	UNION ALL 
    SELECT 2, '0', '(Undefined Pod)'
    --WHERE 4 IN (SELECT value AS ID FROM STRING_SPLIT(@Hierarchy,','))--@HierarchyLookup  = 4
	WHERE @HierarchyLookup = 4
    
UNION ALL

--List all Department based Service Lines
    SELECT DISTINCT 
    	        CAST(CASE WHEN RPT_GRP_THIRTY IS NOT NULL THEN 1 ELSE 2 END AS VARCHAR(50))
            , 	COALESCE(RPT_GRP_THIRTY, '(Undefined ServLine)')
            ,	COALESCE(RPT_GRP_THIRTY, '(Undefined ServLine)')  --, LEN(RPT_GRP_FIVE)
    FROM CLARITY.dbo.CLARITY_DEP dep WITH (NOLOCK)  INNER JOIN
	CLARITY_App.[Mapping].Epic_Dept_Groupers g WITH (NOLOCK)   ON g.epic_department_id = dep.DEPARTMENT_ID
    --WHERE 5 IN (SELECT value AS ID FROM STRING_SPLIT(@Hierarchy,','))--@HierarchyLookup  = 5
	WHERE @HierarchyLookup = 5
	AND g.ambulatory_flag = 1

UNION ALL

--List all Locations
    SELECT DISTINCT 1
        ,   CAST(l.LOC_ID AS VARCHAR(50))
        ,   l.LOC_NAME
    FROM CLARITY.dbo.CLARITY_LOC l WITH (NOLOCK) INNER JOIN
	CLARITY.dbo.CLARITY_DEP dep WITH (NOLOCK) ON dep.REV_LOC_ID = l.LOC_ID INNER JOIN
	CLARITY_App.[Mapping].Epic_Dept_Groupers g WITH (NOLOCK)  ON g.epic_department_id = dep.DEPARTMENT_ID
    WHERE 1=1
	--AND 6 IN (SELECT value AS ID FROM STRING_SPLIT(@Hierarchy,','))--@HierarchyLookup = 6
	AND @HierarchyLookup = 6
	AND g.ambulatory_flag = 1
    	UNION ALL 
    SELECT 2, '0', '(Undefined Location)'
    --WHERE 6 IN (SELECT value AS ID FROM STRING_SPLIT(@Hierarchy,','))--@HierarchyLookup  = 6
	WHERE @HierarchyLookup = 6
    
UNION ALL

--List all Specialties
    SELECT DISTINCT  1
        ,   CAST(s.SPECIALTY_DEP_C AS VARCHAR(50))
        ,   s.NAME 
    FROM CLARITY.dbo.ZC_SPECIALTY_DEP s  WITH (NOLOCK) INNER JOIN
	CLARITY.dbo.CLARITY_DEP dep WITH (NOLOCK) ON dep.SPECIALTY_DEP_C = s.SPECIALTY_DEP_C INNER JOIN 
	CLARITY_App.[Mapping].Epic_Dept_Groupers g WITH (NOLOCK)  ON g.epic_department_id = dep.DEPARTMENT_ID
    WHERE 1=1
	--AND 7 IN (SELECT value AS ID FROM STRING_SPLIT(@Hierarchy,','))--@HierarchyLookup  = 7
	AND @HierarchyLookup = 7
	AND g.ambulatory_flag = 1
    	UNION ALL 
    SELECT 2, '0', '(Undefined Dept Specialty)'
    --WHERE 7 IN (SELECT value AS ID FROM STRING_SPLIT(@Hierarchy,','))--@HierarchyLookup  = 7
	WHERE @HierarchyLookup = 7

UNION ALL

    SELECT  1 AS Sort
        ,   CAST(FIN_DIV_ID as VARCHAR(50)) AS ID
        ,   FIN_DIV_NM AS Label
    FROM CLARITY.dbo. FIN_DIV
    --WHERE 8 IN (SELECT value AS ID FROM STRING_SPLIT(@Hierarchy,','))--@HierarchyLookup = 8
	WHERE @HierarchyLookup = 8
) HierarchyValues
--ORDER BY 1, 3

--SELECT Sort, ID, LABEL FROM @HierarchyValuesSelect ORDER BY 1, 3
SELECT Sort, ID, LABEL FROM @HierarchyValuesSelect ORDER BY 1, 2

DECLARE @HierarchyValues NVARCHAR(MAX)

SET @HierarchyValues = 
(
SELECT STRING_AGG(CONVERT(NVARCHAR(max), ISNULL(HierarchyValuesSelect.ID,'N/A')), ',') AS csv
FROM (SELECT TOP 1 ID FROM @HierarchyValuesSelect ORDER BY NEWID()) HierarchyValuesSelect
);

--SET @HierarchyValues = '27' -- ORTHOPEDIC SURGERY
SET @HierarchyValues = '48000' -- Family Medicine

SELECT @HierarchyValues AS HierarchyValuesSelect

DECLARE @DepartmentsSelect TABLE (ID VARCHAR(50), [Name] VARCHAR(200))

INSERT INTO @DepartmentsSelect
(
    ID,
    [Name]
)

SELECT DepartmentsValues.ID, DepartmentsValues.[Name]
FROM
(
--Get list of Departments
    SELECT  CAST(CLARITY_DEP.DEPARTMENT_ID as VARCHAR(18))	AS ID
        ,   CLARITY_DEP.DEPARTMENT_NAME + ' [' + CAST(CLARITY_DEP.DEPARTMENT_ID as VARCHAR(18)) + ']' AS Name

    FROM CLARITY.dbo.CLARITY_DEP WITH (NOLOCK) INNER JOIN
	CLARITY_App.Mapping.Epic_Dept_Groupers g WITH (NOLOCK)  ON g.epic_department_id = CLARITY_DEP.DEPARTMENT_ID
    LEFT JOIN CLARITY_App.Mapping.Ref_Clinical_Area_Map c WITH (NOLOCK) on g.sk_Ref_Clinical_Area_Map = c.sk_Ref_Clinical_Area_Map
    LEFT JOIN CLARITY_App.Mapping.Ref_Service_Map s WITH (NOLOCK) on c.sk_Ref_Service_Map = s.sk_Ref_Service_Map
    LEFT JOIN CLARITY_App.Mapping.Ref_Organization_Map o WITH (NOLOCK) on s.organization_id = o.organization_id
    WHERE 1=1
		AND g.ambulatory_flag = 1
        --AND (   (   1 IN (SELECT value AS ID FROM STRING_SPLIT(@Hierarchy,',')) -- @HierarchyLookup = 1
        AND (   (   @HierarchyLookup = 1
                AND coalesce(o.[organization_id], '999')					IN (SELECT value FROM STRING_SPLIT(@HierarchyValues,','))	)		--Organization Name
            --OR  (   2 IN (SELECT value AS ID FROM STRING_SPLIT(@Hierarchy,',')) -- @HierarchyLookup = 2
            OR  (   @HierarchyLookup = 2
                AND coalesce(s.[sk_Ref_Service_Map], '999')					IN (SELECT value FROM STRING_SPLIT(@HierarchyValues,','))	)		--Service Area
            --OR  (   3 IN (SELECT value AS ID FROM STRING_SPLIT(@Hierarchy,',')) -- @HierarchyLookup = 3
            OR  (   @HierarchyLookup = 3
                AND COALESCE(c.[clinical_area_id], '999')		IN (SELECT value FROM STRING_SPLIT(@HierarchyValues,','))	)			--Clinical Area
            )

UNION ALL

--Get list of Departments
    SELECT  CAST(DEPARTMENT_ID as VARCHAR(18))	
        ,   DEPARTMENT_NAME + ' [' + CAST(DEPARTMENT_ID as VARCHAR(18)) + ']'

    FROM CLARITY.dbo.CLARITY_DEP WITH (NOLOCK) INNER JOIN
	CLARITY_App.Mapping.Epic_Dept_Groupers g WITH (NOLOCK)  ON g.epic_department_id = CLARITY_DEP.DEPARTMENT_ID
    WHERE 1=1
		AND g.ambulatory_flag = 1
        --AND (   (   4 IN (SELECT value AS ID FROM STRING_SPLIT(@Hierarchy,',')) -- @HierarchyLookup = 4
        AND (   (   @HierarchyLookup = 4
                AND COALESCE(RPT_GRP_SIX,'0')						IN (SELECT value FROM STRING_SPLIT(@HierarchyValues,','))	)		--Pod
            --OR  (   5 IN (SELECT value AS ID FROM STRING_SPLIT(@Hierarchy,',')) -- @HierarchyLookup = 5
            OR  (   @HierarchyLookup = 5
                AND COALESCE(RPT_GRP_THIRTY,'(Undefined ServLine)')	IN (SELECT value FROM STRING_SPLIT(@HierarchyValues,','))	)			--Dept Service Line
            --OR  (   6 IN (SELECT value AS ID FROM STRING_SPLIT(@Hierarchy,',')) -- @HierarchyLookup = 6
            OR  (   @HierarchyLookup = 6
                AND COALESCE(REV_LOC_ID,'0')						IN (SELECT value FROM STRING_SPLIT(@HierarchyValues,','))	)			--Location
            --OR  (   7 IN (SELECT value AS ID FROM STRING_SPLIT(@Hierarchy,',')) -- @HierarchyLookup = 7
            OR  (   @HierarchyLookup = 7
                AND COALESCE(SPECIALTY_DEP_C,'0')					IN (SELECT value FROM STRING_SPLIT(@HierarchyValues,','))	)			--Dept Specialty
            )

UNION ALL /*Finaincal SubDivision*/

    SELECT  CAST(FIN_SUBDIV_ID as VARCHAR(18))
        ,   FIN_SUBDIV_NM
    FROM CLARITY.dbo.FIN_SUBDIV
    --WHERE 8 IN (SELECT value AS ID FROM STRING_SPLIT(@Hierarchy,',')) -- @HierarchyLookup = 8
    WHERE @HierarchyLookup = 8
	 AND COALESCE(FIN_DIV_ID,'0') IN (SELECT value FROM STRING_SPLIT(@HierarchyValues,','))
) DepartmentsValues

SELECT ID, [Name] FROM @DepartmentsSelect ORDER BY 2

DECLARE @Departments NVARCHAR(MAX)

SET @Departments =
(
SELECT STRING_AGG(CONVERT(NVARCHAR(max), ISNULL(DepartmentsSelect.ID,'N/A')), ',') AS csv
FROM (SELECT TOP 5 ID FROM @DepartmentsSelect ORDER BY NEWID()) DepartmentsSelect
);

--SET @Departments = '10293031' --  CPSN UVA ORTHO SPINE
SET @Departments = '4800001' --  FAM: Family Medicine

SELECT @Departments AS DepartmentsSelect

DECLARE @ProvidersSelect TABLE (PROV_ID VARCHAR(50), PROV_NAME VARCHAR(200))

INSERT INTO @ProvidersSelect
(
    PROV_ID,
    PROV_NAME
)

SELECT ProvidersValues.PROV_ID, ProvidersValues.PROV_NAME
FROM
(
SELECT DISTINCT ser.PROV_ID, ser.PROV_NAME 
FROM CLARITY.dbo.CLARITY_SER ser INNER JOIN
CLARITY.dbo.V_AVAILABILITY v ON v.PROV_ID = ser.PROV_ID
WHERE 1=1
AND v.APPT_NUMBER = 0
AND v.ORG_REG_OPENINGS  > 0
AND v.DEPARTMENT_ID IN (SELECT value FROM STRING_SPLIT(@Departments,','))
AND CONVERT(DATE,v.SLOT_DATE) BETWEEN @startdate AND @enddate
--AND 8 NOT IN (SELECT value AS ID FROM STRING_SPLIT(@Hierarchy,',')) -- @HierarchyLookup <> 8
AND @HierarchyLookup <> 8
--AND ser.PROVIDER_TYPE_C IN ('1' , '4', '6', '9', '10','101','105','108','2','2506','2527','2721')  

UNION

SELECT DISTINCT ser.PROV_ID, ser.PROV_NAME 
FROM CLARITY.dbo.CLARITY_SER ser INNER JOIN
CLARITY.dbo.V_AVAILABILITY v ON v.PROV_ID = ser.PROV_ID
WHERE 1=1
AND v.APPT_NUMBER = 0
AND v.ORG_REG_OPENINGS  > 0
AND CONVERT(DATE,v.SLOT_DATE) BETWEEN @startdate AND @enddate
--AND 8 IN (SELECT value AS ID FROM STRING_SPLIT(@Hierarchy,',')) -- @HierarchyLookup = 8
AND @HierarchyLookup = 8
--AND ser.PROVIDER_TYPE_C IN ('1' , '4', '6', '9', '10','101','105','108','2','2506','2527','2721')  
AND COALESCE(ser.RPT_GRP_EIGHT,'0')	IN (SELECT value FROM STRING_SPLIT(@Departments,',')) -- says department but the department parameter does department and financial subdivision
--ORDER BY ser.PROV_NAME
) ProvidersValues

SELECT PROV_ID, PROV_NAME FROM @ProvidersSelect ORDER BY 2

DECLARE @Providers NVARCHAR(MAX)

SET @Providers = 
(
SELECT STRING_AGG(CONVERT(NVARCHAR(max), ISNULL(ProvidersSelect.PROV_ID,'N/A')), ',') AS csv
--FROM (SELECT TOP 5 PROV_ID FROM @ProvidersSelect ORDER BY NEWID()) ProvidersSelect
FROM (SELECT PROV_ID FROM @ProvidersSelect) ProvidersSelect
);

--SET @Providers = '62069' -- SINGLA, ANUJ
--SET @Providers = '478008' -- 	GRAVATTE IV, LEROY T	
--SET @Providers = '28837' -- 	LOCKMAN, ANDREW	
--SET @Providers = '28891' -- CASEY, CATHERINE

SELECT @Providers AS ProvidersSelect
;

WITH cte AS(
SELECT
       util.DEPARTMENT_ID
	 , util.PROV_ID
	 , util.UNAVAILABLE_RSN_C
	 , util.UNAVAILABLE_RSN_NAME
	 , emp.LAST_ACCS_DATE
	 , ser.PROV_NAME
	 , ser.STAFF_RESOURCE_C
	 , ser.STAFF_RESOURCE
	 , ser.PROVIDER_TYPE_C
	 , ser.PROV_TYPE
	 , ser.RPT_GRP_SIX
	 , ser.RPT_GRP_EIGHT
	 , CAST(util.SLOT_BEGIN_TIME AS DATE) AS SLOT_BEGIN_DATE
	 , util.SLOT_BEGIN_TIME
	 , MAX(util.SLOT_LENGTH) AS SLOT_LENGTH
	 , MAX(util.MAX_APPT_LENGTH) AS Booked_Length
	 , MAX(util.MAX_APPT_BLOCK_NAME) AS Template_Block_Name
	 , MAX(util.MAX_APPT_STATUS_NAME) AS Appt_Status_Name
	 , MAX(util.MAX_PRC_NAME) AS Visit_Name
	 , MAX(util.MAX_MRN) AS MRN
	 , SUM(util.[Regular Openings]) AS [Regular Openings]
	 , SUM(util.[Overbook Openings]) AS [Overbook Openings]
	 , SUM(util.NUM_APTS_SCHEDULED) AS NUM_APTS_SCHEDULED
	 , SUM(util.[Openings Booked]) AS [Openings Booked]
	 , SUM(util.[Regular Openings Available]) AS [Regular Openings Available]
	 , SUM(util.[Regular Openings Unavailable]) AS [Regular Openings Unavailable]
	 , SUM(util.[Overbook Openings Available]) AS [Overbook Openings Available]
	 , SUM(util.[Overbook Openings Unavailable]) AS [Overbook Openings Unavailable]
	 , MAX(util.APPT_OVERBOOK_YN) AS APPT_OVERBOOK_YN
	 , MAX(util.OUTSIDE_TEMPLATE_YN) AS OUTSIDE_TEMPLATE_YN
	 , SUM(util.[Regular Openings Booked]) AS [Regular Openings Booked]
	 , SUM(util.[Overbook Openings Booked]) AS [Overbook Openings Booked]
	 , SUM(util.[Regular Outside Template Booked]) AS [Regular Outside Template Booked]
	 , SUM(util.[Overbook Outside Template Booked]) AS [Overbook Outside Template Booked]
	 , SUM(util.[Regular Openings Available Booked]) AS [Regular Openings Available Booked]
	 , SUM(util.[Overbook Openings Available Booked]) AS [Overbook Openings Available Booked]
	 , SUM(util.[Regular Openings Unavailable Booked]) AS [Regular Openings Unavailable Booked]
	 , SUM(util.[Overbook Openings Unavailable Booked]) AS [Overbook Openings Unavailable Booked]
     , SUM(util.[Regular Outside Template Available Booked]) AS [Regular Outside Template Available Booked]
	 , SUM(util.[Overbook Outside Template Available Booked]) AS [Overbook Outside Template Available Booked]
     , SUM(util.[Regular Outside Template Unavailable Booked]) AS [Regular Outside Template Unavailable Booked]
	 , SUM(util.[Overbook Outside Template Unavailable Booked]) AS [Overbook Outside Template Unavailable Booked]
FROM
(
SELECT slot.DEPARTMENT_ID
	  ,slot.PROV_ID
	  ,slot.SLOT_BEGIN_TIME
	  ,slot.SLOT_LENGTH
	  ,appt.MAX_APPT_LENGTH
	  ,appt.MAX_APPT_BLOCK_NAME
	  ,appt.MAX_APPT_STATUS_NAME
	  ,appt.MAX_PRC_NAME
	  ,appt.MAX_MRN
	  ,slot.UNAVAILABLE_RSN_C
	  ,slot.UNAVAILABLE_RSN_NAME
	  ,slot.[Regular Openings]
	  ,slot.[Overbook Openings]
	  ,slot.NUM_APTS_SCHEDULED
	  ,slot.[Openings Booked]
	  ,slot.[Regular Openings Available]
	  ,slot.[Regular Openings Unavailable]
	  ,slot.[Overbook Openings Available]
	  ,slot.[Overbook Openings Unavailable]
	  ,slot.APPT_OVERBOOK_YN
	  ,slot.OUTSIDE_TEMPLATE_YN
	  ,COALESCE(appt.[Regular Openings Booked],0) AS [Regular Openings Booked]
	  ,COALESCE(appt.[Overbook Openings Booked],0) AS [Overbook Openings Booked]
	  ,COALESCE(appt.[Regular Outside Template Booked],0) AS [Regular Outside Template Booked]
	  ,COALESCE(appt.[Overbook Outside Template Booked],0) AS [Overbook Outside Template Booked]
	  ,COALESCE(appt.[Regular Openings Available Booked],0) AS [Regular Openings Available Booked]
	  ,COALESCE(appt.[Overbook Openings Available Booked],0) AS [Overbook Openings Available Booked]
	  ,COALESCE(appt.[Regular Openings Unavailable Booked],0) AS [Regular Openings Unavailable Booked]
	  ,COALESCE(appt.[Overbook Openings Unavailable Booked],0) AS [Overbook Openings Unavailable Booked]
      ,COALESCE(appt.[Regular Outside Template Available Booked],0) AS [Regular Outside Template Available Booked]
	  ,COALESCE(appt.[Overbook Outside Template Available Booked],0) AS [Overbook Outside Template Available Booked]
      ,COALESCE(appt.[Regular Outside Template Unavailable Booked],0) AS [Regular Outside Template Unavailable Booked]
	  ,COALESCE(appt.[Overbook Outside Template Unavailable Booked],0) AS [Overbook Outside Template Unavailable Booked]
FROM
(
	SELECT
	       [AVAILABILITY].DEPARTMENT_ID
	      ,[AVAILABILITY].PROV_ID
	      ,[AVAILABILITY].SLOT_BEGIN_TIME
		  ,[AVAILABILITY].SLOT_LENGTH
		  ,[AVAILABILITY].UNAVAILABLE_RSN_C
		  ,[AVAILABILITY].UNAVAILABLE_RSN_NAME
	      ,[AVAILABILITY].ORG_REG_OPENINGS AS [Regular Openings]
		  ,[AVAILABILITY].ORG_OVBK_OPENINGS AS [Overbook Openings]
	      ,[AVAILABILITY].NUM_APTS_SCHEDULED
	      ,[AVAILABILITY].NUM_APTS_SCHEDULED AS [Openings Booked]
	      ,CASE WHEN [AVAILABILITY].UNAVAILABLE_RSN_C IS NULL THEN [AVAILABILITY].ORG_REG_OPENINGS ELSE 0 END AS [Regular Openings Available]
	      ,CASE WHEN [AVAILABILITY].UNAVAILABLE_RSN_C IS NULL THEN [AVAILABILITY].ORG_OVBK_OPENINGS ELSE 0 END AS [Overbook Openings Available]
	      ,CASE WHEN [AVAILABILITY].UNAVAILABLE_RSN_C IS NOT NULL THEN [AVAILABILITY].ORG_REG_OPENINGS ELSE 0 END AS [Regular Openings Unavailable]
	      ,CASE WHEN [AVAILABILITY].UNAVAILABLE_RSN_C IS NOT NULL THEN [AVAILABILITY].ORG_OVBK_OPENINGS ELSE 0 END AS [Overbook Openings Unavailable]

		  ,COALESCE([AVAILABILITY].APPT_OVERBOOK_YN, 'N') AS APPT_OVERBOOK_YN
		  ,COALESCE([AVAILABILITY].OUTSIDE_TEMPLATE_YN, 'N') AS OUTSIDE_TEMPLATE_YN

    FROM  CLARITY.dbo.V_AVAILABILITY [AVAILABILITY]
		
    WHERE	1=1
	AND [AVAILABILITY].APPT_NUMBER = 0
    AND CAST(CAST([AVAILABILITY].SLOT_BEGIN_TIME AS DATE) AS DATETIME) >= @startdate
    AND CAST(CAST([AVAILABILITY].SLOT_BEGIN_TIME AS DATE) AS DATETIME) <  @enddate

    ORDER BY [AVAILABILITY].DEPARTMENT_ID
           , [AVAILABILITY].PROV_ID
	       , [AVAILABILITY].SLOT_BEGIN_TIME
		   , [AVAILABILITY].UNAVAILABLE_RSN_C
		   , [AVAILABILITY].UNAVAILABLE_RSN_NAME
		     OFFSET 0 ROWS

) slot
LEFT OUTER JOIN
(
    SELECT
	       [AVAILABILITY].DEPARTMENT_ID
		  ,[AVAILABILITY].PROV_ID
		  ,[AVAILABILITY].SLOT_BEGIN_TIME
		  ,SUM(CASE WHEN [AVAILABILITY].APPT_OVERBOOK_YN = 'N' AND [AVAILABILITY].OUTSIDE_TEMPLATE_YN = 'N' THEN 1 ELSE 0 END) AS [Regular Openings Booked]
	      ,SUM(CASE WHEN [AVAILABILITY].APPT_OVERBOOK_YN = 'Y' AND [AVAILABILITY].OUTSIDE_TEMPLATE_YN = 'N' THEN 1 ELSE 0 END) AS [Overbook Openings Booked]
		  ,SUM(CASE WHEN [AVAILABILITY].APPT_OVERBOOK_YN = 'N' AND [AVAILABILITY].OUTSIDE_TEMPLATE_YN = 'Y' THEN 1 ELSE 0 END) AS [Regular Outside Template Booked]
	      ,SUM(CASE WHEN [AVAILABILITY].APPT_OVERBOOK_YN = 'Y' AND [AVAILABILITY].OUTSIDE_TEMPLATE_YN = 'Y' THEN 1 ELSE 0 END) AS [Overbook Outside Template Booked]
		  ,SUM(CASE WHEN [AVAILABILITY].UNAVAILABLE_RSN_C IS NULL AND [AVAILABILITY].APPT_OVERBOOK_YN = 'N' AND [AVAILABILITY].OUTSIDE_TEMPLATE_YN = 'N' THEN 1 ELSE 0 END) AS [Regular Openings Available Booked]
	      ,SUM(CASE WHEN [AVAILABILITY].UNAVAILABLE_RSN_C IS NULL AND [AVAILABILITY].APPT_OVERBOOK_YN = 'Y' AND [AVAILABILITY].OUTSIDE_TEMPLATE_YN = 'N' THEN 1 ELSE 0 END) AS [Overbook Openings Available Booked]
		  ,SUM(CASE WHEN [AVAILABILITY].UNAVAILABLE_RSN_C IS NOT NULL AND [AVAILABILITY].APPT_OVERBOOK_YN = 'N' AND [AVAILABILITY].OUTSIDE_TEMPLATE_YN = 'N' THEN 1 ELSE 0 END) AS [Regular Openings Unavailable Booked]
	      ,SUM(CASE WHEN [AVAILABILITY].UNAVAILABLE_RSN_C IS NOT NULL AND [AVAILABILITY].APPT_OVERBOOK_YN = 'Y' AND [AVAILABILITY].OUTSIDE_TEMPLATE_YN = 'N' THEN 1 ELSE 0 END) AS [Overbook Openings Unavailable Booked]
		  ,SUM(CASE WHEN [AVAILABILITY].UNAVAILABLE_RSN_C IS NULL AND [AVAILABILITY].APPT_OVERBOOK_YN = 'N' AND [AVAILABILITY].OUTSIDE_TEMPLATE_YN = 'Y' THEN 1 ELSE 0 END) AS [Regular Outside Template Available Booked]
	      ,SUM(CASE WHEN [AVAILABILITY].UNAVAILABLE_RSN_C IS NULL AND [AVAILABILITY].APPT_OVERBOOK_YN = 'Y' AND [AVAILABILITY].OUTSIDE_TEMPLATE_YN = 'Y' THEN 1 ELSE 0 END) AS [Overbook Outside Template Available Booked]
		  ,SUM(CASE WHEN [AVAILABILITY].UNAVAILABLE_RSN_C IS NOT NULL AND [AVAILABILITY].APPT_OVERBOOK_YN = 'N' AND [AVAILABILITY].OUTSIDE_TEMPLATE_YN = 'Y' THEN 1 ELSE 0 END) AS [Regular Outside Template Unavailable Booked]
	      ,SUM(CASE WHEN [AVAILABILITY].UNAVAILABLE_RSN_C IS NOT NULL AND [AVAILABILITY].APPT_OVERBOOK_YN = 'Y' AND [AVAILABILITY].OUTSIDE_TEMPLATE_YN = 'Y' THEN 1 ELSE 0 END) AS [Overbook Outside Template Unavailable Booked]

		  ,MAX(APPT.APPT_LENGTH) AS MAX_APPT_LENGTH

		  ,MAX(APPT.APPT_BLOCK_NAME) AS MAX_APPT_BLOCK_NAME
		  ,MAX(APPT.APPT_STATUS_NAME) AS MAX_APPT_STATUS_NAME
		  ,MAX(APPT.PRC_NAME) AS MAX_PRC_NAME
		  ,MAX(IDENTITY_ID.IDENTITY_ID) AS MAX_MRN

    FROM  CLARITY.dbo.V_AVAILABILITY [AVAILABILITY]
	LEFT OUTER JOIN clarity..V_SCHED_APPT [APPT]						ON [APPT].PAT_ENC_CSN_ID = [AVAILABILITY].PAT_ENC_CSN_ID
	LEFT OUTER JOIN CLARITY..PATIENT PATIENT					ON [APPT].PAT_ID = PATIENT.PAT_ID
	LEFT OUTER JOIN CLARITY..IDENTITY_ID						ON IDENTITY_ID.PAT_ID = [APPT].PAT_ID AND IDENTITY_ID.IDENTITY_TYPE_ID = 14
		
    WHERE	1=1
	AND [AVAILABILITY].APPT_NUMBER > 0
    AND CAST(CAST([AVAILABILITY].SLOT_BEGIN_TIME AS DATE) AS DATETIME) >= @startdate
    AND CAST(CAST([AVAILABILITY].SLOT_BEGIN_TIME AS DATE) AS DATETIME) <  @enddate

    GROUP BY [AVAILABILITY].DEPARTMENT_ID
           , [AVAILABILITY].PROV_ID
	       , [AVAILABILITY].SLOT_BEGIN_TIME

    ORDER BY [AVAILABILITY].DEPARTMENT_ID
           , [AVAILABILITY].PROV_ID
	       , [AVAILABILITY].SLOT_BEGIN_TIME
		     OFFSET 0 ROWS

) appt
ON ((appt.DEPARTMENT_ID = slot.DEPARTMENT_ID)
    AND (appt.PROV_ID = slot.PROV_ID)
	AND (appt.SLOT_BEGIN_TIME = slot.SLOT_BEGIN_TIME)
	  )
) util

LEFT OUTER JOIN
(
SELECT
	PROV_ID,
	CAST(LAST_ACCS_DATETIME AS DATE) AS LAST_ACCS_DATE
FROM CLARITY.dbo.CLARITY_EMP
) emp
ON emp.PROV_ID = util.PROV_ID

LEFT OUTER JOIN
(
SELECT
	PROV_ID,
	PROV_NAME,
	STAFF_RESOURCE_C,
	STAFF_RESOURCE,
	PROVIDER_TYPE_C,
	PROV_TYPE,
	RPT_GRP_SIX,
	RPT_GRP_EIGHT
FROM CLARITY.dbo.CLARITY_SER
) ser
ON ser.PROV_ID = util.PROV_ID

WHERE	1=1
AND (ser.STAFF_RESOURCE = 'Resource' -- 03/27/2023 include non-Person resource types; non-Person providers will not have a LAST_ACCS_DATE value
OR CAST(util.SLOT_BEGIN_TIME AS DATE) <= emp.LAST_ACCS_DATE) -- 02/22/23 Exclude templates with slot dates after a provider's last Epic access
AND ( 
		(@HierarchyLookup <> 8 AND util.DEPARTMENT_ID IN (SELECT value FROM STRING_SPLIT(@Departments,',')))
		OR
		(@HierarchyLookup = 8 AND COALESCE(ser.RPT_GRP_EIGHT,'0')	IN (SELECT value FROM STRING_SPLIT(@Departments,',')) ) -- says department but the department parameter does department and financial subdivision
				
	)
AND util.PROV_ID IN (SELECT value FROM STRING_SPLIT(@Providers,','))

--GROUP BY util.DEPARTMENT_ID
--       , util.PROV_ID
--	   , emp.LAST_ACCS_DATE
--	   , ser.PROV_NAME
--	   , ser.STAFF_RESOURCE_C
--	   , ser.STAFF_RESOURCE
--	   , ser.PROVIDER_TYPE_C
--	   , ser.PROV_TYPE
--	   , ser.RPT_GRP_SIX
--	   , ser.RPT_GRP_EIGHT
--	   , CAST(util.SLOT_BEGIN_TIME AS DATE)
--	   , util.UNAVAILABLE_RSN_C
--	   , util.UNAVAILABLE_RSN_NAME
GROUP BY util.DEPARTMENT_ID
       , util.PROV_ID
	   , emp.LAST_ACCS_DATE
	   , ser.PROV_NAME
	   , ser.STAFF_RESOURCE_C
	   , ser.STAFF_RESOURCE
	   , ser.PROVIDER_TYPE_C
	   , ser.PROV_TYPE
	   , ser.RPT_GRP_SIX
	   , ser.RPT_GRP_EIGHT
	   , CAST(util.SLOT_BEGIN_TIME AS DATE)
	   , util.SLOT_BEGIN_TIME
	   , util.UNAVAILABLE_RSN_C
	   , util.UNAVAILABLE_RSN_NAME
)
/*
SELECT
	tabrptg.event_type,
    tabrptg.event_count,
    tabrptg.event_date,
    tabrptg.fmonth_num,
    tabrptg.Fyear_num,
    tabrptg.FYear_name,
    tabrptg.report_period,
    tabrptg.report_date,
    --tabrptg.event_category,
    tabrptg.pod_id,
    tabrptg.pod_name,
    tabrptg.hub_id,
    tabrptg.hub_name,
    tabrptg.epic_department_id,
    tabrptg.epic_department_name,
    tabrptg.epic_department_name_external,
    --tabrptg.peds,
    --tabrptg.transplant,
    --tabrptg.sk_Dim_pt,
    --tabrptg.sk_Fact_Pt_Acct,
    --tabrptg.sk_Fact_Pt_Enc_Clrt,
    --tabrptg.person_birth_date,
    --tabrptg.person_gender,
    --tabrptg.person_id,
    --tabrptg.person_name,
    --tabrptg.practice_group_id,
    --tabrptg.practice_group_name,
    tabrptg.provider_id,
    tabrptg.provider_name,
    --tabrptg.SERVICE_LINE_ID,
    --tabrptg.SERVICE_LINE,
    --tabrptg.prov_service_line_id,
    --tabrptg.prov_service_line,
    --tabrptg.SUB_SERVICE_LINE_ID,
    --tabrptg.SUB_SERVICE_LINE,
    --tabrptg.OPNL_SERVICE_ID,
    --tabrptg.OPNL_SERVICE_NAME,
    --tabrptg.CORP_SERVICE_LINE_ID,
    --tabrptg.CORP_SERVICE_LINE,
    tabrptg.HS_AREA_ID,
    tabrptg.HS_AREA_NAME,
    --tabrptg.prov_hs_area_id,
    --tabrptg.prov_hs_area_name,
    tabrptg.[Regular Openings],
    tabrptg.[Overbook Openings],
    tabrptg.[Openings Booked],
    tabrptg.[Regular Openings Available],
    tabrptg.[Regular Openings Unavailable],
    tabrptg.[Overbook Openings Available],
    tabrptg.[Overbook Openings Unavailable],
    tabrptg.[Regular Openings Booked],
    tabrptg.[Overbook Openings Booked],
    tabrptg.[Regular Outside Template Booked],
    tabrptg.[Overbook Outside Template Booked],
    tabrptg.[Regular Openings Available Booked],
    tabrptg.[Overbook Openings Available Booked],
    tabrptg.[Regular Openings Unavailable Booked],
    tabrptg.[Overbook Openings Unavailable Booked],
    tabrptg.[Regular Outside Template Available Booked],
    tabrptg.[Overbook Outside Template Available Booked],
    tabrptg.[Regular Outside Template Unavailable Booked],
    tabrptg.[Overbook Outside Template Unavailable Booked],
    tabrptg.STAFF_RESOURCE_C,
    tabrptg.STAFF_RESOURCE,
    tabrptg.PROVIDER_TYPE_C,
    tabrptg.PROV_TYPE,
    tabrptg.rev_location_id,
    tabrptg.rev_location,
    tabrptg.financial_division_id,
    tabrptg.financial_division_name,
    tabrptg.financial_sub_division_id,
    tabrptg.financial_sub_division_name,
    tabrptg.som_group_id,
    tabrptg.som_group_name,
    tabrptg.som_department_id,
    tabrptg.som_department_name,
    tabrptg.som_division_id,
    tabrptg.som_division_name,
    tabrptg.som_hs_area_id,
    tabrptg.som_hs_area_name,
    tabrptg.BUSINESS_UNIT,
    tabrptg.upg_practice_flag,
    tabrptg.upg_practice_region_id,
    tabrptg.upg_practice_region_name,
    tabrptg.upg_practice_id,
    tabrptg.upg_practice_name,
    --tabrptg.SUBLOC_ID,
    --tabrptg.SUBLOC_NAME,
	CASE WHEN tabrptg.PROV_TYPE IN ('NURSE PRACTITIONER','PHYSICIAN ASSISTANT','NURSE ANESTHETIST','CLINICAL NURSE SPECIALIST','GENETIC COUNSELOR','AUDIOLOGIST') THEN 1 ELSE 0 END AS app_flag,
	tabrptg.UNAVAILABLE_RSN_C,
	tabrptg.UNAVAILABLE_RSN_NAME,
	CASE WHEN UNAVAILABLE_RSN_C IN
(
 1 -- PTO/Sick/Vacation
,4 --	CTT ONLY - Holiday
,9 --	CME/MOC
,14 -- CTT ONLY - Attending/Precepting
,24 -- Facility Issue
,131 --	CTT ONLY - Template Optimization  
, 21 -- CTT ONLY - Grand Rounds
, 23 -- Protected Leave
, 135 -- CTT ONLY - Remote Outreach Clinic
, 136 -- CTT ONLY - Add-On Session
, 138 -- CTT ONLY - Approved Meetings
, 139 -- Scheduled Inpatient Shifts
)
			   THEN 0 -- Not included in denominator calculation
			   ELSE 1 -- Included in denominator calculation
	END AS AMB_Scorecard_Flag,

	tabrptg.ambulatory_flag,
	tabrptg.clinical_area_name,

	[Openings Booked] AS Numerator,
	[Regular Openings Available] +
	CASE WHEN CASE WHEN UNAVAILABLE_RSN_C IN
(
 1 -- PTO/Sick/Vacation
,4 --	CTT ONLY - Holiday
,9 --	CME/MOC
,14 -- CTT ONLY - Attending/Precepting
,24 -- Facility Issue
,131 --	CTT ONLY - Template Optimization  
, 21 -- CTT ONLY - Grand Rounds
, 23 -- Protected Leave
, 135 -- CTT ONLY - Remote Outreach Clinic
, 136 -- CTT ONLY - Add-On Session
, 138 -- CTT ONLY - Approved Meetings
, 139 -- Scheduled Inpatient Shifts
)
--OR
--UNAVAILABLE_RSN_NAME IN
--(
-- 'CTT ONLY - Commute to Outreach Clinic'
--,'CTT ONLY - Add-On Session'
--)
			   THEN 0 -- Not included in denominator calculation
			   ELSE 1 -- Included in denominator calculation
	END = 1 THEN tabrptg.[Regular Openings Unavailable] ELSE 0 END AS Denominator
*/
/*
SELECT
	tabrptg.event_type,
    tabrptg.event_count,
    tabrptg.epic_department_id,
    tabrptg.epic_department_name,
	tabrptg.dep_epic_department_name,
    tabrptg.epic_department_name_external,
    tabrptg.dep_epic_department_name_external,
    tabrptg.provider_id,
    tabrptg.provider_name,
    tabrptg.event_date,
	tabrptg.SLOT_BEGIN_TIME,
	tabrptg.SLOT_LENGTH,
	tabrptg.Booked_Length,
	tabrptg.NUM_APTS_SCHEDULED,
	tabrptg.Template_Block_Name,
	tabrptg.Appt_Status_Name,
	tabrptg.Visit_Name,
	tabrptg.MRN,
    tabrptg.fmonth_num,
    tabrptg.Fyear_num,
    tabrptg.FYear_name,
    tabrptg.report_period,
    tabrptg.report_date,
    tabrptg.[Regular Openings],
    tabrptg.[Regular Openings Available],
    tabrptg.[Regular Openings Unavailable],
    tabrptg.[Openings Booked],
    tabrptg.[Regular Openings Booked],
    tabrptg.[Overbook Openings Booked],
    tabrptg.[Regular Outside Template Booked],
    tabrptg.[Overbook Outside Template Booked],
    tabrptg.[Regular Openings Available Booked],
    tabrptg.[Overbook Openings Available Booked],
    tabrptg.[Regular Openings Unavailable Booked],
    tabrptg.[Overbook Openings Unavailable Booked],
    tabrptg.[Regular Outside Template Available Booked],
    tabrptg.[Overbook Outside Template Available Booked],
    tabrptg.[Regular Outside Template Unavailable Booked],
    tabrptg.[Overbook Outside Template Unavailable Booked],
	tabrptg.UNAVAILABLE_RSN_C,
	tabrptg.UNAVAILABLE_RSN_NAME,
	CASE WHEN UNAVAILABLE_RSN_C IN
(
 1 -- PTO/Sick/Vacation
,4 --	CTT ONLY - Holiday
,9 --	CME/MOC
,14 -- CTT ONLY - Attending/Precepting
,24 -- Facility Issue
,131 --	CTT ONLY - Template Optimization  
, 21 -- CTT ONLY - Grand Rounds
, 23 -- Protected Leave
, 135 -- CTT ONLY - Remote Outreach Clinic
, 136 -- CTT ONLY - Add-On Session
, 138 -- CTT ONLY - Approved Meetings
, 139 -- Scheduled Inpatient Shifts
)
			   THEN 0 -- Not included in denominator calculation
			   ELSE 1 -- Included in denominator calculation
	END AS AMB_Scorecard_Flag,
	[Openings Booked] AS Numerator,
	[Regular Openings Available] +
	CASE WHEN CASE WHEN UNAVAILABLE_RSN_C IN
(
 1 -- PTO/Sick/Vacation
,4 --	CTT ONLY - Holiday
,9 --	CME/MOC
,14 -- CTT ONLY - Attending/Precepting
,24 -- Facility Issue
,131 --	CTT ONLY - Template Optimization  
, 21 -- CTT ONLY - Grand Rounds
, 23 -- Protected Leave
, 135 -- CTT ONLY - Remote Outreach Clinic
, 136 -- CTT ONLY - Add-On Session
, 138 -- CTT ONLY - Approved Meetings
, 139 -- Scheduled Inpatient Shifts
)
--OR
--UNAVAILABLE_RSN_NAME IN
--(
-- 'CTT ONLY - Commute to Outreach Clinic'
--,'CTT ONLY - Add-On Session'
--)
			   THEN 0 -- Not included in denominator calculation
			   ELSE 1 -- Included in denominator calculation
	END = 1 THEN tabrptg.[Regular Openings Unavailable] ELSE 0 END AS Denominator,
    tabrptg.pod_id,
    tabrptg.pod_name,
    tabrptg.hub_id,
    tabrptg.hub_name,
    tabrptg.HS_AREA_ID,
    tabrptg.HS_AREA_NAME,
    tabrptg.[Overbook Openings],
    tabrptg.[Overbook Openings Available],
    tabrptg.[Overbook Openings Unavailable],
    tabrptg.STAFF_RESOURCE_C,
    tabrptg.STAFF_RESOURCE,
    tabrptg.PROVIDER_TYPE_C,
    tabrptg.PROV_TYPE,
    tabrptg.rev_location_id,
    tabrptg.rev_location,
    tabrptg.financial_division_id,
    tabrptg.financial_division_name,
    tabrptg.financial_sub_division_id,
    tabrptg.financial_sub_division_name,
    tabrptg.som_group_id,
    tabrptg.som_group_name,
    tabrptg.som_department_id,
    tabrptg.som_department_name,
    tabrptg.som_division_id,
    tabrptg.som_division_name,
    tabrptg.som_hs_area_id,
    tabrptg.som_hs_area_name,
    tabrptg.BUSINESS_UNIT,
    tabrptg.upg_practice_flag,
    tabrptg.upg_practice_region_id,
    tabrptg.upg_practice_region_name,
    tabrptg.upg_practice_id,
    tabrptg.upg_practice_name,
	CASE WHEN tabrptg.PROV_TYPE IN ('NURSE PRACTITIONER','PHYSICIAN ASSISTANT','NURSE ANESTHETIST','CLINICAL NURSE SPECIALIST','GENETIC COUNSELOR','AUDIOLOGIST') THEN 1 ELSE 0 END AS app_flag,
	tabrptg.ambulatory_flag,
	tabrptg.clinical_area_name
*/
SELECT
	tabrptg.event_type,
    --tabrptg.event_count,
    tabrptg.financial_division_id,
    tabrptg.financial_division_name,
    tabrptg.financial_sub_division_id,
    tabrptg.financial_sub_division_name,
    tabrptg.epic_department_id,
    --tabrptg.epic_department_name,
	tabrptg.dep_epic_department_name AS epic_department_name,
    --tabrptg.epic_department_name_external,
    tabrptg.dep_epic_department_name_external AS epic_department_name_external,
    --tabrptg.pod_name,
	tabrptg.dep_pod_name AS pod_name,
    tabrptg.provider_id,
    tabrptg.provider_name,
    tabrptg.PROV_TYPE AS provider_type,
    tabrptg.STAFF_RESOURCE AS person_or_resource,
	tabrptg.day_of_week,
    tabrptg.event_date AS slot_date,
	tabrptg.SLOT_BEGIN_TIME AS slot_begin_time,
	tabrptg.SLOT_LENGTH AS slot_length,
	tabrptg.Booked_Length AS booked_length,
	tabrptg.NUM_APTS_SCHEDULED AS num_apts_scheduled,
    tabrptg.[Regular Openings] AS regular_openings,
    tabrptg.[Regular Openings Available] AS regular_openings_available,
    tabrptg.[Regular Openings Unavailable] AS regular_openings_unavailable,
    tabrptg.[Overbook Openings] AS overbook_openings,
	tabrptg.Template_Block_Name AS template_block_name,
	tabrptg.UNAVAILABLE_RSN_NAME AS unavailable_reason,
	tabrptg.APPT_OVERBOOK_YN AS overbook_yn,
	tabrptg.OUTSIDE_TEMPLATE_YN AS outside_template_yn,
	[Openings Booked] AS slot_rate_numerator,
	[Regular Openings Available] +
	CASE WHEN CASE WHEN UNAVAILABLE_RSN_C IN
(
 1 -- PTO/Sick/Vacation
,4 --	CTT ONLY - Holiday
,9 --	CME/MOC
,14 -- CTT ONLY - Attending/Precepting
,24 -- Facility Issue
,131 --	CTT ONLY - Template Optimization  
, 21 -- CTT ONLY - Grand Rounds
, 23 -- Protected Leave
, 135 -- CTT ONLY - Remote Outreach Clinic
, 136 -- CTT ONLY - Add-On Session
, 138 -- CTT ONLY - Approved Meetings
, 139 -- Scheduled Inpatient Shifts
)
--OR
--UNAVAILABLE_RSN_NAME IN
--(
-- 'CTT ONLY - Commute to Outreach Clinic'
--,'CTT ONLY - Add-On Session'
--)
			   THEN 0 -- Not included in denominator calculation
			   ELSE 1 -- Included in denominator calculation
	END = 1 THEN tabrptg.[Regular Openings Unavailable] ELSE 0 END AS slot_rate_denominator,
	tabrptg.MRN,
	tabrptg.Visit_Name AS visit_type,
	tabrptg.Appt_Status_Name AS appt_status--,
--    tabrptg.fmonth_num,
--    tabrptg.Fyear_num,
--    tabrptg.FYear_name,
--    tabrptg.report_period,
--    tabrptg.report_date,
--    tabrptg.[Openings Booked],
--    tabrptg.[Regular Openings Booked],
--    tabrptg.[Overbook Openings Booked],
--    tabrptg.[Regular Outside Template Booked],
--    tabrptg.[Overbook Outside Template Booked],
--    tabrptg.[Regular Openings Available Booked],
--    tabrptg.[Overbook Openings Available Booked],
--    tabrptg.[Regular Openings Unavailable Booked],
--    tabrptg.[Overbook Openings Unavailable Booked],
--    tabrptg.[Regular Outside Template Available Booked],
--    tabrptg.[Overbook Outside Template Available Booked],
--    tabrptg.[Regular Outside Template Unavailable Booked],
--    tabrptg.[Overbook Outside Template Unavailable Booked],
--	tabrptg.UNAVAILABLE_RSN_C,
--	CASE WHEN UNAVAILABLE_RSN_C IN
--(
-- 1 -- PTO/Sick/Vacation
--,4 --	CTT ONLY - Holiday
--,9 --	CME/MOC
--,14 -- CTT ONLY - Attending/Precepting
--,24 -- Facility Issue
--,131 --	CTT ONLY - Template Optimization  
--, 21 -- CTT ONLY - Grand Rounds
--, 23 -- Protected Leave
--, 135 -- CTT ONLY - Remote Outreach Clinic
--, 136 -- CTT ONLY - Add-On Session
--, 138 -- CTT ONLY - Approved Meetings
--, 139 -- Scheduled Inpatient Shifts
--)
--			   THEN 0 -- Not included in denominator calculation
--			   ELSE 1 -- Included in denominator calculation
--	END AS AMB_Scorecard_Flag,
--    tabrptg.pod_id,
--    tabrptg.hub_id,
--    tabrptg.hub_name,
--    tabrptg.HS_AREA_ID,
--    tabrptg.HS_AREA_NAME,
--    tabrptg.[Overbook Openings Available],
--    tabrptg.[Overbook Openings Unavailable],
--    tabrptg.STAFF_RESOURCE_C,
--    tabrptg.PROVIDER_TYPE_C,
--    tabrptg.rev_location_id,
--    tabrptg.rev_location,
--    tabrptg.som_group_id,
--    tabrptg.som_group_name,
--    tabrptg.som_department_id,
--    tabrptg.som_department_name,
--    tabrptg.som_division_id,
--    tabrptg.som_division_name,
--    tabrptg.som_hs_area_id,
--    tabrptg.som_hs_area_name,
--    tabrptg.BUSINESS_UNIT,
--    tabrptg.upg_practice_flag,
--    tabrptg.upg_practice_region_id,
--    tabrptg.upg_practice_region_name,
--    tabrptg.upg_practice_id,
--    tabrptg.upg_practice_name,
--	CASE WHEN tabrptg.PROV_TYPE IN ('NURSE PRACTITIONER','PHYSICIAN ASSISTANT','NURSE ANESTHETIST','CLINICAL NURSE SPECIALIST','GENETIC COUNSELOR','AUDIOLOGIST') THEN 1 ELSE 0 END AS app_flag,
--	tabrptg.ambulatory_flag,
--	tabrptg.clinical_area_name

INTO #util

FROM
(
SELECT 
       CAST('Slot Utilization' AS VARCHAR(50)) AS event_type
      ,CASE WHEN util.SLOT_BEGIN_DATE IS NOT NULL THEN 1
            ELSE 0
       END AS event_count
      ,date_dim.day_date AS event_date
	  ,util.SLOT_BEGIN_TIME
	  ,util.SLOT_LENGTH
	  ,util.Booked_Length
	  ,util.Template_Block_Name
	  ,util.Appt_Status_Name
	  ,util.Visit_Name
	  ,util.MRN
      ,date_dim.fmonth_num
      ,date_dim.Fyear_num
      ,date_dim.FYear_name
	  ,date_dim.day_of_week
      ,CAST(LEFT(DATENAME(MM, date_dim.day_date), 3) + ' ' + CAST(DAY(date_dim.day_date) AS VARCHAR(2)) AS VARCHAR(10)) AS report_period
      ,CAST(CAST(date_dim.day_date AS DATE) AS SMALLDATETIME) AS report_date
	  ,CAST(NULL AS VARCHAR(150)) AS event_category
	  ,mdm.POD_ID AS pod_id
      ,mdm.PFA_POD AS pod_name
	  ,ZC_DEP_RPT_GRP_6.name AS dep_pod_name
	  ,mdm.HUB_ID AS hub_id
	  ,mdm.HUB AS hub_name
      ,util.DEPARTMENT_ID AS epic_department_id
      ,mdm.EPIC_DEPT_NAME AS epic_department_name
	  ,[DEP].DEPARTMENT_NAME AS dep_epic_department_name
      ,mdm.EPIC_EXT_NAME AS epic_department_name_external
	  ,[DEP].EXTERNAL_NAME AS dep_epic_department_name_external
      --,util.peds
      --,util.transplant
      --,util.sk_Dim_Pt
      --,util.sk_Fact_Pt_Acct
      --,util.sk_Fact_Pt_Enc_Clrt
      --,util.person_birth_date
      --,util.person_gender
      --,util.person_id
      --,util.person_name
      --,util.practice_group_id
      --,util.practice_group_name
	  ,util.PROV_ID AS provider_id
      ,ser.PROV_NAME AS provider_name
   --   ,mdm.service_line_id
   --   ,mdm.service_line
	  --,physcn.Service_Line_ID AS prov_service_line_id
	  --,physcn.Service_Line AS prov_service_line
   --   ,mdm.sub_service_line_id
   --   ,mdm.sub_service_line
   --   ,mdm.opnl_service_id
   --   ,mdm.opnl_service_name
   --   ,mdm.corp_service_line_id
   --   ,mdm.corp_service_line
      ,mdm.hs_area_id
      ,mdm.hs_area_name
	  --,physcn.hs_area_id AS prov_hs_area_id
	  --,physcn.hs_area_name AS prov_hs_area_name
	  ,util.[Regular Openings]
	  ,util.[Overbook Openings]
	  ,util.NUM_APTS_SCHEDULED
	  ,util.[Openings Booked]
	  ,util.[Regular Openings Available]
	  ,util.[Regular Openings Unavailable]
	  ,util.[Overbook Openings Available]
	  ,util.[Overbook Openings Unavailable]
	  ,util.APPT_OVERBOOK_YN
	  ,util.OUTSIDE_TEMPLATE_YN
	  ,util.[Regular Openings Booked]
	  ,util.[Overbook Openings Booked]
	  ,util.[Regular Outside Template Booked]
	  ,util.[Overbook Outside Template Booked]
	  ,util.[Regular Openings Available Booked]
	  ,util.[Overbook Openings Available Booked]
	  ,util.[Regular Openings Unavailable Booked]
	  ,util.[Overbook Openings Unavailable Booked]
      ,util.[Regular Outside Template Available Booked]
	  ,util.[Overbook Outside Template Available Booked]
      ,util.[Regular Outside Template Unavailable Booked]
	  ,util.[Overbook Outside Template Unavailable Booked]
	  ,util.STAFF_RESOURCE_C
	  ,util.STAFF_RESOURCE
	  ,COALESCE(ptot.PROV_TYPE_OT_C, util.PROVIDER_TYPE_C, NULL) AS PROVIDER_TYPE_C
	  ,COALESCE(ptot.PROV_TYPE_OT_NAME, util.PROV_TYPE, NULL) AS PROV_TYPE
	  ,mdm.LOC_ID AS rev_location_id
	  ,mdm.REV_LOC_NAME AS rev_location
	  ,TRY_CAST(ser.RPT_GRP_SIX AS INT) AS financial_division_id
	  ,CAST(dvsn.Epic_Financial_Division AS VARCHAR(150)) AS financial_division_name
	  ,TRY_CAST(ser.RPT_GRP_EIGHT AS INT) AS financial_sub_division_id
	  ,CAST(dvsn.Epic_Financial_SubDivision AS VARCHAR(150)) AS financial_sub_division_name
	  ,dvsn.som_group_id
	  ,dvsn.som_group_name
	  ,dvsn.Department_ID AS som_department_id
  	  ,CAST(dvsn.Department AS VARCHAR(150)) AS som_department_name
	  ,CAST(dvsn.Org_Number AS INT) AS som_division_id
	  ,CAST(dvsn.Organization AS VARCHAR(150)) AS som_division_name
	  ,dvsn.som_hs_area_id
	  ,dvsn.som_hs_area_name
	  ,mdm.BUSINESS_UNIT
      ,mdm.upg_practice_flag
      ,mdm.upg_practice_region_id
      ,mdm.upg_practice_region_name
      ,mdm.upg_practice_id
      ,mdm.upg_practice_name
	  --,supp.SUBLOC_ID
	  --,supp.SUBLOC_NAME
	  ,util.UNAVAILABLE_RSN_C
	  ,util.UNAVAILABLE_RSN_NAME

	  ,g.ambulatory_flag
	  --,o.organization_name
	  --,s.service_name
	  ,c.clinical_area_name

FROM
    CLARITY_App.Rptg.vwDim_Date AS date_dim
INNER JOIN
(
    SELECT DISTINCT
           --main.DEPARTMENT_ID AS epic_department_id
           main.DEPARTMENT_ID
    --      ,CAST(NULL AS SMALLINT) AS peds
    --      ,CAST(NULL AS SMALLINT) AS transplant
	   --   ,CAST(NULL AS INTEGER) AS sk_Dim_pt
		  --,CAST(NULL AS INTEGER) AS sk_Fact_Pt_Acct
		  --,CAST(NULL AS INTEGER) AS sk_Fact_Pt_Enc_Clrt
		  --,CAST(NULL AS DATE) AS person_birth_date
		  --,CAST(NULL AS VARCHAR(254)) AS person_gender
		  --,CAST(NULL AS INTEGER) AS person_id
		  --,CAST(NULL AS VARCHAR(200)) AS person_name
    --      ,CAST(NULL AS INT) AS practice_group_id
    --      ,CAST(NULL AS VARCHAR(150)) AS practice_group_name
          --,main.PROV_ID AS provider_id
          ,main.PROV_ID
		  ,main.PROV_NAME
		  ,main.STAFF_RESOURCE_C
		  ,main.STAFF_RESOURCE
		  ,main.PROVIDER_TYPE_C
		  ,main.PROV_TYPE
		  ,main.RPT_GRP_SIX
		  ,main.RPT_GRP_EIGHT
--Select
          ,main.SLOT_BEGIN_DATE
		  ,main.SLOT_BEGIN_TIME
		  ,main.SLOT_LENGTH
		  ,main.Booked_Length
		  ,main.Template_Block_Name
		  ,main.Appt_Status_Name
		  ,main.Visit_Name
		  ,main.MRN
		  ,main.UNAVAILABLE_RSN_C
		  ,main.UNAVAILABLE_RSN_NAME
	      ,main.[Regular Openings]
	      ,main.[Overbook Openings]
		  ,main.NUM_APTS_SCHEDULED
	      ,main.[Openings Booked]
	      ,main.[Regular Openings Available]
	      ,main.[Regular Openings Unavailable]
	      ,main.[Overbook Openings Available]
	      ,main.[Overbook Openings Unavailable]
		  ,main.APPT_OVERBOOK_YN
		  ,main.OUTSIDE_TEMPLATE_YN
	      ,main.[Regular Openings Booked]
	      ,main.[Overbook Openings Booked]
	      ,main.[Regular Outside Template Booked]
	      ,main.[Overbook Outside Template Booked]
	      ,main.[Regular Openings Available Booked]
	      ,main.[Overbook Openings Available Booked]
	      ,main.[Regular Openings Unavailable Booked]
	      ,main.[Overbook Openings Unavailable Booked]
          ,main.[Regular Outside Template Available Booked]
	      ,main.[Overbook Outside Template Available Booked]
          ,main.[Regular Outside Template Unavailable Booked]
	      ,main.[Overbook Outside Template Unavailable Booked]

    FROM
        cte AS main -- main

) util
ON  (date_dim.day_date = CAST(util.SLOT_BEGIN_DATE AS SMALLDATETIME))

LEFT OUTER JOIN Stage.AmbOpt_Excluded_Department excl
ON excl.DEPARTMENT_ID = util.DEPARTMENT_ID
LEFT OUTER JOIN CLARITY.dbo.CLARITY_SER AS ser
ON ser.PROV_ID = util.PROV_ID
LEFT OUTER JOIN Rptg.vwCLARITY_SER_OT_PROV_TYPE ptot
ON util.PROV_ID = ptot.PROV_ID AND date_dim.day_date BETWEEN ptot.CONTACT_DATE AND ptot.EFF_TO_DATE
LEFT OUTER JOIN
(
    SELECT ROW_NUMBER() OVER (PARTITION BY EPIC_DEPARTMENT_ID ORDER BY HS_AREA_ID DESC) AS Seq
	      ,POD_ID
	      ,PFA_POD
	      ,HUB_ID
	      ,HUB
          ,[EPIC_DEPARTMENT_ID]
          ,[EPIC_DEPT_NAME]
          ,[EPIC_EXT_NAME]
          ,[LOC_ID]
          ,[REV_LOC_NAME]
          ,service_line_id
          ,service_line
          ,sub_service_line_id
          ,sub_service_line
          ,opnl_service_id
          ,opnl_service_name
          ,corp_service_line_id
          ,corp_service_line
          ,hs_area_id
          ,hs_area_name
		  ,BUSINESS_UNIT
		  ,UPG_PRACTICE_FLAG AS upg_practice_flag
		  ,CAST(UPG_PRACTICE_REGION_ID AS INTEGER) AS upg_practice_region_id
		  ,CAST(UPG_PRACTICE_REGION_NAME AS VARCHAR(150)) AS upg_practice_region_name
		  ,CAST(UPG_PRACTICE_ID AS INTEGER) AS upg_practice_id
		  ,CAST(UPG_PRACTICE_NAME AS VARCHAR(150)) AS upg_practice_name
	FROM
    (
        SELECT DISTINCT
		       POD_ID
	          ,PFA_POD
	          ,HUB_ID
	          ,HUB
              ,[EPIC_DEPARTMENT_ID]
              ,[EPIC_DEPT_NAME]
              ,[EPIC_EXT_NAME]
              ,[LOC_ID]
              ,[REV_LOC_NAME]
              ,service_line_id
              ,service_line
              ,sub_service_line_id
              ,sub_service_line
              ,opnl_service_id
              ,opnl_service_name
              ,corp_service_line_id
              ,corp_service_line
              ,hs_area_id
              ,hs_area_name
			  ,BUSINESS_UNIT
			  ,UPG_PRACTICE_FLAG
			  ,UPG_PRACTICE_REGION_ID
			  ,UPG_PRACTICE_REGION_NAME
			  ,UPG_PRACTICE_ID
			  ,UPG_PRACTICE_NAME
	    FROM CLARITY_App.Rptg.vwRef_MDM_Location_Master) mdm_LM
) AS mdm
ON (mdm.EPIC_DEPARTMENT_ID = util.DEPARTMENT_ID)
AND mdm.Seq = 1

                -- -------------------------------------
                -- SOM Hierarchy--
                -- -------------------------------------
				--LEFT OUTER JOIN CLARITY_App.Rptg.vwRef_Physcn_Combined physcn
				--    ON physcn.PROV_ID = util.PROV_ID

                -- -------------------------------------
                -- SOM Financial Division Subdivision--
                -- -------------------------------------
				LEFT OUTER JOIN
				(
				    SELECT
					    Epic_Financial_Division_Code,
						Epic_Financial_Division,
                        Epic_Financial_Subdivision_Code,
						Epic_Financial_Subdivision,
                        Department,
                        Department_ID,
                        Organization,
                        Org_Number,
                        som_group_id,
                        som_group_name,
						som_hs_area_id,
						som_hs_area_name
					FROM Rptg.vwRef_OracleOrg_to_EpicFinancialSubdiv) dvsn
				    ON (CAST(dvsn.Epic_Financial_Division_Code AS INTEGER) = TRY_CAST(ser.RPT_GRP_SIX AS INT)
					    AND CAST(dvsn.Epic_Financial_Subdivision_Code AS INTEGER) = TRY_CAST(ser.RPT_GRP_EIGHT AS INT))

                -- --------------------------------------
                -- Supplemental Dept Subloc --
                -- --------------------------------------
				--LEFT OUTER JOIN
				--(
				--    SELECT
				--	    Department_Name,
    --                    Department_ID,
    --                    SUBLOC_ID,
				--		SUBLOC_NAME
				--	FROM Rptg.vwRef_MDM_Supplemental_Dept_Subloc) supp
    --                ON (supp.Department_ID = util.DEPARTMENT_ID)

				LEFT JOIN [CLARITY_App].[Mapping].[Epic_Dept_Groupers] g ON util.DEPARTMENT_ID = g.epic_department_id
				LEFT JOIN [CLARITY_App].[Mapping].Ref_Clinical_Area_Map c on g.sk_Ref_Clinical_Area_Map = c.sk_Ref_Clinical_Area_Map
				--LEFT JOIN [CLARITY_App].[Mapping].Ref_Service_Map s on c.sk_Ref_Service_Map = s.sk_Ref_Service_Map
				--LEFT JOIN [CLARITY_App].[Mapping].Ref_Organization_Map o on s.organization_id = o.organization_id

	            LEFT OUTER JOIN clarity..CLARITY_DEP [DEP]						ON [DEP].DEPARTMENT_ID = util.DEPARTMENT_ID               
				LEFT OUTER JOIN clarity..ZC_DEP_RPT_GRP_6					ON [DEP].RPT_GRP_SIX=ZC_DEP_RPT_GRP_6.RPT_GRP_SIX

WHERE
      ((date_dim.day_date >= @startdate) AND (date_dim.day_date < @enddate))
      AND excl.DEPARTMENT_ID IS NULL
) tabrptg

WHERE
	tabrptg.event_count = 1 -- event_dates with SLOT_BEGIN_DATEs

--ORDER BY
--	tabrptg.epic_department_id
--   ,tabrptg.provider_id
--   ,tabrptg.event_date
--   ,tabrptg.SLOT_BEGIN_TIME

--SELECT *
--FROM #util
--ORDER BY
--	epic_department_id
--   ,provider_id
--   ,slot_date
--   ,slot_begin_time

--DECLARE @TemplatesSelect TABLE (Department_Id NUMERIC(18,0), Provider_Id VARCHAR(50))

--INSERT INTO @TemplatesSelect
--(
--    Department_Id,
--    Provider_Id
--)
--SELECT DISTINCT
--	epic_department_id,
--	provider_id
--FROM #util

SELECT date_dim.day_date
      ,date_dim.fmonth_num
      ,date_dim.Fyear_num
      ,date_dim.FYear_name
	  ,date_dim.day_of_week
	  ,date_dim.day_of_week_num
INTO #datetable
FROM CLARITY_App.Rptg.vwDim_Date AS date_dim
WHERE date_dim.day_date >= '7/1/2017'
--WHERE date_dim.day_date >= CAST(@StartDate AS DATE)
ORDER BY date_dim.day_date

  -- Create index for temp table #datetable
  CREATE UNIQUE CLUSTERED INDEX IX_datetable ON #datetable ([day_date])

--/* #avail
SELECT avail.DEPARTMENT_ID
     , avail.DEPARTMENT_NAME
	 , avail.PROV_ID
	 , avail.PROV_NM_WID
	 , CAST(avail.SLOT_DATE AS DATE) AS APPT_SLOT_DATE
	 , ddte.day_of_week AS SLOT_DOW
	 , CAST(avail.SLOT_BEGIN_TIME AS TIME) AS APPT_SLOT_BEGIN_TIME
	 , CAST(avail.SLOT_END_TIME AS TIME) AS APPT_SLOT_END_TIME
	 --, avail.SLOT_BEGIN_TIME
	 --, avail.SLOT_END_TIME
	 , avail.ORG_REG_OPENINGS AS Opn
	 , avail.ORG_OVBK_OPENINGS AS Ovb
	 , avail.SLOT_LENGTH
	 --, avail.APPT_NUMBER
	 --, avail.APPT_BLOCK_NAME
	 , COALESCE(avail.APPT_BLOCK_NAME,'Unblocked') AS APPT_BLOCK_NAME
	 , avail.APPT_OVERBOOK_YN
	 --, blk.LINE
	 --, blk.BLOCK_C
	 --, blk.ORG_AVAIL_BLOCKS
	 --, blk.BLOCKS_USED
	 --, blk.REL_BLOCK_C
INTO #avail
FROM CLARITY.dbo.V_AVAILABILITY avail
--LEFT OUTER JOIN dbo.AVAIL_BLOCK blk
--ON blk.DEPARTMENT_ID = avail.DEPARTMENT_ID
--AND blk.PROV_ID = avail.PROV_ID
--AND blk.SLOT_BEGIN_TIME = avail.SLOT_BEGIN_TIME
--INNER JOIN @DevPeds DevPeds
--ON avail.PROV_ID = DevPeds.Provider_Id
LEFT OUTER JOIN
(
SELECT
	PROV_ID,
	PROV_NAME,
	STAFF_RESOURCE_C,
	STAFF_RESOURCE,
	PROVIDER_TYPE_C,
	PROV_TYPE,
	RPT_GRP_SIX,
	RPT_GRP_EIGHT
FROM CLARITY.dbo.CLARITY_SER
) ser
ON ser.PROV_ID = avail.PROV_ID
INNER JOIN CLARITY_App.Rptg.vwDim_Date ddte
ON avail.SLOT_DATE = ddte.day_date
WHERE
--avail.DEPARTMENT_ID = 10243003
--avail.DEPARTMENT_ID = 10210002
--avail.DEPARTMENT_ID IN (10210002,10210030,10243003,10243087,10244023)
--AND avail.PROV_ID = '29545'
--AND avail.PROV_ID = '84374' -- TUCKER, SHANNON
--AND avail.PROV_ID = '1300382'
--AND CAST(SLOT_DATE AS DATE) = '1/28/2019'
--AND CAST(avail.SLOT_DATE AS DATE) = '10/4/2017'
--AND CAST(SLOT_DATE AS DATE) >= CAST(@StartDate AS DATE)
CAST(avail.SLOT_DATE AS DATE) >= CAST(@StartDate AS DATE)
AND CAST(avail.SLOT_DATE AS DATE) <= CAST(@EndDate AS DATE)
--AND CAST(avail.SLOT_DATE AS DATE) >= '7/1/2017' /*****/
--AND CAST(SLOT_DATE AS DATE) >= '1/28/2019'
AND avail.APPT_NUMBER = 0
AND ( 
		(@HierarchyLookup <> 8 AND avail.DEPARTMENT_ID IN (SELECT value FROM STRING_SPLIT(@Departments,',')))
		OR
		(@HierarchyLookup = 8 AND COALESCE(ser.RPT_GRP_EIGHT,'0')	IN (SELECT value FROM STRING_SPLIT(@Departments,',')) ) -- says department but the department parameter does department and financial subdivision
				
	)
AND avail.PROV_ID IN (SELECT value FROM STRING_SPLIT(@Providers,','))
ORDER BY avail.DEPARTMENT_ID
       , avail.PROV_ID
	   , avail.SLOT_DATE
	   , CAST(avail.SLOT_BEGIN_TIME AS TIME)
	   , CAST(avail.SLOT_END_TIME AS TIME)
	   , avail.APPT_NUMBER

  -- Create index for temp table #avail
  CREATE UNIQUE CLUSTERED INDEX IX_avail ON #avail (DEPARTMENT_ID, PROV_ID, APPT_SLOT_DATE, APPT_SLOT_BEGIN_TIME, APPT_SLOT_END_TIME)

--SELECT *
--FROM #avail
----WHERE APPT_NUMBER > 0
----ORDER BY DEPARTMENT_ID
----       , PROV_ID
----	   , APPT_SLOT_DATE
----	   , APPT_SLOT_BEGIN_TIME
--ORDER BY DEPARTMENT_ID
--       , PROV_ID
--	   , APPT_SLOT_DATE
--	   , APPT_SLOT_BEGIN_TIME
--	   , APPT_SLOT_END_TIME
--*/ #avail

--/* #schdtmpl
SELECT display_template.DEPARTMENT_ID
     , display_template.DEPARTMENT_NAME
     , display_template.PROV_ID
	 , display_template.PROV_NAME
	 , display_template.DAY_OF_THE_WEEK_C
	 , display_template.DOW
	 , ddte.day_of_week
	 , ddte.day_of_week_num AS ddte_DOW
	 , CAST(display_template.BEGIN_DATE_TM_RANGE AS TIME) AS TEMPLATE_SLOT_BEGIN_TIME
	 , CAST(display_template.END_DATE_TIME_RANGE AS TIME) AS TEMPLATE_SLOT_END_TIME
	 , CAST(ddte.day_date AS DATE) AS TEMPLATE_SLOT_DATE
	 , display_template.OPENINGS_PER_SLOT
	 , display_template.NUMBER_OB_ALLOWED
	 , display_template.SLOT_LENGTH
INTO #schdtmpl
FROM
(
SELECT tmpl.DEPARTMENT_ID
     , dep.DEPARTMENT_NAME
     , tmpl.PROV_ID
	 , ser.PROV_NAME
	 , tmpl.DAY_OF_THE_WEEK_C
	 , zdow.NAME AS DOW
	 --, CAST(tmpl.BEGIN_DATE_TM_RANGE AS DATE) AS BEGIN_DATE_TM_RANGE
	 , tmpl.BEGIN_DATE_TM_RANGE
	 --, ddte.day_of_week AS BEGIN_DOW_TM
	 --, CAST(tmpl.BEGIN_DATE_TM_RANGE AS TIME) AS BEGIN_TIME_TM_RANGE
	 --, CAST(tmpl.END_DATE_TIME_RANGE AS TIME) AS END_TIME_TM_RANGE
	 , tmpl.END_DATE_TIME_RANGE
	 , tmpl.OPENINGS_PER_SLOT
	 , tmpl.NUMBER_OB_ALLOWED
	 , tmpl.SLOT_LENGTH
FROM CLARITY.dbo.ES_SCHED_TEMPLATE tmpl
--INNER JOIN CLARITY_App.Rptg.vwDim_Date ddte
--ON CAST(tmpl.BEGIN_DATE_TM_RANGE AS DATE) = ddte.day_date
LEFT OUTER JOIN CLARITY.dbo.CLARITY_DEP dep
ON dep.DEPARTMENT_ID = tmpl.DEPARTMENT_ID
LEFT OUTER JOIN CLARITY.dbo.CLARITY_SER ser
ON ser.PROV_ID = tmpl.PROV_ID
LEFT OUTER JOIN CLARITY.dbo.ZC_DAY_OF_THE_WEEK zdow
ON zdow.DAY_OF_THE_WEEK_C = tmpl.DAY_OF_THE_WEEK_C
--INNER JOIN @DevPeds DevPeds
--ON tmpl.PROV_ID = DevPeds.Provider_Id
WHERE
--tmpl.DEPARTMENT_ID = 10243003 -- UVHE DIGESTIVE HEALTH
--tmpl.DEPARTMENT_ID = 10210002
--tmpl.DEPARTMENT_ID = 10243087
--tmpl.DEPARTMENT_ID IN (10210002,10210030,10243003,10243087,10244023)
CAST(tmpl.END_DATE_TIME_RANGE AS DATE) >= CAST(@StartDate AS DATE) /*****/
AND CAST(tmpl.END_DATE_TIME_RANGE AS DATE) <= CAST(@EndDate AS DATE) /*****/
--AND tmpl.PROV_ID = '29545' -- BEHM, BRIAN
--AND tmpl.PROV_ID = '84374' -- TUCKER, SHANNON
--AND tmpl.PROV_ID = '92145' -- YOUNGBERG, HEATHER
--AND tmpl.PROV_ID = '30288' -- FRIEL, CHARLES
--AND tmpl.PROV_ID = '1300382'
--AND CAST(tmpl.BEGIN_DATE_TM_RANGE AS DATE) = '1/28/2019'
--AND CAST(tmpl.BEGIN_DATE_TM_RANGE AS DATE) = '10/8/2018'
--AND CAST(tmpl.BEGIN_DATE_TM_RANGE AS DATE) >= CAST(@StartDate AS DATE)
--AND CAST(tmpl.END_DATE_TIME_RANGE AS DATE) >= CAST(@StartDate AS DATE) /*****/
--AND CAST(tmpl.BEGIN_DATE_TM_RANGE AS DATE) >= '1/28/2019'
AND ( 
		(@HierarchyLookup <> 8 AND tmpl.DEPARTMENT_ID IN (SELECT value FROM STRING_SPLIT(@Departments,',')))
		OR
		(@HierarchyLookup = 8 AND COALESCE(ser.RPT_GRP_EIGHT,'0')	IN (SELECT value FROM STRING_SPLIT(@Departments,',')) ) -- says department but the department parameter does department and financial subdivision
				
	)
AND tmpl.PROV_ID IN (SELECT value FROM STRING_SPLIT(@Providers,','))
) display_template
CROSS JOIN #datetable ddte
WHERE (ddte.day_date BETWEEN CAST(display_template.BEGIN_DATE_TM_RANGE AS DATE) AND CAST(display_template.END_DATE_TIME_RANGE AS DATE))
AND ddte.day_of_week = display_template.DOW
--ORDER BY display_template.DEPARTMENT_ID
--       , display_template.PROV_ID
--	   , CAST(ddte.day_date AS DATE)
--	   , CAST(display_template.BEGIN_DATE_TM_RANGE AS TIME)
--	   , CAST(display_template.END_DATE_TIME_RANGE AS TIME)

  -- Create index for temp table #schdtmpl
  CREATE UNIQUE CLUSTERED INDEX IX_schdtmpl ON #schdtmpl (DEPARTMENT_ID, PROV_ID, TEMPLATE_SLOT_DATE, TEMPLATE_SLOT_BEGIN_TIME, TEMPLATE_SLOT_END_TIME)

--SELECT *
--FROM #schdtmpl
----ORDER BY DEPARTMENT_ID
----       , PROV_ID
----	   , BEGIN_DATE_TM_RANGE
----	   , BEGIN_TIME_TM_RANGE
----ORDER BY DEPARTMENT_ID
----       , PROV_ID
----	   , ddte_DOW
----       , TEMPLATE_SLOT_DATE
----       , TEMPLATE_SLOT_BEGIN_TIME
----       , TEMPLATE_SLOT_END_TIME
--ORDER BY DEPARTMENT_ID
--       , PROV_ID
--	   , TEMPLATE_SLOT_DATE
--	   , TEMPLATE_SLOT_BEGIN_TIME
--	   , TEMPLATE_SLOT_END_TIME
--*/ #schdtmpl

--/* #availtmpl
SELECT avail.*,
			   tmpl. OPENINGS_PER_SLOT,
			   tmpl.NUMBER_OB_ALLOWED
INTO #availtmpl
FROM #avail avail
LEFT OUTER JOIN #schdtmpl tmpl
ON tmpl.DEPARTMENT_ID = avail.DEPARTMENT_ID
AND tmpl.PROV_ID = avail.PROV_ID
AND tmpl.TEMPLATE_SLOT_DATE = avail.APPT_SLOT_DATE
AND (avail.APPT_SLOT_BEGIN_TIME >= tmpl.TEMPLATE_SLOT_BEGIN_TIME AND avail.APPT_SLOT_BEGIN_TIME <= tmpl.TEMPLATE_SLOT_END_TIME)
AND (avail.APPT_SLOT_END_TIME >= tmpl.TEMPLATE_SLOT_BEGIN_TIME AND avail.APPT_SLOT_END_TIME <= tmpl.TEMPLATE_SLOT_END_TIME)

  -- Create index for temp table #availtmpl
  CREATE UNIQUE CLUSTERED INDEX IX_availtmpl ON #availtmpl (DEPARTMENT_ID, PROV_ID, APPT_SLOT_DATE, APPT_SLOT_BEGIN_TIME, APPT_SLOT_END_TIME)

--SELECT *
--FROM #availtmpl
--ORDER BY DEPARTMENT_ID
--       , PROV_ID
--	   , APPT_SLOT_DATE
--	   , APPT_SLOT_BEGIN_TIME
--	   , APPT_SLOT_END_TIME
--*/ #availtmpl

--/* #avail_block
SELECT blk.DEPARTMENT_ID
	 , blk.PROV_ID
	 , CAST(blk.SLOT_BEGIN_TIME AS DATE) AS SLOT_DATE
	 , CAST(blk.SLOT_BEGIN_TIME AS TIME) AS SLOT_BEGIN_TIME
	 --, COALESCE(avail.APPT_BLOCK_NAME,'Unblocked') AS APPT_BLOCK_NAME
	 , blk.LINE
	 --, blk.BLOCK_C
	 , zab.NAME AS BLOCK_NAME
	 , COALESCE(blk.ORG_AVAIL_BLOCKS,0) AS ORG_AVAIL_BLOCKS
	 , CASE WHEN COALESCE(blk.BLOCKS_USED,0) = 1 THEN 'Y' ELSE 'N' END AS BLOCKS_USED
	 --, blk.REL_BLOCK_C
	 --, zarb.NAME AS REL_BLOCK_NAME
	 --, zab.NAME + '(' + CAST(COALESCE(blk.BLOCKS_USED,0) AS VARCHAR(2)) + ')' AS BLOCK_NAME_COUNT
INTO #avail_block
FROM CLARITY.dbo.AVAIL_BLOCK blk
LEFT OUTER JOIN CLARITY.dbo.ZC_APPT_BLOCK zab
ON zab.APPT_BLOCK_C = blk.BLOCK_C
--LEFT OUTER JOIN dbo.ZC_APPT_BLOCK zarb
--ON zarb.APPT_BLOCK_C = blk.REL_BLOCK_C
--LEFT OUTER JOIN dbo.AVAIL_BLOCK blk
--ON blk.DEPARTMENT_ID = avail.DEPARTMENT_ID
--AND blk.PROV_ID = avail.PROV_ID
--AND blk.SLOT_BEGIN_TIME = avail.SLOT_BEGIN_TIME
--INNER JOIN @DevPeds DevPeds
--ON blk.PROV_ID = DevPeds.Provider_Id
LEFT OUTER JOIN
(
SELECT
	PROV_ID,
	PROV_NAME,
	STAFF_RESOURCE_C,
	STAFF_RESOURCE,
	PROVIDER_TYPE_C,
	PROV_TYPE,
	RPT_GRP_SIX,
	RPT_GRP_EIGHT
FROM CLARITY.dbo.CLARITY_SER
) ser
ON ser.PROV_ID = blk.PROV_ID
WHERE
--blk.DEPARTMENT_ID = 10243003
--blk.DEPARTMENT_ID = 10210002
--blk.DEPARTMENT_ID = 10243087
--blk.DEPARTMENT_ID IN (10210002,10210030,10243003,10243087,10244023)
--CAST(blk.SLOT_BEGIN_TIME AS DATE) >= '7/1/2017' /*****/
CAST(blk.SLOT_BEGIN_TIME AS DATE) >= CAST(@StartDate AS DATE)
AND CAST(blk.SLOT_BEGIN_TIME AS DATE) <= CAST(@EndDate AS DATE)
--AND blk.PROV_ID = '29545'
--AND blk.PROV_ID = '84374' -- TUCKER, SHANNON
--AND blk.PROV_ID = '92145' -- YOUNGBERG, HEATHER
--AND blk.PROV_ID = '30288' -- FRIEL, CHARLES
--AND avail.PROV_ID = '1300382'
--AND CAST(blk.SLOT_BEGIN_TIME AS DATE) = '1/28/2019'
--AND CAST(blk.SLOT_BEGIN_TIME AS DATE) = '10/8/2018'
--AND CAST(SLOT_DATE AS DATE) >= CAST(@StartDate AS DATE)
--AND CAST(blk.SLOT_BEGIN_TIME AS DATE) >= '7/1/2017' /*****/
--AND CAST(blk.SLOT_BEGIN_TIME AS DATE) >= '1/28/2019'
--AND blk.BLOCK_C IS NOT NULL
AND ( 
		(@HierarchyLookup <> 8 AND blk.DEPARTMENT_ID IN (SELECT value FROM STRING_SPLIT(@Departments,',')))
		OR
		(@HierarchyLookup = 8 AND COALESCE(ser.RPT_GRP_EIGHT,'0')	IN (SELECT value FROM STRING_SPLIT(@Departments,',')) ) -- says department but the department parameter does department and financial subdivision
				
	)
AND blk.PROV_ID IN (SELECT value FROM STRING_SPLIT(@Providers,','))
ORDER BY blk.DEPARTMENT_ID
       , blk.PROV_ID
	   , CAST(blk.SLOT_BEGIN_TIME AS DATE)
	   , CAST(blk.SLOT_BEGIN_TIME AS TIME)

  -- Create index for temp table #avail_block
  CREATE UNIQUE CLUSTERED INDEX IX_avail_block ON #avail_block (DEPARTMENT_ID, PROV_ID, SLOT_DATE, SLOT_BEGIN_TIME, LINE, BLOCK_NAME)

--SELECT *
--FROM #avail_block
--ORDER BY DEPARTMENT_ID
--       , PROV_ID
--	   , SLOT_DATE
--	   , SLOT_BEGIN_TIME
--*/ -- #avail_block

--/* #tmpl_avail_blocks
SELECT avail_blk.DEPARTMENT_ID
     , avail_blk.PROV_ID
	 , avail_blk.APPT_SLOT_DATE
	 , avail_blk.APPT_SLOT_BEGIN_TIME
	 , avail_blk.APPT_SLOT_END_TIME
	 , COALESCE(avail_blk.SLOT_BEGIN_TIME, avail_blk.APPT_SLOT_BEGIN_TIME, NULL) AS SLOT_BEGIN_TIME
	 , avail_blk.OPENINGS_PER_SLOT
	 , avail_blk.NUMBER_OB_ALLOWED
	 , avail_blk.SLOT_LENGTH
	 , COALESCE(avail_blk.LINE,1) AS LINE
	 , COALESCE(avail_blk.BLOCK_NAME,'No Block Information') AS BLOCK_NAME
	 , COALESCE(avail_blk.ORG_AVAIL_BLOCKS,0) AS ORG_AVAIL_BLOCKS
	 --, COALESCE(avail_blk.BLOCKS_USED,0) AS BLOCKS_USED
	 , COALESCE(avail_blk.BLOCKS_USED,'N') AS BLOCKS_USED
     --,ROW_NUMBER() OVER (PARTITION BY avail_blk.DEPARTMENT_ID, avail_blk.PROV_ID, avail_blk.TEMPLATE_SLOT_DATE, avail_blk.TEMPLATE_SLOT_BEGIN_TIME, avail_blk.TEMPLATE_SLOT_END_TIME, COALESCE(avail_blk.BLOCK_NAME,'No Block Information') ORDER BY avail_blk.ORG_AVAIL_BLOCKS DESC) AS Seq
     ,ROW_NUMBER() OVER (PARTITION BY avail_blk.DEPARTMENT_ID, avail_blk.PROV_ID, avail_blk.APPT_SLOT_DATE, avail_blk.APPT_SLOT_BEGIN_TIME, avail_blk.APPT_SLOT_END_TIME, LINE ORDER BY avail_blk.ORG_AVAIL_BLOCKS DESC) AS Seq
INTO #tmpl_avail_blocks
FROM
(
SELECT tmpl.DEPARTMENT_ID
	 , tmpl.PROV_ID
	 , tmpl.APPT_SLOT_DATE
	 , tmpl.APPT_SLOT_BEGIN_TIME
	 , tmpl.APPT_SLOT_END_TIME
	 , COALESCE(tmpl.OPENINGS_PER_SLOT,0) AS OPENINGS_PER_SLOT
	 , COALESCE(tmpl.NUMBER_OB_ALLOWED,0) AS NUMBER_OB_ALLOWED
	 , tmpl.SLOT_LENGTH
	 , blk.SLOT_BEGIN_TIME
	 , blk.LINE
	 , blk.BLOCK_NAME
	 , blk.ORG_AVAIL_BLOCKS
	 , blk.BLOCKS_USED
FROM #availtmpl tmpl
LEFT OUTER JOIN
(
SELECT avail_block.DEPARTMENT_ID
     , avail_block.PROV_ID
	 , avail_block.SLOT_DATE
	 , avail_block.SLOT_BEGIN_TIME
	 , avail_block.LINE
	 , avail_block.BLOCK_NAME
	 , avail_block.ORG_AVAIL_BLOCKS
	 , avail_block.BLOCKS_USED
FROM #avail_block avail_block
WHERE LINE = 1
OR (LINE > 1 AND NOT (BLOCK_NAME = 'No Block Information' AND avail_block.BLOCKS_USED = 'N'))
) blk
ON blk.DEPARTMENT_ID = tmpl.DEPARTMENT_ID
AND blk.PROV_ID = tmpl.PROV_ID
AND blk.SLOT_DATE = tmpl.APPT_SLOT_DATE
AND blk.SLOT_BEGIN_TIME >= tmpl.APPT_SLOT_BEGIN_TIME
AND blk.SLOT_BEGIN_TIME < tmpl.APPT_SLOT_END_TIME
) avail_blk
ORDER BY avail_blk.DEPARTMENT_ID
       , avail_blk.PROV_ID
	   , avail_blk.APPT_SLOT_DATE
	   , avail_blk.APPT_SLOT_BEGIN_TIME
	   , avail_blk.APPT_SLOT_END_TIME
	   , avail_blk.SLOT_BEGIN_TIME
	   , avail_blk.LINE

  -- Create index for temp table #tmpl_avail_blocks
  CREATE UNIQUE CLUSTERED INDEX IX_tmpl_avail_blocks ON #tmpl_avail_blocks (DEPARTMENT_ID, PROV_ID, APPT_SLOT_DATE, APPT_SLOT_BEGIN_TIME, APPT_SLOT_END_TIME, SLOT_BEGIN_TIME, LINE)

--SELECT *
--FROM #tmpl_avail_blocks
--ORDER BY DEPARTMENT_ID
--       , PROV_ID
--	   , APPT_SLOT_DATE
--	   , APPT_SLOT_BEGIN_TIME
--	   , APPT_SLOT_END_TIME
--	   --, COALESCE(BLOCK_NAME,'No Block Information')
--	   , LINE
--	   , Seq
--*/ -- #tmpl_avail_blocks

--SELECT DISTINCT
--       avail.DEPARTMENT_ID
--     , avail.PROV_ID
--	 , avail.APPT_SLOT_DATE
--	 , avail.APPT_SLOT_BEGIN_TIME
--     , (SELECT availt.BLOCK_NAME + ' (' + availt.BLOCKS_USED + '),' AS [text()]
--		FROM (SELECT DISTINCT DEPARTMENT_ID, PROV_ID, APPT_SLOT_DATE, APPT_SLOT_BEGIN_TIME, BLOCK_NAME, BLOCKS_USED FROM #tmpl_avail_blocks) availt
--		WHERE availt.DEPARTMENT_ID = avail.DEPARTMENT_ID
--		AND availt.PROV_ID = avail.PROV_ID
--		AND availt.APPT_SLOT_DATE = avail.APPT_SLOT_DATE
--		--AND CAST(availt.APPT_SLOT_BEGIN_TIME AS TIME) = CAST(avail.APPT_SLOT_BEGIN_TIME AS TIME)
--		AND availt.APPT_SLOT_BEGIN_TIME = avail.APPT_SLOT_BEGIN_TIME
--	    FOR XML PATH ('')) AS BLOCKS_USED_STRING
--FROM #tmpl_avail_blocks avail
--ORDER BY DEPARTMENT_ID
--       , PROV_ID
--       , APPT_SLOT_DATE
--	   , APPT_SLOT_BEGIN_TIME

--SELECT avail.DEPARTMENT_ID
--     , avail.PROV_ID
--	 , avail.APPT_SLOT_DATE
--	 , avail.APPT_SLOT_BEGIN_TIME
--	 , avail.BLOCK_NAME + '(' + avail.BLOCKS_USED + ')' AS BLOCK_NAME_USED
----INTO #tmpl_avail_blocks_aggr
--FROM #tmpl_avail_blocks avail
----GROUP BY avail.DEPARTMENT_ID
----       , avail.PROV_ID
----       , avail.APPT_SLOT_DATE
----	   , avail.APPT_SLOT_BEGIN_TIME
----	   , avail.BLOCK_NAME

SELECT DISTINCT
       avail.DEPARTMENT_ID
     , avail.PROV_ID
	 , avail.APPT_SLOT_DATE
	 , avail.APPT_SLOT_BEGIN_TIME
     , (SELECT availt.BLOCK_NAME + ' (' + availt.BLOCKS_USED + '),' AS [text()]
		--FROM #tmpl_avail_blocks availt
		FROM (SELECT DISTINCT DEPARTMENT_ID, PROV_ID, APPT_SLOT_DATE, APPT_SLOT_BEGIN_TIME, BLOCK_NAME, BLOCKS_USED FROM #tmpl_avail_blocks) availt
		WHERE availt.DEPARTMENT_ID = avail.DEPARTMENT_ID
		AND availt.PROV_ID = avail.PROV_ID
		AND availt.APPT_SLOT_DATE = avail.APPT_SLOT_DATE
		--AND CAST(availt.APPT_SLOT_BEGIN_TIME AS TIME) = CAST(avail.APPT_SLOT_BEGIN_TIME AS TIME)
		AND availt.APPT_SLOT_BEGIN_TIME = avail.APPT_SLOT_BEGIN_TIME
	    FOR XML PATH ('')) AS BLOCKS_USED_STRING
INTO #tmpl_avail_blocks_aggr
FROM #tmpl_avail_blocks avail

--SELECT *
--FROM #tmpl_avail_blocks_aggr
--ORDER BY DEPARTMENT_ID
--       , PROV_ID
--       , APPT_SLOT_DATE
--	   , APPT_SLOT_BEGIN_TIME

SELECT avail.DEPARTMENT_ID,
       avail.PROV_ID,
       avail.APPT_SLOT_DATE,
       avail.APPT_SLOT_BEGIN_TIME,
       avail.APPT_SLOT_END_TIME,
       avail.OPENINGS_PER_SLOT,
       avail.NUMBER_OB_ALLOWED,
	   avail.SLOT_LENGTH,
	   LEFT(aggr.BLOCKS_USED_STRING, LEN(aggr.BLOCKS_USED_STRING)-1) AS BLOCK_USE

INTO #tmpl_avail_blocks_summ

FROM
(
SELECT DISTINCT
	DEPARTMENT_ID,
    PROV_ID,
    APPT_SLOT_DATE,
    APPT_SLOT_BEGIN_TIME,
    APPT_SLOT_END_TIME,
    SLOT_BEGIN_TIME,
    OPENINGS_PER_SLOT,
    NUMBER_OB_ALLOWED,
	SLOT_LENGTH
FROM #tmpl_avail_blocks
) avail
LEFT OUTER JOIN #tmpl_avail_blocks_aggr aggr
ON aggr.DEPARTMENT_ID = avail.DEPARTMENT_ID
AND aggr.PROV_ID = avail.PROV_ID
AND aggr.APPT_SLOT_DATE = avail.APPT_SLOT_DATE
AND aggr.APPT_SLOT_BEGIN_TIME = avail.APPT_SLOT_BEGIN_TIME

--SELECT *
--FROM #tmpl_avail_blocks_summ
--ORDER BY DEPARTMENT_ID
--       , PROV_ID
--       , APPT_SLOT_DATE
--	   , APPT_SLOT_BEGIN_TIME

SELECT 
       util.event_type,
       util.financial_division_id,
       util.financial_division_name,
       util.financial_sub_division_id,
       util.financial_sub_division_name,
       util.epic_department_id,
       util.epic_department_name,
       util.epic_department_name_external,
       util.pod_name,
       util.provider_id,
       util.provider_name,
       util.provider_type,
       util.person_or_resource,
       util.day_of_week,
       util.slot_date,
       util.slot_begin_time,
       util.slot_length,
       util.booked_length,
       util.num_apts_scheduled,
       util.regular_openings,
       util.regular_openings_available,
       util.regular_openings_unavailable,
       util.overbook_openings,
       util.template_block_name,
       util.unavailable_reason,
       util.overbook_yn,
       util.outside_template_yn,
       util.slot_rate_numerator,
       util.slot_rate_denominator,
       util.MRN,
       util.visit_type,
       util.appt_status,
       --blk.DEPARTMENT_ID,
       --blk.PROV_ID,
       --blk.APPT_SLOT_DATE,
       --blk.APPT_SLOT_BEGIN_TIME,
       --blk.APPT_SLOT_END_TIME,
       --blk.OPENINGS_PER_SLOT,
       --blk.NUMBER_OB_ALLOWED,
       --blk.SLOT_LENGTH,
       blk.BLOCK_USE AS template_block_use
FROM #util util
LEFT OUTER JOIN #tmpl_avail_blocks_summ blk
ON blk.DEPARTMENT_ID = util.epic_department_id
AND blk.PROV_ID = util.provider_id
AND blk.APPT_SLOT_DATE = util.slot_date
AND blk.APPT_SLOT_BEGIN_TIME = CAST(util.slot_begin_time AS TIME)
ORDER BY
	util.epic_department_id,
    util.provider_id,
    util.slot_date,
    util.slot_begin_time

/*WITH cte AS(

/*AM*/
	SELECT a.Slot_Date,
	a.DEPARTMENT_ID AS Department_ID,
	a.PROV_ID AS Prov_ID,
	a.PROVIDER_TYPE_C AS Prov_Type_ID,
	a.PROV_TYPE AS Prov_Type,
	'AM' AS Session_Flag,  
	STRING_AGG(CASE WHEN Time_Type IN ('Unavailable_Time','Regular_Time') THEN a.UNAVAILABLE_RSN_NAME ELSE NULL END , ',') AS Unavailable_Reasons,
	STRING_AGG(CASE WHEN Time_Type IN ('Unapproved_Unavailable_Time') THEN a.UNAVAILABLE_RSN_NAME ELSE NULL END , ',') AS Unapproved_Unavailable_Reasons,
	MIN(CASE WHEN Time_Type IN ('Unavailable_Time','Regular_Time') THEN a.SLOT_BEGIN_TIME ELSE NULL END) AS  First_Slot_Start,
	MAX(CASE WHEN Time_Type IN ('Unavailable_Time','Regular_Time') THEN a.SLOT_END_TIME ELSE NULL END) AS  Last_Slot_End,
	CAST(DATEDIFF(MINUTE,CAST(MIN(CASE WHEN Time_Type IN ('Unavailable_Time','Regular_Time') THEN a.SLOT_BEGIN_TIME ELSE NULL END) AS TIME(0)), 
		CAST(MAX(CASE WHEN Time_Type IN ('Unavailable_Time','Regular_Time') THEN a.SLOT_END_TIME ELSE NULL END) AS TIME(0))) AS NUMERIC(18,2)) / 60 AS Duration,
	SUM(CASE WHEN a.Time_Type = 'Regular_Time' THEN CAST(a.SLOT_LENGTH AS NUMERIC(18,2)) ELSE 0 END)/60 AS Regular_Slot_Time_Hrs,
	SUM(CASE WHEN a.Time_Type = 'Unavailable_Time' THEN CAST(a.SLOT_LENGTH AS NUMERIC(18,2)) ELSE 0 END)/60 AS Unavalible_Slot_Time_Hrs,
	SUM(CASE WHEN a.Time_Type = 'Unapproved_Unavailable_Time' THEN CAST(a.SLOT_LENGTH AS NUMERIC(18,2)) ELSE 0 END)/60 AS Unapproved_Unavalible_Slot_Time_Hrs,
	SUM(CAST(CASE WHEN Time_Type IN ('Unavailable_Time','Regular_Time') THEN a.SLOT_LENGTH ELSE NULL END AS NUMERIC(18,2))) / 60 AS Slot_Time_Hrs,
	CASE WHEN SUM(CAST(CASE WHEN Time_Type IN ('Unavailable_Time','Regular_Time') THEN a.SLOT_LENGTH ELSE NULL END AS NUMERIC(18,2))) / 60 >= 4 THEN 1 
		ELSE 0 
		END AS Qualified_Slot_Length
	FROM

	(	SELECT Slot_Date               =   datedim.CALENDAR_DT,
			avail.DEPARTMENT_ID,
			avail.PROV_ID,
			avail.SLOT_BEGIN_TIME,
			avail.SLOT_END_TIME,
			avail.SLOT_LENGTH,
			ser.PROVIDER_TYPE_C,
			ser.PROV_TYPE,
			CASE    
				WHEN avail.UNAVAILABLE_RSN_C IS NOT NULL AND avail.UNAVAILABLE_RSN_C IN (1, 9, 23, 21, 14, 4, 131, 24, 135, 136, 138, 139)	THEN 'Unavailable_Time'    
				WHEN avail.UNAVAILABLE_RSN_C IS NOT NULL AND avail.UNAVAILABLE_RSN_C NOT IN (1, 9, 23, 21, 14, 4, 131, 24, 135, 136, 138, 139)	THEN 'Unapproved_Unavailable_Time'
				WHEN avail.UNAVAILABLE_RSN_C IS NULL	THEN 'Regular_Time'  
				ELSE 'Other'
			END AS Time_Type,
			avail.UNAVAILABLE_RSN_NAME

		FROM CLARITY.dbo.V_AVAILABILITY		avail WITH (NOLOCK)
			INNER JOIN CLARITY.dbo.CLARITY_SER       ser WITH (NOLOCK)     ON avail.PROV_ID = ser.PROV_ID
			LEFT JOIN CLARITY.dbo.ZC_SER_RPT_GRP_6  six  WITH (NOLOCK)    ON ser.RPT_GRP_SIX = six.RPT_GRP_SIX
			LEFT JOIN CLARITY.dbo.ZC_SER_RPT_GRP_8  eight WITH (NOLOCK)  ON ser.RPT_GRP_EIGHT = eight.RPT_GRP_EIGHT 
			INNER JOIN CLARITY.dbo.DATE_DIMENSION	datedim WITH (NOLOCK)	ON avail.SLOT_DATE = datedim.CALENDAR_DT
			LEFT JOIN CLARITY.dbo.ZC_UNAVAIL_REASON r WITH (NOLOCK) ON  r.UNAVAILABLE_RSN_C = avail.UNAVAILABLE_RSN_C
--			INNER JOIN CLARITY.dbo.CLARITY_EMP emp ON ser.PROV_ID = emp.PROV_ID --removed to support future dating
		WHERE	1=1
			AND CAST(avail.SLOT_BEGIN_TIME AS DATE)   >=  @startdate 
			AND CAST(avail.SLOT_BEGIN_TIME AS DATE)   <= @enddate
			AND ( 
					(@HierarchyLookup <> 8 AND avail.DEPARTMENT_ID IN (SELECT value FROM STRING_SPLIT(@Department,',')))
					OR
					(@HierarchyLookup = 8 AND COALESCE(ser.RPT_GRP_EIGHT,'0')	IN (SELECT value FROM STRING_SPLIT(@Department,',')) ) -- says department but the department parameter does department and financial subdivision
				
				)
			AND avail.PROV_ID IN (SELECT value FROM STRING_SPLIT(@Provider,','))
			AND avail.SLOT_HOUR BETWEEN 7 AND 18
			AND datedim.WEEKEND_YN = 'N'
			AND avail.APPT_NUMBER = 0                         -- 0=Slots only
			--AND avail.PROV_NM_WID like '%Goldstein%'
			AND ser.PROVIDER_TYPE_C IN ('1' , '4', '6', '9', '10','101','105','108','2','2506','2527','2721')   
			--1=Physician; 4=Anesthesiologist, 6=Physician Assistant, 9=Nurse Practitioner, 10 = Psychologist, 101=Audiologist, 105=Optometrist, 108=Dentist, 2=Nurse Anesthetist, 2506=Doctor of Philosophy, 2527=Genetic Counselor, 2721=Clinical Nurse Specialist
			AND  (CAST(avail.SLOT_BEGIN_TIME AS TIME) >= '07:00:00' AND CAST(avail.SLOT_BEGIN_TIME AS TIME) < '13:00:00')
			AND avail.ORG_REG_OPENINGS  > 0
			--AND CONVERT(DATE, emp.LAST_ACCS_DATETIME) >= datedim.CALENDAR_DT --removed to support future dating
	) a
	GROUP BY a.DEPARTMENT_ID, a.PROV_ID, a.Slot_Date, a.PROVIDER_TYPE_C, a.PROV_TYPE

UNION ALL

/*PM*/

	SELECT a.Slot_Date,
	a.DEPARTMENT_ID AS Department_ID,
	a.PROV_ID AS Prov_ID,
	a.PROVIDER_TYPE_C AS Prov_Type_ID,
	a.PROV_TYPE AS Prov_Type,
	'PM' AS Session_Flag,  
	STRING_AGG(CASE WHEN Time_Type IN ('Unavailable_Time','Regular_Time') THEN a.UNAVAILABLE_RSN_NAME ELSE NULL END , ',') AS Unavailable_Reasons,
	STRING_AGG(CASE WHEN Time_Type IN ('Unapproved_Unavailable_Time') THEN a.UNAVAILABLE_RSN_NAME ELSE NULL END , ',') AS Unapproved_Unavailable_Reasons,
	MIN(CASE WHEN Time_Type IN ('Unavailable_Time','Regular_Time') THEN a.SLOT_BEGIN_TIME ELSE NULL END) AS  First_Slot_Start,
	MAX(CASE WHEN Time_Type IN ('Unavailable_Time','Regular_Time') THEN a.SLOT_END_TIME ELSE NULL END) AS  Last_Slot_End,
	CAST(DATEDIFF(MINUTE,CAST(MIN(CASE WHEN Time_Type IN ('Unavailable_Time','Regular_Time') THEN a.SLOT_BEGIN_TIME ELSE NULL END) AS TIME(0)), 
		CAST(MAX(CASE WHEN Time_Type IN ('Unavailable_Time','Regular_Time') THEN a.SLOT_END_TIME ELSE NULL END) AS TIME(0))) AS NUMERIC(18,2)) / 60 AS Duration,
	SUM(CASE WHEN a.Time_Type = 'Regular_Time' THEN CAST(a.SLOT_LENGTH AS NUMERIC(18,2)) ELSE 0 END)/60 AS Regular_Slot_Time_Hrs,
	SUM(CASE WHEN a.Time_Type = 'Unavailable_Time' THEN CAST(a.SLOT_LENGTH AS NUMERIC(18,2)) ELSE 0 END)/60 AS Unavalible_Slot_Time_Hrs,
	SUM(CASE WHEN a.Time_Type = 'Unapproved_Unavailable_Time' THEN CAST(a.SLOT_LENGTH AS NUMERIC(18,2)) ELSE 0 END)/60 AS Unapproved_Unavalible_Slot_Time_Hrs,
	SUM(CAST(CASE WHEN Time_Type IN ('Unavailable_Time','Regular_Time') THEN a.SLOT_LENGTH ELSE NULL END AS NUMERIC(18,2))) / 60 AS Slot_Time_Hrs,
	CASE WHEN SUM(CAST(CASE WHEN Time_Type IN ('Unavailable_Time','Regular_Time') THEN a.SLOT_LENGTH ELSE NULL END AS NUMERIC(18,2))) / 60 >= 4 THEN 1 
		ELSE 0 
		END AS Qualified_Slot_Length

	FROM 
	(	SELECT Slot_Date             =   datedim.CALENDAR_DT,
			avail.DEPARTMENT_ID,
			avail.PROV_ID,
			avail.SLOT_BEGIN_TIME,
			avail.SLOT_END_TIME,
			avail.SLOT_LENGTH,
			ser.PROVIDER_TYPE_C,
			ser.PROV_TYPE,
			CASE    
				WHEN avail.UNAVAILABLE_RSN_C IS NOT NULL AND avail.UNAVAILABLE_RSN_C IN (1, 9, 23, 21, 14, 4, 131, 24, 135, 136, 138, 139)	THEN 'Unavailable_Time'    
				WHEN avail.UNAVAILABLE_RSN_C IS NOT NULL AND avail.UNAVAILABLE_RSN_C NOT IN (1, 9, 23, 21, 14, 4, 131, 24, 135, 136, 138, 139)	THEN 'Unapproved_Unavailable_Time'
				WHEN avail.UNAVAILABLE_RSN_C IS NULL	THEN 'Regular_Time'  
				ELSE 'Other'
			END AS Time_Type,
			avail.UNAVAILABLE_RSN_NAME
			FROM CLARITY.dbo.V_AVAILABILITY		avail WITH (NOLOCK)
			INNER JOIN CLARITY.dbo.CLARITY_SER       ser WITH (NOLOCK)     ON avail.PROV_ID = ser.PROV_ID
			LEFT JOIN CLARITY.dbo.ZC_SER_RPT_GRP_6  six  WITH (NOLOCK)    ON ser.RPT_GRP_SIX = six.RPT_GRP_SIX
			LEFT JOIN CLARITY.dbo.ZC_SER_RPT_GRP_8  eight WITH (NOLOCK)  ON ser.RPT_GRP_EIGHT = eight.RPT_GRP_EIGHT 
			INNER JOIN CLARITY.dbo.DATE_DIMENSION	datedim WITH (NOLOCK)	ON avail.SLOT_DATE = datedim.CALENDAR_DT
			LEFT JOIN CLARITY.dbo.ZC_UNAVAIL_REASON r WITH (NOLOCK) ON  r.UNAVAILABLE_RSN_C = avail.UNAVAILABLE_RSN_C
			--INNER JOIN CLARITY.dbo.CLARITY_EMP emp ON ser.PROV_ID = emp.PROV_ID removed to support future dating
			WHERE	1=1
			AND CAST(avail.SLOT_BEGIN_TIME AS DATE)   >=  @startdate	
			AND CAST(avail.SLOT_BEGIN_TIME AS DATE)   <= @enddate
			AND ( 
					(@HierarchyLookup <> 8 AND avail.DEPARTMENT_ID IN (SELECT value FROM STRING_SPLIT(@Department,',')))
					OR
					(@HierarchyLookup = 8 AND COALESCE(ser.RPT_GRP_EIGHT,'0')	IN (SELECT value FROM STRING_SPLIT(@Department,',')) ) -- says department but the department parameter does department and financial subdivision
				
				)
			AND avail.PROV_ID IN (SELECT value FROM STRING_SPLIT(@Provider,','))
			AND avail.SLOT_HOUR BETWEEN 7 AND 18
			AND datedim.WEEKEND_YN = 'N'
			AND avail.APPT_NUMBER = 0                         -- 0=Slots only
			--AND avail.PROV_NM_WID like '%Goldstein%'
			AND ser.PROVIDER_TYPE_C IN ('1' , '4', '6', '9', '10','101','105','108','2','2506','2527','2721')   
			--1=Physician; 4=Anesthesiologist, 6=Physician Assistant, 9=Nurse Practitioner, 10 = Psychologist, 101=Audiologist, 105=Optometrist, 108=Dentist, 2=Nurse Anesthetist, 2506=Doctor of Philosophy, 2527=Genetic Counselor, 2721=Clinical Nurse Specialist
			AND (CAST(avail.SLOT_BEGIN_TIME AS TIME) >= '12:00:00' AND CAST(avail.SLOT_BEGIN_TIME AS TIME) < '19:00:00' ) 
			AND  avail.ORG_REG_OPENINGS  > 0
			--AND CONVERT(DATE, emp.LAST_ACCS_DATETIME) >= datedim.CALENDAR_DT removed to support future dating
	) a
	GROUP BY a.DEPARTMENT_ID, a.PROV_ID, a.Slot_Date, a.PROVIDER_TYPE_C, a.PROV_TYPE

)

SELECT 
  cte.Slot_Date AS event_date
,    cte.Qualified_Slot_Length AS event_count --used to be cte.Qualified_Duration
,   cte.Session_Flag AS session_flag
,	(SELECT STRING_AGG(value,', ') FROM (SELECT DISTINCT value FROM STRING_SPLIT(cte.Unavailable_Reasons,',')) t) AS unavailable_reason
,   NULL AS time_type -- used to be cte.Time_Type
,	cte.Prov_Type AS provider_type
,	CASE WHEN cte.Prov_Type_ID IN ('1' , '4', '6', '9', '10', '108', '2506', '105') THEN 1
	ELSE 0 END AS AMB_Scorecard_Flag
,	CASE WHEN cte.Prov_Type_ID IN ('6', '9', '2', '2721', '2527', '101')  THEN 1
	ELSE 0 END AS app_flag
,   cte.First_Slot_Start AS first_slot_start
,   cte.Last_Slot_End AS last_slot_end
,   cte.Duration AS duration
,   cte.Slot_Time_Hrs slot_time_hours
,	1														                        AS Session_Count
,	CASE	WHEN cte.Slot_Time_Hrs >= 4			    THEN 1 ELSE NULL END                AS Standard_Flag
,	CASE	WHEN cte.Regular_Slot_Time_Hrs	> 0     THEN 1 ELSE NULL END                AS Session_Count_Reg
,	CASE	WHEN cte.Regular_Slot_Time_Hrs >= 4			    THEN 1 ELSE NULL END                AS Standard_Flag_Reg
,	cte.Regular_Slot_Time_Hrs		AS Slot_Time_Hrs_Reg
,	cte.Unavalible_Slot_Time_Hrs	AS Slot_Time_Hrs_Unav
,	CASE    WHEN cte.Slot_Time_Hrs >1.5					THEN 1 ELSE 0 END					AS Adjusted_Denom -- Used to be cte.Duration >=1.5	-- changed >= to > on 2023/05/22
-- Additional requested fields
, dd.day_of_week


/* Standard Fields */
	/* Date/times */
,	'Fmonth_num'					=	dd.Fmonth_num
,	'Fyear_num'						=	dd.Fyear_num
,	'Fyear_name'					=	dd.Fyear_name
,	'report_period'					=	CAST(LEFT(DATENAME(MONTH, dd.day_date), 3) + ' ' + CAST(DAY(dd.day_date) AS VARCHAR(2)) AS VARCHAR(10)) 
,	'report_date'					=	dd.day_date

/* Provider info */
,   'provider_id'					=	cte.Prov_ID
,	'provider_name'					=	mdmprov.Prov_Nme
,	'prov_service_line_id'			=	CAST(NULL AS INT)	
,	'prov_service_line'				=	mdmprov.Service_Line		
,	'financial_division_id'				=	CAST(REPLACE(mdmprov.Financial_Division,'na',NULL) AS INT) 
,	'financial_division_name'			=	CAST(mdmprov.Financial_Division_Name AS VARCHAR(150))
,	'financial_sub_division_id'			=	CAST(REPLACE(mdmprov.Financial_SubDivision,'na',NULL) AS INT) 
,	'financial_sub_division_name'			=	CAST(mdmprov.Financial_SubDivision_Name AS VARCHAR(150))

/* Fac/Org info */
,   'epic_department_id'			=	cte.Department_ID
,	'epic_department_name'			=	mdmdept.epic_department_name							
,	'epic_department_name_external'	=	mdmdept.epic_department_name_external							
,	'rev_location_id'				=	mdmdept.LOC_ID					
,	'rev_location'					=	mdmdept.REV_LOC_NAME				
,	'pod_id'						=	CAST(mdmdept.POD_ID	AS VARCHAR(66))	
,	'pod_name'						=	mdmdept.PFA_POD						
,	'hub_id'						=	CAST(mdmdept.HUB_ID AS VARCHAR(66))						
,	'hub_name'						=	mdmdept.HUB							

/* Service line info */
,	'service_line_id'				=	mdmdept.service_line_id
,	'service_line'					=	mdmdept.service_line
,	'sub_service_line_id'			=	mdmdept.sub_service_line_id	
,	'sub_service_line'				=	mdmdept.sub_service_line 
,	'opnl_service_id'				=	mdmdept.opnl_service_id	
,	'opnl_service_name'				=	mdmdept.opnl_service_name 
,	'corp_service_line_id'			=	mdmdept.corp_service_line_id 
,	'corp_service_line_name'		=	mdmdept.corp_service_line 
,	'hs_area_id'					=	mdmdept.hs_area_id 
,	'hs_area_name'					=	mdmdept.hs_area_name 
,	'practice_group_id'				=	mdmdept.practice_group_id 
,	'practice_group_name'			=	mdmdept.practice_group_name	

/* UPG Practice Info */
,	'upg_practice_region_id'		=	CAST(vwdep.UPG_PRACTICE_REGION_ID	AS INT) 
,	'upg_practice_region_name'		=	CAST(vwdep.UPG_PRACTICE_REGION_NAME AS VARCHAR(150)) 
,	'upg_practice_id'				=	CAST(vwdep.UPG_PRACTICE_ID			AS INT) 
,	'upg_practice_name'				=	CAST(vwdep.UPG_PRACTICE_NAME		AS VARCHAR(150)) 
,	'upg_practice_flag'				=	CAST(vwdep.UPG_PRACTICE_FLAG		AS INT) 

/* SOM info */
,	'som_hs_area_id'				=	orgmap.som_hs_area_id 
,	'som_hs_area_name'				=	CAST(orgmap.som_hs_area_name		AS VARCHAR(150))	
,	'som_group_id'					=	orgmap.som_group_id	
,	'som_group_name'				=	CAST(orgmap.som_group_name			AS VARCHAR(150)) 
,	'som_department_id'				=	orgmap.department_id 
,	'som_department_name'			=	CAST(orgmap.department				AS VARCHAR(150)) 
,	'som_division_id'				=	orgmap.Org_Number 
,	'som_division_name'				=	CAST(orgmap.Organization			AS VARCHAR(150))	

/* Others */		
,	'event_type'					=	CAST('Session Availability' AS VARCHAR(50)) 
,	'event_category'				=	CAST(NULL AS VARCHAR(150)) 
,	'sk_Dim_Pt'						=	CAST(NULL AS INT) 
,	'peds' 							=	CAST(NULL AS SMALLINT) 
,	'transplant'					=	CAST(NULL AS SMALLINT) 
,	'oncology'						=	CAST(NULL AS SMALLINT) 
,	'sk_Fact_Pt_Acct'				=	CAST(NULL AS BIGINT) 
,	'sk_Fact_Pt_Enc_Clrt'			=	CAST(NULL AS INT) 
,	'sk_dim_physcn'					=	mdmprov.sk_Dim_Physcn
,	(SELECT STRING_AGG(value,', ') FROM (SELECT DISTINCT value FROM STRING_SPLIT(cte.Unapproved_Unavailable_Reasons,',')) t) AS unapproved_unavailable_reason
,	cte.Unapproved_Unavalible_Slot_Time_Hrs	AS slot_time_hrs_unapproved

FROM cte
/*Joins for standard fields*/
	LEFT JOIN   Clarity_App..		Dim_Date								dd			ON	cte.Slot_Date = dd.day_date
	LEFT JOIN	CLARITY_App.Rptg.	vwRef_MDM_Location_Master_EpicSvc		mdmdept		ON	cte.Department_ID			= mdmdept.epic_department_id
	LEFT JOIN	CLARITY_App.Rptg.	vwCLARITY_DEP							vwdep		ON	cte.Department_ID = vwdep.DEPARTMENT_ID 		
	LEFT JOIN	CLARITY..			CLARITY_DEP								cdep		ON	cte.Department_ID = cdep.DEPARTMENT_ID 
	LEFT JOIN	CLARITY_App.Rptg.	vwDim_Clrt_SERsrc						mdmprov		ON	cte.Prov_ID				= mdmprov.PROV_ID				
	LEFT JOIN	CLARITY_App.Rptg.	vwRef_OracleOrg_to_EpicFinancialSubdiv	orgmap		ON  mdmprov.Financial_SubDivision	= orgmap.Epic_Financial_Subdivision_Code
*/

GO


