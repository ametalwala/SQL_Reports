SELECT 
	tt.* 
    , ROUND(100.0 * tt.contacted::float / tt.attempted::float, 2)::varchar(1024) || '%' AS percent_contacted
FROM
(
SELECT 
	t.date_called, 
    COUNT(CASE WHEN t.result = 'Talked to Correct Person' THEN 'Contacted' END) AS contacted,
    COUNT(CASE WHEN t.result != 'Talked to Correct Person' THEN 'Attempted' END) AS attempted
FROM tmc_thrutalk.cpd_ngp_call_results_summary t
WHERE t.date_called >= '2021-01-06' 
AND t.date_called <= '2021-11-02'
GROUP BY 1
ORDER BY 1 ASC
) Tt