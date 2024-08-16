require 'fileutils'

# Gazetteer allows a project to add its own named shapes to participate in
# filtering, etc.
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

  delegate :geo_object, to: :geographic_item

  belongs_to :geographic_item, inverse_of: :gazetteer, dependent: :destroy

  before_validation do
    self.iso_3166_a2 = iso_3166_a2.strip.upcase if iso_3166_a2.present?
  end
  before_validation do
    self.iso_3166_a3 = iso_3166_a3.strip.upcase if iso_3166_a3.present?
  end

  validates :name, presence: true, length: {minimum: 1}
  validate :iso_3166_a2_is_two_characters
  validate :iso_3166_a3_is_three_characters

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
    # This is more specific than RGeo::Error::RgeoError
    rescue RGeo::Error::InvalidGeometry => e
      errors.add(:base, e)
    rescue RGeo::Error::RGeoError => e
      errors.add(:base, e)
    rescue TaxonWorks::Error => e
      errors.add(:base, e)
    end

    if errors.include?(:base) || rgeo_shape.nil?
      return
    end

    build_geographic_item(
      geography: rgeo_shape
    )
  end

  # Assumes @gazetteer is set
  # @param [Hash] hash as in build_gi_from_shapes
  # @return A single rgeo shape containing all of the input shapes
  # Raises on error
  def self.combine_shapes_to_rgeo(shapes)
    if shapes['geojson'].blank? && shapes['wkt'].blank? &&
        shapes['points'].blank? && shapes['ga_union'].blank? &&
        shapes['gz_union'].blank?
      raise TaxonWorks::Error, 'No shapes provided'
    end

    leaflet_rgeo = convert_geojson_to_rgeo(shapes['geojson'])
    wkt_rgeo = convert_wkt_to_rgeo(shapes['wkt'])
    points_rgeo = convert_geojson_to_rgeo(shapes['points'])
    ga_rgeo = convert_ga_to_rgeo(shapes['ga_union'])
    gz_rgeo = convert_gz_to_rgeo(shapes['gz_union'])

    shapes = leaflet_rgeo + wkt_rgeo + points_rgeo + ga_rgeo + gz_rgeo

    # Invalid shapes won't raise until they're used in an operation requiring
    # valid shapes, like union below, but we should check here before that
    # happens.
    shapes.each { |s|
      if !s.valid?
        shape_to_s = s.to_s.length > 30 ? s.to_s + '...' : s.to_s
        raise RGeo::Error::InvalidGeometry, "#{s.invalid_reason} #{shape_to_s}"
      end
    }

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
    # TODO use pg's ST_Union/UnaryUnion instead?
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
    shx_doc = Document.find(shapefile[:shx_doc_id])
    dbf_doc = Document.find(shapefile[:dbf_doc_id])
    prj_doc = Document.find(shapefile[:prj_doc_id])
    name_field = shapefile[:name_field]

    # The above shapefile files are unlikely to all be in the same directory as
    # required by rgeo-shapefile, so create symbolic links to each in a new
    # temporary folder.
    tmp_dir = Rails.root.join('tmp', 'shapefiles', SecureRandom.hex)
    FileUtils.mkdir_p(tmp_dir)

    shp_link = File.join(tmp_dir, 'shapefile.shp')
    shx_link = File.join(tmp_dir, 'shapefile.shx')
    dbf_link = File.join(tmp_dir, 'shapefile.dbf')
    prj_link = File.join(tmp_dir, 'shapefile.prj')

    FileUtils.ln_s(shp_doc.document_file.path, shp_link)
    FileUtils.ln_s(shx_doc.document_file.path, shx_link)
    FileUtils.ln_s(dbf_doc.document_file.path, dbf_link)
    FileUtils.ln_s(prj_doc.document_file.path, prj_link)

    r = processShapeFile(shp_link, name_field)

    FileUtils.rm_f([shp_link, dbf_link, shx_link, prj_link])
    FileUtils.rmdir(tmp_dir)

    r
  end

  def self.processShapeFile(shpfile, name_field)
    r = {
      num_records: 0,
      num_gzs_created: 0,
      error_id: nil,
      error_message: nil,
    }
    # TODO what can .open throw? no such file, bad shapefile, ...
    RGeo::Shapefile::Reader.open(
      shpfile, factory: Gis::FACTORY, allow_unsafe: true
    ) do |file|
      r[:num_records] = file.num_records
      begin
        Gazetteer.transaction do
          # Iterate over an index so we can record index on error
          for i in 0...file.num_records
            begin
              # This can throw GeosError even when allow_unsafe: true
              record = file[i]

              g = Gazetteer.new(
                # There's no shapefile requirement that this field be non-nil,
                # so this could cause failure on save
                name: record[name_field]
              )

              # TODO: abort if too many invalid? Checking `valid?` isn't fast
              # on large shapes
              shape = record.geometry.valid? ?
                record.geometry : record.geometry.make_valid

              g.build_geographic_item(
                geography: shape
              )

              g.save!

              r[:num_gzs_created] += 1
            rescue RGeo::Error::InvalidGeometry => e
              r[:error_id] = i + 1
              r[:error_message] = e.to_s
              raise ActiveRecord::RecordInvalid
            rescue ActiveRecord::RecordInvalid => e
              r[:error_id] = i + 1
              r[:error_message] = e.to_s
              raise ActiveRecord::RecordInvalid
            rescue RGeo::Error::GeosError => e
              r[:error_id] = i + 1
              r[:error_message] = e.to_s
              raise ActiveRecord::RecordInvalid
            end
          end
        end
      rescue ActiveRecord::RecordInvalid
        m = "Error on record #{r[:error_id]}/#{r[:num_records]}: #{r[:error_message]}"
        raise TaxonWorks::Error, m
      end
    end

    r
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

end
