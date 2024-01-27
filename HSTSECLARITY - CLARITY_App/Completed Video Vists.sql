USE [CLARITY_App]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

DECLARE @startdate DATETIME
DECLARE @locstartdate DATETIME,
		@enddate DATETIME,
		@locenddate DATETIME

SET @startdate = '1/1/2022 00:00'
SET @enddate = '12/31/2022 23:59'

SET NOCOUNT ON;
			   
 --temp set for testing
SET @locstartdate = @startdate
SET @locenddate = @enddate

------------------------------------------------------------------------------------------------------

IF OBJECT_ID('tempdb..#main ') IS NOT NULL
DROP TABLE #main

/*  All scheduled appointments with patient, MyChart, encounter, department, insurance, and referral detail  */

          SELECT DISTINCT            ---BDD 8/22/2019 added distinct to counteract July change dupe rows

                    F_SCHED_APPT.PAT_ENC_CSN_ID , 
                    F_SCHED_APPT.APPT_STATUS_C ,
                    CASE WHEN F_SCHED_APPT.APPT_STATUS_C IN (2) THEN 'Y' ELSE 'N' END AS COMPLETED_STATUS_YN ,
                    CAST(CASE 
                        WHEN F_SCHED_APPT.APPT_STATUS_C = 1 AND F_SCHED_APPT.SIGNIN_DTTM IS NOT NULL THEN 'Present'
                        WHEN zcappt.NAME IS NOT NULL THEN zcappt.NAME
                        ELSE 
                           CASE
                              WHEN zcappt.APPT_STATUS_C IS NULL THEN '*Unknown status'
                              ELSE '*Unnamed status'
                              END + ' [' + CONVERT(VARCHAR(254), F_SCHED_APPT.APPT_STATUS_C) + ']'
                    END AS VARCHAR(254)) AS APPT_STATUS_NAME,
                    F_SCHED_APPT.CONTACT_DATE ,
                    F_SCHED_APPT.APPT_DTTM ,
                    F_SCHED_APPT.PROV_ID ,
                    CASE
						WHEN F_SCHED_APPT.PROV_ID IS NULL
							THEN '*Unspecified provider'
						ELSE
							CASE
								WHEN CLARITY_SER.prov_name IS NOT NULL
									THEN CLARITY_SER.prov_name
								WHEN CLARITY_SER.prov_id IS NULL
									THEN '*Unknown provider'
								ELSE '*Unnamed provider'
							END + ' [' + F_SCHED_APPT.prov_id + ']'
				     END AS PROV_NAME_WID,
                    CLARITY_SER.PROV_NAME ,
                    F_SCHED_APPT.DEPARTMENT_ID ,
                    CLARITY_DEP.DEPARTMENT_NAME ,
                    CLARITY_DEP.DEPT_ABBREVIATION ,
                    CLARITY_DEP.SPECIALTY_DEP_C AS DEPT_SPECIALTY_C ,
                    CASE
					  WHEN CLARITY_DEP.department_id IS NULL THEN '*Unknown department'
					  WHEN CLARITY_DEP.specialty IS NULL THEN '*No specialty'
					  ELSE CLARITY_DEP.specialty
				    END AS DEPT_SPECIALTY_NAME ,
					CAST(CASE
					  WHEN ( F_SCHED_APPT.APPT_STATUS_C = 3 -- Canceled
                               AND (CASE
					                  WHEN F_SCHED_APPT.CANCEL_REASON_C IS NULL THEN NULL
					                  WHEN canc.CANCEL_REASON_C IS NULL THEN '*Unknown cancel reason [' + CONVERT(VARCHAR(254), F_SCHED_APPT.cancel_reason_c) + ']'
					                  WHEN (SELECT COUNT(PAT_INIT_CANC_C) FROM CLARITY.dbo.PAT_INIT_CANC 
							                  WHERE PAT_INIT_CANC_C=canc.CANCEL_REASON_C) >= 1 THEN 'PATIENT'
					                  WHEN (SELECT COUNT(PROV_INIT_CANC_C) FROM CLARITY.dbo.PROV_INIT_CANC 
							                  WHERE PROV_INIT_CANC_C=canc.CANCEL_REASON_C) >= 1 THEN 'PROVIDER'
					                  ELSE 'OTHER'
				                    END
								   ) = 'PATIENT'
                               AND DATEDIFF(MINUTE, F_SCHED_APPT.APPT_CANC_DTTM, F_SCHED_APPT.APPT_DTTM) / 60 < 24) THEN 'Canceled Late'
					  ELSE CASE 
                               WHEN F_SCHED_APPT.APPT_STATUS_C = 1 AND F_SCHED_APPT.SIGNIN_DTTM IS NOT NULL THEN 'Present'
                               WHEN zcappt.NAME IS NOT NULL THEN zcappt.NAME
                               ELSE 
                                   CASE
                                     WHEN zcappt.APPT_STATUS_C IS NULL THEN '*Unknown status'
                                     ELSE '*Unnamed status'
                                   END + ' [' + CONVERT(VARCHAR(254), F_SCHED_APPT.APPT_STATUS_C) + ']'
                           END

					END AS VARCHAR(254)) AS APPT_STATUS_FLAG ,
					CLARITY_SER_SPEC.SPECIALTY_C AS PROV_SPECIALTY_C ,
					ZC_SPECIALTY.NAME AS PROV_SPECIALTY_NAME ,
					CAST(CAST(F_SCHED_APPT.APPT_DTTM AS DATE) AS DATETIME) AS APPT_DT ,
					PAT_ENC.ENC_TYPE_C ,
					ZC_DISP_ENC_TYPE.TITLE AS ENC_TYPE_TITLE ,
					ptot.PROV_TYPE_OT_NAME ,
					COALESCE(ptot.PROV_TYPE_OT_C, CLARITY_SER.PROVIDER_TYPE_C, NULL) AS PROVIDER_TYPE_C ,
					COALESCE(ptot.PROV_TYPE_OT_NAME, CLARITY_SER.PROV_TYPE, NULL) AS PROV_TYPE ,
