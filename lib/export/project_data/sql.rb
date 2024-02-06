module ::Export::ProjectData::Sql

  # Restorable with psql -U :username -d :database -f dump.sql. Requires database to be created without tables (rails db:create)
  def self.generate_dump(project, file)
    config = ActiveRecord::Base.connection_db_config.configuration_hash

    args = [
      ['-h', config[:host]],
      ['-s', config[:database]],
      ['-U', config[:username]],
      ['-p', config[:port]]
    ].reject! { |(a, v)| v.nil? }.flatten!

    # Retrieve schema
    schema = Open3.capture3({'PGPASSWORD' => config[:password]}, 'pg_dump', '-w', '-O', *args).first

    # Open gap to insert COPY statements (between tables creation and contraints & indices setup)
    split_point = schema.index(/\n(--[^\n]*\n)*\s*ALTER\s+TABLE/)
    schema_head, schema_tail = schema[0..split_point-1], schema[split_point..-1]

    tables = (ActiveRecord::Base.connection.tables - Export::ProjectData::SPECIAL_TABLES - Export::ProjectData::HIERARCHIES.map(&:first)).sort

    file.puts schema_head
    file.write "\n-- DATA RESTORE\n\n"
    export_users(file, project)
    tables.each { |t| dump_table(t, file, project.id) }
    tables.each { |t| setup_pk_sequence(t, file) if get_table_cols(t).include?('"id"') }
    Export::ProjectData::HIERARCHIES.each { |p| dump_hierarchy_table(p, file, project.id) }
    file.puts schema_tail
  end

  # @return String
  #   path to zipfile
  def self.export(project)
    zip_file_path = "/tmp/_#{SecureRandom.hex(8)}_dump.sql"

    Zip::File.open(zip_file_path, Zip::File::CREATE) do |zipfile|
      Tempfile.create(encoding: 'UTF-8') do |tempfile|
        generate_dump(project, tempfile)
        tempfile.flush
        tempfile.rewind

        # Needs rescoping if this is a Tempfile
        # zipfile.add('dump.sql', tempfile.path)
        #
        # Dumps are very large, read them in blocks.
        zipfile.get_output_stream('dump.sql') { |f| f.write(tempfile.read(1024)) until tempfile.eof? }
      end
    end
    zip_file_path
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
  #   everything except source_file_path
  def self.stub_download(target_project)
    Download::ProjectDump::Sql.create!(
      name: "#{target_project.name} export on #{Time.now}.",
      description: 'A zip file containing SQL dump of community data + project-specific data',
      filename: Zaru::sanitize!("#{target_project.name}.zip").gsub(' ', '_').downcase,
      expires: 2.days.from_now,
      is_public: false
    )
  end

  # @return Download
  def self.download_async(target_project)
    d = stub_download(target_project)
    DownloadProjectSqlJob.perform_later(target_project, d)
    d
  end

  def self.setup_pk_sequence(table, io)
    io.write("SELECT setval('public.#{table}_id_seq', (SELECT COALESCE(MAX(id), 0)+1 FROM public.#{table}));\n\n")
  end

  def self.get_connection
    ActiveRecord::Base.connection.raw_connection
  end

  def self.get_table_cols(table)
    ActiveRecord::Base.connection.columns(table).map { |c| "\"#{c.name}\"" }
  end

  def self.dump_table(table, io, project_id)
    cols = get_table_cols(table)
    if cols.include?('"project_id"')
      where_clause = "WHERE project_id IN (#{project_id}, NULL)"
    elsif table == 'projects'
      where_clause = "WHERE id = #{project_id}"
    else
      where_clause = ''
    end

    copy_table(table, io, cols, "SELECT #{cols.join(', ')} FROM #{table} #{where_clause}")
  end

  def self.dump_hierarchy_table(table_pair, io, project_id)
    cols_model = get_table_cols(table_pair.second)

    return dump_table(table_pair.first, io, project_id) unless cols_model.include?('"project_id"')

    cols_hierarchy = get_table_cols(table_pair.first)
    select_query = "SELECT DISTINCT #{cols_hierarchy.map { |c| "#{table_pair.first}.#{c}" }.join(', ')} "\
                   "FROM #{table_pair.second} INNER JOIN "\
                       "#{table_pair.first} ON #{table_pair.second}.id IN ("\
                         "#{table_pair.first}.ancestor_id, #{table_pair.first}.descendant_id"\
                       ') '\
                   "WHERE project_id = #{project_id}"
    copy_table(table_pair.first, io, cols_hierarchy, select_query)
  end

  def self.copy_table(table, io, cols, select_query)
    conn = get_connection

    io.puts("COPY public.#{table} (#{cols.join(', ')}) FROM stdin WITH (ENCODING 'UTF8');")

    # TODO: Consider "WITH CSV HEADER" if dumping to a set of CSV files gets implemented
    conn.copy_data("COPY (#{select_query}) TO STDOUT WITH (ENCODING 'UTF8')") do
      while row = conn.get_copy_data
        io.write(row.force_encoding('UTF-8'))
      end
    end

    io.puts('\.')
    io.puts
  end

  def self.export_users(io, project)
    members = project.project_members.pluck(:user_id)
    conn = get_connection

    User.all.find_each do |user|
      attributes = {
        id: user.id,
        password_digest: "'#{conn.escape_string(User.new(password: 'taxonworks').password_digest)}'",
        created_at: "'#{user.created_at}'",
        updated_at: "'#{user.updated_at}'",
        created_by_id: user.created_by_id || 'NULL',
        updated_by_id: user.updated_by_id || 'NULL',
        is_administrator: user.is_administrator || 'NULL',
        hub_tab_order: "'{#{conn.escape_string(user.hub_tab_order.join(','))}}'"
      }.merge!(
        if members.include?(user.id)
          {
            email: "'#{conn.escape_string(user.email)}'",
            name: "'#{conn.escape_string(user.name)}'"
          }
        else
          {
            email: "'unknown_#{user.id}@example.com'",
            name: "'User outside project (#{user.id})'"
          }
        end
      )
      io.puts("INSERT INTO public.users(#{attributes.keys.join(', ')})\nVALUES (#{attributes.values.join(', ')});")
    end
    io.puts
    setup_pk_sequence('users', io)
  end
end
