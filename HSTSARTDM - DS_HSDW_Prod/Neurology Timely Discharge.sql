USE DS_HSDW_Prod

/*
8/12/2022: 2:44
8/12/2022: Removed addition of time for end date/time: 1:21	 148
8/12/2022: Added back addition of time for end date/time: 1:05	 148
8/12/2022: "Parameter sniffing" measure: 1:11 148
*/

DECLARE @p_DateStart DATETIME
DECLARE @p_DateEnd DATETIME
DECLARE @p_DC_Unit VARCHAR(5080)
DECLARE @p_DRG VARCHAR(60)
DECLARE @p_Attending VARCHAR(120)

SET @p_DateStart = '7/1/2022 00:00:00'
SET @p_DateEnd = '8/11.2022 23:59:59'

DECLARE @locDateStart AS SMALLDATETIME
DECLARE @locDateEnd AS SMALLDATETIME

SET @locDateStart = @p_DateStart
SET @locDateEnd = @p_DateEnd

SELECT [Patients].[Account_Num] AS [Account_Num],
  [Patients].[MRN] AS [MRN],
  [Patients].[Discharge_DtTm] AS [Discharge_DtTm],
  [Patients].[Discharge_Tm] AS [Discharge_Tm],
  [Patients].[Discharge_Tm_Sec] AS [Discharge_Tm_Sec],
  [Patients].[Event] AS [Event],
  [Patients].[D/C Unit] AS [D/C Unit],
  [Patients].[Attending] AS [Attending],
  [Patients].[Division] AS [Division],
  [Patients].[Service Line] AS [Service Line],
  [Patients].[ENCCSN] AS [ENCCSN],
  [Patients].[sk_Dim_Clrt_Disch_Disp] AS [sk_Dim_Clrt_Disch_Disp],
  [Patients].[Disch_Disp_Descr] AS [Disch_Disp_Descr],
  [Patients].[DRG Code-Name] AS [DRG Code-Name],
  [Patients].[LOS] AS [LOS],
  [Patients].[Discharge Destination] AS [Discharge Destination],
  [Patients].[sk_Fact_Pt_Enc_Clrt] AS [sk_Fact_Pt_Enc_Clrt],
  [Patients].[adt_pt_cls] AS [adt_pt_cls],
  [Discharge Orders].[Order Entry DtTm] AS [Order Entry DtTm],
  [Discharge Orders].[Order Entry Time] AS [Order Entry Time],
  [Discharge Orders].[Order Entry Time Sec] AS [Order Entry Time Sec],
  [Discharge Orders].[sk_Fact_Pt_Enc_Clrt_2] AS [sk_Fact_Pt_Enc_Clrt_2],
  [Acuity Score].[MRN] AS [MRN (Custom SQL Query)],
  [Acuity Score].[PAT_ENC_CSN_ID] AS [PAT_ENC_CSN_ID],
  [Acuity Score].[Patient_Name] AS [Patient_Name],
  [Acuity Score].[Time Entered] AS [Time Entered],
  [Acuity Score].[Progression Level] AS [Progression Level],
  [Acuity Score].[Clrt_DEPt_Nme] AS [Clrt_DEPt_Nme]
