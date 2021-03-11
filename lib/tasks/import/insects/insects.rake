require 'fileutils'
require 'benchmark'


# When first starting development, use a blank database with:
#    rake db:drop && rake db:create && rake db:migrate
#
#    rake tw:project_import:insects:import_insects data_directory=/Users/proceps/src/sf/import/inhs-insect-collection-data/ no_transaction=true
# Only data upto the handle_taxa_insects can be loaded from the database or restored from 
# a dump file.  All data after that (specimens, collecting events) must be parsed from scratch.
#
# Be aware of shared methods in lib/tasks/import/shared.rake.
#
#
# redis-server /usr/local/etc/redis.conf          ## to start redis. It should be done before the rake started.
# redis-server ~/redis-4.0.8/redis.conf on a test machine
# a = Redis.new
# a.set(a, b)
# a.get(a)
# hash.sort

namespace :tw do
  namespace :project_import do
    namespace :insects do

      IMPORT_NAME = 'insects'.freeze

      # A utility class to index data.
      class ImportedData1
        attr_accessor :people_id, :keywords, :user_index, :collection_objects, :namespaces, :people_index, #:otus,
                      :preparation_types, :taxa_index, :localities_index, :host_plant_index, # :collecting_event_index,
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
          #@collecting_event_index = {}
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

        def export_to_pg(data_directory) 
          puts "\nExporting snapshot of datababase to all.dump."
          Support::Database.pg_dump_all(data_directory, 'all.dump')
        end
      end

      @preparation_types = {}
      @repository = nil
      @invalid_collecting_event_index = {}
      @redis = Redis.new

      # TODO: Lots could be added here, it could also be yamlified
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

