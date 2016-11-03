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
          # Create data_attributes for:
          #   NomenclatorID becomes nomenclator_string
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

          path = @args[:data_directory] + 'tblCites.txt'
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'UTF-16:UTF-8')

          count_found = 0
          error_counter = 0

          file.each_with_index do |row, i|
            # next if get_tw_otu_id.has_key?(row['FamilyNameID']) # ignore if ill-formed family name created only as OTU

            # project_id = TaxonName.find(older_name_id).project_id





            older_name_id = get_tw_taxon_name_id[row['OlderNameID']].to_i
            younger_name_id = get_tw_taxon_name_id[row['YoungerNameID']].to_i
            relationship = row['Relationship']

            relationship_hash = {'1' => 'TaxonNameRelationship::Iczn::PotentiallyValidating::ReplacementName',
                                 '2' => 'TaxonNameRelationship::Iczn::Invalidating::Synonym::ForgottenName',
                                 '3' => 'TaxonNameRelationship::Iczn::Invalidating::Usage::IncorrectOriginalSpelling',
                                 '4' => 'TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling',
                                 '5' => 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::UnjustifiedEmendation',
                                 '6' => 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::UnnecessaryReplacementName',
                                 '7' => 'TaxonNameRelationship::Iczn::Invalidating::Usage::Misapplication',
                                 '8' => 'TaxonNameRelationship::Iczn::Invalidating::Usage::IncorrectOriginalSpelling', # lapsus calami>>corrected lapsus
                                 '9' => 'TaxonNameRelationship::Iczn::Invalidating' # ::Synonym' # nomen nudum>>nomen nudum made available
            }

            # @todo: @mjy Matt and Dmitry need to come up with two new relationships (lapsus calami / corrected lapsus, nomen nudum / nomen nudum made available) that are semantically sound

            case relationship.to_i
              when 1
                subject_name_id = younger_name_id
                object_name_id = older_name_id
              when 2
                subject_name_id = older_name_id
                object_name_id = younger_name_id
              when 3
                subject_name_id = older_name_id
                object_name_id = younger_name_id
              when 4
                subject_name_id = younger_name_id
                object_name_id = older_name_id
              when 5
                subject_name_id = younger_name_id
                object_name_id = older_name_id
              when 6
                subject_name_id = younger_name_id
                object_name_id = older_name_id
              when 7
                subject_name_id = younger_name_id
                object_name_id = older_name_id
              when 8
                subject_name_id = older_name_id
                object_name_id = younger_name_id
              when 9
                subject_name_id = older_name_id
                object_name_id = younger_name_id

              # when 1 , 4, 5, 6, 7 then
              #   subject_name_id = older_name_id
              #   object_name_id = younger_name_id
              # else # 2, 3, 8, 9
              #   subject_name_id = younger_name_id
              #   object_name_id = older_name_id
            end

            if older_name_id == 0
              logger.error "TaxonNameRelationship SUPPRESSED older name SF.TaxonNameID = #{row['OlderNameID']} (#{suppressed_counter += 1})"
              next
            elsif younger_name_id == 0
              logger.error "TaxonNameRelationship SUPPRESSED younger name SF.TaxonNameID = #{row['YoungerNameID']} (#{suppressed_counter += 1})"
              next
            end

            # project_id = TaxonName.where(id: genus_name_id ).pluck(:project_id).first vs. TaxonName.find(genus_name_id).project_id
            project_id = TaxonName.find(older_name_id).project_id

            logger.info "Working with TW.project_id: #{project_id}, SF.OlderNameID #{row['OlderNameID']} = TW.older_name_id #{older_name_id}, SF.YoungerNameID #{row['YoungerNameID']} = TW.younger_name_id #{younger_name_id} (count #{count_found += 1}) \n"

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

            if tnr.valid?
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
