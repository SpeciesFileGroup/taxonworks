require 'fileutils'

### rake tw:project_import:ucd:import_ucd data_directory=/Users/proceps/src/sf/import/ucd/working/ no_transaction=true



# COLL.txt
# COUNTRY.txt
# DIST.txt
# FAMTRIB.txt
# FGNAMES.txt       Done
# GENUS.txt
# H-FAM.txt
# HKNEW.txt
# HOSTFAM.txt
# HOSTS.txt
# JOURNALS.txt
# KEYWORDS.txt
# LANGUAGE.txt
# MASTER.txt
# P-TYPE.txt
# REFEXT.txt
# RELATION.txt
# RELIABLE.txt
# SPECIES.txt
# STATUS.txt
# TRAN.txt
# TSTAT.txt
# WWWIMAOK.txt

namespace :tw do
  namespace :project_import do
    namespace :ucd do


      class ImportedDataUcd
        attr_accessor :publications_index, :genera_index, :species_index, :keywords, :family_groups, :superfamilies, :families,
                      :taxon_codes
        def initialize()
          @publications_index = {}
          @keywords = {}
          @genera_index = {}
          @species_index = {}
          @family_groups = {}
          @superfamilies = {}
          @families = {}
          @taxon_codes = {}
        end


      end

      task :import_ucd => [:data_directory, :environment] do |t|


        if ENV['no_transaction']
          puts 'Importing without a transaction (data will be left in the database).'
          main_build_loop_ucd
        else

          ActiveRecord::Base.transaction do
            begin
              main_build_loop_ucd
            rescue
              raise
            end
          end

        end

      end

      def main_build_loop_ucd
        print "\nStart time: #{Time.now}\n"

        @import = Import.find_or_create_by(name: @import_name)
        @import.metadata ||= {}
        @data =  ImportedDataUcd.new
        puts @args
        Utilities::Files.lines_per_file(Dir["#{@args[:data_directory]}/**/*.txt"])

        handle_projects_and_users_ucd
        raise '$project_id or $user_id not set.'  if $project_id.nil? || $user_id.nil?

        #$project_id = 1
        handle_fgnames_ucd
        handle_master_ucd_families
        handle_master_ucd_valid_genera
        handle_master_ucd_invalid_genera
        handle_master_ucd_invalid_subgenera
        handle_master_ucd_valid_species
        handle_master_ucd_invalid_species

        handle_genus_ucd

        print "\n\n !! Success. End time: #{Time.now} \n\n"

      end

      def handle_projects_and_users_ucd
        print "\nHandling projects and users "
        email = 'eucharitid@mail.net'
        project_name = 'UCD'
        user_name = 'eucharitid'
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

          if project.nil?
            project = Project.create(name: project_name)
          end

          $project_id = project.id
          pm = ProjectMember.new(user: user, project: project, is_project_administrator: true)
          pm.save! if pm.valid?

          @import.metadata['project_and_users'] = true
        end
        root = Protonym.find_or_create_by(name: 'Root', rank_class: 'NomenclaturalRank', project_id: $project_id)
        @order = Protonym.find_or_create_by(name: 'Hymenoptera', parent: root, rank_class: 'NomenclaturalRank::Iczn::HigherClassificationGroup::Order', project_id: $project_id)
        @data.superfamilies.merge!('1' => Protonym.find_or_create_by(name: 'Serphitoidea', parent: @order, rank_class: 'NomenclaturalRank::Iczn::FamilyGroup::Superfamily', project_id: $project_id).id)
        @data.superfamilies.merge!('2' => Protonym.find_or_create_by(name: 'Chalcidoidea', parent: @order, rank_class: 'NomenclaturalRank::Iczn::FamilyGroup::Superfamily', project_id: $project_id).id)
        @data.superfamilies.merge!('3' => Protonym.find_or_create_by(name: 'Mymarommatoidea', parent: @order, rank_class: 'NomenclaturalRank::Iczn::FamilyGroup::Superfamily', project_id: $project_id).id)
        @data.families.merge!('' => @order.id)
        @data.keywords.merge!('ucd_imported' => Keyword.find_or_create_by(name: 'ucd_imported', definition: 'Imported from UCD database.'))
        @data.keywords.merge!('taxon_id' => Namespace.find_or_create_by(name: 'UCD_Taxon_ID', short_name: 'UCD_Taxon_ID'))
        @data.keywords.merge!('family_id' => Namespace.find_or_create_by(name: 'UCD_Family_ID', short_name: 'UCD_Family_ID'))
      end

      def handle_fgnames_ucd
        #FamCode
        # FamGroup
        # Family
        # Subfam
        # Tribe
        # SuperfamFK
        # SortOrder
        path = @args[:data_directory] + 'FGNAMES.txt'
        print "\nHandling FGNAMES\n"
        raise "file #{path} not found" if not File.exists?(path)
        file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'iso-8859-1:UTF-8')
        file.each_with_index do |row, i|
          print "\r#{i}"
          family = row['Family'].blank? ? nil : Protonym.find_or_create_by!(name: row['Family'], parent_id: @data.superfamilies[row['SuperfamFK']], rank_class: 'NomenclaturalRank::Iczn::FamilyGroup::Family', project_id: $project_id)
          subfamily = row['Subfam'].blank? ? nil : Protonym.find_or_create_by!(name: row['Subfam'], parent: family, rank_class: 'NomenclaturalRank::Iczn::FamilyGroup::Subfamily', project_id: $project_id)
          tribe = row['Tribe'].blank? ? nil : Protonym.find_or_create_by!(name: row['Tribe'], parent: subfamily, rank_class: 'NomenclaturalRank::Iczn::FamilyGroup::Tribe', project_id: $project_id)

          if !tribe.nil?
            @data.families.merge!(row['FamCode'] => tribe.id)
            tribe.identifiers.create!(type: 'Identifier::Local::Import', namespace: @data.keywords['family_id'], identifier: row['FamCode'].to_s)
          elsif !subfamily.nil?
            @data.families.merge!(row['FamCode'] => subfamily.id)
            subfamily.identifiers.create!(type: 'Identifier::Local::Import', namespace: @data.keywords['family_id'], identifier: row['FamCode'].to_s)
          else
            @data.families.merge!(row['FamCode'] => family.id)
            family.identifiers.create!(type: 'Identifier::Local::Import', namespace: @data.keywords['family_id'], identifier: row['FamCode'].to_s)
          end
        end
      end

      def handle_master_ucd_families
        #TaxonCode
        # ValGenus
        # ValSpecies
        # HomCode
        # ValAuthor
        # CitGenus
        # CitSubgen
        # CitSpecies
        # CitSubsp
        # CitAuthor
        # Family
        # ValDate
        # CitDate
        path = @args[:data_directory] + 'MASTER.txt'
        print "\nHandling MASTER -- Families\n"
        raise "file #{path} not found" if not File.exists?(path)
        file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'iso-8859-1:UTF-8')
        file.each_with_index do |row, i|
          print "\r#{i}"
          if row['ValGenus'].blank?
            name = row['ValAuthor'].split(' ').first
            author = row['ValAuthor'].gsub(name + ' ', '')
            taxon = Protonym.find_or_create_by(name: name, project_id: $project_id)
            taxon.parent = @order if taxon.parent_id.nil?
            taxon.year_of_publication = row['ValDate'] if taxon.year_of_publication.nil?
            taxon.verbatim_author = author if taxon.verbatim_author.nil?
            taxon.rank_class = 'NomenclaturalRank::Iczn::FamilyGroup::Superfamily' if taxon.rank_class.nil? && name.include?('oidea')
            taxon.rank_class = 'NomenclaturalRank::Iczn::FamilyGroup::Family' if taxon.rank_class.nil? && name.include?('idae')
            taxon.rank_class = 'NomenclaturalRank::Iczn::FamilyGroup::Subfamily' if taxon.rank_class.nil? && name.include?('inae')
            byebug unless taxon.valid?
            taxon.save!

            if row['ValAuthor'] == row['CitAuthor']
              @data.taxon_codes.merge!(row['TaxonCode'] => taxon.id)
            else
              name = row['CitAuthor'].split(' ').first
              author = row['CitAuthor'].gsub(name + ' ', '')
              rank = taxon.rank_class
              vname = nil
              if rank.parent.to_s == 'NomenclaturalRank::Iczn::FamilyGroup'
                alternative_name = Protonym.family_group_name_at_rank(name, rank.rank_name)
                if name != alternative_name
                  name = alternative_name
                  vname = row['Name']
                end
              end

              taxon1 = Protonym.new(
                       name: name,
                       verbatim_name: vname,
                       parent: taxon.parent,
                       rank_class: taxon.rank_class,
                       verbatim_author: author,
                       year_of_publication: row['CitDate']
              )
              if taxon1.valid?
                taxon1.save!
              elsif !taxon1.errors.messages[:name].blank?
                taxon1.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::Unavailable::NotLatin')
                taxon1.save!
              else
                byebug
              end
              @data.taxon_codes.merge!(row['TaxonCode'] => taxon1.id)
              taxon1.identifiers.create!(type: 'Identifier::Local::Import', namespace: @data.keywords['taxon_id'], identifier: row['TaxonCode'].to_s)
              taxon1.data_attributes.create!(type: 'ImportAttribute', import_predicate: 'HomCode', value: row['HomCode']) unless row['HomCode'].blank?
              TaxonNameRelationship.create!(subject_taxon_name: taxon1, object_taxon_name: taxon, type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym')
            end
          end
        end
      end

      def handle_master_ucd_valid_genera
        path = @args[:data_directory] + 'MASTER.txt'
        print "\nHandling MASTER -- Valid genera\n"
        raise "file #{path} not found" if not File.exists?(path)
        file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'iso-8859-1:UTF-8')
        file.each_with_index do |row, i|
          print "\r#{i}"
          if !row['ValGenus'].blank? && @data.genera_index[row['ValGenus']].nil?
            name = row['ValGenus']
            taxon = Protonym.find_or_create_by(name: name, project_id: $project_id)
            taxon.parent_id = find_family_id_ucd(row['Family']) if taxon.parent_id.nil?
            taxon.year_of_publication = row['ValDate'] if taxon.year_of_publication.nil?
            taxon.verbatim_author = row['ValAuthor'] if taxon.verbatim_author.nil?
            taxon.rank_class = 'NomenclaturalRank::Iczn::GenusGroup::Genus'
            byebug unless taxon.valid?
            taxon.save!

            if row['ValGenus'].to_s == row['CitGenus'] && row['CitSubgen'].blank? && row['ValSpecies'].blank?  && row['CitSpecies'].blank?
              @data.taxon_codes.merge!(row['TaxonCode'] => taxon.id)
              taxon.identifiers.create!(type: 'Identifier::Local::Import', namespace: @data.keywords['taxon_id'], identifier: row['TaxonCode'])
              @data.genera_index.merge!(name => taxon.id)
            end
          end
        end
      end

      def handle_master_ucd_invalid_genera
        path = @args[:data_directory] + 'MASTER.txt'
        print "\nHandling MASTER -- Invalid genera\n"
        raise "file #{path} not found" if not File.exists?(path)
        file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'iso-8859-1:UTF-8')
        file.each_with_index do |row, i|
          print "\r#{i}"
          if !row['CitSpecies'].blank? || !@data.genera_index[row['CitGenus']].blank?
          elsif !row['CitGenus'].blank? && row['CitSpecies'].blank?  && row['CitSubgen'].blank? && @data.taxon_codes[row['TaxonCode']].nil?
              taxon = Protonym.new(name: row['CitGenus'], project_id: $project_id)
              taxon1 = Protonym.find_by(name: row['ValGenus'], project_id: $project_id)
              taxon.parent_id = find_family_id_ucd(row['Family']) if taxon.parent_id.nil?
              taxon.year_of_publication = row['CitDate'] if taxon.year_of_publication.nil?
              taxon.verbatim_author = row['CitAuthor'] if taxon.verbatim_author.nil?
              taxon.rank_class = 'NomenclaturalRank::Iczn::GenusGroup::Genus'
              byebug unless taxon.valid?
              taxon.save!
              if row['ValSpecies'].blank?  && row['CitSpecies'].blank?
                @data.taxon_codes.merge!(row['TaxonCode'] => taxon.id)
                taxon.identifiers.create!(type: 'Identifier::Local::Import', namespace: @data.keywords['taxon_id'], identifier: row['TaxonCode'])
                @data.genera_index.merge!(taxon.name => taxon.id)
                TaxonNameRelationship.create!(subject_taxon_name: taxon, object_taxon_name: taxon1, type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym')
              end
          end
        end
      end

      def handle_master_ucd_invalid_subgenera
        path = @args[:data_directory] + 'MASTER.txt'
        print "\nHandling MASTER -- Invalid subgenera\n"
        raise "file #{path} not found" if not File.exists?(path)
        file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'iso-8859-1:UTF-8')
        file.each_with_index do |row, i|
          print "\r#{i}"
          if !row['CitSubgen'].blank? && (@data.genera_index[row['CitSubgen']].nil? || row['CitSpecies'].blank?) && @data.taxon_codes[row['TaxonCode']].nil?
            name = row['CitSubgen'].gsub(')', '').gsub('?', '').capitalize
            parent = @data.genera_index[row['ValGenus']]
            taxon = Protonym.find_or_create_by(name: name, project_id: $project_id)
            taxon.parent_id = parent if taxon.parent_id.nil?
            taxon.year_of_publication = row['CitDate'] if taxon.year_of_publication.nil?
            taxon.verbatim_author = row['CitAuthor'] if taxon.verbatim_author.nil?
            taxon.rank_class = 'NomenclaturalRank::Iczn::GenusGroup::Subgenus'
            byebug unless taxon.valid?
            taxon.save!

            if row['ValSpecies'].blank?  && row['CitSpecies'].blank?
              @data.taxon_codes.merge!(row['TaxonCode'] => taxon.id)
              taxon.identifiers.create!(type: 'Identifier::Local::Import', namespace: @data.keywords['taxon_id'], identifier: row['TaxonCode'])
              @data.genera_index.merge!(name => taxon.id)
            end
          end
        end
      end

      def handle_master_ucd_valid_species
        path = @args[:data_directory] + 'MASTER.txt'
        print "\nHandling MASTER -- Valid species\n"
        raise "file #{path} not found" if not File.exists?(path)
        file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'iso-8859-1:UTF-8')
        file.each_with_index do |row, i|
          print "\r#{i}"
          if !row['ValSpecies'].blank? && @data.species_index[row['ValGenus'].to_s + ' ' + row['ValSpecies'].to_s].nil? && @data.taxon_codes[row['TaxonCode']].nil?
            parent = @data.genera_index[row['ValGenus']]
            name = row['ValSpecies'].to_s
            taxon = Protonym.find_or_create_by(name: name, parent_id: parent, project_id: $project_id)
            taxon.year_of_publication = row['ValDate'] if taxon.year_of_publication.nil?
            taxon.verbatim_author = row['ValAuthor'] if taxon.verbatim_author.nil?
            taxon.rank_class = 'NomenclaturalRank::Iczn::SpeciesGroup::Species'
            byebug unless taxon.valid?
            taxon.save!

            if row['ValGenus'].to_s == row['CitGenus'] && row['ValSpecies'].to_s == row['CitSpecies']
              @data.taxon_codes.merge!(row['TaxonCode'] => taxon.id)
              taxon.identifiers.create!(type: 'Identifier::Local::Import', namespace: @data.keywords['taxon_id'], identifier: row['TaxonCode'])
              @data.species_index.merge!(row['ValGenus'].to_s + ' ' + name => taxon.id)
              origsubgen = @data.genera_index[row['CitSubgen']]
              TaxonNameRelationship.create!(subject_taxon_name_id: parent, object_taxon_name: taxon, type: 'TaxonNameRelationship::OriginalCombination::OriginalGenus') if taxon.original_genus.nil?
              TaxonNameRelationship.create!(subject_taxon_name_id: origsubgen, object_taxon_name: taxon, type: 'TaxonNameRelationship::OriginalCombination::OriginalSubgenus') if taxon.original_subgenus.nil? && !origsubgen.nil?
            end
          end
        end
      end

      def handle_master_ucd_invalid_species
        path = @args[:data_directory] + 'MASTER.txt'
        print "\nHandling MASTER -- Invalid species\n"
        raise "file #{path} not found" if not File.exists?(path)
        file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'iso-8859-1:UTF-8')
        file.each_with_index do |row, i|
          print "\r#{i}"
          if !row['CitSpecies'].blank? && @data.species_index[row['ValGenus'].to_s + ' ' + row['CitSpecies'].to_s].nil? && @data.taxon_codes[row['TaxonCode']].nil?
            parent = @data.genera_index[row['ValGenus']]
            origgen = @data.genera_index[row['CitGenus']]
            origsubgen = @data.genera_index[row['CitSubgen']]
            name = row['CitSpecies'].to_s
            taxon = Protonym.find_or_create_by(name: name, parent_id: parent, project_id: $project_id)
            taxon.year_of_publication = row['CitDate'] if taxon.year_of_publication.nil?
            taxon.verbatim_author = row['CitAuthor'] if taxon.verbatim_author.nil?
            taxon.rank_class = 'NomenclaturalRank::Iczn::SpeciesGroup::Species'
            byebug unless taxon.valid?
            taxon.save!

            @data.taxon_codes.merge!(row['TaxonCode'] => taxon.id)
            taxon.identifiers.create!(type: 'Identifier::Local::Import', namespace: @data.keywords['taxon_id'], identifier: row['TaxonCode'])
            @data.species_index.merge!(row['ValGenus'].to_s + ' ' + name => taxon.id)
            taxon1 = @data.species_index[row['ValGenus'].to_s + ' ' + row['ValSpecies'].to_s]
            TaxonNameRelationship.create!(subject_taxon_name: taxon, object_taxon_name: taxon1, type: 'TaxonNameRelationship::Iczn::Invalidating::Synonym')
            TaxonNameRelationship.create!(subject_taxon_name_id: origgen, object_taxon_name: taxon, type: 'TaxonNameRelationship::OriginalCombination::OriginalGenus') if taxon.original_genus.nil?
            TaxonNameRelationship.create!(subject_taxon_name_id: origsubgen, object_taxon_name: taxon, type: 'TaxonNameRelationship::OriginalCombination::OriginalSubgenus') if taxon.original_subgenus.nil? && !origsubgen.nil?
            taxon.original_genus = origgen if taxon.original_genus.nil?
            taxon.original_subgenus = origsubgen if taxon.original_subgenus.nil? && !origsubgen.nil?
          end
        end
      end

      def handle_genus_ucd
        path = @args[:data_directory] + 'Genus.txt'
        print "\nHandling GENUS\n"
        raise "file #{path} not found" if not File.exists?(path)
        file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'iso-8859-1:UTF-8')

        type_type = {
            'MT' => 'TaxonNameRelationship::Typification::Genus::Monotypy::Original',
            'OD' => 'TaxonNameRelationship::Typification::Genus::OriginalDesignation',
            'OM' => 'TaxonNameRelationship::Typification::Genus::OriginalDesignation',
            'SD' => 'TaxonNameRelationship::Typification::Genus::SubsequentDesignation',
            'SM' => 'TaxonNameRelationship::Typification::Genus::Monotypy::Subsequent'
        }.freeze

        status_type = {
            'NG' => 'new genus', # nothing
            'RN' => 'replacement name', # relationship
            'SG' => 'subgenus', # rank and parent
            'UE' => 'Unjustified emend', #'relationship'
            'UR' => 'Unnecessary replacement name', #relationship
            'US' => 'Unjustified emendation, new status' #relationship
        }

        file.each_with_index do |row, i|
          print "\r#{i}"
          taxon = find_taxon_ucd(row['TaxonCode'])
          species = find_taxon_id_ucd(row['Code'])
          print "\n TaxonCode: #{row['TaxonCode']} not found" if !row['TaxonCode'].blank? and taxon.nil?
          print "\n Species Code: #{row['Code']} not found" if !row['Code'].blank? and species.nil?
        end
      end



      def find_taxon_id_ucd(key)
        @data.taxon_index[key.to_s] || Identifier.where(cached: 'UCD_Taxon_ID ' + key.to_s, identifier_object_type: 'TaxonName', project_id: $project_id).limit(1).pluck(:identifier_object_id).first
      end

      def find_family_id_ucd(key)
        @data.families[key.to_s] || Identifier.where(cached: 'UCD_Family_ID ' + key.to_s, identifier_object_type: 'TaxonName', project_id: $project_id).limit(1).pluck(:identifier_object_id).first
      end

      def find_taxon_ucd(key)
        Identifier.find_by(cached: 'UCD_Taxon_ID ' + key.to_s, identifier_object_type: 'TaxonName', project_id: $project_id).try(:identifier_object)
      end

      # TODO: Fix this
      ###### commented out to clear general rake failure 07/18/16 @tuckerjd
      # @data.families[row['Family']]