#      TAXA = {}
#      PEOPLE = {}

      desc "Import the INHS insect collection dataset.\n
      rake tw:project_import:insects:import_insects data_directory=/Users/matt/src/sf/import/inhs-insect-collection-data/  \n
      alternately, add: \n
        restore_from_dump=true   (attempt to load the data from the dump) \n
        no_transaction=true      (don't wrap import in a transaction, this will also force a dump of the data)\n"
      task import_insects: [:environment, :data_directory] do |t, args|
        puts @args
        Utilities::Files.lines_per_file(Dir["#{@args[:data_directory]}/TXT/**/*.txt"])

        @dump_directory = dump_directory(@args[:data_directory]) 
        @data1 = ImportedData1.new

        restore_from_pg_dump if ENV['restore_from_dump'] && File.exists?(@dump_directory + 'all.dump')

        begin
          if ENV['no_transaction']
            puts 'Importing without a transaction (data will be left in the database).'
            main_build_loop_insects
          else
            ApplicationRecord.transaction do 
              main_build_loop_insects
              raise
            end
          end
        rescue
          raise
        end
      end

      def checkpoint_save_insects(import)
        import.metadata_will_change!
        import.save
        #@data1.export_to_pg(@dump_directory)
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

      def main_build_loop_insects

        @import = Import.find_or_create_by(name: IMPORT_NAME)
        @import.metadata ||= {} 

        handle_projects_and_users_insects(@data1, @import)
        raise '$project_id or $user_id not set.'  if $project_id.nil? || $user_id.nil?
        handle_namespaces_insects(@data1, @import)

        handle_controlled_vocabulary_insects(@data1, @import)

        handle_biocuration_classes_insects(@data1, @import)
        handle_biological_relationship_classes_insects(@data1, @import)
        handle_preparation_types_insects(@data1, @import)
        # should be run to clear redis database. if specimen from diffrent tables run one buy one, data could be left in Redis and reused
        @redis.flushall
=begin
        handle_people_insects(@data1, @import)
        GC.start
        handle_taxa_insects(@data1, @import)
        GC.start
        handle_loans_insects(@data1, @import)
        GC.start

        # !! The following can not be loaded from the database they are always created anew.

        build_localities_index_insects(@data1)

        puts 'Indexing collecting events.'

        index_collecting_events_from_accessions_new(@data1, @import)
        GC.start
        index_collecting_events_from_ledgers(@data1, @import)
        GC.start
        index_specimen_records_from_specimens_insects(@data1, @import)
        GC.start
        index_specimen_records_from_specimens_insects_new(@data1, @import)
        GC.start
        index_specimen_records_from_neon(@data1, @import)

        puts "\nTotal collecting events to build: #{@redis.keys.count}."
        handle_associations_insects(@data1, @import)
        GC.start
=end
        handle_loan_specimens_insects(@data1)
        GC.start
        handle_letters_insects(@data1)
        handle_collection_profile_insects(@data1)

        handle_locality_images(@data1)
#end
        handle_loan_images(@data1)

        puts "\n!! Unmatched localities: (#{@data1.unmatched_localities.keys.count}): " + @data1.unmatched_localities.keys.sort.join(', ')
        puts "\n!! Unmatched taxa: (#{@data1.unmatched_taxa.keys.count}): " + @data1.unmatched_taxa.keys.sort.join(', ')
        puts "\n!! Invalid_specimens: (#{@data1.invalid_specimens.keys.count}): " + @data1.invalid_specimens.sort.join(', ')
        puts "\n!! Duplicate_specimen_IDs: (#{@data1.duplicate_specimen_ids.keys.count}): " + @data1.duplicate_specimen_ids.sort.join(', ')

        @import.save!
        puts "\n\n !! Success \n\n"
      end

      def handle_projects_and_users_insects(data, import)
        print 'Handling projects and users '
        email = 'arboridia@gmail.com'
        project_name = 'INHS Insect Collection'
        user_name = 'INHS Insect Collection Import'
        $user_id, $project_id, @collection_container = nil, nil, nil
        if import.metadata['project_and_users']
          print "from database.\n"
          project = Project.where(name: project_name).first
          user = User.where(email: email).first
          collection_container = Container.where(name: project_name).first
          $project_id = project.id
          $user_id = user.id
          @collection_container = collection_container
        else
          print "as newly parsed.\n"

          user = User.where(email: email)
          if user.empty?
            pwd = rand(36**10).to_s(36)
            user = User.create(email: email, password: pwd, password_confirmation: pwd, name: user_name, self_created: true, is_flagged_for_password_reset: false)
          else
            user = user.first
          end
          $user_id = user.id # set for project line below

          project = Project.find_or_create_by(name: project_name)

          $project_id = project.id
          pm = ProjectMember.find_by(user: user, project: project)
          if pm.nil?
            pm = ProjectMember.new(user: user, project: project, is_project_administrator: true)
          else
            pm.is_project_administrator = true
          end
          pm.save

          cc = Container.where(name: project_name)
          if cc.empty?
            cc = Container::Collection.create(name: project_name )
          else
            cc = cc.first
          end
          @collection_container = cc.id

          import.metadata['project_and_users'] = true
        end

        @repository = Repository.where(acronym: 'INHS').first
        @repository = @repository.id unless @repository.nil?

        print "Repository not found\n" if @repository.nil?

        @data1.user_index.merge!(
          '0' => user,
          '' => user,
          nil => user
        )

      end

      def handle_biocuration_classes_insects(data, import)
        print "Handling biocuration classes \n"

        biocuration_classes = %w{Adult Male Female Immature Pupa Exuvia}

        biocuration_classes.each do |bc|
          b = BiocurationClass.where(name: bc, project_id: $project_id)
          if b.empty?
            b = BiocurationClass.create(name: bc, definition: bc + ' specimen..........')
          else
            b = b.first
          end
          data.biocuration_classes.merge!(bc => b)
        end
      end

      def handle_biological_relationship_classes_insects(data, import)
        print "Handling biological relationship classes \n"

        biological_relationships = { 'Attendance' => ['Attendant', 'Attended insect'],
                                     'Predation' => ['Predator', 'Prey'],
                                     'Parasitism' => ['Parasitoid', 'Host'],
                                     'Host plant' => ['Host', 'Herbivor'],
                                     'Pollination' => ['Pollinator', 'Pollinated plant'],
                                     'Mating' => ['Mate', 'Mate'],
#                                     'Dissected genitalia' => ['Genitalia', 'Body'],
#                                     'Dissected body part' => ['Body part', 'Body'],
                                     'Reared' => ['Exuvia or pupa', 'Body'] }

        export_relationships = { '15430'  => :ignore,
                                 'attendant' => ['Attendance', :reverse],
                                 'body'  => :ignore,
#                                 'body part (not genitalia)' => ['Dissected body part', :reverse],
#                                 'genitalia' => ['Dissected genitalia', :reverse],
                                 'body part (not genitalia)' => :origin,
                                 'genitalia' => :origin,
                                 'host' => ['Host plant', :direct],
                                 'host of' => ['Host plant', :direct],
                                 'mate' => ['Mating', :reverse],
                                 'parasite' => ['Parasitims', :reverse],
                                 'parasite of' => ['Parasitims', :reverse],
                                 'pollinating' => ['Pollination', :reverse],
                                 'pollination' => ['Pollination', :reverse],
                                 'predator' => ['Predation', :direct],
                                 'prey' => ['Predation', :reverse],
                                 'puparium' => ['Reared', :direct],
                                 'reared from' => ['Parasitims', :reverse],
                                 'soil' => :ignore,
                                 'tending' => ['Attendance', :reverse],
                                 'vicinity' => ['Pollination', :reverse] }

        biological_relationships.each_key do |br|
          b = BiologicalRelationship.where(name: br, project_id: $project_id)
          if b.empty?
            b = BiologicalRelationship.create(name: br)
            a1 = BiologicalRelationshipType.create(biological_property: data.biological_properties[biological_relationships[br][0]], biological_relationship: b, type: 'BiologicalRelationshipType::BiologicalRelationshipSubjectType')
            a2 = BiologicalRelationshipType.create(biological_property: data.biological_properties[biological_relationships[br][1]], biological_relationship: b, type: 'BiologicalRelationshipType::BiologicalRelationshipObjectType')
          end
        end

        export_relationships.each_key do |br|
          if export_relationships[br] == :ignore
            data.biological_relationships[br] = :ignore
          elsif export_relationships[br] == :origin
            data.biological_relationships[br] = :origin
          else
            b = BiologicalRelationship.where(name: export_relationships[br][0], project_id: $project_id).first
            rt = export_relationships[br][1]
            data.biological_relationships[br] = {'biological_relationship' => b, 'direction' => rt}
          end
        end
      end

      def handle_namespaces_insects(data, import)
        print 'Handling namespaces  '

        catalogue_namespaces = [
            'Amber',
            'Acari',
            'Araneae',
            'Coleoptera',
            'Collembola',
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
            'Trichoptera',
        ]

        if import.metadata['namespaces']
          @taxon_namespace = Namespace.where(institution: 'Illinois Natural History Survey', name: 'INHS Taxon Code', short_name: 'Taxon Code').first
          @accession_namespace = Namespace.where(institution: 'Illinois Natural History Survey', name: 'INHS Legacy Accession Code', short_name: 'Accession Code').first
          @user_namespace = Namespace.where(institution: 'Illinois Natural History Survey', name: 'INHS Legacy User ID', short_name: 'User ID').first
          print "from database.\n"
        else
          print "as newly parsed.\n"
          @taxon_namespace = Namespace.create(institution: 'Illinois Natural History Survey', name: 'INHS Taxon Code', short_name: 'Taxon Code')
          @accession_namespace = Namespace.create(institution: 'Illinois Natural History Survey', name: 'INHS Legacy Accession Code', short_name: 'Accession Code')
          @user_namespace = Namespace.create(institution: 'Illinois Natural History Survey', name: 'INHS Legacy User ID', short_name: 'User ID')
          import.metadata['namespaces'] = true
        end

        catalogue_namespaces.each do |cn|
          n = Namespace.find_or_create_by(institution: 'Illinois Natural History Survey', name: 'Illinois Natural History Survey ' + cn, short_name: 'INHS ' + cn)
          data.namespaces[cn] = n
        end

          n = Namespace.find_or_create_by(institution: 'Illinois Natural History Survey', name: 'INHS NEON', short_name: 'NEON')
        data.namespaces['NEON'] = n

          n = Namespace.find_or_create_by(institution: 'Illinois Natural History Survey', name: 'Illinois Natural History Survey loan invoice', short_name: 'INHS Invoice')
        data.namespaces['Invoice'] = n

          n = Namespace.find_or_create_by(institution: 'Illinois Natural History Survey', name: 'Illinois Natural History Survey container', short_name: 'INHS Container')
        data.namespaces['container'] = n

        data.namespaces.merge!(taxon_namespace: @taxon_namespace)
        data.namespaces.merge!(accession_namespace: @accession_namespace)
      end

      CONTAINER_TYPE = {
          nil => 'Container::Virtual',
          '' => 'Container::Virtual',
          'Amber' => 'Container::Box',
          'amber' => 'Container::Box',
          'Bulk dry' => 'Container::PillBox',
          'bulk dry' => 'Container::PillBox',
          'Envelope' => 'Container::Envelope',
          'envelope' => 'Container::Envelope',
          'Jar' => 'Container::Jar',
          'jar' => 'Container::Jar',
          'pill box' => 'Container::PillBox',
          'Pill box' => 'Container::PillBox',
          'Pill Box' => 'Container::PillBox',
          'Pin' => 'Container::Pin',
          'pin' => 'Container::Pin',
          'pins' => 'Container::Pin',
          'Pins' => 'Container::Pin',
          'Slide' => 'Container::Slide',
          'Slides' => 'Container::Slide',
          'slide' => 'Container::Slide',
          'slides' => 'Container::Slide',
          'Vial' => 'Container::Vial',
          'vial' => 'Container::Vial'
      }.freeze

      TYPE_TYPE = {
          'allolectotype' => 'lectotype',
          'allotype' => 'paratype',
          'cotype' => 'syntype',
          'holotype' => 'holotype',
          'holotype, allotype, paratype' => 'paratype',
          'holotype, paratype' => 'paratype',
          'holotype, paratype, allotype' => 'paratype',
          'lectoallotype' => 'lectotype',
          'lecto-allotype' => 'lectotype',
          'lectotype' => 'lectotype',
          'lectotype designated by' => 'lectotype',
          'lectotype, lectoallotype' => 'paralectotype',
          'lectotype, lecto-allotype' => 'paralectotype',
          'lectotype, paratype' => 'paratype',
          'neotype' => 'neotype',
          'paralectotype' => 'paralectotype',
          'parallotype' => 'paralectotype',
          'paratype' => 'paratype',
          'paratype, allotype' => 'paratype',
          'paratypes' => 'paratype',
          'syntype' => 'syntype',
          'syntypes' => 'syntype'
      }.freeze

      def handle_preparation_types_insects(data, import)
        print "Handling namespaces \n"

        preparation_types = {
            'Bulk dry' => 'Unsorted dry specimens',
            'Envelope' => 'Dry specimen(s) in envelope',
            'Pill box' => 'Specimens in pill box',
            'Jar' => 'Specimen(s) in jar...',
            'Pin' => 'Specimen(s) on pin...',
            'Slide' => 'Specimen(s) on slide.',
            'Vial' => 'Specimen(s) in vial..'
        }.freeze

        preparation_types.each do |pt|
          t = PreparationType.where(name: pt[0])
          if t.empty?
            t = PreparationType.create(name: pt[0], definition: pt[1])
            t.tags.create(keyword: data.keywords['INHS'])
          else
            t = t.first
          end
          data.preparation_types[pt[0]] = t
        end
        data.preparation_types['Slides'] = data.preparation_types['Slide']
        data.preparation_types['slides'] = data.preparation_types['Slide']
        data.preparation_types['slide'] = data.preparation_types['Slide']
        data.preparation_types['Vials'] = data.preparation_types['Vial']
        data.preparation_types['vials'] = data.preparation_types['Vial']
        data.preparation_types['vial'] = data.preparation_types['Vial']
        data.preparation_types['Jars'] = data.preparation_types['Jar']
        data.preparation_types.merge!('jars' => data.preparation_types['Jar'])
        data.preparation_types.merge!('jar' => data.preparation_types['Jar'])
        data.preparation_types.merge!('pill box' => data.preparation_types['Pill box'])
        data.preparation_types.merge!('Pill Box' => data.preparation_types['Pill box'])
        data.preparation_types.merge!('envelope' => data.preparation_types['Envelope'])
        data.preparation_types.merge!('pin' => data.preparation_types['Pin'])
        data.preparation_types.merge!('Pins' => data.preparation_types['Pin'])
        import.metadata['preparation_types'] = true
      end

      # These are largely collecting event related
      PREDICATES = [
          'Country',
          'County',
          'State',
          'LedgersCountry',
          'LedgersState',
          'LedgersCounty',
          'LedgersLocality',

          #"AccessionNumber",
          'BodyOfWater',
          'Collection',
          'LedgersComments',
          'Remarks',

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
          'Locality',
          'Park',
          'Sex',
          'Species',
          'StreamSize',
          'WisconsinGlaciated',

          'PrecisionCode',    # tag on Georeference
      ].freeze

      # Builds all the controlled vocabulary terms (tags/keywords)
      def handle_controlled_vocabulary_insects(data, import)
        print 'Handling CV '
        if import.metadata['controlled_vocabulary']
          print "from database.\n"
          Predicate.all.each do |cv|
            data.keywords[cv.name] = cv
          end
          data.keywords.merge!('Exuvium' => data.keywords['Exuvia'])
          Keyword.all.each do |cv|
            data.keywords[cv.name] = cv
          end
          BiologicalProperty.all.each do |cv|
            data.biological_properties[cv.name] = cv
          end
        else
          print "as newly parsed.\n"

          data.keywords.merge!('INHS' => Keyword.create(name: 'INHS', definition: 'Belongs to INHS Insect collection.'))
          data.keywords.merge!('INHS_imported' => Keyword.create(name: 'INHS_imported', definition: 'Imported from INHS Insect collection database.'))
          data.keywords.merge!('INHS_letters' => Keyword.create(name: 'INHS_letters', definition: 'Loan correspondance imported from INHS Insect collection database.'))
          data.keywords.merge!('body part (not genitalia)' => Keyword.create(name: 'body part (not genitalia)', definition: 'Dissected body part (not genitalia).'))
          data.keywords.merge!('genitalia' => Keyword.create(name: 'genitalia', definition: 'Dissected genitalia...'))

          # from collecting_events
          PREDICATES.each do |p|
            data.keywords.merge!(p => Predicate.create(name: "#{p}", definition: "The verbatim value imported from INHS FileMaker database for #{p}.")  )
          end

          # from handle taxa
          data.keywords.merge!(
              'TaxonCode' => Predicate.create(name: 'TaxonCode', definition: 'The verbatim value on import from INHS FileMaker database for Taxa#TaxonCode.'),
              'Synonyms' => Predicate.create(name: 'Synonyms', definition: 'The verbatim value on import from INHS FileMaker database for Taxa#Synonyms.'),
              'References' => Predicate.create(name: 'References', definition: 'The verbatim value on import INHS FileMaker database for Taxa#References.')
          )

          # from handle people
          data.keywords.merge!(
              'PeopleID' => Predicate.create(name: 'PeopleID', definition: 'PeopleID imported from INHS FileMaker database.'),
              'SupervisorID' => Predicate.create(name: 'SupervisorID', definition: 'People:SupervisorID imported from INHS FileMaker database.'),
              'Honorific' => Predicate.create(name: 'Honorific', definition: 'People:Honorific imported from INHS FileMaker database.'),
              'Address' => Predicate.create(name: 'Address', definition: 'People:Address imported from INHS FileMaker database.'),
              'Email' => Predicate.create(name: 'Email', definition: 'People:Email imported from INHS FileMaker database.'),
              'Phone' => Predicate.create(name: 'Phone', definition: 'People:Phone imported from INHS FileMaker database.')
          )

          # from handle specimens
          data.keywords.merge!(
              'AdultMale' => Predicate.create(name: 'AdultMale', definition: 'The collection object is comprised of adult male(s).'),
              'AdultFemale' => Predicate.create(name: 'AdultFemale', definition: 'The collection object is comprised of adult female(s).'),
              'Immature' => Predicate.create(name: 'Immature', definition: 'The collection object is comprised of immature(s).'),
              'Pupa' => Predicate.create(name: 'Pupa', definition: 'The collection object is comprised of pupa.'),
              'Exuvium' => Predicate.create(name: 'Exuvia', definition: 'The collection object is comprised of exuvia.'),
              'AdultUnsexed' => Predicate.create(name: 'AdultUnsexed', definition: 'The collection object is comprised of adults, with sex undetermined.'),
              'AgeUnknown' => Predicate.create(name: 'AgeUnknown', definition: 'The collection object is comprised of individuals of indtermined age.'),
              'OtherSpecimens' => Predicate.create(name: 'OtherSpecimens', definition: 'The collection object that is asserted to be unclassified in any manner.'),

              'ZeroTotal' => Keyword.create(name: 'ZeroTotal', definition: 'On import there were 0 total specimens recorded in INHS FileMaker database.'),
              'Prefix' => Predicate.create(name: 'Prefix', definition: 'CatalogNumberPrefix imported from INHS FileMaker database.'),
              'CatalogNumber' => Predicate.create(name: 'CatalogNumber', definition: 'CatalogNumber imported from INHS FileMaker database.'),
              'IdentifiedBy' => Predicate.create(name: 'IdentifiedBy', definition: 'IdentifiedBy field imported from INHS FileMaker database.'),
              'YearIdentified' => Predicate.create(name: 'YearIdentified', definition: 'YearIdentified field imported from INHS FileMaker database.'),
              'OldIdentifiedBy' => Predicate.create(name: 'OriginalIdentifiedBy', definition: 'OldIdentifiedBy field imported from INHS FileMaker database.'),
              'Type' => Predicate.create(name: 'Type', definition: 'Type field imported from INHS FileMaker database.'),
              'TypeName' => Predicate.create(name: 'TypeName', definition: 'TypeName field imported from INHS FileMaker database.'),
              'AccessionNumberLabel' => Predicate.create(name: 'AccessionNumberLabel', definition: 'AccessionNumberLabel field imported from INHS FileMaker database.'),
              'SpecialCollection' => Predicate.create(name: 'SpecialCollection', definition: 'SpecialCollection field imported from INHS FileMaker database.'),
              'OldCollector' => Predicate.create(name: 'OldCollector', definition: 'OldCollector field imported from INHS FileMaker database.'),
               )

          # from neon
          data.keywords.merge!(
              'IdentifierEmail' => Predicate.create(name: 'IdentifierEmail', definition: 'IdentifierEmail field imported from NEON database.'),
              'IdentifierInstitution' => Predicate.create(name: 'IdentifierInstitution', definition: 'IdentifierInstitution field imported from NEON database.'),
              'IdentificationMethod' => Predicate.create(name: 'IdentificationMethod', definition: 'IdentificationMethod field imported from NEON database.'),
              'VoucherStatus' => Predicate.create(name: 'VoucherStatus', definition: 'VoucherStatus field imported from NEON database.'),
              'TissueDescriptor' => Predicate.create(name: 'TissueDescriptor', definition: 'TissueDescriptor field imported from NEON database.'),
              'ExternalURLs' => Predicate.create(name: 'ExternalURLs', definition: 'ExternalURLs field imported from NEON database.'),
              'GPSSource' => Predicate.create(name: 'GPSSource', definition: 'GPSSource field imported from NEON database.'),
              'CollectionDateAccuracy' => Predicate.create(name: 'CollectionDateAccuracy', definition: 'CollectionDateAccuracy field imported from NEON database.'),
              'SamplingProtocol' => Predicate.create(name: 'SamplingProtocol', definition: 'SamplingProtocol field imported from NEON database.'),
              'SiteCode' => Predicate.create(name: 'SiteCode', definition: 'SiteCode field imported from NEON database.')
          )

          biological_properties = { 'Attendant' => 'An insect attending another insect',
                                    'Attended insect' => 'An insect attended by another insect',
                                    'Body' => 'Body of an insect when a part was dissected',
                                    'Body part' => 'Dissected part of a body (often mounted on a slide)',
                                    'Genitalia' => 'Dissected genitalia (often mounted on a slide)',
                                    'Host' => 'An animal or plant on or in which a parasite or commensal organism lives',
                                    'Herbivor' => 'An animal that feeds on plants',
                                    'Mate' => 'breeding partner.........',
                                    'Parasitoid' => 'An organism that lives in or on another organism',
                                    'Pollinator' => 'An insect pollinating a plant',
                                    'Pollinated plant' => 'A plant visited by insects',
                                    'Predator' => 'An animal that preys on others',
                                    'Prey' => 'An animal that is hunted and killed by another for food',
                                    'Exuvia or pupa' => 'Remains of an exoskeleton that are left after moulting'
          }

          biological_properties.each do |bp|
            data.biological_properties[bp[0]] = BiologicalProperty.create(name: bp[0], definition: bp[1])
          end

          import.metadata['controlled_vocabulary'] = true
          checkpoint_save_insects(import) if ENV['no_transaction']
        end
      end

      def find_or_create_collection_user_insects(id, data)
#      DataAttribute.where(attribute_subject_type: "User", import_predicate: "PeopleID", project_id: $project_id).first.attribute_subject
        if id.blank?
          $user_id
         elsif data.user_index[id]
           data.user_index[id].id
         elsif data.people_id[id]
           p = data.people_id[id]
           email = p['Email'].nil? ? nil : p['Email'].downcase
           email = 'user_' + id + '@unavailable.email.net' if email.blank?

           user_name = ([p['LastName']] + [p['FirstName']]).compact.join(', ')

           existing_user = User.where(email: email.downcase)

           if existing_user.empty?
             pwd = rand(36**10).to_s(36)
             user = User.create(email: email, password: pwd, password_confirmation: pwd, name: user_name, is_flagged_for_password_reset: true,
                    #data_attributes_attributes: [ {value: p['PeopleID'], import_predicate: 'PeopleID', type: 'ImportAttribute'} ],
                    tags_attributes:   [ { keyword: data.keywords['INHS_imported'] } ]
             )
             user.identifiers.create(identifier: p['PeopleID'], namespace: @user_namespace, type: 'Identifier::Local::Import')

           else
             user = existing_user.first
           end

           unless p['SupervisorID'].blank?
             s = data.people_id[p['SupervisorID']]
             user.notes.create(text: 'Student of ' + s['FirstName'] + ' ' + s['LastName']) unless s.blank?
           end
           data.user_index[id] = user
           user.id
         else
           $user_id
         end
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

      def find_or_create_collecting_event_insects(ce, data)
        tmp_ce = { }
        LOCALITY_COLUMNS.each do |c|
          tmp_ce[c] = ce[c] unless ce[c].blank?
        end
        tmp_ce_sorted = tmp_ce.sort.to_s
        c_from_redis = @redis.get(Digest::MD5.hexdigest(tmp_ce_sorted))
        unless ce['AccessionNumber'].blank?
          cached_identifier = nil
          if !ce['Collection'].blank?
            cached_identifier =  'Accession Code ' + ce['Collection'] + ' ' + ce['AccessionNumber']
          else
            cached_identifier = 'Accession Code ' + ce['AccessionNumber']
          end
          c = Identifier.where(project_id: $project_id, identifier_object_type: 'CollectingEvent', cached: cached_identifier).first.try(:identifier_object)

          if !c.nil? && c_from_redis.nil?
            @redis.set(Digest::MD5.hexdigest(tmp_ce_sorted), c.id)
            return c
          end
        end

        if !ce['LocalityLabel'].blank? && ce['LocalityLabel'].to_s.length > 5
          md5 = Utilities::Strings.generate_md5(ce['LocalityLabel'])
         
          c = CollectingEvent.where(md5_of_verbatim_label: md5, project_id: $project_id).first
          
          if !c.nil? && c_from_redis.nil?
            @redis.set(Digest::MD5.hexdigest(tmp_ce_sorted), c.id)

            if !ce['AccessionNumber'].blank? && !ce['Collection'].blank?
              c.identifiers.create(identifier: ce['Collection'] + ' ' + ce['AccessionNumber'], namespace: @accession_namespace, type: 'Identifier::Local::AccessionCode')
            elsif !ce['AccessionNumber'].blank?
              c.identifiers.create(identifier: ce['AccessionNumber'], namespace: @accession_namespace, type: 'Identifier::Local::AccessionCode')
            end
            return c
          end
        end

        c_from_redis = @redis.get(Digest::MD5.hexdigest(tmp_ce_sorted))

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
            no_cached: true
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

          @redis.set(Digest::MD5.hexdigest(tmp_ce_sorted), c.id)
          return c
        rescue ActiveRecord::RecordInvalid 
          @invalid_collecting_event_index[tmp_ce] = nil
          return nil
        end

      end

      #- 0 PeopleID          Import Identifier
      #  1 SupervisorID      Loan#supervisor_person_id  ?
      #
      #- 2 LastName
      #- 3 FirstName
      #
      #  4 Honorific        Loan#recipient_honorific
      #  5 Address           Loan#recipient_address
      #  6 Country           Loan#recipient_country
      #  7 Email             Loan#recipient_email
      #  8 Phone             Loan#recipent_phone

      # - 9 Comments          Note.new
      #
      def handle_people_insects(data, import)
        path = @args[:data_directory] + 'TXT/people.txt'
        raise 'file not found' if not File.exists?(path)
        f = CSV.open(path, col_sep: "\t", headers: true)

        print 'Handling people '
        if import.metadata['people']
          print 'from database.  Indexing People by PeopleID...'
          f.each do |row|
            data.people_id[row['PeopleID']] = row
          end

          DataAttribute.where(import_predicate: 'PeopleID', attribute_subject_type: 'User').find_each do |u|
            data.user_index[u.value] = u.attribute_subject
          end

          DataAttribute.where(controlled_vocabulary_term_id: data.keywords['PeopleID'].id, attribute_subject_type: 'Person').find_each do |p|
            data.people_index[p.value] = p.attribute_subject
          end
          print "done.\n"
        else
          print "as newly parsed.\n"
          f.each do |row|
            puts "\tNo last name: #{row}" if row['LastName'].blank?
            ln = row['LastName']
            sf = nil
            if ln =~ /[a-z], Jr./
              sf = 'Jr.'
              ln = ln[0..-6]
            end

            p = Person::Vetted.create(
                last_name: ln || 'Not Provided',
                first_name: row['FirstName'],
                suffix: sf
            )

            p.notes.create(text: row['Comments']) if !row['Comments'].blank?
            data.keywords.each do |k|
              InternalAttribute.create(attribute_subject: p, predicate: k[1], value: row[k[0]]) unless row[k[0]].blank?
            end

            data.people_id[row['PeopleID']] = row
            data.people_index[row['PeopleID']] = p
          end
          import.metadata['people'] = true
          checkpoint_save_insects(import) if ENV['no_transaction']
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
      def handle_taxa_insects(data, import)
        print 'Handling taxa '
        if import.metadata['taxa']
          print 'from database.  Indexing OTUs by TaxonCode...'
#          Identifier.where(namespace_id: @taxon_namespace.id).each do |i|
#            data.otus.merge!(i.identifier => i.identifier_object)
#          end
          print "done.\n"
        else
          print "as newly parsed.\n"
          puts

          path = @args[:data_directory] + 'TXT/taxa_hierarchical.txt'
          raise 'file not found' if not File.exists?(path)

          parent_index = {}
          f = CSV.open(path, col_sep: "\t", headers: true)

          code = :iczn
          i = 0
          f.each do |row|             #f.first(500).each_with_index
            i += 1
            name = row['Name']
            author = (row['Parens'] == '1' ? "(#{row['Author']})" : row['Author']) unless row['Author'].blank?
            author ||= nil
            code = :icn if code == :iczn && row['Name'] == 'Fungi'
            rank = Ranks.lookup(code, row['Rank'])
            rank ||= 'NomenclaturalRank'
            name = 'Root' if rank == 'NomenclaturalRank'
            updated_by = find_or_create_collection_user_insects(row['ModifiedBy'], data)
            created_by = row['CreatedBy'].blank? ? updated_by : find_or_create_collection_user_insects(row['CreatedBy'], data)
            created_on = row['CreatedOn'].blank? ? row['ModifiedOn'] : row['CreatedOn']

            p = Protonym.new(
              name: name,
              verbatim_author: author,
              year_of_publication: row['Year'],
              rank_class: rank,
              created_by_id: created_by,
              updated_by_id: updated_by,
              created_at: time_from_field(created_on),
              updated_at: time_from_field(row['ModifiedOn'])
            )
            p.parent_id = parent_index[row['Parent'].to_s] unless row['Parent'].blank? || parent_index[row['Parent'].to_s].nil?
            if rank == 'NomenclaturalRank'
              p = Protonym.find_or_create_by(name: 'Root', rank_class: 'NomenclaturalRank', project_id: $project_id)
              parent_index[row['ID']] = p.id
            elsif !p.parent_id.blank?
              bench = Benchmark.measure {
                data.keywords.each do |k|
                  p.data_attributes.build(type: 'InternalAttribute', predicate: k[1], value: row[k[0]]) unless row[k[0]].blank?
                end
              }

              print "\r#{i}\t#{bench.to_s.strip}  #{name}  (Taxon code: #{row['TaxonCode']})                         " #  \t\t#{rank}


              begin
                p.save!
              
                # This line might be broken now? 
                build_otu_insects(row, p, data)
                
                parent_index[row['ID']] = p.id
                data.taxa_index[row['TaxonCode']] = p
                p.notes.create(text: row['Remarks']) unless row['Remarks'].blank?
              rescue ActiveRecord::RecordInvalid
                puts "\n#{p.name}"
                puts p.errors.messages
                puts
              end


            else
              puts "\n  No parent for #{p.name}.\n"
            end

          end

          parent_index = nil
          import.metadata['taxa'] = true
          checkpoint_save_insects(import) if ENV['no_transaction']
        end
      end

      def build_otu_insects(row, taxon_name, data)
        if row['TaxonCode'].blank?
          return true
        end
        if taxon_name.id.nil?
          o =  Otu.create(
              taxon_name_id: taxon_name.parent_id,name: taxon_name.parent.name + ' ' + taxon_name.name,
              identifiers_attributes: [  {identifier: row['TaxonCode'], namespace: @taxon_namespace, type: 'Identifier::Local::OtuUtility'} ]
          )
        else
          o =  Otu.create(
              taxon_name_id: taxon_name.id,
              identifiers_attributes: [  {identifier: row['TaxonCode'], namespace: @taxon_namespace, type: 'Identifier::Local::OtuUtility'} ]
          )
        end
        # data.otus.merge!(row['TaxonCode'] => o)
      end

      # Index localities by their collective column=>data pairs
      def build_localities_index_insects(data)
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

      def build_partially_resolved_index(data)

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

      def index_specimen_records_from_specimens_insects(data, import)
        start = @redis.keys.count
        collecting_event = nil
        puts ' specimen records from specimens.txt'
        path = @args[:data_directory] + 'TXT/specimens.txt'
        raise 'file not found' if not File.exists?(path)

        sp = CSV.open(path, col_sep: "\t", headers: true)

        specimen_fields = %w{ Prefix CatalogNumber PreparationType TaxonCode LocalityCode AccessionSource DeaccessionRecipient DeaccessionCause DeaccessionDate DateCollectedBeginning DateCollectedEnding Collector LocalityLabel AccessionNumberLabel DeterminationLabel OtherLabel SpecialCollection IdentifiedBy YearIdentified CollectionMethod Habitat Type TypeName Remarks AdultMale AdultFemale Immature Pupa Exuvium AdultUnsexed AgeUnknown OtherSpecimens Checked OldLocalityCode OldCollector OldIdentifiedBy CreatedBy CreatedOn ModifiedOn ModifiedBy }.freeze
        count_fields = %w{ AdultMale AdultFemale Immature Pupa Exuvium AdultUnsexed AgeUnknown OtherSpecimens }.freeze

        i = 0
        sp.each do |row|
          i += 1

          unless row['Prefix'] == 'Loan Invoice'
            locality_code = row['LocalityCode']
            se = { }

            if !data.localities_index[locality_code].nil?
              #Utilities::Hashes.puts_collisions(tmp_ce, LOCALITIES[locality_code])
              se.merge!(data.localities_index[locality_code])
            else
              data.unmatched_localities[locality_code] = nil unless locality_code.blank?
            end
            specimen_fields.each do |c|
              se[c] = row[c] unless row[c].blank?
            end

            bench = Benchmark.measure {
              collecting_event = find_or_create_collecting_event_insects(se, data)
            }

            print "\r#{i} \t#{bench.to_s.strip}                            "

            #byebug # preparation type is not saved to a collection object.
            preparation_type = data.preparation_types[se['PreparationType']]

            no_specimens = false
            if count_fields.collect{ |f| se[f] }.select{ |n| !n.nil? }.empty?
              se['OtherSpecimens'] = '1'
              no_specimens = true
            end

            objects = []
            count_fields.each do |count|
              unless se[count].blank?
                updated_by = find_or_create_collection_user_insects(se['ModifiedBy'], data)
                created_by = se['CreatedBy'].blank? ? updated_by : find_or_create_collection_user_insects(se['CreatedBy'], data)
                created_on = se['CreatedOn'].blank? ? se['ModifiedOn'] : se['CreatedOn']
                specimen = CollectionObject::BiologicalCollectionObject.new(
                    total: se[count],
                    preparation_type: preparation_type,
                    repository_id: @repository,
                    buffered_collecting_event: se['LocalityLabel'],
                    buffered_determinations: se['DeterminationLabel'],
                    buffered_other_labels: se['OtherLabel'],
                    collecting_event: collecting_event,
                    deaccessioned_at: time_from_field(se['DeaccessionDate']),
                    deaccession_reason: se['DeaccessionCause'],
                    created_by_id: created_by,
                    updated_by_id: updated_by,
                    created_at: time_from_field(created_on),
                    updated_at: time_from_field(se['ModifiedOn'])
                    )

                begin
                  specimen.save!
                  objects += [specimen]
                  specimen.notes.create(text: se['Remarks']) unless se['Remarks'].blank?

                  data.keywords.each do |k|
                    specimen.data_attributes.create(type: 'InternalAttribute', controlled_vocabulary_term_id: k[1].id, value: se[k[0]]) unless se[k[0]].blank?
                  end

                  specimen.tags.create(keyword: data.keywords['ZeroTotal']) if no_specimens
                  add_bioculation_class_insects(specimen, count, data)

                  Role.create(person: data.people_index[se['AccessionSource']], role_object: specimen, type: 'AccessionProvider') unless se['AccessionSource'].blank?
                  Role.create(person: data.people_index[se['DeaccessionRecipient']], role_object: specimen, type: 'DeaccessionRecipient') unless se['DeaccessionRecipient'].blank?
                rescue ActiveRecord::RecordInvalid 
                  data.invalid_specimens[se['Prefix'] + ' ' + se['CatalogueNumber']] = nil
                end

                byebug if specimen.try(:id).blank?
              end
            end
            add_identifiers_insects(objects, row, data)
            add_determinations_insects(objects, row, data)
          end
        end

        puts "\n Number of collecting events processed from specimens: #{@redis.keys.count - start} "
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

      def index_specimen_records_from_specimens_insects_new(data, import)
        build_partially_resolved_index(data)
        index_host_plants_insects(data)

        start = @redis.keys.count
        puts "\r specimen records from specimens_new.txt"
        path = @args[:data_directory] + 'TXT/specimens_new.txt'
        raise 'file not found' if not File.exists?(path)

        sp = CSV.open(path, col_sep: "\t", headers: true)

        specimen_fields = %w{ Prefix CatalogNumber PreparationType TaxonCode LocalityCode DateCollectedBeginning DateCollectedEnding Collector LocalityLabel AccessionNumberLabel DeterminationLabel OtherLabel SpecialCollection IdentifiedBy YearIdentified CollectionMethod Habitat Type TypeName Remarks AdultMale AdultFemale Immature Pupa Exuvium AdultUnsexed AgeUnknown OtherSpecimens Checked OldLocalityCode OldCollector OldIdentifiedBy CreatedBy CreatedOn ModifiedOn ModifiedBy }.freeze
        count_fields = %w{ AdultMale AdultFemale Immature Pupa Exuvium AdultUnsexed AgeUnknown OtherSpecimens }.freeze


        locality_fields_with_locality_code = %w{ Collector CollectionMethod Habitat IdentifiedBy YearIdentified Type TypeName DateCollectedBeginning DateCollectedEnding Host Remarks ModifiedBy ModifiedOn }.freeze
        locality_fields_without_locality_code = %w{ Collector CollectionMethod Habitat IdentifiedBy YearIdentified Type TypeName DateCollectedBeginning DateCollectedEnding Host NS Lat_deg Lat_min Lat_sec EW Long_deg Long_min Long_sec Elev_m Elev_ft Country State County Locality Park Remarks Precision DeterminationCompare ModifiedBy ModifiedOn }.freeze
        match_fields = %w{ AccessionNumber DeterminationLabel OtherLabel LocalityLabel }.freeze
        br = data.biological_relationships['host']['biological_relationship']

        i = 0
        sp.each do |row|
          i += 1
          print "\r#{i}      "

#          next if (row['Prefix'] != 'Araneae' || row['CatalogNumber'].to_s != '12610')
#          byebug

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
                extra_fields[m] = row[m] unless row[m].blank?
              end
            else
              locality_fields_with_locality_code.each do |m|
                extra_fields[m] = row[m] unless row[m].blank?
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
          collecting_event = find_or_create_collecting_event_insects(se, data) if row['Done'] == '1' || row['Prefix'] == 'Araneae'
          preparation_type = data.preparation_types[se['PreparationType']]

          no_specimens = false
          if count_fields.collect{ |f| se[f] }.select{ |n| !n.nil? }.empty?
            se['OtherSpecimens'] = '1'
            no_specimens = true
          end

          objects = []
          count_fields.each do |count|
            unless se[count].blank?
              updated_by = find_or_create_collection_user_insects(se['ModifiedBy'], data)
              created_by = se['CreatedBy'].blank? ? updated_by : find_or_create_collection_user_insects(se['CreatedBy'], data)
              created_on = se['CreatedOn'].blank? ? se['ModifiedOn'] : se['CreatedOn']
              specimen = CollectionObject::BiologicalCollectionObject.new(
                  total: se[count],
                  preparation_type: preparation_type,
                  repository_id: @repository,
                  buffered_collecting_event: se['LocalityLabel'],
                  buffered_determinations: se['DeterminationLabel'],
                  buffered_other_labels: se['OtherLabel'],
                  collecting_event: collecting_event,
                  created_by_id: created_by,
                  updated_by_id: updated_by,
                  created_at: time_from_field(created_on),
                  updated_at: time_from_field(se['ModifiedOn'])
              )

              begin
                specimen.save!
                objects += [specimen]
                specimen.notes.create(text: se['Remarks']) unless se['Remarks'].blank?

                host = data.host_plant_index[row['Host']]
                unless host.blank?
                  identifier = Identifier.where(namespace_id: @taxon_namespace.id, identifier: host, project_id: $project_id)
                  host = identifier.empty? ? nil : identifier.first.identifier_object
                end
                unless host.blank?
                  BiologicalAssociation.create(biological_relationship: br,
                                               biological_association_subject: host,
                                               biological_association_object: specimen
                                              )
                end

                data.keywords.each do |k|
                  specimen.data_attributes.create(type: 'InternalAttribute', controlled_vocabulary_term_id: k[1].id, value: se[k[0]]) unless se[k[0]].blank?
                end

                specimen.tags.create(keyword: data.keywords['ZeroTotal']) if no_specimens
                add_bioculation_class_insects(specimen, count, data)
              rescue ActiveRecord::RecordInvalid 
                data.invalid_specimens[se['Prefix'] + ' ' + se['CatalogueNumber']] = nil
              end

              byebug if specimen.try(:id).nil?

            end
          end
          add_identifiers_insects(objects, row, data)
          add_determinations_insects(objects, row, data)
        end

        puts "\n Number of collecting events processed from specimens_new: #{@redis.keys.count - start} "
      end

      def index_specimen_records_from_neon(data, import)
        start = @redis.keys.count
        puts ' specimen records from neon.txt'
        path = @args[:data_directory] + 'TXT/neon.txt'
        raise 'file not found' if not File.exists?(path)

        sp = CSV.open(path, col_sep: "\t", headers: true)

        specimen_fields = %w{ SampleID MuseumID TaxonCode IdentifiedBy IdentifierEmail IdentifierInstitution IdentificationMethod TaxonomyNotes ExtraInfo Remarks VoucherStatus TissueDescriptor AssociatedTaxa AssociatedSpecimens ExternalURLs Collector DateCollectedBeginning DateCollectedEnding CollectionMethod LocalityCode GPSSource CoordinateAccuracy EventTime CollectionDateAccuracy SamplingProtocol CollectionNotes SiteCode AdultMale AdultFemale AdultUnsexed }
        count_fields = %w{ AdultMale AdultFemale Immature Pupa Exuvium AdultUnsexed AgeUnknown OtherSpecimens }

        i = 0
        sp.each do |row|
          i += 1
          print "\r#{i}      "

          locality_code = row['LocalityCode']
          se = { }

          if !data.localities_index[locality_code].nil?
            se.merge!(data.localities_index[locality_code])
          else
            data.unmatched_localities[locality_code] = nil unless locality_code.blank?
          end
          specimen_fields.each do |c|
            se[c] = row[c] unless row[c].blank?
          end

          collecting_event = find_or_create_collecting_event_insects(se, data)
          preparation_type = data.preparation_types['Pin']

          no_specimens = false
          if count_fields.collect{ |f| se[f] }.select{ |n| !n.nil? }.empty?
            se['OtherSpecimens'] = '1'
            no_specimens = true
          end
          objects = []
          count_fields.each do |count|
            unless se[count].blank?
              specimen = CollectionObject::BiologicalCollectionObject.new(
                  total: se[count],
                  preparation_type: preparation_type,
                  repository_id: @repository,
                  buffered_collecting_event: nil,
                  buffered_determinations: nil,
                  buffered_other_labels: nil,
                  collecting_event: collecting_event
              )

              begin
                specimen.save!
                objects += [specimen]
                specimen.notes.create(text: se['Remarks']) unless se['Remarks'].blank?

                data.keywords.each do |k|
                  specimen.data_attributes.create(type: 'InternalAttribute', controlled_vocabulary_term_id: k[1].id, value: se[k[0]]) unless se[k[0]].blank?
                end

                specimen.tags.create(keyword: data.keywords['ZeroTotal']) if no_specimens
                add_bioculation_class_insects(specimen, count, data)
              rescue ActiveRecord::RecordInvalid 
                data.invalid_specimens[se['Prefix'] + ' ' + se['CatalogueNumber']] = nil
              end
            end
          end
          add_identifiers_insects(objects, row, data)
          add_determinations_insects(objects, row, data)
        end

        puts "\n Number of collecting events processed from NEON: #{@redis.keys.count - start} "
      end

      def add_identifiers_insects(objects, row, data)
        puts "no catalog number for #{row['ID']}" if row['CatalogNumber'].blank? && row['SampleID'].blank?

        identifier = Identifier::Local::CatalogNumber.new(namespace: data.namespaces[row['Prefix']], identifier: row['CatalogNumber']) unless row['CatalogNumber'].blank?
        identifier = Identifier::Local::CatalogNumber.new(namespace: data.namespaces['NEON'], identifier: row['SampleID']) unless row['SampleID'].blank?

        if objects.count > 1 # Identifier on container.f

          c = Container.containerize(objects, CONTAINER_TYPE[row['PreparationType'].to_s].constantize )
          c.save
          c.identifiers << identifier if identifier
          c.save

        elsif objects.count == 1 # Identifer on object
          objects.first.identifiers << identifier if identifier
          objects.first.save
        else
          raise 'No objects in container.'
        end

        data.duplicate_specimen_ids[row['Prefix'].to_s + ' ' + row['CatalogNumber'].to_s] = nil if identifier.try(:id).nil?
      end

      def add_bioculation_class_insects(o, bcc, data)
        BiocurationClassification.create(biocuration_class: data.biocuration_classes['Adult'], biological_collection_object: o) if bcc == 'AdultMale' || bcc =='AdultFemale' || bcc == 'AdultUnsexed'
          BiocurationClassification.create(biocuration_class: data.biocuration_classes['Male'], biological_collection_object: o) if bcc == 'AdultMale'
          BiocurationClassification.create(biocuration_class: data.biocuration_classes['Female'], biological_collection_object: o) if bcc == 'AdultFemale'
          BiocurationClassification.create(biocuration_class: data.biocuration_classes['Immature'], biological_collection_object: o) if bcc == 'Immature'
          BiocurationClassification.create(biocuration_class: data.biocuration_classes['Exuvium'], biological_collection_object: o) if bcc == 'Exuvium'
          BiocurationClassification.create(biocuration_class: data.biocuration_classes['Pupa'], biological_collection_object: o) if bcc == 'Pupa'
      end


      def add_determinations_insects(objects, row, data)
        #identifier = Identifier.where(namespace_id: @taxon_namespace.id, identifier: row['TaxonCode'], project_id: $project_id)
        #otu = identifier.empty? ? nil : identifier.first.identifier_object

        otu = Identifier.where(project_id: $project_id, cached: 'Taxon Code ' + row['TaxonCode'].to_s, identifier_object_type: 'Otu').first.try(:identifier_object)
 #       otu = otu.empty? ? nil : otu.first

#        otu = data.otus[row['TaxonCode']]
        objects.each do |o|
          unless otu.nil?
            year = row['YearIdentified'].blank? ? year_from_field(row['CreatedOn']) : row['YearIdentified']
            td = TaxonDetermination.create(
                biological_collection_object: o,
                otu: otu,
                year_made: year
            )

            if !row['Type'].blank?
              type = TYPE_TYPE[row['Type'].downcase]
              unless type.nil?
                type = type + 's' if o.type == 'Lot'
                tm = TypeMaterial.create(protonym_id: otu.taxon_name_id, collection_object: o, type_type: type )
                if !tm.id.blank? # tm.valid?
                  tm.data_attributes.create(type: 'InternalAttribute', controlled_vocabulary_term_id: data.keywords['TypeName'], value: row['TypeName']) unless row['TypeName'].blank?
                else
                  o.data_attributes.create(type: 'ImportAttribute', import_predicate: 'type_material_error', value: 'Type material was not created. There are some inconsistensies.')
                end
              end
            end
          else
            data.unmatched_taxa[row['TaxonCode']] = nil unless row['TaxonCode'].blank?
          end
        end
      end

      def index_collecting_events_from_accessions_new(data, import)
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

          find_or_create_collecting_event_insects(tmp_ce, data)
        end
        puts "\n Number of collecting events processed from Accessions_new: #{@redis.keys.count} "
      end

      def index_collecting_events_from_ledgers(data, import)
        starting_number = @redis.keys.empty? ? 0 : @redis.keys.count

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
            find_or_create_collecting_event_insects(tmp_ce, data)
          }
          print "\r#{i}\t#{bench.to_s.strip}"
        end
        puts "\n Number of collecting events processed from Ledgers: #{@redis.keys.count - starting_number} "
      end

      def handle_associations_insects(data, import)
        path = @args[:data_directory] + 'TXT/associations.txt'
        raise 'file not found' if not File.exists?(path)
        as = CSV.open(path, col_sep: "\t", headers: true)
        #fields = %w{ Prefix CatalogNumber AssociatedPrefix AssociatedCatalogNumber AssociatedTaxonCode Type }
        puts "\n  Handle associations \n"

        i = 0
        as.each do |row|
          i += 1
          print "\r#{i}"
          br = data.biological_relationships[row['Type'].to_s.downcase]
          if row['Type'].blank?
          elsif br.nil?
            print "\n#{row['Type']} relationship does not exist!\n"
          elsif br != :ignore
            direction = br['direction']
            specimen = nil
            related_specimen = nil
            otu = nil
            object = nil
            subject = nil

            if !row['Prefix'].blank? && !row['CatalogNumber'].blank?
              identifier = Identifier.where(cached: 'INHS ' + row['Prefix'] + ' ' + row['CatalogNumber'], type: 'Identifier::Local::CatalogNumber', project_id: $project_id)
              specimen = identifier.empty? ? nil : identifier.first.identifier_object
            end
            if !row['AssociatedPrefix'].blank? && !row['AssociatedCatalogNumber'].blank?
              identifier = Identifier.where(cached: 'INHS ' + row['AssociatedPrefix'] + ' ' + row['AssociatedCatalogNumber'], type: 'Identifier::Local::CatalogNumber', project_id: $project_id)
              related_specimen = identifier.empty? ? nil : identifier.first.identifier_object
            end
            if !row['AssociatedTaxonCode'].blank? && related_specimen.nil?
              identifier = Identifier.where(namespace_id: @taxon_namespace.id, identifier: row['AssociatedTaxonCode'], project_id: $project_id)
              otu = identifier.empty? ? nil : identifier.first.identifier_object
            end

            if br == :origin
              OriginRelationship.create(new_object: related_specimen, old_object: specimen)
              related_specimen.tags.create(keyword: data.keywords[row['Type']])
            else
              if direction == :direct
                subject = specimen
                object = related_specimen.nil? ? otu : related_specimen
              elsif direction == :reverse
                subject = related_specimen.nil? ? otu : related_specimen
                object = specimen
              end

              if object && subject
                BiologicalAssociation.create(biological_relationship: br['biological_relationship'],
                                             biological_association_subject: subject,
                                             biological_association_object: object
                )
              end
            end
          end
        end

        puts "\nResolved \n #{BiologicalAssociation.all.count} biological associations\n"
      end

      def handle_loans_insects(data, import)
        path = @args[:data_directory] + 'TXT/loans.txt'
        raise 'file not found' if not File.exists?(path)
        lo = CSV.open(path, col_sep: "\t", headers: true)
        #fields = %w{ InvoiceID ExpectedDateOfReturn DateReceived DateProcessed DateRequested MethodOfRequest Processor RecipientID Signature StudentSignature Comments TotalRecordsOnLoan TotalRecordsReturned TotalRecordsRemaining TotalSpecimensOnLoan TotalSpeciemsnReturned TotalSpeciemsnRemaining Canceled CreatedBy }
        print "\nHandling Loans "
        if import.metadata['loans']
          print 'from database.  Indexing Loans by InvoiceID...'
          Identifier.where(namespace_id: data.namespaces['Invoice']).find_each do |l|
            data.loans[l.identifier] = l.identifier_object
          end
          print "done.\n"
        else
          print "as newly parsed.\n"
          i = 0
          lender_address = 'INHS Insect Collection, Illinois Natural History Survey, 1816 S. Oak st., Champaign, IL 61820'
          lo.each do |row|
            i += 1
            print "\r#{i}"
            next if row['RecipientID'].blank?
            date_closed = (row['Canceled'] == 'Canceled') ? Time.current : nil
            row['Signature'] = nil if row['Signature'].to_s.length == 1
            row['StudentSignature'] = nil if row['StudentSignature'].to_s.length == 1
            #country = parse_geographic_area_insects({'Country' => data.people_id[row['RecipientID']]['Country']})
            #country = country.nil? ? nil : country.id
            country = data.people_id[row['RecipientID']]['Country']
            supervisor = data.people_index[data.people_id[row['RecipientID']]['SupervisorID']]
            supervisor_email = supervisor.nil? ?  nil : data.people_id[data.people_id[row['RecipientID']]['SupervisorID']]['Email']
            supervisor_phone = supervisor.nil? ?  nil : data.people_id[data.people_id[row['RecipientID']]['SupervisorID']]['Phone']
            recipient_email = data.people_id[row['RecipientID']]['Email']
            recipient_email = 'not_provided@email.com' if recipient_email.nil? || recipient_email.to_s.include?(' ') || recipient_email.to_s.include?("\r") || recipient_email.to_s.include?(',') || recipient_email.to_s.include?('’')

            row['DateReceived'] = '' if !time_from_field(row['DateReceived']).nil? && !time_from_field(row['DateProcessed']).nil? && time_from_field(row['DateReceived']) < time_from_field(row['DateProcessed'])
            row['ExpectedDateOfReturn'] = '' if !time_from_field(row['ExpectedDateOfReturn']).nil? && !time_from_field(row['DateProcessed']).nil? && time_from_field(row['ExpectedDateOfReturn']) < time_from_field(row['DateProcessed'])

            l = Loan.create( date_requested: time_from_field(row['DateRequested']),
                             request_method: row['MethodOfRequest'],
                             date_sent: time_from_field(row['DateProcessed']),
                             date_received: time_from_field(row['DateReceived']),
                             date_return_expected: time_from_field(row['ExpectedDateOfReturn']),
                             #recipient_person: data.people_index[row['RecipientID']],
                             recipient_address: data.people_id[row['RecipientID']]['Address'] || 'U.S.A.',
                             recipient_email: recipient_email,
                             recipient_phone: data.people_id[row['RecipientID']]['Phone'],
                             recipient_honorific: data.people_id[row['RecipientID']]['Honorific'],
                             recipient_country: country,
                             #supervisor_person: supervisor,
                             supervisor_email: supervisor_email,
                             supervisor_phone: supervisor_phone,
                             lender_address: lender_address,
                             date_closed: date_closed,
                             created_by_id: find_or_create_collection_user_insects(row['CreatedBy'], data),
                             created_at: time_from_field(row['CreatedOn'])
            )
            byebug if l.id.blank? #  l.valid?
            data.loans[row['InvoiceID']] = l
            l.notes.create(text: row['Comments']) unless row['Comments'].blank?
            l.data_attributes.create(import_predicate: 'Signature', value: row['Signature'].to_s, type: 'ImportAttribute') unless row['Signature'].blank?
            l.data_attributes.create(import_predicate: 'StudentSignature', value: row['StudentSignature'].to_s, type: 'ImportAttribute') unless row['StudentSignature'].blank?
            l.data_attributes.create(import_predicate: 'Processor', value: row['Processor'].to_s, type: 'ImportAttribute') unless row['Processor'].blank?
            l.data_attributes.create(import_predicate: 'RecipientID', value: row['RecipientID'].to_s, type: 'ImportAttribute') unless row['RecipientID'].blank?
            l.identifiers.create(namespace: data.namespaces['Invoice'], identifier: row['InvoiceID'], type: 'Identifier::Local::LoanCode') unless row['InvoiceID'].blank?
            Role.create(person: data.people_index[row['RecipientID']], role_object: l, type: 'LoanRecipient') unless row['RecipientID'].blank?
            Role.create(person: data.people_index[row['SupervisorID']], role_object: l, type: 'LoanSupervisor') unless row['SupervisorID'].blank?
          end
          puts "\nResolved \n #{Loan.all.count} loans\n"
          import.metadata['loans'] = true
          checkpoint_save_insects(import) if ENV['no_transaction']
        end
      end

      def handle_loans_insects_without_specimens(data)
        start = @redis.keys.count
        collecting_event = nil
        puts 'Loan specimen records from specimens.txt'
        path = @args[:data_directory] + 'TXT/specimens.txt'
        raise 'file not found' if not File.exists?(path)

        sp = CSV.open(path, col_sep: "\t", headers: true)

        specimen_fields = %w{ Prefix CatalogNumber TaxonCode AdultMale AdultFemale Immature Pupa Exuvium AdultUnsexed AgeUnknown OtherSpecimens }
        count_fields = %w{ AdultMale AdultFemale Immature Pupa Exuvium AdultUnsexed AgeUnknown OtherSpecimens }

        i = 0
        sp.each do |row|
          i += 1
          if row['Prefix'].downcase == 'loan invoice'
            count = 0
            a = {}
            count_fields.each do |j|
              count += row[j].to_i unless row[j].nil?
            end
            count = nil if count == 0
            a.merge!('TaxonCode' => row['TaxonCode'], 'Total' => count)
            data.loan_invoice_speciments[row['CatalogNumber']] = a
          end
        end
      end

      def handle_loan_specimens_insects(data)

        handle_loans_insects_without_specimens(data)

        path = @args[:data_directory] + 'TXT/loan_specimen.txt'
        raise 'file not found' if not File.exists?(path)
        ls = CSV.open(path, col_sep: "\t", headers: true)
        #fields = %w{ Prefix CatalogNumber InvoiceID Status DateReturned }
        print "Handling loan_specimens\n"

        status = { '2/14/2005' => 'Returned',
                   '3/22/2004' => 'Returned',
                   'destroyed' => 'Destroyed',
                   'donated' => 'Donated',
                   'loaned on' => 'Loaned on',
                   'Lost' => 'Lost',
                   'retained' => 'Retained',
                   'returned' => 'Returned' }

        i = 0
        ls.each do |row|
          i += 1
          print "\r#{i}"
          specimen = nil
          


          # New October 16
          # invoice = data.loans[row['InvoiceID']]
          invoice = Identifier.where(
            project_id: $project_id, 
            cached: 'INHS Invoice ' + row['InvoiceID'].to_s,
            identifier_object_type: 'Loan' 
          ).first.try(:identifier_object)

          # end new October 16

          unless row['Prefix'].blank? || row['CatalogNumber'].blank? || invoice.nil?

            if row['Prefix'].downcase == 'loan invoice' && !data.loan_invoice_speciments[row['CatalogNumber']].nil?

              #identifier = Identifier.where(namespace_id: @taxon_namespace.id, identifier: data.loan_invoice_speciments[row['CatalogNumber']]['TaxonCode'], project_id: $project_id)
              # specimen = identifier.empty? ? nil : identifier.first.identifier_object
              # otu = Otu.with_project_id($project_id).with_identifier('Taxon Code ' + data.loan_invoice_speciments[row['CatalogNumber']]['TaxonCode'].to_s)

              otu = Identifier.where(
                project_id: $project_id, 
                cached: 'Taxon Code ' + data.loan_invoice_speciments[row['CatalogNumber']]['TaxonCode'].to_s,
                identifier_object_type: 'Otu' 
              ).first.try(:identifier_object)

              loan_item_object = otu # .empty? ? nil : otu.first
              total = data.loan_invoice_speciments[row['CatalogNumber']]['Total']
            else
              loan_item_object = Identifier.where(
                cached: 'INHS ' + row['Prefix'] + ' ' + row['CatalogNumber'],
                type: 'Identifier::Local::CatalogNumber',
                project_id: $project_id,
                identifier_object_type: 'CollectionObject'
              ).first.try(:identifier_object)

              # loan_item_object = identifier.empty? ? nil : identifier.first.identifier_object
              total = nil
            end

            l = LoanItem.create( loan: invoice,
                                loan_item_object: loan_item_object,
                                total: total,
                                date_returned: time_from_field(row['DateReturned']),
                                disposition: status[row['Status'].to_s.downcase]
                               )
          end
        end

        Loan.where(project_id: $project_id).joins(:loan_items).select{|o| !o.date_closed.nil? }.each do |l|
          date = l.loan_items.select{|o| !o.date_returned.nil? }.collect{|i| i.date_returned}
          unless date.empty?
            l.date_closed = date.sort.last
            l.save
          end
        end

      end

      def handle_letters_insects(data)
        path = @args[:data_directory] + 'TXT/letters.txt'
        raise 'file not found' if not File.exists?(path)
        ls = CSV.open(path, col_sep: "\t", headers: true)
        #fields = %w{ InvoiceID RecipientID Salutation Body Creator CreatedOn }
        print "\nHandling letters\n"

        ls.each_with_index do |row, i|
          print "\r#{i}"
          # invoice = data.loans[row['InvoiceID']]
          
          invoice = Identifier.where(
            project_id: $project_id, 
            cached: 'INHS Invoice ' + row['InvoiceID'].to_s,
            identifier_object_type: 'Loan' 
          ).first.try(:identifier_object)


          unless row['Body'].to_s.squish.blank? || invoice.nil?
            note = row['Body'].to_s.squish
            note = row['Salutation'].to_s + "\n" + note unless row['Salutation'].to_s.squish.blank?
            invoice.notes.create(text: note,
                                 created_by_id: find_or_create_collection_user_insects(row['Creator'], data),
                                 created_at: time_from_field(row['CreatedOn']),
                                 tags_attributes:   [ { keyword: data.keywords['INHS_letters'] } ]
                                )
          end
        end
      end

      def handle_collection_profile_insects(data)
        path = @args[:data_directory] + 'TXT/collection_profile.txt'
        raise 'file not found' if not File.exists?(path)
        ls = CSV.open(path, col_sep: "\t", headers: true)
        #fields = %w{ ID Room Label1_1 Label1_2 Label1_3 Label1_4 Label2_1 Label2_2 Label2_3 Label2_4 TaxonCode Remarks CollectionType ConservationStatus ProcessingState ContainerCondition ConditionOfLabels IdentificationLevel ArangementLevel DataQuality ComputerizationLevel NumberOfSpecimens NumberOfVialsSlides Print1 Print2 CreatedBy CreatedOn ModifiedBy ModifiedOn }
        print "\nHandling collection profile\n"

        container_type = {'wet' => 'Container::VialRack', 'dry' => 'Container::Drawer', 'slide' => 'Container::SlideBox'}

        i = 0
        ls.each do |row|
          i += 1
          print "\r#{i}"
          otu = Identifier.where(project_id: $project_id, cached: 'Taxon Code ' + row['TaxonCode'].to_s, identifier_object_type: 'Otu').first.try(:identifier_object)
          otu_id = nil
          otu_id = otu.id if otu?
          
          room = find_or_create_room_insects(row, data)

          ['Label1_1', 'Label1_2', 'Label1_3', 'Label1_4', 'Label2_1', 'Label2_2', 'Label2_3', 'Label2_4'].each do |l|
            row[l] = nil if row[l].blank?
          end
          label1 = [row['Label1_1'], row['Label1_2'], row['Label1_3'], row['Label1_4']].compact
          label2 = [row['Label2_1'], row['Label2_2'], row['Label2_3'], row['Label2_4']].compact
          case row['CollectionType']
            when 'dry'
              label1 = label1.join("\n")
              label2 = label2.join("\n")
            when 'wet'
              label1 = (label1 + label2).compact.join("\n")
              label2 = nil
            when 'slide'
              label1 = [label1.join(' '), label2.join(' ')].compact.join("\n")
              label2 = nil
          end

          labels = [label1, label2].compact.join("\n----\n")


          container = Container.create!(created_by_id: find_or_create_collection_user_insects(row['CreatedBy'], data),
                                       created_at: time_from_field(row['CreatedOn']),
                                       updated_by_id: find_or_create_collection_user_insects(row['ModifiedBy'], data),
                                       updated_at: time_from_field(row['ModifiedOn']),
                                       #parent_id: room,
                                       type: container_type[row['CollectionType']],
                                       name: nil,
                                       contained_in: room,
                                       print_label: labels
          )
          container.identifiers.create!(namespace: data.namespaces['container'], identifier: row['ID'], type: 'Identifier::Local::ContainerCode') unless row['ID'].blank?


