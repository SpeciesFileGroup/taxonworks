json.array!(@identifiers) do |identifier|
  json.partial! '/identifiers/api/attributes', identifier: identifier
end
