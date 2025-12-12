json.array! @biological_associations do |ba|
  # pre-loaded in controller
  index = ba.biological_association_index

  json.id ba.id

  # Subject data from index
  json.subject do
    json.type index.subject_type
    json.order index.subject_order
    json.family index.subject_family
    json.genus index.subject_genus
    json.label index.subject_label
    json.properties index.subject_properties
  end

  # Relationship from index
  json.relationship index.relationship_name

  # Object data from index
  json.object do
    json.type index.object_type
    json.order index.object_order
    json.family index.object_family
    json.genus index.object_genus
    json.label index.object_label
    json.properties index.object_properties
  end

  # Citations from index
  json.citations index.citations
end
