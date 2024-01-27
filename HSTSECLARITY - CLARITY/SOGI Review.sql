-- MRN 3060089

use CLARITY

--select * from CLARITY..PAT_SEXUAL_ORIENTATION so
--            LEFT OUTER JOIN CLARITY..ZC_SEXUAL_ORIENTATION AS soc
--                        ON so.SEXUAL_ORIENTATN_C = soc.SEXUAL_ORIENTATION_C
--where 1=1
--and PAT_ID = 'Z2934052'

----LEFT OUTER JOIN CLARITY..ZC_GENDER_CODE/*131*/ AS g_cde
----            ON PATIENT_4.GENDER_IDENTITY_C/*131*/ = g_cde.GENDER_CODE_C

--select * from CLARITY..PATIENT_4 pt
--LEFT OUTER JOIN CLARITY..ZC_GENDER_IDENTITY zc
--on pt.GENDER_IDENTITY_C = zc.GENDER_IDENTITY_C
--where 1=1
--and PAT_ID = 'Z2934052'

--select gc.TITLE, gi.TITLE, pt2.PAT_MRN_ID, pt.* 
--From CLARITY..PATIENT_4 pt
--left outer join CLARITY..ZC_GENDER_CODE gc
--on pt.GENDER_IDENTITY_C = gc.GENDER_CODE_C
--left outer join CLARITY..ZC_GENDER_IDENTITY gi
--on pt.GENDER_IDENTITY_C = gi.GENDER_IDENTITY_C
--left join CLARITY..PATIENT pt2
--on pt2.PAT_ID = pt.PAT_ID
--where 1=1
--and pt.PAT_ID = 'Z2934052'

select pt.PAT_ID, gc.TITLE AS GENDER_CODE_TITLE, gi.TITLE AS GENDER_IDENTITY_TITLE, so.SEXUAL_ORIENTATN_C, soc.NAME AS SEXUAL_ORIENTATN_NAME, cpt.Gender_Identity_Name, cpt.Sexual_Orientation_Name_Current, cpt.Sex_Asgn_at_Birth_Name, cpt.Preferred_Name, cpt.Preferred_Name_Type, pt2.PAT_MRN_ID
From CLARITY..PATIENT_4 pt
left outer join CLARITY..ZC_GENDER_CODE gc
on pt.GENDER_IDENTITY_C = gc.GENDER_CODE_C
left outer join CLARITY..ZC_GENDER_IDENTITY gi
on pt.GENDER_IDENTITY_C = gi.GENDER_IDENTITY_C
left join CLARITY..PATIENT pt2
on pt2.PAT_ID = pt.PAT_ID
LEFT JOIN CLARITY..PAT_SEXUAL_ORIENTATION so
ON so.PAT_ID = pt.PAT_ID
LEFT OUTER JOIN CLARITY..ZC_SEXUAL_ORIENTATION AS soc
ON so.SEXUAL_ORIENTATN_C = soc.SEXUAL_ORIENTATION_C
LEFT OUTER JOIN CLARITY_App.dbo.Dim_Clrt_Pt cpt
ON cpt.Clrt_PAT_ID = pt.PAT_ID
WHERE 1 = 1
--AND gi.TITLE IS NOT NULL
--and pt.PAT_ID = 'Z2934052'
--ORDER BY pt.PAT_ID
ORDER BY so.SEXUAL_ORIENTATN_C DESC, pt.PAT_ID