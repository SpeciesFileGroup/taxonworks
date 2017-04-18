json.array!(@citations) do |citation|
  json.partial! 'attributes', citation: citation
end
