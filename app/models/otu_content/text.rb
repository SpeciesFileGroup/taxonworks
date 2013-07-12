class OtuContent::Text < OtuContent
  belongs_to :topic, class_name: 'ControlledVocabularyTerm::Topic'
end
