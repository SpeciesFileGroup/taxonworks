json.array!(@identifiers) do |identifier|
  json.partial! '/identifiers/api/v1/attributes', identifier: identifier
end
