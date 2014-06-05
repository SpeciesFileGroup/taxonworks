json.array!(@public_contents) do |public_content|
  json.extract! public_content, :id
  json.url public_content_url(public_content, format: :json)
end
