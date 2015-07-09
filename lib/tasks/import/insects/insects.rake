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
        attr_accessor :people_index, :people_id, :keywords, :user_index, :collection_objects, :otus, :namespaces,
                      :preparation_types, :collecting_event_index, :user_index, :taxa_index, :localities_index,
                      :unmatched_localities, :invalid_speciemsn, :unmatched_taxa, :duplicate_specimen_ids,
                      :invalid_type_names
        def initialize()
          @keywords = {}                  # keyword -> ControlledVocabularyTerm
          @namespaces = {}                # SpecimenIDPrefix -> NameSpace class
          @preparation_types = {}         # PreparationType -> PreparationType class
          @people_index = {}              # PeopleID -> Person object
          @people_id = {}                 # PeopleID -> People row
          @user_index = {}                # PeopleID -> User object
          @otus = {}                      # TaxonCode -> Otu object
          @taxa_index = {}                # TaxonCode -> Protonym object
          @collecting_event_index = {}
          @collection_objects = {}
          @localities_index = {}          #LocalityCode -> Locality row

          @unmatched_localities = {}
          @invalid_specimens = {}
          @unmatched_taxa = {}
          @duplicate_specimen_ids = {}
          @invalid_type_names = {}

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


      # TODO: Lots could be added here, it could also be yamlified
      GEO_NAME_TRANSLATOR = {
        'U.S.A.' => 'United States',
        'U. S. A.' => 'United States',
        'Quebec' => 'Québec',
        'U.S.A' => 'United States',
        'MEXICO' => 'Mexico',
        'U. S. A. ' => 'United States'
      }

      def geo_translate(name)
        GEO_NAME_TRANSLATOR[name] ? GEO_NAME_TRANSLATOR[name] : name
      end

      # Attributes to use from specimens.txt
      SPECIMENS_COLUMNS = %w{LocalityCode DateCollectedBeginning DateCollectedEnding Collector CollectionMethod Habitat}

      # Attributes to strip on CollectingEvent creation
      STRIP_LIST = %w{ModifiedBy ModifiedOn CreatedBy CreatedOn Latitude Longitude Elevation} # the last three are calculated

