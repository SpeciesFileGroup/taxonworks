class AssertedDistribution < ActiveRecord::Base
  include Housekeeping
  include Shared::Notable
  include SoftValidation
  include Shared::IsData

  belongs_to :otu, validate: { presence: true }
  belongs_to :geographic_area, validate: { presence: true }
  belongs_to :source, validate:  { presence: true }

  validates_presence_of :otu_id, message: 'Taxon is not specified'
  validates_presence_of :geographic_area_id, message: 'Geographic area is not selected'
  validates_presence_of :source_id, message: 'Source is not selected'
  validates_uniqueness_of :geographic_area_id, scope: [:otu_id, :source_id], message: 'Duplicate record'

  scope :with_otu_id, -> (otu_id) { where(otu_id: otu_id) }
  scope :with_geographic_area_id, -> (geographic_area_id) { where(geographic_area_id: geographic_area_id) }
  scope :with_geographic_area_array, -> (geographic_area_array) { where('geographic_area_id IN (?)', geographic_area_array) }
  scope :with_is_absent, -> { where('is_absent = true') }
  scope :without_is_absent, -> { where('is_absent = false OR is_absent is Null') }

  # TODO: this should be a housekeeping scope
  scope :not_self, -> (id) { where('asserted_distribution.id <> ?', id) }

  soft_validate(:sv_conflicting_geographic_area, set: :conflicting_geographic_area)

  def self.find_for_autocomplete(params)
    # where('geographic_area LIKE ?', "%#{params[:term]}%").with_project_id(params[:project_id])
    term = params[:term]
    include(:geographic_area, :otu, :source).
      where(geographic_areas: {name: term}, otus: {name: term}, sources: {cached: term})
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

  # @param options [Hash] of e.g., {otu_id: 5, source_id: 5, latitude: '12.12', longitude: '12.312'}
  # @ return an array of new AssertedDistributions.
  def self.stub_new(options = {})
    areas = GeographicArea.find_by_lat_long(options['latitude'], options['longitude'])
    result = []
    areas.each do |ga|
      result.push(AssertedDistribution.new(source_id: options['source_id'], otu_id: options['otu_id'], geographic_area: ga))
    end
    result
  end

  #end region

  #region Instance methods

  def to_geo_json_feature
    retval = {
      'type'       => 'Feature',
      'geometry'   => RGeo::GeoJSON.encode(self.geographic_area.geographic_items.first.geo_object),
      'properties' => {
        'asserted_distribution' => {
          'id' => self.id}
      }
    }
    retval
  end

  #end region

end
