require 'fileutils'

### nohup bundle exec rake tw:project_import:ucd:import_ucd no_transaction=true data_directory=/home/matt/src/sandbox/imports/ucd/working/ RAILS_ENV=production reset=true &
### nohup bundle exec rake tw:project_import:ucd:import_ucd no_transaction=true data_directory=/home/matt/src/sandbox/imports/ucd/working/ &
### rake tw:project_import:ucd:import_ucd data_directory=/Users/proceps/src/sf/import/ucd/working/ no_transaction=true
### rake tw:db:restore backup_directory=/Users/proceps/src/pg_dumps/ file=2016-09-07_211456UTC.dump

# COLL.txt          Done
# COUNTRY.txt       Done
# DIST.txt          Most of the areas do not match TW areas
# FAMTRIB.txt       Done
# FGNAMES.txt       Done
# GENUS.txt         Done
# H-FAM.txt         Done
# HKNEW.txt         Done
# HOSTFAM.txt       Done
# HOSTS.txt         Done
# JOURNALS.txt      not needed
# KEYWORDS.txt      Done
# LANGUAGE.txt      Done
# MASTER.txt        Done
# P-TYPE.txt        Done
# REFEXT.txt        Done
# RELATION.txt      Done
# RELIABLE.txt      Done
# SPECIES.txt       Done
# STATUS.txt        Done
# TRAN.txt          not needed
# TSTAT.txt         Done
# WWWIMAOK.txt      image related
#
namespace :tw do
  namespace :project_import do
    namespace :ucd do

      #:nodoc: all
      class ImportedDataUcd

        #  attr_accessor :publications_index, :genera_index, :species_index, :keywords, :family_groups, :superfamilies, :families, :hostfamilies,
        #    :taxon_codes, :languages, :references, :countries, :collections, :all_genera_index, :all_species_index, :topics, :combinations,
        #    :reliable, :ptype, :import, :data, :otus, :done

        attr_accessor :import

        LOOKUPS = %w{ 
          user_id
          project_id
          publications_index
          keywords
          genera_index
          all_genera_index
          species_index
          all_species_index
          family_groups
          superfamilies
          families 
          hostfamilies
          taxon_codes
          languages
          countries
          collections
          references 
          topics 
          combinations
          misspelt_genus
          species_codes
          genus_codes
          new_combinations 
          reliable 
          ptype
          otus 
          done
          valid_taxon_codes
        }.freeze 

        LOOKUPS.each do |l|
          self.send(:attr_accessor, l)
        end

        def initialize()
          @import = Import.find_or_create_by(name: 'UCD IMPORT')

          LOOKUPS.each do |l|
            existing = import.get(l)
            existing ||= {}
            send("#{l}=", existing )
          end

          persist!
        end

        def persist!
          LOOKUPS.each do |l|
            import.set(l.to_s, send(l))
          end 
        end
        
        def done!(lookup)
          done[lookup] = 1
        end

        def redo!
          import.set('done', {})
        end

        # We've initialized #done, so just look it up
        def done?(lookup)
          done[lookup] == 1
        end

      end

      desc 'import UCD data, data_directory=/foo/ no_transaction=true reset=true'
      task import_ucd: [:data_directory, :environment] do |t|

        if ENV['reset'] == 'true'
          Import.where(name: 'UCD IMPORT').destroy_all
          puts 'Resetting import.' 
        end

        if ENV['no_transaction']
          puts 'Importing without a transaction (data will be left in the database on fail).'
          main_build_loop_ucd
        else
          ApplicationRecord.transaction do
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
        puts @args
        Utilities::Files.lines_per_file(Dir["#{@args[:data_directory]}/**/*.txt"])

        Current.user_id, Current.project_id = nil, nil

        @data = ImportedDataUcd.new

        handle_projects_and_users_ucd
#begin
        handle_countries_ucd
        handle_collections_ucd
        handle_keywords_ucd
        handle_reliable_ucd
        combinations_codes_ucd
        species_codes_ucd
        genus_codes_ucd

        handle_references_ucd

        handle_fgnames_ucd
        handle_master_ucd_families
        handle_master_ucd_valid_genera
        handle_master_ucd_invalid_genera
        handle_master_ucd_invalid_genera1
        handle_master_ucd_invalid_genera2
        handle_master_ucd_invalid_subgenera
        handle_master_ucd_invalid_subgenera1
        handle_master_ucd_valid_species
        handle_master_ucd_invalid_species
        handle_master_ucd_invalid_subspecies
        handle_family_ucd
        handle_genus_ucd
        handle_species_ucd
#end
        handle_tstat_ucd

        handle_hknew_ucd
        handle_h_fam_ucd
        handle_hostfam_ucd
        handle_ptype_ucd
        handle_hosts_ucd
        handle_dist_ucd
        print "\n\n !! Pre soft validation done. End time: #{Time.now} \n\n"
#end
#byebug

        invalid_relationship_remove
        invalid_relationship_remove
        soft_validations_ucd

        print "\n\n !! Success. End time: #{Time.now} \n\n"

      end

      # 
      # For the purposes of the UCD we assume the user
      # will be created when this rolls on production
      ###
      def handle_projects_and_users_ucd
        handle = 'projects_and_users' 

        print "\nHandling projects and users "

        if @data.done?(handle)
          print "from database.\n"

          Current.project_id = @data.project_id 
          Current.user_id = @data.user_id
        else
          print "as newly parsed.\n"

          email = 'j.noyes@nhm.ac.uk'
          pwd = rand(36**10).to_s(36)

          print " found existing user #{email} " if user = User.find_by_email(email)
          user ||= User.create!(email: email , password: pwd, password_confirmation: pwd, name: 'John Noyes', is_flagged_for_password_reset: true, self_created: true )

          project = Project.create!(name: 'UCD ' + Time.now.to_s, by: user)

          ProjectMember.create(project: project, user: user, is_project_administrator: true, by: user)

          user1 = User.where(email: 'arboridia@gmail.com').first

          ProjectMember.create(project: project, user: user1, is_project_administrator: true, by: user1) unless user1.nil?

          @data.project_id = project.id
          @data.user_id = user.id 
        end

        Current.project_id = @data.project_id 
        Current.user_id = @data.user_id

        raise 'Current.project_id or Current.user_id not set.' if Current.project_id.nil? || Current.user_id.nil?

        @root = Protonym.find_or_create_by(name: 'Root', rank_class: 'NomenclaturalRank', project_id: Current.project_id)
        @order = Protonym.find_or_create_by(name: 'Hymenoptera', parent: @root, rank_class: 'NomenclaturalRank::Iczn::HigherClassificationGroup::Order', project_id: Current.project_id)

        @data.superfamilies['1'] = Protonym.find_or_create_by(name: 'Serphitoidea', parent: @order, rank_class: 'NomenclaturalRank::Iczn::FamilyGroup::Superfamily', project_id: Current.project_id).id
        @data.superfamilies['2'] = Protonym.find_or_create_by(name: 'Chalcidoidea', parent: @order, rank_class: 'NomenclaturalRank::Iczn::FamilyGroup::Superfamily', project_id: Current.project_id).id
        @data.superfamilies['3'] = Protonym.find_or_create_by(name: 'Mymarommatoidea', parent: @order, rank_class: 'NomenclaturalRank::Iczn::FamilyGroup::Superfamily', project_id: Current.project_id).id
        @data.families[''] = @order.id # Use the order ID as a parent if no family is provided

        @data.keywords['ucd_imported'] = Keyword.find_or_create_by(name: 'UCD_imported', definition: 'Imported from UCD database.').id
        @data.keywords['taxon_id'] = Namespace.find_or_create_by(name: 'UCD_Taxon_ID', short_name: 'UCD_Taxon_ID').id
        @data.keywords['family_id'] = Namespace.find_or_create_by(name: 'UCD_Family_ID', short_name: 'UCD_Family_ID').id
        @data.keywords['host_family_id'] = Namespace.find_or_create_by(name: 'UCD_Host_Family_ID', short_name: 'UCD_Host_Family_ID').id
        @data.keywords['hos_number'] = Namespace.find_or_create_by(name: 'UCD_Hos_Number', short_name: 'UCD_Hos_Number').id

        @data.done!(handle)
        @data.persist!
      end

      def handle_fgnames_ucd
        handle = 'handle_fgnames_ucd'
        print "\nHandling FGNAMES "

        if !@data.done?(handle)
          puts 'as new'
          #FamCode
          # FamGroup
          # Family
          # Subfam
          # Tribe
          # SuperfamFK
          # SortOrder
          path = @args[:data_directory] + 'FGNAMES.txt'
          raise "file #{path} not found" if not File.exists?(path)
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'iso-8859-1:UTF-8')
          i = 0

          file.each do |row|
            i += 1
            print "\r#{i}"

            family = row['Family'].blank? ? nil : Protonym.find_or_create_by!(name: row['Family'], parent_id: @data.superfamilies[row['SuperfamFK']], rank_class: 'NomenclaturalRank::Iczn::FamilyGroup::Family', project_id: Current.project_id)
            subfamily = row['Subfam'].blank? ? nil : Protonym.find_or_create_by!(name: row['Subfam'], parent: family, rank_class: 'NomenclaturalRank::Iczn::FamilyGroup::Subfamily', project_id: Current.project_id)
            tribe = row['Tribe'].blank? ? nil : Protonym.find_or_create_by!(name: row['Tribe'], parent: subfamily, rank_class: 'NomenclaturalRank::Iczn::FamilyGroup::Tribe', project_id: Current.project_id)

            if !tribe.nil?
              @data.families[row['FamCode']] = tribe.id
              tribe.identifiers.create!(type: 'Identifier::Local::Import', namespace_id: @data.keywords['family_id'], identifier: row['FamCode'].to_s)
            elsif !subfamily.nil?
              @data.families[row['FamCode']] = subfamily.id
              subfamily.identifiers.create!(type: 'Identifier::Local::Import', namespace_id: @data.keywords['family_id'], identifier: row['FamCode'].to_s)
            else
              @data.families[row['FamCode']] = family.id
              family.identifiers.create!(type: 'Identifier::Local::Import', namespace_id: @data.keywords['family_id'], identifier: row['FamCode'].to_s)
            end
          end

          @data.done!(handle)
          @data.persist!
        else
          puts 'from database' 
        end
      end

      def handle_keywords_ucd
        handle = 'handle_keywords_ucd'
        print "\nHandling KEYWORDS "

        if !@data.done?(handle)
          puts 'as new'

          tags = {'1' => Keyword.find_or_create_by(name: '1', definition: 'Taxonomic (Definition is needed for the term)', project_id: Current.project_id),
                  '2' => Keyword.find_or_create_by(name: '2', definition: 'Biological (Definition is needed for the term)', project_id: Current.project_id),
                  '3' => Keyword.find_or_create_by(name: '3', definition: 'Economic (Definition is needed for the term)', project_id: Current.project_id),
          }.freeze
          
          path = @args[:data_directory] + 'KEYWORDS.txt'

          raise "file #{path} not found" if not File.exists?(path)
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'iso-8859-1:UTF-8')

          file.each_with_index do |row, i|
            print "\r#{i}"
           
            #definition = row['Meaning'].to_s.length < 4 ? row['Meaning'] + '.' : row['Meaning']
            #definition = definition + '(' + row['KeyWords'] + ')'
            #definition = row['Meaning'].to_s.length < 21 ? row['Meaning'] + '.................' : row['Meaning']
            n = row['Meaning'].to_s + '(' + row['KeyWords'] + ')'

            topic = Topic.find_or_create_by!(name: n, definition: 'Definition is needed for the term: ' + n, project_id: Current.project_id)

            topic.tags.create(keyword: tags[row['Category']]) unless row['Category'].blank?
            
            @data.topics[row['KeyWords']] = topic.id
          end

          @data.done!(handle)
          @data.persist!
        else
          puts 'from database'  
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
        print 'Handling MASTER -- Families '
        raise "file #{path} not found" if not File.exists?(path)
        file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'iso-8859-1:UTF-8')
        i = 0

        file.each do |row|
          i += 1
          print "\r#{i}"

          if row['ValGenus'].blank?
            name = row['ValAuthor'].split(' ').first
            author = row['ValAuthor'].gsub(name + ' ', '')

            taxon = Protonym.find_or_create_by(name: name, project_id: Current.project_id)
          
            taxon.parent = @order if taxon.parent_id.nil?

            taxon.year_of_publication = row['ValDate'] if taxon.year_of_publication.nil?
            taxon.verbatim_author = author if taxon.verbatim_author.nil?

            taxon.rank_class = 'NomenclaturalRank::Iczn::FamilyGroup::Superfamily' if taxon.rank_class.nil? && name.include?('oidea')
            taxon.rank_class = 'NomenclaturalRank::Iczn::FamilyGroup::Family' if taxon.rank_class.nil? && name.include?('idae')
            taxon.rank_class = 'NomenclaturalRank::Iczn::FamilyGroup::Subfamily' if taxon.rank_class.nil? && name.include?('inae')

            begin
              taxon.save!
            rescue ActiveRecord::RecordInvalid
              byebug 
            end

            if row['ValAuthor'] == row['CitAuthor']

              # !! Create identifier
              set_data_for_taxon(taxon, row['TaxonCode'].to_s)
              # @data.taxon_codes[row['TaxonCode']] = taxon.id
              # taxon.identifiers.create!(type: 'Identifier::Local::Import', namespace_id: @data.keywords['taxon_id'], identifier: row['TaxonCode'].to_s)
            
            else
              name = row['CitAuthor'].split(' ').first
              author = row['CitAuthor'].gsub(name + ' ', '')
              rank = taxon.rank_class
              vname = nil
              if rank.parent.to_s == 'NomenclaturalRank::Iczn::FamilyGroup'
                alternative_name = Protonym.family_group_name_at_rank(name, rank.rank_name)
                if name != alternative_name
                  name, vname = alternative_name, name
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

              begin
                taxon1.save!
              rescue ActiveRecord::RecordInvalid
                if !taxon1.errors.messages[:name].blank?
                  taxon1.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::Unavailable::NotLatin')
                  taxon1.save!
                else
                  byebug
                end
              end

              # !! create identifier
              set_data_for_taxon(taxon1, row['TaxonCode'].to_s)

              # @data.taxon_codes[row['TaxonCode']] = taxon1.id
              # taxon1.identifiers.create!(type: 'Identifier::Local::Import', namespace_id: @data.keywords['taxon_id'], identifier: row['TaxonCode'].to_s)


              taxon1.data_attributes.create!(type: 'ImportAttribute', import_predicate: 'HomCode', value: row['HomCode']) unless row['HomCode'].blank?
              TaxonNameRelationship.create!(subject_taxon_name: taxon1, object_taxon_name: taxon, type: 'TaxonNameRelationship::Iczn::Invalidating')
            end
          end
        end
      end

      def handle_master_ucd_valid_genera
        path = @args[:data_directory] + 'MASTER.txt'
        print "\nHandling MASTER -- Valid genera\n"
        raise "file #{path} not found" if not File.exists?(path)
        file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'iso-8859-1:UTF-8')
        i = 0

        file.each do |row|
          i += 1
          print "\r#{i}"

          if !row['ValGenus'].blank? && @data.genera_index[row['ValGenus']].nil?
            name = row['ValGenus']
            taxon = Protonym.find_or_create_by(name: name, project_id: Current.project_id)
            taxon.name = 'Luna' if taxon.name == 'luna'
            taxon.parent_id = find_family_id_ucd(row['Family']) if taxon.parent_id.nil?
            taxon.year_of_publication = row['ValDate'] if taxon.year_of_publication.nil? && row['ValSpecies'].blank?
            taxon.verbatim_author = row['ValAuthor'] if taxon.verbatim_author.nil? && row['ValSpecies'].blank?
            taxon.rank_class = 'NomenclaturalRank::Iczn::GenusGroup::Genus' if taxon.rank_class.nil?
            origgen = @data.all_genera_index[row['CitGenus']]

            begin
              taxon.save! if taxon.changed?
            rescue ActiveRecord::RecordInvalid
              byebug
            end

            @data.all_genera_index[name] = taxon.id
            @data.valid_taxon_codes[taxon.id] = 1

            if row['ValGenus'].to_s == row['CitGenus'].to_s && row['CitSubgen'].blank? && row['ValSpecies'].blank?  && row['CitSpecies'].blank? && !@data.genus_codes[row['TaxonCode']].blank?
              @data.genera_index[name] = taxon.id
              if !@data.genus_codes[row['TaxonCode']].blank?
                taxon.original_genus = taxon
                taxon.save!
              end
              # !! create identifier
              set_data_for_taxon(taxon, row['TaxonCode'].to_s)
              # @data.taxon_codes[row['TaxonCode']] = taxon.id
              # taxon.identifiers.create!(type: 'Identifier::Local::Import', namespace_id: @data.keywords['taxon_id'], identifier: row['TaxonCode'])
            elsif row['ValGenus'].to_s == row['CitSubgen'].to_s && !row['CitSubgen'].blank? && row['ValSpecies'].blank?  && row['CitSpecies'].blank? && !@data.genus_codes[row['TaxonCode']].blank?
              @data.genera_index[name] = taxon.id
              if !@data.genus_codes[row['TaxonCode']].blank?
                taxon.original_genus = Protonym.find(origgen) unless origgen.blank?
                taxon.original_subgenus = taxon
                taxon.save!
              end
              set_data_for_taxon(taxon, row['TaxonCode'].to_s)
            end
          end
        end
      end

      def handle_master_ucd_invalid_genera
        path = @args[:data_directory] + 'MASTER.txt'
        print "\nHandling MASTER -- Invalid genera\n"
        raise "file #{path} not found" if not File.exists?(path)
        file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'iso-8859-1:UTF-8')
        i = 0
        file.each do |row|
          next unless row['CitSpecies'].blank?
          next unless row['CitSubgen'].blank?
          i += 1
          print "\r#{i}"
          changed = false