#      TAXA = {}
#      PEOPLE = {}

      desc "Import the INHS insect collection dataset.\n
      rake tw:project_import:insects:import_insects data_directory=/Users/matt/src/sf/import/inhs-insect-collection-data/  \n
      alternately, add: \n
        restore_from_dump=true   (attempt to load the data from the dump) \n
        no_transaction=true      (don't wrap import in a transaction, this will also force a dump of the data)\n"
      task :import_insects => [:environment, :data_directory] do |t, args|
        puts @args
        Utilities::Files.lines_per_file(Dir["#{@args[:data_directory]}/TXT/**/*.txt"])

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


      def main_build_loop
        @import = Import.find_or_create_by(name: IMPORT_NAME)  
        @import.metadata ||= {} 
        handle_projects_and_users(@data, @import)
        raise '$project_id or $user_id not set.'  if $project_id.nil? || $user_id.nil?
        handle_namespaces(@data, @import)
        handle_controlled_vocabulary(@data, @import)
        handle_preparation_types(@data, @import)
        handle_people(@data, @import)
        handle_taxa(@data, @import)

        # !! The following can not be loaded from the database they are always created anew.

        build_localities_index(@data)

        puts "Indexing collecting events."
        index_collecting_events_from_accessions_new(@data, @import)
        index_collecting_events_from_ledgers(@data, @import)
        index_specimen_records_from_specimens(@data, @import)

        #index_collecting_events_from_specimens_new(collecting_events_index, unmatched_localities)
        puts "\nTotal collecting events to build: #{@data.collecting_events_index.keys.length}."

        puts "\n!! Unmatched localities: (#{@data.unmatched_localities.keys.count}): " + @data.unmatched_localities.keys.sort.join(", ")
        puts "\n!! Unmatched taxa: (#{@data.unmatched_taxa.keys.count}): " + @data.unmatched_taxa.keys.sort.join(", ")
        puts "\n!! Invalid_specimens: (#{@data.invalid_specimens.keys.count}): " + @data.invalid_specimens.sort.join(", ")
        puts "\n!! Duplicate_specimen_IDs: (#{@data.duplicate_specimen_ids.keys.count}): " + @data.duplicate_specimen_ids.sort.join(", ")
        puts "\n!! Invalid_type_names: (#{@data.invalid_type_names.keys.count}): " + @data.invalid_type_names.sort.join(", ")

        # Debugging code, turn this on if you want to inspect all the columns that
        # are used to index a unique collecting event.
        # all_keys = []
        # collecting_events_index.keys.each_with_index do |hsh, i|
        #   all_keys.push hsh.keys
        #   all_keys.flatten!.uniq!
        # end
        # all_keys.sort!

        #handle_specimens(@data, @import)


        @import.save!
        puts "\n\n !! Success \n\n"
      end

      def handle_projects_and_users(data, import)
        print "Handling projects and users "
        email = 'inhs_admin@replace.me'
        project_name = 'INHS Insect Collection'
        user_name = 'INHS Insect Collection Import'
        $user_id, $project_id = nil, nil
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
        @data.user_index.merge!('0' => user)
        @data.user_index.merge!('' => user)
        @data.user_index.merge!(nil => user)

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
          @taxon_namespace = Namespace.where(institution: 'INHS Insect Collection', name: 'INHS Taxon Code', short_name: 'Taxon Code').first
          @accession_namespace = Namespace.where(institution: 'INHS Insect Collection', name: 'INHS Legacy Accession Code', short_name: 'Accession Code').first
          print "from database.\n"
        else
          print "as newly parsed.\n"
          @taxon_namespace = Namespace.create(institution: 'INHS Insect Collection', name: 'INHS Taxon Code', short_name: 'Taxon Code')
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

        data.namespaces.merge!(taxon_namespace: @taxon_namespace)
        data.namespaces.merge!(accession_namespace: @accession_namespace)
      end

      CONTAINER_TYPE = {
          nil => 'Container::Virtual',
          '' => 'Container::Virtual',
          'Amber' => 'Container::Box',
          'Bulk dry' => 'Container::PillBox',
          'Envelope' => 'Container::Envelope',
          'Jar' => 'Container::Jar',
          'pill box' => 'Container::PillBox',
          'Pill box' => 'Container::PillBox',
          'Pin' => 'Container::Pin',
          'Slide' => 'Container::Slide',
          'Slides' => 'Container::Slide',
          'Vial' => 'Container::Vial'
      }

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
      }

      def handle_preparation_types(data, import)
        print "Handling namespaces \n"

        preparation_types = {
            'Bulk dry' => 'Unsorted dry specimens',
            'Envelope' => 'Dry specimen(s) in envelope',
            'Pill box' => 'Specimens in pill box',
            'Jar' => 'Specimen(s) in jar',
            'Pin' => 'Specimen(s) on pin',
            'Slide' => 'Specimen(s) on slide',
            'Vial' => 'Specimen(s) in vial'
        }
        preparation_types.each do |pt|
          t = PreparationType.where(name: pt[0])
          if t.empty?
            t = PreparationType.create(name: pt[0], definition: pt[1])
            t.tags.create(keyword: data.keywords['INHS'])
          else
            t = t.first
          end
          data.preparation_types.merge!(pt[0] => t)
        end
        data.preparation_types.merge!('Slides' => data.preparation_types['Slide'])
        data.preparation_types.merge!('Vials' => data.preparation_types['Vial'])
        data.preparation_types.merge!('Jars' => data.preparation_types['Jar'])
        data.preparation_types.merge!('pill box' => data.preparation_types['Pill box'])
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
          'LedgerBook',
          'Locality',
          'Park',
          'Sex',
          'Species',
          'StreamSize',
          'WisconsinGlaciated',

          'PrecisionCode',    # tag on Georeference
      ]

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

          data.keywords.merge!('INHS' => Keyword.create(name: 'INHS', definition: 'Belongs to INHS Insect collection.'))
          data.keywords.merge!('INHS_imported' => Keyword.create(name: 'INHS_imported', definition: 'Imported from INHS Insect collection database.'))

          # from collecting_events
          PREDICATES.each do |p|
            data.keywords.merge!(p => Predicate.create(name: "#{p}", definition: "The verbatim value imported from INHS FileMaker database for #{p}.")  )
          end

          # from handle taxa
          data.keywords.merge!(
              'Taxa:TaxonCode' => Predicate.create(name: 'TaxonCode', definition: 'The verbatim value on import from INHS FileMaker database for Taxa#TaxonCode.'),
              'Taxa:Synonyms' => Predicate.create(name: 'Synonyms', definition: 'The verbatim value on import from INHS FileMaker database for Taxa#Synonyms.'),
              'Taxa:References' => Predicate.create(name: 'References', definition: 'The verbatim value on import INHS FileMaker database for Taxa#References.')
          )

          # from handle people
          data.keywords.merge!(
              'PeopleID' => Predicate.create(name: 'PeopleID', definition: 'PeopleID imported from INHS FileMaker database.'),
              'SupervisorID' => Predicate.create(name: 'SupervisorID', definition: 'People:SupervisorID imported from INHS FileMaker database.'),
              'Honorarium' => Predicate.create(name: 'Honorarium', definition: 'People:Honorarium imported from INHS FileMaker database.'),
              'Address' => Predicate.create(name: 'Address', definition: 'People:Address imported from INHS FileMaker database.'),
              'Email' => Predicate.create(name: 'Email', definition: 'People:Email imported from INHS FileMaker database.'),
              'Phone' => Predicate.create(name: 'Phone', definition: 'People:Phone imported from INHS FileMaker database.')
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

              'ZeroTotal' => Keyword.create(name: 'ZeroTotal', definition: 'On import there were 0 total specimens recorded in INHS FileMaker database.'),
              'Prefix' => Predicate.create(name: 'Prefix', definition: 'CatalogNumberPrefix imported from INHS FileMaker database.'),
              'CatalogNumber' => Predicate.create(name: 'CatalogNumber', definition: 'CatalogNumber imported from INHS FileMaker database.'),
              'IdentifiedBy' => Predicate.create(name: 'IdentifiedBy', definition: 'IdentifiedBy field imported from INHS FileMaker database.'),
              'YearIdentified' => Predicate.create(name: 'YearIdentified', definition: 'YearIdentified field imported from INHS FileMaker database.'),
              'LocalityCode' => Predicate.create(name: 'LocalityCode', definition: 'LocalityCode field imported from INHS FileMaker database.'),
              'OldIdentifiedBy' => Predicate.create(name: 'OriginalIdentifiedBy', definition: 'OldIdentifiedBy field imported from INHS FileMaker database.'),
              'OldLocalityCode' => Predicate.create(name: 'OldLocalityCode', definition: 'OldLocalityCode field imported from INHS FileMaker database.'),
              'Type' => Predicate.create(name: 'Type', definition: 'Type field imported from INHS FileMaker database.'),
              'TypeName' => Predicate.create(name: 'TypeName', definition: 'TypeName field imported from INHS FileMaker database.'),
              'AccessionNumberLabel' => Predicate.create(name: 'AccessionNumberLabel', definition: 'AccessionNumberLabel field imported from INHS FileMaker database.'),
              'SpecialCollection' => Predicate.create(name: 'SpecialCollection', definition: 'SpecialCollection field imported from INHS FileMaker database.'),
              'OldCollector' => Predicate.create(name: 'OldCollector', definition: 'OldCollector field imported from INHS FileMaker database.'),
              'Host' => Predicate.create(name: 'Host', definition: 'Host field imported from INHS FileMaker database.'),
               )

          import.metadata['controlled_vocabulary'] = true
          checkpoint_save(@import) if ENV['no_transaction']
        end
      end

      def find_or_create_collection_user(id, data)
        if id.blank?
          $user_id
        elsif data.user_index[id]
          data.user_index[id].id
        elsif data.people_id[id]
          p = data.people_id[id]
          email = p['Email'].nil? ? nil : p['Email'].downcase
          email = p['LastName'] + id + '@unavailable.email.net' if email.blank?

          user_name = p['LastName'] + ', ' + p['FirstName']

          existing_user = User.where(email: email)

          if existing_user.empty?
            user = User.create(email: email, password: '3242341aas', password_confirmation: '3242341aas', name: user_name,
                   data_attributes_attributes: [ {value: p['PeopleID'], import_predicate: 'PeopleID', type: 'ImportAttribute'} ],
                   tags_attributes:   [ { keyword: data.keywords['INHS_imported'] } ]
            )
