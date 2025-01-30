require_dependency Rails.root.to_s + '/lib/vendor/rgeo.rb'

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

  # @param shapes [Hash]
  #   geojson: array of geojson feature hashes,
  #   wkt: array of wkt strings,
  #   points: array of geojson feature points
  #   ga_combine: array of GA ids
  #   gz_combine: array of GZ ids
  # @param operation_is_union [Boolean] Union if true, intersection if false
  # Builds a GeographicItem for this gazetteer from the combined input shapes
  def build_gi_from_shapes(shapes, operation_is_union=true)
    begin
      rgeo_shape = self.class.combine_shapes_to_rgeo(shapes, operation_is_union)
    rescue TaxonWorks::Error => e
      errors.add(:base, e)
      return
    end

    build_geographic_item(
      geography: rgeo_shape
    )
  end

  # @param [Hash] hash as in build_gi_from_shapes
  # @param operation_is_union [Boolean] Union if true, intersection if false
  # @return A single rgeo shape that is the combination of all of the input shapes
  # Raises TaxonWorks::Error on error
  def self.combine_shapes_to_rgeo(shapes, operation_is_union)
    begin
      if shapes[:geojson].blank? && shapes[:wkt].blank? &&
          shapes[:points].blank? && shapes[:ga_combine].blank? &&
          shapes[:gz_combine].blank?
        raise TaxonWorks::Error, 'No shapes provided'
      end

      leaflet_rgeo = convert_geojson_to_rgeo(shapes[:geojson])
      wkt_rgeo = convert_wkt_to_rgeo(shapes[:wkt])
      points_rgeo = convert_geojson_to_rgeo(shapes[:points])
      ga_rgeo = convert_ga_to_rgeo(shapes[:ga_combine])
      gz_rgeo = convert_gz_to_rgeo(shapes[:gz_combine])

      user_input_shapes = leaflet_rgeo + wkt_rgeo + points_rgeo

      return combine_rgeo_shapes(
        user_input_shapes + ga_rgeo + gz_rgeo, operation_is_union
      )

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

      GeographicItem.make_valid_non_anti_meridian_crossing_shape(s.as_text)
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

      GeographicItem.make_valid_non_anti_meridian_crossing_shape(s.as_text)
    end
  end

  # @param [Array] rgeo_shapes of RGeo::Geographic::Projected*Impl
  # @param operation_is_union [Boolean] Union if true, intersection if false
  # @return [RGeo::Geographic::Projected*Impl] A single shape combining all of the
  #   input shapes
  # Raises TaxonWorks::Error on error
  def self.combine_rgeo_shapes(rgeo_shapes, operation_is_union)
    if rgeo_shapes.count == 1
      return rgeo_shapes[0]
    end

    if operation_is_union
      # unary_union, which would be preferable here, is apparently unavailable
      # for geographic geometries
      # TODO use pg's ST_Union/UnaryUnion instead?
      u = rgeo_shapes[0]
      rgeo_shapes[1..].each { |s| u = u.union(s) }
    else # Intersection
      u = rgeo_shapes[0]
      rgeo_shapes[1..].each { |s| u = u.intersection(s) }
      # TODO how to check if intersection is empty?
    end

    if u.empty?
      message = operation_is_union ?
        "Empty union can't be saved!" : "Empty intersection can't be saved!"
      raise TaxonWorks::Error, message
    end

    u
  end

  # @param gz [Gazetteer] Unsaved Gazetteer to save and clone from
  # @param project_ids [Array] project ids to clone gz into - gz is always
  #   saved to the current project.
  #   If saves occur in more than one project then all saves occur in a
  #   transaction.
  # @param citation [Hash] Citation object to save to each Gazetteer created
  # Raises ActiveRecord::RecordInvalid on error
  def self.save_and_clone_to_projects(gz, project_ids, citation = nil)
    project_ids.delete(Current.project_id)
    project_ids.uniq!

    if project_ids.count > 0
      Gazetteer.transaction do
        perform_save_and_clone_to_projects(gz, project_ids, citation)
      end
    else
      perform_save_and_clone_to_projects(gz, [], citation)
    end
  end

  def self.validate_iso_3166_a2(a2)
    return false if a2.blank? || a2.class.to_s != 'String'
    /\A[A-Z][A-Z]\z/.match?(a2.strip.upcase)
  end

  def self.validate_iso_3166_a3(a3)
    return false if a3.blank? || a3.class.to_s != 'String'
    /\A[A-Z][A-Z][A-Z]\z/.match?(a3.strip.upcase)
  end

  def self.import_gzs_from_shapefile(
    shapefile, citation_options, progress_tracker, projects
  )
    begin
      shp_doc = Document.find(shapefile[:shp_doc_id])
      shx_doc = Document.find(shapefile[:shx_doc_id])
      dbf_doc = Document.find(shapefile[:dbf_doc_id])
      prj_doc = Document.find(shapefile[:prj_doc_id])
      cpg_doc = shapefile[:cpg_doc_id] ?
        Document.find(shapefile[:cpg_doc_id]) : nil
    rescue ActiveRecord::RecordNotFound => e
      progress_tracker.update!(
        num_records_imported: 0,
        error_messages: e.message,
        started_at: DateTime.now,
        ended_at: DateTime.now
      )
      return
    end
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

    cpg_link = ''
    if cpg_doc.present?
      cpg_link = File.join(tmp_dir, 'shapefile.cpg')
      FileUtils.ln_s(cpg_doc.document_file.path, cpg_link)
    end

    prj = File.read(prj_doc.document_file.path)
    crs = RGeo::CoordSys::CS.create_from_wkt(prj)

    citation = citation_options[:cite_gzs] ? citation_options[:citation] : nil

    process_shape_file(
      shp_link, crs, name_field,
      shapefile[:iso_a2_field], shapefile[:iso_a3_field],
      citation, progress_tracker, projects
    )

    FileUtils.rm_f([shp_link, dbf_link, shx_link, prj_link, cpg_link])
    FileUtils.rmdir(tmp_dir)
  end

  private

  # @param project_ids [Array] the projects to clone to - does not include the
  # current project which gz is saved to.
  def self.perform_save_and_clone_to_projects(gz, project_ids, citation)
    if citation.present?
      gz.citations.build(citation.merge({ project_id: Current.project_id }))
    end
    gz.save!

    project_ids.each do |pr_id|
      g = gz.dup
      g.project_id = pr_id
      if citation.present?
        g.citations.build(citation.merge({ project_id: pr_id }))
      end
      g.save!
    end
  end

  def self.process_shape_file(
    shpfile, crs, name_field, iso_a2_field, iso_a3_field, citation,
    progress_tracker, projects
  )
    r = {
      num_records: 0,
      num_records_imported: 0,
      error_messages: nil,
    }

    # We'll need to transform from whatever CRS the shapefile is in to our WGS84
    # coordinates.
    if (crs_is_wgs84 = Vendor::Rgeo.coord_sys_is_wgs84?(crs))
      from_factory = Gis::FACTORY
    else
      from_proj4 = RGeo::CoordSys::Proj4.create(crs.to_s)
      from_factory = from_proj4.projected? ?
        # Shapefiles using a projected CRS always store their geometries using
        # projected coordinates.
        RGeo::Geographic.projected_factory(
          coord_sys: from_proj4, has_z_coordinate: true
        ).projection_factory :
        RGeo::Geographic.spherical_factory( # geographic? true
          coord_sys: from_proj4, has_z_coordinate: true
        )

      to_proj4 = Gis::FACTORY.coord_sys
      to_factory = Gis::FACTORY
    end

    begin
      file = RGeo::Shapefile::Reader.open(
        shpfile, factory: from_factory, allow_unsafe: true
      )
    rescue Errno::ENOENT => e
      progress_tracker.update!(
        num_records_imported: 0,
        error_messages: e.message,
        started_at: DateTime.now,
        ended_at: DateTime.now
      )
      return
    end

    r[:num_records] = file.num_records

    progress_tracker.update!(
      num_records: file.num_records,
      project_names: Project.where(id: projects).pluck(:name).join(', '),
      started_at: DateTime.now
    )

    # Iterate over an index so we can record index on error and then resume
    for i in 0...file.num_records
      begin
        # This can throw GeosError even when allow_unsafe: true
        record = file[i]

        # iso a2/a3 are optional fields, we ignore them if the shapefile
        # doesn't provide valid data.
        a2 = record[iso_a2_field]
        a3 = record[iso_a3_field]
        iso_3166_a2 = validate_iso_3166_a2(a2) ? a2: nil
        iso_3166_a3 = validate_iso_3166_a3(a3) ? a3: nil

        g = new(
          name: record[name_field],
          iso_3166_a2:,
          iso_3166_a3:
        )

        if crs_is_wgs84
          record_geometry = record.geometry
        else
          # TODO: what might this raise? Might want to cap our total number of
          # errors recorded here
          record_geometry = RGeo::CoordSys::Proj4.transform(
            from_proj4,
            record.geometry,
            to_proj4,
            to_factory
          )
        end

        shape = GeographicItem.make_valid_non_anti_meridian_crossing_shape(
          record_geometry.as_text
        )

        g.build_geographic_item(
          geography: shape
        )

        save_and_clone_to_projects(g, projects, citation)
        r[:num_records_imported] = r[:num_records_imported] + 1

        if i % 5 == 0
          progress_tracker.update!(
            num_records_imported: r[:num_records_imported]
          )
        end

      rescue RGeo::Error::InvalidGeometry => e
        process_import_error(progress_tracker, r, i + 1, e.to_s)
      rescue ActiveRecord::RecordInvalid => e
        process_import_error(progress_tracker, r, i + 1, e.to_s)
      rescue RGeo::Error::GeosError => e
        process_import_error(progress_tracker, r, i + 1, e.to_s)
      rescue ActiveRecord::StatementInvalid => e
        # In known instances this is a result of something like:
        # PG::InternalError:
        #   ERROR:  lwgeom_intersection_prec: GEOS Error: TopologyException:
        #   Input geom 0 is invalid: Self-intersection at 185 5 0
        # !! Any containing transaction (from running in a spec e.g.) is now
        # aborted and open, any attempts to interact with the db will now raise
        # PG::InFailedSqlTransaction: ERROR:  current transaction is aborted,
        #   commands ignored until end of transaction block
        process_import_error(progress_tracker, r, i + 1, e.to_s)
      end
    end

    progress_tracker.update!(
      num_records_imported: r[:num_records_imported],
      ended_at: DateTime.now
    )
  end

  def self.process_import_error(
    progress_tracker, recorder, error_index, error_message
  )
    m = "#{error_index}: '#{error_message}'"
    recorder[:error_messages] = recorder[:error_messages].present? ?
      "#{recorder[:error_messages]}; #{m}" : m

    progress_tracker.update!(
      error_messages: recorder[:error_messages]
    )
  end

  def iso_3166_a2_is_two_characters
    errors.add(:iso_3166_a2, 'must be exactly two characters') unless
      iso_3166_a2.nil? || self.class.validate_iso_3166_a2(iso_3166_a2)
  end

  def iso_3166_a3_is_three_characters
    errors.add(:iso_3166_a3, 'must be exactly three characters') unless
      iso_3166_a3.nil? || self.class.validate_iso_3166_a3(iso_3166_a3)
  end

  def destroy_geographic_item_if_orphaned
    if geographic_item.gazetteers.count == 0
      geographic_item.destroy!
    end
  end
end
