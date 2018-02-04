# TODO: unify with Keyword, CVT
@topics.each_key do |group|
  json.set!(group) do
    json.array! @topics[group] do |k|
      json.partial! '/controlled_vocabulary_terms/attributes', controlled_vocabulary_term: k
    end
  end
end
