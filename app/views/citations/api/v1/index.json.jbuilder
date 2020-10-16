json.array!(@citations) do |citation|
  json.partial! '/citations/api/v1/attributes', citation: citation
end
