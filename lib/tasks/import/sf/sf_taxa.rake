require 'fileutils'

namespace :tw do
  namespace :project_import do
    namespace :sf_taxa do

# import taxa
# original_genus_id: cannot set until all taxa (for a given project) are imported; and the out of scope taxa as well
# pass 1:
#         ok create SFTaxonNameIDToTWTaxonNameID hash;
#         ok save NameStatus, StatusFlags, in hashes as data_attributes or hashes?;
#         ok set rank according to sf_rank_id_to_tw_rank_string hash;
#         ok set classification if
#           nomen nudum = TaxonNameClassification::Iczn::Unavailable::NomenNudum (StatusFlags & 8 = 8 if NameStatus = 4 or 7),
#           nomen dubium = TaxonNameClassification::Iczn::Available::Valid::NomenDubium (StatusFlags & 16 = 16 if NameStatus = 5 or 7), and
#           fossil = TaxonNameClassification::Iczn::Fossil (extinct = 1)
#           (other classifications will probably have relationships)
#         ok add nomenclatural comment as TW.Note (in row['Comment']);
#         ok if temporary, make an OTU which has the TaxonNameID of the AboveID as the taxon name reference (or find the most recent valid above ID);
#         ok natural order is TaxonNameStr (must be in order to ensure synonym parent already imported);
#         ok for synonyms, use sf_synonym_id_to_parent_id_hash; create error message if not found (hash was created from dynamic tblTaxa later than .txt);
# ADD HOUSEKEEPING to _attributes

# 20160628
# Tasks before dumping and restoring db
#   ok Keep copy of current db with some taxa imported
#   Force Import hashes to be strings and change usage instances accordingly
#   ok Manually transfer three adjunct tables: RefIDToRefLink (probably table sfRefLinks which generates ref_id_to_ref_link.txt), sfVerbatimRefs and sfSynonymParents created by ScriptsFor1db2tw.sql
#   Make sure path references correct subdirectory (working vs. old)
#   ok Figure out how to assign myself as project member in each SF, what about universal user like 3i does??
#   ok Make sure none_species_file does not get created (FileID must be > 0)
#   ok Write get_tw_taxon_name_id to db! And three others...
#   ok Use TaxonNameClassification::Iczn::Unavailable::NotLatin for Name Name must be latinized, no digits or spaces allowed
#   no, use NotLatin: Use TaxonNameClassification::Iczn::Unavailable for non-latinized family group name synonyms
#   ok FixSFSynonymIDToParentID to iterate until Parent RankID > synonym RankID

