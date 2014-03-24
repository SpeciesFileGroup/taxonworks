
# (Re)Building the Geographic data
=begin

  In ./taxonworks directory:

  1:  rake db:setup
      (Make sure that there are no processes connected to the development data base, including (but not limited to:
        pgAdmin
        psql
        RubyMine))

  2:  rake tw:init:build_geographic_areas place=../shapes/ shapes=false divisions=false user=person1@example.com NO_GEO_NESTING=1 NO_GEO_VALID=1

  3:  rake tw:init:rebuild_geographic_areas_nesting

  4:  rake tw:export:table table_name=geographic_area_types > ../shapes/data/internal/csv/geographic_area_types.csv

  5:  rake tw:export:table table_name=geographic_areas > ../shapes/data/internal/csv/geographic_areas.csv

  6:  rake tw:export:table table_name=geographic_items > ../shapes/data/internal/csv/geographic_items.csv
      alt:  pg_dump -Fc -t geographic_items -a taxonworks_development > ../shapes/data/internal/dump/geographic_items.dump

  (Reloading)
  7: rake db:setup
      (Make sure that there are no processes connected to the development data base, including (but not limited to:
        pgAdmin
        psql
        RubyMine))

  8:  rake tw:initialization:load_geographic_area_types[../shapes/data/internal/csv/geographic_area_types.csv]

  9:  rake tw:initialization:load_geographic_items[../shapes/data/internal/csv/geographic_items.csv]
      alt:  pg_restore -Fc -d taxonworks_development -t geographic_items ../shapes/data/internal/dump/geographic_items.dump

  10: rake tw:initialization:load_geographic_areas[../shapes/data/internal/csv/geographic_areas.csv] NO_GEO_NESTING=1

  11: rake tw:init:rebuild_geographic_areas_nesting

=end