#          unless label1.blank?
#            cl1 = ContainerLabel.create!(label: label1,
#                                        date_printed: time_from_field(row['ModifiedOn']),
#                                        position: 1,
#                                        created_by_id: find_or_create_collection_user_insects(row['CreatedBy'], data),
#                                        created_at: time_from_field(row['CreatedOn']),
#                                        updated_by_id: find_or_create_collection_user_insects(row['ModifiedBy'], data),
#                                        updated_at: time_from_field(row['ModifiedOn']),
#                                        container: container
#              )
#          end
#          unless label2.blank?
#            cl2 = ContainerLabel.create!(label: label2,
#                                        date_printed: time_from_field(row['ModifiedOn']),
#                                        position: 2,
#                                        created_by_id: find_or_create_collection_user_insects(row['CreatedBy'], data),
#                                        created_at: time_from_field(row['CreatedOn']),
#                                        updated_by_id: find_or_create_collection_user_insects(row['ModifiedBy'], data),
#                                        updated_at: time_from_field(row['ModifiedOn']),
#                                        container: container
#              )
#          end

          cp = CollectionProfile.create!(container: container,
                                   otu_id: otu_id,
                                   conservation_status: row['ConservationStatus'],
                                   processing_state: row['ProcessingState'],
                                   container_condition: row['ContainerCondition'],
                                   condition_of_labels: row['ConditionOfLabels'],
                                   identification_level: row['IdentificationLevel'],
                                   arrangement_level: row['ArangementLevel'],
                                   data_quality: row['DataQuality'],
                                   computerization_level: row['ComputerizationLevel'],
                                   number_of_collection_objects: row['NumberOfSpecimens'],
                                   number_of_containers: row['NumberOfVialsSlides'],
                                   created_by_id: find_or_create_collection_user_insects(row['CreatedBy'], data),
                                   created_at: time_from_field(row['CreatedOn']),
                                   updated_by_id: find_or_create_collection_user_insects(row['CreatedOn'], data),
                                   updated_at: time_from_field(row['CreatedOn']),
                                   collection_type: row['CollectionType']
                                )
          cp.notes.create!(text: row['Remarks']) unless row['Remarks'].blank?

        end
      end

      def find_or_create_room_insects(row, data)
        return @collection_container if row['Room'].nil?
        r = data.rooms[row['Room']]
        if r.nil?
          r = Container::Room.with_project_id($project_id).where(name: row['Room'])
          if r.empty?
            r = Container::Room.create!(name: row['Room'], contained_in: @collection_container )
            #ContainerItem.create!(container_id: @collection_container, contained_object: r)
          else
            r = r.first
          end
        end
        data.rooms[row['Room']] = r
        r
      end

      def handle_locality_images(data1)
        path = @args[:data_directory] + 'INHS_Ross_index_cards/**/*'
        print "\nLocality images\n"

        Dir.glob(path).each_with_index do |file, i|
          print "\r#{i}"
          name = file.match(/([^\/.]*).jpg$/)
          identifier = name.nil? ? nil : name[1]
          unless identifier.nil?
            if ce = Identifier.where(project_id: $project_id, cached: 'Accession Code ' + identifier, identifier_object_type: 'CollectingEvent').first.try(:identifier_object)
              ce.depictions << Depiction.create(image_attributes: { image_file: File.open(file) })
            else
              print "\nCollecting event with identifier #{identifier} does not exist\n"             
              #d1 = Depiction.create(image_attributes: { image_file: File.open(file) }, depiction_object: ce)
            end
          end
        end
      end

      def handle_loan_images(data1)
        path = @args[:data_directory] + 'loans/**/*'
        print "\nLoan images\n"

        Dir.glob(path).each_with_index do |file, i|
          print "\r#{i}"
          name = file.match(/\/(\d*)[_-].*\.pdf$/)
          identifier = name.nil? ? nil : name[1]
          unless identifier.nil?
            loan = Identifier.where(project_id: $project_id, cached: 'INHS Invoice ' + identifier, identifier_object_type: 'Loan').first.try(:identifier_object)
            if loan.nil?
              print "\nInvoice with identifier #{identifier} does not exist\n"
            else
              # !! fix this, not testest
              #d1 = Document.create(document_file: File.open(file), documentation_attributes: [{documentation_object: loan, type: 'Documentation::LoanDocumentation'} ])
              d1 = Document.create(document_file: File.open(file))
              d2 = Documentation.create(documentation_object: loan, document: d1)
            end
          end
        end
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





