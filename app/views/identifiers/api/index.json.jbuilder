json.array!(@identifiers) do |identifier|
  json.partial! 'api/attributes', identifier: identifier
end
