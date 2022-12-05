SELECT 
	'GA' as state
	, CASE WHEN reporting_week >= '2022-03-08' AND reporting_week <= '2022-05-24' THEN 'Primary'
		   WHEN reporting_week >= '2022-05-31' THEN 'Runoff'
		   ELSE NULL END AS "Door_Election_Phase"
	, sum(goal) as total_goal
	, COUNT(DISTINCT(reporting_week)) as week_count
FROM cpd_ngp_reporting_2021.c3_field_primary_goals_2022
WHERE reporting_week <= current_date
AND [Door_Election_Phase=Door_Election_Phase]
AND metric = 'Doors'; 



SELECT
    EXTRACT(month from b.date_called)
    , COUNT(CASE WHEN a.name = 'Sb' THEN b.call_result_id ELSE NULL END) as total_calls_made
FROM tmc_thrutalk.call_results_summary b
LEFT JOIN
(
SELECT 
    a.name
    , a.id
FROM tmc_thrutalk.cpd_ngp_callers a
) a ON a.id = b.call_result_id
GROUP BY 1; 


SELECT 
	CAST(date as date) AS date 
	COUNT(CASE WHEN name = 'sb' THEN id ELSE NULL END) AS total_calls_made
FROM tmc_thrutalk.cpd_ngp_callers; 