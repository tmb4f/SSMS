DECLARE @StartDate DATETIME;
	DECLARE @EndDate DATETIME;

			--SET  @StartDate= DATEADD(yy,-5,DATEADD(yy, DATEDIFF(yy,0,getdate()), 0)); --last five years
			--SET  @EndDate	=CONVERT(DATETIME,CONVERT(VARCHAR(10),DATEADD(dd,-1,GETDATE()),101) + ' 23:59:59'); --Yesterday

			SET  @StartDate= '7/1/2020 00:00:00';
			SET  @EndDate	='5/6/2021 23:59:59';
SELECT 
	hsp.PAT_ID 'Pat_ID'
	,hsp.VISIT_PROV_ID 'Prov_ID'
	,ser.PROV_NAME
	,hsp.APPT_STATUS_C
	,zas.NAME AS APPT_STATUS_NAME
	,hsp.PAT_ENC_DATE_REAL 'Cntc_Dt'
FROM  CLARITY.dbo.PAT_ENC hsp		--ON hsp.PAT_ENC_CSN_ID = enc.PAT_ENC_CSN_ID
LEFT OUTER JOIN CLARITY.dbo.ZC_APPT_STATUS zas
ON zas.APPT_STATUS_C = hsp.APPT_STATUS_C
LEFT OUTER JOIN CLARITY.dbo.CLARITY_SER ser
ON ser.PROV_ID = hsp.VISIT_PROV_ID

WHERE 
((hsp.CONTACT_DATE >=@StartDate		AND		hsp.CONTACT_DATE<@EndDate)
				OR 
				(hsp.HOSP_ADMSN_TIME  >=@StartDate	AND		hsp.HOSP_ADMSN_TIME <@EndDate))
				--AND hsp.APPT_STATUS_C IN ('2','6') --ONLY COMPLETED/ARRIVED STATUS
                --AND hsp.VISIT_PROV_ID IN ('109152','72660')
                AND ser.PROV_NAME LIKE '%O''Conn%'
ORDER BY ser.PROV_NAME


