USE CLARITY

-----  "REFERRALS TO"  Report  "REFERRAL_SOURCE  --> PROV_TYPE" CHANGED TO ZC_REF_PROV_TYPE --> NAME"
-----  DEPRECEATED COLUMN "REFERRAL_SOURCE  --> PROV_TYPE"; USE "REFERRAL_SOURCE  --> REF_PROV_TYPE_C INSTEAD"
-----  Updated on 5/21/2018 by  "Lakshmi Alla"

/*******************************************************************************************
WHAT:	Referred By
WHO :	Dayna Monaghan/Christine Kelly	
WHEN:	04/11/2017
WHY :	Reporting on referrals by a department

-------------------------------------------------------------------------------------------------------------------------
--INFO: 
--      INPUTS: REFERRAL
				REFERRAL_ORDER_ID
				ORDER_PROC
				ZC_RFL_CLASS
				ZC_RFL_STATUS
				ZC_REFD_TO_SPEC
				CLARITY_DEP
				CLARITY_POS
				REFERRAL_SOURCE
				CLARITY_SER
				ZC_NOTE_SER
                  
--      OUTPUTS: 
   
   	
--------------------------------------------------------------------------------------------
MODS:  

*******************************************************************************************/
  SELECT
     --rc.NAME                    AS RFRL_CLASS_NME
	 r.REFERRAL_ID
	,CAST(r.ENTRY_DATE AS DATE) AS RFRL_DATE
    ,rc.NAME                    AS RFRL_CLASS_NME
    ,rs.NAME                    AS RFRL_STATUS_NME
    ,prvtyp.NAME                AS RFRL_BY_PRVDR_TYPE_NME
    ,prvdr1.REFERRING_PROV_NAM  AS FRL_BY_PRVDR_NME
    ,r.REFD_BY_DEPT_ID          AS RFRL_BY_DEPT_ID
    ,d1.EXTERNAL_NAME           AS RFRL_BY_DEPT_NME
    ,pt2.NAME                   AS RFRL_TO_PRVDR_TYPE_NME
    ,prvdr2.PROV_NAME           AS RFRL_TO_PRVDR_NME
	,r.REFD_TO_DEPT_ID          AS RFRL_TO_DEPT_ID
    ,d2.EXTERNAL_NAME           AS RFRL_TO_DEPT_NME
    ,rts.NAME                   AS RFRL_to_SPCLTY_NME
    ,prc.DISPLAY_NAME           AS RFRL_ORDER_DSCR
	--,pt.PAT_ID
	,pt.PAT_MRN_ID              AS MRN
    --,CAST(r.ENTRY_DATE AS DATE) AS RFRL_DATE
	--,rcv.CVG_ID
	--,cv.PLAN_ID
	--,cv.PAYOR_ID
	--,cvpp.PAYOR_NAME
	--,cvpp.BENEFIT_PLAN_NAME
	--,cvm.PAT_ID AS MEM_PAT_ID
 --   ,cvm.MEM_COVERED_YN
    ,CASE
	   WHEN cvg.REFERRAL_ID IS NOT NULL THEN 1
	   ELSE 0
	 END AS MEDICARE
	,ddte.month_num
	,ddte.year_num
	,ddte.month_name
	,ddte.month_short_name
  FROM REFERRAL AS r WITH (NOLOCK)
  INNER JOIN REFERRAL_ORDER_ID     AS roi    WITH (NOLOCK) ON r.REFERRAL_ID          = roi.REFERRAL_ID
  LEFT OUTER JOIN ORDER_PROC       AS prc    WITH (NOLOCK) ON roi.ORDER_ID           = prc.ORDER_PROC_ID
  LEFT OUTER JOIN ZC_RFL_CLASS     AS rc     WITH (NOLOCK) ON r.RFL_CLASS_C          = rc.RFL_CLASS_C
  LEFT OUTER JOIN ZC_RFL_STATUS    AS rs     WITH (NOLOCK) ON r.RFL_STATUS_C         = rs.RFL_STATUS_C
  LEFT OUTER JOIN ZC_REFD_TO_SPEC  AS rts    WITH (NOLOCK) ON r.REFD_TO_SPEC_C       = rts.REFD_to_SPEC_C
  LEFT OUTER JOIN CLARITY_DEP      AS d1     WITH (NOLOCK) ON r.REFD_BY_DEPT_ID      = d1.DEPARTMENT_ID
  LEFT OUTER JOIN CLARITY_DEP      AS d2     WITH (NOLOCK) ON r.REFD_TO_DEPT_ID      = d2.DEPARTMENT_ID
  LEFT OUTER JOIN CLARITY_POS      AS pos1   WITH (NOLOCK) ON r.REFD_BY_LOC_POS_ID   = pos1.POS_ID
  LEFT OUTER JOIN REFERRAL_SOURCE  AS prvdr1 WITH (NOLOCK) ON r.REFERRING_PROV_ID    = prvdr1.REFERRING_PROV_ID
  LEFT OUTER JOIN CLARITY_SER      AS prvdr2 WITH (NOLOCK) ON r.REFERRAL_PROV_ID     = prvdr2.PROV_ID
  LEFT OUTER JOIN PATIENT		   AS pt     WITH (NOLOCK) ON r.PAT_ID               = pt.PAT_ID
  --LEFT OUTER JOIN REFERRAL_CVG     AS rcv    WITH (NOLOCK) ON r.REFERRAL_ID          = rcv.REFERRAL_ID
  LEFT OUTER JOIN ZC_NOTE_SER      AS pt2    WITH (NOLOCK) ON prvdr2.PROVIDER_TYPE_C = pt2.SERVICE_TYPE_C
  LEFT OUTER JOIN ZC_REF_PROV_TYPE AS prvtyp WITH (NOLOCK) ON prvdr1.REF_PROV_TYPE_C = prvtyp.REF_PROV_TYPE_C
  --LEFT OUTER JOIN COVERAGE_MEM_LIST AS cvm   WITH (NOLOCK) ON rcv.CVG_ID             = cvm.COVERAGE_ID
  --LEFT OUTER JOIN COVERAGE         AS cv     WITH (NOLOCK) ON rcv.CVG_ID             = cv.COVERAGE_ID
  --INNER JOIN V_COVERAGE_PAYOR_PLAN AS cvpp   WITH (NOLOCK) ON cv.COVERAGE_ID         = cvpp.COVERAGE_ID
  LEFT OUTER JOIN
  (
  SELECT DISTINCT
	rcv.REFERRAL_ID
  FROM REFERRAL_CVG     AS rcv    WITH (NOLOCK)
  --LEFT OUTER JOIN COVERAGE         AS cv     WITH (NOLOCK) ON rcv.CVG_ID             = cv.COVERAGE_ID
  --INNER JOIN V_COVERAGE_PAYOR_PLAN AS cvpp   WITH (NOLOCK) ON cv.COVERAGE_ID         = cvpp.COVERAGE_ID
  INNER JOIN V_COVERAGE_PAYOR_PLAN AS cvpp   WITH (NOLOCK) ON rcv.CVG_ID               = cvpp.COVERAGE_ID
  WHERE cvpp.PAYOR_NAME = 'MEDICARE'
  ) cvg ON r.REFERRAL_ID = cvg.REFERRAL_ID
  LEFT OUTER JOIN CLARITY_App.Rptg.vwDim_Date AS ddte ON ddte.day_date = CAST(CAST(r.ENTRY_DATE AS DATE) AS SMALLDATETIME)
  WHERE (r.ENTRY_DATE >= '7/1/2017 00:00 AM'
    --AND (r.REFD_TO_DEPT_ID IN (@dept))
    AND (d2.EXTERNAL_NAME LIKE 'Diabetes%'))
	AND d1.DEPARTMENT_NAME IS NOT null
  ORDER BY RFRL_CLASS_NME, r.ENTRY_DATE
  --ORDER BY pt.PAT_ID, r.ENTRY_DATE
  --ORDER BY cvg.REFERRAL_ID DESC