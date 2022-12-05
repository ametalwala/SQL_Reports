SELECT DISTINCT
	nc.vb_vf_source_state
	, nc.vb_vf_county_name
	, nc.vb_tsmart_city
	, nc.vb_vf_city_council
	, nc.vb_tsmart_city_council
FROM ts.ntl_current nc
WHERE
	nc.vb_vf_source_state = 'GA'
	AND LEFT(nc.vb_voterbase_id, 2) = 'GA'
	AND nc.vb_voterbase_registration_status = 'Registered'
	AND nc.vb_voterbase_deceased_flag IS NULL
	AND nc.vb_vf_voter_status IN ('Active', 'Inactive')
ORDER BY 1, 2, 3, 4, 5
;