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

    has_many :type_materials, inverse_of: :collection_object, dependent: :restrict_with_error

    has_many :biocuration_classifications, as: :biocuration_classification_object, dependent: :destroy, inverse_of: :biocuration_classification_object

    has_many :biocuration_classes, through: :biocuration_classifications #, inverse_of: :biological_collection_objects

    accepts_nested_attributes_for :biocuration_classes, allow_destroy: true
    accepts_nested_attributes_for :biocuration_classifications, allow_destroy: true

    accepts_nested_attributes_for :otus, allow_destroy: true, reject_if: :reject_otus
    accepts_nested_attributes_for :taxon_determinations, allow_destroy: true, reject_if: :reject_taxon_determinations

    has_one :taxon_determination, -> { order(:position).limit(1) }, as: :taxon_determination_object, class_name: 'TaxonDetermination', inverse_of: :taxon_determination_object
    has_one :otu, through: :taxon_determination, inverse_of: :taxon_determinations

    # Note that this should not be a has_one because order is over-ridden on .first
    # and can be lost when merged into other queries.
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

end
