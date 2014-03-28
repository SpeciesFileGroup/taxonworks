# A class representing a single, physical, and biological individual that has been collected.  Used when the curator has enumerated something to 1.
class Specimen < CollectionObject::BiologicalCollectionObject

  before_validation :check_and_set_total 
  validates_presence_of :total 
  validates :total, :inclusion => { :in => 1..1 }


  protected

  def check_and_set_total
    if self.total.blank?
      self.total ||= 1  
    end
  end

end
