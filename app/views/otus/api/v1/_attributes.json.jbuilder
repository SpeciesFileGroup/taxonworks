json.extract! otu, :id, :name, :taxon_name_id, :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at
json.global_id otu.to_global_id.to_s

# consider descoration extensions
json.object_tag object_tag(otu)


if extend_response_with('notes')
  json.notes otu.notes.each do |n|
    json.text n.text
  end
end

if extend_response_with('taxon_name')
  json.taxon_name do |n|
    json.partial! '/taxon_names/api/v1/attributes', taxon_name: otu.taxon_name
  end
end