#          byebug if row['CitGenus'] == 'Risbecia'
          if !row['CitGenus'].blank? && @data.taxon_codes[row['TaxonCode']].nil?
            taxon = Protonym.find_or_create_by(name: row['CitGenus'], project_id: Current.project_id)
            if !@data.genus_codes[row['TaxonCode']].blank? && row['CitSubgen'].blank? && row['CitSpecies'].blank? && !taxon.identifiers.empty? && @data.misspelt_genus[row['TaxonCode']].blank?
              taxon = Protonym.create(name: row['CitGenus'], project_id: Current.project_id)
            elsif @data.combinations[row['TaxonCode']].blank? && row['ValSpecies'].blank? && row['CitSpecies'].blank? && row['CitSubgen'].blank? && row['CitSubsp'].blank? && @data.misspelt_genus[row['TaxonCode']].blank?
              taxon = Protonym.create(name: row['CitGenus'], project_id: Current.project_id)
            end
            changed = true if taxon.changed?
            taxon1 = Protonym.find_by(name: row['ValGenus'], project_id: Current.project_id)
            taxon.parent_id = find_family_id_ucd(row['Family']) if taxon.parent_id.nil?
#            taxon.year_of_publication = row['CitDate'] if taxon.year_of_publication.nil? && row['CitSpecies'].blank? && row['CitSubgen'].blank?
#            taxon.verbatim_author = row['CitAuthor'] if taxon.verbatim_author.nil? && row['CitSpecies'].blank? && row['CitSubgen'].blank?
            taxon.rank_class = 'NomenclaturalRank::Iczn::GenusGroup::Genus' if taxon.rank_class.nil?

            begin
              taxon.save! if taxon.changed?
            rescue ActiveRecord::RecordInvalid
              taxon.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::Unavailable::NotLatin') if !taxon.errors.messages[:name].blank?
              taxon.save!
            end

            @data.all_genera_index[taxon.name] = taxon.id if @data.all_genera_index[taxon.name].nil?

#            if !@data.misspelt_genus[row['TaxonCode']].blank? # && (!row['CitSpecies'].blank? && !row['CitSubgen'].blank?)
#              r = TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling.create(subject_taxon_name: taxon, object_taxon_name: taxon1) if taxon.id != taxon1.id
            if row['ValSpecies'].blank? && row['CitSpecies'].blank? && row['CitSubgen'].blank? && row['CitSubsp'].blank?
              if changed
#                r = nil
                r = TaxonNameRelationship::Iczn::Invalidating.create(subject_taxon_name: taxon, object_taxon_name: taxon1) if taxon.id != taxon1.id
                taxon.year_of_publication = row['CitDate'] if taxon.year_of_publication.nil?
                taxon.verbatim_author = row['CitAuthor'] if taxon.verbatim_author.nil?
                taxon.original_genus = taxon
                taxon.save!
              else # elsif taxon.id == taxon1.id
                c = Combination.new()
                c.genus = taxon
                c.save
                if c.id.nil?
                  c1 = Combination.match_exists?(c.get_full_name, genus: c.genus.try(:id))
                  c1 = Combination.matching_protonyms(c.get_full_name, genus: c.genus.try(:id)).first if c1.blank?
                  byebug if c1.blank?
                  c = c1
                end
                taxon = c
              end

              # !! Create identifier
              set_data_for_taxon(taxon, row['TaxonCode'].to_s)
              # @data.taxon_codes[row['TaxonCode']] = taxon.id
              # taxon.identifiers.create!(type: 'Identifier::Local::Import', namespace_id: @data.keywords['taxon_id'], identifier: row['TaxonCode'])
            end
          end
        end
      end

      def handle_master_ucd_invalid_genera1
        path = @args[:data_directory] + 'MASTER.txt'
        print "\nHandling MASTER -- Invalid genera\n"
        raise "file #{path} not found" if not File.exists?(path)
        file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'iso-8859-1:UTF-8')
        i = 0
        file.each do |row|
          next unless row['CitSpecies'].blank?
          i += 1
          print "\r#{i}"
          changed = false
#          byebug if row['CitGenus'] == 'Risbecia'
          if !row['CitGenus'].blank? && @data.taxon_codes[row['TaxonCode']].nil?
#byebug if row['CitGenus'] == 'Sympiezus'
            taxon = Protonym.find_or_create_by(name: row['CitGenus'], project_id: Current.project_id)
            if !@data.genus_codes[row['TaxonCode']].blank? && row['CitSubgen'].blank? && row['CitSpecies'].blank? && !taxon.identifiers.empty? && @data.misspelt_genus[row['TaxonCode']].blank?
              taxon = Protonym.create(name: row['CitGenus'], project_id: Current.project_id)
            elsif @data.combinations[row['TaxonCode']].blank? && row['ValSpecies'].blank? && row['CitSpecies'].blank? && row['CitSubgen'].blank? && row['CitSubsp'].blank? && @data.misspelt_genus[row['TaxonCode']].blank?
              taxon = Protonym.create(name: row['CitGenus'], project_id: Current.project_id)
            end

            changed = true if taxon.changed?
            taxon1 = Protonym.find_by(name: row['ValGenus'], project_id: Current.project_id)
            taxon.parent_id = find_family_id_ucd(row['Family']) if taxon.parent_id.nil?
#            taxon.year_of_publication = row['CitDate'] if taxon.year_of_publication.nil? && row['CitSpecies'].blank? && row['CitSubgen'].blank?
#            taxon.verbatim_author = row['CitAuthor'] if taxon.verbatim_author.nil? && row['CitSpecies'].blank? && row['CitSubgen'].blank?
            taxon.rank_class = 'NomenclaturalRank::Iczn::GenusGroup::Genus' if taxon.rank_class.nil?

            begin
              taxon.save! if taxon.changed?
            rescue ActiveRecord::RecordInvalid
              taxon.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::Unavailable::NotLatin') if !taxon.errors.messages[:name].blank?
              taxon.save!
            end

            @data.all_genera_index[taxon.name] = taxon.id if @data.all_genera_index[taxon.name].nil?

            if !@data.misspelt_genus[row['TaxonCode']].blank? #&& (!row['CitSpecies'].blank? && !row['CitSubgen'].blank?)
              r = TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling.create(subject_taxon_name: taxon, object_taxon_name: taxon1) if taxon.id != taxon1.id
            elsif row['ValSpecies'].blank? && row['CitSpecies'].blank? && row['CitSubgen'].blank? && row['CitSubsp'].blank?
              if changed
                r = nil
                r = TaxonNameRelationship::Iczn::Invalidating.create(subject_taxon_name: taxon, object_taxon_name: taxon1) if taxon.id != taxon1.id
                taxon.year_of_publication = row['CitDate'] if taxon.year_of_publication.nil?
                taxon.verbatim_author = row['CitAuthor'] if taxon.verbatim_author.nil?
                taxon.original_genus = taxon
                taxon.save!
              else # elsif taxon.id == taxon1.id
                c = Combination.new()
                c.genus = taxon
                c.save
                if c.id.nil?
                  c1 = Combination.match_exists?(c.get_full_name, genus: c.genus.try(:id))
                  c1 = Combination.matching_protonyms(c.get_full_name, genus: c.genus.try(:id)).first if c1.blank?
                  byebug if c1.blank?
                  c = c1
                end
                taxon = c
              end

              # !! Create identifier
              set_data_for_taxon(taxon, row['TaxonCode'].to_s)
              # @data.taxon_codes[row['TaxonCode']] = taxon.id
              # taxon.identifiers.create!(type: 'Identifier::Local::Import', namespace_id: @data.keywords['taxon_id'], identifier: row['TaxonCode'])
            end
          end
        end
      end

      def handle_master_ucd_invalid_genera2
        path = @args[:data_directory] + 'MASTER.txt'
        print "\nHandling MASTER -- Invalid genera\n"
        raise "file #{path} not found" if not File.exists?(path)
        file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'iso-8859-1:UTF-8')
        i = 0
        file.each do |row|
          i += 1
          print "\r#{i}"
          changed = false
#          byebug if row['CitGenus'] == 'Risbecia'
          if !row['CitGenus'].blank? && @data.taxon_codes[row['TaxonCode']].nil?
# byebug if row['CitGenus'] == 'Sympiezus'
            taxon = Protonym.find_or_create_by(name: row['CitGenus'], project_id: Current.project_id)
            if !@data.genus_codes[row['TaxonCode']].blank? && row['CitSubgen'].blank? && row['CitSpecies'].blank? && !taxon.identifiers.empty? && @data.misspelt_genus[row['TaxonCode']].blank?
              taxon = Protonym.create(name: row['CitGenus'], project_id: Current.project_id)
            elsif @data.combinations[row['TaxonCode']].blank? && row['ValSpecies'].blank? && row['CitSpecies'].blank? && row['CitSubgen'].blank? && row['CitSubsp'].blank? && @data.misspelt_genus[row['TaxonCode']].blank?
              taxon = Protonym.create(name: row['CitGenus'], project_id: Current.project_id)
            end
            changed = true if taxon.changed?
            taxon1 = Protonym.find_by(name: row['ValGenus'], project_id: Current.project_id)
            taxon.parent_id = find_family_id_ucd(row['Family']) if taxon.parent_id.nil?
#            taxon.year_of_publication = row['CitDate'] if taxon.year_of_publication.nil? && row['CitSpecies'].blank? && row['CitSubgen'].blank?
#            taxon.verbatim_author = row['CitAuthor'] if taxon.verbatim_author.nil? && row['CitSpecies'].blank? && row['CitSubgen'].blank?
            taxon.rank_class = 'NomenclaturalRank::Iczn::GenusGroup::Genus' if taxon.rank_class.nil?

            begin
              taxon.save! if taxon.changed?
            rescue ActiveRecord::RecordInvalid
              taxon.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::Unavailable::NotLatin') if !taxon.errors.messages[:name].blank?
              taxon.save!
            end

            @data.all_genera_index[taxon.name] = taxon.id if @data.all_genera_index[taxon.name].nil?

            if !@data.misspelt_genus[row['TaxonCode']].blank?
              r = TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling.create(subject_taxon_name: taxon, object_taxon_name: taxon1) if taxon.id != taxon1.id
            elsif row['ValSpecies'].blank? && row['CitSpecies'].blank? && row['CitSubgen'].blank? && row['CitSubsp'].blank?
              if changed
                r = TaxonNameRelationship::Iczn::Invalidating.create(subject_taxon_name: taxon, object_taxon_name: taxon1) if taxon.id != taxon1.id
                taxon.year_of_publication = row['CitDate'] if taxon.year_of_publication.nil?
                taxon.verbatim_author = row['CitAuthor'] if taxon.verbatim_author.nil?
                taxon.original_genus = taxon
                taxon.save!
              else # elsif taxon.id == taxon1.id
                c = Combination.new()
                taxon = Protonym.find_or_create_by(name: name, cached_valid_taxon_name_id: taxon1, project_id: Current.project_id) if taxon.cached_valid_taxon_name_id != taxon1
                c.genus = taxon
                c.save
                if c.id.nil?
                  c1 = Combination.match_exists?(c.get_full_name, genus: c.genus.try(:id))
                  c1 = Combination.matching_protonyms(c.get_full_name, genus: c.genus.try(:id)).first if c1.blank?
                  byebug if c1.blank?
                  c = c1
                end
                taxon = c
              end

              # !! Create identifier
              set_data_for_taxon(taxon, row['TaxonCode'].to_s)
              # @data.taxon_codes[row['TaxonCode']] = taxon.id
              # taxon.identifiers.create!(type: 'Identifier::Local::Import', namespace_id: @data.keywords['taxon_id'], identifier: row['TaxonCode'])
            end
          end
        end
      end

      def handle_master_ucd_invalid_subgenera
        path = @args[:data_directory] + 'MASTER.txt'
        print "\nHandling MASTER -- Invalid subgenera\n"
        raise "file #{path} not found" if not File.exists?(path)
        file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'iso-8859-1:UTF-8')
        i = 0
        file.each do |row|
          next unless row['CitSpecies'].blank?
          i += 1
          print "\r#{i}"
          changed = false
          if !row['CitSubgen'].blank? && row['CitSpecies'].blank? && row['CitSubsp'].blank? && @data.taxon_codes[row['TaxonCode']].nil?
            name = row['CitSubgen'].gsub(')', '').gsub('?', '').capitalize
            parent = @data.genera_index[row['ValGenus']]
            taxon = Protonym.find_or_create_by(name: name, project_id: Current.project_id)
            if !@data.genus_codes[row['TaxonCode']].blank? && !taxon.identifiers.empty?
              taxon = Protonym.create(name: name, project_id: Current.project_id)
            elsif @data.combinations[row['TaxonCode']].blank?
              taxon = Protonym.create(name: name, project_id: Current.project_id)
            end
            changed = true if taxon.changed?
            taxon.parent_id = parent if taxon.parent_id.nil? && parent
#            taxon.year_of_publication = row['CitDate'] if taxon.year_of_publication.nil? && row['CitSpecies'].blank?
#            taxon.verbatim_author = row['CitAuthor'] if taxon.verbatim_author.nil? && row['CitSpecies'].blank?
            if taxon.rank_class.nil? && row['CitSpecies'].blank?
              taxon.rank_class = 'NomenclaturalRank::Iczn::GenusGroup::Genus'
              taxon.parent_id = taxon.parent.parent_id
            end
            taxon1 = Protonym.find_by(name: row['ValGenus'], project_id: Current.project_id)
            origgen = @data.all_genera_index[row['CitGenus']]

            begin
              taxon.save! if taxon.changed?
            rescue ActiveRecord::RecordInvalid
              byebug
            end

            @data.all_genera_index[name] = taxon.id if @data.all_genera_index[name].nil?

            if changed
#              r = nil
              r = TaxonNameRelationship::Iczn::Invalidating.create(subject_taxon_name: taxon, object_taxon_name: taxon1) if taxon.id != taxon1.id
#              if !r.nil? && r.id.nil?
#                taxon2 = Protonym.create!(name: row['CitGenus'],
#                                          parent_id: taxon.parent_id,
#                                          rank_class: 'NomenclaturalRank::Iczn::GenusGroup::Genus')
#                taxon = taxon2
#                r = TaxonNameRelationship::Iczn::Invalidating.create!(subject_taxon_name: taxon, object_taxon_name: taxon1) if taxon.id != taxon1.id
#              end
              taxon.year_of_publication = row['CitDate'] if taxon.year_of_publication.nil?
              taxon.verbatim_author = row['CitAuthor'] if taxon.verbatim_author.nil?
              taxon.original_genus = Protonym.find(origgen) unless origgen.blank?
              taxon.original_subgenus = taxon
              taxon.save!  if taxon.changed?

            else # elsif taxon.id == parent
              c = Combination.new()
              c.genus = Protonym.find(origgen) unless origgen.nil?
              t = Protonym.find_by(name: name, cached_valid_taxon_name_id: taxon1.cached_valid_taxon_name_id, project_id: Current.project_id)
              taxon = t unless t.nil?
              c.subgenus = taxon
              c.save
              if c.id.nil?
                c1 = Combination.match_exists?(c.get_full_name, genus: c.genus.try(:id), subgenus: c.subgenus.try(:id))
                c1 = Combination.matching_protonyms(c.get_full_name, genus: c.genus.try(:id), subgenus: c.subgenus.try(:id)).first if c1.blank?
                byebug if c1.blank?
                c = c1
              end
              taxon = c
            end

# !! create identifier
            set_data_for_taxon(taxon, row['TaxonCode'].to_s)
            # @data.taxon_codes[row['TaxonCode']] = taxon.id
            # taxon.identifiers.create!(type: 'Identifier::Local::Import', namespace_id: @data.keywords['taxon_id'], identifier: row['TaxonCode'])
          end
        end
      end

      def handle_master_ucd_invalid_subgenera1
        path = @args[:data_directory] + 'MASTER.txt'
        print "\nHandling MASTER -- Invalid subgenera\n"
        raise "file #{path} not found" if not File.exists?(path)
        file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'iso-8859-1:UTF-8')
        i = 0
        file.each do |row|
          i += 1
          print "\r#{i}"
          changed = false
          if !row['CitSubgen'].blank? && row['CitSpecies'].blank? && row['CitSubsp'].blank? && @data.taxon_codes[row['TaxonCode']].nil?
            name = row['CitSubgen'].gsub(')', '').gsub('?', '').capitalize
            parent = @data.genera_index[row['ValGenus']]
            taxon = Protonym.find_or_create_by(name: name, project_id: Current.project_id)
            if !@data.genus_codes[row['TaxonCode']].blank? && !taxon.identifiers.empty?
              taxon = Protonym.create(name: name, project_id: Current.project_id)
            elsif @data.combinations[row['TaxonCode']].blank?
              taxon = Protonym.create(name: name, project_id: Current.project_id)
            end
            changed = true if taxon.changed?
            taxon.parent_id = parent if taxon.parent_id.nil? && parent
