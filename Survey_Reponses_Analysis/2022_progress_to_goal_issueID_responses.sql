DROP TABLE IF EXISTS cpd_ngp_reporting_2021.c3_volmems_call_p2g_2022;
CREATE TABLE cpd_ngp_reporting_2021.c3_volmems_call_p2g_2022 AS 
WITH a AS ( 
SELECT 
    l.date_called
    , SUM(CASE WHEN l.answer = 'Police Brutality' THEN 1 ELSE 0 END) AS police_brutality
    , SUM(CASE WHEN l.answer = 'Economy' THEN 1 ELSE 0 END) AS Economy
    , SUM(CASE WHEN l.answer = 'Healthcare' THEN 1 ELSE 0 END) AS healthcare
    , SUM(CASE WHEN l.answer = 'Pandemic' THEN 1 ELSE 0 END) AS pandemic
    , SUM(CASE WHEN l.answer = 'Racism' THEN 1 ELSE 0 END) AS racism
    , SUM(CASE WHEN l.answer LIKE 'I%' THEN 1 ELSE 0 END) AS In_Person_EDay
    , SUM(CASE WHEN l.answer = 'Unsure/Not Voting' THEN 1 ELSE 0 END) AS Unsure_Not_Voting
    , SUM(CASE WHEN l.answer = 'Already Voted' THEN 1 ELSE 0 END) AS Already_Voted
    , SUM(CASE WHEN l.answer = 'By Mail' THEN 1 ELSE 0 END) AS By_Mail
    , SUM(CASE WHEN l.answer LIKE 'Early%' THEN 1 ELSE 0 END) AS Early_In_Person
    , SUM(CASE WHEN l.answer = 'Yes' THEN 1 ELSE 0 END) AS YES
    , SUM(CASE WHEN l.answer = 'No' THEN 1 ELSE 0 END) AS NO
    , SUM(CASE WHEN l.answer = 'Unsure' THEN 1 ELSE 0 END) AS Unsure
FROM tmc_thrutalk.cpd_ngp_survey_results_summary l
WHERE l.question IN ('SQ 1 Issue ID', 'RIDES TO POLLS QUESTION', 'PLEDGE TO VOTE', 'SQ 2 PLAN TO VOTE')
AND l.campaign_name = 'ngp-c3-volunteer-team'
GROUP BY 1 
ORDER BY 1 DESC
),  
b AS ( 
SELECT 
    tt.date_called
    , COUNT(tt.call_result_id) AS total_calls
    , COUNT(DISTINCT tt.voter_id) AS unique_people_called
    , COUNT(CASE WHEN tt.result = 'Talked to Correct Person' THEN tt.voter_id END) AS total_contacts
FROM tmc_thrutalk.cpd_ngp_call_results_summary tt
GROUP BY 1
ORDER BY 1 DESC
), 
c AS (
SELECT 
    v.reporting_week
    , v.day_date
    , SUM(DISTINCT(CASE WHEN v.metric IN ('Shifts Recruited') THEN v.goal END)) AS shift_goal
    , SUM(DISTINCT(CASE WHEN v.metric IN ('Calls') THEN v.goal END)) AS call_goal
FROM cpd_ngp_reporting_2021.c3_volmems_call_p2g_2022_backend v
GROUP BY 1, 2
ORDER BY 2 DESC
) 
SELECT 
    c.reporting_week
    , c.day_date
    , a.police_brutality
    , a.economy
    , a.healthcare
    , a.pandemic
    , a.racism
    , a.in_person_eday
    , a.unsure_not_voting
    , a.already_voted
    , a.by_mail
    , a.early_in_person
    , a.yes
    , a.no
    , a.unsure
    , b.total_calls
    , b.unique_people_called
    , b.total_contacts
    , c.shift_goal
    , c.call_goal
    , (b.total_calls::float) / (call_goal::float)::float AS progress_to_goal
FROM c
LEFT JOIN a ON c.day_date = a.date_called
LEFT JOIN b ON c.day_date = b.date_called 
ORDER BY 2 ASC
; 

GRANT ALL ON TABLE cpd_ngp_reporting_2021.c3_volmems_call_p2g_2022 TO GROUP cpd_ngp;