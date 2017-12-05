json.extract! taxon_determination, :id, :biological_collection_object_id, :otu_id, :position, :year_made, :month_made, :day_made, :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at
json.object_tag taxon_determination_tag(taxon_determination)
json.url taxon_determination_url(taxon_determination, format: :json)
json.global_id taxon_determination.to_global_id.to_s

json.type 'TaxonDetermination'


