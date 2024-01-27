USE [CLARITY_App]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

DECLARE @startdate DATETIME = NULL, 
	@enddate DATETIME = NULL

SET @startdate = '7/1/2022 00:00 AM'
SET @enddate = '10/31/2022 11:59 PM'

--EXEC [ETL].[UspSrc_ADT_TransferCenter_ExternalTransfers] '1/1/2019','4/22/2019'

--ALTER PROCEDURE [ETL].[UspSrc_ADT_TransferCenter_ExternalTransfers]
--(
--	@startdate DATETIME = NULL, 
--	@enddate DATETIME = NULL
--)
--AS
-- =============================================

/*******************************************************************************************
WHAT:	ADT_TransferCenter_ExternalTransfers
WHO :	EDM (Replace TeleTracking data)
WHEN:	
WHY :		All External Transfers
			Replace TeleTracking data
AUTHOR:		Mali Amarasinghe
SPEC:	
--------------------------------------------------------------------------------------------
INPUTS: 	        
Clarity- Grand Central Transfer Center Module
		
OUTPUTS: 
   	1) SEQUENCE:				File 1 of 1
   	2) FILE NAMING CONVENTION:	
   	3) OUTPUT TYPE:				Rptg.ADT_TransferCenter_ExternalTransfers
   	4) TRANSFER METHOD:			
   	5) OUTPUT LOCATION:			HSTSDSSQLDM.DS_HSDM_Prod
								
   	6) FREQUENCY:				Daily
   	7) QUERY LOOKBACK PERIOD:	last day
   	8) FILE SPECIFIC NOTES:		
NOTES:

--------------------------------------------------------------------------------------------
MODS: 
	03/15/2019 --Initial Draft  Mali A.

    04/09/2019 - BDD - Marked some Joins that cannot be used in production.	
	04/12/2019 - Mali A --Updated to remove derived tables
						--Add AND dsttxf.line='1'  --first admission insatant 
									--Add filter to remove cancelled pre-admissions
									Replace PAT_ID and Prov_ID with MRN and NPI. View for Teletracknig has these values as INT, cannot convert some PAT_ID and Prov
									_ID to INT.--04/23/2019
	05/28/2019 - Mali A --Change XTPlacementStatusName, and XTPlacementStatusDateTime to NCS 11120/NCS11121- TRansfer Audit Records
	06/05/2019 - Mali A. -- Add Clarity_POS to coalesce Referring Facility Name and free Text referring facility
	06/10/2019 - Mali A. --ADD free text doagnosis (ncs 11090)
	06/27/2019 - <ali A. --Modify Protocol: If flowsheet value is not populated, extract from patient service
*******************************************************************************************/

	SET NOCOUNT ON;

		
	IF @startdate IS NULL
    AND @enddate IS NULL
    BEGIN
	--Set Parameter Values
	   
	    SET @enddate = CAST(CAST(GETDATE() AS DATE) AS DATETIME) 
		SET @startdate = DATEADD(dd,-1,@enddate)


	END;

DECLARE @locstartdate DATETIME,
        @locenddate DATETIME