#            taxon.year_of_publication = row['CitDate'] if taxon.year_of_publication.nil? && row['CitSpecies'].blank?
#            taxon.verbatim_author = row['CitAuthor'] if taxon.verbatim_author.nil? && row['CitSpecies'].blank?
            if taxon.rank_class.nil? && row['CitSpecies'].blank?
              taxon.rank_class = 'NomenclaturalRank::Iczn::GenusGroup::Genus'
              taxon.parent_id = taxon.parent.parent_id
            end
            taxon1 = Protonym.find_by(name: row['ValGenus'], project_id: Current.project_id)
            origgen = @data.all_genera_index[row['CitGenus']]

            begin
              taxon.save! if taxon.changed?
            rescue ActiveRecord::RecordInvalid
              byebug
            end

            @data.all_genera_index[name] = taxon.id if @data.all_genera_index[name].nil?

            if changed
#              r = nil
              r = TaxonNameRelationship::Iczn::Invalidating.create(subject_taxon_name: taxon, object_taxon_name: taxon1) if taxon.id != taxon1.id
#              if !r.nil? && r.id.nil?
#                taxon2 = Protonym.create!(name: row['CitGenus'],
#                                          parent_id: taxon.parent_id,
#                                          rank_class: 'NomenclaturalRank::Iczn::GenusGroup::Genus')
#                taxon = taxon2
#                r = TaxonNameRelationship::Iczn::Invalidating.create!(subject_taxon_name: taxon, object_taxon_name: taxon1) if taxon.id != taxon1.id
#              end
              taxon.year_of_publication = row['CitDate'] if taxon.year_of_publication.nil?
              taxon.verbatim_author = row['CitAuthor'] if taxon.verbatim_author.nil?
              taxon.original_genus = Protonym.find(origgen) unless origgen.blank?
              taxon.original_subgenus = taxon
              taxon.save!  if taxon.changed?

            else # elsif taxon.id == parent
              c = Combination.new()
              c.genus = Protonym.find(origgen) unless origgen.nil?
              t = Protonym.find_by(name: name, cached_valid_taxon_name_id: taxon1.cached_valid_taxon_name_id, project_id: Current.project_id)
              taxon = t unless t.nil?
              c.subgenus = taxon
              c.save
              if c.id.nil?
                c1 = Combination.match_exists?(c.get_full_name, genus: c.genus.try(:id), subgenus: c.subgenus.try(:id))
                c1 = Combination.matching_protonyms(c.get_full_name, genus: c.genus.try(:id), subgenus: c.subgenus.try(:id)).first if c1.blank?
                byebug if c1.blank?
                c = c1
              end
              taxon = c
            end

            # !! create identifier
            set_data_for_taxon(taxon, row['TaxonCode'].to_s)
            # @data.taxon_codes[row['TaxonCode']] = taxon.id
            # taxon.identifiers.create!(type: 'Identifier::Local::Import', namespace_id: @data.keywords['taxon_id'], identifier: row['TaxonCode'])
          end
        end
      end

      def handle_master_ucd_valid_species
        path = @args[:data_directory] + 'MASTER.txt'
        print "\nHandling MASTER -- Valid species\n"
        raise "file #{path} not found" if not File.exists?(path)
        file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'iso-8859-1:UTF-8')
        i = 0
        file.each do |row|
#          byebug if row['TaxonCode'] == 'Achrys pulchG' || row['TaxonCode'] == 'Achrys pulchGb'
# byebug if row['CitSpecies'] == 'abrotoni'

          i += 1
          print "\r#{i}"

          # skip this species if we created it already
          next if !@data.species_index[row['ValGenus'].to_s + ' ' + row['ValSpecies'].to_s].nil? 

          if !row['ValSpecies'].blank? && @data.taxon_codes[row['TaxonCode']].nil?
            parent_id = @data.all_genera_index[row['ValGenus']]  
            name = row['ValSpecies'].to_s
            n1 = name_to_unified_ucd(name)
            n2 = name_to_unified_ucd(row['CitSpecies'].to_s)
            n3 = name_to_unified_ucd(row['CitSubsp'].to_s)

            taxon = Protonym.find_or_create_by(name: name, parent_id: parent_id, project_id: Current.project_id)
            taxon.year_of_publication = row['ValDate'] if taxon.year_of_publication.nil?
            taxon.verbatim_author = row['ValAuthor'] if taxon.verbatim_author.nil?
            taxon.rank_class = 'NomenclaturalRank::Iczn::SpeciesGroup::Species'
            origgen = @data.all_genera_index[row['CitGenus']]
            origsubgen = @data.all_genera_index[row['CitSubgen']]
            origspecies = @data.all_species_index[row['CitGenus'].to_s + ' ' + row['CitSpecies'].to_s]

            begin
              taxon.save! if taxon.changed?
            rescue ActiveRecord::RecordInvalid
              taxon.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::Unavailable::NotLatin') if !taxon.errors.messages[:name].blank?
              taxon.save!
            end

            @data.all_species_index[row['CitGenus'].to_s + ' ' + name] = taxon.id
            @data.all_species_index[row['ValGenus'].to_s + ' ' + name] = taxon.id
            @data.valid_taxon_codes[taxon.id] = 1


            if !@data.species_codes[row['TaxonCode']].blank?

              if n1 == n2 && row['ValAuthor'].to_s.gsub('(', '').gsub(')', '') == row['CitAuthor'].to_s.gsub('(', '').gsub(')', '') && row['ValDate'].to_s == row['CitDate'].to_s && row['CitSubsp'].blank? && !@data.species_codes[row['TaxonCode']].blank? #  && @data.combinations[row['TaxonCode']].blank?
  #           if row['ValSpecies'].to_s == row['CitSpecies'] && row['ValAuthor'] == '(' + row['CitAuthor'] + ')' && row['ValDate'] == row['CitDate'] && row['CitSubsp'].blank? && @data.combinations['TaxonCode'].blank?
                taxon.original_subgenus = Protonym.find(origsubgen) unless origsubgen.nil?
                taxon.original_genus = Protonym.find(origgen) unless origgen.nil?
                taxon.verbatim_name = row['CitSpecies'] if row['ValSpecies'].to_s != row['CitSpecies'].to_s
                taxon.original_species = taxon
                @data.species_index[row['ValGenus'].to_s + ' ' + name] = taxon.id

                # !! Create identifier
                set_data_for_taxon(taxon, row['TaxonCode'].to_s)
                # @data.taxon_codes[row['TaxonCode']] = taxon.id
                # taxon.identifiers.create!(type: 'Identifier::Local::Import', namespace_id: @data.keywords['taxon_id'], identifier: row['TaxonCode'])
              elsif n1 == n3 && row['ValAuthor'].to_s.gsub('(', '').gsub(')', '') == row['CitAuthor'].to_s.gsub('(', '').gsub(')', '') && row['ValDate'].to_s == row['CitDate'].to_s && !row['CitSubsp'].blank? && !@data.species_codes[row['TaxonCode']].blank? #  && @data.combinations[row['TaxonCode']].blank?
                taxon.original_subgenus = Protonym.find(origsubgen) unless origsubgen.nil?
                taxon.original_genus = Protonym.find(origgen) unless origgen.nil?
                taxon.original_subspecies = taxon
                taxon.original_species = Protonym.find(origspecies) unless origspecies.nil?
                taxon.verbatim_name = row['CitSubsp'] if row['ValSpecies'].to_s != row['CitSubsp'].to_s
                @data.species_index[row['ValGenus'].to_s + ' ' + name] = taxon.id
                set_data_for_taxon(taxon, row['TaxonCode'].to_s)
              end
              taxon.save!  if taxon.changed?
            end
          end
        end
      end

      def name_to_unified_ucd(n)
        n = n[0..-3] + 'a' if n =~ /^[a-z]*um$/ # -um > -a
        n = n[0..-3] + 'a' if n =~ /^[a-z]*us$/ # -us > -a
        n = n[0..-3] + 'e' if n =~ /^[a-z]*is$/ # -is > -e
        n = n[0..-3] + 'ra' if n =~ /^[a-z]*er$/ # -er > -ra
        return n
      end

      def handle_master_ucd_invalid_species
        path = @args[:data_directory] + 'MASTER.txt'
        print "\nHandling MASTER -- Invalid species\n"
        raise "file #{path} not found" if not File.exists?(path)
        file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'iso-8859-1:UTF-8')
        i = 0
        file.each do |row|
#byebug if row['TaxonCode'] == 'Closte pulchG'
#byebug if row['ValSpecies'] == 'pehlivani'
#byebug if row['CitSpecies'] == 'asparagi'
#byebug if row['CitSpecies'] == 'abrotoni'


          i += 1
          print "\r#{i}"
          changed = false
          if !row['CitSpecies'].blank? && row['CitSubsp'].blank? && @data.taxon_codes[row['TaxonCode']].nil?
            parent = @data.all_genera_index[row['ValGenus']]
            origgen = @data.all_genera_index[row['CitGenus']]
            origsubgen = @data.all_genera_index[row['CitSubgen']]
            name = row['CitSpecies'].gsub('sp. ', '').to_s

            #@data.combinations
            taxon = Protonym.find_or_create_by(name: name, parent_id: parent, project_id: Current.project_id)
            if !@data.species_codes[row['TaxonCode']].blank? && row['CitSubsp'].blank? && !taxon.identifiers.empty?
              taxon = Protonym.create(name: name, parent_id: parent, project_id: Current.project_id)
            elsif @data.combinations[row['TaxonCode']].blank?
              taxon = Protonym.create(name: name, parent_id: parent, project_id: Current.project_id)
            end
            changed = true if taxon.changed?
            taxon.rank_class = 'NomenclaturalRank::Iczn::SpeciesGroup::Species'

            begin
              taxon.save! if taxon.changed?
            rescue ActiveRecord::RecordInvalid
              taxon.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::Unavailable::NotLatin') if !taxon.errors.messages[:name].blank?
              taxon.save!
            end

            # !?! DON'T Create identifier ... (invalid)
            @data.taxon_codes[row['TaxonCode']] = taxon.id if taxon.changed?
            @data.all_species_index[row['CitGenus'].to_s + ' ' + name] = taxon.id if @data.all_species_index[row['CitGenus'].to_s + ' ' + name].nil?
            #@data.species_index[row['ValGenus'].to_s + ' ' + name] = taxon.id
            taxon1 = @data.all_species_index[row['ValGenus'].to_s + ' ' + row['ValSpecies'].to_s]

            byebug if taxon1.nil?
            if changed
#              r = nil
              r = TaxonNameRelationship::Iczn::Invalidating.create(subject_taxon_name: taxon, object_taxon_name_id: taxon1) if taxon.id != taxon1
              byebug if r.id.nil?
#              if !r.nil? && r.id.nil?
#                taxon2 = Protonym.new(name: name, parent_id: parent, project_id: Current.project_id)
#                taxon2.rank_class = 'NomenclaturalRank::Iczn::SpeciesGroup::Species'
#                taxon2.save!
#                taxon = taxon2
#                r = TaxonNameRelationship::Iczn::Invalidating.create!(subject_taxon_name: taxon, object_taxon_name_id: taxon1) if taxon.id != taxon1
#              end
              taxon.year_of_publication = row['CitDate'] if taxon.year_of_publication.nil?
              taxon.verbatim_author = row['CitAuthor'] if taxon.verbatim_author.nil?
              taxon.original_genus = Protonym.find(origgen) unless origgen.blank?
              taxon.original_subgenus = Protonym.find(origsubgen) unless origsubgen.blank?
              taxon.original_species = taxon
              taxon.save! if taxon.changed?
            else # elsif taxon.id == taxon1
              c = Combination.new()
              c.genus = Protonym.find(origgen) unless origgen.nil?
              c.subgenus = Protonym.find(origsubgen) unless origsubgen.nil?
              taxon1 = Protonym.find(taxon1)
              t = Protonym.find_by(name: name, parent_id: parent, cached_valid_taxon_name_id: taxon1.cached_valid_taxon_name_id, project_id: Current.project_id)
              if t.nil?
                Protonym.where(cached_valid_taxon_name_id: taxon1.cached_valid_taxon_name_id).find_each do |r|
                  if taxon.name_with_alternative_spelling == r.name_with_alternative_spelling
                    r.taxon_name_classifications.create(type: 'TaxonNameClassification::Latinized::PartOfSpeech::Adjective')
                    taxon = r
                    break
                  end
                end
              else
                taxon = t
              end
              c.species = taxon
              c.verbatim_name = c.get_full_name
              c.save
              if c.id.nil?
                c1 = Combination.match_exists?(c.get_full_name, genus: c.genus.try(:id), subgenus: c.subgenus.try(:id), species: c.species.try(:id))
                c1 = Combination.matching_protonyms(c.get_full_name, genus: c.genus.try(:id), subgenus: c.subgenus.try(:id), species: c.species.try(:id)).first if c1.blank?
                byebug if c1.blank?
                c = c1
              end
              taxon = c
            end
            taxon.identifiers.create!(type: 'Identifier::Local::Import', namespace_id: @data.keywords['taxon_id'], identifier: row['TaxonCode'])
          end
        end
      end

      def handle_master_ucd_invalid_subspecies
        path = @args[:data_directory] + 'MASTER.txt'
        print "\nHandling MASTER -- Invalid subspecies\n"
        raise "file #{path} not found" if not File.exists?(path)
        file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'iso-8859-1:UTF-8')
        i = 0
        file.each do |row|
          i += 1
          print "\r#{i}"
          changed = false
          if !row['CitSubsp'].blank? && @data.taxon_codes[row['TaxonCode']].nil?
            parent = @data.all_genera_index[row['ValGenus']]
            origgen = @data.all_genera_index[row['CitGenus']]
            origsubgen = @data.all_genera_index[row['CitSubgen']]
            origspecies = @data.all_species_index[row['CitGenus'].to_s + ' ' + row['CitSpecies'].to_s]
            name = row['CitSubsp'].gsub('sp. ', '').to_s
            taxon = Protonym.find_or_create_by(name: name, parent_id: parent, project_id: Current.project_id)
            if !@data.species_codes[row['TaxonCode']].blank?
              taxon = Protonym.create(name: name, parent_id: parent, project_id: Current.project_id) unless taxon.identifiers.empty?
            elsif @data.combinations[row['TaxonCode']].blank?
              taxon = Protonym.create(name: name, parent_id: parent, project_id: Current.project_id) unless taxon.identifiers.empty?
            end
            changed = true if taxon.changed?
#            taxon.year_of_publication = row['CitDate'] if taxon.year_of_publication.nil?
#            taxon.verbatim_author = row['CitAuthor'] if taxon.verbatim_author.nil?
            taxon.rank_class = 'NomenclaturalRank::Iczn::SpeciesGroup::Species'

            begin
              taxon.save! if taxon.changed?
            rescue ActiveRecord::RecordInvalid
              taxon.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::Unavailable::NotLatin') if !taxon.errors.messages[:name].blank?
              taxon.save!
            end

            # !! don't create identifier, invalid!!
            @data.taxon_codes[row['TaxonCode']] = taxon.id if taxon.changed?
            #@data.species_index[row['ValGenus'].to_s + ' ' + name] = taxon.id
            taxon1 = @data.all_species_index[row['ValGenus'].to_s + ' ' + row['ValSpecies'].to_s]

            byebug if taxon1.nil?
            if changed
#              r = nil
              r = TaxonNameRelationship::Iczn::Invalidating.create(subject_taxon_name: taxon, object_taxon_name_id: taxon1) if taxon.id != taxon1
