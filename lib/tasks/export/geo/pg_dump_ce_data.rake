namespace :tw do
  namespace :export do
    namespace :geo do
    # rake tw:initialization:pg_dump_geo_data[../gaz/data/internal/dump/]
    desc 'Save collected hand-built for collecting events in native pg_dump compressed form.'
    task :pg_dump_ce_data, [:dump_to_path] => [:environment] do |t, args|
      args.with_defaults(dump_to_path: '/tmp/' )
      data_store = args[:dump_to_path]
      begin
        puts "#{Time.now.strftime "%H:%M:%S"}: To #{data_store}geographic_area_types.dump"
        a = Support::Database.pg_dump('geographic_area_types', data_store)
        puts "#{Time.now.strftime "%H:%M:%S"}: To #{data_store}geographic_areas.dump"
        c = Support::Database.pg_dump('geographic_areas', data_store)
        puts "#{Time.now.strftime "%H:%M:%S"}: To #{data_store}geographic_items.dump"
        b = Support::Database.pg_dump('geographic_items', data_store)
        puts "#{Time.now.strftime "%H:%M:%S"}: To #{data_store}geographic_areas_geographic_items.dump"
        d = Support::Database.pg_dump('geographic_areas_geographic_items', data_store)
        puts "#{Time.now.strftime "%H:%M:%S"}: To #{data_store}collecting_events.dump"
        e = Support::Database.pg_dump('collecting_events', data_store)
        puts "#{Time.now.strftime "%H:%M:%S"}: To #{data_store}georeferences.dump"
        f = Support::Database.pg_dump('georeferences', data_store)
        puts "#{Time.now.strftime "%H:%M:%S"}."
      rescue
        raise
      end
    end
    end   
  end
end