-----TMB 01/26/2023, added TELEHEALTH_MODE_C, TELEHEALTH_MODE_NAME, and APP indicator values
					PAT_ENC_6.TELEHEALTH_MODE_C , -- INTEGER
					ztm.NAME AS TELEHEALTH_MODE_NAME , -- VARCHAR(254)
					--CASE WHEN CLARITY_SER.PROV_TYPE IN ('NURSE PRACTITIONER','PHYSICIAN ASSISTANT','NURSE ANESTHETIST','CLINICAL NURSE SPECIALIST','GENETIC COUNSELOR','AUDIOLOGIST') THEN 1 ELSE 0 END AS app_flag , -- INTEGER
					CASE WHEN COALESCE(ptot.PROV_TYPE_OT_NAME, CLARITY_SER.PROV_TYPE, NULL) IN ('NURSE PRACTITIONER','PHYSICIAN ASSISTANT','NURSE ANESTHETIST','CLINICAL NURSE SPECIALIST','GENETIC COUNSELOR','AUDIOLOGIST') THEN 1 ELSE 0 END AS app_flag , -- INTEGER
					CLARITY_EMP_DEMO.EMAIL ,
					--CLARITY_SER.EMAIL ,
					--CLARITY_SER_ADDR.LINE AS CLARITY_SER_ADDR_LINE ,
					--CLARITY_SER_ADDR.EMAIL AS CLARITY_SER_ADDR_EMAIL ,
					CLARITY_SER.[USER_ID] ,
					provemp.SYSTEM_LOGIN-- ,
			--patient info
--                    F_SCHED_APPT.PAT_ID ,
--                    PATIENT.PAT_NAME ,
--                    CAST(IDENTITY_ID.IDENTITY_ID AS VARCHAR(50)) AS IDENTITY_ID , --MRN
--                    PATIENT_MYC.MYCHART_STATUS_C ,
--                    ZC_MYCHART_STATUS.NAME AS MYCHART_STATUS_NAME ,
--                    PAT_ENC_4.VIS_NEW_TO_SYS_YN ,
--                    PAT_ENC_4.VIS_NEW_TO_DEP_YN ,
--                    PAT_ENC_4.VIS_NEW_TO_PROV_YN ,

--			--appt info
--                    F_SCHED_APPT.APPT_SERIAL_NUM ,
--                    F_SCHED_APPT.RESCHED_APPT_CSN_ID ,
--                    F_SCHED_APPT.PRC_ID ,

--                    COALESCE(prc.PRC_NAME,CASE
--                                           WHEN F_SCHED_APPT.PRC_ID IS NULL THEN '*Unspecified visit type'
--                                           ELSE
--                                            CASE 
--                                              WHEN prc.PRC_ID IS NULL THEN '*Unknown visit type'
--                                              ELSE '*Unnamed visit type'
--                                            END + ' [' + F_SCHED_APPT.PRC_ID + ']' END 
--							) AS PRC_NAME,

--                    F_SCHED_APPT.APPT_BLOCK_C ,

--                    CAST(CASE
--                     WHEN F_SCHED_APPT.APPT_BLOCK_C IS NULL THEN NULL
--                       ELSE COALESCE(zcblock.NAME,
--                                                  CASE
--                                                   WHEN zcblock.appt_block_c IS NULL
--                                                    THEN '*Unknown block'
--                                                   ELSE '*Unnamed block'
--                                                   END + ' [' + CONVERT(VARCHAR(254), F_SCHED_APPT.appt_block_c) + ']'
--                                    )
--                    END AS VARCHAR(254))   AS APPT_BLOCK_NAME ,

--                    F_SCHED_APPT.APPT_LENGTH ,


--                    F_SCHED_APPT.APPT_CONF_STAT_C ,
--                    DATEDIFF(MINUTE, F_SCHED_APPT.APPT_CANC_DTTM, F_SCHED_APPT.APPT_DTTM) / 60 AS CANCEL_LEAD_HOURS ,

--                    CAST(CASE
--					  WHEN F_SCHED_APPT.CANCEL_REASON_C IS NULL THEN NULL
--					  WHEN canc.CANCEL_REASON_C IS NULL THEN '*Unknown cancel reason [' + CONVERT(VARCHAR(55), F_SCHED_APPT.cancel_reason_c) + ']'
--					  WHEN (SELECT COUNT(PAT_INIT_CANC_C) FROM CLARITY.dbo.PAT_INIT_CANC 
--							WHERE PAT_INIT_CANC_C=canc.CANCEL_REASON_C) >= 1 THEN 'PATIENT'
--					  WHEN (SELECT COUNT(PROV_INIT_CANC_C) FROM CLARITY.dbo.PROV_INIT_CANC 
--							WHERE PROV_INIT_CANC_C=canc.CANCEL_REASON_C) >= 1 THEN 'PROVIDER'
--					  ELSE 'OTHER'
--				    END AS VARCHAR(55)) AS CANCEL_INITIATOR ,


--                    F_SCHED_APPT.SAME_DAY_YN ,
--                    F_SCHED_APPT.SAME_DAY_CANC_YN ,
--                    F_SCHED_APPT.CANCEL_REASON_C ,
                    
--					CAST(CASE
--                      WHEN F_SCHED_APPT.CANCEL_REASON_C IS NULL 
--					       THEN NULL
--							ELSE COALESCE(canc.NAME,
--	   	  								  CASE
--							                WHEN canc.cancel_reason_c IS NULL
--								              THEN '*Unknown cancel reason'
--							                  ELSE '*Unnamed cancel reason'
--						                   END + ' [' + CONVERT(VARCHAR(254), F_SCHED_APPT.cancel_reason_c) + ']'
--					                      )  
--					END AS VARCHAR(254)) AS CANCEL_REASON_NAME ,

--                    F_SCHED_APPT.WALK_IN_YN ,
--                    F_SCHED_APPT.OVERBOOKED_YN ,
--                    F_SCHED_APPT.OVERRIDE_YN ,
--                    F_SCHED_APPT.UNAVAILABLE_TIME_YN ,
--                    F_SCHED_APPT.CHANGE_CNT ,
--                    F_SCHED_APPT.JOINT_APPT_YN ,
--                    F_SCHED_APPT.PHONE_REM_STAT_C ,