FROM (
  SELECT 												
  	  				pt.AcctNbr_int 'Account_Num'								
  	  				,pt.MRN_int	'MRN'							
  	  				,pt.Dsch_Dtm 'Discharge_DtTm'
					,CONVERT(TIME, pt.Dsch_Dtm) 'Discharge_Tm'
					,(DATEPART(HOUR, CONVERT(TIME, pt.Dsch_Dtm)) * 3600) +
					 (DATEPART(MINUTE, CONVERT(TIME, pt.Dsch_Dtm)) * 60) +
					 (DATEPART(SECOND, CONVERT(TIME, pt.Dsch_Dtm))) 'Discharge_Tm_Sec'
  	  				,adt.sk_Dim_Clrt_ADT_Evnt 'Event'								
  	  				--changed D/C Unit from phy to dept (adt)
  					,dept.Clrt_DEPt_Ext_Nme 'D/C Unit'								
  	  				,md.DisplayName 'Attending'								
  	  				,md.Division 'Division'								
  	  				,md.Service_Line 'Service Line'
  	  				,pt.PAT_ENC_CSN_ID 'ENCCSN'								
  	  				,dis.sk_Dim_Clrt_Disch_Disp								
  	  				,dis.Disch_Disp_Descr								
  	  				,CONCAT(drg.[DRG_Cde],'-',drg.[DRG_Dscr]) 'DRG Code-Name'								
  	  				,pa.LOS								
  	  				,dis.Disch_Disp_Descr 'Discharge Destination'
  					,pt.sk_Fact_Pt_Enc_Clrt		
  					,hsp.adt_pt_cls					
  	  	FROM (SELECT  *, LEAD(sk_dim_clrt_DEPt) OVER(PARTITION BY sk_fact_pt_enc_clrt ORDER BY seq DESC) AS sk_Dim_Clrt_DEPt_prev, ROW_NUMBER() OVER (PARTITION BY sk_Fact_Pt_Enc_Clrt
                           ORDER BY IN_DTTM DESC, OUT_DTTM DESC) AS DschSeq
  						FROM [DS_HSDW_Prod].[Rptg].[vwFact_Clrt_ADT]) adt											
  	  				LEFT JOIN [Rptg].[vwFact_Pt_Enc_Clrt] pt 								
  	  				ON adt.sk_Fact_Pt_Enc_Clrt=pt.sk_Fact_Pt_Enc_Clrt								
  	  				--vwCensus_Unit_Physcn_Seq causing Post-EP2-Go-Live issue	
  	  				--LEFT JOIN [Rptg].[vwCensus_Unit_Physcn_Seq] phy								
  	  				--ON pt.sk_Fact_Pt_Acct=phy.sk_Fact_Pt_Acct								
  	  				LEFT JOIN [DS_HSDW_Prod].[Rptg].[vwFact_Pt_Acct] pa								
  	  				ON pa.AcctNbr_int =pt.AcctNbr_int
  					--added in atn
					LEFT JOIN (SELECT * , ROW_NUMBER() OVER (PARTITION BY sk_Fact_Pt_Enc_Clrt ORDER BY Atn_Beg_Dtm DESC, (CASE WHEN Atn_End_Dtm = '1900-01-01' THEN GETDATE() ELSE Atn_End_Dtm END) DESC) AS Atn_Seq FROM Rptg.vwFact_Pt_Enc_Atn_Prov_All) atn  
					ON (atn.PAT_ENC_CSN_ID = pt.PAT_ENC_CSN_ID AND atn.Atn_Seq = 1)
  					LEFT JOIN [Rptg].[vwDim_Physcn] md								
  	  				--changed phy.sk_Dim_Physcn to atn.
  					ON atn.sk_Dim_Physcn=md.sk_Dim_Physcn								
  	  				LEFT JOIN [Rptg].[vwFact_Pt_Enc_Disch_Disp_All] dis								
  	  				ON dis.sk_Fact_Pt_Enc_Clrt=pt.sk_Fact_Pt_Enc_Clrt									
  	  				LEFT JOIN [DS_HSDW_Prod].[Rptg].[vwDim_DRG] drg								
  	  				ON pa.sk_MS_DRG = drg.sk_Dim_DRG
  					-- added dept below
  					LEFT JOIN [DS_HSDW_Prod].[Rptg].[vwDim_Clrt_DEPt] dept
  					ON adt.sk_Dim_Clrt_DEPt_prev=dept.sk_Dim_Clrt_DEPt		
  					-- added hsp below
  					LEFT JOIN 	[DS_HSDW_Prod].[Rptg].[vwFact_Pt_Enc_Hsp_Clrt] hsp
  					ON hsp.sk_Fact_Pt_Enc_Clrt=pt.sk_Fact_Pt_Enc_Clrt					
  	
  	WHERE
  				    adt.sk_Dim_Clrt_ADT_Evnt ='2'									
  				    --AND phy.[Discharge] = '1'								
  	  			    --AND dis.sk_Dim_Clrt_Disch_Disp NOT IN (4, 26, 27, 28, 40)								
  	  			    --Eliminate next line (md.Service_Line IS NOT NULL) as it eliminates entire discharge
  					--AND md.Service_Line IS NOT NULL
  					--changed dept exclusion criteria to match Clrt_Dept_Ext_Nme and to exclude ED & Main OR & Periop & Unknown & EP/Cath Lab
                      AND dept.Clrt_DEPt_Ext_Nme NOT IN ('Main Operating Room-Periop','UVA Emergency Department', 'UVHE ADMIT', 'TCIR TC2A', 'TCIR TC2B', 'TCIR TC3A', 'Post Anesthesia Care Unit', 'UVA Health System Cardiac Transition Unit
  ', 'PERIOP', 'GPERIOP', 'Null','Unknown', 'Cardiac Cath Lab', 'Outpatient Surgery at Battle', 'Endoscopy/Bronchoscopy Procedure Suite')
                      --AND pt.Dsch_Dtm  BETWEEN @p_DateStart AND (@p_DateEnd + '11:59:00') --'20190101' >= '20220101'
                      --AND pt.Dsch_Dtm  BETWEEN @p_DateStart AND @p_DateEnd --'20190101' >= '20220101'
                      AND pt.Dsch_Dtm  BETWEEN @locDateStart AND (@locDateEnd + '11:59:00') --'20190101' >= '20220101'
  										--add adt_pt_cls filter
  					AND hsp.adt_pt_cls NOT IN ('Outpatient', 'Newborn', 'Emergency')
					AND md.Division = 'Neurology'
					AND md.ProviderGroup = 'Clin Staff'
					--AND dept.Clrt_DEPt_Ext_Nme IN (SELECT value FROM STRING_SPLIT(@p_DC_Unit,','))
					--AND drg.[DRG_Cde] IN (SELECT value FROM STRING_SPLIT(@p_DRG,','))
					--AND md.IDNumber IN (SELECT value FROM STRING_SPLIT(@p_Attending,','))
) [Patients]
  LEFT JOIN (
  SELECT 
  		Ordr_Dtm 'Order Entry DtTm',
		CONVERT(TIME, Ordr_Dtm) 'Order Entry Time',
		(DATEPART(HOUR, CONVERT(TIME, Ordr_Dtm)) * 3600) +
			 (DATEPART(MINUTE, CONVERT(TIME, Ordr_Dtm)) * 60) +
			 (DATEPART(SECOND, CONVERT(TIME, Ordr_Dtm))) 'Order Entry Time Sec',
  		sk_Fact_Pt_Enc_Clrt 'sk_Fact_Pt_Enc_Clrt_2'
  		FROM [Rptg].[vwClrt_ADT_Ordr]
  		WHERE Ordr_Typ_Nme='Discharge'  																										
  	  	AND seq_inv_ordr_typ = '1'									
  	  	AND PROC_CODE = 'ADT8'
) [Discharge Orders] ON ([Patients].[sk_Fact_Pt_Enc_Clrt] = [Discharge Orders].[sk_Fact_Pt_Enc_Clrt_2])
  LEFT JOIN (
  SELECT  acu.MRN												
          ,acu.PAT_ENC_CSN_ID										
          ,acu.[Patient_Name]										
          ,acu.[Time Entered]										
          ,acu.[Progression Level]										
          ,acu.Clrt_DEPt_Nme										
  	  												
              FROM 							
              (SELECT 						
                       pat.MRN_Clrt			 AS 'MRN'			
                      ,peh.PAT_ENC_CSN_ID						
                      ,pat.PAT_NAME			 AS 'Patient_Name'			
                      --,peh.HOSP_ADMSN_TIME	 AS 'Admit Date'					
                      --,peh.sk_Dsch_Dte						
                      --,peh.Dsch_Tm						
                      --,fsm.Msr_Rec_Dtm		 as 'Time Taken'				
                      ,fsm.Msr_Ent_Dtm		 AS 'Time Entered'				
                      ,fsm.Msr_Val			 AS 'Progression Level'			
                      ,dep.Clrt_DEPt_Nme						
                     ,ROW_NUMBER() OVER (PARTITION BY peh.PAT_ENC_CSN_ID ORDER BY fsm.Msr_Rec_Dtm DESC) AS disp_seq
                                                                      
              FROM [DS_HSDW_Prod].[Rptg].[vwFact_Clrt_Flo_Msr] AS fsm							
              INNER JOIN [DS_HSDW_Prod].[Rptg].[vwFact_Pt_Enc_Hsp_Clrt] AS peh	ON fsm.sk_Fact_Pt_Enc_Clrt = peh.sk_Fact_Pt_Enc_Clrt						
              INNER JOIN [DS_HSDW_Prod].[Rptg].[vwFact_Pt_Enc_Clrt] AS pe		ON peh.sk_Fact_Pt_Enc_Clrt = pe.sk_Fact_Pt_Enc_Clrt					
              INNER JOIN [DS_HSDW_Prod].[Rptg].[vwDim_Clrt_Pt] AS pat			ON pat.sk_Dim_Clrt_Pt = pe.sk_Dim_Clrt_Pt				
              LEFT JOIN [DS_HSDW_Prod].[Rptg].[vwDim_Clrt_DEPt] AS dep			ON dep.sk_Dim_Clrt_DEPt = peh.sk_Dim_Clrt_DEPt				
              INNER JOIN [DS_HSDW_Prod].[Rptg].[vwDim_Clrt_Flo_GrpRow] AS grr	ON grr.sk_Dim_Clrt_Flo_GrpRow = fsm.sk_Dim_Clrt_Flo_GrpRow
			  LEFT JOIN [DS_HSDW_Prod].[dbo].Dim_Date dd						ON dd.date_key = peh.sk_Dsch_Dte
                                                                      
              WHERE grr.FLO_MEAS_ID = '305100299'							
                  --AND peh.sk_Dsch_Dte >= 19000101	
				  AND dd.day_date BETWEEN @p_DateStart AND @p_DateEnd
                  AND peh.ADMIT_CONF_STAT NOT IN  ('Canceled','Pending')						
                  AND peh.ADT_PATIENT_STAT <> 'Preadmission'						
                  ) acu						
                              
  WHERE acu.disp_seq = 1								
  AND acu.[Progression Level] IN ('D','C', 'E', 'H')
) [Acuity Score] ON ([Patients].[ENCCSN] = [Acuity Score].[PAT_ENC_CSN_ID])
ORDER BY [Patients].[Attending],   [Patients].[Discharge_DtTm] 