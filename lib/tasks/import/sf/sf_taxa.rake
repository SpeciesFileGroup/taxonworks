require 'fileutils'

namespace :tw do
  namespace :project_import do
    namespace :sf_taxa do

# import taxa
# original_genus_id: cannot set until all taxa (for a given project) are imported; and the out of scope taxa as well
# pass 1
# pass 2

# name_status_lookup = {
#     1 => 'TaxonNameClassification::Iczn::'
# }

# if temporary, don't make taxon name, make an OTU, that OTU has the TaxonNameID of the AboveID as the taxon name reference (or find the most recent valid above ID)


      desc 'create all SF taxa (pass 1)'
      task :create_all_sf_taxa_pass1 => [:data_directory, :environment, :user_id] do
        ### time rake tw:project_import:sf_taxa:create_all_sf_taxa_pass1 user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/

        species_file_data = Import.find_or_create_by(name: 'SpeciesFileData')
        get_user_id = species_file_data.get('FileUserIDToTWUserID') # for housekeeping
        get_rank_string = species_file_data.get('SFRankIDToTWRankString')
        get_apex_taxon_id = species_file_data.get('TWProjectIDToSFApexTaxonID')
        get_source_id = species_file_data.get('SFRefIDToTWSourceID')
        get_project_id = species_file_data.get('SFFileIDToTWProjectID')

        sf_taxon_name_id_to_tw_taxon_name_id = {} # hash of SF.AboveIDs = parent_id, key = SF.TaxonNameID, value = TW.taxon_name.id
        get_parent_id = sf_taxon_name_id_to_tw_taxon_name_id

        tw_taxon_name_id_to_sf_status_flags = {} # hash of TW.taxon_name_id = SF.StatusFlags

        # get reverse of TWProjectIDToSFApexTaxonID: no longer needed because we can use get_project_id
        # get_apex_taxon_project_id = {}
        # get_apex_taxon_id.each { |key, value| get_apex_taxon_project_id[value] = key } # shortcut for do...end

        path = @args[:data_directory] + 'working/tblTaxa.txt'
        file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: "UTF-16:UTF-8")

        # first loop to get ApexTaxonNameID.AboveID
        # puts "before the first loop, apex_taxon_name_id = #{apex_taxon_name_id.class}"
        file.each do |row|
          next unless get_apex_taxon_id.has_value?(row['TaxonNameID'])
          get_parent_id[row['AboveID']] = TaxonName.find_by!(project_id: get_project_id[row['FileID']], name: 'Root').id # substitute for row['AboveID']
          # get_parent_id[row['AboveID']] = TaxonName.find_by(project_id: get_apex_taxon_project_id[row['TaxonNameID']], name: 'Root').id # substitute for row['AboveID'] # this is the reverse hash
        end
        # puts 'done with first loop'
        # ap get_parent_id

        puts "get parent id of apex taxon id"
        ap get_parent_id

        # break

        error_counter = 0
        count_found = 0

        file.each_with_index do |row, i|
          taxon_name_id = row['TaxonNameID']
          next if row['TaxonNameStr'].start_with?('0-')
          # next unless row['TaxonNameStr'].start_with?(apex_taxon_name_id)
          # NameStatus and/or StatusFlags should be attached to taxon_name as data_attribute?

          project_id = get_project_id[row['FileID']]

          count_found += 1
          print "working with TW.project_id: #{project_id} = SF.FileID #{row['FileID']}, SF.TaxonNameID #{taxon_name_id} (count #{count_found}) \n"

          taxon_name = Protonym.new(
              name: row['Name'],
              parent_id: get_parent_id[row['AboveID']],
              rank_class: get_rank_string[row['RankID']],

              origin_citation_attributes: {source_id: get_source_id[row['RefID']], project_id: project_id,
                                           created_by_id: get_user_id[row['CreatedBy']], updated_by_id: get_user_id[row['ModifiedBy']]},


              project_id: project_id,
              created_at: row['CreatedOn'],
              updated_at: row['LastUpdate'],
              created_by_id: get_user_id[row['CreatedBy']],
              updated_by_id: get_user_id[row['ModifiedBy']]
          )

          if taxon_name.save

            sf_taxon_name_id_to_tw_taxon_name_id[row['TaxonNameID']] = taxon_name.id
            tw_taxon_name_id_to_sf_status_flags[taxon_name.id] = row['StatusFlags']

          else
            error_counter += 1
            puts "     ERROR (#{error_counter}): " + taxon_name.errors.full_messages.join(';')
            puts "  project_id: #{project_id}, SF.TaxonNameID: #{row['TaxonNameID']}, TW.taxon_name.id #{taxon_name.id} sf row created by: #{row['CreatedBy']}, sf row updated by: #{row['ModifiedBy']}    "
          end

        end
      end

      desc 'create apex taxon parent id hash, i.e. id of "root" in each project'
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

      desc 'create project_id: apex_taxon_id hash (all SFs)'
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


