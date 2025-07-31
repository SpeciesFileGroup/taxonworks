json.array!(@documents) do |document|
  json.partial! "attributes", document: document
  json.url document_url(document, format: :json)
end
