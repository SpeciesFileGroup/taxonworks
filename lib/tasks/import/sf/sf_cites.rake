namespace :tw do
  namespace :project_import do
    namespace :sf_import do
      require 'fileutils'
      require 'logged_task'
      namespace :cites do

        desc 'time rake tw:project_import:sf_import:cites:create_citations user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        LoggedTask.define :create_some_related_taxa => [:data_directory, :environment, :user_id] do |logger|

          logger.info 'Creating citations...'
          # Probably have original description from taxon import: how to handle duplicate?
          # Create note for tblCites.Note
          # Create data_attributes for NomenclatorID becomes nomenclator_string
          # Create topics for:
          #   NewNameStatusID
          #   TypeInfoID
          #   ConceptChangeID
          #   CurrentConcept
          #   InfoFlags
          #   InfoFlagStatus
          #   PolynomialStatus


          import = Import.find_or_create_by(name: 'SpeciesFileData')
          get_tw_user_id = import.get('SFFileUserIDToTWUserID') # for housekeeping
          get_tw_taxon_name_id = import.get('SFTaxonNameIDToTWTaxonNameID')
          # get_tw_otu_id = import.get('SFTaxonNameIDToTWOtuID')
          get_tw_source_id = import.get('SFRefIDToTWSourceID')
          get_nomenclator_string = import.get('SFNomenclatorIDToSFNomenclatorString')

          # @todo: Temporary "fix" to convert all values to string; will be fixed next time taxon names are imported and following do can be deleted
          get_tw_taxon_name_id.each do |key, value|
            get_tw_taxon_name_id[key] = value.to_s
          end

          # set up topics

          path = @args[:data_directory] + 'tblCites.txt'
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'UTF-16:UTF-8')

          count_found = 0
          error_counter = 0

          file.each_with_index do |row, i|
            taxon_name_id = get_tw_taxon_name_id[row['TaxonNameID']].to_i
            next unless TaxonName.where(id: taxon_name_id).any?

            project_id = TaxonName.find(taxon_name_id).project_id.to_i
            source_id = get_tw_source_id[row['RefID']].to_i
            logger.info "Working with TW.project_id: #{project_id}, SF.TaxonNameID #{row['TaxonNameID']} = TW.taxon_name_id #{taxon_name_id},
