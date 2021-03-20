# A RangedLot is a CollectionObject that is not enumerated in a range (i.e. not a simple integer).
#
class RangedLot < CollectionObject::BiologicalCollectionObject

  is_origin_for 'Sequence'
  originates_from 'Lot', 'RangedLot'

  belongs_to :ranged_lot_category, inverse_of: :ranged_lots

  with_options if: -> {self.type == 'RangedLot'} do |r|
    r.validates_presence_of :ranged_lot_category_id
  end

end



