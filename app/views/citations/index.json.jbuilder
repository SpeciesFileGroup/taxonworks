json.array!(@citations) do |citation|
  json.extract! citation, :id
  json.url citation_url(citation, format: :json)
end
