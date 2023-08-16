json.array!(@depictions) do |depiction|
  json.partial! '/depictions/attributes', depiction: depiction
end