SET @locstartdate = @startdate
SET @locenddate   = @enddate



	
	SELECT 
		txf.COMM_ID				'TransferID'

		,txf.REQUESTED_ZONE_C
		,txf.REQUESTED_DEST_COMM_ID
		,txf.REQUESTED_DEST_LOC_ID
		,txf.REQUESTED_DEST_DECLINE_CAT_C
		,txf.REQUESTED_DEST_IS_EXTERNAL_YN
		,txf.TARGET_DEST_COMM_ID
		,txf.TARGET_DEST_LOC_ID
		,txf.TARGET_DEST_IS_EXTERNAL_YN
		,txf.REFERRING_ZONE_C
		,txf.REFERRING_LOC_ID
		,txf.REFERRING_LOC_IS_EXTERNAL_YN

          ----BDD 03/25/2019 - Status CASE added by Mali 
		,CAST(CASE WHEN (flshtpvt.[7246] ='Tier 5'
               OR txfsvc.TRANS_FIN_ACCEPTED_YN= 'N')
             THEN 'Active'
             ELSE 'Inactive'
          END AS VARCHAR(25)) AS [Status]

		,inttxf.ATCHMENT_TYPE_C AS inttfx_ATCHMENT_TYPE_C
		,dsttxf.ATCHMENT_TYPE_C AS dsttxf_ATCHMENT_TYPE_C

		,inttxf.ATCHMENT_PT_CSN_ID  'IntakeCSN'
		,dsttxf.ATCHMENT_PT_CSN_ID	'AdmissionCSN'
		,cst.RECORD_ENTRY_TIME		'EntryTime'
		,cst.ENTRY_USER_ID			'EntryStaffID'
		,entemp.SYSTEM_LOGIN		'EntryStaffLogon'
		,cst.CRM_CUR_OWNER_ID		'CaseOwnerID'
		,crmemp.SYSTEM_LOGIN		'CaseOwnerLogon'
		,CASE WHEN CAST(txf.TRANSFER_RESOLUTION_UTC_DTTM AS VARCHAR(108)) IS NULL 
				THEN 'TRUE'
				ELSE 'FALSE'
				END					'IsOpen'
		,hsp.HSP_ACCOUNT_ID			'AcctNbrint'
		,idx.IDENTITY_ID			'PatientMR'
		,hsp.ADT_PAT_CLASS_C		'PatientTypeID'  --replace PatientType
		,ptcls.NAME					'PatientType'

		,pt.PAT_LAST_NAME			'PatientLastName'
		,pt.PAT_FIRST_NAME			'PatientFirstName'
		,pt.PAT_MIDDLE_NAME			'PatientMiddleName'
		,LEFT(pt.PAT_MIDDLE_NAME,1)			'PatientMiddleInitial'
		,pt.PAT_NAME_SUFFIX_C		'PatientSuffix'
		,CONCAT(addrs1.ADDRESS,addrs2.ADDRESS)				'AddressStreet'
		,pt.CITY					'AddressCity'
		,ptst.NAME					'AddressState'
		,pt.ZIP						'AddressZip'
		,CAST(idx.IDENTITY_ID	 AS INT)				'AdtPatientID'
		,pt.BIRTH_DATE				'PatientDOB'
		,txfsvc.REQUEST_IS_EMTALA_YN	'EMTALACase'   -- Transfer Center request falls under Emergency Medical Treatment and Labor Act

		,txfsvc.DEST_DECLINE_RSN_C
		,txfsvc.DEST_DECLINE_CAT_C
		,txfsvc.DEST_LOC_ID
		,txfsvc.TRANS_PAT_POINT_OF_ORIGIN_C
		,txfsvc.TRANS_REASON_C

		,flshtpvt.[7246]			'TierLevel'

		,COALESCE(CAST(flshtpvt.[7247] AS VARCHAR(254)),ptsvc.NAME)		'ProtocolNme' --If flowsheet value is not populated, extract from patient service

		,flshtpvt.[7269]			'Isolation'
		,CAST(serid.IDENTITY_ID AS INT)	'ReferringPhysicianID'
		,refingprov.PROV_NAME		'referringProviderName'
		-----
		,LastName = CONVERT(VARCHAR(50), CASE -- Split refingprov.PROV_NAME into Last name and First name by comma, remove JR,SR,I
			WHEN CHARINDEX(',', refingprov.PROV_NAME) > 2
				THEN CASE 
						WHEN CHARINDEX(' JR', SUBSTRING(refingprov.PROV_NAME, 1, CHARINDEX(',',refingprov.PROV_NAME) - 1)) > 2
							THEN LTRIM(SUBSTRING(refingprov.PROV_NAME, 1, CHARINDEX(' JR', SUBSTRING(refingprov.PROV_NAME, 1, CHARINDEX(',', refingprov.PROV_NAME) - 1)) - 1))
						WHEN CHARINDEX(' SR', SUBSTRING(refingprov.PROV_NAME, 1, CHARINDEX(',', refingprov.PROV_NAME) - 1)) > 2
							THEN LTRIM(SUBSTRING(refingprov.PROV_NAME, 1, CHARINDEX(' SR', SUBSTRING(refingprov.PROV_NAME, 1, CHARINDEX(',', refingprov.PROV_NAME) - 1)) - 1))
						WHEN CHARINDEX(' I', SUBSTRING(refingprov.PROV_NAME, 1, CHARINDEX(',', refingprov.PROV_NAME) - 1)) > 2
							THEN LTRIM(SUBSTRING(refingprov.PROV_NAME, 1, CHARINDEX(' I', SUBSTRING(refingprov.PROV_NAME, 1, CHARINDEX(',', refingprov.PROV_NAME) - 1)) - 1))
						ELSE LTRIM(SUBSTRING(refingprov.PROV_NAME, 1, CHARINDEX(',', refingprov.PROV_NAME) - 1))
						END
			ELSE LTRIM(refingprov.PROV_NAME)
			END) --Physician_Last_Name
	,FirstName = CONVERT(VARCHAR(50), CASE 
			WHEN CHARINDEX(',', refingprov.PROV_NAME) > 2
				THEN CASE 
						WHEN CHARINDEX(' ', SUBSTRING(refingprov.PROV_NAME, CHARINDEX(',', refingprov.PROV_NAME) + 2, LEN(refingprov.PROV_NAME))) > 2
							THEN LTRIM(SUBSTRING(refingprov.PROV_NAME, CHARINDEX(',', refingprov.PROV_NAME) + 1, CHARINDEX(' ', SUBSTRING(refingprov.PROV_NAME, CHARINDEX(',', refingprov.PROV_NAME) + 2, LEN(refingprov.PROV_NAME)))))
						ELSE LTRIM(SUBSTRING(refingprov.PROV_NAME, CHARINDEX(',', refingprov.PROV_NAME) + 1, LEN(refingprov.PROV_NAME)))
						END
			END) --Physician_First_Name
	,MiddleName = CONVERT(VARCHAR(50), CASE 
			WHEN CHARINDEX(',', refingprov.PROV_NAME) > 2 -- found lastname, now look for space in first name to split middle name out
				AND CHARINDEX(' ', SUBSTRING(refingprov.PROV_NAME, CHARINDEX(',', refingprov.PROV_NAME) + 2, LEN(refingprov.PROV_NAME))) > 2
				THEN LTRIM(SUBSTRING(SUBSTRING(refingprov.PROV_NAME, CHARINDEX(',', refingprov.PROV_NAME) + 2, LEN(refingprov.PROV_NAME)), CHARINDEX(' ', SUBSTRING(refingprov.PROV_NAME, CHARINDEX(',', refingprov.PROV_NAME) + 2, LEN(refingprov.PROV_NAME))) + 1, LEN(refingprov.PROV_NAME)))
			END)

			------
		,txfsvc.REFERRING_LOC_ID	'ReferringFacilityID'
		,COALESCE(refingloc.LOC_NAME, refingpos.POS_NAME, txfsvc.FREETEXT_REFERRING_LOC_NAME)			'Referring_Facility'   -- Mali A. Add Clarit_POS, and free Text referring facility
		,txfsvc.TRANS_REASON_C		'TransferReasonID'
		,txfrsn.NAME				'TransferReason'
		,txfsvc.MODE_OF_TXPORT_C	'TransferModeID'
		,txp.NAME					'TransferMode'
		,COALESCE(diag.DX_ID, ncsdx.TRANS_DX_ID)					'DiagnosisID'   --Add Free Text Diagnosis 06/10/2019
		,COALESCE(edg.DX_NAME,ncsdx.TRANS_DX_TEXT,diag.ADMIT_DIAG_TEXT)				'Diagnosis'
	--	,CONCAT(hno.[3],' '	, hno.[2],' ', hno.[1])			'HPIPHM'  --removed 4/10/2019 Not needed in dashboard
		--,CAST(intenc2.VITALS_TAKEN_TM AS SMALLDATETIME)	'VITALS_TAKEN_TM'
		--,intenc.BP_SYSTOLIC			'BP_SYSTOLIC'
		--,intenc.BP_DIASTOLIC		'BP_DIASTOLIC'
		--,intenc.PULSE				'PULSE'
		--,intenc.RESPIRATIONS		'RESPIRATIONS'
		--,intenc.TEMPERATURE			'TEMPERATURE'
		--,intenc2.PHYS_TEMP_SRC_C	'TempSourceID'
		--,tempsrc.NAME				'TemperatureSource'
		--,intenc2.PHYS_SPO2			'SPO2'
		--,intenc.WEIGHT				'PatientWeight'
		--,intenc.HEIGHT				'PatientHieght'
		--,intenc.HEAD_CIRCUMFERENCE	'HeadCircumference'
		--,intenc2.PHYS_PEAK_FLOW		'PEAK_FLOW'
		--,intenc2.PAT_PAIN_SCORE_C   'PainScoreID'
		--,painscr.NAME				'PatientPainScore'
		--,intenc2.PAT_PAIN_LOC_C		'PainLocationID'
		--,painloc.NAME						'PatientPainLocation'
		--,intenc3.EXC_IN_GROW_CHAR_YN		'ExcludedinGrowthChart'
		--,flshtpvt.[3050001618]				'ReportedAllergies'
		,txfsvc.TRANS_HOSPITAL_SERVICE_C	'ServiceRequestedID'
		,hspsvc.NAME						'ServiceNme'
		,txfsvc.SOURCE_ADMSN_LVL_OF_CARE_C	'LevelOfCareID'
		,lvl.NAME							'LevelOfCare'
		,txfsvc.TRANSFER_TYPE_C		'TransferTypeID'
		,txftyp.NAME				'TransferType'

		--	Modified 05/28/2019  -Mali A. 
		,pnd.PEND_ID				'XTPlacementID'
		,pnd.PEND_REQ_STATUS_C		'PlacementStatusID'
		,pndsts.NAME				'PlacementStatusName'
		,last_mod.REQUEST_STATUS_C	'XTPlacementStatusID'
		,last_mod.RequestStatus		'XTPlacementStatusName'
		--,CLARITY_App.dbo.udf_UTC_to_DST(last_mod.STATUS_UPDATE_UTC_DTTM)	'XTPlacementStatusDateTime'
		,CLARITY.EPIC_UTIL.EFN_UTC_TO_LOCAL(last_mod.STATUS_UPDATE_UTC_DTTM)	'XTPlacementStatusDateTime'
		----------------
		,CAST(txfsvc.EXPECTED_ARRIVAL_DTTM AS SMALLDATETIME)  'ETA'  --Expected Time of Arrival
		,destloc.LOC_NAME			'PatientReferredTo'
		,COALESCE(destloc.SERV_AREA_ID, 0) AS	'AdtPatientFacilityID'
		,svcarea.LOC_NAME			'AdtPatientFacility'
		,pnd.UNIT_ID				'DestinationUnitID'
		,destdep.DEPARTMENT_NAME	'DestinationUnit'
		,pnd.BED_ID					'XTAssignedBedID'
		,bed.Bed					'BedAssigned'
		,pnd.ACCOMMODATION_C		'BedTypeID'
		,acom.NAME					'BedType'
		,txfsvc.DEST_DECLINE_RSN_C	'DispositionReasonID'
		,COALESCE(cnlrsn.NAME,dclrsn.NAME)	'DispositionReason'
		,txfsvc.REQUEST_STATUS_C			'DispositionID'
		,reqsts.NAME						'Disposition'
		--,CLARITY_App.dbo.udf_UTC_to_DST(txf.ACC_PROV_CONTACT_UTC_DTTM)	'Accepting Timestamp'
		,CLARITY.EPIC_UTIL.EFN_UTC_TO_LOCAL(txf.ACC_PROV_CONTACT_UTC_DTTM)	'Accepting Timestamp'
		,accprov.PROV_NAME			'Accepting MD'	
		,accprov.RPT_GRP_FIVE		'AcceptingMD_ServiceLine'
		--,CLARITY_App.dbo.udf_UTC_to_DST(txf.TRANSFER_RESOLUTION_UTC_DTTM) 'CloseTime'
		,CLARITY.EPIC_UTIL.EFN_UTC_TO_LOCAL(txf.TRANSFER_RESOLUTION_UTC_DTTM) 'CloseTime'
		--,CLARITY_App.dbo.udf_UTC_to_DST(last_mod.STATUS_UPDATE_UTC_DTTM)	'XTLastModDate'
		,CLARITY.EPIC_UTIL.EFN_UTC_TO_LOCAL(last_mod.STATUS_UPDATE_UTC_DTTM)	'XTLastModDate'
		 ,last_mod.USER_ID			'LastModUserId'
		,last_mod.SYSTEM_LOGIN		'LastModUserLogon'
			   
