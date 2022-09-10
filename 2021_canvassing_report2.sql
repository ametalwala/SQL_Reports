SELECT
    a.unique_people
    , a.unique_doors
    , a.walks_attempted
    , a.walk_successful_contacts
    , a.total_conversations
    , a.total_doors_attempted
    , a.contact_rate
    , COUNT(CASE WHEN a.vb_rank = 1 THEN a.vb_voterbase_id END) as total_attempts 
FROM 
(
SELECT -- take all aggs move outside and above 
    COUNT (DISTINCT cc.vb_voterbase_id) AS unique_people
    , COUNT (DISTINCT tn.vb_voterbase_household_id) AS unique_doors
    , COUNT(cc.contactscontactid) AS walks_attempted 
    , COUNT (DISTINCT(CASE WHEN resultshortname = 'Canvassed' THEN cc.vb_voterbase_id END)) AS walk_successful_contacts
    , COUNT(CASE WHEN resultshortname = 'Canvassed' THEN cc.vb_voterbase_id END) AS total_conversations
    , COUNT(tn.vb_voterbase_household_id) AS total_doors_attempted  
    , ROUND(walk_successful_contacts::float/walks_attempted::float, 2) AS contact_rate
    , ROW_NUMBER() OVER (PARTITION BY cc.vb_voterbase_id, cc.datecanvassed::date ORDER BY cc.datecanvassed::date) vb_rank
FROM tmc_van.cpd_ngp_contact_attempts_summary_vf cc
LEFT JOIN
(
SELECT *
FROM ts.ntl_current p
WHERE LEFT(p.vb_voterbase_id, 2) = 'GA'
AND p.vb_vf_source_state  = 'GA'
) tn ON cc.vb_voterbase_id = tn.vb_voterbase_id
WHERE cc.datecanvassed::date > ('2021-01-01')::date AND cc.datecanvassed::date <= ('2021-12-31')
AND cc.contacttypename IN ('Walk', 'Paid Walk')
AND cc.committeename = 'New Georgia Project (c3) (TMC)'
AND vb_rank = 1
) a 
--GROUP BY 1, 2, 3, 4, 5, 6, 7
; 
SELECT
    COUNT (DISTINCT cc.vb_voterbase_id) AS unique_people
    , COUNT (DISTINCT tn.vb_voterbase_household_id) AS unique_doors
    , COUNT(cc.contactscontactid) AS walks_attempted 
    , COUNT (DISTINCT(CASE WHEN resultshortname = 'Canvassed' THEN cc.vb_voterbase_id END)) AS walk_successful_contacts
    , COUNT(CASE WHEN resultshortname = 'Canvassed' THEN cc.vb_voterbase_id END) AS total_conversations
    , COUNT(tn.vb_voterbase_household_id) AS total_doors_attempted  
    , ROUND(walk_successful_contacts::float/walks_attempted::float, 2) AS contact_rate
    , COUNT(CASE WHEN cc.vb_rank = 1 THEN cc.vb_voterbase_id END) as total_attempts 
FROM
(
SELECT -- take all aggs move outside and above 
    *
    , ROW_NUMBER() OVER (PARTITION BY cc.vb_voterbase_id, cc.datecanvassed::date ORDER BY cc.datecanvassed::date) vb_rank
FROM tmc_van.cpd_ngp_contact_attempts_summary_vf cc
) cc
LEFT JOIN
(
SELECT *
FROM ts.ntl_current p
WHERE LEFT(p.vb_voterbase_id, 2) = 'GA'
AND p.vb_vf_source_state  = 'GA'
) tn ON cc.vb_voterbase_id = tn.vb_voterbase_id
WHERE cc.datecanvassed::date > ('2021-01-01')::date AND cc.datecanvassed::date <= ('2021-12-31')
AND cc.contacttypename IN ('Walk', 'Paid Walk')
AND cc.committeename = 'New Georgia Project (c3) (TMC)'
;
--GROUP BY 1, 2, 3, 4, 5, 6, 7