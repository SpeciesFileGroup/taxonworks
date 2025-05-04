require_dependency Rails.root.to_s + '/lib/vendor/rgeo.rb'

module Lib::Vendor::RgeoShapefileHelper
  # Raises TaxonWorks::Error on error.
  def addShapefileImportJobToQueue(
    shapefile, citation, projects, project_id, user_id
  )
    shapefile_docs = validate_shape_file(shapefile, project_id)

    if citation[:cite_gzs] && !citation[:citation]&.dig(:source_id)
      raise TaxonWorks::Error, 'No citation source selected'
    end

    complete_shapefile = shapefile
    # shp_doc_id was required, the following may have been determined instead
    # during validation.
    complete_shapefile[:shx_doc_id] = shapefile_docs[:shx].id
    complete_shapefile[:dbf_doc_id] = shapefile_docs[:dbf].id
    complete_shapefile[:prj_doc_id] = shapefile_docs[:prj].id
    complete_shapefile[:cpg_doc_id] = shapefile_docs[:cpg]&.id

    progress_tracker = GazetteerImport.create!(
      shapefile: shapefile_docs[:shp].document_file_file_name
    )

    ImportGazetteersJob.perform_later(
      complete_shapefile,
      citation,
      user_id, project_id,
      progress_tracker,
      projects
    )
  end

  # @return [Hash of Documents] Raises TaxonWorks::Error on error.
  def fetch_shapefile_documents(shapefile, project_id)
    begin
      docs = {
        shp: shapefile[:shp_doc_id] ? Document.find(shapefile[:shp_doc_id]) : nil,
        shx: shapefile[:shx_doc_id] ? Document.find(shapefile[:shx_doc_id]) : nil,
        dbf: shapefile[:dbf_doc_id] ? Document.find(shapefile[:dbf_doc_id]) : nil,
        prj: shapefile[:prj_doc_id] ? Document.find(shapefile[:prj_doc_id]) : nil,
        cpg: shapefile[:cpg_doc_id] ? Document.find(shapefile[:cpg_doc_id]) : nil
      }
    rescue ActiveRecord::RecordNotFound => e
      raise TaxonWorks::Error, e
    end

    raise TaxonWorks::Error, 'A .shp file is required' if docs[:shp].nil?

    base = basename(docs[:shp].document_file_file_name)

    docs.each do |ext, doc|
      if !doc
        docs[ext] = find_doc_for_extension(base, ext, project_id)
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

  # @return [Hash] of shapefile ext => Document.
  # Raises TaxonWorks::Error on error.
  def validate_shape_file(shapefile, project_id)
    if shapefile[:name_field].nil?
      raise TaxonWorks::Error, 'Name field is required'
    end
    name_field = shapefile[:name_field]

    docs = fetch_shapefile_documents(shapefile, project_id)

    # Check that we can transform from the input CRS to our WGS84 CRS
    prj = File.read(docs[:prj].document_file.path)
    begin
      cs = RGeo::CoordSys::CS.create_from_wkt(prj)
    rescue RGeo::Error::ParseError => e
      raise TaxonWorks::Error, "Failed to parse the prj file: #{e}"
    end

    if !cs.geographic? && !cs.projected?
      raise TaxonWorks::Error, '.prj must be either geographic or projected'
    end

    if !Vendor::Rgeo.coord_sys_is_wgs84?(cs)
      # Make sure we can create a proj4 for the source CRS, it's needed for
      # transforming coordinates.
      begin
        RGeo::CoordSys::Proj4.create(cs.to_s)
      rescue RGeo::Error::InvalidProjection => e
        raise TaxonWorks::Error, "Invalid prj file? #{e}"
      end
    end

    # Check that each record has a name.
    dbf = ::DBF::Table.new(docs[:dbf].document_file.path)
    if dbf.record_count == 0
      raise TaxonWorks::Error, 'Empty dbf file: shapefile must contain records'
    end

    if !dbf.column_names.include?(name_field)
      raise TaxonWorks::Error, "No column named '#{name_field}'"
    end

    rv = dbf_column_type_is_string(dbf, name_field)
    if rv != true
      raise TaxonWorks::Error, "Name error: column '#{name_field}' for Gazetteer names should be a string field, not '#{rv}'"
    end

    for i in 0...dbf.record_count
      record = dbf.find(i)
      if Utilities::Rails::Strings.nil_squish_strip(record[name_field]).nil?
        raise TaxonWorks::Error, "Record #{i} has no name - names are required for all records"
      end
    end

    # Check that iso a2/a3 fields, if provided, exist and are of type String
    iso_a2_field = shapefile[:iso_a2_field]
    if iso_a2_field.present?
      if !dbf.column_names.include?(iso_a2_field)
        raise TaxonWorks::Error, "No column named '#{iso_a2_field}'"
      end

      rv = dbf_column_type_is_string(dbf, iso_a2_field)
      if rv != true
        raise TaxonWorks::Error, "Iso_3166_a2 error: column '#{iso_a2_field}' for a2 values should be a string field, not '#{rv}'"
      end
    end

    iso_a3_field = shapefile[:iso_a3_field]
    if iso_a3_field.present?
      if !dbf.column_names.include?(iso_a3_field)
        raise TaxonWorks::Error, "No column named '#{iso_a3_field}'"
      end

      rv = dbf_column_type_is_string(dbf, iso_a3_field)
      if rv != true
        raise TaxonWorks::Error, "Iso_3166_a3 error: column '#{iso_a3_field}' for a3 values should be a string field, not '#{rv}'"
      end
    end

    if iso_a2_field.present? && iso_a3_field.present? &&
       iso_a2_field == iso_a3_field
      raise TaxonWorks::Error, "Iso_3166_a2 column can't be the same as Iso_3166_a3 column"
    end

    # Check that the cpg encoding is recognized - strings can get returned
    # encoded as binary if failure here is allowed.
    #  cf. https://github.com/rgeo/rgeo-shapefile/blob/d278da0b613425d64e3792497ac9cf474eec6e53/lib/rgeo/shapefile/reader.rb#L194-L198
    if docs[:cpg].present?
      begin
        encoding = nil
        File.open(docs[:cpg].document_file.path, 'r') do |cpg|
          encoding = cpg.read
        end
        Encoding.find(encoding.strip)
      rescue Errno::ENOENT => e
        raise TaxonWorks::Error,
          "Failed to open .cpg document '#{docs[:cpg].id}'"
      rescue ArgumentError => e # Unrecognized encoding
        raise TaxonWorks::Error,
          "'#{e}' from .cpg document '#{docs[:cpg].id}'"
      end
    end

    docs
  end

  # @return true if true, else return actual column type as a string
  # Assumes the column_name is a valid dbf column name
  def dbf_column_type_is_string(dbf, column_name)
    column = dbf.columns.find { |c| c.name == column_name }
    column.type == 'C' ? # 'C' is for 'C'haracter
      true : DBF::Column::TYPE_CAST_CLASS[column.type.to_sym].to_s
  end

  # Raises Taxonworks::Error on error
  def fields_from_shapefile(shp_doc_id, dbf_doc_id, project_id)
    dbf_doc = get_dbf_doc(shp_doc_id, dbf_doc_id, project_id)

    dbf = ::DBF::Table.new(dbf_doc.document_file.path)

    dbf.column_names
  end

  # Raises TaxonWorks::Error on error.
  def validate_and_fetch_shapefile_text_field_values(shapefile, project_id)
    shapefile_docs = validate_shape_file(shapefile, project_id)

    text_fields_hash = { # order here is significant
      record_number: '', # a computed field, see values_from_shapefile below
      name: shapefile[:name_field],
      count: '', # a computed field
      a2: shapefile[:iso_a2_field],
      a3: shapefile[:iso_a3_field]
    }.delete_if { |k,v| k != :record_number && k != :count && v.blank? }
    text_fields = text_fields_hash.values
    max_values_count = 1000

    records_count, shapefile_text_values = text_field_values_from_shapefile(
        shapefile_docs[:dbf], text_fields, max_values_count
      )

    {
      text_fields_hash:,
      text_values: shapefile_text_values,
      records_count:,
      max_values_count:
    }
  end

  # Raises Taxonworks::Error on error
  # !! Assumes the second text_field is a name field, and the third field should
  # be filled in with the # of records with that name. !!
  # !! The counts are restricted to the first max_records, so may not be
  # accurate if there are more records than that. !!
  def text_field_values_from_shapefile(dbf_doc, text_fields, max_records)
    dbf = ::DBF::Table.new(dbf_doc.document_file.path)
    record_count = dbf.count
    text_fields_count = text_fields.count
    counts = {}
    record_number = 1
    text_values = dbf.take(max_records).map do |r|
      a = Array.new(text_fields_count)
      text_fields.each_with_index do |k, i|
        case i
        when 0
          a[i] = record_number
        when 1 # Name field
          w = r[k]
          a[i] = w
          if counts[w]
            counts[w] += 1
          else
            counts[w] = 1
          end
        when 2 # Name count
          a[i] = 0 # temporary, actual count updated below
        else # a2 and/or a3
          a[i] = r[k]
        end
      end
      record_number += 1
      a
    end

    text_values.each { |a| a[2] = counts[a[1]]}

    return record_count, text_values
  end

  # Raises Taxonworks::Error on error
  def get_dbf_doc(shp_doc_id, dbf_doc_id, project_id)
    if !shp_doc_id && !dbf_doc_id
      raise TaxonWorks::Error, '.shp or .dbf required to read shapefile fields'
    end

    dbf_doc = nil
    if dbf_doc_id
      dbf_doc = Document.find(dbf_doc_id)
    else
      shp_doc = Document.find(shp_doc_id)
      base = basename(shp_doc.document_file_file_name)
      dbf_doc = find_doc_for_extension(base, :dbf, project_id)
    end

    if dbf_doc.nil?
      raise TaxonWorks::Error, 'failed to find dbf shapefile document!' if dbf_doc.nil?
    end

    dbf_doc
  end

  # Raises TaxonWorks::Error on error
  def find_doc_for_extension(base, ext, project_id)
    ext = ext.to_s
    ext_filename = base + '.' + ext
    ext_docs = Document.where(
      document_file_file_name: ext_filename,
      project_id:
    )

    if ext_docs.count == 0
      return nil if ext == 'cpg' # cpg isn't required

      raise TaxonWorks::Error, "Failed to find a '#{ext_filename}' document, has one been uploaded?"
    elsif ext_docs.count > 1
      ids = ext_docs.map { |d| d.id }
      # (This makes cpg required when there are multiple matching)
      raise TaxonWorks::Error, "More than one '#{ext_filename}' document exists (ids #{ids.join(',')}), please add the correct one in the document selector"
    end

    # exactly one matching document
    ext_docs.first
  end

end