#              if !r.nil? && r.id.nil?
#                taxon2 = Protonym.new(name: name, parent_id: parent, project_id: Current.project_id)
#                taxon2.rank_class = 'NomenclaturalRank::Iczn::SpeciesGroup::Species'
#                begin
#                  taxon2.save!
#                rescue ActiveRecord::RecordInvalid
#                  taxon2.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::Unavailable::NotLatin') if !taxon2.errors.messages[:name].blank?
#                  taxon2.save!
#                end
#                taxon = taxon2
#                r = TaxonNameRelationship::Iczn::Invalidating.create!(subject_taxon_name: taxon, object_taxon_name_id: taxon1) if taxon.id != taxon1
#              end
              taxon.year_of_publication = row['CitDate'] if taxon.year_of_publication.nil?
              taxon.verbatim_author = row['CitAuthor'] if taxon.verbatim_author.nil?
              taxon.original_genus = Protonym.find(origgen) unless origgen.blank?
              taxon.original_subgenus = Protonym.find(origsubgen) unless origsubgen.blank?
              taxon.original_species = Protonym.find(origspecies) unless origspecies.blank?
              taxon.original_subspecies = taxon
              taxon.save! if taxon.changed?
            else # elsif taxon.id == taxon1
              c = Combination.new()
              c.genus = Protonym.find(origgen) unless origgen.nil?
              c.subgenus = Protonym.find(origsubgen) unless origsubgen.nil?
              c.species = Protonym.find(origspecies) unless origspecies.nil?
              taxon1 = Protonym.find(taxon1)
              t = Protonym.find_by(name: name, parent_id: parent, cached_valid_taxon_name_id: taxon1.cached_valid_taxon_name_id, project_id: Current.project_id)
              if t.nil?
                Protonym.where(cached_valid_taxon_name_id: taxon1.cached_valid_taxon_name_id).find_each do |r|
                  if taxon.name_with_alternative_spelling == r.name_with_alternative_spelling
                    r.taxon_name_classifications.create(type: 'TaxonNameClassification::Latinized::PartOfSpeech::Adjective')
                    taxon = r
                    break
                  end
                end
              else
                taxon = t
              end
              c.subspecies = taxon
              c.verbatim_name = c.get_full_name
              c.save
              if c.id.nil?
                c1 = Combination.match_exists?(c.get_full_name, genus: c.genus.try(:id), subgenus: c.subgenus.try(:id), species: c.species.try(:id), subspecies: c.subspecies.try(:id))
                c1 = Combination.matching_protonyms(c.get_full_name, genus: c.genus.try(:id), subgenus: c.subgenus.try(:id), species: c.species.try(:id), subspecies: c.subspecies.try(:id)).first if c1.blank?
                byebug if c1.blank?
                c = c1
              end
              taxon = c
            end
            taxon.identifiers.create!(type: 'Identifier::Local::Import', namespace_id: @data.keywords['taxon_id'], identifier: row['TaxonCode'])
          end
        end
      end

      def handle_language_ucd
        handle = 'handle_language_ucd' 
        print "\nHandling LANGUAGE "
        if !@data.done?(handle)
          puts 'as new'
          lng_transl = {'al' => 'sq',
                        'ge' => 'ka',
                        'gr' => 'el',
                        'in' => 'id',
                        'kz' => 'kk',
                        'ma' => 'mk',
                        'pe' => 'fa',
                        'sh' => 'hr',
                        'vt' => 'vi'
          }
          path = @args[:data_directory] + 'LANGUAGE.txt'

          raise "file #{path} not found" if not File.exists?(path)
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'iso-8859-1:UTF-8')
          file.each_with_index do |row, i|
            print "\r#{i}"
            c = row['Code'].downcase
            c = lng_transl[c] unless lng_transl[c].nil?
            l = Language.where(alpha_2: c).first
            if l.nil?
              print "\n ERROR: Language not resolved: #{row['Code']} - #{row['Language']}\n"
              @data.languages[row['Code'].downcase] = [nil, row['Language']]
            else
              @data.languages[row['Code'].downcase] = [l.id, row['Language']]
            end
          end

          @data.done!(handle)
          @data.persist!
        else
          puts 'from database'
        end
      end

      def handle_countries_ucd
        handle = 'handle_countries_ucd' 
        print "\nHandling COUNTRY (COUNTRY_MOD)"

        if !@data.done?(handle)
          puts ' as new'
          path = @args[:data_directory] + 'COUNTRY_MOD.txt'

          raise "file #{path} not found" if not File.exists?(path)
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'iso-8859-1:UTF-8')
          file.each_with_index do |row, i|
            next if row['GeographicAreaID'].blank? || (row['GeographicAreaID'] =~ /'no match'/) || row['Country'].blank?
            print "\r#{i}"
            @data.countries["#{row['Country']}|#{row['State']}"] = row['GeographicAreaID']
          end
       
          @data.done!(handle)
          @data.persist!
        else
          puts 'from database'
        end
      end

      def handle_collections_ucd
        handle = 'handle_collections_ucd' 
        print "\nHandling COLL "

        if !@data.done?(handle)
          puts 'as new'
          path = @args[:data_directory] + 'COLL.txt'

          raise "file #{path} not found" if not File.exists?(path)
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'iso-8859-1:UTF-8')
          file.each_with_index do |row, i|
            print "\r#{i}"
            @data.collections[row['Acronym']] = row['Depository']
          end

          @data.done!(handle)
          @data.persist!
        else
          puts 'from database'
        end
      end

      def handle_reliable_ucd
        handle = 'handle_reliable_ucd' 
        print "\nHandling RELIABLE "

        if !@data.done?(handle)
          puts 'as new'
          path = @args[:data_directory] + 'RELIABLE.txt'

          raise "file #{path} not found" if not File.exists?(path)
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'iso-8859-1:UTF-8')
          file.each_with_index do |row, i|
            print "\r#{i}"
            c = ConfidenceLevel.find_or_create_by(name: row['Score'], definition: row['Meaning'], project_id: Current.project_id)
            @data.reliable[row['Score']] = c.id
          end

          @data.reliable['or'] = ConfidenceLevel.find_or_create_by(
            name: 'Primary source', definition: 'Asserted distribution is taken from a primary source.', project_id: Current.project_id).id
          @data.reliable['rv'] = ConfidenceLevel.find_or_create_by(
            name: 'Secondary source', definition: 'Asserted distribution is not taken from a primary source.', project_id: Current.project_id).id

          @data.done!(handle)
          @data.persist!
        else
          puts 'from database'
        end
      end

      def handle_ptype_ucd
        handle = 'handle_ptype_ucd' 
        print "\nHandling P-TYPE "

        if !@data.done?(handle)
          puts 'as new'

          path = @args[:data_directory] + 'P-TYPE.txt'

          raise "file #{path} not found" if not File.exists?(path)
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'iso-8859-1:UTF-8')
          file.each_with_index do |row, i|
            print "\r#{i}"
            @data.ptype[row['Code']] = row['ParType']
          end
          @data.done!(handle)
          @data.persist!
        else
          puts 'from database'
        end
      end

      def handle_references_ucd
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

        path1 = @args[:data_directory] + 'REFS.txt'
        path2 = @args[:data_directory] + 'REFEXT.txt'
        print "\nHandling References\n"
        raise "file #{path1} not found" if not File.exists?(path1)
        raise "file #{path2} not found" if not File.exists?(path2)
        file1 = CSV.foreach(path1, col_sep: "\t", headers: true, encoding: 'iso-8859-1:UTF-8')
        file2 = CSV.foreach(path2, col_sep: "\t", headers: true, encoding: 'iso-8859-1:UTF-8')

        namespace = Namespace.find_or_create_by(name: 'UCD_RefCode', short_name: 'UCD_RefCode')
        keywords = {
          'Refs:Location' => Predicate.find_or_create_by(name: 'Refs::Location', definition: 'The verbatim value in Ref#location.', project_id: Current.project_id),
          'Refs:Source' => Predicate.find_or_create_by(name: 'Refs::Source', definition: 'The verbatim value in Ref#source.', project_id: Current.project_id),
          'Refs:Check' => Predicate.find_or_create_by(name: 'Refs::Check', definition: 'The verbatim value in Ref#check.', project_id: Current.project_id),
          'Refs:LanguageA' => Predicate.find_or_create_by(name: 'Refs::LanguageA', definition: 'The verbatim value in Refs#LanguageA', project_id: Current.project_id),
          'Refs:LanguageB' => Predicate.find_or_create_by(name: 'Refs::LanguageB', definition: 'The verbatim value in Refs#LanguageB', project_id: Current.project_id),
          'Refs:LanguageC' => Predicate.find_or_create_by(name: 'Refs::LanguageC', definition: 'The verbatim value in Refs#LanguageC', project_id: Current.project_id),
          'Refs:ChalcFam' => Predicate.find_or_create_by(name: 'Refs::ChalcFam', definition: 'The verbatim value in Refs#ChalcFam', project_id: Current.project_id),
          'Refs:M_Y' => Predicate.find_or_create_by(name: 'Refs::M_Y', definition: 'The verbatim value in Refs#M_Y.', project_id: Current.project_id),
          'Refs:PDF_file' => Predicate.find_or_create_by(name: 'Refs::PDF_file', definition: 'The verbatim value in Refs#PDF_file.', project_id: Current.project_id),
          'RefsExt:Translate' => Predicate.find_or_create_by(name: 'RefsExt::Translate', definition: 'The verbatim value in RefsExt#Translate.', project_id: Current.project_id),
        }

        fext_data = {}

        file2.each_with_index do |r, i|
          fext_data[r[0]] = { translate: r[1], notes: r[2], publisher: r[3], ext_author: r[4], ext_title: r[5], ext_journal: r[6], editor: r[7] }
        end

        i = 0
        file1.each do |row|
          i += 1
          print "\r#{i}"

          year, month, day = nil, nil, nil
          unless row['PubDate'].nil?
            year, month, day = row['PubDate'].split('-', 3)
            month = Utilities::Dates::SHORT_MONTH_FILTER[month]
            month = month.to_s if !month.nil?
          end
          
          stated_year = row['Year']
          if year.nil? 
            year = stated_year
            stated_year = nil
          end

          print "\n ERROR: #{row['RefCode']} : Year out of range: [#{year.to_i == 0 ? 'not provided' : year}]\n" if year.to_i < 1500 || year.to_i > 2018
          year = nil if year.to_i < 1500 || year.to_i > 2018
          stated_year = nil if stated_year.to_i < 1500 || stated_year.to_i > 2018

          # Need to translate | | to \textit{ } I think (bibtex format)
          title = [row['Title'],  (fext_data[row['RefCode']] && !fext_data[row['RefCode']][:ext_title].blank? ? fext_data[row['RefCode']][:ext_title] : nil)].compact.join(' ')
          journal = [row['JourBook'],  (fext_data[row['RefCode']] && !fext_data[row['RefCode']][:ext_journal].blank? ? fext_data[row['RefCode']][:ext_journal] : nil)].compact.join(' ')
          author = [row['Author'],  (fext_data[row['RefCode']] && !fext_data[row['RefCode']][:ext_author].blank? ? fext_data[row['RefCode']][:ext_author] : nil)].compact.join(' ')
          if row['LanguageA'].blank? || @data.languages[row['LanguageA'].downcase].nil?
            language, language_id = nil, nil
          else
            language_id = @data.languages[row['LanguageA'].downcase][0]
            language = @data.languages[row['LanguageA'].downcase][1]
          end

          serial_id = Serial.where(name: journal).limit(1).pluck(:id).first
          serial_id ||= Serial.with_any_value_for(:name, journal).limit(1).pluck(:id).first # uses AlternateValues for search as well

#          b = Identifier.find_by(cached: 'UCD_RefCode ' + row['RefCode'] + row['Letter'].to_s).try(:identifier_object)

          b = Source::Bibtex.where(
            author: author.split(/\s*\;\s*/).compact.join(' and '),
            year: (year.blank? ? nil : year.to_i),
            month: month,
            day: (day.blank? ? nil : day.to_i) ,
            stated_year: stated_year,
            year_suffix: row['Letter'],
            title: title,
            booktitle: journal,
            serial_id: serial_id,
            volume: row['Volume'],
            pages: row['Pages'],
            bibtex_type: 'article',
            language_id: language_id,
            language: language,
            publisher: (fext_data[row['RefCode']] ? fext_data[row['RefCode']][:publisher] : nil),
            editor: (fext_data[row['RefCode']] ? fext_data[row['RefCode']][:editor].split(/\s*\;\s*/).compact.join(' and ') : nil )
          ).first

          b = Source::Bibtex.create(
              no_year_suffix_validation: true, # only used on create?
              author: author.split(/\s*\;\s*/).compact.join(' and '),
              year: (year.blank? ? nil : year.to_i),
              month: month,
              day: (day.blank? ? nil : day.to_i) ,
              stated_year: stated_year,
              year_suffix: row['Letter'],
              title: title,
              booktitle: journal,
              serial_id: serial_id,
              volume: row['Volume'],
              pages: row['Pages'],
              bibtex_type: 'article',
              language_id: language_id,
              language: language,
              publisher: (fext_data[row['RefCode']] ? fext_data[row['RefCode']][:publisher] : nil),
              editor: (fext_data[row['RefCode']] ? fext_data[row['RefCode']][:editor].split(/\s*\;\s*/).compact.join(' and ') : nil )
          ) if b.nil?


          if !b.id.blank?
            b.project_sources.create
            b.identifiers.create(type: 'Identifier::Local::Import', namespace: namespace, identifier: row['RefCode'] + row['Letter'].to_s)

            b.data_attributes.create(type: 'InternalAttribute', predicate: keywords['Refs:Location'], value: row['Location'])   if !row['Location'].blank?
            b.data_attributes.create(type: 'InternalAttribute', predicate: keywords['Refs:Source'], value: row['Source'])       if !row['Source'].blank?
            b.data_attributes.create(type: 'InternalAttribute', predicate: keywords['Refs:Check'], value: row['Check'])         if !row['Check'].blank?
            b.data_attributes.create(type: 'InternalAttribute', predicate: keywords['Refs:ChalcFam'], value: row['ChalcFam'])   if !row['ChalcFam'].blank?
            b.data_attributes.create(type: 'InternalAttribute', predicate: keywords['Refs:LanguageA'], value: row['LanguageA']) if !row['LanguageA'].blank?
            b.data_attributes.create(type: 'InternalAttribute', predicate: keywords['Refs:LanguageB'], value: row['LanguageB']) if !row['LanguageB'].blank?
            b.data_attributes.create(type: 'InternalAttribute', predicate: keywords['Refs:LanguageC'], value: row['LanguageC']) if !row['LanguageC'].blank?
            b.data_attributes.create(type: 'InternalAttribute', predicate: keywords['Refs:M_Y'], value: row['M_Y'])             if !row['M_Y'].blank?

            if fext_data[row['RefCode']]
              b.data_attributes.create!(type: 'InternalAttribute', predicate: keywords['RefsExt:Translate'], value: fext_data[row['RefCode']][:translate]) unless fext_data[row['RefCode']][:translate].blank?
              b.notes.create!(text: fext_data[row['RefCode']][:note].gsub(/|/,'_')) unless fext_data[row['RefCode']][:note].blank?
            end

            ['KeywordA', 'KeywordB', 'KeywordC'].each do |i|
              k =  Keyword.with_alternate_value_on(:name, row[i]).first
              b.tags.create(keyword: k) unless k.nil?
            end
            @data.references[row['RefCode']] = b.id
          else
            print "\nThe reference with RefCode: #{row['RefCode']} is invalid: #{b.errors.full_messages.join('; ')}.\n"
          end

        end

        fext_data = nil
        keywords = nil 
      end

      def species_codes_ucd
        path = @args[:data_directory] + 'SPECIES.txt'
        print "\nHandling Species Codes\n"
        raise "file #{path} not found" if not File.exists?(path)
        file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'iso-8859-1:UTF-8')
        file.each_with_index do |row, i|
          print "\r#{i}"
          @data.species_codes[row['TaxonCode']] = true
        end
      end

      def genus_codes_ucd
        path = @args[:data_directory] + 'GENUS.txt'
        print "\nHandling Genus Codes\n"
        raise "file #{path} not found" if not File.exists?(path)
        file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'iso-8859-1:UTF-8')
        file.each_with_index do |row, i|
          print "\r#{i}"
          @data.genus_codes[row['TaxonCode']] = true
        end
      end

      def combinations_codes_ucd
        combinations = {
          'CG' => 'Misspelt generic name, new combination for',
          'CS' => 'New combination, status revived for',
          'FM' => 'Form',
          'FR' => 'Form, new status for',
          'GI' => 'Generic placement incorrect',
          'GQ' => 'Generic placement queried',
          'GR' => 'Generic placement queried, new combination for',
          'GS' => 'Generic name synonymized with', # only generic name provided for species
          'IA' => 'Incorrect gender agreement of species name in',
          'JG' => 'Misspelt generic name, justified emendation of',
          'MC' => 'Mandatory change of species name in',
          'NA' => 'Name based based on alternative original spelling of',
          'NC' => 'New combination for',
          'NE' => 'New combination, justified emendation of',
          'NF' => 'New combination based on misspelt species name',
          'MG' => 'Misspelt genus name',
          'NH' => 'New combination based on unjustified emendation of',
          'NI' => 'New combination based on lapsus for',
          'NJ' => 'New combination based on incorrect emendation of',
          'NK' => 'New combination, incorrect justified emendation of',
          'NL' => 'New combination, by implication, for',
          'NO' => 'New status, subspecies of',
          'NV' => 'Name revived for',
          'NZ' => 'New combination based on misspelt species name of',
          'PC' => 'Possible new combination in',
          'PF' => 'Possible new combination for',
          'RC' => 'Revived combination for',
          'RV' => 'Revived combination, valid species for',
          'SC' => 'New status, new combination for',
          'SF' => 'New status, subgenus of',
          'SJ' => 'SubsequentMonotypy use of unjustified emendation of',
          'SN' => 'New status for',
          'SR' => 'Status revived',
          'SS' => 'Subspecies',
          'SV' => 'Spelling validated',
          'SW' => 'Status revived, combination revived for',
          'TI' => 'Transferred, by implication, from',
          'VC' => 'Valid species, new combination',
          'VO' => 'Variety, new status for',
        }.freeze
        misspelling = {
            'MG' => 'Misspelt genus name',
            'MB' => 'Misspelt genus and species names'
        }.freeze

        path = @args[:data_directory] + 'TSTAT.txt'
        print "\nHandling TSTAT - combinations\n"
        raise "file #{path} not found" if not File.exists?(path)
        file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'iso-8859-1:UTF-8')
        file.each_with_index do |row, i|
          print "\r#{i}"
          @data.combinations[row['TaxonCode']] = true if combinations[row['Status']] && row['TaxonCode'].to_s != row['Code'].to_s
          @data.misspelt_genus[row['TaxonCode']] = true if misspelling[row['Status']] && row['TaxonCode'].to_s != row['Code'].to_s
        end
      end

      def handle_family_ucd
        path = @args[:data_directory] + 'FAMTRIB.txt'
        print "\nHandling FAMTRIB\n"
        raise "file #{path} not found" if not File.exists?(path)
        file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'iso-8859-1:UTF-8')

        keywords = {
          'FamTrib:Status' => Predicate.find_or_create_by(name: 'FamTrib:Status', definition: 'The verbatim value in FamTrib#Status.', project_id: Current.project_id)
        }.freeze

        status_type = {
          'FY' => 'Family of',
          'SB' => 'Subfamily of',
          'SF' => 'New status, subgenus of',
          'VF' => 'Family of',
          'VI' => 'Valid subtribe of',
          'VT' => 'Valid tribe of'
        }

        i = 0
        file.each do |row|
          i += 1
          print "\r#{i}"
         
          taxon = find_taxon_ucd(row['TaxonCode'])
          genus = find_taxon_id_ucd(row['Code'])
          ref = find_source_id_ucd(row['RefCode'])

          print "\n ERROR: TaxonCode: #{row['TaxonCode']} not found \n" if !row['TaxonCode'].blank? && taxon.nil?
          print "\n ERROR: Genus Code: #{row['Code']} not found \n" if !row['Code'].blank? && genus.nil?
          unless taxon.nil?
            unless genus.nil?
              TaxonNameRelationship.create(type: 'TaxonNameRelationship::Typification::Family', subject_taxon_name_id: genus, object_taxon_name: taxon)
            end
            unless ref.nil?
              taxon.citations.create!(source_id: ref, pages: row['PageRef'], is_original: true)
            end
            taxon.notes.create!(text: row['Notes'].gsub(/\|/,'_')) unless row['Notes'].blank?
            da = taxon.data_attributes.create(type: 'InternalAttribute', predicate: keywords['FamTrib:Status'], value: status_type[row['Status']]) unless row['Status'].blank?

            byebug if da.try(:id).blank?
          end
        end
      end

      def handle_genus_ucd
        path = @args[:data_directory] + 'GENUS.txt'
        print "\nHandling GENUS\n"
        raise "file #{path} not found" if not File.exists?(path)
        file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'iso-8859-1:UTF-8')

        type_type = {
          'MT' => 'TaxonNameRelationship::Typification::Genus::Original::OriginalMonotypy',
          'OD' => 'TaxonNameRelationship::Typification::Genus::Original::OriginalDesignation',
          'OM' => 'TaxonNameRelationship::Typification::Genus::Original',
          'SD' => 'TaxonNameRelationship::Typification::Genus::Subsequent::SubsequentDesignation',
          'SM' => 'TaxonNameRelationship::Typification::Genus::Subsequent::SubsequentMonotypy',
          ''   => 'TaxonNameRelationship::Typification::Genus' # This is correct
        }.freeze

        keywords = {
          'Genus:Status' => Predicate.find_or_create_by(name: 'Genus:Status', definition: 'The verbatim value in Genus#Status.', project_id: Current.project_id)
        }.freeze

        status_type = {
          'NG' => 'New genus', # nothing
          'RN' => 'Replacement name', # relationship
          'SG' => 'Subgenus', # rank and parent
          'UE' => 'Unjustified emendantion', #relationship
          'UR' => 'Unnecessary replacement name', #relationship
          'US' => 'Unjustified emendation, new status' #relationship
        }
        classification_type = {
            'AB' => 'TaxonNameClassification::Iczn::Unavailable::Excluded::Infrasubspecific',
            'FS' => 'TaxonNameClassification::Iczn::Fossil',
            'ND' => 'TaxonNameClassification::Iczn::Available::Valid::NomenDubium',
            'NN' => 'TaxonNameClassification::Iczn::Unavailable::NomenNudum',
        }

        i = 0
        file.each do |row|
          i += 1
          print "\r#{i}"
          taxon = find_taxon_ucd(row['TaxonCode'])
          species = find_taxon_id_ucd(row['Code'])
          ref = find_source_id_ucd(row['RefCode'])
          designator = find_source_id_ucd(row['Designator'])
          print "\n ERROR: TaxonCode: #{row['TaxonCode']} not found \n" if !row['TaxonCode'].blank? && taxon.nil?
          print "\n ERROR: Species Code: #{row['Code']} not found \n" if !row['Code'].blank? && species.nil?
          typedesign = row['TypeDesign'].blank? ? type_type[''] : type_type[row['TypeDesign']]

          unless taxon.nil?
            unless species.nil?
              TaxonNameRelationship.create(type: typedesign, subject_taxon_name_id: species, object_taxon_name: taxon,
                                           origin_citation_attributes: {source_id: designator, pages: row['PageDesign']})
            end

            unless ref.nil?
              taxon.citations.create(source_id: ref, pages: row['PageRef'], is_original: true)
            end

