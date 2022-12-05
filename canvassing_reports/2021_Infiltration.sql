SELECT 
	county_level_data.*
    , uni_counts.target_count
FROM 
(
SELECT  
	tn.vb_vf_county_name AS county
	, COUNT (DISTINCT tmc.statecode || tmc.vanid) AS count_unique_vanid
FROM tmc_van.cpd_ngp_contactscontacts_vf tmc
LEFT JOIN 
( 
SELECT cpd.vb_smartvan_id 
  FROM cpd_ngp_universes_2021.uni_2021_municipal_20210706_v01_vanids_filtered_by_van cpd
) unique_vanid ON tmc.statecode = 'GA' AND tmc.vanid = unique_vanid.vb_smartvan_id
LEFT JOIN tmc_van.tsm_tmc_results canvassed_results ON tmc.resultid = canvassed_results.resultid 
LEFT JOIN ts.ntl_current tn ON tmc.statecode = tn.vb_vf_source_state AND tmc.vanid = tn.vb_smartvan_id
WHERE tmc.datecanvassed::date > ('2020-11-04')::date AND tmc.datecanvassed::date <= ('2021-01-05')::date
AND canvassed_results.resultshortname = 'Canvassed'
AND unique_vanid.vb_smartvan_id IS NOT NULL
AND tmc.statecode = 'GA' 
GROUP BY 1
ORDER BY 2 desc 
) county_level_data
LEFT JOIN
(
SELECT COUNT (DISTINCT uni.vb_smartvan_id) as target_count
  	, ntl.vb_vf_county_name AS county 
  FROM cpd_ngp_universes_2021.uni_2021_municipal_20210706_v01_vanids_filtered_by_van uni 
LEFT JOIN ts.ntl_current ntl ON ntl.vb_smartvan_id = uni.vb_smartvan_id
WHERE ntl.vb_vf_source_state = 'GA'
GROUP BY 2
ORDER BY 2
) uni_counts ON county_level_data.county = uni_counts.county
