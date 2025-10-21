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

  is_origin_for 'Specimen', 'Lot', 'Extract', 'AssertedDistribution', 'Sequence', 'Sound', 'AnatomicalPart'
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

  validate :records_include_taxon_determination
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

  def records_include_taxon_determination
    # !! Be careful making changes here: remember that conditions on one
    # association may/not affect other associations when the actual save
    # happens.
    # Maintain with AssertedDistribution#new_records_include_citation

    # Watch out, taxon_determination and taxon_determination *do not*
    # necessarily share the same marked_for_destruction? info, even when
    # taxon_determination is a member of taxon_determinations.

    taxon_determination_is_marked_for_destruction_on_taxon_determinations =
      taxon_determination.present? && taxon_determinations.present? &&
      taxon_determinations.count == 1 && !taxon_determinations.first.id.nil? &&
      taxon_determination.id == taxon_determinations.first.id &&
      taxon_determinations.first.marked_for_destruction?

    the_one_taxon_determinations_is_marked_for_destruction_on_taxon_determination =
      taxon_determination.present? && taxon_determinations.present? &&
      taxon_determinations.count == 1 && !taxon_determinations.first.id.nil? &&
      taxon_determination.id == taxon_determinations.first.id &&
      taxon_determination.marked_for_destruction?

    has_valid_otu =
      otu.present? &&
      !otu.marked_for_destruction? && (
        !taxon_determination.present? ||
        (!taxon_determination.marked_for_destruction? &&
        !taxon_determination_is_marked_for_destruction_on_taxon_determinations)
      )

    has_valid_taxon_determination =
      taxon_determination.present? &&
      !taxon_determination.marked_for_destruction? &&
      !taxon_determination_is_marked_for_destruction_on_taxon_determinations

    has_valid_taxon_determinations =
     taxon_determinations.count(&:marked_for_destruction?) < taxon_determinations.size &&
     !the_one_taxon_determinations_is_marked_for_destruction_on_taxon_determination

    if !has_valid_otu && !has_valid_taxon_determination && !has_valid_taxon_determinations
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

  # @param used_on [String]
  # @return [Scope]
  #    the max 10 most recently used collection_objects, as `used_on`
  def self.used_recently(user_id, project_id, used_on = '', ba_target = 'object')
    return [] if used_on != 'TaxonDetermination' && used_on != 'BiologicalAssociation'
    t = case used_on
        when 'TaxonDetermination'
          TaxonDetermination.arel_table
        when 'BiologicalAssociation'
          BiologicalAssociation.arel_table
        end
    if ba_target == 'subject'
      target_type = 'biological_association_subject_type'
      target_id = 'biological_association_subject_id'
    else
      target_type = 'biological_association_object_type'
      target_id = 'biological_association_object_id'
    end

    p = FieldOccurrence.arel_table

    # i is a select manager
    i = case used_on
        when 'BiologicalAssociation'
          t.project(t[target_id], t['updated_at']).from(t)
           .where(t[target_type].eq('FieldOccurrence'))
           .where(t['updated_at'].gt(1.week.ago))
           .where(t['updated_by_id'].eq(user_id))
           .where(t['project_id'].eq(project_id))
           .order(t['updated_at'].desc)
        else
          # TODO: update to reference new TaxonDetermination
          t.project(t['taxon_determination_object_id'], t['updated_at']).from(t)
           .where(t['taxon_determination_object_type'].eq('FieldOccurrence'))
           .where(t['updated_at'].gt( 1.week.ago ))
           .where(t['updated_by_id'].eq(user_id))
           .where(t['project_id'].eq(project_id))
           .order(t['updated_at'].desc)
        end

    # z is a table alias
    z = i.as('recent_t')

    j = case used_on
        when 'BiologicalAssociation'
          Arel::Nodes::InnerJoin.new(z, Arel::Nodes::On.new(
            z[target_id].eq(p['id'])
          ))
        else
          Arel::Nodes::InnerJoin.new(z, Arel::Nodes::On.new(
            z['taxon_determination_object_id'].eq(p['id'])))
        end

    FieldOccurrence.joins(j).pluck(:id).uniq
  end

  # @params target [String] currently only 'TaxonDetermination' is accepted
  # @return [Hash] field_occurrences optimized for user selection
  def self.select_optimized(user_id, project_id, target = nil, ba_target = 'object')
    h = {
      quick: [],
      pinboard: FieldOccurrence.pinned_by(user_id).where(project_id:).to_a,
      recent: []
    }

    if target && !(r = used_recently(user_id, project_id, target, ba_target)).empty?
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
