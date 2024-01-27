USE [CLARITY_App]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--ALTER PROCEDURE [ETL].[uspSrc_SvcLine_Transfer_TAT]
--	   (
--		@startdate SMALLDATETIME = NULL
--	   ,@enddate SMALLDATETIME = NULL)

--AS 
/**********************************************************************************************************************
WHAT: Create procedure ETL.uspSrc_SvcLine_Transfer_TAT
WHO : Rena Morse
WHEN: 7/26/2017
WHY : Create data source for Balanced Scorecard Transfer Turnaround Time metric, measuring average time in minutes
for bed transfers between inpatient units. Using CLARITY because PEND_ACTION not in EDW. Based on Mali's SSRS report for
the same data (Pt_Progression).
-----------------------------------------------------------------------------------------------------------------------
INFO: 
      INPUTS:	CLARITY_App.Rptg.vwDim_Date date_dim
				CLARITY.dbo.PEND_ACTION
				CLARITY.dbo.PAT_ENC_HSP
				CLARITY.dbo.ZC_PEND_RECRD_TYPE
				CLARITY.dbo.CLARITY_DEP
				CLARITY.dbo.CLARITY_BED
				CLARITY.dbo.CLARITY_ADT
				CLARITY.dbo.ZC_PAT_CLASS
				CLARITY.dbo.ORDER_PROC
				CLARITY.dbo.IDENTITY_ID
				CLARITY.dbo.PATIENT pt
				CLARITY.dbo.ZC_SEX
				CLARITY.dbo.CLARITY_SER
				CLARITY.dbo.IDENTITY_SER_ID
				CLARITY_App.dbo.Dim_Physcn
				CLARITY.dbo.HSP_ATND_PROV
				CLARITY_App.Rptg.vwRef_MDM_Location_Master_EpicSvc
				CLARITY_App.Rptg.vwRef_MDM_Location_Master
				CLARITY_App.Rptg.Ref_Service_Line
				CLARITY_App.Rptg.Ref_Opnl_Service_Line 
				CLARITY_App.Rptg.Big6_Transplant_Datamart
				CLARITY.dbo.PAT_ENC 

      OUTPUTS:  ETL.uspSrc_SvcLine_Transfer_TAT

------------------------------------------------------------------------------------------------------------------------
MODS: 
	10/16/2018 BDD changes for Epic upgrade
	10/17/2018 - RM: updated inpatient unit flag
***********************************************************************************************************************/

SET NOCOUNT ON; 

 DECLARE @startdate AS SMALLDATETIME = NULL
 DECLARE @enddate AS SMALLDATETIME = NULL

---------------------------------------------------
 ----get default Balanced Scorecard date range
 IF @startdate IS NULL AND @enddate IS NULL
    EXEC etl.usp_Get_Dash_Dates_BalancedScorecard @startdate OUTPUT, @enddate OUTPUT
----------------------------------------------------


DECLARE @locstartdate SMALLDATETIME,
        @locenddate SMALLDATETIME

SET @locstartdate = @startdate
SET @locenddate   = @enddate


SELECT

	-- standard event columns

	CAST('Transfer' AS VARCHAR(50)) AS 'event_type'
   ,CASE WHEN (transfers.occupied_date IS NOT NULL AND transfers.inpt_unit_flag = 1) 
			THEN 1
			ELSE 0
		END AS 'event_count'
   ,CASE WHEN transfers.occupied_date IS NULL
			THEN date_dim.day_date
			ELSE transfers.occupied_date
		END AS 'event_date'
   ,CAST(NULL AS VARCHAR(150)) AS 'event_category'
   ,transfers.occupied_dept_id AS 'epic_department_id'
   ,transfers.occupied_dept AS 'epic_department_name'
   ,transfers.occupied_dept_ext_name AS 'epic_department_name_external'
   ,date_dim.fmonth_num
   ,date_dim.FYear_name
   ,date_dim.Fyear_num
   ,CAST(LEFT(DATENAME(MM, date_dim.day_date), 3) + ' '
	+ CAST(DAY(date_dim.day_date) AS VARCHAR(2)) AS VARCHAR(10)) AS 'report_period'
   ,date_dim.day_date AS 'report_date'
   ,CAST(CASE WHEN FLOOR((CAST (COALESCE(transfers.occupied_date, day_date) AS INTEGER)
								 - CAST(CAST(transfers.BIRTH_DATE AS DATETIME) AS INTEGER))
								/ 365.25) < 18 THEN 1
				ELSE 0
			END AS SMALLINT) AS 'peds'
   ,CAST(CASE WHEN tx.pat_enc_csn_id IS NOT NULL THEN 1
				ELSE 0
			END AS SMALLINT) AS 'transplant'
