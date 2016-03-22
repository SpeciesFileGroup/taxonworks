# json.extract! @otu, :id, :name, :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at, :taxon_name_id

json.success true
json.result do
  json.id @otu.id
  json.collection_objects @collection_objects
end
