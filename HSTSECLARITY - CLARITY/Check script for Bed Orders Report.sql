USE CLARITY
SELECT DISTINCT  eap.PROC_CODE, eap.PROC_NAME, ord.ORDER_PROC_ID, ord.ORDERING_DATE, ord.ORDER_INST, ord.INSTANTIATED_TIME, hsp.HOSP_DISCH_TIME AS DISCHARGED, emp.NAME AS ORDER_ENTERED_BY, ord.DISPLAY_NAME AS ORDER_DESCRIPTION, 
                  dep.EXTERNAL_NAME AS DEPARTMENT, bed.BED_LABEL, CASE WHEN cmnt1.ORDERING_COMMENT IS NULL THEN '' ELSE CONCAT(cmnt1.ORDERING_COMMENT, ';', cmnt2.ORDERING_COMMENT) 
                  END AS ORDERING_COMMENT,
				  --oqr.ORD_QUEST_RESP AS CRITERIA, att.ORD_QUEST_RESP AS ATTESTATION,
				  DATEDIFF(dd, ord.ORDERING_DATE, COALESCE (hsp.HOSP_DISCH_TIME, oedt.ORD_LST_ED_INST_TM)) AS THERAPY_DURATION_DAYS, 
                  oedt.ORD_LST_ED_INST_TM AS DISCONTINUED, CASE WHEN oedt.ORD_LST_ED_INST_TM IS NOT NULL AND (canc.NAME IS NULL OR
                  canc.NAME NOT LIKE 'Auto%') THEN COALESCE (emp2.NAME, ' ') ELSE ' ' END AS DISCONTINUED_BY, CASE WHEN oedt.ORD_LST_ED_INST_TM IS NULL THEN ' ' ELSE COALESCE (canc.NAME, '(None)') END AS CANCEL_REASON
FROM        ORDER_PROC AS ord INNER JOIN
                  CLARITY_EAP AS eap ON eap.PROC_ID = ord.PROC_ID INNER JOIN
                  PAT_ENC_HSP AS hsp ON hsp.PAT_ENC_CSN_ID = ord.PAT_ENC_CSN_ID INNER JOIN
                  ZC_PAT_CLASS AS cls ON cls.ADT_PAT_CLASS_C = hsp.ADT_PAT_CLASS_C INNER JOIN
                  PATIENT AS pt ON pt.PAT_ID = hsp.PAT_ID INNER JOIN
                  IDENTITY_ID AS idx ON idx.PAT_ID = hsp.PAT_ID INNER JOIN
                  CLARITY_BED AS bed ON bed.BED_ID = hsp.BED_ID INNER JOIN
                  CLARITY_DEP AS dep ON dep.DEPARTMENT_ID = hsp.DEPARTMENT_ID
				  --INNER JOIN  CLARITY_App.MDM_REV_LOC_ID AS mloc ON mloc.REV_LOC_ID = dep.REV_LOC_ID
				  INNER JOIN
                  ORDER_PROC_2 AS ord2 ON ord2.ORDER_PROC_ID = ord.ORDER_PROC_ID INNER JOIN
                  CLARITY_EMP AS emp ON emp.USER_ID = ord.ORD_CREATR_USER_ID LEFT OUTER JOIN
                  ORDER_LAST_EDIT AS oedt ON oedt.ORDER_ID = ord.ORDER_PROC_ID AND oedt.ORD_LST_ED_ACTION_C = 4 LEFT OUTER JOIN
                  CLARITY_EMP AS emp2 ON emp2.USER_ID = oedt.ORD_LST_ED_USER_ID LEFT OUTER JOIN
                      (SELECT     ORDER_ID, LINE, CM_PHY_OWNER_ID, CM_LOG_OWNER_ID, ORDERING_COMMENT
                       FROM        ORDER_COMMENT
                       WHERE     (LINE = '1') AND (ORDERING_COMMENT IS NOT NULL)) AS cmnt1 ON cmnt1.ORDER_ID = ord.ORDER_PROC_ID LEFT OUTER JOIN
                      (SELECT     ORDER_ID, LINE, CM_PHY_OWNER_ID, CM_LOG_OWNER_ID, ORDERING_COMMENT
                       FROM        ORDER_COMMENT AS ORDER_COMMENT_1
                       WHERE     (LINE = '2')) AS cmnt2 ON cmnt2.ORDER_ID = ord.ORDER_PROC_ID LEFT OUTER JOIN
                  PAT_ENC AS enc ON enc.PAT_ENC_CSN_ID = ord.PAT_ENC_CSN_ID LEFT OUTER JOIN
                  ZC_REASON_FOR_CANC AS canc ON canc.REASON_FOR_CANC_C = ord.REASON_FOR_CANC_C
				  --LEFT OUTER JOIN
      --                (SELECT     osq.ORDER_ID, osq.ORD_QUEST_RESP
      --                 FROM        ORD_SPEC_QUEST AS osq INNER JOIN
      --                                   CL_QQUEST AS cq ON osq.ORD_QUEST_ID = cq.QUEST_ID
      --                 --WHERE     (cq.QUEST_ID IN ('107097', '107098', '107101', '107102'))
					 --  ) AS oqr
					 --  ON ord.ORDER_PROC_ID = oqr.ORDER_ID
					 --  LEFT OUTER JOIN
      --                (SELECT     osq.ORDER_ID, osq.ORD_QUEST_RESP
      --                 FROM        ORD_SPEC_QUEST AS osq INNER JOIN
      --                                   CL_QQUEST AS cq ON osq.ORD_QUEST_ID = cq.QUEST_ID
      --                 --WHERE     (cq.QUEST_ID IN ('107099', '107100'))
					 --  ) AS att
					 --  ON ord.ORDER_PROC_ID = att.ORDER_ID
WHERE     (1 = 1)
----AND (eap.PROC_CODE IN ('EQ150', 'EQ159', 'EQ158', 'EQ21', 'EQ12', 'EQ157', 'EQ14', 'EQ149', 'EQ162'))
--AND eap.PROC_CODE LIKE 'EQ%'
AND (eap.PROC_CODE LIKE 'EQ%'
	OR (ord.DISPLAY_NAME LIKE '%Envella%'
			OR ord.DISPLAY_NAME LIKE '%Compella%'
			OR ord.DISPLAY_NAME LIKE '%Standing%'
			OR ord.DISPLAY_NAME LIKE '%Versa%'
			OR ord.DISPLAY_NAME LIKE '%Posey%'
			))
/*envella, compella, standing bed , versa care and posey*/
AND (ord.INSTANTIATED_TIME IS NOT NULL)
AND (idx.IDENTITY_TYPE_ID = '14')
AND (ord.ORDERING_DATE >= '7/1/2023'
) AND (ord.ORDERING_DATE <= '10/17/2023')

ORDER BY eap.PROC_CODE, eap.PROC_NAME, ord.ORDERING_DATE