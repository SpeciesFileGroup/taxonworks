class Specimen < CollectionObject::BiologicalCollectionObject::PhysicalBiologicalObject

  before_validation :check_and_set_total 
  before_validation 
  validates_presence_of :total 
  validates :total, :inclusion => { :in => 1..1 }

  protected

  def check_and_set_total
    if self.total.blank?
      self.total ||= 1  
    end
  end

end
