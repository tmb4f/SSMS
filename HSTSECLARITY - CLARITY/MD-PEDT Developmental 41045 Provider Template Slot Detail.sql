USE [CLARITY]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

DECLARE @StartDate SMALLDATETIME = NULL
       ,@EndDate SMALLDATETIME = NULL

--SET @StartDate = '10/1/2017 00:00:00'
--SET @StartDate = '11/10/2018 00:00:00'
--SET @StartDate = '7/1/2020 00:00:00'
--SET @EndDate = '6/30/2023 00:00:00'
SET @StartDate = '7/1/2020 00:00 AM'
SET @EndDate = '6/30/2023 11:59 PM'

--SET @StartDate = '3/15/2021 00:00 AM'
--SET @EndDate = '3/15/2021 11:59 PM'
--SET @StartDate = '4/5/2021 00:00 AM'
--SET @EndDate = '4/5/2021 11:59 PM'
--SET @StartDate = '5/17/2021 00:00 AM'
--SET @EndDate = '5/17/2021 11:59 PM'
--SET @StartDate = '12/20/2021 00:00 AM'
--SET @EndDate = '12/20/2021 11:59 PM'
--SET @StartDate = '1/31/2022 00:00 AM'
--SET @EndDate = '1/31/2022 11:59 PM'

  SET NOCOUNT ON;

  --SELECT @StartDate, @EndDate

---------------------------------------------------
---Default date range is the prior day up to the following two months
  DECLARE @CurrDate SMALLDATETIME;

  SET @CurrDate = CAST(CAST(GETDATE() AS DATE) AS SMALLDATETIME);

  IF @StartDate IS NULL
      BEGIN
          -- Yesterday's date
          SET @StartDate = CAST(CAST(DATEADD(DAY, -1, @CurrDate) AS DATE) AS SMALLDATETIME)
          + CAST(CAST('00:00:00' AS TIME) AS SMALLDATETIME);
      END;
  IF @EndDate IS NULL
      BEGIN
          -- End of month, six months ahead from current date
          SET @EndDate = CAST(EOMONTH(@CurrDate, 6) AS SMALLDATETIME)
          + CAST(CAST('23:59:59' AS TIME) AS SMALLDATETIME);
      END;
----------------------------------------------------

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

IF OBJECT_ID('tempdb..#avail_aggr ') IS NOT NULL
DROP TABLE #avail_aggr

IF OBJECT_ID('tempdb..#booked_blocks ') IS NOT NULL
DROP TABLE #booked_blocks

IF OBJECT_ID('tempdb..#used_blocks ') IS NOT NULL
DROP TABLE #used_blocks

IF OBJECT_ID('tempdb..#tmpl_booked_blocks ') IS NOT NULL
DROP TABLE #tmpl_booked_blocks

IF OBJECT_ID('tempdb..#tmpl_used_blocks ') IS NOT NULL
DROP TABLE #tmpl_used_blocks

IF OBJECT_ID('tempdb..#tmpl_avail_blocks ') IS NOT NULL
DROP TABLE #tmpl_avail_blocks

IF OBJECT_ID('tempdb..#tmpl_avail_blocks_aggr ') IS NOT NULL
DROP TABLE #tmpl_avail_blocks_aggr

IF OBJECT_ID('tempdb..#tmpl_avail_blocks_summ ') IS NOT NULL
DROP TABLE #tmpl_avail_blocks_summ

IF OBJECT_ID('tempdb..#booked_appts ') IS NOT NULL
DROP TABLE #booked_appts

IF OBJECT_ID('tempdb..#booked_appts_aggr ') IS NOT NULL
DROP TABLE #booked_appts_aggr

IF OBJECT_ID('tempdb..#tmpl_avail_blocks_booked ') IS NOT NULL
DROP TABLE #tmpl_avail_blocks_booked

IF OBJECT_ID('tempdb..#sched_appts ') IS NOT NULL
DROP TABLE #sched_appts

IF OBJECT_ID('tempdb..#RptgTmp ') IS NOT NULL
DROP TABLE #RptgTmp

IF OBJECT_ID('tempdb..#RptgTmpStats ') IS NOT NULL
DROP TABLE #RptgTmpStats

IF OBJECT_ID('tempdb..#RptgTmp2 ') IS NOT NULL
DROP TABLE #RptgTmp2

IF OBJECT_ID('tempdb..#tmpl_booked_appts ') IS NOT NULL
DROP TABLE #tmpl_booked_appts

IF OBJECT_ID('tempdb..#tmpl ') IS NOT NULL
DROP TABLE #tmpl

DECLARE @DevPeds TABLE (Provider_Id VARCHAR(30))

