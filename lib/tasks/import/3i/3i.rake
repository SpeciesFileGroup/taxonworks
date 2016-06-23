  require 'fileutils'

  ### rake tw:project_import:access3i:import_all data_directory=/Users/proceps/src/sf/import/3i/TXT/ no_transaction=true

  namespace :tw do
    namespace :project_import do
      namespace :access3i do

      @import_name = '3i'

      # A utility class to index data.
      class ImportedData3i
        attr_accessor :people_index, :user_index, :publications_index, :citations_index, :genera_index, :images_index,
                      :parent_id_index, :statuses, :taxon_index, :citation_to_publication_index, :keywords,
                      :incertae_sedis, :emendation, :original_combination, :unique_host_plant_index,
                      :host_plant_index, :topics, :nouns, :countries, :geographic_areas, :museums, :namespaces, :biocuration_classes
        def initialize()
          @keywords = {}                  # keyword -> ControlledVocabularyTerm
          @people_index = {}              # PeopleID -> Person object
          @user_index = {}                # PeopleID -> User object
          @publications_index = {}        # Key3 -> Surce object
          @citations_index = {}           # NEW_REF_ID -> row
          @citation_to_publication_index = {} # NEW_REF_ID -> source.id
          @genera_index = {}              # GENUS_NUMBER -> row
          @images_index = {}              # TaxonNo -> row
          @parent_id_index = {}           # Rank:TaxonName -> Taxon.id
          @statuses = {}
          @taxon_index = {}             #Key -> Taxon.id
          @incertae_sedis = {}            #for those taxa which have a parent of incertae sedis
          @emendation = {}                # taxon name emendation source reference key => row
          @original_combination = {}      # original combination key => row
          @unique_host_plant_index = {}
          @host_plant_index = {}
          @topics = {}
          @nouns = {}
          @countries = {}
          @geographic_areas = {}
          @museums = {}
          @namespaces = {}
          @biocuration_classes = {}
        end
      end

      task :import_all => [:data_directory, :environment] do |t|

        @ranks = {
            0 => '',
            1 => Ranks.lookup(:iczn, :subspecies),
            2 => Ranks.lookup(:iczn, :species),
            4 => 'NomenclaturalRank::Iczn::SpeciesGroup::SpeciesGroup',
            6 => Ranks.lookup(:iczn, :subgenus),
            7 => Ranks.lookup(:iczn, :genus),
            8 => 'NomenclaturalRank::Iczn::GenusGroup::GenusGroup',
            9 => Ranks.lookup(:iczn, :subtribe),
            10 => Ranks.lookup(:iczn, :tribe),
            11 => Ranks.lookup(:iczn, :supertribe),
            12 => Ranks.lookup(:iczn, :subfamily),
            13 => Ranks.lookup(:iczn, :family),
            15 => Ranks.lookup(:iczn, :superfamily),
            17 => Ranks.lookup(:iczn, :infraorder),
            18 => Ranks.lookup(:iczn, :suborder),
            19 => Ranks.lookup(:iczn, :order),
            20 => Ranks.lookup(:iczn, :class),
            21 => Ranks.lookup(:iczn, :subphylum),
            22 => Ranks.lookup(:iczn, :phylum),
            23 => Ranks.lookup(:iczn, :kingdom)
        }.freeze

        @relationship_classes = {
            0 => '', ### valid
            1 => 'TaxonNameRelationship::Iczn::Invalidating::Synonym',   #### ::Objective or ::Subjective
            2 => '', ### Original combination
            3 => 'TaxonNameRelationship::Iczn::Invalidating::Homonym::Primary',
            4 => 'TaxonNameRelationship::Iczn::Invalidating::Homonym::Secondary', #### or 'Secondary::Secondary1961'
            5 => 'TaxonNameRelationship::Iczn::Invalidating::Homonym', ## Preocupied
            6 => 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression',
            7 => '', ###common name
            8 => 'TaxonNameRelationship::Iczn::Invalidating::Usage::FamilyGroupNameForm', #### combination => Combination
            9 => 'TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling',
            10 => 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::UnjustifiedEmendation',
            11 => 'TaxonNameRelationship::Iczn::Invalidating', #### misaplication
            12 => '', #### nomen dubium
            13 => '', #### nomen nudum
            14 => 'TaxonNameRelationship::Iczn::Invalidating::Synonym::ForgottenName',
            15 => 'TaxonNameRelationship::Iczn::PotentiallyValidating::ReplacementName', #### nomen novum; not used
            16 => '', #### unnamed => OTU
            17 => 'TaxonNameRelationship::Iczn::Invalidating::Synonym', #### new synonym; not used
            18 => '', ### type designation => relationship source.
            19 => '', ### neotype designation => atribute
            20 => '', ### lectotype designation => atribute
            21 => '', ### new status; not used
            22 => 'TaxonNameRelationship::Iczn::Invalidating', ### not binomial
            23 => 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression',
            24 => 'TaxonNameRelationship::Iczn::Invalidating', ### not available
            25 => 'TaxonNameRelationship::Iczn::PotentiallyValidating::FirstRevisorAction', #### justified emendation
            26 => 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::SynonymicHomonym',
            27 => 'TaxonNameRelationship::Iczn::Invalidating::Usage::Misapplication',
            28 => 'TaxonNameRelationship::Iczn::Invalidating', ### invalid
            29 => 'TaxonNameRelationship::Iczn::Invalidating', ### infrasubspecific

            'type species' => 'TaxonNameRelationship::Typification::Genus',
            'absolute tautonymy' => 'TaxonNameRelationship::Typification::Genus::Tautonomy::Absolute',
            'monotypy' => 'TaxonNameRelationship::Typification::Genus::Monotypy::Original',
            'original designation' => 'TaxonNameRelationship::Typification::Genus::OriginalDesignation',
            'subsequent designation' => 'TaxonNameRelationship::Typification::Genus::Tautonomy',
            'original monotypy' => 'TaxonNameRelationship::Typification::Genus::Monotypy::Original',
            'subsequent monotypy' => 'TaxonNameRelationship::Typification::Genus::Monotypy::Subsequent',
            'Incorrect original spelling' => 'TaxonNameRelationship::Iczn::Invalidating::Usage::IncorrectOriginalSpelling',
            'Incorrect subsequent spelling' => 'TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling',
            'Junior objective synonym' => 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective',
            'Junior subjective synonym' => 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Subjective',
            'Junior subjective Synonym' => 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Subjective',
            'Misidentification' => 'TaxonNameRelationship::Iczn::Invalidating::Usage::Misapplication',
            'Nomen nudum: Published as synonym and not validated before 1961' => 'TaxonNameRelationship::Iczn::Invalidating',
            'Objective replacement name: Junior subjective synonym' => 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Subjective',
            'Unnecessary replacement name' => 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::UnnecessaryReplacementName',
            'Suppressed name' => 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression',
            'Unavailable name: pre-Linnean' => 'TaxonNameRelationship::Iczn::Invalidating',
            'Unjustified emendation' => 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::UnjustifiedEmendation',
            'Objective replacement name: Valid Name' => 'TaxonNameRelationship::Iczn::Invalidating::Synonym',
            'Hybrid' => '',
            'Junior homonym' => 'TaxonNameRelationship::Iczn::Invalidating::Synonym',
            'Manuscript name' => '',
            'Nomen nudum' => '',
            'Nomen nudum: no description' => '',
            'Nomen nudum: No type fixation after 1930' => '',
            'Unavailable name: Infrasubspecific name' => '',
            'Suppressed name: ICZN official index of rejected and invalid works' => 'TaxonNameRelationship::Iczn::Invalidating::Synonym',
            'Valid Name' => '',
            'Original_Genus' => 'TaxonNameRelationship::OriginalCombination::OriginalGenus',
            'OrigSubgen' => 'TaxonNameRelationship::OriginalCombination::OriginalSubgenus',
            'Original_Species' => 'TaxonNameRelationship::OriginalCombination::OriginalSpecies',
            'Original_Subspecies' => 'TaxonNameRelationship::OriginalCombination::OriginalSubspecies',
            'Original_Infrasubspecies' => 'TaxonNameRelationship::OriginalCombination::OriginalVariety',
            'Incertae sedis' => 'TaxonNameRelationship::Iczn::Validating::UncertainPlacement'
        }.freeze

        @classification_classes = {
            0 => '', ### valid
            12 => 'TaxonNameClassification::Iczn::Available::Valid::NomenDubium',
            13 => 'TaxonNameClassification::Iczn::Unavailable::NomenNudum',
            22 => 'TaxonNameClassification::Iczn::Unavailable::NonBinomial',
            24 => 'TaxonNameClassification::Iczn::Unavailable',
            28 => 'TaxonNameClassification::Iczn::Available::Invalid',
            29 => 'TaxonNameClassification::Iczn::Unavailable::Excluded::Infrasubspecific', ### infrasubspecific
        }.freeze

        @languages = {
            'ba' => 'bal',
            'en' => 'eng',
            'fr' => 'fre',
            'ge' => 'ger',
            'ko' => 'kor',
            'ma' => 'hun',
            'sp' => 'spa',
            'ta' => 'tgl',
            'vi' => 'hil',
            'pt' => 'por'
        }.freeze

        @locality_columns_3i = %w{
          Country
          State
          County
          GLocality
          SLocality
          Date
          DateTo
          Collectors
          Method
          LatNS
          LatDeg
          LatMin
          LatSec
          LongEW
          LongDeg
          LongMin
          LongSec
          ElevationM
          ElevationF
          Ecology
          Precision
          TW_id }.freeze

        @type_type_3i = {
            'allotype' => 'paratype',
            'holotype' => 'holotype',
            'lectotype' => 'lectotype',
            'neotype' => 'neotype',
            'paralectotype' => 'paralectotype',
            'paratype' => 'paratype',
            'paratypes' => 'paratype',
            'syntype' => 'syntype',
            'syntypes' => 'syntype'
        }.freeze



        if ENV['no_transaction']
          puts 'Importing without a transaction (data will be left in the database).'
          main_build_loop_3i
        else

          ActiveRecord::Base.transaction do
            begin
              main_build_loop_3i
            rescue
              raise
            end
          end

        end

      end

      def main_build_loop_3i
        print "\nStart time: #{Time.now}\n"

        @import = Import.find_or_create_by(name: @import_name)
        @import.metadata ||= {}
        @data =  ImportedData3i.new
        puts @args
        Utilities::Files.lines_per_file(Dir["#{@args[:data_directory]}/**/*.txt"])
        handle_projects_and_users_3i
        raise '$project_id or $user_id not set.'  if $project_id.nil? || $user_id.nil?

        #$project_id = 1
        handle_controlled_vocabulary_3i
        handle_references_3i
        handle_taxonomy_3i
        handle_taxon_name_relationships_3i
        handle_citation_topics_3i
        handle_host_plant_name_dictionary_3i
        handle_host_plants_3i
        handle_distribution_3i
        handle_localities_3i

        print "\n\n !! Success. End time: #{Time.now} \n\n"
      end

      def handle_projects_and_users_3i
        print "\nHandling projects and users "
        email = 'arboridia@gmail.com'
        project_name = '3i Auchenorrhyncha'
        user_name = '3i Import'
        $user_id, $project_id = nil, nil
        if @import.metadata['project_and_users']
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
          $user_id = user.id

          project = nil

          if project.nil?
            project = Project.create(name: project_name)
          end

          $project_id = project.id
          pm = ProjectMember.new(user: user, project: project, is_project_administrator: true)
          pm.save! if pm.valid?

          @import.metadata['project_and_users'] = true
        end

        @root = Protonym.find_or_create_by(name: 'Root', rank_class: 'NomenclaturalRank', project_id: $project_id)
        @data.keywords.merge!('3i_imported' => Keyword.find_or_create_by(name: '3i_imported', definition: 'Imported from 3i database.'))
      end


      def handle_controlled_vocabulary_3i
        print "\nHandling CV \n"

        @data.keywords.merge!(
            #'AuthorDrMetcalf' => Predicate.find_or_create_by(name: 'AuthorDrMetcalf', definition: 'Author name from DrMetcalf bibliography database.', project_id: $project_id),
            '3i_imported' => Keyword.find_or_create_by(name: '3i_imported', definition: 'Imported from 3i database.', project_id: $project_id),
            'introduced' => Keyword.find_or_create_by(name: 'Introduced', definition: 'Introduced species.', project_id: $project_id),
            'ZeroTotal' => Keyword.find_or_create_by(name: 'ZeroTotal', definition: 'On import there were 0 total specimens recorded in INHS FileMaker database.', project_id: $project_id),
            'CallNumberDrMetcalf' => Predicate.find_or_create_by(name: 'call_number_dr_metcalf', definition: 'Call Number from DrMetcalf bibliography database.', project_id: $project_id),
            #'AuthorReference' => Predicate.find_or_create_by(name: 'author_reference', definition: 'Author string as it appears in the nomenclatural reference.', project_id: $project_id),
            #'YearReference' => Predicate.find_or_create_by(name: 'year_reference', definition: 'Year string as it appears in the nomenclatural reference.', project_id: $project_id),
            'Ethymology' => Predicate.find_or_create_by(name: 'ethymology', definition: 'Ethymology.', project_id: $project_id),
            'TypeDepository' => Predicate.find_or_create_by(name: 'type_depository', definition: 'Type depository.', project_id: $project_id),
            'YearRem' => Predicate.find_or_create_by(name: 'nomenclatural_string', definition: 'Nomenclatural remarks.', project_id: $project_id),
            'Typification' => Predicate.find_or_create_by(name: 'type_designated_by', definition: 'Type designated by', project_id: $project_id),
            'FirstRevisor' => Predicate.find_or_create_by(name: 'first_revisor_action', definition: 'First revisor action', project_id: $project_id),
            'PageAuthor' => Predicate.find_or_create_by(name: 'page_author', definition: 'Page author.', project_id: $project_id),
            'SimilarSpecies' => Predicate.find_or_create_by(name: 'similar_species', definition: 'Similar species.', project_id: $project_id),
            'IDDrMetcalf' => Namespace.find_or_create_by(name: 'DrMetcalf_Source_ID', short_name: 'DrMetcalf_ID'),
            'Key3' => Namespace.find_or_create_by(name: '3i_Source_ID', short_name: '3i_Source_ID'),
            'Key' => Namespace.find_or_create_by(name: '3i_Taxon_ID', short_name: '3i_Taxon_ID'),
            'FLOW-ID' => Namespace.find_or_create_by(name: 'FLOW_Source_ID', short_name: 'FLOW_Source_ID'),
            'DelphacidaeID' => Namespace.find_or_create_by(name: 'Delphacidae_Source_ID', short_name: 'Delphacidae_ID'),
            'Taxonomy' => Keyword.find_or_create_by(name: 'Taxonomy updated', definition: 'Taxonomical information entered to the DB.', project_id: $project_id),
            'Typhlocybinae' => Keyword.find_or_create_by(name: 'Typhlocybinae updated', definition: 'Information related to Typhlocybinae entered to the DB.', project_id: $project_id),
            'Illustrations' => Keyword.find_or_create_by(name: 'Illustrations exported', definition: 'Illustrations of Typhlocybinae species entered to the DB.', project_id: $project_id),
            'Distribution' => Keyword.find_or_create_by(name: 'Distribution exported', definition: 'Illustrations on species distribution entered to the DB.', project_id: $project_id),
            'Notes' => Topic.find_or_create_by(name: 'Notes', definition: 'Notes topic on the OTU.', project_id: $project_id),
            'Host' => BiologicalProperty.find_or_create_by(name: 'Host', definition: 'An animal or plant on or in which a parasite or commensal organism lives.', project_id: $project_id),
            'Herbivor' => BiologicalProperty.find_or_create_by(name: 'Herbivor', definition: 'An animal that feeds on plants.', project_id: $project_id),
            'Parasitoid' => BiologicalProperty.find_or_create_by(name: 'Parasitoid', definition: 'An organism that lives in or on another organism.', project_id: $project_id),
            'Attendant' => BiologicalProperty.find_or_create_by(name: 'Attendant', definition: 'An insect attending another insect.', project_id: $project_id),
            'Symbiont' => BiologicalProperty.find_or_create_by(name: 'Symbiont', definition: 'An insect leaving togeather with another insect.', project_id: $project_id),
            'Pin' => PreparationType.find_or_create_by(name: 'Pin', definition: 'Specimen(s) on pin')
        )

        @data.namespaces.merge!(
            'INHS' => Namespace.find_or_create_by(institution: 'INHS Insect Collection', name: 'INHS Insect Collection', short_name: 'Insect Collection'),
            'CAS' => Namespace.find_or_create_by(institution: 'California Academy of Sciences (Erythroneura project label)', name: 'Erythroneura CAS', short_name: 'CAS'),
            'CNC' => Namespace.find_or_create_by(institution: 'Canadian National Collection of Insects, Arachnids and Nematodes (project label)', name: 'Erythroneura CNC', short_name: 'CNC'),
            'CSU' => Namespace.find_or_create_by(institution: 'Colorado State University (Erythroneura project label)', name: 'Erythroneura CSU', short_name: 'CSU'),
            'MSU' => Namespace.find_or_create_by(institution: 'Mississippi State University, Mississippi Entomological Museum (Erythroneura project label)', name: 'Erythroneura MEM', short_name: 'MEM'),
            'NCSU' => Namespace.find_or_create_by(institution: 'North Carolina State University Insect Collection (Erythroneura project label)', name: 'Erythroneura NCSU', short_name: 'NCSU'),
            'OSU' => Namespace.find_or_create_by(institution: 'Ohio State University (Erythroneura project label)', name: 'Erythroneura OSU', short_name: 'OSU'),
            'OSUC' => Namespace.find_or_create_by(institution: 'Ohio State University', name: 'OSUC', short_name: 'OSUC'),
            'SEMC' => Namespace.find_or_create_by(institution: 'University of Kansas Natural History Museum', name: 'SEMC', short_name: 'SEMC'),
            'SM' => Namespace.find_or_create_by(institution: 'University of Kansas Natural History Museum', name: 'SM', short_name: 'SM'),
            'TACatanach' => Namespace.find_or_create_by(institution: 'T.A. Catanach (project label)', name: 'T.A. Catanach', short_name: 'TACatanach'),
            'Type' => Namespace.find_or_create_by(institution: 'INHS Insect Collection', name: 'INHS Type', short_name: 'Type'),
            'USNM' => Namespace.find_or_create_by(institution: 'Smithsonian National Museum of Natural History (Erythroneura project label)', name: 'Erythroneura USNM', short_name: 'USNM')
        )

        @data.biocuration_classes.merge!(
            "Specimens" => BiocurationClass.find_or_create_by(name: "Adult", definition: 'Adult specimen', project_id: $project_id),
            "Males" => BiocurationClass.find_or_create_by(name: "Male", definition: 'Male specimen', project_id: $project_id),
            "Females" => BiocurationClass.find_or_create_by(name: "Female", definition: 'Female specimen', project_id: $project_id),
            "Nymphs" => BiocurationClass.find_or_create_by(name: "Immature", definition: 'Immature specimen', project_id: $project_id),
            "Exuvia" => BiocurationClass.find_or_create_by(name: "Exuvia", definition: 'Exuvia specimen', project_id: $project_id)
        )

        @data.topics.merge!(
                        'Descriptions' => Topic.find_or_create_by(name: 'Description', definition: 'Source has morphological description.', project_id: $project_id),
                        'Records' => Topic.find_or_create_by(name: 'Distribution', definition: 'Source has data on species distrebution or studied material.', project_id: $project_id),
                        'Pictures' => Topic.find_or_create_by(name: 'Illustrations', definition: 'Source has illustrations.', project_id: $project_id),
                        'Types' => Topic.find_or_create_by(name: 'Original description', definition: 'Source has original description.', project_id: $project_id),
                        'Keys' => Topic.find_or_create_by(name: 'Identification key', definition: 'Source has identification key.', project_id: $project_id),
                        'Synonymy' => Topic.find_or_create_by(name: 'Synonymy', definition: 'Source has synonymy records.', project_id: $project_id),
                        'Host' => Topic.find_or_create_by(name: 'Host plants', definition: 'Source has host plant records.', project_id: $project_id),
                        'Parasitoids' => Topic.find_or_create_by(name: 'Parasitoids', definition: 'Source has parasitoid records.', project_id: $project_id),
        )

        @host_plant_relationship = BiologicalRelationship.where(name: 'Host plant', project_id: $project_id).first
        if @host_plant_relationship.nil?
          @host_plant_relationship = BiologicalRelationship.create(name: 'Host plant')
          a1 = BiologicalRelationshipType.create(biological_property: @data.keywords['Host'], biological_relationship: @host_plant_relationship, type: 'BiologicalRelationshipType::BiologicalRelationshipSubjectType')
          a2 = BiologicalRelationshipType.create(biological_property: @data.keywords['Herbivor'], biological_relationship: @host_plant_relationship, type: 'BiologicalRelationshipType::BiologicalRelationshipObjectType')
        end
        @parasitoid_relationship = BiologicalRelationship.where(name: 'Parasitism', project_id: $project_id)
        if @parasitoid_relationship.empty?
          @parasitoid_relationship = BiologicalRelationship.create(name: 'Parasitism')
          a1 = BiologicalRelationshipType.create(biological_property: @data.keywords['Parasitoid'], biological_relationship: @parasitoid_relationship, type: 'BiologicalRelationshipType::BiologicalRelationshipSubjectType')
          a2 = BiologicalRelationshipType.create(biological_property: @data.keywords['Host'], biological_relationship: @parasitoid_relationship, type: 'BiologicalRelationshipType::BiologicalRelationshipObjectType')
        end
        @attendance_relationship = BiologicalRelationship.where(name: 'Attendance', project_id: $project_id)
        if @attendance_relationship.empty?
          @attendance_relationship = BiologicalRelationship.create(name: 'Attendance')
          a1 = BiologicalRelationshipType.create(biological_property: @data.keywords['Attendant'], biological_relationship: @attendance_relationship, type: 'BiologicalRelationshipType::BiologicalRelationshipSubjectType')
          a2 = BiologicalRelationshipType.create(biological_property: @data.keywords['Host'], biological_relationship: @attendance_relationship, type: 'BiologicalRelationshipType::BiologicalRelationshipObjectType')
        end
        @mutualism_relationship = BiologicalRelationship.where(name: 'Mutualism', project_id: $project_id)
        if @mutualism_relationship.empty?
          @mutualism_relationship = BiologicalRelationship.create(name: 'Mutualism')
          a1 = BiologicalRelationshipType.create(biological_property: @data.keywords['Symbiont'], biological_relationship: @mutualism_relationship, type: 'BiologicalRelationshipType::BiologicalRelationshipSubjectType')
          a2 = BiologicalRelationshipType.create(biological_property: @data.keywords['Host'], biological_relationship: @mutualism_relationship, type: 'BiologicalRelationshipType::BiologicalRelationshipObjectType')
        end
      end


      def handle_references_3i

        # Key3
        # AY
        # Author
        # Year
        # Title
        # Bibliography
        # Notes
        # AuthorDrMetcalf
        # VerbatimDrMetcalf ---- Not export
        # CallNumberDrMetcalf
        # NotesDrMetcalf
        # IDDrMetcalf
        # CachedSanborn ---- Not export
        # VerbatimOmanEtAl ---- Not export
        # FLOW-ID
        # DelphacidaeID
        # Key3C ---- Not export
        # Key3D ---- Not export

        path = @args[:data_directory] + 'literature.txt'
        print "\nHandling references\n"
        raise "file #{path} not found" if not File.exists?(path)
        file = CSV.foreach(path, col_sep: "\t", headers: true)
        language = %w(French Russian German Japanese Chinese English Korean Polish Italian Georgian )

        file.each_with_index do |row, i|
          if i < 100000 ######################
          print "\r#{i}"
          journal, serial_id, volume, pages = parse_bibliography_3i(row['Bibliography'])
          year, year_suffix = parse_year_3i(row['Year'])
          taxonomy, distribution, illustration, typhlocybinae = nil, nil, nil, nil
          note = row['Notes']
            source = Source::Bibtex.new( author: row['AuthorDrMetcalf'].blank? ? row['Author'] : row['AuthorDrMetcalf'],
                                         year: year,
                                         year_suffix: year_suffix,
                                         title: row['Title'],
                                         journal: journal,
                                         serial_id: serial_id,
                                         pages: pages,
                                         volume: volume,
                                         bibtex_type: 'article'
            )

          source.alternate_values.new(value: row['Author'], type: 'AlternateValue::Abbreviation', alternate_value_object_attribute: 'author') if !row['AuthorDrMetcalf'].blank? && row['AuthorDrMetcalf'] != row['Author']

          InternalAttribute.new(attribute_subject: source, predicate: @data.keywords['CallNumberDrMetcalf'], value: row['CallNumberDrMetcalf']) unless row['CallNumberDrMetcalf'].blank?

          source.data_attributes.new(type: 'ImportAttribute', import_predicate: 'Author3i', value: row['AY']) unless row['AY'].blank?
          source.data_attributes.new(type: 'ImportAttribute', import_predicate: 'YearReference', value: row['Year']) unless row['Year'].blank?
          source.data_attributes.new(type: 'ImportAttribute', import_predicate: 'BibliographyReference', value: row['Bibliography']) unless row['Bibliography'].blank?

          if !note.blank? && note.include?('Taxonomy only and distribution')
            source.tags.new(keyword: @data.keywords['Distribution'])
            note.gsub!(' and distribution', '')
          end
          if !note.blank? && note.include?('Taxonomy only')
            source.tags.new(keyword: @data.keywords['Taxonomy'])
            note.gsub!('Taxonomy only', '')
          end
          if !note.blank? && note.index('T ') == 0
            source.tags.new(keyword: @data.keywords['Typhlocybinae'])
            note = note[2..-1]
          end
          if !note.blank? && note.include?('Illustrations done')
            source.tags.new(keyword: @data.keywords['Illustrations'])
            note.gsub!('Illustrations done', '')
          end
          note.squish! unless note.nil?


          source.notes.new(text: row['NotesDrMetcalf']) unless row['NotesDrMetcalf'].blank?
          source.notes.new(text: note) unless note.blank?

          language.each do |l|
            if (row['Notes'].to_s + ' ' + row['Bibliography'].to_s).include?('In ' + l)
              source.language_id = Language.where(english_name: l).limit(1).pluck(:id).first
            end
          end

          source.identifiers.new(type: 'Identifier::Local::Import', namespace: @data.keywords['IDDrMetcalf'], identifier: row['IDDrMetcalf']) unless row['IDDrMetcalf'].blank?
          source.identifiers.new(type: 'Identifier::Local::Import', namespace: @data.keywords['Key3'], identifier: row['Key3']) unless row['Key3'].blank?
          source.identifiers.new(type: 'Identifier::Local::Import', namespace: @data.keywords['FLOW-ID'], identifier: row['FLOW-ID']) if !row['FLOW-ID'].blank? && !row['FLOW-ID'] == '0'
          source.identifiers.new(type: 'Identifier::Local::Import', namespace: @data.keywords['DelphacidaeID'], identifier: row['DelphacidaeID']) if !row['DelphacidaeID'].blank? && !row['DelphacidaeID'] == '0'


          if source.valid?
            source.save!
            source.project_sources.create!
            @data.publications_index.merge!(row['Key3'] => source.id)
          else
            byebug
          end
          end #########################################################
        end

        puts "\nResolved #{@data.publications_index.keys.count} publications\n"

      end

      def parse_bibliography_3i(bibl)
        return nil, nil, nil, nil if bibl.blank?

        matchdata = bibl.match(/(^.+)\s+(\d+\(.+\)|\d+): *(\d+-\d+|\d+–\d+|\d+)\.*\s*(.*$)/)
        return bibl, nil, nil, nil if matchdata.nil?

        serial_id = Serial.where(name: matchdata[1]).limit(1).pluck(:id).first
        serial_id ||= Serial.with_any_value_for(:name, matchdata[1]).limit(1).pluck(:id).first
        #serial_id = serial.nil? ? nil : serial.id
        journal = matchdata[4].blank? ? matchdata[1] : bibl
        volume = matchdata[2]
        pages = matchdata[3]
        return journal, serial_id, volume, pages
      end

      def parse_year_3i(year)
        return nil, nil if year.blank?
        matchdata = year.match(/(\d\d\d\d)(.*)/)
        return nil.nil if matchdata.nil?
        return matchdata[1], matchdata[2]
      end

      def handle_nouns_3i
        path = @args[:data_directory] + 'unchangednames.txt'
        print "\nUnchanging names\n"
        raise "file #{path} not found" if not File.exists?(path)
        file = CSV.foreach(path, col_sep: "\t", headers: true)

        #speciesname

        file.each_with_index do |row, i|
          @data.nouns.merge!(row['speciesname'] => true)
        end

      end

      def handle_taxonomy_3i

        handle_nouns_3i


        # Key !
        # Key3 !
        # Name !
        # Author !
        # Year !
        # YearRem !
        # Page !
        # Rank !
        # Status
        # Parent !
        # nameM !
        # nameF !
        # nameN !
        # is_fossil !
        # Gender !
        # Remarks !
        # DescriptEn !
        # PageAuthor !
        # TypeDepository !
        # Ethymology !

        # OrigGen
        # OrigSubGen
        # OriginalSpecies
        # OriginalSubSpecies
        # TypeDesignation
        # Type
        # Homonym
        # MisspellingOf
        # CombinationOf
        # OriginalCombinationOf
        # NomenNovumFor
        # CommonNameLang
        # MisapplicationFor


        gender = {'M' => 'TaxonNameClassification::Latinized::Gender::Masculine',
                  'F' => 'TaxonNameClassification::Latinized::Gender::Feminine',
                  'N' => 'TaxonNameClassification::Latinized::Gender::Neuter',
                  'm' => 'TaxonNameClassification::Latinized::Gender::Masculine',
                  'f' => 'TaxonNameClassification::Latinized::Gender::Feminine',
                  'n' => 'TaxonNameClassification::Latinized::Gender::Neuter' }.freeze

        synonym_statuses = %w(1 6 8 10 11 14 17 22 23 24 26 27 28 29)

          path = @args[:data_directory] + 'taxon.txt'
          print "\nHandling taxonomy\n"
          raise "file #{path} not found" if not File.exists?(path)
          file = CSV.foreach(path, col_sep: "\t", headers: true)


          file.each_with_index do |row, i|
            if i < 200000
            print "\r#{i}"
            if row['Name'] == 'Incertae sedis' || row['Name'] == 'Unplaced'
              @data.incertae_sedis.merge!(row['Key'] => @data.taxon_index[row['Parent']])
            elsif row['Status'] == '7' ### common name
            elsif row['Status'] == '8' && !find_taxon(row['Parent']).try(:rank_class).to_s.include?('Family') ### combination
            elsif row['Status'] == '2'
              @data.original_combination.merge!(row['OriginalCombinationOf'] => row)
            elsif row['Status'] == '16'
              rank = @ranks[row['Rank'].to_i]
              otu = Otu.create!(name: 'Genus ' + row['Name']) if rank.to_s.include?('Genus')
              otu = Otu.create!(name: ('Species ' + @data.taxon_index[row['Parent']].try(:name).to_s + ' ' + row['Name']).squish) if rank.to_s.include?('Species')
              otu.identifiers.create!(type: 'Identifier::Local::Import', namespace: @data.keywords['Key'], identifier: row['Key'])
            elsif row['Status'] == '18'
              taxon = find_taxon(row['Parent'])
              taxon.data_attributes.new(type: 'InternalAttribute', controlled_vocabulary_term_id: @data.keywords['Typification'].id, value: ('Type designation: ' + row['Author'].to_s + ', ' + row['Year'].to_s + row['YearRem'].to_s).squish)
              taxon.valid? ? taxon.save! : byebug
            elsif row['Status'] == '19'
              taxon = find_taxon(row['Parent'])
              taxon.data_attributes.new(type: 'InternalAttribute', controlled_vocabulary_term_id: @data.keywords['Typification'].id, value: ('Neotype designation: ' + row['Author'].to_s + ', ' + row['Year'].to_s + row['YearRem'].to_s).squish)
              taxon.valid? ? taxon.save! : byebug
            elsif row['Status'] == '20'
              taxon = find_taxon(row['Parent'])
              taxon.data_attributes.new(type: 'InternalAttribute', controlled_vocabulary_term_id: @data.keywords['Typification'].id, value: ('Lectotype designation: ' + row['Author'].to_s + ', ' + row['Year'].to_s + row['YearRem'].to_s).squish)
              taxon.valid? ? taxon.save! : byebug
            elsif row['Status'] == '25'  && !find_taxon(row['Parent']).rank_class.to_s.include?('Family') # emendation
              taxon = find_taxon(row['Parent'])
              taxon.data_attributes.new(type: 'InternalAttribute', controlled_vocabulary_term_id: @data.keywords['FirstRevisor'].id, value: (row['Name'] + ' ' + row['Author'].to_s + ', ' + row['Year'].to_s + row['YearRem'].to_s).squish)
              taxon.valid? ? taxon.save! : byebug
              @data.emendation.merge!(row['Parent'] => row)
            else
              name = row['Name'].split(' ').last
              vname = row['Name'].split(' ').last
              #parent = row['Parent'].blank? ? @root : Protonym.with_identifier('3i_Taxon_ID ' + row['Parent']).find_by(project_id: $project_id)
              parent = row['Parent'].blank? ? @root : @data.incertae_sedis[row['Parent']] ? TaxonName.find(@data.incertae_sedis[row['Parent']]) : find_taxon(row['Parent'])

              if row['Rank'] == '0'
                rank = parent.rank_class
                if rank.parent.to_s == 'NomenclaturalRank::Iczn::FamilyGroup'
                  alternative_name = Protonym.family_group_name_at_rank(name, rank.rank_name)
                  if name != alternative_name
                    name = alternative_name
                    vname = row['Name']
                  end
                end
              else
                rank = @ranks[row['Rank'].to_i]
              end
              if !row['OriginalSpecies'].blank? && row['Rank'] == '2'
                parent = find_taxon(row['OriginalSpecies'])
                rank = @ranks[1]
              end
              byebug if row['Rank'].blank?

              #rank = row['Rank'] == '0' ? parent.rank_class : @ranks[row['Rank'].to_i]
              source = row['Key3'].blank? ? nil : @data.publications_index[row['Key3']] # Source.with_identifier('3i_Source_ID ' + row['Key3']).first
              if row['Rank'] == '0'
                byebug if parent.parent.nil?
                parent = parent.parent
              end

              taxon = Protonym.new( name: name,
                                    parent: parent,
                                    origin_citation_attributes: {source_id: source, pages: row['Page']},
                                    year_of_publication: row['Year'],
                                    verbatim_author: row['Author'],
                                    rank_class: rank,
                                    masculine_name: row['nameM'],
                                    feminine_name: row['nameF'],
                                    neuter_name: row['nameN'],
                                    verbatim_name: vname,
                                    also_create_otu: true
                                    #no_cached: true,
              )

