# A FieldOccurrence is
#   * A TaxonDetermination
#   * Done in the field (As defined by the CollectingEvent)
#
# It is differentiated from a CollectionObject by:
#   * No physical individual is brought back to a physical collection.
#   * It requires a TaxonDetermination be present
#   * It is not Containable (or Loanable, etc.)
#
# @!attribute total
#   @return [Integer]
#    The enumerated number of things observed in the field, as asserted by *the collector* of a CollectingEvent.  Must be zero if is_absent = true.
#
# @!attribute is_absent
#   @return [Boolean]
#     a positive negative, when true then there exists an assertion that the taxon was not observed given the effort of the CollectingEvent.  Inessence a confirmation/checksum of total=0 assertions.
#     Total must be zero here.
#
class FieldOccurrence < ApplicationRecord
  include GlobalID::Identification
  include Housekeeping

  include Shared::Citations
  include Shared::DataAttributes
  include Shared::Identifiers
  include Shared::Notes
  include Shared::Tags
  include Shared::Depictions

  include Shared::OriginRelationship
  include Shared::Confidences
  include Shared::ProtocolRelationships
  include Shared::HasPapertrail
  include Shared::Observations
  include Shared::IsData
  include Shared::QueryBatchUpdate
  include SoftValidation

  # At present must be before IsDwcOccurence
  include FieldOccurrence::DwcExtensions
  include Shared::Taxonomy
  
  include Shared::Conveyances
  include Shared::BiologicalExtensions
  include Shared::IsDwcOccurrence

  is_origin_for 'Specimen', 'Lot', 'Extract', 'AssertedDistribution', 'Sequence', 'Sound'

  belongs_to :collecting_event, inverse_of: :field_occurrences
  belongs_to :ranged_lot_category, inverse_of: :ranged_lots

  has_many :georeferences, through: :collecting_event
  has_many :geographic_items, through: :georeferences

  # Hmmm- semantics here?
  # Should be observers?
  has_many :collectors, through: :collecting_event

  validates_presence_of :collecting_event

  validate :new_records_include_taxon_determination
  validate :check_that_either_total_or_ranged_lot_category_id_is_present
  validate :check_that_both_of_category_and_total_are_not_present
  validate :total_zero_when_absent

  accepts_nested_attributes_for :collecting_event, allow_destroy: true, reject_if: :reject_collecting_event

  def requires_taxon_determination?
    true
  end

  private

  def total_zero_when_absent
    errors.add(:total, 'Must be zero when absent.') if (total != 0) && is_absent
  end

  def check_that_both_of_category_and_total_are_not_present
    errors.add(:ranged_lot_category_id, 'Both ranged_lot_category and total can not be set') if ranged_lot_category_id.present? && total.present?
  end

  def check_that_either_total_or_ranged_lot_category_id_is_present
    errors.add(:base, 'Either total or a ranged lot category must be provided') if ranged_lot_category_id.blank? && total.blank?
  end

  # @return [Boolean]
  def new_records_include_taxon_determination
    if new_record? && taxon_determination.blank? && !taxon_determinations.any?
      errors.add(:base, 'required taxon determination is not provided')
    end
  end

  # Duplicated with CollectionObject
  def reject_collecting_event(attributed)
    reject = true
    CollectingEvent.core_attributes.each do |a|
      if attributed[a].present?
        reject = false
        break
      end
    end
    # !! does not account for georeferences_attributes!
    reject
  end

end
