namespace :tw do
  namespace :development do
    namespace :data do
      namespace :geo do

        # Presently benchmarks at under 10 minutes.
        desc "Loads shape files related to GeographicAreas by querying against temporarily loaded source shapefiles in SFGs /gaz repo.\n
          database_role is the postgres role that has permissions for the database used.\n
            rake tw:development:data:geo:build_geographic_items_from_temporary_shape_tables data_directory=/Users/matt/src/sf/tw/gaz/ database_role=matt user_id=1"
        task 'build_geographic_items_from_temporary_shape_tables' => [:environment, :geo_dev_init, :data_directory, :database_role, :user_id, :build_temporary_shapefile_tables] do
          create_geographic_item_records
          remove_invalid_data
          quick_validate
        end

        def create_geographic_item_records
          puts 'Creating GeographicItems'
          geo_item = GeographicItem.new
          geo_item.multi_polygon = SIMPLE_SHAPES[:multi_polygon]
          @dummy_multi_polygon = geo_item.geo_object
          GeographicAreasGeographicItem.order('data_origin').find_each do |a|
            create_geographic_item_and_update_related(a) if a.geographic_item_id.blank?
          end
        end

        # Creates GeographicItems and adds their geometries using an Update statement
        def create_geographic_item_and_update_related(a)
          return unless a.geographic_item_id.blank? # allows the task to be stopped and started, be careful with this assumption!

          i    = GeographicItem.create(multi_polygon: @dummy_multi_polygon)
          sql1 = "UPDATE geographic_areas_geographic_items SET geographic_item_id = '#{i.id}' where id = #{a.id};"
          sql2 = "UPDATE geographic_items SET point = null, multi_polygon = ( select ST_Force3D(geom) from #{a.data_origin} where gid = '#{a.origin_gid}') WHERE id = #{i.id};"
          ApplicationRecord.connection.execute(sql1)

          b = Benchmark.measure {
            ApplicationRecord.connection.execute(sql2)
          }

          print "\r#{a.id} : #{a.data_origin}            : #{b.to_s.strip}                      "
        end

        # Deletes all GeographicItems (and by relation GeographicAreasGeographicItems) that have ST_InvalidGeometries.
        # !! This assumes all imported data are to GeographicItem#multi_polygon.  At present this is true.
        def remove_invalid_data
          invalid_records = 0
          ir = []
          print "\nRemoving invalid data:"
          test_b = Benchmark.measure {ir = ApplicationRecord.connection.execute('select id from geographic_items where ST_IsValid(ST_AsBinary(multi_polygon)) = \'f\'')}
          print " #{test_b}"
          # test_t = Benchmark.measure {ir = ApplicationRecord.connection.execute('select id from geographic_items where ST_IsValid(ST_AsText(multi_polygon)) = \'f\'')}
          # print " <=> #{test_t}: "

          ir.each do |i|
            invalid_records += 1
            print " #{i['id']}"
            GeographicItem.destroy(i['id'])
          end
          print "(#{invalid_records}).\n"
        end

        # Uses St_SymDifference to check whether geometries are identical for a small
        # set of each kind of imported data.
        def quick_validate
          puts "\nDoing some validation"
          expected_diff = '010700000000000000' # ?
          IMPORT_TABLES.each_key do |t|
            GeographicAreasGeographicItem.where(data_origin: t.to_s).limit(9).each do |i|
              if i.geographic_item.valid_geometry?
                a    = "SELECT St_AsBinary(geom)          FROM #{i.data_origin} WHERE gid = #{i.origin_gid}"
                b    = "SELECT St_AsBinary(multi_polygon) FROM geographic_items WHERE id  = #{i.geographic_item_id}"
                sql1 = "SELECT St_SymDifference((#{a}), (#{b}));"
                r    = ApplicationRecord.connection.execute(sql1).first['St_SymDifference'].to_s
                if r == expected_diff
                  puts "#{i.data_origin} data matching"
                else
                  puts "#{i.data_origin} data not matching"
                  puts a
                  puts b
                end
              end
            end
          end
        end

        desc "Removes GeographicItems for which there is no corresponding GeographicArea.\n
          database_role is the postgres role that has permissions for the database used.\n
            rake tw:development:data:geo:clean_orphan_geographic_items_from_table database_role=taxonworks_development user_id=1"
        task 'clean_orphan_geographic_items_from_table' => [:environment, :geo_dev_init, :database_role, :user_id] do
          clean?
          clean!
        end

        # There may be cases where there are orphan shapes, since the table for this model in NOT normalized for shape.
        #  This method is provided to find all of the orphans, and store their ids in the table 't20140306', and return an
        # array to the caller.
        def clean?
          GeographicItem.connection.execute('DROP TABLE IF EXISTS t20140306')
          GeographicItem.connection.execute('CREATE TABLE t20140306(id integer)')
          GeographicItem.connection.execute('delete from t20140306')
          # collect all the GeoItem ids
          GeographicItem.connection.execute('insert into t20140306 select id from geographic_items')
          # remove the GeoItem ids which are represented in the joining table
          GeographicItem.connection.execute('delete from t20140306 where id in (select geographic_item_id from geographic_areas_geographic_items)')
          GeographicItem.connection.execute('select id from t20140306').to_a
        end

        # given the list of orphan shapes (in 't20140306'), delete them, drop the table, and return the list (which is
        # probably not very useful).
        def clean!
          list = clean?
          GeographicItem.connection.execute('delete from geographic_items where id in (select id from t20140306)')
          GeographicItem.connection.execute('drop table t20140306')
          list
        end
      end
    end
  end
end

