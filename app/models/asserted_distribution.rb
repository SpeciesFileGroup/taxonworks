# An Asserted distribution is the assertion that a taxon is present in some *spatial area*.
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
# @!attribute source_id
#   @return [Integer]
#   the source ID
#
# @!attribute project_id
#   @return [Integer]
#   the project ID
#
# @!attribute is_absent
#   @return [Boolean]
#   @todo
#
class AssertedDistribution < ActiveRecord::Base
  include Housekeeping
  include Shared::Notable
  include SoftValidation
  include Shared::IsData
  include Shared::Taggable
  include Shared::DataAttributes
  include Shared::Citable

  belongs_to :otu
  belongs_to :geographic_area

  accepts_nested_attributes_for :otu, allow_destroy: false, reject_if: proc { |attributes| attributes['name'].blank? && attributes['taxon_name_id'].blank?  }

  validates_presence_of :otu_id, message: 'Taxon is not specified', if: proc { |attributes| attributes['otu_attributes'] && (!attributes['otu_attributes']['name'] || !attributes['otu_attributes']['taxon_name_id'])}

#  validates_presence_of :geographic_area_id, message: 'Geographic area is not selected'
#  validates_presence_of :source_id, message: 'Source is not selected'
#  validates :geographic_area, presence: true
  validates :otu, presence: true
#  validates :source, presence: true

#  validates_uniqueness_of :geographic_area_id, scope: [:otu_id, :source_id], message: 'record for this source/otu combination already exists'
  validates_uniqueness_of :geographic_area_id, scope: :otu_id

  before_validation :check_required_fields

  scope :with_otu_id, -> (otu_id) { where(otu_id: otu_id) }
  scope :with_geographic_area_id, -> (geographic_area_id) { where(geographic_area_id: geographic_area_id) }
  scope :with_geographic_area_array, -> (geographic_area_array) { where('geographic_area_id IN (?)', geographic_area_array) }
  scope :with_is_absent, -> { where('is_absent = true') }
  scope :without_is_absent, -> { where('is_absent = false OR is_absent is Null') }

  soft_validate(:sv_conflicting_geographic_area, set: :conflicting_geographic_area)

  def self.find_for_autocomplete(params)
    # where('geographic_area LIKE ?', "%#{params[:term]}%").with_project_id(params[:project_id])
    term = params[:term]
#    include(:geographic_area, :otu, :source).
#      where(geographic_areas: {name: term}, otus: {name: term}, sources: {cached: term}).with_project_id(params[:project_id])
    include(:geographic_area, :otu).
        where(geographic_areas: {name: term}, otus: {name: term}).with_project_id(params[:project_id])
  end

  def to_geo_json_feature
    retval = {
      'type'       => 'Feature',
      'geometry'   => RGeo::GeoJSON.encode(self.geographic_area.geographic_items.first.geo_object),
      'properties' => {
        'asserted_distribution' => {
          'id' => self.id
        }
      }
    }
    retval
  end

  protected

  def check_required_fields
    if self.geographic_area_id.nil? && self.verbatim_geographic_area.blank?
      errors.add(:geographic_area_id, 'and/or verbatim geographic area should be selected')
      errors.add(:verbatim_geographic_area, 'and/or geographic area should be selected')
    end
  end

  #region Soft validation

  def sv_conflicting_geographic_area
    ga = self.geographic_area
    unless ga.nil?
      if self.is_absent == true
        presence = AssertedDistribution.without_is_absent.with_geographic_area_id(self.geographic_area_id) # this returns an array, not a single GA so test below is not right
        soft_validations.add(:geographic_area_id, "Taxon is reported as present in #{presence.first.geographic_area.name}") unless presence.empty?
      else
        areas    = [ga.level0_id, ga.level1_id, ga.level2_id].compact
        presence = AssertedDistribution.with_is_absent.with_geographic_area_array(areas)
        soft_validations.add(:geographic_area_id, "Taxon is reported as missing in #{presence.first.geographic_area.name}") unless presence.empty?
      end
    end
  end

  #end region

  #region Class methods

  # @param options [Hash] of e.g., {otu_id: 5, source_id: 5, geographic_areas: Array of {GeographicArea}}
  # @return an array of new AssertedDistributions.
  def self.stub_new(options = {})
    result = []
    options['geographic_areas'].each do |ga|
#      result.push(AssertedDistribution.new(source_id: options['source_id'], otu_id: options['otu_id'], geographic_area: ga))
      result.push(AssertedDistribution.new(otu_id: options['otu_id'], geographic_area: ga))
    end
    result
  end

  def self.generate_download(scope)
    CSV.generate do |csv|
      csv << column_names
      scope.order(id: :asc).each do |o|
        csv << o.attributes.values_at(*column_names).collect { |i|
          i.to_s.gsub(/\n/, '\n').gsub(/\t/, '\t')
        }
      end
    end
  end

  #end region
end