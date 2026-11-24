module Support
  module Database

    # @return [Hash]
    #   the primary database configuration for the current environment (symbol keys).
    #   database.yml is multi-database (primary, solid), so read configs by name,
    #   never as database_configuration[Rails.env].
    def self.primary_config
      ActiveRecord::Base.configurations.configs_for(env_name: Rails.env, name: 'primary').configuration_hash
    end

    # @return [Hash, nil]
    #   the solid (Solid Cache, Solid Cable) database configuration for the current environment (symbol keys)
    def self.solid_config
      ActiveRecord::Base.configurations.configs_for(env_name: Rails.env, name: 'solid')&.configuration_hash
    end

    # Guards against the solid database being (mis)configured as the primary database,
    # e.g. POSTGRES_SOLID_DB set to the primary's database name. Solid tables would then
    # be migrated into, dumped with, and dropped with TaxonWorks data. Checked at boot,
    # see config/initializers/solid_database.rb.
    #
    # @param primary [Hash] a database configuration_hash
    # @param solid [Hash, nil] a database configuration_hash
    # @return [true]
    # @raise [TaxonWorks::Error] if solid is missing or is the primary database
    def self.assert_solid_separate!(primary, solid)
      raise TaxonWorks::Error, "No 'solid' database is configured, see config/database.yml.example" if solid.nil?

      if database_identity(primary) == database_identity(solid)
        raise TaxonWorks::Error, "The 'solid' database must not be the primary database (#{solid[:database]}), see config/database.yml.example"
      end

      true
    end

    # @return [Array]
    #   what makes a configuration the same physical database, with server defaults applied
    def self.database_identity(config)
      if config[:adapter].to_s.start_with?('sqlite')
        [:sqlite, config[:database].to_s]
      else
        host = config[:host].presence || 'localhost'
        host = 'localhost' if %w{127.0.0.1 ::1}.include?(host)
        [:postgresql, host, (config[:port].presence || 5432).to_i, config[:database].to_s]
      end
    end
    private_class_method :database_identity

    # Extracts DB settings to be used for pg_dump, pg_restore and psql.
    def self.pg_env_args(database_arg = '-d')
      config = ActiveRecord::Base.connection_db_config.configuration_hash

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
