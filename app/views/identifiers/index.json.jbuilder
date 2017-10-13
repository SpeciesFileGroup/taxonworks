json.array!(@identifiers) do |identifier|
  json.partial! 'attributes', identifier: identifier
end
