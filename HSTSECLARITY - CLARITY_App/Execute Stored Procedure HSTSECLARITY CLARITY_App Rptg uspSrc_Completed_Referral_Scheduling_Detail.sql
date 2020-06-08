USE [CLARITY_App]
GO

DECLARE @RC INT
DECLARE @StartDate SMALLDATETIME
DECLARE @EndDate SMALLDATETIME
DECLARE @DepartmentGrouperColumn VARCHAR(12)
DECLARE @DepartmentGrouperNoValue VARCHAR(25)
DECLARE @in_pods_servLine VARCHAR(MAX)
DECLARE @in_depid VARCHAR(MAX)

-- TODO: Set parameter values here.

SET @StartDate = '7/1/2019'
SET @EndDate = '3/23/2020'
SET @DepartmentGrouperColumn = 'service_line'
SET @DepartmentGrouperNoValue = '(No Service Line Defined)'
SET @in_pods_servLine = 'Unknown'
SET @in_depid = '10228012'

EXECUTE @RC = [Rptg].[uspSrc_Completed_Referral_Scheduling_Detail] 
   @StartDate
  ,@EndDate
  ,@DepartmentGrouperColumn
  ,@DepartmentGrouperNoValue
  ,@in_pods_servLine
  ,@in_depid
GO


