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
SET @StartDate = '7/1/2020 00:00:00'
--SET @EndDate = '11/28/2018 00:00:00'

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

IF OBJECT_ID('tempdb..#schdtmpl ') IS NOT NULL
DROP TABLE #schdtmpl

IF OBJECT_ID('tempdb..#avail ') IS NOT NULL
DROP TABLE #avail

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

IF OBJECT_ID('tempdb..#booked_appts ') IS NOT NULL
DROP TABLE #booked_appts

IF OBJECT_ID('tempdb..#tmpl_booked_appts ') IS NOT NULL
DROP TABLE #tmpl_booked_appts

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
ORDER BY display_template.DEPARTMENT_ID
       , display_template.PROV_ID
	   , CAST(ddte.day_date AS DATE)
	   , CAST(display_template.BEGIN_DATE_TM_RANGE AS TIME)
	   , CAST(display_template.END_DATE_TIME_RANGE AS TIME)

  -- Create index for temp table #schdtmpl
  CREATE UNIQUE CLUSTERED INDEX IX_schdtmpl ON #schdtmpl (DEPARTMENT_ID, PROV_ID, TEMPLATE_SLOT_DATE, TEMPLATE_SLOT_BEGIN_TIME, TEMPLATE_SLOT_END_TIME)

--SELECT *
--FROM #schdtmpl
----ORDER BY DEPARTMENT_ID
----       , PROV_ID
----	   , BEGIN_DATE_TM_RANGE
----	   , BEGIN_TIME_TM_RANGE
--ORDER BY DEPARTMENT_ID
--       , PROV_ID
--	   , ddte_DOW
--       , TEMPLATE_SLOT_DATE
--       , TEMPLATE_SLOT_BEGIN_TIME
--       , TEMPLATE_SLOT_END_TIME
/*
SELECT avail.DEPARTMENT_ID
     , avail.DEPARTMENT_NAME
	 , avail.PROV_ID
	 , avail.PROV_NM_WID
	 , avail.SLOT_DATE AS APPT_SLOT_DATE
	 , ddte.day_of_week AS SLOT_DOW
	 , CAST(avail.SLOT_BEGIN_TIME AS TIME) AS APPT_SLOT_BEGIN_TIME
	 , CAST(avail.SLOT_END_TIME AS TIME) AS APPT_SLOT_END_TIME
	 --, avail.SLOT_BEGIN_TIME
	 --, avail.SLOT_END_TIME
	 , avail.ORG_REG_OPENINGS AS Opn
	 , avail.ORG_OVBK_OPENINGS AS Ovb
	 , avail.SLOT_LENGTH
	 , avail.APPT_NUMBER
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
INNER JOIN CLARITY_App.Rptg.vwDim_Date ddte
ON avail.SLOT_DATE = ddte.day_date
WHERE
avail.DEPARTMENT_ID = 10243003
--avail.DEPARTMENT_ID = 10210002
--avail.DEPARTMENT_ID IN (10210002,10210030,10243003,10243087,10244023)
--AND avail.PROV_ID = '29545'
AND avail.PROV_ID = '84374' -- TUCKER, SHANNON
--AND avail.PROV_ID = '1300382'
--AND CAST(SLOT_DATE AS DATE) = '1/28/2019'
--AND CAST(avail.SLOT_DATE AS DATE) = '10/4/2017'
--AND CAST(SLOT_DATE AS DATE) >= CAST(@StartDate AS DATE)
AND CAST(avail.SLOT_DATE AS DATE) >= '7/1/2017' /*****/
--AND CAST(SLOT_DATE AS DATE) >= '1/28/2019'
ORDER BY avail.DEPARTMENT_ID
       , avail.PROV_ID
	   , avail.SLOT_DATE
	   , CAST(avail.SLOT_BEGIN_TIME AS TIME)
	   , CAST(avail.SLOT_END_TIME AS TIME)
	   , avail.APPT_NUMBER

  -- Create index for temp table #avail
  CREATE UNIQUE CLUSTERED INDEX IX_avail ON #avail (DEPARTMENT_ID, PROV_ID, APPT_SLOT_DATE, APPT_SLOT_BEGIN_TIME, APPT_SLOT_END_TIME, APPT_NUMBER)

