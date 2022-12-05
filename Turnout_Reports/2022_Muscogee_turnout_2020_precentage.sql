SELECT 
	tn.vb_vf_source_state AS state 
	, tn.vb_vf_county_name AS county
    , tn.civis_race AS race
    , SUM(CASE WHEN tn.vb_vf_g2020 IN ('A','B','F','R','Y','Z') THEN 1 ELSE 0 END) AS general_votes 
	, SUM(CASE WHEN tn.vb_vf_p2020 IN ('A','B','F','R','Y','Z') THEN 1 ELSE 0 END) AS primary_votes
    , SUM(CASE WHEN vb_voterbase_registration_status = 'Registered' AND vb_voterbase_deceased_flag IS NULL 
          AND vb_vf_voter_status IN ('Active', 'Inactive') THEN 1 ELSE 0 END) AS TOT
    , ROUND(100.0 * general_votes::float / TOT::float, 2)::varchar(1024) || '%' AS general_turnout
    , ROUND(100.0 * primary_votes::float / TOT::float, 2)::varchar(1024) || '%' AS primary_turnout
FROM ts.ntl_current tn 
WHERE state = 'GA'
AND county = 'MUSCOGEE'
GROUP BY 1, 2, 3
ORDER BY race