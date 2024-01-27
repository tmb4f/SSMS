USE [DS_HSDM_Prod]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--ALTER PROCEDURE [ETL].[usp_HSDO_UVa_Pt_Encounters]

--AS
/*******************************************************************************************
WHAT: Clinician patient encounter table input for Grateful Patient Program.
WHO : Tom Burgan
WHEN: 5/19/2015

WHY :
--------------------------------------------------------------------------------------------
INFO:
INPUTS:
        DS_HSDW_Prod.dbo.Fact_Pt_Acct
        DS_HSDW_Prod.dbo.Dim_Physcn
        DS_HSDW_Prod.dbo.Dim_Pt
        DS_HSDW_Prod.dbo.Fact_Pt_Acct_Aggr
        DS_HSDW_Prod.dbo.Dim_Date
        DS_HSDW_Prod.dbo.Dim_Demographics
        DS_HSDW_Prod.dbo.Fact_Pt_Dx
        DS_HSDW_Prod.dbo.Dim_Dx
        DS_HSDW_Prod.dbo.Fact_Pt_Acct_Prmrys
        DS_HSDW_Prod.dbo.Dim_Billg_Fin_Cls
        DS_HSDW_Prod.dbo.Dim_Disch_Disp_Invision
        DS_HSDW_Prod.dbo.Dim_Hsptl_Svc
        DS_HSDW_Prod.Rptg.vwFact_Pt_Insrnc_Flattened
	
OUTPUTS:
		 ETL.usp_HSDO_UVa_Pt_Encounters
--------------------------------------------------------------------------------------------
MODS:
  5/19/2015 - New Build
  6/03/2015 - Implemented temporary table logic
  6/04/2015 - Restore table variables
************************************************************************************/
--
SET NOCOUNT ON

BEGIN

DECLARE @Acct TABLE (
	Acct_Num BIGINT PRIMARY KEY
  , Atn_Dr INT
  , Med_Rec INT
  , Id SMALLINT
  , Adm_Date INT
  , Adm_Dt SMALLDATETIME
  , Dis_Date INT
  , Dis_Dt SMALLDATETIME
  , Sex CHAR(1)
  , Age SMALLINT
  , sk_Dim_Pt INT
  , Pay_Scale CHAR(1)
  , PtAcctg_Typ VARCHAR(3)
  , sk_Dim_Disch_Disp_Inv SMALLINT
  , sk_Dsch_Dte INT
  , sk_Phys_Atn INT
  , sk_Phys_Adm INT
  , sk_Fact_Pt_Acct INT
  , sk_Dim_Billg_Fin_Cls SMALLINT
  , sk_Adm_Hsptl_Svc SMALLINT
  , sk_Dim_Hsptl_Svc SMALLINT
  , Atn_Dr_LName VARCHAR(30)
  , Atn_Dr_FName VARCHAR(25)
  , Atn_Dr_MI VARCHAR(12)
  , Atn_Dr_Type VARCHAR(30)
  , Atn_Dr_Status VARCHAR(25)
  , Atn_Dr_Last_Update_Dt DATETIME
);

DECLARE @Dx TABLE (
	Acct_Num BIGINT
  , Age SMALLINT
  , Dx_Prio_Nbr SMALLINT
  , Dx_Clasf_cde CHAR(2)
  , D_Dx VARCHAR(20)
  , Dx VARCHAR(255)
  , D_Dx_Grp VARCHAR(15)
  , Dx_Grp VARCHAR(80)
  , Excluded_Adult_Child_DX SMALLINT
  , Excluded_Child_DX SMALLINT
  , UNIQUE CLUSTERED (Acct_Num, Dx_Clasf_cde, D_Dx, Dx_Prio_Nbr)
);

DECLARE @Excluded_Dx_Aggr TABLE (
	Acct_Num BIGINT
  , Excluded_DX_Count SMALLINT
  , UNIQUE CLUSTERED (Acct_Num)
);

DECLARE @Acct2 TABLE (
	Acct_Num BIGINT
  , Atn_Dr INT
  , Med_Rec INT
  , Id SMALLINT
  , Adm_Date INT
  , Adm_Dt SMALLDATETIME
  , Dis_Date INT
  , Dis_Dt SMALLDATETIME
  , Sex CHAR(1)
  , Age SMALLINT
  , sk_Dim_Pt INT
  , Pay_Scale CHAR(1)
  , PtAcctg_Typ VARCHAR(3)
  , sk_Dim_Disch_Disp_Inv SMALLINT
  , sk_Dsch_Dte INT
  , sk_Phys_Atn INT
  , sk_Phys_Adm INT
  , sk_Fact_Pt_Acct INT PRIMARY KEY
  , sk_Dim_Billg_Fin_Cls SMALLINT
  , sk_Adm_Hsptl_Svc SMALLINT
  , sk_Dim_Hsptl_Svc SMALLINT
  , Atn_Dr_LName VARCHAR(30)
  , Atn_Dr_FName VARCHAR(25)
  , Atn_Dr_MI VARCHAR(12)
  , Atn_Dr_Type VARCHAR(30)
  , Atn_Dr_Status VARCHAR(25)
  , Atn_Dr_Last_Update_Dt DATETIME
);

DECLARE @Acct3 TABLE (
	Acct_Num BIGINT
  , Atn_Dr INT
  , Med_Rec INT
  , Id SMALLINT
  , Adm_Date INT
  , Adm_Dt SMALLDATETIME
  , Dis_Date INT
  , Dis_Dt SMALLDATETIME
  , Sex CHAR(1)
  , Age SMALLINT
  , sk_Dim_Pt INT
  , Pay_Scale CHAR(1)
  , PtAcctg_Typ VARCHAR(3)
  , P_Dx VARCHAR(20)
  , Dx_Primary VARCHAR(255)
  , P_Dx_Grp VARCHAR(15)
  , Dx_Primary_Grp VARCHAR(80)
  , sk_Dim_Disch_Disp_Inv SMALLINT
  , sk_Dsch_Dte INT
  , sk_Phys_Atn INT
  , sk_Phys_Adm INT
  , sk_Fact_Pt_Acct INT PRIMARY KEY
  , sk_Dim_Billg_Fin_Cls SMALLINT
  , sk_Adm_Hsptl_Svc SMALLINT
  , sk_Dim_Hsptl_Svc SMALLINT
  , Atn_Dr_LName VARCHAR(30)
  , Atn_Dr_FName VARCHAR(25)
  , Atn_Dr_MI VARCHAR(12)
  , Atn_Dr_Type VARCHAR(30)
  , Atn_Dr_Status VARCHAR(25)
  , Atn_Dr_Last_Update_Dt DATETIME
);

