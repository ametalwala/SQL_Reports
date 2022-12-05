SELECT 
	SUM(tt.contacted)
    , SUM(tt.total_attempts)
FROM
(
SELECT 
	t.date_called 
    , COUNT(CASE WHEN t.result = 'Talked to Correct Person' THEN 'Contacted' END) AS contacted
    , COUNT(DISTINCT t.call_result_id) AS total_attempts
FROM tmc_thrutalk.cpd_ngp_call_results_summary t
WHERE t.date_called >= '2021-01-01' 
AND t.date_called <= '2021-12-02'
AND t.campaign_name IN ('ngp-c3-line-1', 'ngp-c3-line-2', 'ngp-c3-line-3', 'ngp-c3-line-4')
GROUP BY 1
ORDER BY 1 ASC
) Tt