--                    CAST(CASE WHEN F_SCHED_APPT.PHONE_REM_STAT_C IS NULL 
--					       THEN NULL
--						   ELSE
--							   CASE
--								   WHEN zcrem.PHONE_REM_STAT_C IS NULL THEN '*Unknown phone reminder status'
--								   WHEN zcrem.NAME IS NULL THEN '*Unnamed phone reminder status [' + CONVERT(VARCHAR(254), zcrem.PHONE_REM_STAT_C) + ']'
--				   					/* 09/28/18 bug fix start */
--								   ELSE zcrem.NAME
--								   /* 09/28/18 bug fix end */
--                               END 
--                    END AS VARCHAR(254)) AS PHONE_REM_STAT_NAME ,

--			--dates/times
--                    F_SCHED_APPT.APPT_MADE_DATE ,
--                    F_SCHED_APPT.APPT_CANC_DATE ,
--                    F_SCHED_APPT.APPT_CONF_DTTM ,
--					F_SCHED_APPT.SIGNIN_DTTM,
--					F_SCHED_APPT.PAGED_DTTM,
--					F_SCHED_APPT.BEGIN_CHECKIN_DTTM,
--					F_SCHED_APPT.CHECKIN_DTTM,
--					F_SCHED_APPT.ARVL_LIST_REMOVE_DTTM,
--					F_SCHED_APPT.ROOMED_DTTM,
--					F_SCHED_APPT.FIRST_ROOM_ASSIGN_DTTM,
--					F_SCHED_APPT.NURSE_LEAVE_DTTM,
--					F_SCHED_APPT.PHYS_ENTER_DTTM,
--					F_SCHED_APPT.VISIT_END_DTTM,
--					F_SCHED_APPT.CHECKOUT_DTTM,

--			 DATEDIFF(
--					MINUTE
--					, F_SCHED_APPT.CHECKIN_DTTM
--					, (SELECT MIN(candidate_dttm) --select the earliest of three roomed timestamps occurring after check-in
--					   FROM (VALUES(CASE WHEN F_SCHED_APPT.arvl_list_remove_dttm >= F_SCHED_APPT.checkin_dttm THEN F_SCHED_APPT.arvl_list_remove_dttm ELSE NULL END),
--									(CASE WHEN F_SCHED_APPT.roomed_dttm >= F_SCHED_APPT.checkin_dttm THEN F_SCHED_APPT.roomed_dttm ELSE NULL END), 
--									(CASE WHEN F_SCHED_APPT.first_room_assign_dttm >= F_SCHED_APPT.checkin_dttm THEN F_SCHED_APPT.first_room_assign_dttm ELSE NULL END)
--									) AS Roomed_Cols(candidate_dttm))
--				  ) AS TIME_TO_ROOM_MINUTES,
--				 DATEDIFF(
--					MINUTE
--					, (SELECT MIN(candidate_dttm) --select the earliest of three roomed timestamps occurring after check-in
--					   FROM (VALUES(CASE WHEN F_SCHED_APPT.arvl_list_remove_dttm >= F_SCHED_APPT.checkin_dttm THEN F_SCHED_APPT.arvl_list_remove_dttm ELSE NULL END),
--								   (CASE WHEN F_SCHED_APPT.roomed_dttm >= F_SCHED_APPT.checkin_dttm THEN F_SCHED_APPT.roomed_dttm ELSE NULL END), 
--								   (CASE WHEN F_SCHED_APPT.first_room_assign_dttm >= F_SCHED_APPT.checkin_dttm THEN F_SCHED_APPT.first_room_assign_dttm ELSE NULL END)
--							) AS Roomed_Cols(candidate_dttm))
--					, (CASE WHEN F_SCHED_APPT.visit_end_dttm >= 
--								  (SELECT MIN(candidate_dttm) --select the earliest of three roomed timestamps occurring after check-in
--								   FROM (VALUES(CASE WHEN F_SCHED_APPT.arvl_list_remove_dttm >= F_SCHED_APPT.checkin_dttm THEN F_SCHED_APPT.arvl_list_remove_dttm ELSE NULL END),
--											   (CASE WHEN F_SCHED_APPT.roomed_dttm >= F_SCHED_APPT.checkin_dttm THEN F_SCHED_APPT.roomed_dttm ELSE NULL END), 
--											   (CASE WHEN F_SCHED_APPT.first_room_assign_dttm >= F_SCHED_APPT.checkin_dttm THEN F_SCHED_APPT.first_room_assign_dttm ELSE NULL END)
--										 ) AS Roomed_Cols(candidate_dttm))
--								  AND (F_SCHED_APPT.checkout_dttm IS NULL OR F_SCHED_APPT.visit_end_dttm <= F_SCHED_APPT.checkout_dttm)
--								  THEN F_SCHED_APPT.visit_end_dttm
--							WHEN F_SCHED_APPT.checkout_dttm >= 
--									(SELECT MIN(candidate_dttm) --select the earliest of three roomed timestamps occurring after check-in
--									 FROM (VALUES(CASE WHEN F_SCHED_APPT.arvl_list_remove_dttm >= F_SCHED_APPT.checkin_dttm THEN F_SCHED_APPT.arvl_list_remove_dttm ELSE NULL END),
--												 (CASE WHEN F_SCHED_APPT.roomed_dttm >= F_SCHED_APPT.checkin_dttm THEN F_SCHED_APPT.roomed_dttm ELSE NULL END), 
--												 (CASE WHEN F_SCHED_APPT.first_room_assign_dttm >= F_SCHED_APPT.checkin_dttm THEN F_SCHED_APPT.first_room_assign_dttm ELSE NULL END)
--										   ) AS Roomed_Cols(candidate_dttm))
--									 AND (F_SCHED_APPT.visit_end_dttm IS NULL OR F_SCHED_APPT.checkout_dttm < F_SCHED_APPT.visit_end_dttm)
--									THEN F_SCHED_APPT.checkout_dttm
--							ELSE NULL
--					  END)
--				  ) AS TIME_IN_ROOM_MINUTES,
--				 DATEDIFF(
--					  MINUTE
--					, F_SCHED_APPT.CHECKIN_DTTM
--					, CASE 
--						WHEN F_SCHED_APPT.VISIT_END_DTTM >= F_SCHED_APPT.CHECKIN_DTTM
--							 AND (F_SCHED_APPT.CHECKOUT_DTTM IS NULL 
--								OR F_SCHED_APPT.CHECKOUT_DTTM < F_SCHED_APPT.CHECKIN_DTTM
--								OR F_SCHED_APPT.VISIT_END_DTTM <= F_SCHED_APPT.CHECKOUT_DTTM)
--							 THEN F_SCHED_APPT.VISIT_END_DTTM
--						WHEN F_SCHED_APPT.CHECKOUT_DTTM >= F_SCHED_APPT.CHECKIN_DTTM
--							 THEN F_SCHED_APPT.CHECKOUT_DTTM
--						ELSE NULL
--					  END) AS CYCLE_TIME_MINUTES,

