class CollectionObject::BiologicalCollectionObject < CollectionObject
  has_many :otus, through: :taxon_determinations
  has_many :taxon_determinations

  has_many :biocuration_classifications
  has_many :biocuration_classes, through: :biocuration_classifications

end
