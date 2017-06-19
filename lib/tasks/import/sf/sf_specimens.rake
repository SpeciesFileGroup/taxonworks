namespace :tw do
  namespace :project_import do
    namespace :sf_import do
      require 'fileutils'
      require 'logged_task'
      namespace :specimens do

        desc 'time rake tw:project_import:sf_import:specimens:collection_objects user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        LoggedTask.define :collection_objects => [:data_directory, :environment, :user_id] do |logger|

          logger.info 'Building new collection objects...'

          # total
          # type (Specimen, Lot, RangedLot --  Dmitry uses lot, not ranged lot)
          # preparation_type_id (TW integer, include SF text as data attribute?)
          # respository_id (Dmitry manually reconciled these)
          # buffered_collecting_event (no SF data)
          # buffered_determinations (no SF data)
          # buffered_other_labels (no SF data)
          # ranged_lot_category_id
          # collecting_event_id
          # accessioned_at (no SF data)
          # deaccession_reason (no SF data)
          # deaccessioned_at (no SF data)
          # housekeeping
          
          # note with SF.SpecimenID

          # About total:
          # @!attribute total
          #   @return [Integer]
          #   The enumerated number of things, as asserted by the person managing the record.  Different totals will default to different subclasses.  How you enumerate your collection objects is up to you.  If you want to call one chunk of coral 50 things, that's fine (total = 50), if you want to call one coral one thing (total = 1) that's fine too.  If not nil then ranged_lot_category_id must be nil.  When =1 the subclass is Specimen, when > 1 the subclass is Lot.


          # Need count and description (gender, adult): query => sfSpecimenTypeCounts (SpecimenID, FileID, Count, SingularName)
          # If count > 1, use lot
          # If lot contains mixed males, females, adult, nymphs, etc., create a container (have several cases of this in tblSpecimenCounts)
          # @data.biocuration_classes.merge!(
          #     "Specimens" => BiocurationClass.find_or_create_by(name: "Adult", definition: 'Adult specimen', project_id: $project_id),
          #     "Males" => BiocurationClass.find_or_create_by(name: "Male", definition: 'Male specimen', project_id: $project_id),
          #     "Females" => BiocurationClass.find_or_create_by(name: "Female", definition: 'Female specimen', project_id: $project_id),
          #     "Nymphs" => BiocurationClass.find_or_create_by(name: "Immature", definition: 'Immature specimen', project_id: $project_id),
          #     "Exuvia" => BiocurationClass.find_or_create_by(name: "Exuvia", definition: 'Exuvia specimen', project_id: $project_id)
          # )


          import = Import.find_or_create_by(name: 'SpeciesFileData')
          get_tw_project_id = import.get('SFFileIDToTWProjectID')







          
          end


          #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        desc 'time rake tw:project_import:sf_import:specimens:collecting_events user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        LoggedTask.define :collecting_events => [:data_directory, :environment, :user_id] do |logger|

          logger.info 'Building new collecting events...'

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          get_tw_project_id = import.get('SFFileIDToTWProjectID')
          get_sf_geo_level4 = import.get('SFGeoLevel4')

          # var = get_sf_geo_level4['lskdfj']['Name']

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
          }.freeze

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

          # Working with TW.project_id = 3, UniqueID = 42414 (count 42414): Year 1993, Month 2, Day 29 (not a leap year), FileID = 1, TaxonNameID = 1140695, CollectEventID = 6584
          # ActiveRecord::RecordInvalid: Validation failed: Start date day 29 is not a valid start_date_day for the month provided
          # [0] 1993,
          # [1] 2,
          # [2] 29,
          # [3] nil,
          # [4] nil,
          # [5] nil


          file.each do |row|
            project_id = get_tw_project_id[row['FileID']]

            logger.info "Working with TW.project_id = #{project_id}, UniqueID = #{row['UniqueID']} (count #{counter += 1}) \n"

            this_year, this_month, this_day = row['Year'], row['Month'], row['Day']

            # in rescue below, used collect_event.errors vs. c.error
            # if (this_year == '1900' || this_year == '1993') && this_month == '2' && this_day == '29'
            #   this_month, this_day = '3', '1'
            # end

            d = this_day != "0"
            m = this_month != "0"
            y = !((this_year == "1000") || (this_year == "0"))
            dte = row['DaysToEnd'].to_i.abs != 0

            start_date_year, start_date_month, start_date_day,
                end_date_year, end_date_month, end_date_day =

                case [y, m, d, dte] # year, month, day, days_to_end

                  when [true, true, true, true] # have (year, month, day, days_to_end)

                  when [true, true, true, false] # have (year, month, day), no days_to_end
                    [this_year.to_i, this_month.to_i, this_day.to_i, nil, nil, nil]

                  when [true, true, false, false] # have (year, month), no (day, days_to_end)
                    [this_year.to_i, this_month.to_i, nil, nil, nil, nil]

                  when [true, false, false, false] # have year, no (month, day, days_to_end)
                    [this_year.to_i, nil, nil, nil, nil, nil]

                  when [false, true, true, false] # no year, have (month, day), no days_to_end
                    [nil, this_month.to_i, this_day.to_i, nil, nil, nil]

                  when [false, true, true, true] # no year, have (month, day, days_to_end)
                    sdm = this_month.to_i
                    sdd = this_day.to_i
                    dte = row['DaysToEnd'].to_i.abs
                    start_date = Date.new(1999, sdm, sdd) # an arbitrary non-leap year
                    end_date = dte.days.from_now(start_date)

                    [nil, sdm, sdd, nil, end_date.month, end_date.year]

                  else
                    [nil, nil, nil, nil, nil, nil]
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

            location_string = {type: 'ImportAttribute', import_predicate: 'CountryStateCounty',
                               value: [row['Country'], row['State'], row['County']].join(':'), project_id: project_id}
            data_attributes_bucket[:data_attributes_attributes].push(location_string)

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

            # do we still need next line?
            # start_date_year, end_date_year = nil, nil if row['Year'] == "1000"

            ap [start_date_year, start_date_month, start_date_day, end_date_year, end_date_month, end_date_day]

            # metadata = {
            #     # data_attributes_attributes: data_attributes_bucket
            #
            #
            # }.merge(data_attributes_bucket)


            lat, long = row['Latitude'], row['Longitude']
            c = CollectingEvent.new(
                {
                    verbatim_latitude: (lat.length > 0) ? lat : nil,
                    verbatim_longitude: (long.length > 0) ? long : nil,
                    maximum_elevation: row['MaxElevation'].to_i,
                    verbatim_locality: row['LocalityDetail'],
                    verbatim_collectors: row['CollectorName'],
                    start_date_day: start_date_day,
                    start_date_month: start_date_month,
                    start_date_year: start_date_year,
                    end_date_day: end_date_day,
                    end_date_month: end_date_month,
                    end_date_year: end_date_year,
                    geographic_area: get_tw_geographic_area(row, logger, get_sf_geo_level4),

                    project_id: project_id
                    # paleobio_db_interval_id: TIME_PERIOD_MAP[row['TimePeriodID']], # TODO: Matt add attribute to CE !! rember ENVO implications
                }.merge(data_attributes_bucket)
            )

            begin
              c.save!
              logger.info "UniqueID #{row['UniqueID']} written"

              get_tw_collecting_event_id[row['UniqueID']] = c.id.to_s

              begin
                pr = row['PrecisionRadius'].to_i
                c.generate_verbatim_data_georeference(true, no_cached: true) # reference self, no cache
                if c.georeferences.any?
                  c.georeferences[0].error_radius = pr unless pr == '0'
                else
                  # georeference failed (bad lat/long?)
                end

              rescue ActiveRecord::RecordInvalid

                logger.error "Error: TW.project_id = #{project_id}, UniqueID = #{row['UniqueID']} (error count #{error_counter += 1}) \n"
              end

            rescue ActiveRecord::RecordInvalid # bad date?
              logger.error "CollectEvent error: FileID = #{row['FileID']}, UniqueID = #{row['UniqueID']}, Year = #{this_year}, Month = #{this_month}, Day = #{this_day}, DaysToEnd = #{row['DaysToEnd']}, (error count #{error_counter += 1})" + c.errors.full_messages.join(';')
              next
            end
          end

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          import.set('SFUniqueIDToTWCollectingEventID', get_tw_collecting_event_id)

          puts 'SFUniqueIDToTWCollectingEventID'
          ap get_tw_collecting_event_id

        end

        # Find a TW geographic_area
        # @todo JDT HELP!
        def get_tw_geographic_area(row, logger, sf_geo_level4_hash)

          tw_area = nil
          l1, l2, l3, l4 = row['Level1ID'], row['Level2ID'], row['Level3ID'], row['Level4ID']
          l1 = '' if l1 == '0'
          l2 = '' if l2 == '-'
          l3 = '' if l3 == '---'
          l4 = '' if l4 == '---'
          t1 = l1
          t2 = t1 + l2
          t3 = t2 + l3
          tdwg_id = l1
          tdwg_id = t3 if l4 == ''
          tdwg_id = t2 if l3 == ''
          tdwg_id = t1 if l2 == ''
          tdwg_id.strip!

          if tdwg_id.blank?
            case l4
              when /\d+/ # any digits, needs translation
                # TODO @MB if level 4 is a number, look up county name in SFGeoLevel4
                # packet = 0
                name = sf_geo_level4_hash[(t3 + t4)][:name].chomp('County').strip
                tw_area = GeographicArea.where("\"tdwgID\" like '#{t3}%' and name like '%#{name}%'").first
              when /[a-z]/i # if it exists, it might be directly findable
                tdwg_id = (t3 + '-' + l4).strip
                tw_area = GeographicArea.where(tdwgID: tdwg_id).first
                if tw_area.nil? # fall back to next larger container
                  tw_area = GeographicArea.where(tdwgID: t3).first
                end
              else # must be ''
                tw_area = GeographicArea.where(tdwgID: t3).first
            end
          end

          logger.info "target tdwg id: #{tdwg_id}"

          tw_area
        end

        desc 'time rake tw:project_import:sf_import:specimens:create_sf_geo_level4_hash user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        # consists of unique_key: (level3_id, level4_id, name, country_code)
        LoggedTask.define :create_sf_geo_level4_hash => [:data_directory, :environment, :user_id] do |logger|
          # Can be run independently at any time

          logger.info 'Running create_sf_geo_level4_hash...'

          get_sf_geo_level4 = {} # key = unique_key (combined level3_id + level4_id), value = level3_id, level4_id, name, country_code (from tblGeoLevel4)

          path = @args[:data_directory] + 'sfGeoLevel4.txt'
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

          file.each_with_index do |row, i|

            logger.info "working with UniqueKey #{row['UniqueKey']}"

            get_sf_geo_level4[row['UniqueKey']] = {level3_id: row['Level3ID'], level4_id: row['Level4ID'], name: row['Name'], country_code: row['CountryCode']}
          end

          puts 'Getting ready to display results -- takes longer than it seems it should!'

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          import.set('SFGeoLevel4', get_sf_geo_level4)

          puts 'SFGeoLevel4'
          ap get_sf_geo_level4
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