--			--Provider/scheduler info
--                    F_SCHED_APPT.REFERRING_PROV_ID ,

--                    CASE
--						WHEN F_SCHED_APPT.REFERRING_PROV_ID IS NULL THEN NULL
--						ELSE
--							CASE
--								WHEN refprov.prov_name IS NOT NULL
--									THEN refprov.prov_name
--								WHEN refprov.prov_id IS NULL
--									THEN '*Unknown provider'
--								ELSE '*Unnamed provider'
--							END + ' [' + F_SCHED_APPT.referring_prov_id + ']'
--						END AS REFERRING_PROV_NAME_WID,


--                    CLARITY_SER.RPT_GRP_FIVE , --service line
--                    F_SCHED_APPT.APPT_ENTRY_USER_ID ,

--                    CASE
--						WHEN F_SCHED_APPT.APPT_ENTRY_USER_ID IS NULL
--							THEN '*Unspecified user'
--						ELSE
--							CASE
--								WHEN entryemp.USER_ID IS NULL 
--									THEN '*Unknown user'
--								WHEN entryemp.NAME IS NULL
--									THEN '*Unnamed user'
--								ELSE entryemp.NAME
--							END + ' [' + F_SCHED_APPT.appt_entry_user_id + ']'
--                    END AS APPT_ENTRY_USER_NAME_WID ,


--			--Billing info 
--                    V_COVERAGE_PAYOR_PLAN.PAYOR_ID ,
--                    V_COVERAGE_PAYOR_PLAN.PAYOR_NAME ,
--                    V_COVERAGE_PAYOR_PLAN.BENEFIT_PLAN_ID ,
--                    CAST(V_COVERAGE_PAYOR_PLAN.BENEFIT_PLAN_NAME AS VARCHAR(75)) AS BENEFIT_PLAN_NAME ,
--                    V_COVERAGE_PAYOR_PLAN.FIN_CLASS_NAME ,
--                    PAT_ENC_3.DO_NOT_BILL_INS_YN ,
--                    PAT_ENC_3.SELF_PAY_VISIT_YN ,

--                    F_SCHED_APPT.HSP_ACCOUNT_ID ,
--                    F_SCHED_APPT.ACCOUNT_ID ,
--                    F_SCHED_APPT.COPAY_DUE ,
--                    F_SCHED_APPT.COPAY_COLLECTED ,
--                    F_SCHED_APPT.COPAY_USER_ID ,

--                    CASE WHEN F_SCHED_APPT.COPAY_USER_ID IS NULL 
--					   THEN NULL
--					   ELSE
--						 CASE
--							WHEN copayemp.USER_ID IS NULL 
--								THEN '*Unknown user'
--							WHEN copayemp.NAME IS NULL
--								THEN '*Unnamed user'
--							ELSE copayemp.NAME
--						END + ' [' + F_SCHED_APPT.copay_user_id + ']'
--                    END AS COPAY_USER_NAME_WID ,
	
--			 --fac-org info
--                    CLARITY_DEP.RPT_GRP_THIRTY , -- service line
--                    CLARITY_DEP.RPT_GRP_SIX , -- pod
--                    CLARITY_DEP.RPT_GRP_SEVEN , -- hub


--                    CLARITY_DEP.CENTER_C ,
--                    COALESCE(zccenter.name,
--									   CASE
--										   WHEN CLARITY_DEP.department_id IS NULL THEN '*Unknown department'
--										   WHEN CLARITY_DEP.center_c IS NULL THEN '*No center'
--										   ELSE '*Unknown center [' + CLARITY_DEP.center_c + ']'
--									   END
--						    ) AS CENTER_NAME ,

--                    LOC.LOC_ID ,
--                    COALESCE(loc.loc_name,
--                                          CASE
--                                            WHEN CLARITY_DEP.department_id IS NULL THEN '*Unknown department'
--                                            WHEN CLARITY_DEP.rev_loc_id IS NULL THEN '*No location'
--                                            ELSE '*Unknown location [' + CAST(CLARITY_DEP.rev_loc_id AS VARCHAR(18)) + ']'
--                                          END
--							) AS LOC_NAME ,

--                    CLARITY_DEP.SERV_AREA_ID ,
	
--			 --appt status flag

--					PAT_ENC_4.VIS_NEW_TO_SPEC_YN ,
--					PAT_ENC_4.VIS_NEW_TO_SERV_AREA_YN ,
--					PAT_ENC_4.VIS_NEW_TO_LOC_YN ,
--					REFERRAL.REFERRAL_ID ,
--					REFERRAL.ENTRY_DATE ,
--					ZC_RFL_STATUS.NAME AS RFL_STATUS_NAME ,
--					ZC_RFL_TYPE.NAME AS RFL_TYPE_NAME ,

--					zcconf.name AS APPT_CONF_STAT_NAME ,