--   ,CAST(NULL AS INT) AS 'sk_Dim_Pt' --only lives in EDW
   ,transfers.BIRTH_DATE AS 'person_birth_date'
   ,transfers.Sex AS 'person_gender'
   ,transfers.MRN AS 'person_id'
   ,transfers.PAT_NAME AS 'person_name'
   ,CAST(NULL AS VARCHAR(150)) AS 'practice_group_name'
   ,CAST(NULL AS INT) AS 'practice_group_id'
   ,oclocsvc.service_line_id
   ,oclocsvc.service_line
   ,CAST(CASE	WHEN FLOOR((CAST (COALESCE(transfers.occupied_date, day_date) AS INTEGER)
												- CAST(CAST(transfers.BIRTH_DATE AS DATETIME) AS INTEGER))
											   / 365.25) < 18 THEN 1
									ELSE NULL
							   END AS INT) AS 'sub_service_line_id'
   ,CAST(CASE WHEN FLOOR((CAST (COALESCE(transfers.occupied_date, day_date) AS INTEGER)
											 - CAST(CAST(transfers.BIRTH_DATE AS DATETIME) AS INTEGER))
											/ 365.25) < 18 THEN 'Children'
								 ELSE NULL
							END AS VARCHAR(150)) AS 'sub_service_line'
   ,oclocsvc.opnl_service_id
   ,oclocsvc.opnl_service_name
   ,oclocsvc.hs_area_id
   ,oclocsvc.hs_area_name
  
	-- extra transfer fields

   ,transfers.PAT_ENC_CSN_ID
   ,transfers.HSP_ACCOUNT_ID
   ,transfers.PAT_ID
   ,transfers.PAT_CLASS_C
   ,transfers.adt_class
   ,transfers.ADT_PAT_CLASS_C
   ,transfers.hsp_class
   ,transfers.origin_dept_id
   ,transfers.origin_dept
   ,transfers.origin_dept_ext_name
   ,transfers.assigned_dept_id
   ,transfers.assigned_dept
   ,transfers.assigned_dept_ext_name
   ,transfers.assigned_bed
   ,transfers.transfer_order_written_date
   ,transfers.bed_request_date
   ,transfers.bed_assigned_date
   ,transfers.occupied_date
   ,transfers.occupied_dept_id
   ,transfers.occupied_dept
   ,transfers.occupied_dept_ext_name
   ,transfers.occupied_bed
   ,transfers.inpt_unit_flag

	-- extra transfer dept service line fields (for origin dept)

   ,orlocsvc.service_line_id AS 'origin_dept_sl_id'
   ,orlocsvc.service_line AS 'origin_dept_sl'
   ,orlocsvc.opnl_service_id AS 'origin_dept_osl_id'
   ,orlocsvc.opnl_service_name AS 'origin_dept_osl'
				
	-- extra transfer physician fields 

   ,transfers.ord_auth_phys_prov_id		-- transfer order authorizing physician
   ,transfers.ord_auth_phys
   ,slor.Service_Line_ID AS 'ord_auth_phys_sl_id'
   ,slor.Service_Line AS 'ord_auth_phys_sl'
   ,oslor.Opnl_Service_Line_ID AS 'ord_auth_phys_osl_id'
   ,oslor.Opnl_Service_Line AS 'ord_auth_phys_osl'

   ,ordatn.PROV_ID AS 'ord_atn_phys_prov_id'	--transfer order attending physician
   ,ordatn.PROV_NAME AS 'ord_atn_phys'
   ,sloa.Service_Line_ID AS 'ord_atn_phys_sl_id'
   ,sloa.Service_Line AS 'ord_atn_phys_sl'
   ,osloa.Opnl_Service_Line_ID AS 'ord_atn_phys_osl_id'
   ,osloa.Opnl_Service_Line AS 'ord_atn_phys_osl'

   ,transfers.occ_atn_phys_prov_id		--transfer occupying unit attending physician
   ,transfers.occ_atn_phys
   ,sloc.Service_Line_ID AS 'occ_atn_phys_sl_id'
   ,sloc.Service_Line AS 'occ_atn_phys_sl'
   ,osloc.Opnl_Service_Line_ID AS 'occ_atn_phys_osl_id'
   ,osloc.Opnl_Service_Line AS 'occ_atn_phys_osl'

  FROM
	CLARITY_App.Rptg.vwDim_Date date_dim

  LEFT OUTER JOIN (SELECT DISTINCT
					  hsp.PAT_ENC_CSN_ID
					 ,hsp.HSP_ACCOUNT_ID
					 ,CAST(idx.IDENTITY_ID AS VARCHAR(50)) AS 'MRN'      ----BDD 10/16/2018 Cast for Epic upgrade
					 ,hsp.PAT_ID
					 ,pt.PAT_NAME
					 ,pt.BIRTH_DATE
					 ,sx.NAME AS 'Sex'
					 ,adt.PAT_CLASS_C
					 ,cls.NAME AS 'adt_class'
					 ,hsp.ADT_PAT_CLASS_C
					 ,hcls.NAME AS 'hsp_class'
					 ,prvdep.DEPARTMENT_ID AS 'origin_dept_id'
					 ,prvdep.DEPARTMENT_NAME AS 'origin_dept'
					 ,prvdep.EXTERNAL_NAME AS 'origin_dept_ext_name'
					 ,dep.DEPARTMENT_ID AS 'assigned_dept_id'
					 ,dep.DEPARTMENT_NAME AS 'assigned_dept'
					 ,dep.EXTERNAL_NAME AS 'assigned_dept_ext_name'
					 ,bed.BED_LABEL AS 'assigned_bed'
					 ,prc.ORDER_INST AS 'transfer_order_written_date'
					 ,pnd.REQUEST_TIME AS 'bed_request_date'
					 ,YEAR(pnd.REQUEST_TIME) AS 'bed_request_year'
					 ,DATENAME(MONTH, pnd.REQUEST_TIME) AS 'bed_request_month'
					 ,DATENAME(dw, pnd.REQUEST_TIME) AS 'bed_request_day'
					 ,pnd.ASSIGNED_TIME AS 'bed_assigned_date'
					 ,adt.EFFECTIVE_TIME AS 'occupied_date'
					 ,CAST(CAST(adt.EFFECTIVE_TIME AS DATE) AS SMALLDATETIME) AS occupied_date_date   ----BDD 3/4/2019 use for matching data types in join below
					 ,occdpt.DEPARTMENT_ID AS 'occupied_dept_id'
					 ,occdpt.DEPARTMENT_NAME AS 'occupied_dept'
					 ,occdpt.EXTERNAL_NAME AS 'occupied_dept_ext_name'
					 ,occbed.BED_LABEL AS 'occupied_bed'
					 ,pndatn.PROV_ID AS 'occ_atn_phys_prov_id'
					 ,pndatn.PROV_NAME AS 'occ_atn_phys'
					 ,ophys.Service_Line AS 'occ_atn_phys_sl'
					 ,ordauth.PROV_ID AS 'ord_auth_phys_prov_id'
					 ,ordauth.PROV_NAME AS 'ord_auth_phys'
					 ,rphys.Service_Line AS 'ord_auth_phys_sl'
					 ,(SELECT TOP 1
						  ser.PROV_ID
						FROM
						  CLARITY.dbo.HSP_ATND_PROV prov
						INNER JOIN CLARITY.dbo.CLARITY_SER ser ON ser.PROV_ID = prov.PROV_ID
						WHERE
						  adt.PAT_ENC_CSN_ID = prov.PAT_ENC_CSN_ID
						  AND prc.ORDER_INST >= prov.ATTEND_FROM_DATE
						  AND prc.ORDER_INST < (CASE WHEN prov.ATTEND_TO_DATE IS NULL THEN GETDATE() ELSE prov.ATTEND_TO_DATE END)
						ORDER BY
						  ABS(DATEDIFF(dd, prov.ATTEND_FROM_DATE,
									   prc.ORDER_INST)
							 )
					    ) AS 'ord_atn_phys'
																				
					 --,CASE WHEN ((prvdep.DEPARTMENT_ID IN (		
						--		  SELECT
						--			  [Epic DEPARTMENT_ID]
						--			FROM
						--			  CLARITY_App.Rptg.Balanced_ScoreCard_Mapping
						--			WHERE
						--			  Inpatient_Care_Unit = 1))
						--		 AND (occdpt.DEPARTMENT_ID IN (
						--			  SELECT
						--				  [Epic DEPARTMENT_ID]
						--				FROM
						--				  CLARITY_App.Rptg.Balanced_ScoreCard_Mapping
						--				WHERE
						--				  Inpatient_Care_Unit = 1))) THEN 1
						--   ELSE 0
					 -- END AS 'inpt_unit_flag'

					   ,CASE WHEN ((prvdep.DEPARTMENT_ID IN (
								   SELECT  EPIC_DEPARTMENT_ID
										FROM  CLARITY_App.Rptg.vwRef_MDM_Location_Master
										WHERE  EPIC_DEPT_TYPE = 'IN PATIENT'))
								 AND (occdpt.DEPARTMENT_ID IN (
									   SELECT  EPIC_DEPARTMENT_ID
										FROM  CLARITY_App.Rptg.vwRef_MDM_Location_Master
										WHERE  EPIC_DEPT_TYPE = 'IN PATIENT')))
						THEN 1
						ELSE 0
					  END AS 'inpt_unit_flag'

					FROM
					  CLARITY.dbo.PEND_ACTION pnd
					LEFT OUTER JOIN CLARITY.dbo.PAT_ENC_HSP hsp ON pnd.PAT_ENC_CSN_ID = hsp.PAT_ENC_CSN_ID
					LEFT OUTER JOIN CLARITY.dbo.ZC_PEND_RECRD_TYPE recrd ON pnd.PEND_RECRD_TYPE_C = recrd.PEND_RECRD_TYPE_C
					LEFT OUTER JOIN CLARITY.dbo.CLARITY_DEP dep ON dep.DEPARTMENT_ID = pnd.UNIT_ID
					LEFT OUTER JOIN CLARITY.dbo.CLARITY_BED bed ON bed.BED_ID = pnd.BED_ID
					LEFT OUTER JOIN CLARITY.dbo.CLARITY_ADT adt ON pnd.LINKED_EVENT_ID = adt.EVENT_ID
																--AND adt.EVENT_TYPE_C IN ('1','3')
					LEFT OUTER JOIN CLARITY.dbo.ZC_PAT_CLASS cls ON cls.ADT_PAT_CLASS_C = adt.PAT_CLASS_C
					LEFT OUTER JOIN CLARITY.dbo.ZC_PAT_CLASS hcls ON hcls.ADT_PAT_CLASS_C = hsp.ADT_PAT_CLASS_C
					LEFT OUTER JOIN CLARITY.dbo.CLARITY_DEP occdpt ON adt.DEPARTMENT_ID = occdpt.DEPARTMENT_ID
					LEFT OUTER JOIN CLARITY.dbo.CLARITY_BED occbed ON adt.BED_ID = occbed.BED_ID
					LEFT OUTER JOIN CLARITY.dbo.ORDER_PROC prc ON pnd.ADT_ORDER_ID = prc.ORDER_PROC_ID
					INNER JOIN CLARITY.dbo.IDENTITY_ID idx ON idx.PAT_ID = adt.PAT_ID

---BDD 10/08/2018 change join for Epic upgrade deprecated column					 
---					INNER JOIN CLARITY.dbo.CLARITY_ADT adtprv ON adtprv.EVENT_ID = adt.PREV_EVENT_ID
					INNER JOIN CLARITY.dbo.CLARITY_ADT adtprv ON adtprv.EVENT_ID = adt.XFER_EVENT_ID

					INNER JOIN CLARITY.dbo.CLARITY_DEP prvdep ON adtprv.DEPARTMENT_ID = prvdep.DEPARTMENT_ID
					LEFT OUTER JOIN CLARITY.dbo.PATIENT pt ON pt.PAT_ID = hsp.PAT_ID
					LEFT OUTER JOIN CLARITY.dbo.ZC_SEX sx ON sx.RCPT_MEM_SEX_C = pt.SEX_C
					LEFT OUTER JOIN CLARITY.dbo.CLARITY_SER pndatn ON pndatn.PROV_ID = pnd.PEND_ATND_PROV_ID
					LEFT OUTER JOIN CLARITY.dbo.CLARITY_SER ordauth ON ordauth.PROV_ID = prc.AUTHRZING_PROV_ID
					LEFT OUTER JOIN CLARITY.dbo.IDENTITY_SER_ID seridoc ON pndatn.PROV_ID = seridoc.PROV_ID
															  AND seridoc.IDENTITY_TYPE_ID = 6
					LEFT OUTER JOIN CLARITY_App.dbo.Dim_Physcn ophys ON TRY_CONVERT(INT, seridoc.IDENTITY_ID) = ophys.IDNumber AND ophys.current_flag = 1
					LEFT OUTER JOIN CLARITY.dbo.IDENTITY_SER_ID seridor ON ordauth.PROV_ID = seridor.PROV_ID
															  AND seridor.IDENTITY_TYPE_ID = 6
					LEFT OUTER JOIN CLARITY_App.dbo.Dim_Physcn rphys ON TRY_CONVERT(INT, seridor.IDENTITY_ID) = rphys.IDNumber AND rphys.current_flag = 1
				
					WHERE
					  pnd.PEND_REQ_STATUS_C IS NOT NULL --all bed requests
						--AND adt.EVENT_TYPE_C = 3
						--AND pnd.IS_DELETED_YN='N'
					  AND dep.RECORD_STATUS IS NULL
					  AND adt.EVENT_SUBTYPE_C <> 2	--'Canceled'
					  AND dep.DEPARTMENT_NAME IS NOT NULL
					  --AND prvdep.DEPARTMENT_ID <> occdpt.DEPARTMENT_ID	--exclude same unit bed changes	 
					  AND idx.IDENTITY_TYPE_ID = 14
					  AND (pnd.REQUEST_TIME >= @locstartdate
						   AND pnd.REQUEST_TIME < @locenddate)
					  AND (adt.EFFECTIVE_TIME >= @locstartdate
						   AND adt.EFFECTIVE_TIME < @locenddate)

					) transfers ---ON CAST(transfers.occupied_date AS DATE) = CAST(date_dim.day_date AS DATE)    ----BDD 03/04/2019 change to matching data type
					            ON transfers.occupied_date_date = date_dim.day_date                              ----    hopefully speed this up a bit

