require 'fileutils'

### rake tw:project_import:access3i:import_all data_directory=/Users/proceps/src/sf/import/3i/TXT/ no_transaction=true

namespace :tw do
  namespace :project_import do
    namespace :access3i do

    @import_name = '3i'

    # A utility class to index data.
    class ImportedData3i
      attr_accessor :people_index, :user_index, :publications_index, :citations_index, :genera_index, :images_index,
                    :parent_id_index, :statuses, :taxonno_index, :citation_to_publication_index, :keywords
      def initialize()
        @keywords = {}                  # keyword -> ControlledVocabularyTerm
        @people_index = {}              # PeopleID -> Person object
        @user_index = {}                # PeopleID -> User object
        @publications_index = {}        # unique_fields hash -> Surce object
        @citations_index = {}           # NEW_REF_ID -> row
        @citation_to_publication_index = {} # NEW_REF_ID -> source.id
        @genera_index = {}              # GENUS_NUMBER -> row
        @images_index = {}              # TaxonNo -> row
        @parent_id_index = {}           # Rank:TaxonName -> Taxon.id
        @statuses = {}
        @taxonno_index = {}             #TaxonNo -> Taxon.id
      end
    end

    task :import_all => [:data_directory, :environment] do |t|

      @ranks ={
          0 => '',
          1 => Ranks.lookup(:iczn, :subspecies),
          2 => Ranks.lookup(:iczn, :species),
          4 => 'NomenclaturalRank::Iczn::SpeciesGroup::SpeciesGroup',
          6 => Ranks.lookup(:iczn, :subgenus),
          7 => Ranks.lookup(:iczn, :genus),
          8 => 'NomenclaturalRank::Iczn::GenusGroup::GenusGroup',
          9 => Ranks.lookup(:iczn, :subtribe),
          10 => Ranks.lookup(:iczn, :tribe),
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
      }

      @relationship_classes = {
          0 => '', ### valid
          1 => 'TaxonNameRelationship::Iczn::Invalidating::Synonym',   #### ::Objective or ::Subjective
          2 => '', ### Original combination
          3 => 'TaxonNameRelationship::Iczn::Invalidating::Homonym::Primary',
          4 => 'TaxonNameRelationship::Iczn::Invalidating::Homonym::Secondary', #### or 'Secondary::Secondary1961'
          5 => 'TaxonNameRelationship::Iczn::Invalidating::Homonym',
          6 => 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression',
          7 => '', ###common name
          8 => '', #### combination => Combination
          9 => 'TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling',
          10 => 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::UnjustifiedEmendation',
          11 => 'TaxonNameRelationship::Iczn::Invalidating::Usage::Misapplication',
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
          'Nomen nudum: Published as synonym and not validated before 1961' => '',
          'Unavailable name: Infrasubspecific name' => '',
          'Unavailable name: pre-Linnean' => '',
          'Suppressed name: ICZN official index of rejected and invalid works' => 'TaxonNameRelationship::Iczn::Invalidating::Synonym',
          'Valid Name' => '',
          'Original_Genus' => 'TaxonNameRelationship::OriginalCombination::OriginalGenus',
          'OrigSubgen' => 'TaxonNameRelationship::OriginalCombination::OriginalSubgenus',
          'Original_Species' => 'TaxonNameRelationship::OriginalCombination::OriginalSpecies',
          'Original_Subspecies' => 'TaxonNameRelationship::OriginalCombination::OriginalSubspecies',
          'Original_Infrasubspecies' => 'TaxonNameRelationship::OriginalCombination::OriginalVariety',
          'Incertae sedis' => 'TaxonNameRelationship::Iczn::Validating::UncertainPlacement'
      }

      @classification_classes = {
          0 => '', ### valid
          12 => 'TaxonNameClassification::Iczn::Available::Valid::NomenDubium',
          13 => 'TaxonNameClassification::Iczn::Unavailable::NomenNudum',
          22 => 'TaxonNameClassification::Iczn::Unavailable::NonBinomial',
          24 => 'TaxonNameClassification::Iczn::Unavailable',
          28 => 'TaxonNameClassification::Iczn::Available::Invalid',
          29 => 'TaxonNameClassification::Iczn::Unavailable::Excluded::Infrasubspecific', ### infrasubspecific
      }

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

      handle_controlled_vocabulary_3i
      handle_references_3i
      ###handle_list_of_genera_lepindex
      ###handle_images_lepindex
      ###handle_species_lepindex
      ####soft_validations_lepindex

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
        $user_id = user.id # set for project line below

        project = nil
        #project = Project.where(name: project_name).first #################### Comment fot creating a new one
        if project.nil?
          project = Project.create(name: project_name)
        end

        $project_id = project.id
        pm = ProjectMember.new(user: user, project: project, is_project_administrator: true)
        pm.save! if pm.valid?

        @import.metadata['project_and_users'] = true
      end
      root = Protonym.find_or_create_by(name: 'Root', rank_class: 'NomenclaturalRank', project_id: $project_id)

      @data.keywords.merge!('3i_imported' => Keyword.find_or_create_by(name: '3i_imported', definition: 'Imported from 3i database.'))
    end


    def handle_controlled_vocabulary_3i
      print "Handling CV "

      @data.keywords.merge!(
          #'AuthorDrMetcalf' => Predicate.find_or_create_by(name: 'AuthorDrMetcalf', definition: 'Author name from DrMetcalf bibliography database.'),
          '3i_imported' => Keyword.find_or_create_by(name: '3i_imported', definition: 'Imported from 3i database.'),
          'CallNumberDrMetcalf' => Predicate.find_or_create_by(name: 'CallNumberDrMetcalf', definition: 'Call Number from DrMetcalf bibliography database.'),
          'AuthorReference' => Predicate.find_or_create_by(name: 'AuthorReference', definition: 'Author string as it appears in the nomenclatural reference.'),
          'YearReference' => Predicate.find_or_create_by(name: 'YearReference', definition: 'Year string as it appears in the nomenclatural reference.'),
          'IDDrMetcalf' => Namespace.find_or_create_by(name: 'DrMetcalf_ID', short_name: 'DrMetcalf_ID'),
          'Key3' => Namespace.find_or_create_by(name: '3i_Source_ID', short_name: '3i_Source_ID'),
          'FLOW-ID' => Namespace.find_or_create_by(name: 'FLOWSourceID', short_name: 'FLOW_Source_ID'),
          'Taxonomy' => Keyword.find_or_create_by(name: 'Taxonomy updated', definition: 'Taxonomical information entered to the DB.'),
          'Typhlocybinae' => Keyword.find_or_create_by(name: 'Typhlocybinae updated', definition: 'Information related to Typhlocybinae entered to the DB.'),
          'Illustrations' => Keyword.find_or_create_by(name: 'Illustrations exported', definition: 'Illustrations of Typhlocybinae species entered to the DB.'),
          'Distribution' => Keyword.find_or_create_by(name: 'Distribution exported', definition: 'Illustrations on species distribution entered to the DB.'),
      )
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
      # Key3C ---- Not export
      # Key3D ---- Not export

      path = @args[:data_directory] + 'literature.txt'
      print "\nHandling references\n"
      raise "file #{path} not found" if not File.exists?(path)
      file = CSV.foreach(path, col_sep: "\t", headers: true)
      language = %w(French Russian German Japanese Chinese English Korean Polish Italian Georgian )

      file.each_with_index do |row, i|
        print "\r#{i}"
        journal, serial_id, volume, pages = parse_bibliography_3i(row['Bibliography'])
        year, year_suffix = parse_year_3i(row['Year'])
        taxonomy, distribution, illustration, typhlocybinae = nil, nil, nil, nil
        note = row['Notes']
          source = Source::Bibtex.new( volume: nil,
                                       author: row['AuthorDrMetcalf'].blank? ? row['Author'] : row['AuthorDrMetcalf'],
                                       year: year,
                                       year_suffix: year_suffix,
                                       title: row['Title'],
                                       journal: journal,
                                       serial_id: serial_id,
                                       pages: pages,
                                       volume: volume,
                                       bibtex_type: 'article',
                                       tags_attributes: [ { keyword: @data.keywords['3i_imported'] } ]
          )

        source.alternate_values.new(value: row['Author'], type: 'AlternateValue::Abbreviation', alternate_value_object_attribute: 'author') if !row['AuthorDrMetcalf'].blank? && row['AuthorDrMetcalf'] != row['Author']

        InternalAttribute.new(attribute_subject: source, predicate: @data.keywords['CallNumberDrMetcalf'], value: row['CallNumberDrMetcalf']) unless row['CallNumberDrMetcalf'].blank?

        source.data_attributes.new(type: 'ImportAttribute', import_predicate: 'Author3i', value: row['AY']) unless row['AY'].blank?
        source.data_attributes.new(type: 'ImportAttribute', import_predicate: 'YearReference', value: row['Year']) unless row['Year'].blank?
        source.data_attributes.new(type: 'ImportAttribute', import_predicate: 'BibliographyReference', value: row['Bibliography']) unless row['Bibliography'].blank?


        if !note.nil? && note.include?('Taxonomy only and distribution')
          source.tags.new(keyword: @data.keywords['Distribution'])
          note.gsub!(' and distribution', '')
        end
        if !note.nil? && note.include?('Taxonomy only')
          source.tags.new(keyword: @data.keywords['Taxonomy'])
          note.gsub!('Taxonomy only', '')
        end
        if !note.nil? && note.index('T ') == 1
          source.tags.new(keyword: @data.keywords['Typhlocybinae'])
          note = note[2..-1]
        end
        if !note.nil? && note.include?('Illustrations done')
          source.tags.new(keyword: @data.keywords['Illustrations'])
          note.gsub!('Illustrations done', '')
        end
        note.squish! unless note.nil?

        source.notes.new(text: row['NotesDrMetcalf']) unless row['NotesDrMetcalf'].blank?
        source.notes.new(text: note) unless note.blank?

        language.each do |l|
          if (row['Notes'].to_s + ' ' + row['Bibliography'].to_s).include?('In ' + l)
            source.language = Language.where(english_name: l).first
          end
        end

        source.identifiers.new(type: 'Identifier::Local::Import', namespace: @data.keywords['IDDrMetcalf'], identifier: row['IDDrMetcalf']) unless row['IDDrMetcalf'].blank?
        source.identifiers.new(type: 'Identifier::Local::Import', namespace: @data.keywords['Key3'], identifier: row['Key3']) unless row['Key3'].blank?
        source.identifiers.new(type: 'Identifier::Local::Import', namespace: @data.keywords['FLOW-ID'], identifier: row['FLOW-ID']) if !row['FLOW-ID'].blank? && !row['FLOW-ID'] == '0'

        source.project_sources.new

        if source.valid?
          source.save!
          @data.publications_index.merge!(row['Key3'] => source.id)
        else
          byebug
        end
      end

      puts "\nResolved #{@data.publications_index.keys.count} publications\n"

    end

    def parse_bibliography_3i(bibl)
      return nil, nil, nil, nil if bibl.blank?

      matchdata = bibl.match(/(^.+)\s+(\d+\(.+\)|\d+): *(\d+-\d+|\d+–\d+|\d+)\.*\s*(.*$)/)
      return bibl, nil, nil, nil if matchdata.nil?

      serial = Serial.where(name: matchdata[1]).first
      serial ||= Serial.with_any_value_for(:name, matchdata[1]).first
      serial_id = serial.nil? ? nil : serial.id
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



    end
  end
end
