json.array!(@import_jobs) do |j|
  json.extract! j, :shapefile, :num_records, :num_records_processed, :aborted_reason,
    :started_at, :ended_at
end