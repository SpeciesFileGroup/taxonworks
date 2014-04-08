class BiocurationGroup < Keyword 

  # Watch out this is borked with squeel
  has_many :biocuration_classes, through: :tags, source: 'tag_object', source_type: 'ControlledVocabularyTerm'


end
