DECLARE @StartDate DATE
DECLARE @EndDate DATE

SET @StartDate = '4/1/2020'
SET @EndDate = '6/30/2020'

--SELECT DISTINCT
--       [NPI]
--      ,MAX([Prov_Name]) 'Prov_Name'
--   ,MAX(pg.Department_External_Name) 'Deptartment'
--	--  ,[Appt_Date]
--	  ,Month([Appt_Date]) 'Appt_Mnth'
--	  ,YEAR([Appt_Date]) 'Appt_Yr'
--	  ,Max(DATENAME(Month,([Appt_Date]))) 'Appt_Mnth_Nm'
--	  ,Count([PAT_ENC_CSN]) '#'
--  FROM [DS_HSDM_Ext_OutPuts].[PrsGny].[Daily_PrsGny_CGCAHPS_Epic_Extract] pg
--  WHERE 1=1
--   AND CAST(pg.Appt_Date AS DATE)>=@StartDate
--   AND CAST(pg.Appt_Date AS DATE)<=@EndDate
-- GROUP BY YEAR([Appt_Date])
-- ,Month([Appt_Date]) 
-- ,[NPI]

SELECT --DISTINCT
       [fill04] 'Visit_Type'
	  --,LEN([fill04]) 'Visit Type Length'
      --,[Department_External_Name] 'Department'
	--  ,[Appt_Date]
	  ,Month([Appt_Date]) 'Appt_Mnth'
	  ,YEAR([Appt_Date]) 'Appt_Yr'
	  ,Max(DATENAME(Month,([Appt_Date]))) 'Appt_Mnth_Nm'
	  ,Count([PAT_ENC_CSN]) '#'
  FROM [DS_HSDM_Ext_OutPuts].[PrsGny].[Daily_PrsGny_CGCAHPS_Epic_Extract] pg
  WHERE 1=1
   AND CAST(pg.Appt_Date AS DATE)>=@StartDate
   AND CAST(pg.Appt_Date AS DATE)<=@EndDate
   AND LEN([fill04]) > 0
 GROUP BY YEAR([Appt_Date])
 ,Month([Appt_Date]) 
 ,[fill04]
 --,LEN([fill04])
 --,[Department_External_Name]
 ORDER BY pg.fill04
         --,Department
		 ,YEAR([Appt_Date])
         ,Month([Appt_Date]) 