INSERT INTO @DevPeds
(
    Provider_Id
)
VALUES
('107673'), -- ANDERSON, CAITLIN E
('28771	'), --  LETZKUS, LISA CANTORE
('29987'), --	STEVENSON, RICHARD D
('30063'), --	NORWOOD, KENNETH
('45888'), --	WHITE, ELIZABETH M.
('46620'), --	SCHARF, REBECCA
('52816	'), --  BAHL, ALISA B
('54283	'), --  MCNERNEY, STEPHANIE B
('56723'), --	INTAGLIATA, VALENTINA J
('66982	'), --  SHAFFER, LAURA A
('67454	'), --  GONZALEZ, ROSE E.
--('67454	'), --  GONZALEZ, ROSE E
('70739'), --	BISHOP, KARRI M
('75034'), --	FRAZIER, KATHERYN F
('76007'), --	STURGILL, ALISON
('76058'), --	FANG, CHRISTINA
('82958	'), --  MADDEN, DANA
('83198	'), --  DAVIS, BETH E.
('92260	'), --  HERRERA, JENNIFFER T.
('93082	')  --  STEPHENS, HALEY F
--('45888') --	WHITE, ELIZABETH M.
--('29987')--, --	STEVENSON, RICHARD D
--('107673'), -- ANDERSON, CAITLIN E
--('28771	'), --  LETZKUS, LISA CANTORE
--('29987'), --	STEVENSON, RICHARD D
--('30063'), --	NORWOOD, KENNETH
--('45888')--, --	WHITE, ELIZABETH M.

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
	 , avail.ORG_REG_OPENINGS AS Regular_Openings
	 , avail.ORG_OVBK_OPENINGS AS Overbook_Openings
	 ,[avail].NUM_APTS_SCHEDULED AS [Openings_Booked]
	 ,CASE WHEN [avail].UNAVAILABLE_RSN_C IS NULL THEN [avail].ORG_REG_OPENINGS ELSE 0 END AS [Regular_Openings_Available]
	 ,CASE WHEN [avail].UNAVAILABLE_RSN_C IS NOT NULL THEN [avail].ORG_REG_OPENINGS ELSE 0 END AS [Regular_Openings_Unavailable]
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
FROM dbo.V_AVAILABILITY avail
--LEFT OUTER JOIN dbo.AVAIL_BLOCK blk
--ON blk.DEPARTMENT_ID = avail.DEPARTMENT_ID
--AND blk.PROV_ID = avail.PROV_ID
--AND blk.SLOT_BEGIN_TIME = avail.SLOT_BEGIN_TIME
INNER JOIN @DevPeds DevPeds
ON avail.PROV_ID = DevPeds.Provider_Id
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
FROM dbo.ES_SCHED_TEMPLATE tmpl
--INNER JOIN CLARITY_App.Rptg.vwDim_Date ddte
--ON CAST(tmpl.BEGIN_DATE_TM_RANGE AS DATE) = ddte.day_date
LEFT OUTER JOIN CLARITY.dbo.CLARITY_DEP dep
ON dep.DEPARTMENT_ID = tmpl.DEPARTMENT_ID
LEFT OUTER JOIN CLARITY.dbo.CLARITY_SER ser
ON ser.PROV_ID = tmpl.PROV_ID
LEFT OUTER JOIN dbo.ZC_DAY_OF_THE_WEEK zdow
ON zdow.DAY_OF_THE_WEEK_C = tmpl.DAY_OF_THE_WEEK_C
INNER JOIN @DevPeds DevPeds
ON tmpl.PROV_ID = DevPeds.Provider_Id
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
FROM dbo.AVAIL_BLOCK blk
LEFT OUTER JOIN dbo.ZC_APPT_BLOCK zab
ON zab.APPT_BLOCK_C = blk.BLOCK_C
--LEFT OUTER JOIN dbo.ZC_APPT_BLOCK zarb
--ON zarb.APPT_BLOCK_C = blk.REL_BLOCK_C
--LEFT OUTER JOIN dbo.AVAIL_BLOCK blk
--ON blk.DEPARTMENT_ID = avail.DEPARTMENT_ID
--AND blk.PROV_ID = avail.PROV_ID
--AND blk.SLOT_BEGIN_TIME = avail.SLOT_BEGIN_TIME
INNER JOIN @DevPeds DevPeds
ON blk.PROV_ID = DevPeds.Provider_Id
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
     , avail_blk.DEPARTMENT_NAME
     , avail_blk.PROV_ID
	 , avail_blk.PROV_NM_WID
	 , avail_blk.APPT_SLOT_DATE
	 , avail_blk.APPT_SLOT_BEGIN_TIME
	 , avail_blk.APPT_SLOT_END_TIME
	 , COALESCE(avail_blk.SLOT_BEGIN_TIME, avail_blk.APPT_SLOT_BEGIN_TIME, NULL) AS SLOT_BEGIN_TIME
	 , avail_blk.Regular_Openings
	 , avail_blk.Overbook_Openings
	 , avail_blk.Openings_Booked
	 , avail_blk.Regular_Openings_Available
	 , avail_blk.Regular_Openings_Unavailable
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
     , tmpl.DEPARTMENT_NAME
	 , tmpl.PROV_ID
	 , tmpl.PROV_NM_WID
	 , tmpl.APPT_SLOT_DATE
	 , tmpl.APPT_SLOT_BEGIN_TIME
	 , tmpl.APPT_SLOT_END_TIME
	 ,tmpl.Regular_Openings
	 ,tmpl.Overbook_Openings
	 ,tmpl.Openings_Booked
	 ,tmpl.Regular_Openings_Available
	 ,tmpl.Regular_Openings_Unavailable
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
		FROM #tmpl_avail_blocks availt
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
       avail.DEPARTMENT_NAME,
       avail.PROV_ID,
	   avail.PROV_NM_WID,
       avail.APPT_SLOT_DATE,
       avail.APPT_SLOT_BEGIN_TIME,
       avail.APPT_SLOT_END_TIME,
	   avail.SLOT_BEGIN_TIME,
	   avail.Regular_Openings,
	   avail.Overbook_Openings,
	   avail.Openings_Booked,
	   avail.Regular_Openings_Available,
	   avail.Regular_Openings_Unavailable,
       avail.OPENINGS_PER_SLOT,
       avail.NUMBER_OB_ALLOWED,
	   avail.SLOT_LENGTH,
	   LEFT(aggr.BLOCKS_USED_STRING, LEN(aggr.BLOCKS_USED_STRING)-1) AS BLOCK_USE

INTO #tmpl_avail_blocks_summ