-- Service Lines by transfer location (for eventual use -- med ctr level will be attributed to Patient Progression service line in Tableau)

  LEFT OUTER JOIN CLARITY_App.Rptg.vwRef_MDM_Location_Master_EpicSvc orlocsvc ON orlocsvc.epic_department_id = transfers.origin_dept_id
  LEFT OUTER JOIN CLARITY_App.Rptg.vwRef_MDM_Location_Master_EpicSvc oclocsvc ON oclocsvc.epic_department_id = transfers.occupied_dept_id

-- Additional Service lines by transfer physicians (for eventual use)

  LEFT OUTER JOIN CLARITY.dbo.CLARITY_SER ordatn ON ordatn.PROV_ID = transfers.ord_atn_phys
  LEFT OUTER JOIN CLARITY.dbo.IDENTITY_SER_ID seridoca ON ordatn.PROV_ID = seridoca.PROV_ID
														  AND seridoca.IDENTITY_TYPE_ID = 6
  LEFT OUTER JOIN CLARITY_App.dbo.Dim_Physcn oaphys ON TRY_CONVERT(INT, seridoca.IDENTITY_ID) = oaphys.IDNumber AND oaphys.current_flag = 1
													
  LEFT OUTER JOIN CLARITY_App.Rptg.Ref_Service_Line slor ON transfers.ord_auth_phys_sl = slor.Physician_Roster_Name
  LEFT OUTER JOIN CLARITY_App.Rptg.Ref_Opnl_Service_Line oslor ON transfers.ord_auth_phys_sl = oslor.Physician_Roster_Name
  LEFT OUTER JOIN CLARITY_App.Rptg.Ref_Service_Line sloa ON oaphys.Service_Line = sloa.Physician_Roster_Name
  LEFT OUTER JOIN CLARITY_App.Rptg.Ref_Opnl_Service_Line osloa ON oaphys.Service_Line = osloa.Physician_Roster_Name
  LEFT OUTER JOIN CLARITY_App.Rptg.Ref_Service_Line sloc ON transfers.occ_atn_phys_sl = sloc.Physician_Roster_Name
  LEFT OUTER JOIN CLARITY_App.Rptg.Ref_Opnl_Service_Line osloc ON transfers.occ_atn_phys_sl = osloc.Physician_Roster_Name

