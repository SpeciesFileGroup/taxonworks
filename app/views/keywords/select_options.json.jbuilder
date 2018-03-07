@keywords.each_key do |group|
  json.set!(group) do
    json.array! @keywords[group] do |k|
      json.partial! '/controlled_vocabulary_terms/attributes', controlled_vocabulary_term: k
    end
  end
end
