namespace :tw do
  namespace :project_import do
    namespace :sf_import do
      require 'fileutils'
      require 'logged_task'
      namespace :supplementary do

        desc 'time rake tw:project_import:sf_import:supplementary:taxon_info user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        LoggedTask.define taxon_info: [:data_directory, :environment, :user_id] do |logger|

          logger.info 'Creating list of taxa with AccessCode = 4'
          taxa_access_code_4 = [1143399, 1143399, 1143402, 1143402, 1143403, 1143403, 1143403, 1143404, 1143405, 1143406, 1143408, 1143414, 1143415, 1143416, 1143417, 1143418, 1143419, 1143420, 1143421, 1143422, 1143423, 1143425, 1143430, 1143431, 1143434, 1143435, 1143436, 1143437, 1143438, 1207769, 1232866]

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          skipped_file_ids = import.get('SkippedFileIDs')
          skipped_file_ids = import.get('SkippedFileIDs')
          get_sf_file_id = import.get('SFTaxonNameIDToSFFileID')
          get_tw_project_id = import.get('SFFileIDToTWProjectID')
          get_tw_user_id = import.get('SFFileUserIDToTWUserID') # for housekeeping
          get_tw_taxon_name_id = import.get('SFTaxonNameIDToTWTaxonNameID')
          get_tw_otu_id = import.get('SFTaxonNameIDToTWOtuID') # Note this is an OTU associated with a SF.TaxonNameID (probably a bad taxon name)
          get_taxon_name_otu_id = import.get('TWTaxonNameIDToOtuID') # Note this is the OTU offically associated with a real TW.taxon_name_id
          get_tw_source_id = import.get('SFRefIDToTWSourceID')
          get_sf_verbatim_ref = import.get('RefIDToVerbatimRef') # key is SF.RefID, value is verbatim string

          counter = 0
          # otu_only_counter = 0
          # otu_not_found_array = []


          # first create hash of scrutinies
          get_scrutinies = {} # key = ScrutinyID, value = FileID, Year, Comment
          logger.info 'Creating scrutinies hash...'
          path = @args[:data_directory] + 'tblScrutinies.txt'
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'UTF-16:UTF-8')
          file.each_with_index do |row, i|
            get_scrutinies[row['ScrutinyID']] = {sf_file_id: row['FileID'], year: row['Year'], comment: row['Comment']}
          end

          # next create hash of arrays for scrutiny authors
          get_scrutiny_authors = {} # from tblScrutinyAuthors, key = ScrutinyID, value = PersonID, SeqNum
          logger.info 'Creating scrutiny_authors hash...'
          path = @args[:data_directory] + 'tblScrutinyAuthors.txt'
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'UTF-16:UTF-8')
          file.each_with_index do |row, i|
            id = row['ScrutinyID']
            index = row['SeqNum'].to_i
            if get_scrutiny_authors[id]   # subsequent author for same ScrutinyID
              get_scrutiny_authors[id][index] = row['PersonID']
            else
              get_scrutiny_authors[id] = []   # first author for different ScrutinyID
              get_scrutiny_authors[id][index] = [row['PersonID'] ]
            end
          end
       # =======================================================
       #    get_scrutiny_authors = {
       #        22 => [1,2,3],
       #        44 => [4,5]
       #    }
       #
       #  people_for_22 = get_scrutiny_authors[22]  # == [1,2,3]
       # =======================================================

          import.set('Scrutinies', get_scrutinies)
          import.set('ScrutinyAuthors', get_scrutiny_authors)

          # finally process tblTaxonScrutinies

          logger.info 'Importing Scrutinies...'

          path = @args[:data_directory] + 'tblTaxonScrutinies.txt'
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'UTF-16:UTF-8')

          file.each_with_index do |row, i|
            next if taxa_access_code_4.include? row['TaxonNameID'].to_i
            next if row['TaxonNameID'] == '0'
            next if [1143402, 1143425, 1143430, 1143432, 1143436].freeze.include?(row['TaxonNameID'].to_i) # used for excluded Beckma ids
            next if [1109922, 1195997, 1198855].freeze.include?(row['TaxonNameID'].to_i) # bad data in Orthoptera (first) and Psocodea (rest)
            sf_taxon_name_id = row['TaxonNameID']
            next if skipped_file_ids.include? sf_file_id.to_i
            taxon_name_id = get_tw_taxon_name_id[sf_taxon_name_id] # cannot to_i because if nil, nil.to_i = 0
            scrutiny_id = row['ScrutinyID']


            project_id = get_tw_project_id[get_scrutinies[scrutiny_id]['FileID']]
            year = get_scrutinies[scrutiny_id]['Year']
            comment = get_scrutinies[scrutiny_id]['Comment']


            logger.info "Working on SF.TaxonNameID #{sf_taxon_name_id} = tw.taxon_name_id #{taxon_name_id}, project_id = #{project_id}, counter = #{counter += 1}"

            content = ''  # ScrutinyID, SeqNum, Year, PersonIDs, Comment

            scrutiny_predicate = Predicate.find_or_create_by(name: 'Species File scrutiny', definition: 'from tblScrutinies, limit of three scrutinies per taxon name', project_id: project_id)
            scrutiny = internal_attributes.create!(predicate: scrutiny_predicate,
                                                   attribute_subject_id: taxon_name_id,
                                                   attribute_subject_type: 'TaxonName',
                                                   value: content,
                                                   project_id: project_id)





          end
        end

        desc 'time rake tw:project_import:sf_import:supplementary:taxon_info user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        LoggedTask.define taxon_info: [:data_directory, :environment, :user_id] do |logger|

          logger.info 'Creating list of taxa with AccessCode = 4'
          taxa_access_code_4 = [1143399, 1143399, 1143402, 1143402, 1143403, 1143403, 1143403, 1143404, 1143405, 1143406, 1143408, 1143414, 1143415, 1143416, 1143417, 1143418, 1143419, 1143420, 1143421, 1143422, 1143423, 1143425, 1143430, 1143431, 1143434, 1143435, 1143436, 1143437, 1143438, 1207769, 1232866]

          logger.info 'Importing SupplementaryTaxonInformation...'

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          skipped_file_ids = import.get('SkippedFileIDs')
          get_sf_file_id = import.get('SFTaxonNameIDToSFFileID')
          get_tw_project_id = import.get('SFFileIDToTWProjectID')
          get_tw_user_id = import.get('SFFileUserIDToTWUserID') # for housekeeping
          get_tw_taxon_name_id = import.get('SFTaxonNameIDToTWTaxonNameID')
          get_tw_otu_id = import.get('SFTaxonNameIDToTWOtuID') # Note this is an OTU associated with a SF.TaxonNameID (probably a bad taxon name)
          get_taxon_name_otu_id = import.get('TWTaxonNameIDToOtuID') # Note this is the OTU offically associated with a real TW.taxon_name_id
          get_tw_source_id = import.get('SFRefIDToTWSourceID')
          get_sf_verbatim_ref = import.get('RefIDToVerbatimRef') # key is SF.RefID, value is verbatim string

          counter = 0
          # otu_only_counter = 0
          # otu_not_found_array = []

          path = @args[:data_directory] + 'tblSupplTaxonInfo.txt'
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'UTF-16:UTF-8')

          file.each_with_index do |row, i|
            next if taxa_access_code_4.include? row['TaxonNameID'].to_i
            next if row['TaxonNameID'] == '0'
            next if [1143402, 1143425, 1143430, 1143432, 1143436].freeze.include?(row['TaxonNameID'].to_i) # used for excluded Beckma ids
            next if [1109922, 1195997, 1198855].freeze.include?(row['TaxonNameID'].to_i) # bad data in Orthoptera (first) and Psocodea (rest)
            sf_taxon_name_id = row['TaxonNameID']
            sf_file_id = get_sf_file_id[sf_taxon_name_id]
            next if skipped_file_ids.include? sf_file_id.to_i
            taxon_name_id = get_tw_taxon_name_id[sf_taxon_name_id] # cannot to_i because if nil, nil.to_i = 0
            project_id = get_tw_project_id[sf_file_id]

            logger.info "Working on SF.TaxonNameID #{sf_taxon_name_id} = tw.taxon_name_id #{taxon_name_id}, project_id = #{project_id}, counter = #{counter += 1}"

            title = row['Title']
            if taxon_name_id.nil?
              if get_tw_otu_id[sf_taxon_name_id]
                attribute_subject_id = get_tw_otu_id[sf_taxon_name_id]
                attribute_subject_type = 'Otu'
              else
                logger.warn "SF.TaxonNameID = #{sf_taxon_name_id} not found and OTU not found"
                next
              end
            else
              if title.include? 'etymology'
                attribute_subject_id = taxon_name_id
                attribute_subject_type = 'TaxonName'
              else
                attribute_subject_id = get_taxon_name_otu_id[taxon_name_id]
                attribute_subject_type = 'Otu'
              end
            end

            if row['SourceID'].to_i > 0
              title += ", source_id = #{get_tw_source_id[row['SourceID']]}"
            end

            logger.info "attribute_subject_id = #{attribute_subject_id}, attribute_subject_type = #{attribute_subject_type}, title = #{title}"

            da = DataAttribute.new(type: 'ImportAttribute',
                                   attribute_subject_id: attribute_subject_id,
                                   attribute_subject_type: attribute_subject_type,
                                   import_predicate: title,
                                   value: row['Content'],
                                   project_id: project_id,
                                   created_at: row['CreatedOn'],
                                   updated_at: row['LastUpdate'],
                                   created_by_id: get_tw_user_id[row['CreatedBy']],
                                   updated_by_id: get_tw_user_id[row['ModifiedBy']])

            begin
              da.save!
                # data_attributes are not citable
                # if row['SourceID'].to_i > 0
                #   Citation.create!(source_id: get_tw_source_id[row['SourceID']],
                #                    citation_object: da,
                #                    created_at: row['CreatedOn'],
                #                    updated_at: row['LastUpdate'],
                #                    created_by_id: get_tw_user_id[row['CreatedBy']],
                #                    updated_by_id: get_tw_user_id[row['ModifiedBy']])
                # end
            rescue ActiveRecord::RecordInvalid
              logger.error "DataAttribute ERROR" + da.errors.full_messages.join(';')
              # Validation failed: Value has already been taken
              # next
            end
          end
        end

      end # namespaces below
    end
  end
end
