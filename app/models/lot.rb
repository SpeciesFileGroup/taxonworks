# A class representing physical, biological, collection enumerated (precisely, see also RangedLot) to > 1, i.e. a group of individuals.
class Lot < CollectionObject::BiologicalCollectionObject

  with_options if: 'self.type == "Lot"' do |l|
    l.validate :size_of_total
  end

  protected

  def size_of_total
    errors.add(:total, "total must be > 1") if self.total.nil? || !(self.total > 1)
  end
end
