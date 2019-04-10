json.array!(@georeferences) do |georeference|
  json.partial! '/georeferences/attributes', georeference: georeference
end
