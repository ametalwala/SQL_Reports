SELECT 
	tn.vb_vf_source_state AS state 
	, tn.vb_vf_county_name AS county
    , tn.civis_race AS race
    , COUNT(vb_voterbase_id) AS eligible_black_male_voters
FROM ts.ntl_202012_xf tn
WHERE state = 'GA'
AND vb_voterbase_registration_status = 'Registered'
AND vb_voterbase_deceased_flag IS NULL
AND vb_vf_voter_status IN ('Active', 'Inactive')
AND race = 'AFAM'
AND vb_voterbase_gender = 'Male'
GROUP BY 1, 2, 3
ORDER BY county