DECLARE @Dx2 TABLE (
	Atn_Dr INT
  , Med_Rec INT
  , Id SMALLINT
  , Adm_Date INT
  , Adm_Dt SMALLDATETIME
  , Dis_Date INT
  , Dis_Dt SMALLDATETIME
  --, Seq_Nbr INT
  , Acct_Num BIGINT
  , Dx_Prio_Nbr SMALLINT
  , Dx_Clasf_cde CHAR(2)
  , D_Dx VARCHAR(20)
  , Dx VARCHAR(255)
  , D_Dx_Grp VARCHAR(15)
  , Dx_Grp VARCHAR(80)
  , P_Dx VARCHAR(20)
  , Dx_Primary VARCHAR(255)
  , P_Dx_Grp VARCHAR(15)
  , Dx_Primary_Grp VARCHAR(80)
  , Sex CHAR(1)
  , Age SMALLINT
  , sk_Dim_Pt INT
  , Pay_Scale CHAR(1)
  , PtAcctg_Typ VARCHAR(3)
  , sk_Dim_Disch_Disp_Inv SMALLINT
  , sk_Dsch_Dte INT
  , sk_Phys_Atn INT
  , sk_Phys_Adm INT
  , sk_Fact_Pt_Acct INT
  , sk_Dim_Billg_Fin_Cls SMALLINT
  , sk_Adm_Hsptl_Svc SMALLINT
  , sk_Dim_Hsptl_Svc SMALLINT
  , Atn_Dr_LName VARCHAR(30)
  , Atn_Dr_FName VARCHAR(25)
  , Atn_Dr_MI VARCHAR(12)
  , Atn_Dr_Type VARCHAR(30)
  , Atn_Dr_Status VARCHAR(25)
  , Atn_Dr_Last_Update_Dt DATETIME
  , UNIQUE CLUSTERED (Atn_Dr, Med_Rec, Id, Adm_Date, Acct_Num, Dx_Clasf_cde, D_Dx, Dx_Prio_Nbr)
);

DECLARE @ADx TABLE (
	Acct_Num BIGINT
  , A_Dx VARCHAR(20)
  , Dx_Admitting VARCHAR(80)
  , Seq_Nbr INT
  , UNIQUE CLUSTERED (Acct_Num, Seq_Nbr)
);

DECLARE @ADxUnique TABLE (
	Acct_Num BIGINT
  , A_Dx VARCHAR(20)
  , Dx_Admitting VARCHAR(80)
  , UNIQUE CLUSTERED (Acct_Num)
);

DECLARE @Dx3 TABLE (
	Atn_Dr INT
  , Med_Rec INT
  , Id SMALLINT
  , Adm_Date INT
  , Adm_Dt SMALLDATETIME
  , Dis_Date INT
  , Dis_Dt SMALLDATETIME
  --, Seq_Nbr INT
  , Acct_Num BIGINT
  , Dx_Prio_Nbr SMALLINT
  , Dx_Clasf_cde CHAR(2)
  , D_Dx VARCHAR(20)
  , Dx VARCHAR(255)
  , D_Dx_Grp VARCHAR(15)
  , Dx_Grp VARCHAR(80)
  , P_Dx VARCHAR(20)
  , Dx_Primary VARCHAR(255)
  , P_Dx_Grp VARCHAR(15)
  , Dx_Primary_Grp VARCHAR(80)
  , Sex CHAR(1)
  , Age SMALLINT
  , sk_Dim_Pt INT
  , Pay_Scale CHAR(1)
  , PtAcctg_Typ VARCHAR(3)
  , sk_Dim_Disch_Disp_Inv SMALLINT
  , sk_Dsch_Dte INT
  , sk_Phys_Atn INT
  , sk_Phys_Adm INT
  , sk_Fact_Pt_Acct INT
  , sk_Dim_Billg_Fin_Cls SMALLINT
  , sk_Adm_Hsptl_Svc SMALLINT
  , sk_Dim_Hsptl_Svc SMALLINT
  , Atn_Dr_LName VARCHAR(30)
  , Atn_Dr_FName VARCHAR(25)
  , Atn_Dr_MI VARCHAR(12)
  , Atn_Dr_Type VARCHAR(30)
  , Atn_Dr_Status VARCHAR(25)
  , Atn_Dr_Last_Update_Dt DATETIME
  , UNIQUE CLUSTERED (Atn_Dr, Med_Rec, Id, Adm_Date, Acct_Num, Dx_Clasf_cde, D_Dx, Dx_Prio_Nbr)
);

DECLARE @AcctSeq TABLE (
	Atn_Dr INT
  , Med_Rec INT
  , Id SMALLINT
  , Adm_Date INT
  , Adm_Dt SMALLDATETIME
  , Dis_Date INT
  , Dis_Dt SMALLDATETIME
  , Seq_Nbr INT
  , Acct_Num BIGINT
  , D_Dx VARCHAR(20)
  , Dx_Primary VARCHAR(255)
  , D_Dx_Grp VARCHAR(15)
  , Dx_Primary_Grp VARCHAR(80)
  , A_Dx VARCHAR(20)
  , Dx_Admitting VARCHAR(255) 
  , Sex CHAR(1)
  , Age SMALLINT
  , sk_Dim_Pt INT
  , Pay_Scale CHAR(1)
  , PtAcctg_Typ VARCHAR(3)
  , sk_Dim_Disch_Disp_Inv SMALLINT
  , sk_Dsch_Dte INT
  , sk_Phys_Atn INT
  , sk_Phys_Adm INT
  , sk_Fact_Pt_Acct INT
  , sk_Dim_Billg_Fin_Cls SMALLINT
  , sk_Adm_Hsptl_Svc SMALLINT
  , sk_Dim_Hsptl_Svc SMALLINT
  , Atn_Dr_LName VARCHAR(30)
  , Atn_Dr_FName VARCHAR(25)
  , Atn_Dr_MI VARCHAR(12)
  , Atn_Dr_Type VARCHAR(30)
  , Atn_Dr_Status VARCHAR(25)
  , Atn_Dr_Last_Update_Dt DATETIME
  , PRIMARY KEY NONCLUSTERED (Atn_Dr, Med_Rec, Seq_Nbr, Acct_Num)
);
 
