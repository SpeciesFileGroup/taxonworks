class Predicate < ControlledVocabularyTerm
  has_many :internal_attributes, inverse_of: :predicate, foreign_key: :controlled_vocabulary_term_id
end
