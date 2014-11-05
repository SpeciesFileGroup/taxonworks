# A RangedLotCategory is an estimate used to assert that a CollectinObject contains somewhere between a minimum and maximum
# number of individuals, as asserted by a curator of that CollectionObject.  When a RangedLotCategory is assigned to
# a CollectionObject then no CollectionObject#total can be provided.. 
# 
class RangedLotCategory < ActiveRecord::Base
  include Housekeeping
  include Shared::IsData 
  include SoftValidation

  validates_presence_of :name 
  before_validation :validate_values
  validates :minimum_value, numericality: {greater_than: 0, only_integer: true}, allow_nil: true
  validates :maximum_value, numericality: {greater_than: 1, only_integer: true}, allow_nil: true

  has_many :ranged_lots, inverse_of: :ranged_lot_category, dependent: :restrict_with_error

  soft_validate(:sv_range_does_not_overlap)

  protected

  def validate_values
    errors.add(:maximum_value, 'minimum value must be less than maximum value') if self.minimum_value && self.maximum_value && (self.minimum_value >= self.maximum_value)
  end

  def range_does_not_overlap
    soft_validations.add(:minimum_value, "The range of values overlaps with another defined range of values.") if RangedLotCategory.where("minimum_value >= ? and maximum_value <= ? and project_id = ?", minimum_value, maximum_value, project_id)
  end

end