DECLARE @AcctLatest TABLE (
	Atn_Dr INT
  , Med_Rec INT
  , Id SMALLINT
  , Adm_Date INT
  , Adm_Dt SMALLDATETIME
  , Dis_Date INT
  , Dis_Dt SMALLDATETIME
  , Acct_Num BIGINT
  , D_Dx VARCHAR(20)
  , Dx_Primary VARCHAR(255)
  , D_Dx_Grp VARCHAR(15)
  , Dx_Primary_Grp VARCHAR(80)
  , A_Dx VARCHAR(20)
  , Dx_Admitting VARCHAR(255) 
  , Sex CHAR(1)
  , Age SMALLINT
  , sk_Dim_Pt INT
  , Pay_Scale CHAR(1)
  , PtAcctg_Typ VARCHAR(3)
  , sk_Dim_Disch_Disp_Inv SMALLINT
  , sk_Dsch_Dte INT
  , sk_Phys_Atn INT
  , sk_Phys_Adm INT
  , sk_Fact_Pt_Acct INT
  , sk_Dim_Billg_Fin_Cls SMALLINT
  , sk_Adm_Hsptl_Svc SMALLINT
  , sk_Dim_Hsptl_Svc SMALLINT
  , Atn_Dr_LName VARCHAR(30)
  , Atn_Dr_FName VARCHAR(25)
  , Atn_Dr_MI VARCHAR(12)
  , Atn_Dr_Type VARCHAR(30)
  , Atn_Dr_Status VARCHAR(25)
  , Atn_Dr_Last_Update_Dt DATETIME
  , PRIMARY KEY NONCLUSTERED (sk_Dsch_Dte, sk_Fact_Pt_Acct)
);

INSERT INTO @Acct
        ( Acct_Num ,
          Atn_Dr ,
          Med_Rec ,
          Id ,
          Adm_Date ,
          Adm_Dt ,
          Dis_Date ,
          Dis_Dt ,
          Sex ,
          Age ,
          sk_Dim_Pt ,
          Pay_Scale ,
          PtAcctg_Typ ,
          sk_Dim_Disch_Disp_Inv ,
          sk_Dsch_Dte ,
          sk_Phys_Atn ,
          sk_Phys_Adm ,
          sk_Fact_Pt_Acct ,
          sk_Dim_Billg_Fin_Cls ,
          sk_Adm_Hsptl_Svc ,
          sk_Dim_Hsptl_Svc ,
          Atn_Dr_LName ,
          Atn_Dr_FName ,
          Atn_Dr_MI ,
          Atn_Dr_Type ,
          Atn_Dr_Status ,
          Atn_Dr_Last_Update_Dt
        )

SELECT
    acct.AcctNbr_int as Acct_Num
  , ddoc.IDNumber as Atn_Dr
  , pt.MED_REC as Med_Rec
  , CASE
      WHEN COALESCE(aggr.chg_REV_LAB,0) + COALESCE(aggr.chg_REV_PHAR,0) + COALESCE(aggr.chg_REV_RAD,0) = COALESCE(aggr.tot_chg_amt,0)
       THEN 2
       ELSE 1
    END AS Id
  , adt.date_key AS Adm_Date
  , adt.day_date AS Adm_Dt
  , ddt.date_key AS Dis_Date
  , ddt.day_date AS Dis_Dt
  , demog.gender_cde as Sex
  , demog.Age_Val AS Age
  , acct.sk_Dim_Pt
  , acct.Pay_Scale
  , acct.PtAcctg_Typ
  , acct.sk_Dim_Disch_Disp_Inv
  , acct.sk_Dsch_Dte
  , acct.sk_Phys_Atn
  , acct.sk_Phys_Adm
  , acct.sk_Fact_Pt_Acct
  , acct.sk_Dim_Billg_Fin_Cls
  , aggr.sk_Adm_Hsptl_Svc
  , aggr.sk_Dim_Hsptl_Svc
  , ddoc.LastName as Atn_Dr_LName
  , ddoc.FirstName as Atn_Dr_FName
  , ddoc.MI as Atn_Dr_MI
  , ddoc.ProviderType AS Atn_Dr_Type
  , ddoc.[Status] AS Atn_Dr_Status
  , CAST(ddoc.lastupdate AS DATETIME) AS Atn_Dr_Last_Update_Dt
