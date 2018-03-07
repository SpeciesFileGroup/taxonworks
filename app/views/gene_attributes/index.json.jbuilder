json.array!(@gene_attributes) do |gene_attribute|
  json.extract! gene_attribute, :id, :descriptor_id, :sequence_id, :sequence_relationship_type, :controlled_vocabulary_term_id, :position, :created_by_id, :updated_by_id, :project_id
  json.url gene_attribute_url(gene_attribute, format: :json)
end