FROM CLARITY.dbo.V_ADT_TRANSFER_CENTER txf
INNER JOIN CLARITY.dbo.CUST_SERVICE_TRANSFER txfsvc					ON txfsvc.COMM_ID = txf.COMM_ID

INNER JOIN   CLARITY.dbo.CUST_SERV_ATCHMENT inttxf					ON txf.COMM_ID = inttxf.COMM_ID
                                                                   	  --AND inttxf.ATCHMENT_TYPE_C='22' --Transfer Center Intake/ 21	Transfer Center Destination

INNER JOIN CLARITY.dbo.CUST_SERVICE cst								ON cst.COMM_ID = txf.COMM_ID
LEFT OUTER JOIN CLARITY.dbo.CUST_SERVICE_TRANS_DX ncsdx				ON ncsdx.COMM_ID = cst.COMM_ID
LEFT OUTER JOIN CLARITY.dbo.CLARITY_EDG ncsedg							ON ncsedg.DX_ID = ncsdx.TRANS_DX_ID

LEFT OUTER JOIN CLARITY.dbo.PAT_ENC intenc							ON intenc.PAT_ENC_CSN_ID = inttxf.ATCHMENT_PT_CSN_ID

LEFT OUTER JOIN CLARITY.dbo.CUST_SERV_ATCHMENT dsttxf				ON txf.TARGET_DEST_COMM_ID = dsttxf.COMM_ID  
	                                                                  --AND dsttxf.ATCHMENT_TYPE_C='18' -- Admission --'21' --Transfer Center Destination

