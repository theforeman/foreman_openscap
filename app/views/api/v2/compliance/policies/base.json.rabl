object @policy

extends "api/v2/compliance/common/org"
extends "api/v2/compliance/common/loc"

attributes :id, :name, :period, :weekday, :description, :scap_content_id, :scap_content_profile_id, :day_of_month, :cron_line,
           :tailoring_file_id, :tailoring_file_profile_id, :deploy_by
