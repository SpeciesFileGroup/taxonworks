json.extract! otu, :id, :name, :taxon_name_id, :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at
json.partial! '/shared/data/all/metadata', object: otu

if extend_response_with('taxonomy')
  json.taxonomy do
   json.merge! otu.taxonomy 
  end
end