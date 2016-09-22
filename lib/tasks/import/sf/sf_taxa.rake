namespace :tw do
  namespace :project_import do
    namespace :sf_import do
      require 'fileutils'
      require 'logged_task'
      namespace :taxa do

        desc 'time rake tw:project_import:sf_import:taxa:create_type_species user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        LoggedTask.define :create_type_species => [:data_directory, :environment, :user_id] do |logger|

          logger.info 'Creating type species...'

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          get_tw_user_id = import.get('SFFileUserIDToTWUserID') # for housekeeping
          get_tw_source_id = import.get('SFRefIDToTWSourceID')
          get_tw_taxon_name_id = import.get('SFTaxonNameIDToTWTaxonNameID')

          path = @args[:data_directory] + 'tblTypeSpecies.txt'
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'UTF-16:UTF-8')

          type_species_reason_hash = { '0' => 'unknown',
                                       '1' => 'Typification::Genus::Monotypy::Original',
                                       '2' => 'Typification::Genus::OriginalDesignation',
                                       '3' => 'Typification::Genus::SubsequentDesignation',
                                       '4' => 'Typification::Genus::Monotypy', # test if = '5', then add second reason 'original_designation' (= '3')
                                       '5' => 'Typification::Genus::Monotypy::Subsequent',
                                       '6' => 'Typification::Genus::Tautonomy::Absolute',
                                       '7' => 'Typification::Genus::Tautonomy::Linnaean',
                                       '8' => 'Typification::Genus::RulingByCommission',
                                       '9' => 'inherited from replaced name'
          }

          file.each_with_index do |row, i|

            genus_name_id = get_tw_taxon_name_id[row['GenusNameID']]  # is integer
            species_name_id = get_tw_taxon_name_id[row['SpeciesNameID']]
            reason = row['Reason']  # test if = '5', then add second reason 'original_designation' (= '3')
            authority_ref_id = get_tw_source_id[row['AuthorityRefID']]  # is string
            first_family_group_name_id = get_tw_taxon_name_id[row['FirstFamGrpNameID']]

            # Need project_id for each genus (for TaxonNameRelationship): can I query TaxonNames?

            TaxonNameRelationship.new
          end

        end


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

              # if taxon_name.save
              if taxon_name.valid?
                taxon_name.save!
                # logger.info "taxon_name.id = #{taxon_name.id}"
                get_tw_taxon_name_id[row['TaxonNameID']] = taxon_name.id.to_s
                get_sf_name_status[row['TaxonNameID']] = name_status
                get_sf_status_flags[row['TaxonNameID']] = status_flags

                # add taxon_name_classifications here


                # test if valid before save; if one of anticipated import errors, add classification, then try to save again...

                # Dmitry's code:
                # if taxon.valid?
                #   taxon.save!
                #   @data.taxon_index.merge!(row['Key'] => taxon.id)
                # else
                #   taxon.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::Unavailable::NotLatin') if taxon.rank_string =~ /Family/ && row['Status'] != '0' && !taxon.errors.messages[:name].blank?
                #   taxon.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::Unavailable::NotLatin') if taxon.rank_string =~ /Species/ && row['Status'] != '0' && taxon.errors.full_messages.include?('Name name must be lower case')
                #   taxon.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::Unavailable::NotLatin') if taxon.rank_string =~ /Species/ && row['Status'] != '0' && taxon.errors.full_messages.include?('Name Name must be latinized, no digits or spaces allowed')
                #   taxon.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::Unavailable::NotLatin') if taxon.rank_string =~ /Genus/ && row['Status'] != '0' && taxon.errors.full_messages.include?('Name Name must be latinized, no digits or spaces allowed')
                #
                #   if taxon.valid?
                #     taxon.save!
                #     @data.taxon_index.merge!(row['Key'] => taxon.id)
                #   else
                #     print "\n#{row['Key']}         #{row['Name']}"
                #     print "\n#{taxon.errors.full_messages}\n"
                #     #byebug
                #   end
                # end of Dmitry's code

                #
                # case taxon_name.errors.full_messages.include?
                # when 'Name name must end in -oidea', 'Name name must end in -idae', 'Name name must end in ini', 'Name name must end in -inae'
                # and row['NameStatus'] == '7'
                # taxon_name.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::Unavailable')

                #
                # when 'Name Name must be latinized, no digits or spaces allowed'
                # and row['NameStatus'] == '7'
                # taxon_name.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::NotLatin')

                # elsif row['NameStatus'] == '7' # make all NotLatin... Dmitry Add project_id
                #   # case taxon_name.errors.full_messages.include? # ArgumentError: wrong number of arguments (given 0, expected 1)
                #   #   when 'Name name must end in -oidea', 'Name name must end in -idae', 'Name name must end in ini', 'Name name must end in -inae'
                #   #     taxon_name.taxon_name_classifications.new(type: 'TaxonNameClassification::Iczn::Unavailable')
                #   #   when 'Name Name must be latinized, no digits or spaces allowed'
              else
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

              if taxon_name.valid?
                taxon_name.save! # taxon won't be saved if something wrong with classifications_attributes, read about !
                get_tw_taxon_name_id[row['TaxonNameID']] = taxon_name.id
                get_sf_name_status[row['TaxonNameID']] = name_status
                get_sf_status_flags[row['TaxonNameID']] = status_flags

              else
                logger.error "TaxonName ERROR (#{error_counter += 1}) AFTER synonym test (SF.TaxonNameID = #{taxon_name_id}, parent_id = #{parent_id}): " + taxon_name.errors.full_messages.join(';')
              end
            end
          end

          import.set('SFTaxonNameIDToTWTaxonNameID', get_tw_taxon_name_id)
          import.set('SFTaxonNameIDToSFNameStatus', get_sf_name_status)
          import.set('SFTaxonNameIDToSFStatusFlags', get_sf_status_flags)
          import.set('SFTaxonNameIDToTWOtuID', get_tw_otu_id)

          puts 'SFTaxonNameIDToTWTaxonNameID'
          ap get_tw_taxon_name_id
          puts 'SFTaxonNameIDToSFNameStatus'
          ap get_sf_name_status
          puts 'SFTaxonNameIDToSFStatusFlags'
          ap get_sf_status_flags
          puts 'SFTaxonNameIDToTWOtuID'
          ap get_tw_otu_id

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
                created_at: Time.now,
                updated_at: Time.now,
                created_by_id: $user_id,
                updated_by_id: $user_id
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