-- Identify transplant encounter

  LEFT OUTER JOIN (SELECT DISTINCT
					  btd.pat_enc_csn_id
					 ,btd.Event_Transplanted AS 'transplant_surgery_dt'
					 ,btd.hosp_admsn_time AS 'Adm_Dtm'
					FROM
					  CLARITY_App.Rptg.Big6_Transplant_Datamart btd
					INNER JOIN CLARITY.dbo.PAT_ENC enc ON btd.pat_enc_csn_id = enc.PAT_ENC_CSN_ID
					WHERE
					  (btd.TX_Episode_Phase = 'transplanted'
					   AND btd.TX_Stat_Dt >= @locstartdate
					   AND btd.TX_Stat_Dt < @locenddate)
					  AND btd.TX_GroupedPhaseStatus = 'TX-ADMIT') tx ON tx.pat_enc_csn_id = transfers.PAT_ENC_CSN_ID
  
  WHERE
	date_dim.day_date >= @locstartdate
	AND day_date < @locenddate
	--AND ord_auth_phys_prov_id = '75647'
	--AND ord_auth_phys_prov_id IN ('75647','48063','55059','35300','60093','71423','97715','48306','98164') -- Barbara Baxter, Sherry Child, Melinda Childress, Tiffany Colavincenzo, Markus DeLung, Teresa Fadely, Stephanie Good, Matthew Robertson, Marife Toledo-Canete
	--AND transfers.origin_dept_id = 10239015
	AND sloc.Service_Line = 'Oncology'
  ORDER BY
	event_date;




GO