--					CAST(SUBSTRING(PATIENT.ZIP, 1, 5) AS VARCHAR(5)) AS ZIP ,
--					ZC_SER_RPT_GRP_6.NAME AS SER_RPT_GRP_SIX ,
--					ZC_SER_RPT_GRP_8.NAME AS SER_RPT_GRP_EIGHT ,
--					CASE
--					  WHEN PAT_ENC.ENC_TYPE_C IN (				-- FACE TO FACE UVA DEFINED ENCOUNTER TYPES
--			                                      '1001'			--Anti-coag visit
--			                                     ,'50'			--Appointment
--			                                     ,'213'			--Dentistry Visit
--			                                     ,'2103500001'	--Home Visit
--			                                     ,'3'			--Hospital Encounter
--			                                     ,'108'			--Immunization
--			                                     ,'1201'			--Initial Prenatal
--			                                     ,'101'			--Office Visit
--			                                     ,'2100700001'	--Office Visit / FC
--			                                     ,'1003'			--Procedure visit
--			                                     ,'1200'			--Routine Prenatal
--			                                     ) THEN 1
--                      ELSE 0
--					END AS F2F_Flag ,
--					F_SCHED_APPT.APPT_CANC_DTTM ,
--					F_SCHED_APPT.APPT_CANC_USER_ID ,

--					CASE
--						WHEN F_SCHED_APPT.APPT_CANC_USER_ID IS NULL THEN NULL
--						ELSE
--							CASE
--								WHEN cancemp.USER_ID IS NULL 
--									THEN '*Unknown user'
--								WHEN cancemp.NAME IS NULL
--									THEN '*Unnamed user'
--								ELSE cancemp.NAME
--							END + ' [' + F_SCHED_APPT.appt_canc_user_id + ']'
--					END AS APPT_CANC_USER_NAME_WID ,

--					F_SCHED_APPT.APPT_CONF_USER_ID ,

--					CASE
--						  WHEN F_SCHED_APPT.APPT_CONF_USER_ID IS NOT NULL 
--							THEN 
--								CASE
--									WHEN confemp.USER_ID IS NULL THEN '*Unknown user'
--									ELSE COALESCE(confemp.NAME, '*Unnamed user')
--								END + ' [' + F_SCHED_APPT.APPT_CONF_USER_ID + ']'
--						  ELSE PAT_ENC.APPT_CONF_PERS
--					END AS APPT_CONF_USER_NAME ,

--					REFERRAL_HIST.CHANGE_DATE ,
--					F_SCHED_APPT.APPT_MADE_DTTM ,
--                    'RefreshScheduledAppointment' AS ETL_guid ,
--					CAST(GETDATE() AS DATETIME) AS UPDATE_DATE ,
--					CASE WHEN PROV_ATTR_INFO_OT.BILL_PROV_YN = 'Y' THEN 1 ELSE 0 END AS BILL_PROV_YN ,
--					F_SCHED_APPT.PAT_SCHED_MYC_STAT_C ,
--					ZC_MYCHART_STATUS_2.NAME AS PAT_SCHED_MYC_STAT_NAME ,

-----ARD 03/03/22, added Allowable Telehealth Modes given the visit type.
--					CAST(vt.ALLOWED_TELEHEALTH_MODES AS VARCHAR(66)) AS ALLOWED_TELEHEALTH_MODES -- VARCHAR(66)
-------ARD 05/3/2022, added Audit task and Audit action to identify online scheduled appts.							
--					, mych.Audit	AS AUDIT_TASK
--					, mych.Action	AS AUDIT_ACTION
--					, mych.AUDIT_TYPE AS AUDIT_TYPE

		  INTO #main

          FROM      CLARITY.dbo.F_SCHED_APPT AS F_SCHED_APPT

                    INNER JOIN CLARITY.dbo.PATIENT PATIENT						
					  ON F_SCHED_APPT.PAT_ID = PATIENT.PAT_ID
                    INNER JOIN CLARITY.dbo.PAT_ENC AS PAT_ENC				
					  ON PAT_ENC.PAT_ENC_CSN_ID = F_SCHED_APPT.PAT_ENC_CSN_ID
                    INNER JOIN CLARITY.dbo.PAT_ENC_4 AS PAT_ENC_4				
					  ON PAT_ENC_4.PAT_ENC_CSN_ID = F_SCHED_APPT.PAT_ENC_CSN_ID

                    LEFT OUTER JOIN CLARITY.dbo.CLARITY_DEP CLARITY_DEP		
					  ON F_SCHED_APPT.DEPARTMENT_ID = CLARITY_DEP.DEPARTMENT_ID

                    LEFT OUTER JOIN CLARITY.dbo.PAT_ENC_3 PAT_ENC_3			
					  ON F_SCHED_APPT.PAT_ENC_CSN_ID = PAT_ENC_3.PAT_ENC_CSN
                    LEFT OUTER JOIN CLARITY.dbo.V_COVERAGE_PAYOR_PLAN V_COVERAGE_PAYOR_PLAN 
					  ON ( ( F_SCHED_APPT.CONTACT_DATE >= V_COVERAGE_PAYOR_PLAN.EFF_DATE )
                            AND
						   ( F_SCHED_APPT.CONTACT_DATE <= V_COVERAGE_PAYOR_PLAN.TERM_DATE )
                         )
                      AND ( F_SCHED_APPT.COVERAGE_ID = V_COVERAGE_PAYOR_PLAN.COVERAGE_ID )
                    LEFT OUTER JOIN CLARITY.dbo.PATIENT_MYC PATIENT_MYC		
					  ON F_SCHED_APPT.PAT_ID = PATIENT_MYC.PAT_ID

                    LEFT OUTER JOIN CLARITY.dbo.CLARITY_SER	AS CLARITY_SER				
					  ON F_SCHED_APPT.PROV_ID = CLARITY_SER.PROV_ID
                    LEFT OUTER JOIN CLARITY.dbo.IDENTITY_ID	AS IDENTITY_ID			
					  ON IDENTITY_ID.PAT_ID = F_SCHED_APPT.PAT_ID AND IDENTITY_ID.IDENTITY_TYPE_ID = 14
					LEFT OUTER JOIN CLARITY.dbo.REFERRAL AS REFERRAL
					  ON REFERRAL.REFERRAL_ID = F_SCHED_APPT.REFERRAL_ID

--------------------
                    LEFT OUTER JOIN CLARITY.dbo.CLARITY_SER_SPEC AS CLARITY_SER_SPEC
					  ON CLARITY_SER_SPEC.PROV_ID = CLARITY_SER.PROV_ID
					    AND CLARITY_SER_SPEC.LINE = 1
                    LEFT OUTER JOIN CLARITY.dbo.REFERRAL_HIST AS REFERRAL_HIST
					  ON REFERRAL_HIST.REFERRAL_ID = REFERRAL.REFERRAL_ID   
					    AND REFERRAL_HIST.CHANGE_TYPE_C  = 1
