require 'fileutils'

### rake tw:project_import:access_odonata:import_all data_directory=/Users/proceps/src/sf/import/odonata/TXT/ no_transaction=true
### rake tw:db:restore backup_directory=/Users/proceps/src/sf/import/odonata/pg_dumps/ file=localhost_2018-05-15_200847UTC.dump
# ./bin/webpack-dev-server



namespace :tw do
  namespace :project_import do
    namespace :access_odonata do

      @import_name = 'odonata'

      # A utility class to index data.
      class ImportedDataOdonata
        attr_accessor :keywords, :publications_index, :taxon_index
        def initialize()
          @keywords = {}
          @publications_index = {}
          @taxon_index = {}
        end
      end

      task import_all: [:data_directory, :environment] do |t|

        @ranks = {
            0 => Ranks.lookup(:iczn, :subspecies),
            1 => Ranks.lookup(:iczn, :species),
            2 => Ranks.lookup(:iczn, :genus),
            3 => Ranks.lookup(:iczn, :subfamily),
            4 => Ranks.lookup(:iczn, :family),
            5 => Ranks.lookup(:iczn, :superfamily),
            6 => Ranks.lookup(:iczn, :suborder),
            7 => Ranks.lookup(:iczn, :order)
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

        if ENV['no_transaction']
          puts 'Importing without a transaction (data will be left in the database).'
          main_build_loop_odonata
        else

          ApplicationRecord.transaction do
            begin
              main_build_loop_odonata
            rescue
              raise
            end
          end

        end

      end

      def main_build_loop_odonata
        print "\nStart time: #{Time.now}\n"

        @import = Import.find_or_create_by(name: @import_name)
        @import.metadata ||= {}
        @data =  ImportedDataOdonata.new
        puts @args
        Utilities::Files.lines_per_file(Dir["#{@args[:data_directory]}/**/*.txt"])

        handle_projects_and_users_odonata

#        $project_id = 16
#        $user_id = 1
        raise '$project_id or $user_id not set.'  if $project_id.nil? || $user_id.nil?
#        @root = Protonym.find_or_create_by(name: 'Root', rank_class: 'NomenclaturalRank', project_id: $project_id) if @root.blank?

        handle_controlled_vocabulary_odonata
        handle_references_odonata
        handle_taxonomy_odonata
        handle_taxon_name_relationships_odonata
        handle_common_names_odonata
        handle_distribution_odonata

        #soft_validations_odonata
        print "\n\n !! Success. End time: #{Time.now} \n\n"
      end

      def handle_projects_and_users_odonata
        print "\nHandling projects and users "
        email = 'arboridia@gmail.com'
        project_name = 'Odonata'
        user_name = 'Odonata Import'
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
        #@data.keywords['odonata_imported'] = Keyword.find_or_create_by(name: 'odonata_imported', definition: 'Imported from odonata database.')
      end

      def handle_controlled_vocabulary_odonata
        print "\nHandling CV \n"

        @data.keywords.merge!(
            'questionable' => Keyword.find_or_create_by(name: 'Original genus is questionable', definition: 'Original genus is questionable', project_id: $project_id),
            'ref_id' => Namespace.find_or_create_by(institution: 'Odonata', name: 'Odonata_ref_ID', short_name: 'ref_ID'),
            'accession_number' => Namespace.find_or_create_by(institution: 'Odonata', name: 'Odonata_accession_number', short_name: 'accession_number'),
            'Key' => Namespace.find_or_create_by(institution: 'Odonota', name: 'Odonata_taxon_ID', short_name: 'taxon_ID'),
            'Synonym' => Namespace.find_or_create_by(institution: 'Odonota', name: 'Odonata_synonym_ID', short_name: 'synonym_ID'),
            'CN' => Namespace.find_or_create_by(institution: 'Odonota', name: 'Odonata_common_name_ID', short_name: 'common_name_ID'),
        )
      end

      def handle_references_odonata

        # id
        # Abstract
        # Accession_Number
        # Author
        # year1
        # Title
        # Secondary_Title
        # vol
        # num
        # Citation
        # File_Attachments
        # Place_Published
        # Publisher
        # Reference_Notes
        # url

        path = @args[:data_directory] + 'references.txt'
        print "\nHandling references\n"
        raise "file #{path} not found" if not File.exists?(path)
        file = CSV.foreach(path, col_sep: "\t", headers: true)

        i = 0
        file.each do |row|
          i += 1
          print "\r#{i}"
          journal, serial_id, volume, pages = parse_bibliography_odonata(row['Citation'], row['Secondary_Title'])
          taxonomy, distribution, illustration, typhlocybinae = nil, nil, nil, nil
          note = row['Notes']
          author = row['Author'].to_s.gsub('., ', '.|').split('|').compact.join(' and ')
          if !row['vol'].blank? && !row['num'].blank?
            volume = row['vol'].to_s + '(' + row['num'].to_s + ')'
          elsif !row['vol'].blank?
            volume = row['vol']
          else
            volume = nil
          end
          year = row['year1'] == '0' ? nil : row['year1']
          source = Source::Bibtex.find_or_create_by( author: author,
                                                     year: year,
                                                     title: row['Title'],
                                                     journal: row['Secondary_Title'],
                                                     serial_id: serial_id,
                                                     pages: pages,
                                                     volume: volume,
                                                     bibtex_type: 'article',
                                                     abstract: row['Abstract'],
                                                     publisher: row['Publisher'],
                                                     organization: row['Place_Published'],
                                                     url: row['url']
          )

          # id
          # Accession_Number
          source.notes.new(text: note) unless note.blank?
          source.data_attributes.new(type: 'ImportAttribute', import_predicate: 'citation', value: row['Citation']) unless row['Citation'].blank?
          source.data_attributes.new(type: 'ImportAttribute', import_predicate: 'file_attachments', value: row['File_Attachments']) unless row['File_Attachments'].blank?
          source.identifiers.new(type: 'Identifier::Local::Import', namespace: @data.keywords['ref_id'], identifier: row['id']) unless row['id'].blank?
          source.identifiers.new(type: 'Identifier::Local::Import', namespace: @data.keywords['accession_number'], identifier: row['Accession_Number']) unless row['Accession_Number'].blank?

          begin
            source.save!
            @data.publications_index[row['id']] = source.id
            source.project_sources.create!
          rescue ActiveRecord::RecordInvalid
            puts "\nDuplicate record: #{row}\n"
          end
        end

        puts "\nResolved #{@data.publications_index.keys.count} publications\n"

      end

      def parse_bibliography_odonata(bibl, j)
        return nil, nil, nil, nil if bibl.blank?

        matchdata = bibl.match(/(^.+)\s+(\d+\(.+\)|\d+)(:|\(|\)) *(\d+-\d+|\d+–\d+|\d+)\.*\s*(.*$)/)
        return bibl, nil, nil, nil if matchdata.nil?

        serial_id = Serial.where(name: j).limit(1).pluck(:id).first
        serial_id ||= Serial.with_any_value_for(:name, j).limit(1).pluck(:id).first
        journal = matchdata[4].blank? ? matchdata[1] : bibl
        volume = matchdata[2]
        pages = matchdata[4]
        return journal, serial_id, volume, pages
      end

      def handle_taxonomy_odonata

        # id
        # parent_id
        # Author
        # OriginalGenus
        # TaxaName
        # TaxaNotes
        # year1
        # rank
        # Type

        path = @args[:data_directory] + 'taxa.txt'
        print "\nHandling taxonomy\n"
        raise "file #{path} not found" if not File.exists?(path)
        file = CSV.foreach(path, col_sep: "\t", headers: true)

        i = 0
        file.each do |row|
          i += 1
          print "\r#{i}"
          #next if i < 2825
          #byebug
          parent = @root if row['parent_id'] == '0
'
            name = row['TaxaName']
            parent = row['parent_id'] == '0' ? @root : find_taxon_odonata(row['parent_id'])

            byebug if parent.nil?
            rank = @ranks[row['rank'].to_i]
            byebug if rank.blank?
            year = row['year1'] unless row['year1'] == '0'

            taxon = Protonym.new( name: name,
                                  parent: parent,
                                  year_of_publication: year,
                                  verbatim_author: row['Author'],
                                  rank_class: rank,
                                  also_create_otu: true
            )

            taxon.identifiers.new(type: 'Identifier::Local::Import', namespace: @data.keywords['Key'], identifier: row['id'])
            taxon.notes.new(text: row['TaxaNotes']) unless row['TaxaNotes'].blank?

          if !row['OriginalGenus'].blank?
            og = find_original_genus_odonata(row['OriginalGenus'])
            taxon.original_genus = og unless og.nil?
            taxon.original_species = taxon unless og.nil?
          end

            begin
              taxon.save!
              @data.taxon_index[row['id']] = taxon.id

            rescue ActiveRecord::RecordInvalid
              taxon.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::Unavailable::NotLatin') if taxon.rank_string =~ /Family/ && row['Status'] != '0' && !taxon.errors.messages[:name].blank?
              taxon.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::Unavailable::NotLatin') if taxon.rank_string =~ /Species/ && row['Status'] != '0' && taxon.errors.full_messages.include?('Name name must be lower case')
              taxon.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::Unavailable::NotLatin') if taxon.rank_string =~ /Species/ && row['Status'] != '0' && taxon.errors.full_messages.include?('Name Name must be latinized, no digits or spaces allowed')
              taxon.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::Unavailable::NotLatin') if taxon.rank_string =~ /Genus/ && row['Status'] != '0' && taxon.errors.full_messages.include?('Name Name must be latinized, no digits or spaces allowed')

              if taxon.valid?
                taxon.save!
                @data.taxon_index[row['id']] = taxon.id
              else
                print "\n#{row['id']}         #{row['Name']}"
                print "\n#{taxon.errors.full_messages}\n"
                #byebug
              end
            end
        end
      end

      def handle_common_names_odonata

        # comm_name
        # taxonID
        # CommonName
        # Notes

        path = @args[:data_directory] + 'common_names.txt'
        print "\nHandling common names\n"
        raise "file #{path} not found" if not File.exists?(path)
        file = CSV.foreach(path, col_sep: "\t", headers: true)
        lng = Language.find_by_alpha_3_bibliographic('eng')

        i = 0
        file.each do |row|
          i += 1
          print "\r#{i}"
          taxon = find_otu_odonata(row['taxonID'])
          unless taxon.nil?
            c = CommonName.create!(otu: taxon, name: row['CommonName'], language: lng)
            c.identifiers.create(type: 'Identifier::Local::Import', namespace: @data.keywords['CN'], identifier: row['comm_name']) unless row['comm_name'].blank?
            c.notes.create(text: row['Notes']) unless row['Notes'].blank?
          end
        end
      end

      def handle_taxon_name_relationships_odonata
        path = @args[:data_directory] + 'synonyms.txt'
        print "\nHandling taxon name synonyms\n"
        raise "file #{path} not found" if not File.exists?(path)
        file = CSV.foreach(path, col_sep: "\t", headers: true)

        # syn_id
        # taxon_id
        # Synonym

        #result = TaxonWorks::Vendor::Biodiversity::Result.new(query_string: 'Arboridia (Bus) aus Ivanon, 1975', project_id: 1, code: :iczn)
        #result.genus
        #result.subgenus
        #result.species
        #result.subspecies
        #result.variety
        #result.author
        #result.year
        #result.finest_rank
        # result.parseable

        # result.protonym_result[:genus].first



        i = 0
        file.each do |row|
          i += 1
          print "\r#{i} (Synonyms)"
          #next if i<1737
          next if row['Synonym'].blank?
          matchdata = row['Synonym'].to_s.gsub('race?', '').gsub('race', '').gsub(' forma ', ' ').match(/(Syn|syn|syn.|\s*)\.*\s*\?*([\w\s.,'’?&öüéäöñá-]*)(\s+[\(|\[][\w\s.?,\)\(;&ü\]\[]*[\)|\]][\w\s,]*$|$)/)
          print "\n#{row['Synonym']}\n" if matchdata.blank?

          string = matchdata[0]
          name = matchdata[2].gsub('?', '')
          status = matchdata[3]

          result = TaxonWorks::Vendor::Biodiversity::Result.new(query_string: name, project_id: 1, code: :iczn)

          if result.parseable
            print "\n#{row['Synonym']} match is blank\n" if matchdata.blank? || name.blank?
            print "\n#{row['Synonym']} genus is blank\n" if result.genus.blank?
            print "\n#{row['Synonym']} species is blank\n" if result.species.blank?
            next if result.species.blank?
            print "\n#{row['Synonym']} author is blank\n" if result.author.blank?
            print "\n#{row['Synonym']} subspecies and variety both present\n" if !result.subspecies.blank? && !result.variety.blank?
            print "\n#{row['Synonym']} name is blank\n" if name.blank?

            valid_taxon = find_taxon_odonata(row['taxon_id'])
            print "\n#{row['Synonym']} valid taxon not found\n" if valid_taxon.nil?
            next if valid_taxon.nil?
           species, subspecies, variety = nil, nil, nil
            case result.finest_rank
              when :genus
                name1 = result.genus
              when :species
                name1 = result.species
              when :subspecies
                name1 = result.subspecies
              when :variety
                name1 = result.variety
              when :form
                name1 = result.form
            end
            genus_name = result.genus
            species_name = result.species
            subspecies_name = result.subspecies
            variety_name = result.variety
            form_name = result.form
            taxon = Protonym.create( name: name1, parent_id: valid_taxon.parent_id, year_of_publication: result.year, verbatim_author: result.author, rank_class: valid_taxon.rank_class)
            genus = find_original_genus_odonata(result.genus)
            species = nil
            if !variety_name.blank? || !subspecies_name.blank? || !form_name.blank?
              list_of_species = result.protonym_result[:genus]
              list_of_species.each do |t|
                species = t if t.cached.include?(result.genus)
              end
            end
            species = taxon if species.nil? && !species_name.blank?
            variety = variety_name.blank? ? nil : taxon
            form = form_name.blank? ? nil : taxon
            subspecies = subspecies_name.blank? ? nil : taxon
            taxon.original_genus = genus unless genus.nil?
            taxon.original_species = species unless species.nil?
            taxon.original_subspecies = subspecies unless subspecies.nil?
            taxon.original_variety = variety unless variety.nil?
            taxon.original_form = form unless form.nil?
            taxon.identifiers.new(type: 'Identifier::Local::Import', namespace: @data.keywords['Synonym'], identifier: row['syn_id']) unless row['syn_id'].blank?
            taxon.data_attributes.new(type: 'ImportAttribute', import_predicate: 'synonym_string', value: row['Synonym']) unless row['Synonym'].blank?
            if status.include?('nomen nudum')
              taxon.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::Unavailable::NomenNudum')
            end
            begin
              taxon.save!
            rescue ActiveRecord::RecordInvalid
              byebug
            end
            if status.include?('lapsus')
              tnr = TaxonNameRelationship.create(subject_taxon_name: taxon, object_taxon_name: valid_taxon, type: 'TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling')
            elsif status.include?('nec ') || status.include?('nomen nudum')
              tnr = TaxonNameRelationship.create(subject_taxon_name: taxon, object_taxon_name: valid_taxon, type: 'TaxonNameRelationship::Iczn::Invalidating')
            else
              tnr = TaxonNameRelationship.create(subject_taxon_name: taxon, object_taxon_name: valid_taxon, type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym')
            end

          else
            print "\n#{row['Synonym']} not parseable\n" if matchdata.blank?
          end

        end
      end


      def handle_distribution_odonata

        # id
        # taxon_id
        # Questionable
        # IdTD

        path = @args[:data_directory] + 'distribution.txt'
        print "\nHandling distribution\n"
        raise "file #{path} not found" if not File.exists?(path)
        file = CSV.foreach(path, col_sep: "\t", headers: true)
        conf = ConfidenceLevel.find_or_create_by(name: 'Questionable', definition: 'Asserted Distribution is Questionable', project_id: $project_id).id,


            source = Source::Verbatim.find_or_create_by!(verbatim: 'Odonata database')
        i = 0
        file.each do |row|
          i += 1
          print "\r#{i}"
          otu = find_otu_odonata(row['taxon_id'])
          country = row['IdTD']
          ga = GeographicArea.find(country)

          if !otu.nil? && !source.nil? && !ga.nil?
            ad = AssertedDistribution.find_or_create_by(
                otu: otu,
                geographic_area: ga,
                project_id: $project_id )
            c = ad.citations.new(source_id: source.id, project_id: $project_id)
            ad.save
            byebug if ad.id.nil?
            ad.confidences.create(confidence_level_id: conf) if row['Questionable'] = '?'
          end
        end
      end

      def handle_countries_odonata
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

      def add_identifiers_odonata(objects, row)
        return nil if row['ID'].blank?
        ns = 'INHS'
        i = row['ID']
        @data.namespaces.each_key do |p|
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

      def find_taxon_id_odonata(key)
        @data.taxon_index[key.to_s] || Identifier.where(cached: 'taxon_ID ' + key.to_s, identifier_object_type: 'TaxonName', project_id: $project_id).limit(1).pluck(:identifier_object_id).first
      end

      def find_taxon_odonata(key)
        Identifier.find_by(cached: 'taxon_ID ' + key.to_s, identifier_object_type: 'TaxonName', project_id: $project_id).try(:identifier_object)
      end

      def find_original_genus_odonata(genus)
        if genus.to_i > 0
          g = find_taxon_odonata(genus)
          return g unless g.nil?
        end

        g = Protonym.find_by(name: genus, rank_class: 'NomenclaturalRank::Iczn::GenusGroup::Genus', project_id: $project_id)
        if g.nil?
          o = Protonym.find_by(name: 'Odonata', rank_class: 'NomenclaturalRank::Iczn::HigherClassificationGroup::Order', project_id: $project_id)
          g = Protonym.create!(name: genus.gsub('?', ''), parent: o, rank_class: 'NomenclaturalRank::Iczn::GenusGroup::Genus')
          g.tags.create(keyword: @data.keywords['questionable']) if genus.include?('?')
        end
        return g unless g.id.nil?
        return nil
      end


      def find_otu_odonata(key)
        otu = nil

        r = Identifier.find_by(cached: 'taxon_ID ' + key.to_s, project_id: $project_id)
        return nil if r.nil?
        if r.identifier_object_type == 'TaxonName'
          r.identifier_object.otus.first
        elsif r.identifier_object_type == 'Otu'
          r.identifier_object
        else
          raise
        end

        # otu
      end

      def find_publication_id_odonata(key3)
        @data.publications_index[key3.to_s] || Identifier.where(cached: 'Odonata_ref_ID' + key3.to_s).limit(1).pluck(:identifier_object_id).first
      end

      def find_publication_odonata(key3)
        @data.publications_index[key3.to_s] || Identifier.where(cached: 'Odonata_ref_ID ' + key3.to_s).limit(1).first
      end

      def soft_validations_odonata
        fixed = 0
        print "\nApply soft validation fixes to taxa 1st pass \n"
        i = 0
        TaxonName.where(project_id: $project_id).find_each do |t|
          i += 1
          print "\r#{i}    Fixes applied: #{fixed}"
          t.soft_validate
          t.fix_soft_validations
          t.soft_validations.soft_validations.each do |f|
#            byebug if fixed == 0 && f.fixed?
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