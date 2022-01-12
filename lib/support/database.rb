module Support
  module Database
    # Extracts DB settings to be used for pg_dump, pg_restore and psql.
    def self.pg_env_args(database_arg = '-d')
      config = ActiveRecord::Base.connection_config

      {
        env: {
          'PGPASSWORD' => config[:password]
        },
        args: [
          [database_arg, config[:database]],
          ['-h', config[:host]],
          ['-U', config[:username]],
          ['-p', config[:port]&.to_s]
        ].reject { |(a, v)| v.nil? }.flatten!
      }
    end

    # Dump a specific table from a database.
    def self.pg_dump(table_name, data_directory, dump_filename = nil)
      config = pg_env_args('-a')
      dump_filename ||= "/#{table_name}.dump"

      system(config[:env], 'pg_dump', '-Fc', '-t', table_name, *config[:args], '-f', File.join(data_directory, dump_filename))

      $?.to_i
    end

    # For example:
    #   pg_restore -Fc -d taxonworks_development -t geographic_area_types ~/src/gaz/data/internal/dump/geographic_area_types.dump
    def self.pg_restore(table_name, data_directory, dump_filename = nil)
      config = pg_env_args
      dump_filename ||= "/#{table_name}.dump"

      system(config[:env], 'pg_restore', '-Fc', '-t', table_name, *config[:args], File.join(data_directory, dump_filename))

      $?.to_i
    end

    def self.pg_dump_all(data_directory, dump_filename)
      config = pg_env_args('-a')
      dump_filename ||= "/#{table_name}.dump"

      system(config[:env], 'pg_dump', '-Fc', *config[:args], '-f', File.join(data_directory, dump_filename))

      $?.to_i
    end

    def self.pg_restore_all(data_directory, dump_filename)
      config = pg_env_args
      dump_filename ||= "/#{table_name}.dump"

      system(config[:env], 'pg_restore', '-Fc', *config[:args], File.join(data_directory, dump_filename))

      $?.to_i
    end

    # This doesn't actually say if the database exists or not!
    #   Try it, load a console, drop the database in another terminal, and call this method.
    def self.pg_database_exists?
      begin
        ApplicationRecord.connection
        # ApplicationRecord.connection.disconnect!
       rescue ActiveRecord::NoDatabaseError
         false
       else
         true
      end
    end

  end
end
