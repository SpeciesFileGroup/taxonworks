json.array!(@recent_objects) do |combination|
  json.partial! '/taxon_names/base_attributes', taxon_name: combination
end