# pass 2

      desc 'create all SF taxa (pass 1)'
      ### time rake tw:project_import:sf_taxa:create_all_sf_taxa_pass1 user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/
      task :create_all_sf_taxa_pass1 => [:data_directory, :environment, :user_id] do

        puts 'Creating all SF taxa (pass 1)...'

        import = Import.find_or_create_by(name: 'SpeciesFileData')
        get_tw_user_id = import.get('SFFileUserIDToTWUserID') # for housekeeping
        get_tw_rank_string = import.get('SFRankIDToTWRankString')
        get_tw_source_id = import.get('SFRefIDToTWSourceID')
        get_tw_project_id = import.get('SFFileIDToTWProjectID')
        get_animalia_id = import.get('ProjectIDToAnimaliaID') # key = TW.Project.id, value TW.TaxonName.id where Name = 'Animalia', used when AboveID = 0
        get_sf_parent_id = import.get('SFSynonymIDToSFParentID')

        get_tw_taxon_name_id = {} # key = SF.TaxonNameID, value = TW.taxon_name.id
        get_sf_name_status = {} # key = SF.TaxonNameID, value = SF.NameStatus
        get_sf_status_flags = {} # key = SF.TaxonNameID, value = SF.StatusFlags
        get_tw_otu_id = {} # key = SF.TaxonNameID, value = TW.otu.id; used for temporary SF taxa

        path = @args[:data_directory] + 'tblTaxa.txt'
        file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'UTF-16:UTF-8')

        error_counter = 0
        count_found = 0
        no_parent_counter = 0

        file.each_with_index do |row, i|
          taxon_name_id = row['TaxonNameID']
          next unless taxon_name_id.to_i > 0
          next if row['TaxonNameStr'].start_with?('1100048-1143863') # name = MiscImages (body parts)
          next if row['RankID'] == '90' # TaxonNameID = 1221948, Name = Deletable, RankID = 90 == Life, FileID = 1

          project_id = get_tw_project_id[row['FileID']]

          print "Working with TW.project_id: #{project_id} = SF.FileID #{row['FileID']}, SF.TaxonNameID #{taxon_name_id} (count #{count_found += 1}) \n"

          animalia_id = get_animalia_id[project_id.to_s]

          if row['AboveID'] == '0' # must check AboveID = 0 before synonym
            parent_id = animalia_id
          elsif row['NameStatus'] == '7' # = synonym
            parent_id = get_tw_taxon_name_id[get_sf_parent_id[taxon_name_id]] # assumes tw_taxon_name_id exists
          else
            parent_id = get_tw_taxon_name_id[row['AboveID']]
          end

          if parent_id == nil
            puts "ALERT: Could not find parent_id (error #{no_parent_counter += 1}! Set to animalia_id = #{animalia_id}"
            parent_id = animalia_id # this is problematic; need real solution
          end

          name_status = row['NameStatus']
          status_flags = row['StatusFlags']

          if name_status == '2' # temporary, create OTU, not TaxonName
            otu = Otu.new(
                name: row['Name'],
                taxon_name_id: parent_id,
                project_id: project_id,
                created_at: row['CreatedOn'],
                updated_at: row['LastUpdate'],
                created_by_id: get_tw_user_id[row['CreatedBy']],
                updated_by_id: get_tw_user_id[row['ModifiedBy']]
            )

            if otu.save
              puts "  Note!! Created OTU for temporary taxon, otu.id: #{otu.id}"
              get_tw_otu_id[row['TaxonNameID']] = otu.id.to_s
              get_sf_name_status[row['TaxonNameID']] = name_status
              get_sf_status_flags[row['TaxonNameID']] = status_flags

            else
              puts "     OTU ERROR (#{error_counter += 1}): " + otu.errors.full_messages.join(';')
            end

          else
            fossil, nomen_nudum, nomen_dubium = nil, nil, nil
            fossil = 'TaxonNameClassification::Iczn::Fossil' if row['Extinct'] == '1'
            nomen_nudum = 'TaxonNameClassification::Iczn::Unavailable::NomenNudum' if (status_flags.to_i & 8) == 8
            nomen_dubium = 'TaxonNameClassification::Iczn::Available::Valid::NomenDubium' if status_flags.to_i & 16 == 16

            taxon_name = Protonym.new(
                name: row['Name'],
                parent_id: parent_id,
                rank_class: get_tw_rank_string[row['RankID']],

                # housekeeping attributed to SF last_editor, etc.
                origin_citation_attributes: {source_id: get_tw_source_id[row['RefID']],
                                             project_id: project_id,
                                             created_at: row['CreatedOn'],
                                             updated_at: row['LastUpdate'],
                                             created_by_id: get_tw_user_id[row['CreatedBy']],
                                             updated_by_id: get_tw_user_id[row['ModifiedBy']]},

                notes_attributes: [{text: (row['Comment'].blank? ? nil : row['Comment']),
                                    project_id: project_id,
                                    created_at: row['CreatedOn'],
                                    updated_at: row['LastUpdate'],
                                    created_by_id: get_tw_user_id[row['CreatedBy']],
                                    updated_by_id: get_tw_user_id[row['ModifiedBy']]}],

                # perhaps test for nil for each...  (Dmitry) classification.new? Dmitry prefers doing one at a time and validating?? And after the taxon is saved.

                taxon_name_classifications_attributes: [
                    {type: fossil,
                     project_id: project_id,
                     created_at: row['CreatedOn'],
                     updated_at: row['LastUpdate'],
                     created_by_id: get_tw_user_id[row['CreatedBy']],
                     updated_by_id: get_tw_user_id[row['ModifiedBy']]},
                    {type: nomen_nudum,
                     project_id: project_id,
                     created_at: row['CreatedOn'],
                     updated_at: row['LastUpdate'],
                     created_by_id: get_tw_user_id[row['CreatedBy']],
                     updated_by_id: get_tw_user_id[row['ModifiedBy']]},
                    {type: nomen_dubium,
                     project_id: project_id,
                     created_at: row['CreatedOn'],
                     updated_at: row['LastUpdate'],
                     created_by_id: get_tw_user_id[row['CreatedBy']],
                     updated_by_id: get_tw_user_id[row['ModifiedBy']]}
                ],

                also_create_otu: true, # pretty nifty way to automatically make an OTU!

                project_id: project_id,
                created_at: row['CreatedOn'],
                updated_at: row['LastUpdate'],
                created_by_id: get_tw_user_id[row['CreatedBy']],
                updated_by_id: get_tw_user_id[row['ModifiedBy']]
            )

            # if taxon_name.save
            if taxon_name.valid?
              taxon_name.save!
              get_tw_taxon_name_id[row['TaxonNameID']] = taxon_name.id
              get_sf_name_status[row['TaxonNameID']] = name_status
              get_sf_status_flags[row['TaxonNameID']] = status_flags

              # add taxon_name_classifications here


              # test if valid before save; if one of anticipated import errors, add classification, then try to save again...

              # Dmitry's code:
              # if taxon.valid?
              #   taxon.save!
              #   @data.taxon_index.merge!(row['Key'] => taxon.id)
              # else
              #   taxon.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::Unavailable::NotLatin') if taxon.rank_string =~ /Family/ && row['Status'] != '0' && !taxon.errors.messages[:name].blank?
              #   taxon.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::Unavailable::NotLatin') if taxon.rank_string =~ /Species/ && row['Status'] != '0' && taxon.errors.full_messages.include?('Name name must be lower case')
              #   taxon.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::Unavailable::NotLatin') if taxon.rank_string =~ /Species/ && row['Status'] != '0' && taxon.errors.full_messages.include?('Name Name must be latinized, no digits or spaces allowed')
              #   taxon.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::Unavailable::NotLatin') if taxon.rank_string =~ /Genus/ && row['Status'] != '0' && taxon.errors.full_messages.include?('Name Name must be latinized, no digits or spaces allowed')
              #
              #   if taxon.valid?
              #     taxon.save!
              #     @data.taxon_index.merge!(row['Key'] => taxon.id)
              #   else
              #     print "\n#{row['Key']}         #{row['Name']}"
              #     print "\n#{taxon.errors.full_messages}\n"
              #     #byebug
              #   end
              # end of Dmitry's code

              #
              # case taxon_name.errors.full_messages.include?
              # when 'Name name must end in -oidea', 'Name name must end in -idae', 'Name name must end in ini', 'Name name must end in -inae'
              # and row['NameStatus'] == '7'
              # taxon_name.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::Unavailable')

              #
              # when 'Name Name must be latinized, no digits or spaces allowed'
              # and row['NameStatus'] == '7'
              # taxon_name.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::NotLatin')

            elsif row['NameStatus'] == '7' # make all NotLatin... Dmitry Add project_id
              # case taxon_name.errors.full_messages.include? # ArgumentError: wrong number of arguments (given 0, expected 1)
              #   when 'Name name must end in -oidea', 'Name name must end in -idae', 'Name name must end in ini', 'Name name must end in -inae'
              #     taxon_name.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::Unavailable')
              #   when 'Name Name must be latinized, no digits or spaces allowed'
              taxon_name.taxon_name_classifications.new(
                  type: 'TaxonNameClassification::Iczn::Unavailable::NotLatin',
                  project_id: project_id,
                  created_at: row['CreatedOn'],
                  updated_at: row['LastUpdate'],
                  created_by_id: get_tw_user_id[row['CreatedBy']],
                  updated_by_id: get_tw_user_id[row['ModifiedBy']])
            end

            if taxon_name.valid?
              taxon_name.save! # taxon won't be saved if something wrong with classifications_attributes, read about !
              get_tw_taxon_name_id[row['TaxonNameID']] = taxon_name.id
              get_sf_name_status[row['TaxonNameID']] = name_status
              get_sf_status_flags[row['TaxonNameID']] = status_flags

            else
              puts "     TaxonName ERROR (#{error_counter += 1}) AFTER synonym test: " + taxon_name.errors.full_messages.join(';')
              puts "parent_id = #{parent_id}"
            end
          end
        end

        import.set('SFTaxonNameIDToTWTaxonNameID', get_tw_taxon_name_id)
        import.set('SFTaxonNameIDToSFNameStatus', get_sf_name_status)
        import.set('SFTaxonNameIDToSFStatusFlags', get_sf_status_flags)
        import.set('SFTaxonNameIDToTWOtuID', get_tw_otu_id)

        puts 'SFTaxonNameIDToTWTaxonNameID'
        ap get_tw_taxon_name_id
        puts 'SFTaxonNameIDToSFNameStatus'
        ap get_sf_name_status
        puts 'SFTaxonNameIDToSFStatusFlags'
        ap get_sf_status_flags
        puts 'SFTaxonNameIDToTWOtuID'
        ap get_tw_otu_id

      end

      desc 'create bad valid name list (will create OTUs) and new parent_ids for taxa subordinate to the bad valid names'
      ### time rake tw:project_import:sf_taxa:create_bad_valid_name_and_sub_parent_hashes user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/
      task :create_bad_valid_name_and_sub_parent_hashes => [:data_directory, :environment, :user_id] do
        # Can be run independently at any time

        puts 'Running bad valid name and sub parent hashes...'

        get_sf_above_id = {} # key = SF.TaxonNameID of bad valid name, value = SF.AboveID of bad valid name
        get_sf_new_parent_id = {} # key = SF.TaxonNameID of bad valid name subordinate, value = SF.AboveID of bad valid name

        path = @args[:data_directory] + 'sfBadValidNames.txt'
        file = CSV.read(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

        file.each do |row|
          # byebug
          # puts row.inspect
          make_otu = row['MakeOTU']
          taxon_name_id = row['TaxonNameID']
          use_above_id = row['UseAboveID']
          print "working with TaxonNameID = #{taxon_name_id}, MakeOTU = #{make_otu} \n"

          if make_otu == '1'
            get_sf_above_id[taxon_name_id] = use_above_id
          else
            get_sf_new_parent_id[taxon_name_id] = use_above_id
          end
        end

        import = Import.find_or_create_by(name: 'SpeciesFileData')
        import.set('SFBadValidNameIDToSFAboveID', get_sf_above_id)
        import.set('SFSubordinateIDToSFNewParentID', get_sf_new_parent_id)

        puts 'SFBadValidNameIDToSFAboveID'
        ap get_sf_above_id

        puts 'SFSubordinateIDToSFNewParentID'
        ap get_sf_new_parent_id

      end

      desc 'create SF synonym.id to new parent.id hash'
      ### time rake tw:project_import:sf_taxa:create_sf_synonym_id_to_new_parent_id_hash user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/
      task :create_sf_synonym_id_to_new_parent_id_hash => [:data_directory, :environment, :user_id] do
        # Can be run independently at any time

        puts 'Running SF new synonym parent hash...'

        get_sf_parent_id = {} # key = SF.TaxonNameID of synonym, value = SF.TaxonNameID of new parent

        path = @args[:data_directory] + 'sfSynonymParents.txt'
        file = CSV.read(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

        file.each do |row|
          # byebug
          # puts row.inspect
          taxon_name_id = row['TaxonNameID']
          print "working with #{taxon_name_id} \n"
          get_sf_parent_id[taxon_name_id] = row['NewAboveID']
        end

        import = Import.find_or_create_by(name: 'SpeciesFileData')
        import.set('SFSynonymIDToSFParentID', get_sf_parent_id)

        puts 'SFSynonymIDToSFParentID'
        ap get_sf_parent_id

      end

      desc 'create Animalia taxon name subordinate to each project Root (and make hash of project.id, animalia.id'
      ### time rake tw:project_import:sf_taxa:create_animalia_below_root user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/
      task :create_animalia_below_root => [:data_directory, :environment, :user_id] do
        # Can be run independently at any time after projects created BUT not after animalia species created (must restore to before)

        puts 'Running create_animalia_below_root...'

        import = Import.find_or_create_by(name: 'SpeciesFileData')
        get_tw_project_id = import.get('SFFileIDToTWProjectID')

        get_animalia_id = {} # key = TW.project_id, value = TW.taxon_name_id = 'Animalia'

        get_tw_project_id.values.each do |project_id|

          this_project = Project.find(project_id)
          puts "working with project.id: #{project_id}, root_name: #{this_project.root_taxon_name.name}, root_name_id: #{this_project.root_taxon_name.id}"

          animalia_taxon_name = Protonym.new(
              name: 'Animalia',
              parent_id: this_project.root_taxon_name.id,
              rank_class: NomenclaturalRank::Iczn::HigherClassificationGroup::Kingdom,
              project_id: project_id,
              created_at: Time.now,
              updated_at: Time.now,
              created_by_id: $user_id,
              updated_by_id: $user_id
          )

          if animalia_taxon_name.save
            get_animalia_id[project_id] = animalia_taxon_name.id.to_s # key (project_id) is integer, would prefer string
          end
        end

        import.set('ProjectIDToAnimaliaID', get_animalia_id)

        puts "ProjectIDToAnimaliaID"
        ap get_animalia_id

      end

      desc 'create rank hash'
      ### time rake tw:project_import:sf_taxa:create_rank_hash user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/
      task :create_rank_hash => [:data_directory, :environment, :user_id] do
        # Can be run independently at any time

        puts 'Running create_rank_hash...'

        get_tw_rank_string = {} # key = SF.RankID, value = TW.rank_string (Ranks.lookup(SF.Rank.Name))

        path = @args[:data_directory] + 'tblRanks.txt'
        file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'UTF-16:UTF-8')

        file.each_with_index do |row, i|
          rank_id = row['RankID']
          next if ['90', '100'].include?(rank_id) # RankID = 0, "not specified", will = nil

          get_tw_rank_string[rank_id] = Ranks.lookup(:iczn, row['RankName'])
        end

        import = Import.find_or_create_by(name: 'SpeciesFileData')
        import.set('SFRankIDToTWRankString', get_tw_rank_string)

        puts = 'SFRankIDToTWRankString'
        ap get_tw_rank_string
      end
    end
  end
end




