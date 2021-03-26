require 'fileutils'
require 'benchmark'
# rake tw:db:restore backup_directory=/Users/proceps/src/dump/ file=taxonworks_production_2020-09-28.dump

namespace :tw do
  namespace :project_import do
    namespace :insects_update1 do

      IMPORT_NAME = 'insects'.freeze

      # A utility class to index data.
      class ImportedData2
        attr_accessor :people_id, :keywords, :user_index, :collection_objects, :namespaces, :people_index, #:otus,
                      :preparation_types, :taxa_index, :localities_index, :host_plant_index, :collecting_event_index,
                      :unmatched_localities, :invalid_specimens, :unmatched_taxa, :duplicate_specimen_ids, :rooms,
                      :partially_resolved_index, :biocuration_classes, :biological_properties, :biological_relationships, :loans, :loan_invoice_speciments
        def initialize()
          @keywords = {}                  # keyword -> ControlledVocabularyTerm
          @namespaces = {}                # SpecimenIDPrefix -> NameSpace class
          @preparation_types = {}         # PreparationType -> PreparationType class
          @people_index = {}              # PeopleID -> Person object
          @people_id = {}                 # PeopleID -> People row
          @user_index = {}                # PeopleID -> User object
          #@otus = {}                      # TaxonCode -> OtuID
          @taxa_index = {}                # TaxonCode -> Protonym object
          @collecting_event_index = {}
          @collection_objects = {}
          @localities_index = {}          #LocalityCode -> Locality row
          @host_plant_index = {}

          @unmatched_localities = {}
          @invalid_specimens = {}
          @unmatched_taxa = {}
          @duplicate_specimen_ids = {}
          @partially_resolved_index = {}
          @biocuration_classes = {}
          @biological_properties = {}
          @biological_relationships = {}
          @loan_invoice_speciments = {}
          @loans = {}
          @rooms = {}
        end

      end

      @invalid_collecting_event_index = {}
      #  @redis = Redis.new

      GEO_NAME_TRANSLATOR = {
          'Unknown' => '',
          'U.S.A.' => 'United States',
          'U. S. A.' => 'United States',
          'Quebec' => 'Québec',
          'U.S.A' => 'United States',
          'MEXICO' => 'Mexico',
          'U. S. A. ' => 'United States'
      }.freeze

      def geo_translate(name)
        GEO_NAME_TRANSLATOR[name] ? GEO_NAME_TRANSLATOR[name] : name
      end

      # Attributes to use from specimens.txt
      SPECIMENS_COLUMNS = %w{LocalityCode DateCollectedBeginning DateCollectedEnding Collector CollectionMethod Habitat}.freeze

      # Attributes to strip on CollectingEvent creation
      STRIP_LIST = %w{ModifiedBy ModifiedOn CreatedBy CreatedOn Latitude Longitude Elevation}.freeze # the last three are calculated

      desc "Import the INHS insect collection dataset.\n
      rake tw:project_import:insects_update1:import_insects1 data_directory=/Users/proceps/src/sf/import/inhs-insect-collection-data/  \n
      alternately, add: \n
        restore_from_dump=true   (attempt to load the data from the dump) \n
        no_transaction=true      (don't wrap import in a transaction, this will also force a dump of the data)\n"
      task import_insects1: [:environment, :data_directory] do |t, args|
        puts @args
        Utilities::Files.lines_per_file(Dir["#{@args[:data_directory]}/TXT/**/*.txt"])

        @dump_directory = dump_directory(@args[:data_directory])
        @data1 = ImportedData2.new
        #        restore_from_pg_dump if ENV['restore_from_dump'] && File.exists?(@dump_directory + 'all.dump')

        begin
            main_build_loop_insects1
        rescue
          raise
        end
      end

      # handle the tables in this order
      #--- mostly done
      #  people.txt
      #  taxa_hierarchical.txt
      #--- mostly done
      #  localities.txt
      #  geography.txt
      #  accessions_new.txt
      #  associations.txt
      #  collection_profile.txt
      #  ledgers.txt
      #  letters.txt
      #  loan_reminders.txt
      #  loan_specimen.txt
      #  loans.txt
      #  specimens.txt
      #  specimens_from_3i.txt
      #  specimens_new.txt
      #  specimens_new_partially_resolved.txt
      #  types.txt
      #  neon.txt

      def main_build_loop_insects1


        handle_projects_and_users_insects1(@data1)
        raise '$project_id or $user_id not set.'  if Current.project_id.nil? || Current.user_id.nil?

        build_localities_index_insects1(@data1)

        puts 'Indexing collecting events.'

        #  index_collecting_events_from_accessions_new1(@data1)
        #  index_collecting_events_from_ledgers1(@data1)

        index_specimen_records_from_specimens_insects_new1(@data1)

        puts "\n!! Unmatched localities: (#{@data1.unmatched_localities.keys.count}): " + @data1.unmatched_localities.keys.sort.join(', ')
        puts "\n!! Unmatched taxa: (#{@data1.unmatched_taxa.keys.count}): " + @data1.unmatched_taxa.keys.sort.join(', ')
        puts "\n!! Invalid_specimens: (#{@data1.invalid_specimens.keys.count}): " + @data1.invalid_specimens.sort.join(', ')
        puts "\n!! Duplicate_specimen_IDs: (#{@data1.duplicate_specimen_ids.keys.count}): " + @data1.duplicate_specimen_ids.sort.join(', ')

        puts "\n\n !! Success \n\n"
      end


      def handle_projects_and_users_insects1(data)
        print 'Handling projects and users '
        email = 'arboridia@gmail.com'
        $user_id, $project_id, @collection_container = nil, nil, nil
        Current.user_id = User.where(email: email).first.id
        Current.project_id = Project.find(1).id

      end









      $found_geographic_areas = {}
      $matchless_for_geographic_area ={}

      LOCALITY_COLUMNS = %w{
           Country
           State
           County
           Locality
           Park
           BodyOfWater
           DrainageBasinLesser
           DrainageBasinGreater
           StreamSize
           INDrainage
           WisconsinGlaciated
           NS
           Lat_deg
           Lat_min
           Lat_sec
           EW
           Long_deg
           Long_min
           Long_sec
           Elev_m
           Elev_ft
           Datum
           PrecisionCode
           Habitat
           Host
           DateCollectedBeginning
           DateCollectedEnding
           Collector
           CollectionMethod
           Comments
           GPSSource
           CollectionDateAccuracy
           SamplingProtocol
           SiteCode

            LedgersComments
            Remarks
            LedgersCountry
            LedgersState
            LedgersCounty
            LedgersLocality
            Description
            Family
            Genus
            HostGenus
            HostSpecies
            LedgerBook
            Order
            Sex
            Species}.freeze

      def find_or_create_collecting_event_insects1(ce, data)
        #         byebug
        tmp_ce = { }
        LOCALITY_COLUMNS.each do |c|
          tmp_ce[c] = ce[c] unless ce[c].blank?
        end
        tmp_ce_sorted = tmp_ce.sort.to_s
        #        c_from_redis = @redis.get(Digest::MD5.hexdigest(tmp_ce_sorted))
        c_from_redis = data.collecting_event_index[Digest::MD5.hexdigest(tmp_ce_sorted)]

        unless ce['AccessionNumber'].blank?
          cached_identifier = nil
          if !ce['Collection'].blank?
            cached_identifier =  'Accession Code ' + ce['Collection'] + ' ' + ce['AccessionNumber']
          else
            cached_identifier = 'Accession Code ' + ce['AccessionNumber']
          end
          c = Identifier.where(project_id: Current.project_id, identifier_object_type: 'CollectingEvent', cached: cached_identifier).first.try(:identifier_object)

          if !c.nil? && c_from_redis.nil?
            data.collecting_event_index[Digest::MD5.hexdigest(tmp_ce_sorted)] = c.id
            return c
          end
        end

        if !ce['LocalityLabel'].blank? && ce['LocalityLabel'].to_s.length > 5
          md5 = Utilities::Strings.generate_md5(ce['LocalityLabel'])

          c = CollectingEvent.where(md5_of_verbatim_label: md5, project_id: Current.project_id).first

          if !c.nil? && c_from_redis.nil?
            #@redis.set(Digest::MD5.hexdigest(tmp_ce_sorted), c.id)
            data.collecting_event_index[Digest::MD5.hexdigest(tmp_ce_sorted)] = c.id
            if !ce['AccessionNumber'].blank? && !ce['Collection'].blank?
              c.identifiers.create(identifier: ce['Collection'] + ' ' + ce['AccessionNumber'], namespace: @accession_namespace, type: 'Identifier::Local::AccessionCode')
            elsif !ce['AccessionNumber'].blank?
              c.identifiers.create(identifier: ce['AccessionNumber'], namespace: @accession_namespace, type: 'Identifier::Local::AccessionCode')
            end
            return c
          end
        end

        #        c_from_redis = @redis.get(Digest::MD5.hexdigest(tmp_ce_sorted))
        c_from_redis = data.collecting_event_index[Digest::MD5.hexdigest(tmp_ce_sorted)]

        unless c_from_redis.nil?
          c = CollectingEvent.where(id: c_from_redis).first
          if c.data_attributes.where(import_predicate: 'LocalityCode').nil? && !ce['LocalityCode'].blank?
            c.data_attributes.create(import_predicate: 'LocalityCode', value: ce['LocalityCode'].to_s, type: 'ImportAttribute')
          end
          if c.verbatim_locality.nil? && !ce['LocalityLabel'].nil?
            c.verbatim_locality = ce['LocalityLabel']
            c.save!
          end
          unless ce['AccessionNumber'].nil?
            if !ce['AccessionNumber'].blank? && !ce['Collection'].blank?
              id1 = c.identifiers.new(identifier: ce['Collection'] + ' ' + ce['AccessionNumber'], namespace: @accession_namespace, type: 'Identifier::Local::AccessionCode')
            elsif !ce['AccessionNumber'].blank?
              id1 = c.identifiers.new(identifier: ce['AccessionNumber'], namespace: @accession_namespace, type: 'Identifier::Local::AccessionCode')
            end

            begin
              id1.save!
            rescue ActiveRecord::RecordInvalid
              puts "\nDuplicate identifier: #{ce['AccessionNumber']}\n"
            end

          end
          return c
        end

        latitude, longitude = nil, nil
        latitude, longitude = parse_lat_long_insects(ce) unless [4, 5, 6].include?(ce['PrecisionCode'].to_i)
        sdm, sdd, sdy, edm, edd, edy = parse_dates_insects(ce)
        elevation, verbatim_elevation = parse_elevation_insects(ce)
        geographic_area = parse_geographic_area_insects(ce)
        geolocation_uncertainty = parse_geolocation_uncertainty_insects(ce)
        locality =  ce['Park'].blank? ? ce['Locality'] : ce['Locality'].to_s + ', ' + ce['Park'].to_s
        updated_by = find_or_create_collection_user_insects(ce['ModifiedBy'], data)
        created_by = ce['CreatedBy'].blank? ? updated_by : find_or_create_collection_user_insects(ce['CreatedBy'], data)
        created_on = ce['CreatedOn'].blank? ? ce['ModifiedOn'] : ce['CreatedOn']

        c = CollectingEvent.new(
            geographic_area: geographic_area,
            verbatim_label: ce['LocalityLabel'],
            verbatim_locality: locality,
            verbatim_collectors: ce['Collector'],
            verbatim_method: ce['CollectionMethod'],
            start_date_day: sdd,
            start_date_month: sdm,
            start_date_year: sdy,
            end_date_day: edd,
            end_date_month: edm,
            end_date_year: edy,
            verbatim_habitat: ce['Habitat'],
            minimum_elevation: elevation,
            maximum_elevation: nil,
            verbatim_elevation: verbatim_elevation,
            verbatim_latitude: latitude,
            verbatim_longitude: longitude,
            verbatim_geolocation_uncertainty: geolocation_uncertainty,
            verbatim_datum: ce['Datum'],
            field_notes: ce['CollectionNotes'],
            verbatim_date: nil,
            created_by_id: created_by,
            updated_by_id: updated_by,
            created_at: time_from_field(created_on),
            updated_at: time_from_field(ce['ModifiedOn']),
            no_cached: false
        )

        begin
          c.save!

          c.notes.create(text: ce['Comments']) unless ce['Comments'].blank?

          data.keywords.each do |k|
            c.data_attributes.create(type: 'InternalAttribute', controlled_vocabulary_term_id: k[1].id, value: tmp_ce[k[0]]) unless tmp_ce[k[0]].blank?
          end

          if !ce['AccessionNumber'].blank? && !ce['Collection'].blank?
            c.identifiers.create(identifier: ce['Collection'] + ' ' + ce['AccessionNumber'], namespace: @accession_namespace, type: 'Identifier::Local::AccessionCode')
          elsif !ce['AccessionNumber'].blank?
            c.identifiers.create(identifier: ce['AccessionNumber'], namespace: @accession_namespace, type: 'Identifier::Local::AccessionCode')
          end

          gr = geolocation_uncertainty.nil? ? false : c.generate_verbatim_data_georeference(true, no_cached: true)

          unless gr == false
            gr.is_public = true

            unless gr.id.nil?
              c.update_column(:geographic_area_id, nil)
              gr.no_cached = true
              gr.save # could still be invalid
            end

            # Do a second pass to see if the uncertainty
            gr.error_radius = geolocation_uncertainty

            begin
              gr.no_cached = true
              gr.save!
            rescue ActiveRecord::RecordInvalid
              c.data_attributes.create(type: 'ImportAttribute',
                                       import_predicate: 'georeference_error',
                                       value: 'Geolocation uncertainty is conflicting with geographic area')
            end



          end

          #          @redis.set(Digest::MD5.hexdigest(tmp_ce_sorted), c.id)
          data.collecting_event_index[Digest::MD5.hexdigest(tmp_ce_sorted)] = c.id
          return c
        rescue ActiveRecord::RecordInvalid
          @invalid_collecting_event_index[tmp_ce] = nil
          return nil
        end

      end




      # Index localities by their collective column=>data pairs
      def build_localities_index_insects1(data)
        locality_fields = %w{LocalityCode Country State County Locality Park BodyOfWater NS Lat_deg Lat_min Lat_sec EW Long_deg Long_min Long_sec Elev_m Elev_ft PrecisionCode Comments DrainageBasinLesser DrainageBasinGreater StreamSize INDrainage WisconsinGlaciated OldLocalityCode CreatedOn ModifiedOn CreatedBy ModifiedBy}

        path = @args[:data_directory] + 'TXT/localities.txt'
        raise 'file not found' if not File.exists?(path)
        lo = CSV.open(path, col_sep: "\t", headers: true)

        print "\nIndexing localities..."

        #        localities = {}
        lo.each do |row|
          tmp_l = {}
          locality_fields.each do |c|
            tmp_l[c] = row[c] unless row[c].blank?
          end

          tmp_l['County'] = geo_translate(tmp_l['County']) unless tmp_l['County'].blank?
          tmp_l['State'] = geo_translate(tmp_l['State']) unless tmp_l['State'].blank?
          tmp_l['Country'] = geo_translate(tmp_l['Country']) unless tmp_l['Country'].blank?

          data.localities_index[row['LocalityCode']] = tmp_l
        end
        print "done\n"
      end



      def build_partially_resolved_index1(data)

        locality_fields = %w{LocalityCode Collector CollectionMethod Habitat IdentifiedBy YearIdentified Type TypeName DateCollectedBeginning DateCollectedEnding Host NS Lat_deg Lat_min Lat_sec EW Long_deg Long_min Long_sec Elev_m Elev_ft Country State County Locality Park Remarks Precision Done Georeferenced DeterminationCompare ModifiedBy ModifiedOn}
        match_fields = %w{AccessionNumber DeterminationLabel OtherLabel LocalityLabel}

        path = @args[:data_directory] + 'TXT/specimens_new_partially_resolved.txt'
        raise 'file not found' if not File.exists?(path)
        lo = CSV.open(path, col_sep: "\t", headers: true)

        print 'Indexing partially resolved specimens...'

        ## localities = {}
        lo.each do |row|
          tmp_l = {}
          tmp_m = {}
          match_fields.each do |m|
            tmp_m[m] = row[m] unless row[m].blank?
          end
          locality_fields.each do |c|
            tmp_l[c] = row[c] unless row[c].blank?
          end

          tmp_l['County'] = geo_translate(tmp_l['County']) unless tmp_l['County'].blank?
          tmp_l['State'] = geo_translate(tmp_l['State']) unless tmp_l['State'].blank?
          tmp_l['Country'] = geo_translate(tmp_l['Country']) unless tmp_l['Country'].blank?

          data.partially_resolved_index[tmp_m] = tmp_l if row['Done'] == '1'
        end
        print "done\n"
      end



      def index_host_plants_insects(data)
        # Host
        # TaxonCode
        puts ' host plants from hostplants.txt'
        path = @args[:data_directory] + 'TXT/hostplants.txt'
        raise 'file not found' if not File.exists?(path)

        sp = CSV.open(path, col_sep: "\t", headers: true)

        sp.each_with_index do |row, i|
          print "\r#{i}      "
          data.host_plant_index[row['Host']] = row['TaxonCode'] unless row['TaxonCode'].blank?
        end
      end

      def index_specimen_records_from_specimens_insects_new1(data)
        build_partially_resolved_index(data)
        index_host_plants_insects(data)

        start = data.collecting_event_index.keys.count
        puts "\r specimen records from specimens_new.txt"
        path = @args[:data_directory] + 'TXT/specimens_new.txt'
        raise 'file not found' if not File.exists?(path)

        sp = CSV.open(path, col_sep: "\t", headers: true)

        specimen_fields = %w{ Prefix CatalogNumber PreparationType TaxonCode LocalityCode DateCollectedBeginning DateCollectedEnding Collector LocalityLabel AccessionNumberLabel DeterminationLabel OtherLabel SpecialCollection IdentifiedBy YearIdentified CollectionMethod Habitat Type TypeName Remarks AdultMale AdultFemale Immature Pupa Exuvium AdultUnsexed AgeUnknown OtherSpecimens Checked OldLocalityCode OldCollector OldIdentifiedBy CreatedBy CreatedOn ModifiedOn ModifiedBy }.freeze
        count_fields = %w{ AdultMale AdultFemale Immature Pupa Exuvium AdultUnsexed AgeUnknown OtherSpecimens }.freeze


        locality_fields_with_locality_code = %w{ Collector CollectionMethod Habitat IdentifiedBy YearIdentified Type TypeName DateCollectedBeginning DateCollectedEnding Host Remarks ModifiedBy ModifiedOn }.freeze
        locality_fields_without_locality_code = %w{ Collector CollectionMethod Habitat IdentifiedBy YearIdentified Type TypeName DateCollectedBeginning DateCollectedEnding Host NS Lat_deg Lat_min Lat_sec EW Long_deg Long_min Long_sec Elev_m Elev_ft Country State County Locality Park Remarks Precision DeterminationCompare ModifiedBy ModifiedOn }.freeze
        match_fields = %w{ AccessionNumber DeterminationLabel OtherLabel LocalityLabel }.freeze
        #br = data.biological_relationships['host']['biological_relationship']

        added_collecting_events = 0
        i = 0
        sp.each do |row|
          i += 1
          print "\r#{i}      "
          #next if i < 19820

          identifier = Identifier.where(cached: 'INHS ' + row['Prefix'].to_s + ' ' + row['CatalogNumber'].to_s, project_id: Current.project_id)
          object = identifier.empty? ? nil : identifier.first.identifier_object

          next if object.nil?
          if object.type == 'Lot' || object.type == 'Specimen' || object.type == 'CollectionObject::BiologicalCollectionObject'
            next unless object.collecting_event_id.nil?
          else
            object.contained_objects.each do |i|
              next unless i.collecting_event_id.nil?
            end
          end
          tmp_m = {}
          match_fields.each do |m|
            tmp_m[m] = row[m] unless row[m].blank?
          end
          partially_resolved = data.partially_resolved_index[tmp_m]

          locality_code = partially_resolved.nil? ? nil : partially_resolved['LocalityCode']

          if locality_code.blank?
            if row['LocalityCode'].blank?
              locality_code = nil
            else
              locality_code = row['LocalityCode']
            end
          end

          extra_fields = {}
          #          unless partially_resolved.nil?
          if locality_code.nil?
            locality_fields_without_locality_code.each do |m|
              extra_fields[m] = partially_resolved[m] if partially_resolved && !partially_resolved[m].blank?
            end
          else
            locality_fields_with_locality_code.each do |m|
              extra_fields[m] = partially_resolved[m] if partially_resolved && !partially_resolved[m].blank?
            end
          end
          #          end

          se = { }

          if !data.localities_index[locality_code].nil?
            se.merge!(data.localities_index[locality_code])
          else
            data.unmatched_localities[locality_code] = nil unless locality_code.blank?
          end

          specimen_fields.each do |c|
            se[c] = row[c] unless row[c].blank?
          end

          se.merge!(extra_fields)

          collecting_event = nil
          collecting_event = find_or_create_collecting_event_insects1(se, data) if (partially_resolved && partially_resolved['Done'] == '1') || row['Prefix'] == 'Araneae'
          #####################################
          next if collecting_event.nil? || collecting_event.id.nil?

          if object.type == 'Lot' || object.type == 'Specimen' || object.type == 'CollectionObject::BiologicalCollectionObject'
            # byebug if object.collecting_event_id.nil?
            object.update_column(:collecting_event_id, collecting_event.id) if object.collecting_event_id.nil? && !collecting_event.nil?
            added_collecting_events +=1
          else
            object.contained_objects.each do |i|
              i.update_column(:collecting_event_id, collecting_event.id) if i.collecting_event_id.nil? & !collecting_event.nil?
              added_collecting_events +=1
            end
          end
          ########################################



        end
        puts "\n Number of collecting events added: #{added_collecting_events} "
      end










      def index_collecting_events_from_accessions_new1(data)
        path = @args[:data_directory] + 'TXT/accessions_new.txt' # self contained
        raise 'file not found' if not File.exists?(path)

        ac = CSV.open(path, col_sep: "\t", headers: true)

        fields = %w{LocalityLabel Habitat Host AccessionNumber Country State County Locality Park DateCollectedBeginning DateCollectedEnding Collector CollectionMethod Elev_m Elev_ft NS Lat_deg Lat_min Lat_sec EW Long_deg Long_min Long_sec Comments PrecisionCode Datum ModifiedBy ModifiedOn}

        puts "\naccession new records\n"
        i = 0
        ac.each do |row|
          i += 1
          print "\r#{i}"
          tmp_ce = { }
          fields.each do |c|
            tmp_ce[c] = row[c] unless row[c].blank?
          end
          tmp_ce['County'] = geo_translate(tmp_ce['County']) unless tmp_ce['County'].blank?
          tmp_ce['State'] = geo_translate(tmp_ce['State']) unless tmp_ce['State'].blank?
          tmp_ce['Country'] = geo_translate(tmp_ce['Country']) unless tmp_ce['Country'].blank?

          tmp_ce.merge!('CreatedBy' => '1031', 'CreatedOn' => '01/20/2014 12:00:00')

          find_or_create_collecting_event_insects1(tmp_ce, data)
        end
        puts "\n Number of collecting events processed from Accessions_new: #{data.collecting_event_index.keys.count} "
      end


      def index_collecting_events_from_ledgers1(data)
        starting_number = data.collecting_event_index.keys.empty? ? 0 : data.collecting_event_index.keys.count

        path = @args[:data_directory] + 'TXT/ledgers.txt'
        raise 'file not found' if not File.exists?(path)
        le = CSV.open(path, col_sep: "\t", headers: true)

        fields = %w{Collection AccessionNumber LedgerBook LedgersCountry LedgersState LedgersCounty LedgersLocality DateCollectedBeginning DateCollectedEnding Collector Order Family Genus Species HostGenus HostSpecies Sex LedgersComments Description Remarks LocalityCode OldLocalityCode CreatedBy CreatedOn}

        puts "\n  from ledgers\n"

        i = 0
        le.each do |row|
          i += 1
          tmp_ce = { }

          fields.each do |c|
            tmp_ce[c] = row[c] unless row[c].blank?
          end

          #          byebug if !row['Sex'].blank?

          unless tmp_ce['LocalityCode'].nil?
            if data.localities_index[tmp_ce['LocalityCode']].nil?
              print "\nLocality Code #{tmp_ce['LocalityCode']} does not exist!\n"
            else
              tmp_ce.merge!(data.localities_index[tmp_ce['LocalityCode']])
            end
          end

          tmp_ce['LedgersCounty'] = geo_translate(tmp_ce['LedgersCounty']) unless tmp_ce['LedgersCounty'].blank?
          tmp_ce['LedgersState'] = geo_translate(tmp_ce['LedgersState']) unless tmp_ce['LedgersState'].blank?
          tmp_ce['LedgersCountry'] = geo_translate(tmp_ce['LedgersCountry']) unless tmp_ce['LedgersCountry'].blank?
          tmp_ce['County'] = geo_translate(tmp_ce['County']) unless tmp_ce['County'].blank?
          tmp_ce['State'] = geo_translate(tmp_ce['State']) unless tmp_ce['State'].blank?
          tmp_ce['Country'] = geo_translate(tmp_ce['Country']) unless tmp_ce['Country'].blank?

          tmp_ce.delete('LedgersCountry') if !tmp_ce['LedgersCountry'].nil? && tmp_ce['LedgersCountry'] == tmp_ce['Country']
          tmp_ce.delete('LedgersState') if !tmp_ce['LedgersState'].nil? && tmp_ce['LedgersState'] == tmp_ce['State']
          tmp_ce.delete('LedgersCounty') if !tmp_ce['LedgersCounty'].nil? && tmp_ce['LedgersCounty'] == tmp_ce['County']
          tmp_ce.delete('LedgersLocality') if !tmp_ce['LedgersLocality'].nil? && tmp_ce['LedgersLocality'] == tmp_ce['Locality']

          bench = Benchmark.measure {
            find_or_create_collecting_event_insects1(tmp_ce, data)
          }
          print "\r#{i}\t#{bench.to_s.strip}"
        end
        puts "\n Number of collecting events processed from Ledgers: #{data.collecting_event_index.keys.count - starting_number} "
      end



      def parse_geographic_area_insects(ce)
        geog_search = []
        [ ce['County'], ce['State'], ce['Country']].each do |v|
          geog_search.push( GEO_NAME_TRANSLATOR[v] ? GEO_NAME_TRANSLATOR[v] : v) if !v.blank?
        end

        match = geog_search.empty? ? [] : GeographicArea.find_by_self_and_parents(geog_search)
        geographic_area = nil

        if match.empty?
          #puts "\nNo matching geographic area for: #{geog_search}"
          if $matchless_for_geographic_area[geog_search]
            $matchless_for_geographic_area[geog_search] += 1
          else
            $matchless_for_geographic_area[geog_search] = 1
          end
        elsif match.count > 1
          match = match.select{|g| !g.geographic_items.empty?}

          #puts "\nMultiple geographic areas match #{geog_search}\n"
          if $matchless_for_geographic_area[geog_search]
            $matchless_for_geographic_area[geog_search] += 1
          else
            $matchless_for_geographic_area[geog_search] = 1
          end
        elsif match.count == 1
          if $found_geographic_areas[geog_search]
            $found_geographic_areas[geog_search] += 1
          else
            $found_geographic_areas[geog_search] = 1
          end
          geographic_area = match[0]
        else
          puts "\nHuh?! not zero, 1 or more than one matches"
        end
        geographic_area
      end

      def parse_lat_long_insects(ce)
        latitude, longitude = nil, nil
        nlt = ce['NS'].blank? ? nil : ce['NS'].capitalize #  (ce['NS'].downcase == 's' ? '-' : nil) if !ce['NS'].blank?
        ltd = ce['Lat_deg'].blank? ? nil : "#{ce['Lat_deg']}º"
        ltm = ce['Lat_min'].blank? ? nil : "#{ce['Lat_min']}'"
        lts = ce['Lat_sec'].blank? ? nil : "#{ce['Lat_sec']}\""
        latitude = [nlt,ltd,ltm,lts].compact.join
        latitude = nil if latitude == '-'

        nll = ce['EW'].blank? ? nil : ce['EW'].capitalize # (ce['EW'].downcase == 'w' ? '-' : nil ) if !ce['EW'].blank?
        lld = ce['Long_deg'].blank? ? nil : "#{ce['Long_deg']}º"
        llm = ce['Long_min'].blank? ? nil : "#{ce['Long_min']}'"
        lls = ce['Long_sec'].blank? ? nil : "#{ce['Long_sec']}\""
        longitude = [nll,lld,llm,lls].compact.join
        longitude = nil if longitude == '-'

        [latitude, longitude]
      end

      def parse_geolocation_uncertainty_insects(ce)
        return ce['CoordinateAccuracy'] unless ce['CoordinateAccuracy'].blank?

        geolocation_uncertainty = nil
        unless ce['PrecisionCode'].blank?
          case ce['PrecisionCode'].to_i
          when 1
            geolocation_uncertainty = 10
          when 2
            geolocation_uncertainty = 1000
          when 3
            geolocation_uncertainty = 10000
          when 4
            nil
            #geolocation_uncertainty = 100000
          when 5
            nil
            #geolocation_uncertainty = 1000000
          when 6
            nil
            #geolocation_uncertainty = 1000000
          end
        end
        return geolocation_uncertainty
      end

      def parse_dates_insects(ce)
        sdm, sdd, sdy, edm, edd, edy = nil, nil, nil, nil, nil, nil
        ( sdm, sdd, sdy = ce['DateCollectedBeginning'].split('/') ) if !ce['DateCollectedBeginning'].blank?
        ( edm, edd, edy = ce['DateCollectedEnding'].split('/')    ) if !ce['DateCollectedEnding'].blank?

        sdy = sdy.to_i unless sdy.blank?
        edy = edy.to_i unless edy.blank?
        sdd = sdd.to_i unless sdd.blank?
        edd = edd.to_i unless edd.blank?
        sdm = sdm.to_i unless sdm.blank?
        edm = edm.to_i unless edm.blank?
        [sdm, sdd, sdy, edm, edd, edy]
      end

      def parse_elevation_insects(ce)
        ft =  ce['Elev_ft']
        m = ce['Elev_m']

        if !ft.blank? && !m.blank? && !Utilities::Measurements.feet_equals_meters(ft, m)
          puts "\n !! Feet and meters both providing and not equal: #{ft}, #{m}."
        end

        elevation, verbatim_elevation = nil, nil

        if !ft.blank?
          elevation = ft.to_i * 0.305
          verbatim_elevation = ft + ' ft.'
        elsif !m.blank?
          elevation = m.to_i
        end
        [elevation, verbatim_elevation]
      end

      def dump_directory(base)
        base + 'pg_dumps/'
      end

      def restore_from_pg_dump
        raise 'Database is not empty, it is not possible to restore from all.dump.' if Project.count > 0
        puts 'Restoring from all.dump (to avoid this use no_dump_load=true when calling the rake task).'
        ApplicationRecord.connection.execute('delete from schema_migrations')
        Support::Database.pg_restore_all(dump_directory(@args[:data_directory]),  'all.dump')
      end

    end
  end
end





