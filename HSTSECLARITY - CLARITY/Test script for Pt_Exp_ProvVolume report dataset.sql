USE CLARITY

DECLARE @StartDate AS SMALLDATETIME
DECLARE @EndDate AS SMALLDATETIME

SET @StartDate = '1/1/2021 00:00'
SET @EndDate = '2/1/2022 00:00'

/*SELECT		npi.NPI
        ,npi.PROV_ID
		--,ser.PROV_NAME 'Display name'
		--,zcsp.NAME 'Specialty'
		--,dept.DEPARTMENT_NAME 'Primary clinic'
		,enc.APPT_TIME
		,dt.month_name 'month'
		,dt.fmonth_num
		,dt.year_num 'Year'
		,enc.PAT_ENC_CSN_ID 'Encounters'


FROM dbo.PAT_ENC enc
	INNER JOIN (
					SELECT idx.IDENTITY_ID 'NPI'
							,idx.PROV_ID
					FROM CLARITY.dbo.IDENTITY_SER_ID idx
					WHERE idx.IDENTITY_TYPE_ID='100001'
			   ) npi								ON enc.VISIT_PROV_ID=npi.PROV_ID
	--INNER JOIN dbo.CLARITY_SER ser					ON ser.PROV_ID = npi.PROV_ID
	--INNER JOIN (SELECT *
	--			FROM dbo.CLARITY_SER_SPEC
	--			WHERE LINE='1') sp					ON sp.PROV_ID = ser.PROV_ID
	--INNER JOIN dbo.ZC_SPECIALTY zcsp					ON zcsp.SPECIALTY_C = sp.SPECIALTY_C
	--INNER JOIN (SELECT *
	--			FROM dbo.CLARITY_SER_DEPT dep
	--			WHERE dep.LINE='1') dep				ON dep.DEPARTMENT_ID = enc.DEPARTMENT_ID
	--INNER JOIN dbo.CLARITY_DEP dept					ON dep.DEPARTMENT_ID=dept.DEPARTMENT_ID
	INNER JOIN CLARITY_App.dbo.Dim_Date dt				ON CAST(dt.day_date AS DATE)=CAST(enc.APPT_TIME AS DATE)


WHERE 1=1
--AND  (@NPI IS NULL OR npi.NPI IN (SELECT * FROM CLARITY.ETL.fn_ParmParse(@NPI,',')))
AND npi.NPI IN ('1811156649')
AND enc.APPT_STATUS_C in ('2','6')--completed
AND dt.day_date >=@StartDate
AND dt.day_date <=@EndDate
AND npi.NPI IS NOT NULL 
--GROUP BY npi.NPI,dt.year_num, dt.fmonth_num
--ORDER BY npi.NPI,dt.year_num, dt.fmonth_num
ORDER BY npi.NPI,dt.year_num, dt.fmonth_num, enc.APPT_TIME, enc.PAT_ENC_CSN_ID

SELECT		npi.NPI
        ,npi.PROV_ID
		,ser.PROV_NAME 'Display name'
		--,zcsp.NAME 'Specialty'
		--,dept.DEPARTMENT_NAME 'Primary clinic'
		,enc.APPT_TIME
		,dt.month_name 'month'
		,dt.fmonth_num
		,dt.year_num 'Year'
		,enc.PAT_ENC_CSN_ID 'Encounters'


FROM dbo.PAT_ENC enc
	INNER JOIN (
					SELECT idx.IDENTITY_ID 'NPI'
							,idx.PROV_ID
					FROM CLARITY.dbo.IDENTITY_SER_ID idx
					WHERE idx.IDENTITY_TYPE_ID='100001'
			   ) npi								ON enc.VISIT_PROV_ID=npi.PROV_ID
	INNER JOIN dbo.CLARITY_SER ser					ON ser.PROV_ID = npi.PROV_ID
	--INNER JOIN (SELECT *
	--			FROM dbo.CLARITY_SER_SPEC
	--			WHERE LINE='1') sp					ON sp.PROV_ID = ser.PROV_ID
	--INNER JOIN dbo.ZC_SPECIALTY zcsp					ON zcsp.SPECIALTY_C = sp.SPECIALTY_C
	--INNER JOIN (SELECT *
	--			FROM dbo.CLARITY_SER_DEPT dep
	--			WHERE dep.LINE='1') dep				ON dep.DEPARTMENT_ID = enc.DEPARTMENT_ID
	--INNER JOIN dbo.CLARITY_DEP dept					ON dep.DEPARTMENT_ID=dept.DEPARTMENT_ID
	INNER JOIN CLARITY_App.dbo.Dim_Date dt				ON CAST(dt.day_date AS DATE)=CAST(enc.APPT_TIME AS DATE)


WHERE 1=1
--AND  (@NPI IS NULL OR npi.NPI IN (SELECT * FROM CLARITY.ETL.fn_ParmParse(@NPI,',')))
AND npi.NPI IN ('1811156649')
AND enc.APPT_STATUS_C in ('2','6')--completed
AND dt.day_date >=@StartDate
AND dt.day_date <=@EndDate
AND npi.NPI IS NOT NULL 
--GROUP BY npi.NPI,dt.year_num, dt.fmonth_num
--ORDER BY npi.NPI,dt.year_num, dt.fmonth_num
ORDER BY npi.NPI,dt.year_num, dt.fmonth_num, enc.APPT_TIME, enc.PAT_ENC_CSN_ID

SELECT		npi.NPI
        ,npi.PROV_ID
		,ser.PROV_NAME 'Display name'
		,sp.SPECIALTY_C
		,zcsp.NAME 'Specialty'
		--,dept.DEPARTMENT_NAME 'Primary clinic'
		,enc.APPT_TIME
		,dt.month_name 'month'
		,dt.fmonth_num
		,dt.year_num 'Year'
		,enc.PAT_ENC_CSN_ID 'Encounters'


FROM dbo.PAT_ENC enc
	INNER JOIN (
					SELECT idx.IDENTITY_ID 'NPI'
							,idx.PROV_ID
					FROM CLARITY.dbo.IDENTITY_SER_ID idx
					WHERE idx.IDENTITY_TYPE_ID='100001'
			   ) npi								ON enc.VISIT_PROV_ID=npi.PROV_ID
	INNER JOIN dbo.CLARITY_SER ser					ON ser.PROV_ID = npi.PROV_ID
	INNER JOIN (SELECT *
				FROM dbo.CLARITY_SER_SPEC
				WHERE LINE='1') sp					ON sp.PROV_ID = ser.PROV_ID
	INNER JOIN dbo.ZC_SPECIALTY zcsp					ON zcsp.SPECIALTY_C = sp.SPECIALTY_C
	--INNER JOIN (SELECT *
	--			FROM dbo.CLARITY_SER_DEPT dep
	--			WHERE dep.LINE='1') dep				ON dep.DEPARTMENT_ID = enc.DEPARTMENT_ID
	--INNER JOIN dbo.CLARITY_DEP dept					ON dep.DEPARTMENT_ID=dept.DEPARTMENT_ID
	INNER JOIN CLARITY_App.dbo.Dim_Date dt				ON CAST(dt.day_date AS DATE)=CAST(enc.APPT_TIME AS DATE)


WHERE 1=1
--AND  (@NPI IS NULL OR npi.NPI IN (SELECT * FROM CLARITY.ETL.fn_ParmParse(@NPI,',')))
AND npi.NPI IN ('1811156649')
AND enc.APPT_STATUS_C in ('2','6')--completed
AND dt.day_date >=@StartDate
AND dt.day_date <=@EndDate
AND npi.NPI IS NOT NULL 
--GROUP BY npi.NPI,dt.year_num, dt.fmonth_num
--ORDER BY npi.NPI,dt.year_num, dt.fmonth_num
ORDER BY npi.NPI,dt.year_num, dt.fmonth_num, enc.APPT_TIME, enc.PAT_ENC_CSN_ID

SELECT		npi.NPI
        ,npi.PROV_ID
		,ser.PROV_NAME 'Display name'
		,sp.SPECIALTY_C
		,zcsp.NAME 'Specialty'
		,enc.DEPARTMENT_ID
		,dep.DEPARTMENT_ID
		--,dept.DEPARTMENT_NAME 'Primary clinic'
		,enc.APPT_TIME
		,dt.month_name 'month'
		,dt.fmonth_num
		,dt.year_num 'Year'
		,enc.PAT_ENC_CSN_ID 'Encounters'


FROM dbo.PAT_ENC enc
	INNER JOIN (
					SELECT idx.IDENTITY_ID 'NPI'
							,idx.PROV_ID
					FROM CLARITY.dbo.IDENTITY_SER_ID idx
					WHERE idx.IDENTITY_TYPE_ID='100001'
			   ) npi								ON enc.VISIT_PROV_ID=npi.PROV_ID
	INNER JOIN dbo.CLARITY_SER ser					ON ser.PROV_ID = npi.PROV_ID
	INNER JOIN (SELECT *
				FROM dbo.CLARITY_SER_SPEC
				WHERE LINE='1') sp					ON sp.PROV_ID = ser.PROV_ID
	INNER JOIN dbo.ZC_SPECIALTY zcsp					ON zcsp.SPECIALTY_C = sp.SPECIALTY_C
	INNER JOIN (SELECT *
				FROM dbo.CLARITY_SER_DEPT dep
				WHERE dep.LINE='1') dep				ON dep.DEPARTMENT_ID = enc.DEPARTMENT_ID
	--INNER JOIN dbo.CLARITY_DEP dept					ON dep.DEPARTMENT_ID=dept.DEPARTMENT_ID
	INNER JOIN CLARITY_App.dbo.Dim_Date dt				ON CAST(dt.day_date AS DATE)=CAST(enc.APPT_TIME AS DATE)


WHERE 1=1
--AND  (@NPI IS NULL OR npi.NPI IN (SELECT * FROM CLARITY.ETL.fn_ParmParse(@NPI,',')))
AND npi.NPI IN ('1811156649')
AND enc.APPT_STATUS_C in ('2','6')--completed
AND dt.day_date >=@StartDate
AND dt.day_date <=@EndDate
AND npi.NPI IS NOT NULL 
--GROUP BY npi.NPI,dt.year_num, dt.fmonth_num
--ORDER BY npi.NPI,dt.year_num, dt.fmonth_num
ORDER BY npi.NPI,dt.year_num, dt.fmonth_num, enc.APPT_TIME, enc.PAT_ENC_CSN_ID

SELECT		npi.NPI
        ,npi.PROV_ID
		--,ser.PROV_NAME 'Display name'
		--,sp.SPECIALTY_C
		--,zcsp.NAME 'Specialty'
		,enc.DEPARTMENT_ID
		,dep.DEPARTMENT_ID
		,dep.PROV_ID
		--,dept.DEPARTMENT_NAME 'Primary clinic'
		,enc.APPT_TIME
		,dt.month_name 'month'
		,dt.fmonth_num
		,dt.year_num 'Year'
		,enc.PAT_ENC_CSN_ID 'Encounters'


FROM dbo.PAT_ENC enc
	INNER JOIN (
					SELECT idx.IDENTITY_ID 'NPI'
							,idx.PROV_ID
					FROM CLARITY.dbo.IDENTITY_SER_ID idx
					WHERE idx.IDENTITY_TYPE_ID='100001'
			   ) npi								ON enc.VISIT_PROV_ID=npi.PROV_ID
	--INNER JOIN dbo.CLARITY_SER ser					ON ser.PROV_ID = npi.PROV_ID
	--INNER JOIN (SELECT *
	--			FROM dbo.CLARITY_SER_SPEC
	--			WHERE LINE='1') sp					ON sp.PROV_ID = ser.PROV_ID
	--INNER JOIN dbo.ZC_SPECIALTY zcsp					ON zcsp.SPECIALTY_C = sp.SPECIALTY_C
	INNER JOIN (SELECT *
				FROM dbo.CLARITY_SER_DEPT dep
				WHERE dep.LINE='1') dep				ON (dep.DEPARTMENT_ID = enc.DEPARTMENT_ID)
				AND (dep.PROV_ID = npi.PROV_ID)
	--INNER JOIN dbo.CLARITY_DEP dept					ON dep.DEPARTMENT_ID=dept.DEPARTMENT_ID
	INNER JOIN CLARITY_App.dbo.Dim_Date dt				ON CAST(dt.day_date AS DATE)=CAST(enc.APPT_TIME AS DATE)


WHERE 1=1
--AND  (@NPI IS NULL OR npi.NPI IN (SELECT * FROM CLARITY.ETL.fn_ParmParse(@NPI,',')))
AND npi.NPI IN ('1811156649')
AND enc.APPT_STATUS_C in ('2','6')--completed
AND dt.day_date >=@StartDate
AND dt.day_date <=@EndDate
AND npi.NPI IS NOT NULL 
--GROUP BY npi.NPI,dt.year_num, dt.fmonth_num
--ORDER BY npi.NPI,dt.year_num, dt.fmonth_num
ORDER BY npi.NPI,dt.year_num, dt.fmonth_num, enc.APPT_TIME, enc.PAT_ENC_CSN_ID
*/
SELECT		npi.NPI
		,MAX(ser.PROV_NAME) 'Display name'
		,MAX(zcsp.NAME) 'Specialty'
		,MAX(dept.DEPARTMENT_NAME) 'Primary clinic'
		,MAX(dt.month_name) 'month'
		,dt.fmonth_num
		,dt.year_num 'Year'
		,COUNT(enc.PAT_ENC_CSN_ID) 'Encounters'