#            if taxon.type == 'Combination' && !classification_type[row['CurrStat']].nil?
#              # valid = TaxonName.find(taxon.cached_valid_taxon_name_id)
#              valid = taxon.subgenus || taxon.genus
#              byebug if valid.nil?
#              taxon = valid unless valid.nil?
#            end

            taxon.notes.create(text: row['Notes'].gsub('|','_')) unless row['Notes'].blank?
            taxon.data_attributes.create(type: 'InternalAttribute', predicate: keywords['Genus:Status'], value: status_type[row['Status']]) unless row['Status'].blank?
          end
        end
      end

      def handle_species_ucd
        path = @args[:data_directory] + 'SPECIES.txt'
        print "\nHandling SPECIES\n"
        raise "file #{path} not found" if not File.exists?(path)
        file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'iso-8859-1:UTF-8')

        keywords = {
          'Region' => Predicate.find_or_create_by(name: 'Species:Region', definition: 'The verbatim value in Species#Region.', project_id: Current.project_id),
          'Species:Country' => Predicate.find_or_create_by(name: 'Species:Country', definition: 'The verbatim value in Species#Coutry-State.', project_id: Current.project_id),
          'Coll:Depository' => Predicate.find_or_create_by(name: 'Coll:Depository', definition: 'The verbatim value in Coll#Depository.', project_id: Current.project_id),
          'Sex' => Predicate.find_or_create_by(name: 'Species:Sex', definition: 'The verbatim value in Species#Sex.', project_id: Current.project_id),
          'Figures' => Predicate.find_or_create_by(name: 'Species:Figures', definition: 'The verbatim value in Species#Figures.', project_id: Current.project_id),
          'PrimType' => Predicate.find_or_create_by(name: 'Species:PrimType', definition: 'The verbatim value in Species#PrimType.', project_id: Current.project_id),
          'TypeSex' => Predicate.find_or_create_by(name: 'Species:TypeSex', definition: 'The verbatim value in Species#TypeSex.', project_id: Current.project_id),
          'Designator' => Predicate.find_or_create_by(name: 'Species:Designator', definition: 'The verbatim value in Species#Designator.', project_id: Current.project_id),
          'Depository' => Predicate.find_or_create_by(name: 'Species:Depository', definition: 'The verbatim value in Species#Depository.', project_id: Current.project_id),
          'TypeNumber' => Predicate.find_or_create_by(name: 'Species:TypeNumber', definition: 'The verbatim value in Species#TypeNumber.', project_id: Current.project_id),
          'DeposB' => Predicate.find_or_create_by(name: 'Species:DeposB', definition: 'The verbatim value in Species#DeposB.', project_id: Current.project_id),
          'DeposC' => Predicate.find_or_create_by(name: 'Species:DeposC', definition: 'The verbatim value in Species#DeposC.', project_id: Current.project_id),
          'Species:CurrStat' => Predicate.find_or_create_by(name: 'Species:CurrStat', definition: 'The verbatim value in Species#CurrStat.', project_id: Current.project_id),
          'Status:Meaning' => Predicate.find_or_create_by(name: 'Status:Meaning', definition: 'The verbatim value in Status#Meaning.', project_id: Current.project_id)
        }.freeze
        topics = {
          'Figures' => Topic.find_or_create_by(name: 'Figures', definition: 'Original source has figures.', project_id: Current.project_id)
        }

        status_type = {
          'AB' => 'Aberration',
          'FM' => 'Form',
          'NS' => 'New species',
          'NT' => 'New species, invalid spelling',
          'NU' => 'New species, misspelt generic name',
          'NW' => 'New species, misspelt subgeneric name',
          'NY' => 'New species, generic placement queried',
          'RN' => 'Replacement name',
          'SS' => 'Subspecies',
          'UE' => 'Unjustified emendation',
          'UN' => 'Unjustified emendation, new combination',
          'UR' => 'Unnecessary replacement name',
          'VM' => 'Variety, misspelt species name',
          'VR' => 'Variety',
          'VS' => 'Valid species'
        }
        classification_type = {
          'AB' => 'TaxonNameClassification::Iczn::Unavailable::Excluded::Infrasubspecific',
          'FS' => 'TaxonNameClassification::Iczn::Fossil',
          'ND' => 'TaxonNameClassification::Iczn::Available::Valid::NomenDubium',
          'NN' => 'TaxonNameClassification::Iczn::Unavailable::NomenNudum',
        }

        i = 0
        file.each do |row|
 #         byebug if row['TaxonCode'] == 'Eupelm acineA' || row['TaxonCode'] == 'Eupelm acineAa'
          i += 1
          print "\r#{i}"
          taxon = find_taxon_ucd(row['TaxonCode'])
          ref = find_source_id_ucd(row['RefCode'])
          print "\n ERROR: TaxonCode: #{row['TaxonCode']} not found \n" if !row['TaxonCode'].blank? && taxon.nil?
          unless taxon.nil?
