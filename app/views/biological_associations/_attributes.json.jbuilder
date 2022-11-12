json.partial! '/biological_associations/base_attributes', biological_association: biological_association
json.partial! '/shared/data/all/metadata', object: biological_association

if extend_response_with('biological_relationship')
  json.biological_relationship do
    json.partial! '/shared/data/all/metadata', object: biological_association.biological_relationship, extensions: false
  end
end

if extend_response_with('biological_relationship_types')
  json.biological_relationship_types do
    json.array! biological_association.biological_relationship.biological_relationship_types do |biological_relationship_type|
      json.partial! '/biological_relationship_types/attributes', biological_relationship_type: biological_relationship_type
    end
  end
end

if extend_response_with('subject')
  json.subject do
    json.partial! '/shared/data/all/metadata', object: biological_association.biological_association_subject, extensions: false

    if extend_response_with('taxonomy')
      json.taxonomy do
        json.merge! biological_association.biological_association_subject.taxonomy
      end
    end

  end
end

if extend_response_with('object')
  json.object do
    json.partial! '/shared/data/all/metadata', object: biological_association.biological_association_object, extensions: false

    if extend_response_with('taxonomy')
      json.taxonomy do
        json.merge! biological_association.biological_association_object.taxonomy
      end
    end

  end
end