#              taxon.citations.new(source_id: source, pages: row['Page'], is_original: true) unless source.blank?
              taxon.identifiers.new(type: 'Identifier::Local::Import', namespace: @data.keywords['Key'], identifier: row['Key'])
              taxon.notes.new(text: row['Remarks']) unless row['Remarks'].blank?
              taxon.data_attributes.new(type: 'InternalAttribute', controlled_vocabulary_term_id: @data.keywords['Ethymology'].id, value: row['Ethymology']) unless row['Ethymology'].blank?
              taxon.data_attributes.new(type: 'InternalAttribute', controlled_vocabulary_term_id: @data.keywords['TypeDepository'].id, value: row['TypeDepository']) unless row['TypeDepository'].blank?
              taxon.data_attributes.new(type: 'InternalAttribute', controlled_vocabulary_term_id: @data.keywords['YearRem'].id, value: row['YearRem']) unless row['YearRem'].blank?
              taxon.data_attributes.new(type: 'InternalAttribute', controlled_vocabulary_term_id: @data.keywords['PageAuthor'].id, value: row['PageAuthor']) unless row['PageAuthor'].blank?

              if !row['DescriptEn'].blank? && row['DescriptEn'].include?('<h2>Similar species</h2>')
                taxon.data_attributes.new(type: 'InternalAttribute', controlled_vocabulary_term_id: @data.keywords['SimilarSpecies'].id, value: row['DescriptEn'].gsub('<h2>Similar species</h2>', '').squish)
              end

              taxon.taxon_name_classifications.new(type: gender[row['Gender']]) unless row['Gender'].blank?

              if taxon.rank_string =~ /Species/
                if @data.nouns[row['Name']]
                  taxon.taxon_name_classifications.new(type: 'TaxonNameClassification::Latinized::PartOfSpeech::NounInApposition')
                elsif row['Name'].ends_with?('i') || row['Name'].ends_with?('ae') || row['Name'].ends_with?('arum') || row['Name'].ends_with?('orum')
                  taxon.taxon_name_classifications.new(type: 'TaxonNameClassification::Latinized::PartOfSpeech::NounInGenitiveCase')
                elsif !row['nameM'].blank?
                  taxon.taxon_name_classifications.new(type: 'TaxonNameClassification::Latinized::PartOfSpeech::Adjective')
                end
              end

              taxon.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::Fossil') if row['is_fossil'] == '1'
              byebug if row['Status'].blank?
              taxon.taxon_name_classifications.new(type: @classification_classes[row['Status'].to_i]) unless @classification_classes[row['Status'].to_i].blank?

              taxon.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::Available::OfficialListOfFamilyGroupNamesInZoology') if row['YearRem'].to_s.include?('Official List of Family-Group Names in Zoology')
              taxon.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::Available::OfficialListOfGenericNamesInZoology') if row['YearRem'].to_s.include?('Official List of Generic Names in Zoology')
              taxon.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::Available::OfficialListOfSpecificNamesInZoology') if row['YearRem'].to_s.include?('Official List of Specific Names in Zoology')
              t3 = taxon.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::Unavailable::Suppressed::OfficialIndexOfRejectedFamilyGroupNamesInZoology') if row['YearRem'].to_s.include?('Official Index of Rejected and Invalid Family-Group Names in Zoology')
              t1 = taxon.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::Unavailable::Suppressed::OfficialIndexOfRejectedGenericNamesInZoology') if row['YearRem'].to_s.include?('Official Index of Rejected and Invalid Generic Names in Zoology')
              t2 = taxon.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::Unavailable::Suppressed::OfficialIndexOfRejectedSpecificNamesInZoology') if row['YearRem'].to_s.include?('Official Index of Rejected and Invalid Specific Names in Zoology')
              taxon.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::Unavailable::LessThanTwoLetters') if name.length == 1

              taxon.iczn_uncertain_placement = TaxonName.find(@data.incertae_sedis[row['Parent']]) if @data.incertae_sedis[row['Parent']]
              taxon.original_variety = taxon if row['Name'].include?(' var. ')
              taxon.original_form = taxon if row['Name'].include?(' f. ')

              if taxon.valid?
                taxon.save!
                @data.taxon_index.merge!(row['Key'] => taxon.id)
              else
                taxon.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::Unavailable::NotLatin') if taxon.rank_string =~ /Family/ && row['Status'] != '0' && !taxon.errors.messages[:name].blank?
                taxon.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::Unavailable::NotLatin') if taxon.rank_string =~ /Species/ && row['Status'] != '0' && taxon.errors.full_messages.include?('Name name must be lower case')
                taxon.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::Unavailable::NotLatin') if taxon.rank_string =~ /Species/ && row['Status'] != '0' && taxon.errors.full_messages.include?('Name Name must be latinized, no digits or spaces allowed')
                taxon.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::Unavailable::NotLatin') if taxon.rank_string =~ /Genus/ && row['Status'] != '0' && taxon.errors.full_messages.include?('Name Name must be latinized, no digits or spaces allowed')

                if taxon.valid?
                  taxon.save!
                  @data.taxon_index.merge!(row['Key'] => taxon.id)
                else
                  print "\n#{row['Key']}         #{row['Name']}"
                  print "\n#{taxon.errors.full_messages}\n"
                  #byebug
                end
                if !row['DescriptEn'].blank? && (row['DescriptEn'].include?('<h2>Notes</h2>') || row['DescriptEn'].include?('<h2>Remarks</h2>'))
                  taxon.otus.first.contents.new(topic_id: @data.keywords['Notes'], text: row['DescriptEn'].gsub('<h2>Notes</h2>').gsub('<h2>Remarks</h2>').squish)
                end

              end

            end

            end ############################
          end
      end

      def handle_taxon_name_relationships_3i
        path = @args[:data_directory] + 'taxon.txt'
        print "\nHandling taxon name relationships\n"
        raise "file #{path} not found" if not File.exists?(path)
        file = CSV.foreach(path, col_sep: "\t", headers: true)

        synonym_statuses = %w(1 6 8 10 11 14 17 22 23 24 26 27 28 29).freeze

        Combination.tap{}

        file.each_with_index do |row, i|
         # if i == 299
         #   byebug
         #   i = 299
         #   print "######################################################################"


         # end

          if i < 2000000 #######################################
            print "\r#{i} (Relationships)"
            taxon = nil
            taxon = find_taxon(row['Key'])

            if !taxon.nil? ### original combinations, synonyms, types
              taxon.original_genus = find_taxon(row['OrigGen']) unless row['OrigGen'].blank?
              taxon.original_species = find_taxon(row['OriginalSpecies']) unless row['OriginalSpecies'].blank?
              taxon.original_subspecies = find_taxon(row['OriginalSubSpecies']) unless row['OriginalSubSpecies'].blank?
              taxon.original_variety = taxon if row['Name'].include?(' var. ')
              taxon.original_form = taxon if row['Name'].include?(' f. ')
              if taxon.rank_string =~ /Genus/
                taxon.original_genus.nil? ? taxon.original_genus = taxon : taxon.original_subgenus = taxon
              elsif taxon.rank_string =~ /Species/
                if taxon.original_species.nil?
                  taxon.original_species = taxon
                elsif taxon.original_subspecies.nil? && taxon.original_variety.nil? && taxon.original_form.nil?
                  taxon.original_subspecies = taxon
                elsif taxon.original_variety.nil?
                  taxon.original_variety = taxon
                end
              end

              if taxon.rank_string =~ /Genus/ && !row['Type'].blank?
                case row['TypeDesignation']
                  when 'original monotypy'
                    taxon.type_species_by_original_monotypy = find_taxon(row['Type'])
                  when 'monotypy'
                    taxon.type_species_by_monotypy = find_taxon(row['Type'])
                  when 'subsequent monotypy'
                    taxon.type_species_by_subsequent_monotypy = find_taxon(row['Type'])
                  when 'original designation'
                    taxon.type_species_by_original_designation = find_taxon(row['Type'])
                  when 'subsequent designation'
                    taxon.type_species_by_subsequent_designation = find_taxon(row['Type'])
                  when 'ruling by commission'
                    taxon.type_species_by_ruling_by_Commission = find_taxon(row['Type'])
                  else
                    taxon.type_species = find_taxon(row['Type'])
                end
              end
              taxon.type_genus = find_taxon(row['Type']) if taxon.rank_string =~ /Family/ && !row['Type'].blank?
              taxon.iczn_set_as_primary_homonym_of = find_taxon(row['Homonym']) if !row['Homonym'].blank? && row['Status'] == '3'
              taxon.iczn_set_as_secondary_homonym_of = find_taxon(row['Homonym']) if !row['Homonym'].blank? && row['Status'] == '4'
              taxon.iczn_set_as_homonym_of = find_taxon(row['Homonym']) if !row['Homonym'].blank? && row['Status'] == '5'
              taxon.iczn_set_as_replacement_name_of = find_taxon(row['NomenNovumFor']) if !row['NomenNovumFor'].blank?
              taxon.iczn_set_as_misspelling_of = find_taxon(row['MisspellingOf']) if !row['MisspellingOf'].blank?
              taxon.iczn_set_as_misspelling_of = find_taxon(row['Parent']) if row['MisspellingOf'].blank? && row['Status'] == '9'
              taxon.iczn_set_as_incorrect_original_spelling_of = find_taxon(row['OriginalCombinationOf']) if !row['OriginalCombinationOf'].blank? && row['Status'] == '9'
              taxon.iczn_set_as_misapplication_of = find_taxon(row['MisapplicationFor']) if !row['MisapplicationFor'].blank? && row['Status'] == '11'
              #taxon.iczn_first_revisor_action = @data.taxon_index[row['Parent']] if !row['OriginalCombinationOf'].blank? && row['Status'] == '9'

              source = nil
              if !@data.emendation[row['Parent']].blank? && row['OriginalCombinationOf'] == row['Parent']
                source = find_taxon(@data.emendation[row['Parent']]).try(['Key3']).nil? ? nil : @data.publications_index[@data.emendation[row['Parent']]['Key3']] unless @data.emendation[row['Parent']].nil?
                tnr = TaxonNameRelationship::Iczn::PotentiallyValidating::FirstRevisorAction.create(object_taxon_name: find_taxon(@data.emendation[row['Parent']]['Parent']), subject_taxon_name: taxon, origin_citation_attributes: {source_id: source}) if !@data.emendation[row['Parent']].blank? && row['OriginalCombinationOf'] == row['Parent']
                byebug unless tnr.valid?
              end

              if taxon.valid?
                taxon.save!
              else
                byebug
              end

              if synonym_statuses.include?(row['Status']) # %w(1 6 8 10 11 14 17 22 23 24 26 27 28 29)
                tnr = TaxonNameRelationship.create(subject_taxon_name: taxon, object_taxon_name: find_taxon(row['Parent']), type: @relationship_classes[row['Status'].to_i])
                byebug unless tnr.valid?
              end

            elsif row['Status'] == '8' || row['Status'] == '25' ### taxon name combinations
              taxon = find_taxon(row['CombinationOf']) || find_taxon(row['Parent'])

              source = row['Key3'].blank? ? nil : @data.publications_index[row['Key3']]
              c = Combination.new(origin_citation_attributes: {source_id: source, pages: row['Page']}, verbatim_author: row['Author'], year_of_publication: row['Year'])
              c.identifiers.new(type: 'Identifier::Local::Import', namespace: @data.keywords['Key'], identifier: row['Key'])

              origgen = row['OrigGen'].blank? ? nil : find_taxon(row['OrigGen'])
              origsubgen = row['OrigSubGen'].blank? ? nil : find_taxon(row['OrigSubGen'])
              origspecies = row['OriginalSpecies'].blank? ? nil : find_taxon(row['OriginalSpecies'])
              origsubspecies = row['OriginalSubSpecies'].blank? ? nil : find_taxon(row['OriginalSubSpecies'])

              #  c.citations.new(source_id: source, pages: row['Page']) unless source.blank?
              c.genus = origgen unless origgen.blank?
              gender = c.genus.gender_name unless c.genus.blank?
              c.subgenus = origsubgen unless origsubgen.blank?
              c.species = origspecies unless origspecies.blank?
              c.subspecies = origsubspecies unless origsubspecies.blank?
              c.variety = taxon if row['Name'].include?(' var. ')
              c.form = taxon if row['Name'].include?(' f. ')
              c.parent = origgen.blank? ? find_taxon(row['Parent']).parent : origgen.parent
              if taxon.rank_string =~ /Genus/
                c.genus.nil? ? c.genus = taxon : c.subgenus = taxon
              elsif taxon.rank_string =~ /Species/
                if c.species.nil?
                  c.species = taxon
                elsif c.subspecies.nil? && c.variety.nil? && c.form.nil?
                  c.subspecies = taxon
                elsif c.variety.nil?
                  c.variety = taxon
                end
              elsif taxon.rank_string =~ /Family/
                tnr = TaxonNameRelationship.create(subject_taxon_name: taxon, object_taxon_name: find_taxon(row['Parent']), type: 'TaxonNameRelationship::Iczn::Invalidating::Usage::FamilyGroupNameForm')
                byebug unless tnr.valid?
              end
              c.data_attributes.new(type: 'InternalAttribute', controlled_vocabulary_term_id: @data.keywords['YearRem'].id, value: row['YearRem']) unless row['YearRem'].blank?

              i3_combination = ''
              i3_combination = origgen.name_with_misspelling(gender).to_s + ' ' unless origgen.blank?
              i3_combination += '(' + origsubgen.name_with_misspelling(gender).to_s + ') ' unless origsubgen.blank?
              i3_combination += row['Name'].to_s
              i3_combination.squish!


              if c.valid?
                c.save!
                if !i3_combination.blank? && i3_combination != c.cached
                  #c.data_attributes.create(type: 'ImportAttribute', import_predicate: 'combination_in_3i', value: i3_combination)
                  #c.data_attributes.create(type: 'ImportAttribute', import_predicate: 'name_in_3i', value: row['Name'])
                  c.verbatim_name = i3_combination

                  c.valid? ? c.save! : byebug
                end
              else
                print "\n#{row['Key']}         #{row['Name']}"
                print "\n#{c.errors.full_messages}\n"
                #byebug
              end

            elsif row['Status'] == '7' #  common name
              lng = Language.find_by_alpha_3_bibliographic(@languages[row['CommonNameLang'].to_s.downcase])
              CommonName.create!(otu: find_taxon(row['Parent']).otus.first, name: row['Name'], language: lng)
            elsif row['Status'] == '2' || !row['OriginalCombinationOf'].blank? ### Original combination
              taxon = find_taxon(row['OriginalCombinationOf']) || find_taxon(row['Parent'])
              if taxon.blank?
                byebug
              else
                taxonid = taxon.id
              end
              taxon.verbatim_name = row['Name'].split(' ').last
              taxon.original_species_relationship.destroy unless taxon.original_species_relationship.blank?
              taxon.original_subspecies_relationship.destroy unless taxon.original_subspecies_relationship.blank?
              taxon.original_variety_relationship.destroy unless taxon.original_variety_relationship.blank?
              taxon.original_form_relationship.destroy unless taxon.original_form_relationship.blank?

              taxon = TaxonName.find(taxonid)
              taxon.original_species = find_taxon(row['OriginalSpecies']) unless row['OriginalSpecies'].blank?
              taxon.original_subspecies = find_taxon(row['OrigOriginalSubSpecies']) unless row['OriginalSubSpecies'].blank?
              taxon.original_variety = taxon if row['Name'].include?(' var. ')
              taxon.original_form = taxon if row['Name'].include?(' f. ')
              if taxon.rank_string =~ /Species/
                if taxon.original_species.nil?
                  taxon.original_species = taxon
                elsif taxon.original_subspecies.nil? && taxon.original_variety.nil? && taxon.original_form.nil?
                  taxon.original_subspecies = taxon
                elsif taxon.original_variety.nil?
                  taxon.original_variety = taxon
                end
              end
              if taxon.valid?
                taxon.save!
              else
                byebug
              end


            end

          end ###################

        end
      end

      def handle_host_plant_name_dictionary_3i
        #CommonName
        # HostPlant
        # Phylum
        # Class
        # Order
        # Family
        # Genus
        # Subgenus
        # Species
        # Variety
        # Author
        # Lng
        # New

        plantae = Protonym.find_or_create_by!(name: 'Plantae', rank_class: Ranks.lookup(:icn, 'kingdom'), parent: @root, project_id: $project_id)


        path = @args[:data_directory] + 'hostplants.txt'
        print "\nHandling host plant name dictionary\n"
        raise "file #{path} not found" if not File.exists?(path)
        file = CSV.foreach(path, col_sep: "\t", headers: true)

        file.each_with_index do |row, i|
          print "\r#{i}"
          tmp = {}
          %w(Phylum Class Order Family Genus Subgenus Species Variety).each do |c|
            tmp.merge!(c => row[c]) unless row[c].blank?
          end

          otu = @data.unique_host_plant_index[tmp]

          parent = plantae

          if otu.nil?
            author = row['Author']
            unless row['Phylum'].blank?
              plant = Protonym.find_or_create_by!(name: row['Phylum'], rank_class: Ranks.lookup(:icn, 'phylum'), parent: parent, project_id: $project_id)
              parent = plant
            end
            unless row['Class'].blank?
              plant = Protonym.find_or_create_by!(name: row['Class'], rank_class: Ranks.lookup(:icn, 'class'), parent: parent, project_id: $project_id)
              parent = plant
            end
            unless row['Order'].blank?
              plant = Protonym.find_or_create_by!(name: row['Order'], rank_class: Ranks.lookup(:icn, 'order'), parent: parent, project_id: $project_id)
              parent = plant
            end
            unless row['Family'].blank?
              plant = Protonym.find_or_create_by!(name: row['Family'], rank_class: Ranks.lookup(:icn, 'family'), parent: parent, project_id: $project_id)
              parent = plant
              otu = Otu.find_or_create_by!(taxon_name_id: plant.id, project_id: $project_id).id
              @data.host_plant_index.merge!(row['Family'] => otu)
            end
            unless row['Genus'].blank?
              plant = Protonym.find_or_create_by!(name: row['Genus'], rank_class: Ranks.lookup(:icn, 'genus'), parent: parent, project_id: $project_id)
              parent = plant
            end
            unless row['Subgenus'].blank?
              plant = Protonym.find_or_create_by!(name: row['Subgenus'], rank_class: Ranks.lookup(:icn, 'subgenus'), parent: parent, project_id: $project_id)
              parent = plant
            end
            unless row['Species'].blank?
              name = row['Species'].gsub('x ', '')
              if row['Variety'].blank? && !author.blank?
                plant = Protonym.find_or_create_by!(name: name, rank_class: Ranks.lookup(:icn, 'species'), verbatim_author: author, parent: parent, project_id: $project_id)
              else
                plant = Protonym.find_or_create_by!(name: name, rank_class: Ranks.lookup(:icn, 'species'), parent: parent, project_id: $project_id)
              end
              plant.taxon_name_classifications.create(type: 'TaxonNameClassification::Icn::Hybrid') if name != row['Species']
              parent = plant
            end
            unless row['Variety'].blank?
              plant = Protonym.find_or_create_by!(name: row['Variety'], rank_class: Ranks.lookup(:icn, 'variety'), verbatim_author: author, parent: parent, project_id: $project_id)
            end
            otu = Otu.find_or_create_by!(taxon_name_id: plant.id, project_id: $project_id).id
            @data.unique_host_plant_index.merge!(tmp => otu)
          end

          unless row['CommonName'].blank?
            lng = Language.find_by_alpha_3_bibliographic(@languages[row['lng'].to_s.downcase])
            c = CommonName.new(otu_id: otu, name: row['CommonName'], language: lng)
            if c.valid?
              c.save
            else
              byebug
            end
          end

          @data.host_plant_index.merge!(row['HostPlant'] => otu)
          @data.host_plant_index.merge!(row['CommonName'] => otu) unless row['CommonName'].blank?

        end
      end

      def handle_host_plants_3i
        # Key
        # Family
        # Name
        # CommonName
        # Key3
        path = @args[:data_directory] + 'hosts.txt'
        print "\nHandling host plants\n"
        raise "file #{path} not found" if not File.exists?(path)
        file = CSV.foreach(path, col_sep: "\t", headers: true)

        file.each_with_index do |row, i|
          print "\r#{i}"

          object = find_otu(row['Key'])
          subject = nil
          subject = @data.host_plant_index[row['Name']] unless row['Name'].nil?
          subject = @data.host_plant_index[row['CommonName']] if subject.nil? && !row['CommonName'].blank?
          subject = @data.host_plant_index[row['Family']] if subject.nil? && !row['Family'].blank?

          if !subject.nil?
            subject = Otu.find(subject)
          elsif !row['Name'].blank?
            subject = Otu.find_or_create_by!(name: row['Name'], project_id: $project_id)
          elsif !row['CommonName'].blank?
            subject = Otu.find_or_create_by!(name: row['CommonName'], project_id: $project_id)
          elsif !row['Family'].blank?
            print "\n#{row['Family']} does not exists\n"
          end

          s = find_publication_id(row['Key3'])

          if subject && object
            ba = BiologicalAssociation.find_or_create_by!(biological_relationship: @host_plant_relationship,
                                          biological_association_subject: subject,
                                          biological_association_object: object,
                                          project_id: $project_id
            )
            Citation.find_or_create_by!(citation_object: ba, source_id: s, project_id: $project_id) unless s.blank?
          else
            print "\nRow #{row} is problematic\n"
          end

        end

      end

      def handle_citation_topics_3i
        # Key3
        # Key
        # Descriptions
        # Records
        # Pictures
        # Types
        # Keys
        # Synonymy
        # Host
        # HostPlant
        # Notes
        # size
        
        path = @args[:data_directory] + 'littable.txt'
        print "\nHandling citation topics\n"
        raise "file #{path} not found" if not File.exists?(path)
        file = CSV.foreach(path, col_sep: "\t", headers: true)

        file.each_with_index do |row, i|
          print "\r#{i}"

          p = find_taxon(row['Key'])
          if p.nil?
            print "\nProblematic Key: #{row['Key']}\n"
          else
            source = find_publication_id(row['Key3'])

            byebug if p.nil?
            c = p.citations.find_or_create_by!(source_id: source, project_id: $project_id)

            c.citation_topics.find_or_create_by(topic: @data.topics['Descriptions'], project_id: $project_id) if row['Descriptions'] == '1' && row['Types'] == '0'
            c.citation_topics.find_or_create_by(topic: @data.topics['Types'], project_id: $project_id) if row['Descriptions'] == '1' && row['Types'] == '1'
            c.citation_topics.find_or_create_by(topic: @data.topics['Records'], project_id: $project_id) if row['Records'] == '1'
            c.citation_topics.find_or_create_by(topic: @data.topics['Pictures'], project_id: $project_id) if row['Pictures'] == '1'
            c.citation_topics.find_or_create_by(topic: @data.topics['Keys'], project_id: $project_id) if row['Keys'] == '1'
            c.citation_topics.find_or_create_by(topic: @data.topics['Synonymy'], project_id: $project_id) if row['Synonymy'] == '1'
            c.citation_topics.find_or_create_by(topic: @data.topics['Host'], project_id: $project_id) if row['Host'] == '1'

            if c.valid?
              c.save!
            else
              byebug
            end
            if row['Synonymy'] == '1'
              tr = p.taxon_name_relationships.with_type_array(TAXON_NAME_RELATIONSHIP_NAMES_INVALID).first
              unless tr.nil?
                cit = tr.citations.find_or_create_by!(source_id: source, project_id: $project_id)
                if row['Descriptions'] == '1'
                  cit.is_original = true
                  cit.save!
                end
              end
            end
          end
        end
      end

      def handle_distribution_3i
        handle_countries_3i

        # Key
        # Key6
        # Key3

        path = @args[:data_directory] + 'countrytable.txt'
        print "\nHandling distribution\n"
        raise "file #{path} not found" if not File.exists?(path)
        file = CSV.foreach(path, col_sep: "\t", headers: true)

        file.each_with_index do |row, i|
          print "\r#{i}"
          otu = find_otu(row['Key'])
          source = find_publication_id(row['Key3'])
          country = @data.countries[row['Key6']]
          erroneously, introduced = nil, false
          unless country.nil?
            ga = country['TW_id'].nil? ? nil : GeographicArea.find(country['TW_id'])
            erroneously = country['Country'].include?('erroneously') ? true : nil
            introduced = country['Country'].include?('introduced')
          end
          print "\nGeographic area not found for Key6 = #{row['Key6']}\n" if !country.nil? && !country['TW_id'].nil? && ga.nil?
          print "\nGeographic area does not match Country = #{country['TW_name']}; GeographicArea = #{ga.name}\n" if !ga.nil? && ga.name != country['TW_name']

          if !otu.nil? && !source.nil? && !ga.nil?
            ad = AssertedDistribution.find_or_create_by!(
                                    otu: otu,
                                    geographic_area: ga,
                                    source_id: source,
                                    is_absent: erroneously,
                                    project_id: $project_id )

            ad.tags.find_or_create_by!(keyword: @data.keywords['introduced']) if introduced
          end


        end
      end

      def handle_countries_3i
        #Key6
        # Count
        # Country
        # LongCentr
        # LatCentr
        # CountryCode
        # Realm
        # TW_name
        # TW_id
        # used
        path = @args[:data_directory] + 'countries.txt'
        print "\nHandling list of countries\n"
        raise "file #{path} not found" if not File.exists?(path)
        file = CSV.foreach(path, col_sep: "\t", headers: true)

        file.each_with_index do |row, i|
          print "\r#{i}"
          @data.countries.merge!(row['Key6'] => row)
        end
      end

      def handle_museums_3i
        #Abbreviation
        # Museum
        # Country
        # Location
        # Http
        # TW_acronim

        path = @args[:data_directory] + 'museums.txt'
        print "\nHandling list of museums\n"
        raise "file #{path} not found" if not File.exists?(path)
        file = CSV.foreach(path, col_sep: "\t", headers: true)

        file.each_with_index do |row, i|
          print "\r#{i}"
          @data.museums.merge!(row['abbreviation'] => row['TW_acronim']) unless row['TW_acronim'].blank?
        end
      end


      def handle_localities_3i
        handle_museums_3i

        # Key4
        # Key
        # Country !
        # State !
        # County !
        # GLocality !
        # SLocality !
        # Date !
        # DateTo !
        # Collectors !
        # HostFamily
        # HostPlant
        # HostCommonName
        # Method !
        # LatNS !
        # LatDeg !
        # LatMin !
        # LatSec !
        # LongEW !
        # LongDeg !
        # LongMin !
        # LongSec !
        # ElevationM !
        # ElevationF !
        # Ecology !
        # Specimens
        # Males
        # Females
        # Nymphs
        # Type
        # Notes
        # Museum
        # ID
        # Precision !
        # Key3
        # Dissected
        # TW_id !

        path = @args[:data_directory] + 'localities.txt'
        print "\nHandling localities\n"
        raise "file #{path} not found" if not File.exists?(path)
        file = CSV.foreach(path, col_sep: "\t", headers: true)
        preparation_type = @data.keywords['Pin']
        count_fields = %w{ Specimens Males Females Nymphs }.freeze

        file.each_with_index do |row, i|
          if i > 30000 #######################
          print "\r#{i}"

          collecting_event = find_or_create_collecting_event_3i(row)
          repository = Repository.find_by_acronym(@data.museums[row['Museum']]) unless @data.museums[row['Museum']].blank?
          source = find_publication_id(row['Key3'])

          no_specimens = false
          if count_fields.collect{ |f| row[f] }.select{ |n| !n.nil? }.empty?
            row['Specimens'] = '1'
            no_specimens = true
          end

          objects = []
          count_fields.each do |count|
            unless row[count].blank?
              specimen = CollectionObject::BiologicalCollectionObject.new(
                  total: row[count],
                  preparation_type: preparation_type,
                  repository: repository,
                  buffered_collecting_event: nil,
                  buffered_determinations: nil,
                  buffered_other_labels: nil,
                  collecting_event: collecting_event
              )
              if specimen.valid?
                specimen.save!
                Citation.find_or_create_by!(citation_object: specimen, source_id: source, project_id: $project_id) unless source.blank?
                objects += [specimen]
                specimen.notes.create(text: row['Notes']) unless row['Notes'].blank?

                host = @data.host_plant_index[row['Host']]
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

