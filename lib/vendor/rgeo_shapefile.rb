module Vendor::RgeoShapefile
  def self.import_gzs_from_shapefile(
    shapefile, citation_options, progress_tracker
  )
    begin
      shp_doc = Document.find(shapefile[:shp_doc_id])
      shx_doc = Document.find(shapefile[:shx_doc_id])
      dbf_doc = Document.find(shapefile[:dbf_doc_id])
      prj_doc = Document.find(shapefile[:prj_doc_id])
    rescue ActiveRecord::RecordNotFound => e
      progress_tracker.update!(
        num_records_processed: 0,
        aborted_reason: e.message,
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

    processShapeFile(shp_link, name_field, citation, progress_tracker)

    FileUtils.rm_f([shp_link, dbf_link, shx_link, prj_link])
    FileUtils.rmdir(tmp_dir)
  end

  def self.processShapeFile(shpfile, name_field, citation, progress_tracker)
    r = {
      num_records: 0,
      error_id: nil,
      error_message: nil,
    }

    begin
      file = RGeo::Shapefile::Reader.open(
        shpfile, factory: Gis::FACTORY, allow_unsafe: true
      )
    rescue Errno::ENOENT => e
      progress_tracker.update!(
        num_records_processed: 0,
        aborted_reason: e.message,
        started_at: DateTime.now,
        ended_at: DateTime.now
      )
      return
    end

    r[:num_records] = file.num_records

    progress_tracker.update!(
      num_records: file.num_records,
      started_at: DateTime.now
    )
    begin
      Gazetteer.transaction do
        # Iterate over an index so we can record index on error
        for i in 0...file.num_records
          begin
            # This can throw GeosError even when allow_unsafe: true
            record = file[i]

            g = Gazetteer.new(
              name: record[name_field]
            )

            # Abort if too many invalid?
            # TODO Track how many were invalid and were made valid?
            shape = record.geometry.valid? ?
              record.geometry : record.geometry.make_valid

            g.build_geographic_item(
              geography: shape
            )

            g.save!

            if citation.present?
              Citation.create!(citation.merge({
                citation_object_type: 'Gazetteer',
                citation_object_id: g.id
              }))
            end
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
      progress_tracker.update!(
        num_records_processed: r[:error_id] - 1,
        aborted_reason: m,
        ended_at: DateTime.now
      )
      return
    end

    progress_tracker.update!(
      num_records_processed: r[:num_records],
      ended_at: DateTime.now
    )
  end

end
