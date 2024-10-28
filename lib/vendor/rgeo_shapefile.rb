module Vendor::RgeoShapefile
  def self.import_gzs_from_shapefile(
    shapefile, citation_options, progress_tracker, projects
  )
    begin
      shp_doc = Document.find(shapefile[:shp_doc_id])
      shx_doc = Document.find(shapefile[:shx_doc_id])
      dbf_doc = Document.find(shapefile[:dbf_doc_id])
      prj_doc = Document.find(shapefile[:prj_doc_id])
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

    citation = citation_options[:cite_gzs] ? citation_options[:citation] : nil

    process_shape_file(
      shp_link, name_field, shapefile[:iso_a2_field], shapefile[:iso_a3_field],
      citation, progress_tracker, projects
    )

    FileUtils.rm_f([shp_link, dbf_link, shx_link, prj_link])
    FileUtils.rmdir(tmp_dir)
  end

  def self.process_shape_file(
    shpfile, name_field, iso_a2_field, iso_a3_field, citation,
    progress_tracker, projects
  )
    r = {
      num_records: 0,
      num_records_imported: 0,
      error_messages: nil,
    }

    begin
      file = RGeo::Shapefile::Reader.open(
        shpfile, factory: Gis::FACTORY, allow_unsafe: true
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
        iso_3166_a2 = Gazetteer.validate_iso_3166_a2(a2) ? a2: nil
        iso_3166_a3 = Gazetteer.validate_iso_3166_a3(a3) ? a3: nil

        g = Gazetteer.new(
          name: record[name_field],
          iso_3166_a2:,
          iso_3166_a3:
        )

        shape = record.geometry

        # See anti_meridian_spec.rb for the reasoning behind (provisionally)
        # putting the anti_meridian check before the make_valid call.
        if GeographicItem.crosses_anti_meridian?(shape.as_text)
          # If this shape crosses the anti_meridian and then raises on
          # split_along_anti_meridian because it's invalid then we give up.
          shape = GeographicItem.split_along_anti_meridian(shape.as_text)
        end

        # TODO remove lower-dimensional geometries introduced by make_valid
        # (maybe use ST_MakeValid which has an option to do this)
        shape = shape.make_valid if !shape.valid?

        g.build_geographic_item(
          geography: shape
        )

        Gazetteer.clone_to_projects(g, projects, citation)
        r[:num_records_imported] = r[:num_records_imported] + 1

        if i % 5 == 0
          progress_tracker.update!(
            num_records_imported: r[:num_records_imported]
          )
        end

      rescue RGeo::Error::InvalidGeometry => e
        process_error(progress_tracker, r, i + 1, e.to_s)
      rescue ActiveRecord::RecordInvalid => e
        process_error(progress_tracker, r, i + 1, e.to_s)
      rescue RGeo::Error::GeosError => e
        process_error(progress_tracker, r, i + 1, e.to_s)
      rescue ActiveRecord::StatementInvalid => e
        process_error(progress_tracker, r, i + 1, e.to_s)
      end
    end

    progress_tracker.update!(
      num_records_imported: r[:num_records_imported],
      ended_at: DateTime.now
    )
  end

  def self.process_error(progress_tracker, recorder, error_index, error_message)
    m = "#{error_index}: '#{error_message}'"
    recorder[:error_messages] = recorder[:error_messages].present? ?
      "#{recorder[:error_messages]}; #{m}" : m

    progress_tracker.update!(
      error_messages: recorder[:error_messages]
    )
  end
end
