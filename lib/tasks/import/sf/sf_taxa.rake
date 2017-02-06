namespace :tw do
  namespace :project_import do
    namespace :sf_import do
      require 'fileutils'
      require 'logged_task'
      namespace :taxa do

        desc 'time rake tw:project_import:sf_import:taxa:create_status_flag_relationships user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        #  real	~1 hour, 62.5 minutes, 256 errors (a little > 234 before today's changes)

        LoggedTask.define :create_status_flag_relationships => [:data_directory, :environment, :user_id] do |logger|

          logger.info 'Creating relationships from StatusFlags...'

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          # get_tw_user_id = import.get('SFFileUserIDToTWUserID') # for housekeeping
          get_tw_taxon_name_id = import.get('SFTaxonNameIDToTWTaxonNameID')
          get_tw_project_id = import.get('SFFileIDToTWProjectID')
          get_tw_otu_id = import.get('SFTaxonNameIDToTWOtuID')
          get_animalia_id = import.get('ProjectIDToAnimaliaID') # key = TW.Project.id, value TW.TaxonName.id where Name = 'Animalia', used when AboveID = 0

          # @todo: Temporary "fix" to convert all values to string; will be fixed next time taxon names are imported and following do can be deleted
          get_tw_taxon_name_id.each do |key, value|
            get_tw_taxon_name_id[key] = value.to_s
          end

          path = @args[:data_directory] + 'sfTaxaByTaxonNameStr.txt'
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

          count_found = 0
          error_counter = 0

          file.each_with_index do |row, i|
            next unless row['TaxonNameID'].to_i > 0
            next if get_tw_otu_id.has_key?(row['TaxonNameID']) # check if OTU was made
            next if row['TaxonNameStr'].start_with?('1100048-1143863') # name = MiscImages (body parts)
            next if row['RankID'] == '90' # TaxonNameID = 1221948, Name = Deletable, RankID = 90 == Life, FileID = 1
            next if row['AccessCode'].to_i == 4

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
                    type = 'TaxonNameRelationship::Iczn::Invalidating::Usage::Misapplication'
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

                # tnr = TaxonNameRelationship.where(subject_taxon_name_id: above_id,
                #                                   object_taxon_name_id: taxon_name_id,
                #                                   type: type,
                #                                   project_id: project_id)
                #
                # tnr = TaxonNameRelationship.new(
                #     subject_taxon_name_id: above_id,
                #     object_taxon_name_id: taxon_name_id,
                #     type: type,
                #     project_id: project_id
                # )  if tnr.nil?

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

        desc 'time rake tw:project_import:sf_import:taxa:create_some_related_taxa user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        LoggedTask.define :create_some_related_taxa => [:data_directory, :environment, :user_id] do |logger|
          # 45 errors, 2.5 minutes

          logger.info 'Creating some related taxa (from tblRelatedTaxa)...'

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          get_tw_user_id = import.get('SFFileUserIDToTWUserID') # for housekeeping
          get_tw_taxon_name_id = import.get('SFTaxonNameIDToTWTaxonNameID')
          # get_tw_otu_id = import.get('SFTaxonNameIDToTWOtuID')

          # @todo: Temporary "fix" to convert all values to string; will be fixed next time taxon names are imported and following do can be deleted
          get_tw_taxon_name_id.each do |key, value|
            get_tw_taxon_name_id[key] = value.to_s
          end

          path = @args[:data_directory] + 'tblRelatedTaxa.txt'
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'UTF-16:UTF-8')

          count_found = 0
          error_counter = 0
          suppressed_counter = 0

          file.each_with_index do |row, i|
            # next if get_tw_otu_id.has_key?(row['FamilyNameID']) # ignore if ill-formed family name created only as OTU

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

            if !tnr.try(:id).nil?
              # tnr.save!
              puts 'TaxonNameRelationship created or already existed'

            else # tnr not valid
              logger.error "TaxonNameRelationship tblRelatedTaxa ERROR tw.project_id #{project_id}, SF.OlderNameID #{row['OlderNameID']} = tw.object_name_id #{object_name_id} (#{error_counter += 1}): " + tnr.errors.full_messages.join(';')
            end
          end
        end

        desc 'time rake tw:project_import:sf_import:taxa:create_type_genera user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        LoggedTask.define :create_type_genera => [:data_directory, :environment, :user_id] do |logger|

          logger.info 'Creating type genera...'

          # Four family names suppressed (Beckmaninae, etc.)
          # About 100 family names not compatible with type genus relationship, mostly genus group names (see log)

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          get_tw_user_id = import.get('SFFileUserIDToTWUserID') # for housekeeping
          get_tw_taxon_name_id = import.get('SFTaxonNameIDToTWTaxonNameID')
          get_tw_otu_id = import.get('SFTaxonNameIDToTWOtuID')

          # @todo: Temporary "fix" to convert all values to string; will be fixed next time taxon names are imported and following do can be deleted
          get_tw_taxon_name_id.each do |key, value|
            get_tw_taxon_name_id[key] = value.to_s
          end

          path = @args[:data_directory] + 'tblTypeGenera.txt'
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'UTF-16:UTF-8')

          count_found = 0
          error_counter = 0

          file.each_with_index do |row, i|
            next if get_tw_otu_id.has_key?(row['FamilyNameID']) # ignore if ill-formed family name created only as OTU

            genus_name_id = get_tw_taxon_name_id[row['GenusNameID']].to_i
            family_name_id = get_tw_taxon_name_id[row['FamilyNameID']].to_i

            if family_name_id == 0
              logger.error "TaxonNameRelationship SUPPRESSED family name SF.TaxonNameID = #{row['FamilyNameID']}"
              next
            end

            # project_id = TaxonName.where(id: genus_name_id ).pluck(:project_id).first vs. TaxonName.find(genus_name_id).project_id
            project_id = TaxonName.find(family_name_id).project_id

            logger.info "Working with TW.project_id: #{project_id}, SF.FamilyNameID #{row['FamilyNameID']} = TW.FamilyNameID #{family_name_id}, SF.GenusNameID #{row['GenusNameID']} = TW.GenusNameID #{genus_name_id} (count #{count_found += 1}) \n"

            tnr = TaxonNameRelationship.new(
                subject_taxon_name_id: genus_name_id,
                object_taxon_name_id: family_name_id,
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
              logger.error "TaxonNameRelationship ERROR TW.taxon_name_id #{family_name_id} (#{error_counter += 1}): " + tnr.errors.full_messages.join(';')
            end
          end
        end

        desc 'time rake tw:project_import:sf_import:taxa:create_type_species user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        LoggedTask.define :create_type_species => [:data_directory, :environment, :user_id] do |logger|

          logger.info 'Creating type species...'

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          get_tw_user_id = import.get('SFFileUserIDToTWUserID') # for housekeeping
          get_tw_source_id = import.get('SFRefIDToTWSourceID')
          get_tw_taxon_name_id = import.get('SFTaxonNameIDToTWTaxonNameID')

          # @todo: Temporary "fix" to convert all values to string; will be fixed next time taxon names are imported and following do can be deleted
          get_tw_taxon_name_id.each do |key, value|
            get_tw_taxon_name_id[key] = value.to_s
          end

          path = @args[:data_directory] + 'tblTypeSpecies.txt'
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'UTF-16:UTF-8')

          type_species_reason_hash = {'0' => 'TaxonNameRelationship::Typification::Genus', # unknown
                                      '1' => 'TaxonNameRelationship::Typification::Genus::Monotypy::Original',
                                      '2' => 'TaxonNameRelationship::Typification::Genus::OriginalDesignation',
                                      '3' => 'TaxonNameRelationship::Typification::Genus::SubsequentDesignation',
                                      '4' => 'TaxonNameRelationship::Typification::Genus::OriginalDesignation', # was monotypy and original designation, OriginalDesignation has priority per Dmitry, make note about SF value
                                      '5' => 'TaxonNameRelationship::Typification::Genus::Monotypy::Subsequent',
                                      '6' => 'TaxonNameRelationship::Typification::Genus::Tautonomy::Absolute',
                                      '7' => 'TaxonNameRelationship::Typification::Genus::Tautonomy::Linnaean',
                                      '8' => 'TaxonNameRelationship::Typification::Genus::RulingByCommission',
                                      '9' => 'TaxonNameRelationship::Typification::Genus' # inherited from replaced name
          }

          count_found = 0
          error_counter = 0
          no_species_counter = 0
          no_genus_counter = 0

          file.each_with_index do |row, i|
            next if row['SpeciesNameID'] == '0'
            next if [1143402, 1143425, 1143430, 1143432, 1143436].freeze.include?(row['GenusNameID'].to_i) # used for excluded Beckma ids
            next if [1109922, 1195997, 1198855].freeze.include?(row['GenusNameID'].to_i) # bad data in Orthoptera (first) and Psocodea (rest)

            # @todo: SF TaxonNameID pairs must be manually fixed: 1132639/1132641 (Orthoptera) and 1184619/1184569 (Mantodea)
            # @todo: 18 sources not found (see log)

            genus_name_id = get_tw_taxon_name_id[row['GenusNameID']].to_i

            if genus_name_id == 0
              logger.error "TaxonNameRelationship ERROR SF.GenusNameID #{row['GenusNameID']} (#{no_genus_counter += 1}): NO TW GENUS"
              next
            end

            species_name_id = get_tw_taxon_name_id[row['SpeciesNameID']].to_i

            reason = row['Reason'] # test if = '4' to add note after; if reason = 9, make note in SF it is inherited from replaced name
            authority_ref_id = get_tw_source_id[row['AuthorityRefID']] # is string
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

              if row['AuthorityRefID'].to_i > 0 # 20 out of 1924 sources not found
                tnr_cit = tnr.citations.new(source_id: authority_ref_id,
                                            project_id: project_id)
                begin
                  tnr_cit.save!
                  puts 'Citation created'
                rescue ActiveRecord::RecordInvalid # tnr_cit not valid
                  logger.error "TaxonNameRelationship citation ERROR TW.taxon_name_id #{genus_name_id} (#{error_counter += 1}): " + tnr_cit.errors.full_messages.join(';')
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
        # ### time rake tw:project_import:sf_taxa:try_logger user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/
        # LoggedTask.define :try_logger => [:data_directory, :environment, :user_id] do |logger|
        #   logger.info "This is :try_logger"
        #   logger.warn "This is a logger warning"
        #   logger.error "This is a big bad nasty error message"
        # end
        ### ---------------------------------------------------------------------------------------------------------------------------------------------


        desc 'time rake tw:project_import:sf_import:taxa:create_all_sf_taxa_pass1 user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        LoggedTask.define :create_all_sf_taxa_pass1 => [:data_directory, :environment, :user_id] do |logger|

          logger.info 'Creating all SF taxa (pass 1)...'

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          get_tw_user_id = import.get('SFFileUserIDToTWUserID') # for housekeeping
          get_tw_rank_string = import.get('SFRankIDToTWRankString')
          get_tw_source_id = import.get('SFRefIDToTWSourceID')
          get_tw_project_id = import.get('SFFileIDToTWProjectID')
          get_animalia_id = import.get('ProjectIDToAnimaliaID') # key = TW.Project.id, value TW.TaxonName.id where Name = 'Animalia', used when AboveID = 0
          get_sf_parent_id = import.get('SFSynonymIDToSFParentID')
          get_otu_sf_above_id = import.get('SFIllFormedNameIDToSFAboveID')
          # get_sf_new_parent_id = import.get('SFSubordinateIDToSFNewParentID')

          get_tw_taxon_name_id = {} # key = SF.TaxonNameID, value = TW.taxon_name.id
          get_sf_name_status = {} # key = SF.TaxonNameID, value = SF.NameStatus
          get_sf_status_flags = {} # key = SF.TaxonNameID, value = SF.StatusFlags
          get_tw_otu_id = {} # key = SF.TaxonNameID, value = TW.otu.id; used for temporary or bad valid SF taxa
          get_taxon_name_otu_id = {}  # key = TW.TaxonName.id, value TW.OTU.id just created for newly added taxon_name

          project_id = 1 # default value, will be updated before keyword is used
          keyword = Keyword.find_or_create_by(
              name: 'Taxon name validation failed', definition: 'Taxon name validation failed', project_id: project_id)

          path = @args[:data_directory] + 'sfTaxaByTaxonNameStr.txt'
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

          error_counter = 0
          count_found = 0
          no_parent_counter = 0

          file.each_with_index do |row, i|

            taxon_name_id = row['TaxonNameID']
            next unless taxon_name_id.to_i > 0
            next if row['TaxonNameStr'].start_with?('1100048-1143863') # name = MiscImages (body parts)
            next if row['RankID'] == '90' # TaxonNameID = 1221948, Name = Deletable, RankID = 90 == Life, FileID = 1
            next if row['AccessCode'].to_i == 4

            project_id = get_tw_project_id[row['FileID']]

            logger.info "Working with TW.project_id: #{project_id} = SF.FileID #{row['FileID']}, SF.TaxonNameID #{taxon_name_id} (count #{count_found += 1}) \n"

            animalia_id = get_animalia_id[project_id.to_s]

            if row['AboveID'] == '0' # must check AboveID = 0 before synonym
              parent_id = animalia_id
            elsif row['NameStatus'] == '7' # = synonym; MUST handle synonym parent before BadValidName (because latter doesn't treat synonym parents)
              # new synonym parent id could be = 0 if RankID bubbles up to top
              # logger.info "get_sf_parent_id[taxon_name_id] = #{get_sf_parent_id[taxon_name_id]}, taxon_name_id.class = #{taxon_name_id.class}"
              if get_sf_parent_id[taxon_name_id.to_s] == '0' # use animalia_id
                parent_id = animalia_id
              else
                parent_id = get_tw_taxon_name_id[get_sf_parent_id[taxon_name_id]] # assumes tw_taxon_name_id exists
              end
            elsif get_otu_sf_above_id.has_key?(taxon_name_id) # ill-formed sf taxon name, will make OTU
              parent_id = get_tw_taxon_name_id[get_otu_sf_above_id[taxon_name_id]]
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
              logger.warn "ALERT: Could not find parent_id of SF.TaxonNameID = #{taxon_name_id} (error #{no_parent_counter += 1})! Set to animalia_id = #{animalia_id}"
              parent_id = animalia_id # this is problematic; need real solution
            end

            name_status = row['NameStatus']
            status_flags = row['StatusFlags']

            # if name_status == '2' or get_otu_sf_above_id.has_key?(taxon_name_id) # temporary, create OTU, not TaxonName
            if get_otu_sf_above_id.has_key?(taxon_name_id) # temporary, create OTU, not TaxonName
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
                logger.info "Note!! Created OTU for temporary or ill-formed taxon SF.TaxonNameID = #{taxon_name_id}, otu.id = #{otu.id}"
                get_tw_otu_id[row['TaxonNameID']] = otu.id.to_s
                get_sf_name_status[row['TaxonNameID']] = name_status
                get_sf_status_flags[row['TaxonNameID']] = status_flags

              else
                logger.error "OTU ERROR (#{error_counter += 1}) for SF.TaxonNameID = #{taxon_name_id}: " + otu.errors.full_messages.join(';')
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


              begin
                taxon_name.save!
                # logger.info "taxon_name.id = #{taxon_name.id}"
              #  get_tw_taxon_name_id[row['TaxonNameID']] = taxon_name.id.to_s
              #  get_sf_name_status[row['TaxonNameID']] = name_status
              #  get_sf_status_flags[row['TaxonNameID']] = status_flags
              #  get_taxon_name_otu_id[taxon_name.id.to_s] = taxon_name.otus.last.id.to_s

                  # if one of anticipated import errors, add classification, then try to save again...
              rescue ActiveRecord::RecordInvalid
                taxon_name.taxon_name_classifications.new(
                    type: 'TaxonNameClassification::Iczn::Unavailable::NotLatin',
                    project_id: project_id,
                    created_at: row['CreatedOn'],
                    updated_at: row['LastUpdate'],
                    created_by_id: get_tw_user_id[row['CreatedBy']],
                    updated_by_id: get_tw_user_id[row['ModifiedBy']])

                taxon_name.tags.new(keyword: keyword,
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

                # taxon_name.save! # taxon won't be saved if something wrong with classifications_attributes, read about !
                # @todo: Make sure get_tw_taxon_name_id.value is string
                get_tw_taxon_name_id[row['TaxonNameID']] = taxon_name.id.to_s # original import made this an integer
                get_sf_name_status[row['TaxonNameID']] = name_status
                get_sf_status_flags[row['TaxonNameID']] = status_flags
                get_taxon_name_otu_id[taxon_name.id.to_s] = taxon_name.otus.last.id.to_s

              rescue ActiveRecord::RecordInvalid
                logger.error "TaxonName ERROR (#{error_counter += 1}) AFTER synonym test (SF.TaxonNameID = #{taxon_name_id}, parent_id = #{parent_id}): " + taxon_name.errors.full_messages.join(';')
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

        desc 'time rake tw:project_import:sf_import:taxa:create_otus_for_ill_formed_names_hash user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        LoggedTask.define :create_otus_for_ill_formed_names_hash => [:data_directory, :environment, :user_id] do |logger|
          # Can be run independently at any time

          logger.info 'Running create otus for ill-formed names hash...'

          get_otu_sf_above_id = {} # key = SF.TaxonNameID of bad valid name, value = SF.AboveID of bad valid name

          path = @args[:data_directory] + 'sfMakeOTUs.txt'
          file = CSV.read(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

          file.each do |row|
            # byebug
            # puts row.inspect
            taxon_name_id = row['TaxonNameID']
            above_id = row['AboveID']
            logger.info "working with TaxonNameID = #{taxon_name_id} \n"

            get_otu_sf_above_id[taxon_name_id] = above_id
          end

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          import.set('SFIllFormedNameIDToSFAboveID', get_otu_sf_above_id)

          puts 'SFIllFormedNameIDToSFAboveID'
          ap get_otu_sf_above_id

        end

        desc 'time rake tw:project_import:sf_import:taxa:create_sf_synonym_id_to_new_parent_id_hash user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        # also nomina nuda and dubia IDs to new parent.id hash
        LoggedTask.define :create_sf_synonym_id_to_new_parent_id_hash => [:data_directory, :environment, :user_id] do |logger|
          # Can be run independently at any time

          logger.info 'Running SF new synonym, nomen novum, nomen dubium parent hash...'

          get_sf_parent_id = {} # key = SF.TaxonNameID of synonym, value = SF.TaxonNameID of new parent

          path = @args[:data_directory] + 'sfSynonymParents.txt'
          file = CSV.read(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

          file.each do |row|
            # byebug
            # puts row.inspect
            taxon_name_id = row['TaxonNameID']
            logger.info "working with #{taxon_name_id} \n"
            get_sf_parent_id[taxon_name_id] = row['NewAboveID']
          end

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          import.set('SFSynonymIDToSFParentID', get_sf_parent_id)

          puts 'SFSynonymIDToSFParentID'
          ap get_sf_parent_id

        end

        desc 'time rake tw:project_import:sf_import:taxa:create_animalia_below_root user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        # creates Animalia taxon name subordinate to each project Root (and make hash of project.id, animalia.id
        LoggedTask.define :create_animalia_below_root => [:data_directory, :environment, :user_id] do |logger|
          # Can be run independently at any time after projects created BUT not after animalia species created (must restore to before)

          logger.info 'Running create_animalia_below_root...'

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          get_tw_project_id = import.get('SFFileIDToTWProjectID')

          get_animalia_id = {} # key = TW.project_id, value = TW.taxon_name_id = 'Animalia'

          get_tw_project_id.values.each do |project_id|

            this_project = Project.find(project_id)
            logger.info "working with project.id: #{project_id}, root_name: #{this_project.root_taxon_name.name}, root_name_id: #{this_project.root_taxon_name.id}"

            animalia_taxon_name = Protonym.new(
                name: 'Animalia',
                parent_id: this_project.root_taxon_name.id,
                rank_class: NomenclaturalRank::Iczn::HigherClassificationGroup::Kingdom,
                project_id: project_id,
            )

            if animalia_taxon_name.save
              get_animalia_id[project_id] = animalia_taxon_name.id.to_s # key (project_id) is integer, would prefer string
            end
          end

          import.set('ProjectIDToAnimaliaID', get_animalia_id)

          puts "ProjectIDToAnimaliaID"
          ap get_animalia_id

        end

        desc 'time rake tw:project_import:sf_import:taxa:create_rank_hash user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        LoggedTask.define :create_rank_hash => [:data_directory, :environment, :user_id] do |logger|
          # Can be run independently at any time

          logger.info 'Running create_rank_hash...'

          get_tw_rank_string = {} # key = SF.RankID, value = TW.rank_string (Ranks.lookup(SF.Rank.Name))

          path = @args[:data_directory] + 'tblRanks.txt'
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'UTF-16:UTF-8')

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
                rank_name = 'supergenus'
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


      end
    end
  end
end




