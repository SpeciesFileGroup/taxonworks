
=begin

# (Re)Building the Geographic data

  In Rails.root directory (/taxonworks):

  1:  rake db:setup
      (Make sure that there are no processes connected to the development data base, including (but not limited to:
        pgAdmin
        psql
        RubyMine))

  2:  rake tw:init:build_geographic_areas place=../gaz/ shapes=false divisions=false user=person1@example.com NO_GEO_NESTING=1 NO_GEO_VALID=1

  3:  rake tw:init:rebuild_geographic_areas_nesting

  4.  rake tw:initialization:save_geo_data ../gaz/data/internal/dump/

      alt:
      a:  rake tw:export:table table_name=geographic_area_types > ../gaz/data/internal/csv/geographic_area_types.csv

      b:  rake tw:export:table table_name=geographic_areas > ../gaz/data/internal/csv/geographic_areas.csv

      c:  rake tw:export:table table_name=geographic_items > ../gaz/data/internal/csv/geographic_items.csv

  (Reloading)
  1: rake db:setup
      (Make sure that there are no processes connected to the development data base, including (but not limited to:
        pgAdmin
        psql
        RubyMine))

  2.  rake tw:initialization:restore_geo_data[../gaz/data/internal/dump/]

      Alternately, load them individually:
      a:  rake tw:initialization:load_geographic_area_types[../gaz/data/internal/csv/geographic_area_types.csv]

      b:  rake tw:initialization:load_geographic_items[../gaz/data/internal/csv/geographic_items.csv]

      c:  rake tw:initialization:load_geographic_areas[../gaz/data/internal/csv/geographic_areas.csv] NO_GEO_NESTING=1

  11: rake tw:init:rebuild_geographic_areas_nesting

=end

