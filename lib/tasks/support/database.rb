module Support
  module Database

    def self.pg_dump(database_name, table_name, data_directory)
      a = `pg_dump -Fc -t #{table_name} -a #{database_name} > #{data_directory}/#{table_name}.dump`
      a
    end

    # For example:
    #   pg_restore -Fc -d taxonworks_development -t geographic_area_types ~/src/gaz/data/internal/dump/geographic_area_types.dump
    def self.pg_restore(database_name, table_name, data_directory)
      a = `pg_restore -Fc -d #{database_name} -t #{table_name} #{data_directory}/#{table_name}.dump`
      a
    end

  end
end
