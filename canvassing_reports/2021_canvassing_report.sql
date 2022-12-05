SELECT
    COUNT (DISTINCT cc.vanid) AS unique_people
    , COUNT (DISTINCT cc.vb_voterbase_household_id) AS unique_doors
    , COUNT(cc.contactscontactid) AS walks_attempted 
    , COUNT (DISTINCT(CASE WHEN resultshortname = 'Canvassed' THEN cc.vanid END)) AS walk_successful_contacts
    , COUNT(CASE WHEN resultshortname = 'Canvassed' THEN cc.vanid END) AS total_conversations
    , ROUND(walk_successful_contacts::float/walks_attempted::float, 2) AS contact_rate
    , COUNT(CASE WHEN cc.vb_rank = 1 THEN cc.vanid END) AS total_attempts -- bc there could be people in there 4 time
FROM
(
SELECT 
    *
    , ROW_NUMBER() OVER (PARTITION BY cc.vanid, cc.datecanvassed::date ORDER BY cc.datecanvassed::date) vb_rank
    , ROW_NUMBER() OVER (PARTITION BY tn.vb_voterbase_household_id, cc.datecanvassed::date ORDER BY cc.datecanvassed::date) household_rank
FROM tmc_van.cpd_ngp_contact_attempts_summary_vf cc
LEFT JOIN
(
SELECT *
FROM ts.ntl_current p
WHERE p.vb_vf_source_state  = 'GA'
AND LEFT(p.vb_voterbase_id, 2) = 'GA'
) tn ON cc.vanid = tn.vb_smartvan_id
WHERE cc.datecanvassed::date > ('2021-01-01')::date AND cc.datecanvassed::date <= ('2021-12-31')
AND cc.contacttypename IN ('Walk', 'Paid Walk')
AND cc.committeename = 'New Georgia Project (c3) (TMC)'
) cc