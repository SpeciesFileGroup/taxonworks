# Shared code that references things with TaxonDeterminations and Biocuration classes
#   Current FieldOccurence
#           CollectionObject (should be CollectionObject::BiologicalCollectionObject)
module Shared::BiologicalExtensions

  extend ActiveSupport::Concern

  included do

    include Shared::BiologicalAssociations

    # Otu delegations
    delegate :name, to: :current_otu, prefix: :otu, allow_nil: true # could be Otu#otu_name?
    delegate :id, to: :current_otu, prefix: :otu, allow_nil: true

    has_many :taxon_determinations, as: :taxon_determination_object, dependent: :destroy, inverse_of: :taxon_determination_object

    # All determiners, regardless of what the taxon is
    has_many :determiners, through: :taxon_determinations, source: :determiners

    has_many :otus, through: :taxon_determinations

    has_many :taxon_names, through: :otus

    has_many :biocuration_classifications, as: :biocuration_classification_object, dependent: :destroy, inverse_of: :biocuration_classification_object

    has_many :biocuration_classes, through: :biocuration_classifications #, inverse_of: :biological_collection_objects

    accepts_nested_attributes_for :biocuration_classes, allow_destroy: true
    accepts_nested_attributes_for :biocuration_classifications, allow_destroy: true

    accepts_nested_attributes_for :otus, allow_destroy: true, reject_if: :reject_otus
    accepts_nested_attributes_for :taxon_determinations, allow_destroy: true, reject_if: :reject_taxon_determinations

    # DEPRECATED - TODO: replace with current_taxon_name and current_otu (below).
    # Note that this should not be a has_one because order is over-ridden on .first
    # and can be lost when merged into other queries.
    has_one :taxon_determination, -> { order(:position).limit(1) }, as: :taxon_determination_object, class_name: 'TaxonDetermination', inverse_of: :taxon_determination_object
    has_one :otu, through: :taxon_determination, inverse_of: :taxon_determinations

    def current_taxon_determination
      taxon_determinations.eager_load(:notes, :determiners).order(:position).first
    end

    def current_otu
      otus.order(:position).limit(1).first
    end

    def current_taxon_name
      taxon_names.order('taxon_determinations.position').first
    end

    # Prefer the valid name, but fall back to invalid for edge cases where there is no valid
    #
    # Benchmark vs.
    #   `current_taxon_name&.valid_taxon_name || current_taxon_name`` is around 20% faster
    #
    def current_valid_taxon_name
      TaxonName.joins('JOIN taxon_names tnv on taxon_names.id = tnv.cached_valid_taxon_name_id')
        .joins('JOIN otus o on o.taxon_name_id = tnv.id')
        .joins('JOIN taxon_determinations td on o.id = td.otu_id')
        .where(td: {
          position: 1,
          taxon_determination_object_type: self.class.base_class.name,
          taxon_determination_object_id: id })
        .first
    end

  end

  # see BiologicalCollectionObject
  def missing_determination
  end

  def requires_taxon_determination?
    false
  end

  # Ugh: TODO: deprecate!  no utility gained here, and it's HTML!!!
  # @param [String] rank
  # @return [String] if a determination exists, and the Otu in the determination has a taxon name then return the taxon name at the rank supplied
  def name_at_rank_string(rank)
    current_taxon_name.try(:ancestor_at_rank, rank).try(:cached_html)
  end

  # @return [Boolean]
  def reject_taxon_determinations(attributed)
    attributed['otu_id'].blank? && attributed[:otu]&.id.blank?
  end

  def reject_otus(attributed)
    a = attributed['taxon_name_id']
    b = attributed['name']
    a.blank? && b.blank?
  end

  # Propagate a change in the accepted OTU (top/position 1 TaxonDetermination)
  # down to descendant AnatomicalParts.
  def propagate_current_otu_change!(from_id:, to_id:)
    return true if from_id == to_id # includes nil == nil
    return true if !AnatomicalPart.valid_old_object_classes.include?(self.class.name)

    anatomical_part_ids = descendant_anatomical_part_ids
    return true if anatomical_part_ids.empty?

    scope = AnatomicalPart
      .where(project_id: project_id, id: anatomical_part_ids)
      .where(cached_otu_id: from_id)

    scope.update_all(cached_otu_id: to_id)
    true
  rescue => e
    Rails.logger.warn("#{self.class}##{id} propagation failed: #{e.class}: #{e.message}")
    false
  end

  private

  # @return [Array<Integer>]
  def descendant_anatomical_part_ids
    project = project_id
    seen_ids = Set.new
    result = []
    frontier = [id]
    old_type = self.class.base_class.name

    while frontier.any?
      old_frontier = frontier
      frontier = []
      old_old_type = old_type
      old_type = 'AnatomicalPart'

      old_frontier.each do |old_id|
        rels = OriginRelationship
          .where(
            project_id: project,
            old_object_type: old_old_type,
            old_object_id: old_id,
            new_object_type: 'AnatomicalPart')
          .pluck(:new_object_id)

        rels.each do |anatomical_part_id|
          next if seen_ids.include?(anatomical_part_id)
          seen_ids << anatomical_part_id
          result << anatomical_part_id
          frontier << anatomical_part_id
        end
      end
    end

    result
  end

end
