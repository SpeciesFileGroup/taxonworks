class BiocurationClass < ControlledVocabularyTerm
  
  has_many :biocuration_classifications
  has_many :biological_objects

end
