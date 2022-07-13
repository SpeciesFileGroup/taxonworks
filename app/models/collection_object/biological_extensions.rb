# This is all code that properly belongs in CollectionObject::BiologicalCollectionObject,
# but because inheritance sucks sometimes we include it at the top level
module CollectionObject::BiologicalExtensions

  extend ActiveSupport::Concern

  included do  

    include Shared::BiologicalAssociations

    # Otu delegations
    delegate :name, to: :current_otu, prefix: :otu, allow_nil: true # could be Otu#otu_name?
    delegate :id, to: :current_otu, prefix: :otu, allow_nil: true

    has_many :taxon_determinations, foreign_key: :biological_collection_object_id, inverse_of: :biological_collection_object, dependent: :destroy

    # All determiners, regardless of what the taxon is
    has_many :determiners, through: :taxon_determinations, source: :determiners

    has_many :otus, through: :taxon_determinations, inverse_of: :collection_objects
    has_many :taxon_names, through: :otus

    has_many :type_materials, inverse_of: :collection_object, dependent: :restrict_with_error

    has_many :biocuration_classifications,  inverse_of: :biological_collection_object, dependent: :destroy, foreign_key: :biological_collection_object_id
    has_many :biocuration_classes, through: :biocuration_classifications, inverse_of: :biological_collection_objects

    accepts_nested_attributes_for :biocuration_classes, allow_destroy: true
    accepts_nested_attributes_for :biocuration_classifications, allow_destroy: true

    accepts_nested_attributes_for :otus, allow_destroy: true, reject_if: :reject_otus
    accepts_nested_attributes_for :taxon_determinations, allow_destroy: true, reject_if: :reject_taxon_determinations

    # Note that this should not be a has_one because order is over-ridden on .first 
    # and can be lost when merged into other queries.
    def current_taxon_determination
      taxon_determinations.order(:position).first
    end

    def current_otu
      current_taxon_determination&.otu
    end

    def current_taxon_name
      current_otu&.taxon_name
    end
  end

  # see BiologicalCollectionObject
  def missing_determination
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

