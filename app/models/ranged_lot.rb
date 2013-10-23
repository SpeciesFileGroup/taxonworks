class RangedLot < CollectionObject::PhysicalCollectionObject::BiologicalCollectionObject

  validates_presence_of :ranged_lot_category_id

  belongs_to :ranged_lot_category

end