LEFT OUTER JOIN CLARITY.dbo.PAT_ENC_HSP hsp							ON hsp.PAT_ENC_CSN_ID=dsttxf.ATCHMENT_PT_CSN_ID  
                                                                      AND hsp.PREADM_UNDO_RSN_C IS NULL --pre-admission not cancelled

LEFT OUTER JOIN CLARITY.dbo.ZC_TC_REQUEST_STATUS reqsts				ON txfsvc.REQUEST_STATUS_C=reqsts.TC_REQUEST_STATUS_C

LEFT OUTER JOIN CLARITY.dbo.IDENTITY_ID idx							ON idx.PAT_ID = inttxf.ATCHMENT_PAT_ID
	                                                                  AND idx.IDENTITY_TYPE_ID='14'

LEFT OUTER JOIN CLARITY.dbo.PATIENT pt								ON pt.PAT_ID = inttxf.ATCHMENT_PAT_ID
LEFT OUTER JOIN (
					SELECT * FROM 
							(SELECT 
							COALESCE(flwshtm.MEAS_VALUE, flwshtm.MEAS_COMMENT) 'MEAS_VALUE'
							,flwshtm.FLO_MEAS_ID
							,flwshtrw.INPATIENT_DATA_ID
							, ROW_NUMBER() OVER (PARTITION BY flwshtrw.INPATIENT_DATA_ID, flwshtm.FLO_MEAS_ID ORDER BY flwshtm.RECORDED_TIME DESC) 'RNo'
							 FROM CLARITY.dbo.IP_FLWSHT_MEAS flwshtm
							 INNER JOIN CLARITY.dbo.IP_FLWSHT_REC flwshtrw		ON flwshtrw.FSD_ID = flwshtm.FSD_ID
							 WHERE flwshtm.FLO_MEAS_ID IN ('7246','7247','7269','3050001618')
							) flsht
					 PIVOT 
					 (
					 MAX(flsht.MEAS_VALUE) 
					 FOR FLO_MEAS_ID IN ([7246],[7247],[7269],[3050001618])
					) AS pvt
				) flshtpvt											ON flshtpvt.INPATIENT_DATA_ID = intenc.INPATIENT_DATA_ID
																					AND flshtpvt.RNo='1'

