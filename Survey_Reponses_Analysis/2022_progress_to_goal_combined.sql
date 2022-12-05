
-- p2g & script responses consolidated 
DROP TABLE IF EXISTS cpd_ngp_reporting_2021.c3_gotv_volmems_phone_p2g_2022;
CREATE TABLE cpd_ngp_reporting_2021.c3_gotv_volmems_phone_p2g_2022 AS 
SELECT
    tt.reporting_week
    , tt.day_date
    , SUM(CASE WHEN tt.metric = 'Shifts Recruited' THEN tt.goal END) AS shift_goal
    , SUM(CASE WHEN tt.metric = 'Calls' THEN tt.goal END) AS call_goal
    , COUNT(DISTINCT tt.call_result_id) AS total_calls
    , COUNT(DISTINCT tt.voter_id) AS unique_people_called
    , COUNT(CASE WHEN tt.result = 'Talked to Correct Person' THEN tt.voter_id END) AS total_contacts
    , (total_calls::float) / (call_goal::float)::float AS progress_to_goal
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
FROM
(
SELECT 
    * 
FROM tmc_thrutalk.cpd_ngp_call_results_summary t
WHERE t.campaign_name = 'ngp-c3-volunteer-team'
AND t.date_called >= '2022-03-07'
) tt
LEFT JOIN
(
SELECT * 
FROM tmc_thrutalk.cpd_ngp_survey_results_summary l
WHERE l.campaign_name = 'ngp-c3-volunteer-team'
AND l.date_called >= '2022-03-07'
) l ON tt.voterbase_id = l.voterbase_id 
LEFT JOIN cpd_ngp_reporting_2021."2022_c3_vol_mems_call_goals" v ON t.date_called = v.day_date
WHERE l.question IN ('SQ 1 Issue ID', 'RIDES TO POLLS QUESTION', 'PLEDGE TO VOTE', 'SQ 2 PLAN TO VOTE')
GROUP BY 1, 2
ORDER BY 2 ASC
;
-- Updates p2g query by itself
SELECT
    tt.reporting_week -- added weeks
    , tt.day_date
    , (CASE WHEN tt.metric = 'Shifts Recruited' THEN tt.goal END) AS shift_goal -- added shift_goal
    , (CASE WHEN tt.metric = 'Calls' THEN ROUND(tt.goal) END) AS call_goal
    , COUNT(DISTINCT tt.call_result_id) AS total_calls
    , COUNT(DISTINCT tt.voter_id) AS unique_people_called
    , COUNT(CASE WHEN tt.result = 'Talked to Correct Person' THEN tt.voter_id END) AS total_contacts
    , (total_calls::float) / (call_goal::float)::float AS progress_to_goal
FROM
(
SELECT 
    * 
FROM tmc_thrutalk.cpd_ngp_call_results_summary t
LEFT JOIN cpd_ngp_reporting_2021."2022_c3_vol_mems_call_goals" v ON t.date_called = v.day_date
WHERE t.campaign_name = 'ngp-c3-volunteer-team'
AND t.date_called >= '2022-03-07'
) tt
GROUP BY 1, 2, 3, 4
ORDER BY 2 ASC



SUM(goal(case when metric = 'Shifts Recruited' END)) as shift_goal