#            if taxon.type == 'Combination' && !classification_type[row['CurrStat']].nil?
#              # valid = TaxonName.find(taxon.cached_valid_taxon_name_id)
#              valid = taxon.subspecies || taxon.species
#              byebug if valid.nil?
#              taxon = valid unless valid.nil?
#            end
            unless ref.nil?
              c = taxon.citations.create(source_id: ref, pages: row['PageRef'], is_original: true)

              if !c.id.blank? 
                c.citation_topics.find_or_create_by(topic: topics['Figures'], project_id: Current.project_id) unless row['Figures'].blank?
              end

            end
            taxon.notes.create(text: row['Notes'].gsub('|', '_')) unless row['Notes'].blank?
            taxon.data_attributes.create!(type: 'InternalAttribute', predicate: keywords['Status:Meaning'], value: status_type[row['CurrStat']]) unless status_type[row['CurrStat']].nil?
            taxon.data_attributes.create!(type: 'InternalAttribute', predicate: keywords['Species:Country'], value: @data.countries[row['Country'].to_s + '|' + row['State'].to_s]) unless @data.countries[row['Country'].to_s + '|' + row['State'].to_s].blank?
            taxon.data_attributes.create!(type: 'InternalAttribute', predicate: keywords['Coll:Depository'], value: @data.collections[row['Depository']]) unless @data.collections[row['Depository']].nil?
            keywords.each_key do |k|
              da = taxon.data_attributes.create(type: 'InternalAttribute', predicate: keywords[k], value: row[k]) unless row[k].blank?

              byebug if da && da.id.blank?
            end
            taxon.taxon_name_classifications.create(type: classification_type[row['CurrStat']]) unless classification_type[row['CurrStat']].nil?
          end
        end
      end

      def handle_h_fam_ucd
        keywords = {
          'SuperFam' => Predicate.find_or_create_by(name: 'H-Fam:SuperFam', definition: 'The verbatim value in H-Fam#SuperFam.', project_id: Current.project_id)
        }.freeze

        path = @args[:data_directory] + 'H-FAM.txt'
        print "\nHandling H-FAM\n"
        raise "file #{path} not found" if not File.exists?(path)
        file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'iso-8859-1:UTF-8')
        plantae = Protonym.find_or_create_by!(name: 'Plantae', rank_class: Ranks.lookup(:icn, 'kingdom'), parent: @root, project_id: Current.project_id)

        file.each_with_index do |row, i|
          print "\r#{i}"
          name = row['Order'].to_s.gsub('.', '')

          if name.blank?
            taxon = @root
          else
            rnk = 'NomenclaturalRank::Iczn::HigherClassificationGroup::Order'
            if row['Order'] == 'Bacteria'
              rnk = 'NomenclaturalRank::Icn::HigherClassificationGroup::Kingdom'
            elsif row['Family'] =~/^[A-Z]\w*aceae/
              rnk = 'NomenclaturalRank::Icn::HigherClassificationGroup::Order'
            end

            taxon = Protonym.find_or_create_by(name: name, parent: @root, rank_class: rnk, project_id: Current.project_id)
          end

          parent = taxon
	
          if row['SuperFam'] =~/^[A-Z]\w*oidea/
            name = row['SuperFam']
            taxon = Protonym.find_or_create_by(name: name, parent: parent, rank_class: 'NomenclaturalRank::Iczn::FamilyGroup::Superfamily', project_id: Current.project_id)
          end

          parent = taxon

          name = row['Family'].to_s.gsub(' indet.', '').gsub(' (part)', '').gsub(' ', '')
          if row['Family'] =~/^[A-Z]\w*idae/
            if row['SuperFam'] == 'Chalcidoidea'
              taxon = Protonym.find_or_create_by(name: name, cached: name, rank_class: 'NomenclaturalRank::Iczn::FamilyGroup::Family', project_id: Current.project_id)
              if taxon.id.nil?
                name1 = Protonym.family_group_name_at_rank(name, 'Subfamily')
                taxon = Protonym.find_or_create_by(name: name1, cached: name1, rank_class: 'NomenclaturalRank::Iczn::FamilyGroup::Subfamily', project_id: Current.project_id)
              end

              byebug if taxon.id.nil?
            else
              taxon = Protonym.find_or_create_by(name: name, parent: parent, rank_class: 'NomenclaturalRank::Iczn::FamilyGroup::Family', project_id: Current.project_id)
            end

          elsif row['Family'] =~/^[A-Z]\w*aceae/
            taxon = Protonym.find_or_create_by(name: name, parent: plantae, rank_class: 'NomenclaturalRank::Icn::FamilyGroup::Family', project_id: Current.project_id)
          elsif row['Family'] == 'Bacteria indet.'
            taxon = Protonym.find_or_create_by(name: 'Bacteria', parent: @root, rank_class: 'NomenclaturalRank::Iczn::HigherClassificationGroup::Kingdom', project_id: Current.project_id)
          elsif row['Family'] == 'Slime mould'
            k = Protonym.find_or_create_by(name: 'Bacteria', parent: @root, rank_class: 'NomenclaturalRank::Iczn::HigherClassificationGroup::Kingdom', project_id: Current.project_id)
            taxon = Protonym.find_or_create_by(name: 'Slime', parent: k, rank_class: 'NomenclaturalRank::Iczn::HigherClassificationGroup::Phylum', project_id: Current.project_id)
          end

          if taxon.nil? || taxon.id.nil?
	    puts "invalid row #{row['Family']}, #{row['Code']}"
	    next
	  end

          taxon.data_attributes.create(type: 'InternalAttribute', predicate: keywords['SuperFam'], value: row['SuperFam']) if !row['SuperFam'].blank? && !taxon.parent.nil? && taxon.parent.rank_class != 'NomenclaturalRank::Iczn::FamilyGroup::Superfamily' && taxon.data_attributes.nil?
          taxon.identifiers.create(type: 'Identifier::Local::Import', namespace_id: @data.keywords['host_family_id'], identifier: row['Code']) if !row['Code'].blank?
          @data.hostfamilies[row['Code']] = taxon.id

        end

      end

      def handle_hostfam_ucd
        path = @args[:data_directory] + 'HOSTFAM.txt'
        print "\nHandling HOSTFAM\n"
        raise "file #{path} not found" if not File.exists?(path)
        file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'iso-8859-1:UTF-8')
        file.each_with_index do |row, i|
          print "\r#{i}"

          # TODO: don't reuse variables like this, it leads to downstream confusion
          family = find_host_family_id_ucd(row['PrimHosFam']) || @root.id # should be parent_id
          parent = family
          parent = TaxonName.find(parent) # this will raise if parent doesn't exist, so if you go further it does exist

          nc = parent == @root ? :iczn : parent.rank_class.nomenclatural_code

          taxon = Protonym.where(name: row['HosGenus'], rank_class: Ranks.lookup(nc, 'Genus'), project_id: Current.project_id).order(:id).first

          if !taxon.nil?
            ancestors = taxon.safe_self_and_ancestors.collect{|t| t.id}
            if !ancestors.include?(family)
              taxon = Protonym.find_or_create_by(name: row['HosGenus'], parent: parent, rank_class: Ranks.lookup(nc, 'Genus'), project_id: Current.project_id)
            end
          else
            taxon = Protonym.find_or_create_by(name: row['HosGenus'], parent: parent, rank_class: Ranks.lookup(nc, 'Genus'), project_id: Current.project_id)
          end


          parent = taxon if !taxon.id.blank? # if found don't validate it!

          # TODO: now re-using taxon?.. confusing 
          unless row['HosSpecies'].blank?
            taxon = Protonym.where(cached: row['HosGenus'] + ' ' + row['HosSpecies'], rank_class: Ranks.lookup(nc, 'Species'), project_id: Current.project_id).order(:id).first
            if !taxon.nil?
              ancestors = taxon.safe_self_and_ancestors.collect{|t| t.id}
              if !ancestors.include?(family)
                taxon = Protonym.find_or_create_by(name: row['HosSpecies'], rank_class: Ranks.lookup(nc, 'Species'), parent: parent, project_id: Current.project_id)
              end
            else
              taxon = Protonym.find_or_create_by(name: row['HosSpecies'], rank_class: Ranks.lookup(nc, 'Species'), parent: parent, project_id: Current.project_id)
            end
          end

          #   unless row['HosAuthor'].blank?
          #     taxon.verbatim_author = row['HosAuthor']
          #     taxon.save if taxon.valid?  
          #   end

          # Prevent another validation
          if !taxon.id.blank?
            taxon.update_column(:verbatim_author, row['HosAuthor']) if !row['HosAuthor'].blank? # validation skipped, callbacks 
          end

          # it could become invalid if verbatim_author is set? 
          taxon = TaxonName.find(parent.id) unless taxon.valid? # bad form to re-use variable name - and this doesn't make sense, you already have a parent why find it again?
          taxon.identifiers.create(type: 'Identifier::Local::Import', namespace_id: @data.keywords['hos_number'], identifier: row['HosNumber']) if !row['HosNumber'].blank?
        end
      end

      def handle_hosts_ucd
        relation = {'APL' => BiologicalRelationship.find_or_create_by(name: 'Plant associate', project_id: Current.project_id),
                    'AST' => BiologicalRelationship.find_or_create_by(name: 'Associate', project_id: Current.project_id),
                    'HYP' => BiologicalRelationship.find_or_create_by(name: 'Parasitoid', project_id: Current.project_id),
                    'PAH' => BiologicalRelationship.find_or_create_by(name: 'Parasitoid host', project_id: Current.project_id),
                    'PLH' => BiologicalRelationship.find_or_create_by(name: 'Plant host', project_id: Current.project_id),
                    'PRH' => BiologicalRelationship.find_or_create_by(name: 'Primary host', project_id: Current.project_id),
        }.freeze

        bp = { 'Pollinator' => BiologicalProperty.find_or_create_by(name: 'Pollinator', definition:'An insect pollinating a plant'),
               'Pollinated plant' => BiologicalProperty.find_or_create_by(name: 'Pollinated plant', definition:'A plant visited by insects'),
               'Attendant' => BiologicalProperty.find_or_create_by(name: 'Attendant', definition:'An insect attending another insect'),
               'Attended insect' => BiologicalProperty.find_or_create_by(name: 'Attended insect', definition:'An insect attended by another insect'),
               'Host' => BiologicalProperty.find_or_create_by(name: 'Host', definition:'An animal or plant on or in which a parasite or commensal organism lives'),
               'Parasitoid' => BiologicalProperty.find_or_create_by(name: 'Parasitoid', definition:'An organism that lives in or on another organism'),
        }

        BiologicalRelationshipType::BiologicalRelationshipSubjectType.find_or_create_by(project_id: Current.project_id, biological_property: bp['Pollinator'], biological_relationship: relation['APL'])
        BiologicalRelationshipType::BiologicalRelationshipObjectType.find_or_create_by(project_id: Current.project_id, biological_property: bp['Pollinated plant'], biological_relationship: relation['APL'])
        BiologicalRelationshipType::BiologicalRelationshipSubjectType.find_or_create_by(project_id: Current.project_id, biological_property: bp['Attendant'], biological_relationship: relation['AST'])
        BiologicalRelationshipType::BiologicalRelationshipObjectType.find_or_create_by(project_id: Current.project_id, biological_property: bp['Attended insect'], biological_relationship: relation['AST'])
        BiologicalRelationshipType::BiologicalRelationshipSubjectType.find_or_create_by(project_id: Current.project_id, biological_property: bp['Host'], biological_relationship: relation['HYP'])
        BiologicalRelationshipType::BiologicalRelationshipObjectType.find_or_create_by(project_id: Current.project_id, biological_property: bp['Parasitoid'], biological_relationship: relation['HYP'])
        BiologicalRelationshipType::BiologicalRelationshipSubjectType.find_or_create_by(project_id: Current.project_id, biological_property: bp['Parasitoid'], biological_relationship: relation['PAH'])
        BiologicalRelationshipType::BiologicalRelationshipObjectType.find_or_create_by(project_id: Current.project_id, biological_property: bp['Host'], biological_relationship: relation['PAH'], type: '')
        BiologicalRelationshipType::BiologicalRelationshipSubjectType.find_or_create_by(project_id: Current.project_id, biological_property: bp['Parasitoid'], biological_relationship: relation['PLH'])
        BiologicalRelationshipType::BiologicalRelationshipObjectType.find_or_create_by(project_id: Current.project_id, biological_property: bp['Host'], biological_relationship: relation['PLH'])
        BiologicalRelationshipType::BiologicalRelationshipSubjectType.find_or_create_by(project_id: Current.project_id, biological_property: bp['Parasitoid'], biological_relationship: relation['PRH'])
        BiologicalRelationshipType::BiologicalRelationshipObjectType.find_or_create_by(project_id: Current.project_id, biological_property: bp['Host'], biological_relationship: relation['PRH'])

        keywords = {
          'ParTypeA' => Predicate.find_or_create_by(name: 'Hosts:ParTypeA', definition: 'The verbatim value in Hosts#ParTypeA.', project_id: Current.project_id),
          'ParTypeB' => Predicate.find_or_create_by(name: 'Hosts:ParTypeB', definition: 'The verbatim value in Hosts#ParTypeB.', project_id: Current.project_id),
          'ParTypeC' => Predicate.find_or_create_by(name: 'Hosts:ParTypeC', definition: 'The verbatim value in Hosts#ParTypeC.', project_id: Current.project_id),
          'ParTypeD' => Predicate.find_or_create_by(name: 'Hosts:ParTypeD', definition: 'The verbatim value in Hosts#ParTypeD.', project_id: Current.project_id),
          #'ReliableA' => Predicate.find_or_create_by(name: 'Hosts:ReliableA', definition: 'The verbatim value in Hosts#ReliableA.', project_id: Current.project_id),
          #'ReliableB' => Predicate.find_or_create_by(name: 'Hosts:ReliableB', definition: 'The verbatim value in Hosts#ReliableB.', project_id: Current.project_id),
          'Comment' => Predicate.find_or_create_by(name: 'Hosts:Comment', definition: 'The verbatim value in Hosts#Comment.', project_id: Current.project_id),
          'CommonName' => Predicate.find_or_create_by(name: 'Hosts:CommonName', definition: 'The verbatim value in Hosts#CommenName.', project_id: Current.project_id),
        }.freeze

        path = @args[:data_directory] + 'HOSTS.txt'
        print "\nHandling HOSTS\n"
        raise "file #{path} not found" if not File.exists?(path)
        file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'iso-8859-1:UTF-8')
        i = 0

        file.each do |row|
          i += 1
          print "\r#{i}"
        
          taxon = find_taxon_id_ucd(row['TaxonCode'])
          host = find_host_id_ucd(row['HosNumber'])
         
          host = find_host_family_id_ucd(row['PrimHosFam']) if row['HosNumber'].blank?
          ref = find_source_id_ucd(row['RefCode'])
          br = relation[row['Relation']]
          
          if taxon && host && br

            subject = Otu.find_or_create_by(taxon_name_id: taxon, project_id: Current.project_id)
            object = Otu.find_or_create_by(taxon_name_id: host, project_id: Current.project_id)

            r = BiologicalAssociation.find_or_create_by!(biological_relationship: br, biological_association_subject: subject, biological_association_object: object, project_id: Current.project_id)
            r.citations.create(source_id: ref, pages: row['PageRef']) unless ref.nil?
            r.notes.create(text: row['Notes'].gsub('|','_')) unless row['Notes'].blank?
            r.data_attributes.create(type: 'InternalAttribute', predicate: keywords['ParTypeA'], value: @data.ptype[row['ParTypeA']]) unless row['ParTypeA'].blank?
            r.data_attributes.create(type: 'InternalAttribute', predicate: keywords['ParTypeB'], value: @data.ptype[row['ParTypeB']]) unless row['ParTypeB'].blank?
            r.data_attributes.create(type: 'InternalAttribute', predicate: keywords['ParTypeC'], value: @data.ptype[row['ParTypeC']]) unless row['ParTypeC'].blank?
            r.data_attributes.create(type: 'InternalAttribute', predicate: keywords['ParTypeD'], value: @data.ptype[row['ParTypeD']]) unless row['ParTypeD'].blank?
            r.data_attributes.create(type: 'InternalAttribute', predicate: keywords['Comment'], value: row['Comment']) unless row['Comment'].blank?
            r.data_attributes.create(type: 'InternalAttribute', predicate: keywords['CommonName'], value: row['CommonName']) unless row['CommonName'].blank?
            r.confidences.create(position: 1, confidence_level_id: @data.reliable[row['ReliableA']]) unless row['ReliableA'].blank?
            r.confidences.create(position: 2, confidence_level_id: @data.reliable[row['ReliableB']]) unless row['ReliableB'].blank?
            #r.data_attributes.create(type: 'InternalAttribute', predicate: keywords['ReliableA'], value: @data.reliable[row['ReliableA']]) unless row['ReliableA'].blank?
            #r.data_attributes.create(type: 'InternalAttribute', predicate: keywords['ReliableB'], value: @data.reliable[row['ReliableB']]) unless row['ReliableB'].blank?
          else
            print "\n ERROR: Invalid host relationship: TaxonCode: #{row['TaxonCode']}, Relation: #{row['Relation']}, PrimHosFam: #{row['PrimHosFam']}, HosNumber: #{row['HosNumber']}\n"
          end
        end
      end

      def handle_dist_ucd
        unresolved = {}
        path = @args[:data_directory] + 'DIST.txt'
        print "\nHandling DIST \n"
        raise "file #{path} not found" if not File.exists?(path)

        file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'iso-8859-1:UTF-8')

        i = 0
        file.each do |row|
          i += 1
          print "\r#{i}"

          source_id = find_source_id_ucd(row['RefCode'])
          if source_id.nil?  # no point in searching forward, abort
            print " ERROR: Reference #{row['RefCode']} not found skipping asserted distribution for this row!\n"
            next
          end

          taxon_id = find_taxon_id_ucd(row['TaxonCode'])

          otu = Otu.find_or_create_by(taxon_name_id: taxon_id)

          if otu.id.blank? # no point in searching forward, abort - don't check valid, check if ID is there, it has to be valid then
            print " ERROR: OTU for TaxonCode #{row['TaxonCode']} not found skipping asserted distribution for this row!\n"
            next
          end

          match = "#{row['Country']}|#{row['State']}"

          geographic_area_id = @data.countries[match]

          if geographic_area_id.nil? || geographic_area_id == 'no match'
            print "skipping: #{i}: #{match}"
            next
          end

          # at this point you know you have an otu, a ga, and a ref, no need to check validity
          ad = AssertedDistribution.find_or_create_by(
            otu: otu,
            geographic_area_id: geographic_area_id, 
            project_id: Current.project_id 
          )

          c = nil
          if ad.id.nil?
            c = ad.citations.new(source_id: source_id, pages: row['PageRef'])
            ad.save!
          else
            c = ad.citations.find_or_create_by(source_id: source_id, pages: row['PageRef'])
          end

          if !ad.id.blank? 
            ad.confidences.create(confidence_level_id: @data.reliable[row['Reliable']]) unless row['Reliable'].blank?
            ad.confidences.create(confidence_level_id: @data.reliable[row['Comment']]) unless row['Comment'].blank?
            ad.notes.create(text: row['Notes']) unless row['Notes'].blank?

            CitationTopic.find_or_create_by(topic_id: @data.topics[row['Keyword']], citation: c) unless row['Keyword'].blank?
          end

        end
      end

      def handle_hknew_ucd
        path = @args[:data_directory] + 'HKNEW.txt'
        print "\nHandling HKNEW\n"
        raise "file #{path} not found" if not File.exists?(path)
        
        file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'iso-8859-1:UTF-8')

        file.each_with_index do |row, i|
          print "\r#{i}"

          taxon = find_taxon_ucd(row['TaxonCode'])
          # otu = @data.otus[row['TaxonCode'].to_s]
 
          print "\n ERROR: TaxonCode: #{row['TaxonCode']} not found \n" if row['TaxonCode'].blank?
          #print "\n No corresponding OTU for TaxonCode: [#{row['TaxonCode']}] \n" if otu.nil? #  taxon.nil?

          if taxon.nil?
            print "\n ERROR: Taxon not found. TaxonCode: [#{row['TaxonCode']}] \n"
            next
          end

          ref = find_source_id_ucd(row['RefCode'])

          if ref.nil?
            print "\n ERROR: No reference found for #{row['RefCode']} \n"
            next
          end

          page = row['PageRef'].blank? ? nil : row['PageRef']

          otu = Otu.find_or_create_by(taxon_name_id: taxon.id)
          c = otu.citations.find_or_create_by(source_id: ref, pages: page)

          CitationTopic.find_or_create_by(topic_id: @data.topics[row['Keyword']], citation: c) unless row['Keyword'].blank?
          Note.find_or_create_by(note_object: c, text: row['Notes'].gsub('|','_') ) unless row['Notes'].blank?
        end
      end

      def handle_tstat_ucd

        relationship = {
          'AC' => 'TaxonNameRelationship::Iczn::Invalidating::Usage::IncorrectOriginalSpelling', # 'Alternative original combination of',
          'AS' => 'TaxonNameRelationship::Iczn::Invalidating::Usage::IncorrectOriginalSpelling', # 'Alternative original spelling of',
          'AT' => 'TaxonNameRelationship::Iczn::Invalidating::Usage::IncorrectOriginalSpelling', # 'Alternative original status of',
          'CH' => 'TaxonNameRelationship::Iczn::Invalidating::Homonym::Secondary', # 'Junior secondary homonym of',
          'CM' => 'TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling', # 'Misspelt species name, compared with',
          'DT' => 'TaxonNameRelationship::Typification::Genus::Subsequent::SubsequentDesignation', # 'Designated type species of'
          'IC' => 'TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling', # 'Misspelling based on original lapsus for',
          'ID' => 'TaxonNameRelationship::Iczn::Invalidating', # 'Identified subsequently as',
          'IE' => 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::UnjustifiedEmendation', # 'Incorrect, justified emendation of',
          'IN' => 'TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling', #'Invalid spelling of',
          'IO' => 'TaxonNameRelationship::Iczn::Invalidating::Usage::IncorrectOriginalSpelling', # 'Incorrect original spelling of',
          'IT' => 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective', # 'Isotypic (same primary type) with',
          'JH' => 'TaxonNameRelationship::Iczn::Invalidating::Homonym::Primary', # 'Junior primary homonym of',
          'LA' => 'TaxonNameRelationship::Iczn::Invalidating', # 'Lapsus for',
          'MA' => 'TaxonNameRelationship::Iczn::Invalidating', # 'Misidentified as',
          'MB' => 'TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling', # 'Misspelling of genus and species names of', #####
          'MF' => 'TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling', # 'Misspelt family group name',
          'MG' => 'TaxonNameRelationship::Iczn::Invalidating', # 'Misspelling of genus name',   ######
          'MI' => 'TaxonNameRelationship::Iczn::Invalidating', # 'Misidentification',
          'MJ' => 'TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling', # 'Misspelt species name, synonym of',
          'MO' => 'TaxonNameRelationship::Iczn::Invalidating', # 'Misidentification of',
          'MP' => 'TaxonNameRelationship::Iczn::Invalidating', # 'Misidentification (in part) as',
          'MS' => 'TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling', # 'Misspelling of species group name',
          'MY' => 'TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling', # 'Misspelt family group name of',
          'NM' => 'TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling', # 'Misspelt species name, new combination for',
          'NR' => 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression', # 'Name rejected in favour of',
          'NQ' => 'TaxonNameRelationship::Iczn::Invalidating', # 'Nomen nudum, but identified subsequently as',
          'OT' => 'TaxonNameRelationship::Typification::Genus::Subsequent::RulingByCommission', # 'Placed on official list as type species of',
          'PL' => 'TaxonNameRelationship::Iczn::Invalidating', # 'Possible lapsus for',
          'PM' => 'TaxonNameRelationship::Iczn::Invalidating', # 'Misidentification (in part) of',
          'PO' => 'TaxonNameRelationship::Iczn::Invalidating', # 'Possible misidentification of',
          'RN' => 'TaxonNameRelationship::Iczn::PotentiallyValidating::ReplacementName', # 'Replacement name',
          'RO' => 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::SynonymicHomonym', # 'Repetition of original description of',
          'SA' => 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::UnjustifiedEmendation', # 'Spelling rejected',
          'SE' => 'TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling', # 'Misspelling based on incorrect emendation of',
          'SH' => 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::SynonymicHomonym', # 'Junior synonym and homonym of',
          'SL' => 'TaxonNameRelationship::Iczn::Invalidating', # 'New status, lapsus for',
          'ST' => 'TaxonNameRelationship::Iczn::Invalidating::Synonym', # 'Synonymized, by implication, with',
          'SY' => 'TaxonNameRelationship::Iczn::Invalidating::Synonym', # 'Synonym of',
          'TD' => 'TaxonNameRelationship::Typification::Genus::Subsequent::SubsequentDesignation', # 'Designated type species of',
          'TS' => 'TaxonNameRelationship::Iczn::Invalidating::Synonym', # 'Type species transferred to',
          'UE' => 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::UnjustifiedEmendation', # 'Unjustified emendation',
          'UI' => 'TaxonNameRelationship::Iczn::Invalidating', # 'Unavailable name, identified subsequently as',
          'UR' => 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::UnnecessaryReplacementName', # 'Unnecessary replacement name',
          'VM' => 'TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling', # 'Variety, misspelt species name',
          'FY' => 'TaxonNameRelationship::SourceClassifiedAs', # 'Family of',
          'SB' => 'TaxonNameRelationship::SourceClassifiedAs', # 'Subfamily of',
          'TT' => 'TaxonNameRelationship::SourceClassifiedAs', # 'Transferred, by implication, to',
        }.freeze

        classification = {
          'AN' => 'TaxonNameClassification::Iczn::Available', # 'Available name',
          'LA' => 'TaxonNameClassification::Iczn::Unavailable', # 'Lapsus for',
          'ND' => 'TaxonNameClassification::Iczn::Available::Valid::NomenDubium', # 'Nomen dubium',
          'NN' => 'TaxonNameClassification::Iczn::Unavailable::NomenNudum', # 'Nomen nudum',
          'NP' => 'TaxonNameClassification::Iczn::Unavailable::NomenNudum', # 'Nomen nudum, new combination for',
          'NQ' => 'TaxonNameClassification::Iczn::Unavailable::NomenNudum', # 'Nomen nudum, but identified subsequently as',
          'NX' => 'TaxonNameClassification::Iczn::Unavailable::NomenNudum', # 'Nomen nudum, based on misspelling of',
          'OG' => 'TaxonNameClassification::Iczn::Available::OfficialListOfGenericNamesInZoology', # 'Placed on Official List of Generic Names',
          'OR' => 'TaxonNameClassification::Iczn::Unavailable::Suppressed', # 'Placed on Official List of Rejected Names',
          'OS' => 'TaxonNameClassification::Iczn::Available::OfficialListOfSpecificNamesInZoology', # 'Placed on Official List of Species Names',
          'PL' => 'TaxonNameClassification::Iczn::Unavailable', # 'Possible lapsus for',
          'SI' => 'TaxonNameClassification::Iczn::Available::Valid::NomenDubium', # 'Species inquirenda',
          'SL' => 'TaxonNameClassification::Iczn::Unavailable', # 'New status, lapsus for',
          'UI' => 'TaxonNameClassification::Iczn::Unavailable', # 'Unavailable name, identified subsequently as',
          'UV' => 'TaxonNameClassification::Iczn::Unavailable', # 'Unavailable name',
        }.freeze

        combination = {
          'CG' => 'Misspelt generic name, new combination for',
          'CS' => 'New combination, status revived for',
          'FR' => 'Form, new status for',
          'GI' => 'Generic placement incorrect',
          'GQ' => 'Generic placement queried',
          'GR' => 'Generic placement queried, new combination for',
          'GS' => 'Generic name synonymized with', # only generic name provided for species
          'IA' => 'Incorrect gender agreement of species name in',
          'JG' => 'Misspelt generic name, justified emendation of',
          'MC' => 'Mandatory change of species name in',
          'NA' => 'Name based based on alternative original spelling of',
          'NC' => 'New combination for',
          'NE' => 'New combination, justified emendation of',
          'NF' => 'New combination based on misspelt species name',
          'NH' => 'New combination based on unjustified emendation of',
          'NI' => 'New combination based on lapsus for',
          'NJ' => 'New combination based on incorrect emendation of',
          'NK' => 'New combination, incorrect justified emendation of',
          'NL' => 'New combination, by implication, for',
          'NO' => 'New status, subspecies of',
          'NV' => 'Name revived for',
          'NZ' => 'New combination based on misspelt species name of',
          'PC' => 'Possible new combination in',
          'PF' => 'Possible new combination for',
          'RC' => 'Revived combination for',
          'RV' => 'Revived combination, valid species for',
          'SC' => 'New status, new combination for',
          'SF' => 'New status, subgenus of',
          'SJ' => 'SubsequentMonotypy use of unjustified emendation of',
          'SN' => 'New status for',
          'SR' => 'Status revived',
          'SS' => 'Subspecies',
          'SV' => 'Spelling validated',
          'SW' => 'Status revived, combination revived for',
          'TI' => 'Transferred, by implication, from',
          'VC' => 'Valid species, new combination',
          'VO' => 'Variety, new status for',
        }.freeze

        compared_with = {
            'CF' => 'Compared with' # BIO REL
        }

        biological_relationship = BiologicalRelationship.find_or_create_by(name: 'compared with', inverted_name: 'reference for', project_id: Current.project_id)

        notes = {
          'FM' => 'Form',
          'FR' => 'Form, new status for',
          'PS' => 'Possible synonym of',
          'CR' => 'New combination and replacement',
          'CV' => 'Request to ICZN for conservation of name',
          'CM' => 'Misspelt species name, compared with', # 'Misspelt species name, compared with',
          'DI' => 'Division of',
          'EX' => 'Excluded from Chalcidoidea',
          'ID' => 'Identified subsequently as', # 'Identified subsequently as',
          'IS' => 'Incertae sedis',
          'JE' => 'Justified emendation of',
          'JG' => 'Misspelt generic name, justified emendation of',
          'LA' => 'Lapsus for', # 'Lapsus for',
          'MA' => 'Misidentified as', # 'Misidentified as',
          'MI' => 'Misidentification', # 'Misidentification',
          'MO' => 'Misidentification of', # 'Misidentification of',
          'MP' => 'Misidentification (in part) as', # 'Misidentification (in part) as',
          'NG' => 'New genus',
          'NS' => 'New species',
          'PC' => 'Possible new combination in',
          'PF' => 'Possible new combination for',
          'PL' => 'Possible lapsus for', # 'Possible lapsus for',
          'PM' => 'Misidentification (in part) of', # 'Misidentification (in part) of',
          'PO' => 'Possible misidentification of', # 'Possible misidentification of',
          'PV' => 'Possibly valid species',
          'RT' => 'Request to ICZN for type species designation as',
          'SP' => 'Request to ICZN for suppression in favour of',
          'SG' => 'Subgenus',
          'SL' => 'New status, lapsus for', # 'New status, lapsus for',
          'SZ' => 'Superfamily',
          'TC' => 'Type species cited as',
          'VF' => 'Family of',
          'VG' => 'Valid genus', # like VG
          'VI' => 'Valid subtribe of',
          'VR' => 'Variety',
          'VS' => 'Valid species',   # like VS
          'VT' => 'Valid tribe of', # like VY
          'VY' => 'Valid superfamily', # citations on protonym with note "VT: [note field]"
          'GQ' => 'Generic placement queried',
          'GR' => 'Generic placement queried, new combination for',
          'GI' => 'Generic placement incorrect',
          'IA' => 'Incorrect gender agreement of species name in',
        }.freeze

        keywords = {}

        notes.keys.each do |n|
          keywords[n] = Predicate.find_or_create_by(name: n, definition: 'The status in UCD database: ' + notes[n], project_id: Current.project_id)
        end

