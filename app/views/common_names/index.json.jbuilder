json.array!(@common_names) do |common_name|
  json.extract! common_name, :id, :name, :geographic_area_id, :otu_id, :language_id, :start_year, :end_year
  json.url common_name_url(common_name, format: :json)
end
