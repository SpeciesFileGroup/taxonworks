json.array!(@tags) do |tag|
  json.partial! '/tags/api/v1/attributes', tag: tag
end
