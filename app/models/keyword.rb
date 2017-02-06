class Keyword < ControlledVocabularyTerm 

  has_many :tags, foreign_key: :keyword_id, dependent: :destroy, inverse_of: :keyword, validate: true

  def tagged_objects
    tags.collect{|t| t.tag_object}
  end

  def tagged_object_class_names
    tags.pluck(:tag_object_type)
  end

end
