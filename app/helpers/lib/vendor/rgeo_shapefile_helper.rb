module Lib::Vendor::RgeoShapefileHelper
  # @return [Hash of Documents] Raises TaxonWorks::Error on error.
  def fetch_shapefile_documents(shapefile, project_id)
    begin
      docs = {
        shp: shapefile[:shp_doc_id] ? Document.find(shapefile[:shp_doc_id]) : nil,
        shx: shapefile[:shx_doc_id] ? Document.find(shapefile[:shx_doc_id]) : nil,
        dbf: shapefile[:dbf_doc_id] ? Document.find(shapefile[:dbf_doc_id]) : nil,
        prj: shapefile[:prj_doc_id] ? Document.find(shapefile[:prj_doc_id]) : nil
      }
    rescue ActiveRecord::RecordNotFound => e
      raise TaxonWorks::Error, e
    end

    raise TaxonWorks::Error, 'A .shp file is required' if docs[:shp].nil?

    base = basename(docs[:shp].document_file_file_name)

    docs.each do |ext, doc|
      next if ext == 'shp'
      if !doc
        ext_filename = base + '.' + ext.to_s
        ext_docs = Document.where(
          document_file_file_name: ext_filename,
          project_id:
        )

        if ext_docs.count == 0
          raise TaxonWorks::Error, "Failed to find a required '#{ext_filename}' document, has one been uploaded?"
        elsif ext_docs.count > 1
          ids = ext_docs.map { |d| d.id }
          raise TaxonWorks::Error, "More than one '#{ext_filename}' document exists (ids #{ids.join(',')}), please add the correct one in the document selector"
        else # exactly one matching document
          docs[ext] = ext_docs.first
        end
      elsif basename(doc.document_file_file_name) != base
        raise TaxonWorks::Error, ".#{ext} file must have the same name as the .shp file: '#{base}'"
      end
    end

    return docs
  end

  # Assumes an extension of the form .xyz
  def basename(filename)
    filename[0, filename.size - 4]
  end

  # @return [Hash] of shapefile ext => document_id. Raises TaxonWorks::Error on
  # error.
  def validate_shape_file(shapefile, project_id)
    if shapefile[:name_field].nil?
      raise TaxonWorks::Error, 'Name field is required'
    end
    name_field = shapefile[:name_field]

    docs = fetch_shapefile_documents(shapefile, project_id)

    # Check that the CRS is geographic and WGS 84
    prj = File.read(docs[:prj].document_file.path)
    begin
      cs = RGeo::CoordSys::CS.create_from_wkt(prj)
    rescue RGeo::Error::ParseError => e
      raise TaxonWorks::Error, "Failed to parse the prj file: #{e}"
    end

    if cs.class.to_s != 'RGeo::CoordSys::CS::GeographicCoordinateSystem' ||
      (cs.name.present? && cs.name != 'GCS_WGS_1984') ||
      (cs.authority_code.present? && cs.authority_code != '4326')

      raise TaxonWorks::Error, "The reference system of the shapefile is '#{cs.name}', but only GCS_WGS_1984 is supported"
    end

    # Check that each record has a name.
    dbf = ::DBF::Table.new(docs[:dbf].document_file.path)
    if dbf.record_count == 0
      raise TaxonWorks::Error, 'Empty dbf file: shapefile must contain records'
    end

    if !dbf.column_names.include?(name_field)
      raise TaxonWorks::Error, "No column named '#{name_field}'"
    end

    if dbf.find(0)[name_field].class.to_s != 'String'
      raise TaxonWorks::Error, "Column #{name_field} is of type #{dbf.find(0)[name_field].class}, should be String"
    end

    for i in 0...dbf.record_count
      record = dbf.find(i)
      if Utilities::Rails::Strings.nil_squish_strip(record[name_field]).nil?
        raise TaxonWorks::Error, "Record #{i} has no name - names are required for all records"
      end
    end

    docs
  end

  # Raises Taxonworks::Error on error
  def fields_from_shapefile(shp_doc_id, dbf_doc_id, project_id)
    if !shp_doc_id && !dbf_doc_id
      raise TaxonWorks::Error, '.shp or .dbf required to read shapefile fields'
    end

    if !dbf_doc_id
      shp_doc = Document.find(shp_doc_id)
      base = basename(shp_doc.document_file_file_name)
      dbf_docs = Document.where(
          document_file_file_name: base + '.dbf',
          project_id:
        )
      if dbf_docs.size == 0
        raise TaxonWorks::Error, "No '#{base}.dbf' document found, has one been uploaded?"
      elsif dbf_docs.size > 1
        ids = dbf_docs.map { |d| d.id }
        raise TaxonWorks::Error, "Multiple '#{base}.dbf' documents found (ids: #{ids.join(',')}), specify one in the document selector"
      else
        dbf_doc_id = dbf_docs.first.id
      end
    end

    dbf_doc = Document.find(dbf_doc_id)
    dbf = ::DBF::Table.new(dbf_doc.document_file.path)

    dbf.column_names
  end

end