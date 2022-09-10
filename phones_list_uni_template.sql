with voter_phones_filtered as (
	-- this sub-query produces a filtered version of voter_phones
	-- ALL STRIKING + FILTERING MUST BE DONE HERE, b/c subsequent queries will rank and coalesce phones
	select p.*
	from cpd_ngp.voter_phones_master p

	-- vf (voterfile)
	left join ts.ntl_current vf on vf.vb_voterbase_id = p.voterbase_id

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
		where (
            -- codes to always exclude (INcluding thrutalk)
                resultshortname in (
                                    'Do Not Contact',
                                    'Do Not Call',
                                    'Deceased',
                                    'Refused',
                                    'Spanish',
                                    'Other Language'
                )
     )
	) vs on vf.vb_voterbase_id = vs.vb_voterbase_id

	-- sr (survey response from van strikelist)
	left join (
		select distinct vb_voterbase_id, 1 as van_survey_strike
		from tmc_van.cpd_ngp_survey_responses_summary_vf
		where surveyresponsename in ('4 - Leaning Loeffler','5 - Strong Loeffler','4 - Leaning Perdue','5 - Strong Perdue')
	) sr on sr.vb_voterbase_id = vf.vb_voterbase_id

	where
		-- filter down to universe
		vf.vb_voterbase_id in (select distinct vb_voterbase_id from cpd_ngp.) -- INPUT UNIVERSE HERE

		-- standard filters from voterfile (sanity check)
		and vf.vb_voterbase_deceased_flag is null
		and vf.vb_voterbase_registration_status in ('Registered')
		and vf.vb_vf_voter_status in ('Active', 'Inactive')
		and vf.vb_vf_source_state= 'GA'

		-- thrutalk strikes
		and thrutalk_strike_1 is null
		and thrutalk_strike_2 is null

		-- van strikes
		and van_strike is null
		and van_survey_strike is null
)
select
	-- common fields from voterfile (vf)
	vf.vb_voterid, -- state file ID
	vf.vb_smartvan_id as vanid,
	initcap(vf.vb_tsmart_first_name) as first_name,
	initcap(vf.vb_tsmart_last_name) as last_name,
	initcap(vf.vb_tsmart_middle_name) as middle_name,
	initcap(vf.vb_vf_reg_city) as city,
	initcap(vf.vb_vf_county_name) as county,
	vf.age_next_election as age,
	vf.vb_voterbase_gender as gender,
	vf.vb_voterbase_race as race,
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
					when p.type = 'tmc_cell' then 10
					when p.type = 'tmc_landline' then 20
					when p.type like '%vr%' then 30 + p.match_score
					else 100
				end as phone_priority,

				row_number() over (
					partition by voterbase_id order by phone_priority ASC
				) as voter_dupe
			from voter_phones_filtered p
		)
		where voter_dupe = 1
	)
	where phone_dupe = 1
) p
-- join in voterfile just for supplemantal info
left join ts.ntl_current vf on p.voterbase_id = vf.vb_voterbase_id
order by vf.vb_smartvan_id asc
;