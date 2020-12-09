namespace :tw do
  namespace :initialize do

    desc 'load all geo related data, requires a data_directory'
    task load_geo: [:environment, :data_directory] do |t|

      puts 'Loading geo data...'
      [GeographicArea, GeographicAreaType, GeographicItem, GeographicAreasGeographicItem].each do |klass|
        if klass.count > 0
          puts "There are existing #{klass.name.humanize}, doing nothing.".red.on_white
          raise
        end
      end

      data_store = @args[:data_directory]
      data_store += '/' unless data_store.end_with?('/')

      geographic_areas_file                  = "#{data_store}geographic_areas.dump"
      geographic_area_types_file             = "#{data_store}geographic_area_types.dump"
      geographic_items_file                  = "#{data_store}geographic_items.dump"
      geographic_areas_geographic_items_file = "#{data_store}geographic_areas_geographic_items.dump"

      raise "Missing #{geographic_areas_file}, doing nothing.".red unless File.exists?(geographic_areas_file)
      raise "Missing #{geographic_items_file}, doing nothing.".red unless File.exists?(geographic_items_file)
      raise "Missing #{geographic_area_types_file}, doing nothing.".red unless File.exists?(geographic_area_types_file)
      raise "Missing #{geographic_areas_geographic_items_file}, doing nothing.red" unless File.exists?(geographic_areas_geographic_items_file)

      puts "#{Time.now.strftime "%H:%M:%S"}: From #{geographic_area_types_file}"

      a = Support::Database.pg_restore('geographic_area_types', data_store)
      ApplicationRecord.connection.reset_pk_sequence!('geographic_area_types')
      puts "#{Time.now.strftime "%H:%M:%S"}: From #{geographic_areas_file}"

      c = Support::Database.pg_restore('geographic_areas', data_store)
      ApplicationRecord.connection.reset_pk_sequence!('geographic_areas')
      puts "#{Time.now.strftime "%H:%M:%S"}: From #{geographic_items_file}"

      b = Support::Database.pg_restore('geographic_items', data_store)
      ApplicationRecord.connection.reset_pk_sequence!('geographic_items')
      puts "#{Time.now.strftime "%H:%M:%S"}: From #{geographic_areas_geographic_items_file}"

      d = Support::Database.pg_restore('geographic_areas_geographic_items', data_store)
      ApplicationRecord.connection.reset_pk_sequence!('geographic_areas_geographic_items')
      puts "#{Time.now.strftime "%H:%M:%S"}."

      puts 'Rebuilding GeographicArea...'
      e = GeographicArea.rebuild! # closure_tree
      puts "#{Time.now.strftime "%H:%M:%S"}."

      puts '...done.'
    end
  end
end
