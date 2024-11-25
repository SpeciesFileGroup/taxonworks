json.extract! gazetteer_import, :id, :shapefile, :project_names, :num_records,
:num_records_imported, :error_messages, :submitted_by

if gazetteer_import[:started_at].present?
  json.started_at gazetteer_import[:started_at].to_fs(:db) + ' UTC'
end

if gazetteer_import[:ended_at].present?
  json.ended_at gazetteer_import[:ended_at].to_fs(:db) + ' UTC'
end

# Intended to indicate a job should be considered completed and can be deleted
# even if ended_at was never recorded (due to some error, for example).
json.aged Time.now.utc - gazetteer_import[:created_at] > 1.day
