# TODO: write some pre/post dump methods
#


require 'fileutils'
require 'benchmark'

namespace :tw do
  namespace :project_import do
    namespace :insects do

      # A utility class to index data.
      class ImportedData
        attr_accessor :people, :keywords, :users, :collecting_events, :collection_objects, :otus, :namespaces
        def initialize()
          @namespaces = {}
          @people = {}
          @users = {}
          @keywords = {}
          @collecting_events = {}
          @collection_objects = {}
          @otus = {}
        end

        def save_all
          [@users, @otus, @keywords, @people, @collecting_events, @collection_objects].each do |ary|
            ary.values.each do |o|
              o.save!
            end
          end
        end
        
      end

      # These are largely collecting event related
      PREDICATES = [ 
        "Country",
        "County",
        "State",

        "AccessionNumber",
        "BodyOfWater",
        "Collection",
        "Comments",

        "Datum",
        "Description",
        "DrainageBasinGreater",
        "DrainageBasinLesser",
        "Family",

        "Genus",
        "Host",
        "HostGenus",
        "HostSpecies",
        "INDrainage",
        "LedgerBook",
        "LocalityCode",
        "OldLocalityCode",
        "Order",
        "Park",
        "Remarks",
        "Sex",
        "Species",
        "StreamSize",
        "WisconsinGlaciated",

        "PrecisionCode",    # tag on Georeference
        "GBIF_precission",  # tag
      ]

      # TODO: Lots could be added here, it could also be yamlified
      GEO_NAME_TRANSLATOR = {
        'U.S.A.' => 'United States',
        'U. S. A.' => 'United States',
        'Quebec' => 'Québec',
        'U.S.A' => 'United States',
        'MEXICO' => 'Mexico',
        'U. S. A. ' => 'United States',
      }

      CONTAINER_TYPE = {
        '' => 'Container::Virtual',            # TODO: update with propper class
        'amber' => 'Container::PillBox',       # remove
        'bulk dry' => 'Container::PillBox',
        'envelope' => 'Container::Envelope',
        'jar' => 'Container::Jar',
        'jars' => 'Container::Jar', # remove
        'pill box' => 'Container::PillBox',
        'pin' => 'Container::Pin',
        'slide' => 'Container::Slide',
        'vial' => 'Container::Vial',
        'other' => 'Container::Vial'
      }

      # Attributes to use from specimens.txt
      SPECIMENS_COLUMNS = %w{LocalityCode DateCollectedBeginning DateCollectedEnding Collector CollectionMethod Habitat} 

      # Attributes to strip on CollectingEvent creation 
      STRIP_LIST = %w{ModifiedBy ModifiedOn CreatedBy ModifiedBy CreatedOn Latitude Longitude Elevation} # the last three are calculated



      desc "Import the INHS insect collection dataset.\n
      rake tw:project_import:insects:import_insects data_directory=/Users/matt/src/sf/import/inhs-insect-collection-data/TXT/
      " 
      task :import_insects => [:data_directory, :environment] do |t, args| 
        puts @args

        ActiveRecord::Base.transaction do 
          begin
            Utilities::Files.lines_per_file(Dir["#{@args[:data_directory]}/**/*.txt"])

            # A lookup index for localities
            LOCALITIES = build_localities_index(@args[:data_directory])

            @project, @user = initiate_project_and_users('INHS Insect Collection', nil)

            $project_id = @project.id
            $user_id = @user.id

            @import_namespace = Namespace.create(name: 'INHS Import Identifiers', short_name: 'INHS Import')
            @accession_namespace = Namespace.create(name: 'INHS Legacy Accession Codes', short_name: 'INHS Legacy Accession Code')

            @data =  ImportedData.new

            # handle the tables in this order
            #--- mostly done 
            #  people.txt
            #  taxa_hierarchical.txt
            #  localities.txt

            #--- mostly done 
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

            Rake::Task["tw:project_import:insects:handle_people"].execute
            Rake::Task["tw:project_import:insects:handle_taxa"].execute
            Rake::Task["tw:project_import:insects:handle_collecting_events"].execute
            Rake::Task["tw:project_import:insects:handle_specimens"].execute

            # Rake::Task["tw:project_import:insects:handle_users"].execute

            byebug

            puts "\n\n !! Success \n\n"
            raise
          rescue
            raise
          end
        end
      end

      desc 'handle collecting events'
      task :handle_collecting_events => [:data_directory, :environment] do |t, args|
        matchless_for_geographic_area = []
        found = 0

        collecting_events_index = {}
        unmatched_localities = {}

        build_predicates_for_collecting_events
        
        puts "\nindexing collecting events" 
        index_collecting_events_from_specimens(collecting_events_index, unmatched_localities)
        index_collecting_events_from_ledgers(collecting_events_index)
        index_collecting_events_from_accessions_new(collecting_events_index)

        puts "\ntotal collecting events to build: #{collecting_events_index.keys.length}." 

        # Debugging code, turn this on if you want to inspect all the columns that 
        # are used to index a unique collecting event.
        # all_keys = [] 
        # collecting_events_index.keys.each_with_index do |hsh, i|
        #   all_keys.push hsh.keys
        #   all_keys.flatten!.uniq!
        # end
        # all_keys.sort!

        collecting_events_index.keys.each_with_index do |ce,i|
          break if i > 100  # TODO: Remove
          print "\r#{i}"

          latitude, longitude = parse_lat_long(ce)
          sdm, sdd, sdy, edm, edd, edy = parse_dates(ce)
          elevation, elevation_unit = parse_elevation(ce)
          geographic_area = parse_geographic_area(ce, found, matchless_for_geographic_area)

          c = CollectingEvent.new(
            geographic_area: geographic_area,
            verbatim_label: ce['LocalityLabel'], 
            verbatim_locality: ce['Locality'],
            verbatim_collectors: ce['Collector'],                
            verbatim_method: ce['CollectionMethod'],            
            start_date_day: sdd,
            start_date_month: sdm,
            start_date_year: sdy,
            end_date_day: edd,
            end_date_month: edm,
            end_date_year: edy,
            macro_habitat: ce['Habitat'],
            minimum_elevation: elevation,
            elevation_unit: elevation_unit,
            verbatim_latitude: latitude,
            verbatim_longitude: longitude,
          )


          ce.select{|k,v| !v.nil?}.each do |a,b|
          if PREDICATES.include?(a)
              c.data_attributes.build(predicate: @data.keywords[a], value: b, type: 'InternalAttribute')
            end
          end

          @data.collecting_events.merge!(ce => c)
        end
      end

      # Index localities by their collective column=>data pairs
      def build_localities_index(data_directory)
        # LocalityCode
        # Country
        # State
        # County
        # Locality
        # Park
        # BodyOfWater
        # NS
        # Lat_deg
        # Lat_min
        # Lat_sec
        # EW
        # Long_deg
        # Long_min
        # Long_sec
        # Latitude
        # Longitude
        # Elev_m
        # Elev_ft
        # Elevation
        # PrecisionCode
        # Comments
        # GBIG_precission
        # DrainageBasinLesser
        # DrainageBasinGreater
        # StreemSize
        # INDrainage
        # WisconsinGlaciated
        # OldLocalityCode
        #
        # CreatedOn
        # ModifiedOn
        # CreatedBy
        # ModifiedBy

        localities_file = data_directory + 'localities.txt'
        raise 'file not found' if not File.exists?(localities_file)
        lo = CSV.open(localities_file, col_sep: "\t", :headers => true)

        localities = {}
        lo.each do |row|
          localities.merge!(row['LocalityCode'] => row.to_h)
        end
        localities
      end

      def build_predicates_for_collecting_events
        PREDICATES.each do |p|
          @data.keywords.merge!(p => Predicate.new(name: "CollectingEvents:#{p}", definition: "The verbatim value imported in for #{p}.")  )
        end
      end

      def  index_collecting_events_from_accessions_new(collecting_events_index)
        path = @args[:data_directory] + 'accessions_new.txt' # self contained
        raise 'file not found' if not File.exists?(path)

        #   AccessionNumber - field notes for collecting event /  # Not the same accession code 
        #      missing a "file"  
        #   Prefix
        #   CatalogNumber
        #   LocalityLabel
        #   Habitat
        #   Host
        #   Country
        #   State
        #   County
        #   Locality
        #   Park
        #   DateCollectedBeginning
        #   DateCollectedEnding
        #   Collector
        #   CollectionMethod
        #   ElevationM
        #   ElevationF
        #   NS
        #   Lat_deg
        #   Lat_min
        #   Lat_sec
        #   EW
        #   Long_deg
        #   Long_Ming
        #   Long_Sec
        #   Remarks
        #   Precision
        #   Datum
        #
        #   ModifiedBy
        #   ModifiedOn

        ac = CSV.open(path, col_sep: "\t", :headers => true)
        
        puts "\naccession new records\n"
        ac.each_with_index do |row, i|
          collecting_events_index.merge!( Utilities::Hashes.delete_keys(row.to_h, STRIP_LIST)  => nil)
          print "\r#{i}" 
        end
      end

      def index_collecting_events_from_ledgers(collecting_events_index)
        path = @args[:data_directory] + 'ledgers.txt'
        raise 'file not found' if not File.exists?(path)

        #  LocalityCode
        #  Collector
        #  DateCollectedBeginning
        #  DateCollectedEnding
        #       
        #  Collection
        #  AccessionNumber
        #  LedgerBook
        #
        #  Country
        #  State
        #  County
        #  Locality
        #  HostGenus
        #  HostSpecies
        #  Description
        #  Remarks
        #  OldLocalityCode
        #
        #  CreatedBy
        #  CreatedOn
        #
        #  Comments
        #  Order
        #  Family
        #  Genus
        #  Species
        #  Sex

        le = CSV.open(path, col_sep: "\t", :headers => true)
        
        puts "\nledgers\n"
        le.each_with_index do |row, i|
          collecting_events_index.merge!(Utilities::Hashes.delete_keys(row.to_h, STRIP_LIST) => nil)
          print "\r#{i}" 
        end
      end


      # Relevant columns
      # -    LocalityCode --- 
      # -    DateCollectedBeginning
      # -    DateCollectedEnding
      # -    Collector
      # -    CollectionMethod
      # -    Habitat
      # -    OldLocalityCode    # tags on CE
      # -    OldCollector       # tags on CE
      # --- not used 
      #     LocalityCompare     # related to hash md5
      def index_collecting_events_from_specimens(collecting_events_index, unmatched_localities)
        print "\nfrom specimens"
        path = @args[:data_directory] + 'specimens.txt'
        raise 'file not found' if not File.exists?(path)

        sp = CSV.open(path, col_sep: "\t", :headers => true)

        sp.each_with_index do |row, i|
          print "\r#{i}      "

          locality_code = row['LocalityCode']
          tmp_ce = { }   
          SPECIMENS_COLUMNS.each do |c|
            tmp_ce.merge!(c => row[c]) if !row[c].blank?
          end

          if LOCALITIES[locality_code]
            Utilities::Hashes.puts_collisions(tmp_ce, LOCALITIES[locality_code])
            tmp_ce.merge!(LOCALITIES[locality_code]) 
          else
            unmatched_localities.merge!(row['LocalityCode'] => nil) if !locality_code.blank?
          end

          collecting_events_index.merge!(Utilities::Hashes.delete_keys(tmp_ce, STRIP_LIST)  => nil)
        end

        puts "\n!! The following are locality codes in specimens without corresponding values in localities (#{unmatched_localities.keys.count}): " + unmatched_localities.keys.sort.join(", ") 
      end

      def parse_geographic_area(ce, found, matchless_for_geographic_area)
        geog_search = []
        [ ce['County'], ce['State'], ce['Country']].each do |v|
          geog_search.push( GEO_NAME_TRANSLATOR[v] ? GEO_NAME_TRANSLATOR[v] : v) if !v.blank?
        end

        match = GeographicArea.find_by_self_and_parents(geog_search)            
        geographic_area = nil

        if match.count == 0
          puts "\nNo matching geographic area for: #{geog_search}"
          matchless_for_geographic_area.push geog_search
        elsif match.count > 1
          puts "\nMultiple geographic areas match #{geog_search}\n"
          matchless_for_geographic_area.push geog_search
        elsif match.count == 1
          found += 1
          geographic_area = match[0]
        else
          puts "\nHuh?! not zero, 1 or more than one matches"
        end
        geographic_area
      end

      def parse_lat_long(ce)
        latitude, longitude = nil, nil
        # TODO: needs refactoring, Lat_deg contains a mix of decimal degrees and otherwise
        nlt = ce['NS'] #  (ce['NS'].downcase == 's' ? '-' : nil) if !ce['NS'].blank?
        ltd = ce['Lat_deg'].blank? ? nil : "#{ce['Lat_deg']}º"
        ltm = ce['Lat_min'].blank? ? nil : "#{ce['Lat_min']}'"
        lts = ce['Lat_sec'].blank? ? nil : "#{ce['Lat_sec']}\""
        latitude = [nlt, ltd,ltm,lts].compact.join
        latitude = nil if latitude == '-'

        nll = ce['EW'] # (ce['EW'].downcase == 'w' ? '-' : nil ) if !ce['EW'].blank?
        lld = ce['Long_deg'].blank? ? nil : "#{ce['Long_deg']}º"
        llm = ce['Long_min'].blank? ? nil : "#{ce['Long_min']}'"
        lls = ce['Long_sec'].blank? ? nil : "#{ce['Long_sec']}\""
        longitude = [nll,lld,llm,lls].compact.join
        longitude = nil if longitude == '-'

        [latitude, longitude]
      end

      def parse_dates(ce)
        sdm, sdd, sdy, edm, edd, edy = nil, nil, nil, nil, nil, nil
        ( sdm, sdd, sdy = ce['DateCollectedBeginning'].split("/") ) if !ce['DateCollectedBeginning'].blank?
        ( edm, edd, edy = ce['DateCollectedEnding'].split("/")    ) if !ce['DateCollectedEnding'].blank?

        sdy = sdy.to_i if sdy 
        edy = edy.to_i if edy
        [sdm, sdd, sdy, edm, edd, edy]
      end

      def parse_elevation(ce)
        ft =  ce['Elev_ft']
        m = ce['Elev_m'] 

        if !ft.blank? && !m.blank? && not(Utilities::Measurements.feet_equals_meters(ft, m))
          puts "\n !! Feet and meters both providing and not equal: #{ft}, #{m}."
        end

        elevation, elevation_unit = nil, nil

        if !ce['Elev_ft'].blank?
          elevation = ce['Elev_ft']
          elevation_unit = 'feet'
        elsif !ce['Elev_m'].blank?
          elevation = ce['Elev_m']
          elevation_unit = 'meters'
        else
          elevation = nil
          elevation_unit = nil
        end
        [elevation, elevation_unit]
      end

      desc 'handle specimens'
      task :handle_specimens => [:data_directory, :environment] do |t, args|
        # -- Collection Object
        # *   AccessionNumber               # catalog_number of particular namespace Legacy Namespace
        # *   LocalityLabel                 # buffered_collecting_event
        # *   OtherLabel                    # buffered
        # -- Taxon Determination
        # *   DeterminationLabel      # buffered
        # *  IdentifiedBy             # internal attribute 
        # *  YearIdentified           # internal attribute  
        # *  OldIdentifiedBy          # internal attribute 

        # *  PreparationType          # Biocuration classification

        # *   AccessionSource        # people_id  # Asserts a person donated the specimen.
        # *   DeaccessionRecipient   # people_id  # Asserts the specimen was given to a person, and the (and nothing else).
        # *   DeaccessionCause       # cause      # A reason the specimen is no longer (= owned (= under the responsibility of an organization) by) the identified repository_id
        # *   DeaccessionDate        # date       # Date ownership was given up. 

        # * -- Identifier
        # *     Prefix
        # *     CatalogNumber

        # *  -- Otu   
        # *      TaxonCode

        path = @args[:data_directory] + 'specimens.txt'
        raise 'file not found' if not File.exists?(path)
        co = CSV.open(path, col_sep: "\t", :headers => true)

        @data.keywords.merge!(  
                              'AdultMale' => BiocurationClass.create(name: 'Taxa:Synonyms', definition: 'The collection object is comprised of adult male(s).'), 
                              'AdultFemale' => BiocurationClass.create(name: 'Taxa:Synonyms', definition: 'The collection object is comprised of adult female(s).'), 
                              'Immature' => BiocurationClass.create(name: 'Taxa:Synonyms', definition: 'The collection object is comprised of immature(s).'), 
                              'Pupa' => BiocurationClass.create(name: 'Taxa:Synonyms', definition: 'The collection object is comprised of pupa.'), 
                              'Exuvium' => BiocurationClass.create(name: 'Taxa:Synonyms', definition: 'The collection object is comprised of exuviae.'), 
                              'AdultUnsexed' => BiocurationClass.create(name: 'Taxa:Synonyms', definition: 'The collection object is comprised of adults, with sex undetermined.'), 
                              'AgeUnknown' => BiocurationClass.create(name: 'Taxa:Synonyms', definition: 'The collection object is comprised of individuals of indtermined age.'), 
                              'OtherSpecimens' => BiocurationClass.create(name: 'Taxa:Synonyms', definition: 'The collection object that is asserted to be unclassified in any manner.'), 
                              'ZeroTotal' => Keyword.create(name: 'Zero total', definition: 'On import there were 0 total specimens recorded in the FM database.'),
                              'IdentifiedBy' => Predicate.create(name: 'Identified by (INHS IMPORT)', definition: 'The verbatim value in the identified by field.'),
                              'YearIdentified' => Predicate.create(name: 'Year Identified (INHS IMPORT)', definition: 'The verbatim value in the year identified field.'),
                              'OldIdentifiedBy' => Predicate.create(name: 'Old Identified By (INHS IMPORT)', definition: 'The verbatim value in the old identified by.'),
                             )

        tmp_namespaces = {} 
        co.each do |row|
          tmp_namespaces.merge!(row['Prefix'] => nil)
        end

        tmp_namespaces.keys.delete_if{|k,v| k.nil? || k.to_s == ""} 
        tmp_namespaces.keys.each do |k|
          @data.namespaces.merge!(k => Namespace.create(short_name: k) ) 
        end

        co.rewind
        co.each_with_index do |row, i|
          if @data.otus[row['TaxonCode']] 
            
            @data.collection_objects.merge!(i => objects_from_co_row(row) )
          end
        end
      end

      def objects_from_co_row(row)
        # otu = Identifier.of_type(:otu_utility).where(identifier: row['TaxonCode']).first.identified_object
        otu = @data.otus[row['TaxonCode']]

        return [] if otu.nil?

        determination = {
          otu: otu 
        }

        accession_attributes = { accessioned_at: '', 
                                 deaccession_at: row['DeaccessionData'],               
                                 accession_provider_id: @data.people[row['AccessionSource']],       
                                 deaccession_recipient_id: @data.people[row['AccessionSource']],    
                                 deaccession_reason: row['DeaccessionCause'], 
        }       

        objects = []

        %w{AdultMale AdultFemale Immature Pupa Exuvium AdultUnsexed AgeUnknown OtherSpecimens}.each do |c|
          total = row[c].to_i
          if total > 0
            o = CollectionObject::BiologicalCollectionObject.create(
              total: total,
              taxon_determinations_attributes: [ determination ], 
              buffered_collecting_event: row['LocalityLabel'],
              buffered_determinations: row['DeterminationLabel'],
              buffered_other_labels: row['OtherLabel']
            )

            # add the biological attribute
            o.biocuration_classifications.build(biocuration_class: @data.keywords[c])
            o.save
            objects.push(o) 
          end
        end

        # Some specimen records have 0 total specimens! WATCH OUT.
        if objects.count == 0
          o = Specimen.create(taxon_determinations_attributes: [ determination] )
          o.tags.build(keyword: @data.keywords['ZeroTotal'])
          o.save!
          objects.push(o)
        end

        add_identifiers(objects, row)
        add_determinations(objects, row)
        add_collecting_event(objects, row)

        objects
      end

      def ce_from_specimens_row(row)
        tmp_ce = {}

        # pull from the row 
        SPECIMENS_COLUMNS.each do |c|
          tmp_ce.merge!(c => row[c]) if !row[c].blank?
        end

        # pull from the locality index 
        if v = LOCALITIES[row['LocalityCode']]
          tmp_ce.merge!(v) 
        end
        tmp_ce
      end

      def add_collecting_event(objects, row)
        tmp_ce = ce_from_specimens_row(row)
        objects.each do |o|
          o.update(collecting_event: @data.collecting_events(tmp_ce) )
        end
      end 

      def add_identifiers(objects, row)
        puts "no catalog number for #{row['ID']}" if row['CatalogNumber'].blank?

        identifier = Identifier::Local::CatalogNumber.new(namespace: @data.namespaces[row['Prefix']], identifier: row['CatalogNumber']) if !row['CatalogNumber'].blank?
        accession_number = InternalAttribute.new(value: row['AccessionNumber'], predicate: @data.keywords['AccessionCode']) if !row['AccessionNumber'].blank?

        if objects.count > 1 
          puts "More than one in a #{row['PreparationType']}"

          objects.each do |o|
            o.data_attributes << accession_number.dup if accession_number
            o.save!
          end

          # Identifier on container. 
          c = Container.containerize(objects)
          c.type = CONTAINER_TYPE[row['PreparationType'].to_s.downcase]
          c.save!
          c.identifiers << identifier if identifier
          c.save! 
          # Identifer on object
        elsif objects.count == 1
          objects.first.identifiers << identifier if identifier
          objects.first.data_attributes << accession_number if accession_number 
          objects.first.save!
        else
          raise 'No objects in container.'
        end
      end

      def add_determinations(objects, row)
        objects.each do |o|
          %w{IdentifiedBy YearIdentified OldIdentifiedBy}.each do |c|
            o.data_attributes.build(predicate: @data.keywords[c], value: row[c], type: 'InternalAttribute')  if !row[c].blank?
          end
        end
      end

      desc 'handle taxa'
      task :handle_taxa => [:data_directory, :environment] do |t, args|
        #   ID             Not Included (parent use only)

        #   Name           TaxonName#name  
        #   Author         TaxonName#verbatim_author
        #   Year           TaxonName#year_of_publication
        #   Parens         TaxonName#verbatim_author addition
        #   Rank           TaxonName#rank
        #   Parent         TaxonName#parent_id
        #   Synonyms       'Taxa#Synonyms'  
        #   References     'Taxa#References' 
        #   Remarks         Note
        #   CreatedOn 
        #   ModifiedOn
        #   CreatedBy 
        #   ModifiedBy

        # -- is on the OTU
        #   TaxonCode      New Namespace Identifier 

        path = @args[:data_directory] + 'taxa_hierarchical.txt'
        raise 'file not found' if not File.exists?(path)

        parent_index = {}

        @data.keywords.merge!(  
                              'Taxa:Synonyms' => Predicate.new(name: 'Taxa:Synonyms', definition: 'The verbatim value on import from Taxa#Synonyms.'), 
                              'Taxa:References' => Predicate.new(name: 'Taxa:References', definition: 'The verbatim value on import Taxa#References.') 
                             )

        f = CSV.open(path, col_sep: "\t", :headers => true)

        code = :iczn

        f.each_with_index do |row, i|
          break if i > 100
          author = (row['Parens'] ? "(#{row['Author']})" : row['Author']) if !row['Author'].blank?
          author ||= nil

          code = :icn if row['Name'] == 'Plantae'
          rank = Ranks.lookup(code, row['Rank'])
          rank ||= NomenclaturalRank
          name = row['Name']
          parent = parent_index[row['Parent']]
          # puts "\r#{name}                          #{rank}                           "

          # raise 'no parent' if parent.nil? && rank != NomenclaturalRank

          p = Protonym.new(
            name: name,
            verbatim_author: author,
            year_of_publication: row['Year'],
            rank_class: rank,
            creator: find_or_create_user(row['CreatedBy'], @data),
            updater: find_or_create_user(row['ModifiedBy'], @data),
            parent: parent
          )

          p.created_at = time_from_field(row['CreatedOn'])
          p.updated_at = time_from_field(row['ModifiedOn'])
          p.data_attributes.build(type: 'InternalAttribute', predicate: @data.keywords['Taxa:Synonyms'], value: row['Synonyms'])
          p.data_attributes.build(type: 'InternalAttribute', predicate: @data.keywords['Taxa:References'], value: row['References'])
          p.notes.build(text: row['Remarks']) if !row['Remarks'].blank?

          p.parent_id = p.parent.id if p.parent && !p.parent.id.blank?

          if rank == NomenclaturalRank || !p.parent_id.blank?
            bench = Benchmark.measure { p.save }

            # Build the associated OTU
            # TODO: .create!?
            o = Otu.create(
              taxon_name_id: p.id,
              identifiers_attributes: [  {identifier: row['TaxonCode'], namespace: @identifier_namespace, type: 'Identifier::Local::OtuUtility'} ]
            )

            @data.otus.merge!(row['TaxonCode'] => o)

            if p.valid?
              parent_index.merge!(row['ID'] => p) 
              print "\r#{i}\t#{bench.to_s.strip}  #{name}        \t\t#{rank}                                     "
            else
              puts 
              puts p.name
              puts p.errors.messages
              puts
            end
          else
            puts "\n\t!!? No parent for #{p.name}\n"
          end
        end
        puts puts
      end

      desc 'handle people'
      task :handle_people => [:data_directory, :environment] do |t, args|

        #- 0 PeopleID          Import Identifier
        #  1 SupervisorID      Loan#supervisor_person_id  ?

        #- 2 LastName           
        #- 3 FirstName

        #  4 Honorarium        Loan#recipient_honorarium 
        #  5 Address           Loan#recipient_address
        #  6 Country           Loan#recipient_country 
        #  7 Email             Loan#recipient_email 
        #  8 Phone             Loan#recipent_phone

        # - 9 Comments          Note.new 

        path = @args[:data_directory] + 'people.txt'
        raise 'file not found' if not File.exists?(path)

        f = CSV.open(path, col_sep: "\t", :headers => true)

        f.each do |row|
          p = Person::Vetted.new(
            last_name: row['LastName'],
            first_name: row['FirstName'],
            identifiers_attributes: [ {identifier: row['PeopleID'], namespace: @identifier_namespace, type: 'Identifier::Local::Import'} ]
          )
          p.notes.build(text: row['Comments']) if !row['Comments'].blank?
          @data.people.merge!(p => row)
        end
      end

    end
  end
end