#        keywords.merge!{
#          }


        path = @args[:data_directory] + 'TSTAT.txt'
        print "\nHandling TSTAT\n"
        raise "file #{path} not found" if not File.exists?(path)
        file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'iso-8859-1:UTF-8')
        i = 0
        file.each do |row|
          i += 1
          print "\r#{i}"
          #          byebug if row['Code'] == 'PentarR'

          taxon = find_taxon_ucd(row['TaxonCode'])
          taxon1 = find_taxon_ucd(row['Code'])
#byebug if           row['TaxonCode'] == 'Closte pulchG'
#byebug if taxon && taxon.name == "abrotoni"
#byebug if taxon1 && taxon1.name == "abrotoni"
#          byebug if row['TaxonCode'] == 'IhambrA' && row['Code'] == 'IhrambA'
#          byebug if taxon.try(:name) == 'Ihambrek' || taxon1.try(:name) == 'Ihambrek'

          if taxon.nil?
	          puts "Unmatched(?) TaxonCode #{row['TaxonCode']}, skipping TSTAT row"
	          next
	        end

          ref = find_source_id_ucd(row['RefCode'])
          ref2 = find_source_id_ucd(row['RefCodeB'])

          if !combination[row['Status']].nil? # && @data.new_combinations[row['TaxonCode']]
            #            genus = @data.new_combinations[row['TaxonCode']]['genus']
            #            subgenus = @data.new_combinations[row['TaxonCode']]['subgenus']
            #            species = @data.new_combinations[row['TaxonCode']]['species']
            #            subspecies = @data.new_combinations[row['TaxonCode']]['subspeces']
            #            name = [genus] unless genus.blank?
            #            name << '(' + subgenus + ')' unless subgenus.blank?
            #            name << species.split.last unless species.blank?
            #            name << subspecies.split.last unless subspecies.blank?
            #            name = name.join(' ')
            #            taxon = TaxonName.where(cached: name, classified_as: classified_as, project_id: Current.project_id).first
            #            if taxon.nil?
            #              taxon = Combination.new
            #              taxon.genus = Protonym.find(@data.all_genera_index[genus]) unless genus.blank?
            #              taxon.subgenus = Protonym.find(@data.all_genera_index[subgenus]) unless subgenus.blank?
            #              taxon.species = Protonym.find(@data.all_species_index[species]) unless species.blank?
            #              taxon.subspecies = Protonym.find(@data.all_species_index[subspecies]) unless subspecies.blank?
            #              if taxon.valid?
            #                taxon.save!
            #              else
            #                byebug
            #              end
            #            end
            if !ref2.nil? && !ref.nil?
              taxon.citations.create(source_id: ref, pages: row['PageRef'], is_original: true) unless ref.nil?
              taxon.citations.create(source_id: ref2, pages: row['PagesB']) unless ref2.nil?
            else
              taxon.citations.create(source_id: ref, pages: row['PageRef']) unless ref.nil?
            end
          end

          # create predicates for status
          if !notes[row['Status']].nil? && !taxon.nil?
            nt = notes[row['Status']]
            nt += ' ' + taxon1.cached.to_s + ' ' + taxon1.cached_author_year.to_s if taxon1
            nt += ' ' + row['Notes'].to_s.gsub('|','_') unless row['Notes'].blank?

            pred = keywords[row['Status']]
            byebug if pred.nil? || pred.id.nil?
            c = taxon.internal_attributes.find_or_create_by(controlled_vocabulary_term_id: pred.id, value: nt, project_id: Current.project_id)


            if !c.id.blank? # valid?
              taxon.citations.create(source_id: ref, pages: row['PageRef'])
              if !ref2.nil? && !ref.nil?
                c.citations.create(source_id: ref2, pages: row['PagesB'])
              else
                c.citations.create(source_id: ref, pages: row['PageRef'])
              end
            else
              print "\n ERROR: Invalid status: TaxonCode: #{row['TaxonCode']}, Status: #{row['Status']}\n"
              print "\n ERROR: Invalid status: Taxon1: #{taxon.try(:cached)}, Status: #{nt}\n"
            end
          end

          if taxon.nil?
            print "\n ERROR: Invalid TaxonCode: #{row['TaxonCode']}\n"
          elsif taxon.type == 'Combination'
            #valid = TaxonName.find(taxon.cached_valid_taxon_name_id)
            #taxon = valid
            taxon = taxon.protonyms.last
          end

          if !taxon1.nil? && taxon1.type == 'Combination'
            #valid = TaxonName.find(taxon1.cached_valid_taxon_name_id)
            #taxon1 = valid
            taxon1 = taxon1.protonyms.last
          end
          taxon.notes.create(text: row['Notes'].to_s.gsub('|','_') + ' ' + row['Code'].to_s) if !row['Notes'].blank? && !taxon.nil? && notes[row['Status']].nil?

          # create biological associations for CF status
          if !compared_with[row['Status']].nil? && !taxon.nil? && !taxon1.nil?
          otu1 = taxon1.otus.first
          otu = taxon.otus.first
          if otu.nil?
            otu = Otu.find_or_create_by(taxon_name: taxon, project_id: Current.project_id)
            @data.otus[row['TaxonCode']] = otu.id
          end
          if otu1.nil?
            otu1 = Otu.find_or_create_by(taxon_name: taxon1, project_id: Current.project_id)
            @data.otus[row['Code']] = otu1.id
          end
          c = BiologicalAssociation.find_or_create_by!(biological_relationship: biological_relationship,
                                                          biological_association_subject: otu1,
                                                          biological_association_object: otu,
                                                          project_id: Current.project_id
            )
            if !c.id.blank? # valid?
              taxon.citations.create(source_id: ref, pages: row['PageRef'])
              if !ref2.nil? && !ref.nil?
                c.citations.create(source_id: ref2, pages: row['PagesB'])
              else
                c.citations.create(source_id: ref, pages: row['PageRef'])
              end
            else
              print "\n ERROR: Invalid status: TaxonCode: #{row['TaxonCode']}, Status: #{row['Status']}\n"
              print "\n ERROR: Invalid status: Taxon1: #{taxon.try(:cached)}, Status: #{nt}\n"
            end

          end

          if !relationship[row['Status']].nil? && !taxon.nil? && !taxon1.nil?
            if taxon != taxon1

              c = TaxonNameRelationship.where(subject_taxon_name: taxon, object_taxon_name: taxon1, type: 'TaxonNameRelationship::Iczn::Invalidating').first

              if relationship[row['Status']].include?('TaxonNameRelationship::Iczn::Invalidating') && !c.nil?
                c.update_column(:type, relationship[row['Status']])
              else
                c2 = TaxonNameClassification.find_or_create_by(taxon_name: taxon, type: 'TaxonNameClassification::Iczn::Available::Valid', project_id: Current.project_id) if @data.valid_taxon_codes[taxon.id] == 1
                if row['Status'] == 'MG' && taxon.rank_string == 'NomenclaturalRank::Iczn::GenusGroup::Genus'
                  c = TaxonNameRelationship.find_or_create_by(subject_taxon_name: taxon, object_taxon_name: taxon1, type: 'TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling', project_id: Current.project_id)
                else
                  c = TaxonNameRelationship.find_or_create_by(subject_taxon_name: taxon, object_taxon_name: taxon1, type: relationship[row['Status']], project_id: Current.project_id)
                end
              end

              if !c.id.blank? # valid?
                if !ref2.nil? && !ref.nil?
                  taxon.citations.create(source_id: ref, pages: row['PageRef'], is_original: true) unless ref.nil?
                  c.citations.create(source_id: ref2, pages: row['PagesB']) unless ref2.nil?
                else
                  c.citations.create(source_id: ref, pages: row['PageRef']) unless ref.nil?
                end
              else
                print "\n ERROR: Invalid relationship: TaxonCode: #{row['TaxonCode']}, Status: #{row['Status']}, Code: #{row['Code']}\n"
                print "\n ERROR: Invalid relationship: Taxon1: #{taxon.try(:cached)}, Status: #{relationship[row['Status']]}, Taxon2: #{taxon1.try(:cached)}\n"
              end

            else
              if !ref2.nil? && !ref.nil?
                taxon.citations.create(source_id: ref, pages: row['PageRef'], is_original: true) unless ref.nil?
                taxon.citations.create(source_id: ref2, pages: row['PagesB']) unless ref2.nil?
              else
                taxon.citations.create(source_id: ref, pages: row['PageRef']) unless ref.nil?
              end
            end
          end

          if !classification[row['Status']].nil? && !taxon.nil?
            c = TaxonNameClassification.find_or_create_by(taxon_name: taxon, type: classification[row['Status']], project_id: Current.project_id)

            if !c.id.blank?
              if !ref2.nil? && !ref.nil?
                taxon.citations.create(source_id: ref, pages: row['PageRef'], is_original: true) unless ref.nil?
                c.citations.create(source_id: ref2, pages: row['PagesB']) unless ref2.nil?
              else
                c.citations.create(source_id: ref, pages: row['PageRef']) unless ref.nil?
              end
            else
              print "\n ERROR: Invalid status: TaxonCode: #{row['TaxonCode']}, Status: #{row['Status']}, Code: #{row['Code']}\n"
            end
          end
        end
      end

      # All valid names go through this indexing
      # Takes a Protonym, and UCD taxon code
      # * maps the taxon code to the taxon.id
      # * creates a local import identifier
      # * creates (findy) a related OTU
      # * maps the taxon code to the otu.id
      #
      def set_data_for_taxon(taxon, taxon_code)
        @data.taxon_codes[taxon_code] = taxon.id
        Identifier::Local::Import.create!(identifier_object: taxon, namespace_id: @data.keywords['taxon_id'], identifier: taxon_code)
        @data.otus[taxon_code] = Otu.find_or_create_by(taxon_name: taxon, project_id: Current.project_id).id
      end

      # Return a TW TaxonName id 
      def find_taxon_id_ucd(key)
        @data.taxon_codes[key.to_s] || Identifier.where(cached: 'UCD_Taxon_ID ' + key.to_s, identifier_object_type: 'TaxonName', project_id: Current.project_id).limit(1).pluck(:identifier_object_id).first
      end

      # Return a TW TaxonName id 
      def find_family_id_ucd(key)
        @data.families[key.to_s] || Identifier.where(cached: 'UCD_Family_ID ' + key.to_s, identifier_object_type: 'TaxonName', project_id: Current.project_id).limit(1).pluck(:identifier_object_id).first
      end

      def find_host_family_id_ucd(key)
        @data.hostfamilies[key.to_s] || Identifier.where(cached: 'UCD_Host_Family_ID ' + key.to_s, identifier_object_type: 'TaxonName', project_id: Current.project_id).limit(1).pluck(:identifier_object_id).first
      end

      def find_host_id_ucd(key)
        @data.taxon_codes[key.to_s] || Identifier.where(cached: 'UCD_Hos_Number ' + key.to_s, identifier_object_type: 'TaxonName', project_id: Current.project_id).limit(1).pluck(:identifier_object_id).first
      end

      # TODO: This should pluck an :id not, return the object?
      def find_taxon_ucd(key)
        Identifier.find_by(cached: 'UCD_Taxon_ID ' + key.to_s, identifier_object_type: 'TaxonName', project_id: Current.project_id).try(:identifier_object)
      end

      # TODO: This should pluck an :id not, return the object?
      # Not used?!
      # def find_host_ucd(key)
      #  Identifier.find_by(cached: 'UCD_Hos_Number ' + key.to_s, identifier_object_type: 'TaxonName', project_id: Current.project_id).try(:identifier_object)
      # end

      # TODO: This should pluck an :id not, return the object?
      # NOT used?!
      # def find_source_ucd(key)
      #   Identifier.find_by(cached: 'UCD_RefCode ' + key.to_s, identifier_object_type: 'Source', project_id: Current.project_id).try(:identifier_object)
      # end

      def find_source_id_ucd(key)
        @data.references[key.to_s] || Identifier.where(cached: 'UCD_RefCode ' + key.to_s, identifier_object_type: 'Source', project_id: Current.project_id).limit(1).pluck(:identifier_object_id).first
      end

      def soft_validations_ucd
        @data = nil
        GC.start
        fixed = 0
        #        print "\nApply soft validation fixes to relationships \n"
        #        TaxonNameRelationship.where(project_id: Current.project_id).each_with_index do |t, i|
        #          print "\r#{i}    Fixes applied: #{fixed}"
        #          t.soft_validate
        #          t.fix_soft_validations
        #          t.soft_validations.soft_validations.each do |f|
        #            fixed += 1  if f.fixed?
        #          end
        #        end
        print "\nApply soft validation fixes to taxa 1st pass \n"
        i = 0
        TaxonName.where(project_id: Current.project_id).find_each do |t|
          i += 1
          print "\r#{i}    Fixes applied: #{fixed}"
          t.soft_validate(:all, true, true)
          t.fix_soft_validations
          t.soft_validations.soft_validations.each do |f|
            fixed += 1  if f.fixed?
          end
        end
      
        print "\nApply soft validation fixes to relationships \n"
        i = 0
        GC.start
        TaxonNameRelationship.where(project_id: Current.project_id).find_each do |t|
          i += 1
          print "\r#{i}    Fixes applied: #{fixed}"
          t.soft_validate(:all, true, true)
          t.fix_soft_validations
          t.soft_validations.soft_validations.each do |f|
            fixed += 1  if f.fixed?
          end
        end

        print "\nApply soft validation fixes to taxa 2nd pass \n"
        GC.start
        i = 0
        TaxonName.where(project_id: Current.project_id).find_each do |t|
          i += 1
          print "\r#{i}    Fixes applied: #{fixed}"
          t.soft_validate(:all, true, true)
          t.fix_soft_validations
          t.soft_validations.soft_validations.each do |f|
            fixed += 1  if f.fixed?
          end
        end
      end

      def invalid_relationship_remove
