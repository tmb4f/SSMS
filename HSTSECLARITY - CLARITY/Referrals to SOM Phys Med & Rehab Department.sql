
-- Provide a short summary of your request: Monthly report for referrals of cancer patients to rehab services

-- Detailed Description of Request: 
-- Monthly report of # of referrals and # of appointments made and kept for cancer patients 
-- referred to rehabilitation services of PT, OT, PMR and SLP. 
-- The referral source should be tracked by department and cancer diagnosis.

-- Author: Karen Stanford
-- Date Created: 2021-03-15
-- The report is for referrals to these 4 departments:
-- Referred to Dept.
-------------------
-- PM&R (ECCC PHYSMD&REHB epic dept)
-- Physical therapy (ECCC PHY THERAPY 2 WEST)
-- PM&R (CVPP PHYMED &REHB)
-- Physical Therapy (CVPP PHY THERAPY)

-- Referral ID| Patient Name| MRN| Referral Type| Referral Status |Referred By Provider |Referred By Department |Referred to Provider |Referred to Department |Reason for Referral|Sub-specialty |First Appt Date |Appt Scheduled/Completed
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DECLARE @BeginDt AS DATETIME
DECLARE @EndDt AS DATETIME

SET @BeginDt = '6/1/2022 00:00:00'
SET @EndDt = '7/31/2022 23:59:59'

/*PROV_ID	PROV_NAME
29096	ALFANO, ALAN PETER
67158	AMALFITANO, JOSEPH
56932	ASTHAGIRI, HEATHER L
29097	DIAMOND, PAUL T
41083	GRICE, D. PRESTON
51070	GRICE, DARLINDA M
29094	GYPSON, WARD
74042	HRYVNIAK, DAVID
29087	JENKINS, JEFFREY
56129	KELLEHER, NICOLE C.
68058	LUNSFORD, CHRISTOPHER D
29095	MILLER, SUSAN
116776	MIXON, ALYSSA
64818	REDIESKE, CRYSTON MICHELLE
74043	ROYER, REGAN H
29092	RUBENDALL, DAVID S
90452	SHEPPARD, MICHAEL
46238	SMITH II, GEOFFREY R
71719	WARWICK, MICHAEL D
66781	WEPPNER, JUSTIN L
29073	WILDER, ROBERT*/

;WITH providers AS
(
SELECT
	 ser.PROV_ID
    ,ser.PROV_NAME

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

FROM CLARITY.dbo.CLARITY_SER AS ser
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
					FROM CLARITY_App.Rptg.vwRef_OracleOrg_to_EpicFinancialSubdiv) dvsn
				    ON (CAST(dvsn.Epic_Financial_Division_Code AS INTEGER) = TRY_CAST(ser.RPT_GRP_SIX AS INT)
					    AND CAST(dvsn.Epic_Financial_Subdivision_Code AS INTEGER) = TRY_CAST(ser.RPT_GRP_EIGHT AS INT))
