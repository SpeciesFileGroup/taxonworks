json.array!(@controlled_vocabulary_terms) do |controlled_vocabulary_term|
  json.extract! controlled_vocabulary_term, :id, :type, :name, :definition, :created_by_id, :updated_by_id, :project_id
  json.url controlled_vocabulary_term_url(controlled_vocabulary_term, format: :json)
end
