json.array!(@origin_relationships) do |origin_relationship|
  json.partial! 'attributes', origin_relationship: origin_relationship
end
