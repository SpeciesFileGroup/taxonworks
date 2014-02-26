class CollectionObject::PhysicalCollectionObject::BiologicalCollectionObject < CollectionObject::PhysicalCollectionObject
  has_many :otus, through: :taxon_determinations
  has_many :taxon_determinations


end
