# An AssertedDistribution is the source-backed assertion that a taxon (OTU) is present in some *spatial area*.  It requires a Citation indicating where/who made the assertion.
# In TaxonWorks the areas are drawn from GeographicAreas, which essentially represent a gazeteer of 3 levels of subdivision (e.g. country, state, county).
#
# AssertedDistributions can be asserts that the source indicates that a taxon is NOT present in an area.  This is a "positive negative" in , i.e. the Source can be thought of recording evidence that a taxon is not present. TaxonWorks does not differentiate between types of negative evidence.
#
#
# @!attribute otu_id
#   @return [Integer]
#   the OTU ID
#
# @!attribute geographic_area_id
#   @return [Integer]
#   the geographic area ID
#
# @!attribute project_id
#   @return [Integer]
#   the project ID
#
# @!attribute is_absent
#   @return [Boolean]
#     a positive negative, when true then there exists an assertion that the taxon is not present in the spatial area
#
class AssertedDistribution < ApplicationRecord
  include Housekeeping
  include Shared::Notes
  include SoftValidation
  include Shared::Tags
  include Shared::DataAttributes
  include Shared::Citations
  include Shared::Confidences
  include Shared::IsData

  include Shared::IsDwcOccurrence
  include AssertedDistribution::DwcExtensions

  belongs_to :otu, inverse_of: :asserted_distributions
  has_one :taxon_name, through: :otu
  belongs_to :geographic_area, inverse_of: :asserted_distributions

  has_one :geographic_item, through: :geographic_area, source: :default_geographic_item
  has_many :geographic_items, through: :geographic_area

  validates_presence_of :geographic_area_id, message: 'geographic area is not selected'

  # Might not be able to do these for nested attributes
  validates :geographic_area, presence: true
  validates :otu, presence: true

  validates_uniqueness_of :geographic_area_id, scope: [:project_id, :otu_id, :is_absent], message: 'this geographic_area, OTU and present/absent combination already exists'

  validate :new_records_include_citation

  scope :with_otu_id, -> (otu_id) { where(otu_id: otu_id) }
  scope :with_geographic_area_id, -> (geographic_area_id) { where(geographic_area_id: geographic_area_id) }
  scope :with_geographic_area_array, -> (geographic_area_array) { where('geographic_area_id IN (?)', geographic_area_array) }
  scope :with_is_absent, -> { where('is_absent = true') }
  scope :without_is_absent, -> { where('is_absent = false OR is_absent is Null') }

  accepts_nested_attributes_for :otu, allow_destroy: false, reject_if: proc { |attributes| attributes['name'].blank? && attributes['taxon_name_id'].blank? }

  soft_validate(:sv_conflicting_geographic_area, set: :conflicting_geographic_area)

  # @param [ActionController::Parameters] params
  # @return [Scope]
  def self.find_for_autocomplete(params)
    term = params[:term]
    include(:geographic_area, :otu)
      .where(geographic_areas: {name: term}, otus: {name: term})
      .with_project_id(params[:project_id])
  end

  # @param [Hash] defaults
  # @return [AssertedDistribution]
  #   used to also stub an #origin_citation, as required
  def self.stub(defaults: {})
    a                 = AssertedDistribution.new(
      otu_id:                     defaults[:otu_id],
      origin_citation_attributes: {source_id: defaults[:source_id]}
    )
    a.origin_citation = Citation.new if defaults[:source_id].blank?
    a
  end

  # rubocop:disable Style/StringHashKeys
  # @return [Hash] GeoJSON feature
  def to_geo_json_feature
    retval = {
      'type'       => 'Feature',
      'geometry'   => RGeo::GeoJSON.encode(self.geographic_area.geographic_items.first.geo_object),
      'properties' => {'asserted_distribution' => {'id' => self.id}}
    }
    retval
  end

  # rubocop:enable Style/StringHashKeys

  # @return [True]
  #   see citable.rb
  def requires_citation?
    true
  end

  def geographic_item
    geographic_area.default_geographic_item
  end

  protected

  # @return [Boolean]
  def new_records_include_citation
    if new_record? && source.blank? && origin_citation.blank? && !citations.any?
      errors.add(:base, 'required citation is not provided')
    end
  end

  # @return [Nil]
  def new_records_include_otu
  end

  # @return [Boolean]
  def sv_conflicting_geographic_area
    ga = self.geographic_area
    unless ga.nil?
      if self.is_absent == true # this returns an array, not a single GA so test below is not right
        presence = AssertedDistribution.without_is_absent.with_geographic_area_id(self.geographic_area_id)
        soft_validations.add(:geographic_area_id, "Taxon is reported as present in #{presence.first.geographic_area.name}") unless presence.empty?
      else
        areas    = [ga.level0_id, ga.level1_id, ga.level2_id].compact
        presence = AssertedDistribution.with_is_absent.with_geographic_area_array(areas)
        soft_validations.add(:geographic_area_id, "Taxon is reported as missing in #{presence.first.geographic_area.name}") unless presence.empty?
      end
    end
  end

  # @param [Hash] options of e.g., {otu_id: 5, source_id: 5, geographic_areas: Array of {GeographicArea}}
  # @return [Array] an array of AssertedDistributions
  def self.stub_new(options = {})
    options.symbolize_keys!
    result = []
    options[:geographic_areas].each do |ga|
      result.push(
        AssertedDistribution.new(
          otu_id: options[:otu_id],
          geographic_area: ga,
          origin_citation_attributes: {source_id: options[:source_id]})
      )
    end
    result
  end

end
