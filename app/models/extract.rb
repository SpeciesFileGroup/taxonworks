# An Extract is the quantified physical entity that originated from a CollectionObject.
# Extracts are linked to their origin through an OriginRelationship.
#
# @!attribute quantity_value
#   @return [Numeric]
#    # @Merfoo, define with David
#
# @!attribute quantity_unit
#   @return [Numeric]
#      # @Merfoo, define with David
#
# @!attribute concentration_value
#   @return [Numeric]
#      # @Merfoo, define with David
#
# @!attribute concentration_unit
#   @return [Numeric]
#      # @Merfoo, define with David
#
# @!attribute verbatim_anatomical_origin
#  @return [String]
#    proxy for a OriginRelationship to an AnatomicalClass
#
# @!attribute year_made
#  @return [Integer]
#    4 digit year the extract originated
#
# @!attribute month_made
#  @return [Integer]
#    2 digit month the extract originated
#
# @!attribute day_made
#  @return [Integer]
#    2 digit day the extract originated
#
class Extract < ApplicationRecord
  include Housekeeping
  include Shared::Identifiers
  include Shared::ProtocolRelationships
  include Shared::OriginRelationship
  include Shared::IsData

  is_origin_for 'Extract', 'Sequence'
  originates_from 'Extract', 'Specimen', 'Lot', 'RangedLot', 'Otu'

  has_many :sequences, through: :origin_relationships, source: :new_object, source_type: 'Sequence'

  validates_presence_of :quantity_value
  attr_accessor :is_made_now

  before_validation :set_made, if: -> {is_made_now}

  validates_presence_of :quantity_value
  validates_presence_of :quantity_unit

  validates :quantity_unit, with: :validate_units

  validates :year_made, date_year: { allow_blank: false }
  validates :month_made, date_month: { allow_blank: false }
  validates :day_made, date_day: { allow_blank: false }

  protected

  def set_made
    write_attribute(:year_made, Time.now.year)
    write_attribute(:month_made, Time.now.month)
    write_attribute(:day_made, Time.now.day)
  end

  def validate_units
    begin
      RubyUnits::Unit.new(quantity_unit)
    rescue ArgumentError, 'Unit not recognized'
      errors.add(:quantity_unit, "'#{quantity_unit}' is an invalid quantity_unit")
    end
  end


end