--SELECT *
--FROM #avail
--WHERE APPT_NUMBER > 0
--ORDER BY DEPARTMENT_ID
--       , PROV_ID
--	   , APPT_SLOT_DATE
--	   , APPT_SLOT_BEGIN_TIME
*/
SELECT blk.DEPARTMENT_ID
	 , blk.PROV_ID
	 , CAST(blk.SLOT_BEGIN_TIME AS DATE) AS SLOT_DATE
	 , CAST(blk.SLOT_BEGIN_TIME AS TIME) AS SLOT_BEGIN_TIME
	 --, COALESCE(avail.APPT_BLOCK_NAME,'Unblocked') AS APPT_BLOCK_NAME
	 , blk.LINE
	 --, blk.BLOCK_C
	 , zab.NAME AS BLOCK_NAME
	 , COALESCE(blk.ORG_AVAIL_BLOCKS,0) AS ORG_AVAIL_BLOCKS
	 , blk.BLOCKS_USED
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
CAST(blk.SLOT_BEGIN_TIME AS DATE) >= '7/1/2017' /*****/
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
AND blk.BLOCK_C IS NOT NULL
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
/*
SELECT avail.DEPARTMENT_ID
     , avail.PROV_ID
	 , avail.APPT_SLOT_DATE
	 , avail.APPT_SLOT_BEGIN_TIME
	 --, COALESCE(avail.APPT_BLOCK_NAME,'Unblocked') AS APPT_BLOCK_NAME
	 --, COUNT(*) AS APPT_COUNT
	 , avail.APPT_BLOCK_NAME + '(' + CAST(COUNT(*) AS VARCHAR(2)) + ')' AS APPT_BLOCK_NAME_COUNT
INTO #avail_aggr
--FROM dbo.V_AVAILABILITY avail
FROM #avail avail
WHERE avail.APPT_NUMBER > 0
GROUP BY avail.DEPARTMENT_ID
       , avail.PROV_ID
       , avail.APPT_SLOT_DATE
	   , avail.APPT_SLOT_BEGIN_TIME
	   , avail.APPT_BLOCK_NAME

--SELECT *
--FROM #avail_aggr avail_aggr
--ORDER BY avail_aggr.DEPARTMENT_ID
--       , avail_aggr.PROV_ID
--	   , avail_aggr.SLOT_DATE
--	   , avail_aggr.SLOT_BEGIN_TIME
--	   , avail_aggr.APPT_BLOCK_NAME_COUNT

--SELECT DISTINCT
--       avail_aggr.SLOT_DATE
--	 , avail_aggr.SLOT_BEGIN_TIME
--	 , avail_aggr.APPT_BLOCK_NAME_COUNT AS APPT_BLOCK_NAME
--     , (SELECT avail_aggrt.APPT_BLOCK_NAME_COUNT + ',' AS [text()]
--		FROM #avail_aggr avail_aggrt
--		WHERE avail_aggrt.SLOT_DATE = avail_aggr.SLOT_DATE
--		AND CAST(avail_aggrt.SLOT_BEGIN_TIME AS TIME) = CAST(avail_aggr.SLOT_BEGIN_TIME AS TIME)
--	    FOR XML PATH ('')) AS APPT_BLOCK_NAME_STRING
--FROM #avail_aggr avail_aggr
--ORDER BY avail_aggr.SLOT_DATE
--	   , avail_aggr.SLOT_BEGIN_TIME
--	   , avail_aggr.APPT_BLOCK_NAME_COUNT

SELECT DISTINCT
       avail_aggr.DEPARTMENT_ID
	 , avail_aggr.PROV_ID
     , avail_aggr.APPT_SLOT_DATE
	 , avail_aggr.APPT_SLOT_BEGIN_TIME
	 --, avail_aggr.APPT_BLOCK_NAME_COUNT AS APPT_BLOCK_NAME
     , (SELECT avail_aggrt.APPT_BLOCK_NAME_COUNT + ',' AS [text()]
		FROM #avail_aggr avail_aggrt
		WHERE avail_aggrt.DEPARTMENT_ID = avail_aggr.DEPARTMENT_ID
		AND avail_aggrt.PROV_ID = avail_aggr.PROV_ID
		AND avail_aggrt.APPT_SLOT_DATE = avail_aggr.APPT_SLOT_DATE
		--AND CAST(avail_aggrt.SLOT_BEGIN_TIME AS TIME) = CAST(avail_aggr.SLOT_BEGIN_TIME AS TIME)
		AND avail_aggrt.APPT_SLOT_BEGIN_TIME = avail_aggr.APPT_SLOT_BEGIN_TIME
	    FOR XML PATH ('')) AS APPT_BLOCK_NAME_STRING
INTO #booked_blocks
FROM #avail_aggr avail_aggr
ORDER BY avail_aggr.DEPARTMENT_ID
	   , avail_aggr.PROV_ID
	   , avail_aggr.APPT_SLOT_DATE
	   , avail_aggr.APPT_SLOT_BEGIN_TIME

SELECT *
FROM #booked_blocks
ORDER BY DEPARTMENT_ID
       , PROV_ID
	   , APPT_SLOT_DATE
	   , APPT_SLOT_BEGIN_TIME
*/
/*
SELECT DISTINCT
       avail_block.DEPARTMENT_ID
	 , avail_block.PROV_ID
     , avail_block.SLOT_DATE
	 , avail_block.SLOT_BEGIN_TIME
	 --, avail_block.BLOCK_NAME
	 --, avail_block.BLOCKS_USED
     , (SELECT avail_blockt.BLOCK_NAME_COUNT + ',' AS [text()]
		FROM #avail_block avail_blockt
		WHERE avail_blockt.DEPARTMENT_ID = avail_block.DEPARTMENT_ID
		AND avail_blockt.PROV_ID = avail_block.PROV_ID
		AND avail_blockt.SLOT_DATE = avail_block.SLOT_DATE
		AND avail_blockt.SLOT_BEGIN_TIME = avail_block.SLOT_BEGIN_TIME
	    FOR XML PATH ('')) AS BLOCK_NAME_STRING
INTO #used_blocks
FROM #avail_block avail_block
ORDER BY avail_block.DEPARTMENT_ID
	   , avail_block.PROV_ID
	   , avail_block.SLOT_DATE
	   , avail_block.SLOT_BEGIN_TIME

SELECT *
FROM #used_blocks
ORDER BY DEPARTMENT_ID
       , PROV_ID
	   , SLOT_DATE
	   , SLOT_BEGIN_TIME
*/
/*
SELECT booked_blk.DEPARTMENT_ID
     , booked_blk.PROV_ID
	 , booked_blk.TEMPLATE_SLOT_DATE
	 , booked_blk.TEMPLATE_SLOT_BEGIN_TIME
	 , booked_blk.TEMPLATE_SLOT_END_TIME
	 , booked_blk.APPT_BLOCK_NAME + '(' + CAST(COUNT(*) AS VARCHAR(2)) + ')' AS APPT_BLOCK_NAME_COUNT
INTO #tmpl_booked_blocks
FROM
(
SELECT tmpl.DEPARTMENT_ID
	 , tmpl.PROV_ID
	 , tmpl.TEMPLATE_SLOT_DATE
	 , tmpl.TEMPLATE_SLOT_BEGIN_TIME
	 , tmpl.TEMPLATE_SLOT_END_TIME
	 , blk.APPT_BLOCK_NAME
FROM #schdtmpl tmpl
LEFT OUTER JOIN
(
SELECT DEPARTMENT_ID
     , PROV_ID
	 , APPT_SLOT_DATE
	 , APPT_SLOT_BEGIN_TIME
	 , APPT_SLOT_END_TIME
	 , APPT_BLOCK_NAME
FROM #avail
WHERE APPT_NUMBER > 0) blk
ON blk.DEPARTMENT_ID = tmpl.DEPARTMENT_ID
AND blk.PROV_ID = tmpl.PROV_ID
AND blk.APPT_SLOT_DATE = tmpl.TEMPLATE_SLOT_DATE
AND blk.APPT_SLOT_BEGIN_TIME >= tmpl.TEMPLATE_SLOT_BEGIN_TIME
AND blk.APPT_SLOT_END_TIME <= tmpl.TEMPLATE_SLOT_END_TIME
) booked_blk
GROUP BY booked_blk.DEPARTMENT_ID
       , booked_blk.PROV_ID
	   , booked_blk.TEMPLATE_SLOT_DATE
	   , booked_blk.TEMPLATE_SLOT_BEGIN_TIME
	   , booked_blk.TEMPLATE_SLOT_END_TIME
	   , booked_blk.APPT_BLOCK_NAME
ORDER BY booked_blk.DEPARTMENT_ID
       , booked_blk.PROV_ID
	   , booked_blk.TEMPLATE_SLOT_DATE
	   , booked_blk.TEMPLATE_SLOT_BEGIN_TIME
	   , booked_blk.TEMPLATE_SLOT_END_TIME
	   , booked_blk.APPT_BLOCK_NAME

  -- Create index for temp table #tmpl_booked_blocks
  CREATE UNIQUE CLUSTERED INDEX IX_tmpl_booked_blocks ON #tmpl_booked_blocks (DEPARTMENT_ID, PROV_ID, TEMPLATE_SLOT_DATE, TEMPLATE_SLOT_BEGIN_TIME, TEMPLATE_SLOT_END_TIME, APPT_BLOCK_NAME_COUNT)

SELECT *
FROM #tmpl_booked_blocks
ORDER BY DEPARTMENT_ID
       , PROV_ID
	   , TEMPLATE_SLOT_DATE
	   , TEMPLATE_SLOT_BEGIN_TIME
*/
/*
SELECT used_blk.DEPARTMENT_ID
     , used_blk.PROV_ID
	 , used_blk.TEMPLATE_SLOT_DATE
	 , used_blk.TEMPLATE_SLOT_BEGIN_TIME
	 , used_blk.TEMPLATE_SLOT_END_TIME
	 , used_blk.APPT_BLOCK_NAME_STRING AS APPT_BLOCK_NAME_COUNT
INTO #tmpl_used_blocks
FROM
(
SELECT tmpl.DEPARTMENT_ID
	 , tmpl.PROV_ID
	 , tmpl.TEMPLATE_SLOT_DATE
	 , tmpl.TEMPLATE_SLOT_BEGIN_TIME
	 , tmpl.TEMPLATE_SLOT_END_TIME
	 , blk.APPT_BLOCK_NAME_STRING
FROM #schdtmpl tmpl
LEFT OUTER JOIN
(
SELECT avail.DEPARTMENT_ID
     , avail.PROV_ID
	 , avail.APPT_SLOT_DATE
	 , avail.APPT_SLOT_BEGIN_TIME
	 , avail.APPT_SLOT_END_TIME
	 , avail_block.APPT_BLOCK_NAME_STRING
FROM #avail avail
LEFT OUTER JOIN #used_blocks avail_block
ON avail_block.DEPARTMENT_ID = avail.DEPARTMENT_ID
AND avail_block.PROV_ID = avail.PROV_ID
AND avail.APPT_SLOT_DATE = avail_block.SLOT_DATE
AND avail.APPT_SLOT_BEGIN_TIME = avail_block.SLOT_BEGIN_TIME
WHERE avail.APPT_NUMBER > 0) blk
ON blk.DEPARTMENT_ID = tmpl.DEPARTMENT_ID
AND blk.PROV_ID = tmpl.PROV_ID
AND blk.APPT_SLOT_DATE = tmpl.TEMPLATE_SLOT_DATE
AND blk.APPT_SLOT_BEGIN_TIME >= tmpl.TEMPLATE_SLOT_BEGIN_TIME
AND blk.APPT_SLOT_END_TIME <= tmpl.TEMPLATE_SLOT_END_TIME
) used_blk
ORDER BY used_blk.DEPARTMENT_ID
       , used_blk.PROV_ID
	   , used_blk.TEMPLATE_SLOT_DATE
	   , used_blk.TEMPLATE_SLOT_BEGIN_TIME
	   , used_blk.TEMPLATE_SLOT_END_TIME
	   , used_blk.APPT_BLOCK_NAME_STRING

  -- Create index for temp table #tmpl_used_blocks
  CREATE UNIQUE CLUSTERED INDEX IX_tmpl_used_blocks ON #tmpl_used_blocks (DEPARTMENT_ID, PROV_ID, TEMPLATE_SLOT_DATE, TEMPLATE_SLOT_BEGIN_TIME, TEMPLATE_SLOT_END_TIME, APPT_BLOCK_NAME_COUNT)

SELECT *
FROM #tmpl_used_blocks
ORDER BY DEPARTMENT_ID
       , PROV_ID
	   , TEMPLATE_SLOT_DATE
	   , TEMPLATE_SLOT_BEGIN_TIME
*/
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
/*
SELECT avail.DEPARTMENT_ID
     , avail.PROV_ID
	 , avail.APPT_SLOT_DATE
	 , avail.APPT_SLOT_BEGIN_TIME
	 , COUNT(*) AS Booked
	 , SUM(CASE WHEN avail.APPT_OVERBOOK_YN = 'Y' THEN 1 ELSE 0 END) AS Booked_Ovbs
	 , SUM(CASE WHEN avail.APPT_OVERBOOK_YN = 'N' THEN 1 ELSE 0 END) AS Booked_Opns
	 --, SUM(avail.ORG_AVAIL_BLOCKS) AS ORG_AVAIL_BLOCKS
	 --, SUM(avail.BLOCKS_USED) AS BLOCKS_USED
INTO #booked_appts
--FROM dbo.V_AVAILABILITY avail
FROM #avail avail
WHERE avail.APPT_NUMBER > 0
GROUP BY avail.DEPARTMENT_ID
       , avail.PROV_ID
       , avail.APPT_SLOT_DATE
       , avail.APPT_SLOT_BEGIN_TIME
ORDER BY avail.DEPARTMENT_ID
       , avail.PROV_ID
       , avail.APPT_SLOT_DATE
       , avail.APPT_SLOT_BEGIN_TIME

SELECT booked_appt.DEPARTMENT_ID
     , booked_appt.PROV_ID
	 , booked_appt.TEMPLATE_SLOT_DATE
	 , booked_appt.TEMPLATE_SLOT_BEGIN_TIME
	 , booked_appt.TEMPLATE_SLOT_END_TIME
	 --, COUNT(*) AS Booked
	 , SUM(CASE WHEN booked_appt.APPT_NUMBER IS NOT NULL THEN 1 ELSE 0 END) AS Booked
	 , SUM(CASE WHEN booked_appt.APPT_OVERBOOK_YN = 'Y' THEN 1 ELSE 0 END) AS Booked_Ovbs
	 , SUM(CASE WHEN booked_appt.APPT_OVERBOOK_YN = 'N' THEN 1 ELSE 0 END) AS Booked_Opns
	 --, SUM(booked_appt.ORG_AVAIL_BLOCKS) AS ORG_AVAIL_BLOCKS
	 --, SUM(booked_appt.BLOCKS_USED) AS BLOCKS_USED
INTO #tmpl_booked_appts
FROM
(
SELECT tmpl.DEPARTMENT_ID
	 , tmpl.PROV_ID
	 , tmpl.TEMPLATE_SLOT_DATE
	 , tmpl.TEMPLATE_SLOT_BEGIN_TIME
	 , tmpl.TEMPLATE_SLOT_END_TIME
	 , appt.APPT_OVERBOOK_YN
	 , appt.APPT_NUMBER
	 --, appt.ORG_AVAIL_BLOCKS
	 --, appt.BLOCKS_USED
FROM #schdtmpl tmpl
LEFT OUTER JOIN
(
SELECT DEPARTMENT_ID
     , PROV_ID
	 , APPT_SLOT_DATE
	 , APPT_SLOT_BEGIN_TIME
	 , APPT_SLOT_END_TIME
	 , APPT_OVERBOOK_YN
	 , APPT_NUMBER
	 --, ORG_AVAIL_BLOCKS
	 --, BLOCKS_USED
FROM #avail
WHERE APPT_NUMBER > 0) appt
ON appt.DEPARTMENT_ID = tmpl.DEPARTMENT_ID
AND appt.PROV_ID = tmpl.PROV_ID
AND appt.APPT_SLOT_DATE = tmpl.TEMPLATE_SLOT_DATE
AND appt.APPT_SLOT_BEGIN_TIME >= tmpl.TEMPLATE_SLOT_BEGIN_TIME
AND appt.APPT_SLOT_END_TIME <= tmpl.TEMPLATE_SLOT_END_TIME
) booked_appt
GROUP BY booked_appt.DEPARTMENT_ID
       , booked_appt.PROV_ID
	   , booked_appt.TEMPLATE_SLOT_DATE
	   , booked_appt.TEMPLATE_SLOT_BEGIN_TIME
	   , booked_appt.TEMPLATE_SLOT_END_TIME
ORDER BY booked_appt.DEPARTMENT_ID
       , booked_appt.PROV_ID
	   , booked_appt.TEMPLATE_SLOT_DATE
	   , booked_appt.TEMPLATE_SLOT_BEGIN_TIME
	   , booked_appt.TEMPLATE_SLOT_END_TIME

  -- Create index for temp table #tmpl_booked_appts
  CREATE UNIQUE CLUSTERED INDEX IX_tmpl_booked_appts ON #tmpl_booked_appts (DEPARTMENT_ID, PROV_ID, TEMPLATE_SLOT_DATE, TEMPLATE_SLOT_BEGIN_TIME, TEMPLATE_SLOT_END_TIME)

--SELECT *
--FROM #tmpl_booked_appts
--ORDER BY DEPARTMENT_ID
--       , PROV_ID
--	   , BEGIN_DATE_TM_RANGE
--	   , BEGIN_TIME_TM_RANGE

--SELECT avail.DEPARTMENT_ID
--     , avail.DEPARTMENT_NAME
--	 , avail.PROV_ID
--	 , avail.PROV_NM_WID
--	 , avail.SLOT_DATE
--	 , avail.SLOT_DOW
--	 , avail.SLOT_BEGIN_TIME
--	 , avail.SLOT_END_TIME
--	 , avail.Opn
--	 , avail.Ovb
--	 , avail.SLOT_LENGTH
--	 , COALESCE(booked_appts.Booked,0) AS Booked
--	 , COALESCE(booked_appts.Booked_Opns,0) AS Booked_Opns
--	 , COALESCE(booked_appts.Booked_Ovbs,0) AS Booked_Ovbs
--	 , COALESCE(LEFT(booked_blocks.APPT_BLOCK_NAME_STRING,LEN(booked_blocks.APPT_BLOCK_NAME_STRING)-1),'') AS Booked_Blks
----FROM dbo.V_AVAILABILITY avail
--FROM #avail avail
--LEFT OUTER JOIN #booked_appts booked_appts
--ON booked_appts.DEPARTMENT_ID = avail.DEPARTMENT_ID
--AND booked_appts.PROV_ID = avail.PROV_ID
--AND booked_appts.SLOT_DATE = avail.SLOT_DATE
--AND booked_appts.SLOT_BEGIN_TIME = avail.SLOT_BEGIN_TIME
--LEFT OUTER JOIN #booked_blocks booked_blocks
--ON booked_blocks.DEPARTMENT_ID = booked_appts.DEPARTMENT_ID
--AND booked_blocks.PROV_ID = booked_appts.PROV_ID
--AND booked_blocks.SLOT_DATE = avail.SLOT_DATE
--AND booked_blocks.SLOT_BEGIN_TIME = avail.SLOT_BEGIN_TIME
--WHERE avail.APPT_NUMBER = 0
--  --ORDER BY SLOT_BEGIN_TIME
--  --       , APPT_NUMBER
--  --ORDER BY avail.SLOT_DATE
--  --       , SLOT_BEGIN_TIME
--  --       , APPT_NUMBER
--  ORDER BY avail.DEPARTMENT_ID
--         , avail.PROV_ID
--         , avail.SLOT_DATE
--         , avail.SLOT_BEGIN_TIME
--         , avail.APPT_NUMBER

--SELECT *
--FROM #schdtmpl
--  ORDER BY DEPARTMENT_ID
--         , PROV_ID
--         , TEMPLATE_SLOT_DATE
--		 , TEMPLATE_SLOT_BEGIN_TIME
--         , TEMPLATE_SLOT_END_TIME

--SELECT *
--FROM #tmpl_booked_blocks
--  ORDER BY DEPARTMENT_ID
--         , PROV_ID
--         , TEMPLATE_SLOT_DATE
--		 , TEMPLATE_SLOT_BEGIN_TIME
--         , TEMPLATE_SLOT_END_TIME

--SELECT *
--FROM #tmpl_booked_appts
--  ORDER BY DEPARTMENT_ID
--         , PROV_ID
--         , TEMPLATE_SLOT_DATE
--		 , TEMPLATE_SLOT_BEGIN_TIME
--         , TEMPLATE_SLOT_END_TIME

--SELECT DISTINCT
--       blk.DEPARTMENT_ID
--	 , blk.PROV_ID
--	 , blk.BEGIN_DATE_TM_RANGE
--	 , blk.BEGIN_TIME_TM_RANGE
--	 , blk.END_TIME_TM_RANGE
--     , (SELECT blkt.APPT_BLOCK_NAME_COUNT + ',' AS [text()]
--		FROM #tmpl_booked_blocks blkt
--		WHERE blkt.DEPARTMENT_ID = blk.DEPARTMENT_ID
--		AND blkt.PROV_ID = blk.PROV_ID
--		AND blkt.BEGIN_DATE_TM_RANGE = blk.BEGIN_DATE_TM_RANGE
--		AND blkt.BEGIN_TIME_TM_RANGE = blk.BEGIN_TIME_TM_RANGE
--	    FOR XML PATH ('')) AS APPT_BLOCK_NAME_STRING
--FROM #tmpl_booked_blocks blk
*/
/*
SELECT tmpl.DEPARTMENT_ID
     , tmpl.DEPARTMENT_NAME
	 , tmpl.PROV_ID
	 , tmpl.PROV_NAME
	 , tmpl.DOW AS SLOT_DOW
	 , tmpl.TEMPLATE_SLOT_DATE AS SLOT_DATE
	 , tmpl.TEMPLATE_SLOT_BEGIN_TIME AS SLOT_BEGIN_TIME
	 , tmpl.TEMPLATE_SLOT_END_TIME AS SLOT_END_TIME
	 , tmpl.OPENINGS_PER_SLOT
	 , tmpl.NUMBER_OB_ALLOWED
	 , tmpl.SLOT_LENGTH
	 --, COALESCE(tmpl_booked_appts.ORG_AVAIL_BLOCKS,0) AS ORG_AVAIL_BLOCKS
	 --, COALESCE(tmpl_booked_appts.BLOCKS_USED,0) AS BLOCKS_USED
	 , COALESCE(tmpl_booked_appts.Booked,0) AS Booked
	 , COALESCE(tmpl_booked_appts.Booked_Opns,0) AS Booked_Opns
	 , COALESCE(tmpl_booked_appts.Booked_Ovbs,0) AS Booked_Ovbs
	 --, COALESCE(LEFT(tmpl_booked_blocks.APPT_BLOCK_NAME_STRING,LEN(tmpl_booked_blocks.APPT_BLOCK_NAME_STRING)-1),'') AS Booked_Blks
	 , CASE WHEN LEN(tmpl_booked_blocks.APPT_BLOCK_NAME_STRING) > 0 THEN COALESCE(LEFT(tmpl_booked_blocks.APPT_BLOCK_NAME_STRING,LEN(tmpl_booked_blocks.APPT_BLOCK_NAME_STRING)-1),'')
	        ELSE ''
	   END AS Booked_Blks
	 --, tmpl_booked_blocks.APPT_BLOCK_NAME_STRING
	 --, LEN(tmpl_booked_blocks.APPT_BLOCK_NAME_STRING) AS LEN_APPT_BLOCK_NAME_STRING
FROM #schdtmpl tmpl
LEFT OUTER JOIN
(
SELECT DISTINCT
       blk.DEPARTMENT_ID
	 , blk.PROV_ID
	 , blk.TEMPLATE_SLOT_DATE
	 , blk.TEMPLATE_SLOT_BEGIN_TIME
	 , blk.TEMPLATE_SLOT_END_TIME
     , (SELECT blkt.APPT_BLOCK_NAME_COUNT + ',' AS [text()]
		FROM #tmpl_booked_blocks blkt
		WHERE blkt.DEPARTMENT_ID = blk.DEPARTMENT_ID
		AND blkt.PROV_ID = blk.PROV_ID
		AND blkt.TEMPLATE_SLOT_DATE = blk.TEMPLATE_SLOT_DATE
		AND blkt.TEMPLATE_SLOT_BEGIN_TIME = blk.TEMPLATE_SLOT_BEGIN_TIME
	    FOR XML PATH ('')) AS APPT_BLOCK_NAME_STRING
FROM #tmpl_booked_blocks blk) tmpl_booked_blocks
ON tmpl_booked_blocks.DEPARTMENT_ID = tmpl.DEPARTMENT_ID
AND tmpl_booked_blocks.PROV_ID = tmpl.PROV_ID
AND tmpl_booked_blocks.TEMPLATE_SLOT_DATE = tmpl.TEMPLATE_SLOT_DATE
AND tmpl_booked_blocks.TEMPLATE_SLOT_BEGIN_TIME = tmpl.TEMPLATE_SLOT_BEGIN_TIME
AND tmpl_booked_blocks.TEMPLATE_SLOT_END_TIME = tmpl.TEMPLATE_SLOT_END_TIME
LEFT OUTER JOIN
(
SELECT
       appt.DEPARTMENT_ID
	 , appt.PROV_ID
	 , appt.TEMPLATE_SLOT_DATE
	 , appt.TEMPLATE_SLOT_BEGIN_TIME
	 , appt.TEMPLATE_SLOT_END_TIME
	 , appt.Booked
	 , appt.Booked_Opns
	 , appt.Booked_Ovbs
	 --, appt.ORG_AVAIL_BLOCKS
	 --, appt.BLOCKS_USED
FROM #tmpl_booked_appts appt) tmpl_booked_appts
ON tmpl_booked_appts.DEPARTMENT_ID = tmpl.DEPARTMENT_ID
AND tmpl_booked_appts.PROV_ID = tmpl.PROV_ID
AND tmpl_booked_appts.TEMPLATE_SLOT_DATE = tmpl.TEMPLATE_SLOT_DATE
AND tmpl_booked_appts.TEMPLATE_SLOT_BEGIN_TIME = tmpl.TEMPLATE_SLOT_BEGIN_TIME
AND tmpl_booked_appts.TEMPLATE_SLOT_END_TIME = tmpl.TEMPLATE_SLOT_END_TIME
  --ORDER BY SLOT_BEGIN_TIME
  --       , APPT_NUMBER
  --ORDER BY  avail.SLOT_DATE
  --       , SLOT_BEGIN_TIME
  --       , APPT_NUMBER
  --ORDER BY tmpl.DEPARTMENT_ID
  --       , tmpl.PROV_ID
		-- , tmpl.TEMPLATE_SLOT_DATE
  --       , tmpl.TEMPLATE_SLOT_BEGIN_TIME
		-- , tmpl.TEMPLATE_SLOT_END_TIME
  ORDER BY tmpl.DEPARTMENT_ID
         , tmpl.PROV_ID
         --, tmpl.DAY_OF_THE_WEEK_C
		 , tmpl.ddte_DOW
		 , tmpl.TEMPLATE_SLOT_DATE
         , tmpl.TEMPLATE_SLOT_BEGIN_TIME
		 , tmpl.TEMPLATE_SLOT_END_TIME
  --ORDER BY tmpl.DAY_OF_THE_WEEK_C
  --       , tmpl.DEPARTMENT_ID
  --       , tmpl.PROV_ID
		-- , tmpl.TEMPLATE_SLOT_DATE
  --       , tmpl.TEMPLATE_SLOT_BEGIN_TIME
  --ORDER BY LEN(tmpl_booked_blocks.APPT_BLOCK_NAME_STRING)
  --       , tmpl.DEPARTMENT_ID
  --       , tmpl.PROV_ID
		-- , tmpl.BEGIN_DATE_TM_RANGE
  --       , tmpl.BEGIN_TIME_TM_RANGE
*/
SELECT display_template.DEPARTMENT_ID
     , display_template.DEPARTMENT_NAME
	 , display_template.PROV_ID
	 , display_template.PROV_NAME
	 , display_template.SLOT_DOW
	 , display_template.SLOT_DATE
	 , display_template.SLOT_BEGIN_TIME
	 , display_template.SLOT_END_TIME
	 , display_template.SLOT_LENGTH
	 , display_template.OPENINGS_PER_SLOT
	 , display_template.NUMBER_OB_ALLOWED
	 , CASE WHEN LEN(display_template.BLOCK_NAME_STRING) > 0 THEN COALESCE(LEFT(display_template.BLOCK_NAME_STRING,LEN(display_template.BLOCK_NAME_STRING)-1),'')
	        ELSE ''
	   END AS BLOCK_INFORMATION