FROM
(
SELECT DISTINCT
	DEPARTMENT_ID,
	DEPARTMENT_NAME,
    PROV_ID,
	PROV_NM_WID,
    APPT_SLOT_DATE,
    APPT_SLOT_BEGIN_TIME,
    APPT_SLOT_END_TIME,
    SLOT_BEGIN_TIME,
	Regular_Openings,
	Overbook_Openings,
	Openings_Booked,
	Regular_Openings_Available,
	Regular_Openings_Unavailable,
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

/* #tmpl_avail_blocks
SELECT avail_blk.DEPARTMENT_ID
     , avail_blk.PROV_ID
	 , avail_blk.TEMPLATE_SLOT_DATE
	 , avail_blk.TEMPLATE_SLOT_BEGIN_TIME
	 , avail_blk.TEMPLATE_SLOT_END_TIME
	 , avail_blk.SLOT_BEGIN_TIME
	 , avail_blk.LINE
	 , COALESCE(avail_blk.BLOCK_NAME,'No Block Information') AS BLOCK_NAME
	 , avail_blk.ORG_AVAIL_BLOCKS
     --,ROW_NUMBER() OVER (PARTITION BY avail_blk.DEPARTMENT_ID, avail_blk.PROV_ID, avail_blk.TEMPLATE_SLOT_DATE, avail_blk.TEMPLATE_SLOT_BEGIN_TIME, avail_blk.TEMPLATE_SLOT_END_TIME, COALESCE(avail_blk.BLOCK_NAME,'No Block Information') ORDER BY avail_blk.ORG_AVAIL_BLOCKS DESC) AS Seq
     ,ROW_NUMBER() OVER (PARTITION BY avail_blk.DEPARTMENT_ID, avail_blk.PROV_ID, avail_blk.TEMPLATE_SLOT_DATE, avail_blk.TEMPLATE_SLOT_BEGIN_TIME, avail_blk.TEMPLATE_SLOT_END_TIME, LINE ORDER BY avail_blk.ORG_AVAIL_BLOCKS DESC) AS Seq
INTO #tmpl_avail_blocks
FROM
(
SELECT tmpl.DEPARTMENT_ID
	 , tmpl.PROV_ID
	 , tmpl.TEMPLATE_SLOT_DATE
	 , tmpl.TEMPLATE_SLOT_BEGIN_TIME
	 , tmpl.TEMPLATE_SLOT_END_TIME
	 , blk.SLOT_BEGIN_TIME
	 , blk.LINE
	 , blk.BLOCK_NAME
	 , blk.ORG_AVAIL_BLOCKS
FROM #schdtmpl tmpl
LEFT OUTER JOIN
(
SELECT avail_block.DEPARTMENT_ID
     , avail_block.PROV_ID
	 , avail_block.SLOT_DATE
	 , avail_block.SLOT_BEGIN_TIME
	 , avail_block.LINE
	 , avail_block.BLOCK_NAME
	 , avail_block.ORG_AVAIL_BLOCKS
FROM #avail_block avail_block) blk
ON blk.DEPARTMENT_ID = tmpl.DEPARTMENT_ID
AND blk.PROV_ID = tmpl.PROV_ID
AND blk.SLOT_DATE = tmpl.TEMPLATE_SLOT_DATE
AND blk.SLOT_BEGIN_TIME >= tmpl.TEMPLATE_SLOT_BEGIN_TIME
AND blk.SLOT_BEGIN_TIME < tmpl.TEMPLATE_SLOT_END_TIME
) avail_blk
ORDER BY avail_blk.DEPARTMENT_ID
       , avail_blk.PROV_ID
	   , avail_blk.TEMPLATE_SLOT_DATE
	   , avail_blk.TEMPLATE_SLOT_BEGIN_TIME
	   , avail_blk.TEMPLATE_SLOT_END_TIME
	   , avail_blk.SLOT_BEGIN_TIME
	   , avail_blk.LINE

  -- Create index for temp table #tmpl_avail_blocks
  CREATE UNIQUE CLUSTERED INDEX IX_tmpl_avail_blocks ON #tmpl_avail_blocks (DEPARTMENT_ID, PROV_ID, TEMPLATE_SLOT_DATE, TEMPLATE_SLOT_BEGIN_TIME, TEMPLATE_SLOT_END_TIME, SLOT_BEGIN_TIME, LINE)

--SELECT *
--FROM #tmpl_avail_blocks
--ORDER BY DEPARTMENT_ID
--       , PROV_ID
--	   , TEMPLATE_SLOT_DATE
--	   , TEMPLATE_SLOT_BEGIN_TIME
--	   , TEMPLATE_SLOT_END_TIME
--	   --, COALESCE(BLOCK_NAME,'No Block Information')
--	   , LINE
--	   , Seq
*/ -- #tmpl_avail_blocks

--/* -- #booked_appts
SELECT avail.DEPARTMENT_ID
     , avail.PROV_ID
	 , avail.SLOT_DATE
	 , CAST(avail.SLOT_BEGIN_TIME AS TIME) AS SLOT_BEGIN_TIME
	 , CAST(avail.SLOT_END_TIME AS TIME) AS SLOT_END_TIME
	 , avail.APPT_NUMBER
	 , avail.APPT_OVERBOOK_YN
	 , avail.PAT_ENC_CSN_ID
	 , avail.PAT_ID
INTO #booked_appts
FROM dbo.V_AVAILABILITY avail
--FROM #avail avail
INNER JOIN @DevPeds DevPeds
ON avail.PROV_ID = DevPeds.Provider_Id
WHERE avail.APPT_NUMBER > 0
AND CAST(avail.SLOT_DATE AS DATE) >= CAST(@StartDate AS DATE)
AND CAST(avail.SLOT_DATE AS DATE) <= CAST(@EndDate AS DATE)

--SELECT *
--FROM #booked_appts avail
--ORDER BY avail.DEPARTMENT_ID
--       , avail.PROV_ID
--       , avail.SLOT_DATE
--       , avail.SLOT_BEGIN_TIME
--*/ -- #booked_appts

--/* -- #booked_appts_aggr
SELECT avail.DEPARTMENT_ID
     , avail.PROV_ID
	 , avail.SLOT_DATE
	 , avail.SLOT_BEGIN_TIME
	 , avail.SLOT_END_TIME
	 , COUNT(*) AS Booked
	 , SUM(CASE WHEN avail.APPT_OVERBOOK_YN = 'Y' THEN 1 ELSE 0 END) AS Booked_Ovbs
	 , SUM(CASE WHEN avail.APPT_OVERBOOK_YN = 'N' THEN 1 ELSE 0 END) AS Booked_Opns
	 --, SUM(avail.ORG_AVAIL_BLOCKS) AS ORG_AVAIL_BLOCKS
	 --, SUM(avail.BLOCKS_USED) AS BLOCKS_USED
INTO #booked_appts_aggr
FROM #booked_appts avail
GROUP BY avail.DEPARTMENT_ID
       , avail.PROV_ID
       , avail.SLOT_DATE
       , avail.SLOT_BEGIN_TIME
	   , avail.SLOT_END_TIME

--SELECT *
--FROM #booked_appts_aggr avail
--ORDER BY avail.DEPARTMENT_ID
--       , avail.PROV_ID
--       , avail.SLOT_DATE
--       , avail.SLOT_BEGIN_TIME
--*/ -- #booked_appts_aggr

SELECT 
       avail.DEPARTMENT_ID,
	   avail.DEPARTMENT_NAME,
       avail.PROV_ID,
	   avail.PROV_NM_WID,
       avail.APPT_SLOT_DATE,
       avail.APPT_SLOT_BEGIN_TIME,
       avail.APPT_SLOT_END_TIME,
	   avail.SLOT_BEGIN_TIME,
	   avail.Regular_Openings,
	   avail.Overbook_Openings,
	   avail.Openings_Booked,
	   avail.Regular_Openings_Available,
	   avail.Regular_Openings_Unavailable,
       avail.OPENINGS_PER_SLOT,
       avail.NUMBER_OB_ALLOWED,
	   avail.SLOT_LENGTH,
       avail.BLOCK_USE,
       COALESCE(appts.Booked,0) AS Booked_Total,
	   COALESCE(appts.Booked_Opns,0) AS Booked_Opns,
	   COALESCE(appts.Booked_Ovbs,0) AS Booked_Ovbs
INTO #tmpl_avail_blocks_booked
FROM #tmpl_avail_blocks_summ avail
LEFT OUTER JOIN #booked_appts_aggr appts
ON appts.DEPARTMENT_ID = avail.DEPARTMENT_ID
AND appts.PROV_ID = avail.PROV_ID
AND appts.SLOT_DATE = avail.APPT_SLOT_DATE
AND appts.SLOT_BEGIN_TIME = avail.APPT_SLOT_BEGIN_TIME
AND appts.SLOT_END_TIME = avail.APPT_SLOT_END_TIME

--SELECT *
--FROM #tmpl_avail_blocks_booked
--ORDER BY DEPARTMENT_ID
--       , PROV_ID
--       , APPT_SLOT_DATE
--	   , APPT_SLOT_BEGIN_TIME

          SELECT DISTINCT            ---BDD 8/22/2019 added distinct to counteract July change dupe rows

			--patient info
                    F_SCHED_APPT.PAT_ENC_CSN_ID , 
                    F_SCHED_APPT.PAT_ID ,
                    PATIENT.PAT_NAME ,
                    CAST(IDENTITY_ID.IDENTITY_ID AS VARCHAR(50)) AS IDENTITY_ID , --MRN
                    COALESCE(prc.PRC_NAME,CASE
                                           WHEN F_SCHED_APPT.PRC_ID IS NULL THEN '*Unspecified visit type'
                                           ELSE
                                            CASE 
                                              WHEN prc.PRC_ID IS NULL THEN '*Unknown visit type'
                                              ELSE '*Unnamed visit type'
                                            END + ' [' + F_SCHED_APPT.PRC_ID + ']' END 
							) AS PRC_NAME,
                    F_SCHED_APPT.APPT_STATUS_C ,
                    CAST(CASE 
                        WHEN F_SCHED_APPT.APPT_STATUS_C = 1 AND F_SCHED_APPT.SIGNIN_DTTM IS NOT NULL THEN 'Present'
                        WHEN zcappt.NAME IS NOT NULL THEN zcappt.NAME
                        ELSE 
                           CASE
                              WHEN zcappt.APPT_STATUS_C IS NULL THEN '*Unknown status'
                              ELSE '*Unnamed status'
                              END + ' [' + CONVERT(VARCHAR(254), F_SCHED_APPT.APPT_STATUS_C) + ']'
                    END AS VARCHAR(254)) AS APPT_STATUS_NAME,
                    CAST(CASE
					  WHEN F_SCHED_APPT.CANCEL_REASON_C IS NULL THEN NULL
					  WHEN canc.CANCEL_REASON_C IS NULL THEN '*Unknown cancel reason [' + CONVERT(VARCHAR(55), F_SCHED_APPT.cancel_reason_c) + ']'
					  WHEN (SELECT COUNT(PAT_INIT_CANC_C) FROM CLARITY.dbo.PAT_INIT_CANC 
							WHERE PAT_INIT_CANC_C=canc.CANCEL_REASON_C) >= 1 THEN 'PATIENT'
					  WHEN (SELECT COUNT(PROV_INIT_CANC_C) FROM CLARITY.dbo.PROV_INIT_CANC 
							WHERE PROV_INIT_CANC_C=canc.CANCEL_REASON_C) >= 1 THEN 'PROVIDER'
					  ELSE 'OTHER'
				    END AS VARCHAR(55)) AS CANCEL_INITIATOR ,
			--dates/times
                    F_SCHED_APPT.CONTACT_DATE ,
                    F_SCHED_APPT.APPT_MADE_DATE ,
                    F_SCHED_APPT.APPT_CANC_DATE ,
                    F_SCHED_APPT.APPT_DTTM ,
                    F_SCHED_APPT.PROV_ID ,
                    CASE
						WHEN F_SCHED_APPT.PROV_ID IS NULL
							THEN '*Unspecified provider'
						ELSE
							CASE
								WHEN CLARITY_SER.prov_name IS NOT NULL
									THEN CLARITY_SER.prov_name
								WHEN CLARITY_SER.prov_id IS NULL
									THEN '*Unknown provider'
								ELSE '*Unnamed provider'
							END + ' [' + F_SCHED_APPT.prov_id + ']'
				     END AS PROV_NAME_WID,
                    CLARITY_SER.PROV_NAME ,
			 --fac-org info
                    F_SCHED_APPT.DEPARTMENT_ID ,
                    CLARITY_DEP.DEPARTMENT_NAME ,
			 --appt status flag
					CAST(CASE
					  WHEN ( F_SCHED_APPT.APPT_STATUS_C = 3 -- Canceled
                               AND (CASE
					                  WHEN F_SCHED_APPT.CANCEL_REASON_C IS NULL THEN NULL
					                  WHEN canc.CANCEL_REASON_C IS NULL THEN '*Unknown cancel reason [' + CONVERT(VARCHAR(254), F_SCHED_APPT.cancel_reason_c) + ']'
					                  WHEN (SELECT COUNT(PAT_INIT_CANC_C) FROM CLARITY.dbo.PAT_INIT_CANC 
							                  WHERE PAT_INIT_CANC_C=canc.CANCEL_REASON_C) >= 1 THEN 'PATIENT'
					                  WHEN (SELECT COUNT(PROV_INIT_CANC_C) FROM CLARITY.dbo.PROV_INIT_CANC 
							                  WHERE PROV_INIT_CANC_C=canc.CANCEL_REASON_C) >= 1 THEN 'PROVIDER'
					                  ELSE 'OTHER'
				                    END
								   ) = 'PATIENT'
                               AND DATEDIFF(MINUTE, F_SCHED_APPT.APPT_CANC_DTTM, F_SCHED_APPT.APPT_DTTM) / 60 < 24) THEN 'Canceled Late'
					  ELSE CASE 
                               WHEN F_SCHED_APPT.APPT_STATUS_C = 1 AND F_SCHED_APPT.SIGNIN_DTTM IS NOT NULL THEN 'Present'
                               WHEN zcappt.NAME IS NOT NULL THEN zcappt.NAME
                               ELSE 
                                   CASE
                                     WHEN zcappt.APPT_STATUS_C IS NULL THEN '*Unknown status'
                                     ELSE '*Unnamed status'
                                   END + ' [' + CONVERT(VARCHAR(254), F_SCHED_APPT.APPT_STATUS_C) + ']'
                           END

					END AS VARCHAR(254)) AS APPT_STATUS_FLAG ,
					CAST(CAST(F_SCHED_APPT.APPT_DTTM AS DATE) AS DATETIME) AS APPT_DT ,
					CAST(F_SCHED_APPT.APPT_DTTM AS TIME) AS APPT_TM ,
                    F_SCHED_APPT.APPT_LENGTH ,
					DATEADD(MINUTE, F_SCHED_APPT.APPT_LENGTH, F_SCHED_APPT.APPT_DTTM) AS APPT_DTTM_END ,
					CAST(DATEADD(MINUTE, F_SCHED_APPT.APPT_LENGTH, F_SCHED_APPT.APPT_DTTM) AS TIME) AS APPT_TM_END ,
					F_SCHED_APPT.APPT_CANC_DTTM ,
					F_SCHED_APPT.APPT_MADE_DTTM-- ,

		  INTO #sched_appts

          FROM      CLARITY.dbo.F_SCHED_APPT AS F_SCHED_APPT
					--INNER JOIN
					--(
					--SELECT DISTINCT
					--	PAT_ENC_CSN_ID
					--FROM #booked_appts
					--) booked
					--ON F_SCHED_APPT.PAT_ENC_CSN_ID = booked.PAT_ENC_CSN_ID
					INNER JOIN
					(
					SELECT DISTINCT
						Provider_Id
					FROM @DevPeds
					) booked
					ON F_SCHED_APPT.PROV_ID = booked.Provider_Id
                    INNER JOIN CLARITY.dbo.PATIENT PATIENT						
					  ON F_SCHED_APPT.PAT_ID = PATIENT.PAT_ID
                    LEFT OUTER JOIN CLARITY.dbo.CLARITY_DEP CLARITY_DEP		
					  ON F_SCHED_APPT.DEPARTMENT_ID = CLARITY_DEP.DEPARTMENT_ID
                    LEFT OUTER JOIN CLARITY.dbo.CLARITY_SER	AS CLARITY_SER				
					  ON F_SCHED_APPT.PROV_ID = CLARITY_SER.PROV_ID
                    LEFT OUTER JOIN CLARITY.dbo.IDENTITY_ID	AS IDENTITY_ID			
					  ON IDENTITY_ID.PAT_ID = F_SCHED_APPT.PAT_ID AND IDENTITY_ID.IDENTITY_TYPE_ID = 14
 ----joins added to eliminate the V_SCHED_APPT view
                    LEFT OUTER JOIN CLARITY.dbo.CLARITY_PRC AS prc 
					  ON F_SCHED_APPT.PRC_ID = prc.PRC_ID
					LEFT OUTER JOIN CLARITY.dbo.ZC_APPT_STATUS AS zcappt
					  ON F_SCHED_APPT.APPT_STATUS_C = zcappt.APPT_STATUS_C
					LEFT OUTER JOIN CLARITY.dbo.ZC_CANCEL_REASON AS canc
					  ON F_SCHED_APPT.CANCEL_REASON_C = canc.CANCEL_REASON_C
		  WHERE CAST(F_SCHED_APPT.APPT_DTTM AS SMALLDATETIME) >= @StartDate
		  AND CAST(F_SCHED_APPT.APPT_DTTM AS SMALLDATETIME) <= @EndDate

	   --   SELECT *
		  --FROM #sched_appts
		  --ORDER BY DEPARTMENT_ID, PROV_ID, APPT_DTTM
		  
--SELECT booked.DEPARTMENT_ID,
--       booked.PROV_ID,
--       booked.APPT_SLOT_DATE,
--       booked.APPT_SLOT_BEGIN_TIME,
--       booked.APPT_SLOT_END_TIME,
--	   booked.SLOT_LENGTH,
--	   appts.APPT_DTTM,
--	   appts.PAT_ENC_CSN_ID,
--	   appts.PAT_ID AS appts_PAT_ID,
--	   appts.APPT_CANC_DTTM,
--	   appts.CANCEL_INITIATOR,
--	   appts.APPT_STATUS_FLAG,
--	   appts.APPT_LENGTH
--FROM #tmpl_avail_blocks_booked booked
--LEFT OUTER JOIN
--(
--SELECT *
--FROM #sched_appts
--WHERE #sched_appts.APPT_STATUS_FLAG IN ('Canceled','Canceled Late')
--) appts
--ON appts.DEPARTMENT_ID = booked.DEPARTMENT_ID
--AND appts.PROV_ID = booked.PROV_ID
--AND appts.APPT_DT = booked.APPT_SLOT_DATE
--AND appts.APPT_TM >= booked.APPT_SLOT_BEGIN_TIME
--AND appts.APPT_TM < booked.APPT_SLOT_END_TIME
--ORDER BY booked.DEPARTMENT_ID
--       , booked.PROV_ID
--       , booked.APPT_SLOT_DATE
--	   , booked.APPT_SLOT_BEGIN_TIME
--	   , appts.APPT_DTTM

SELECT noshow_attended_canceled.DEPARTMENT_ID,
       noshow_attended_canceled.DEPARTMENT_NAME,
       noshow_attended_canceled.PROV_ID,
	   noshow_attended_canceled.PROV_NM_WID,
       noshow_attended_canceled.APPT_SLOT_DATE,
       noshow_attended_canceled.APPT_SLOT_BEGIN_TIME,
       noshow_attended_canceled.APPT_SLOT_END_TIME,
	   noshow_attended_canceled.SLOT_BEGIN_TIME,
	   noshow_attended_canceled.Regular_Openings,
	   noshow_attended_canceled.Overbook_Openings,
	   noshow_attended_canceled.Openings_Booked,
	   noshow_attended_canceled.Regular_Openings_Available,
	   noshow_attended_canceled.Regular_Openings_Unavailable,
       noshow_attended_canceled.OPENINGS_PER_SLOT,
       noshow_attended_canceled.NUMBER_OB_ALLOWED,
       noshow_attended_canceled.SLOT_LENGTH,
       noshow_attended_canceled.BLOCK_USE,
       noshow_attended_canceled.Booked_Total,
       noshow_attended_canceled.Booked_Opns,
       noshow_attended_canceled.Booked_Ovbs,
       noshow_attended_canceled.APPT_NUMBER,
	   noshow_attended_canceled.APPT_DTTM,
       noshow_attended_canceled.APPT_LENGTH,
	   noshow_attended_canceled.APPT_MADE_DTTM,
       noshow_attended_canceled.PAT_ENC_CSN_ID,
       --noshow_attended_canceled.PAT_ID,
       --noshow_attended_canceled.PAT_ENC_CSN_ID,
       noshow_attended_canceled.PAT_NAME,
       noshow_attended_canceled.IDENTITY_ID AS MRN,
       noshow_attended_canceled.PRC_NAME AS VISIT_TYPE,
       noshow_attended_canceled.APPT_STATUS_FLAG,
	   noshow_attended_canceled.APPT_CANC_DTTM,
	   noshow_attended_canceled.CANCEL_INITIATOR

INTO #RptgTmp

FROM
(
SELECT avail.DEPARTMENT_ID,
       avail.DEPARTMENT_NAME,
       avail.PROV_ID,
	   avail.PROV_NM_WID,
       avail.APPT_SLOT_DATE,
       avail.APPT_SLOT_BEGIN_TIME,
       avail.APPT_SLOT_END_TIME,
	   avail.SLOT_BEGIN_TIME,
	   avail.Regular_Openings,
	   avail.Overbook_Openings,
	   avail.Openings_Booked,
	   avail.Regular_Openings_Available,
	   avail.Regular_Openings_Unavailable,
       avail.OPENINGS_PER_SLOT,
       avail.NUMBER_OB_ALLOWED,
	   avail.SLOT_LENGTH,
       avail.BLOCK_USE,
       avail.Booked_Total,
       avail.Booked_Opns,
       avail.Booked_Ovbs,
	   booked.APPT_NUMBER,
	   booked.PAT_ENC_CSN_ID,
	   booked.PAT_ID,
	   --appts.PAT_ENC_CSN_ID,
	   appts.PAT_NAME,
	   appts.IDENTITY_ID,
	   appts.PRC_NAME,
	   appts.APPT_STATUS_FLAG,
	   appts.APPT_LENGTH,
	   appts.APPT_DTTM,
	   appts.APPT_MADE_DTTM,
	   NULL AS APPT_CANC_DTTM,
	   NULL AS CANCEL_INITIATOR
FROM #tmpl_avail_blocks_booked avail
LEFT OUTER JOIN
(
SELECT DEPARTMENT_ID,
       PROV_ID,
       SLOT_DATE,
       SLOT_BEGIN_TIME,
       SLOT_END_TIME,
       APPT_NUMBER,
       APPT_OVERBOOK_YN,
       PAT_ENC_CSN_ID,
       PAT_ID
FROM #booked_appts
) booked
ON booked.DEPARTMENT_ID = avail.DEPARTMENT_ID
AND booked.PROV_ID = avail.PROV_ID
AND booked.SLOT_DATE = avail.APPT_SLOT_DATE
AND booked.SLOT_BEGIN_TIME = avail.APPT_SLOT_BEGIN_TIME
AND booked.SLOT_END_TIME = avail.APPT_SLOT_END_TIME
LEFT OUTER JOIN #sched_appts appts
ON appts.PAT_ENC_CSN_ID = booked.PAT_ENC_CSN_ID
UNION-- ALL
SELECT avail.DEPARTMENT_ID,
       avail.DEPARTMENT_NAME,
       avail.PROV_ID,
	   avail.PROV_NM_WID,
       avail.APPT_SLOT_DATE,
       avail.APPT_SLOT_BEGIN_TIME,
       avail.APPT_SLOT_END_TIME,
	   avail.SLOT_BEGIN_TIME,
	   avail.Regular_Openings,
	   avail.Overbook_Openings,
	   avail.Openings_Booked,
	   avail.Regular_Openings_Available,
	   avail.Regular_Openings_Unavailable,
       avail.OPENINGS_PER_SLOT,
       avail.NUMBER_OB_ALLOWED,
	   avail.SLOT_LENGTH,
       avail.BLOCK_USE,
       avail.Booked_Total,
       avail.Booked_Opns,
       avail.Booked_Ovbs,
	   --booked.APPT_NUMBER,
	   1 AS APPT_NUMBER,
	   appts.PAT_ENC_CSN_ID,
	   appts.PAT_ID,
	   appts.PAT_NAME,
	   appts.IDENTITY_ID,
	   appts.PRC_NAME,
	   appts.APPT_STATUS_FLAG,
	   appts.APPT_LENGTH,
	   appts.APPT_DTTM,
	   appts.APPT_MADE_DTTM,
	   appts.APPT_CANC_DTTM,
	   appts.CANCEL_INITIATOR
FROM #tmpl_avail_blocks_booked avail
LEFT OUTER JOIN
(
SELECT *
FROM #sched_appts
WHERE #sched_appts.APPT_STATUS_FLAG IN ('Canceled','Canceled Late')
) appts
ON appts.DEPARTMENT_ID = avail.DEPARTMENT_ID
AND appts.PROV_ID = avail.PROV_ID
AND appts.APPT_DT = avail.APPT_SLOT_DATE
AND appts.APPT_TM >= avail.APPT_SLOT_BEGIN_TIME
AND appts.APPT_TM < avail.APPT_SLOT_END_TIME
WHERE appts.APPT_STATUS_FLAG IS NOT NULL
) noshow_attended_canceled

--SELECT *
--FROM #RptgTmp
--ORDER BY DEPARTMENT_ID
--       , PROV_ID
--       , APPT_SLOT_DATE
--	   , APPT_SLOT_BEGIN_TIME

SELECT DEPARTMENT_ID,
       DEPARTMENT_NAME,
       PROV_ID,
	   PROV_NM_WID,
       APPT_SLOT_DATE,
       APPT_SLOT_BEGIN_TIME,
       APPT_SLOT_END_TIME,
	   SLOT_BEGIN_TIME,
	   Regular_Openings,
	   Overbook_Openings,
	   Openings_Booked,
	   Regular_Openings_Available,
	   Regular_Openings_Unavailable,
       OPENINGS_PER_SLOT,
       NUMBER_OB_ALLOWED,
       SLOT_LENGTH,
       BLOCK_USE,
       Booked_Total,
       Booked_Opns,
       Booked_Ovbs,
	   SUM(CASE WHEN APPT_STATUS_FLAG IN ('Completed','No Show','Left without seen','Scheduled') THEN 1 ELSE 0 END) AS Completed_NoShow,
	   SUM(CASE WHEN APPT_STATUS_FLAG IN ('Canceled','Canceled Late') THEN 1 ELSE 0 END) AS Canceled_CanceledLate

INTO #RptgTmpStats

FROM #RptgTmp

GROUP BY
	   DEPARTMENT_ID,
	   DEPARTMENT_NAME,
       PROV_ID,
	   PROV_NM_WID,
       APPT_SLOT_DATE,
       APPT_SLOT_BEGIN_TIME,
       APPT_SLOT_END_TIME,
	   SLOT_BEGIN_TIME,
	   Regular_Openings,
	   Overbook_Openings,
	   Openings_Booked,
	   Regular_Openings_Available,
	   Regular_Openings_Unavailable,
       OPENINGS_PER_SLOT,
       NUMBER_OB_ALLOWED,
       SLOT_LENGTH,
       BLOCK_USE,
       Booked_Total,
       Booked_Opns,
       Booked_Ovbs

SELECT tmp.DEPARTMENT_ID,
       tmp.DEPARTMENT_NAME,
       tmp.PROV_ID,
	   tmp.PROV_NM_WID,
       tmp.APPT_SLOT_DATE,
       tmp.APPT_SLOT_BEGIN_TIME,
       tmp.APPT_SLOT_END_TIME,
	   tmp.SLOT_BEGIN_TIME,
	   tmp.Regular_Openings,
	   tmp.Overbook_Openings,
	   tmp.Openings_Booked,
	   tmp.Regular_Openings_Available,
	   tmp.Regular_Openings_Unavailable,
       tmp.OPENINGS_PER_SLOT,
       tmp.NUMBER_OB_ALLOWED,
       tmp.SLOT_LENGTH,
       tmp.BLOCK_USE,
       tmp.Booked_Total,
       tmp.Booked_Opns,
       tmp.Booked_Ovbs,
       tmp.APPT_NUMBER,
       tmp.APPT_DTTM,
       tmp.APPT_LENGTH,
       tmp.APPT_MADE_DTTM,
       tmp.PAT_ENC_CSN_ID,
       tmp.PAT_NAME,
       tmp.MRN,
       tmp.VISIT_TYPE,
       tmp.APPT_STATUS_FLAG,
       tmp.APPT_CANC_DTTM,
	   tmp.CANCEL_INITIATOR,
       stats.Completed_NoShow,
       stats.Canceled_CanceledLate
INTO #RptgTmp2
FROM #RptgTmp tmp
LEFT OUTER JOIN #RptgTmpStats stats
ON stats.DEPARTMENT_ID = tmp.DEPARTMENT_ID
AND stats.DEPARTMENT_NAME = tmp.DEPARTMENT_NAME
AND stats.PROV_ID = tmp.PROV_ID
AND stats.PROV_NM_WID = tmp.PROV_NM_WID
AND stats.APPT_SLOT_DATE = tmp.APPT_SLOT_DATE
AND stats.APPT_SLOT_BEGIN_TIME = tmp.APPT_SLOT_BEGIN_TIME
AND stats.APPT_SLOT_END_TIME = tmp.APPT_SLOT_END_TIME
AND stats.SLOT_BEGIN_TIME = tmp.SLOT_BEGIN_TIME
AND stats.Regular_Openings = tmp.Regular_Openings
AND stats.Overbook_Openings = tmp.Overbook_Openings
AND stats.Openings_Booked = tmp.Openings_Booked
AND stats.Regular_Openings_Available = tmp.Regular_Openings_Available
AND stats.Regular_Openings_Unavailable = tmp.Regular_Openings_Unavailable
AND stats.OPENINGS_PER_SLOT = tmp.OPENINGS_PER_SLOT
AND stats.NUMBER_OB_ALLOWED = tmp.NUMBER_OB_ALLOWED
AND stats.SLOT_LENGTH = tmp.SLOT_LENGTH
AND stats.BLOCK_USE = tmp.BLOCK_USE
AND stats.Booked_Opns = tmp.Booked_Opns
AND stats.Booked_Ovbs = tmp.Booked_Ovbs
AND stats.Booked_Total = tmp.Booked_Total

--SELECT DEPARTMENT_ID,
--	   DEPARTMENT_NAME,
--       PROV_ID,
--	   PROV_NM_WID
--       APPT_SLOT_DATE,
--       APPT_SLOT_BEGIN_TIME,
--       APPT_SLOT_END_TIME,
--	   SLOT_BEGIN_TIME,
--	   Regular_Openings,
--	   Overbook_Openings,
--	   Openings_Booked,
--	   Regular_Openings_Available,
--	   Regular_Openings_Unavailable,
--       OPENINGS_PER_SLOT,
--       NUMBER_OB_ALLOWED,
--       SLOT_LENGTH,
--       BLOCK_USE,
--       Booked_Total,
--       Booked_Opns,
--       Booked_Ovbs,
--       APPT_NUMBER,
--       APPT_DTTM,
--       APPT_LENGTH,
--       APPT_MADE_DTTM,
--       PAT_ENC_CSN_ID,
--       PAT_NAME,
--       MRN,
--       VISIT_TYPE,
--       APPT_STATUS_FLAG,
--       APPT_CANC_DTTM,
--       CANCEL_INITIATOR,
--       Completed_NoShow,
--       Canceled_CanceledLate
--FROM #RptgTmp2
--ORDER BY DEPARTMENT_ID
--       , PROV_ID
--       , APPT_SLOT_DATE
--	   , APPT_SLOT_BEGIN_TIME

SELECT DEPARTMENT_ID,
       DEPARTMENT_NAME,
       PROV_ID,
	   PROV_NM_WID,
       APPT_SLOT_DATE,
       APPT_SLOT_BEGIN_TIME,
       APPT_SLOT_END_TIME,
	   --SLOT_BEGIN_TIME,
       SLOT_LENGTH,
	   Regular_Openings,
	   Regular_Openings_Available,
	   Regular_Openings_Unavailable,
	   Overbook_Openings,
	   Openings_Booked,
    --   OPENINGS_PER_SLOT,
    --   NUMBER_OB_ALLOWED,
       BLOCK_USE,
       --Booked_Total,
       --Booked_Opns,
       --Booked_Ovbs,
       APPT_NUMBER,
       APPT_DTTM,
       APPT_LENGTH,
       APPT_MADE_DTTM,
       PAT_ENC_CSN_ID,
       PAT_NAME,
       MRN,
       VISIT_TYPE,
       APPT_STATUS_FLAG,
       APPT_CANC_DTTM,
       CANCEL_INITIATOR--,
       --Completed_NoShow,
       --Canceled_CanceledLate	
FROM #RptgTmp2
WHERE NOT (APPT_NUMBER IS NULL AND Completed_NoShow = 0 AND Canceled_CanceledLate > 0)
ORDER BY DEPARTMENT_ID
       , PROV_ID
       , APPT_SLOT_DATE
	   , APPT_SLOT_BEGIN_TIME

GO