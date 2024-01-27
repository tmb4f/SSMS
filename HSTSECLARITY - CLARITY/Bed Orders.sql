USE CLARITY

SELECT DISTINCT
		pt.PAT_NAME
		,idx.IDENTITY_ID 'MRN'
		,ord.ORDERING_DATE
		,ord.DISPLAY_NAME
		,dep.EXTERNAL_NAME
		,bed.BED_LABEL
		,eap.PROC_CODE
		,eap.PROC_NAME
		,(enc.WEIGHT/16) 'WEIGHT LB'
		,enc.HEIGHT
		,CASE WHEN cmnt1.ORDERING_COMMENT IS NULL 
				THEN ''
				ELSE CONCAT(cmnt1.ORDERING_COMMENT,';',cmnt2.ORDERING_COMMENT) 
				END 																'ORDERING_COMMENT'
	
 FROM CLARITY.dbo.ORDER_PROC ord
 INNER JOIN CLARITY.dbo.CLARITY_EAP eap				ON eap.PROC_ID = ord.PROC_ID
 INNER JOIN CLARITY.dbo.PAT_ENC_HSP hsp				ON hsp.PAT_ENC_CSN_ID = ord.PAT_ENC_CSN_ID
 INNER JOIN CLARITY.dbo.PATIENT pt					ON pt.PAT_ID = hsp.PAT_ID
 INNER JOIN CLARITY.dbo.IDENTITY_ID idx				ON idx.PAT_ID = hsp.PAT_ID
 INNER JOIN CLARITY.dbo.CLARITY_BED bed				ON bed.BED_ID = hsp.BED_ID
 INNER JOIN CLARITY.dbo.CLARITY_DEP dep				ON dep.DEPARTMENT_ID = hsp.DEPARTMENT_ID
 INNER JOIN CLARITY.dbo.ORDER_PROC_2 ord2			ON ord2.ORDER_PROC_ID = ord.ORDER_PROC_ID

 LEFT OUTER JOIN (SELECT *
					FROM CLARITY.dbo.ORDER_COMMENT
					WHERE LINE='1'
					AND ORDERING_COMMENT IS NOT NULL) cmnt1		ON cmnt1.ORDER_ID=ord.ORDER_PROC_ID
LEFT OUTER JOIN (SELECT *
					FROM CLARITY.dbo.ORDER_COMMENT
					WHERE LINE='2') cmnt2		ON cmnt2.ORDER_ID=ord.ORDER_PROC_ID


LEFT OUTER JOIN CLARITY.dbo.PAT_ENC enc			ON enc.PAT_ENC_CSN_ID =ord.PAT_ENC_CSN_ID


 WHERE 1=1
 AND eap.PROC_CODE IN ('EQ150','EQ159','EQ158','EQ21','EQ12','EQ157','EQ14','EQ149')
 AND hsp.ADT_PAT_CLASS_C='101' --Inpatient
 AND idx.IDENTITY_TYPE_ID='14'
 AND ord.ORDERING_DATE>=@p_SlotStart
 AND ord.ORDERING_DATE<=@p_SlotEnd