FROM DS_HSDW_Prod.dbo.Fact_Pt_Acct as acct with (nolock) 
    
 left outer  join DS_HSDW_Prod.dbo.Dim_Physcn as ddoc with (nolock)
     on acct.sk_Phys_Atn = ddoc.sk_Dim_Physcn
    
 left outer join DS_HSDW_Prod.dbo.Dim_Pt as pt with (nolock)
     on acct.sk_Dim_Pt = pt.sk_Dim_Pt
    
 LEFT OUTER join DS_HSDW_Prod.dbo.Fact_Pt_Acct_Aggr as aggr with (nolock) 
    on aggr.sk_Fact_Pt_Acct = acct.sk_Fact_Pt_Acct
    
 left outer join DS_HSDW_Prod.dbo.Dim_Date as adt with (nolock)
    on adt.date_key = acct.sk_Adm_Dte 
 
 left outer join DS_HSDW_Prod.dbo.Dim_Demographics as demog with (nolock) 
    on demog.sk_dim_demog = acct.sk_Dim_Demog 
 
 inner join DS_HSDW_Prod.dbo.Dim_Date as ddt with (nolock)
    on ddt.date_key = acct.sk_Dsch_Dte
        
 WHERE (((acct.PtAcctg_Typ IN ('IP')) AND (ddt.day_date >= '1/1/2010 00:00 AM')) OR
        ((acct.PtAcctg_Typ IN ('OP','PPP','SSP')) AND (adt.day_date >= '1/1/2010 00:00 AM'))
 --WHERE (((acct.PtAcctg_Typ IN ('IP')) AND
 --       ((ddt.day_date >= '5/24/2015 00:00 AM') AND (ddt.day_date <= '5/30/2015 00:00 AM'))) OR
 --       ((acct.PtAcctg_Typ IN ('OP','PPP','SSP')) AND
 --       ((adt.day_date >= '5/24/2015 00:00 AM') AND (adt.day_date <= '5/30/2015 00:00 AM')))
       )
       AND (COALESCE(aggr.tot_chg_amt,0) > 0)
       AND ((ddoc.IDNumber > 0) AND (ddoc.current_flag = 1))
  
INSERT INTO @Dx
        ( Acct_Num ,
          Age ,
          Dx_Prio_Nbr ,
          Dx_Clasf_cde ,
          D_Dx ,
          Dx ,
          D_Dx_Grp ,
          Dx_Grp ,
          Excluded_Adult_Child_DX ,
          Excluded_Child_DX       
        )
SELECT
    acct.Acct_Num
  , acct.Age
  , adx.Dx_Prio_Nbr
  , adx.Dx_Clasf_cde
  , dx.Dx_Cde AS D_Dx
  , dx.Dx_Nme AS Dx
  , dx.Dx_Grp_Cde as D_Dx_Grp
  , dx.Dx_Grp_Nme as Dx_Grp
  , CASE
      WHEN ((dx.Dx_Cde BETWEEN '042' AND '044.9') OR
            (dx.Dx_Cde BETWEEN '054.10' AND '054.19') OR
            (dx.Dx_Cde = '078.1') OR
            (dx.Dx_Cde BETWEEN '079.51' AND '079.53') OR
            (dx.Dx_Cde BETWEEN '090.0' AND '099.9') OR
            (dx.Dx_Cde BETWEEN '279.10' AND '279.19') OR
            (dx.Dx_Cde BETWEEN '632' AND '639.99') OR
            (dx.Dx_Cde = '795.8') OR
            (dx.Dx_Cde = 'V08') OR
            (dx.Dx_Cde = 'V27.1') OR
            (dx.Dx_Cde = 'V27.3') OR
            (dx.Dx_Cde = 'V27.4') OR
            (dx.Dx_Cde = 'V27.6') OR
            (dx.Dx_Cde = 'V27.7'))
      THEN 1
      ELSE 0
    END
  , CASE
      WHEN ((dx.Dx_Cde BETWEEN '640.0' AND '676.94') OR
            (dx.Dx_Cde BETWEEN 'V22.0' AND 'V25.9'))
      THEN 1
      ELSE 0
    END
 FROM @Acct acct
 
 INNER JOIN DS_HSDW_Prod.dbo.Fact_Pt_Acct as fact with (nolock)
    ON fact.AcctNbr_int = acct.Acct_Num
        
 INNER JOIN DS_HSDW_Prod.dbo.Fact_Pt_Dx as adx with (nolock)
    on adx.sk_Fact_Pt_Acct = fact.sk_Fact_Pt_Acct AND adx.FY = fact.FY
    
 inner join DS_HSDW_Prod.dbo.Dim_Dx as dx with (nolock)
    on adx.sk_dim_dx = dx.sk_Dim_Dx
 
INSERT INTO @Excluded_Dx_Aggr
        ( Acct_Num ,
          Excluded_DX_Count
        )
SELECT
    dx.Acct_Num
  , SUM(CASE
          WHEN ((dx.Excluded_Adult_Child_DX = 1) OR
                ((dx.Excluded_Child_DX = 1) AND
                 (dx.Age <= 17)))
          THEN 1
          ELSE 0
        END) AS Excluded_DX_Count
 FROM @Dx dx
 
 GROUP BY dx.Acct_Num

INSERT INTO @Acct2
        ( Acct_Num ,
          Atn_Dr ,
          Med_Rec ,
          Id ,
          Adm_Date ,
          Adm_Dt ,
          Dis_Date ,
          Dis_Dt ,
          Sex ,
          Age ,
          sk_Dim_Pt ,
          Pay_Scale ,
          PtAcctg_Typ ,
          sk_Dim_Disch_Disp_Inv ,
          sk_Dsch_Dte ,
          sk_Phys_Atn ,
          sk_Phys_Adm ,
          sk_Fact_Pt_Acct ,
          sk_Dim_Billg_Fin_Cls ,
          sk_Adm_Hsptl_Svc ,
          sk_Dim_Hsptl_Svc ,
          Atn_Dr_LName ,
          Atn_Dr_FName ,
          Atn_Dr_MI ,
          Atn_Dr_Type ,
          Atn_Dr_Status ,
          Atn_Dr_Last_Update_Dt
        )
        
SELECT dx.Acct_Num
     , acct.Atn_Dr
     , acct.Med_Rec
     , acct.Id
     , acct.Adm_Date
     , acct.Adm_Dt
     , acct.Dis_Date
     , acct.Dis_Dt
     , acct.Sex
     , acct.Age
     , acct.sk_Dim_Pt
     , acct.Pay_Scale
     , acct.PtAcctg_Typ
     , acct.sk_Dim_Disch_Disp_Inv
     , acct.sk_Dsch_Dte
     , acct.sk_Phys_Atn
     , acct.sk_Phys_Adm
     , acct.sk_Fact_Pt_Acct
     , acct.sk_Dim_Billg_Fin_Cls
     , acct.sk_Adm_Hsptl_Svc
     , acct.sk_Dim_Hsptl_Svc
     , acct.Atn_Dr_LName
     , acct.Atn_Dr_FName
     , acct.Atn_Dr_MI
     , acct.Atn_Dr_Type
     , acct.Atn_Dr_Status
     , acct.Atn_Dr_Last_Update_Dt
FROM @Acct acct
INNER JOIN (SELECT Acct_Num 
            FROM @Excluded_Dx_Aggr
            WHERE Excluded_DX_Count = 0) dx
ON dx.Acct_Num = acct.Acct_Num

INSERT INTO @Acct3
        ( Acct_Num ,
          Atn_Dr ,
          Med_Rec ,
          Id ,
          Adm_Date ,
          Adm_Dt ,
          Dis_Date ,
          Dis_Dt ,
          Sex ,
          Age ,
          sk_Dim_Pt ,
          Pay_Scale ,
          PtAcctg_Typ ,
          P_Dx ,
          Dx_Primary ,
          P_Dx_Grp ,
          Dx_Primary_Grp ,
          sk_Dim_Disch_Disp_Inv ,
          sk_Dsch_Dte ,
          sk_Phys_Atn ,
          sk_Phys_Adm ,
          sk_Fact_Pt_Acct ,
          sk_Dim_Billg_Fin_Cls ,
          sk_Adm_Hsptl_Svc ,
          sk_Dim_Hsptl_Svc ,
          Atn_Dr_LName ,
          Atn_Dr_FName ,
          Atn_Dr_MI ,
          Atn_Dr_Type ,
          Atn_Dr_Status ,
          Atn_Dr_Last_Update_Dt
        )
SELECT
    acct.Acct_Num
  , acct.Atn_Dr
  , acct.Med_Rec
  , acct.Id
  , acct.Adm_Date
  , acct.Adm_Dt
  , acct.Dis_Date
  , acct.Dis_Dt
  , acct.Sex
  , acct.Age
  , acct.sk_Dim_Pt
  , acct.Pay_Scale
  , acct.PtAcctg_Typ
  , pdx.DX_Cde AS P_Dx
  , pdx.Dx_Nme AS Dx_Primary
  , pdx.Dx_Grp_Cde AS P_Dx_Grp
  , pdx.Dx_Grp_Nme AS Dx_Primary_Grp
  , acct.sk_Dim_Disch_Disp_Inv
  , acct.sk_Dsch_Dte
  , acct.sk_Phys_Atn
  , acct.sk_Phys_Adm
  , acct.sk_Fact_Pt_Acct
  , acct.sk_Dim_Billg_Fin_Cls
  , acct.sk_Adm_Hsptl_Svc
  , acct.sk_Dim_Hsptl_Svc
  , acct.Atn_Dr_LName
  , acct.Atn_Dr_FName
  , acct.Atn_Dr_MI
  , acct.Atn_Dr_Type
  , acct.Atn_Dr_Status
  , acct.Atn_Dr_Last_Update_Dt
FROM @Acct2 AS acct

 left outer join DS_HSDW_Prod.dbo.Fact_Pt_Acct_Prmrys as prmrys with (nolock)
	on acct.sk_Fact_Pt_Acct = prmrys.sk_Fact_Pt_Acct

 left outer join DS_HSDW_Prod.dbo.Dim_Dx as pdx with (nolock)
	on prmrys.sk_Prmry_Dx = pdx.sk_Dim_Dx

INSERT INTO @Dx2
        ( Atn_Dr ,
          Med_Rec ,
          Id ,
          Adm_Date ,
          Adm_Dt ,
          Dis_Date ,
          Dis_Dt ,
          Acct_Num ,
          Dx_Prio_Nbr ,
          Dx_Clasf_cde ,
          D_Dx ,
          Dx ,
          D_Dx_Grp ,
          Dx_Grp ,
          P_Dx ,
          Dx_Primary ,
          P_Dx_Grp ,
          Dx_Primary_Grp ,
          Sex ,
          Age ,
          sk_Dim_Pt ,
          Pay_Scale ,
          PtAcctg_Typ ,
          sk_Dim_Disch_Disp_Inv ,
          sk_Dsch_Dte ,
          sk_Phys_Atn ,
          sk_Phys_Adm ,
          sk_Fact_Pt_Acct ,
          sk_Dim_Billg_Fin_Cls ,
          sk_Adm_Hsptl_Svc ,
          sk_Dim_Hsptl_Svc ,
          Atn_Dr_LName ,
          Atn_Dr_FName ,
          Atn_Dr_MI ,
          Atn_Dr_Type ,
          Atn_Dr_Status ,
          Atn_Dr_Last_Update_Dt
        )
SELECT
    acct.Atn_Dr
  , acct.Med_Rec
  , acct.Id
  , acct.Adm_Date
  , acct.Adm_Dt
  , acct.Dis_Date
  , acct.Dis_Dt
  , acct.Acct_Num
  , dx.Dx_Prio_Nbr
  , dx.Dx_Clasf_cde
  , dx.D_Dx
  , dx.Dx
  , dx.D_Dx_Grp
  , dx.Dx_Grp
  , acct.P_Dx
  , acct.Dx_Primary
  , acct.P_Dx_Grp
  , acct.Dx_Primary_Grp
  , acct.Sex
  , acct.Age
  , acct.sk_Dim_Pt
  , acct.Pay_Scale
  , acct.PtAcctg_Typ
  , acct.sk_Dim_Disch_Disp_Inv
  , acct.sk_Dsch_Dte
  , acct.sk_Phys_Atn
  , acct.sk_Phys_Adm
  , acct.sk_Fact_Pt_Acct
  , acct.sk_Dim_Billg_Fin_Cls
  , acct.sk_Adm_Hsptl_Svc
  , acct.sk_Dim_Hsptl_Svc
  , acct.Atn_Dr_LName
  , acct.Atn_Dr_FName
  , acct.Atn_Dr_MI
  , acct.Atn_Dr_Type
  , acct.Atn_Dr_Status
  , acct.Atn_Dr_Last_Update_Dt
FROM @Acct3 AS acct
INNER JOIN @Dx dx
ON dx.Acct_Num = acct.Acct_Num

INSERT INTO @ADx
        ( Acct_Num ,
          A_Dx ,
          Dx_Admitting ,
          Seq_Nbr )
SELECT
    Acct_Num ,
    D_Dx ,
    Dx ,
    ROW_NUMBER() OVER (PARTITION BY Acct_Num ORDER BY Dx_Prio_Nbr) AS Seq_Nbr
FROM @Dx2
WHERE Dx_Clasf_cde = 'DA'

INSERT INTO @ADxUnique
        ( Acct_Num ,
          A_Dx ,
          Dx_Admitting )
SELECT
    Acct_Num ,
    A_Dx ,
    Dx_Admitting
FROM @ADx
WHERE Seq_Nbr = 1

INSERT INTO @Dx3
        ( Atn_Dr ,
          Med_Rec ,
          Id ,
          Adm_Date ,
          Adm_Dt ,
          Dis_Date ,
          Dis_Dt ,
          Acct_Num ,
          Dx_Prio_Nbr ,
          Dx_Clasf_cde ,
          D_Dx ,
          Dx ,
          D_Dx_Grp ,
          Dx_Grp ,
          P_Dx ,
          Dx_Primary ,
          P_Dx_Grp ,
          Dx_Primary_Grp ,
          Sex ,
          Age ,
          sk_Dim_Pt ,
          Pay_Scale ,
          PtAcctg_Typ ,
          sk_Dim_Disch_Disp_Inv ,
          sk_Dsch_Dte ,
          sk_Phys_Atn ,
          sk_Phys_Adm ,
          sk_Fact_Pt_Acct ,
          sk_Dim_Billg_Fin_Cls ,
          sk_Adm_Hsptl_Svc ,
          sk_Dim_Hsptl_Svc ,
          Atn_Dr_LName ,
          Atn_Dr_FName ,
          Atn_Dr_MI ,
          Atn_Dr_Type ,
          Atn_Dr_Status ,
          Atn_Dr_Last_Update_Dt
        )
SELECT
    dx.Atn_Dr
  , dx.Med_Rec
  , dx.Id
  , dx.Adm_Date
  , dx.Adm_Dt
  , dx.Dis_Date
  , dx.Dis_Dt
  , dx.Acct_Num
  , dx.Dx_Prio_Nbr
  , dx.Dx_Clasf_cde
  , dx.D_Dx
  , dx.Dx
  , dx.D_Dx_Grp
  , dx.Dx_Grp
  , dx.P_Dx
  , dx.Dx_Primary
  , dx.P_Dx_Grp
  , dx.Dx_Primary_Grp
  , dx.Sex
  , dx.Age
  , dx.sk_Dim_Pt
  , dx.Pay_Scale
  , dx.PtAcctg_Typ
  , dx.sk_Dim_Disch_Disp_Inv
  , dx.sk_Dsch_Dte
  , dx.sk_Phys_Atn
  , dx.sk_Phys_Adm
  , dx.sk_Fact_Pt_Acct
  , dx.sk_Dim_Billg_Fin_Cls
  , dx.sk_Adm_Hsptl_Svc
  , dx.sk_Dim_Hsptl_Svc
  , dx.Atn_Dr_LName
  , dx.Atn_Dr_FName
  , dx.Atn_Dr_MI
  , dx.Atn_Dr_Type
  , dx.Atn_Dr_Status
  , dx.Atn_Dr_Last_Update_Dt
FROM @Dx2 dx

WHERE ((dx.Dx_Clasf_cde = 'DF') AND
       (dx.D_Dx = dx.P_Dx))
     
INSERT INTO @AcctSeq
        ( Atn_Dr ,
          Med_Rec ,
          Id ,
          Adm_Date ,
          Adm_Dt ,
          Dis_Date ,
          Dis_Dt ,
          Seq_Nbr ,
          Acct_Num ,
          D_Dx ,
          Dx_Primary ,
          D_Dx_Grp ,
          Dx_Primary_Grp ,
          A_Dx ,
          Dx_Admitting ,
          Sex ,
          Age ,
          sk_Dim_Pt ,
          Pay_Scale ,
          PtAcctg_Typ ,
          sk_Dim_Disch_Disp_Inv ,
          sk_Dsch_Dte ,
          sk_Phys_Atn ,
          sk_Phys_Adm ,
          sk_Fact_Pt_Acct ,
          sk_Dim_Billg_Fin_Cls ,
          sk_Adm_Hsptl_Svc ,
          sk_Dim_Hsptl_Svc ,
          Atn_Dr_LName ,
          Atn_Dr_FName ,
          Atn_Dr_MI ,
          Atn_Dr_Type ,
          Atn_Dr_Status ,
          Atn_Dr_Last_Update_Dt
        )
SELECT
    Atn_Dr
  , Med_Rec
  , Id
  , Adm_Date
  , Adm_Dt
  , Dis_Date
  , Dis_Dt
  , ROW_NUMBER() OVER (PARTITION BY Atn_Dr, Med_Rec
                          ORDER BY Id
                                 , Adm_Date DESC
                                 , Dx_Prio_Nbr) AS Seq_Nbr
  , dx.Acct_Num
  , D_Dx
  , Dx_Primary
  , D_Dx_Grp
  , Dx_Primary_Grp
  , adx.A_Dx
  , adx.Dx_Admitting
  , Sex
  , Age
  , sk_Dim_Pt
  , Pay_Scale
  , PtAcctg_Typ
  , sk_Dim_Disch_Disp_Inv
  , sk_Dsch_Dte
  , sk_Phys_Atn
  , sk_Phys_Adm
  , sk_Fact_Pt_Acct
  , sk_Dim_Billg_Fin_Cls
  , sk_Adm_Hsptl_Svc
  , sk_Dim_Hsptl_Svc
  , Atn_Dr_LName
  , Atn_Dr_FName
  , Atn_Dr_MI
  , Atn_Dr_Type
  , Atn_Dr_Status
  , Atn_Dr_Last_Update_Dt
 FROM @Dx3 dx
 LEFT OUTER JOIN @ADxUnique adx
 ON adx.Acct_Num = dx.Acct_Num

INSERT INTO @AcctLatest
        ( Atn_Dr ,
          Med_Rec ,
          Id ,
          Adm_Date ,
          Adm_Dt ,
          Dis_Date ,
          Dis_Dt ,
          Acct_Num ,
          D_Dx ,
          Dx_Primary ,
          D_Dx_Grp ,
          Dx_Primary_Grp ,
          A_Dx ,
          Dx_Admitting ,
          Sex ,
          Age ,
          sk_Dim_Pt ,
          Pay_Scale ,
          PtAcctg_Typ ,
          sk_Dim_Disch_Disp_Inv ,
          sk_Dsch_Dte ,
          sk_Phys_Atn ,
          sk_Phys_Adm ,
          sk_Fact_Pt_Acct ,
          sk_Dim_Billg_Fin_Cls ,
          sk_Adm_Hsptl_Svc ,
          sk_Dim_Hsptl_Svc ,
          Atn_Dr_LName ,
          Atn_Dr_FName ,
          Atn_Dr_MI ,
          Atn_Dr_Type ,
          Atn_Dr_Status ,
          Atn_Dr_Last_Update_Dt
        )
SELECT
    Atn_Dr
  , Med_Rec
  , Id
  , Adm_Date
  , Adm_Dt
  , Dis_Date
  , Dis_Dt
  , Acct_Num
  , D_Dx
  , Dx_Primary
  , D_Dx_Grp
  , Dx_Primary_Grp
  , A_Dx
  , Dx_Admitting
  , Sex
  , Age
  , sk_Dim_Pt
  , Pay_Scale
  , PtAcctg_Typ
  , sk_Dim_Disch_Disp_Inv
  , sk_Dsch_Dte
  , sk_Phys_Atn
  , sk_Phys_Adm
  , sk_Fact_Pt_Acct
  , sk_Dim_Billg_Fin_Cls
  , sk_Adm_Hsptl_Svc
  , sk_Dim_Hsptl_Svc
  , Atn_Dr_LName
  , Atn_Dr_FName
  , Atn_Dr_MI
  , Atn_Dr_Type
  , Atn_Dr_Status
  , Atn_Dr_Last_Update_Dt
 FROM @AcctSeq
 WHERE Seq_Nbr = 1;
 
WITH GPP_UVa_CTE (
	Med_Rec
  , sk_Dim_Pt
  , Adm_Date
  , Adm_Dt
  , Dis_Date
  , Dis_Dt
  , Acct_Num
  , D_Dx
  , Dx_Primary
  , D_Dx_Grp
  , Dx_Primary_Grp
  , A_Dx
  , Dx_Admitting
  , Fin_Clas
  , Pay_Scale
  , Adm_Dr
  , Adm_Dr_FName
  , Adm_Dr_MI
  , Adm_Dr_LName
  , Atn_Dr
  , Atn_Dr_FName
  , Atn_Dr_MI
  , Atn_Dr_LName
  , Atn_Dr_Type
  , Atn_Dr_Status
  , Atn_Dr_Last_Update_Dt
  , IO_Flag 
  , Sex 
  , Birth_Dt
  , Age
  , Age_Group
  , Pt_FName_MI
  , Pt_LName
  , CURR_PT_ADDR1
  , CURR_PT_ADDR2
  , CURR_PT_CITY
  , CURR_PT_STATE
  , CURR_PT_ZIP
  , CURR_PT_PHONE
  , GUAR_FNAME
  , GUAR_MNAME
  , GUAR_LNAME
  , GUAR_ADDR1
  , GUAR_ADDR2
  , GUAR_CITY
  , GUAR_STATE
  , GUAR_ZIP
  , GUAR_PHONE
  , GUAR_TO_PT
  , PT_DEATH_IND
  , [Status]
  , Adm_Hosp_Svc
  , Hosp_Svc
  , Dis_Disp 
  , Ins_1
  , Ins_2
  , Ins_3
  , Ins_4
  , Anc_Flag
)
AS
(
SELECT
    acct.Med_Rec
  , acct.sk_Dim_Pt
  , acct.Adm_Date
  , acct.Adm_Dt
  , acct.Dis_Date
  , acct.Dis_Dt
  , acct.Acct_Num
  , acct.D_Dx
  , acct.Dx_Primary
  , acct.D_Dx_Grp
  , acct.Dx_Primary_Grp
  , acct.A_Dx
  , acct.Dx_Admitting
  , fc.Billg_Fin_Cls_Cde AS Fin_Clas
  , acct.Pay_Scale
  , adoc.IDNumber AS Adm_Dr
  , adoc.FirstName AS Adm_Dr_FName
  , adoc.MI AS Adm_Dr_MI
  , adoc.LastName AS Adm_Dr_LName
  , acct.Atn_Dr
  , acct.Atn_Dr_FName
  , acct.Atn_Dr_MI
  , acct.Atn_Dr_LName
  , acct.Atn_Dr_Type
  , acct.Atn_Dr_Status
  , acct.Atn_Dr_Last_Update_Dt
  , CASE
      WHEN acct.PtAcctg_Typ IN ('IP') THEN 'I'
      WHEN acct.PtAcctg_Typ IN ('OP','PPP','SSP') THEN 'O'
    END AS IO_Flag  
  , acct.Sex
  , pt.BIRTH_DT AS Birth_Dt
  , acct.Age
  , CASE
      WHEN acct.Age <= 17 THEN 'PED'
      ELSE 'ADULT'
    END AS Age_Group
  , pt.PT_FNAME_MI AS Pt_FName_MI
  , pt.PT_LNAME AS Pt_LName
  , pt.CURR_PT_ADDR1
  , pt.CURR_PT_ADDR2
  , pt.CURR_PT_CITY
  , pt.CURR_PT_STATE
  , pt.CURR_PT_ZIP
  , pt.CURR_PT_PHONE
  , pt.GUAR_FNAME
  , pt.GUAR_MNAME
  , pt.GUAR_LNAME
  , pt.GUAR_ADDR1
  , pt.GUAR_ADDR2
  , pt.GUAR_CITY
  , pt.GUAR_STATE
  , pt.GUAR_ZIP
  , pt.GUAR_PHONE
  , pt.GUAR_TO_PT
  , pt.PT_DEATH_IND
  , CASE
      WHEN SUBSTRING(ddisp.Disch_Disp_cde,1,1) IN ('D') THEN 'D'
      ELSE ''
    END AS Status
  , asvc.Hsptl_Svc_Cde AS Adm_Hosp_Svc
  , svc.Hsptl_Svc_Cde AS Hosp_Svc
  , ddisp.Disch_Disp_cde AS Dis_Disp 
  , ins.Ins1_Nme AS Ins_1
  , ins.Ins2_Nme AS Ins_2
  , ins.Ins3_Nme AS Ins_3
  , ins.Ins4_Nme AS Ins_4
  , CASE
      WHEN acct.Id = 2 THEN 'Y'
      ELSE 'N'
    END AS Anc_Flag
    
 FROM @AcctLatest acct
              
 LEFT OUTER JOIN DS_HSDW_Prod.dbo.Dim_Billg_Fin_Cls AS fc WITH (NOLOCK)
     ON fc.sk_Dim_Billg_Fin_Cls = acct.sk_Dim_Billg_Fin_Cls
    
 LEFT OUTER JOIN DS_HSDW_Prod.dbo.Dim_Physcn AS adoc WITH (NOLOCK)
     ON acct.sk_Phys_Adm = adoc.sk_Dim_Physcn 
    
 LEFT OUTER JOIN DS_HSDW_Prod.dbo.Dim_Pt AS pt WITH (NOLOCK)
     ON acct.sk_Dim_Pt = pt.sk_Dim_Pt
    
LEFT OUTER JOIN DS_HSDW_Prod.dbo.Dim_Disch_Disp_Invision AS ddisp WITH (NOLOCK) 
    ON ddisp.sk_Dim_Disch_Disp_Inv = acct.sk_Dim_Disch_Disp_Inv
     
 LEFT OUTER JOIN DS_HSDW_Prod.dbo.Dim_Hsptl_Svc AS asvc WITH (NOLOCK)
    ON acct.sk_Adm_Hsptl_Svc = asvc.sk_Dim_Hsptl_Svc
     
 LEFT OUTER JOIN DS_HSDW_Prod.dbo.Dim_Hsptl_Svc AS svc WITH (NOLOCK)
    ON acct.sk_Dim_Hsptl_Svc = svc.sk_Dim_Hsptl_Svc
     
 LEFT OUTER JOIN DS_HSDW_Prod.Rptg.vwFact_Pt_Insrnc_Flattened ins
	ON acct.sk_Fact_Pt_Acct = ins.sk_Fact_Pt_Acct
)



SELECT DISTINCT 
       cte.Med_Rec ,
       cte.sk_Dim_Pt ,
       cte.Adm_Date ,
       CAST(cte.Adm_Dt AS DATETIME) AS Adm_Dt ,
       cte.Dis_Date ,
       CAST(cte.Dis_Dt AS DATETIME) AS Dis_Dt ,
       cte.Acct_Num ,
       cte.D_Dx ,
       cte.DX_Primary ,
       cte.D_Dx_Grp ,
       cte.DX_Primary_Grp ,
       cte.A_Dx ,
       cte.DX_Admitting ,
       cte.Fin_Clas ,
       cte.Pay_Scale ,
       cte.Adm_Dr ,
       cte.Adm_Dr_FName ,
       cte.Adm_Dr_MI ,
       cte.Adm_Dr_LName ,
       cte.Atn_Dr ,
       cte.Atn_Dr_FName ,
       cte.Atn_Dr_MI ,
       cte.Atn_Dr_LName ,
       cte.Atn_Dr_Type ,
       cte.Atn_Dr_Status ,
       cte.Atn_Dr_Last_Update_Dt ,
       CAST(cte.IO_Flag AS CHAR(1)) AS IO_Flag ,
       cte.Sex ,
       cte.Birth_Dt ,
       cte.Age ,
       CAST(cte.Age_Group AS VARCHAR(5)) AS Age_Group ,
       cte.Pt_FName_MI ,
       cte.Pt_LName ,
       cte.CURR_PT_ADDR1 ,
       cte.CURR_PT_ADDR2 ,
       cte.CURR_PT_CITY ,
       cte.CURR_PT_STATE ,
       cte.CURR_PT_ZIP ,
       cte.CURR_PT_PHONE ,
       cte.GUAR_FNAME ,
       cte.GUAR_MNAME ,
       cte.GUAR_LNAME ,
       cte.GUAR_ADDR1 ,
       cte.GUAR_ADDR2 ,
       cte.GUAR_CITY ,
       cte.GUAR_STATE ,
       cte.GUAR_ZIP ,
       cte.GUAR_PHONE ,
       cte.GUAR_TO_PT ,
       cte.PT_DEATH_IND ,
       CAST(cte.[Status] AS CHAR(1)) AS [Status] ,
       cte.Adm_Hosp_Svc ,
       cte.Hosp_Svc ,
       cte.Dis_Disp ,
       cte.Ins_1 ,
       cte.Ins_2 ,
       cte.Ins_3 ,
       cte.Ins_4 ,
       cte.Anc_Flag
     , CASE
         WHEN (cte.Pay_Scale IN ('1','2','3','4','5'))
           THEN 'Y'
           ELSE 'N'
       END AS Excluded_Payscale
     , CASE
         WHEN (cte.Fin_Clas IN ('K','0','1','2','3','4','5','6','7','8','9'))
           THEN 'Y'
           ELSE 'N'
       END AS Excluded_Financial_Class
FROM GPP_UVa_CTE cte
ORDER BY cte.Atn_Dr
       , cte.Med_Rec

END

GO


