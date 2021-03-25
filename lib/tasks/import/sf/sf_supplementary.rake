namespace :tw do
  namespace :project_import do
    namespace :sf_import do
      require 'fileutils'
      require 'logged_task'
      namespace :supplementary do



        # 52;"Person::Vetted";"Schröder";"C."
        # 29;"Person::Vetted";"Tinkham";"Ernest R."
        # 41;"Person::Vetted";"Voisin";"Jean-François"
        # 13;"Person::Vetted";"Blatchley";"W.S."
        #
        # Source::Human.joins(:people).where(person_ids: [1,2,3], year: 1234)


        desc 'time rake tw:project_import:sf_import:supplementary:scrutiny_related user_id=1 data_directory=~/src/onedb2tw/working/'
        LoggedTask.define scrutiny_related: [:data_directory, :backup_directory, :environment, :user_id] do |logger|

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          skipped_file_ids = import.get('SkippedFileIDs')
          excluded_taxa = import.get('ExcludedTaxa')
          # get_sf_file_id = import.get('SFTaxonNameIDToSFFileID')
          get_tw_project_id = import.get('SFFileIDToTWProjectID')
          get_tw_person_id = import.get('SFPersonIDToTWPersonID')
          get_tw_user_id = import.get('SFFileUserIDToTWUserID') # for housekeeping
          get_tw_taxon_name_id = import.get('SFTaxonNameIDToTWTaxonNameID')

          scrutiny_predicate_ids = {}

          get_tw_project_id.each_value do |project_id|
            scrutiny_predicate = Predicate.create!(
              name: 'Scrutiny',
              definition: 'Nomenclature comments made by a taxonomist on a certain date and year not published',
              project_id: project_id
            )
            scrutiny_predicate_ids[project_id.to_i] = scrutiny_predicate.id
          end

          counter = 0

          # first create hash of scrutinies
          get_scrutinies = {} # key = ScrutinyID, value = FileID, Year, Comment
          logger.info 'Creating scrutinies hash...'
          path = @args[:data_directory] + 'tblScrutinies.txt'
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')
          file.each_with_index do |row, i|
            get_scrutinies[row['ScrutinyID']] = {sf_file_id: row['FileID'], year: row['Year'], comment: row['Comment']}
          end

          # next create hash of arrays for scrutiny authors
          # No error handling if no TW equiv person
          get_tw_scrutiny_authors = {} # from tblScrutinyAuthors, key = ScrutinyID, value = PersonID, SeqNum
          logger.info 'Creating scrutiny_authors hash...'
          path = @args[:data_directory] + 'tblScrutinyAuthors.txt'
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')
          file.each_with_index do |row, i|
            id = row['ScrutinyID']
            index = row['SeqNum'].to_i
            if get_tw_scrutiny_authors[id] # subsequent author for same ScrutinyID
              get_tw_scrutiny_authors[id][index] = get_tw_person_id[row['PersonID']]
            else
              get_tw_scrutiny_authors[id] = [] # first author for different ScrutinyID
              get_tw_scrutiny_authors[id][index] = get_tw_person_id[row['PersonID']]
            end
          end

          import.set('Scrutinies', get_scrutinies)
          import.set('ScrutinyAuthors', get_tw_scrutiny_authors)

          puts 'Scrutinies'
          ap get_scrutinies
          puts 'ScrutinyAuthors'
          ap get_tw_scrutiny_authors

          # finally process tblTaxonScrutinies
          # No error handling if there is no TW equiv taxon_name
          path = @args[:data_directory] + 'tblTaxonScrutinies.txt'
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

          file.each_with_index do |row, i|
            sf_taxon_name_id = row['TaxonNameID']
            next if excluded_taxa.include? sf_taxon_name_id
            tw_taxon_name_id = get_tw_taxon_name_id[sf_taxon_name_id] # cannot to_i because if nil, nil.to_i = 0 ]
            scrutiny_id = row['ScrutinyID']
            sf_file_id = get_scrutinies[scrutiny_id][:sf_file_id]
            next if skipped_file_ids.include? sf_file_id.to_i
            if tw_taxon_name_id.nil?
              logger.error "TW.taxon_name_id is nil: ScrutinyID = #{scrutiny_id}, SF.TaxonNameID #{sf_taxon_name_id}, SF.FileID = #{sf_file_id}"
              next
            end

            seqnum = row['SeqNum']
            project_id = get_tw_project_id[sf_file_id].to_i
            year = get_scrutinies[scrutiny_id][:year]
            comment = get_scrutinies[scrutiny_id][:comment]

            logger.info "Working on ScrutinyID = #{scrutiny_id}, SF.TaxonNameID #{sf_taxon_name_id} = tw.taxon_name_id #{tw_taxon_name_id}, project_id = #{project_id}, counter = #{counter += 1}"

            sh = Source::Human.create!(year: year, person_ids: get_tw_scrutiny_authors[scrutiny_id])

            scrutiny = InternalAttribute.create(
                                            controlled_vocabulary_term_id: scrutiny_predicate_ids[project_id],
                                            attribute_subject_id: tw_taxon_name_id,
                                            attribute_subject_type: 'TaxonName',
                                            value: comment,
                                            project_id: project_id,
                                            created_at: row['CreatedOn'],
                                            updated_at: row['LastUpdate'],
                                            created_by_id: get_tw_user_id[row['CreatedBy']],
                                            updated_by_id: get_tw_user_id[row['ModifiedBy']],

                                            citations_attributes: [{source_id: sh.id, project_id: project_id}]  # source: {id: sh.id}   # source_id: sh.id
            )

            unless scrutiny.persisted?
              logger.error "Error creating TaxonScrutiny: ScrutinyID = #{scrutiny_id}, SF.TaxonNameID #{sf_taxon_name_id} = tw.taxon_name_id #{tw_taxon_name_id}. Errors: #{scrutiny.errors.messages}"
            # else
            #   cite = Citation.new(source_id: sh.id, citation_object: scrutiny)
            #   byebug
            #
            end
          end
        end

        desc 'time rake tw:project_import:sf_import:supplementary:taxon_info user_id=1 data_directory=~/src/onedb2tw/working/'
        LoggedTask.define taxon_info: [:data_directory, :backup_directory, :environment, :user_id] do |logger|

          logger.info 'Importing SupplementaryTaxonInformation...'

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          get_sf_taxon_info = import.get('SFTaxonNameIDMiscInfo')
          skipped_file_ids = import.get('SkippedFileIDs')
          excluded_taxa = import.get('ExcludedTaxa')
          get_tw_project_id = import.get('SFFileIDToTWProjectID')
          get_tw_user_id = import.get('SFFileUserIDToTWUserID') # for housekeeping
          get_tw_taxon_name_id = import.get('SFTaxonNameIDToTWTaxonNameID')
          get_tw_otu_id = import.get('SFTaxonNameIDToTWOtuID') # Note this is an OTU associated with a SF.TaxonNameID (probably a bad taxon name)
          get_taxon_name_otu_id = import.get('TWTaxonNameIDToOtuID') # Note this is the OTU offically associated with a real TW.taxon_name_id
          get_tw_source_id = import.get('SFRefIDToTWSourceID')
          # get_sf_verbatim_ref = import.get('RefIDToVerbatimRef') # key is SF.RefID, value is verbatim string

          counter = 0
          # otu_only_counter = 0
          # otu_not_found_array = []

          path = @args[:data_directory] + 'tblSupplTaxonInfo.txt'
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

          file.each_with_index do |row, i|
            sf_taxon_name_id = row['TaxonNameID']
            sf_file_id = get_sf_taxon_info[sf_taxon_name_id]['file_id']
            next if skipped_file_ids.include? sf_file_id.to_i
            next if excluded_taxa.include? sf_taxon_name_id
            tw_taxon_name_id = get_tw_taxon_name_id[sf_taxon_name_id] # cannot to_i because if nil, nil.to_i = 0
            project_id = get_tw_project_id[sf_file_id]

            logger.info "Working on SF.TaxonNameID #{sf_taxon_name_id} = tw.taxon_name_id #{tw_taxon_name_id}, project_id = #{project_id}, counter = #{counter += 1}"

            title = row['Title']
            if tw_taxon_name_id.nil?
              if get_tw_otu_id[sf_taxon_name_id]
                attribute_subject_id = get_tw_otu_id[sf_taxon_name_id]
                attribute_subject_type = 'Otu'
              else

                logger.warn "SF.TaxonNameID = #{sf_taxon_name_id} not found and OTU not found"
                next
              end
            else
              if title.include? 'etymology'
                attribute_subject_id = tw_taxon_name_id
                attribute_subject_type = 'TaxonName'
              else
                attribute_subject_id = get_taxon_name_otu_id[tw_taxon_name_id]
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
