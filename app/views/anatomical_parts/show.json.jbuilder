json.anatomical_part do
  json.partial! "attributes", anatomical_part: @anatomical_part
end

if @origin_relationship
  json.origin_relationship do
    json.partial! 'origin_relationships/attributes', origin_relationship: @origin_relationship
  end
end
