require 'fileutils'

# Gazetteer allows a project to add its own named shapes to participate in
# filtering, georeferencing, etc.
#
# @!attribute geography
#   @return [RGeo::Geographic::Geography]
#   Can hold any of the RGeo geometry types point, line string, polygon,
#   multipoint, multilinestring, multipolygon.
#
# @!attribute name
#   @return [String]
#   The name of the gazetteer item
#
# @!attribute parent_id
#   @return [Integer]
#   ???
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
#   the project ID

class Gazetteer < ApplicationRecord
  include Housekeeping
  include Shared::Citations
  include Shared::Notes
  include Shared::DataAttributes
  include Shared::AlternateValues
  include Shared::IsData

  ALTERNATE_VALUES_FOR = [:name].freeze

  has_closure_tree

  belongs_to :geographic_item, inverse_of: :gazetteer, dependent: :destroy

  validates :name, presence: true, length: {minimum: 1}

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
  #   geojson: array of geojson hashes,
  #   wkt: array of wkt strings,
  #   points: array of geojson points
  # Builds a GeographicItem for this gazetteer from the combined input shapes
  def build_gi_from_shapes(shapes)
    begin
      rgeo_shape = self.class.combine_shapes_to_rgeo(shapes)
    # TODO make sure these errors work
    rescue RGeo::Error::RGeoError => e
      errors.add(:base, e)
    rescue RGeo::Error::InvalidGeometry => e
      errors.add(:base, "Invalid geometry: #{e}")
    rescue TaxonWorks::Error => e
      errors.add(:base, e)
    end

    if errors.include?(:base) || rgeo_shape.nil?
      return
    end

    build_geographic_item(
      type: 'GeographicItem::Geography',
      geography: rgeo_shape
    )
  end

  # Assumes @gazetteer is set
  # @param [Hash] hash as in build_gi_from_shapes
  # @return A single rgeo shape containing all of the input shapes
  # Raises on error
  def self.combine_shapes_to_rgeo(shapes)
    if shapes['geojson'].blank? && shapes['wkt'].blank? &&
        shapes['points'].blank?
      raise TaxonWorks::Error, 'No shapes provided'
    end

    # TODO anti-meridian fails here
    leaflet_rgeo = convert_geojson_to_rgeo(shapes['geojson'])
    wkt_rgeo = convert_wkt_to_rgeo(shapes['wkt'])
    points_rgeo = convert_geojson_to_rgeo(shapes['points'])

    shapes = leaflet_rgeo + wkt_rgeo + points_rgeo

    combine_rgeo_shapes(shapes)
  end

  # @return [Array] of RGeo::Geographic::Projected*Impl
  # Raises RGeo::Error::InvalidGeometry on error
  def self.convert_geojson_to_rgeo(shapes)
    return [] if shapes.blank?

    rgeo_shapes = shapes.map { |shape|
      # Raises RGeo::Error::InvalidGeometry on error
      rgeo_shape = RGeo::GeoJSON.decode(
        shape, json_parser: :json, geo_factory: Gis::FACTORY
      )

      circle = nil
      if rgeo_shape.geometry.geometry_type.to_s == 'Point' &&
           rgeo_shape.properties['radius'].present?
        # TODO probably limit radius and/or center (if leaflet doesn't already)
        r = rgeo_shape.properties['radius']

        circle = GeographicItem.circle(rgeo_shape.geometry, r)
      end

      circle || rgeo_shape.geometry
    }

    rgeo_shapes
  end

  # @return [Array] of RGeo::Geographic::Projected*Impl
  # Raises RGeo::Error::RGeoError on error
  def self.convert_wkt_to_rgeo(wkt_shapes)
    return [] if wkt_shapes.blank?

    wkt_shapes.map { |shape|
      begin
        ::Gis::FACTORY.parse_wkt(shape)
      rescue RGeo::Error::RGeoError => e
        raise e.exception("Invalid WKT: #{e.message}")
      end
    }
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
    # TODO use pg's ST_UnaryUnion instead?
    u = rgeo_shapes[0]
    rgeo_shapes[1..].each { |s| u = u.union(s) }

    if u.nil?
      raise TaxonWorks::Error, 'Computing the union of the shapes failed'
    end

    u
  end

  def self.import_from_shapefile(shapefile)
    # TODO check params
    shp_doc = Document.find(shapefile[:shp_doc_id])
    shx_doc = Document.find(shapefile[:shp_doc_id])
    dbf_doc = Document.find(shapefile[:shp_doc_id])
    prj_doc = Document.find(shapefile[:shp_doc_id])


  end
end