#                   data_attributes_attributes: [ {value: p['PeopleID'], import_predicate: data.keywords['PeopleID'].name, controlled_vocabulary_term_id: data.keywords['PeopleID'].id, type: 'ImportAttribute'} ],

            #user.tags.create(keyword: data.keywords['INHS_imported'])
          else
            user = existing_user.first
          end

          unless p['SupervisorID'].blank?
            s = data.people_id[p['SupervisorID']]
            user.notes.create(text: 'Student of ' + s['FirstName'] + ' ' + s['LastName']) unless s.blank?
          end
          data.user_index.merge!(id => user)
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
           Comments}

      def find_or_create_collecting_event(ce, data)

        tmp_ce = { }
        LOCALITY_COLUMNS.each do |c|
          tmp_ce.merge!(c => ce[c]) unless ce[c].blank?
        end

        unless ce['AccessionNumber'].blank?
          if !ce['Collection'].blank?
            c = Identifier.where(identifier: ce['Collection'] + ' ' + ce['AccessionNumber'], namespace_id: @accession_namespace, type: 'Identifier::Local::AccessionCode', project_id: $project_id)
          else
            c = Identifier.where(identifier: ce['AccessionNumber'], namespace_id: @accession_namespace, type: 'Identifier::Local::AccessionCode', project_id: $project_id)
          end
          unless c.empty?
            c = c.first.annotated_object
            data.collecting_event_index.merge!(tmp_ce => c)
            return c
          end
        end

        if !ce['LocalityLabel'].blank? && ce['LocalityLabel'].to_s.length > 5
          md5 = Utilities::Strings.generate_md5(ce['LocalityLabel'])
          c = CollectingEvent.where(md5_of_verbatim_label: md5, project_id: $project_id)
          unless c.empty?
            c = c.first
            data.collecting_event_index.merge!(tmp_ce => c)
            if !ce['AccessionNumber'].blank? && !ce['Collection'].blank?
              c.identifiers.create(identifier: ce['Collection'] + ' ' + ce['AccessionNumber'], namespace: @accession_namespace, type: 'Identifier::Local::AccessionCode')
            elsif !ce['AccessionNumber'].blank?
              c.identifiers.create(identifier: ce['AccessionNumber'], namespace: @accession_namespace, type: 'Identifier::Local::AccessionCode')
            end
            return c
          end
        end

        unless data.collecting_event_index[tmp_ce].nil?
          collecting_event = data.collecting_event_index[tmp_ce]
          if collecting_event.data_attributes.where(import_predicate: 'LocalityCode').nil? && !tmp_ce['LocalityCode'].blank?
            byebug
            collecting_event.data_attributes.create(import_predicate: 'LocalityCode', value: tmp_ce['LocalityCode'].to_s, type: 'ImportAttribute')
            #collecting_event.data_attributes.create(import_predicate: 'LocalityCode', value: tmp_ce['LocalityCode'].to_s, type: 'ImportAttribute', controlled_vocabulary_term_id: data.keywords['LocalityCode'].id)
          end
          if collecting_event.verbatim_locality.nil? && !tmp_ce['LocalityLabel'].nil?
            byebug
            collecting_event.verbatim_locality = tmp_ce['LocalityLabel']
            collecting_event.save!
          end
          if collecting_event.identifiers.empty? && !tmp_ce['AccessionNumber'].nil?
            byebug
            if !ce['AccessionNumber'].blank? && !ce['Collection'].blank?
              c.identifiers.create(identifier: ce['Collection'] + ' ' + ce['AccessionNumber'], namespace: @accession_namespace, type: 'Identifier::Local::AccessionCode')
            elsif !ce['AccessionNumber'].blank?
              c.identifiers.create(identifier: ce['AccessionNumber'], namespace: @accession_namespace, type: 'Identifier::Local::AccessionCode')
            end
          end
          if collecting_event.identifiers.empty? || collecting_event.identifiers.first.identifier == tmp_ce['AccessionNumber']
            return collecting_event
          end
        end

        latitude, longitude = parse_lat_long(ce)
        sdm, sdd, sdy, edm, edd, edy = parse_dates(ce)
        elevation, verbatim_elevation = parse_elevation(ce)
        geographic_area = parse_geographic_area(ce)
        geolocation_uncertainty = parse_geolocation_uncertainty(ce)
        locality =  ce['Park'].blank? ? ce['Locality'] : ce['Locality'].to_s + ', ' + ce['Park'].to_s
        created_by = find_or_create_collection_user(ce['CreatedBy'], data)
        updated_by = find_or_create_collection_user(ce['ModifiedBy'], data)

        c = CollectingEvent.new(
            geographic_area_id: geographic_area,
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
            field_notes: nil,
            verbatim_date: nil,
            created_by_id: created_by,
            updated_by_id: updated_by,
            created_at: time_from_field(ce['CreatedOn']),
            updated_at: time_from_field(ce['ModifiedOn'])
        )
        if c.valid?
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

          c.generate_verbatim_data_georeference

          glc = c.georeferences.first
          unless glc.nil?
            glc.error_radius = geolocation_uncertainty
            glc.is_public = true
            glc.save
            c.data_attributes.create(type: 'ImportAttribute', import_predicate: 'georeference_error', value: 'Geolocation uncertainty is conflicting with geographic area') unless glc.valid?
          end

          data.collecting_event_index.merge!(tmp_ce => c)
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
            data.user_index.merge!(u.value => u.attribute_subject)
          end

          DataAttribute.where(import_predicate: 'PeopleID', attribute_subject_type: 'Person').each do |p|
            data.people_index.merge!(p.value => p.attribute_subject)
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

            data.people_id.merge!(row['PeopleID'] => row)
            data.people_index.merge!(row['PeopleID'] => p)
          end
          import.metadata['people'] = true
          checkpoint_save(@import) if ENV['no_transaction']
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
          Identifier.where(namespace_id: @taxon_namespace.id).each do |i|
            data.otus.merge!(i.identifier => i.identifier_object)
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

          f.each_with_index do |row, i|             #f.first(500).each_with_index
            name = row['Name']
            author = (row['Parens'] ? "(#{row['Author']})" : row['Author']) unless row['Author'].blank?
            author ||= nil
            code = :icn if code == :iczn && row['Name'] == 'Plantae'
            rank = Ranks.lookup(code, row['Rank'])
            rank ||= 'NomenclaturalRank'
            name = 'Root' if rank == 'NomenclaturalRank'

            p = Protonym.new(
              name: name,
              verbatim_author: author,
              year_of_publication: row['Year'],
              rank_class: rank,
              created_by_id: find_or_create_collection_user(row['CreatedBy'], data),
              updated_by_id: find_or_create_collection_user(row['ModifiedBy'], data),
              created_at: time_from_field(row['CreatedOn']),
              updated_at: time_from_field(row['ModifiedOn']),
            )
            p.parent_id = parent_index[row['Parent'].to_s].id unless row['Parent'].blank? || parent_index[row['Parent'].to_s].nil?
            if rank == 'NomenclaturalRank'
              p = Protonym.with_rank_class('NomenclaturalRank').first
              parent_index.merge!(row['ID'] => p)
            elsif !p.parent_id.blank?
              bench = Benchmark.measure {
                data.keywords.each do |k|
                  p.data_attributes.build(type: 'InternalAttribute', predicate: k[1], value: row[k[0]]) unless row[k[0]].blank?
                end
              }

              print "\r#{i}\t#{bench.to_s.strip}  #{name}  (Taxon code: #{row['TaxonCode']})                         " #  \t\t#{rank}
              if p.valid?
                p.save!
                build_otu(row, p, data)
                parent_index.merge!(row['ID'] => p)
                data.taxa_index.merge!(row['TaxonCode'] => p)
              else
                puts "\n#{p.name}"
                puts p.errors.messages
                puts
              end
            else
              puts "\n  No parent for #{p.name}.\n"
            end

            p.notes.create(text: row['Remarks']) unless row['Remarks'].blank?
          end

          import.metadata['taxa'] = true
          checkpoint_save(@import) if ENV['no_transaction']
        end
      end

      def build_otu(row, taxon_name, data)
        if row['TaxonCode'].blank?
          # puts "  Skipping OTU creation for #{taxon_name.name}, there is no TaxonCode."
          return true
        end
        o =  Otu.create(
          taxon_name_id: taxon_name.id,
          identifiers_attributes: [  {identifier: row['TaxonCode'], namespace: @taxon_namespace, type: 'Identifier::Local::OtuUtility'} ]
        )
        data.otus.merge!(row['TaxonCode'] => o)
        o
      end

      # Index localities by their collective column=>data pairs
      def build_localities_index(data)
        locality_fields = %w{ LocalityCode Country State County Locality Park BodyOfWater NS Lat_deg Lat_min Lat_sec EW Long_deg Long_min Long_sec Latitude Longitude Elev_m Elev_ft Elevation PrecisionCode Comments DrainageBasinLesser DrainageBasinGreater StreamSize INDrainage WisconsinGlaciated OldLocalityCode CreatedOn ModifiedOn CreatedBy ModifiedBy }

        path = @args[:data_directory] + 'TXT/localities.txt'
        raise 'file not found' if not File.exists?(path)
        lo = CSV.open(path, col_sep: "\t", :headers => true)

        print "Indexing localities..."

        localities = {}
        lo.each do |row|
          tmp_l = {}
          locality_fields.each do |c|
            tmp_l.merge!(c => row[c]) unless row[c].blank?
          end

          tmp_l['County'] = geo_translate(tmp_l['County']) unless tmp_l['County'].blank?
          tmp_l['State'] = geo_translate(tmp_l['State']) unless tmp_l['State'].blank?
          tmp_l['Country'] = geo_translate(tmp_l['Country']) unless tmp_l['Country'].blank?

          data.localities_index.merge!(row['LocalityCode'] => tmp_l)
        end
        print "done\n"
      end

      def index_specimen_records_from_specimens(data, import)
        start = data.collecting_event_index.keys.count
        puts " specimen records from specimens.txt"
        path = @args[:data_directory] + 'TXT/specimens.txt'
        raise 'file not found' if not File.exists?(path)

        sp = CSV.open(path, col_sep: "\t", :headers => true)

        specimen_fields = %w{ Prefix CatalogNumber PreparationType TaxonCode LocalityCode AccessionSource DeaccessionRecipient DeaccessionCause DeaccessionDate DateCollectedBeginning DateCollectedEnding Collector LocalityLabel AccessionNumberLabel DeterminationLabel OtherLabel SpecialCollection IdentifiedBy YearIdentified CollectionMethod Habitat Type TypeName Remarks AdultMale AdultFemale Immature Pupa Exuvium AdultUnsexed AgeUnknown OtherSpecimens Checked OldLocalityCode OldCollector OldIdentifiedBy CreatedBy CreatedOn ModifiedOn ModifiedBy }
        count_fields = %w{ AdultMale AdultFemale Immature Pupa Exuvium AdultUnsexed AgeUnknown OtherSpecimens }

        sp.each_with_index do |row, i|
          print "\r#{i}      "

          locality_code = row['LocalityCode']
          se = { }

          if !data.localities_index[locality_code].nil?
            #Utilities::Hashes.puts_collisions(tmp_ce, LOCALITIES[locality_code])
            se.merge!(data.localities_index[locality_code])
          else
            data.unmatched_localities.merge!(locality_code => nil) unless locality_code.blank?
          end
          specimen_fields.each do |c|
            se.merge!(c => row[c]) unless row[c].blank?
          end

          collecting_event = find_or_create_collecting_event(se, data)
          preparation_type = data.preparation_types[se['preparation_type']]

          no_specimens = false
          if count_fields.collect{ |f| se[f] }.select{ |n| !n.nil? }.empty?
            se.merge!('OtherSpecimens' => '1')
            no_specimens = true
          end

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
                objects += [specimen]
                specimen.notes.create(text: se['Remarks']) unless se['Remarks'].blank?

                data.keywords.each do |k|
                  specimen.data_attributes.create(type: 'InternalAttribute', controlled_vocabulary_term_id: k[1].id, value: se[k[0]]) unless se[k[0]].blank?
                end

                specimen.tags.create(keyword: data.keywords['ZeroTotal']) if no_specimens

                Role.create(person: data.people_index[se['AccessionSource']], role_object: specimen, type: 'AccessionProvider') unless se['AccessionSource'].blank?
                Role.create(person: data.people_index[se['DeaccessionRecipient']], role_object: specimen, type: 'DeaccessionRecipient') unless se['DeaccessionRecipient'].blank?
              else
                data.invalid_specimens.merge!(se['Prefix'] + ' ' + se['CatalogueNumber'] => nil)
              end

              unless specimen.valid?
                byebug
              end
            end
          end
          add_identifiers(objects, row, data)
          add_determinations(objects, row, data)
        end

        puts "\n Number of collecting events processed from specimens: #{data.collecting_events_index.keys.count - start} "
      end

      def add_identifiers(objects, row, data)
        puts "no catalog number for #{row['ID']}" if row['CatalogNumber'].blank?

        identifier = Identifier::Local::CatalogNumber.new(namespace: @data.namespaces[row['Prefix']], identifier: row['CatalogNumber']) unless row['CatalogNumber'].blank?

        if objects.count > 1 # Identifier on container.
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
        data.duplicate_specimen_ids.merge!(row['Prefix'].to_s + ' ' + row['CatalogueNumber'].to_s => nil) unless identifier.valid?
      end

      def add_determinations(objects, row, data)
        otu = data.otus[row['TaxonCode']]
        objects.each do |o|
          unless otu.nil?
            td = TaxonDetermination.create(
                biological_collection_object: o,
                otu: otu,
                year_made: row['YearIdentified']
            )

            if !row['Type'].blank?
              type = TYPE_TYPE[row['Type'].downcase]
              unless type.nil?
                type = type + 's' if o.type == "Lot"
                tm = TypeMaterial.create(protonym_id: otu.taxon_name_id, material: o, type_type: type )
                if tm.valid?
                  tm.data_attributes.create(type: 'InternalAttribute', controlled_vocabulary_term_id: data.keywords['TypeName'], value: row['TypeName']) unless row['TypeName'].blank?
                else
                  byebug
                  data.invalid_type_names.merge!(row['Type'].downcase => nil)
                end
              end
            end
          else
            data.unmatched_taxa.merge!(row['TaxonCode'] => nil) unless row['TaxonCode'].blank?
          end
        end
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

      def  index_collecting_events_from_accessions_new(data, import)
        path = @args[:data_directory] + 'TXT/accessions_new.txt' # self contained
        raise 'file not found' if not File.exists?(path)

        ac = CSV.open(path, col_sep: "\t", :headers => true)

        fields = %w{ LocalityLabel Habitat Host AccessionNumber Country State County Locality Park DateCollectedBeginning DateCollectedEnding Collector CollectionMethod Elev_m Elev_ft NS Lat_deg Lat_min Lat_sec EW Long_deg Long_min Long_sec Comments PrecisionCode Datum ModifiedBy ModifiedOn }

        puts "\naccession new records\n"
        ac.each_with_index do |row, i|
          print "\r#{i}"
          tmp_ce = { }
          fields.each do |c|
            tmp_ce.merge!(c => row[c]) unless row[c].blank?
          end
          tmp_ce['County'] = geo_translate(tmp_ce['County']) unless tmp_ce['County'].blank?
          tmp_ce['State'] = geo_translate(tmp_ce['State']) unless tmp_ce['State'].blank?
          tmp_ce['Country'] = geo_translate(tmp_ce['Country']) unless tmp_ce['Country'].blank?

          tmp_ce.merge!('CreatedBy' => '1031', 'CreatedOn' => '01/20/2014 12:00:00')

          find_or_create_collecting_event(tmp_ce, data)

          #puts "\n!! Duplicate collecting event: #{row['Collection']} #{row['AccessionNumber']}" unless collecting_events_index[tmp_ce].nil?

          #collecting_events_index.merge!(tmp_ce => row.to_h)
          #collecting_events_index.merge!( Utilities::Hashes.delete_keys(row.to_h, STRIP_LIST)  => nil)
        end
        puts "\n Number of collecting events processed from Accessions_new: #{data.collecting_event_index.keys.count} "
      end

      def index_collecting_events_from_ledgers(data, import)
        starting_number = data.collecting_event_index.empty? ? 0 : data.collecting_event_index.keys.count

        path = @args[:data_directory] + 'TXT/ledgers.txt'
        raise 'file not found' if not File.exists?(path)
        le = CSV.open(path, col_sep: "\t", :headers => true)

        fields = %w{ Collection AccessionNumber LedgerBook LedgersCountry LedgersState LedgersCounty LedgersLocality DateCollectedBeginning DateCollectedEnding Collector Order Family Genus Species HostGenus HostSpecies Sex LedgersComments Description Remarks LocalityCode OldLocalityCode CreatedBy CreatedOn }

        puts "\n  from ledgers\n"

        le.each_with_index do |row, i|
          print "\r#{i}"
          tmp_ce = { }
          fields.each do |c|
            tmp_ce.merge!(c => row[c]) unless row[c].blank?
          end
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

          find_or_create_collecting_event(tmp_ce, data)
        end