#                @data.keywords.each do |k|
#                  specimen.data_attributes.create(type: 'InternalAttribute', controlled_vocabulary_term_id: k[1].id, value: row[k[0]]) unless row[k[0]].blank?
#                end

                specimen.tags.create(keyword: @data.keywords['ZeroTotal']) if no_specimens
                add_bioculation_class_3i(specimen, count)
              end

              unless specimen.valid?
                byebug
              end
            end
          end
          add_identifiers_3i(objects, row)
          add_determinations_3i(objects, row)
          end ########################
        end
      end

      def find_or_create_collecting_event_3i(ce)
        tmp_ce = { }
        @locality_columns_3i.each do |c|
          tmp_ce.merge!(c => ce[c]) unless ce[c].blank?
        end
        tmp_ce_sorted = tmp_ce.sort.to_s
        c_stored = @data.geographic_areas[Digest::MD5.hexdigest(tmp_ce_sorted)]

        unless c_stored.nil?
          c = CollectingEvent.find(c_stored)
          return c
        end

        latitude, longitude = nil, nil
        latitude, longitude = parse_lat_long_3i(ce) unless [4, 5, 6].include?(ce['Precision'].to_i)
        sdm, sdd, sdy, edm, edd, edy = parse_dates_3i(ce)
        elevation, verbatim_elevation = parse_elevation_3i(ce)
        geographic_area = GeographicArea.find(ce['TW_id'])
        geolocation_uncertainty = parse_geolocation_uncertainty_3i(ce)
        locality =  ce['SLocality'].blank? ? ce['GLocality'] : ce['GLocality'].to_s + ', ' + ce['SLocality'].to_s

        c = CollectingEvent.new(
            geographic_area: geographic_area,
            verbatim_label: nil,
            verbatim_locality: locality,
            verbatim_collectors: ce['Collectors'],
            verbatim_method: ce['Method'],
            start_date_day: sdd,
            start_date_month: sdm,
            start_date_year: sdy,
            end_date_day: edd,
            end_date_month: edm,
            end_date_year: edy,
            verbatim_habitat: ce['Ecology'],
            minimum_elevation: elevation,
            maximum_elevation: nil,
            verbatim_elevation: verbatim_elevation,
            verbatim_latitude: latitude,
            verbatim_longitude: longitude,
            verbatim_geolocation_uncertainty: geolocation_uncertainty,
            verbatim_datum: nil,
            field_notes: nil,
            verbatim_date: nil,
            no_cached: true,
       #     with_verbatim_data_georeference: true
        )

        if c.valid?
          c.save!
          c.data_attributes.create(import_predicate: 'Country', value: ce['Country'].to_s, type: 'ImportAttribute') unless ce['Country'].blank?
          c.data_attributes.create(import_predicate: 'State', value: ce['State'].to_s, type: 'ImportAttribute') unless ce['State'].blank?
          c.data_attributes.create(import_predicate: 'County', value: ce['County'].to_s, type: 'ImportAttribute') unless ce['County'].blank?
          gr = geolocation_uncertainty.nil? ? false : c.generate_verbatim_data_georeference(true, no_cached: true)


          unless gr == false
            ga, c.geographic_area_id = c.geographic_area_id, nil
            if gr.valid?
              c.no_cached = true
              c.save
              gr.save
            else
              c.geographic_area_id = ga
              c.no_cached = true
              c.save
            end

            gr.error_radius = geolocation_uncertainty
            gr.is_public = true
            gr.save
            c.data_attributes.create(type: 'ImportAttribute', import_predicate: 'georeference_error', value: 'Geolocation uncertainty is conflicting with geographic area') unless gr.valid?
          end

          @data.geographic_areas.merge!(Digest::MD5.hexdigest(tmp_ce_sorted) => c.id)
          return c
        else
          byebug
        end
      end

      def add_bioculation_class_3i(o, bcc)
        BiocurationClassification.create(biocuration_class: @data.biocuration_classes['Specimens'], biological_collection_object: o) if bcc == 'Specimens'
        BiocurationClassification.create(biocuration_class: @data.biocuration_classes['Males'], biological_collection_object: o) if bcc == 'Males'
        BiocurationClassification.create(biocuration_class: @data.biocuration_classes['Females'], biological_collection_object: o) if bcc == 'Females'
        BiocurationClassification.create(biocuration_class: @data.biocuration_classes['Nymphs'], biological_collection_object: o) if bcc == 'Nymphs'
      end


      def add_identifiers_3i(objects, row)
        return nil if row['ID'].blank?
        ns = 'INHS'
        i = row['ID']
        @data.namespaces.keys.each do |p|
          if i.include?(p)
            ns = p
            i = i.gsub(p, '')
          end
        end
        identifier = Identifier::Local::CatalogNumber.new(namespace: @data.namespaces[ns], identifier: i)

        if objects.count > 1 # Identifier on container.

          c = Container.containerize(objects, 'Container::Pin'.constantize )
          c.save
          c.identifiers << identifier if identifier
          c.save

        elsif objects.count == 1 # Identifer on object
          objects.first.identifiers << identifier if identifier
          objects.first.save
        else
          raise 'No objects in container.'
        end
      end

      def add_determinations_3i(objects, row)
        otu = find_otu(row['Key'])

        objects.each do |o|
          unless otu.nil?
            td = TaxonDetermination.create(
                biological_collection_object: o,
                otu: otu,
                year_made: year_from_field(row['DateID'])
            )

            if !row['Type'].blank?
              type = @type_type_3i[row['Type'].downcase]
              unless type.nil?
                type = type + 's' if o.type == "Lot"
                tm = TypeMaterial.create(protonym_id: otu.taxon_name_id, material: o, type_type: type )
                unless tm.valid?
                  o.data_attributes.create(type: 'ImportAttribute', import_predicate: 'type_material_error', value: 'Type material was not created. There are some inconsistensies.')
                end
              end
            end
          end
        end

      end


      def parse_lat_long_3i(ce)
        latitude, longitude = nil, nil
        nlt = ce['LatNS'].blank? ? nil : ce['LatNS'].capitalize
        ltd = ce['LatDeg'].blank? ? nil : "#{ce['LatDeg']}º"
        ltm = ce['LatMin'].blank? ? nil : "#{ce['LatMin']}'"
        lts = ce['LatSec'].blank? ? nil : "#{ce['LatSec']}\""
        latitude = [nlt,ltd,ltm,lts].compact.join
        latitude = nil if latitude == '-'

        nll = ce['LongEW'].blank? ? nil : ce['LongEW'].capitalize
        lld = ce['LongDeg'].blank? ? nil : "#{ce['LongDeg']}º"
        llm = ce['LongMin'].blank? ? nil : "#{ce['LongMin']}'"
        lls = ce['LongSec'].blank? ? nil : "#{ce['LongSec']}\""
        longitude = [nll,lld,llm,lls].compact.join
        longitude = nil if longitude == '-'

        [latitude, longitude]
      end

      def parse_dates_3i(ce)
        # Date
        # DateTo

      sdm, sdd, sdy, edm, edd, edy = nil, nil, nil, nil, nil, nil
        ( sdm, sdd, sdy = ce['Date'].split("/") ) if !ce['Date'].blank?
        ( edm, edd, edy = ce['DateTo'].split("/") ) if !ce['DateTo'].blank?
        sdy = sdy.to_i unless sdy.blank?
        edy = edy.to_i unless edy.blank?
        sdd = sdd.to_i unless sdd.blank?
        edd = edd.to_i unless edd.blank?
        sdm = sdm.to_i unless sdm.blank?
        edm = edm.to_i unless edm.blank?
        [sdm, sdd, sdy, edm, edd, edy]
      end

      def parse_elevation_3i(ce)
        # ElevationM
        # ElevationF
        ft =  ce['ElevationF']
        m = ce['ElevationM']

        if !ft.blank? && !m.blank? && !Utilities::Measurements.feet_equals_meters(ft, m)
          puts "\n !! Feet and meters both providing and not equal: #{ft}, #{m}."
        end

        elevation, verbatim_elevation = nil, nil

        if !ft.blank?
          elevation = (ft.to_i * 0.305).round
          verbatim_elevation = ft + ' ft.'
        elsif !m.blank?
          elevation = m.to_i
        end
        [elevation, verbatim_elevation]
      end

      def parse_geolocation_uncertainty_3i(ce)
        geolocation_uncertainty = nil
        return nil if ce['LatDeg'].blank? or ce['LongDeg'].blank?
        unless ce['Precision'].blank?
          case ce['Precision'].to_i
            when 1
              geolocation_uncertainty = 10
            when 2
              geolocation_uncertainty = 1000
            when 3
              geolocation_uncertainty = 10000
            when 4
              nil #geolocation_uncertainty = 100000
            when 5
              nil #geolocation_uncertainty = 1000000
            when 6
              nil #geolocation_uncertainty = 1000000
          end
        end
        return geolocation_uncertainty
      end


      def find_taxon_id(key)
          #@data.taxon_index[key.to_s] || Protonym.with_identifier('3i_Taxon_ID ' + key.to_s).find_by(project_id: $project_id).try(:id)
          @data.taxon_index[key.to_s] || Identifier.where(cached: '3i_Taxon_ID ' + key.to_s, project_id: $project_id).limit(1).pluck(:identifier_object_id).first
        end

        def find_taxon(key)
          Identifier.find_by(cached: '3i_Taxon_ID ' + key.to_s, project_id: $project_id).try(:identifier_object)
          #Protonym.with_identifier('3i_Taxon_ID ' + key.to_s).find_by(project_id: $project_id)
        end

        def find_otu(key)
          otu = nil
         # otu = Otu.joins(taxon_name: :identifiers).where(identifiers: {cached: '3i_Taxon_ID ' + key.to_s}, project_id: $project_id).first
         # otu = Otu.joins(:identifiers).where(identifiers: {cached: '3i_Taxon_ID ' + key.to_s}, project_id: $project_id).first if otu.nil?

          r = Identifier.find_by(cached: '3i_Taxon_ID ' + key.to_s, project_id: $project_id)
          if r.identifier_object_type == 'TaxonName'
            r.taxon_name.otus.first
          elsif r.identifier_object_type == 'Otu'
            r.identifier_object
          else
            raise
          end

          # otu
        end

        def find_publication_id(key3)
          #@data.publications_index[key3.to_s] || Source.with_identifier('3i_Source_ID ' + key3.to_s).first.try(:id)
          @data.publications_index[key3.to_s] || Identifier.where(cached: '3i_Source_ID ' + key3.to_s).limit(1).pluck(:identifier_object_id).first
        end

      end
    end
  end
