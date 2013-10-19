class CollectionObject::BiologicalCollectionObject < CollectionObject
  has_many :otus, through: :taxon_determinations
  # TODO: as?
  has_many :taxon_determinations

end
