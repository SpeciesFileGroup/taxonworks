json.array!(@serial_chronologies) do |serial_chronology|
  json.extract! serial_chronology, :id, :preceding_serial_id, :succeeding_serial_id, :created_by_id, :modified_by_id
  json.url serial_chronology_url(serial_chronology, format: :json)
end
