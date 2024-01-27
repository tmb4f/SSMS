USE DS_HSDW_Prod;
GO

DECLARE @Begin_Svc_Date AS INT;
DECLARE @End_Svc_Date AS INT;
SET @Begin_Svc_Date = 20210501;
SET @End_Svc_Date = 20210531;

SELECT  txx.TX_ID
      , tx.sk_Pst_Dte
      , tx.sk_Svc_Dte
      , prv.IDNumber                                                            AS Prov_ID
      , prv.DisplayName                                                         AS Provider_Name
      , tx.AcctNbr_int                                                          AS HAR
      , txm.Department_ID                                                       AS Epic_Dept
      , cdep.Clrt_DEPt_Nme                                                      AS Epic_Department
      , eap.PROC_CODE                                                           AS Epic_Proc_Cd
      , eap.PROC_NAME                                                           AS Epic_Proc
      , dtl.dtl_grp                                                             AS TRANS_TP
      , tx.Tx_Dscr                                                              AS Charge_Description
      , CASE WHEN cpt.sk_Dim_CPT < 1 THEN '' ELSE COALESCE(cpt.CPT_Cde, '') END AS CPT
      , tx.Tx_Amt
      , tx.Tx_Qty
FROM    Rptg.vwFact_Pt_Tx                     AS tx
INNER JOIN Rptg.vwFact_Pt_Tx_Clrt_Ext_Chg     AS txx
    ON  txx.sk_Fact_Pt_Tx = tx.sk_Fact_Pt_Tx
    AND txx.FY = tx.FY -- FACT TABLE data is partitioned by FY, performance GREATLY improved
INNER JOIN Rptg.vwDim_Clrt_TransactionMap     AS txm
    ON txm.sk_Dim_Clrt_TransactionMap = tx.sk_Dim_Clrt_TransactionMap
INNER JOIN Rptg.vwDim_Clrt_EAPrcdr            AS eap
    ON eap.sk_Dim_Clrt_EAPrcdr = txm.sk_Dim_Clrt_EAPrcdr
INNER JOIN Rptg.vwDim_Dtl_Typ_Ind             AS dtl
    ON dtl.sk_Dim_Dtl_Typ_Ind = tx.sk_Dim_Dtl_Typ_Ind
INNER JOIN Rptg.vwFact_Pt_Acct_Aggr           AS aggr
    ON  tx.sk_Fact_Pt_Acct = aggr.sk_Fact_Pt_Acct
    AND tx.FY = aggr.FY -- FACT TABLE data is partitioned by FY, performance GREATLY improved
INNER JOIN Rptg.vwDim_Physcn                  AS prv
    ON prv.sk_Dim_Physcn = txx.sk_Dim_Physcn
INNER JOIN Rptg.vwDim_MedicalCenterDepartment AS mcdep
    ON mcdep.sk_Dim_MedicalCenterDepartment = tx.sk_Dim_Med_Cntr_Dept
INNER JOIN Rptg.vwDim_Clrt_EAPrcdr            AS prc
    ON prc.sk_Dim_Clrt_EAPrcdr = txm.sk_Dim_Clrt_EAPrcdr
INNER JOIN Rptg.vwDim_Clrt_DEPt               AS cdep
    ON cdep.sk_Dim_Clrt_DEPt = txm.sk_Dim_Clrt_DEPt
INNER JOIN Rptg.vwDim_CPT                     AS cpt
    ON txx.sk_Dim_CPT = cpt.sk_Dim_CPT
INNER JOIN Rptg.vwFact_Pt_Acct                AS acct
    ON  aggr.sk_Fact_Pt_Acct = acct.sk_Fact_Pt_Acct
    AND aggr.FY = acct.FY -- FACT TABLE data is partitioned by FY, performance GREATLY improved
INNER JOIN Rptg.vwDim_Pt_Acct_Typ             AS parm_ptp
    ON parm_ptp.sk_Dim_Pt_Acct_Typ = aggr.sk_Dim_Pt_Acct_Typ
WHERE   1 = 1
AND     tx.FY = 2021 -- FACT TABLE data is partitioned by FY, performance GREATLY improved
AND     tx.sk_Svc_Dte >= @Begin_Svc_Date
AND     tx.sk_Svc_Dte <= @End_Svc_Date
AND     aggr.PtAcctg_Typ = 'OP' -- outpatients
AND     (aggr.tot_chg_amt > 0 OR aggr.NoCharge_Baby = 1) -- is a real, used account
AND     aggr.Load_Src >= 5 -- Epic account

-- little test
AND     tx.AcctNbr_int = 13009022542;


