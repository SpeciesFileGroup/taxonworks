namespace :tw do
  namespace :project_import do
    namespace :sf_import do
      require 'fileutils'
      require 'logged_task'
      namespace :specimens do

        desc 'time rake tw:project_import:sf_import:specimens:collection_objects user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        LoggedTask.define :collection_objects => [:data_directory, :environment, :user_id] do |logger|

          logger.info 'Importing specimen records as collection objects...'

          # total (see below)
          # type (Specimen, Lot, RangedLot --  Dmitry uses lot, not ranged lot)
          # preparation_type_id (TW integer, include SF text as data attribute?)
          # respository_id (Dmitry manually reconciled these); manually reconciled, not all will be found, add sf_depo_id and sf_depo_string as attribute
          # buffered_collecting_event (no SF data)
          # buffered_determinations (no SF data)
          # buffered_other_labels (no SF data)
          # ranged_lot_category_id (leave nil)
          # collecting_event_id
          # accessioned_at (no SF data)
          # deaccession_reason (no SF data)
          # deaccessioned_at (no SF data)
          # housekeeping

          # add specimen note
          # add specimen status note (identifier?): 0 = presumed Ok, 1 = missing, 2 = destroyed, 3 = lost, 4 = unknown, 5 = missing?, 6 = destroyed?, 7 = lost?, 8 = damaged, 9 = damaged?, 10 = no data entered
          # specimen dataflags: 1 = ecological relationship, 2 = character data not yet implemented, 4 = image, 8 = sound, 16 = include specimen locality in maps, 32 = image of specimen label

          # About total:
          # @!attribute total
          #   @return [Integer]
          #   The enumerated number of things, as asserted by the person managing the record.  Different totals will default to different subclasses.  How you enumerate your collection objects is up to you.  If you want to call one chunk of coral 50 things, that's fine (total = 50), if you want to call one coral one thing (total = 1) that's fine too.  If not nil then ranged_lot_category_id must be nil.  When =1 the subclass is Specimen, when > 1 the subclass is Lot.

          # cat # = identifier on collecting event, controlled vocab term - create sf.specimen_id to catalog number hash (can do here)
          # where does the biocuration_class_id come from?
          # requires collection_object_id (biological_collection_object_id)
          # basis of record = confidence on collection object
          # preparation type = controlled vocabulary term for collection object
          # specimen count and description = BiocurationClass, object tied to collection_object (??)

          # Columns in tblSpecimens not accounted for:
          #   SpecimenStatus
          #   DepoCatNo -- recorded in hash for now, will be identifier  <<< NO, add as import_attribute
          #   SourceID citation to collection object (refID) + description as import attribute
          #   BasisOfRecord as data_attribute  type 5 will be asserted distribution, ignore 3, 4, and 6 (for all of 5 bor, what doesn't have refid in sourceid)
          #   VerbatimLabel NOT USED in SF, perhaps buffered collecting event


          # no count = 1?

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          get_tw_user_id = import.get('SFFileUserIDToTWUserID') # for housekeeping
          get_tw_project_id = import.get('SFFileIDToTWProjectID')
          get_sf_unique_id = import.get('SFSpecimenToUniqueIDs') # get the unique_id for given SF specimen_id
          get_tw_collecting_event_id = import.get('SFUniqueIDToTWCollectingEventID') # use unique_id as key to collecting_event_id
          get_tw_repo_id = import.get('SFDepoIDToTWRepoID')
          get_sf_depo_string = import.get('SFDepoIDToSFDepoString')
          get_biocuration_class_id = import.get('SpmnCategoryIDToBiocurationClassID')
          get_specimen_category_counts = import.get('SFSpecimenIDCategoryIDCount')
          get_sf_source_metadata = import.get('SFSourceMetadata')
          get_sf_identification_metadata = import.get('SFIdentificationMetadata')

          get_tw_collection_object_id = {} # key = SF.SpecimenID, value = TW.collection_object.id OR TW.container.id
          # get_depo_catalog_number = {} # key = SF.SpecimenID, value = depo catalog number

          depo_namespace = Namespace.find_or_create_by(institution: 'Species File', name: 'SpecimenDepository', short_name: 'Depo')


          path = @args[:data_directory] + 'tblSpecimens.txt'
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'UTF-16:UTF-8')

          error_counter = 0

          file.each_with_index do |row, i|
            specimen_id = row['SpecimenID']
            next if specimen_id == '0'

            project_id = get_tw_project_id[row['FileID']]

            sf_depo_id = row['DepoID']
            repository_id = get_tw_repo_id.has_key?(sf_depo_id) ? get_tw_repo_id[sf_depo_id] : nil

            collecting_event_id = get_tw_collecting_event_id[get_sf_unique_id[specimen_id]]

            # get otu id from sf taxon name id, a taxon determination, called 'the primary otu id'   (what about otus without tw taxon names?)

            # list of import_attributes:
            basis_of_record_string = []
            # Note: collection_objects are made for all specimen records, regardless of basis of record (for now)
            basis_of_record = row['BasisOfRecord'].to_i
            if basis_of_record > 0
              case basis_of_record
                when 1
                  basis_of_record_string = 'Preserved specimen'
                when 2
                  basis_of_record_string = 'Fossil specimen'
                when 3
                  basis_of_record_string = 'Image (still or video)'
                when 4
                  basis_of_record_string = 'Audio recording'
                when 5
                  basis_of_record_string = 'Checklist/Literature/Map'
                when 6
                  basis_of_record_string = 'Personal observation'
              end
            end

            preparation_type = []
            if row['PreparationType'].present?
              preparation_type = {import_predicate: 'preparation_type',
                                  value: row['PreparationType'],
                                  project_id: project_id}
            end

            specimen_dataflags = []
            dataflags = row['DataFlags'].to_i
            if dataflags > 0
              dataflags_array = Utilities::Numbers.get_bits(dataflags)

              # for bit_position in 0..status_flags_array.length - 1 # length is number of bits set
              dataflag_text = ''
              dataflags_array.each do |bit_position|
                # 1 = ecological relationship, 2 = character data not yet implemented, 4 = image, 8 = sound, 16 = include specimen locality in maps, 32 = image of specimen label
                case bit_position # array use .join(','), flatten?
                  when 0 # ecological relationship (1)
                    dataflag_text = '(ecological relationship)'
                  when 1 # character data not yet implemended (2)
                    dataflag_text.concat('(character data not yet implemented)')
                  when 2 # image (4)
                    dataflag_text.concat('(image)')
                  when 3 # sound (8)
                    dataflag_text.concat('(sound)')
                  when 4 # include specimen locality in maps (16)
                    dataflag_text.concat('(include specimen locality in maps)')
                  when 5 # image of specimen label (32)
                    dataflag_text.concat('(image of specimen label)')
                end

                specimen_dataflags = {import_predicate: 'specimen_dataflags',
                                      value: dataflag_text,
                                      project_id: project_id}
              end
            end

            specimen_status = [] # (disposition) 0 = presumed Ok, 1 = missing, 2 = destroyed, 3 = lost, 4 = unknown, 5 = missing?, 6 = destroyed?, 7 = lost?, 8 = damaged, 9 = damaged?, 10 = no data entered
            specimen_status_id = row['SpecimenStatusID'].to_i
            if specimen_status_id > 0 || specimen_status_id == 10
              case specimen_status_id
                when 1
                  specimen_status = 'missing'
                when 2
                  specimen_status = 'destroyed'
                when 3
                  specimen_status = 'lost'
                when 4
                  specimen_status = 'unknown'
                when 5
                  specimen_status = 'missing?'
                when 6
                  specimen_status = 'destroyed?'
                when 7
                  specimen_status = 'lost?'
                when 8
                  specimen_status = 'damaged'
                when 9
                  specimen_status = 'damaged?'
              end
            end

            sf_source_description = []
            citations_attributes = []
            if row['SourceID'] != '0'
              sf_source_id = row['SourceID']

              if get_sf_source_metadata[sf_source_id][row['RefID']] != '0' # SF.Source has RefID, create citation for collection object (assuming it will be created)
                citations_attributes = {source_id: sf_source_id, project_id: project_id}
              end

              if get_sf_source_metadata[sf_source_id][row['Description']].length > 0 # SF.Source has description, create an import_attribute
                sf_source_description = {import_predicate: 'sf_source_description',
                                         value: row['Description'],
                                         project_id: project_id}
              end
            end

            sf_depo_string = []
            if sf_depo_id > '0'
              sf_depo_string = {import_predicate: 'sf_depo_string',
                                value: get_sf_depo_string[sf_depo_string],
                                project_id: project_id}
            end

            import_attribute_attributes = []
            metadata = {notes_attributes: [{text: row['Note'],
                                            project_id: project_id,
                                            created_at: row['CreatedOn'],
                                            updated_at: row['LastUpdate'],
                                            created_by_id: get_tw_user_id[row['CreatedBy']],
                                            updated_by_id: get_tw_user_id[row['ModifiedBy']]}],

                        import_attributes_attributes: import_attribute_attributes.concat(basis_of_record_string, preparation_type, specimen_dataflags, specimen_status, sf_source_description, sf_depo_string),
                        citations_attributes: citations_attributes,

                        # data_attributes to do:
                        #   import_attribute if identification.IdentifierName

                        # create taxon determination for species this is attached to
                        # create type specimen if tblIdentifications.TypeTaxonNameID maybe


            }

            # At this point all the related metadata except specimen category and count must be set

            begin

              ActiveRecord::Base.transaction do
                current_objects = [] # stores all objects created in the row below temporarily

                # This outer loop loops through total, category pairs, we create
                # a new collection object for each pair
                get_specimen_category_counts[specimen_id].each do |specimen_category_id, count|

                  collection_object = CollectionObject.new(
                      metadata.merge(
                          total: count,
                          collecting_event_id: collecting_event_id,
                          repository_id: repository_id,

                          bicuration_classification_attributes: [{biocuration_class_id: get_biocuration_class_id[specimen_category_id.to_s]}],

                          # housekeeping for collection_object
                          project_id: project_id,
                          created_at: row['CreatedOn'],
                          updated_at: row['LastUpdate'],
                          created_by_id: get_tw_user_id[row['CreatedBy']],
                          updated_by_id: get_tw_user_id[row['ModifiedBy']]
                      ))

                  collection_object.save!

                  current_objects.push(collection_object)

                end

                # At this point the collection objects have been saved successfully


                # 1) if there were two collection objects with the same SF specimen ID, then put them
                # in a virtual container
                # 2) If there is an "identifier", associate it with a single collection object or the container (if applicable)
                identifier = nil
                if row['DepoCatNo']
                  identifier = Identifier::Local::CatalogNumber.create!(
                      namespace: depo_namespace,
                      project_id: project_id,
                      identifier: "SF.DepoID#{sf_depo_id} #{row['DepoCatNo']}"
                  )
                  # identifier = ImportAttribute.new(value: row['DepotCatNo'], import_predicate: 'DepotCatNo', project_id: project_id)
                end

                if current_objects.count == 1
                  # The "Identifier" is attached to the only collection object that is created
                  current_objects.first.identifiers << identifier if identifier

                elsif current_objects > 1
                  # There is more than one object, put them in a virtual container
                  c = Container::Virtual.create!(project_id: project_id)
                  current_objects.each do |o|
                    o.put_in_container(c)
                  end

                  c.identifiers << identifier if identifier

                else
                  puts "OOPS" # would this happen?
                end

                puts 'CollectionObject created'
                get_tw_collection_object_id[specimen_id] = current_objects.collect {|a| a.id} # an arry of collection object ids for this specimen_id

              end

            rescue ActiveRecord::RecordInvalid => e
              logger.error "CollectionObject ERROR SF.SpecimenID = #{specimen_id} (#{error_counter += 1}): " + e.errors.full_messages.join(';')
            end
          end

          import.set('SFSpecimenIDToCollObjID', get_tw_collection_object_id)
          import.set('SFSpecimenIDToCatalogNumber', get_depo_catalog_number)

          puts 'SFSpecimenIDToCollObjID'
          ap get_tw_collection_object_id

          puts 'SFSpecimenIDToCatalogNumber'
          ap get_depo_catalog_number

        end


        desc 'time rake tw:project_import:sf_import:specimens:create_sf_identification_metadata user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        LoggedTask.define :create_sf_identification_metadata => [:data_directory, :environment, :user_id] do |logger|

          logger.info 'Creating SF tblIdentifications metadata...'

          get_sf_identification_metadata = {} # key = SF.SpecimenID, value = array of hashes [{SeqNum => s, relevant columns => etc}, {}]

          path = @args[:data_directory] + 'tblIdentifications.txt'
          file = CSV.read(path, col_sep: "\t", headers: true, encoding: 'UTF-16:UTF-8')

          file.each do |row|
            specimen_id = row['SpecimenID']
            seqnum = row['SeqNum']

            logger.info "Working with SF.SpecimenID = '#{specimen_id}', SeqNum = '#{seqnum}' \n"

            this_ident = {
                :seqnum => seqnum,
                :higher_taxon_name => row['HigherTaxonName'],
                :nomenclator_id => row['NomenclatorID'],
                :taxon_ident_note => row['TaxonIdentNote'],
                :type_kind_id => row['TypeKindID'],
                :topotype => row['Topotype'],
                :type_taxon_name_id => row['TypeTaxonNameID'],
                :ref_id => row['RefID'],
                :identifier_name => row['IdentifierName'],
                :year => row['Year'],
                :place_in_collection => row['PlaceInCollection'],
                :identification_mode_note => row['IdentificationModeNote'],
                :verbatim_label => row['VerbatimLabel']
            }

            if get_sf_identification_metadata[specimen_id] # this is the same SpecimenID as last row with another seqnum, add another identification record
              get_sf_identification_metadata[specimen_id].push this_ident

            else # this is a new SpecimenID, start new identification
              get_sf_identification_metadata[specimen_id] = [this_ident]
            end

          end

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          import.set('SFIdentificationMetadata', get_sf_identification_metadata)

          puts 'SFIdentificationMetadata'
          ap get_sf_identification_metadata
        end


        desc 'time rake tw:project_import:sf_import:specimens:create_sf_source_metadata user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        LoggedTask.define :create_sf_source_metadata => [:data_directory, :environment, :user_id] do |logger|

          logger.info 'Creating SF tblSources metadata...'

          get_sf_source_metadata = {} # key = SF.SourceID, value = hash (SourceID, FileID, RefID, Description)

          path = @args[:data_directory] + 'tblSources.txt'
          file = CSV.read(path, col_sep: "\t", headers: true, encoding: 'UTF-16:UTF-8')

          file.each do |row|
            source_id = row['SourceID']
            next if source_id == '0'

            logger.info "Working with SF.SourceID = '#{source_id}' \n"

            get_sf_source_metadata[source_id] = {file_id: row['FileID'], ref_id: row['RefID'], description: row['Description']}
          end

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          import.set('SFSourceMetadata', get_sf_source_metadata)

          puts 'SFSourceMetadata'
          ap get_sf_source_metadata
        end


        desc 'time rake tw:project_import:sf_import:specimens:create_specimen_category_counts user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        LoggedTask.define :create_specimen_category_counts => [:data_directory, :environment, :user_id] do |logger|

          logger.info 'Creating specimen category counts...'

          get_specimen_category_counts = {} # key = SF.SpecimenID, value = array [category0, count0] [category1, count1]
          #previous_specimen_id = '0'

          path = @args[:data_directory] + 'tblSpecimenCounts.txt'
          file = CSV.read(path, col_sep: "\t", headers: true, encoding: 'UTF-16:UTF-8')

          file.each do |row|
            specimen_id = row['SpecimenID']
            specimen_category_id = row['SpmnCategoryID'].to_i
            count = row['Count'].to_i.abs

            logger.info "Working with SF.SpecimenID = '#{specimen_id}', specimen_category_id = '#{specimen_category_id}', count = '#{count}' \n"

            if get_specimen_category_counts[specimen_id] # specimen_id == previous_specimen_id # this is the same SpecimenID as last row, add another category/count
              get_specimen_category_counts[specimen_id].push [specimen_category_id, count]

            else # this is a new SpecimenID, start new category/count
              get_specimen_category_counts[specimen_id] = [[specimen_category_id, count]]
              # previous_specimen_id = specimen_id
            end
          end

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          import.set('SFSpecimenIDCategoryIDCount', get_specimen_category_counts)

          puts 'SFSpecimenIDCategoryIDCount'
          ap get_specimen_category_counts
        end


        desc 'time rake tw:project_import:sf_import:specimens:create_biocuration_classes user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        LoggedTask.define :create_biocuration_classes => [:data_directory, :environment, :user_id] do |logger|

          logger.info 'Creating biocuration classes...'

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          get_tw_project_id = import.get('SFFileIDToTWProjectID')

          get_biocuration_class_id = {} # key = SF.tblSpecimenCategories.SpmnCategoryID, value = TW.biocuration_class.id

          path = @args[:data_directory] + 'sfSpecimenCategories.txt'
          file = CSV.read(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

          file.each_with_index do |row, i|
            spmn_category_id = row['SpmnCategoryID']
            next if spmn_category_id == '0'
            project_id = get_tw_project_id[row['FileID']]

            logger.info "Working with SF.SpmnCategoryID '#{spmn_category_id}', SF.FileID '#{row['FileID']}', project.id = '#{project_id}' \n"

            biocuration_class = BiocurationClass.create!(name: row['SingularName'], definition: row['PluralName'], project_id: project_id)
            get_biocuration_class_id[spmn_category_id] = biocuration_class.id.to_s
          end

          import.set('SpmnCategoryIDToBiocurationClassID', get_biocuration_class_id)

          puts 'SpmnCategoryIDToBiocurationClassID'
          ap get_biocuration_class_id
        end


        desc 'time rake tw:project_import:sf_import:specimens:import_sf_depos user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        LoggedTask.define :import_sf_depos => [:data_directory, :environment, :user_id] do |logger|

          logger.info 'Importing SF depo_strings and SF to TW depo/repo mappings...'

          get_sf_depo_string = {} # key = sf.DepoID, value = sf.depo_string
          get_tw_repo_id = {} # key = sf.DepoID, value = tw respository.id; ex. ["23, 25, 567"] => {1 => tw_repo_id, 2 => tw_repo_id, 3 => tw_repo_id}
          # Note: Many SF DepoIDs will not be mapped to TW repo_ids

          count_found = 0

          path = @args[:data_directory] + 'sfDepoStrings.txt'
          file = CSV.read(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

          file.each_with_index do |row, i|
            depo_id = row['DepoID']

            depo_string = row['DepoString']

            logger.info "Working with SF.DepoID '#{depo_id}', SF.NomenclatorString '#{depo_string}' (count #{count_found += 1}) \n"

            get_sf_depo_string[depo_id] = depo_string
          end

          path = @args[:data_directory] + 'sfTWDepoMappings.txt'
          file = CSV.read(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

          file.each_with_index do |row, i|
            sf_depo_id_array = row['SFDepoIDarray']
            next if sf_depo_id_array.blank?

            tw_repo_id = row['TWDepoID']
            logger.info "Working with TWD/RepoID '#{tw_repo_id}', SFDepoIDarray '#{sf_depo_id_array}' \n"

            sf_depo_id_array = sf_depo_id_array.split(", ").map(&:to_i)
            sf_depo_id_array.each do |each_id|
              get_tw_repo_id[each_id] = tw_repo_id
            end
          end

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          import.set('SFDepoIDToSFDepoString', get_sf_depo_string)
          import.set('SFSpecimenIDToCatalogNumber', get_depo_catalog_number)

          puts 'SFDepoIDToSFDepoString'
          ap get_sf_depo_string

          puts 'SFDepoIDToTWRepoID'
          ap get_tw_repo_id

        end


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
          ap SFGeoLevel4
        end


        desc 'time rake tw:project_import:sf_import:specimens:create_specimen_unique_id user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        LoggedTask.define :create_specimen_unique_id => [:data_directory, :environment, :user_id] do |logger|
          # Can be run independently at any time

          logger.info 'Running new specimen lists (hash, array)...'

          # get_new_preserved_specimen_id = [] # array of SF.SpecimenIDs with BasisOfRecord = 0 (not stated) but with DepoID or specimen count
          get_sf_unique_id = {} # key = SF.SpecimenID, value = sfUniqueLocColEvents.UniqueID


          # logger.info '1. Getting new preferred specimen ids'
          #
          # path = @args[:data_directory] + 'sfAddPreservedSpecimens.txt'
          # file = CSV.read(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')
          #
          # file.each do |row|
          #   get_new_preserved_specimen_id.push(row[0])
          # end


          logger.info '2. Getting SF SpecimenID to UniqueID hash'

          count = 0

          path = @args[:data_directory] + 'sfSpecimenToUniqueIDs.txt'
          file = CSV.read(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

          file.each do |row|
            puts "SpecimenID = #{row['SpecimenID']}, count #{count += 1} \n"
            get_sf_unique_id[row['SpecimenID']] = row['UniqueLocColEventID']
          end


          import = Import.find_or_create_by(name: 'SpeciesFileData')
          # import.set('SFNewPreservedSpecimens', get_new_preserved_specimen_id)
          import.set('SFSpecimenToUniqueIDs', get_sf_unique_id)

          # puts 'SFNewPreservedSpecimens'
          # ap get_new_preserved_specimen_id

          puts 'SFSpecimenToUniqueIDs'
          ap get_sf_unique_id
        end

      end
    end
  end
end

