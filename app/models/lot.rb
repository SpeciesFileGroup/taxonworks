# A class representing physical, biological, collection enumerated (precisely, see also RangedLot) to > 1, i.e. a group of individuals.
class Lot < CollectionObject::BiologicalCollectionObject
  include Housekeeping

  validate :size_of_total

  protected

  def size_of_total
    errors.add(:total, "total must be > 1") if self.total.nil? || not(self.total > 1) 
  end
end