namespace :tw do

  # TODO: Lock initialization down to (mostly) empty databases
  namespace :initialization do

    GAZ_DATA = '~/src/gaz/data/internal/dump/'

    # rake tw:initialization:save_geo_data[../gaz/data/internal/dump/]
    desc 'Save geographic area information in native pg_dump compressed form.'
    task :save_geo_data, [:data_store] => [:environment] do |t, args|
      database = 'taxonworks_development'
      args.with_defaults(:data_store => '/tmp/' )
      data_store = args[:data_store]
      begin
        puts "#{Time.now.strftime "%H:%M:%S"}: To #{data_store}geographic_area_types.dump"
        a = pg_dump(database, 'geographic_area_types', data_store)
        puts "#{Time.now.strftime "%H:%M:%S"}: To #{data_store}geographic_items.dump"
        b = pg_dump(database, 'geographic_items', data_store)
        puts "#{Time.now.strftime "%H:%M:%S"}: To #{data_store}geographic_areas.dump"
        c = pg_dump(database, 'geographic_areas', data_store)
        puts "#{Time.now.strftime "%H:%M:%S"}."
      rescue
        raise
      end
    end

    # rake tw:initialization:restore_geo_data[../gaz/data/internal/dump/]
    desc 'Restore geographic area information from compressed form.'
    task :restore_geo_data, [:data_store] => [:environment] do |t, args|
      database = 'taxonworks_development'
      args.with_defaults(:data_store => GAZ_DATA)
      data_store = args[:data_store]
      # TODO: Add condition for abort, i.e., dump files do not exist in the data_store directory.
    
      geographic_areas_file = "#{data_store}geographic_areas.dump"
      geographic_area_types_file = "#{data_store}geographic_area_types.dump"
      geographic_items_file = "#{data_store}geographic_items.dump"

      raise "Missing #{geographic_areas_file}, doing nothing." if !File.exists?(geographic_areas_file )
      raise "Missing #{geographic_items_file}, doing nothing." if !File.exists?(geographic_items_file) 
      raise "Missing #{geographic_area_types_file}, doing nothing." if !File.exists?(geographic_area_types_file) 

      puts "#{Time.now.strftime "%H:%M:%S"}: From #{geographic_area_types_file}"
      a = pg_restore(database, 'geographic_area_types', data_store)
      puts "#{Time.now.strftime "%H:%M:%S"}: From #{geographic_items_file}"
      b = pg_restore(database, 'geographic_items', data_store)
      puts "#{Time.now.strftime "%H:%M:%S"}: From #{geographic_areas_file}"
      c = pg_restore(database, 'geographic_areas', data_store)
      puts "#{Time.now.strftime "%H:%M:%S"}."
    end

    # Assumes input is from rake tw:export:table table_name=geographic_area_types
    # rake tw:initialization:load_geographic_area_types[../gaz/data/internal/csv/geographic_area_types.csv]
    desc 'call with "rake tw:initialization:load_geographic_area_types[/path/to/geographic_area_types.csv]"'
    task :load_geographic_area_types, [:data_file] => [:environment] do |t, args|
      args.with_defaults(:data_file => '../gaz/data/internal/csv/geographic_area_types.csv')
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
    # rake tw:initialization:load_geographic_items[../gaz/data/internal/csv/geographic_itemss.csv]
    desc 'call with "rake tw:initialization:load_geographic_items[/path/to/geographic_items.csv]"'
    task :load_geographic_items, [:data_file] => [:environment] do |t, args|
      args.with_defaults(:data_file => '../gaz/data/internal/csv/geographic_items.csv')
      #raise 'There are existing geographic_items, doing nothing.' if GeographicItem.all.count > 0
      begin
        data    = CSV.read(args[:data_file], options = {headers: true, col_sep: "\t"})
        records = {}

        count = data.count
        puts "#{args[:data_file]}: #{count} records."
        puts "#{Time.now.strftime "%H:%M:%S"}."

        #ActiveRecord::Base.transaction do
        data.each { |row|

          row_data      = row.to_h
          #row_data.delete('rgt')
          #row_data.delete('lft')
          r             = GeographicItem.new(row_data)
          records[r.id] = r
          print "\rBuild:  record #{r.id}"
        }

        puts "#{Time.now.strftime "%H:%M:%S"}."

        records.values.each do |r|
          #snap      = Time.now
          #elapsed   = snap - time_then
          #time_then = snap

          r.save!
          print "\rSave:   record #{r.id} of #{count}"
          #print ": #{Time.at(elapsed).getgm.strftime "%S:%L"}"
        end
        puts "\n\n#{Time.now.strftime "%H:%M:%S"}.\n\n"
          #end
      rescue
        raise
      end
    end

    # Assumes input is from rake tw:export:table table_name=geographic_area
    # rake tw:initialization:load_geographic_areas[../gaz/data/internal/csv/geographic_areas.csv] NO_GEO_NESTING=1
    desc 'call with "rake tw:initialization:load_geographic_areas[/Users/matt/Downloads/geographic_areas.csv]  NO_GEO_NESTING=1"'
    task :load_geographic_areas, [:data_file] => [:environment] do |t, args|
      args.with_defaults(:data_file => './tmp/geographic_areas.csv')
      raise 'GeographicAreaTypes must be loaded first: run \'rake tw:initialization:load_geographic_area_types ../gaz/data/internal/csv/geographic_area_types.csv\' first.' if GeographicAreaType.all.count < 1
      raise 'GeographicAreaTypes must be loaded first: run \'rake tw:initialization:load_geographic_area_types ../gaz/data/internal/csv/geographic_area_types.csv\' first.' if GeographicItem.all.count < 1
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

    def add_temporary_shape_tables
      SHAPETABLES.each do |table_name, file_path|
       puts `shp2pgsql -W LATIN1 #{file_path} #{table_name} > /tmp/foo.sql`
       puts `psql #{@args[:database_role]} -d taxonworks_development -f /tmp/foo.sql` 
       puts `rm /tmp/foo.sql` 
      end
    end

    def remove_temporary_shape_tables
      SHAPETABLES.keys.each do |table_name|
        ActiveRecord::Base.connection.execute("drop table #{table_name};")
      end
    end

    def build_and_assign(a, where_clause, join_table, placer, area_clause)
      print "\r#{a.id}    \t\t"
      b = Benchmark.measure {
        i = GeographicItem.create(point: @dummy_point)
        ActiveRecord::Base.connection.execute("update geographic_areas set #{placer} = '#{i.id}' where #{area_clause};")  
        ActiveRecord::Base.connection.execute("update geographic_items set point = null, multi_polygon = (select ST_Force3D(geom) from #{join_table} where #{where_clause}) where id = #{i.id};") 
      }
      print "#{b.to_s.strip}   "
    end

    def log_missmatch(a,r,where_clause)
      if r.count > 1
        @too_many_found[a.data_origin].push [a.name, a.id, r.count,  where_clause].join(" : ")
      else # has to be r.count == 0 
        @not_found[a.data_origin].push [a.name, a.id, where_clause].join(" : ") 
      end
    end 

    def assign_ne_country(a)
      where_clause = "iso_n3 = '#{a.neID}'"
      area_clause = "'neID' = '#{a.neID}'"
      assign_check(a, where_clause, 'ne_countries', 'ne_geo_item_id', area_clause)
   end

    def assign_ne_state(a)  
      where_clause = "'adm1_code_' = '#{a.neID}'"
      area_clause = "'neID' = '#{a.neID}'"
      assign_check(a, where_clause, 'ne_countries', 'ne_geo_item_id', area_clause)
    end
   
    def assign_check(a, where_clause, join_table, placer, area_clause)
      r = ActiveRecord::Base.connection.execute("select count(*) from #{join_table} where #{where_clause};")  # Do a fast query to check to see if there is a 1:1 map
      if r.count == 1 
        build_and_assign(a, where_clause, join_table, placer, area_clause) 
      else
        log_missmatch(a,r,where_clause)
      end
    end

    def assign_gadm(a) 
      where_clause = "'OBJECTID' = '#{a.gadmID}'"
      area_clause = "'gadmID' = '#{a.gadmID}'"
      assign_check(a, where_clause, 'gadm', 'gadm_geo_item_id', area_clause)
    end
   
    def assign_tdwg1(a)     
    end
  
    def assign_tdwg2(a)     
    end
 
    def assign_tdwg3(a)     
    end

    def assign_tdwg4(a)     
    end

    desc "Loads shape files related to GeographicAreas by querying against temporaryily loaded source shapefiles in SFGs /gaz repo:\n
        rake tw:initialization:load_geographic_area_shapes data_directory=/Users/matt/src/sf/tw/gaz/ database_role=postgres user_id=1"
    task 'load_geographic_area_shapes' => [:environment, :data_directory, :database_role, :user_id] do

      base = "#{@args[:data_directory]}data/external/shapefiles/"

      SHAPETABLES = {
        gadm: "#{base}gadm/gadm_v2_shp/gadm2.shp",
        ne_countries:   "#{base}NaturalEarth/10m_cultural/ne_10m_admin_0_countries.shp",
        ne_states:   "#{base}NaturalEarth/10m_cultural/ne_10m_admin_1_states_provinces_shp.shp",
        tdwg_l1: "#{base}tdwg/level1/level1.shp",
        tdwg_l2: "#{base}tdwg/level2/level2.shp",
        tdwg_l3: "#{base}tdwg/level3/level3.shp",
        tdwg_l4: "#{base}tdwg/level4/level4.shp"
      }

      SHAPETABLES.values.each do |file|
        raise "Can't find #{file}." if !File.exists?(file)
      end

      # add_temporary_shape_tables

      @dummy_point = Georeference::FACTORY.point(-12.345678, 12.345678, 123)
  
      @not_found = {} 
      @too_many_found = {}
      GeographicArea.pluck('data_origin').uniq.inject(@not_found) {|hsh, a| hsh.merge!(a => [])} 
      GeographicArea.pluck('data_origin').uniq.inject(@too_many_found) {|hsh, a| hsh.merge!(a => [])} 

      begin
        ActiveRecord::Base.transaction do 
          a = Benchmark.measure { 
            GeographicArea.all.each do |a|
              assign_ne_country(a) if !a.neID.blank? && a.ne_geo_item_id.blank?
              assign_ne_state(a)   if !a.neID.blank? && a.ne_geo_item_id.blank?
              assign_gadm(a)       if !a.gadmID.blank? && a.gadm_geo_item_id.blank?
              if !a.tdwgID.blank? && a.tdwg_geo_item_id.blank?
                assign_tdwg1(a)      
                assign_tdwg2(a)     
                assign_tdwg3(a)    
                assign_tdwg4(a)   
              end
            end
          }

          puts "\n\n #{a.to_s}"

          byebug
          raise
        end
      rescue
        raise
      end
   
       # remove_temporary_shape_tables
    end


    

  #   byebug
  #         raise
  #         # there are different ways of locating the record for this shape, depending on where the data came from.
  #         case filename
  #           when /ne_10m_admin_0_countries\.shp/i
  #             finder = {:neID => record['iso_n3']}
  #             placer = 'ne_geo_item'
  #           when /ne_10m_admin_1_states_provinces_shp\.shp/i
  #             finder = {:neID => record['adm1_code']}
  #             placer = 'ne_geo_item'
  #           when /level1/i
  #             finder = {:tdwgID => record['LEVEL1_COD'].to_s + '----'}
  #             placer = 'tdwg_geo_item'
  #           when /level2/i
  #             finder = {:tdwgID => record['LEVEL2_COD'].to_s + '---'}
  #             placer = 'tdwg_geo_item'
  #           when /level3/i
  #             finder = {:tdwgID => record['LEVEL2_COD'].to_s + record['LEVEL3_COD']}
  #             placer = 'tdwg_geo_item'
  #           when /level4/i
  #             finder = {:tdwgID => record['Level2_cod'].to_s + record['Level4_cod']}
  #             placer = 'tdwg_geo_item'
  #           when /gadm2/i
  #             finder = {:gadmID => record['OBJECTID']}
  #             placer = 'gadm_geo_item'
  #           else
  #             finder = nil
  #             placer = nil
  #         end

  #   multiples = []
  #     #   check     ={}
  #   placer    = nil
  #   finder    = {}

  #   filenames.each { |filename|
  #     # puts "\n\n#{Time.now.strftime "%H:%M:%S"} => #{filename}.\n\n"

  #     shapes = RGeo::Shapefile::Reader.open(filename, factory: Georeference::FACTORY)

  #     begin
  #       #ActiveRecord::Base.transaction do
  #       count = shapes.num_records.to_s
  #       puts "\n\n#{Time.now.strftime "%H:%M:%S"}: #{filename}: #{count} records.\n\n"

  #       shapes.each do |record|

  #         byebug
  #         raise
  #         # there are different ways of locating the record for this shape, depending on where the data came from.
  #         case filename
  #           when /ne_10m_admin_0_countries\.shp/i
  #             finder = {:neID => record['iso_n3']}
  #             placer = 'ne_geo_item'
  #           when /ne_10m_admin_1_states_provinces_shp\.shp/i
  #             finder = {:neID => record['adm1_code']}
  #             placer = 'ne_geo_item'
  #           when /level1/i
  #             finder = {:tdwgID => record['LEVEL1_COD'].to_s + '----'}
  #             placer = 'tdwg_geo_item'
  #           when /level2/i
  #             finder = {:tdwgID => record['LEVEL2_COD'].to_s + '---'}
  #             placer = 'tdwg_geo_item'
  #           when /level3/i
  #             finder = {:tdwgID => record['LEVEL2_COD'].to_s + record['LEVEL3_COD']}
  #             placer = 'tdwg_geo_item'
  #           when /level4/i
  #             finder = {:tdwgID => record['Level2_cod'].to_s + record['Level4_cod']}
  #             placer = 'tdwg_geo_item'
  #           when /gadm2/i
  #             finder = {:gadmID => record['OBJECTID']}
  #             placer = 'gadm_geo_item'
  #           else
  #             finder = nil
  #             placer = nil
  #         end

  #         #if check[finder]
  #         #  puts "\nDanger"
  #         #  puts
  #         #end
  #         #check[finder] = record.index

  #               if finder.nil?
  #         else
  #           ga = GeographicArea.where(finder)
  #           if ga.count < 1
  #             skipped[placer].push(finder.values.first)
  #             #$stderr.puts
  #             #$stderr.print "Skipped #{skipped[placer].count} : (#{record.index}) #{finder} from #{filename} (#{record['name']})."
  #             #$stderr.puts

  #           else

  #             # create the shape in which we are interested.
  #             gi = GeographicItem.new(creator:       builder,
  #                                     updater:       builder,
  #                                     multi_polygon: record.geometry)
  #             gi.save!

  #             ga.each { |area|
  #               multiples.push(finder => area.name)
  #               #$stderr.puts
  #               #$stderr.print "Multiple #{multiples.count}: #{finder} found #{area.name} from #{area.data_origin}."
  #               #$stderr.puts
  #             } if ga.count > 1

  #             ga.each { |area|

  #               print "\r#{' ' * 80}\r#{record.index + 1} of #{count} (#{finder}) #{area.name}."
  #               area.send("#{placer}=".to_sym, gi)
  #               area.save
  #             }
  #           end
  #         end
  #       end

  #         # open the shape/dbf
  #         # for each record, check for a  a corresponding Geographic Area
  #         # found - > add shape
  #         # raise
  #         #end
  #     rescue
  #       raise
  #     end
  #   }
  #   puts
  #   puts "\n\n#{Time.now.strftime "%H:%M:%S"}: Multiples: #{multiples.count} records, skipped #{skipped[placer].count} records."

    # end
  end
end

def pg_dump(database_name, table_name, data_store)
  a = `pg_dump -Fc -t #{table_name} -a #{database_name} > #{data_store}/#{table_name}.dump`
  a
end

def pg_restore(database_name, table_name, data_store)
=begin
  pg_restore -Fc -d taxonworks_development -t geographic_area_types ~/src/gaz/data/internal/dump/geographic_area_types.dump
  pg_restore -Fc -d taxonworks_development -t geographic_items ~/src/gaz/data/internal/dump/geographic_items.dump
  pg_restore -Fc -d taxonworks_development -t geographic_areas ~/src/gaz/data/internal/dump/geographic_areas.dump
=end
  a = `pg_restore -Fc -d #{database_name} -t #{table_name} #{data_store}/#{table_name}.dump`
  a
end