--------------------

--------------------
--- TMB 7/25/2019 compare CONTACT_DATE to date ranges where provider is documented as a billing provider
---               set default value when CONTACT_TO_DATE is NULL
					LEFT OUTER JOIN CLARITY.dbo.PROV_ATTR_INFO_OT AS PROV_ATTR_INFO_OT
					  ON PROV_ATTR_INFO_OT.PROV_ATTR_ID = CLARITY_SER.PROV_ATTR_ID
					    AND PROV_ATTR_INFO_OT.BILL_PROV_YN = 'Y'
						AND F_SCHED_APPT.CONTACT_DATE BETWEEN PROV_ATTR_INFO_OT.CONTACT_DATE AND COALESCE(PROV_ATTR_INFO_OT.CONTACT_TO_DATE,@locenddate)
--------------------
--------------------

--------------------
--- TMB 1/17/2020 compare CONTACT_DATE to date ranges for OT provider type designation
					LEFT OUTER JOIN CLARITY_App.Rptg.vwCLARITY_SER_OT_PROV_TYPE AS ptot
					  ON F_SCHED_APPT.PROV_ID = ptot.PROV_ID
					    AND F_SCHED_APPT.CONTACT_DATE BETWEEN ptot.CONTACT_DATE AND ptot.EFF_TO_DATE
--------------------
                    LEFT OUTER JOIN CLARITY.dbo.ZC_MYCHART_STATUS AS ZC_MYCHART_STATUS	
					  ON ZC_MYCHART_STATUS.MYCHART_STATUS_C = PATIENT_MYC.MYCHART_STATUS_C
                    LEFT OUTER JOIN CLARITY.dbo.ZC_MYCHART_STATUS AS ZC_MYCHART_STATUS_2	
					  ON ZC_MYCHART_STATUS_2.MYCHART_STATUS_C = F_SCHED_APPT.PAT_SCHED_MYC_STAT_C
                    LEFT OUTER JOIN CLARITY.dbo.ZC_RFL_STATUS AS ZC_RFL_STATUS
                      ON ZC_RFL_STATUS.RFL_STATUS_C = REFERRAL.RFL_STATUS_C
                    LEFT OUTER JOIN CLARITY.dbo.ZC_RFL_TYPE AS ZC_RFL_TYPE
                      ON ZC_RFL_TYPE.RFL_TYPE_C = REFERRAL.RFL_TYPE_C
					LEFT OUTER JOIN CLARITY.dbo.ZC_SPECIALTY AS ZC_SPECIALTY
					  ON ZC_SPECIALTY.SPECIALTY_C = CLARITY_SER_SPEC.SPECIALTY_C
					LEFT OUTER JOIN CLARITY.dbo.ZC_DISP_ENC_TYPE AS ZC_DISP_ENC_TYPE
					  ON ZC_DISP_ENC_TYPE.DISP_ENC_TYPE_C = PAT_ENC.ENC_TYPE_C
					LEFT OUTER JOIN CLARITY.dbo.ZC_SER_RPT_GRP_6 AS ZC_SER_RPT_GRP_6
					  ON ZC_SER_RPT_GRP_6.RPT_GRP_SIX = CLARITY_SER.RPT_GRP_SIX
					LEFT OUTER JOIN CLARITY.dbo.ZC_SER_RPT_GRP_8 AS ZC_SER_RPT_GRP_8
					  ON ZC_SER_RPT_GRP_8.RPT_GRP_EIGHT = CLARITY_SER.RPT_GRP_EIGHT

 ----joins added to eliminate the V_SCHED_APPT view
                    LEFT OUTER JOIN CLARITY.dbo.CLARITY_PRC AS prc 
					  ON F_SCHED_APPT.PRC_ID = prc.PRC_ID
                    LEFT OUTER JOIN CLARITY.dbo.ZC_APPT_BLOCK AS zcblock
					  ON F_SCHED_APPT.APPT_BLOCK_C = zcblock.APPT_BLOCK_C
					LEFT OUTER JOIN CLARITY.dbo.ZC_APPT_STATUS AS zcappt
					  ON F_SCHED_APPT.APPT_STATUS_C = zcappt.APPT_STATUS_C
					LEFT OUTER JOIN CLARITY.dbo.CLARITY_LOC AS loc 
					  ON CLARITY_DEP.rev_loc_id = loc.loc_id
                    LEFT OUTER JOIN CLARITY.dbo.CLARITY_SER AS refprov 
					  ON F_SCHED_APPT.REFERRING_PROV_ID = refprov.PROV_ID
					LEFT OUTER JOIN CLARITY.dbo.ZC_CANCEL_REASON AS canc
					  ON F_SCHED_APPT.CANCEL_REASON_C = canc.CANCEL_REASON_C
					LEFT OUTER JOIN CLARITY.dbo.ZC_PHONE_REM_STAT AS zcrem
					  ON F_SCHED_APPT.PHONE_REM_STAT_C = zcrem.PHONE_REM_STAT_C
					LEFT OUTER JOIN CLARITY.dbo.CLARITY_EMP AS entryemp
					  ON F_SCHED_APPT.APPT_ENTRY_USER_ID = entryemp.USER_ID
                    LEFT OUTER JOIN CLARITY.dbo.CLARITY_EMP AS copayemp
					  ON F_SCHED_APPT.COPAY_USER_ID = copayemp.USER_ID
                    LEFT OUTER JOIN CLARITY.dbo.CLARITY_EMP AS cancemp
					  ON F_SCHED_APPT.APPT_CANC_USER_ID = cancemp.USER_ID
                    LEFT OUTER JOIN CLARITY.dbo.CLARITY_EMP AS confemp
					  ON F_SCHED_APPT.APPT_CONF_USER_ID = confemp.USER_ID

					LEFT OUTER JOIN CLARITY.dbo.ZC_CENTER AS zccenter
					  ON CLARITY_DEP.CENTER_C = zccenter .CENTER_C
					LEFT OUTER JOIN CLARITY.dbo.ZC_APPT_CONF_STAT AS zcconf
					  ON F_SCHED_APPT.APPT_CONF_STAT_C = zcconf.APPT_CONF_STAT_C

