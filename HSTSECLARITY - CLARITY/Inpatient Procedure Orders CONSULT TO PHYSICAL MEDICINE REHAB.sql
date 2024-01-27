USE CLARITY

SELECT op.ORDER_PROC_ID
	 , op.PAT_ID
	 , op.PAT_ENC_CSN_ID
	 , dep.DEPARTMENT_NAME
	 , dephsp.DEPARTMENT_NAME AS DEPARTMENT_NAME_HSP
	 , zc.NAME[ORDER_STATUS]
	 , op.ORDERING_DATE
	 , op.ORDER_INST[ORDER_INSTANTIATED]
	 , ORD_AUDIT.AUDIT_TRL_TIME[ORDER_COMPLETE_DTTM]
	 , op.FUTURE_OR_STAND
	 , op.ORDER_TYPE_C
	 , op.PROC_ID
	 , op.DESCRIPTION
	 , op.ORDER_CLASS_C
	 , op.AUTHRZING_PROV_ID -- who wrote the order 
	 ,ser.PROV_NAME

FROM      CLARITY..ORDER_PROC		op
LEFT JOIN CLARITY..CLARITY_SER		ser		ON op.AUTHRZING_PROV_ID = ser.PROV_ID 
LEFT JOIN CLARITY..ZC_ORDER_STATUS	zc		ON zc.ORDER_STATUS_C = op.ORDER_STATUS_C
LEFT JOIN ( SELECT  OAT.ORDER_ID -- look for the FIRST TIME the ORDER is complete as there can be addendums
				   ,MIN(OAT.AUDIT_TRL_TIME)[AUDIT_TRL_TIME]
			FROM CLARITY..ORDER_AUDIT_TRL OAT
			WHERE AUDIT_TRL_ACTION_C = 7 -- Completed
			GROUP BY OAT.ORDER_ID
			)ORD_AUDIT ON OP.ORDER_PROC_ID = ORD_AUDIT.ORDER_ID
LEFT OUTER JOIN dbo.PAT_ENC ordenc ON ordenc.PAT_ENC_CSN_ID = op.PAT_ENC_CSN_ID
LEFT OUTER JOIN dbo.PAT_ENC_HSP ordenchsp ON ordencHSP.PAT_ENC_CSN_ID = op.PAT_ENC_CSN_ID
LEFT JOIN dbo.CLARITY_DEP dep ON ordenc.DEPARTMENT_ID = dep.DEPARTMENT_ID
LEFT JOIN dbo.CLARITY_DEP dephsp ON ordenchsp.DEPARTMENT_ID = dephsp.DEPARTMENT_ID
--WHERE	op.PAT_ID = 'Z324387'
--		AND op.ORDERING_DATE BETWEEN '5/1/2022' AND '6/30/2022'
--		AND op.PROC_ID = 351 --CONSULT TO PHYSICAL MEDICINE REHAB
--		AND op.ORDER_TYPE_C = 12 -- consult orders
--		AND op.ORDER_CLASS_C = 22 -- hospital performed
--		AND op.ORDER_STATUS_C <> 4 -- Not Canceled
WHERE	op.ORDERING_DATE BETWEEN '6/1/2022' AND '6/30/2022'
		AND op.PROC_ID = 351 --CONSULT TO PHYSICAL MEDICINE REHAB
		AND op.ORDER_TYPE_C = 12 -- consult orders
		AND op.ORDER_CLASS_C = 22 -- hospital performed
		AND op.ORDER_STATUS_C <> 4 -- Not Canceled
		AND op.FUTURE_OR_STAND = 'S'

--ORDER BY op.PAT_ID, op.ORDER_PROC_ID, op.DESCRIPTION

ORDER BY
            op.DESCRIPTION
        ,   COALESCE(dep.DEPARTMENT_NAME, dephsp.DEPARTMENT_NAME, NULL)
        ,   ser.PROV_NAME
	    ,   op.ORDERING_DATE
		,   op.ORDER_TIME
		,   op.PAT_ENC_CSN_ID