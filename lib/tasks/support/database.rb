module Support
  module Database

    def self.pg_dump(database_name, table_name, data_directory)
      a = `pg_dump -Fc -t #{table_name} -a #{database_name} > #{data_directory}/#{table_name}.dump`
      a
    end

    def self.pg_restore(database_name, table_name, data_directory)
=begin
  # For example:
  pg_restore -Fc -d taxonworks_development -t geographic_area_types ~/src/gaz/data/internal/dump/geographic_area_types.dump
  pg_restore -Fc -d taxonworks_development -t geographic_areas ~/src/gaz/data/internal/dump/geographic_areas.dump
  pg_restore -Fc -d taxonworks_development -t geographic_items ~/src/gaz/data/internal/dump/geographic_items.dump
  pg_restore -Fc -d taxonworks_development -t geographic_areas_geographic_items ~/src/gaz/data/internal/dump/geographic_areas_geographic_items.dump
=end
      a = `pg_restore -Fc -d #{database_name} -t #{table_name} #{data_directory}/#{table_name}.dump`
      a
    end

  end
end
