module Support
  module Database

    # Dump a specific table from a database.
    def self.pg_dump(database_name, table_name, data_directory, dump_filename = nil)
      dump_filename ||= "/#{table_name}.dump"
      `pg_dump -Fc -t #{table_name} -a #{database_name} -f #{File.join(data_directory, dump_filename)}`
      $?.to_i
    end

    # For example:
    #   pg_restore -Fc -d taxonworks_development -t geographic_area_types ~/src/gaz/data/internal/dump/geographic_area_types.dump
    def self.pg_restore(database_name, table_name, data_directory, dump_filename = nil)
      dump_filename ||= "/#{table_name}.dump"
      `pg_restore -Fc -d #{database_name} -t #{table_name} #{File.join(data_directory, dump_filename)}`
      $?.to_i
    end

    def self.pg_dump_all(database_name, data_directory, dump_filename)
      `pg_dump -Fc -a #{database_name} -f #{File.join(data_directory, dump_filename)}`
      $?.to_i
    end

    def self.pg_restore_all(database_name, data_directory, dump_filename)
      `pg_restore -Fc -d #{database_name} #{File.join(data_directory, dump_filename)}`
      $?.to_i
    end

    # This doesn't actually say if the database exists or not!  
    #   Try it, load a console, drop the database in another terminal, and call this method.
    def self.pg_database_exists?
      begin
        ActiveRecord::Base.connection
       # ActiveRecord::Base.connection.disconnect!
      rescue ActiveRecord::NoDatabaseError
        false
      else
        true
      end
    end

  end
end
