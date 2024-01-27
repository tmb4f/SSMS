SELECT
	  har.HSP_ACCOUNT_ID
	, har.DISCH_DATE_TIME
	, har.LOC_ID				[HAR_LOC_ID]
	, loc.LOC_ID				[LOC_LOC_ID]
	, loc.LOC_NAME
	, loc.LOC_GROUPER_ID
	, loc.LOC_GROUPER_NAME
	, har.DISCH_DEPT_ID
	, dep.REV_LOC_ID			[DEPT_REV_LOC_ID]
 	,dep.DEPT_ABBREVIATION
FROM CLARITY.dbo.hsp_account har 
	 INNER JOIN (
					SELECT DISTINCT
						[LOC_ID]	= ISNULL(CAST(loc1.LOC_ID AS VARCHAR(MAX)),'NULL')
					  , [LOC_NAME]	= CONCAT(loc1.LOC_NAME, ' [', CAST(loc1.LOC_ID AS VARCHAR(MAX)), ']')
					  , [LOC_GROUPER_ID] = CAST(LOC_GROUPER_ID AS VARCHAR(MAX))
					  , [LOC_GROUPER_NAME] =loc1.LOC_GROUPER_NAME
					FROM	(SELECT DISTINCT
								   [LOC_GROUPER_ID]		=  ISNULL(LOC.RPT_GRP_NINE,'NULL')
								  ,[LOC_GROUPER_NAME]	= ISNULL(ZEAF9.NAME,'*Not Indicated [NULL]')
								  ,loc_id				= ISNULL(CAST(LOC.LOC_ID AS VARCHAR(MAX)),'NULL')
								  ,loc.LOC_NAME								  
								FROM	CLARITY..CLARITY_LOC				LOC
										LEFT JOIN CLARITY..ZC_LOC_RPT_GRP_9 ZEAF9	ON LOC.RPT_GRP_NINE = ZEAF9.RPT_GRP_NINE
								WHERE	LOC.RECORD_STATUS	IS NULL 
									AND	LOC.SERV_AREA_ID	= 10  
									AND loc.LOC_NAME		NOT LIKE 'EHS%'
								) loc1

					WHERE	1=1
						
					/*===============================================================
					CHOOSE EITHER 1 OR 2 DEPENDING ON IF DATASET IS EMBEDDED OR IF REFERENCING A STORED PROC/SQL QUERY
					==================================================================*/

					/* 1.  SSRS EMBEDDED TEXT PARSING OF PARAMETERS */
				    
					      AND ISNULL(CAST(loc1.LOC_GROUPER_ID AS VARCHAR(MAX)), 'NULL') IN ('3') -- Haymarket		         
						  AND ISNULL(CAST(loc1.LOC_ID         AS VARCHAR(MAX)),'null')  IN ('10002') -- UVA Haymarket Medical Center Parent [10002]
					


					/* 2.  SQL STORED PROC PARSING OF PARAMS
					
						  ( ISNULL(CAST(loc1.LOC_GROUPER_ID AS VARCHAR(MAX)), 'NULL') IN (SELECT param FROM clarity.etl.fn_ParmParse(@LocGrouperSA10,','))	)
						  AND
						   (ISNULL(CAST(loc1.LOC_ID AS VARCHAR(MAX)),'NULL') IN (SELECT  param FROM clarity.etl.fn_ParmParse(@LocID,','))	)
					 */

					)loc ON ISNULL(CAST(har.LOC_ID AS VARCHAR(MAX)),'NULL') = ISNULL(CAST(loc.LOC_ID AS Varchar(MAX)),'NULL')	
		LEFT JOIN CLARITY..CLARITY_DEP DEP ON HAR.DISCH_DEPT_ID = DEP.DEPARTMENT_ID

WHERE  CAST(HAR.DISCH_DATE_TIME AS DATE) >= '7/1/2021'
   AND CAST(HAR.DISCH_DATE_TIME AS DATE) <= '9/29/2022'
 --AND HAR.HSP_ACCOUNT_ID IN (
 --  14017069014 -- NULL GROUPER NINE ( Note LOC_ID = 10)
 -- , 14017043865 -- HAYMARKET
 -- , 14017143747  -- Prince William
 -- , 13013784772 -- UVA

  --)
  AND har.DISCH_DEPT_ID IN (10376002) -- HYHB OUTSIDE RADIOLOGY
  ORDER BY har.DISCH_DEPT_ID, har.HSP_ACCOUNT_ID