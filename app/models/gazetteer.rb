# Gazetteer allows a project to add its own named shapes to participate in
# filtering, etc.
#
# @!attribute geographic_item_id
#   @return [Integer]
#   The shape of the gazetteer
#
# @!attribute name
#   @return [String]
#   The name of the gazetteer
#
# @!attribute iso_3166_a2
#   @return [String]
#   Two alpha-character identification of country.
#
# @!attribute iso_3166_a3
#   @return [String]
#   Three alpha-character identification of country.
#
# @!attribute project_id
#   @return [Integer]
#   The project ID
#
class Gazetteer < ApplicationRecord
  include Housekeeping
  include Shared::Citations
  include Shared::Notes
  include Shared::DataAttributes
  include Shared::AlternateValues
  include Shared::IsData

  ALTERNATE_VALUES_FOR = [:name].freeze

  delegate :geo_object, to: :geographic_item

  belongs_to :geographic_item, inverse_of: :gazetteers

  before_validation do
    self.iso_3166_a2 = iso_3166_a2.strip.upcase if iso_3166_a2.present?
  end
  before_validation do
    self.iso_3166_a3 = iso_3166_a3.strip.upcase if iso_3166_a3.present?
  end

  validates :name, presence: true, length: {minimum: 1}
  validate :iso_3166_a2_is_two_characters
  validate :iso_3166_a3_is_three_characters

  after_destroy :destroy_geographic_item_if_orphaned

  accepts_nested_attributes_for :geographic_item

  # @return [Hash] of the pieces of a GeoJSON 'Feature'
  def to_geo_json_feature
    to_simple_json_feature.merge(
      properties: {
        gazetteer: {
          id:,
          tag: name
        }
      }
    )
  end

  def to_simple_json_feature
    {
      type: 'Feature',
      properties: {},
      geometry: geographic_item.to_geo_json
    }
  end

  # @param shapes, a hash:
  #   geojson: array of geojson feature hashes,
  #   wkt: array of wkt strings,
  #   points: array of geojson feature points
  #   ga_union: array of GA ids
  #   gz_union: array of GZ ids
  # Builds a GeographicItem for this gazetteer from the combined input shapes
  def build_gi_from_shapes(shapes)
    begin
      rgeo_shape = self.class.combine_shapes_to_rgeo(shapes)
    rescue TaxonWorks::Error => e
      errors.add(:base, e)
      return
    end

    build_geographic_item(
      geography: rgeo_shape
    )
  end

  # @param [Hash] hash as in build_gi_from_shapes
  # @return A single rgeo shape that is the union of all of the input shapes
  # Raises TaxonWorks::Error on error
  def self.combine_shapes_to_rgeo(shapes)
    begin
      if shapes[:geojson].blank? && shapes[:wkt].blank? &&
          shapes[:points].blank? && shapes[:ga_union].blank? &&
          shapes[:gz_union].blank?
        raise TaxonWorks::Error, 'No shapes provided'
      end

      leaflet_rgeo = convert_geojson_to_rgeo(shapes[:geojson])
      wkt_rgeo = convert_wkt_to_rgeo(shapes[:wkt])
      points_rgeo = convert_geojson_to_rgeo(shapes[:points])
      ga_rgeo = convert_ga_to_rgeo(shapes[:ga_union])
      gz_rgeo = convert_gz_to_rgeo(shapes[:gz_union])

      user_input_shapes = leaflet_rgeo + wkt_rgeo + points_rgeo

      # Special case: longitudes get normalized by our rgeo processing for all
      # cases except for a single point, so we need to handle that case ourselves.
      if user_input_shapes.count == 1 && (ga_rgeo.count + gz_rgeo.count == 0)
        s = user_input_shapes.first
        if s.geometry_type.to_s == 'Point' && (s.lon < -180.0 || s.lon > 180.0)
          new_lon = s.lon % 360.0
          new_lon = new_lon - 360.0 if new_lon > 180.0
          user_input_shapes[0] = Gis::FACTORY.point(new_lon, s.lat)
        end
      end

      # Invalid shapes won't raise until they're used in an operation requiring
      # valid shapes, like union below, but we should check here before that
      # happens. (Existing GAs and GZs are asummed valid!)
      user_input_shapes.each do |s|
        if !s.valid?
          s_str = s.to_s
          shape_to_s = s_str.length > 30 ? "'#{s_str[0, 30]}'..." : "'#{s_str}'"
          raise RGeo::Error::InvalidGeometry, "#{s.invalid_reason} #{shape_to_s}"
        end
      end

      return combine_rgeo_shapes(user_input_shapes + ga_rgeo + gz_rgeo)

    # This is more specific than RGeo::Error::RgeoError
    rescue RGeo::Error::InvalidGeometry => e
      raise TaxonWorks::Error, e
    rescue RGeo::Error::RGeoError => e
      raise TaxonWorks::Error, e
    end
  end

  # @return [Array] of RGeo::Geographic::Projected*Impl
  # Raises RGeo::Error::InvalidGeometry on error
  def self.convert_geojson_to_rgeo(shapes)
    return [] if shapes.blank?

    rgeo_shapes = shapes.map do |shape|
      # Raises RGeo::Error::InvalidGeometry on error
      rgeo_shape = RGeo::GeoJSON.decode(shape, geo_factory: Gis::FACTORY)

      circle = nil
      if rgeo_shape.geometry.geometry_type.to_s == 'Point' &&
           rgeo_shape.properties['radius'].present?
        r = rgeo_shape.properties['radius']

        circle = GeographicItem.circle(rgeo_shape.geometry, r)
      end

      s = circle || rgeo_shape.geometry

      split_shape_along_anti_meridian(s)
    end

    rgeo_shapes
  end

  def self.convert_ga_to_rgeo(ga_ids)
    return [] if ga_ids.blank?

    GeographicArea.where(id: ga_ids).map { |ga| ga.geo_object }
  end

  def self.convert_gz_to_rgeo(gz_ids)
    return [] if gz_ids.blank?

    Gazetteer.where(id: gz_ids).map { |gz| gz.geo_object }
  end

  # @return [Array] of RGeo::Geographic::Projected*Impl
  # Raises RGeo::Error::RGeoError on error
  def self.convert_wkt_to_rgeo(wkt_shapes)
    return [] if wkt_shapes.blank?

    wkt_shapes.map do |shape|
      begin
        s = ::Gis::FACTORY.parse_wkt(shape)
      rescue RGeo::Error::RGeoError => e
        raise e.exception("Invalid WKT: #{e.message}")
      end

      split_shape_along_anti_meridian(s)
    end
  end

  # @param [Array] rgeo_shapes of RGeo::Geographic::Projected*Impl
  # @return [RGeo::Geographic::Projected*Impl] A single shape combining all of the
  #   input shapes
  # Raises TaxonWorks::Error on error
  def self.combine_rgeo_shapes(rgeo_shapes)
    if rgeo_shapes.count == 1
      return rgeo_shapes[0]
    end

    # unary_union, which would be preferable here, is apparently unavailable
    # for geographic geometries
    # TODO use pg's ST_Union/UnaryUnion instead?
    u = rgeo_shapes[0]
    rgeo_shapes[1..].each { |s| u = u.union(s) }

    if u.nil?
      raise TaxonWorks::Error, 'Computing the union of the shapes failed'
    end

    u
  end

  # @param gz [Gazetteer] Unsaved Gazetteer to save and clone from
  # @param project_ids [Array] project ids to clone gz into - gz is always
  #   saved to the current project
  # @return [Array] of {id:, project_id:} for gazetteers created
  # Raises ActiveRecord::RecordInvalid on error
  def self.clone_to_projects(gz, project_ids)
    project_ids.delete(Current.project_id)
    project_ids.uniq!
    if project_ids.empty?
      gz.save!
      return [{ id: gz.id, project_id: gz.project_id }]
    end

    rv = []
    Gazetteer.transaction do
      gz.save!
      rv << { id: gz.id, project_id: gz.project_id }
      project_ids.each do |pr_id|
        d = gz.dup
        d.project_id = pr_id
        d.save!
        rv << { id: d.id, project_id: d.project_id }
      end
    end

    rv
  end

  private

  def iso_3166_a2_is_two_characters
    errors.add(:iso_3166_a2, 'must be exactly two characters') unless
      iso_3166_a2.nil? || /\A[A-Z][A-Z]\z/.match?(iso_3166_a2)
  end

  def iso_3166_a3_is_three_characters
    errors.add(:iso_3166_a3, 'must be exactly three characters') unless
      iso_3166_a3.nil? || /\A[A-Z][A-Z][A-Z]\z/.match?(iso_3166_a3)
  end

  # @param [RGeo shape] s
  # @return [RGeo shape] s split along the anti-meridian
  def self.split_shape_along_anti_meridian(s)
    GeographicItem.crosses_anti_meridian?(s.as_text) ?
      GeographicItem.split_along_anti_meridian(s.as_text) : s
  end

  def destroy_geographic_item_if_orphaned
    if geographic_item.gazetteers.count == 0
      geographic_item.destroy!
    end
  end
end
