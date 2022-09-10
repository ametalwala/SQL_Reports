SELECT 
	survey_contacts.statecode
    , survey_contacts.vanid
    , survey_contacts.question_id
    , survey_contacts.response_id
    , survey_contacts.campaignid
    , survey_question.surveyquestionname
    , survey_response.surveyresponsename
FROM
(
SELECT 
	csr.statecode AS statecode
    , csr.vanid AS vanid
    , csr.contactssurveyresponseid
    , csr.surveyquestionid AS question_id
    , csr.surveyresponseid AS response_id
    , csr.datecanvassed 
    , csr.campaignid 
FROM tmc_van.cpd_ngp_contactssurveyresponses_vf csr
--WHERE vanid IS NOT NULL 
--AND csr.statecode = 'GA'
) survey_contacts
LEFT JOIN
(
SELECT sq.surveyquestionid
  		, sq.stateid
  		, sq.surveyquestionname 
  FROM tmc_van.cpd_ngp_surveyquestions sq
) survey_question ON survey_contacts.statecode = survey_question.stateid AND survey_contacts.question_id = survey_question.surveyquestionid 
LEFT JOIN
( 
SELECT sr.surveyresponseid
  		, sr.surveyquestionid
  		, sr.surveyresponsename
FROM tmc_van.cpd_ngp_surveyresponses sr
--WHERE sr.surveyresponseid IS NOT NULL 
--AND sr.surveyquestionid IS NOT NULL
--AND sr.surveyresponsename IS NOT NULL 
) survey_response ON survey_question.surveyquestionid = survey_response.surveyquestionid AND survey_contacts.response_id = survey_response.surveyresponseid
--WHERE survey_contacts.campaignid IS NOT NULL
--AND survey_question.surveyquestionname IS NOT NULL 
--AND survey_response.surveyresponsename IS NOT NULL 
ORDER BY 1