namespace :tw do
  namespace :development do
    namespace :data do
      namespace :geo do

        # Currently clocks at ~ 0.1 seconds / record : 149.780000  11.220000 161.000000 (6233.255875); results in 36235 records (vs. 34125 in gaz)

        desc "Loads shape files related to GeographicAreas by querying against temporaryily loaded source shapefiles in SFGs /gaz repo.\n
          database_role is the postgres role that has permissions for the database used.\n
            rake tw:development:data:geo:build_geographic_items_from_temporary_shape_tables data_directory=/Users/matt/src/sf/tw/gaz/ database_role=matt user_id=1"
        task 'build_geographic_items_from_temporary_shape_tables' => [:environment, :geo_dev_init, :data_directory, :database_role, :user_id, :build_temporary_shapefile_tables] do

          @dummy_point = Georeference::FACTORY.point(-12.345678, 12.345678, 123)

          @not_found = {} 
          @too_many_found = {}

          GeographicArea.pluck('data_origin').uniq.inject(@not_found) {|hsh, a| hsh.merge!(a => [])} 
          GeographicArea.pluck('data_origin').uniq.inject(@too_many_found) {|hsh, a| hsh.merge!(a => [])} 

          # No transaction, gets in the way of .execute()
          a = Benchmark.measure { 
            GeographicArea.find_each do |a|
              assign_ne_country(a) if !a.neID.blank? && a.ne_geo_item_id.blank? && a.data_origin == 'NaturalEarth-0 (10m)'
              assign_ne_state(a)   if !a.neID.blank? && a.ne_geo_item_id.blank? && a.data_origin == 'NaturalEarth-1 (10m)'
              if !a.tdwgID.blank? && a.tdwg_geo_item_id.blank?
                assign_tdwg1(a)    if a.tdwg_level == '1'
                assign_tdwg2(a)    if a.tdwg_level == '2'
                assign_tdwg3(a)    if a.tdwg_level == '3' 
                assign_tdwg4(a)    if a.tdwg_level == '4' 
              end
              assign_gadm(a)       if !a.gadmID.blank? && a.gadm_geo_item_id.blank?
            end
          }
          puts "\n\n #{a.to_s}"

          quick_validate
        end

        
        # Helper methods

        def add_temporary_shape_tables
          puts "Adding temporary shape files."
          SHAPETABLES.each do |table_name, file_path|
            puts `shp2pgsql -W LATIN1 #{file_path} #{table_name} > /tmp/foo.sql`
            puts `psql #{@args[:database_role]} -d taxonworks_development -f /tmp/foo.sql` 
            puts `rm /tmp/foo.sql` 

            # cleanup TDWG - there is one duplicate record in level 4
            ActiveRecord::Base.connection.execute('delete from tdwg_l4 where gid = 193;')
          end
        end

        def remove_temporary_shape_tables
          puts "Removing temporary shape tables."
          SHAPETABLES.keys.each do |table_name|
            ActiveRecord::Base.connection.execute("drop table #{table_name};")
          end
        end

        def build_and_assign(a, where_clause, join_table, placer, area_clause)
          print "\r#{a.id}      \t\t"
          b = Benchmark.measure {
            i = GeographicItem.create!(point: @dummy_point)
            sql1 = "UPDATE geographic_areas SET #{placer} = '#{i.id}' where #{area_clause};"
            sql2 = "UPDATE geographic_items SET point = null, multi_polygon = (select ST_Force3D(geom) from #{join_table} where #{where_clause}) where id = #{i.id};"
            ActiveRecord::Base.connection.execute(sql1)  
            ActiveRecord::Base.connection.execute(sql2) 
          }
          print "#{b.to_s.strip}       "
        end

        def log_missmatch(a,r,where_clause)
          if r.count > 1
            @too_many_found[a.data_origin].push [a.name, a.id, r.count, where_clause].join(" : ")
          else # has to be r.count == 0 
            @not_found[a.data_origin].push [a.name, a.id, where_clause].join(" : ") 
          end
        end 

        def assign_check(a, where_clause, join_table, placer, area_clause)
          r = ActiveRecord::Base.connection.execute("select count(*) from #{join_table} where #{where_clause};")  # Do a fast query to check to see if there is a 1:1 map
          if r.count == 1 
            build_and_assign(a, where_clause, join_table, placer, area_clause) 
          else
            log_missmatch(a,r,where_clause)
          end
        end

        def assign_ne_country(a)
          where_clause = "iso_n3 = '#{a.neID}'"
          area_clause = "\"neID\" = '#{a.neID}'"
          assign_check(a, where_clause, 'ne_countries', 'ne_geo_item_id', area_clause)
        end

        def assign_ne_state(a)  
          where_clause = "\"adm1_code_\" = '#{a.neID}'"
          area_clause = "\"neID\" = '#{a.neID}'"
          assign_check(a, where_clause, 'ne_states', 'ne_geo_item_id', area_clause)
        end

        def assign_gadm(a) 
          where_clause = "objectid = '#{a.gadmID}'"
          area_clause = "\"gadmID\" = '#{a.gadmID}'"
          assign_check(a, where_clause, 'gadm', 'gadm_geo_item_id', area_clause)
        end

        def assign_tdwg1(a)
          where_clause = "level1_cod = '#{a.tdwg_ids[:lvl1]}'"
          area_clause = "\"tdwgID\" = '#{a.tdwgID}'"
          assign_check(a, where_clause, 'tdwg_l1', 'tdwg_geo_item_id', area_clause)
        end

        def assign_tdwg2(a)    
          where_clause = "level2_cod = '#{a.tdwg_ids[:lvl2]}'"
          area_clause = "\"tdwgID\" = '#{a.tdwgID}'"
          assign_check(a, where_clause, 'tdwg_l2', 'tdwg_geo_item_id', area_clause)
        end

        def assign_tdwg3(a)     
          where_clause = "level2_cod = '#{a.tdwg_ids[:lvl2]}' AND level3_cod = '#{a.tdwg_ids[:lvl3]}'"
          area_clause = "\"tdwgID\" = '#{a.tdwgID}'"
          assign_check(a, where_clause, 'tdwg_l3', 'tdwg_geo_item_id', area_clause)
        end

        def assign_tdwg4(a)     
          where_clause = "level2_cod = '#{a.tdwg_ids[:lvl2]}' AND level4_cod = '#{a.tdwg_ids[:lvl4]}'"
          area_clause = "\"tdwgID\" = '#{a.tdwgID}'"
          assign_check(a, where_clause, 'tdwg_l4', 'tdwg_geo_item_id', area_clause)
        end

        def quick_validate
          expected_diff = '010700000000000000'
          sql1 = 'select St_SymDifference((select ST_AsBinary(geom) from gadm where gid = 212288), (select ST_AsBinary(multi_polygon) from geographic_items where id = 32805));'
          puts (ActiveRecord::Base.connection.execute(sql1).first['st_symdifference'].to_s == expected_diff) ? 'GADM data matching' : 'GADM data not matching'

          %w{gadm ne tdwg}.each do |t|
            r = ActiveRecord::Base.connection.execute("select id from geographic_items where '#{t}ID' is not null and '#{t}_geo_item_id' is null;")
            puts (r.count > 0) ? "#{t} records with a #{t}ID does not have matching geo_item_id" : "All #{t} have geo_items."  
          end
        end

      end
    end
  end
end

