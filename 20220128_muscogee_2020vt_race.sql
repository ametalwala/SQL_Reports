SELECT 
	tn.vb_vf_source_state AS state 
	, tn.vb_vf_county_name AS county
    , tn.vb_vf_race AS race
    , SUM(CASE WHEN tn.vb_vf_g2020 IN ('A','B','F','R','Y','Z') THEN 1 ELSE 0 END) AS general_votes
	, SUM(CASE WHEN tn.vb_vf_p2020 IN ('A','B','F','R','Y','Z') THEN 1 ELSE 0 END) AS primary_votes
FROM ts.ntl_current tn
WHERE state = 'GA' 
AND county = 'MUSCOGEE'
GROUP BY 1, 2, 3
ORDER BY race