SELECT 
	 csr.statecode
    , csr.vanid
  	, csr.datecanvassed
    , csr.contactscontactid
    , csr.surveyquestionid
    , csr.surveyresponseid
    , tv.surveyquestionname
    , tv.surveyquestiontext
    , tr.surveyresponsename 
FROM tmc_van.cpd_ngp_contactssurveyresponses_vf csr
LEFT JOIN tmc_van.cpd_ngp_surveyquestions tv ON csr.surveyquestionid = tv.surveyquestionid
LEFT JOIN tmc_van.cpd_ngp_surveyresponses tr ON csr.surveyresponseid = tr.surveyresponseid
LEFT JOIN tmc_van.cpd_ngp_survey_responses_summary_vf srs ON tv.surveyquestionid = srs.surveyquestionid AND tr.surveyresponseid = srs.surveyresponseid
WHERE csr.statecode = 'GA'
AND csr.vanid IS NOT NULL 
ORDER BY 1, 2