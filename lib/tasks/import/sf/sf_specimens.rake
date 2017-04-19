namespace :tw do
  namespace :project_import do
    namespace :sf_import do
      require 'fileutils'
      require 'logged_task'
      namespace :specimens do

        desc 'time rake tw:project_import:sf_import:specimens:collecting_events user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        LoggedTask.define :collecting_events => [:data_directory, :environment, :user_id] do |logger|

          logger.info 'Building new collecting events...'

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          get_tw_project_id = import.get('SFFileIDToTWProjectID')

          get_tw_collecting_event_id = {} # key = sfUniqueLocColEvents.UniqueID, value = TW.collecting_event_id

          # SF.TimePeriodID to interval code (https://paleobiodb.org/data1.2/intervals/single.json?name='')
          TIME_PERIOD_MAP = {
              768 => 1, # Cenozoic
              784 => 12, # Quaternary
              790 => 32, # Holocene
              795 => 33, # Pleistocene
              800 => 13, # Tertiary
              804 => 25, # Neogene
              805 => 34, # Pliocene
              806 => 35, # Miocene
              808 => 26, # Paleogene
              809 => 36, # Oligocene
              810 => 37, # Eocene
              811 => 38, # Paleocene
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
          }

          path = @args[:data_directory] + 'sfUniqueLocColEvents.txt'
          file = CSV.read(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

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

          counter = 0
          error_counter = 0

          file.each do |row|
            project_id = get_tw_project_id(row['FileID']).to_i

            logger.info "Working with TW.project_id = #{project_id}, UniqueID = #{row['UniqueID']} (count #{counter += 1}) \n"

            # handle dates
            end_date = nil
            if row['DaysToEnd'].present?
              y = row['year'] == '1000' ? '2000' : row['year']

              start_date = Date.new(
                  [y, row['month'], row['day']].join('/')
              )
              end_date = row['DaysToEnd'].to_i.days.since(start_date)
            end

            end_date_year, end_date_month, end_date_day = nil, nil, nil

            if end_date
              end_date_year, end_date_month, end_date_day = end_date.year, end_date.month, end_date.day
            end

            end_date_year = nil if row['year'] == '1000'
            start_date_year = row['year'] == '1000' ? nil : row['year'].to_i

            # TODO:
            #  PrecisionCode?  integer
            #  handle PrecisionRadius as Georeference precision
            #  some_precisions_radius_conversion   = row['PrecisionRadius'].to_i  * 10 # METERS

            data_attributes_attributes = {
                data_attributes_attributes: [],
                project_id: project_id
                # rest of housekeeping?
            }

            if row['TimeDetail'].present?
              type = 'ImportAttribute'
              import_predicate = 'TimeDetail'
              value = row['TimeDetail']

              data_attributes_attributes[:data_attributes_attributes].push
            end

            if row['BodyOfWater'].present?
              type = 'ImportAttribute'
              import_predicate = 'BodyOfWater'
              value = row['BodyOfWater']

              data_attributes_attributes[:data_attributes_attributes].push
            end

            precision_code = row['PrecisionCode'].to_i
            if precision_code > 0
              type = 'ImportAttribute'
              import_predicate = 'PrecisionCode'
              case precision_code
                when 1 then
                  value = 'from locality label'
                when 2 then
                  value = 'estimated from map and locality label'
                when 3 then
                  value = 'based on county or similar modest area specified on locality label'
                when 4 then
                  value = 'estimated from less specific locality label'
                else
                  value = 'error'
              end

              data_attributes_attributes[:data_attributes_attributes].push
            end


            metadata = {
                data_attributes_attributes: data_attributes_attributes

            }

            c = CollectingEvent.new(
                verbatim_latitude: row['Latitude'],
                verbatim_longitude: row['Longitude'],
                maximum_elevation: row['MaxElevation'],
                collectors: row['CollectoName'],
                start_date_day: (row['day'].present? ? row['day'].to_i : nil),
                start_date_month: (row['month'].present? ? row['month'].to_i : nil),
                start_date_year: start_date_year,
                end_date_day: end_date_day,
                end_date_month: end_date_month,
                end_date_year: end_date_year,
                geographic_area: get_tw_geographic_area(row),

                project_id: get_tw_project_id[row['FileID']],
                paleobio_db_interval_id: TIME_PERIOD_MAP[row['TimePeriodID']], # TODO: Matt add attribute to CE !! rember ENVO implications


            #
            #     # add in data attributes, import_predicate,
            # georeferences_attributes: [
            #     {
            #         type: 'Georeference::VerbatimData',
            #         error_radius: some_precisions_radius_conversion,
            #         geographic_item_attributes: {
            #             # JIM WILL HELP YOU WITH THE Rgeo::Point construction
            #             # basically, the lat long values go here
            #         }
            #
            #     }
            # ],
            #
            #

            #
            ).merge(metadata) # add a .merge(object_name_created_outside_the_main_object)


            begin
              c.save!
              logger.info "UniqueID #{row['UniqueID']} written"

              get_tw_collecting_event_id[row['UniqueID']] = c.id.to_s

              begin
                c.generate_verbatim_data_georeference(true, true) # reference self, no cache (c.georeferences.any? is true, then succeeded)
                c.georeferences[0].error_radius = row['PrecisionRadius'].to_i unless row['PrecisionRadius'] == '0'

              rescue ActiveRecord::RecordInvalid

                logger.error
              end


              # Don't know if embedded attribute objects can have conditions, e.g., only make this object if condition > 0
              if row['TimeDetail'].present?
                da = DataAttribute.new(type: 'ImportAttribute',
                                       attribute_subject_id: c.id,
                                       attribute_subject_type: CollectingEvent,
                                       import_predicate: 'TimeDetail',
                                       value: row['TimeDetail'],
                                       project_id: project_id)
                begin
                  da.save!
                  puts 'DataAttribute TimeDetail created'


                rescue ActiveRecord::RecordInvalid # da not valid
                  logger.error "DataAttribute TimeDetail ERROR SF.UniqueID #{row['UniqueID']} = TW.collecting_event #{c.id} (#{error_counter += 1}): " + da.errors.full_messages.join(';')
                end
              end

              if row['BodyOfWater'].present?
                da = DataAttribute.new(type: 'ImportAttribute',
                                       attribute_subject_id: c.id,
                                       attribute_subject_type: CollectingEvent,
                                       import_predicate: 'BodyOfWater',
                                       value: row['BodyOfWater'],
                                       project_id: project_id)
                begin
                  da.save!
                  puts 'DataAttribute BodyOfWater created'
                rescue ActiveRecord::RecordInvalid # da not valid
                  logger.error "DataAttribute BodyOfWater ERROR SF.UniqueID #{row['UniqueID']} = TW.collecting_event #{c.id} (#{error_counter += 1}): " + da.errors.full_messages.join(';')
                end
              end


            rescue ActiveRecord::RecordInvalid

              logger.info "Failed on UniqueID #{row['UniqueID']}"

            end


          end

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          import.set('SFUniqueIDToTWCollectingEventID', get_tw_collecting_event_id)

        end

        # Find a TW geographic_area
        def get_tw_geographic_area(row)
          # we can lookup TDWG id, is this enough to represent country/state/county
          tdwg_id = [
              row['Level1ID'],
              row['Level2ID'],
              row['Level3ID'],
              row['Level4ID'] # TODO: we have to pad dashes here to match off values
          ].select {|a| a.length > 0}.join

          logger.info "target tdwg id: #{tdwg_id}"

          # Lookup the TDWG geographic area
          tdwg_area = GeographicArea.where(tdwgID: tdwg_id).last.tdwgID

          # Find values in country/state/county
          finest_sf_level = [
              row['country'],
              row['state'],
              row['county']
          ].select {|a| !a.blank?}

          # If there is no value, just return the tdwg based match
          if finest_sf_level.empty?
            return tdwg_area

            # If a value is provided for country/state/county, and that value matches the name we found for tdwg, we're done
          elsif tdwg_area.name == finest_sf_level.last
            return tdwg_area

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
          get_sf_unique_id = {} # key = SF.SpecimenID, value = sfUniqueLocColEvents.UniqueID


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

