module Export::Project
  
  # Restorable with psql -U :username -d :database -f dump.sql. Requires database to be created without tables (rails db:create)
  def self.generate_dump(project, path)
    config = ActiveRecord::Base.connection_config

    args = [
      ['-h', config[:host]],
      ['-s', config[:database]],
      ['-U', config[:username]],
      ['-p', config[:port]]
    ].reject! { |(a, v)| v.nil? }.flatten!

    # Retrieve schema
    schema = Open3.capture3({'PGPASSWORD' => config[:password]}, 'pg_dump', '-w', '-O', *args).first

    # Open gap to insert COPY statements (between tables creation and contraints & indices setup)
    split_point = schema.index(/ALTER\s+TABLE/)
    schema_head, schema_tail = schema[0..split_point-1], schema[split_point..-1]

    tables = (ActiveRecord::Base.connection.tables - ['spatial_ref_sys', 'project']).sort
    
    File.open(File.join(path, 'dump.sql'), 'wb') do |file|
      file.puts schema_head
      tables.each { |t| dump_table(t, file, project.id) }
      file.puts schema_tail
    end
  end

  private

  def self.dump_table(table, io, project_id)
    conn = ActiveRecord::Base.connection.raw_connection
    cols = ActiveRecord::Base.connection.columns(table).map { |c| "\"#{c.name}\"" }

    if cols.include?('"project_id"')
      where_clause = "WHERE project_id = #{project_id}"
    elsif table == 'projects'
      where_clause = "WHERE id = #{project_id}"
    else
      where_clause = ''
    end
    
    io.puts("COPY public.#{table} (#{cols.join(', ')}) FROM stdin;")

    # TODO: Consider "WITH CSV HEADER" if dumping to a set of CSV files gets implemented
    conn.copy_data("COPY (SELECT #{cols.join(', ')} FROM #{table} #{where_clause}) TO STDOUT") do
      while row = conn.get_copy_data
        io.write(row)
      end
    end

    io.puts('\.')
    io.puts
  end
end
