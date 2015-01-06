require 'fileutils'
require 'benchmark'


# When first starting development, use a blank database with:
#    rake db:drop && rake db:create && rake db:migrate
#
#    rake tw:project_import:insects:import_insects data_directory=/Users/proceps/src/sf/import/inhs-insect-collection-data/ no_transaction=true
# Only data upto the handle_taxa can be loaded from the database or restored from 
# a dump file.  All data after that (specimens, collecting events) must be parsed from scratch.
#
# Be aware of shared methods in lib/tasks/import/shared.rake.
#

namespace :tw do
  namespace :project_import do
    namespace :insects do

      IMPORT_NAME = 'insects'

      # A utility class to index data.
      class ImportedData
        attr_accessor :people, :people_id, :keywords, :users, :collecting_events, :collection_objects, :otus, :namespaces
        def initialize()
          @keywords = {}
          @people = {}
          @people_id = {}
          @users = {}
          @namespaces = {}
          @collecting_events = {}
          @collection_objects = {}
          @otus = {}
        end

        def export_to_pg(data_directory) 
          puts "\nExporting snapshot of datababase to all.dump."
          Support::Database.pg_dump_all('taxonworks_development', data_directory, 'all.dump')
        end
      end

      $preparation_types = {}
      #$project_id = nil
      #$user_id = nil
      $repository = nil
      $user_index = {}
      $collecting_event_index = {}
      $invalid_collecting_event_index = {}

      # These are largely collecting event related
      PREDICATES = [
        'Country',
        'County',
        'State',

        #"AccessionNumber",
        'BodyOfWater',
        'Collection',
        'Comments',

        #"Datum",
        'Description',
        'DrainageBasinGreater',
        'DrainageBasinLesser',
        'Family',

        'Genus',
        'Host',
        'HostGenus',
        'HostSpecies',
        'INDrainage',
        'LedgerBook',
        'LocalityCode',
        'OldLocalityCode',
        'Order',
        'Park',
        'Remarks',
        'Sex',
        'Species',
        'StreamSize',
        'WisconsinGlaciated',

        'PrecisionCode',    # tag on Georeference

        'Prefix',        #specimens
        'CatalogNumber',
        'TaxonCode',
        'LocalityCode',
        'SpecialCollection',
        'IdentifiedBy',
        'YearIdentified',
        'Type',
        'TypeName',
        'AccessionNumberLabel',
        'SpecialCollection',
        'OldLocalityCode',
        'OldCollector',
        'OldIdentifiedBy'
      ]

      # TODO: Lots could be added here, it could also be yamlified
      GEO_NAME_TRANSLATOR = {
        'U.S.A.' => 'United States',
        'U. S. A.' => 'United States',
        'Quebec' => 'Québec',
        'U.S.A' => 'United States',
        'MEXICO' => 'Mexico',
        'U. S. A. ' => 'United States'
      }

      CONTAINER_TYPE = {
        '' => 'Container::Virtual',            # TODO: update with propper class
        'amber' => 'Container::Box',       # remove
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
           Comments}

      # Attributes to strip on CollectingEvent creation
      STRIP_LIST = %w{ModifiedBy ModifiedOn CreatedBy CreatedOn Latitude Longitude Elevation} # the last three are calculated

      TAXA = {}
      PEOPLE = {}

      desc "Import the INHS insect collection dataset.\n
      rake tw:project_import:insects:import_insects data_directory=/Users/matt/src/sf/import/inhs-insect-collection-data/  \n
      alternately, add: \n
        restore_from_dump=true   (attempt to load the data from the dump) \n
        no_transaction=true      (don't wrap import in a transaction, this will also force a dump of the data)\n"
      task :import_insects => [:environment, :data_directory] do |t, args|
        puts @args
        Utilities::Files.lines_per_file(Dir["#{@args[:data_directory]}/TXT/**/*.txt"])
        LOCALITIES = build_localities_index(@args[:data_directory])        

        @dump_directory = dump_directory(@args[:data_directory]) 
        @data =  ImportedData.new

        restore_from_pg_dump if ENV['restore_from_dump'] && File.exists?(@dump_directory + 'all.dump')

        begin
          if ENV['no_transaction']
            puts 'Importing without a transaction (data will be left in the database).'
            main_build_loop
          else
            ActiveRecord::Base.transaction do 
              main_build_loop 
              raise
            end
          end
        rescue
          raise
        end
      end

      def checkpoint_save(import)
        @import.save
        @data.export_to_pg(@dump_directory) 
      end

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


      def main_build_loop
        @import = Import.find_or_create_by(name: IMPORT_NAME)  
        @import.metadata ||= {} 
        handle_projects_and_users(@data, @import)
        raise '$project_id or $user_id not set.'  if $project_id.nil? || $user_id.nil?
        handle_namespaces(@data, @import)
        handle_preparation_types(@data, @import)
        handle_controlled_vocabulary(@data, @import)

        handle_people(@data, @import) ## !created as new

        handle_taxa(@data, @import)

        checkpoint_save(@import) if ENV['no_transaction']

        # !! The following can not be loaded from the database they are always created anew.
        handle_collecting_events(@data, @import)
        handle_specimens(@data, @import)

        # handle_users(@data, @import)

        @import.save!
        puts "\n\n !! Success \n\n"
      end

      def handle_projects_and_users(data, import)
        print "Handling projects and users "
        email = 'inhs_admin@replace.me'
        project_name = 'INHS Insect Collection'
        user_name = 'INHS Insect Collection Import'
        user, project = nil, nil
        if import.metadata['project_and_users']
          print "from database.\n"
          project = Project.where(name: project_name).first
          user = User.where(email: email).first
          $project_id = project.id
          $user_id = user.id
        else
          print "as newly parsed.\n"

          user = User.where(email: email)
          if user.empty?
            user = User.create(email: email, password: '3242341aas', password_confirmation: '3242341aas', name: user_name, self_created: true)
          else
            user = user.first
          end
          $user_id = user.id # set for project line below

          project = Project.where(name: project_name)
          if project.empty?
            project = Project.create(name: project_name)
          else
            project = project.first
          end

          $project_id = project.id
          pm = ProjectMember.new(user: user, project: project, is_project_administrator: true)
          pm.save! if pm.valid?

          import.metadata['project_and_users'] = true
        end

        $repository = Repository.where(institutional_LSID: 'urn:lsid:biocol.org:col:34797').first
        $user_index.merge!('0' => user.id)
        #data.users.merge!(user.email => user)

      end

      def handle_namespaces(data, import)
        print "Handling namespaces "

        catalogue_namespaces = [
            'Acari',
            'Araneae',
            'Coleoptera',
            'Diplopoda',
            'Diptera',
            'Ephemeroptera',
            'Heteroptera',
            'Homoptera',
            'Hymenoptera',
            'Insect Collection',
            'Lepidoptera',
            'Loan Invoice',
            'Mecoptera',
            'Neuroptera',
            'Odonata',
            'Opiliones',
            'Orthoptera',
            'Phthiraptera',
            'Plecoptera',
            'Pseudoscorpiones',
            'Psocoptera',
            'Scorpiones',
            'Strepsiptera',
            'Trichoptera'
        ]

        if import.metadata['namespaces']
          @import_namespace = Namespace.where(institution: 'INHS Insect Collection', name: 'INHS Import Identifiers', short_name: 'Import').first
          @accession_namespace = Namespace.where(institution: 'INHS Insect Collection', name: 'INHS Legacy Accession Code', short_name: 'Accession Code').first
          print "from database.\n"
        else
          print "as newly parsed.\n"
          @import_namespace = Namespace.create(institution: 'INHS Insect Collection', name: 'INHS Import Identifiers', short_name: 'Import')
          @accession_namespace = Namespace.create(institution: 'INHS Insect Collection', name: 'INHS Legacy Accession Code', short_name: 'Accession Code')
          import.metadata['namespaces'] = true
        end

        catalogue_namespaces.each do |cn|
          n = Namespace.where(institution: 'INHS Insect Collection', short_name: cn)
          if n.empty?
            n = Namespace.create(institution: 'INHS Insect Collection', name: 'INHS ' + cn, short_name: cn)
          else
            n = n.first
          end
          data.namespaces.merge!(cn => n)
        end

        data.namespaces.merge!(import_namespace: @import_namespace)
        data.namespaces.merge!(accession_namespace: @accession_namespace)
      end

      def handle_preparation_types(data, import)
        print "Handling namespaces "

        preparation_types = [
            'Bulk dry',
            'Envelope',
            'Jar',
            'Pill box',
            'Pin',
            'Slide',
            'Vial'
          ]
        preparation_types.each do |pt|
          t = PreparationType.where(name: pt)
          if t.empty?
            t = PreparationType.create(name: pt) if t.nil?
          else
            t = t.first
          end
          $preparation_types.merge!(pt => t)
        end
        $preparation_types.merge!('Slides' => $preparation_types['Slide'])
        $preparation_types.merge!('Vials' => $preparation_types['Vial'])
        $preparation_types.merge!('pill box' => $preparation_types['Pill box'])
      end


            # Builds all the controlled vocabulary terms (tags/keywords)
      def handle_controlled_vocabulary(data, import)
        print "Handling CV "
        if import.metadata['controlled_vocabulary']
          print "from database.\n"
          ControlledVocabularyTerm.all.each do |cv|
            data.keywords.merge!(cv.name => cv)
          end
        else
          print "as newly parsed.\n"
          # from collecting_events
          PREDICATES.each do |p|
            data.keywords.merge!(p => Predicate.create(name: "CollectingEvents:#{p}", definition: "The verbatim value imported in for #{p}.")  )
          end

          # from handle taxa
          data.keywords.merge!(  
              'Taxa:Synonyms' => Predicate.create(name: 'Taxa:Synonyms', definition: 'The verbatim value on import from Taxa#Synonyms.'),
              'Taxa:References' => Predicate.create(name: 'Taxa:References', definition: 'The verbatim value on import Taxa#References.')
          )

          # from handle specimens
          data.keywords.merge!(  
                               'AdultMale' => BiocurationClass.create(name: 'AdultMale', definition: 'The collection object is comprised of adult male(s).'), 
                               'AdultFemale' => BiocurationClass.create(name: 'AdultFemale', definition: 'The collection object is comprised of adult female(s).'), 
                               'Immature' => BiocurationClass.create(name: 'Immature', definition: 'The collection object is comprised of immature(s).'), 
                               'Pupa' => BiocurationClass.create(name: 'Pupa', definition: 'The collection object is comprised of pupa.'), 
                               'Exuvium' => BiocurationClass.create(name: 'Exuvia', definition: 'The collection object is comprised of exuvia.'),
                               'AdultUnsexed' => BiocurationClass.create(name: 'AdultUnsexed', definition: 'The collection object is comprised of adults, with sex undetermined.'), 
                               'AgeUnknown' => BiocurationClass.create(name: 'AgeUnknown', definition: 'The collection object is comprised of individuals of indtermined age.'), 
                               'OtherSpecimens' => BiocurationClass.create(name: 'OtherSpecimens', definition: 'The collection object that is asserted to be unclassified in any manner.'), 
                               'ZeroTotal' => Keyword.create(name: 'ZeroTotal', definition: 'On import there were 0 total specimens recorded in the FM database.'),
                               'IdentifiedBy' => Predicate.create(name: 'IdentifiedBy', definition: 'The verbatim value in the identified by field.'),
                               'YearIdentified' => Predicate.create(name: 'YearIdentified', definition: 'The verbatim value in the year identified field.'),
                               'OldIdentifiedBy' => Predicate.create(name: 'OriginalIdentifiedBy', definition: 'Imported value: Old identified by.'),
                               'LocalityCode' => Predicate.create(name: 'LocalityCode', definition: 'Imported value: Locality Code.'),
                               'Country' => Predicate.create(name: 'Country', definition: 'Imported value: Country.'),
                               'State' => Predicate.create(name: 'State', definition: 'Imported value: State.'),
                               'County' => Predicate.create(name: 'County', definition: 'Imported value: County.'),
                               'Locality' => Predicate.create(name: 'Locality', definition: 'Imported value: Locality.'),
                               'Park' => Predicate.create(name: 'Park', definition: 'Imported value: Park.'),
                               'BodyOfWater' => Predicate.create(name: 'BodyOfWater', definition: 'The verbatim value in the Body Of Water.'),
                               'DrainageBasinLesser' => Predicate.create(name: 'DrainageBasinLesser', definition: 'The verbatim value in the Drainage Basin Lesser.'),
                               'DrainageBasinGreater' => Predicate.create(name: 'DrainageBasinGreater', definition: 'The verbatim value in the Drainage Basin Greater.'),
                               'StreamSize' => Predicate.create(name: 'StreamSize', definition: 'The verbatim value in the StreamSize.'),
                               'INDrainage' => Predicate.create(name: 'INDrainage', definition: 'The verbatim value in the INDrainage.'),
                               'WisconsinGlaciated' => Predicate.create(name: 'WisconsinGlaciated', definition: 'The verbatim value in the Wisconsin Glaciated.'),
                               'OldLocalityCode' => Predicate.create(name: 'OldLocalityCode', definition: 'Imported value: Old Locality Code.'),
                               'Host' => Predicate.create(name: 'Host', definition: 'The verbatim value in the Host.'),
                              )

          import.metadata['controlled_vocabulary'] = true
        end
      end


      def find_or_create_collection_user(id, data)
        if id.blank?
          $user_id
        elsif $user_index[id]
          $user_index[id]
        elsif data.people_id[id]
          p = data.people_id[id]
          email = p['Email']
          if email.blank?
            puts 'PeopleID = ' + id.to_s + ' does not have e-mail' if email.blank?
            $user_id
          else
            user_name = p['LastName'] + ', ' + p['FirstName'] + ' - imported'

            user = User.create(email: email, password: '3242341aas', password_confirmation: '3242341aas', name: user_name,
                   data_attributes_attributes: [ {value: p['PeopleID'], import_predicate: 'PeopleID', type: 'ImportAttribute'} ] )

            unless p['SupervisorID'].blank?
              s = data.people_id[p['SupervisorID']]
              user.notes.create(text: 'Student of ' + s['FirstName'] + ' ' + s['LastName']) unless s.blank?
            end
            $user_index.merge!(id => user.id)
            user
          end
        else
          $user_id
        end
      end


      $found_geographic_areas = 0
      $matchless_for_geographic_area =[]


      def find_or_create_collecting_event(ce, data)

        tmp_ce = { }
        LOCALITY_COLUMNS.each do |c|
          tmp_ce.merge!(c => ce[c]) unless ce[c].blank?
        end

        unless $collecting_event_index[tmp_ce].nil?
          collecting_event = $collecting_event_index[tmp_ce]
          if collecting_event.data_attributes['LocalityCode'].nil? && !tmp_ce['LocalityCode'].nil?
            collecting_event.data_attributes.create(predicate: 'LocalityCode', value: tmp_ce['LocalityCode'], type: 'ImportAttribute')
          end
          if collecting_event.verbatim_locality.nil? && !tmp_ce['LocalityLabel'].nil?
            collecting_event.verbatim_locality = tmp_ce['LocalityLabel']
            collecting_event.save!
          end
          return collecting_event
        end

        latitude, longitude = parse_lat_long(ce)
        sdm, sdd, sdy, edm, edd, edy = parse_dates(ce)
        elevation, verbatim_elevation = parse_elevation(ce)
        geographic_area = parse_geographic_area(ce)
        geolocation_uncertainty = parse_geolocation_uncertainty(ce)

        c = CollectingEvent.new(
            geographic_area_id: geographic_area,
            verbatim_label: ce['LocalityLabel'],
            verbatim_locality: (ce['Locality'] + ' ' + ce['Park']).squish,
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
            verbatim_elevation: verbatim_elevation,
            verbatim_latitude: latitude,
            verbatim_longitude: longitude,
            verbatim_geolocation_uncertainty: geolocation_uncertainty,
            verbatim_datum: ce['Datum'],
            verbatim_trip_identifier: ce['AccessionNumber'],
            created_by_id: find_or_create_collection_user(ce['CreatedBy'], data),
            updated_by_id: find_or_create_collection_user(ce['ModifiedBy'], data),
            created_at: time_from_field(ce['CreatedOn']),
            updated_at: time_from_field(ce['ModifiedOn'])
        )
        if c.valid?
          c.save!
          c.notes.create(text: ce['Comments']) unless ce['Comments'].blank?
          ce.select{|k,v| !v.nil?}.each do |a,b|
            if PREDICATES.include?(a)
              c.data_attributes.create(predicate: data.keywords[a], value: b, type: 'ImportAttribute')
            end
          end

          c.generate_verbatim_georeference
          $collecting_event_index.merge!(tmp_ce => c)
          return c
        else
          $invalid_collecting_event_index.merge!(tmp_ce => nil)
          return nil
        end
      end

      #- 0 PeopleID          Import Identifier
      #  1 SupervisorID      Loan#supervisor_person_id  ?
      #
      #- 2 LastName
      #- 3 FirstName
      #
      #  4 Honorarium        Loan#recipient_honorarium
      #  5 Address           Loan#recipient_address
      #  6 Country           Loan#recipient_country
      #  7 Email             Loan#recipient_email
      #  8 Phone             Loan#recipent_phone

      # - 9 Comments          Note.new
      #
      def handle_people(data, import)
        path = @args[:data_directory] + 'TXT/people.txt'
        raise 'file not found' if not File.exists?(path)
        f = CSV.open(path, col_sep: "\t", :headers => true)

        print 'Handling people '
        if import.metadata['people']
          print "from database.  Indexing People by PeopleID..."
          f.each do |row|
            data.people_id.merge!(row['PeopleID'] => row)
          end

          DataAttribute.where(import_predicate: 'PeopleID', attribute_subject_type: 'User').each do |u|
            $user_index.merge!(u.value => u.attribute_subject_id)
          end

          DataAttribute.where(import_predicate: 'PeopleID', attribute_subject_type: 'People').each do |p|
            PEOPLE.merge!(p.value => p.attribute_subject_id)
          end

          print "done.\n"
        else
          print "as newly parsed.\n"
          f.each do |row|
            puts "\tNo last name: #{row}" if row['LastName'].blank?
            p = Person::Vetted.new(
                last_name: row['LastName'] || 'Not Provided',
                first_name: row['FirstName'],
                data_attributes_attributes: [ {value: row['PeopleID'], import_predicate: 'PeopleID', type: 'ImportAttribute'} ]
            )
            p.notes.build(text: row['Comments']) if !row['Comments'].blank?
            p.save!
            #data.people.merge!(row => p)
            data.people_id.merge!(row['PeopleID'] => row)
            PEOPLE.merge!(row['PeopleID'] => p)
          end
          import.metadata['people'] = true
        end
      end

      #   ID             Not Included (parent use only)
      #
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
      #
      # -- is on the OTU
      #   TaxonCode      New Namespace Identifier 
      def handle_taxa(data, import)
        print "Handling taxa "
        if import.metadata['taxa']
          print "from database.  Indexing OTUs by TaxonCode..."
          Otu.includes(:identifiers).each do |o|
            # There is only one identifier added at this point, so we are safe here. If this changes specify here.
            data.otus.merge!(o.identifiers.first.identifier => o)
          end
          print "done.\n" 
        else
          print "as newly parsed.\n"
          puts

          path = @args[:data_directory] + 'TXT/taxa_hierarchical.txt'
          raise 'file not found' if not File.exists?(path)

          parent_index = {}
          f = CSV.open(path, col_sep: "\t", :headers => true)


          code = :iczn

          f.first(500).each_with_index do |row, i|             #f.first(500).each_with_index
            name = row['Name']
            author = (row['Parens'] ? "(#{row['Author']})" : row['Author']) unless row['Author'].blank?
            author ||= nil
            code = :icn if code == :iczn && row['Name'] == 'Plantae'
            rank = Ranks.lookup(code, row['Rank'])
            rank ||= NomenclaturalRank

            p = Protonym.new(
              name: name,
              verbatim_author: author,
              year_of_publication: row['Year'],
              rank_class: rank,
              created_by_id: find_or_create_collection_user(row['CreatedBy'], data),
              updated_by_id: find_or_create_collection_user(row['ModifiedBy'], data),
              #creator: find_or_create_user(row['CreatedBy'], data),
              #updater: find_or_create_user(row['ModifiedBy'], data),
              created_at: time_from_field(row['CreatedOn']),
              updated_at: time_from_field(row['ModifiedOn'])
            )
            p.parent_id = parent_index[row['Parent'].to_s].id unless row['Parent'].blank? || parent_index[row['Parent'].to_s].nil?
            if rank == NomenclaturalRank || !p.parent_id.blank?
              bench = Benchmark.measure {
                p.save
                build_otu(row, p, data)
              }

              if p.valid?
                parent_index.merge!(row['ID'] => p)
                TAXA.merge!(row['TaxonCode'] => p)
                print "\r#{i}\t#{bench.to_s.strip}  #{name}                           " #  \t\t#{rank}
              else
                puts "\n#{p.name}"
                puts p.errors.messages
                puts
              end
            else
              puts "\n  No parent for #{p.name}.\n"
            end


            p.data_attributes.create(type: 'InternalAttribute', predicate: data.keywords['Taxa:Synonyms'], value: row['Synonyms'])     unless row['Synonyms'].blank?
            p.data_attributes.create(type: 'InternalAttribute', predicate: data.keywords['Taxa:References'], value: row['References']) unless row['References'].blank?
            p.notes.create(text: row['Remarks']) unless row['Remarks'].blank?

            #p.parent_id = p.parent.id if p.parent && !p.parent.id.blank?

          end

          import.metadata['taxa'] = true
        end
      end

      def build_otu(row, taxon_name, data)
        if row['TaxonCode'].blank?
          # puts "  Skipping OTU creation for #{taxon_name.name}, there is no TaxonCode."
          return true
        end
        o =  Otu.create(
          taxon_name_id: taxon_name.id,
          identifiers_attributes: [  {identifier: row['TaxonCode'], namespace: @identifier_namespace, type: 'Identifier::Local::OtuUtility'} ]
        )

        data.otus.merge!(row['TaxonCode'] => o)
        o
      end

      def handle_collecting_events(data, import)
        matchless_for_geographic_area = []
        found = 0

        collecting_events_index = {}
        unmatched_localities = {}
        invalid_specimens = {}
        unmatched_taxa = {}

        puts "Indexing collecting events."
        index_collecting_events_from_accessions_new(data)
        index_specimen_records_from_specimens(unmatched_localities, unmatched_taxa, invalid_specimens, data)



        index_collecting_events_from_specimens_new(collecting_events_index, unmatched_localities)
        #index_collecting_events_from_ledgers(collecting_events_index)
        puts "\nTotal collecting events to build: #{collecting_events_index.keys.length}."


        puts "\nUnmatched localities: #{unmatched_localities.to_s}."
        puts "\nUnmatched taxa: #{unmatched_taxa.to_s}."
        puts "\nInvalid_specimens: #{invalid_specimens.to_s}."

        # Debugging code, turn this on if you want to inspect all the columns that 
        # are used to index a unique collecting event.
        # all_keys = [] 
        # collecting_events_index.keys.each_with_index do |hsh, i|
        #   all_keys.push hsh.keys
        #   all_keys.flatten!.uniq!
        # end
        # all_keys.sort!

      end

      # Index localities by their collective column=>data pairs
      def build_localities_index(data_directory)

        locality_fields = %w{ LocalityCode Country State County Locality Park BodyOfWater NS Lat_deg Lat_min Lat_sec EW Long_deg Long_min Long_sec Latitude Longitude Elev_m Elev_ft Elevation PrecisionCode Comments DrainageBasinLesser DrainageBasinGreater StreamSize INDrainage WisconsinGlaciated OldLocalityCode CreatedOn ModifiedOn CreatedBy ModifiedBy }

        localities_file = data_directory + 'TXT/localities.txt'
        raise 'file not found' if not File.exists?(localities_file)
        lo = CSV.open(localities_file, col_sep: "\t", :headers => true)

        puts "Indexing localities."

        localities = {}
        lo.each do |row|
          tmp_l = {}
          locality_fields.each do |c|
            tmp_l.merge!(c => row[c]) unless row[c].blank?
          end
          localities.merge!(row['LocalityCode'] => tmp_l)
        end

        localities
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

      # SPECIMENS_COLUMNS = %w{LocalityCode DateCollectedBeginning DateCollectedEnding Collector CollectionMethod Habitat}
      def index_specimen_records_from_specimens(unmatched_localities, unmatched_taxa, invalid_specimens, data)
        puts " specimen records from specimens.text"
        path = @args[:data_directory] + 'TXT/specimens.txt'
        raise 'file not found' if not File.exists?(path)

        sp = CSV.open(path, col_sep: "\t", :headers => true)

        specimen_fields = %w{ Prefix CatalogNumber PreparationType TaxonCode LocalityCode AccessionSource DeaccessionRecipient DeaccessionCause DeaccessionDate DateCollectedBeginning DateCollectedEnding Collector LocalityLabel AccessionNumberLabel DeterminationLabel OtherLabel SpecialCollection IdentifiedBy YearIdentified CollectionMethod Habitat Type TypeName Remarks AdultMale AdultFemale Immature Pupa Exuvium AdultUnsexed AgeUnknown OtherSpecimens Checked OldLocalityCode OldCollector OldIdentifiedBy CreatedBy CreatedOn ModifiedOn ModifiedBy }
        count_fields = %w{ AdultMale AdultFemale Immature Pupa Exuvium AdultUnsexed AgeUnknown OtherSpecimens }

        sp.each_with_index do |row, i|
          print "\r#{i}      "

          locality_code = row['LocalityCode']
          tmp_ce = { }   
          SPECIMENS_COLUMNS.each do |c|
            tmp_ce.merge!(c => row[c]) unless row[c].blank?
          end

          if LOCALITIES[locality_code]
            #Utilities::Hashes.puts_collisions(tmp_ce, LOCALITIES[locality_code])
            tmp_ce.merge!(LOCALITIES[locality_code])
          else
            unmatched_localities.merge!(row['LocalityCode'] => nil) unless locality_code.blank?
          end

          #collecting_events_index.merge!(tmp_ce  => nil)
          #collecting_events_index.merge!(Utilities::Hashes.delete_keys(tmp_ce, STRIP_LIST)  => nil)

          collecting_event = find_or_create_collecting_event(tmp_ce, data)
          otu = data.otus['TaxonCode']
          preparation_type = $preparation_types[se['preparation_type']]

          objects = []
          count_fields.each do |count|
            unless se[count].blank?
              specimen = CollectionObject.new(
              total: se[count],
              preparation_type_id: preparation_type,
              repository_id: $repository,
              buffered_collecting_event: se['LocalityLabel'],
              buffered_determinations: se['DeterminationLabel'],
              buffered_other_labels: se['OtherLabel'],
              collecting_event_id: collecting_event,
              deaccessioned_at: time_from_field(se['DeaccessionDate']),
              deaccession_reason: se['DeaccessionCause'],
              created_by_id: find_or_create_collection_user(se['CreatedBy'], data),
              updated_by_id: find_or_create_collection_user(se['ModifiedBy'], data),
              created_at: time_from_field(se['CreatedOn']),
              updated_at: time_from_field(se['ModifiedOn'])
              )
              if specimen.valid?
                specimen.save!
                objects += specimen
                specimen.notes.create(text: se['Remarks']) unless se['Remarks'].blank?
                se.select{|k,v| !v.nil?}.each do |a,b|
                  if PREDICATES.include?(a)
                    c.data_attributes.create(predicate: data.keywords[a], value: b, type: 'ImportAttribute')
                  end
                end
                if data.otus[se['TaxonCode']]
                  td = TaxonDetermination.create(
                     biological_collection_object_id: specimen,
                     otu_id: data.otus[se['TaxonCode']],
                     year_made: se['YearIdentified']
                      )
                  td.data_attributes.create(predicate: 'DetermidedBy', value: se['IdentifiedBy'], type: 'ImportAttribute')

                  if !se['Type'].blank? && !se['TypeName'].blank?
                    tm = TypeMaterial.create(
                        protonym_id: TAXA[se['TaxonCode']],
                        biological_object_id: specimen,
                        type_type: se['Type'],
                    )
                    tm.data_attributes.create(predicate: 'TypeName', value: se['TypeName'], type: 'ImportAttribute')
                  end

                else
                  unmatched_taxa.merge!(se['TaxonCode'] => nil) unless se['TaxonCode'].blank?
                end

                Role.create(person: PEOPLE[se['AccessionSource'], role_object: specimen, type: 'AccessionSource']) unless se['AccessionSource'].blank?
                Role.create(person: PEOPLE[se['DeaccessionRecipient'], role_object: specimen, type: 'DeaccessionRecipient']) unless se['DeaccessionRecipient'].blank?

              else
                invalid_specimens.merge!(se['Prefix'] + ' ' + se['CatalogueNumber'] => nil)
              end

            end
          end
          add_identifiers(objects, row)

        end

        puts "\n Number of collecting events processed from specimens: #{collecting_events_index.keys.count} "
        puts "\n!! The following are locality codes in specimens without corresponding values in localities (#{unmatched_localities.keys.count}): " + unmatched_localities.keys.sort.join(", ")
      end

      def index_collecting_events_from_specimens_new(collecting_events_index, unmatched_localities)
        puts " from specimens_new"
        path = @args[:data_directory] + 'TXT/specimens_new_partially_resolved.txt'
        raise 'file not found' if not File.exists?(path)

        sp = CSV.open(path, col_sep: "\t", :headers => true)

        unmatched_localities = { }
        sp.each_with_index do |row, i|
          print "\r#{i}      "

          locality_code = row['LocalityCode']
          tmp_ce = { }
          SPECIMENS_COLUMNS.each do |c|
            tmp_ce.merge!(c => row[c]) unless row[c].blank?
          end

          if LOCALITIES[locality_code]
            #Utilities::Hashes.puts_collisions(tmp_ce, LOCALITIES[locality_code])
            #tmp_ce.merge!(LOCALITIES[locality_code])
          else
            unmatched_localities.merge!(row['LocalityCode'] => nil) unless locality_code.blank?
          end

          collecting_events_index.merge!(tmp_ce  => nil) if !locality_code.blank? && row['Done'] == '1'
          #collecting_events_index.merge!(Utilities::Hashes.delete_keys(tmp_ce, STRIP_LIST)  => nil)
        end

        puts "\n Number of collecting events processed from specimensNew: #{collecting_events_index.keys.count} "
        puts "\n!! The following are locality codes in specimensNew without corresponding values in localities (#{unmatched_localities.keys.count}): " + unmatched_localities.keys.sort.join(", ")
      end

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
      # SPECIMENS_COLUMNS = %w{LocalityCode DateCollectedBeginning DateCollectedEnding Collector CollectionMethod Habitat}

      def index_collecting_events_from_ledgers(collecting_events_index)
        path = @args[:data_directory] + 'TXT/ledgers.txt'
        raise 'file not found' if not File.exists?(path)
        le = CSV.open(path, col_sep: "\t", :headers => true)

        puts "\n  from ledgers\n"
        le.each_with_index do |row, i|
          print "\r#{i}      "
          tmp_ce = { }
          SPECIMENS_COLUMNS.each do |c|
            tmp_ce.merge!(c => row[c]) unless row[c].blank?
          end
          #Utilities::Hashes.puts_collisions(tmp_ce, LOCALITIES[locality_code])
          puts "\n!! Duplicate collecting event: #{row['Collection']} #{row['AccessionNumber']}" unless collecting_events_index[tmp_ce].nil?

          collecting_events_index.merge!(tmp_ce => row.to_h)
          #collecting_events_index.merge!(Utilities::Hashes.delete_keys(row.to_h, STRIP_LIST) => nil)
        end
        puts "\n Number of collecting events processed from Ledgers: #{collecting_events_index.keys.count} "
      end

      def  index_collecting_events_from_accessions_new(data)
        path = @args[:data_directory] + 'TXT/accessions_new.txt' # self contained
        raise 'file not found' if not File.exists?(path)

        ac = CSV.open(path, col_sep: "\t", :headers => true)
        #ac = CSV.open(path, col_sep: "\t", :headers => true)


        accessions_new_fields = %w{ LocalityLabel Habitat Host AccessionNumber Country State County Locality Park DateCollectedBeginning DateCollectedEnding Collector CollectionMethod Elev_m Elev_ft NS Lat_deg Lat_min Lat_sec EW Long_deg Long_min Long_sec Comments PrecisionCode Datum ModifiedBy ModifiedOn }

        puts "\naccession new records\n"
        ac.each_with_index do |row, i|
          print "\r#{i}"
          tmp_ce = { }
          accessions_new_fields.each do |c|
            tmp_ce.merge!(c => row[c]) unless row[c].blank?
          end

          find_or_create_collecting_event(tmp_ce, data)

          #puts "\n!! Duplicate collecting event: #{row['Collection']} #{row['AccessionNumber']}" unless collecting_events_index[tmp_ce].nil?

          #collecting_events_index.merge!(tmp_ce => row.to_h)
          #collecting_events_index.merge!( Utilities::Hashes.delete_keys(row.to_h, STRIP_LIST)  => nil)
        end
        puts "\n Number of collecting events processed from Accessions_new: #{$collecting_events_index.keys.count} "
      end



      def parse_geographic_area(ce)
        geog_search = []
        [ ce['County'], ce['State'], ce['Country']].each do |v|
          geog_search.push( GEO_NAME_TRANSLATOR[v] ? GEO_NAME_TRANSLATOR[v] : v) if !v.blank?
        end

        match = GeographicArea.find_by_self_and_parents(geog_search)            
        geographic_area = nil

        if match.count == 0
          #puts "\nNo matching geographic area for: #{geog_search}"
          $matchless_for_geographic_area.push geog_search
        elsif match.count > 1
          #puts "\nMultiple geographic areas match #{geog_search}\n"
          $matchless_for_geographic_area.push geog_search
        elsif match.count == 1
          $found_geographic_areas += 1
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
        latitude = [nlt,ltd,ltm,lts].compact.join
        latitude = nil if latitude == '-'

        nll = ce['EW'] # (ce['EW'].downcase == 'w' ? '-' : nil ) if !ce['EW'].blank?
        lld = ce['Long_deg'].blank? ? nil : "#{ce['Long_deg']}º"
        llm = ce['Long_min'].blank? ? nil : "#{ce['Long_min']}'"
        lls = ce['Long_sec'].blank? ? nil : "#{ce['Long_sec']}\""
        longitude = [nll,lld,llm,lls].compact.join
        longitude = nil if longitude == '-'

        [latitude, longitude]
      end

      def parse_geolocation_uncertainty(ce)
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
              geolocation_uncertainty = 100000
            when 5
              geolocation_uncertainty = 1000000
            when 6
              geolocation_uncertainty = 1000000
          end
        end
      end

      def parse_dates(ce)
        sdm, sdd, sdy, edm, edd, edy = nil, nil, nil, nil, nil, nil
        ( sdm, sdd, sdy = ce['DateCollectedBeginning'].split("/") ) if !ce['DateCollectedBeginning'].blank?
        ( edm, edd, edy = ce['DateCollectedEnding'].split("/")    ) if !ce['DateCollectedEnding'].blank?

        sdy = sdy.to_i if sdy 
        edy = edy.to_i if edy
        sdd = sdd.to_i if sdd
        edd = edd.to_i if edd
        sdm = sdm.to_i if sdm
        edm = edy.to_i if edm
        [sdm, sdd, sdy, edm, edd, edy]
      end

      def parse_elevation(ce)
        ft =  ce['Elev_ft']
        m = ce['Elev_m'] 

        if !ft.blank? && !m.blank? && !Utilities::Measurements.feet_equals_meters(ft, m)
          puts "\n !! Feet and meters both providing and not equal: #{ft}, #{m}."
        end

        elevation, verbatim_elevation = nil, nil

        if !ce['Elev_ft'].blank?
          elevation = ce['Elev_ft'].to_i * 0.305
          verbatim_elevation = ce['Elev_ft'] & ' ft.'
        elsif !ce['Elev_m'].blank?
          elevation = ce['Elev_m'].to_i
        end
        [elevation, verbatim_elevation]
      end


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
      def handle_specimens(data, import)
        path = @args[:data_directory] + 'TXT/specimens.txt'
        raise 'file not found' if not File.exists?(path)
        co = CSV.open(path, col_sep: "\t", :headers => true)

        tmp_namespaces = {} 
        co.each do |row|
          tmp_namespaces.merge!(row['Prefix'] => nil)
        end

        tmp_namespaces.keys.delete_if{|k,v| k.nil? || k.to_s == ""} 
        tmp_namespaces.keys.each do |k|
          data.namespaces.merge!(k => Namespace.create(short_name: k) ) 
        end

        co.rewind
        co.each_with_index do |row, i|
          if data.otus[row['TaxonCode']] 
            data.collection_objects.merge!(i => objects_from_co_row(row) )
          end
        end
      end

      def objects_from_co_row(row)
        # otu = Identifier.of_type(:otu_utility).where(identifier: row['TaxonCode']).first.identifier_object
        otu = data.otus[row['TaxonCode']]

        return [] if otu.nil?

        determination = {
          otu: otu 
        }

        accession_attributes = { accessioned_at: '', # revisits 
                                 deaccession_at: row['DeaccessionData'],               
                                 accession_provider_id: data.people[row['AccessionSource']],       
                                 deaccession_recipient_id: data.people[row['AccessionSource']],    
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
            o.biocuration_classifications.build(biocuration_class: data.keywords[c])
            o.save
            if not o.valid?
              puts o.errors.messages
            end
            objects.push(o) 
          end
        end

        # Some specimen records have 0 total specimens! WATCH OUT.
        if objects.count == 0
          o = Specimen.create(taxon_determinations_attributes: [ determination] )
          o.tags.build(keyword: data.keywords['ZeroTotal'])
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
          o.update(collecting_event: data.collecting_events(tmp_ce) )
        end
      end 

      def add_identifiers(objects, row)
        puts "no catalog number for #{row['ID']}" if row['CatalogNumber'].blank?

        identifier = Identifier::Local::CatalogNumber.new(namespace: @data.namespaces[row['Prefix']], identifier: row['CatalogNumber']) if !row['CatalogNumber'].blank?
        #accession_number = InternalAttribute.new(value: row['AccessionNumber'], predicate: @data.keywords['AccessionCode']) if !row['AccessionNumber'].blank?

        if objects.count > 1 
          puts "More than one in a #{row['PreparationType']}"

         # objects.each do |o|
         #   o.data_attributes << accession_number.dup if accession_number
         #   o.save!
         # end

          # Identifier on container. 
          c = Container.containerize(objects)
          c.type = CONTAINER_TYPE[row['PreparationType'].to_s.downcase]
          c.save!
          c.identifiers << identifier if identifier
          c.save! 
          # Identifer on object
        elsif objects.count == 1
          objects.first.identifiers << identifier if identifier
          # objects.first.data_attributes << accession_number if accession_number
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

      def dump_directory(base)
        base + 'pg_dumps/'
      end

      def restore_from_pg_dump
        raise 'Database is not empty, it is not possible to restore from all.dump.' if Project.count > 0
        puts 'Restoring from all.dump (to avoid this use no_dump_load=true when calling the rake task).'
        ActiveRecord::Base.connection.execute('delete from schema_migrations')
        Support::Database.pg_restore_all('taxonworks_development', dump_directory(@args[:data_directory]),  'all.dump')
      end



    end
  end
end





