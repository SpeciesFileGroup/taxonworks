module Lib::Vendor::RgeoShapefileHelper
  # @return [true or String] Returns true on success, otherwise returns an error
  # string
  def validate_shape_file(shapefile)
    if shapefile[:name_field].nil?
      return 'Name field is required'
    end
    name_field = shapefile[:name_field]

    begin
      _shp_doc = Document.find(shapefile[:shp_doc_id])
      _shx_doc = Document.find(shapefile[:shx_doc_id])
      dbf_doc = Document.find(shapefile[:dbf_doc_id])
      prj_doc = Document.find(shapefile[:prj_doc_id])
    rescue ActiveRecord::RecordNotFound => e
      return e
    end

    # Check that the CRS is geographic and WGS 84
    prj = File.read(prj_doc.document_file.path)
    begin
      cs = RGeo::CoordSys::CS.create_from_wkt(prj)
    rescue RGeo::Error::ParseError => e
      return "Failed to parse the prj file: #{e}"
    end

    if cs.class.to_s != 'RGeo::CoordSys::CS::GeographicCoordinateSystem' ||
      (cs.name.present? && cs.name != 'GCS_WGS_1984') ||
      (cs.authority_code.present? && cs.authority_code != '4326')

      return "The reference system of the shapefile is '#{cs.name}', but only GCS_WGS_1984 is supported"
    end

    # Check that each record has a name.
    dbf = ::DBF::Table.new(dbf_doc.document_file.path)
    if dbf.record_count == 0
      return 'Empty dbf file: shapefile must contain records'
    end

    if !dbf.column_names.include?(name_field)
      return "No column named '#{name_field}'"
    end

    if dbf.find(0)[name_field].class.to_s != 'String'
      return "Column #{name_field} is of type #{dbf.find(0)[name_field].class}, should be String"
    end

    for i in 0...dbf.record_count
      record = dbf.find(i)
      if record[name_field].nil? || record[name_field] == ''
        return "Record #{i} has no name - names are required for all records"
      end
    end

    true
  end

  # Raises Taxonworks::Error on error
  def fields_from_shapefile(dbf_doc_id)
    begin
      dbf_doc = Document.find(dbf_doc_id)
    rescue ActiveRecord::RecordNotFound => e
      raise TaxonWorks::Error, e
    end

    dbf = ::DBF::Table.new(dbf_doc.document_file.path)

    dbf.column_names
  end

end