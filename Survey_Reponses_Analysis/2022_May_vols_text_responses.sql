DROP TABLE IF EXISTS cpd_ngp_reporting_2021.c3_volmems_txt_20220520;
CREATE TABLE cpd_ngp_reporting_2021.c3_volmems_txt_20220520 AS 
WITH a AS (
SELECT 
	t.import_date AS date
	, SUM(CASE WHEN t.message_body LIKE 'Great! We recommend%' THEN 1 ELSE 0 END) AS yes_to_voting
	, SUM(CASE WHEN t.message_body LIKE '%bring a photo ID to the polls%' THEN 1 ELSE 0 END) AS in_person
	, SUM(CASE WHEN t.message_body LIKE 'Wonderful! Thanks for being a voter.%' THEN 1 ELSE 0 END) AS absentee
	, SUM(CASE WHEN t.message_body LIKE 'We took to the polls and made history in Georgia in 2020%' THEN 1 ELSE 0 END) AS undecided_or_not_voting
	, SUM(CASE WHEN t.message_body LIKE 'I understand. If you change your mind%' THEN 1 ELSE 0 END) AS undecided_2x
	, SUM(CASE WHEN t.message_body LIKE 'Follow this link to get registered%' THEN 1 ELSE 0 END) AS unregistered 
	, SUM(CASE WHEN t.message_body LIKE 'Awesome! I just wnat to confirm%' THEN 1 ELSE 0 END) AS already_voted
	, SUM(CASE WHEN t.message_body LIKE 'I am optiing you out of texts%' THEN 1 ELSE 0 END) AS opt_outs
FROM tmc_thrutext.cpd_ngp_messages t
WHERE t.campaign_name IN ('05022022 General Election 5-24-22', '05102022 General Election 5-24-22', '05172022 General Election 5-24-22', '06132022 Primary Runoff Election 6-21-22')
AND t.import_date >= '2022-05-01' 
GROUP BY 1 
ORDER BY 1 DESC
),
b AS (
SELECT
	m.messages_created_date AS date  
	, (CASE WHEN m.campaign_name IN ('05022022 General Election 5-24-22', '05102022 General Election 5-24-22') THEN '1st Text Bank'
			WHEN m.campaign_name = '05172022 General Election 5-24-22' THEN '2nd Text Bank'
			WHEN m.campaign_name = '(Cloned) 05242022 General Election 5-24-22' THEN 'Election Day Text Bank'
			WHEN m.campaign_name = '06132022 Primary Runoff Election 6-21-22' THEN 'Runoff Election Text Bank'
			ELSE NULL END) AS textbank 
	, COUNT(DISTINCT m.voterbase_id) AS unique_people
    , COUNT(m.message_id) AS total_messages
    , COUNT(m.conversation_id) AS total_conversations
    , COUNT(m.voterbase_id) AS total_people_messaged 
    , SUM(CASE WHEN m.incoming = '1' THEN 1 ELSE 0 END) AS replies 
FROM tmc_thrutext.cpd_ngp_message_summary m 
WHERE m.s3_member_name = 'newgeorgia'
AND m.messages_created_date >= '2022-05-01'
GROUP BY 1, 2
ORDER BY 1 DESC
) 
SELECT 
	a.date
	, a.yes_to_voting
	, a.in_person
	, a.absentee
	, a.undecided_or_not_voting
	, a.undecided_2x
	, a.unregistered
	, a.already_voted
	, a.opt_outs
	, b.textbank	
	, b.total_messages
	, b.total_conversations
	, b.unique_people
	, b.total_people_messaged
	, b.replies
FROM b 
LEFT JOIN a ON a.date = b.date
ORDER BY 1 ASC
;

GRANT ALL ON TABLE cpd_ngp_reporting_2021.c3_volmems_txt_20220520 TO GROUP cpd_ngp;