json.array! @citations do |citation|
  json.partial! '/citations/api/v1/attributes', citation: citation
  if extend_response_with('source')
    json.source do
      json.partial! '/sources/api/v1/attributes', source: citation.source
    end
  end
end
