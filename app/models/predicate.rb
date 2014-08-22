class Predicate < ControlledVocabularyTerm

  has_many :internal_attributes, inverse_of: :predicate

end
