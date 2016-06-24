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
#           (other classifications will probably have relationships);
#         ok add nomenclatural comment as TW.Note (in row['Comment']);
#         ok if temporary, make an OTU which has the TaxonNameID of the AboveID as the taxon name reference (or find the most recent valid above ID);
#         ok natural order is TaxonNameStr (must be in order to ensure synonym parent already imported);
#         ok for synonyms, use sf_synonym_id_to_parent_id_hash; create error message if not found (hash was created from dynamic tblTaxa later than .txt);
      # ADD HOUSEKEEPING to _attributes
# pass 2

      desc 'create all SF taxa (pass 1)'
      task :create_all_sf_taxa_pass1 => [:data_directory, :environment, :user_id] do
        ### time rake tw:project_import:sf_taxa:create_all_sf_taxa_pass1 user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/

        puts 'Creating all SF taxa...'

        species_file_data = Import.find_or_create_by(name: 'SpeciesFileData')
        get_user_id = species_file_data.get('FileUserIDToTWUserID') # for housekeeping
        get_rank_string = species_file_data.get('SFRankIDToTWRankString')
        get_source_id = species_file_data.get('SFRefIDToTWSourceID')
        get_project_id = species_file_data.get('SFFileIDToTWProjectID')
        get_animalia_id = species_file_data.get('ProjectIDToAnimaliaID') # key = TW.Project.id, value TW.TaxonName.id where Name = 'Animalia', used when AboveID = 0
        get_synonym_parent_id = species_file_data.get('SFSynonymIDToParentID')

        get_tw_taxon_name_id = {} # SF.TaxonNameID to TW.TaxonNameID hash, key = SF.TaxonNameID, value = TW.taxon_name.id
        get_sf_name_status = {} # key = SF.TaxonNameID, value = SF.NameStatus
        get_sf_status_flags = {} # key = SF.TaxonNameID, value = SF.StatusFlags
        get_tw_otu_id = {}  # key = SF.TaxonNameID, value = TW.otu.id; used for temporary SF taxa

        path = @args[:data_directory] + 'working/tblTaxa.txt'
        file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: "UTF-16:UTF-8")

        error_counter = 0
        count_found = 0

        file.each_with_index do |row, i|
          taxon_name_id = row['TaxonNameID']
          next unless taxon_name_id.to_i > 0

          project_id = get_project_id[row['FileID']]

          count_found += 1
          print "Working with TW.project_id: #{project_id} = SF.FileID #{row['FileID']}, SF.TaxonNameID #{taxon_name_id} (count #{count_found}) \n"

          if row['AboveID'] == '0' # must check AboveID = 0 before synonym
            parent_id = get_animalia_id[project_id]
          elsif row['NameStatus'] == '7' # = synonym
            parent_id = get_tw_taxon_name_id[get_synonym_parent_id[taxon_name_id]] # assumes tw_taxon_name_id exists
          else
            parent_id = get_tw_taxon_name_id[row['AboveID']]
          end

          if parent_id == nil
            puts '      ERROR: Could not find parent_id!'
            next
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
              created_by_id: get_user_id[row['CreatedBy']],
              updated_by_id: get_user_id[row['ModifiedBy']]
           )

            if otu.save
              puts "  Note!! Created OTU for temporary taxon, otu.id: #{otu.id}"
              get_tw_otu_id[row['TaxonNameID']] = taxon_name.id
              get_sf_name_status[row['TaxonNameID']] = name_status
              get_sf_status_flags[row['TaxonNameID']] = status_flags

            else
              error_counter += 1
              puts "     OTU ERROR (#{error_counter}): " + otu.errors.full_messages.join(';')
              puts "  project_id: #{project_id}, SF.TaxonNameID: #{row['TaxonNameID']}, sf row created by: #{row['CreatedBy']}, sf row updated by: #{row['ModifiedBy']}    "
             end

          else
            fossil, nomen_nudum, nomen_dubium = nil
            fossil = 'TaxonNameClassification::Iczn::Fossil' if row['Extinct'] == '1'
            nomen_nudum = 'TaxonNameClassification::Iczn::Unavailable::NomenNudum' if status_flags.to_i & 8 == 8
            nomen_dubium = 'TaxonNameClassification::Iczn::Available::Valid::NomenDubium' if status_flags.to_i & 16 == 16

            taxon_name = Protonym.new(
                name: row['Name'],
                parent_id: get_parent_id[row['AboveID']],
                rank_class: get_rank_string[row['RankID']],

                origin_citation_attributes: {source_id: get_source_id[row['RefID']], project_id: project_id,
                                             created_by_id: get_user_id[row['CreatedBy']], updated_by_id: get_user_id[row['ModifiedBy']]},

                notes_attributes: [{text: (row['Comment'].blank? ? nil : row['Comment'])}],

                taxon_name_classifications_attributes: [{type: fossil}, {type: nomen_nudum}, {type: nomen_dubium}],

                also_create_otu: true,  # pretty nifty way to make automatically make an OTU!

                project_id: project_id,
                created_at: row['CreatedOn'],
                updated_at: row['LastUpdate'],
                created_by_id: get_user_id[row['CreatedBy']],
                updated_by_id: get_user_id[row['ModifiedBy']]
            )

            if taxon_name.save
              get_tw_taxon_name_id[row['TaxonNameID']] = taxon_name.id
              get_sf_name_status[row['TaxonNameID']] = name_status
              get_sf_status_flags[row['TaxonNameID']] = status_flags

            else
              error_counter += 1
              puts "     TaxonName ERROR (#{error_counter}): " + taxon_name.errors.full_messages.join(';')
              puts "  project_id: #{project_id}, SF.TaxonNameID: #{row['TaxonNameID']}, sf row created by: #{row['CreatedBy']}, sf row updated by: #{row['ModifiedBy']}    "
            end
          end
        end
      end

      desc 'create SF synonym.id to parent.id hash'
      task :create_sf_synonym_id_to_parent_id_hash => [:data_directory, :environment, :user_id] do
        ### time rake tw:project_import:sf_taxa:create_sf_synonym_id_to_parent_id_hash user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/

        puts 'Running SF synonym parent hash...'

        sf_synonym_id_to_parent_id_hash = {}

        path = @args[:data_directory] + 'direct_from_sf/sf_synonym_parents.txt'
        file = CSV.read(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

        file.each do |row|
          # byebug
          # puts row.inspect
          taxon_name_id = row['TaxonNameID']
          print "working with #{taxon_name_id} \n"
          sf_synonym_id_to_parent_id_hash[taxon_name_id] = row['NewAboveID']
        end

        i = Import.find_or_create_by(name: 'SpeciesFileData')
        i.set('SFSynonymIDToParentID', sf_synonym_id_to_parent_id_hash)

        puts 'SFSynonymIDToParentID'
        ap sf_synonym_id_to_parent_id_hash

      end

      desc 'create Animalia taxon name subordinate to each project Root (and make hash of project.id, animalia.id'
      # creating project_id_animalia_id_hash
      task :create_animalia_below_root => [:data_directory, :environment, :user_id] do
        ### time rake tw:project_import:sf_taxa:create_animalia_below_root user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/

        species_file_data = Import.find_or_create_by(name: 'SpeciesFileData')
        get_project_id = species_file_data.get('SFFileIDToTWProjectID')

        project_id_animalia_id_hash = {} # hash of TW.project_id (key), TW.taxon_name_id = 'Animalia' (value)

        TaxonName.first # a royal kludge to ensure taxon_name plumbing is in place v-a-v project

        get_project_id.values.each_with_index do |project_id, index|
          next if index == 0 # hash accidently included FileID = 0
          # puts "before root = (index = #{index}, project_id = #{project_id})"
          # puts "after this_project assignment #{this_project.id}"
          # puts "this_project.name: #{this_project.root_taxon_name.name}; this_project.name.id: #{this_project.root_taxon_name.id}!"
          next if TaxonName.find_by(project_id: project_id, name: 'Animalia') # test if Animalia already exists

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
            project_id_animalia_id_hash[project_id] = animalia_taxon_name.id
          end
        end

        i = Import.find_or_create_by(name: 'SpeciesFileData')
        i.set('ProjectIDToAnimaliaID', project_id_animalia_id_hash)

        puts "ProjectIDToAnimaliaID"
        ap project_id_animalia_id_hash

      end

      desc 'XXX create apex taxon parent id hash, i.e. id of "root" in each project'
      # use Animalia instead; project_id_animalia_id_hash
      task :create_apex_taxon_parent_id_hash => [:data_directory, :environment, :user_id] do
        ### time rake tw:project_import:sf_taxa:create_apex_taxon_parent_id_hash user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/

        species_file_data = Import.find_or_create_by(name: 'SpeciesFileData')
        get_apex_taxon_id = species_file_data.get('TWProjectIDToSFApexTaxonID')
        get_project_id = species_file_data.get('SFFileIDToTWProjectID')

        get_apex_taxon_parent_id = {} # hash of SF.AboveIDs = parent_id, key = SF.TaxonNameID, value = TW.taxon_name.id of each project's Root

        # get reverse of TWProjectIDToSFApexTaxonID: no longer needed because we can use get_project_id
        # get_apex_taxon_project_id = {}
        # get_apex_taxon_id.each { |key, value| get_apex_taxon_project_id[value] = key } # shortcut for do...end

        path = @args[:data_directory] + 'working/tblTaxa.txt'
        file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: "UTF-16:UTF-8")

        # get ApexTaxonNameID.AboveID
        file.each do |row|
          t = row['TaxonNameID']
          next unless get_apex_taxon_id.has_value?(t)
          puts "TaxonNameID: #{t}, AboveID: #{row['AboveID']}"
          get_apex_taxon_parent_id[t] = TaxonName.find_by!(project_id: get_project_id[row['FileID']], name: 'Root').id # substitute for row['AboveID']
          # get_parent_id[row['AboveID']] = TaxonName.find_by(project_id: get_apex_taxon_project_id[row['TaxonNameID']], name: 'Root').id # substitute for row['AboveID'] # this is the reverse hash
        end

        species_file_data.set('SFApexTaxonIDToTWParentID', get_apex_taxon_parent_id)

        puts "get parent id of apex taxon id"
        ap get_apex_taxon_parent_id
      end

      # desc 'create valid taxa for Embioptera (FileID = 60)'
      # task :create_valid_taxa_for_embioptera => [:data_directory, :environment, :user_id] do
      #   ### time rake tw:project_import:sf_taxa:create_valid_taxa_for_embioptera user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/
      #
      #   species_file_data = Import.find_or_create_by(name: 'SpeciesFileData')
      #   get_user_id = species_file_data.get('FileUserIDToTWUserID') # for housekeeping
      #   get_rank_string = species_file_data.get('SFRankIDToTWRankString')
      #   get_apex_taxon_id = species_file_data.get('TWProjectIDToSFApexTaxonID')
      #   get_source_id = species_file_data.get('SFRefIDToTWSourceID')
      #
      #   sf_taxon_name_id_to_tw_taxon_name_id = {} # hash of SF.AboveIDs = parent_id, key = SF.TaxonNameID, value = TW.taxon_name.id
      #   get_parent_id = sf_taxon_name_id_to_tw_taxon_name_id
      #
      #
      #   # name_status_lookup = {
      #   #     1 => 'TaxonNameClassification::Iczn::'
      #   # }
      #
      #   # if temporary, don't make taxon name, make an OTU, that OTU has the TaxonNameID of the AboveID as the taxon name reference (or find the most recent valid above ID)
      #
      #
      #   project_id = Project.find_by_name('embioptera_species_file').id
      #   apex_taxon_name_id = get_apex_taxon_id[project_id.to_s]
      #
      #   path = @args[:data_directory] + 'working/tblTaxa.txt'
      #   file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: "UTF-16:UTF-8")
      #
      #   # first loop to get ApexTaxonNameID.AboveID
      #   # puts "before the first loop, apex_taxon_name_id = #{apex_taxon_name_id.class}"
      #   file.each do |row|
      #     next unless row['TaxonNameID'] == apex_taxon_name_id
      #     get_parent_id[row['AboveID']] = TaxonName.find_by(project_id: project_id, name: 'Root').id # substitute for row['AboveID']
      #     break
      #   end
      #   # puts 'done with first loop'
      #   # ap get_parent_id
      #
      #   error_counter = 0
      #   count_found = 0
      #
      #   file.each_with_index do |row, i|
      #     taxon_name_id = row['TaxonNameID']
      #     next unless row['TaxonNameStr'].start_with?(apex_taxon_name_id)
      #     next unless row['NameStatus'] == '0'
      #     # Valid names only, 18, including 0, instances of StatusFlags > 0 when NameStatus = 0
      #     # NameStatus should be attached to taxon_name as data_attribute?
      #
      #     count_found += 1
      #     print "working with TaxonNameID #{taxon_name_id} (count #{count_found}) \n"
      #
      #     taxon_name = Protonym.new(
      #         # taxon_name = TaxonName.new(
      #         name: row['Name'],
      #         parent_id: get_parent_id[row['AboveID']],
      #         rank_class: get_rank_string[row['RankID']],
      #         # type: 'Protonym',
      #
      #         origin_citation_attributes: {source_id: get_source_id[row['RefID']], project_id: project_id,
      #                                      created_by_id: get_user_id[row['CreatedBy']], updated_by_id: get_user_id[row['ModifiedBy']]},
      #
      #         # original_genus_id: cannot set until all taxa (for a given project) are imported; and the out of scope taxa as well,
      #
      #         project_id: project_id,
      #         created_at: row['CreatedOn'],
      #         updated_at: row['LastUpdate'],
      #         created_by_id: get_user_id[row['CreatedBy']],
      #         updated_by_id: get_user_id[row['ModifiedBy']]
      #     )
      #
      #     if taxon_name.save
      #
      #       sf_taxon_name_id_to_tw_taxon_name_id[row['TaxonNameID']] = taxon_name.id
      #
      #     else
      #       error_counter += 1
      #       puts "     ERROR (#{error_counter}): " + taxon_name.errors.full_messages.join(';')
      #       puts "  project_id: #{project_id}, SF.TaxonNameID: #{row['TaxonNameID']}, TW.taxon_name.id #{taxon_name.id} sf row created by: #{row['CreatedBy']}, sf row updated by: #{row['ModifiedBy']}    "
      #     end
      #
      #   end
      #
      #
      # end

      desc 'XXX create project_id: apex_taxon_id hash (all SFs)'
      # use Animalia instead; project_id_animalia_id_hash
      task :create_apex_taxon_id_hash => [:data_directory, :environment, :user_id] do
        ### rake tw:project_import:sf_taxa:create_apex_taxon_id_hash user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/

        species_file_data = Import.find_or_create_by(name: 'SpeciesFileData')
        get_project_id = species_file_data.get('SFFileIDToTWProjectID') # cross ref hash

        # make hash of AboveIDs = parent_id, key = TW.project.id, value = TW.ApexTaxonNameID.value
        tw_project_id_to_sf_apex_taxon_id = {}

        path = @args[:data_directory] + 'working/tblConstants.txt'
        file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: "UTF-16:UTF-8")

        file.each_with_index do |row, i|
          next unless row['Name'] == 'ApexTaxonNameID'

          tw_project_id_to_sf_apex_taxon_id[get_project_id[row['FileID']]] = row['Value']

        end

        i = Import.find_or_create_by(name: 'SpeciesFileData')
        i.set('TWProjectIDToSFApexTaxonID', tw_project_id_to_sf_apex_taxon_id)

        ap tw_project_id_to_sf_apex_taxon_id
      end

      desc 'create rank hash'
      task :create_rank_hash => [:data_directory, :environment, :user_id] do
        ### rake tw:project_import:sf_taxa:create_rank_hash user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/

        sf_rank_id_to_tw_rank_string = {}

        path = @args[:data_directory] + 'working/tblRanks.txt'
        file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: "UTF-16:UTF-8")

        file.each_with_index do |row, i|
          rank_id = row['RankID']
          next if ['90', '100'].include?(rank_id) # RankID = 0, "not specified", will = nil

          sf_rank_id_to_tw_rank_string[rank_id] = Ranks.lookup(:iczn, row['RankName'])
        end

        i = Import.find_or_create_by(name: 'SpeciesFileData')
        i.set('SFRankIDToTWRankString', sf_rank_id_to_tw_rank_string)

        ap sf_rank_id_to_tw_rank_string
      end
    end
  end
end




