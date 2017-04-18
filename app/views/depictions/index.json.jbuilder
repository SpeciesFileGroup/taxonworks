json.array!(@depictions) do |depiction|
  json.partial! 'attributes', depiction: depiction 
end