---No. Creates > 2 million row derived table for the join
LEFT OUTER JOIN CLARITY.dbo.PAT_ADDRESS addrs1						ON addrs1.PAT_ID=pt.PAT_ID 
                                                                      AND addrs1.LINE='1'
 ---No. creates a 256,000 row derived table for the join 
LEFT OUTER JOIN  CLARITY.dbo.PAT_ADDRESS addrs2						ON addrs2.PAT_ID=pt.PAT_ID 
                                                                      AND addrs2.LINE='2'

LEFT OUTER JOIN CLARITY.dbo.ZC_STATE ptst							ON pt.STATE_C=ptst.STATE_C
LEFT OUTER JOIN CLARITY.dbo.CLARITY_EMP entryemp					ON cst.ENTRY_USER_ID=entryemp.USER_ID
LEFT OUTER JOIN CLARITY.dbo.CLARITY_LOC destloc						ON destloc.LOC_ID=txf.TARGET_DEST_LOC_ID

---No. Creates a > 3 million row derived table for the join
LEFT OUTER JOIN CLARITY.dbo.PEND_ACTION pnd							ON pnd.PAT_ENC_CSN_ID = hsp.PAT_ENC_CSN_ID 
                                                                     AND pnd.PEND_EVENT_TYPE_C = '1'