FROM
(
SELECT DISTINCT
       tmpl.DEPARTMENT_ID
     , tmpl.DEPARTMENT_NAME
	 , tmpl.PROV_ID
	 , tmpl.PROV_NAME
	 , tmpl.DOW AS SLOT_DOW
	 , tmpl.ddte_DOW AS SLOT_DOW_NUM
	 , tmpl.TEMPLATE_SLOT_DATE AS SLOT_DATE
	 , tmpl.TEMPLATE_SLOT_BEGIN_TIME AS SLOT_BEGIN_TIME
	 , tmpl.TEMPLATE_SLOT_END_TIME AS SLOT_END_TIME
	 , tmpl.SLOT_LENGTH
	 , tmpl.OPENINGS_PER_SLOT
	 , tmpl.NUMBER_OB_ALLOWED
     --, (SELECT CASE WHEN tmpl_avail_blockst.BLOCK_NAME = 'No Block Information' THEN '' ELSE tmpl_avail_blockst.BLOCK_NAME + CASE WHEN tmpl_avail_blockst.ORG_AVAIL_BLOCKS > 0 THEN '(1)' ELSE '' END END + ',' AS [text()]
     , (SELECT CASE WHEN tmpl_avail_blockst.BLOCK_NAME = 'No Block Information' THEN '' ELSE tmpl_avail_blockst.BLOCK_NAME + CASE WHEN tmpl_avail_blockst.ORG_AVAIL_BLOCKS > 0 THEN '(' + CAST(tmpl_avail_blockst.ORG_AVAIL_BLOCKS AS VARCHAR(2)) + ')' ELSE '' END END + ',' AS [text()]
		FROM #tmpl_avail_blocks tmpl_avail_blockst
		WHERE tmpl_avail_blockst.DEPARTMENT_ID = tmpl_avail_blocks.DEPARTMENT_ID
		AND tmpl_avail_blockst.PROV_ID = tmpl_avail_blocks.PROV_ID
		AND tmpl_avail_blockst.TEMPLATE_SLOT_DATE = tmpl_avail_blocks.TEMPLATE_SLOT_DATE
		AND tmpl_avail_blockst.TEMPLATE_SLOT_BEGIN_TIME = tmpl_avail_blocks.TEMPLATE_SLOT_BEGIN_TIME
		AND tmpl_avail_blockst.Seq = 1
		ORDER BY tmpl_avail_blockst.LINE
	    FOR XML PATH ('')) AS BLOCK_NAME_STRING
FROM #schdtmpl tmpl
LEFT OUTER JOIN
(
SELECT DISTINCT
       blk.DEPARTMENT_ID
	 , blk.PROV_ID
	 , blk.TEMPLATE_SLOT_DATE
	 , blk.TEMPLATE_SLOT_BEGIN_TIME
	 , blk.TEMPLATE_SLOT_END_TIME
	 , blk.BLOCK_NAME
	 , blk.ORG_AVAIL_BLOCKS
	 --, CASE
	 --    WHEN blk.BLOCK_NAME = 'No Block Information' THEN ''
		-- ELSE blk.BLOCK_NAME + CASE
		--                         WHEN blk.ORG_AVAIL_BLOCKS > 0 THEN '(1)'
		--						 ELSE ''
		--						END
	 --  END AS BLOCK_NAME_COUNT
FROM #tmpl_avail_blocks blk
WHERE blk.Seq = 1) tmpl_avail_blocks
ON tmpl_avail_blocks.DEPARTMENT_ID = tmpl.DEPARTMENT_ID
AND tmpl_avail_blocks.PROV_ID = tmpl.PROV_ID
AND tmpl_avail_blocks.TEMPLATE_SLOT_DATE = tmpl.TEMPLATE_SLOT_DATE
AND tmpl_avail_blocks.TEMPLATE_SLOT_BEGIN_TIME = tmpl.TEMPLATE_SLOT_BEGIN_TIME
AND tmpl_avail_blocks.TEMPLATE_SLOT_END_TIME = tmpl.TEMPLATE_SLOT_END_TIME
) display_template
  --ORDER BY SLOT_BEGIN_TIME
  --       , APPT_NUMBER
  --ORDER BY  avail.SLOT_DATE
  --       , SLOT_BEGIN_TIME
  --       , APPT_NUMBER
  --ORDER BY tmpl.DEPARTMENT_ID
  --       , tmpl.PROV_ID
		-- , tmpl.TEMPLATE_SLOT_DATE
  --       , tmpl.TEMPLATE_SLOT_BEGIN_TIME
		-- , tmpl.TEMPLATE_SLOT_END_TIME
  ORDER BY display_template.DEPARTMENT_ID
         , display_template.PROV_ID
		 , display_template.SLOT_DOW_NUM
		 , display_template.SLOT_DATE
         , display_template.SLOT_BEGIN_TIME
		 , display_template.SLOT_END_TIME
  --ORDER BY tmpl.DAY_OF_THE_WEEK_C
  --       , tmpl.DEPARTMENT_ID
  --       , tmpl.PROV_ID
		-- , tmpl.TEMPLATE_SLOT_DATE
  --       , tmpl.TEMPLATE_SLOT_BEGIN_TIME
  --ORDER BY LEN(tmpl_booked_blocks.APPT_BLOCK_NAME_STRING)
  --       , tmpl.DEPARTMENT_ID
  --       , tmpl.PROV_ID
		-- , tmpl.BEGIN_DATE_TM_RANGE
  --       , tmpl.BEGIN_TIME_TM_RANGE
