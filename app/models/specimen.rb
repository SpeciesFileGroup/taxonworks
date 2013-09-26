class Specimen < CollectionObject::BiologicalCollectionObject::PhysicalBiologicalObject

  before_validation :check_and_set_total
  validates_presence_of :total 
  validate :value_of_total

  protected

  def value_of_total 
    errors.add(:total, "total must be 1") if !self.total == 1
  end

  def check_and_set_total
    self.total ||= 1  
    errors.add(:total, "total must be 1") if !self.total == 1
  end

end
