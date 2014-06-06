json.array!(@citation_topics) do |citation_topic|
  json.extract! citation_topic, :id
  json.url citation_topic_url(citation_topic, format: :json)
end
