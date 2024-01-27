USE CLARITY;

/*
WHERE 	PROV_TYPE_C IN 	(		'1'       /*   Physician			*/	,   '4'       /*   Anesthesiologist					*/
                           	,   '5'       /*   Midwife				*/	,   '6'       /*   Physician Assistant				*/
                            ,   '9'       /*   Nurse Practitioner	*/	,   '10'      /*   Psychologist						*/
                            ,   '12'      /*   Hygienist			*/	,   '108'     /*   Dentist							*/
                            ,   '2505'    /*   MBBS					*/	,   '2506'    /*   Doctor of Philosophy				*/
                            ,   '2508'    /*   Psychiatrist			*/	,   '100'     /*   Occupational Therapist			*/
                            ,   '106'     /*   Physical Therapist	*/	,   '21'      /*   Speech and Language Pathologist	*/
                        )
*/

WITH	Clarity_SER_OT_Prov_Type AS		
	(	SELECT	PROV_ID						
			,	CONTACT_DATE 			
			,	COALESCE(LEAD(CONTACT_DATE) OVER(PARTITION BY PROV_ID ORDER BY CONTACT_DATE_REAL),'2099-12-31') AS 'EFF_TO_DATE' 
			,	PROV_TYPE_OT_C
		FROM CLARITY.dbo.CLARITY_SER_OT	
	)

,	Clarity_SER_OT_Prov_Type_cte AS
	(	SELECT	PROV_ID
			,	CONTACT_DATE
			,	DATEADD(DAY,-1,EFF_TO_DATE)		AS 'EFF_TO_DATE' 
			,	PROV_TYPE_OT_C
		FROM Clarity_SER_OT_Prov_Type ptot
			--INNER JOIN Provider_Types			ptcte	ON ptot.PROV_TYPE_OT_C = ptcte.PROV_TYPE_C		/* Limit to target Patient Types defined */
		WHERE CONTACT_DATE <> EFF_TO_DATE																/* To get a single contact per date */
	)

--SELECT * FROM Clarity_SER_OT_Prov_Type_cte
--WHERE PROV_ID = '580597'

--SELECT cte.* , zctyp.NAME
--FROM 	Clarity_SER_OT_Prov_Type_cte  cte
--	LEFT JOIN ZC_PROV_TYPE	zctyp	ON cte.PROV_TYPE_OT_C = zctyp.PROV_TYPE_C
----WHERE PROV_ID = '74413'
--WHERE PROV_ID = '62404'
--ORDER BY CONTACT_DATE


--SELECT TOP 100 pt.PROV_TYPE_OT_C, ser.PROV_TYPE, arpb.* 
SELECT arpb.PAT_ENC_CSN_ID,
etyp.NAME AS ENCOUNTER_TYPE_NAME,
--CASE WHEN appt.PAT_ENC_CSN_ID IS NULL THEN 'N' ELSE 'Y' END AS [Sched Appt?],
asts.NAME AS APPT_STATUS_NAME,
PRC.PRC_NAME,
ser.RPT_GRP_SIX AS FIN_DIV,
arpb.BILLING_PROV_ID,
ser.PROV_NAME,
zctyp.NAME AS PROV_TYPE_dos,
ser.PROV_TYPE AS PROV_TYPE_curr
	, SERVICE_DATE, TX_ID, AMOUNT
	--, MIN(POST_DATE)	AS POST_DATE_min
	--, MAX(POST_DATE)	AS POST_DATE_max
	--, COUNT(TX_ID)		AS Txn_count
	--, SUM(AMOUNT)		AS Charges

FROM ARPB_TRANSACTIONS	arpb
	INNER JOIN Clarity_SER_OT_Prov_Type_cte		pt		ON		arpb.BILLING_PROV_ID = pt.PROV_ID 
													AND			arpb.SERVICE_DATE BETWEEN pt.CONTACT_DATE AND pt.EFF_TO_DATE
	LEFT JOIN CLARITY_SER						ser		ON		arpb.BILLING_PROV_ID = ser.PROV_ID
	LEFT JOIN ZC_PROV_TYPE						zctyp	ON		pt.PROV_TYPE_OT_C = zctyp.PROV_TYPE_C

	LEFT OUTER JOIN CLARITY..PAT_ENC															AS  PE		ON PE.PAT_ENC_CSN_ID=arpb.PAT_ENC_CSN_ID
    LEFT JOIN CLARITY..ZC_APPT_STATUS													AS  asts	ON asts.APPT_STATUS_C=pe.APPT_STATUS_C
    LEFT JOIN CLARITY..CLARITY_PRC														AS  PRC		ON prc.PRC_ID=pe.APPT_PRC_ID
	LEFT JOIN CLARITY..ZC_DISP_ENC_TYPE etyp									ON etyp.DISP_ENC_TYPE_C = pe.ENC_TYPE_C
	--LEFT JOIN (SELECT PAT_ENC_CSN_ID FROM CLARITY..V_SCHED_APPT WHERE APPT_DTTM >= '6/1/2021 00:00 AM') appt											ON appt.[PAT_ENC_CSN_ID] = arpb.PAT_ENC_CSN_ID
WHERE TX_TYPE_C = 1
--AND SERVICE_DATE >= '2017-07-01'
AND SERVICE_DATE >= '2021-06-01'
--AND SERVICE_DATE <= '2021-06-30'
--AND pt.PROV_TYPE_OT_C <> ser.PROVIDER_TYPE_C
AND VOID_DATE IS NULL
--AND BILLING_PROV_ID = '580597'
--AND BILLING_PROV_ID = '83064'
--GROUP BY ser.RPT_GRP_SIX, arpb.BILLING_PROV_ID, ser.PROV_NAME, pt.PROV_TYPE_OT_C, zctyp.NAME, ser.PROV_TYPE, TX_ID
AND arpb.PAT_ENC_CSN_ID IS NOT NULL
ORDER BY arpb.PAT_ENC_CSN_ID, ser.RPT_GRP_SIX, arpb.BILLING_PROV_ID, POST_DATE, pt.PROV_TYPE_OT_C
