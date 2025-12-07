json.partial! "attributes", anatomical_part: @anatomical_part

if @origin_relationship
  json.origin_relationship do
    json.partial! 'origin_relationships/attributes', origin_relationship: @origin_relationship
  end
end
