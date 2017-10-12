json.array!(@tags) do |tag|
  json.partial! 'attributes', tag: tag
end
