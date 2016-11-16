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
          # get_tw_user_id = import.get('SFFileUserIDToTWUserID') # for housekeeping
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




            # CiteInfoFlags = tblCites.InfoFlags, treat like StatusFlags, append all info_flags into single string as topics

            # info_flags = row['InfoFlags'].to_i
            #
            # if info_flags > 0
            #
            #   cite_info_flags_array = Utilities::Numbers.get_bits(info_flags)
            #
            #   # for bit_position in 0..status_flags_array.length - 1 # length is number of bits set
            #   status_flags_array.each do |bit_position|
            #
            #     no_relationship = false # set to true if no relationship should be created
            #     bit_flag_name = ''
            #
            #     case bit_position
            #
            #
            #     #   end of example



            tnr = TaxonNameRelationship.find_or_create_by(
                subject_taxon_name_id: subject_name_id,
                object_taxon_name_id: object_name_id,
                type: relationship_hash[relationship],
                # created_at: row['CreatedOn'],
                # updated_at: row['LastUpdate'],
                # created_by_id: get_tw_user_id[row['CreatedBy']],
                # updated_by_id: get_tw_user_id[row['ModifiedBy']],
                project_id: project_id
            )

            if !tnr.try(:id).nil?
              # tnr.save!
              puts 'TaxonNameRelationship created'

            else # tnr not valid
              logger.error "TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id #{project_id}, SF.OlderNameID #{row['OlderNameID']} = tw.object_name_id #{object_name_id} (#{error_counter += 1}): " + tnr.errors.full_messages.join(';')
            end
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
