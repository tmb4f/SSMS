USE [CLARITY_App]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [Rptg].[uspSrc_Scheduled_Appointment_Actions_Recall]
       (
        @StartDate SMALLDATETIME = NULL,
        @EndDate SMALLDATETIME = NULL,
		@DepartmentGrouperColumn VARCHAR(12),
		@DepartmentGrouperNoValue VARCHAR(25),
        @in_pods_servLine VARCHAR(MAX),
        @in_depid VARCHAR(MAX)
	   )
AS
/****************************************************************************************************************************************
WHAT: Create procedure Rptg.uspSrc_Scheduled_Appointment_Actions_Recall
WHO : Tom Burgan
WHEN: 06/18/2019
WHY : Recall appointment action report
----------------------------------------------------------------------------------------------------------------------------------------
INFO:
      INPUTS:   CLARITY_App.ETL.fn_ParmParse
				CLARITY.dbo.CL_SSA
				CLARITY.dbo.CLARITY_DEP
				CLARITY_App.Rptg.vwRef_MDM_Location_Master_EpicSvc

      OUTPUTS:
                CLARITY_App.Rptg.uspSrc_Scheduled_Appointment_Actions_Recall
----------------------------------------------------------------------------------------------------------------------------------------
MODS:     06/18/2019--TMB-- Create new stored procedure
          07/31/2019--TMB-- Edit grouper column logic
*****************************************************************************************************************************************/

  SET NOCOUNT ON;

---------------------------------------------------
---Default recall date range is the current FYTD
  DECLARE @CurrDate SMALLDATETIME;

  SET @CurrDate = CAST(CAST(GETDATE() AS DATE) AS SMALLDATETIME);
    
  IF @StartDate IS NULL
      BEGIN
		SET @StartDate=CASE WHEN DATEPART(mm, @CurrDate)<7 
 	                        THEN CAST('07/01/'+CAST(DATEPART(yy, @CurrDate)-1 AS CHAR(4)) AS SMALLDATETIME)
                            ELSE CAST('07/01/'+CAST(DATEPART(yy, @CurrDate) AS CHAR(4)) AS SMALLDATETIME)
                       END;
	  END;

  IF @EndDate IS NULL
      BEGIN
        SET @EndDate = CAST(CAST(DATEADD(DAY, -1, @CurrDate) AS DATE) AS SMALLDATETIME);
      END;
----------------------------------------------------

DECLARE @locstartdate SMALLDATETIME,
        @locenddate SMALLDATETIME

SET @locstartdate = @StartDate
SET @locenddate   = @EndDate

DECLARE @SelectString NVARCHAR(4000),
		@ParmDefinition NVARCHAR(500)

SET @SelectString = N';WITH cte_pods_servLine (pod_Service_Line)
AS
(
SELECT Param FROM CLARITY_App.ETL.fn_ParmParse(@PodServiceLine, '','')
)
,cte_depid (DepartmentId)
AS
(
SELECT Param FROM CLARITY_App.ETL.fn_ParmParse(@DepartmentId, '','')
)
SELECT CAST(''Recall Action'' AS VARCHAR(50)) AS event_type,
       1 AS event_count,
	   evnts.RECALL_DT AS event_date,
       evnts.fmonth_num,
       evnts.Fyear_num,
       evnts.FYear_name,
       CAST(LEFT(DATENAME(MM, evnts.day_date), 3) + '' '' + CAST(DAY(evnts.day_date) AS VARCHAR(2)) AS VARCHAR(10)) AS report_period,
       CAST(CAST(evnts.day_date AS DATE) AS SMALLDATETIME) AS report_date,
       evnts.POD_ID AS pod_id,
       evnts.PFA_POD AS pod_name,
       evnts.DEP_ID AS epic_department_id,
       evnts.epic_department_name,
       evnts.epic_department_name_external,
       CAST(evnts.PAT_MRN_ID AS INTEGER) AS person_id,
       evnts.PAT_NAME AS person_name,
       evnts.PROV_ID AS provider_id,
       evnts.PROV_NAME AS provider_name,
       evnts.service_line_id,
       evnts.service_line,
	   evnts.ACTION_ID,
	   evnts.RECALL_EXPIRE_DT,
	   evnts.RECALL_NOTIF_DATE,
	   evnts.REC_STAT_HX_INST,
	   evnts.REC_STAT_HX_EMP_NAME,
	   evnts.LINE