----03/04/2022 - ARD - join to add Telehealth Mode flag
					LEFT OUTER JOIN 
						(
						SELECT DISTINCT
						 vt.VISIT_TYPE_ID
						, COALESCE(STUFF((SELECT ', ' + CAST(tm.ALLOWED_TELEHEALTH_MODES_C AS VARCHAR(1))
										  FROM CLARITY..VT_TELEHEALTH_MODES tm
										  WHERE tm.VISIT_TYPE_ID = vt.VISIT_TYPE_ID
										  FOR XML PATH('')),1,1,''),'')	AS 'ALLOWED_TELEHEALTH_MODES'

						FROM CLARITY..VT_TELEHEALTH_MODES vt
						) vt ON PAT_ENC.APPT_PRC_ID = vt.VISIT_TYPE_ID
-------5/2/2022 - ard - join to add online scheduled appointment Flag
					LEFT OUTER JOIN 
						(
						SELECT
							PAT_ENC_ES_AUD_ACT.PAT_ENC_CSN_ID
							,CLARITY_EMP.NAME [Audit]
							,ZC_ES_AUDIT_ACTION.NAME [Action]
							, PAT_ENC_ES_AUD_ACT.LINE
							, PAT_ENC_ES_AUD_ACT.PAT_ONLINE_YN
							, PAT_MYC_SMTP_MSG.MYC_SMTP_ENC_CSN
							, CASE WHEN 	CAST(MYC_SMTP_ENC_CSN AS NUMERIC) IS NOT NULL THEN 'Open Scheduling' 
											ELSE 'Direct Scheduling'
											END AS AUDIT_TYPE

							FROM CLARITY.dbo.PAT_ENC_ES_AUD_ACT
							 LEFT OUTER JOIN CLARITY.dbo.CLARITY_EMP ON PAT_ENC_ES_AUD_ACT.ES_AUDIT_USER_ID=CLARITY_EMP.USER_ID 
							 INNER JOIN CLARITY.dbo.ZC_ES_AUDIT_ACTION ON PAT_ENC_ES_AUD_ACT.ES_AUDIT_ACTION_C=ZC_ES_AUDIT_ACTION.ES_AUDIT_ACTION_C
							 LEFT JOIN CLARITY.dbo.PAT_MYC_SMTP_MSG ON PAT_MYC_SMTP_MSG.MYC_SMTP_ENC_CSN=PAT_ENC_ES_AUD_ACT.PAT_ENC_CSN_ID

							WHERE CLARITY_EMP.NAME = 'MYCHART, GENERIC'
							 AND PAT_ENC_ES_AUD_ACT.ES_AUDIT_ACTION_C IN ( '1' , '8')

						) mych ON F_SCHED_APPT.PAT_ENC_CSN_ID  = mych.PAT_ENC_CSN_ID

					LEFT OUTER JOIN CLARITY.dbo.PAT_ENC_6	 PAT_ENC_6
					  ON F_SCHED_APPT.PAT_ENC_CSN_ID = PAT_ENC_6.PAT_ENC_CSN_ID
					LEFT OUTER JOIN CLARITY.dbo.ZC_TELEHEALTH_MODE ztm
					  ON ZTM.TELEHEALTH_MODE_C = PAT_ENC_6.TELEHEALTH_MODE_C

       --             LEFT OUTER JOIN CLARITY.dbo.CLARITY_SER_ADDR	AS CLARITY_SER_ADDR				
					  --ON F_SCHED_APPT.PROV_ID = CLARITY_SER_ADDR.PROV_ID
					LEFT OUTER JOIN CLARITY.dbo.CLARITY_EMP AS provemp
					  ON CLARITY_SER.USER_ID = provemp.USER_ID

					LEFT OUTER JOIN [CLARITY].[dbo].[CLARITY_EMP_DEMO] CLARITY_EMP_DEMO
					  ON CLARITY_EMP_DEMO.USER_ID = CLARITY_SER.USER_ID

		  WHERE F_SCHED_APPT.APPT_DTTM >= @locstartdate
		  AND F_SCHED_APPT.APPT_DTTM <= @locenddate
		  AND F_SCHED_APPT.APPT_STATUS_C = 2 -- Completed
		  AND PAT_ENC_6.TELEHEALTH_MODE_C = 2 -- Video
					 
		  --WHERE F_SCHED_APPT.PAT_ENC_CSN_ID = 200050666630

		  --WHERE F_SCHED_APPT.PAT_ENC_CSN_ID IN (200050666630,200050665377,200050661365)

		  --WHERE ZC_DISP_ENC_TYPE.NAME LIKE '%TELEMEDICINE%'

		  --WHERE ztm.NAME IN ('Video','Clinic to Clinic Video','Telephone')
		  --WHERE ztm.NAME IN ('Video','Clinic to Clinic Video')
		  --AND F_SCHED_APPT.APPT_STATUS_C = 2

