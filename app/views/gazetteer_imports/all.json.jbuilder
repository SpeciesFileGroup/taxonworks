json.array!(@import_jobs) do |j|
  json.extract! j, :id, :shapefile, :project_names, :num_records,
    :num_records_imported, :error_messages, :submitted_by

  if j[:started_at].present?
    json.started_at j[:started_at].to_fs(:db) + ' UTC'
  end

  if j[:ended_at].present?
    json.ended_at j[:ended_at].to_fs(:db) + ' UTC'
  end

  # Intended to indicate a job should be considered completed and can be deleted
  # even if ended_at was never recorded (due to some error, for example).
  json.aged Time.now.utc - j[:created_at] > 1.day

end