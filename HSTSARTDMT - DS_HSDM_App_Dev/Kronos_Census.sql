USE DS_HSDM_App_Dev

IF OBJECT_ID('tempdb..#staffed ') IS NOT NULL
DROP TABLE #staffed

IF OBJECT_ID('tempdb..#staffed_detail ') IS NOT NULL
DROP TABLE #staffed_detail

SELECT [EPIC_DEPARTMENT_ID]
      ,ddte.day_date AS CENSUS_DT

  INTO #staffed

  FROM [DS_HSDM_App_Dev].[ETL].[Kronos_Census] census
  LEFT OUTER JOIN DS_HSDM_App.Rptg.vwDim_Date ddte
  ON ddte.day_date = CAST(CAST(census.CENSUS_DTTM AS DATE) AS SMALLDATETIME)
  WHERE ddte.day_date BETWEEN '7/1/2023' and '11/20/2023'
  GROUP BY census.EPIC_DEPARTMENT_ID, ddte.day_date
  HAVING SUM(census.CENSUS) > 0

SELECT census.[EPIC_DEPARTMENT_ID]
      ,[EPIC_DEPARTMENT_NAME]
      ,[CENSUS]
      ,[CENSUS_DTTM]
	  ,ddte.day_date
	  ,ddte.day_of_week_num
	  ,ddte.day_of_week

  INTO #staffed_detail

  FROM [DS_HSDM_App_Dev].[ETL].[Kronos_Census] census
  LEFT OUTER JOIN DS_HSDM_App.Rptg.vwDim_Date ddte
  ON ddte.day_date = CAST(CAST(census.CENSUS_DTTM AS DATE) AS SMALLDATETIME)
  INNER JOIN #staffed staffed
  ON staffed.EPIC_DEPARTMENT_ID = census.EPIC_DEPARTMENT_ID
  AND staffed.CENSUS_DT = ddte.day_date

  SELECT EPIC_DEPARTMENT_ID
	, EPIC_DEPARTMENT_NAME
	, day_date AS CENSUS_DATE
	, day_of_week AS DOW
	, day_of_week_num AS DOW_NUM
	, MIN(CENSUS) AS MINIMUM_CENSUS
	, CAST(AVG(CAST(CENSUS AS NUMERIC(7,3))) AS NUMERIC(6,2)) AS AVERAGE_CENSUS
	, MAX(CENSUS) AS MAXIMUM_CENSUS
	, SUM(CENSUS) AS CENSUS_TOTAL
	, COUNT(*) AS CENSUS_MEASURES
  FROM #staffed_detail
  GROUP BY EPIC_DEPARTMENT_ID
	, EPIC_DEPARTMENT_NAME
	, day_date
	, day_of_week
	, day_of_week_num
 -- ORDER BY EPIC_DEPARTMENT_ID
	--, EPIC_DEPARTMENT_NAME
	--, day_date
	--, day_of_week
	--, day_of_week_num
  ORDER BY EPIC_DEPARTMENT_NAME
	, day_date
	, day_of_week
	, day_of_week_num