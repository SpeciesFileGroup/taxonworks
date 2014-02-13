namespace :tw do
  namespace :initialization do

    # Assumes input is from rake tw:export:table table_name=geographic_area_types
    desc 'call like "rake tw:initialization:load_geographic_area_types[/Users/matt/Downloads/geographic_area_types.csv]"'
    task :load_geographic_area_types, [:data_directory] => [:environment] do |t, args|
      args.with_defaults(:data_directory => './tmp/geographic_area_types.csv')
      raise 'There are existing geographic_area_types, doing nothing.' if GeographicAreaType.all.count > 0
      begin
        data = CSV.read(args[:data_directory], options = {headers: true, col_sep: "\t"})
        ActiveRecord::Base.transaction do
          data.each { |row|
            r = GeographicAreaType.new(row.to_h)
            r.save!
          }
        end
      rescue
        raise
      end
    end

    # Assumes input is from rake tw:export:table table_name=geographic_area
    desc 'call like "rake tw:initialization:load_geographic_areas[/Users/matt/Downloads/geographic_areas.csv]"'
    task :load_geographic_areas, [:data_directory] => [:environment] do |t, args|
      args.with_defaults(:data_directory => './tmp/geographic_areas.csv')
      raise 'There are existing geographic_areas, doing nothing.' if GeographicArea.all.count > 0
      begin
        data    = CSV.read(args[:data_directory], options = {headers: true, col_sep: "\t"})
        records = {}
        ActiveRecord::Base.transaction do
          data.each { |row|
            r             = GeographicArea.new(row.to_h)
            records[r.id] = r
          }

          records.each do |k, v|
            v.level0               = records[v.level0_id]
            v.level1               = records[v.level1_id]
            v.level2               = records[v.level2_id]
            v.parent               = records[v.parent_id]
            v.geographic_area_type = records[v.geographic_area_type_id]
            v
          end

          records.each do |r|
            r[1].save!
          end
        end
      rescue
        raise
      end
    end
  end
end
