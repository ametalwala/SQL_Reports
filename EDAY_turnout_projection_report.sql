SELECT
  COUNT(case when v.tsmart_requested IS NOT NULL THEN 1 ELSE NULL END) as requested
  , COUNT(case when p.vb_vf_g2020 IN ('A','B','F','R','Y','Z') then 1 else null end) as voted
  , COUNT(case when v.tsmart_requested IS NOT NULL AND (p.vb_vf_g2020 NOT IN ('A','B','F','R','Y','Z') OR p.vb_vf_g2020 IS NULL) then 1 else null end) as g20_rec_novote
  , count(case when v.tsmart_requested IS NOT NULL AND (p.vb_vf_g2020 NOT IN ('A','B','F','R','Y','Z') OR p.vb_vf_g2020 IS NULL) then 1 else null end)::float/count(case when v.tsmart_requested IS NOT NULL THEN 1 ELSE NULL END)::float as g20_req_novote_perc
  FROM ts.ntl_202102 p
  LEFT JOIN ts.early_and_absentee_vote_g2020 v
  ON p.vb_voterbase_id = v.voterbase_id
  WHERE
    p.vb_vf_source_state = 'GA'
    AND v.state = 'GA'