--field name: s3_member_name
SELECT
	tt.s3_member_name
	, tt.campaign_name
	, tt.import_date
	, tt.messages_created_date
FROM tmc_thrutext.cpd_ngp_message_summary tt 
WHERE s3_member_name = 'newgeorgia'
ORDER BY 4 DESC
;