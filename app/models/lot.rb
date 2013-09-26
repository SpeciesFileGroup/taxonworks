class Lot < CollectionObject::BiologicalCollectionObject::PhysicalBiologicalObject

  validate :size_of_total

  protected

  def size_of_total
    errors.add(:total, "total must be > 1") if self.total.nil? || not(self.total > 1) 
  end

end
