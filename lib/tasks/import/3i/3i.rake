require 'fileutils'

### rake tw:project_import:access3i:import_all data_directory=/Users/proceps/src/sf/import/3i/TXT/ no_transaction=true

##### Tables
# Authors
# BrochCharacters
# Brochosomes
#! Characters
#! CharTable
# Collections-
#! Countries!
#! CountrTable!
#! CountryCodes!
# DicotKey
# Export
# GenBank
#! Host!
#! HostPlants!
# ImageCharacters
# Images
# Keys
# Links
#! LitAuthors1!
#! Literature!
#! LitTable!
#! Localities!
#! Morph
#! Museums!
#! Parasitoids!
#! Rank!
#! State
#! Status!
#! Taxon!
#! Transl
#! UnchangedSpeciesNames!

namespace :tw do
  namespace :project_import do
    namespace :access3i do

      @import_name = '3i'

      # A utility class to index data.
      class ImportedData3i
        attr_accessor :people_index, :user_index, :publications_index, :citations_index, :genera_index, :images_index,
                      :parent_id_index, :statuses, :taxon_index, :citation_to_publication_index, :keywords,
                      :incertae_sedis, :emendation, :original_combination, :unique_host_plant_index,
                      :host_plant_index, :topics, :nouns, :countries, :geographic_areas, :museums, :namespaces, :biocuration_classes,
                      :people, :source_ay, :source_checked_taxonomy, :keyn, :chars, :states, :morph
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
          @people = {}
          @source_ay = {}
          @source_checked_taxonomy = {}
          @keyn = {}
          @chars = {}
          @states = {}
          @morph = {}
        end
      end

      task :import_all => [:data_directory, :environment] do |t|

        @ranks = {
            0 => '',
            1 => Ranks.lookup(:iczn, :subspecies),
            2 => Ranks.lookup(:iczn, :species),
            4 => Ranks.lookup(:iczn, :superspecies),
            6 => Ranks.lookup(:iczn, :subgenus),
            7 => Ranks.lookup(:iczn, :genus),
            8 => Ranks.lookup(:iczn, :supergenus),
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
            1 => 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Subjective',   #### ::Objective or ::Subjective
            2 => '', ### Original combination
            3 => 'TaxonNameRelationship::Iczn::Invalidating::Homonym::Primary',
            4 => 'TaxonNameRelationship::Iczn::Invalidating::Homonym::Secondary', #### or 'Secondary::Secondary1961'
            5 => 'TaxonNameRelationship::Iczn::Invalidating::Homonym', ## Preocupied
            6 => 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression',
            7 => '', ###common name
            8 => '', ##### 'TaxonNameRelationship::Iczn::Invalidating::Usage::FamilyGroupNameForm', #### combination => Combination
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
            27 => 'TaxonNameRelationship::Iczn::Invalidating::Misapplication',
            28 => 'TaxonNameRelationship::Iczn::Invalidating', ### invalid
            29 => 'TaxonNameRelationship::Iczn::Invalidating', ### infrasubspecific
            30 => 'TaxonNameRelationship::Iczn::Invalidating::Homonym::Primary::ForgottenHomonym',

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
            'Misidentification' => 'TaxonNameRelationship::Iczn::Invalidating::Misapplication',
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
            #           24 => 'TaxonNameClassification::Iczn::Unavailable',
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

        $project_id = 1
=begin
        handle_controlled_vocabulary_3i
        handle_litauthors_3i
        handle_references_3i
        handle_transl_3i
        handle_taxonomy_3i
        handle_taxon_name_relationships_3i
        handle_citation_topics_3i
        index_collecting_events_from_accessions_new_3i
        handle_host_plant_name_dictionary_3i
        handle_host_plants_3i
        handle_distribution_3i
        handle_parasitoids_3i
        handle_localities_3i

        handle_characters_3i
        handle_state_3i
        handle_chartable_3i
=end
        soft_validations_3i

        print "\n\n !! Success. End time: #{Time.now} \n\n"
      end

      def handle_projects_and_users_3i
        print "\nHandling projects and users "
        email = 'arboridia@gmail.com'
        project_name = '3i Auchenorrhyncha'
        user_name = '3i Import'
        $user_id, $project_id = nil, nil
        project1 = Project.where(name: project_name).first
        project_name = project_name + ' ' + Time.now.to_s  unless project1.nil?

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
            pwd = rand(36**10).to_s(36)
            user = User.create(email: email, password: pwd, password_confirmation: pwd, name: user_name, self_created: true)
          else
            user = user.first
          end
          $user_id = user.id

          project = nil

          if project.nil?
            project = Project.create(name: project_name)
          end

          $project_id = project.id
          pm = ProjectMember.create(user: user, project: project, is_project_administrator: true)

          @import.metadata['project_and_users'] = true
        end

        @root = Protonym.find_or_create_by(name: 'Root', rank_class: 'NomenclaturalRank', project_id: $project_id)
        @data.keywords['3i_imported'] = Keyword.find_or_create_by(name: '3i_imported', definition: 'Imported from 3i database.')
      end

      def handle_controlled_vocabulary_3i
        print "\nHandling CV \n"

        @accession_namespace = Namespace.create(institution: '3i Auchenorrhyncha', name: 'Accession Code', short_name: 'Accession Code')


        @data.keywords.merge!(
            #'AuthorDrMetcalf' => Predicate.find_or_create_by(name: 'AuthorDrMetcalf', definition: 'Author name from DrMetcalf bibliography database.', project_id: $project_id),
            '3i_imported' => Keyword.find_or_create_by(name: '3i_imported', definition: 'Imported from 3i database.', project_id: $project_id),
            'introduced' => Keyword.find_or_create_by(name: 'Introduced', definition: 'Introduced species.', project_id: $project_id),
            'ZeroTotal' => Keyword.find_or_create_by(name: 'ZeroTotal', definition: 'On import there were 0 total specimens recorded in INHS FileMaker database.', project_id: $project_id),
            'Allotype' => Keyword.find_or_create_by(name: 'Allotype', definition: 'Allotype.', project_id: $project_id),
            'CallNumberDrMetcalf' => Predicate.find_or_create_by(name: 'call_number_dr_metcalf', definition: 'Call Number from DrMetcalf bibliography database.', project_id: $project_id),
            #'AuthorReference' => Predicate.find_or_create_by(name: 'author_reference', definition: 'Author string as it appears in the nomenclatural reference.', project_id: $project_id),
            #'YearReference' => Predicate.find_or_create_by(name: 'year_reference', definition: 'Year string as it appears in the nomenclatural reference.', project_id: $project_id),
            #'Ethymology' => Predicate.find_or_create_by(name: 'ethymology', definition: 'Ethymology.', project_id: $project_id),
            'TypeDepository' => Predicate.find_or_create_by(name: 'type_depository', definition: 'Type depository.', project_id: $project_id),
            'HostPlant' => Predicate.find_or_create_by(name: 'host_plant', definition: 'Host plant.', project_id: $project_id),
            'YearRem' => Predicate.find_or_create_by(name: 'nomenclatural_string', definition: 'Nomenclatural remarks.', project_id: $project_id),
            'Typification' => Predicate.find_or_create_by(name: 'type_designated_by', definition: 'Type designated by', project_id: $project_id),
            'FirstRevisor' => Predicate.find_or_create_by(name: 'first_revisor_action', definition: 'First revisor action', project_id: $project_id),
            'PageAuthor' => Predicate.find_or_create_by(name: 'page_author', definition: 'Page author.', project_id: $project_id),
            'SimilarSpecies' => Predicate.find_or_create_by(name: 'similar_species', definition: 'Similar species.', project_id: $project_id),
            'IDDrMetcalf' => Namespace.find_or_create_by(institution: '3i Auchenorrhyncha', name: 'DrMetcalf_Source_ID', short_name: 'DrMetcalf_ID'),
            'KeyN' => Namespace.find_or_create_by(institution: '3i Auchenorrhyncha', name: '3i_KeyN_ID', short_name: '3i_KeyN_ID'),
            'Key3' => Namespace.find_or_create_by(institution: '3i Auchenorrhyncha', name: '3i_Source_ID', short_name: '3i_Source_ID'),
            'Key1' => Namespace.find_or_create_by(institution: '3i Auchenorrhyncha', name: '3i_Key1_ID', short_name: '3i_Key1_ID'),
            'Key2' => Namespace.find_or_create_by(institution: '3i Auchenorrhyncha', name: '3i_Key2_ID', short_name: '3i_Key2_ID'),
            'Key' => Namespace.find_or_create_by(institution: '3i Auchenorrhyncha', name: '3i_Taxon_ID', short_name: '3i_Taxon_ID'),
            'FLOW-ID' => Namespace.find_or_create_by(institution: '3i Auchenorrhyncha', name: 'FLOW_Source_ID', short_name: 'FLOW_Source_ID'),
            'DelphacidaeID' => Namespace.find_or_create_by(institution: '3i Auchenorrhyncha', name: 'Delphacidae_Source_ID', short_name: 'Delphacidae_Source_ID'),
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
            'Descriptions' => Topic.find_or_create_by(name: 'description', definition: 'Source has morphological description.', project_id: $project_id),
            'Records' => Topic.find_or_create_by(name: 'distribution', definition: 'Source has data on species distrebution or studied material.', project_id: $project_id),
            'Pictures' => Topic.find_or_create_by(name: 'illustrations', definition: 'Source has illustrations.', project_id: $project_id),
            'Types' => Topic.find_or_create_by(name: 'original description', definition: 'Source has original description.', project_id: $project_id),
            'Keys' => Topic.find_or_create_by(name: 'identification key', definition: 'Source has identification key.', project_id: $project_id),
            'Synonymy' => Topic.find_or_create_by(name: 'synonymy', definition: 'Source has synonymy records.', project_id: $project_id),
            'Host' => Topic.find_or_create_by(name: 'host plants', definition: 'Source has host plant records.', project_id: $project_id),
            'Parasitoids' => Topic.find_or_create_by(name: 'parasitoids', definition: 'Source has parasitoid records.', project_id: $project_id),
        )

        @host_plant_relationship = BiologicalRelationship.where(name: 'Host plant', project_id: $project_id).first
        if @host_plant_relationship.nil?
          @host_plant_relationship = BiologicalRelationship.create(name: 'Host plant')
          a1 = BiologicalRelationshipType.create(biological_property: @data.keywords['Host'], biological_relationship: @host_plant_relationship, type: 'BiologicalRelationshipType::BiologicalRelationshipSubjectType')
          a2 = BiologicalRelationshipType.create(biological_property: @data.keywords['Herbivor'], biological_relationship: @host_plant_relationship, type: 'BiologicalRelationshipType::BiologicalRelationshipObjectType')
        end
        @parasitoid_relationship = BiologicalRelationship.where(name: 'Parasitism', project_id: $project_id).first
        if @parasitoid_relationship.nil?
          @parasitoid_relationship = BiologicalRelationship.create(name: 'Parasitism')
          a1 = BiologicalRelationshipType.create(biological_property: @data.keywords['Parasitoid'], biological_relationship: @parasitoid_relationship, type: 'BiologicalRelationshipType::BiologicalRelationshipSubjectType')
          a2 = BiologicalRelationshipType.create(biological_property: @data.keywords['Host'], biological_relationship: @parasitoid_relationship, type: 'BiologicalRelationshipType::BiologicalRelationshipObjectType')
        end
        @attendance_relationship = BiologicalRelationship.where(name: 'Attendance', project_id: $project_id).first
        if @attendance_relationship.nil?
          @attendance_relationship = BiologicalRelationship.create(name: 'Attendance')
          a1 = BiologicalRelationshipType.create(biological_property: @data.keywords['Attendant'], biological_relationship: @attendance_relationship, type: 'BiologicalRelationshipType::BiologicalRelationshipSubjectType')
          a2 = BiologicalRelationshipType.create(biological_property: @data.keywords['Host'], biological_relationship: @attendance_relationship, type: 'BiologicalRelationshipType::BiologicalRelationshipObjectType')
        end
        @mutualism_relationship = BiologicalRelationship.where(name: 'Mutualism', project_id: $project_id).first
        if @mutualism_relationship.nil?
          @mutualism_relationship = BiologicalRelationship.create(name: 'Mutualism')
          a1 = BiologicalRelationshipType.create(biological_property: @data.keywords['Symbiont'], biological_relationship: @mutualism_relationship, type: 'BiologicalRelationshipType::BiologicalRelationshipSubjectType')
          a2 = BiologicalRelationshipType.create(biological_property: @data.keywords['Host'], biological_relationship: @mutualism_relationship, type: 'BiologicalRelationshipType::BiologicalRelationshipObjectType')
        end
      end

      def handle_litauthors_3i
        # Author
        # FullName
        path = @args[:data_directory] + 'litauthors.txt'
        print "\nHandling litauthors\n"
        raise "file #{path} not found" if not File.exists?(path)
        file = CSV.foreach(path, col_sep: "\t", headers: true)
        i = 0
        file.each do |row|
          i += 1
          print "\r#{i}"
          if row['FullName'].blank?
            person = Person.parse_to_people(row['Author']).first
          else
            person = Person.parse_to_people(row['FullName']).first
          end
          unless person.nil?
            person.data_attributes.new(type: 'ImportAttribute', import_predicate: '3i_Author', value: row['Author']) unless row['Author'].blank?
            person.data_attributes.new(type: 'ImportAttribute', import_predicate: 'AuthorDrMetcalf', value: row['FullName']) unless row['FullName'].blank?
            person.save!
            @data.people[row['Author']] = person.id
          end

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

        i = 0
        file.each do |row|
          i += 1
          print "\r#{i}"
          journal, serial_id, volume, pages = parse_bibliography_3i(row['Bibliography'])
          year, year_suffix = parse_year_3i(row['Year'])
          taxonomy, distribution, illustration, typhlocybinae = nil, nil, nil, nil
          note = row['Notes']
          author = row['Author'].gsub('., ', '.|').split('|').compact.join(' and ')
          source = Source::Bibtex.find_or_create_by( author: author,
                                                     year: year,
                                                     year_suffix: year_suffix,
                                                     title: row['Title'],
                                                     journal: journal,
                                                     serial_id: serial_id,
                                                     pages: pages,
                                                     volume: volume,
                                                     bibtex_type: 'article'
          )

          #source.alternate_values.new(value: row['Author'], type: 'AlternateValue::Abbreviation', alternate_value_object_attribute: 'author') if !row['AuthorDrMetcalf'].blank? && row['AuthorDrMetcalf'] != row['Author']

          source.data_attributes.create(type: 'InternalAttribute', predicate: @data.keywords['CallNumberDrMetcalf'], value: row['CallNumberDrMetcalf']) unless row['CallNumberDrMetcalf'].blank?

          source.data_attributes.create(type: 'ImportAttribute', import_predicate: 'AY3i', value: row['AY']) unless row['AY'].blank?
          source.data_attributes.create(type: 'ImportAttribute', import_predicate: 'Author3i', value: row['Author']) unless row['Author'].blank?
          source.data_attributes.create(type: 'ImportAttribute', import_predicate: 'YearReference', value: row['Year']) unless row['Year'].blank?
          source.data_attributes.create(type: 'ImportAttribute', import_predicate: 'BibliographyReference', value: row['Bibliography']) unless row['Bibliography'].blank?
          source.data_attributes.create(type: 'ImportAttribute', import_predicate: 'AuthorDrMetcalf', value: row['AuthorDrMetcalf']) unless row['AuthorDrMetcalf'].blank?

          if !note.blank? && note.include?('Taxonomy only and distribution')
            source.tags.create(keyword: @data.keywords['Distribution'])
            note.gsub!(' and distribution', '')
          end
          if !note.blank? && note.include?('Taxonomy only')
            tg = source.tags.create(keyword: @data.keywords['Taxonomy'])
            byebug if tg.id.nil?
            note.gsub!('Taxonomy only', '')
            @data.source_checked_taxonomy[source.id] = true
          end
          if !note.blank? && note.index('T ') == 0
            tg = source.tags.create(keyword: @data.keywords['Typhlocybinae'])
            byebug if tg.id.nil?
            note = note[2..-1]
          end
          #TODO check illustrations
          if !note.blank? && note.include?('Illustrations done')
            tg = source.tags.create(keyword: @data.keywords['Illustrations'])
            byebug if tg.id.nil?
            note.gsub!('Illustrations done', '')
          end
          note.squish! unless note.nil?


          source.notes.create(text: row['NotesDrMetcalf']) unless row['NotesDrMetcalf'].blank?
          source.notes.create(text: note) unless note.blank?

          language.each do |l|
            if (row['Notes'].to_s + ' ' + row['Bibliography'].to_s).include?('In ' + l)
              source.language_id = Language.where(english_name: l).limit(1).pluck(:id).first
            end
          end

          source.identifiers.create!(type: 'Identifier::Local::Import', namespace: @data.keywords['IDDrMetcalf'], identifier: row['IDDrMetcalf']) unless row['IDDrMetcalf'].blank?
          source.identifiers.create!(type: 'Identifier::Local::Import', namespace: @data.keywords['Key3'], identifier: row['Key3']) unless row['Key3'].blank?
          source.identifiers.create!(type: 'Identifier::Local::Import', namespace: @data.keywords['FLOW-ID'], identifier: row['FLOW-ID']) if !row['FLOW-ID'].blank? && row['FLOW-ID'] != '0'
          source.identifiers.create!(type: 'Identifier::Local::Import', namespace: @data.keywords['DelphacidaeID'], identifier: row['DelphacidaeID']) if !row['DelphacidaeID'].blank? && row['DelphacidaeID'] != '0'


          begin
            @data.publications_index[row['Key3']] = source.id
            @data.source_ay[row['Key3']] = row['AY']
            authors = row['Author'].gsub('., ', '.|').split('|')
            authors.each_with_index do |author, i|
              a = @data.people[author]
              if a.nil?
                a = Person.parse_to_people(author).first
                unless a.nil?
                  a.save!
                  a = a.id
                  @data.people[author] = a
                end
              end
              sa = SourceAuthor.create(person_id: a, role_object: source, position: i + 1) unless a.nil?
            end
            source.save!
            source.project_sources.create!
          rescue ActiveRecord::RecordInvalid
            puts "\nDuplicate record: #{row}\n"
          end
        end

        puts "\nResolved #{@data.publications_index.keys.count} publications\n"

      end

      def parse_bibliography_3i(bibl)
        return nil, nil, nil, nil if bibl.blank?

        matchdata = bibl.match(/(^.+)\s+(\d+\(.+\)|\d+): *(\d+-\d+|\d+–\d+|\d+)\.*\s*(.*$)/)
        return bibl, nil, nil, nil if matchdata.nil?

        serial_id = Serial.where(name: matchdata[1]).limit(1).pluck(:id).first
        serial_id ||= Serial.with_any_value_for(:name, matchdata[1]).limit(1).pluck(:id).first
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
          @data.nouns[row['speciesname']] = true
        end

      end

      def handle_taxonomy_3i

        handle_nouns_3i


        # Key !
        # Key3 !
        # Key3a
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

        confidence = ConfidenceLevel.find_or_create_by(name: 'Verified', definition: 'Verified against the original source', project_id: $project_id).id

        synonym_statuses = %w(1 6 10 11 14 17 22 23 24 26 27 28 29).freeze

        path = @args[:data_directory] + 'taxon.txt'
        print "\nHandling taxonomy\n"
        raise "file #{path} not found" if not File.exists?(path)
        file = CSV.foreach(path, col_sep: "\t", headers: true)

        i = 0
        file.each do |row|
          i += 1
          print "\r#{i}"
          if row['Name'] == 'Incertae sedis' || row['Name'] == 'Unplaced'
            @data.incertae_sedis[row['Key']] = @data.taxon_index[row['Parent']]
          elsif row['Status'] == '7' ### common name
          elsif row['Status'] == '8' #### && !find_taxon_3i(row['Parent']).try(:rank_class).to_s.include?('Family') ### combination
          elsif row['Status'] == '2'
            @data.original_combination[row['OriginalCombinationOf']] = row
          elsif row['Status'] == '16'
            rank = @ranks[row['Rank'].to_i]
            otu = Otu.create!(name: 'Genus ' + row['Name']) if rank.to_s.include?('Genus')
            otu = Otu.create!(name: ('Species ' + @data.taxon_index[row['Parent']].try(:name).to_s + ' ' + row['Name']).squish) if rank.to_s.include?('Species')
            otu.identifiers.create!(type: 'Identifier::Local::Import', namespace: @data.keywords['Key'], identifier: row['Key'])
          elsif row['Status'] == '18'
            taxon = find_taxon_3i(row['Parent'])
            taxon.data_attributes.create!(type: 'InternalAttribute', controlled_vocabulary_term_id: @data.keywords['Typification'].id, value: ('Type designation: ' + row['Author'].to_s + ', ' + row['Year'].to_s + row['YearRem'].to_s).squish)
#              taxon.valid? ? taxon.save! : byebug
          elsif row['Status'] == '19'
            taxon = find_taxon_3i(row['Parent'])
            taxon.data_attributes.create!(type: 'InternalAttribute', controlled_vocabulary_term_id: @data.keywords['Typification'].id, value: ('Neotype designation: ' + row['Author'].to_s + ', ' + row['Year'].to_s + row['YearRem'].to_s).squish)
#              taxon.valid? ? taxon.save! : byebug
          elsif row['Status'] == '20'
            taxon = find_taxon_3i(row['Parent'])
            taxon.data_attributes.create!(type: 'InternalAttribute', controlled_vocabulary_term_id: @data.keywords['Typification'].id, value: ('Lectotype designation: ' + row['Author'].to_s + ', ' + row['Year'].to_s + row['YearRem'].to_s).squish)
#              taxon.valid? ? taxon.save! : byebug
          elsif row['Status'] == '25'  && !find_taxon_3i(row['Parent']).rank_class.to_s.include?('Family') # emendation
            taxon = find_taxon_3i(row['Parent'])
            taxon.data_attributes.create!(type: 'InternalAttribute', controlled_vocabulary_term_id: @data.keywords['FirstRevisor'].id, value: (row['Name'] + ' ' + row['Author'].to_s + ', ' + row['Year'].to_s + row['YearRem'].to_s).squish)
#              taxon.valid? ? taxon.save! : byebug
            @data.emendation[row['Parent']] = row
          else
            name = row['Name'].split(' ').last
            vname = row['Name'].split(' ').last
            #parent = row['Parent'].blank? ? @root : Protonym.with_identifier('3i_Taxon_ID ' + row['Parent']).find_by(project_id: $project_id)
            parent = row['Parent'].blank? ? @root : @data.incertae_sedis[row['Parent']] ? TaxonName.find(@data.incertae_sedis[row['Parent']]) : find_taxon_3i(row['Parent'])

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
              parent = find_taxon_3i(row['OriginalSpecies'])
              rank = @ranks[1]
            end
            byebug if row['Rank'].blank?

            #rank = row['Rank'] == '0' ? parent.rank_class : @ranks[row['Rank'].to_i]
            source = row['Key3'].blank? ? nil : @data.publications_index[row['Key3']] # Source.with_identifier('3i_Source_ID ' + row['Key3']).first
            #source_id = Identifier.where(cached: '3i_Source_ID ' + row['Key3'].to_s).limit(1).first if source.nil? && !row['Key3'].blank?
            #source = source_id.identifier_object if source.nil? && !source_id.nil?
            if row['Rank'] == '0'
              byebug if parent.parent.nil?
              parent = parent.parent
            end
            name = name.gsub('2222', '').gsub('1111', '')

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
                                  etymology: row['Ethymology'],
                                  also_create_otu: true
            #no_cached: true,
            )

            #              taxon.citations.new(source_id: source, pages: row['Page'], is_original: true) unless source.blank?
            taxon.identifiers.new(type: 'Identifier::Local::Import', namespace: @data.keywords['Key'], identifier: row['Key'])
            taxon.notes.new(text: row['Remarks']) unless row['Remarks'].blank?
            #taxon.data_attributes.new(type: 'InternalAttribute', controlled_vocabulary_term_id: @data.keywords['Ethymology'].id, value: row['Ethymology']) unless row['Ethymology'].blank?
            taxon.data_attributes.new(type: 'InternalAttribute', controlled_vocabulary_term_id: @data.keywords['TypeDepository'].id, value: row['TypeDepository']) unless row['TypeDepository'].blank?
            taxon.data_attributes.new(type: 'InternalAttribute', controlled_vocabulary_term_id: @data.keywords['YearRem'].id, value: row['YearRem']) unless row['YearRem'].blank?
            taxon.data_attributes.new(type: 'InternalAttribute', controlled_vocabulary_term_id: @data.keywords['PageAuthor'].id, value: row['PageAuthor']) unless row['PageAuthor'].blank?


            if @data.source_checked_taxonomy[source]
              taxon.confidences.new(position: 1, confidence_level_id: confidence)
            end

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

            of_tnr = nil
            of_tnr = taxon.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::Available::OfficialListOfFamilyGroupNamesInZoology') if row['YearRem'].to_s.include?('Official List of Family-Group Names in Zoology')
            of_tnr = taxon.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::Available::OfficialListOfGenericNamesInZoology') if row['YearRem'].to_s.include?('Official List of Generic Names in Zoology')
            of_tnr = taxon.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::Available::OfficialListOfSpecificNamesInZoology') if row['YearRem'].to_s.include?('Official List of Specific Names in Zoology')
            of_tnr = taxon.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::Unavailable::Suppressed::OfficialIndexOfRejectedFamilyGroupNamesInZoology') if row['YearRem'].to_s.include?('Official Index of Rejected and Invalid Family-Group Names in Zoology')
            of_tnr = taxon.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::Unavailable::Suppressed::OfficialIndexOfRejectedGenericNamesInZoology') if row['YearRem'].to_s.include?('Official Index of Rejected and Invalid Generic Names in Zoology')
            of_tnr = taxon.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::Unavailable::Suppressed::OfficialIndexOfRejectedSpecificNamesInZoology') if row['YearRem'].to_s.include?('Official Index of Rejected and Invalid Specific Names in Zoology')
            of_tnr = taxon.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::Unavailable::Suppressed::OfficialIndexOfRejectedAndInvalidWorksInZoology') if row['YearRem'].to_s.include?('Official Index of Rejected and Invalid Works in Zoological Nomenclature')

            if !of_tnr.nil? && row['TypeDesignation'] !='subsequent designation'
              source1 = row['Key3a'].blank? ? nil : @data.publications_index[row['Key3a']]
              of_tnr.citations.new(source_id: source1, is_original: true) unless source1.nil?
            end

            if row['Status'].to_i == 24
              if name.length == 1
                taxon.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::Unavailable::LessThanTwoLetters')
              else
                taxon.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::Unavailable')
              end
            end

            taxon.iczn_uncertain_placement = TaxonName.find(@data.incertae_sedis[row['Parent']]) if @data.incertae_sedis[row['Parent']]
            taxon.original_variety = taxon if row['Name'].include?(' var. ')
            taxon.original_form = taxon if row['Name'].include?(' f. ')

            begin
              taxon.save!
              @data.taxon_index[row['Key']] = taxon.id



              if !row['Author'].nil? && @data.source_ay[row['Key3']] == row['Author']
                SourceAuthor.where(role_object_type: 'Source', role_object_id: source).find_each do |sa|
                  TaxonNameAuthor.create(person_id: sa.person_id, role_object: taxon, position: sa.position)
                end
              end

            rescue ActiveRecord::RecordInvalid
              taxon.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::Unavailable::NotLatin') if taxon.rank_string =~ /Family/ && row['Status'] != '0' && !taxon.errors.messages[:name].blank?
              taxon.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::Unavailable::NotLatin') if taxon.rank_string =~ /Species/ && row['Status'] != '0' && taxon.errors.full_messages.include?('Name name must be lower case')
              taxon.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::Unavailable::NotLatin') if taxon.rank_string =~ /Species/ && row['Status'] != '0' && taxon.errors.full_messages.include?('Name Name must be latinized, no digits or spaces allowed')
              taxon.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::Unavailable::NotLatin') if taxon.rank_string =~ /Genus/ && row['Status'] != '0' && taxon.errors.full_messages.include?('Name Name must be latinized, no digits or spaces allowed')

              if taxon.valid?
                taxon.save!
                @data.taxon_index[row['Key']] = taxon.id
              else
                print "\n#{row['Key']}         #{row['Name']}"
                print "\n#{taxon.errors.full_messages}\n"
                #byebug
              end
            end
            if !row['DescriptEn'].blank? && (row['DescriptEn'].include?('<h2>Notes</h2>') || row['DescriptEn'].include?('<h2>Remarks</h2>'))
              content = taxon.otus.first.contents.create(topic: @data.keywords['Notes'], text: row['DescriptEn'].gsub('<h2>Notes</h2>', '').gsub('<h2>Remarks</h2>', '').squish) ####################?????????
              byebug if content.id.nil?
            end
            unless row['KeyN'].blank?
              row['KeyN'].gsub(' ', '').split(',').each do |kn|
                a = ObservationMatrixRowItem::SingleOtu.create(observation_matrix_id: @data.keyn[kn], otu_id: taxon.otus.first.id)
                byebug if a.id.nil?
              end
            end

          end
        end
      end

      def handle_taxon_name_relationships_3i
        path = @args[:data_directory] + 'taxon.txt'
        print "\nHandling taxon name relationships\n"
        raise "file #{path} not found" if not File.exists?(path)
        file = CSV.foreach(path, col_sep: "\t", headers: true)

        synonym_statuses = %w(1 6 10 11 14 17 22 23 24 26 27 28 29).freeze
        homonym_statuses = %w(3 4 5).freeze

        Combination.tap{}

        i = 0
        file.each do |row|
          i += 1
          print "\r#{i} (Relationships)"
          taxon = nil
          taxon = find_taxon_3i(row['Key'])
          if !taxon.nil? ### original combinations, synonyms, types
            taxon.original_genus = find_taxon_3i(row['OrigGen']) unless row['OrigGen'].blank?
            taxon.original_species = find_taxon_3i(row['OriginalSpecies']) unless row['OriginalSpecies'].blank?
            taxon.original_subspecies = find_taxon_3i(row['OriginalSubSpecies']) unless row['OriginalSubSpecies'].blank?
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
                  taxon.type_species_by_original_monotypy = find_taxon_3i(row['Type'])
                when 'monotypy'
                  taxon.type_species_by_monotypy = find_taxon_3i(row['Type'])
                when 'subsequent monotypy'
                  taxon.type_species_by_subsequent_monotypy = find_taxon_3i(row['Type'])
                when 'original designation'
                  taxon.type_species_by_original_designation = find_taxon_3i(row['Type'])
                when 'subsequent designation'
                  #taxon.type_species_by_subsequent_designation = find_taxon_3i(row['Type'])
                  source1 = row['Key3a'].blank? ? nil : @data.publications_index[row['Key3a']]
                  tssd = taxon.related_taxon_name_relationships.create(subject_taxon_name: find_taxon_3i(row['Type']),  type: 'TaxonNameRelationship::Typification::Genus::SubsequentDesignation')
                  byebug if tssd.id.nil?
                  tssd.citations.create(source_id: source1, is_original: true) unless source1.nil?
                when 'ruling by commission'
                  taxon.type_species_by_ruling_by_Commission = find_taxon_3i(row['Type'])
                else
                  taxon.type_species = find_taxon_3i(row['Type'])
              end
            end
            taxon.type_genus = find_taxon_3i(row['Type']) if taxon.rank_string =~ /Family/ && !row['Type'].blank?
            taxon.iczn_set_as_primary_homonym_of = find_taxon_3i(row['Homonym']) if !row['Homonym'].blank? && row['Status'] == '3'
            taxon.iczn_set_as_secondary_homonym_of = find_taxon_3i(row['Homonym']) if !row['Homonym'].blank? && row['Status'] == '4'
            taxon.iczn_set_as_homonym_of = find_taxon_3i(row['Homonym']) if !row['Homonym'].blank? && row['Status'] == '5'
            taxon.iczn_set_as_replacement_name_of = find_taxon_3i(row['NomenNovumFor']) if !row['NomenNovumFor'].blank?
            taxon.iczn_set_as_misspelling_of = find_taxon_3i(row['MisspellingOf']) if row['OriginalCombinationOf'].blank? && !row['MisspellingOf'].blank?
            taxon.iczn_set_as_misspelling_of = find_taxon_3i(row['Parent']) if row['OriginalCombinationOf'].blank? && row['MisspellingOf'].blank? && row['Status'] == '9'
            taxon.iczn_set_as_incorrect_original_spelling_of = find_taxon_3i(row['OriginalCombinationOf']) if !row['OriginalCombinationOf'].blank? && row['Status'] == '9'
            taxon.iczn_set_as_misapplication_of = find_taxon_3i(row['MisapplicationFor']) if !row['MisapplicationFor'].blank? && row['Status'] == '11'
            #taxon.iczn_first_revisor_action = @data.taxon_index[row['Parent']] if !row['OriginalCombinationOf'].blank? && row['Status'] == '9'

            source = nil
            if !@data.emendation[row['Parent']].blank? && row['OriginalCombinationOf'] == row['Parent']
              source = find_taxon_3i(@data.emendation[row['Parent']]).try(['Key3']).nil? ? nil : @data.publications_index[@data.emendation[row['Parent']]['Key3']] unless @data.emendation[row['Parent']].nil?
              tnr = TaxonNameRelationship::Iczn::PotentiallyValidating::FirstRevisorAction.create(object_taxon_name: find_taxon_3i(@data.emendation[row['Parent']]['Parent']), subject_taxon_name: taxon, origin_citation_attributes: {source_id: source}) if !@data.emendation[row['Parent']].blank? && row['OriginalCombinationOf'] == row['Parent']
              byebug if tnr.id.nil?
            end

            begin
              taxon.save!
            rescue ActiveRecord::RecordInvalid
              byebug
            end

            if !row['NomenNovumFor'].blank?
              source = row['Key3'].blank? ? nil : @data.publications_index[row['Key3']]
              if row['YearRem'].to_s.include?('unneded n.nov.')
                tnr = TaxonNameRelationship.create(subject_taxon_name: taxon, object_taxon_name: find_taxon_3i(row['NomenNovumFor']), type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::UnnecessaryReplacementName')
              else
                tnr = TaxonNameRelationship.create(subject_taxon_name: find_taxon_3i(row['NomenNovumFor']), object_taxon_name: taxon, type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::ReplacedHomonym')
              end
              if !source.blank? && !tnr.id.nil?
                tnr.citations.create(source_id: source, pages: row['Page'], is_original: true)
              elsif tnr.id.nil?
                byebug
              end

            end
            if synonym_statuses.include?(row['Status']) # %w(1 6 10 11 14 17 22 23 24 26 27 28 29)
              if TaxonNameRelationship.where_subject_is_taxon_name(taxon.id).with_type_base('TaxonNameRelationship::Iczn::Invalidating::Synonym').first.nil?
                tnr = TaxonNameRelationship.create(subject_taxon_name: taxon, object_taxon_name: find_taxon_3i(row['Parent']), type: @relationship_classes[row['Status'].to_i])
                byebug if tnr.id.nil?
              end
            end
            if homonym_statuses.include?(row['Status']) && row['Rank'] == '0'
              if TaxonNameRelationship.where_subject_is_taxon_name(taxon.id).with_type_base('TaxonNameRelationship::Iczn::Invalidating::Synonym').first.nil?
                tnr = TaxonNameRelationship.create(subject_taxon_name: taxon, object_taxon_name: find_taxon_3i(row['Parent']), type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Subjective')
                byebug if !tnr.nil? && tnr.id.nil?
              end
            end


          elsif row['Status'] == '8' || row['Status'] == '25' ### taxon name combinations
            taxon = find_taxon_3i(row['CombinationOf']) || find_taxon_3i(row['Parent'])

            source = row['Key3'].blank? ? nil : @data.publications_index[row['Key3']]
            c = Combination.new(origin_citation_attributes: {source_id: source, pages: row['Page']}, verbatim_author: row['Author'], year_of_publication: row['Year'])
            c.identifiers.new(type: 'Identifier::Local::Import', namespace: @data.keywords['Key'], identifier: row['Key'])

            origgen = row['OrigGen'].blank? ? nil : find_taxon_3i(row['OrigGen'])
            origsubgen = row['OrigSubGen'].blank? ? nil : find_taxon_3i(row['OrigSubGen'])
            origspecies = row['OriginalSpecies'].blank? ? nil : find_taxon_3i(row['OriginalSpecies'])
            origsubspecies = row['OriginalSubSpecies'].blank? ? nil : find_taxon_3i(row['OriginalSubSpecies'])

            #  c.citations.new(source_id: source, pages: row['Page']) unless source.blank?
            c.genus = origgen unless origgen.blank?
            gender = c.genus.gender_name unless c.genus.blank?
            c.subgenus = origsubgen unless origsubgen.blank?
            c.species = origspecies unless origspecies.blank?
            c.subspecies = origsubspecies unless origsubspecies.blank?
            c.variety = taxon if row['Name'].include?(' var. ')
            c.form = taxon if row['Name'].include?(' f. ')
            c.parent = origgen.blank? ? find_taxon_3i(row['Parent']).parent : origgen.parent
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
              #
            elsif taxon.rank_string =~ /Family/
              c.family = taxon
              c.verbatim_name = row['Name'].to_s
              #tnr = TaxonNameRelationship.create(subject_taxon_name: taxon, object_taxon_name: find_taxon_3i(row['Parent']), type: 'TaxonNameRelationship::Iczn::Invalidating::Usage::FamilyGroupNameForm')
              #byebug unless tnr.valid?
            end
            c.data_attributes.new(type: 'InternalAttribute', controlled_vocabulary_term_id: @data.keywords['YearRem'].id, value: row['YearRem']) unless row['YearRem'].blank?

            i3_combination = ''
            i3_combination = origgen.name_with_misspelling(gender).to_s + ' ' unless origgen.blank?
            i3_combination += '(' + origsubgen.name_with_misspelling(gender).to_s + ') ' unless origsubgen.blank?
            i3_combination += row['Name'].to_s
            i3_combination.squish!


            begin
              if !i3_combination.blank? && i3_combination != c.cached
                #c.data_attributes.create(type: 'ImportAttribute', import_predicate: 'combination_in_3i', value: i3_combination)
                #c.data_attributes.create(type: 'ImportAttribute', import_predicate: 'name_in_3i', value: row['Name'])
                c.verbatim_name = i3_combination if c.verbatim_name.blank?
#                c.valid? ? c.save! : byebug
              end
              c.save!
            rescue ActiveRecord::RecordInvalid
              print "\n#{row['Key']}         #{row['Name']}"
              print "\n#{c.errors.full_messages}\n"
            end

          elsif row['Status'] == '7' #  common name
            lng = Language.find_by_alpha_3_bibliographic(@languages[row['CommonNameLang'].to_s.downcase])
            CommonName.create!(otu: find_taxon_3i(row['Parent']).otus.first, name: row['Name'], language: lng)
          elsif row['Status'] == '2' || !row['OriginalCombinationOf'].blank? ### Original combination
            taxon = find_taxon_3i(row['OriginalCombinationOf']) || find_taxon_3i(row['Parent'])
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

            taxon = TaxonName.find(taxonid) ## Do not delete this line
            taxon.original_species = find_taxon_3i(row['OriginalSpecies']) unless row['OriginalSpecies'].blank?
            taxon.original_subspecies = find_taxon_3i(row['OrigOriginalSubSpecies']) unless row['OriginalSubSpecies'].blank?
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

            begin
              taxon.save!
            rescue ActiveRecord::RecordInvalid
              byebug
            end
          end
        end
      end

      def index_collecting_events_from_accessions_new_3i


        path = @args[:data_directory] + 'accessions_new.txt' # self contained
        raise 'file not found' if not File.exists?(path)

        ac = CSV.open(path, col_sep: "\t", :headers => true)

        fields = %w{LocalityLabel Habitat Host AccessionNumber Country State County Locality Park DateCollectedBeginning DateCollectedEnding Collector CollectionMethod Elev_m Elev_ft NS Lat_deg Lat_min Lat_sec EW Long_deg Long_min Long_sec Comments PrecisionCode Datum ModifiedBy ModifiedOn}

        fields1 = %w{Host AccessionNumber Comments PrecisionCode Datum}


        field_translate = {
            'NS' => 'LatNS',
            'Lat_deg' => 'LatDeg',
            'Lat_min' => 'LatMin',
            'Lat_sec' => 'LatSec',
            'EW' => 'LongEW',
            'Long_deg' => 'LongDeg',
            'Long_min' => 'LongMin',
            'Long_sec' => 'LongSec',
            'Elev_m' => 'ElevationF',
            'Elev_ft' => 'ElevationM',
            'Locality' => 'GLocality',
            'Park' => 'SLocality',
            'CollectionMethod' => 'Method',
            'Habitat' => 'Ecology',
            'DateCollectedBeginning' => 'Date',
            'DateCollectedEnding' => 'DateTo',
            'Collector' => 'Collectors',
            'PrecisionCode' => 'Precision'
        }

        puts "\naccession new records\n"
        i = 0
        ac.each do |row|
          i += 1
          print "\r#{i}"
          tmp_ce = { }
          fields.each do |c|
            tmp_ce[c] = row[c] unless row[c].blank?
          end
          field_translate.keys.each do |c|
            tmp_ce[field_translate[c]] = tmp_ce[c]
          end
          tmp_ce['County'] = geo_translate_3i(tmp_ce['County']) unless tmp_ce['County'].blank?
          tmp_ce['State'] = geo_translate_3i(tmp_ce['State']) unless tmp_ce['State'].blank?
          tmp_ce['Country'] = geo_translate_3i(tmp_ce['Country']) unless tmp_ce['Country'].blank?

          ce = find_or_create_collecting_event_3i(tmp_ce)

        end
      end

      def geo_translate_3i(name)
        GEO_NAME_TRANSLATOR[name] ? GEO_NAME_TRANSLATOR[name] : name
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
        rank_a = %w(Phylum Class Order Family Genus Subgenus Species Variety).freeze

        i = 0
        file.each do |row|
          i += 1
          print "\r#{i}"
          tmp = {}
          rank_a.each do |c|
            tmp[c] = row[c] unless row[c].blank?
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
              @data.host_plant_index[row['Family']] = otu
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
            @data.unique_host_plant_index[tmp] = otu
          end

          unless row['CommonName'].blank?
            lng = Language.find_by_alpha_3_bibliographic(@languages[row['lng'].to_s.downcase])
            c = CommonName.new(otu_id: otu, name: row['CommonName'], language: lng)
            begin
              c.save
            rescue ActiveRecord::RecordInvalid
              byebug
            end
          end

          @data.host_plant_index[row['HostPlant']] = otu
          @data.host_plant_index[row['CommonName']] = otu unless row['CommonName'].blank?

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

        i = 0
        file.each do |row|
          i += 1
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

          s = find_publication_id_3i(row['Key3'])

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

        confidence = ConfidenceLevel.find_or_create_by(name: 'Verified', definition: 'Verified against the original source', project_id: $project_id).id


        i = 0
        file.each do |row|
          i += 1
          print "\r#{i}"

          p = find_taxon_3i(row['Key'])
          if p.nil?
            print "\nProblematic Key: #{row['Key']}\n"
          else
            source = find_publication_id_3i(row['Key3'])

            byebug if p.nil?
            c = p.citations.find_or_create_by!(source_id: source, project_id: $project_id)

            if row['Descriptions'] == '1' && row['Types'] == '1'
              c.citation_topics.find_or_create_by(topic: @data.topics['Types'], project_id: $project_id)
              p.confidences.create(position: 1, confidence_level_id: confidence)
            end
            c.citation_topics.find_or_create_by(topic: @data.topics['Descriptions'], project_id: $project_id) if row['Descriptions'] == '1' && row['Types'] == '0'
            c.citation_topics.find_or_create_by(topic: @data.topics['Records'], project_id: $project_id) if row['Records'] == '1'
            c.citation_topics.find_or_create_by(topic: @data.topics['Pictures'], project_id: $project_id) if row['Pictures'] == '1'
            c.citation_topics.find_or_create_by(topic: @data.topics['Keys'], project_id: $project_id) if row['Keys'] == '1'
            c.citation_topics.find_or_create_by(topic: @data.topics['Synonymy'], project_id: $project_id) if row['Synonymy'] == '1'
            c.citation_topics.find_or_create_by(topic: @data.topics['Host'], project_id: $project_id) if row['Host'] == '1'

            begin
              c.save!
            rescue ActiveRecord::RecordInvalid
              byebug
            end
            if row['Synonymy'] == '1'
              tr = p.taxon_name_relationships.with_type_array(TAXON_NAME_RELATIONSHIP_NAMES_SYNONYM).first
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

        i = 0
        file.each do |row|
          i += 1
          print "\r#{i}"
          otu = find_otu(row['Key'])
          source = find_publication_id_3i(row['Key3'])
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
            ad = AssertedDistribution.find_or_create_by(
                otu: otu,
                geographic_area: ga,
                #source_id: source,
                is_absent: erroneously,
                project_id: $project_id )
            c = ad.citations.new(source_id: source, project_id: $project_id)
            ad.save
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
          @data.countries[row['Key6']] = row
        end
      end

      def handle_museums_3i
        # Abbreviation
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
          @data.museums[row['Abbreviation']] = row['TW_acronim'] unless row['TW_acronim'].blank?
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

        i = 0
        file.each do |row|
          i += 1
          print "\r#{i}"
          collecting_event = find_or_create_collecting_event_3i(row)
          repository = nil
          repository = Repository.find_by_acronym(@data.museums[row['Museum']]) unless @data.museums[row['Museum']].blank?
          source = find_publication_id_3i(row['Key3'])

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
              begin
                specimen.save!
                Citation.find_or_create_by!(citation_object: specimen, source_id: source, project_id: $project_id) unless source.blank?
                objects += [specimen]
                specimen.notes.create(text: row['Notes']) unless row['Notes'].blank?

                host = @data.host_plant_index[row['HostPlant']]
                host = @data.host_plant_index[row['HostCommonName']] if host.blank?
                host = @data.host_plant_index[row['HostFamily']] if host.blank?
                host = Otu.find(host) unless host.nil?

#                unless host.blank?
#                  identifier = Identifier.where(namespace_id: @taxon_namespace.id, identifier: host, project_id: $project_id)
#                  host = identifier.empty? ? nil : identifier.first.identifier_object
#                end
                unless host.blank?
                  BiologicalAssociation.create(biological_relationship: @host_plant_relationship,
                                               biological_association_subject: host,
                                               biological_association_object: specimen
                  )
                end

#                @data.keywords.each do |k|
#                  specimen.data_attributes.create(type: 'InternalAttribute', controlled_vocabulary_term_id: k[1].id, value: row[k[0]]) unless row[k[0]].blank?
#                end

                specimen.tags.create(keyword: @data.keywords['ZeroTotal']) if no_specimens
                add_bioculation_class_3i(specimen, count)
              rescue ActiveRecord::RecordInvalid
                byebug
              end
            end
          end
          add_identifiers_3i(objects, row)
          add_determinations_3i(objects, row)
        end
      end

      def find_or_create_collecting_event_3i(ce)
        tmp_ce = { }
        @locality_columns_3i.each do |c|
          tmp_ce[c] = ce[c] unless ce[c].blank?
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
        geographic_area = ce['TW_id'].blank? ? nil : GeographicArea.find(ce['TW_id'])
        geolocation_uncertainty = parse_geolocation_uncertainty_3i(ce)
        locality =  ce['SLocality'].blank? ? ce['GLocality'] : ce['GLocality'].to_s + ', ' + ce['SLocality'].to_s
        locality = ce['Locality'] if locality.blank? && !ce['Locality'].blank?
        #collector =

        c = CollectingEvent.new(
            geographic_area: geographic_area,
            verbatim_label: ce['LocalityLabel'],
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
            verbatim_datum: ce['Datum'],
            field_notes: nil,
            verbatim_date: nil,
            no_cached: true,
#     with_verbatim_data_georeference: true
        )
        # byebug unless c.valid?
        begin
          c.save
          if c.id.nil? && !c.errors.messages[:md5_of_verbatim_label].blank?
            c = CollectingEvent.where(md5_of_verbatim_label: c.md5_of_verbatim_label).first
          end
          c.data_attributes.create(import_predicate: 'Country', value: ce['Country'].to_s, type: 'ImportAttribute') unless ce['Country'].blank?
          c.data_attributes.create(import_predicate: 'State', value: ce['State'].to_s, type: 'ImportAttribute') unless ce['State'].blank?
          c.data_attributes.create(import_predicate: 'County', value: ce['County'].to_s, type: 'ImportAttribute') unless ce['County'].blank?
          gr = geolocation_uncertainty.blank? ? false : c.generate_verbatim_data_georeference(true, no_cached: false)
          c.notes.create(text: ce['Comments']) unless ce['Comments'].blank?
          c.data_attributes.create(type: 'InternalAttribute', predicate: @data.keywords['HostPlant'], value: ce['Host']) unless ce['Host'].blank?
          c.data_attributes.create(type: 'InternalAttribute', predicate: @data.keywords['HostPlant'], value: ce['HostPlant']) unless ce['HostPlant'].blank?
          c.identifiers.create(identifier: ce['AccessionNumber'], namespace: @accession_namespace, type: 'Identifier::Local::AccessionCode') unless ce['AccessionNumber'].blank?

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

          @data.geographic_areas[Digest::MD5.hexdigest(tmp_ce_sorted)] = c.id
          return c
        rescue ActiveRecord::RecordInvalid
          byebug
        end
      end

      def parse_geolocation_uncertainty_3i(ce)
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
                o.tags.find_or_create_by!(keyword: @data.keywords['Allotype']) if row['Type'] == 'Allotype'
                if tm.id.nil?
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
        ltd = ce['LatDeg'].blank? ? nil : "#{ce['LatDeg']}º".gsub('.00º', 'º')
        ltm = ce['LatMin'].blank? ? nil : "#{ce['LatMin']}'".gsub(".00'", "'")
        lts = ce['LatSec'].blank? ? nil : "#{ce['LatSec']}\"".gsub(".00\"", "\"")
        latitude = [nlt,ltd,ltm,lts].compact.join
        latitude = nil if latitude == '-'

        nll = ce['LongEW'].blank? ? nil : ce['LongEW'].capitalize
        lld = ce['LongDeg'].blank? ? nil : "#{ce['LongDeg']}º".gsub('.00º', 'º')
        llm = ce['LongMin'].blank? ? nil : "#{ce['LongMin']}'".gsub(".00'", "'")
        lls = ce['LongSec'].blank? ? nil : "#{ce['LongSec']}\"".gsub(".00\"", "\"")

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

      def find_taxon_id_3i(key)
        #@data.taxon_index[key.to_s] || Protonym.with_identifier('3i_Taxon_ID ' + key.to_s).find_by(project_id: $project_id).try(:id)
        @data.taxon_index[key.to_s] || Identifier.where(cached: '3i_Taxon_ID ' + key.to_s, identifier_object_type: 'TaxonName', project_id: $project_id).limit(1).pluck(:identifier_object_id).first
      end

      def find_taxon_3i(key)
        Identifier.find_by(cached: '3i_Taxon_ID ' + key.to_s, identifier_object_type: 'TaxonName', project_id: $project_id).try(:identifier_object)
        #Protonym.with_identifier('3i_Taxon_ID ' + key.to_s).find_by(project_id: $project_id)
      end

      def find_otu(key)
        otu = nil
        # otu = Otu.joins(taxon_name: :identifiers).where(identifiers: {cached: '3i_Taxon_ID ' + key.to_s}, project_id: $project_id).first
        # otu = Otu.joins(:identifiers).where(identifiers: {cached: '3i_Taxon_ID ' + key.to_s}, project_id: $project_id).first if otu.nil?

        r = Identifier.find_by(cached: '3i_Taxon_ID ' + key.to_s, project_id: $project_id)
        if r.identifier_object_type == 'TaxonName'
          r.identifier_object.otus.first
        elsif r.identifier_object_type == 'Otu'
          r.identifier_object
        else
          raise
        end

        # otu
      end

      def find_publication_id_3i(key3)
        @data.publications_index[key3.to_s] || Identifier.where(cached: '3i_Source_ID ' + key3.to_s).limit(1).pluck(:identifier_object_id).first
      end

      def find_publication_3i(key3)
        @data.publications_index[key3.to_s] || Identifier.where(cached: '3i_Source_ID ' + key3.to_s).limit(1).first
      end

      def handle_parasitoids_3i
        # Key
        # Order
        # Superfamily
        # Family
        # Genus
        # Species
        # Author
        # Year
        # Page
        # Key3

        path = @args[:data_directory] + 'parasitoids.txt'
        print "\nHandling parasitoids\n"
        raise "file #{path} not found" if not File.exists?(path)
        file = CSV.foreach(path, col_sep: "\t", headers: true)

        i = 0
        file.each do |row|
          i += 1
          next if row['Family'].blank?
          print "\r#{i}"
          p = Protonym.find_by(name: row['Order'], rank_class: Ranks.lookup(:iczn, 'Order'), project_id: $project_id)
          p = Protonym.find_or_create_by(name: row['Superfamily'], parent_id: p.id, rank_class: Ranks.lookup(:iczn, 'Superfamily'), project_id: $project_id) unless row['Superfamily'].blank?
          family = Protonym.find_or_create_by(name: row['Family'], rank_class: Ranks.lookup(:iczn, 'Family'), project_id: $project_id) unless row['Family'].blank?
          if family.parent_id != p.id
            family.parent_id = p.id
            family.save!
          end
          p = family
          p = Protonym.find_or_create_by(name: row['Genus'], parent_id: p.id, rank_class: Ranks.lookup(:iczn, 'Genus'), project_id: $project_id) unless row['Genus'].blank?
          p = Protonym.find_or_create_by(name: row['Species'], parent_id: p.id, rank_class: Ranks.lookup(:iczn, 'Species'), project_id: $project_id) if !row['Species'].blank? && row['Species'].to_s.length > 1
          if p.verbatim_author.blank? || p.year_of_publication.blank?
            p.verbatim_author = row['Author'] if p.verbatim_author.blank?
            p.year_of_publication = row['Year'] if p.verbatim_author.blank?
            p.save!
          end
          parasitoid = Otu.find_or_create_by(taxon_name_id: p.id, project_id: $project_id)
          taxon = find_otu(row['Key'])
          source = find_publication_id_3i(row['Key3'])
          if parasitoid && taxon
            ba = BiologicalAssociation.find_or_create_by!(biological_relationship: @parasitoid_relationship,
                                                          biological_association_subject: parasitoid,
                                                          biological_association_object: taxon,
                                                          project_id: $project_id
            )
            Citation.find_or_create_by!(citation_object: ba, source_id: source, project_id: $project_id, pages: row['Page']) unless source.blank?
          else
            print "\nRow #{row} is problematic\n"
          end
        end


      end

      def handle_transl_3i
        # Flag
        # KeyN
        # Num
        # Abr
        # LanguageName
        # Title
        # Copy"
        path = @args[:data_directory] + 'transl.txt'
        print "\nHandling transl\n"
        raise "file #{path} not found" if not File.exists?(path)
        file = CSV.foreach(path, col_sep: "\t", headers: true)

        file.each_with_index do |row, i|
          next if row['KeyN'].blank?
          if row['Abr'] == 'En'
            matrix = ObservationMatrix.find_or_create_by!(name: row['Title'])
            matrix.identifiers.find_or_create_by!(type: 'Identifier::Local::Import', namespace: @data.keywords['KeyN'], identifier: row['KeyN'])
            @data.keyn[row['KeyN']] = matrix.id
          else
            matrix = Identifier.where(cached: '3i_KeyN_ID ' + row['KeyN']).limit(1).first.identifier_object
            lng = Language.where(alpha_2: row['Abr'].downcase).limit(1).first
            a = AlternateValue.create(type: 'AlternateValue::Translation', value: row['Title'], alternate_value_object: matrix, alternate_value_object_attribute: 'name', language_id:lng.id)
          end
        end
      end

      def handle_characters_3i
        handle_morph_3i
        # Key1
        # # KeyN
        # # Char
        # # Type
        # # Weight
        # # Numeric
        # # CharRu
        # # CharEn
        # # CharDt
        # # CharFr
        # # CharSp
        # # CharZh
        # # Morph
        # # DescrRu
        # # DescrEn
        # # DescrDt
        # # DescrFr
        # # DescrSp
        # # DescrZh
        path = @args[:data_directory] + 'characters.txt'
        print "\nHandling craracters\n"
        raise "file #{path} not found" if not File.exists?(path)
        file = CSV.foreach(path, col_sep: "\t", headers: true)

        lngru = Language.where(alpha_2: 'ru').limit(1).first.id
        lngsp = Language.where(alpha_2: 'es').limit(1).first.id
        lngzh = Language.where(alpha_2: 'zh').limit(1).first.id

        i = 0
        file.each do |row|
          i += 1
          print "\r#{i}"
          t = row['Numeric'] == '1' ? 'Descriptor::Continuous' : 'Descriptor::Qualitative'
          descriptor = Descriptor.create!(name: row['CharEn'].empty? ? '?' : row['CharEn'], short_name: row['CharEn'].empty? ? '?' : row['CharEn'], type: t, position: row['Char'].to_i + 1 )
          a = AlternateValue.create(type: 'AlternateValue::Translation', value: row['CharRu'], alternate_value_object: descriptor, alternate_value_object_attribute: 'name', language_id: lngru) unless row['CharRu'].nil?
          a = AlternateValue.create(type: 'AlternateValue::Translation', value: row['CharSp'], alternate_value_object: descriptor, alternate_value_object_attribute: 'name', language_id: lngsp) unless row['CharSp'].nil?
          a = AlternateValue.create(type: 'AlternateValue::Translation', value: row['CharZh'], alternate_value_object: descriptor, alternate_value_object_attribute: 'name', language_id: lngzh) unless row['CharZh'].nil?
          descriptor.identifiers.create(type: 'Identifier::Local::Import', namespace: @data.keywords['Key1'], identifier: row['Key1'].to_s) unless row['Key1'].blank?
          descriptor.data_attributes.create(type: 'ImportAttribute', import_predicate: 'char_weight', value: row['Weight'].to_s) unless row['Weight'].blank?
          descriptor.data_attributes.create(type: 'ImportAttribute', import_predicate: 'descr_ru', value: row['DescrRu']) unless row['DescrRu'].blank?
          descriptor.data_attributes.create(type: 'ImportAttribute', import_predicate: 'descr_en', value: row['DescrEn']) unless row['DescrEn'].blank?
          descriptor.data_attributes.create(type: 'ImportAttribute', import_predicate: 'descr_sp', value: row['DescrSp']) unless row['DescrSp'].blank?
          descriptor.data_attributes.create(type: 'ImportAttribute', import_predicate: 'descr_zh', value: row['DescrZh']) unless row['DescrZh'].blank?
          descriptor.tags.create(keyword_id: @data.morph[row['Morph'].to_s]) unless row['Morph'].blank?
          descriptor.tags.create(keyword_id: @data.morph['n']) if row['Type'].include?('n')
          descriptor.tags.create(keyword_id: @data.morph['m']) if row['Type'].include?('m')
          descriptor.tags.create(keyword_id: @data.morph['f']) if row['Type'].include?('f')

          unless row['KeyN'].blank?
            row['KeyN'].gsub(' ', '').split(',').each do |kn|
              ObservationMatrixColumnItem::TaggedDescriptor.find_or_create_by!(observation_matrix_id: @data.keyn[kn], controlled_vocabulary_term_id: @data.morph[row['Morph']], project_id: $project_id) unless row['Morph'].blank?
              ObservationMatrixColumnItem::TaggedDescriptor.find_or_create_by!(observation_matrix_id: @data.keyn[kn], controlled_vocabulary_term_id: @data.morph['n'], project_id: $project_id) if row['Type'].include?('n')
              ObservationMatrixColumnItem::TaggedDescriptor.find_or_create_by!(observation_matrix_id: @data.keyn[kn], controlled_vocabulary_term_id: @data.morph['m'], project_id: $project_id) if row['Type'].include?('m')
              ObservationMatrixColumnItem::TaggedDescriptor.find_or_create_by!(observation_matrix_id: @data.keyn[kn], controlled_vocabulary_term_id: @data.morph['f'], project_id: $project_id) if row['Type'].include?('f')
              ObservationMatrixColumnItem::SingleDescriptor.create!(observation_matrix_id: @data.keyn[kn], descriptor_id: descriptor.id, position: row['Char'].to_i + 1)
            end
          end

          @data.chars[row['Key1'].to_s] = [descriptor.id, row['Numeric'].to_s]
        end
      end

      def handle_morph_3i
        # Morph
        # MorphEn
        # MorphRu
        # MorphDt
        # MorphFr
        # MorphSp
        # MorphZh
        path = @args[:data_directory] + 'morph.txt'
        print "\nHandling morph\n"
        raise "file #{path} not found" if not File.exists?(path)
        file = CSV.foreach(path, col_sep: "\t", headers: true)
        file.each_with_index do |row, i|
          kw = Keyword.find_or_create_by(name: row['MorphEn'], definition: 'Morphological group of descriptors: ' + row['MorphEn'].to_s + ' (' + row['Morph'].to_s + ')', project_id: $project_id)
          @data.morph[row['Morph'].to_s] = kw.id
        end
        kw1 = Keyword.find_or_create_by(name: 'Nymphs', definition: 'Morphological group of descriptors: Nymphs', project_id: $project_id)
        @data.morph['n'] = kw1.id unless kw1.blank?
        kw2 = Keyword.find_or_create_by(name: 'Males', definition: 'Morphological group of descriptors: Males', project_id: $project_id)
        @data.morph['m'] = kw2.id unless kw2.blank?
        kw3 = Keyword.find_or_create_by(name: 'Females', definition: 'Morphological group of descriptors: Females', project_id: $project_id)
        @data.morph['f'] = kw3.id unless kw3.blank?
      end

      def handle_state_3i
        # Key2
        # State
        # Key1
        # StateRu
        # StateEn
        # StateDt
        # StateFr
        # StateSp
        # StateZh
        # Fig
        path = @args[:data_directory] + 'state.txt'
        print "\nHandling state\n"
        raise "file #{path} not found" if not File.exists?(path)
        file = CSV.foreach(path, col_sep: "\t", headers: true)
        lngru = Language.where(alpha_2: 'ru').limit(1).first.id
        lngsp = Language.where(alpha_2: 'es').limit(1).first.id
        lngzh = Language.where(alpha_2: 'zh').limit(1).first.id
        i = 0
        file.each do |row|
          i += 1
          print "\r#{i}"
          if @data.chars[row['Key1'].to_s][1] == '1'
            @data.states[row['Key2'].to_s] = [nil, @data.chars[row['Key1'].to_s][0], row['StateEn']]
          else
            cs = CharacterState.create(name: row['StateEn'], label: row['StateEn'], descriptor_id: @data.chars[row['Key1']][0], position: row['State'].to_i + 1)
            cs.identifiers.create(type: 'Identifier::Local::Import', namespace: @data.keywords['Key2'], identifier: row['Key2']) unless row['Key2'].blank?
            a = AlternateValue.create(type: 'AlternateValue::Translation', value: row['StateRu'], alternate_value_object: cs, alternate_value_object_attribute: 'name', language_id: lngru) unless row['StateRu'].nil?
            a = AlternateValue.create(type: 'AlternateValue::Translation', value: row['StateSp'], alternate_value_object: cs, alternate_value_object_attribute: 'name', language_id: lngsp) unless row['StateSp'].nil?
            a = AlternateValue.create(type: 'AlternateValue::Translation', value: row['StateZh'], alternate_value_object: cs, alternate_value_object_attribute: 'name', language_id: lngzh) unless row['StateZh'].nil?
            cs.data_attributes.create(type: 'ImportAttribute', import_predicate: 'figure', value: row['Fig']) unless row['Fig'].blank?
            @data.states[row['Key2'].to_s] = [cs.id, @data.chars[row['Key1'].to_s][0], nil]
          end
        end
      end

      def handle_chartable_3i
        # Key
        # Key2
        # NumericFrom
        # NumericTo
        path = @args[:data_directory] + 'chartable.txt'
        print "\nHandling chartable\n"
        raise "file #{path} not found" if not File.exists?(path)
        file = CSV.foreach(path, col_sep: "\t", headers: true)
        i = 0
        file.each do |row|
          i += 1
          print "\r#{i}"
          if @data.states[row['Key2'].to_s][2].nil? # Qualitative
            o = Observation::Qualitative.create(descriptor_id: @data.states[row['Key2'].to_s][1], otu_id: find_otu(row['Key']).id, character_state_id: @data.states[row['Key2'].to_s][0] )
            byebug if o.id.nil?
          else # Sample
            o = Observation::Sample.create(descriptor_id: @data.states[row['Key2'].to_s][1], otu_id: find_otu(row['Key']).id, sample_min: row['NumericFrom'].to_f, sample_max: row['NumericTo'].to_f, sample_units: @data.states[row['Key2'].to_s][2])
            byebug if o.id.nil?
          end
        end
      end

      def soft_validations_3i
        fixed = 0
        print "\nApply soft validation fixes to taxa 1st pass \n"
        i = 0
        TaxonName.where(project_id: $project_id).find_each do |t|
          i += 1
          print "\r#{i}    Fixes applied: #{fixed}"
          t.soft_validate
          t.fix_soft_validations
          t.soft_validations.soft_validations.each do |f|
            byebug if fixed == 0 && f.fixed?
            fixed += 1  if f.fixed?
          end
        end
        print "\nApply soft validation fixes to relationships \n"
        i = 0
        TaxonNameRelationship.where(project_id: $project_id).find_each do |t|
          i += 1
          print "\r#{i}    Fixes applied: #{fixed}"
          t.soft_validate
          t.fix_soft_validations
          t.soft_validations.soft_validations.each do |f|
            fixed += 1  if f.fixed?
          end
        end
        print "\nApply soft validation fixes to taxa 2nd pass \n"
        i = 0
        TaxonName.where(project_id: $project_id).find_each do |t|
          i += 1
          print "\r#{i}    Fixes applied: #{fixed}"
          t.soft_validate
          t.fix_soft_validations
          t.soft_validations.soft_validations.each do |f|
            fixed += 1  if f.fixed?
          end
        end
      end

    end
  end
end
