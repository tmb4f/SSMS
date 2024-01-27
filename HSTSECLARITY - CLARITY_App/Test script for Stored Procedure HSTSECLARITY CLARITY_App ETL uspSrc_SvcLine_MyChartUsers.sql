USE [CLARITY_App]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

DECLARE @startdate SMALLDATETIME = NULL, 
        @enddate SMALLDATETIME = NULL

--SET @startdate = '12/1/2021 00:00 AM'
--SET @enddate = '12/31/2021 11:59 PM'
--SET @startdate = '2/1/2022 00:00 AM'
--SET @enddate = '2/28/2022 11:59 PM'
--SET @startdate = '7/1/2021 00:00 AM'
--SET @enddate = '3/31/2022 11:59 PM'
SET @startdate = '1/1/2021 00:00'
SET @enddate = '3/31/2022 23:59'

--ALTER PROCEDURE [ETL].[uspSrc_SvcLine_MyChartUsers]
--    (
--     @startdate SMALLDATETIME = NULL
--    ,@enddate SMALLDATETIME = NULL
--    )
--AS --/**********************************************************************************************************************
--WHAT: ETL.uspSrc_SvcLine_MyChartUsers
--WHO : Linda Lemieux/Dayna Monaghan
--WHEN: 10/26/17
--WHY : Detail to provide a cumulative count of mychart users
-------------------------------------------------------------------------------------------------------------------------
--INFO: 
--      INPUTS:	dbo.Dim_Date
--				(Mapping Table)
--			CLARITY.dbo.MYC_PT_USER_ACCSS 
--			CLARITY.dbo.PATIENT_MYC
--			CLARITY.dbo.PATIENT
--			CLARITY.dbo.ZC_SEX


                
--      OUTPUTS:  TabRptg.Dash_BalancedScorecard_MyChart_Users
   
--------------------------------------------------------------------------------------------------------------------------
--MODS: 	
--************************************************************************************************************************

    SET NOCOUNT ON;
	
---------------------------------------------------
 ----get default Balanced Scorecard date range
 IF @startdate IS NULL AND @enddate IS NULL
    EXEC etl.usp_Get_Dash_Dates_BalancedScorecard @startdate OUTPUT, @enddate OUTPUT
----------------------------------------------------
--replace calc'd start date
--this is a hard-coded start date to match Epic reporting criteria
    --SET @startdate = '7/1/2010';

-------------------------------------------------------------------

DECLARE @locstartdate SMALLDATETIME,
        @locenddate SMALLDATETIME
SET @locstartdate = @startdate
SET @locenddate   = @enddate

IF OBJECT_ID('tempdb..#datetable') is not NULL
DROP TABLE #datetable

IF OBJECT_ID('tempdb..#calendar_months') is not NULL
DROP TABLE #calendar_months
  
IF OBJECT_ID('tempdb..#mychart_users ') IS NOT NULL
DROP TABLE #mychart_users

SELECT date_dim.day_date
      ,date_dim.month_num
	  ,date_dim.month_name
      ,date_dim.year_num
      ,date_dim.Year_name
INTO #datetable
FROM CLARITY_App.Rptg.vwDim_Date AS date_dim
WHERE date_dim.day_date >= @locstartdate
AND date_dim.day_date < @locenddate
ORDER BY date_dim.day_date

  -- Create index for temp table #datetable
  CREATE UNIQUE CLUSTERED INDEX IX_datetable ON #datetable ([day_date])

SELECT DISTINCT
       date_dim.month_num
	  ,date_dim.month_name
      ,date_dim.year_num
      ,date_dim.Year_name
INTO #calendar_months
FROM #datetable date_dim
ORDER BY date_dim.year_num, date_dim.month_num

  -- Create index for temp table #calendar_months
  CREATE UNIQUE CLUSTERED INDEX IX_calendar_months ON #calendar_months (year_num, month_num)

  SELECT date_dim.year_num AS running_year_num
              , date_dim.Year_name AS running_year_name
			  , date_dim.month_num AS running_month_num
			  , date_dim.month_name AS running_month_name
			  , mychart.event_type
			  --, mychart.hs_area_id
			  , mychart.event_count

  INTO #mychart_users

  FROM
  (
    SELECT	
            --date_dim.month_begin_date AS event_date
            CAST('MyChart Access' AS VARCHAR(50)) AS event_type
           ,CAST(CASE WHEN MYChart.person_id IS NOT NULL THEN 1
                               ELSE 0
                          END AS INT) AS event_count
           ,date_dim.day_date AS event_date
           ,CAST(NULL AS VARCHAR(150)) AS event_category
           ,CAST(NULL AS NUMERIC(18, 0)) AS epic_department_id
           ,CAST(NULL AS VARCHAR(255)) AS epic_department_name
           ,CAST(NULL AS VARCHAR(255)) AS epic_department_name_external
           ,date_dim.month_num
           ,date_dim.year_num
           ,CAST(LEFT(DATENAME(MM, date_dim.day_date), 3) + ' ' + CAST(DAY(date_dim.day_date) AS VARCHAR(2)) AS VARCHAR(10)) AS report_period
           ,CAST(CAST(date_dim.day_date AS DATE) AS SMALLDATETIME) AS report_date
           ,CAST(CASE WHEN FLOOR((CAST (date_dim.day_date AS INTEGER) - CAST(CAST(MYChart.BIRTH_DATE AS DATETIME) AS INTEGER)) / 365.25) < 18 THEN 1
                      ELSE 0
                 END AS SMALLINT) AS peds
           ,CAST(NULL AS SMALLINT) AS transplant
           ,CAST(NULL AS INT) AS sk_Dim_Pt
           ,MYChart.BIRTH_DATE AS person_birth_date
           ,MYChart.NAME AS person_gender
           ,MYChart.person_id
           ,MYChart.PAT_NAME AS person_name
		   ,MYChart.PAT_ID                                                  ----BDD 11/9/2017 added
           ,CAST(NULL AS INT) AS practice_group_id
           ,CAST(NULL AS VARCHAR(150)) AS practice_group_name
           ,CAST(NULL AS VARCHAR(18)) AS provider_id
           ,CAST(NULL AS VARCHAR(200)) AS provider_name
           ,CAST(NULL AS INT) AS service_line_id
           ,CAST(NULL AS VARCHAR(150)) AS service_line
           ,CAST(NULL AS INT) AS sub_service_line_id
           ,CAST(NULL AS VARCHAR(150)) AS sub_service_line
           ,CAST(NULL AS INT) AS opnl_service_id
           ,CAST(NULL AS VARCHAR(150)) AS opnl_service_name
           ,CAST(NULL AS SMALLINT) AS hs_area_id
           ,CAST(NULL AS VARCHAR(150)) AS hs_area_name
       --,COUNT(DISTINCT MYChart.[MyChart ID]) AS Total_MyChart_Users
        FROM
            CLARITY_App.dbo.Dim_Date AS date_dim
        LEFT OUTER JOIN (
                         SELECT DISTINCT
                                myc.MYPT_ID AS person_id
                               ,CAST(pat.PAT_MRN_ID AS VARCHAR(25)) AS PAT_MRN_ID                         ---BDD 10/17/2018 Cast for Epic upgrade
							   ,pat.PAT_ID                                 ----BDD 11/09/2017 added
                               ,pat.BIRTH_DATE
                               ,pat.PAT_NAME
                               ,gender.NAME
                               ,FIRST_VALUE(myc.UA_TIME) OVER (PARTITION BY myc.MYPT_ID ORDER BY myc.UA_TIME ROWS UNBOUNDED PRECEDING) AS FIRST_DATE
                               ,CASE WHEN FIRST_VALUE(myc.UA_EXTENDED_INFO) OVER (PARTITION BY myc.MYPT_ID ORDER BY myc.UA_TIME ROWS UNBOUNDED PRECEDING) IS NULL
                                     THEN 1
                                     ELSE 0
                                END AS Mobile_or_Tablet_Device_Access
                               ,CASE WHEN FIRST_VALUE(myc.UA_USER_AGENT) OVER (PARTITION BY myc.MYPT_ID ORDER BY myc.UA_TIME ROWS UNBOUNDED PRECEDING) LIKE '%iphone%'
                                     THEN 'iPhone'
                                     WHEN FIRST_VALUE(myc.UA_USER_AGENT) OVER (PARTITION BY myc.MYPT_ID ORDER BY myc.UA_TIME ROWS UNBOUNDED PRECEDING) LIKE '%android%'
                                     THEN 'Android'
                                END AS Mobile_OS
                            FROM
                                CLARITY.dbo.MYC_PT_USER_ACCSS AS myc
                            LEFT OUTER JOIN CLARITY.dbo.PATIENT_MYC AS pmyc
                            ON  myc.MYPT_ID = pmyc.MYPT_ID
                            LEFT OUTER JOIN CLARITY.dbo.PATIENT AS pat
                            ON  pmyc.PAT_ID = pat.PAT_ID
                            LEFT OUTER JOIN CLARITY.dbo.ZC_SEX AS gender
                            ON  pat.SEX_C = gender.RCPT_MEM_SEX_C
                            WHERE
                                myc.USER_ID IS NULL
                                AND myc.MYC_UA_TYPE_C IN ('1', '191')
                        ) AS MYChart
        ON  date_dim.day_date = CAST (MYChart.FIRST_DATE AS DATE)
  ) mychart
  INNER JOIN #calendar_months date_dim
  ON ((mychart.year_num < date_dim.year_num)
        OR ((mychart.year_num = date_dim.year_num) AND (mychart.month_num <= date_dim.month_num)))
        --WHERE
        --    date_dim.day_date >= @startdate
        --    AND date_dim.day_date < @enddate
        --ORDER BY
        --    date_dim.day_date;
        --ORDER BY
        --    date_dim.year_num, date_dim.month_num;

SELECT running_year_num,
       running_year_name,
       running_month_num,
       running_month_name,
       event_type,
       SUM(event_count) AS My_Chart_User
FROM #mychart_users
GROUP BY
       running_year_num,
       running_year_name,
       running_month_num,
       running_month_name,
       event_type
ORDER BY
       running_year_num,
       running_year_name,
       running_month_num,
       running_month_name,
       event_type

GO


