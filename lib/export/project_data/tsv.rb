# !!
# !! Only exports ApplicationEnumeration.project_data_classes
# !! See the .sql version for code that would handle Community data
# !!
module ::Export::ProjectData::Tsv

  # @return path
  #   to the zipped data in /tmp
  def self.export(project)
    zip_file_path = "/tmp/_#{SecureRandom.hex(8)}_project_tsv.zip"

    Zip::File.open(zip_file_path, Zip::File::CREATE) do |zipfile|
      ApplicationEnumeration.project_data_classes.each do |k|
        q = k.where(project_id: project.to_param)
        next if !q.any?
        copy_table(k, zipfile, q)
      end
    end
    zip_file_path
  end

  def self.copy_table(klass, zipfile, query)
    Tempfile.create do |table_file|
      query = "COPY ( #{query.to_sql} ) TO '#{table_file.path}' WITH (FORMAT CSV, DELIMITER E'\t', HEADER, ENCODING 'UTF8')"

      klass.connection.execute(query)

      table_file.flush
      table_file.rewind
      filename = Zaru::sanitize!("#{klass.name}_#{DateTime.now}.tsv")

      # ?! Does not queue the reads until the zipfile loop closes,
      # so tempfiles may dispappear before they can be read
      #
      # zipfile.add(filename, table_file.path )

      zipfile.get_output_stream(filename) { |f| f.write table_file.read }
    end
  end

  # TODO - DRY with generic params passing
  # @return Download
  #   a completely built Download, but unsaved
  def self.download(target_project)
    file_path = export(target_project)

    d = stub_download(target_project)
    d.source_file_path = file_path
    d
  end

  # @return Download
  def self.download_async(target_project)
    d = stub_download(target_project)
    DownloadProjectTsvJob.perform_later(target_project, d)
    d
  end

  # @return Download
  #   everything except source_file_path
  def self.stub_download(target_project)
    Download::ProjectDump::Tsv.create!(
       name: "#{target_project.name} export on #{Time.current}.",
       description: 'A zip file containing TSV dump of project-specific data.',
       filename: Zaru::sanitize!("#{target_project.name}_tsv.zip").gsub(' ', '_').downcase,
       expires: 2.days.from_now,
       is_public: false
     )
  end
end
