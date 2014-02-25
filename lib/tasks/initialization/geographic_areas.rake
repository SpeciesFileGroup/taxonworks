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
          count = data.count
          puts
          data.each { |row|
            r = GeographicAreaType.new(row.to_h)
            r.save!
            print "Save:   record #{r.id} of #{count}.\r"
          }
        end
        puts
      rescue
        raise
      end
    end

    # Assumes input is from rake tw:export:table table_name=geographic_area
    desc 'call like "rake tw:initialization:load_geographic_areas[/Users/matt/Downloads/geographic_areas.csv]"'
    task :load_geographic_areas, [:data_directory] => [:environment] do |t, args|
      args.with_defaults(:data_directory => './tmp/geographic_areas.csv')
      raise 'GeographicAreaTypes must be loaded first: run \'rake tw:initialization:load_geographic_area_types ./tmp/geographic_area_types.csv\' first.' if GeographicAreaType.all.count < 1
      raise 'There are existing geographic_areas, doing nothing.' if GeographicArea.all.count > 0
      begin
        puts "#{Time.now.strftime "%H:%M:%S"}."
        data    = CSV.read(args[:data_directory], options = {headers: true, col_sep: "\t"})
        records = {}

        ActiveRecord::Base.transaction do
          data.each { |row|

            row_data      = row.to_h
            #row_data.delete('rgt')
            #row_data.delete('lft')
            r             = GeographicArea.new(row_data)
            records[r.id] = r
            print "Build:  record #{r.id}\r"
          }

          count = records.count
          puts

          records.each do |k, v|
            #snap      = Time.now
            #elapsed   = snap - time_then
            #time_then = snap

            v.level0               = records[v.level0_id]
            v.level1               = records[v.level1_id]
            v.level2               = records[v.level2_id]
            v.parent               = records[v.parent_id]
            v.geographic_area_type = GeographicAreaType.where(id: v.geographic_area_type_id).first
            print "Update: record #{v.id} of #{count}.\r"
          end
          puts

          records.values.each do |r|
            #snap      = Time.now
            #elapsed   = snap - time_then
            #time_then = snap

            r.save!
            print "Save:   record #{r.id} of #{count}"
            #print ": #{Time.at(elapsed).getgm.strftime "%S:%L"}"
            print ".\r"
          end
=begin
          puts
          elapsed = Time.now - time_start
          puts "#{Time.at(elapsed).getgm.strftime "%H:%M:%S"}:"
=end
        end
      rescue
        raise
      end
    end

    desc 'load shapes for geographic_areas'
    task 'load_geographic_area_shapes' => [:environment] do

      Builder  = 'person1@example.com'
      builder  = User.where(email: Builder).first

      #'G:\Share\rails\shapes\gadm_v2_shp\gadm2.shp'
      filename = ENV['table_name']
      shapes   = RGeo::Shapefile::Reader.open(filename, factory: Georeference::FACTORY)

      begin
        ActiveRecord::Base.transaction do
          shapes.each do |record|

            # there are different ways of locating the record for this shape, depending on where the data came from.
            finder = {}
            placer = nil
            case filename
              when /ne_10m_admin_0_countries\.shp/i
                finder = {:neID => record['iso_n3']}
                placer = 'ne_geo_item'
              when /ne_10m_admin_1_states_provinces_shp\.shp/i
                finder = {:neID => record['adm1_code']}
                placer = 'ne_geo_item'
              when /level1/i
                finder = {:tdwgID => record['LEVEL1_COD'].to_s + '----'}
                placer = 'tdwg_geo_item'
              when /level2/i
                finder = {:tdwgID => record['LEVEL2_COD'].to_s + '---'}
                placer = 'tdwg_geo_item'
              when /level3/i
                finder = {:tdwgID => record['LEVEL2_COD'].to_s + record['LEVEL3_COD']}
                placer = 'tdwg_geo_item'
              when /level4/i
                finder = {:tdwgID => record['Level2_cod'].to_s + record['Level4_cod']}
                placer = 'tdwg_geo_item'
              when /gadm2/i
                finder = {:gadmID => record['OBJECTID']}
                placer = 'gadm_geo_item'
              else
                finder = nil
                placer = nil
            end

            if finder.nil?
            else
              ga = GeographicArea.where(finder)
              if ga.nil?
              else

                # create the shape in which we are interested.
                gi = GeographicItem.new(creator:       builder,
                                        updater:       builder,
                                        multi_polygon: record.geometry)
                gi.save!

                ga.each { |area|
                  # placer = 'geographic_item'
                  #area.send("#{placer}=".to_sym, gi)

                  case placer
                    when /tdwg/
                      area.tdwg_geo_item = gi
                    when /ne_/
                      area.ne_geo_item = gi
                    when /gadm/
                      area.gadm_geo_item = gi
                    else
                      area
                  end

                  area.save
                  area
                }
              end
            end
          end

          # open the shape/dbf
          # for each record, check for a  a corresponding Geographic Area
          # found - > add shape
          raise
        end
      rescue
        raise
      end


    end
  end
end
