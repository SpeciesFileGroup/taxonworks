json.extract! taxon_determination, :id, :biological_collection_object_id, :otu_id, 
  :position, :year_made, :month_made, :day_made,
  :print_label,
  :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at
json.partial! '/shared/data/all/metadata', object: taxon_determination, klass: 'TaxonDetermination'

