# A Specimen is a single (by single we mean a curator has enumerated the object as 1), physical, and biological individual that has been collected.
#
#
# @attribute total
#   @return [1]
#     a specimen always has a total of one.
#
class Specimen < CollectionObject::BiologicalCollectionObject

  is_origin_for 'Specimen', 'Extract', 'AssertedDistribution'
  originates_from 'Specimen', 'Lot', 'RangedLot'

  with_options if: -> {self.type == 'Specimen'} do |s|
    s.before_validation :check_and_set_total
    s.validates :total, inclusion: { in: 1..1 }, presence: true
  end

  protected

  def check_and_set_total
    if self.total.blank?
      self.total ||= 1
    end
  end

end