=begin
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

      desc 'reconcile Refs::Chalcfam (look for unique values'
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



      desc 'handle_names - rake tw:project_import:ucd:handle_master[/Users/matt/src/sf/import/ucd/csv]'
      task :handle_names => [:data_directory, :environment] do |t, args|
        # Master            # Famtrib         # Genus           # Species
        # 0  TaxonCode      # 0  TaxonCode    # 0  TaxonCode    # 0  TaxonCode
        # 1  ValGenus       # 1  RefCode      # 1  RefCode      # 1  Region
        # 2  ValSpecies     # 2  PageRef      # 2  PageRef      # 2  Country
        # 3  HomCode        # 3  H_levelTax   # 3  Code         # 3  State
        # 4  ValAuthor      # 4  Of_for_to    # 4  CitGenus     # 4  RefCode
                            # 5  Status       # 5  CitSpecies   # 4  PageRef
        # 5  CitGenus       # 6  CitGenus     # 6  CitAuthor    # 5  Figures
        # 6  CitSubgen      # 7  CitAuthor    # 7  TypeDesign   # 6  Sex
        # 7  CitSpecies     # 8  Code         # 8  Designator   # 7  CurrStat
        # 8  CitSubsp       # 9 Notes         # 9  PageDesign   # 8  PrimType
        # 9 CitAuthor                         # 10 Status       # 9  TypeSex
                                                                # 10 Designator
        # 10 Family                                             # 11 Pages
        # 11 ValDate                                            # 12 Depository
        # 12 CitDate                                            # 13 Notes
                                                                # 14 TypeNumber
                                                                # 15 DeposB
                                                                # 16 DeposC


        puts "names ... "

        path1 = @args[:data_directory] + 'master.csv'
        path2 = @args[:data_directory] + 'famtrib.csv'
        path3 = @args[:data_directory] + 'genus.csv'
        path4 = @args[:data_directory] + 'species.csv'

        (1..4).each do |p|
          raise 'file not found' if not File.exists?(eval("path#{p}"))
        end

        m  = CSV.open(path1, col_sep: "\t")
        ft = CSV.open(path2, col_sep: "\t")
        g  = CSV.open(path3, col_sep: "\t")
        s  = CSV.open(path4, col_sep: "\t")

        root = TaxonName.new(name: 'Root', rank_class: NomenclaturalRank, parent_id: nil)
        root.save!

        chalcidoidea = TaxonName.new(name: 'Chalcidoidea', parent: root, rank_class: Ranks.lookup(:iczn, 'superfamily'))
        chalcidoidea.save!

        #mi = ft.inject({}).{|hsh, row| hsh.merge!(row[0] => row[0..

        ft.each do |row|


        end

        count_higher_taxa = 0

        valid_names = { }

        # valid pass
        m.each do |row|

        rank = nil

        # puts row[0]

        valid_genus = row[1]
        valid_species = row[2]
        valid_author = row[4]

        if valid_genus.blank? && valid_species.blank?
          rank = :higher
        elsif valid_species.blank?
          rank = :genus
        else
          rank = :species
        end

        higher_taxon, authors = row[4].split(/\s/,2) if rank == :higher

        # superfamilies = length(family) = 0 and valgenus

        if rank == :higher
          puts row[0], higher_taxon,  authors , ""
          count_higher_taxa += 1
        end
        # o.identifiers.build(type: 'Identifier::LocalId', namespace: namespace, identifier: row[0])
        end
        puts count_higher_taxa
      end




      desc 'handle_famtrib - rake tw:project_import:ucd:handle_famtrib[/Users/matt/src/sf/import/ucd/csv]'
      task :handle_famtrib => [:data_directory, :environment] do |t, args|










      end

      desc 'handle keywords - rake tw:project_import:ucd:keywords[/Users/matt/src/sf/import/ucd/csv]'
      task :handle_keywords => [:data_directory, :environment] do |t, args|
        # 0  Keywords
        # 1  Meaning
        # 2  Category

        path = @args[:data_directory] + 'keywords.csv'
        f = CSV.open(path, col_sep: "\t")
        keywords = []
        abbreviations = []
        tags = []

        meta_keywords = {
          '1' => Keyword.new(name: 'Taxonomic Keyword in UCD', definition: 'The Topic categorized by Noyes as being taxonomic (1 in UCD).'),
          '2' => Keyword.new(name: 'Biological Keyword in UCD', definition: 'The Topic categorized by Noyes as being biological (2 in UCD).'),
          '3' => Keyword.new(name: 'Economic Keyword in UCD Keyword', definition: 'The Topic categorized by Noyes as being economic (3 in UCD).')
        }
        f.each do |row|
          t = Keyword.new(name: row[1], definition: "The topic derived from the UCD keyword for #{row[1]}.")
          keywords.push t
          abbreviations.push AlternateValue::Abbreviation.new(alternate_value_object: t, value: row[0], alternate_value_object_attribute: :name)
          tags.push Tag.new(keyword: meta_keywords[row[2]], tag_object: t)
        end

        Topic.transaction do
          [meta_keywords.values, keywords, abbreviations, tags].each do |objs|
            objs.each do |o|
              o.save!
            end
          end

          # puts keyowrds.map(&:valid?), abbreviations.map(&:valid?), tags.map(&:valid?), meta_keywords.values
        end
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

      task :sql_dump_script do
        puts 'SET NAMES utf8;'
        %w{coll country dist famtrib fgnames genus h-fam hknew hostfam hosts journals keywords language master p-type refext refs relation reliable species status tran tstat wwwimaok}.each do |t|
          puts "SELECT * FROM `#{t}` INTO OUTFILE '/tmp/ucd/#{t}.csv'
        FIELDS
          TERMINATED BY '\\t'
          OPTIONALLY ENCLOSED BY '\"'
          ESCAPED BY '\\\\'
        LINES
          TERMINATED BY '\\n';"
          # ENCLOSED BY '|' # Ruby CSV is borked, to be fixed in 2.1
          # Ruby CSV wants "" (two quotes) as an escaped quote by default) - so we need to convert with rows
        end
      end
=end

    end
  end
end



