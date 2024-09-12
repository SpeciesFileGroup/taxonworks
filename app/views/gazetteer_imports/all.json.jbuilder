json.array!(@import_jobs) do |j|
  json.extract! j, :id, :shapefile, :num_records, :num_records_processed,
    :aborted_reason, :submitted_by

  if j[:started_at].present?
    json.started_at j[:started_at].to_fs(:db) + ' UTC'
  end

  if j[:ended_at].present?
    json.ended_at j[:ended_at].to_fs(:db) + ' UTC'
  end
end