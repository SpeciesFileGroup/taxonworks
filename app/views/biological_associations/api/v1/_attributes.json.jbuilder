json.partial!('/biological_associations/base_attributes', biological_association:)
json.partial! '/shared/data/all/metadata', object: biological_association

if extend_response_with('biological_relationship')
  json.biological_relationship do
    json.partial! '/biological_relationships/attributes', biological_relationship: biological_association.biological_relationship
  end
end

if extend_response_with('subject')
  json.subject do
    json.id biological_association.biological_association_subject.id
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
    json.id biological_association.biological_association_object.id
    json.partial! '/shared/data/all/metadata', object: biological_association.biological_association_object, extensions: false
    if extend_response_with('taxonomy')
      json.taxonomy do
        json.merge! biological_association.biological_association_object.taxonomy
      end
    end
  end
end