LEFT OUTER JOIN (
					SELECT BED_ID
						,MAX(BED_LABEL) 'Bed'
					FROM CLARITY.dbo.CLARITY_BED
					GROUP BY BED_ID
				) bed												ON bed.BED_ID = pnd.BED_ID
LEFT OUTER JOIN CLARITY.dbo.ZC_PEND_REQ_STATUS pndsts				ON pndsts.PEND_REQ_STATUS_C = pnd.PEND_REQ_STATUS_C
LEFT OUTER JOIN CLARITY.dbo.CLARITY_SER accprov						ON txf.TRANSFER_ACCEPT_PROV_ID=accprov.PROV_ID
LEFT OUTER JOIN CLARITY.dbo.CLARITY_EMP entemp						ON cst.ENTRY_USER_ID=entemp.USER_ID
LEFT OUTER JOIN CLARITY.dbo.CLARITY_EMP crmemp						ON cst.ENTRY_USER_ID=crmemp.USER_ID

 -----No. Creates a > 11 million row derived table for the join
LEFT OUTER JOIN CLARITY.dbo.HSP_ADMIT_DIAG diag						ON hsp.PAT_ENC_CSN_ID=diag.PAT_ENC_CSN_ID 
                                                                     AND diag.LINE='1' --primary diagnosis 

