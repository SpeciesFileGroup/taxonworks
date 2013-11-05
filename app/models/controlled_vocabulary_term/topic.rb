class ControlledVocabularyTerm::Topic < ControlledVocabularyTerm
  has_many :citation_topics, inverse_of: :topic
end
