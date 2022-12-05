DROP TABLE IF EXISTS cpd_ngp_universes_2021.c3_text_south_fulton_city_councilaction_20220722;
CREATE TABLE cpd_ngp_universes_2021.c3_text_ayg_bus_final_20220713 AS



with voter_phones_filtered as (
	-- this sub-query produces a filtered version of voter_phones
	-- ALL STRIKING + FILTERING MUST BE DONE HERE, b/c subsequent queries will rank and coalesce phones
    SELECT p.*
		FROM (
			SELECT
				distinct phone
				, p.vb_voterbase_id as voterbase_id
				, p.source
			-- An insane way to make sure we have all the phones and they are stacked
			FROM (
				-- SELECT
				-- 	p.vb_voterbase_id as voterbase_id
				-- 	, t.phone as phone
				-- 	, 'vr_form' as source
				-- FROM
				-- 	cpd_ngp_universes_2021.south_fulton_city_council_action_20220722 t
				-- LEFT JOIN (
				-- 	SELECT * FROM ts.ntl_current
				-- 	WHERE LEFT(vb_voterbase_id, 2) = 'GA'
				-- 	AND vb_vf_reg_state = 'GA'
				-- ) p ON p.vb_voterbase_id = t.voterbase_id

			
				SELECT
					p.vb_voterbase_id
					, p.vb_voterbase_phone_wireless as phone
					, 'vb_wireless' as source
				FROM
					cpd_ngp_universes_2021.south_fulton_city_council_action_20220722 t
				LEFT JOIN (
					SELECT * FROM ts.ntl_current
					WHERE LEFT(vb_voterbase_id, 2) = 'GA'
					AND vb_vf_reg_state = 'GA'
				) p ON p.vb_voterbase_id = t.vbvoterbase_id

			UNION ALL
				SELECT
					p.vb_voterbase_id
					, p.vb_voterbase_phone as phone
					, 'vb_voterbase_phone' as source
				FROM
					cpd_ngp_universes_2021.south_fulton_city_council_action_20220722 t
				LEFT JOIN (
					SELECT * FROM ts.ntl_current
					WHERE LEFT(vb_voterbase_id, 2) = 'GA'
					AND vb_vf_reg_state = 'GA'
				) p ON p.vb_voterbase_id = t.vbvoterbase_id

			UNION ALL
				SELECT
					p.vb_voterbase_id
					, p.vb_vf_phone as phone
					, 'vb_vf_phone' as source
				FROM
					cpd_ngp_universes_2021.south_fulton_city_council_action_20220722 t
				LEFT JOIN (
					SELECT * FROM ts.ntl_current
					WHERE LEFT(vb_voterbase_id, 2) = 'GA'
					AND vb_vf_reg_state = 'GA'
				) p ON p.vb_voterbase_id = t.vbvoterbase_id

			UNION ALL
				SELECT
					p.vb_voterbase_id
					, p.cell_tsmart_wireless_phone as phone
					, 'tsmart_wireless' as source
				FROM
					cpd_ngp_universes_2021.south_fulton_city_council_action_20220722 t
				LEFT JOIN (
					SELECT * FROM ts.ntl_current
					WHERE LEFT(vb_voterbase_id, 2) = 'GA'
					AND vb_vf_reg_state = 'GA'
				) p ON p.vb_voterbase_id = t.vbvoterbase_id

			UNION ALL
				SELECT
					p.vb_voterbase_id
					, p.tmc_cell_phone as phone
					, 'tmc_cell' as source
				FROM
					cpd_ngp_universes_2021.south_fulton_city_council_action_20220722 t
				LEFT JOIN (
					SELECT * FROM ts.ntl_current
					WHERE LEFT(vb_voterbase_id, 2) = 'GA'
					AND vb_vf_reg_state = 'GA'
				) p ON p.vb_voterbase_id = t.vbvoterbase_id

			UNION ALL
				SELECT
					p.vb_voterbase_id
					, p.tmc_landline_phone as phone
					, 'tmc_landline' as source
				FROM
					cpd_ngp_universes_2021.south_fulton_city_council_action_20220722 t
				LEFT JOIN (
					SELECT * FROM ts.ntl_current
					WHERE LEFT(vb_voterbase_id, 2) = 'GA'
					AND vb_vf_reg_state = 'GA'
				) p ON p.vb_voterbase_id = t.vbvoterbase_id

			) p
			WHERE
				p.vb_voterbase_id IS NOT NULL
				AND p.phone IS NOT NULL
				-- AND (p.vb_smartvan_id NOT IN (SELECT voter_file_vanid FROM cpd_ngp_universes_2021.c3_full_universe_through_van_20220330)
				-- and p.vb_smartvan_id NOT IN (SELECT vanid FROM cpd_ngp_universes_2021.plans_2022_c3_phones_v04))
			) p

		-- vf (voterfile)
		left join ts.ntl_current vf on vf.vb_voterbase_id = p.voterbase_id

		-- tts (thrutext strike list)
		left join (
			select distinct split_part(contact_phone, '+1', 2) as phone, 1 as thrutext_canvass_code_strike
			from tmc_thrutext.cpd_ngp_surveys
			where
				contact_phone like '+1%' -- sanity check, in case foreign numbers are in there
				and (
					(
						survey_question = 'Wrong Number' AND response = 'Yes'
					) OR (
						survey_question = 'Canvass Results' AND response in ('Wrong Number', 'Moved')
					) OR (
						survey_question = 'What language do you prefer to communicate in?'
					)
				)
		) tts on tts.phone = p.phone

		-- tto (thrutext opt outs)
		left join (
			select distinct split_part(contact_phone, '+1', 2) as phone, 1 as thrutext_opt_out
			from tmc_thrutext.cpd_ngp_opt_outs
			where contact_phone like '+1%' -- sanity check, in case foreign numbers are in there
		) tto on tto.phone = p.phone

		-- ps (phone strikelist from thrutalk: refused, disconnected, etc + survey question like )
		left join (
			select distinct(voter_phone) as phone, 1 as thrutalk_strike_1
			from tmc_thrutalk.cpd_ngp_call_results r
			full outer join tmc_thrutalk.cpd_ngp_script_results s on s.call_result_id = r.id
			where (
				result in ('Disconnected', 'Fax', 'Remove number from list')
				OR answer ilike '%refused%'
				OR answer ilike '%hostile%'
				OR answer ilike '%out of service%'
				OR answer ilike '%deceased%'
			)
		) ps on ps.phone = p.phone

		-- vps (voter-phone strikelist from thrutalk: wrong number, moved)
		left join (
			select distinct vb_voterbase_id as voterbase_id, voter_phone as phone, 1 as thrutalk_strike_2
			from tmc_thrutalk.cpd_ngp_call_results r
			full outer join tmc_thrutalk.cpd_ngp_script_results s on s.call_result_id = r.id
			left join ts.ntl_current vf on vf.vb_smartvan_id = r.voter_id and vf.vb_vf_source_state = 'GA'
			where r.voter_id_type = 'van' and (
				answer ilike '%moved%'
				OR answer ilike '%wrong number%'
			)
		) vps on vps.voterbase_id = p.voterbase_id and vps.phone = p.phone

		-- vs (VAN strikelist)
		left join (
			select distinct a.vb_voterbase_id, 1 as van_strike
			from tmc_van.cpd_ngp_contact_attempts_summary_vf a
			where 
				-- codes to always exclude (all methods)
				resultshortname in (
					'Do Not Contact',
					'Do Not Text',
					'Deceased',
					'Refused',
					'Spanish',
					'Other Language'
				)
		
		) vs on vf.vb_voterbase_id = vs.vb_voterbase_id

		-- -- evs (early vote strikelist: anyone who has already voted)
		-- left join (
		-- 	select distinct voterbase_id, 1 as ev_strike
		-- 	from ts.early_vote_and_ballot
		-- 	where tsmart_voted in ('Absentee', 'Early')
		-- 	and state = 'GA'
		-- ) evs on vf.vb_voterbase_id = evs.voterbase_id

		-- -- sr (survey response from van strikelist)
		-- left join (
		-- 	select distinct vb_voterbase_id, statecode, 1 as van_survey_strike
		-- 	from tmc_van.cpd_ngp_survey_responses_summary_vf
		-- 	-- loeffler survey questions (we are leaving in perdue, focusing on warnock)
		-- 	where surveyresponsename in ('4 - Leaning Loeffler','5 - Strong Loeffler','4 - Leaning Perdue','5 - Strong Perdue')
		-- ) sr on sr.vb_voterbase_id = vf.vb_voterbase_id

		where
			-- filter down to universe
			-- vf.vb_voterbase_id in (select distinct vb_voterbase_id from XXXXX) -- FILL IN UNIVERSE HERE

			-- standard filters from voterfile (sanity check)
			-- vf.vb_voterbase_deceased_flag is null
			-- and vf.vb_voterbase_registration_status in ('Registered')
			-- and vf.vb_vf_voter_status in ('Active', 'Inactive')
			-- and vf.vb_vf_source_state= 'GA'

			-- thrutalk strikes
			-- we leave these in for texting, because they are sufficiently precise (wrong # for this voter, disconnected #)
			 thrutalk_strike_1 is null
			and thrutalk_strike_2 is null

			-- thrutext strikes
			and thrutext_canvass_code_strike is null
			and thrutext_opt_out is null

			-- van strikes
			and van_strike is null
			-- and van_survey_strike is null

			-- -- ev strike
			-- and ev_strike is null

			-- additonal targeting
			-- and vf.vb_voterbase_age <= 25
			-- and (vf.vb_voterbase_race = 'AFAM'
			-- or vf.vb_voterbase_race = 'African-American')
			-- and vf.ts_tsmart_college_graduate_score > 40
			-- and (vf.civis_race != 'WHITE' OR vf.civis_race IS NULL
			-- 		OR (vf.civis_race = 'WHITE'
			-- 			AND (vf.vb_voterbase_age < 35
			-- 				OR (vf.vb_voterbase_gender != 'MALE' and vf.ts_tsmart_marriage_score < 20))))
	)
	select
		-- common fields from voterfile (vf)
		vf.vb_voterid, -- state file ID
		vf.vb_smartvan_id as vanid,
		initcap(vf.vb_tsmart_first_name) as first_name,
		initcap(vf.vb_tsmart_last_name) as last_name,
		initcap(vf.vb_tsmart_middle_name) as middle_name,
		p.phone
	from (
		-- this subquery handles all coalescing and ranking
		-- universe and other filters are applied above, inside voter_phones_filtered
		select *
		from (
			-- this sub-query ranks any duplicate phones based on phone_priority
			-- TODO might want to order by something else, like warnock score?
			select * ,
				row_number() over (
					partition by phone order by phone_priority ASC
				) as phone_dupe
			from (
				-- this sub-query ranks voter's phones based on phone_priority
				select
					p.voterbase_id,
					p.phone,

					-- mess with this to determine priority of phone sources
					case
						when p.source = 'tmc_cell' then 10
						when p.source = 'vb_wireless' then 20
						when p.source = 'tsmart_wireless' then 30
						-- when p.phone_source like '%self%' then 40
						else 100
					end as phone_priority,

					row_number() over (
						partition by voterbase_id order by phone_priority ASC
					) as voter_dupe
				from voter_phones_filtered p
				where p.source != 'tmc_landline' -- no landlines for texting
			)
			where voter_dupe = 1
		)
		where phone_dupe = 1
	) p
-- join in voterfile just for supplemantal info
left join ts.ntl_current vf on p.voterbase_id = vf.vb_voterbase_id
order by vf.vb_smartvan_id asc
;


GRANT ALL ON TABLE cpd_ngp_universes_2021.c3_text_ayg_bus_final_20220713 TO GROUP cpd_ngp;