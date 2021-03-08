namespace :tw do
  namespace :project_import do
    namespace :sf_import do
      require 'fileutils'
      require 'logged_task'
      namespace :taxa do


        desc 'time rake tw:project_import:sf_import:taxa:create_status_flag_relationships user_id=1 data_directory=~/src/onedb2tw/working/'
        LoggedTask.define create_status_flag_relationships: [:data_directory, :backup_directory, :environment, :user_id] do |logger|

          logger.info 'Creating relationships from StatusFlags...'

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          skipped_file_ids = import.get('SkippedFileIDs')
          excluded_taxa = import.get('ExcludedTaxa')
          # get_tw_user_id = import.get('SFFileUserIDToTWUserID') # for housekeeping
          get_tw_taxon_name_id = import.get('SFTaxonNameIDToTWTaxonNameID')
          get_tw_project_id = import.get('SFFileIDToTWProjectID')
          get_tw_otu_id = import.get('SFTaxonNameIDToTWOtuID')
          get_animalia_id = import.get('ProjectIDToAnimaliaID') # key = TW.Project.id, value TW.TaxonName.id where Name = 'Animalia', used when AboveID = 0

          path = @args[:data_directory] + 'sfTaxaByTaxonNameStr.txt'
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

          count_found = 0
          error_counter = 0

          file.each_with_index do |row, i|
            next if skipped_file_ids.include? row['FileID'].to_i
            next if excluded_taxa.include? row['TaxonNameID']
            next if get_tw_otu_id.has_key?(row['TaxonNameID']) # check if OTU was made

            project_id = get_tw_project_id[row['FileID']].to_i
            taxon_name_id = get_tw_taxon_name_id[row['TaxonNameID']].to_i
            original_genus_id = get_tw_taxon_name_id[row['OriginalGenusID']].to_i

            # pluck parent_id; thought I needed it for incertae sedis, but actually I don't
            # parent_id = TaxonName.where(id: taxon_name_id).pluck(:parent_id)[0]

            if row['AboveID'] == '0'
              above_id = get_animalia_id[project_id.to_s].to_i
            else
              above_id = get_tw_taxon_name_id[row['AboveID']].to_i
            end

            logger.info "Working with TW.project_id: #{project_id}, SF.TaxonNameID #{row['TaxonNameID']} = TW.taxon_name_id #{taxon_name_id}, RankID #{row['RankID']} (count #{count_found += 1}) \n"

            if row['RankID'] < '11' and row['OriginalGenusID'] > '0' # There are some SF genera with OriginalGenusID set???
              tnr = TaxonNameRelationship.new(
                  subject_taxon_name_id: original_genus_id,
                  object_taxon_name_id: taxon_name_id,
                  type: 'TaxonNameRelationship::OriginalCombination::OriginalGenus',
                  project_id: project_id
              )
              begin
                tnr.save!
                puts 'TaxonNameRelationship OriginalGenusID created'
              rescue ActiveRecord::RecordInvalid # tnr not valid
                logger.error "TaxonNameRelationship OriginalGenusID ERROR tw.project_id #{project_id}, SF.TaxonNameID #{row['TaxonNameID']} = TW.taxon_name_id #{taxon_name_id}, SF.OriginalGenusID #{row['OriginalGenusID']} = TW.original_genus_id #{original_genus_id} (Error # #{error_counter += 1}): " + tnr.errors.full_messages.join(';')
              end
            end

            name_status = row['NameStatus']
            status_flags = row['StatusFlags'].to_i

            if name_status == '7' and status_flags == 0 # add invalidating relationship to above_id (162 instances)
              # Not sure why >100 errors on invalidating alone; sometimes subject/object same rank, sometimes not??
              tnc = TaxonNameClassification.new(
                  type: 'TaxonNameClassification::Iczn::Unavailable',
                  taxon_name_id: taxon_name_id,
                  project_id: project_id
              )
              begin
                tnc.save!
                puts 'TaxonNameClassification::Iczn::Unavailable created'
              rescue ActiveRecord::RecordInvalid # tnc not valid
                logger.error "TaxonNameClassification 'TaxonNameClassification::Iczn::Unavailable' ERROR tw.project_id #{project_id}, SF.TaxonNameID #{row['TaxonNameID']} = TW.taxon_name_id #{taxon_name_id} (Error # #{error_counter += 1}): " + tnc.errors.full_messages.join(';')
              end
            end

            # Create import attribute (?) if NecAuthor.length > 0
            if row['NecAuthor'].length > 0
              da = DataAttribute.new(type: 'ImportAttribute',
                                     attribute_subject_id: taxon_name_id,
                                     attribute_subject_type: TaxonName,
                                     import_predicate: 'Nec author',
                                     value: row['NecAuthor'],
                                     project_id: project_id)
              begin
                da.save!
                puts 'DataAttribute NecAuthor created'
              rescue ActiveRecord::RecordInvalid # da not valid
                logger.error "DataAttribute NecAuthor ERROR SF.TaxonNameID #{row['TaxonNameID']} = TW.taxon_name_id #{taxon_name_id} (#{error_counter += 1}): " + da.errors.full_messages.join(';')
              end
            end

            if status_flags > 0

              status_flags_array = Utilities::Numbers.get_bits(status_flags)

              # for bit_position in 0..status_flags_array.length - 1 # length is number of bits set
              status_flags_array.each do |bit_position|

                no_relationship = false # set to true if no relationship should be created
                bit_flag_name = ''

                case bit_position

                when 0 # informal (inconsistently used)
                  # if encountered, classify as unavailable
                  tnc = TaxonNameClassification.new(
                      type: 'TaxonNameClassification::Iczn::Unavailable',
                      taxon_name_id: taxon_name_id,
                      project_id: project_id
                  )
                  begin
                    tnc.save!
                    puts 'TaxonNameClassification Unavailable created'
                  rescue ActiveRecord::RecordInvalid
                    logger.error "TaxonNameClassification Unavailable ERROR tw.project_id #{project_id}, SF.TaxonNameID #{row['TaxonNameID']} = TW.taxon_name_id #{taxon_name_id}, (Error # #{error_counter += 1}): " + tnc.errors.full_messages.join(';')
                  end
                  no_relationship = true
                  bit_flag_name = 'informal'
                when 1 # subsequent misspelling
                  type = 'TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling'
                  bit_flag_name = 'subsequent misspelling'
                when 2 # unjustified emendation
                  type = 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::UnjustifiedEmendation'
                  bit_flag_name = 'unjustified emendation'
                when 3 # nomen nudum
                  # if taxon is also synonym, treat as senior/junior synonym
                  if name_status == '7'
                    type = 'TaxonNameRelationship::Iczn::Invalidating::Synonym'
                  else
                    no_relationship = true
                  end
                  bit_flag_name = 'nomen nudum'
                when 4 # nomen dubium
                  # if taxon is also synonym, treat as senior/junior synonym
                  if name_status == '7'
                    type = 'TaxonNameRelationship::Iczn::Invalidating::Synonym'
                  else
                    no_relationship = true
                  end
                  bit_flag_name = 'nomen dubium'
                when 5 # incertae sedis
                  type = 'TaxonNameRelationship::Iczn::Validating::UncertainPlacement'
                  bit_flag_name = 'incertae sedis'

                  # when 6 # justified emendation; reciprocal of 15

                  # when 7 # nomen protectum; reciprocal of 8

                when 8 # suppressed by ruling
                  type = 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Suppression'
                  bit_flag_name = 'suppressed by ruling'
                when 9 # misapplied
                  type = 'TaxonNameRelationship::Iczn::Invalidating::Misapplication'
                  bit_flag_name = 'misapplied'

                  # - - -
                  # When 10 - 12, 22, may not have relationship in SF; new rule: If making relationship with AboveID fails, create classification only (invalid::homonym)
                when 10, 11, 12, 22 # create homonym classification and synonym relationship, then add note to taxon name about SF status, e.g., preoccupied
                  tnc = TaxonNameClassification.new(
                      type: 'TaxonNameClassification::Iczn::Available::Invalid::Homonym',
                      taxon_name_id: taxon_name_id,
                      project_id: project_id
                  )
                  begin
                    tnc.save!
                    puts 'TaxonNameClassification Invalid::Homonym created'
                  rescue ActiveRecord::RecordInvalid
                    logger.error "TaxonNameClassification Invalid::Homonym ERROR tw.project_id #{project_id}, SF.TaxonNameID #{row['TaxonNameID']} = TW.taxon_name_id #{taxon_name_id}, (Error # #{error_counter += 1}): " + tnc.errors.full_messages.join(';')
                  end

                  type = 'TaxonNameRelationship::Iczn::Invalidating::Synonym'

                  case bit_position
                  when 10
                    bit_flag_name = 'preoccupied'
                  when 11
                    bit_flag_name = 'primary homonym'
                  when 12
                    bit_flag_name = 'secondary homonym'
                  when 22
                    bit_flag_name = 'unspecified homonym'
                  end

                  Note.create!(
                      text: "Species File taxon (TaxonNameID = #{row['TaxonNameID']}), marked as '#{bit_flag_name}', created generic TaxonNameRelationship type '#{type}'",
                      note_object_id: taxon_name_id,
                      note_object_type: 'TaxonName',
                      project_id: project_id
                  )

                  # when 10 # preoccupied; if not in scope, no relationship
                  #   type = 'TaxonNameRelationship::Iczn::Invalidating::Homonym'
                  #   bit_flag_name = 'preoccupied'
                  # when 11 # primary homonym
                  #   type = 'TaxonNameRelationship::Iczn::Invalidating::Homonym::Primary'
                  #   bit_flag_name = 'primary homonym'
                  # when 12 # secondary homonym
                  #   type = 'TaxonNameRelationship::Iczn::Invalidating::Homonym::Secondary'
                  #   bit_flag_name = 'secondary homonym'
                  # - - -

                when 13 # nomen oblitum
                  type = 'TaxonNameRelationship::Iczn::Invalidating::Synonym::ForgottenName'
                  bit_flag_name = 'nomen oblitum'
                when 14 # unnecessary replacement
                  type = 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::UnnecessaryReplacementName'
                  bit_flag_name = 'unnecessary replacement'
                when 15 # incorrect original spelling
                  type = 'TaxonNameRelationship::Iczn::Invalidating::Usage::IncorrectOriginalSpelling'
                  bit_flag_name = 'incorrect original spelling'

                  # when 16 # other comment; comments were entered at time of taxon import

                when 17 # unavailable other; use invalidating?
                  type = 'TaxonNameRelationship::Iczn::Invalidating'
                  bit_flag_name = 'unavailable other'
                when 18 # junior synonym
                  type = 'TaxonNameRelationship::Iczn::Invalidating::Synonym'
                  bit_flag_name = 'junior synonym'

                  # when 19 # nomen novum; reciprocal of 10, 11, 12, others?

                when 20 # original name
                  Note.create!(
                      text: "Species File taxon (TaxonNameID = #{row['TaxonNameID']}) marked as 'original name'",
                      note_object_id: taxon_name_id,
                      note_object_type: 'TaxonName',
                      project_id: project_id
                  )

                  if name_status == '7' # create senior/junior synonym
                    type = 'TaxonNameRelationship::Iczn::Invalidating::Synonym'
                  else
                    no_relationship = true
                  end
                  bit_flag_name = 'original name'

                  # when 21 # subsequent name; reciprocal of homonym or required emendation?

                  # when 22 # unspecified homonym
                  #   type = 'TaxonNameRelationship::Iczn::Invalidating::Homonym'
                  #   bit_flag_name = 'unspecified homonym'
                when 23 # lapsus calami; treat as incorrect original spelling for now
                  type = 'TaxonNameRelationship::Iczn::Invalidating::Usage::IncorrectOriginalSpelling'
                  bit_flag_name = 'lapsus calami'

                  # when 24 # corrected lapsus; reciprocal of 23

                  # when 25 # nomen nudum made available; treat as reciprocal of 3 for now

                else
                  no_relationship = true
                end

                next if no_relationship

                tnr = TaxonNameRelationship.find_or_create_by(
                    subject_taxon_name_id: taxon_name_id,
                    object_taxon_name_id: above_id,
                    type: type,
                    project_id: project_id
                )

                if !tnr.try(:id).nil?
                  # tnr.save!
                  puts "TaxonNameRelationship '#{type}' exists"

                else # tnr not valid
                  logger.error "TaxonNameRelationship '#{type}' ERROR tw.project_id #{project_id}, object: SF.TaxonNameID #{row['TaxonNameID']} = TW.taxon_name_id #{taxon_name_id}, subject: SF.TaxonNameID #{row['AboveID']} = TW.taxon_name_id #{above_id} (Error # #{error_counter += 1}): " + tnr.errors.full_messages.join(';')

                  # if tnr fails because current taxon is homonym (preoccupied, primary, or secondary) and AboveID doesn't make sense: create classification instead 'TaxonNameClassification::Iczn::Available::Invalid::Homonym'
                  if [10, 11, 12].include?(bit_position)
                    tnc = TaxonNameClassification.new(
                        type: 'TaxonNameClassification::Iczn::Available::Invalid::Homonym',
                        taxon_name_id: taxon_name_id,
                        project_id: project_id
                    )
                    begin
                      tnc.save!
                      puts 'TaxonNameClassification Invalid::Homonym created'
                    rescue ActiveRecord::RecordInvalid
                      logger.error "TaxonNameClassification Invalid::Homonym ERROR tw.project_id #{project_id}, SF.TaxonNameID #{row['TaxonNameID']} = TW.taxon_name_id #{taxon_name_id}, (Error # #{error_counter += 1}): " + tnc.errors.full_messages.join(';')

                    end
                  end

                  # 234 failures 27 October 2016
                  Note.create!(
                      text: "Species File taxon (TaxonNameID = #{row['TaxonNameID']}), marked as '#{bit_flag_name}', TaxonNameRelationship type '#{type}' failed, error message '#{tnr.errors.full_messages.join('; ')}'",
                      note_object_id: taxon_name_id,
                      note_object_type: 'TaxonName',
                      project_id: project_id
                  )
                end
              end
            end
          end
        end

        desc 'time rake tw:project_import:sf_import:taxa:create_some_related_taxa user_id=1 data_directory=~/src/onedb2tw/working/'
        LoggedTask.define create_some_related_taxa: [:data_directory, :backup_directory, :environment, :user_id] do |logger|
          logger.info 'Creating some related taxa...'

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          skipped_file_ids = import.get('SkippedFileIDs')
          get_sf_taxon_info = import.get('SFTaxonNameIDMiscInfo')
          excluded_taxa = import.get('ExcludedTaxa')
          get_tw_project_id = import.get('SFFileIDToTWProjectID')
          get_tw_user_id = import.get('SFFileUserIDToTWUserID') # for housekeeping
          get_tw_taxon_name_id = import.get('SFTaxonNameIDToTWTaxonNameID')
          # get_tw_otu_id = import.get('SFTaxonNameIDToTWOtuID')

          path = @args[:data_directory] + 'tblRelatedTaxa.txt'
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

          count_found = 0
          error_counter = 0
          suppressed_counter = 0

          file.each_with_index do |row, i|
            sf_older_name_id = row['OlderNameID']
            sf_younger_name_id = row['YoungerNameID']
            next if sf_older_name_id == sf_younger_name_id
            sf_file_id = get_sf_taxon_info[sf_older_name_id]['file_id']
            next if skipped_file_ids.include? sf_file_id.to_i
            next if excluded_taxa.include? sf_older_name_id
            next if excluded_taxa.include? sf_younger_name_id

            tw_older_name_id = get_tw_taxon_name_id[sf_older_name_id]
            tw_younger_name_id = get_tw_taxon_name_id[sf_younger_name_id]
            project_id = get_tw_project_id[get_sf_taxon_info[sf_older_name_id]['file_id']]

            relationship = row['Relationship']

            relationship_hash = {'1' => 'TaxonNameRelationship::Iczn::PotentiallyValidating::ReplacementName',
                                 '2' => 'TaxonNameRelationship::Iczn::Invalidating::Synonym::ForgottenName',
                                 '3' => 'TaxonNameRelationship::Iczn::Invalidating::Usage::IncorrectOriginalSpelling',
                                 '4' => 'TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling',
                                 '5' => 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::UnjustifiedEmendation',
                                 '6' => 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::UnnecessaryReplacementName',
                                 '7' => 'TaxonNameRelationship::Iczn::Invalidating::Misapplication',
                                 '8' => 'TaxonNameRelationship::Iczn::Invalidating::Usage::IncorrectOriginalSpelling', # lapsus calami>>corrected lapsus
                                 '9' => 'TaxonNameRelationship::Iczn::Invalidating' # ::Synonym' # nomen nudum>>nomen nudum made available
            }

            # @todo: @mjy Matt and Dmitry need to come up with two new relationships (lapsus calami / corrected lapsus, nomen nudum / nomen nudum made available) that are semantically sound

            case relationship.to_i
            when 1
              subject_name_id = tw_younger_name_id
              object_name_id = tw_older_name_id
            when 2
              subject_name_id = tw_older_name_id
              object_name_id = tw_younger_name_id
            when 3
              subject_name_id = tw_older_name_id
              object_name_id = tw_younger_name_id
            when 4
              subject_name_id = tw_younger_name_id
              object_name_id = tw_older_name_id
            when 5
              subject_name_id = tw_younger_name_id
              object_name_id = tw_older_name_id
            when 6
              subject_name_id = tw_younger_name_id
              object_name_id = tw_older_name_id
            when 7
              subject_name_id = tw_younger_name_id
              object_name_id = tw_older_name_id
            when 8
              subject_name_id = tw_older_name_id
              object_name_id = tw_younger_name_id
            when 9
              subject_name_id = tw_older_name_id
              object_name_id = tw_younger_name_id
            end


            logger.info "Working with TW.project_id: #{project_id}, Relationship #{relationship}, SF.OlderNameID #{sf_older_name_id} = TW.older_name_id #{tw_older_name_id}, SF.YoungerNameID #{sf_younger_name_id} = TW.younger_name_id #{tw_younger_name_id} (count #{count_found += 1}) \n"

            tnr = TaxonNameRelationship.find_or_create_by(
                subject_taxon_name_id: subject_name_id,
                object_taxon_name_id: object_name_id,
                type: relationship_hash[relationship],
                project_id: project_id
            )

            if !tnr.try(:id).nil?
              # tnr.save!
              puts 'TaxonNameRelationship created or already existed'

            else # tnr not valid
              logger.error "TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id #{project_id}, SF.OlderNameID #{row['OlderNameID']} = tw.object_name_id #{object_name_id} (#{error_counter += 1}): " + tnr.errors.full_messages.join(';')
            end
          end
        end

        desc 'time rake tw:project_import:sf_import:taxa:create_type_genera user_id=1 data_directory=~/src/onedb2tw/working/'
        LoggedTask.define create_type_genera: [:data_directory, :backup_directory, :environment, :user_id] do |logger|

          logger.info 'Creating type genera...'

          # Four family names suppressed (Beckmaninae, etc.)
          # About 100 family names not compatible with type genus relationship, mostly genus group names (see log)

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          get_sf_taxon_info = import.get('SFTaxonNameIDMiscInfo')
          skipped_file_ids = import.get('SkippedFileIDs')
          excluded_taxa = import.get('ExcludedTaxa')
          get_tw_project_id = import.get('SFFileIDToTWProjectID')
          get_tw_user_id = import.get('SFFileUserIDToTWUserID') # for housekeeping
          get_tw_taxon_name_id = import.get('SFTaxonNameIDToTWTaxonNameID')
          get_tw_otu_id = import.get('SFTaxonNameIDToTWOtuID')

          path = @args[:data_directory] + 'tblTypeGenera.txt'
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

          count_found = 0
          error_counter = 0

          file.each_with_index do |row, i|
            next if skipped_file_ids.include? get_sf_taxon_info[row['FamilyNameID']]['file_id'].to_i
            next if get_tw_otu_id.has_key?(row['FamilyNameID']) # ignore if ill-formed family name created only as OTU
            next if excluded_taxa.include? row['FamilyNameID']
            next if excluded_taxa.include? row['GenusNameID']

            sf_family_name_id = row['FamilyNameID']
            sf_genus_name_id = row['GenusNameID']
            tw_family_name_id = get_tw_taxon_name_id[sf_family_name_id].to_i
            tw_genus_name_id = get_tw_taxon_name_id[sf_genus_name_id].to_i
            project_id = get_tw_project_id[get_sf_taxon_info[sf_family_name_id]['file_id']]
            sf_rank_id = get_sf_taxon_info[sf_family_name_id]['rank_id']

            # test if SF rank of family_name is 'Genus Group'; equivalent to TW.supergenus (not a family group name)
            # create note for both genus and genus group names stating cannot create type genus relationship
            if sf_rank_id == '22'
              Note.create!(
                  text: "SF.FamilyID = #{sf_family_name_id} is a genus group rank in TW; it cannot have SF.GenusID = #{sf_genus_name_id} as a type genus",
                  note_object_id: tw_family_name_id,
                  note_object_type: 'TaxonName',
                  project_id: project_id
              )
              Note.create!(
                  text: "SF.FamilyID = #{sf_family_name_id} is a genus group rank in TW; it cannot have SF.GenusID = #{sf_genus_name_id} as a type genus",
                  note_object_id: tw_genus_name_id,
                  note_object_type: 'TaxonName',
                  project_id: project_id
              )
              next
            end

            if tw_family_name_id == 0
              logger.error "TaxonNameRelationship SUPPRESSED family name SF.TaxonNameID = #{row['FamilyNameID']}"
              next
            end


            logger.info "Working with TW.project_id: #{project_id}, SF.FamilyNameID #{sf_family_name_id} = TW.FamilyNameID #{tw_family_name_id}, SF.GenusNameID #{sf_genus_name_id} = TW.GenusNameID #{tw_genus_name_id} (count #{count_found += 1}) \n"

            tnr = TaxonNameRelationship.new(
                subject_taxon_name_id: tw_genus_name_id,
                object_taxon_name_id: tw_family_name_id,
                type: 'TaxonNameRelationship::Typification::Family',
                created_at: row['CreatedOn'],
                updated_at: row['LastUpdate'],
                created_by_id: get_tw_user_id[row['CreatedBy']],
                updated_by_id: get_tw_user_id[row['ModifiedBy']],
                project_id: project_id,
            )

            begin
              tnr.save!
              puts 'TaxonNameRelationship created'

            rescue ActiveRecord::RecordInvalid # tnr not valid
              logger.error "TaxonNameRelationship ERROR TW.taxon_name_id #{tw_family_name_id} (#{error_counter += 1}): " + tnr.errors.full_messages.join(';')
            end
          end
        end

        desc 'time rake tw:project_import:sf_import:taxa:create_type_species user_id=1 data_directory=~/src/onedb2tw/working/'
        LoggedTask.define create_type_species: [:data_directory, :backup_directory, :environment, :user_id] do |logger|

          logger.info 'Creating type species...'

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          get_sf_taxon_info = import.get('SFTaxonNameIDMiscInfo')
          # get_sf_file_id = import.get('SFTaxonNameIDToSFFileID')
          skipped_file_ids = import.get('SkippedFileIDs')
          excluded_taxa = import.get('ExcludedTaxa')
          get_tw_user_id = import.get('SFFileUserIDToTWUserID') # for housekeeping
          get_tw_source_id = import.get('SFRefIDToTWSourceID')
          get_tw_taxon_name_id = import.get('SFTaxonNameIDToTWTaxonNameID')

          path = @args[:data_directory] + 'tblTypeSpecies.txt'
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

          type_species_reason_hash = {'0' => 'TaxonNameRelationship::Typification::Genus', # unknown
                                      '1' => 'TaxonNameRelationship::Typification::Genus::Original::OriginalMonotypy',
                                      '2' => 'TaxonNameRelationship::Typification::Genus::Original::OriginalDesignation',
                                      '3' => 'TaxonNameRelationship::Typification::Genus::Subsequent::SubsequentDesignation',
                                      '4' => 'TaxonNameRelationship::Typification::Genus::Original',
                                      '5' => 'TaxonNameRelationship::Typification::Genus::Subsequent::SubsequentMonotypy',
                                      '6' => 'TaxonNameRelationship::Typification::Genus::Tautonomy::Absolute',
                                      '7' => 'TaxonNameRelationship::Typification::Genus::Tautonomy::Linnaean',
                                      '8' => 'TaxonNameRelationship::Typification::Genus::Subsequent::RulingByCommission',
                                      '9' => 'TaxonNameRelationship::Typification::Genus' # inherited from replaced name (TODO: it should be the same relationship as for replaced name)
          }

          count_found = 0
          error_counter = 0
          no_species_counter = 0
          no_genus_counter = 0

          file.each_with_index do |row, i|
            next if skipped_file_ids.include? get_sf_taxon_info[row['GenusNameID']]['file_id'].to_i
            next if excluded_taxa.include? row['GenusNameID']
            next if row['SpeciesNameID'] == '0' # if SpeciesNameID = 0 entry is for FirstFamilyGroupNameID

            # @todo: SF TaxonNameID pairs must be manually fixed: 1132639/1132641 (Orthoptera) and 1184619/1184569 (Mantodea)

            genus_name_id = get_tw_taxon_name_id[row['GenusNameID']].to_i

            if genus_name_id == 0
              logger.error "TaxonNameRelationship ERROR SF.GenusNameID #{row['GenusNameID']} (#{no_genus_counter += 1}): NO TW GENUS"
              next
            end

            species_name_id = get_tw_taxon_name_id[row['SpeciesNameID']].to_i

            reason = row['Reason'] # test if = '4' to add note after; if reason = 9, make note in SF it is inherited from replaced name
            authority_ref_id = row['AuthorityRefID'].to_i > 0 ? get_tw_source_id[row['AuthorityRefID']]&.to_i : nil # is string
            first_family_group_name_id = get_tw_taxon_name_id[row['FirstFamGrpNameID']].to_i # make import attribute

            # project_id = TaxonName.where(id: genus_name_id ).pluck(:project_id).first vs. TaxonName.find(genus_name_id).project_id
            project_id = TaxonName.find(genus_name_id).project_id

            logger.info "Working with TW.project_id: #{project_id}, SF.GenusNameID #{row['GenusNameID']} = TW.GenusNameID #{genus_name_id}, SF.SpeciesNameID #{row['SpeciesNameID']} = TW.SpeciesNameID #{species_name_id} (count #{count_found += 1}) \n"

            if species_name_id == 0
              logger.error "TaxonNameRelationship ERROR TW.taxon_name_id #{genus_name_id} (#{no_species_counter += 1}): NO TW SPECIES"
              Note.create!(
                  text: "Problem with type species: SF species TaxonNameID = #{row['SpeciesNameID']} not present in taxon_names",
                  note_object_id: genus_name_id,
                  note_object_type: 'TaxonName',
                  project_id: project_id
              )
              next
            end

            tnr = TaxonNameRelationship.new(
                subject_taxon_name_id: species_name_id,
                object_taxon_name_id: genus_name_id,
                type: type_species_reason_hash[reason],
                created_at: row['CreatedOn'],
                updated_at: row['LastUpdate'],
                created_by_id: get_tw_user_id[row['CreatedBy']],
                updated_by_id: get_tw_user_id[row['ModifiedBy']],
                project_id: project_id,
            )

            begin
              tnr.save!
              puts 'TaxonNameRelationship created'

              if tnr.id && row['AuthorityRefID'].to_i > 0 # 20 out of 1924 sources not found
                unless authority_ref_id.nil?
                  tnr_cit = tnr.citations.new(source_id: authority_ref_id,
                                              project_id: project_id)
                  tnr_cit.save
                  if !tnr_cit.id.nil?
                    puts 'Citation created'
                  else
                    logger.error "TaxonNameRelationship citation ERROR TW.taxon_name_id #{genus_name_id} (#{error_counter += 1}): " + tnr_cit.errors.full_messages.join(';')
                  end
                else
                  logger.error "TaxonNameRelationship citation ERROR TW.taxon_name_id #{genus_name_id} (#{error_counter += 1}): AuthorityRefID=#{row['AuthorityRefID']} source not found!"
                end
              end

              if reason == '4'
                note4 = Note.new(text: 'SF reason: monotypy and original designation',
                                 note_object_id: genus_name_id,
                                 note_object_type: 'TaxonName',
                                 project_id: project_id)

                begin
                  note4.save!
                  puts 'Note4 created'
                rescue ActiveRecord::RecordInvalid # note4 not valid
                  logger.error "TaxonName note4 ERROR TW.taxon_name_id #{genus_name_id} (#{error_counter += 1}): " + note4.errors.full_messages.join(';')
                end
              end

              if reason == '9'
                note9 = Note.new(text: 'SF reason: inherited from replaced name',
                                 note_object_id: genus_name_id,
                                 note_object_type: 'TaxonName',
                                 project_id: project_id)

                begin
                  note9.save!
                  puts 'Note9 created'
                rescue ActiveRecord::RecordInvalid # note9 not valid
                  logger.error "TaxonName note9 ERROR TW.taxon_name_id #{genus_name_id} (#{error_counter += 1}): " + note9.errors.full_messages.join(';')
                end
              end

              if first_family_group_name_id > 0
                da = DataAttribute.new(type: 'ImportAttribute',
                                       attribute_subject_id: genus_name_id,
                                       attribute_subject_type: TaxonName,
                                       import_predicate: 'FirstFamilyGroupName',
                                       value: first_family_group_name_id,
                                       project_id: project_id)

                begin
                  da.save!
                  puts 'FirstFamilyGroupName (da) created'
                rescue ActiveRecord::RecordInvalid # da not valid
                  logger.error "DataAttribute ERROR TW.taxon_name_id #{genus_name_id} (#{error_counter += 1}): " + da.errors.full_messages.join(';')
                end
              end

            rescue ActiveRecord::RecordInvalid # tnr not valid
              logger.error "TaxonNameRelationship ERROR TW.taxon_name_id #{genus_name_id} (#{error_counter += 1}): " + tnr.errors.full_messages.join(';')
            end
          end
        end

        ### ---------------------------------------------------------------------------------------------------------------------------------------------
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

        # desc 'try the logger utility'
        # ### time rake tw:project_import:sf_taxa:try_logger user_id=1 data_directory=~/src/onedb2tw/working/
        # LoggedTask.define :try_logger => [:data_directory, :backup_directory, :environment, :user_id] do |logger|
        #   logger.info "This is :try_logger"
        #   logger.warn "This is a logger warning"
        #   logger.error "This is a big bad nasty error message"
        # end
        ### ---------------------------------------------------------------------------------------------------------------------------------------------


        ############ check if taxon description requires a source where ContainingRefID > 0

        desc 'time rake tw:project_import:sf_import:taxa:create_all_sf_taxa_pass1 user_id=1 data_directory=~/src/onedb2tw/working/'
        LoggedTask.define create_all_sf_taxa_pass1: [:data_directory, :backup_directory, :environment, :user_id] do |logger|

          ################ NOTE NOTE NOTE
          # Some OriginalGenusIDs are not being created if they have not been imported yet. Order by TaxonNameStr ensured current genus exists.
          # To be fixed in separate task prior to creating citations (check_original_genus_ids).

          # real	310m28.726s
          # user	207m23.957s
          # sys	6m50.530s

          # [INFO]2017-03-15 15:43:39.366: Logged task tw:project_import:sf_import:taxa:create_all_sf_taxa_pass1 completed!
          # [INFO]2017-03-15 15:43:39.367: All tasks completed. Dumping summary for each task...
          # === Summary of warnings and errors for task tw:project_import:sf_import:taxa:create_all_sf_taxa_pass1 ===
          # [ERROR]2017-03-15 13:11:40.264: TaxonName ERROR (1) AFTER synonym test (SF.TaxonNameID = 1225991, parent_id = 68332): Parent The parent rank (subspecies) is not higher than subspecies
          # [ERROR]2017-03-15 13:20:22.621: TaxonName ERROR (2) AFTER synonym test (SF.TaxonNameID = 1170406, parent_id = 71920): Parent The parent rank (subspecies) is not higher than subspecies
          #
          # Error count = 6582 after synonym test on 16 July 2019

          logger.info 'Creating all SF taxa (pass 1)...'

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          skipped_file_ids = import.get('SkippedFileIDs')
          excluded_taxa = import.get('ExcludedTaxa')
          get_tw_user_id = import.get('SFFileUserIDToTWUserID') # for housekeeping
          get_tw_rank_string = import.get('SFRankIDToTWRankString')
          get_tw_source_id = import.get('SFRefIDToTWSourceID')
          get_tw_project_id = import.get('SFFileIDToTWProjectID')
          get_animalia_id = import.get('ProjectIDToAnimaliaID') # key = TW.Project.id, value TW.TaxonName.id where Name = 'Animalia', used when AboveID = 0
          get_sf_parent_id = import.get('SFSynonymIDToSFParentID')
          get_otu_sf_above_id = import.get('SFIllFormedNameIDToSFAboveID')
          get_tw_person_id = import.get('SFPersonIDToTWPersonID')
          # get_sf_new_parent_id = import.get('SFSubordinateIDToSFNewParentID')
          # get_contained_cite_aux_data = import.get('SFContainedCiteAuxData')
          ref_id_containing_id_hash = import.get('RefIDContainingHash')
          ref_taxon_name_authors = import.get('SFRefIDToTaxonNameAuthors')
          family_group_related_info = import.get('SFFamilyGroupRelatedInfo')

          get_tw_taxon_name_id = {} # key = SF.TaxonNameID, value = TW.taxon_name.id
          get_sf_name_status = {} # key = SF.TaxonNameID, value = SF.NameStatus
          get_sf_status_flags = {} # key = SF.TaxonNameID, value = SF.StatusFlags
          get_tw_otu_id = {} # key = SF.TaxonNameID, value = TW.otu.id; used for temporary or bad valid SF taxa
          get_taxon_name_otu_id = {} # key = TW.TaxonName.id, value TW.OTU.id just created for newly added taxon_name

          # ecology info setup
          # row['Ecology'], row['LifeZone']
          # distribution text set up
          # row['Distribution']

          ecology_topic_ids = {}
          distribution_topic_ids = {}
          get_tw_project_id.each_value do |project_id|
            puts project_id
            ecology_topic = Topic.create!(
                name: 'Life zone and ecology data',
                definition: 'Life zone and ecology data',
                project_id: project_id)
            ecology_topic_ids[project_id] = ecology_topic.id

            distribution_topic = Topic.create!(
                name: 'Distribution text',
                definition: 'List of documented place names',
                project_id: project_id)
            distribution_topic_ids[project_id] = distribution_topic.id
          end

          ap ecology_topic_ids
          ap distribution_topic_ids

          life_zone_map = {0 => 'marine', 1 => 'brackish', 2 => 'freshwater', 3 => 'terrestrial'} # must be bit position

          path = @args[:data_directory] + 'sfTaxaByTaxonNameStr.txt'
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

          error_counter = 0
          count_found = 0
          no_parent_counter = 0

          invalid_name_keywords = {}
          get_tw_project_id.each_value do |project_id|
            k = Keyword.find_or_create_by(
                name: 'Taxon name validation failed',
                definition: 'Taxon name validation failed',
                project_id: project_id)
            invalid_name_keywords[project_id] = k
          end

          file.each_with_index do |row, i|
            next if skipped_file_ids.include? row['FileID'].to_i
            sf_taxon_name_id = row['TaxonNameID']
            # puts sf_taxon_name_id
            # puts row['TaxonNameStr']
            sf_rank_id = row['RankID']
            next if excluded_taxa.include? sf_taxon_name_id
            next if sf_rank_id == '90' # TaxonNameID = 1221948, Name = Deletable, RankID = 90 == Life, FileID = 1
            next if [4, 19].include?(row['AccessCode'].to_i)

            project_id = get_tw_project_id[row['FileID']]


            # Note: sf_ref_id can be 0

            if (22..44).include?(sf_rank_id.to_i)
              # byebug

              # If family-group name, get RefID from family_group_related_info hash for family_taxon_name_author; value in tblTaxa is first use of this family_group name
              if family_group_related_info[sf_taxon_name_id].nil?
                logger.error "No family-group taxon (no type genus ID?): sf_taxon_name_id = #{sf_taxon_name_id} (error_counter = #{error_counter += 1})"
              else
                ref_id = family_group_related_info[sf_taxon_name_id]['family_author_ref_id']
              end
            else
              ref_id = row['RefID'] # preserve this value; used intact below for creating taxon_name_author list if this is a contained ref
            end

            if ref_id_containing_id_hash[ref_id].nil? # this RefID does not have a ContainingRefID
              use_this_ref_id = ref_id
              add_different_authors = false # copy source_author list to taxon_name_author list
            else
              use_this_ref_id = ref_id_containing_id_hash[ref_id]
              add_different_authors = true # add taxon_name_authors for contained ref
            end

            # For ecology
            life_zones = row['LifeZone'].to_i
            if life_zones == 0
              life_zone_text = 'not specified'
            else
              life_zone_text = Utilities::Numbers.get_bits(life_zones).collect { |i| life_zone_map[i] }.compact.join(', ')
            end
            ecology_text = "* Life zone [#{life_zone_text}]"
            ecology_text += ": #{row['Ecology']}" unless row['Ecology'].blank?

            life_zone_predicate = Predicate.create_with(
              name: 'Life zone', definition: 'Catalogue of Life lifeZone term'
            ).find_or_create_by!(
              project_id: project_id, uri: 'https://api.catalogue.life/datapackage#Taxon.lifezone'
            )

            extinct_predicate = Predicate.create_with(
              name: 'Extinct', definition: 'Catalogue of Life extinct term'
            ).find_or_create_by!(
              project_id: project_id, uri: 'https://api.catalogue.life/datapackage#Taxon.extinct'
            )

            logger.info "Working with TW.project_id: #{project_id} = SF.FileID #{row['FileID']}, SF.TaxonNameID #{sf_taxon_name_id}, use_this_ref_id #{use_this_ref_id}, add_different_authors #{add_different_authors} (count #{count_found += 1}) \n"

            animalia_id = get_animalia_id[project_id.to_s]

            if row['AboveID'] == '0' # must check AboveID = 0 before synonym
              parent_id = animalia_id
            elsif row['NameStatus'] == '7' # = synonym; MUST handle synonym parent before BadValidName (because latter doesn't treat synonym parents)
              # new synonym parent id could be = 0 if RankID bubbles up to top
              # logger.info "get_sf_parent_id[taxon_name_id] = #{get_sf_parent_id[taxon_name_id]}, taxon_name_id.class = #{taxon_name_id.class}"
              if get_sf_parent_id[sf_taxon_name_id] == '0' # use animalia_id
                parent_id = animalia_id
              else
                parent_id = get_tw_taxon_name_id[get_sf_parent_id[sf_taxon_name_id]] # assumes a TW taxon_name_id exists
              end
            elsif get_otu_sf_above_id[sf_taxon_name_id] # ill-formed sf taxon name, will make OTU
              parent_id = get_tw_taxon_name_id[get_otu_sf_above_id[sf_taxon_name_id]]
              # problem with two instances of parent not properly selected when nominotypical species, seems to default to nominotypical subspecies:
              # TaxonNameID 1225991 (Plec, tadzhikistanicum, nomen dubium, parent should be 1166943)
              # TaxonNameID 1170406 (Plec, suppleta, nomen nudum, parent should be 1170405)
              # logger.info "get_otu_sf_above_id.has_key? parent_id = #{parent_id}"
              # elsif get_sf_new_parent_id.has_key?(taxon_name_id) # subordinate of bad valid taxon name
              #   parent_id = get_tw_taxon_name_id[get_sf_new_parent_id[taxon_name_id]]
              # logger.info "get_sf_new_parent_id.has_key? parent_id = #{parent_id}"
            else
              parent_id = get_tw_taxon_name_id[row['AboveID']]
            end

            if parent_id == nil
              logger.warn "ALERT: Could not find parent_id of SF.TaxonNameID = #{sf_taxon_name_id} (error #{no_parent_counter += 1})! Set to animalia_id = #{animalia_id}"
              parent_id = animalia_id # this is problematic; need real solution
            end

            name_status = row['NameStatus']
            status_flags = row['StatusFlags']

            if get_otu_sf_above_id[sf_taxon_name_id] # temporary, create OTU, not TaxonName; create citation, too
              if row['NameStatus'] == '7' && !get_taxon_name_otu_id[row['TaxonNameID']].blank?
                otu = Otu.find(get_taxon_name_otu_id[row['TaxonNameID']].to_i)
              else
                otu = Otu.new(
                    name: row['Name'],
                    taxon_name_id: parent_id,
                    project_id: project_id,
                    created_at: row['CreatedOn'],
                    updated_at: row['LastUpdate'],
                    created_by_id: get_tw_user_id[row['CreatedBy']],
                    updated_by_id: get_tw_user_id[row['ModifiedBy']]
                )
              end

              if otu.save
                logger.info "Note!! Created OTU for temporary or ill-formed taxon SF.TaxonNameID = #{sf_taxon_name_id}, otu.id = #{otu.id}"

                otu.citations << Citation.new(source_id: get_tw_source_id[use_this_ref_id], is_original: true, project_id: project_id)
                # Note: If contained ref, no need to specify separate taxon_name_author for OTUs

                get_tw_otu_id[row['TaxonNameID']] = otu.id.to_s
                get_sf_name_status[row['TaxonNameID']] = name_status
                get_sf_status_flags[row['TaxonNameID']] = status_flags

                # life zone and ecology for otu only
                logger.info "Ecology: Working with SF.TaxonNameID = '#{row['TaxonNameID']}', otu_id = '#{otu.id}, SF.FileID = '#{row['FileID']}', life_zones = '#{life_zone_text}' \n"

                Content.create!(
                    topic_id: ecology_topic_ids[project_id],
                    otu_id: otu.id,
                    project_id: project_id,
                    text: ecology_text)

                InternalAttribute.create!(
                  predicate: life_zone_predicate,
                  attribute_subject: otu,
                  value: life_zone_text,
                  project_id: project_id,
                  created_at: row['CreatedOn'],
                  updated_at: row['LastUpdate'],
                  created_by_id: get_tw_user_id[row['CreatedBy']],
                  updated_by_id: get_tw_user_id[row['ModifiedBy']]
                ) unless life_zones == 0

                InternalAttribute.create!(
                  predicate: extinct_predicate,
                  attribute_subject: otu,
                  value: row['Extinct'],
                  project_id: project_id,
                  created_at: row['CreatedOn'],
                  updated_at: row['LastUpdate'],
                  created_by_id: get_tw_user_id[row['CreatedBy']],
                  updated_by_id: get_tw_user_id[row['ModifiedBy']]
                ) unless row['NameStatus'] == '7' # Value ignored per docs: http://help.speciesfile.org/index.php/Taxa

                # distribution text for otu only
                distribution_text = row['Distribution'] || ''
                logger.info "Distribution: Working with SF.TaxonNameID = '#{row['TaxonNameID']}', otu_id = '#{otu.id}, SF.FileID = '#{row['FileID']}', distribution_text = '#{distribution_text}' \n"

                if distribution_text.present?
                  Content.create!(
                      topic_id: distribution_topic_ids[project_id],
                      otu_id: otu.id,
                      project_id: project_id,
                      text: distribution_text)
                end

              else
                logger.error "OTU ERROR (#{error_counter += 1}) for SF.TaxonNameID = #{sf_taxon_name_id}: " + otu.errors.full_messages.join(';')
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

                  data_attributes_attributes: [
                      {type: 'ImportAttribute',
                       import_predicate: 'SF.TaxonNameID',
                       value: sf_taxon_name_id,
                       project_id: project_id
                      }],

                  # housekeeping attributed to SF last_editor, etc.
                  origin_citation_attributes: {source_id: get_tw_source_id[use_this_ref_id],
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


              begin
                taxon_name.save!

                  # if one of anticipated import errors, add classification, then try to save again...
              rescue ActiveRecord::RecordInvalid
                taxon_name.taxon_name_classifications.new(
                    type: 'TaxonNameClassification::Iczn::Unavailable::NotLatin',
                    project_id: project_id,
                    created_at: row['CreatedOn'],
                    updated_at: row['LastUpdate'],
                    created_by_id: get_tw_user_id[row['CreatedBy']],
                    updated_by_id: get_tw_user_id[row['ModifiedBy']])

                taxon_name.tags.new(keyword: invalid_name_keywords[project_id],
                                    project_id: project_id,
                                    created_at: row['CreatedOn'],
                                    updated_at: row['LastUpdate'],
                                    created_by_id: get_tw_user_id[row['CreatedBy']],
                                    updated_by_id: get_tw_user_id[row['ModifiedBy']])
              end

              begin
                if taxon_name.new_record?
                  taxon_name.save!
                end

                get_tw_taxon_name_id[row['TaxonNameID']] = taxon_name.id.to_s # force to string
                get_sf_name_status[row['TaxonNameID']] = name_status
                get_sf_status_flags[row['TaxonNameID']] = status_flags
                get_taxon_name_otu_id[taxon_name.id.to_s] = taxon_name.otus.last.id.to_s


                # ecology

                otu_id = get_taxon_name_otu_id[taxon_name.id.to_s]
                logger.info "Ecology: Working with SF.TaxonNameID = '#{row['TaxonNameID']}', TW.TaxonNameID = '#{taxon_name.id}, otu_id = '#{otu_id}, SF.FileID = '#{row['FileID']}', life_zones = '#{life_zone_text}' \n"

                Content.create!(
                    topic_id: ecology_topic_ids[project_id],
                    otu_id: otu_id,
                    project_id: project_id,
                    text: ecology_text)

                InternalAttribute.create!(
                  predicate: life_zone_predicate,
                  attribute_subject_id: otu_id,
                  attribute_subject_type: 'Otu',
                  value: life_zone_text,
                  project_id: project_id,
                  created_at: row['CreatedOn'],
                  updated_at: row['LastUpdate'],
                  created_by_id: get_tw_user_id[row['CreatedBy']],
                  updated_by_id: get_tw_user_id[row['ModifiedBy']]
                ) unless life_zones == 0

                InternalAttribute.create!(
                  predicate: extinct_predicate,
                  attribute_subject_id: otu_id,
                  attribute_subject_type: 'Otu',
                  value: row['Extinct'],
                  project_id: project_id,
                  created_at: row['CreatedOn'],
                  updated_at: row['LastUpdate'],
                  created_by_id: get_tw_user_id[row['CreatedBy']],
                  updated_by_id: get_tw_user_id[row['ModifiedBy']]
                ) unless row['NameStatus'] == '7' # Value ignored per docs: http://help.speciesfile.org/index.php/Taxa

                # distribution

                logger.info "Distribution: Working with SF.TaxonNameID = '#{row['TaxonNameID']}', otu_id = '#{otu_id}, SF.FileID = '#{row['FileID']}', distribution_text = '#{distribution_text}' \n"

                if distribution_text.present?
                  Content.create!(
                      topic_id: distribution_topic_ids[project_id],
                      otu_id: otu_id,
                      project_id: project_id,
                      text: distribution_text)
                end

                # taxon_name_roles for original citation

                if add_different_authors
                  # This is a ref in ref, taxon_name_authors listed in sfRefAuthorsOrdered, use value in ref_id, not use_this_ref_id
                  ref_taxon_name_authors[ref_id].each do |sf_person_id| # person_id from author_array
                    TaxonNameAuthor.create!(
                        person_id: get_tw_person_id[sf_person_id],
                        role_object_id: taxon_name.id,
                        role_object_type: 'TaxonName',
                        project_id: project_id # role is project_role
                    )
                  end
                else
                  # This is a simple citation, copy source author list to taxon name author list
                  # SourceAuthor.where(role_object_type: 'Source', role_object_id: source).find_each do |sa|
                  #   TaxonNameAuthor.create(person_id: sa.person_id, role_object: taxon, position: sa.position)

                  ordered_authors = SourceAuthor.where(role_object_id: get_tw_source_id[use_this_ref_id]).order(:position).pluck(:person_id).each do |person_id|
                    puts person_id
                  end

                  ordered_authors.each do |person_id|
                    role = TaxonNameAuthor.new(
                        person_id: person_id,
                        role_object_id: taxon_name.id,
                        role_object_type: 'TaxonName',
                        project_id: project_id
                    )
                    begin
                      role.save!
                    rescue ActiveRecord::RecordInvalid
                      logger.error "TaxonNameAuthor role ERROR person_id = #{person_id} (#{editor_error_counter += 1}): " + role.errors.full_messages.join(';')
                    end
                  end

                end


              rescue ActiveRecord::RecordInvalid
                logger.error "TaxonName ERROR (count = #{error_counter += 1}) AFTER synonym test (SF.TaxonNameID = #{sf_taxon_name_id}, parent_id = #{parent_id}): " + taxon_name.errors.full_messages.join(';')
              end
            end
          end

          import.set('SFTaxonNameIDToTWTaxonNameID', get_tw_taxon_name_id)
          import.set('SFTaxonNameIDToSFNameStatus', get_sf_name_status)
          import.set('SFTaxonNameIDToSFStatusFlags', get_sf_status_flags)
          import.set('SFTaxonNameIDToTWOtuID', get_tw_otu_id)
          import.set('TWTaxonNameIDToOtuID', get_taxon_name_otu_id)

          puts 'SFTaxonNameIDToTWTaxonNameID'
          ap get_tw_taxon_name_id
          puts 'SFTaxonNameIDToSFNameStatus'
          ap get_sf_name_status
          puts 'SFTaxonNameIDToSFStatusFlags'
          ap get_sf_status_flags
          puts 'SFTaxonNameIDToTWOtuID'
          ap get_tw_otu_id
          puts 'TWTaxonNameIDToOtuID'
          ap get_taxon_name_otu_id
        end

        desc 'time rake tw:project_import:sf_import:taxa:create_otus_for_ill_formed_names_hash user_id=1 data_directory=~/src/onedb2tw/working/'
        LoggedTask.define create_otus_for_ill_formed_names_hash: [:data_directory, :backup_directory, :environment, :user_id] do |logger|

          logger.info 'Running create otus for ill-formed names hash...'

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          skipped_file_ids = import.get('SkippedFileIDs')

          get_otu_sf_above_id = {} # key = SF.TaxonNameID of bad valid name, value = SF.AboveID of bad valid name

          path = @args[:data_directory] + 'sfMakeOTUs.txt'
          # not a problem right now but eventually should change
          file = CSV.read(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

          file.each do |row|
            next if skipped_file_ids.include? row['FileID'].to_i
            # byebug
            # puts row.inspect
            taxon_name_id = row['TaxonNameID']
            above_id = row['AboveID']
            logger.info "working with TaxonNameID = #{taxon_name_id} \n"

            get_otu_sf_above_id[taxon_name_id] = above_id
          end

          import.set('SFIllFormedNameIDToSFAboveID', get_otu_sf_above_id)

          puts 'SFIllFormedNameIDToSFAboveID'
          ap get_otu_sf_above_id
        end

        desc 'time rake tw:project_import:sf_import:taxa:create_sf_synonym_id_to_new_parent_id_hash user_id=1 data_directory=~/src/onedb2tw/working/'
        # also nomina nuda and dubia IDs to new parent.id hash
        LoggedTask.define create_sf_synonym_id_to_new_parent_id_hash: [:data_directory, :backup_directory, :environment, :user_id] do |logger|
          # Can be run independently at any time

          logger.info 'Running SF new synonym, nomen novum, nomen dubium parent hash...'

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          skipped_file_ids = import.get('SkippedFileIDs')

          get_sf_parent_id = {} # key = SF.TaxonNameID of synonym, value = SF.TaxonNameID of new parent

          path = @args[:data_directory] + 'sfSynonymParents.txt'
          # not a problem right now but eventually should change
          file = CSV.read(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

          file.each do |row|
            next if skipped_file_ids.include? row['FileID'].to_i
            # byebug
            # puts row.inspect
            taxon_name_id = row['TaxonNameID']
            logger.info "working with #{taxon_name_id} \n"
            get_sf_parent_id[taxon_name_id] = row['NewAboveID']
          end

          import.set('SFSynonymIDToSFParentID', get_sf_parent_id)

          puts 'SFSynonymIDToSFParentID'
          ap get_sf_parent_id

        end

        desc 'time rake tw:project_import:sf_import:taxa:create_animalia_below_root user_id=1 data_directory=~/src/onedb2tw/working/'
        # creates Animalia taxon name subordinate to each project Root (and make hash of project.id, animalia.id
        LoggedTask.define create_animalia_below_root: [:data_directory, :backup_directory, :environment, :user_id] do |logger|
          # Can be run independently at any time after projects created BUT not after animalia species created (must restore to before)

          # user = User.find_by_email('mbeckman@illinois.edu')
          # Current.user_id = user.id

          logger.info 'Running create_animalia_below_root...'

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          get_tw_project_id = import.get('SFFileIDToTWProjectID')

          get_animalia_id = {} # key = TW.project_id, value = TW.taxon_name_id = 'Animalia'

          get_tw_project_id.each_value do |project_id|

            this_project = Project.find(project_id)
            logger.info "working with project.id: #{project_id}, root_name: #{this_project.root_taxon_name.name}, root_name_id: #{this_project.root_taxon_name.id}"

            animalia_taxon_name = Protonym.new(
                name: 'Animalia',
                cached_html: 'Animalia',
                parent_id: this_project.root_taxon_name.id,
                rank_class: 'NomenclaturalRank::Iczn::HigherClassificationGroup::Kingdom',
                project_id: project_id,
            )

            if animalia_taxon_name.save
              get_animalia_id[project_id] = animalia_taxon_name.id.to_s # key (project_id) is integer, would prefer string
            end
          end

          import.set('ProjectIDToAnimaliaID', get_animalia_id)

          puts 'ProjectIDToAnimaliaID'
          ap get_animalia_id

        end

        desc 'time rake tw:project_import:sf_import:taxa:create_rank_hash user_id=1 data_directory=~/src/onedb2tw/working/'
        LoggedTask.define create_rank_hash: [:data_directory, :backup_directory, :environment, :user_id] do |logger|
          # Can be run independently at any time

          logger.info 'Running create_rank_hash...'

          get_tw_rank_string = {} # key = SF.RankID, value = TW.rank_string (Ranks.lookup(SF.Rank.Name))

          path = @args[:data_directory] + 'tblRanks.txt'
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

          file.each_with_index do |row, i|
            rank_id = row['RankID']
            next if ['90', '100'].include?(rank_id) # RankID = 0, "not specified", will = nil

            case rank_id.to_i
            when 11 then
              rank_name = 'subsuperspecies'
            when 12 then
              rank_name = 'superspecies'
            when 14 then
              rank_name = 'supersuperspecies'
            when 22 then
              rank_name = 'infratribe'
            when 39 then
              rank_name = 'supersubfamily'
            when 44 then
              rank_name = 'nanorder'
            when 45 then
              rank_name = 'parvorder'
            else
              rank_name = row['RankName']
            end

            get_tw_rank_string[rank_id] = Ranks.lookup(:iczn, rank_name)
          end

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          import.set('SFRankIDToTWRankString', get_tw_rank_string)

          puts = 'SFRankIDToTWRankString'
          ap get_tw_rank_string
        end

        desc 'time rake tw:project_import:sf_import:taxa:create_sf_taxa_misc_info user_id=1 data_directory=~/src/onedb2tw/working/'
        LoggedTask.define create_sf_taxa_misc_info: [:data_directory, :backup_directory, :environment, :user_id] do |logger|

          logger.info 'Running create_sf_taxa_misc_info...'

          get_sf_taxon_info = {} # key = SF.TaxonNameID, value = hash of SF.FileID, SF.RankID

          path = @args[:data_directory] + 'sfTaxaMiscInfo.txt'
          file = CSV.read(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

          file.each_with_index do |row, i|

            logger.info "Working with SF.TaxonNameID = '#{row['TaxonNameID']}', SF.FileID = '#{row['FileID']}', SF.RankID = '#{row['RankID']}' \n"

            get_sf_taxon_info[row['TaxonNameID']] = {file_id: row['FileID'], rank_id: row['RankID']}
          end

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          import.set('SFTaxonNameIDMiscInfo', get_sf_taxon_info)

          puts 'SFTaxonNameIDMiscInfo'
          ap get_sf_taxon_info
        end

      end
    end
  end
end




