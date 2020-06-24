json.array!(@serials) do |serial|
  json.extract! serial, :id, :name, :created_by_id, :updated_by_id, :publisher, :place_published, :primary_language_id, :first_year_of_issue, :last_year_of_issue
  json.url serial_url(serial, format: :json)
end
