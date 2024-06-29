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

  belongs_to :geographic_item, inverse_of: :gazetteers

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

  # Assumes @gazetteer is set
  # @param [Hash] TODO describe shape of hash
  # @return A single rgeo shape containing all of the input shapes
  # Raises on error
  def self.combine_shapes_to_rgeo(shapes)
    if shapes['geojson'].blank? && shapes['wkt'].blank?
      raise TaxonWorks::Error, 'No shapes provided'
    end

    geojson_rgeo = convert_geojson_to_rgeo(shapes['geojson'])
    wkt_rgeo = convert_wkt_to_rgeo(shapes['wkt'])
    if geojson_rgeo.nil? || wkt_rgeo.nil?
      return nil
    end

    shapes = geojson_rgeo + wkt_rgeo

    combine_rgeo_shapes(shapes)
  end

  # @return [Array] of RGeo::Geographic::Projected*Impl
  # Raises RGeo::Error::InvalidGeometry on error
  def self.convert_geojson_to_rgeo(shapes)
    return [] if shapes.blank?

    rgeo_shapes = shapes.map { |shape|
      # Raises RGeo::Error::InvalidGeometry on error
      RGeo::GeoJSON.decode(
        shape, json_parser: :json, geo_factory: Gis::FACTORY
      )
    }

    # TODO can i do the &geometry thing here?
    rgeo_shapes.map { |shape| shape.geometry }
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

    multi = nil
    type = nil

    types = rgeo_shapes.map { |shape|
      shape.geometry_type.type_name
    }.uniq

    if types.count == 1
      type = types[0]
      case type
      when 'Point'
        multi = Gis::FACTORY.multi_point(rgeo_shapes)
      when 'LineString'
        multi = Gis::FACTORY.multi_line_string(rgeo_shapes)
      when 'Polygon'
        multi = Gis::FACTORY.multi_polygon(rgeo_shapes)
      when 'GeometryCollection'
        multi = Gis::FACTORY.collection(rgeo_shapes)
      end
    else # multiple geometries of different types
      type = 'Multi-types'
      # This could itself include GeometryCollection(s)
      multi = Gis::FACTORY.collection(rgeo_shapes)
    end

    if multi.nil?
      message = type == 'Multi-types' ?
        'Error in combining mutiple types into a single GeometryCollection' :
        "Error in combining multiple #{type}s into a multi-#{type}"
      raise Taxonworks::Error, message
    end

    multi
  end


end