LEFT OUTER JOIN CLARITY.dbo.CLARITY_EDG edg							ON edg.DX_ID = diag.DX_ID
LEFT OUTER JOIN CLARITY.dbo.CLARITY_LOC svcarea						ON destloc.SERV_AREA_ID=svcarea.LOC_ID
LEFT OUTER JOIN CLARITY.dbo.ZC_PAT_SERVICE hspsvc					ON hspsvc.HOSP_SERV_C = txfsvc.TRANS_HOSPITAL_SERVICE_C
LEFT OUTER JOIN CLARITY.dbo.CLARITY_SER refingprov					ON txfsvc.REFERRING_PROV_ID=refingprov.PROV_ID
LEFT OUTER JOIN CLARITY.dbo.CLARITY_LOC refingloc					ON refingloc.LOC_ID=txfsvc.REFERRING_LOC_ID
LEFT OUTER JOIN CLARITY.dbo.CLARITY_POS refingpos					ON refingpos.POS_ID=txfsvc.REFERRING_LOC_ID
LEFT OUTER JOIN CLARITY.dbo.ZC_TC_DECLINE_RSN dclrsn				ON txfsvc.DEST_DECLINE_RSN_C=dclrsn.TC_DECLINE_RSN_C
LEFT OUTER JOIN CLARITY.dbo.ZC_TC_CANCEL_RSN cnlrsn					ON txfsvc.CANCEL_STATUS_RSN_C=cnlrsn.TC_CANCEL_RSN_C
LEFT OUTER JOIN CLARITY.dbo.ZC_TRANS_REASON txfrsn					ON txfsvc.TRANS_REASON_C=txfrsn.TRANS_REASON_C
LEFT OUTER JOIN CLARITY.dbo.ZC_PAT_CLASS ptcls						ON hsp.ADT_PAT_CLASS_C=ptcls.ADT_PAT_CLASS_C
LEFT OUTER JOIN CLARITY.dbo.ZC_LVL_OF_CARE lvl						ON txfsvc.TRANS_LVL_OF_CARE_C=lvl.LEVEL_OF_CARE_C
LEFT OUTER JOIN CLARITY.dbo.ZC_ARRIV_MEANS txp						ON txfsvc.MODE_OF_TXPORT_C=txp.MEANS_OF_ARRV_C
LEFT OUTER JOIN CLARITY.dbo.CLARITY_DEP destdep						ON pnd.UNIT_ID=destdep.DEPARTMENT_ID
LEFT OUTER JOIN CLARITY.dbo.ZC_TC_TRANSFER_TYPE txftyp				ON txfsvc.TRANSFER_TYPE_C=txftyp.TC_TRANSFER_TYPE_C
LEFT OUTER JOIN CLARITY.dbo.ZC_ACCOMMODATION acom					ON acom.ACCOMMODATION_C=pnd.ACCOMMODATION_C
LEFT OUTER JOIN CLARITY.dbo.MEDICAL_HX phm							ON phm.PAT_ENC_CSN_ID = hsp.PAT_ENC_CSN_ID
LEFT OUTER JOIN CLARITY.dbo.PAT_ENC_2 intenc2						ON intenc.PAT_ENC_CSN_ID=intenc2.PAT_ENC_CSN_ID
LEFT OUTER JOIN CLARITY.dbo.PAT_ENC_3 intenc3						ON intenc.PAT_ENC_CSN_ID=intenc3.PAT_ENC_CSN
LEFT OUTER JOIN CLARITY.dbo.ZC_PHYS_TEMP_SRC tempsrc				ON tempsrc.PHYS_TEMP_SRC_C = intenc2.PHYS_TEMP_SRC_C
LEFT OUTER JOIN CLARITY.dbo.ZC_PAT_PAIN_SCORE painscr				ON intenc2.PAT_PAIN_SCORE_C=painscr.PAT_PAIN_SCORE_C
LEFT OUTER JOIN CLARITY.dbo.ZC_PAT_PAIN_LOC painloc					ON intenc2.PAT_PAIN_LOC_C=painloc.PAT_PAIN_LOC_C
LEFT OUTER JOIN CLARITY.dbo.CLARITY_EDG phmedg						ON phm.DX_ID=phmedg.DX_ID

 --Updated 10/08/2019 Mali A for Ser identity NPI