#byebug
        @data = nil
        GC.start
        fixed = 0
        combinations = 0
        i = 0
        j = 0
        print "\nHandling Invalid relationships: synonyms of synonyms\n"

        TaxonNameRelationship.where(project_id: Current.project_id).with_type_base('TaxonNameRelationship::Iczn::Invalidating::Homonym').find_each do |t|
          j += 1
          print "\r#{j}    Fixes applied: #{fixed}   "
          o = t.object_taxon_name
          Protonym.where(id: o.cached_valid_taxon_name_id, cached_secondary_homonym_alternative_spelling: o.cached_secondary_homonym_alternative_spelling).not_self(o).each do |p|
            t.object_taxon_name = p
            t.save
            fixed += 1
          end
        end

        TaxonNameRelationship.where(project_id: Current.project_id).with_type_array(TAXON_NAME_RELATIONSHIP_NAMES_SYNONYM).find_each do |t|
          j += 1
          print "\r#{j}    Fixes applied: #{fixed}   "
          s = t.subject_taxon_name
          o = t.object_taxon_name
#byebug if s.name == 'abrotoni'
          sval = s.valid_taxon_name
#          next unless s.name == 'hispanicus' || s.name == 'hispanica'
#          byebug

          if o.rank_string =~ /Family/
            if o.id != sval.id && o.cached_primary_homonym_alternative_spelling == sval.cached_primary_homonym_alternative_spelling
              t.object_taxon_name = sval
              t.save
              s.save
              fixed += 1
            end
            if s.cached_primary_homonym_alternative_spelling != o.cached_primary_homonym_alternative_spelling && s.origin_citation.nil?
              Protonym.where(cached_valid_taxon_name_id: sval.id, cached_primary_homonym_alternative_spelling: s.cached_primary_homonym_alternative_spelling).not_self(s).each do |p|
                if !p.origin_citation.nil?
                  t.object_taxon_name = p
                  t.save
                  s.save
                  fixed += 1
                end
              end
            end
          else
            #byebug if j == 7216
            if o.id != sval.id && o.cached_secondary_homonym_alternative_spelling == sval.cached_secondary_homonym_alternative_spelling
              t.object_taxon_name = sval
              t.save
              s.save
              fixed += 1
            end
            if s.cached_secondary_homonym_alternative_spelling != o.cached_secondary_homonym_alternative_spelling && s.origin_citation.nil?
              Protonym.where(cached_valid_taxon_name_id: sval.id, cached_secondary_homonym_alternative_spelling: s.cached_secondary_homonym_alternative_spelling).not_self(s).each do |p|
               if !p.origin_citation.nil?
                  t.object_taxon_name = p
                  t.save
                  s.save
                  fixed += 1
                end
              end
            end
          end
        end

      print "\nHandling Invalid relationships: synonyms to combinations\n"
        TaxonNameRelationship.where(project_id: Current.project_id).with_type_string('TaxonNameRelationship::Iczn::Invalidating').pluck(:id).each do |t1|
          t = TaxonNameRelationship.find(t1)
          i += 1
          print "\r#{i}    Fixes applied: #{fixed}    Combinations created: #{combinations}"
          if t.citations.empty?
          s = t.subject_taxon_name
#byebug if s.name == 'abrotoni'
          svalid = s.cached_valid_taxon_name_id
          o = t.object_taxon_name
          shas = s.cached_secondary_homonym_alternative_spelling
          r = TaxonNameRelationship.where(project_id: Current.project_id, object_taxon_name_id: s.id).with_type_base('TaxonNameRelationship::Iczn::Invalidating')
          r2 = TaxonNameRelationship.where(project_id: Current.project_id, subject_taxon_name_id: s.id).with_type_base('TaxonNameRelationship::Iczn::Invalidating').count
          if s.taxon_name_classifications.empty? && r.empty?
            if o.rank_string =~ /Family/ && s.cached_primary_homonym_alternative_spelling == o.cached_primary_homonym_alternative_spelling && r2 == 1
              t.destroy
              s.save
              fixed += 1
              TaxonNameRelationship.create!(subject_taxon_name: s, object_taxon_name: o, type: 'TaxonNameRelationship::Iczn::Invalidating::Usage::FamilyGroupNameForm')
            elsif (o.rank_string =~ /Species/  && shas == o.cached_secondary_homonym_alternative_spelling && r2 == 1) ||
                (o.rank_string =~ /Genus/  && s.cached_primary_homonym_alternative_spelling == o.cached_primary_homonym_alternative_spelling && r2 == 1)
#byebug if s.name == 'truncatus'
              s = s.becomes_combination
              combinations +=1 if s.type == 'Combination'
#              byebug if s.type == 'Combination' && TaxonName.find(s.id).type != 'Combination'
              if s.type == 'Combination'
                TaxonNameRelationship.where(project_id: Current.project_id, subject_taxon_name_id: s.id).with_type_contains('Combination').each do |z|
                  z.object_taxon_name.verbatim_name = z.object_taxon_name.cached if z.object_taxon_name.type == 'Combination' && z.object_taxon_name.verbatim_name.blank?
                  z.subject_taxon_name_id = o.id
                  z.save
                  z.subject_taxon_name.save
                  fixed += 1
                end
#                TaxonNameRelationship.where(project_id: Current.project_id, subject_taxon_name_id: s.id).select{|i| i.type !~ /Combination/}.each do |z|
#byebug
#                  z.subject_taxon_name_id = o.id
#                  z.save
#                  fixed += 1
#                end
#                TaxonNameRelationship.where(project_id: Current.project_id, subject_taxon_name_id: s.id).select{|i| i.type =~ /Combination/}.each do |z|
#byebug
#                  z.object_taxon_name.verbatim_name = z.object_taxon_name.cached if z.object_taxon_name.type == 'Combination' && z.object_taxon_name.verbatim_name.blank?
#                  z.subject_taxon_name_id = o.id
#                  z.save
#                  fixed += 1
#                end
#                TaxonNameRelationship.where(project_id: Current.project_id, object_taxon_name_id: s.id).select{|i| i.type !~ /Combination/}.each do |z|
#byebug
#                  z.object_taxon_name_id = o.id
#                  z.save
#                  fixed += 1
#                end
              end
            end





            end
          end
end
=begin
            s = t.subject_taxon_name
            svalid = s.cached_valid_taxon_name_id
            o = t.object_taxon_name
            shas = s.cached_secondary_homonym_alternative_spelling
            r = TaxonNameRelationship.where(project_id: Current.project_id, object_taxon_name_id: s.id).with_type_base('TaxonNameRelationship::Iczn::Invalidating')
            r2 = TaxonNameRelationship.where(project_id: Current.project_id, subject_taxon_name_id: s.id).with_type_base('TaxonNameRelationship::Iczn::Invalidating').count
            if s.taxon_name_classifications.empty? && r.empty?
              t.destroy
              s.save
                if o.rank_string =~ /Family/ && s.cached_primary_homonym_alternative_spelling == o.cached_primary_homonym_alternative_spelling && r2 == 1
                    fixed += 1
                    TaxonNameRelationship.create!(subject_taxon_name: s, object_taxon_name: o, type: 'TaxonNameRelationship::Iczn::Invalidating::Usage::FamilyGroupNameForm')
                elsif (o.rank_string =~ /Species/  && shas == o.cached_secondary_homonym_alternative_spelling && r2 == 1) ||
                    (o.rank_string =~ /Genus/  && s.cached_primary_homonym_alternative_spelling == o.cached_primary_homonym_alternative_spelling && r2 == 1)
                  combinations += 1
                  byebug if s.type != 'Protonym'
                  genus = s.original_genus
                  subgenus = s.original_subgenus
                  species = s.original_species
                  subspecies = s.original_subspecies
                  vname = s.cached_original_combination # .to_s.gsub('<i>', '').gsub('</i>', '')
                  s.original_genus_relationship.destroy unless genus.blank?
                  s.original_subgenus_relationship.destroy unless subgenus.blank?
                  s.original_species_relationship.destroy unless species.blank?
                  s.original_subspecies_relationship.destroy unless subspecies.blank?
                  s.parent_id = nil
                  s.year_of_publication = nil
                  s.verbatim_author = nil
                  s.rank_class = nil
                  s.cached_html = nil
                  s.cached_author_year = nil
                  s.cached_original_combination_html = nil
                  s.cached_secondary_homonym = nil
                  s.cached_primary_homonym = nil
                  s.cached_secondary_homonym_alternative_spelling = nil
                  s.cached_primary_homonym_alternative_spelling = nil
                  s.cached = nil
                  s.cached_original_combination = nil
                  s.type = 'Combination'
                  s = s.becomes(Combination)
                 
                  s.genus = genus unless genus.nil?
                  s.subgenus = subgenus unless subgenus.nil?
                  s.species = species unless species.nil?
                  s.subspecies = subspecies unless subspecies.nil?
                  s.verbatim_name = vname
                  if !s.subspecies.nil?
                    s.subspecies = o
                  elsif !s.species.nil?
                    s.species = o
                  elsif !s.subgenus.nil?
                    s.subgenus = o
                  elsif !s.genus.nil?
                    s.genus = o
                  end
                  
                  if !s.valid?
                    s = TaxonName.find(s.id).reload # make sure we're not validating against a Combination Object in some cached check
                    TaxonNameRelationship.create!(subject_taxon_name: s, object_taxon_name: o, type: 'TaxonNameRelationship::Iczn::Invalidating')
                    s.original_genus = genus unless genus.nil?
                    s.original_subgenus = subgenus unless subgenus.nil?
                    s.original_species = species unless species.nil?
                    s.original_subspecies = subspecies unless subspecies.nil?
                  else
                    s.save
                    TaxonNameRelationship.where(project_id: Current.project_id, subject_taxon_name_id: s.id).with_type_contains('Combination').each do |z|
                      z.object_taxon_name.verbatim_name = z.object_taxon_name.cached if z.object_taxon_name.type == 'Combination' && z.object_taxon_name.verbatim_name.blank?
                      z.subject_taxon_name_id = o.id
                      z.save
                      z.subject_taxon_name.save
                      fixed += 1
                    end
                    TaxonNameRelationship.where(project_id: Current.project_id, subject_taxon_name_id: s.id).select{|i| i.type !~ /Combination/}.each do |z|
                      z.subject_taxon_name_id = o.id
                      z.save
                      fixed += 1
                    end
                    TaxonNameRelationship.where(project_id: Current.project_id, subject_taxon_name_id: s.id).select{|i| i.type =~ /Combination/}.each do |z|
                      z.object_taxon_name.verbatim_name = z.object_taxon_name.cached if z.object_taxon_name.type == 'Combination' && z.object_taxon_name.verbatim_name.blank?
                      z.subject_taxon_name_id = o.id
                      z.save
                      fixed += 1
                    end
                    TaxonNameRelationship.where(project_id: Current.project_id, object_taxon_name_id: s.id).select{|i| i.type !~ /Combination/}.each do |z|
                      z.object_taxon_name_id = o.id
                      z.save
                      fixed += 1
                    end
                  end
                elsif s.cached_valid_taxon_name_id != svalid
                TaxonNameRelationship.create!(subject_taxon_name: s, object_taxon_name: o, type: 'TaxonNameRelationship::Iczn::Invalidating')
              else
                fixed += 1
              end
            end
=end



#        print "\nHandling Invalid relationships: cached valid\n"
#        i = 0
#        fixed = 0
#        tn = TaxonName.where(project_id: Current.project_id)
#        tn.each do |t|
#          i += 1
#          print "\r#{i}    wrong cached valid fixed: #{fixed}   "
#          if t.cached_valid_taxon_name_id != t.id && t.valid_taxon_name.type == 'Combination'
#            t.save
#            fixed += 1 if t.valid_taxon_name.type == 'Protonym'
#            byebug if t.valid_taxon_name.type == 'Combination'
#          end
#        end


#        print "\nHandling Invalid relationships: wrong combination relationships\n"
#        i = 0
#        fixed = 0
#        tr = TaxonNameRelationship.where(project_id: Current.project_id).with_type_contains('Combination')
#        tr.each do |t|
#          i += 1
#          print "\r#{i}    Wrong combinations found: #{fixed}   "
#          s = t.subject_taxon_name
#          if s.type == 'Combination'
#            print "\nWrong combination id: #{t.object_taxon_name_id}\n"

#            fixed += 1
#          end
#        end

      end

    end
  end
end




