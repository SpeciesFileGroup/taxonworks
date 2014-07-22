class Keyword < ControlledVocabularyTerm 

  has_many :tags, foreign_key: :keyword_id, dependent: :destroy

  def tagged_objects
    self.tags.collect{|t| t.tag_object}
  end

  def tagged_object_class_names
    Tag.where(keyword: self).pluck(:tag_object_type)
  end

end
