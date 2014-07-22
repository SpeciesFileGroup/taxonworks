class RangedLotCategory < ActiveRecord::Base

  include Housekeeping

  validates_presence_of :name 
  before_validation :validate_values
  validates :minimum_value, numericality: {greater_than: 0, only_integer: true}, allow_nil: true
  validates :maximum_value, numericality: {greater_than: 1, only_integer: true}, allow_nil: true

  has_many :ranged_lots, inverse_of: :ranged_lot_category, dependent: :restrict_with_error

  protected

  def validate_values
    errors.add(:maximum_value, 'minimum value must be less than maximum value') if self.minimum_value && self.maximum_value && (self.minimum_value >= self.maximum_value)
  end

end