WHERE dvsn.Department_ID = 259 -- MD-PHMR Phys Med & Rehab
)


  SELECT	DISTINCT
			r.REFERRAL_ID																													AS "Referral ID"
			, p.PAT_NAME																													AS "Patient Name"
			, p.PAT_MRN_ID																													AS "MRN"
			, r.START_DATE																													AS "Referral Created Date"	
			, r.EXP_DATE																													AS "Referral Expires Date"
			, ztyp.NAME																														AS "Referral Type"
			, zstat.NAME																													AS "Referral Status"
			, prov_from.PROV_NAME + ' [' + prov_from.PROV_ID  + ']'																			AS "Referred by Provider"	
			, d1.DEPARTMENT_NAME																											AS "Referred by Dept"
			, l1.LOC_NAME																													AS "Referred by Location"
			, vsa.PROV_NAME_WID																												AS "Referred to Provider"
			, d2.DEPARTMENT_NAME																											AS "Referred to Dept"
 			, osq.[REASON FOR REFERRAL || SUBSPECIALTY]																						AS "Reason for Referral || Subspecialty"
			--, edg.DX_NAME																													AS "Cancer Dx"
			, prior_month.FirstApptDate																										AS "First Appt Date"
			, CONVERT(varchar(150), prior_month.ApptCompleted) + '/' + CONVERT(varchar(150),prior_month.TotApptScheduled)					AS "Appt Completed/Scheduled"
	

  FROM CLARITY.dbo.REFERRAL									r WITH (NOLOCK)
		LEFT OUTER JOIN CLARITY.dbo.PATIENT					p WITH (NOLOCK)				ON r.PAT_ID = p.PAT_ID
		LEFT OUTER JOIN CLARITY.dbo.ZC_RFL_TYPE				ztyp WITH (NOLOCK)			ON r.RFL_TYPE_C = ztyp.RFL_TYPE_C
		LEFT OUTER JOIN CLARITY.dbo.ZC_RFL_STATUS			zstat WITH (NOLOCK)			ON r.RFL_STATUS_C = zstat.RFL_STATUS_C
		INNER JOIN CLARITY.dbo.V_SCHED_APPT					vsa WITH (NOLOCK)			ON r.REFERRAL_ID = vsa.REFERRAL_ID 
		INNER JOIN providers providers ON vsa.PROV_ID = providers.PROV_ID
		LEFT OUTER JOIN 		(SELECT REFERRAL_ID,
										MIN(CONTACT_DATE) AS 'FirstApptDate',
										SUM(CASE WHEN COMPLETED_STATUS_YN = 'Y' THEN 1 ELSE 0 End) AS ApptCompleted,
										SUM(CASE WHEN COMPLETED_STATUS_YN = 'N' THEN 1 ELSE 0 end) AS ApptNotCompleted,
										COUNT(*) AS TotApptScheduled
									FROM CLARITY.dbo.V_SCHED_APPT
									--WHERE REFERRAL_ID = 7462228
									GROUP BY REFERRAL_ID
								) prior_month ON vsa.REFERRAL_ID = prior_month.REFERRAL_ID 

		INNER JOIN CLARITY.dbo.REFERRAL_DX			rdx	WITH (NOLOCK)	ON					r.REFERRAL_ID = rdx.REFERRAL_ID AND rdx.LINE = 1
		LEFT OUTER JOIN CLARITY.dbo.CLARITY_DEP		d1  WITH (NOLOCK)	ON					d1.DEPARTMENT_ID		= r.REFD_BY_DEPT_ID
		LEFT OUTER JOIN CLARITY.dbo.CLARITY_LOC     l1  WITH (NOLOCK)	ON					l1.LOC_ID				= r.REFD_BY_LOC_POS_ID
		LEFT OUTER JOIN CLARITY.dbo.CLARITY_SER     s2  WITH (NOLOCK)	ON					s2.PROV_ID				= r.REFERRING_PROV_ID
		LEFT OUTER JOIN CLARITY.dbo.CLARITY_DEP     d2  WITH (NOLOCK)	ON					d2.DEPARTMENT_ID		= r.REFD_TO_DEPT_ID
		LEFT OUTER JOIN CLARITY.dbo.CLARITY_LOC     l2  WITH (NOLOCK)	ON					l2.LOC_ID				= r.REFD_TO_LOC_POS_ID
		INNER JOIN CLARITY.dbo.REFERRAL_SOURCE		rs  WITH (NOLOCK)	ON					r.REFERRING_PROV_ID		= rs.REFERRING_PROV_ID
		INNER JOIN CLARITY.dbo.CLARITY_SER			prov_from WITH (NOLOCK) ON				rs.REF_PROVIDER_ID		= prov_from.PROV_ID
		INNER JOIN CLARITY.dbo.REFERRAL_ORDER_ID    roi WITH (NOLOCK)	ON					r.REFERRAL_ID			= roi.REFERRAL_ID
		INNER JOIN CLARITY.dbo.ORDERS				o WITH (NOLOCK)		ON					roi.ORDER_ID			= o.ORDER_ID
		INNER JOIN  
								(SELECT		ORDER_ID,  
											[REASON FOR REFERRAL || SUBSPECIALTY] = 
											STUFF  
											(  
												(  
													SELECT DISTINCT ' || ' + CAST(ORD_QUEST_RESP AS VARCHAR(MAX))  
														FROM CLARITY.dbo.ORD_SPEC_QUEST t2   
														WHERE t2.ORDER_ID = t1.ORDER_ID 
														FOR XML PATH('')  
											),1,1,''  
											)  
										FROM CLARITY.dbo.ORD_SPEC_QUEST t1  
										GROUP BY ORDER_ID
										) osq ON o.ORDER_ID = osq.ORDER_ID  
		--INNER JOIN CLARITY.dbo.CLARITY_EDG			edg WITH (NOLOCK)	ON					rdx.DX_ID				= edg.DX_ID

		WHERE r.START_DATE >= @BeginDt
		AND r.START_DATE  < @EndDt
		--AND d2.DEPARTMENT_NAME IN ('ECCC PHY THERPY 2 WEST','CVPP PHY THERAPY','ECCC PHYSMD&RHB 2 WEST','CVPP PHYMED&REHB')
 
 		ORDER BY r.REFERRAL_ID, r.START_DATE