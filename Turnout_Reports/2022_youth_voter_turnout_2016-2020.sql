WITH a AS 
( 
SELECT
    p.vb_vf_source_state
   , SUM(CASE WHEN vb_voterbase_registration_status = 'Registered' THEN 1 ELSE 0 END) AS total_reg_2020
   , COUNT(case when p.vb_vf_g2020 IN ('A','B','F','R','Y','Z') AND p.vb_voterbase_age <= '29' then 1 else null end) as total_youth_votes_2020
FROM ts.ntl_202102 p
WHERE vb_vf_source_state = 'GA'
AND LEFT(vb_voterbase_id, 2) = 'GA'
AND p.vb_vf_voter_status = 'Active'
AND p.vb_voterbase_deceased_flag IS NULL
GROUP BY 1
), 
b AS 
(
SELECT 
    p.vb_vf_source_state
   , SUM(CASE WHEN vb_voterbase_registration_status = 'Registered' THEN 1 ELSE 0 END) AS total_reg_2016
   , COUNT(case when p.vb_vf_g2016 IN ('A','B','F','R','Y','Z') AND p.vb_voterbase_age <= '29' then 1 else null end) as total_youth_votes_2016
FROM ts.ntl_2016_historic p
WHERE vb_vf_source_state = 'GA'
AND LEFT(vb_voterbase_id, 2) = 'GA'
AND p.vb_vf_voter_status = 'Active'
AND p.vb_voterbase_deceased_flag IS NULL
GROUP BY 1
)
SELECT 
	a.total_reg_2020
	, a.total_youth_votes_2020
	, b.total_reg_2016
	, b.total_youth_votes_2016
	, (a.total_youth_votes_2020::float) / (a.total_reg_2020::float)::float AS youth_perc_2020
	, (b.total_youth_votes_2016::float) / (b.total_reg_2016::float)::float AS youth_perc_2016
	, (youth_perc_2020 - youth_perc_2016) AS youth_growth
FROM a
LEFT JOIN b ON a.vb_vf_source_state = b.vb_vf_source_state


--2020 general election youth voter (under 29) turnout increase from 2016 in GA
--2020 general election youth turnout / 2020 general election registered
--2016 general election youth turnout / 2016 general election registered
--The change between them
total_reg_2020	total_youth_votes_2020	total_reg_2016	total_youth_votes_2016	youth_perc_2020	youth_perc_2016	youth_growth
7340868	785404	5370884	571374	0.106990617458317	0.106383604635661	0.000607012822655462

total_reg_2020 - 7340868
total_youth_votes_2020 - 785404
total_reg_2016 - 5370884
total_youth_votes_2016 - 571374
youth_perc_2020 - 0.106990617458317
youth_perc_2016 - 0.106383604635661
youth_growth - 0.000607012822655462


total_reg_2020	total_youth_votes_2020	total_reg_2016	total_youth_votes_2016	youth_perc_2020	youth_perc_2016	youth_growth
7729838	4558048	6625053	3587107	0.589669278968072	0.541445781641294	0.0482234973267774
total_reg_2020 - 7729838
total_youth_votes_2020 - 4558048
total_reg_2016 - 6625053
total_youth_votes_2016 - 3587107
youth_perc_2020 - 0.589669278968072
youth_perc_2016 - 0.541445781641294
youth_growth - 0.0482234973267774