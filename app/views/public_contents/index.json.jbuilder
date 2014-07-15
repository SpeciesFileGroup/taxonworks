json.array!(@public_contents) do |public_content|
  json.extract! public_content, :id, :otu_id, :topic_id, :text, :project_id, :created_by_id, :updated_by_id, :content_id
  json.url public_content_url(public_content, format: :json)
end
