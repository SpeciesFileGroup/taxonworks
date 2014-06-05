json.array!(@contents) do |content|
  json.extract! content, :id
  json.url content_url(content, format: :json)
end
