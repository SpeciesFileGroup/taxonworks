namespace :tw do
  namespace :project_import do
    namespace :sf_import do
      require 'fileutils'
      require 'logged_task'
      namespace :specimens do

        desc 'time rake tw:project_import:sf_import:specimens:collecting_events user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        LoggedTask.define :collecting_events => [:data_directory, :environment, :user_id] do |logger|

          logger.info 'Building new collecting events...'

          import            = Import.find_or_create_by(name: 'SpeciesFileData')
          get_tw_project_id = import.get('SFFileIDToTWProjectID')

          get_tw_collecting_event_id = {} # key = sfUniqueLocColEvents.UniqueID, value = TW.collecting_event_id

          # SF.TimePeriodID to interval code (https://paleobiodb.org/data1.2/intervals/single.json?name='')
          TIME_PERIOD_MAP            = {
            768  => 1, # Cenozoic
            784  => 12, # Quaternary
            790  => 32, # Holocene
            795  => 33, # Pleistocene
            800  => 13, # Tertiary
            804  => 25, # Neogene
            805  => 34, # Pliocene
            806  => 35, # Miocene
            808  => 26, # Paleogene
            809  => 36, # Oligocene
            810  => 37, # Eocene
            811  => 38, # Paleocene
            1024 => 2, # Mesozoic
            1040 => 14, # Cretaceous
            1056 => 15, # Jurassic
            1072 => 16, # Triassic
            1280 => 3, # Paleozoic
            1296 => 17, # Permian
            1312 => 18, # Carboniferous
            1316 => 27, # Pennsylvanian
            1320 => 28, # Mississippian
            1328 => 19, # Devonian
            1344 => 20, # Silurian
            1360 => 21, # Ordovician
            1376 => 22, # Cambrian
            # 1536 => nil,  # Precambrian
            1552 => 752, # Proterozoic
            1568 => 753, # Archaean vs. Archean
            1584 => 11 # Hadean
          }.freeze

          path          = @args[:data_directory] + 'sfUniqueLocColEvents.txt'
          file          = CSV.read(path, col_sep: "\t", quote_char: '"', headers: true, encoding: 'BOM|UTF-8')

          # FileID
          # Level1ID	Level2ID	Level3ID	Level4ID
          # Latitude	Longitude	PrecisionCode
          # Elevation	MaxElevation
          # TimePeriodID
          # LocalityDetail
          # TimeDetail
          # DataFlags, ignore: bitwise, 1 = ecological relationship, 2 = character data (not implemented?), 4 = image, 8 = sound, 16 = include specimen locality in maps, 32 = image of specimen label
          # Country	State	County
          # BodyOfWater
          # PrecisionRadius
          # LatLongFrom, ignore
          # CollectorName
          # Year MonthDay
          # DaysToEnd
          # UniqueID

          counter       = 0
          error_counter = 0

          file.each do |row|
            project_id = get_tw_project_id[row['FileID']]

            logger.info "Working with TW.project_id = #{project_id}, UniqueID = #{row['UniqueID']} (count #{counter += 1}) \n"

            # handle dates
            start_date_year                             = nil
            end_date_year, end_date_month, end_date_day = nil, nil, nil

            if row['Year'] != '0'
              end_date = nil

              if row['DaysToEnd'].present?
                y = row['Year'] == '1000' ? '2000' : row['year']

                start_date = Date.new([y.to_i, row['Month'].to_i, row['Day'].to_i].join('/'))
                end_date   = row['DaysToEnd'].to_i.days.since(start_date)
              end

              if end_date
                end_date_year, end_date_month, end_date_day = end_date.year, end_date.month, end_date.day
              end

              end_date_year   = nil if row['Year'] == '1000'
              start_date_year = row['Year'] == '1000' ? nil : row['Year'].to_i

            end


            data_attributes_bucket = {
              data_attributes_attributes: [],
              # project_id: project_id  # cannot universally assign project_id to all array attribute hashes
              # rest of housekeeping?
            }


            if row['TimeDetail'].present?
              time_detail = {type: 'ImportAttribute', import_predicate: 'TimeDetail', value: row['TimeDetail'], project_id: project_id}
              data_attributes_bucket[:data_attributes_attributes].push(time_detail)
            end

            if row['BodyOfWater'].present?
              body_of_water = {type: 'ImportAttribute', import_predicate: 'BodyOfWater', value: row['BodyOfWater'], project_id: project_id}
              data_attributes_bucket[:data_attributes_attributes].push(body_of_water)
            end

            p_code = row['PrecisionCode'].to_i
            if p_code > 0
              value = case p_code
                        when 1 then
                          'from locality label'
                        when 2 then
                          'estimated from map and locality label'
                        when 3 then
                          'based on county or similar modest area specified on locality label'
                        when 4 then
                          'estimated from less specific locality label'
                        else
                          'error'
                      end

              precision_code = {type: 'ImportAttribute', import_predicate: 'PrecisionCode', value: value, project_id: project_id}
              data_attributes_bucket[:data_attributes_attributes].push(precision_code)
            end


            # metadata = {
            #     # data_attributes_attributes: data_attributes_bucket
            #
            #
            # }.merge(data_attributes_bucket)

            c = CollectingEvent.new(
              verbatim_latitude:  row['Latitude'],
              verbatim_longitude: row['Longitude'],
              maximum_elevation:  row['MaxElevation'],
              collectors:         row['CollectoName'],
              start_date_day:     (row['Day'].present? ? row['Day'].to_i : nil),
              start_date_month:   (row['Month'].present? ? row['Month'].to_i : nil),
              start_date_year:    start_date_year,
              end_date_day:       end_date_day,
              end_date_month:     end_date_month,
              end_date_year:      end_date_year,
              geographic_area:    get_tw_geographic_area(row, logger),

              project_id:         project_id,
            # paleobio_db_interval_id: TIME_PERIOD_MAP[row['TimePeriodID']], # TODO: Matt add attribute to CE !! rember ENVO implications

            ).merge(data_attributes_bucket)


            begin
              c.save!
              logger.info "UniqueID #{row['UniqueID']} written"

              get_tw_collecting_event_id[row['UniqueID']] = c.id.to_s

              begin
                c.generate_verbatim_data_georeference(true, true) # reference self, no cache (c.georeferences.any? is true, then succeeded)
                c.georeferences[0].error_radius = row['PrecisionRadius'].to_i unless row['PrecisionRadius'] == '0'

              rescue ActiveRecord::RecordInvalid

                logger.error "Error: TW.project_id = #{project_id}, UniqueID = #{row['UniqueID']} (error count #{error_counter += 1}) \n"
              end


              #   # Don't know if nested attribute objects can have conditions, e.g., only make this object if condition > 0
              #   if row['TimeDetail'].present?
              #     da = DataAttribute.new(type: 'ImportAttribute',
              #                            attribute_subject_id: c.id,
              #                            attribute_subject_type: CollectingEvent,
              #                            import_predicate: 'TimeDetail',
              #                            value: row['TimeDetail'],
              #                            project_id: project_id)
              #     begin
              #       da.save!
              #       puts 'DataAttribute TimeDetail created'
              #
              #
              #     rescue ActiveRecord::RecordInvalid # da not valid
              #       logger.error "DataAttribute TimeDetail ERROR SF.UniqueID #{row['UniqueID']} = TW.collecting_event #{c.id} (#{error_counter += 1}): " + da.errors.full_messages.join(';')
              #     end
              #   end
              #
              #   if row['BodyOfWater'].present?
              #     da = DataAttribute.new(type: 'ImportAttribute',
              #                            attribute_subject_id: c.id,
              #                            attribute_subject_type: CollectingEvent,
              #                            import_predicate: 'BodyOfWater',
              #                            value: row['BodyOfWater'],
              #                            project_id: project_id)
              #     begin
              #       da.save!
              #       puts 'DataAttribute BodyOfWater created'
              #     rescue ActiveRecord::RecordInvalid # da not valid
              #       logger.error "DataAttribute BodyOfWater ERROR SF.UniqueID #{row['UniqueID']} = TW.collecting_event #{c.id} (#{error_counter += 1}): " + da.errors.full_messages.join(';')
              #     end
              #   end
              #
              #
              # rescue ActiveRecord::RecordInvalid
              #
              #   logger.info "Failed on UniqueID #{row['UniqueID']}"
              #
            end


          end

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          import.set('SFUniqueIDToTWCollectingEventID', get_tw_collecting_event_id)

          puts 'SFUniqueIDToTWCollectingEventID'
          ap get_tw_collecting_event_id

        end

        # Find a TW geographic_area
        # @todo JDT HELP!
        def get_tw_geographic_area(row, logger)
          begin
            # text of Country/State/County not used to determine the GA (GeographicArea)

            # TDWG data used to determine GA
            #   if level4 = '---'
            #     resolve to level3
            #   else
            #     if level4 is alpha
            #       resolve to level4
            #     else
            #       resolve level4 name from GeoLevel4 translater
            #       resolve by name from level3:level4 (Illinois:Champaign)
            #         (don't udr level1:level2, because they do not always resolve to country:state names.)
            #       if no resolution
            #         no resolution, return nil
            #       end
            #     end
            #   end
          end

          begin
            # tw_areas  = GeographicArea.none
            # # best indication of place is lat_long
            # lat, long = row['Latitude'].to_f, row['Longitude'].to_f
            # unless lat * long == 0.0
            #   tw_areas << GeographicArea(lat, long)
            # end
            #
            # location_string = [row['Country'],
            #                    row['State'],
            #                    row['County']].join(':')
            #
            # unless location_string.blank?
            #   tw_areas = GeographicArea.matching(location_string, true, true)
            # end
          end
          # we can lookup TDWG id, is this enough to represent country/state/county
          tdwg_id = [row['Level1ID'].chomp('0'),
                     row['Level2ID'].chomp('-'),
                     row['Level3ID'].chomp('---'),
                     ('-' + row['Level4ID']).chomp('---').chomp('-') # TODO: we have to pad dashes here to match off values
          ].select {|a| a.length > 0}.join

          # l1, l2, l3, l4 = row['Level1ID'], row['Level2ID'], row['Level3ID'], row['Level4ID']
          # tdwg_id        = ''
          # tdwg_id        += l1 unless (l1.blank? or l1 == '0')
          # tdwg_id        += l2 unless l2 == '-'
          # tdwg_id        += l3 unless l3 == '---'
          # tdwg_id        += "-#{l4}" unless l4 == '---'

          # TODO if level 4 is a number, look up county name in SFGeoLevel4

          logger.info "target tdwg id: #{tdwg_id}"

          # Lookup the TDWG geographic area
          tw_areas << GeographicArea.where(tdwgID: tdwg_id).first # .last.tdwgID

          # Find values in country/state/county
          finest_sf_level = [row['Country'],
                             row['State'],
                             row['County']
          ].select {|a| (not a.blank?)}

          # If there is no political division, just return the tdwg based match
          if finest_sf_level.empty?
            return tw_areas.first

            # If a value is provided for country/state/county, and that value matches the name we found for tdwg, we're done
          elsif tw_areas.name == finest_sf_level.last
            return tw_areas.first

          else
            # TODO: do something else
            return nil
          end

        end


        desc 'time rake tw:project_import:sf_import:specimens:import_two_specimen_lists user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        LoggedTask.define :import_two_specimen_lists => [:data_directory, :environment, :user_id] do |logger|
          # Can be run independently at any time

          logger.info 'Running new specimen lists (hash, array)...'

          get_new_preserved_specimen_id = [] # array of SF.SpecimenIDs with BasisOfRecord = 0 (not stated) but with DepoID or specimen count
          get_sf_unique_id              = {} # key = SF.SpecimenID, value = sfUniqueLocColEvents.UniqueID


          logger.info '1. Getting new preferred specimen ids'

          path = @args[:data_directory] + 'sfAddPreservedSpecimens.txt'
          file = CSV.read(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

          file.each do |row|
            get_new_preserved_specimen_id.push(row[0])
          end


          logger.info '2. Getting SF SpecimenID to UniqueID hash'

          count = 0

          path = @args[:data_directory] + 'sfSpecimenToUniqueIDs.txt'
          file = CSV.read(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

          file.each do |row|
            puts "SpecimenID = #{row['SpecimenID']}, count #{count += 1} \n"
            get_sf_unique_id[row['SpecimenID']] = row['UniqueLocColEventID']
          end


          import = Import.find_or_create_by(name: 'SpeciesFileData')
          import.set('SFNewPreservedSpecimens', get_new_preserved_specimen_id)
          import.set('SFSpecimenToUniqueIDs', get_sf_unique_id)

          puts 'SFNewPreservedSpecimens'
          ap get_new_preserved_specimen_id

          puts 'SFSpecimenToUniqueIDs'
          ap get_sf_unique_id
        end

      end
    end
  end
end

