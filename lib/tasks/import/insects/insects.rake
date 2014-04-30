require 'fileutils'
require 'benchmark'

namespace :tw do
  namespace :project_import do
    namespace :insects do

      # A utility class to index data.
      class ImportData
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
      end

      # Index localities by their collective column=>data pairs
      def build_localities_index
        localities_file = @args[:data_directory] + 'localities.txt'
        raise 'file not found' if not File.exists?(localities_file)
        lo = CSV.open(localities_file, col_sep: "\t", :headers => true)

        localities = {}
        lo.each do |row|
          localities.merge!(row['LocalityCode'] => row.to_h)
        end
        localities
      end

      desc 'the full loop' 
      task :import_insects => [:data_directory, :environment] do |t, args| 
        @args[:data_directory] ||=  "#{ENV['HOME']}/src/sf/import/inhs-insect-collection-data/TXT/"

        puts @args

        ActiveRecord::Base.transaction do 
          begin

            puts "\n lines per file:"
            Dir["#{@args[:data_directory]}/**/*.txt"].each do |f|
              puts `wc -l #{f}`
            end
                    
            LOCALITIES = build_localities_index 
            SPECIMENS_COLUMNS = %w{LocalityCode DateCollectedBeginning DateCollectedEnding Collector CollectionMethod Habitat OldCollector} 

            @project, @user = initiate_project_and_users('INHS Insect Collection', nil)

            $project_id = @project.id
            $user_id = @user.id

            @import_namespace = Namespace.create(name: 'INHS Import Identifiers', short_name: 'INHS Import')
            @accession_namespace = Namespace.create(name: 'INHS Legacy Accession Codes', short_name: 'INHS Legacy Accession Code')

            @data =  ImportData.new
        
            # TODO: do a file row count sanity check

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

          # Rake::Task["tw:project_import:insects:handle_people"].execute
          # Rake::Task["tw:project_import:insects:handle_taxa"].execute
          # Rake::Task["tw:project_import:insects:handle_specimens"].execute

            Rake::Task["tw:project_import:insects:handle_collecting_events"].execute

            puts "\n\n !! Success \n\n"
            raise
          rescue
            raise
          end
        end
      end


      desc 'handle collecting events'
      task :handle_collecting_events => [:data_directory, :environment] do |t, args|

        path1 = @args[:data_directory] + 'localities.txt'
        raise 'file not found' if not File.exists?(path1)
        lo = CSV.open(path1, col_sep: "\t", :headers => true)

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


        path2 = @args[:data_directory] + 'ledgers.txt'
        raise 'file not found' if not File.exists?(path2)

        #  LocalityCode
        #  Collector
        #  DateCollectedBeginning
        #  DateCollectedEnding
        #  Collection
        #  AccessionNumber
        #  LedgerBook
        #  Country
        #  State
        #  County
        #  Locality
        #  HostGenus
        #  HostSpecies
        #  Description
        #  Remarks
        #  OldLocalityCode
        #  CreatedBy
        #  CreatedOn
        #  Comments
        #  Order
        #  Family
        #  Genus
        #  Species
        #  Sex
      
        path3 = @args[:data_directory] + 'specimens.txt'
        raise 'file not found' if not File.exists?(path3)

        # -- Collecting Event 
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



        path4 = @args[:data_directory] + 'accessions_new.txt' # self contained
        raise 'file not found' if not File.exists?(path4)

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

        collecting_events = {}


        le = CSV.open(path2, col_sep: "\t", :headers => true)
        sp = CSV.open(path3, col_sep: "\t", :headers => true)
        ac = CSV.open(path4, col_sep: "\t", :headers => true)
      
        unmatched_localities = {}

        sp.each_with_index do |row, i|
          locality_code = row['LocalityCode']
          tmp_ce = { }   
          SPECIMENS_COLUMNS.each do |c|
            tmp_ce.merge!(c => row[c]) if !row[c].blank?
          end

          if LOCALITIES[locality_code]
            hashcollisions(tmp_ce, LOCALITIES[locality_code])
            tmp_ce.merge!(LOCALITIES[locality_code]) 
          else
            unmatched_localities.merge!(row['LocalityCode'] => nil) if !locality_code.blank?
          end

          collecting_events.merge!(tmp_ce => nil)
        end

        puts "\n!! The following are locality codes in specimens without corresponding values in localities (#{unmatched_localities.keys.count}): " + unmatched_localities.keys.sort.join(", ") 

        puts "\nledgers\n"
        le.each_with_index do |row, i|
          collecting_events.merge!(row.to_h => nil)
          print "\r#{i}" 
        end

        puts "\naccession new records\n"
        ac.each_with_index do |row, i|
          collecting_events.merge!(row.to_h => nil)
          print "\r#{i}" 
        end

        all_keys = [] 
        puts "\ntotal collecting events to build:"
        collecting_events.keys.each_with_index do |hsh,i|
          all_keys.push hsh.keys
          all_keys.flatten!.uniq!
          print "\r#{i}" 
        end

        all_keys.sort!

        byebug 

        raise

        fce = {}
        collecting_events.keys.each do |ce|
         
         # AccessionNumber
         # BodyOfWater
         # Collection
         # CollectionMethod
         # Collector
         # Comments
         # Country
         # County
         # CreatedBy
         # CreatedOn
         # DateCollectedBeginning
         # DateCollectedEnding
         # Datum
         # Description
         # DrainageBasinGreater
         # DrainageBasinLesser
         # EW
         # Elev_ft
         # Elev_m
         # Elevation
         # Family
         # GBIF_precission
         # Genus
         # Habitat
         # Host
         # HostGenus
         # HostSpecies
         # INDrainage
         
         # LedgerBook
         # Locality
         # LocalityCode
         # LocalityLabel
         # ModifiedBy
         # ModifiedOn
         # NS
         # OldCollector
         # OldLocalityCode
         # Order
         # Park
         # PrecisionCode
         # Remarks
         # Sex
         # Species
         # State
         # StreamSize
         # WisconsinGlaciated

          
          ltd = rows['Lat_deg'].blank? ? nil : "#{rows['Lat_deg']}º"
          ltm = rows['Lat_min'].blank? ? nil : "#{rows['Lat_min']}'"
          lts = rows['Lat_sec'].blank? ? nil : "#{rows['Lat_sec']}\""
          latitude = [ltd,ltm,lts].compact.join

          lld = rows['Long_deg'].blank? ? nil : "#{rows['Long_deg']}º"
          llm = rows['Long_min'].blank? ? nil : "#{rows['Long_min']}'"
          lls = rows['Long_sec'].blank? ? nil : "#{rows['Long_sec']}\""
          latitude = [lld,llm,lls].compact.join

          puts "!! values for both Latitude and Lat_ provided" if !latitude.blank? && !rows['Latitude'].blank?
          puts "!! values for both Longitude and Long_ provided" if !longitude.blank? && !rows['Longitude'].blank?
          latitude ||= rows['Latitude']
          longitude ||= rows['Longitude']

          sdd, sdm, sdy = ce['DateCollectedBeginning'].split("/")
          edd, edm, edy = ce['DateCollectedEnding'].split("/")

          raise if !ce['Elev_ft'].blank? && ce['Elev_m'].blank?        
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

          c = CollectingEvent.new(
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
            habitat_macro: ce['Habitat'],
            elevation: elevation,
            verbatim_longitude: longitude,
            verbatim_latitude: latitude,
          )

          @data.collecting_events.merge!(ce => c)
        end
      end 

      def hashcollisions(a, b)
        a.each do |i,j|
          if b[i] && !j.blank? && b[i] != j 
            puts "#{i}: [#{j}] != [#{b[i]}]"
          end
        end
      end


      desc 'handle specimens'
      task :handle_specimens => [:data_directory, :environment] do |t, args|

        # ------- specimens.txt ------------------------------
          #  
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
        byebug 
      end

      CONTAINER_TYPE = {
        '' => 'Container::Virtual', # update with propper
        'amber' => 'Container::PillBox', # remove
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


      def add_collecting_event(objects, row)
        tmp_ce = {}
        # TODO: refactor
        SPECIMENS_COLUMNS.each do |c|
          tmp_ce.merge!(c => row[c]) if !row[c].blank?
        end

        if v = LOCALITIES[row['LocalityCode']]
          tmp_ce.merge!(v) 
        end

        objects.each do |o|
          o.collecting_event = @data.collecting_events(tmp_ce)
          o.save! 
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

      desc 'reconcile colls'
      task :reconcile_colls => [:data_directory, :environment] do |t, args| 
        path = @args[:data_directory] + 'coll.csv'
        raise 'file not found' if not File.exists?(path)

        f = CSV.open(path, col_sep: "\t")
        f.each do |row|
          if r = Repository.where(acronym: row[0]).first
            # puts r.id
          else
            print "#{row[0]}\t#{row[1]}\n" if not  Repository.where(acronym: "#{row[0]}\<IH\>").first
          end
        end

        f.close
      end

      desc 'reconcile language'
      task :reconcile_languages => [:data_directory, :environment] do |t, args| 
        path = @args[:data_directory] + 'language.csv'
        raise 'file not found' if not File.exists?(path)

        f = CSV.open(path, col_sep: "\t")
        f.each do |row|
          if r = Language.where(alpha_2: row[0]).first
            # puts r.id
          else
            print "#{row[0]}\t#{row[1]}\n" 
          end
        end
        f.close
      end

      def fix_line(line)
        line.gsub(/\t\\N\t/, "\t\"NULL\"\t").gsub(/\\"/, '""') # .gsub(/\t/, '|')
      end

      def column_values(fixed_line)
        CSV.parse(fixed_line, col_sep: "\t").first
      end

      desc 'reconcile Refs::Chalcfam (look for unique values)'
      task :reconcile_refs_chalcfam => [:data_directory, :environment] do |t, args| 
        path = @args[:data_directory] + 'refs.csv'

        raise 'file not found' if not File.exists?(path)

        # f = CSV.open(path, col_sep: "\t")
        families = {}

        # This pattern handles quotes/escaping crap MySQL export
        File.foreach(path) do |csv_line| 
          row = column_values(fix_line(csv_line))

          if row[12]
            v = row[12].strip
            r = nil             
            if v  =~ /\s/
              r = Regexp.new(/\s/)
            else
              r = Regexp.new(/(?=[A-Z])/)
            end

            row[12].split(r).inject(families){|hsh, v| hsh.merge!(v => nil)} 
          end
        end

        print families.keys.sort.join(", ")
        # f.close
      end

     desc 'handle refs - rake tw:project_import:ucd:handle_refs[/Users/matt/src/sf/import/ucd/csv]'
      task :handle_refs => [:data_directory, :environment, :handle_keywords] do |t, args| 
        # - 0   RefCode   | varchar(15)  |
        # - 1   Author    | varchar(52)  |
        # - 2   Year      | varchar(4)   |
        # - 3   Letter    | varchar(2)   | # ?! key/value - if they want to maintain a manual system let them
        # - 4   PubDate   | date         |
        # - 5   Title     | varchar(188) |
        # - 6   JourBook  | varchar(110) |
        # - 7   Volume    | varchar(20)  |
        # - 8   Pages     | varchar(36)  |
        # - 9   Location  | varchar(27)  | # Attribute::Internal
        # - 10  Source    | varchar(28)  | # Attribute::Internal
        # - 11  Check     | varchar(11)  | # Attribute::Internal
        # - 12  ChalcFam  | varchar(20)  | # Attribute::Internal a key/value (memory aid of john)
        # - 13  KeywordA  | varchar(2)   | # Tag 
        # - 14  KeywordB  | varchar(2)   | # Tag 
        # - 15  KeywordC  | varchar(2)   | # Tag 
        # - 16  LanguageA | varchar(2)   | Attribute::Internal & Language
        # - 17  LanguageB | varchar(2)   | Attribute::Internal
        # - 18  LanguageC | varchar(2)   | Attribute::Internal 
        # - 19  M_Y       | varchar(1)   | # Attribute::Internal fuzziness on month/day/year - an annotation
        # 20  PDF_file  | varchar(1)   | # [X or Y] TODO: NOT HANDLED

        # 0 RefCode   
        # - 1 Translate 
        # - 2 Notes     
        # - 3 Publisher 
        # - 4 ExtAuthor 
        # - 5 ExtTitle  
        # - 6 ExtJournal
        # - 7 Editor    

        path1 = @args[:data_directory] + 'refs.csv'
        path2 = @args[:data_directory] + 'refext.csv'
        raise 'file not found' if not File.exists?(path1)
        raise 'file not found' if not File.exists?(path2)

        fext_data = {}

        File.foreach(path2) do |csv_line| 
          r = column_values(fix_line(csv_line))
          fext_data.merge!(
            r[0] => { translate: r[1], notes: r[2], publisher: r[3], ext_author: r[4], ext_title: r[5], ext_journal: r[6], editor: r[7] }
          )
        end

        namespace = Namespace.new(name: 'UCD refCode', short_name: 'UCDabc')
        namespace.save!

        keywords = {
          'Refs:Location' => Predicate.new(name: 'Refs::Location', definition: 'The verbatim value in Ref#location.'),
          'Refs:Source' => Predicate.new(name: 'Refs::Source', definition: 'The verbatim value in Ref#source.'),
          'Refs:Check' => Predicate.new(name: 'Refs::Check', definition: 'The verbatim value in Ref#check.'),
          'Refs:LanguageA' => Predicate.new(name: 'Refs::LanguageA', definition: 'The verbatim value in Refs#LanguageA'),
          'Refs:LanguageB' => Predicate.new(name: 'Refs::LanguageB', definition: 'The verbatim value in Refs#LanguageB'),
          'Refs:LanguageC' => Predicate.new(name: 'Refs::LanguageC', definition: 'The verbatim value in Refs#LanguageC'),
          'Refs:ChalcFam' => Predicate.new(name: 'Refs::ChalcFam', definition: 'The verbatim value in Refs#ChalcFam'),
          'Refs:M_Y' => Predicate.new(name: 'Refs::M_Y', definition: 'The verbatim value in Refs#M_Y.'),
          'Refs:PDF_file' => Predicate.new(name: 'Refs::PDF_file', definition: 'The verbatim value in Refs#PDF_file.'),
          'RefsExt:Translate' => Predicate.new(name: 'RefsExt::Translate', definition: 'The verbatim value in RefsExt#Translate.'),
        }

        keywords.values.each do |k|
          k.save!
        end

        i = 0 

        File.foreach(path1) do |csv_line| 
          row = column_values(fix_line(csv_line))

          year, month, day = nil, nil, nil
          if row[4] != 'NULL'
            year, month, day = row[4].split('-', 3) 
            month = Utilities::Dates::SHORT_MONTH_FILTER[month]
            month = month.to_s if !month.nil?
          end

          stated_year = row[2]
          if year.nil?
            year = stated_year 
            stated_year = nil
          end

          title = [row[5],  (fext_data[row[0]] && !fext_data[row[0]][:ext_title].blank? ? fext_data[row[0]][:ext_title] : nil)].compact.join(" ")
          journal = [row[6],  (fext_data[row[0]] && !fext_data[row[0]][:ext_journal].blank? ? fext_data[row[0]][:ext_journal] : nil)].compact.join(" ")
          author = [row[1],  (fext_data[row[0]] && !fext_data[row[0]][:ext_author].blank? ? fext_data[row[0]][:ext_author] : nil)].compact.join(" ")

          b = Source::Bibtex.new(
            author: author,
            year: (year.blank? ? nil : year.to_i),
            month: month, 
            day: (day.blank? ? nil : day.to_i) ,
            stated_year: stated_year,
            year_suffix: row[3],           
            title: title,                      
            booktitle: journal,                  
            volume: row[7],                     
            pages: row[8],                      
            bibtex_type: 'article',            
            language: (row[16] ? Language.where(alpha_2: row[16] ).first : nil),
            publisher: (fext_data[row[0]] ? fext_data[row[0]][:publisher] : nil),
            editor: (fext_data[row[0]] ? fext_data[row[0]][:editor] : nil ),
          )

          b.publisher = nil if b.publisher.blank? # lazy get rid of ""
          b.editor = nil if b.editor.blank?

          b.save!

          b.identifiers.build(type: 'Identifier::LocalId', namespace: namespace, identifier: row[0]) 

          b.data_attributes.build(type: 'DataAttribute::InternalAttribute', predicate: keywords['Refs:Location'], value: row[9])    if !row[9].blank?
          b.data_attributes.build(type: 'DataAttribute::InternalAttribute', predicate: keywords['Refs:Source'], value: row[10])     if !row[10].blank?
          b.data_attributes.build(type: 'DataAttribute::InternalAttribute', predicate: keywords['Refs:Check'], value: row[11])      if !row[11].blank?
          b.data_attributes.build(type: 'DataAttribute::InternalAttribute', predicate: keywords['Refs::ChalcFam'], value: row[12])  if !row[12].blank?
          b.data_attributes.build(type: 'DataAttribute::InternalAttribute', predicate: keywords['Refs:LanguageA'], value: row[16])  if !row[16].blank?
          b.data_attributes.build(type: 'DataAttribute::InternalAttribute', predicate: keywords['Refs:LanguageB'], value: row[17])  if !row[17].blank?
          b.data_attributes.build(type: 'DataAttribute::InternalAttribute', predicate: keywords['Refs:LanguageB'], value: row[18])  if !row[18].blank?
          b.data_attributes.build(type: 'DataAttribute::InternalAttribute', predicate: keywords['Refs:M_Y'], value: row[19])        if !row[19].blank?

          if fext_data[row[0]]
            b.data_attributes.build(type: 'DataAttribute::InternalAttribute', predicate: keywords['RefsExt:Translate'], value: fext_data[row[0]][:translate]) if !fext_data[row[0]][:translate].blank?
            b.notes.build(text: fext_data[row[0]][:note]) if !fext_data[row[0]][:note].nil?
          end

          [13,14,15].each do |i| 
            k =  Keyword.with_alternate_value_on(:name, row[i]).first
            if k 
              b.tags.build(keyword: k)
            end
          end

          !b.save

          print "#{i}," 
          i+=1
          break if i > 200 
        end
      end

    end
  end
end



