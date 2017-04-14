json.array!(@controlled_vocabulary_terms) do |controlled_vocabulary_term|
  json.partial! '/controlled_vocabulary_terms/attributes', controlled_vocabulary_term: controlled_vocabulary_term
end
