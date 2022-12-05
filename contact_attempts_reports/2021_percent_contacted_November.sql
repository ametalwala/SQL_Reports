SELECT 
	tt.* 
    ,tt.contacted::float / tt.total_attempts::float AS percent_contacted
FROM
(
SELECT 
	t.date_called 
    , COUNT(CASE WHEN t.result = 'Talked to Correct Person' THEN 'Contacted' END) AS contacted
    , COUNT(DISTINCT t.call_result_id) AS total_attempts
FROM tmc_thrutalk.cpd_ngp_call_results_summary t
WHERE t.date_called >= '2021-11-02' 
AND t.date_called <= '2021-11-30'
GROUP BY 1
ORDER BY 1 ASC
) Tt