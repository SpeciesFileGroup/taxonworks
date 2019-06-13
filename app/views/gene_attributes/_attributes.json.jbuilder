json.extract! gene_attribute, :id, :descriptor_id, :sequence_id, :sequence_relationship_type, :controlled_vocabulary_term_id, :position, :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at

json.partial! '/shared/data/all/metadata', object: gene_attribute

json.sequence do
  json.partial! '/sequences/attributes', sequence: gene_attribute.sequence
end