LEFT OUTER JOIN clarity.dbo.IDENTITY_SER_ID serid					ON refingprov.PROV_ID=serid.PROV_ID 
                                                                      AND serid.IDENTITY_TYPE_ID = 100001

LEFT OUTER JOIN CLARITY.dbo.ZC_PAT_SERVICE ptsvc					ON txfsvc.TRANS_HOSPITAL_SERVICE_C=ptsvc.HOSP_SERV_C

---Questionable. Can't tell with only test data
LEFT OUTER JOIN (
					SELECT hx.COMM_ID
							,hx.REQUEST_STATUS_C
							,sts.NAME 'RequestStatus'
							,hx.STATUS_UPDATE_UTC_DTTM
							,hx.STATUS_UPDATE_USER_ID
							,emp.USER_ID
							,emp.SYSTEM_LOGIN
							,ROW_NUMBER() OVER(PARTITION BY hx.COMM_ID ORDER BY hx.STATUS_UPDATE_UTC_DTTM DESC) 'RNo'
					FROM CLARITY.dbo.TC_REQUEST_STATUS_HX hx
					LEFT OUTER JOIN CLARITY.dbo.CLARITY_EMP emp			ON hx.STATUS_UPDATE_USER_ID=emp.USER_ID
					LEFT OUTER JOIN CLARITY.dbo.ZC_TC_REQUEST_STATUS sts	ON hx.REQUEST_STATUS_C=sts.TC_REQUEST_STATUS_C
					WHERE 1=1
					--AND CLARITY_App.dbo.udf_UTC_to_DST(hx.STATUS_UPDATE_UTC_DTTM) >= @StartDate
					AND CLARITY.EPIC_UTIL.EFN_UTC_TO_LOCAL(hx.STATUS_UPDATE_UTC_DTTM) >= @StartDate
					--AND CLARITY_App.dbo.udf_UTC_to_DST(hx.STATUS_UPDATE_UTC_DTTM) <  @EndDate
					AND CLARITY.EPIC_UTIL.EFN_UTC_TO_LOCAL(hx.STATUS_UPDATE_UTC_DTTM) <  @EndDate
				) last_mod											ON last_mod.COMM_ID = txf.COMM_ID
																		AND last_mod.RNo='1'

WHERE 1=1

--	AND idx.IDENTITY_TYPE_ID='14'
--	AND inttxf.ATCHMENT_TYPE_C='22' --Transfer Center Intake/ 21	Transfer Center Destination
--	AND dsttxf.ATCHMENT_TYPE_C='18' -- Admission --'21' --Transfer Center Destination
--	AND pnd.PEND_EVENT_TYPE_C='1' --Admission
--	AND hsp.PREADM_UNDO_RSN_C IS NULL --pre-admission not cancelled
  AND (serid.IDENTITY_TYPE_ID='100001' OR serid.IDENTITY_ID IS NULL )

	AND CLARITY.EPIC_UTIL.EFN_UTC_TO_LOCAL(last_mod.STATUS_UPDATE_UTC_DTTM) >= @locstartdate
	AND CLARITY.EPIC_UTIL.EFN_UTC_TO_LOCAL(last_mod.STATUS_UPDATE_UTC_DTTM) <  @locenddate

ORDER BY EntryTime, TransferID
GO


