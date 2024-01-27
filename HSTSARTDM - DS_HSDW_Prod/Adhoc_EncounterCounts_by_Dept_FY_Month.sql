-- HSTSARTDM 
USE DS_HSDW_Prod

;WITH cte_PS_Codes AS 
(SELECT DISTINCT mdm.EPIC_DEPARTMENT_ID, mdm.FINANCE_COST_CODE FROM Rptg.vwRef_MDM_Location_Master mdm )


SELECT dte.Fyear_num, dte.fmonth_num, dep.DEPARTMENT_ID, dep.Clrt_DEPt_Nme, mdm.FINANCE_COST_CODE, dte.date_key, COUNT(DISTINCT adt.PAT_ENC_CSN_ID) ENC_CNT, CONVERT(VARCHAR(10), GETDATE(),112) AsofDate
FROM  Rptg.vwDim_Date dte
INNER JOIN Rptg.vwFact_Clrt_ADT_Census adt
ON dte.date_key BETWEEN adt.sk_ADT_In_Dte AND adt.sk_ADT_Out_Dte
INNER JOIN Rptg.vwDim_Clrt_DEPt dep
ON dep.sk_Dim_Clrt_DEPt = adt.sk_Dim_Clrt_DEPt
INNER JOIN  cte_PS_Codes mdm
ON dep.DEPARTMENT_ID = mdm.epic_department_id

WHERE 1=1
AND dte.Fyear_num > 2017
AND adt.PAT_ENC_CSN_ID = 21926376
GROUP BY dte.Fyear_num, dte.fmonth_num, dep.DEPARTMENT_ID, dep.Clrt_DEPt_Nme, mdm.FINANCE_COST_CODE, dte.date_key
ORDER BY dte.Fyear_num DESC, dte.fmonth_num, dte.date_key


