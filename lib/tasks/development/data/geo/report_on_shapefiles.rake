namespace :tw do
  namespace :development do
    namespace :data do
      namespace :geo do

        desc "Report on the shapefiles.\n
           rake tw:development:data:geo:report_on_shapefiles data_directory=/Users/matt/src/sf/tw/gaz/ ?index=[something]"
        task report_on_shapefiles: [:environment, :geo_dev_init, :data_directory] do
          BaseDir  = @args[:data_directory]
          Dir.glob(BaseDir + '**/*.shp').each { |filename|
            # @mjy is unsure of use of index at this point
            # index is only expected to work for the GADM V2 shape file set: intended *only* as a
            # short-cut to a problem record.
            # index     = ENV['index']
            read_shape(filename, 0)
          }
        end

        #noinspection RubyStringKeysInHashInspection
        # This does not update the database.
        # Should be considered early trial code?
        def read_shape(filename, index)
          # TODO: For some reason, Gis::FACTORY does not seem to be the default factory, so we are being specific here, to get the lenient polygon tests.  This gets us past the problem polygons, but does not actually deal with the problem.
          # See http://dazuma.github.io/rgeo-shapefile/rdoc/RGeo/Shapefile/Reader.html for reader options.

          # ne10 = RGeo::Shapefile::Reader.open('G:\Share\Downloads\PostgreSQL\PostGIS\10m_cultural\10m_cultural\ne_10m_admin_0_countries.shp', factory: Gis::FACTORY)
          # gadm = RGeo::Shapefile::Reader.open('G:\Share\rails\shapes\gadm_v2_shp\gadm2.shp', factory: Gis::FACTORY)

          RGeo::Shapefile::Reader.open(filename, factory: Gis::FACTORY) { |file|
            file.seek_index(index)
            count = file.num_records
            ess   = (count == 1) ? '' : 's'
            puts filename
            puts "#{Time.now.strftime "%H:%M:%S"}: #{filename} contains #{count} item#{ess}."

            # things to do before each file
            case filename
            when /adm1/i
              # since we are going to have to skip XXX_adm0, we need to build a master records for North America,
              # the USA by hand
              mr = GeographicArea.where(name: 'United States')
              if mr[0].nil?
                mr = GeographicArea.new(name:                 'United States',
                                        country_id:           240,
                                        parent_id:            0,
                                        geographic_area_type: GeographicAreaType.where(name: 'Country')[0])
                mr.save! # !! WHY!?
              end
            when /level1/i
              record = GeographicArea.where(name: 'Earth')
              if record.count == 0
                record    = GeographicArea.new(parent_id: nil,
                                               name:      'Earth')
                area_type = GeographicAreaType.where(name: 'Planet')[0]
                # save this record for later
                earth     = record.save! # !! WHY!?
              else
                earth = record[0]
              end
            end

            # record    = GeographicArea.new
            # area_type = GeographicAreaType.new

            time_then = Time.now
            file.each { |item|
              record = nil

              # todo: This processing is *very* specific, and currently only handles the USA_adm shape file case: it must be made to handle a more general case of GADM, and/or TDWG

              case filename
                #when /USA_adm0/
                #  record    = GeorgaphicArea.new(parent_id:  0,
                #                                 name:       item[:NAME_ENGLISH],
                #                                 country_id: item[:PID])
                #  area_type = GeographicAreaType.where(name: 'Country')[0]
                #  #if area_type.nil?
                #  #  at = GeographicAreaType.new(name: 'Country')
                #  #  at.save
                #  #  area_type = at
                #  #end
                #when /USA_adm1/
                #  record    = GeographicArea.new(parent_id:  item[:ID_0],
                #                                 name:       item[:NAME_1],
                #                                 state_id:   item[:ID_1],
                #                                 country_id: item[:ID_0])
                #  area_type = GeographicAreaType.where(name: item[:TYPE_1])
                #  #if area_type.nil?
                #  #  at = GeographicAreaType.new(name: item[:TYPE_1])
                #  #  at.save
                #  #  area_type = at
                #  #end
                #when /USA_adm2/
                #  record    = GeographicArea.new(parent_id:  item[:ID_1],
                #                                 name:       item[:NAME_2],
                #                                 state_id:   item[:ID_1],
                #                                 country_id: item[:ID_0],
                #                                 county_id:  item[:ID_2])
                #  area_type = GeographicAreaType.where(name: item[:TYPE_2])
                #  #if area_type.nil?
                #  #  at = GeographicAreaType.new(name: item[:TYPE_2])
                #  #  at.save
                #  #  area_type = at
                #  #end
              when /GADM/i
              when /level1/
                record = GeographicArea.new(parent_id: earth.id,
                                            name:      item['LEVEL1_NAM'])
                GeographicAreaType.where(name: item[''])
              when /level2/
              when /level3/
              when /level4/
              else
              end

              if !(record.nil?)
                record.geographic_area_type          = area_type[0]

                record.geographic_item               = GeographicItem.new
                record.geographic_item.geography = item.geometry

                record.save!

                raise
                # Update the record to te
                # ApplicationRecord.connection.execute(' ')


                case filename
                when /USA_adm0/
                  # when country, find parent continent
                  # parent_record = GeographicArea.where({parent_id: 0, country_id: 0})[0]
                  parent_record = GeographicArea.new(name:                 'North America',
                                                     geographic_area_type: GeographicAreaType.where(name: 'Continent')[0])
                when /USA_adm1/
                  # when state, find parent country
                  parent_record = GeographicArea.where({state_id: nil, country_id: record.country_id})[0]
                when /USA_adm2/
                  # when county, find parent state
                  parent_record = GeographicArea.where({state_id: record.parent_id})[0]
                else

                end
                count = record.geographic_item.multi_polygon.num_geometries
                ess   = (count == 1) ? '' : 's'
                puts "#{'% 5d' % (item.index + 1)}:  #{record.geographic_area_type.name} of #{record.name} in the #{parent_record.geographic_area_type.name} of #{parent_record.name} => #{count} polygon#{ess}."
              else
                # this processing is specifically for GADM2
                if item.geometry.nil?
                  item_type = 'Bad geometry'
                  count_geo = 0
                else
                  item_type = item.geometry.geometry_type
                  count_geo = item.geometry.num_geometries
                end
                ess = (count_geo == 1) ? 'y' : 'ies'

                snap      = Time.now
                elapsed   = snap - time_then
                time_then = snap
                case filename
                when /GADM/i

                  i5 = item['NAME_5']
                  s5 = i5.empty? ? '' : (i5 + ', ')
                  i4 = item['NAME_4']
                  s4 = i4.empty? ? '' : (i4 + ', ')
                  i3 = item['NAME_3']
                  s3 = i3.empty? ? '' : (i3 + ', ')
                  i2 = item['NAME_2']
                  s2 = i2.empty? ? '' : (i2 + ', ')
                  i1 = item['NAME_1']
                  s1 = i1.empty? ? '' : (i1 + ', ')
                  puts item.attributes
                  puts "#{Time.at(time_then).strftime "%T"}: #{Time.at(elapsed).getgm.strftime "%H:%M:%S"}: #{item_type}#{'% 5d' % (item.index + 1)} (of #{count} items)(#{count_geo} geometr#{ess}) is called \'#{s5}#{s4}#{s3}#{s2}#{s1}#{item['NAME_0']}\'."
                when /level1/
                  puts "#{Time.at(time_then).strftime "%T"}: #{Time.at(elapsed).getgm.strftime "%H:%M:%S"}: #{item['LEVEL1_COD']}, #{item['LEVEL1_NAM']}:  #{item_type}, (#{count_geo} geometr#{ess})"
                when /level2/
                  puts "#{Time.at(time_then).strftime "%T"}: #{Time.at(elapsed).getgm.strftime "%H:%M:%S"}: #{item['LEVEL2_COD']}, #{item['LEVEL2_NAM']}, #{item['LEVEL1_NAM']}:  #{item_type}, (#{count_geo} geometr#{ess})"
                when /level3/
                  o1 = Time.at(time_then).strftime '%T'
                  o2 = Time.at(elapsed).getgm.strftime '%H:%M:%S'
                  o3 = item['LEVEL2_COD']
                  o4 = item['LEVEL3_COD']
                  o5 = item['LEVEL3_NAM']
                  o6 = item_type
                  o7 = count_geo
                  o8 = ess
                  puts "#{o1}: #{o2}: #{o3}#{o4}, #{o5}:  #{o6}, (#{o7} geometr#{o8})"
                when /level4/
                  # "ISO_Code","Level_4_Na","Level4_cod","Level4_2","Level3_cod","Level2_cod","Level1_cod"
                  o1 = Time.at(time_then).strftime '%T'
                  o2 = Time.at(elapsed).getgm.strftime '%H:%M:%S'
                  o3 = item['ISO_Code']
                  o9 = item['Level2_cod']
                  o4 = item['Level4_cod']
                  o5 = item['Level_4_Na']
                  o6 = item_type
                  o7 = count_geo
                  o8 = ess

                  puts "#{o1}: #{o2}: #{o3}: #{o9}#{o4},  #{o5}:  #{o6}, (#{o7} geometr#{o8})"
                else
                end

              end
            }
          } if !(filename =~ /[0]/)
        end
      end
    end
  end
end
