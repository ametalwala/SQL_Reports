SELECT
    a.vb_vf_reg_address_1 
    , a.vb_vf_reg_city 
    , a.vb_vf_reg_state 
    , a.vb_vf_reg_zip 
FROM 
(
SELECT * 
FROM tmc_van.cpd_ngp_contactscontacts_vf tt
WHERE tt.datecreated::date >= ('2022-01-01')::date
AND tt.contacttypeid = '37'
) tt
LEFT JOIN 
( 
SELECT * 
FROM ts.ntl_current p 
WHERE p.vb_vf_source_state = 'GA'
AND LEFT(p.vb_voterbase_id, 2) = 'GA'
) a ON tt.vanid = a.vb_smartvan_id
GROUP BY 1, 2, 3, 4
; 

-- field - vr forms collected
SELECT 
    address
    , city
    , county
    , state
    , zip_code
FROM cpd_ngp_vr_2021.c3_vr_matched_current
WHERE date > '2022-01-01'; 

-- report for to see if creating an interactive map would be sufficient to display the information
-- it was