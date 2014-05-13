namespace :tw do
  namespace :development do
    namespace :data do
      namespace :geo do

        # Presently benchmarks at under 10 minutes.
        desc "Loads shape files related to GeographicAreas by querying against temporaryily loaded source shapefiles in SFGs /gaz repo.\n
          database_role is the postgres role that has permissions for the database used.\n
            rake tw:development:data:geo:build_geographic_items_from_temporary_shape_tables data_directory=/Users/matt/src/sf/tw/gaz/ database_role=matt user_id=1"
        task 'build_geographic_items_from_temporary_shape_tables' => [:environment, :geo_dev_init, :data_directory, :database_role, :user_id, :build_temporary_shapefile_tables] do
          create_geographic_item_records 
          remove_invalid_data
          quick_validate
        end

        def create_geographic_item_records
          puts "Creating GeographicItems"
          @dummy_point = Georeference::FACTORY.point(-12.345678, 12.345678, 123)
          GeographicAreasGeographicItem.order('data_origin').find_each do |a|
            create_geographic_item_and_update_related(a) if a.geographic_item_id.blank?
          end
        end

        # Creates GeographicItems and adds their geometries using an Update statement
        def create_geographic_item_and_update_related(a)
          return if !a.geographic_item_id.blank? # allows the task to be stopped and started, be careful with this assumption!

          i = GeographicItem.create(point: @dummy_point)
          sql1 = "UPDATE geographic_areas_geographic_items SET geographic_item_id = '#{i.id}' where id = #{a.id};" 
          sql2 = "UPDATE geographic_items SET point = null, multi_polygon = ( select ST_Force3D(geom) from #{a.data_origin} where gid = '#{a.origin_gid}') WHERE id = #{i.id};"
          ActiveRecord::Base.connection.execute(sql1)  

          b = Benchmark.measure {
            ActiveRecord::Base.connection.execute(sql2) 
          }

          print "\r#{a.id} : #{a.data_origin}            : #{b.to_s.strip}                      "
        end

        # Deletes all GeographicItems (and by relation GeographicAreasGeographicItems) that have ST_InvalidGeometries. 
        # !! This assumes all imported data are to GeographicItem#multi_polygon.  At present this is true.
        def remove_invalid_data
          invalid_records = 0
          print "\nRemoving invalid data:"
          ActiveRecord::Base.connection.execute("select id from geographic_items where ST_IsValid(ST_AsTExt(multi_polygon)) = 'f'").each do |i|
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
          IMPORT_TABLES.keys.each do |t|
            GeographicAreasGeographicItem.where(data_origin: t.to_s).limit(5).each do |i|
              if i.geographic_item.is_valid_geometry?
                a = "SELECT St_AsText(geom)          FROM #{i.data_origin} WHERE gid = #{i.origin_gid}"
                b = "SELECT St_AsText(multi_polygon) FROM geographic_items WHERE id  = #{i.geographic_item_id}"
                sql1 = "SELECT St_SymDifference((#{a}), (#{b}));"
                r = ActiveRecord::Base.connection.execute(sql1).first['st_symdifference'].to_s
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

      end
    end
  end
end