SF.RefID #{row['RefID']} = TW.source_id #{row['']}, SF.SeqNum #{row['SeqNum']} (count #{count_found += 1}) \n"

            # @todo Original description citation most likely exists already but pages are source pages, not cite pages
            cite_pages = row['CitePages']

            # Basic citation can now be created:
            citation = Citation.new(
                source_id: source_id,
                pages: cite_pages,
                # is_original:
                citation_object_type: 'TaxonName',
                citation_object_id: taxon_name_id,
                project_id: project_id,
                created_at: row['CreatedOn'],
                updated_at: row['LastUpdate'],
                created_by_id: get_tw_user_id[row['CreatedBy']],
                updated_by_id: get_tw_user_id[row['ModifiedBy']]
            )

            begin
              citation.save!
              logger.info "Citation saved"
            rescue ActiveRecord::RecordInvalid # citation not valid
              logger.info "Citation ERROR (#{error_counter += 1}): " + citation.errors.full_messages.join(';')
              next
            end

            ### After citation created

            ## Note
            # Can Note be created as note_attribute before the citation is created and saved?
            # notes_attributes: [{text: (row['Note'].blank? ? nil : row['Comment']),
            #                     project_id: project_id,
            #                     created_at: row['CreatedOn'],
            #                     updated_at: row['LastUpdate'],
            #                     created_by_id: get_tw_user_id[row['CreatedBy']],
            #                     updated_by_id: get_tw_user_id[row['ModifiedBy']]}],


            ## Nomenclator: DataAttribute of citation, NomenclatorID > 0
            if row['NomenclatorID'] == '0' # OR could value: be evaluated below based on NomenclatorID?
              da = DataAttribute.new(type: 'ImportAttribute',
                                     attribute_subject_id: citation.id,
                                     attribute_subject_type: Citation,
                                     import_predicate: 'Nomenclator',
                                     value: get_nomenclator_string[row['NomenclatorID']],
                                     project_id: project_id,
                                     created_at: row['CreatedOn'],
                                     updated_at: row['LastUpdate'],
                                     created_by_id: get_tw_user_id[row['CreatedBy']],
                                     updated_by_id: get_tw_user_id[row['ModifiedBy']]
              )
              begin
                da.save!
                puts 'DataAttribute Nomenclator created'
              rescue ActiveRecord::RecordInvalid # da not valid
                logger.error "DataAttribute Nomenclator ERROR NomenclatorID = #{row['NomenclatorID']}, SF.TaxonNameID #{row['TaxonNameID']} = TW.taxon_name_id #{taxon_name_id} (#{error_counter += 1}): " + da.errors.full_messages.join(';')
              end
            end


            ## NewNameStatus


            ## TypeInfo


            ## ConceptChange


            ## CurrentConcept: bit


            ## InfoFlags: Attribute/topic of citation?!! Treat like StatusFlags for individual values

            info_flags = row['InfoFlags'].to_i

            if info_flags > 0
              cite_info_flags_array = Utilities::Numbers.get_bits(info_flags)

              cite_info_flags_array.each do |bit_position|

                # no_relationship = false # set to true if no relationship should be created
                # bit_flag_name = ''

                case bit_position

                  when 1 # Image or description
                  when 2 # Phylogeny or classification
                  when 3 # Ecological data
                  when 4 # Specimen or distribution
                  when 5 # Key
                  when 6 # Life history
                  when 7 # Behavior
                  when 8 # Economic matters
                  when 9 # Physiology
                  when 10 # Structure
                end
              end
            end


            ## InfoFlagStatus: Add confidence, 1 = partial data or needs review, 2 = complete data
            # @!attribute confidence_level_id
            #   @return [Integer]
            #     the controlled vocabulary term used in the confidence
            #
            # @!attribute confidence_object_id
            #   @return [Integer]
            #      Rails polymorphic. The id of of the object being annotated.
            #
            # @!attribute confidence_object_type
            #   @return [String]
            #      Rails polymorphic.  The type of the object being annotated.
            #
            # @!attribute project_id
            #   @return [Integer]
            #   the project ID
            #
            # @!attribute position
            #   @return [Integer]
            #     a user definable sort code on the tags on an object, handled by acts_as_list

            # [11/18/16, 4:10:27 PM] Marilyn Beckman: For confidences, do I first create a ConfidenceLevel which defines the item about which I am confident?
            # [11/18/16, 4:10:56 PM] Marilyn Beckman: Then I assign a specific confidence for a given datum??

            info_flag_status = row['InfoFlagStatus'].to_i

            # if info_flag_status > 0
            #   confidence = Confidence.new(
            #                              confidence_level_id: row['InfoFlagStatus'],
            #
            #   )
            # end


            ## PolynomialStatus: based on NewNameStatus


          end
        end


        desc 'time rake tw:project_import:sf_import:cites:create_topics_for_citations user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        # @todo Do I really need a data_directory if I'm using a Postgres table? Not that it hurts...
        LoggedTask.define :create_topics_for_citations => [:data_directory, :environment, :user_id] do |logger|

          # Create topics for each project consisting of:
          #   NewNameStatusID
          #   TypeInfoID
          #   ConceptChangeID
          #   CurrentConcept
          #   InfoFlags
          #   InfoFlagStatus
          #   PolynomialStatus

          logger.info 'Running create_topics...'

          names = {} # initialize names hash

          Project.all.each do |project|
            next unless project.name.end_with?('species_file')

            names[project.id.to_s] = project.name # don't really need hash, but conveys logger info
            project_id = project.id

            logger.info "Working with TW.project_id: #{project_id} = '#{project.name}'"

            Topic.create!(
                name: 'NewNameStatus',
                definition: 'something'
            )


          end
        end

        desc 'time rake tw:project_import:sf_import:cites:import_nomenclator_strings user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        LoggedTask.define :import_nomenclator_strings => [:data_directory, :environment, :user_id] do |logger|
          # Can be run independently at any time

          logger.info 'Running import_nomenclator_strings...'

          get_nomenclator_string = {} # key = SF.NomenclatorID, value = SF.nomenclator_string

          count_found = 0

          path = @args[:data_directory] + 'sfNomenclatorStrings.txt'
          file = CSV.read(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

          file.each_with_index do |row, i|
            nomenclator_id = row['NomenclatorID']
            next if nomenclator_id == '0'

            nomenclator_string = row['NomenclatorString']

            logger.info "Working with SF.NomenclatorID '#{nomenclator_id}', SF.NomenclatorString '#{nomenclator_string}' (count #{count_found += 1}) \n"

            get_nomenclator_string[nomenclator_id] = nomenclator_string
          end

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          import.set('SFNomenclatorIDToSFNomenclatorString', get_nomenclator_string)

          puts = 'SFNomenclatorIDToSFNomenclatorString'
          ap get_nomenclator_string
        end

      end
    end
  end
end