FROM
(
	SELECT ssa.[ACTION_ID]
		  ,ssa.[PAT_ID]
		  ,ssa.[RECALL_EXPIRE_DT]
		  ,ssa.[RECALL_NOTIF_DATE]
		  ,ssa.RECALL_DT
		  ,date_dim.day_date
		  ,date_dim.fmonth_num
		  ,date_dim.Fyear_num
		  ,date_dim.FYear_name
		  ,pat.PAT_NAME
		  ,pat.PAT_MRN_ID
		  ,ssahx.REC_STAT_HX_INST
		  ,ssahx.REC_STAT_HX_EMP_NAME
		  ,ssapd.LINE
		  ,ssapd.PROV_ID
		  ,ssapd.PROV_NAME
		  ,ssapd.DEP_ID
		  ,mdm.epic_department_name
		  ,mdm.epic_department_name_external
		  ,mdm.service_line_id
		  ,mdm.service_line
		  ,mdm.POD_ID
		  ,mdm.PFA_POD
    FROM CLARITY.[dbo].[CL_SSA] ssa
    LEFT OUTER JOIN
    (
	    SELECT day_date,
               fmonth_num,
               Fyear_num,
               FYear_name
        FROM CLARITY_App.Rptg.vwDim_Date
    ) date_dim
	ON (date_dim.day_date = CAST(ssa.RECALL_DT AS SMALLDATETIME))
    LEFT OUTER JOIN CLARITY.dbo.PATIENT pat
    ON pat.PAT_ID = ssa.PAT_ID
	LEFT OUTER JOIN
	(   SELECT hx.[ACTION_ID]
              ,hx.[REC_STAT_HX_INST]
              ,hx.[REC_STAT_HX_EMP_ID]
	          ,emp.NAME AS [REC_STAT_HX_EMP_NAME]
        FROM CLARITY.[dbo].[CL_SSA_RECALL_HX] hx
        LEFT OUTER JOIN CLARITY.dbo.CLARITY_EMP emp
        ON emp.USER_ID = hx.REC_STAT_HX_EMP_ID
	    WHERE hx.RECALL_STAT_HX_C = 10
	) ssahx
	ON ssahx.ACTION_ID = ssa.ACTION_ID
	LEFT OUTER JOIN
	(
	    SELECT pd.[ACTION_ID]
              ,pd.[LINE]
	          ,pd.PROV_ID
	          ,ser.PROV_NAME
	          ,pd.DEP_ID
        FROM CLARITY.[dbo].[CL_SSA_PROV_DEPT] pd
        LEFT OUTER JOIN CLARITY.dbo.CLARITY_SER ser
        ON ser.PROV_ID = pd.PROV_ID
        LEFT OUTER JOIN CLARITY.dbo.CLARITY_DEP dep
        ON dep.DEPARTMENT_ID = pd.DEP_ID
        WHERE pd.LINE = 1
        OR (pd.LINE > 1 AND pd.PROV_ID IS NOT NULL)
    ) ssapd
    ON ssapd.ACTION_ID = ssa.ACTION_ID
    LEFT OUTER JOIN CLARITY_App.Rptg.vwRef_MDM_Location_Master_EpicSvc mdm
    ON ssapd.DEP_ID = mdm.epic_department_id
) evnts

WHERE (evnts.RECALL_DT >= @RecallStartDate
AND evnts.RECALL_DT <= @RecallEndDate) AND (COALESCE(evnts.' + @DepartmentGrouperColumn + ',''' + @DepartmentGrouperNoValue + ''') IN (SELECT pod_Service_Line FROM cte_pods_servLine)) AND (evnts.DEP_ID IN (SELECT DepartmentId FROM cte_depid))
ORDER BY evnts.RECALL_DT';
SET @ParmDefinition = N'@RecallStartDate SMALLDATETIME, @RecallEndDate SMALLDATETIME, @PodServiceLine VARCHAR(MAX), @DepartmentId VARCHAR(MAX)';
EXECUTE sp_executesql @SelectString, @ParmDefinition, @RecallStartDate=@locstartdate, @RecallEndDate=@locenddate, @PodServiceLine=@in_pods_servLine, @DepartmentId=@in_depid;

GO


