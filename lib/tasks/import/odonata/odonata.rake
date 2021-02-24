require 'fileutils'

### rake tw:project_import:odonata:import_all_odonata_index data_directory=/Users/proceps/src/sf/import/odonata/odonata_new/TXT no_transaction=true

namespace :tw do
  namespace :project_import do
    namespace :odonata do

      # A utility class to index data.
      class ImportedData
        attr_accessor :taxon_index, :user_index, :genus_id, :parent_id, :species_id

        def initialize()
          @taxonno_index = {}                 #TaxonNo -> Taxon.id
          @user_index = {}
          @genus_id = {}
          @species_id = {}
          @parent_id = {}
        end
      end

      task import_all_odonata_index: [:data_directory, :environment] do |t|
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
        puts Rainbow("\nStart time: #{Time.now}\n").yellow

        @data =  ImportedData.new

        puts Rainbow(@args).gray

        Utilities::Files.lines_per_file(Dir["#{@args[:data_directory]}/**/*.txt"])

        handle_projects_and_users_odonata
        handle_list_of_higher_taxa_odonata
        handle_list_of_species_odonata
        soft_validations_odonata

        puts Rainbow("\n\n !! Success. End time: #{Time.now} \n\n").yellow
      end

      def handle_projects_and_users_odonata
        $user_id, $project_id = nil, nil

        print "\nHandling projects and users "
        email = 'jabbott1@ua.edu'
        user_name = 'John Abbott'

        project_name = 'Odonata' +  Time.now.to_s

        user = User.where(email: email).first
        user ||= User.create!(email: email, password: '3242341aas', password_confirmation: '3242341aas', name: user_name, self_created: true, is_flagged_for_password_reset: true)
        Current.user_id = user.id

        # Always start with a new project
        project = Project.create!(name: project_name)
        Current.project_id = project.id

        raise Rainbow('Current.project_id or Current.user_id not set.').red if Current.project_id.nil? || Current.user_id.nil?

        pm = ProjectMember.create!(user: user, project: project, is_project_administrator: true)

        @root = project.root_taxon_name

        u = User.where(email: 'arboridia@gmail.com').first
        pm = ProjectMember.create!(user: u, project: project, is_project_administrator: true)

      end

      def handle_list_of_higher_taxa_odonata
        # Genus
        # Genus_ID
        # Rank
        # Author
        # Common
        ## creation date
        ## First_author
        ## Full_name
        ## modification date
        # notes
        # Taxonomic_status : 'unavailable', 'subsequent misspelling'
        # Tribe
        ## Type species
        ## Type_reason
        # validity : 'Valid Name', 'Needs correction', 'Junior synonym', 'Invalid name'
        # Year

        path = @args[:data_directory] + '/' + 'HigherTaxa.txt'
        print "\nHandling higher taxa\n"
        raise "file #{path} not found" if not File.exists?(path)

        file = CSV.foreach(path, col_sep: "\t", headers: true)
        ['Kingdom', 'Phylum', 'Subphylum', 'Class', 'Order', 'Suborder', 'Family', 'Genus'].each do |rank|
          puts "\n !! Rank: #{rank} \n"
          file.each_with_index do |row, i|
            print "\r#{i}"
            next if row['Rank'] != rank

            p = Protonym.new(name: row['Genus'],
                             parent_id: @data.parent_id[row['Tribe']],
                             rank_class: Ranks.lookup(:iczn, row['Rank'].downcase),
                             verbatim_author: row['Author'],
                             year_of_publication: row['Year'],
                             also_create_otu: true)
            p.parent_id = @root.id if p.parent_id.nil?
            p.save
            unless p.id.nil?
              @data.parent_id[row['Genus']] = p.id
              @data.genus_id[row['Genus_ID']] = p.id
              CommonName.create!(otu: p.otus.first, name: row['Common']) unless row['Common'].blank?
              p.notes.create(text: row['notes']) unless row['notes'].blank?
              p.data_attributes.create(import_predicate: 'Taxonomic_status', value: row['Taxonomic_status'], type: 'ImportAttribute') unless row['Taxonomic_status'].blank?
              p.data_attributes.create(import_predicate: 'Validity', value: row['validity'], type: 'ImportAttribute') unless row['validity'].blank?
              p.taxon_name_classifications.create(type: 'TaxonNameClassification::Iczn::Unavailable') if row['validity'] == 'unavailable'
            end
          end
        end

        puts "\nResolved #{@data.genus_id.keys.count} genera\n"

      end

      def handle_list_of_species_odonata
        # Author
        ## Genus_Species
        # Genus
        # Species
        # Species_ID
        # Genus_ID
        ## Up::Tribe
        # Genus_orig
        ## Junior_synonyms
        # Senior_ID
        ## Senior_Junior
        ## Subgenus
        # Subspecies
        # Taxonomic_status : 'nomen oblitum', 'nomen oblitum?', 'nomen nudum', 'lapsus', 'doubtful species', 'doubtful'
        ## validity
        ## Junior_synonym::Full_name
        # Year
        ## Junior_synonym::mark_junior
        ## Senior_synonym::Full_name
        ## Up::Higher_taxa Up::Up2
        # Common
        ## Up::Up3
        ## A_Y
        # Coden
        ## creation date
        # Distribution
        ## First_author found
        ## Full_name_NA
        ## New_gen
        # Region
        ## searchname
        # Species notes
        ## Species_ID_storage
        ## temporary mark
        # Type depository
        # Type locality
        # Type_kind : 'holotype', 'Holotype'
        # Type_stage : 'male', 'Adult', 'adult'
        ## PrimaryRef::complete_reference
        # Variety : 'var. ...', nothing, 'race? ...', 'race [?] ...', 'race ...', 'form ...'
        ## ID
        ## Reflink::Citation_ID

        stage = {
            'Adult' => BiocurationClass.find_or_create_by(name: 'Adult', definition: 'Number of adult specimens.', project_id: Current.project_id),
            'adult' => BiocurationClass.find_or_create_by(name: 'Adult', definition: 'Number of adult specimens.', project_id: Current.project_id),
            'Males' => BiocurationClass.find_or_create_by(name: 'Male', definition: 'Number of male specimens.', project_id: Current.project_id)}


        path = @args[:data_directory] + '/' + 'Species.txt'
        print "\nHandling species\n"
        raise "file #{path} not found" if not File.exists?(path)

        file = CSV.foreach(path, col_sep: "\t", headers: true)
        ['species', 'subspecies', 'variety'].each do |rank|
          puts "\n !! Rank: #{rank} \n"
          file.each_with_index do |row, i|
            print "\r#{i}"

            next if rank == 'species' && (row['Species'].blank? || !row['Subspecies'].blank? || !row['Variety'].blank?)
            next if rank == 'subspecies' && (row['Species'].blank? || row['Subspecies'].blank? || !row['Variety'].blank?)
            next if rank == 'variety' && (row['Species'].blank? || row['Variety'].blank?)

            case rank
            when 'species'
              name = row['Species']
              parent_id = @data.genus_id[row['Genus_ID']]
              parent_id = @data.parent_id[row['Genus']] if parent_id.nil?
              if parent_id.nil?
                p = Protonym.create(name: row['Genus'], parent_id: @root.id, rank_class: Ranks.lookup(:iczn, 'genus'))
                @data.parent_id[row['Genus']] = p.id unless p.id.nil?
              end
              rank_cl = Ranks.lookup(:iczn, 'species')
            when 'subspecies'
              name = row['Subspecies']
              parent_id = @data.parent_id[row['Genus'].to_s + '_' + row['Species'].to_s]
              rank_cl = Ranks.lookup(:iczn, 'subspecies')
            when 'variety'
              name = row['Variety'].gsub('var. ', '').gsub('race? ', '').gsub('race [?] ', '').gsub('race ', '').gsub('form ', '')
              parent_id = @data.parent_id[row['Genus'].to_s + '_' + row['Species'].to_s + '_' + row['Subspecies'].to_s]
              parent_id = @data.parent_id[row['Genus'].to_s + '_' + row['Species'].to_s] if row['Subspecies'].blank?
              rank_cl = Ranks.lookup(:iczn, 'subspecies')
            end
            parent_id = @root.id if parent_id.nil?

            p = Protonym.create(name: name,
                             parent_id: parent_id,
                             rank_class: rank_cl,
                             verbatim_author: row['Author'],
                             year_of_publication: row['Year'],
                             also_create_otu: true)
            if p.id.nil?
              puts "\n !! Species_ID #{row['Species_ID']} not exported \n"
            else
              @data.parent_id[[row['Genus'], row['Species'], row['Subspecies'] ].compact.join('_')] = p.id unless rank == 'variety'
              @data.species_id[row['Species_ID']] = p.id
              CommonName.create!(otu: p.otus.first, name: row['Common']) unless row['Common'].blank?
              p.notes.create(text: row['Species notes']) unless row['Species notes'].blank?
              p.data_attributes.create(import_predicate: 'Coden', value: row['Coden'], type: 'ImportAttribute') unless row['Coden'].blank?
              p.data_attributes.create(import_predicate: 'Distribution', value: row['Distribution'], type: 'ImportAttribute') unless row['Distribution'].blank?
              p.data_attributes.create(import_predicate: 'Region', value: row['Region'], type: 'ImportAttribute') unless row['Region'].blank?
              p.taxon_name_classifications.create(type: 'TaxonNameClassification::Iczn::Unavailable::NomenNudum') if row['Taxonomic_status'] == 'nomen nudum'
              p.taxon_name_classifications.create(type: 'TaxonNameClassification::Iczn::Available::Valid::NomenDubium') if row['Taxonomic_status'] == 'doubtful species' || row['Taxonomic_status'] == 'doubtful'
              original_genus_id = @data.parent_id[row['Genus_orig']]
              if original_genus_id.nil? && row['Genus_orig']
                par = Protonym.create(name: row['Genus_orig'], parent_id: @root.id, rank_class: Ranks.lookup(:iczn, 'genus'))
                @data.parent_id[row['Genus_orig']] = par.id unless par.id.nil?
                original_genus_id = par.id
              end
              p.original_genus = Protonym.find(original_genus_id) unless original_genus_id.nil?
              case rank
              when 'species'
                p.original_species = p
              when 'subspecies'
                p.original_subspecies = p
                p.original_species = Protonym.find(@data.parent_id[row['Genus'].to_s + '_' + row['Species'].to_s]) if @data.parent_id[row['Genus'].to_s + '_' + row['Species'].to_s]
              when 'variety'
                if row['Variety'].to_s.include?('form ')
                  p.original_form = p
                else
                  p.original_variety = p
                  p.taxon_name_classifications.create(type: 'TaxonNameClassification::Iczn::Unavailable::Excluded::Infrasubspecific') if row['Variety'].to_s.include?('race ')
                end
                p.original_species = Protonym.find(@data.parent_id[row['Genus'].to_s + '_' + row['Species'].to_s]) if @data.parent_id[row['Genus'].to_s + '_' + row['Species'].to_s]
                p.original_subspecies = Protonym.find(@data.parent_id[row['Genus'].to_s + '_' + row['Species'].to_s + '_' + row['Subspecies'].to_s]) if @data.parent_id[row['Genus'].to_s + '_' + row['Species'].to_s + '_' + row['Subspecies'].to_s]
              end
              p.save

              unless row['Type_kind'].blank?
                o = CollectionObject::BiologicalCollectionObject.create(
                    total: 1,
                    buffered_collecting_event: row['Type locality'],
                    buffered_determinations: nil,
                    buffered_other_labels: 'Type depository: ' + row['Type depository'].to_s,
                    collecting_event: nil)
                BiocurationClassification.create(biocuration_class: stage[row['Type_stage']], biological_collection_object: o) unless row['Type_stage'].blank?
                tm = TypeMaterial.create(protonym_id: p.id, collection_object: o, type_type: 'holotype' )
              end
            end
          end
        end

        puts "\n !! Synonyms \n"
        file.each_with_index do |row, i|
          print "\r#{i}"
          next if row['Senior_ID'].blank?
          # Taxonomic_status : 'nomen oblitum', 'nomen oblitum?', 'nomen nudum', 'lapsus', 'doubtful species', 'doubtful'
          t = 'TaxonNameRelationship::Iczn::Invalidating::Synonym'
          t = 'TaxonNameRelationship::Iczn::Invalidating::Synonym::ForgottenName' if row['Taxonomic_status'] == 'nomen oblitum'
          t = 'TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling' if row['Taxonomic_status'] == 'lapsus'
          t = 'TaxonNameRelationship::Iczn::Invalidating' if row['Taxonomic_status'] == 'nomen nudum'
          tr = TaxonNameRelationship.create(subject_taxon_name_id: @data.species_id[row['Species_ID']], object_taxon_name_id: @data.species_id[row['Senior_ID']], type: t)
          if tr.id.nil?
            puts "\n !! Species_ID #{row['Species_ID']} synonymy was not added \n"
          end
        end
        puts "\nResolved #{@data.species_id.keys.count} species\n"

      end

      def soft_validations_odonata
        @data = nil
        GC.start
        fixed = 0
        print "\nApply soft validation fixes to taxa 1st pass \n"
        i = 0
        TaxonName.where(project_id: Current.project_id).each do |t|
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
        GC.start
        TaxonNameRelationship.where(project_id: Current.project_id).each do |t|
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

