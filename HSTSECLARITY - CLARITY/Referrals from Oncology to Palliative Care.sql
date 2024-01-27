USE CLARITY

SELECT
     CAST(r.ENTRY_DATE AS DATE) AS RFRL_DATE
    ,rc.NAME                    AS RFRL_CLASS_NME
    ,rs.NAME                    AS RFRL_STATUS_NME
    ,prvtyp.NAME                AS RFRL_BY_PRVDR_TYPE_NME
    ,prvdr1.REFERRING_PROV_NAM  AS RFRL_BY_PRVDR_NME
    ,r.REFD_BY_DEPT_ID          AS RFRL_BY_DEPT_ID
    ,d1.EXTERNAL_NAME           AS RFRL_BY_DEPT_NME
	,MDM.service_line           AS RFRL_BY_SERVICE_LINE
    ,pt2.NAME                   AS RFRL_TO_PRVDR_TYPE_NME
    ,prvdr2.PROV_NAME           AS RFRL_TO_PRVDR_NME
    ,d2.EXTERNAL_NAME           AS RFRL_TO_DEPT_NME
	,r.REFD_TO_SPEC_C           AS REFD_TO_SPEC_C
    ,rts.NAME                   AS RFRL_to_SPCLTY_NME
	,prc.ORDER_PROC_ID          AS ORDER_PROC_ID
    ,prc.DISPLAY_NAME           AS RFRL_ORDER_DSCR
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
  LEFT OUTER JOIN ZC_NOTE_SER      AS pt2    WITH (NOLOCK) ON prvdr2.PROVIDER_TYPE_C = pt2.SERVICE_TYPE_C
  LEFT OUTER JOIN ZC_REF_PROV_TYPE AS prvtyp WITH (NOLOCK) ON prvdr1.REF_PROV_TYPE_C = prvtyp.REF_PROV_TYPE_C
  LEFT OUTER JOIN CLARITY_App.Rptg.vwRef_MDM_Location_Master_EpicSvc MDM
  --ON mdm.epic_department_id = r.REFD_BY_DEPT_ID
  ON mdm.epic_department_id = r.REFD_TO_DEPT_ID
  --WHERE (r.ENTRY_DATE BETWEEN '1/1/2020' and '12/31/2020')
  WHERE (r.ENTRY_DATE BETWEEN '7/1/2021' and '6/30/2022')
 --   AND (r.REFD_TO_DEPT_ID IN (@dept))
	--AND d1.DEPARTMENT_NAME IS NOT null
  --AND r.REFD_TO_SPEC_C IN (98,129,153)
  AND MDM.service_line = 'Oncology'
  --AND prc.PROC_ID IN (111,371,41033,85984,112455,112461,143437,177126)
  ORDER BY d1.EXTERNAL_NAME, RFRL_CLASS_NME, r.ENTRY_DATE