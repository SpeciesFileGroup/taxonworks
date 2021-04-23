# A RangedLotCategory is an estimate used to assert that a CollectoinObject contains somewhere between a minimum and maximum
# number of individuals, as asserted by a curator of that CollectionObject.  When a RangedLotCategory is assigned to
# a CollectionObject then no CollectionObject#total can be provided.
#
# @!attribute name
#   @return [String]
#      a label for the category 
#
# @!attribute minimum_value
#   @return [Integer]
#      the minimum number of enumerated objects       
#
# @!attribute maximum_value
#   @return [Integer]
#      the maximum number of enumerated objects 
#
# @!attribute project_id
#   @return [Integer]
#   the project ID
#
class RangedLotCategory < ApplicationRecord
  include Housekeeping
  include Shared::IsData
  include SoftValidation

  validates_presence_of :name, :minimum_value
  validate :validate_values
  validates :minimum_value, numericality: {greater_than: 0, only_integer: true}, allow_nil: false
  validates :maximum_value, numericality: {greater_than: 1, only_integer: true}, allow_nil: false

  validates_uniqueness_of :name, scope: [:project_id]

  has_many :ranged_lots, inverse_of: :ranged_lot_category, dependent: :restrict_with_error

  soft_validate(:sv_range_does_not_overlap)

  protected

  # @return [Object]
  def validate_values
    errors.add(:maximum_value, 'minimum value must be less than maximum value') if self.minimum_value && self.maximum_value && (self.minimum_value >= self.maximum_value)
  end

  # @return [Object]
  def sv_range_does_not_overlap
    soft_validations.add(:minimum_value, 'The range of values overlaps with another defined range of values.') if RangedLotCategory.where('minimum_value >= ? and maximum_value <= ? and project_id = ?', minimum_value, maximum_value, project_id)
  end

end
