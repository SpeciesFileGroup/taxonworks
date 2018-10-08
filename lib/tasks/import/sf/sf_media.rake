namespace :tw do
  namespace :project_import do
    namespace :sf_import do
      require 'fileutils'
      require 'logged_task'
      namespace :media do

        desc 'time rake tw:project_import:sf_import:media:images user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        LoggedTask.define scrutiny_related: [:data_directory, :environment, :user_id] do |logger|

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          skipped_file_ids = import.get('SkippedFileIDs')
          excluded_taxa = import.get('ExcludedTaxa')
          get_sf_file_id = import.get('SFTaxonNameIDToSFFileID')
          get_tw_project_id = import.get('SFFileIDToTWProjectID')
          get_tw_person_id = import.get('SFPersonIDToTWPersonID')
          get_tw_user_id = import.get('SFFileUserIDToTWUserID') # for housekeeping
          get_tw_taxon_name_id = import.get('SFTaxonNameIDToTWTaxonNameID')
          get_taxon_name_otu_id = import.get('TWTaxonNameIDToOtuID')
          get_tw_collection_object_id = import.get('SFSpecimenIDToCollObjID')

          counter = 0

          path = @args[:data_directory] + 'tblImages.txt'
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'UTF-16:UTF-8')

          file.each_with_index do |row, i|
            sf_file_id = row['FileID']
            next if skipped_file_ids.include? sf_file_id.to_i
            sf_taxon_name_id = row['TaxonNameID']
            next if excluded_taxa.include? sf_taxon_name_id
            specimen_id = row['SpecimenID']

            # check if specimen_id > 0, use that
            # else check if otu exists for sf_taxon_name_id ( Is it important to check if tw_taxon_name_id exists?  If otu only, just skip, too? )
            # if image assigned to specimen, forget about taxon_name_id
            # If specimen not real specimen (perhaps only a determination), should I assign to otu_id?

            if specimen_id.to_i > 0
              collection_object_id = get_tw_collection_object_id[specimen_id] # is there an equiv collection_object (could be a determination)
              if collection_object_id.nil? # try taxon?

              elsif row['TaxonNameID'] == '0'
                # log not found

              end


              otu_id = get_taxon_name_otu_id[get_tw_taxon_name_id[sf_taxon_name_id]] # cannot to_i because if nil, nil.to_i = 0 ]
              if taxon_name_id.nil?
                logger.error "TW.taxon_name_id is nil: SF.TaxonNameID #{sf_taxon_name_id}, SF.FileID = #{sf_file_id}"
                next
              end

              seqnum = row['SeqNum']
              project_id = get_tw_project_id[sf_file_id].to_i

              logger.info "Working on ScrutinyID = #{scrutiny_id}, SF.TaxonNameID #{sf_taxon_name_id} = tw.taxon_name_id #{taxon_name_id}, project_id = #{project_id}, counter = #{counter += 1}"


            end
          end
        end


      end
    end
  end
end
