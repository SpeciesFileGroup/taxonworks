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
  include Shared::Confidences
  include Shared::DataAttributes
  include Shared::Depictions
  include Shared::Conveyances
  include Shared::HasPapertrail
  include Shared::Identifiers
  include Shared::Notes
  include Shared::Observations
  include Shared::OriginRelationship
  include Shared::ProtocolRelationships
  include Shared::Tags
  include Shared::IsData
  include Shared::QueryBatchUpdate
  include SoftValidation

  # At present must be before BiologicalExtensions
  include Shared::TaxonDeterminationRequired
  include Shared::BiologicalExtensions

  include Shared::Taxonomy
  include FieldOccurrence::DwcExtensions

  is_origin_for 'Specimen', 'Lot', 'Extract', 'AssertedDistribution', 'Sequence', 'Sound'
  originates_from 'FieldOccurrence'

  GRAPH_ENTRY_POINTS = [:biological_associations, :taxon_determinations, :biocuration_classifications, :collecting_event, :origin_relationships]

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
  validate :total_positive_when_present

  accepts_nested_attributes_for :collecting_event, allow_destroy: true, reject_if: :reject_collecting_event

  def requires_taxon_determination?
    true
  end

  private

  def total_zero_when_absent
    errors.add(:total, 'Must be zero when absent.') if (total != 0) && is_absent
  end

  def total_positive_when_present
    errors.add(:total, 'Must be positive when not absent.') if !is_absent && total.present? && total <= 0
  end

  def check_that_both_of_category_and_total_are_not_present
    errors.add(:ranged_lot_category_id, 'Both ranged_lot_category and total can not be set') if ranged_lot_category_id.present? && total.present?
  end

  def check_that_either_total_or_ranged_lot_category_id_is_present
    errors.add(:base, 'Either total or a ranged lot category must be provided') if ranged_lot_category_id.blank? && total.blank?
  end

  # @return [Boolean]
  def new_records_include_taxon_determination
    # !! Be careful making changes here: remember that conditions on one
    # association may/not affect other associations when the actual save
    # happens.
    # Maintain with AssertedDistribution#new_records_include_citation
    has_valid_taxon_determinations = taxon_determinations.count(&:marked_for_destruction?) < taxon_determinations.size

    has_valid_taxon_determination =
      taxon_determination && !taxon_determination.marked_for_destruction?

    # If we remove taxon_determination (singular!) and that's the only TD, none
    # will be left after save.
    last_is_taxon_determination_to_be_removed =
      taxon_determination && taxon_determination.marked_for_destruction? && taxon_determinations.size == 1

    if new_record? && otu.blank? && (
       (!has_valid_taxon_determination && !has_valid_taxon_determinations) ||
       last_is_taxon_determination_to_be_removed
    )
      errors.add(:base, 'required taxon determination is not provided')
      return
    end

    # We loaded the taxon_determinations association above. If it was empty,
    # Rails caches that value and *will not* add a determination created during
    # save from otu or taxon_determination unless we reset the citations
    # association.
    if (otu.present? || taxon_determination.present?) && taxon_determinations.size == 0
      association(:taxon_determinations).reset
    end

    if otu.present? && taxon_determination.nil?
      association(:taxon_determination).reset
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

  # @param used_on [String] required, currently only `TaxonDetermination` is
  #   accepted
  # @return [Scope]
  #    the max 10 most recently used collection_objects, as `used_on`
  def self.used_recently(user_id, project_id, used_on = '')
    return [] if used_on != 'TaxonDetermination'
    a = case used_on
      when 'TaxonDetermination'
        TaxonDetermination
          .select(:taxon_determination_object_id,
            :taxon_determination_object_type, :updated_at)
          .where('updated_at > ?', 1.week.ago )
          .where(updated_by_id: user_id)
          .where(project_id:)
          .order(updated_at: :desc)
      end

      FieldOccurrence
        .with(recent_t: a)
        .joins("JOIN recent_t ON recent_t.taxon_determination_object_id = field_occurrences.id AND recent_t.taxon_determination_object_type = 'FieldOccurrence'")
        .pluck(:id).uniq
  end

  # @params target [String] currently only 'TaxonDetermination' is accepted
  # @return [Hash] field_occurrences optimized for user selection
  def self.select_optimized(user_id, project_id, target = nil)
    h = {
      quick: [],
      pinboard: FieldOccurrence.pinned_by(user_id).where(project_id:).to_a,
      recent: []
    }

    if target && !(r = used_recently(user_id, project_id, target)).empty?
      h[:recent] = FieldOccurrence.where(id: r.first(10)).to_a
      h[:quick] = (
        FieldOccurrence
          .pinned_by(user_id)
          .pinboard_inserted
          .where(project_id:).to_a  +
        FieldOccurrence.where(id: r.first(4)).to_a
      ).uniq
    else
      h[:recent] = FieldOccurrence
        .where(project_id:, updated_by_id: user_id)
        .order('updated_at DESC')
        .limit(10).to_a
      h[:quick] = FieldOccurrence
        .pinned_by(user_id)
        .pinboard_inserted
        .where(project_id:).to_a
    end

    h
  end

end
