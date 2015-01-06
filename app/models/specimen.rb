# A Specimen is a single (by single we mean a curator has enumerated the object as 1), physical, and biological individual that has been collected. 
#
#
# @attribute total
#   @return [1]
#     a specimen always has a total of one. 
#
class Specimen < CollectionObject::BiologicalCollectionObject

  before_validation :check_and_set_total 
  
  validates_presence_of :total 
  validates :total, :inclusion => { :in => 1..1 }, if: 'self.type == "Specimen"'
  protected

  def check_and_set_total
    if self.total.blank?
      self.total ||= 1  
    end
  end

end
