class RangedLotCategory < ActiveRecord::Base

  validates_presence_of :name 
  before_validation :validate_values
  validates :minimum_value, numericality: {greater_than: 0, only_integer: true}, allow_nil: true
  validates :maximum_value, numericality: {greater_than: 1, only_integer: true}, allow_nil: true

  has_many :ranged_lots

  protected

  def validate_values
    errors.add(:maximum_value, 'minimum value must be less than maximum value') if self.minimum_value && self.maximum_value && (self.minimum_value >= self.maximum_value)
  end

end
