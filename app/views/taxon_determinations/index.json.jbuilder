json.array!(@taxon_determinations) do |taxon_determination|
  json.extract! taxon_determination, :id, :biological_collection_object_id, :otu_id, :position, :year_made, :month_made, :day_made, :created_by_id, :updated_by_id, :project_id
  json.url taxon_determination_url(taxon_determination, format: :json)
end
