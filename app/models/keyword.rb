class Keyword < ControlledVocabularyTerm 

  has_many :tags, foreign_key: :keyword_id

 def tagged_objects
   self.tags.collect{|t| t.tag_object}
 end

end