namespace :tw do
  namespace :initialization do

    # Assumes input is from rake tw:export:table table_name=geographic_area_types
    # rake tw:initialization:load_geographic_area_types[../shapes/data/internal/csv/geographic_area_types.csv]
    desc 'call with "rake tw:initialization:load_geographic_area_types[/Users/matt/Downloads/geographic_area_types.csv]"'
    task :load_geographic_area_types, [:data_file] => [:environment] do |t, args|
      args.with_defaults(:data_file => '../shapes/data/internal/csv/geographic_area_types.csv')
      raise 'There are existing geographic_area_types, doing nothing.' if GeographicAreaType.all.count > 0
      begin
        data = CSV.read(args[:data_file], options = {headers: true, col_sep: "\t"})
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

    # Assumes input is from rake tw:export:table table_name=geographic_items
    # rake tw:initialization:load_geographic_items[../shapes/data/internal/csv/geographic_area_types.csv]
    desc 'call with "rake tw:initialization:load_geographic_items[/Users/matt/Downloads/geographic_items.csv]"'
    task :load_geographic_items, [:data_file] => [:environment] do |t, args|
      args.with_defaults(:data_file => '../shapes/data/internal/csv/geographic_items.csv')
      #raise 'There are existing geographic_items, doing nothing.' if GeographicItem.all.count > 0
      begin
        data = CSV.read(args[:data_file], options = {headers: true, col_sep: "\t"})
        records = {}

        puts "#{Time.now.strftime "%H:%M:%S"}."
        puts "#{args[:data_file]}: #{data.count} records."

        ActiveRecord::Base.transaction do
          data.each { |row|

            row_data      = row.to_h
            #row_data.delete('rgt')
            #row_data.delete('lft')
            r             = GeographicItem.new(row_data)
            records[r.id] = r
            print "\rBuild:  record #{r.id}"
          }

          count = records.count
          puts

          records.values.each do |r|
            #snap      = Time.now
            #elapsed   = snap - time_then
            #time_then = snap

            r.save!
            print "\rSave:   record #{r.id} of #{count}"
            #print ": #{Time.at(elapsed).getgm.strftime "%S:%L"}"
          end
          puts "\n\n#{Time.now.strftime "%H:%M:%S"}.\n\n"
        end
      rescue
        raise
      end
    end

    # Assumes input is from rake tw:export:table table_name=geographic_area
    # rake tw:initialization:load_geographic_areas[../shapes/data/internal/csv/geographic_areas.csv] NO_GEO_NESTING=1
    desc 'call with "rake tw:initialization:load_geographic_areas[/Users/matt/Downloads/geographic_areas.csv]  NO_GEO_NESTING=1"'
    task :load_geographic_areas, [:data_file] => [:environment] do |t, args|
      args.with_defaults(:data_file => './tmp/geographic_areas.csv')
      raise 'GeographicAreaTypes must be loaded first: run \'rake tw:initialization:load_geographic_area_types ../shapes/data/internal/csv/geographic_area_types.csv\' first.' if GeographicAreaType.all.count < 1
      raise 'GeographicAreaTypes must be loaded first: run \'rake tw:initialization:load_geographic_area_types ../shapes/data/internal/csv/geographic_area_types.csv\' first.' if GeographicItem.all.count < 1
      raise 'There are existing geographic_areas, doing nothing.' if GeographicArea.all.count > 0
      begin
        puts "#{Time.now.strftime "%H:%M:%S"}."
        data    = CSV.read(args[:data_file], options = {headers: true, col_sep: "\t"})
        records = {}

        ActiveRecord::Base.transaction do
          data.each { |row|

            row_data      = row.to_h
            #row_data.delete('rgt')
            #row_data.delete('lft')
            r             = GeographicArea.new(row_data)
            records[r.id] = r
            print "\rBuild:  record #{r.id}"
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
            print "\rUpdate: record #{v.id} of #{count}."
          end
          puts

          records.values.each do |r|
            #snap      = Time.now
            #elapsed   = snap - time_then
            #time_then = snap

            r.save!
            print "\rSave:   record #{r.id} of #{count}"
            #print ": #{Time.at(elapsed).getgm.strftime "%S:%L"}"
            print "."
          end
          puts "\n\n#{Time.now.strftime "%H:%M:%S"}."
        end
      rescue
        raise
      end
    end

    # rake tw:initialization:load_geographic_area_shapes
    desc 'load shapes for geographic_areas'
    task 'load_geographic_area_shapes' => [:environment] do

      Builder = 'person1@example.com'
      builder = User.where(email: Builder).first

      filenames = []
      filename  = ENV['table_name']

      if filename.blank?
        one_file = false
      else
        one_file = true
      end

      if one_file then
        filenames.push(filename)
      else
        filenames = [
          '../shapes/data/external/shapefiles/NaturalEarth/10m_cultural/ne_10m_admin_0_countries.shp',
          '../shapes/data/external/shapefiles/NaturalEarth/10m_cultural/ne_10m_admin_1_states_provinces_shp.shp',
          '../shapes/data/external/shapefiles/tdwg/level1/level1.shp',
          '../shapes/data/external/shapefiles/tdwg/level2/level2.shp',
          '../shapes/data/external/shapefiles/tdwg/level3/level3.shp',
          '../shapes/data/external/shapefiles/tdwg/level4/level4.shp',
          '../shapes/data/external/shapefiles/gadm/gadm_v2_shp/gadm2.shp'
        ]
      end

      multiples = []
      skipped   = {'ne_geo_item'   => [],
                   'tdwg_geo_item' => [],
                   'gadm_geo_item' => []}
      check     ={}
      placer = nil
      finder = {}

      filenames.each { |filename|
        # puts "\n\n#{Time.now.strftime "%H:%M:%S"} => #{filename}.\n\n"

        shapes = RGeo::Shapefile::Reader.open(filename, factory: Georeference::FACTORY)

        begin
          #ActiveRecord::Base.transaction do
          count = shapes.num_records.to_s
          puts "\n\n#{Time.now.strftime "%H:%M:%S"}: #{filename}: #{count} records.\n\n"

          shapes.each do |record|

            # there are different ways of locating the record for this shape, depending on where the data came from.
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

            #if check[finder]
            #  puts "\nDanger"
            #  puts
            #end
            #check[finder] = record.index

            if finder.nil?
            else
              ga = GeographicArea.where(finder)
              if ga.count < 1
                skipped[placer].push(finder.values.first)
                #$stderr.puts
                #$stderr.print "Skipped #{skipped[placer].count} : (#{record.index}) #{finder} from #{filename} (#{record['name']})."
                #$stderr.puts

              else

                # create the shape in which we are interested.
                gi = GeographicItem.new(creator:       builder,
                                        updater:       builder,
                                        multi_polygon: record.geometry)
                gi.save!

                ga.each { |area|
                  multiples.push(finder => area.name)
                  #$stderr.puts
                  #$stderr.print "Multiple #{multiples.count}: #{finder} found #{area.name} from #{area.data_origin}."
                  #$stderr.puts
                } if ga.count > 1

                ga.each { |area|

                  print "\r#{' ' * 80}\r#{record.index + 1} of #{count} (#{finder}) #{area.name}."
                  area.send("#{placer}=".to_sym, gi)
                  area.save
                }
              end
            end
          end

            # open the shape/dbf
            # for each record, check for a  a corresponding Geographic Area
            # found - > add shape
            # raise
            #end
        rescue
          raise
        end
      }
      puts
      puts "\n\n#{Time.now.strftime "%H:%M:%S"}: Multiples: #{multiples.count} records, skipped #{skipped[placer].count} records."

    end
  end
end

def pg_dump(table_name)
  a = `pg_dump -Fc -t #{table_name} -a taxonworks_development > ../shapes/data/internal/dump/#{table_name}.dump`
end

def pg_restore(table_name)
  a = `pg_restore -Fc -d taxonworks_development -t #{table_name} ../shapes/data/internal/dump/#{table_name}.dump`
end

