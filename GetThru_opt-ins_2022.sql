SELECT
    DISTINCT s.answer
    , COUNT(DISTINCT s.voterbase_id) AS uni_folk
FROM tmc_thrutalk.cpd_ngp_survey_results_summary s
WHERE question IN ('IF YES to CELL COLLECTION', 'Contact Confirmation', 'Mun Gov Follow Up', 'Mun Gov Follow up 2', 'CELL COLLECTION', 'Contact Confirmation', 'Keep in touch?', 'contact info', 'Cell Capture', 'email_or_text', 'Cell Phone Number Input')
GROUP BY 1; 

-- CELL COLLECTION -> IF YES to CELL COLLECTION 
-- Add 'Keep in touch?' 'contact info' 'Cell Capture' 'email_or_text' 'Cell Phone Number Input' ('email_or_text' -> 'contact_text')

SELECT
    DISTINCT s.answer
    , COUNT(DISTINCT s.voterbase_id) AS uni_folk
FROM tmc_thrutalk.cpd_ngp_survey_results_summary s
LEFT JOIN tmc_thrutalk.cpd_ngp_
WHERE question IN ('IF YES to CELL COLLECTION', 'Contact Confirmation', 'Mun Gov Follow Up', 'Mun Gov Follow up 2', 'CELL COLLECTION', 'Contact Confirmation', 'Keep in touch?', 'contact info', 'Cell Capture', 'email_or_text', 'Cell Phone Number Input')
GROUP BY 1; 

SELECT
    COUNT(s.answer) 
    , COUNT(DISTINCT s.voterbase_id) AS uni_folk
FROM tmc_thrutalk.cpd_ngp_survey_results_summary s
LEFT JOIN
(
SELECT * 
FROM ts.ntl_current p
WHERE vb_vf_source_state = 'GA'
AND LEFT (vb_voterbase_id, 2) = 'GA'
) a ON a.vb_voterbase_id = s.voterbase_id 
WHERE s.question IN ('IF YES to CELL COLLECTION', 'Contact Confirmation', 'CELL COLLECTION', 'Contact Confirmation', 'Keep in touch?', 'contact info', 'Cell Capture', 'email_or_text', 'Cell Phone Number Input')
; 
SELECT
    COUNT(s.answer) 
    , COUNT(DISTINCT s.thrutalk_voter_id) AS uni_folk
FROM tmc_thrutalk.cpd_ngp_survey_results_summary s
WHERE s.question IN ('Contact Confirmation', 'CELL COLLECTION', 'Keep in touch?', 'contact info', 'Cell Capture', 'email_or_text', 'Cell Phone Number Input', 'Text call email question')
; 

--keep in touch 'Is it okay if we stay in touch with you to keep you up to date?'
--CELL Collection 'Can we keep you updated with more actions and updates from the New Georgia Project?'
-- Text call email question -> 'Would you like to be reached out to for future upcoming Black and Green Environmental justice activities and events?'

-- Do you agree to receive text messages from NGP
-- Would you like information from us on future events?
-- Would you like to become a NGP member?
-- Will you volunteer with us?
-- Would you like to become an NGPAF volunteer?

SELECT 
    DISTINCT survey_question 
    , COUNT(response)
    , s3_member_name
FROM tmc_thrutext.cpd_ngp_survey_responses_summary
WHERE survey_question IN ('Do you agree to receive text messages from NGP', 
'Would you like information from us on future events?', 
'Would you like to become a NGP member?')
AND response ='Yes'
GROUP BY 1, 3; 