json.extract! otu, :id, :name, :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at, :taxon_name_id
json.object_tag object_tag(otu)
json.url otu_url(otu, format: :json)

