# A Taxon determination is an assertion that a collection object belongs to a taxonomic *concept*.
#
# If you wish to capture verbatim determinations then they should be added to CollectionObject#buffered_determinations,
# i.e. TaxonDeterminations are fully "normalized".
#
# @!attribute taxon_determination_object_id
#   @return [Integer]
#     id of the object being determined
#
# @!attribute taxon_determination_object_type
#   @return [Integer]
#     type of the object being determined
#
# @!attribute otu_id
#   @return [Integer]
#   the OTU (concept) of the determination
#
# @!attribute position
#   @return [Integer]
#     a cached, field managed by acts_as_list
#     the deterimination of a specimen with position '1' is the *accepted* determination, it NOT
#     necessarily the most recent determination made
#
# @!attribute year_made
#   @return [Integer]
#     the 4 digit year the determination was made
#
# @!attribute month_made
#   @return [Integer]
#     the month the determination was made
#
# @!attribute day_made
#   @return [Integer]
#   the day of the month the determination was made
#
# @!attribute project_id
#   @return [Integer]
#   the project ID
#
class TaxonDetermination < ApplicationRecord
  acts_as_list scope: [:taxon_determination_object_id, :taxon_determination_object_type, :project_id], add_new_at: :top

  include Housekeeping
  include Shared::Citations
  include Shared::DataAttributes
  include Shared::Notes
  include Shared::Confidences
  include Shared::Labels
  include Shared::Depictions
  include Shared::ProtocolRelationships
  include Shared::IsData
  include SoftValidation
  ignore_whitespace_on(:print_label)

  belongs_to :otu, inverse_of: :taxon_determinations
  belongs_to :taxon_determination_object, polymorphic: true, inverse_of: :taxon_determinations

  has_many :determiner_roles, class_name: 'Determiner', as: :role_object, inverse_of: :role_object
  has_many :determiners, through: :determiner_roles, source: :person, inverse_of: :taxon_determinations

  has_many :determiners_organization, through: :determiner_roles, source: :organization, inverse_of: :taxon_determinations

  validates :taxon_determination_object, presence: true
  validates :otu, presence: true
  validates :year_made, date_year: { min_year: 1757, max_year: -> {Time.now.year} }
  validates :month_made, date_month: true
  validates :day_made, date_day: {year_sym: :year_made, month_sym: :month_made}, unless: -> {year_made.nil? || month_made.nil?}

  # Careful, position must be reset with :update_column!
  validates_uniqueness_of :position, scope: [:taxon_determination_object_id, :taxon_determination_object_type, :project_id]

  # TODO: Add uniquiness constraint that also checks roles

  accepts_nested_attributes_for :determiners
  accepts_nested_attributes_for :determiner_roles, allow_destroy: true
  accepts_nested_attributes_for :otu, allow_destroy: false, reject_if: :reject_otu

  scope :current, -> { where(position: 1)}
  scope :historical, -> { where.not(position: 1)}

  before_destroy :prevent_if_required

  # @params params [Hash]
  # @params collection_objectt_id [Array, Integer]
  #   an Array or single id
  # @return Hash
  def self.batch_create(collection_object_id, params)
    collection_object_ids = [collection_object_id].flatten.compact.uniq
    result = {
      failed: [],
      total_created: 0
    }

    collection_object_ids.each do |id|
      begin
        TaxonDetermination.create!(
          params.merge(
            taxon_determination_object_id: id,
            taxon_determination_object_type: 'CollectionObject'
          )
        )

        result[:total_created] += 1

      rescue ActiveRecord::RecordInvalid
        result[:failed].push id
        next
      end
    end
    result
  end

  # @return [String]
  def date
    [year_made, month_made, day_made].compact.join('-')
  end

  # @return [Time]
  def sort_date
    Utilities::Dates.nomenclature_date(day_made, month_made, year_made)
  end

  protected

  # @param [Hash] attributed
  # @return [Boolean]
  def reject_otu(attributed)
    attributed['name'].blank? && attributed['taxon_name_id'].blank?
  end

  def prevent_if_required
    unless taxon_determination_object && taxon_determination_object.respond_to?(:ignore_taxon_determination_restriction) && taxon_determination_object.ignore_taxon_determination_restriction
      if !marked_for_destruction? && !new_record? && taxon_determination_object.requires_taxon_determination? && taxon_determination_object.taxon_determinations.count == 1
        errors.add(:base, 'at least one taxon determination is required')
        throw :abort
      end
    end
  end

end
