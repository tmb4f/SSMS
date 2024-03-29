USE DS_HSDW_Prod

IF OBJECT_ID('tempdb..#census') IS NOT NULL
DROP TABLE #census

IF OBJECT_ID('tempdb..#unique') IS NOT NULL
DROP TABLE #unique

IF OBJECT_ID('tempdb..#xtr') IS NOT NULL
DROP TABLE #xtr

SELECT [EVENT_ID]
      ,[PAT_ENC_CSN_ID]
      ,[sk_Fact_Pt_Enc_Clrt]
      ,census.[sk_Dim_Pt]
	  ,pt.MRN_int
      ,[HSP_ACCOUNT_ID]
      ,[AcctNbr_Clrt]
      ,[ADT_In_Dtm]
      ,[sk_ADT_In_Dte]
      ,[sk_ADT_In_Tm]
      ,[ADT_Out_Dtm]
      ,[sk_ADT_Out_Dte]
      ,[sk_ADT_Out_Tm]
      ,[Enter_Dtm]
      ,[sk_ADT_Enter_Dte]
      ,[sk_ADT_Enter_Tm]
      ,[Hsp_Adm_Event_Id]
      ,[Hsp_Dis_Event_Id]
      ,[Xfer_in_Event_Id]
      ,[Xfer_Out_Event_Id]
      ,census.[sk_Dim_Clrt_DEPt]
	  ,dep.DEPARTMENT_ID
	  ,dep.Clrt_DEPt_Nme
	  ,mdm.SERVICE_LINE
      ,[sk_Dim_Clrt_Rm]
      ,[sk_Dim_Clrt_Bed]
      ,[Envt_Sub_Nme]
      ,[Fr_Base_Cls]
      ,[To_Base_Cls]
      ,[Labor_Sts]
      ,[sk_Dim_AccountClass]
      ,[sk_Dim_HospitalService]
      ,[sk_Dim_Clrt_ADT_Evnt]
      ,[sk_ADT_Evnt_In]
      ,[sk_ADT_Evnt_Out]
      ,[Seq_Num_in_Enc]
      ,[Seq_Num_in_Bed_Min]
      ,[Admit]
      ,[Discharge]
      ,[Pt_Days]
      ,[Occ_Minutes]
      ,census.[Load_Dtm]
      ,census.[ETL_GUID]
      ,census.[UpDte_Dtm]
      ,[Cancelled]
      ,[sk_Dim_BedUnit]
      ,[First_IP_in_IP_YN]
      ,[TO_BASE_CLASS_C]
      ,[FROM_BASE_CLASS_C]

  INTO #census

  FROM [dbo].[Fact_Clrt_ADT_Census] census
  LEFT OUTER JOIN dbo.Dim_Clrt_DEPt dep
  ON census.sk_Dim_Clrt_DEPt = dep.sk_Dim_Clrt_DEPt
  LEFT OUTER JOIN dbo.Dim_Clrt_Pt pt
  ON pt.sk_Dim_Pt = census.sk_Dim_Pt
  LEFT OUTER JOIN dbo.Ref_MDM_Location_Master mdm
  ON mdm.EPIC_DEPARTMENT_ID = dep.DEPARTMENT_ID
  WHERE sk_Dim_Clrt_ADT_Evnt = 6 -- Census
  --AND sk_ADT_In_Dte BETWEEN 20210424 AND 20210425
  AND sk_ADT_In_Dte >= 20230701
  --AND Fr_Base_Cls = 'IP'
  AND Cancelled = 0

  SELECT census.*
                ,ROW_NUMBER() OVER (PARTITION BY census.ADT_In_Dtm, census.AcctNbr_Clrt ORDER BY census.AcctNbr_Clrt) AS 'Seq'

  INTO #unique

  FROM #census census
    
  SELECT
	sk_ADT_TransferCenterExternalTransfers,
    TransferID,
    IntakeCSN,
    AdmissionCSN,
    EntryTime,
    EntryStaffID,
    EntryStaffLogon,
    CaseOwnerID,
    CaseOwnerLogon,
    IsOpen,
    AcctNbrint,
    PatientMR,
    PatientLastName,
    PatientFirstName,
    PatientMiddleName,
    PatientSuffix,
    AddressStreet,
    AddressCity,
    AddressState,
    AddressZip,
    AdtPatientID,
    PatientDOB,
    EMTALACase,
    TierLevel,
    [Isolation],
    ReferringPhysicianID,
    referringProviderName,
    ReferringFacilityID,
    Referring_Facility,
    TransferReasonID,
    TransferReason,
    TransferModeID,
    TransferMode,
    DiagnosisID,
    Diagnosis,
    VITALS_TAKEN_TM,
    BP_SYSTOLIC,
    BP_DIASTOLIC,
    PULSE,
    RESPIRATIONS,
    TEMPERATURE,
    TempSourceID,
    TemperatureSource,
    SPO2,
    HeadCircumference,
    PEAK_FLOW,
    PainScoreID,
    PatientPainScore,
    PainLocationID,
    PatientPainLocation,
    ExcludedinGrowthChart,
    ReportedAllergies,
    ServiceRequestedID,
    ServiceNme,
    LevelOfCareID,
    LevelOfCare,
    TransferTypeID,
    TransferType,
    XTPlacementID,
    PlacementStatusID,
    PlacementStatusName,
    XTPlacementStatusID,
    XTPlacementStatusName,
    XTPlacementStatusDateTime,
    ETA,
    PatientReferredTo,
    AdtPatientFacilityID,
    AdtPatientFacility,
    DestinationUnitID,
    DestinationUnit,
    XTAssignedBedID,
    BedAssigned,
    BedType,
    DispositionReasonID,
    DispositionReason,
    DispositionID,
    Disposition,
    Accepting_Timestamp,
    Accepting_MD,
    AcceptingMD_ServiceLine,
    CloseTime,
    XTLastModDate,
    LastModUserId,
    LastModUserLogon,
    [Status],
    PatientTypeID,
    PatientType,
    PatientMiddleInitial,
    ProtocolNme,
    LastName,
    FirstName,
    MiddleName,
    PatientWeight,
    PatientHieght,
    BedTypeID,
    Load_Dtm,
    Update_Dtm,
    AcceptingMD_ID,
    TransferTypeHx

  INTO #xtr

  FROM DS_HSDM_Prod.Rptg.ADT_TransferCenter_ExternalTransfers
  WHERE EntryTime >= '7/1/2023'

  SELECT 
         CAST(ADT_In_Dtm AS DATE) AS Census_Effective_Date,
         AcctNbr_Clrt AS Account_Number,
         HSP_ACCOUNT_ID,
         sk_Dim_Pt,
         MRN_int AS MRN,
         DEPARTMENT_ID AS Department_Id,
         Clrt_DEPt_Nme AS Department_Name,
		 SERVICE_LINE AS Service_Line,
		 Fr_Base_Cls AS Patient_Class,
         PAT_ENC_CSN_ID AS CSN,
		 ADT_In_Dtm AS Event_Time,
		 tc.AdmissionCSN,
		 tc.Referring_Facility,
		 tc.TransferType,
		 tc.TransferTypeHx,
		 tc.Disposition
  FROM #unique census
  LEFT OUTER JOIN #xtr tc
  ON tc.AdmissionCSN = census.PAT_ENC_CSN_ID
  WHERE census.Seq = 1
  ORDER BY sk_ADT_In_Dte
                    , sk_ADT_In_Tm
					, Department_Name
