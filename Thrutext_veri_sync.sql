SELECT
	tt.s3_member_name
	, tt.campaign_name
    , COUNT(DISTINCT tt.message_id) AS a
    , COUNT(DISTINCT tt.conversation_id) AS b
    , COUNT(DISTINCT tt.voterbase_id) AS c
    , COUNT(DISTINCT tt.contact_phone) AS d
    , COUNT(DISTINCT tt.outgoing) AS e
    , COUNT(tt.messages_created_timestamp) AS f
FROM tmc_thrutext.cpd_ngp_message_summary tt 
WHERE s3_member_name = 'ngpc3'
AND campaign_name = 'HD 156 Election and Hurricane Elsa ' 
GROUP BY 1, 2