#        le.each_with_index do |row, i|
#          print "\r#{i}      "
#          tmp_ce = { }
#          SPECIMENS_COLUMNS.each do |c|
#            tmp_ce.merge!(c => row[c]) unless row[c].blank?
#          end
#          #Utilities::Hashes.puts_collisions(tmp_ce, LOCALITIES[locality_code])
#          puts "\n!! Duplicate collecting event: #{row['Collection']} #{row['AccessionNumber']}" unless collecting_events_index[tmp_ce].nil?#
#
#          collecting_events_index.merge!(tmp_ce => row.to_h)
#          #collecting_events_index.merge!(Utilities::Hashes.delete_keys(row.to_h, STRIP_LIST) => nil)
#        end
        puts "\n Number of collecting events processed from Ledgers: #{data.collecting_event_index.keys.count - starting_number} "
      end

      def parse_geographic_area(ce)
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
            $matchless_for_geographic_area.merge!(geog_search => 1)
          end
        elsif match.count > 1
          #puts "\nMultiple geographic areas match #{geog_search}\n"
          if $matchless_for_geographic_area[geog_search]
            $matchless_for_geographic_area[geog_search] += 1
          else
            $matchless_for_geographic_area.merge!(geog_search => 1)
          end
        elsif match.count == 1
          if $found_geographic_areas[geog_search]
            $found_geographic_areas[geog_search] += 1
          else
            $found_geographic_areas.merge!(geog_search => 1)
          end
          geographic_area = match[0]
        else
          puts "\nHuh?! not zero, 1 or more than one matches"
        end
        geographic_area
      end

      def parse_lat_long(ce)
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

        sdy = sdy.to_i unless sdy.blank?
        edy = edy.to_i unless edy.blank?
        sdd = sdd.to_i unless sdd.blank?
        edd = edd.to_i unless edd.blank?
        sdm = sdm.to_i unless sdm.blank?
        edm = edm.to_i unless edm.blank?
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
          verbatim_elevation = ce['Elev_ft'] + ' ft.'
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





