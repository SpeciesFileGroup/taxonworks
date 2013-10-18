class RangedLot < CollectionObject::BiologicalCollectionObject::PhysicalBiologicalObject 

  validates_presence_of :ranged_lot_category_id

  belongs_to :ranged_lot_category

end



