json.array!(@controlled_vocabulary_terms) do |controlled_vocabulary_term|
  json.partial! '/controlled_vocabulary_terms/api/v1/attributes', controlled_vocabulary_term:
end
