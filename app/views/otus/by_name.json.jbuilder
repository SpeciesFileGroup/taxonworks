# json.extract! @otu, :id, :name, :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at, :taxon_name_id

json.success true
json.result do
  json.name @otu_name
  json.otu_ids @otu_ids
end
