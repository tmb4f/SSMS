USE CLARITY

DECLARE @StartDate AS DATETIME
DECLARE @EndDate AS DATETIME

--WITH dates AS(
--select '9/1/2022 00:00 AM' AS StartDate, 
--         '2/28/2023 11:59 PM' as EndDate,
--         MIN(ddend.tomorrow_dt) as EndDateExcl
--		 from clarity..DATE_DIMENSION ddend
--  where ddend.CALENDAR_DT = '2/28/2023 11:59 PM'
--  )

SET @StartDate = '9/1/2022 00:00 AM'
SET @EndDate = '2/28/2023 11:59 PM'

  --SELECT *
  --FROM dates

; WITH
availbase as (
   select 
          avail.department_id, 
		  department_name = avail.DEPARTMENT_NAME,
		  department_service_line = CLARITY_DEP.RPT_GRP_THIRTY ,
		   pod_name = ZC_DEP_RPT_GRP_6.name ,
		  --avail.DEPT_SPECIALTY_NAME,
          		  avail.prov_id, 
		  provider = PROV_NM_WID,
		  provider_type = ZC_PROV_TYPE.NAME,
          person_or_resource = avail.PROV_SCHED_TYPE_NAME,
		  dd.day_of_week,
          slot_date,
		  slot_begin_time, 
		  slot_length,
		  booked_length=V_SCHED_APPT.APPT_LENGTH,
		  appt_slot_number = appt_number, 
          num_apts_scheduled, 
		  regular_openings = org_reg_openings,
		  overbook_openings = ORG_OVBK_OPENINGS, 
		  template_block_name = avail.APPT_BLOCK_NAME, 
		  unavailable_reason = dbo.ZC_UNAVAIL_REASON.NAME,
          overbook_yn = COALESCE(appt_overbook_yn, 'N'), 
          outside_template_yn = COALESCE(outside_template_yn, 'N'), 
		  held_yn = case when coalesce(avail.day_held_rsn_c, avail.time_held_rsn_c) is null
							THEN 'N'
							ELSE 'Y'
					 END,
  
            MRN= IDENTITY_ID.IDENTITY_ID ,	
           visit_type = V_SCHED_APPT.PRC_NAME,
           appt_status = V_SCHED_APPT.APPT_STATUS_NAME
            --V_SCHED_APPT.COMPLETED_STATUS_YN ,
            --V_SCHED_APPT.SAME_DAY_YN ,
            --V_SCHED_APPT.JOINT_APPT_YN 
            

    from v_availability avail 
	--INNER join dates on avail.SLOT_BEGIN_TIME >= dates.StartDate and 
 --                                     avail.SLOT_BEGIN_TIME < dates.EndDateExcl

	INNER join DATE_DIMENSION dd								ON avail.SLOT_DATE = dd.CALENDAR_DT
	LEFT OUTER JOIN CLARITY..CLARITY_SER						ON avail.PROV_ID = CLARITY_SER.PROV_ID
	LEFT OUTER JOIN clarity..CLARITY_DEP						ON clarity_dep.DEPARTMENT_ID = avail.DEPARTMENT_ID              
	LEFT OUTER JOIN clarity..ZC_DEP_RPT_GRP_6					ON CLARITY_DEP.RPT_GRP_SIX=ZC_DEP_RPT_GRP_6.RPT_GRP_SIX
	LEFT OUTER JOIN clarity..ZC_DEP_RPT_GRP_7					ON CLARITY_DEP.RPT_GRP_seven=ZC_DEP_RPT_GRP_7.RPT_GRP_seven

	LEFT OUTER JOIN clarity..V_SCHED_APPT						ON v_sched_appt.PAT_ENC_CSN_ID = avail.PAT_ENC_CSN_ID
	LEFT outer JOIN CLARITY..PATIENT PATIENT					ON V_SCHED_APPT.PAT_ID = PATIENT.PAT_ID
            
	LEFT OUTER JOIN CLARITY..IDENTITY_ID						ON IDENTITY_ID.PAT_ID = V_SCHED_APPT.PAT_ID AND IDENTITY_ID.IDENTITY_TYPE_ID = 14
	LEFT OUTER JOIN clarity..ZC_UNAVAIL_REASON					ON zc_unavail_reason.UNAVAILABLE_RSN_C = avail.UNAVAILABLE_RSN_C
	LEFT OUTER JOIN clarity..ZC_PROV_TYPE					    ON zc_prov_type.PROV_TYPE_C = clarity_ser.PROVider_TYPE_C

   where 1=1
   --AND slot_begin_time >=  dates.StartDate  
   --AND  SLOT_BEGIN_TIME < dates.EndDateExcl
   AND slot_begin_time >=  @StartDate  
   AND  SLOT_BEGIN_TIME <= @EndDate

)

SELECT * FROM availbase
where  department_id in (
10242051, -- UVPC DIGESTIVE HEALTH
10243003, -- UVHE DIGESTIVE HEALTH
10246004, -- WALL MED DH FAM MED
10210028) -- ECCC MED DHC EAST CL
ORDER BY
	availbase.DEPARTMENT_ID,
	availbase.PROV_ID,
	availbase.SLOT_DATE,
	availbase.SLOT_BEGIN_TIME

