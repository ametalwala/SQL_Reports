---- This is total electorate (in our districts) for the runoff

SELECT
	COUNT(DISTINCT(CASE WHEN p.vb_voterbase_registration_status = 'Registered'
      AND p.vb_voterbase_deceased_flag IS NULL
      AND p.vb_vf_voter_status IN ('Active', 'Inactive')
      THEN p.vb_smartvan_id ELSE NULL END)) AS unique_electorate
    , COUNT(DISTINCT(CASE WHEN r21.vf_g2021 IN ('Y', 'A', 'B', 'R', 'Z') THEN r21.smartvan_id ELSE NULL END)) AS unique_rvoted
    , unique_rvoted::float/unique_electorate::float AS perc_rturnout

FROM (
  SELECT * FROM ts.ntl_current nc
  WHERE nc.vb_vf_source_state = 'GA'
      AND LEFT(nc.vb_voterbase_id, 2) = 'GA'
) p

-- Pull in vote history from the 2021 runoff
LEFT JOIN (
  SELECT * FROM cpd_ngp."2021g_vh_xref_20220208"
  ) AS r21 ON p.vb_smartvan_id = r21.smartvan_id

-- Narrow to places we were canvassing
WHERE
	p.vb_vf_municipal_district IN (
      SELECT DISTINCT vb_vf_municipal_district
      FROM cpd_ngp_universes_2021.uni_2021_c3_municipal_20211105_v01)
--  AND UPPER(p.vb_vf_municipal_district) IN ('ATLANTA')
--  AND UPPER(p.vb_vf_municipal_district) IN ('SOUTH FULTON')
;



---------- This is our contacts in the runoff
SELECT
  COUNT(DISTINCT(vanid)) AS dist_ppl_contacted
-- This one is runoff
   , COUNT(DISTINCT(CASE WHEN r21.vf_g2021 IN ('Y', 'A', 'B', 'R', 'Z') THEN vanid ELSE NULL END)) AS dist_ppl_contacted_voted
    , dist_ppl_contacted_voted::float/dist_ppl_contacted::float AS perc_voted_of_contacted

-- Start with the contacts table
FROM tmc_van.cpd_ngp_contactscontacts_vf cc

-- Pull in vote history from the 2021 runoff
LEFT JOIN (
  SELECT * FROM cpd_ngp."2021g_vh_xref_20220208"
  ) AS r21 ON cc.vanid = r21.smartvan_id

-- Pull in ntl_current for geography info
LEFT JOIN (
  SELECT * FROM ts.ntl_current nc
  WHERE nc.vb_vf_source_state = 'GA'
  AND LEFT(nc.vb_voterbase_id, 2) = 'GA'
  ) p ON p.vb_smartvan_id = cc.vanid
    
-- Narrow narrow narrow to only people we contacted in that time span
WHERE
  cc.contacttypeid IN (36, 2) -- Focus only on contact type "Paid Walk" and "Walk"
  AND cc.committeeid = 84551 -- Only pull from the c3 VAN committee
    -- Specify the time range for the attempts to have happened
  AND cc.datecanvassed::date >= ('2021-11-03')::date
  AND cc.datecanvassed::date <= ('2021-11-30')::date
  AND cc.resultid = 14
-- AND UPPER(p.vb_vf_municipal_district) IN ('ATLANTA')
-- AND UPPER(p.vb_vf_municipal_district) IN ('SOUTH FULTON')
;


----- This is total electorate in the general
SELECT
  COUNT(DISTINCT(CASE WHEN p.vb_voterbase_registration_status = 'Registered'
      AND p.vb_voterbase_deceased_flag IS NULL
      AND p.vb_vf_voter_status IN ('Active', 'Inactive')
      THEN p.vb_smartvan_id ELSE NULL END)) AS unique_electorate
    , COUNT(DISTINCT(CASE WHEN g21.g2021 IN ('Y', 'A') THEN g21.smartvan_id ELSE NULL END)) AS unique_gvoted
    , unique_gvoted::float/unique_electorate::float AS perc_gturnout

FROM (
  SELECT * FROM ts.ntl_current nc
  WHERE nc.vb_vf_source_state = 'GA'
      AND LEFT(nc.vb_voterbase_id, 2) = 'GA'
) p

-- Pull in vote history from the 2021 general
LEFT JOIN (
  SELECT * FROM cpd_ngp.ga_2021g_vh_20220228
  ) as g21 ON p.vb_smartvan_id = g21.smartvan_id

-- Narrow to places we were canvassing
WHERE
  p.vb_vf_municipal_district IN (
      SELECT DISTINCT vb_vf_municipal_district
      -- INSERT THE MUNICIPAL UNIVERSE TABLE)
;



------ This is who we contacted in the general
SELECT
  COUNT(DISTINCT(vanid)) AS dist_ppl_contacted
    , COUNT(DISTINCT(CASE WHEN g2021 IN ('Y', 'A') THEN vanid ELSE NULL END)) AS dist_ppl_contacted_voted
    , dist_ppl_contacted_voted::float/dist_ppl_contacted::float AS perc_voted_of_contacted
FROM tmc_van.cpd_ngp_contactscontacts_vf cc

-- Pull in vote history from the 2021 general
LEFT JOIN (
  SELECT * FROM cpd_ngp.ga_2021g_vh_20220228
  ) as g21 ON cc.vanid = g21.smartvan_id
    
-- Narrow narrow narrow
WHERE
  cc.contacttypeid IN (36, 2) -- Focus only on contact type "Paid Walk" and "Walk"
  AND cc.committeeid = 84551 -- Only pull from the c3 VAN committee
    -- Specify the time range for the attempts to have happened
  AND cc.datecanvassed::date >= ('2021-08-30')::date
  AND cc.datecanvassed::date <= ('2021-11-02')::date
  AND cc.resultid = 14

;