--SELECT		npi.NPI
--		,ser.PROV_NAME 'Display name'
--		,zcsp.NAME 'Specialty'
--		,dept.DEPARTMENT_NAME 'Primary clinic'
--		,enc.APPT_TIME
--		,dt.month_name 'month'
--		,dt.fmonth_num
--		,dt.year_num 'Year'
--		,enc.PAT_ENC_CSN_ID 'Encounters'


FROM dbo.PAT_ENC enc
	INNER JOIN (
					SELECT idx.IDENTITY_ID 'NPI'
							,idx.PROV_ID
					FROM CLARITY.dbo.IDENTITY_SER_ID idx
					WHERE idx.IDENTITY_TYPE_ID='100001'
			   ) npi								ON enc.VISIT_PROV_ID=npi.PROV_ID
	INNER JOIN dbo.CLARITY_SER ser					ON ser.PROV_ID = npi.PROV_ID
	INNER JOIN (SELECT *
				FROM dbo.CLARITY_SER_SPEC
				WHERE LINE='1') sp					ON sp.PROV_ID = ser.PROV_ID
	INNER JOIN dbo.ZC_SPECIALTY zcsp					ON zcsp.SPECIALTY_C = sp.SPECIALTY_C
	INNER JOIN (SELECT *
				FROM dbo.CLARITY_SER_DEPT dep
				WHERE dep.LINE='1') dep				ON (dep.DEPARTMENT_ID = enc.DEPARTMENT_ID)
				AND (dep.PROV_ID = sp.PROV_ID)
	INNER JOIN dbo.CLARITY_DEP dept					ON dep.DEPARTMENT_ID=dept.DEPARTMENT_ID
	INNER JOIN CLARITY_App.dbo.Dim_Date dt				ON CAST(dt.day_date AS DATE)=CAST(enc.APPT_TIME AS DATE)


WHERE 1=1
--AND  (@NPI IS NULL OR npi.NPI IN (SELECT * FROM CLARITY.ETL.fn_ParmParse(@NPI,',')))
--AND npi.NPI IN ('1811156649')
AND npi.NPI IN ('1164591780',
'1760511711',
'1811156649',
'1114345162',
'1629359013',
'1659519932',
'1073035668',
'1679618763',
'1164591780',
'1164591701',
'1780730036')
AND enc.APPT_STATUS_C in ('2','6')--completed
AND dt.day_date >=@StartDate
AND dt.day_date <=@EndDate
AND npi.NPI IS NOT NULL 
GROUP BY npi.NPI,dt.year_num, dt.fmonth_num
ORDER BY npi.NPI,dt.year_num, dt.fmonth_num
--ORDER BY npi.NPI,dt.year_num, dt.fmonth_num, enc.APPT_TIME, enc.PAT_ENC_CSN_ID