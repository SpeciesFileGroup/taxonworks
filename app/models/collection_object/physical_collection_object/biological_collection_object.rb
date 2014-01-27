class CollectionObject::PhysicalCollectionObject::BiologicalCollectionObject < CollectionObject::PhysicalCollectionObject
  has_many :otus, through: :taxon_determinations
  # TODO: as?
  has_many :taxon_determinations

end
