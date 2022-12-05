SELECT 
	tn.vb_vf_municipal_district
    , tn.vb_vf_city_council
    , COUNT(CASE WHEN t.result = 'Talked to Correct Person' THEN 'Contacted' END) AS contacted
    , COUNT(DISTINCT t.call_result_id) AS total_attempts
FROM tmc_thrutalk.cpd_ngp_call_results_summary t
LEFT JOIN 
(
SELECT *
FROM ts.ntl_current tn
WHERE tn.vb_vf_source_state = 'GA' 
) tn ON t.voterbase_id = tn.vb_voterbase_id  
WHERE t.date_called >= '2021-08-30' 
AND t.date_called <= '2021-11-30'
GROUP BY 1, 2
ORDER BY 1 ASC