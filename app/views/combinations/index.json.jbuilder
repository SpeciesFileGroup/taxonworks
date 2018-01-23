json.array!(@recent_objects) do |combination|
  json.partial! '/combinations/attributes', combination: combination
end