SELECT
	*
	--PAT_ENC_CSN_ID,
 --   PAT_ID,
 --   PAT_NAME,
 --   IDENTITY_ID,
 --   MYCHART_STATUS_C,
 --   MYCHART_STATUS_NAME,
 --   VIS_NEW_TO_SYS_YN,
 --   VIS_NEW_TO_DEP_YN,
 --   VIS_NEW_TO_PROV_YN,
 --   APPT_SERIAL_NUM,
 --   RESCHED_APPT_CSN_ID,
 --   PRC_ID,
 --   PRC_NAME,
 --   APPT_BLOCK_C,
 --   APPT_BLOCK_NAME,
 --   APPT_LENGTH,
 --   APPT_STATUS_C,
 --   APPT_STATUS_NAME,
 --   APPT_CONF_STAT_C,
 --   CANCEL_LEAD_HOURS,
 --   CANCEL_INITIATOR,
 --   COMPLETED_STATUS_YN,
 --   SAME_DAY_YN,
 --   SAME_DAY_CANC_YN,
 --   CANCEL_REASON_C,
 --   CANCEL_REASON_NAME,
 --   WALK_IN_YN,
 --   OVERBOOKED_YN,
 --   OVERRIDE_YN,
 --   UNAVAILABLE_TIME_YN,
 --   CHANGE_CNT,
 --   JOINT_APPT_YN,
 --   PHONE_REM_STAT_C,
 --   PHONE_REM_STAT_NAME,
 --   CONTACT_DATE,
 --   APPT_MADE_DATE,
 --   APPT_CANC_DATE,
 --   APPT_CONF_DTTM,
 --   APPT_DTTM,
 --   SIGNIN_DTTM,
 --   PAGED_DTTM,
 --   BEGIN_CHECKIN_DTTM,
 --   #main.CHECKIN_DTTM,
 --   ARVL_LIST_REMOVE_DTTM,
 --   ROOMED_DTTM,
 --   FIRST_ROOM_ASSIGN_DTTM,
 --   NURSE_LEAVE_DTTM,
 --   PHYS_ENTER_DTTM,
 --   VISIT_END_DTTM,
 --   CHECKOUT_DTTM,
 --   #main.CHECKIN_DTTM,
 --   TIME_TO_ROOM_MINUTES,
 --   TIME_IN_ROOM_MINUTES,
 --   CYCLE_TIME_MINUTES,
 --   REFERRING_PROV_ID,
 --   REFERRING_PROV_NAME_WID,
 --   PROV_ID,
 --   PROV_NAME_WID,
 --   RPT_GRP_FIVE,
 --   APPT_ENTRY_USER_ID,
 --   APPT_ENTRY_USER_NAME_WID,
 --   PROV_NAME,
 --   PAYOR_ID,
 --   PAYOR_NAME,
 --   BENEFIT_PLAN_ID,
 --   BENEFIT_PLAN_NAME,
 --   FIN_CLASS_NAME,
 --   DO_NOT_BILL_INS_YN,
 --   SELF_PAY_VISIT_YN,
 --   HSP_ACCOUNT_ID,
 --   ACCOUNT_ID,
 --   COPAY_DUE,
 --   COPAY_COLLECTED,
 --   COPAY_USER_ID,
 --   COPAY_USER_NAME_WID,
 --   DEPARTMENT_ID,
 --   DEPARTMENT_NAME,
 --   DEPT_ABBREVIATION,
 --   RPT_GRP_THIRTY,
 --   RPT_GRP_SIX,
 --   RPT_GRP_SEVEN,
 --   DEPT_SPECIALTY_C,
 --   DEPT_SPECIALTY_NAME,
 --   CENTER_C,
 --   CENTER_NAME,
 --   LOC_ID,
 --   LOC_NAME,
 --   SERV_AREA_ID,
 --   APPT_STATUS_FLAG,
 --   VIS_NEW_TO_SPEC_YN,
 --   VIS_NEW_TO_SERV_AREA_YN,
 --   VIS_NEW_TO_LOC_YN,
 --   REFERRAL_ID,
 --   ENTRY_DATE,
 --   RFL_STATUS_NAME,
 --   RFL_TYPE_NAME,
 --   PROV_SPECIALTY_C,
 --   PROV_SPECIALTY_NAME,
 --   APPT_DT,
 --   ENC_TYPE_C,
 --   ENC_TYPE_TITLE,
 --   APPT_CONF_STAT_NAME,
 --   ZIP,
 --   SER_RPT_GRP_SIX,
 --   SER_RPT_GRP_EIGHT,
 --   F2F_Flag,
 --   APPT_CANC_DTTM,
 --   APPT_CANC_USER_ID,
 --   APPT_CANC_USER_NAME_WID,
 --   APPT_CONF_USER_ID,
 --   APPT_CONF_USER_NAME,
 --   CHANGE_DATE,
 --   APPT_MADE_DTTM,
 --   ETL_guid,
 --   UPDATE_DATE,
 --   BILL_PROV_YN,
 --   PROV_TYPE_OT_NAME,
 --   PAT_SCHED_MYC_STAT_C,
 --   PAT_SCHED_MYC_STAT_NAME,
 --   ALLOWED_TELEHEALTH_MODES,
 --   AUDIT_TASK,
 --   AUDIT_ACTION,
 --   AUDIT_TYPE,
 --   TELEHEALTH_MODE_C,
 --   TELEHEALTH_MODE_NAME,
	--app_flag
FROM #main
--WHERE DEPARTMENT_ID IN (10354031,10354032,10354033)
--AND APPT_STATUS_NAME IN ('Arrived','Completed')
--AND F2F_Flag = 1
--ORDER BY DEPARTMENT_ID,
--         APPT_DTTM
--ORDER BY APPT_STATUS_NAME,
--         ENC_TYPE_TITLE,
--         DEPARTMENT_ID,
--         APPT_DTTM
--ORDER BY PROV_ID, CLARITY_SER_ADDR_LINE, PAT_ENC_CSN_ID
--ORDER BY PROV_ID, PAT_ENC_CSN_ID
--ORDER BY PAT_ENC_CSN_ID
ORDER BY
	SYSTEM_LOGIN,
	EMAIL,
	PROV_NAME,
	DEPT_SPECIALTY_NAME,
	DEPARTMENT_NAME,
	PROV_TYPE,
	app_flag,
	PAT_ENC_CSN_ID

SELECT
	SYSTEM_LOGIN AS Computing_Id,
	EMAIL AS Email_Address,
	PROV_NAME AS Provider_Name,
	DEPT_SPECIALTY_NAME AS Department_Specialty,
	DEPARTMENT_NAME AS Department,
	PROV_TYPE AS Provider_Type,
	app_flag AS APP_Flag,
	COUNT(*) AS Completed_Video_Visits
FROM #main
GROUP BY
	SYSTEM_LOGIN,
	EMAIL,
	PROV_NAME,
	DEPT_SPECIALTY_NAME,
	DEPARTMENT_NAME,
	PROV_TYPE,
	app_flag
ORDER BY
	SYSTEM_LOGIN,
	EMAIL,
	PROV_NAME,
	DEPT_SPECIALTY_NAME,
	DEPARTMENT_NAME,
	PROV_TYPE,
	app_flag

GO


