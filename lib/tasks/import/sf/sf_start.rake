namespace :tw do
  namespace :project_import do
    namespace :sf_import do
      require 'fileutils'
      require 'logged_task'
      namespace :start do

        # Anyone who runs these tasks:  Substitute your id as user_id, not user_id=1
        # check out default user_id if SF.FileUserID < 1 (indicates change was made programmatically)

        desc 'time rake tw:project_import:sf_import:start:create_source_roles user_id=1 data_directory=~/src/onedb2tw/working/'
        LoggedTask.define create_source_roles: [:data_directory, :backup_directory, :environment, :user_id] do |logger|

          logger.info 'Running create_source_roles...'

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          skipped_file_ids = import.get('SkippedFileIDs')
          get_tw_person_id = import.get('SFPersonIDToTWPersonID')
          get_tw_source_id = import.get('SFRefIDToTWSourceID')
          get_tw_user_id = import.get('SFFileUserIDToTWUserID') # for housekeeping

          ref_id_containing_id_hash = import.get('RefIDContainingHash')
          ref_file_id = import.get('RefIDsByFileID')
          ref_id_editor_array = import.get('RefIDEditorArray') # author as editor if RefID is in array

          ref_taxon_name_authors = {} # key = SF.RefID (contained ref), value = array of SF.Person.IDs (ordered); only contains ref in ref taxon_name_authors

          path = @args[:data_directory] + 'sfRefAuthorsOrdered.txt'
          file = CSV.read(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

          previous_ref_id = '0'
          person_error_counter = 0
          source_nil_counter = 0
          tw_person_nil_counter = 0
          in_ref_counter = 0

          ##### Newest logic
          # If containing_ref_is == "0"
          #   create role for person
          #   if author acted as editor
          #     create editor role for person
          # else has containing_ref_id
          #   create taxon_name_author hash (test for same ref_id or new ref_id)

          file.each_with_index do |row, i|
            ref_id = row['RefID']
            next if skipped_file_ids.include? ref_file_id[ref_id].to_i

            sf_person_id = row['PersonID']
            tw_person_id = get_tw_person_id[sf_person_id]
            if tw_person_id.nil?
              logger.error "Missing person ERROR: SF.PersonID = #{sf_person_id} (person_nil_counter = #{tw_person_nil_counter += 1})"
              next
            end

            logger.info "working with SF.RefID = #{ref_id}, SF.PersonID = #{sf_person_id}, TW.person_id = #{tw_person_id}, position = #{row['SeqNum']} \n"


            if ref_id_containing_id_hash[ref_id].nil? # only executed if simple ref (no ref in ref)

              source_id = get_tw_source_id[ref_id]
              if source_id.nil?
                logger.error "Missing source ERROR: SF.RefID = #{ref_id} (source_nil_counter = #{source_nil_counter += 1})"
                next
              end

              logger.info "working with TW.source_id = #{source_id} \n"

              role = Role.new(
                  person_id: tw_person_id,
                  type: 'SourceAuthor',
                  role_object_id: source_id,
                  role_object_type: 'Source',
                  created_at: row['CreatedOn'],
                  updated_at: row['LastUpdate'],
                  created_by_id: get_tw_user_id[row['CreatedBy']],
                  updated_by_id: get_tw_user_id[row['ModifiedBy']]
              )

              begin
                role.save!
              rescue ActiveRecord::RecordInvalid
                logger.error "SourceAuthor role ERROR (#{person_error_counter += 1}): " + role.errors.full_messages.join(';')
              end

              if ref_id_editor_array.include? ref_id # person is also editor
                role = Role.new(
                    person_id: tw_person_id,
                    type: 'SourceEditor',
                    role_object_id: source_id,
                    role_object_type: 'Source',
                    created_at: row['CreatedOn'],
                    updated_at: row['LastUpdate'],
                    created_by_id: get_tw_user_id[row['CreatedBy']],
                    updated_by_id: get_tw_user_id[row['ModifiedBy']]
                )

                begin
                  role.save!
                rescue ActiveRecord::RecordInvalid
                  logger.error "SourceEditor role ERROR (#{person_error_counter += 1}): " + role.errors.full_messages.join(';')
                end
              end

            else # only executed if ref in ref
              # byebug

              logger.info "processing ref in ref, in-ref counter = #{in_ref_counter += 1} \n"

              if ref_id == previous_ref_id # this is the same RefID as last row, add another author
                ref_taxon_name_authors[ref_id].push(sf_person_id)

              else # this is a new RefID, start a new author array
                ref_taxon_name_authors[ref_id] = [sf_person_id]
              end
            end

            previous_ref_id = ref_id
          end

          import.set('SFRefIDToTaxonNameAuthors', ref_taxon_name_authors)

          puts 'SFRefIDToTaxonNameAuthors'
          ap ref_taxon_name_authors
        end

        desc 'time rake tw:project_import:sf_import:start:create_sf_family_group_related_info user_id=1 data_directory=~/src/onedb2tw/working/'
        LoggedTask.define create_sf_family_group_related_info: [:data_directory, :backup_directory, :environment, :user_id] do |logger|

          logger.info 'Running create_sf_family_group_related_info...'

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          skipped_file_ids = import.get('SkippedFileIDs')
          excluded_taxa = import.get('ExcludedTaxa')

          family_group_related_info = {} # key = SF.TaxonNameID, value = { FileID, RankID, Name (family group), FirstUseRefID, TypeGenusID, FirstFamGrpNameID, FamilyAuthorRefID }

          path = @args[:data_directory] + 'sfFamilyGroupRelatedInfo.txt'
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

          file.each_with_index do |row, i|
            puts "TaxonNameID = #{row['TaxonNameID']}"
            sf_file_id = row['FileID']
            next if skipped_file_ids.include? row['FileID'].to_i
            sf_taxon_name_id = row['TaxonNameID']
            next if excluded_taxa.include? sf_taxon_name_id

            logger.info "working with TaxonNameID #{sf_taxon_name_id}"

            family_group_related_info[sf_taxon_name_id] = {sf_file_id: sf_file_id, rank_id: row['RankID'], family_name: row['Name'],
                                                           first_use_ref_id: row['FirstUseRefID'], type_genus_id: row['TypeGenusID'],
                                                           first_fam_grp_name_id: row['FirstFamGrpNameID'], family_author_ref_id: row['FamilyAuthorRefID']}
          end

          import.set('SFFamilyGroupRelatedInfo', family_group_related_info)

          puts 'SFFamilyGroupRelatedInfo'
          ap family_group_related_info
        end

        desc 'time rake tw:project_import:sf_import:start:list_excluded_taxa user_id=1 data_directory=~/src/onedb2tw/working/'
        LoggedTask.define list_excluded_taxa: [:data_directory, :backup_directory, :environment, :user_id] do |logger|

          logger.info 'Running list_excluded_taxa...'

          excluded_taxa = [] # list of taxa with AccessCode = 4, TaxonNameID = 0, those used for anatomy, known errors, bad ranks, assorted others

          path = @args[:data_directory] + 'sfExcludedTaxa.txt'
          file = CSV.read(path, col_sep: "\r", headers: true, encoding: 'BOM|UTF-8')
          # file = CSV.read(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

          file.each_with_index do |row|
            excluded_taxa.push(row['TaxonNameID'])
          end

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          import.set('ExcludedTaxa', excluded_taxa)

          puts 'ExcludedTaxa'
          ap excluded_taxa
        end

        desc 'time rake tw:project_import:sf_import:start:create_misc_ref_info user_id=1 data_directory=~/src/onedb2tw/working/'
        # via tblRefs
        LoggedTask.define create_misc_ref_info: [:data_directory, :backup_directory, :environment, :user_id] do |logger|

          logger.info 'Running create_misc_ref_info...'

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          skipped_file_ids = import.get('SkippedFileIDs')
          get_tw_source_id = import.get('SFRefIDToTWSourceID')

          ref_id_editor_array = []
          ref_id_containing_id_hash = {} # key = RefID, value = ContainingRefID
          ref_id_pub_id_hash = {} # key = RefID, value = PubID
          ref_file_id = {} # key = SF.RefID, value = SF.FileID

          # Part I: a) Create array of refs with editor flag set
          #         b) Create hash of refs with containing refs NOTE: Only includes those with ContainingRefIDs > 0
          #         c) Create hash of SF.RefID to SF.PubID
          path = @args[:data_directory] + 'tblRefs.txt'
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

          file.each do |row|
            next if skipped_file_ids.include? row['FileID'].to_i or get_tw_source_id[row['RefID']]
            ref_id = row['RefID']
            containing_ref_id = row['ContainingRefID']
            pub_id = row['PubID']

            logger.info "working with SF.RefID = #{ref_id}, SF.ContainingRefID = #{row['ContainingRefID']}, flags = #{row['Flags']} \n"

            ref_id_editor_array.push(ref_id) if row['Flags'].to_i & 2 == 2 # is_editor
            # TODO: This might not be dealing with refs contained in contained refs.
            ref_id_containing_id_hash[ref_id] = containing_ref_id if containing_ref_id != '0'
            ref_id_pub_id_hash[ref_id] = pub_id
          end

          # Part II: Create hash of RefID and FileID
          path = @args[:data_directory] + 'sfRefIDsByFileID.txt'
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

          file.each do |row|
            ref_file_id[row['RefID']] = row['FileID']
          end

          import.set('RefIDEditorArray', ref_id_editor_array)
          import.set('RefIDContainingHash', ref_id_containing_id_hash)
          import.set('RefIDPubIDHash', ref_id_pub_id_hash)
          import.set('RefIDsByFileID', ref_file_id)

          puts 'RefIDEditorArray'
          ap ref_id_editor_array

          puts 'RefIDContainingHash'
          ap ref_id_containing_id_hash

          puts 'RefIDPubIDHash'
          ap ref_id_pub_id_hash

          puts 'RefIDsByFileID'
          ap ref_file_id
        end


        desc 'time rake tw:project_import:sf_import:start:create_sources user_id=1 data_directory=~/src/onedb2tw/working/'
        LoggedTask.define create_sources: [:data_directory, :backup_directory, :environment, :user_id] do |logger|
          # @todo: See :create_sf_book_hash and :update_sources_with_book_info above. Should be incorporated here.

          logger.info 'Running create_sources...'

=begin  Old logic
          # tblRefs columns to import: Title, PubID, Series, Volume, Issue, RefPages, ActualYear, StatedYear, LinkID, LastUpdate, ModifiedBy, CreatedOn, CreatedBy
          # tblRefs other columns: RefID => Source.identifier, FileID => used when creating ProjectSources, ContainingRefID => sfVerbatimRefs contains full
          #   RefStrings attached as data_attributes in ProjectSources (no need for ContainingRefID), AccessCode => n/a, Flags => identifies editor
          #   (use when creating roles and generating author string from tblRefAuthors), Note => attach to ProjectSources, CiteDataStatus => can be derived,
          #   Verbatim => not used
=end

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          skipped_file_ids = import.get('SkippedFileIDs')
          get_tw_user_id = import.get('SFFileUserIDToTWUserID') # for housekeeping
          get_tw_serial_id = import.get('SFPubIDToTWSerialID') # for FK
          get_sf_ref_link = import.get('RefIDToRefLink') # key is SF.RefID, value is URL string
          get_sf_verbatim_ref = import.get('RefIDToVerbatimRef') # key is SF.RefID, value is verbatim string
          get_tw_project_id = import.get('SFFileIDToTWProjectID')
          get_sf_booktitle_publisher_address = import.get('SFPubIDTitlePublisherAddress') # key = SF.PubID, value = hash of booktitle, publisher, address
          get_sf_pub_type_string = import.get('SFPubIDToPubTypeString')
          # get_contained_cite_aux_data = import.get('SFContainedCiteAuxData')

          get_tw_source_id = {} # key = SF.RefID, value = TW.source_id
          get_containing_source_id = {} # key = TW.contained_source_id, value = TW.containing_source_id # use for containing auths/eds
          # byebug

          # Namespace for Identifier
          # source_namespace = Namespace.find_or_create_by(institution: 'Species File', name: 'tblRefs', short_name: 'SF RefID')

          count_found = 0
          error_counter = 0
          contained_error_counter = 0
          source_not_found_error = 0

          path = @args[:data_directory] + 'tblRefs.txt'
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

          skipped_ref_ids = []

          file.each_with_index do |row, i|
            # break if i == 20
            ref_id = row['RefID']

            skipped_ref_ids.push ref_id
            next if skipped_file_ids.include? row['FileID'].to_i
            next if row['ContainingRefID'].to_i > 0 # Only create sources for standalone refs
            next if (row['Title'].empty? and row['PubID'] == '0' and row['Series'].empty? and row['Volume'].empty? and row['Issue'].empty? and row['ActualYear'].empty? and row['StatedYear'].empty?) or row['AccessCode'] == '4'
            skipped_ref_ids.pop

            logger.info "working with SF.RefID = #{ref_id}, SF.FileID = #{row['FileID']} (count = #{count_found += 1}) \n"

            pub_id = row['PubID']
            pub_type_string = get_sf_pub_type_string[pub_id]

            booktitle = nil
            publisher = nil
            address = nil

            if get_sf_booktitle_publisher_address[pub_id]
              booktitle = get_sf_booktitle_publisher_address[pub_id]['booktitle']
              publisher = get_sf_booktitle_publisher_address[pub_id]['publisher']
              address = get_sf_booktitle_publisher_address[pub_id]['address']
            end

            # if year range, select min year (record full verbatim ref as data attribute after save)
            actual_year = row['ActualYear'].split('-').map(&:to_i).min
            stated_year = row['StatedYear'].split('-').map(&:to_i).min

            source = Source::Bibtex.new(
                bibtex_type: pub_type_string,
                title: row['Title'],
                booktitle: booktitle.blank? ? nil : booktitle,
                publisher: publisher.blank? ? nil : publisher,
                address: address.blank? ? nil : address,
                serial_id: get_tw_serial_id[pub_id],
                series: row['Series'],
                volume: row['Volume'],
                number: row['Issue'],
                pages: row['RefPages'],
                year: actual_year,
                stated_year: stated_year,
                url: row['LinkID'].to_i > 0 ? get_sf_ref_link[ref_id] : nil,
                created_at: row['CreatedOn'],
                updated_at: row['LastUpdate'],
                created_by_id: get_tw_user_id[row['CreatedBy']],
                updated_by_id: get_tw_user_id[row['ModifiedBy']]
            )

            begin
              source.save!
              source.data_attributes.create!(type: 'ImportAttribute', project_id: get_tw_project_id[row['FileID']], import_predicate: 'SF.RefID', value: ref_id)

              puts "RefID = #{ref_id}, PubID = #{pub_id}, serial_id = #{get_tw_serial_id[pub_id]}"

              if row['ActualYear'].include?('-') or row['StatedYear'].include?('-')
                source.data_attributes.create!(type: 'ImportAttribute', project_id: get_tw_project_id[row['FileID']], import_predicate: 'SF verbatim reference for year range', value: get_sf_verbatim_ref[ref_id])
              end

              if pub_type_string == 'unpublished'
                source.data_attributes.create!(type: 'ImportAttribute', project_id: get_tw_project_id[row['FileID']], import_predicate: 'SF verbatim reference for unpublished reference', value: get_sf_verbatim_ref[ref_id])
              end

              source_id = source.id.to_s
              get_tw_source_id[ref_id] = source_id

              ProjectSource.create!(
                  project_id: get_tw_project_id[row['FileID']],
                  source_id: source.id,
                  created_at: row['CreatedOn'],
                  updated_at: row['LastUpdate'],
                  created_by_id: get_tw_user_id[row['CreatedBy']],
                  updated_by_id: get_tw_user_id[row['ModifiedBy']]
              )

            rescue ActiveRecord::RecordInvalid
              logger.info "Source ERROR (#{error_counter += 1}): " + source.errors.full_messages.join(';')
                # @todo Not found: Slater, J.A. Date unknown. A Catalogue of the Lygaeidae of the world. << RefID = 44058, PubID = 21898
            rescue StandardError => e
              # byebug
              puts "Rescued: #{e.inspect}"
            rescue AnotherError => e
              # byebug
              puts "Rescued, but with a different block: #{e.inspect}"
            end

          end




          ##### Second Ref loop: Create sources for SF.tblRefs.ContainingRefID > 0
          # skip if get_contained_cite_aux_data[sf_ref_id] -- do not create this source stub

          file.each_with_index do |row, i|
            next if row['ContainingRefID'].to_i == 0 # Creating only contained references in this pass
            next if row['Title'].blank? or row['AccessCode'] == '4'
            # next if get_contained_cite_aux_data[row['RefID']] # if get_contained_cite_aux_data[sf_ref_id] is true, this is a taxon author, not chapter author

            ref_id = row['RefID']
            containing_ref_id = row['ContainingRefID']
            containing_source_id = get_tw_source_id[containing_ref_id]

            logger.info "working with contained SF.RefID = #{ref_id}, SF.ContainingRefID = #{containing_ref_id}, tw.containing_source_id = #{containing_source_id}, SF.FileID = #{row['FileID']} (count = #{count_found += 1}) \n"

            begin
              containing_source = Source.find(containing_source_id)
            rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound
              logger.error "Source ERROR: containing source not found for RefID = #{ref_id} (source not found = #{source_not_found_error += 1})"
              next
            end

            if containing_source.bibtex_type == 'book'
              pub_type_string = 'inbook'
            else
              pub_type_string = 'incollection'
              logger.info "Source ERROR: containing source bibtex_type is not 'book', SF.RefID = #{ref_id}, SF.ContainingRefID = #{containing_ref_id}, TW.containing_source_id = #{containing_source_id}"
              # pub_type_string = 'misc' # per Matt, parent source is 'article'
            end

            source = Source::Bibtex.new(
                bibtex_type: pub_type_string,
                title: row['Title'],
                booktitle: containing_source.booktitle,
                publisher: containing_source.publisher,
                address: containing_source.address,
                serial_id: containing_source.serial_id,
                series: containing_source.series,
                volume: containing_source.volume,
                number: containing_source.number,
                pages: row['RefPages'],
                year: containing_source.year,
                stated_year: containing_source.stated_year,
                url: row['LinkID'].to_i > 0 ? get_sf_ref_link[ref_id] : nil,
                created_at: row['CreatedOn'],
                updated_at: row['LastUpdate'],
                created_by_id: get_tw_user_id[row['CreatedBy']],
                updated_by_id: get_tw_user_id[row['ModifiedBy']]
            )

            begin
              source.save!
              source.data_attributes.create!(type: 'ImportAttribute', project_id: get_tw_project_id[row['FileID']], import_predicate: 'SF.RefID', value: ref_id)

              # Also keep db record of containing_source_id for future reference
              source.data_attributes.create!(type: 'ImportAttribute', project_id: get_tw_project_id[row['FileID']], import_predicate: 'containing_source_id', value: containing_source_id)


              source_id = source.id.to_s
              get_tw_source_id[ref_id] = source_id
              get_containing_source_id[source_id] = containing_source_id
            rescue ActiveRecord::RecordInvalid
              logger.error "Source (Containing_ref_id > 0) ERROR (#{contained_error_counter += 1}): " + source.errors.full_messages.join(';')
            end

          end

          import.set('SFRefIDToTWSourceID', get_tw_source_id)
          import.set('TWSourceIDToContainingSourceID', get_containing_source_id)

          puts 'SFRefIDToTWSourceID'
          ap get_tw_source_id

          puts 'TWSourceIDToContainingSourceID'
          ap get_containing_source_id

          logger.info "Skipped RefIDs on first loop: #{skipped_ref_ids}"
        end

        # desc 'time rake tw:project_import:sf_import:start:contained_cite_aux_data user_id=1 data_directory=~/src/onedb2tw/working/'
        # LoggedTask.define contained_cite_aux_data: [:data_directory, :backup_directory, :environment, :user_id] do |logger|
        #
        #   logger.info 'Creating SF contained cite aux data...'
        #
        #   # Misc. data associated with contained ref acting as taxon name author. Ref in refs of articles, not books. Do not create source records
        #   #   for these. The aux data will be used in a note for a citation. The containing ref ID will be the actual record for the citation.
        #
        #   get_contained_cite_aux_data = {} # key = SF.RefID, value = ContainingRefID, RefPages, Note, LinkID
        #
        #   path = @args[:data_directory] + 'sfContainedCiteAuxData.txt'
        #   file = CSV.read(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')
        #
        #   file.each do |row|
        #     ref_id = row['RefID']
        #
        #     logger.info "Working with SF.RefID = '#{ref_id}' \n"
        #
        #     get_contained_cite_aux_data[ref_id] = {containing_ref_id: row['ContainingRefID'], ref_pages: row['RefPages'], note: row['Note'], link_id: row['LinkID']}
        #   end
        #
        #   import = Import.find_or_create_by(name: 'SpeciesFileData')
        #   import.set('SFContainedCiteAuxData', get_contained_cite_aux_data)
        #
        #   puts 'SFContainedCiteAuxData'
        #   ap get_contained_cite_aux_data
        #
        #   #######################################################################################
        #   # `rake tw:db:dump backup_directory=~/src/db_backup/`
        #   #######################################################################################
        # end

        desc 'time rake tw:project_import:sf_import:start:map_pub_type user_id=1 data_directory=~/src/onedb2tw/working/'
        # map SF.PubID by SF.PubType
        LoggedTask.define map_pub_type: [:data_directory, :backup_directory, :environment, :user_id] do |logger|
          # Can be run independently at any time

          logger.info 'Running map_pub_types...'

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          skipped_file_ids = import.get('SkippedFileIDs')

          get_sf_pub_type_string = {} # key = SF.PubID, value = SF.PubType

          path = @args[:data_directory] + 'tblPubs.txt'
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

          file.each_with_index do |row|
            next if skipped_file_ids.include? row['FileID'].to_i

            pub_type = row['PubType']
            if pub_type == '1'
              pub_type_string = 'article'
            elsif pub_type == '3'
              pub_type_string = 'book'
            elsif pub_type == '4'
              pub_type_string = 'unpublished'
            else
              pub_type_string = '**ERROR**'
            end

            get_sf_pub_type_string[row['PubID']] = pub_type_string
          end

          import.set('SFPubIDToPubTypeString', get_sf_pub_type_string)

          puts 'SFPubIDToPubTypeString'
          ap get_sf_pub_type_string
        end

        desc 'time rake tw:project_import:sf_import:start:create_sf_book_hash user_id=1 data_directory=~/src/onedb2tw/working/'
        # consists of book_title:, publisher:, and place_published: (address)'
        LoggedTask.define create_sf_book_hash: [:data_directory, :backup_directory, :environment, :user_id] do |logger|
          # Can be run independently at any time

          logger.info 'Running create_sf_book_hash...'

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          skipped_file_ids = import.get('SkippedFileIDs')

          get_sf_booktitle_publisher_address = {} # key = SF.PubID, value = booktitle, publisher, and address from tblPubs

          path = @args[:data_directory] + 'tblPubs.txt'
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

          file.each_with_index do |row, i|
            next if skipped_file_ids.include? row['FileID'].to_i
            next unless row['PubType'] == '3' # book

            logger.info "working with PubID #{row['PubID']}"

            get_sf_booktitle_publisher_address[row['PubID']] = {booktitle: row['ShortName'], publisher: row['Publisher'], address: row['PlacePublished']}
          end

          import.set('SFPubIDTitlePublisherAddress', get_sf_booktitle_publisher_address)

          puts 'SFPubIDTitlePublisherAddress'
          ap get_sf_booktitle_publisher_address
        end

        desc 'time rake tw:project_import:sf_import:start:create_projects user_id=1 data_directory=~/src/onedb2tw/working/'
        LoggedTask.define create_projects: [:data_directory, :backup_directory, :environment, :user_id] do |logger|

          logger.info 'Running create_projects...'

          get_tw_project_id = {} # key = SF.FileID, value = TW.project_id

          # create mb as project member for each project -- comment out for Sandbox
          # user = User.find_by_email('mbeckman@illinois.edu')
          # Current.user_id = user.id # not sure if this is really needed?

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          skipped_file_ids = import.get('SkippedFileIDs')

          path = @args[:data_directory] + 'tblFiles.txt'
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

          file.each_with_index do |row, i|
            file_id = row['FileID']
            next if file_id == '0'
            next if skipped_file_ids.include? file_id.to_i

            website_name = row['WebsiteName'].downcase # want to be lower case

            # project = Project.new(name: "#{website_name}_species_file(#{Time.now})", without_root_taxon_name: true)
            project = Project.new(
                name: "#{website_name}_species_file(#{Time.now})"
            )

            # byebug

            if project.save
              # Protonym.create!(name: 'Root', rank_class: 'NomenclaturalRank', parent_id: nil, project: project, creator: user, updater: user, cached_html: 'Root')

              get_tw_project_id[file_id] = project.id.to_s

              # comment out project_member for Sandbox use
              ProjectMember.create!(user_id: Current.user_id, project: project, is_project_administrator: true)

            else
              logger.info "ERROR (#{error_counter += 1}): " + source.errors.full_messages.join(';')
              logger.info "FileID: #{file_id}, sf row created by: #{row['CreatedBy']}, sf row updated by: #{row['ModifiedBy']}    "
            end
          end

          import.set('SFFileIDToTWProjectID', get_tw_project_id)
          puts 'SFFileIDToTWProjectID'
          ap get_tw_project_id

        end

        desc 'time rake tw:project_import:sf_import:start:list_verbatim_refs user_id=1 data_directory=~/src/onedb2tw/working/'
        LoggedTask.define list_verbatim_refs: [:data_directory, :backup_directory, :environment, :user_id] do |logger|
          # Can be run independently at any time before referenced

          logger.info 'Running list_verbatim_refs...'

          get_sf_verbatim_ref = {} # key = SF.RefID, value = SF verbatim ref (table generated from a script)

          path = @args[:data_directory] + 'sfVerbatimRefs.txt'
          file = CSV.read(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

          file.each do |row|
            # byebug
            # puts row.inspect
            ref_id = row['RefID']
            logger.info "working with #{ref_id} \n"
            get_sf_verbatim_ref[ref_id] = row['RefString']
          end

          i = Import.find_or_create_by(name: 'SpeciesFileData')
          i.set('RefIDToVerbatimRef', get_sf_verbatim_ref)

          puts 'RefIDToVerbatimRef'
          ap get_sf_verbatim_ref
        end

        desc 'time rake tw:project_import:sf_import:start:map_ref_links user_id=1 data_directory=~/src/onedb2tw/working/'
        LoggedTask.define map_ref_links: [:data_directory, :backup_directory, :environment, :user_id] do |logger|
          # Can be run independently at any time before referenced

          logger.info 'Running map_ref_links...'

          get_sf_ref_link = {} # key = SF.RefID, value = SF ref link (table generated from a script)

          path = @args[:data_directory] + 'sfRefLinks.txt'
          file = CSV.read(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

          file.each do |row|
            # byebug
            # puts row.inspect
            ref_id = row['RefID']
            logger.info "working with #{ref_id} \n"
            get_sf_ref_link[ref_id] = row['RefLink']
          end

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          import.set('RefIDToRefLink', get_sf_ref_link)

          puts 'RefIDToRefLink'
          ap get_sf_ref_link

        end

=begin  obsolete
        # :create_no_ref_list_array is now created on the fly in :create_sources (data conflicts)
        # desc 'make array from no_ref_list'
        # task :create_no_ref_list_array => [:data_directory, :backup_directory, :environment, :user_id] do
        #   ### rake tw:project_import:sf_start:create_no_ref_list_array user_id=1 data_directory=~/src/onedb2tw/working/
        #   sf_no_ref_list = []
        #
        #   path = @args[:data_directory] + 'direct_from_sf/no_ref_list.txt'
        #   file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')
        #
        #   file.each do |row|
        #     sf_no_ref_list.push(row[0])
        #   end
        #
        #   i = Import.find_or_create_by(name: 'SpeciesFileData')
        #   i.set('SFNoRefList', sf_no_ref_list)
        #
        #   puts 'SF no_ref_list'
        #   ap sf_no_ref_list
        #
        # end
=end

        desc 'time rake tw:project_import:sf_import:start:map_serials user_id=1 data_directory=~/src/onedb2tw/working/'
        LoggedTask.define map_serials: [:environment, :user_id] do |logger|
          # Can be run independently at any time before referenced: Why can't the value be cast as string??

          logger.info 'Running map_serials...'

          # pubs = DataAttribute.where(import_predicate: 'SF ID', attribute_subject_type: 'Serial').limit(10).pluck(:value, :attribute_subject_id)
          get_tw_serial_id = DataAttribute.where(import_predicate: 'SF ID', attribute_subject_type: 'Serial').pluck(:value, :attribute_subject_id).to_h #.to_s

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          import.set('SFPubIDToTWSerialID', get_tw_serial_id)

          puts 'SFPubIDToTWSerialID'
          ap get_tw_serial_id
        end

        desc 'time rake tw:project_import:sf_import:start:create_people user_id=1 data_directory=~/src/onedb2tw/working/'
        LoggedTask.define create_people: [:data_directory, :backup_directory, :environment, :user_id] do |logger|

          logger.info 'Running create_people...'

=begin  Thinking through logic:

          # Two loops:
          # Loop # 1
          # loop through entire table (22004 entries)
          # process only those rows where row['PrefID'] == 0
          # create person, how to assign original housekeeping (save hashes from create_users)?
          # save person, validate, etc.
          # save PersonID as identifier or data_attribute or ?? << probably identifier/local import identifier
          # save Role (bitmap) as data_attribute (?) for later role assignment; Role & 256 = 256 should indicate name is deletable, but it is often incorrectly set!
          # make SF.PersonID and TW.person.id hash (for processing in second loop)
          #
          # Loop # 2
          # loop through entire table
          # process only those rows where row['PrefID'] > 0
          # identify tw.person.id via row['PrefID'] in hash
          # create alternate_value for tw.person.id using last_name only

          # tblPeople: PersonID, FileID, PrefID, [PersonRegID], FamilyName, GivenName, GivenInitials, Suffix, *Role*, [Status], LastUpdate, ModifiedBy, CreatedOn, CreatedBy
          #   Identifiers: PersonID; DataAttributes: FileID, Role; Do not import: PersonRegID; GivenName/GivenInitials: If GN is blank, use GI
          #
          # People: id, type, last_name, first_name, created_at, updated_at, suffix, prefix, created_by_id, updated_by_id, cached

          # @project = Project.find_by_name('Orthoptera Species File')
          # Current.project_id = @project.id
=end

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          get_tw_user_id = import.get('SFFileUserIDToTWUserID') # for housekeeping

          get_tw_person_id ||= {} # key = SF.PersonID, value = TW.person_id; make empty hash if doesn't exist (otherwise it would be nil), used in loop 2

          # create Namespace for Identifier (used in loop below): Species File, tblPeople, SF PersonID
          # 'Key3' => Namespace.find_or_create_by(name: '3i_Source_ID', short_name: '3i_Source_ID')     # 'Key3' was key in hash @data.keywords.merge! ??
          # auth_user_namespace = Namespace.find_or_create_by(institution: 'Species File', name: 'tblAuthUsers', short_name: 'SF AuthUserID')
          person_namespace = Namespace.find_or_create_by(institution: 'Species File', name: 'tblPeople', short_name: 'SF PersonID')

          # No longer using InternalAttribute for following import values; using ImportAttribute instead since it doesn't require a project_id
          # file_id = Predicate.find_or_create_by(name: 'FileID', definition: 'SpeciesFile.FileID', project_id: Current.project_id)
          # person_roles = Predicate.find_or_create_by(name: 'Roles', definition: 'Bitmap of person roles', project_id: Current.project_id)
          # example of internal attr:
          # person.data_attributes << InternalAttribute.new(predicate: person_roles, value: row['Role'])
          # person.identifiers.new(type: 'Identifier::Local::Import', namespace: person_namespace, identifier: sf_person_id)
          # # probably only writes to memory, to save in db, use <<

          path = @args[:data_directory] + 'tblPeople.txt'
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

          # loop 1: Get preferred records only

          person_error_counter = 0

          file.each_with_index do |row, i|
            sf_person_id = row['PersonID']
            # next if get_tw_person_id[sf_person_id] # do not create if already exists

            pref_id = row['PrefID']
            next if pref_id.to_i > 0 # alternate spellings will be handled in second loop

            logger.info "working with SF.PersonID: #{sf_person_id} \n"

            person = Person::Vetted.new(
                # type: 'Person_Vetted',
                last_name: row['FamilyName'],
                first_name: row['GivenNames'].blank? ? row['GivenInitials'] : row['GivenNames'],
                created_at: row['CreatedOn'],
                updated_at: row['LastUpdate'],
                suffix: row['Suffix'],
                # prefix: '',
                created_by_id: get_tw_user_id[row['CreatedBy']],
                updated_by_id: get_tw_user_id[row['ModifiedBy']]
                # cached: '?'
            )

            begin
              person.save!

              person.data_attributes << ImportAttribute.new(import_predicate: 'FileID', value: row['FileID'])
              person.data_attributes << ImportAttribute.new(import_predicate: 'Role', value: row['Role'])

              person.identifiers << Identifier::Local::Import.new(namespace: person_namespace, identifier: sf_person_id)

              get_tw_person_id[sf_person_id] = person.id.to_s

            rescue ActiveRecord::RecordInvalid
              logger.info "Person ERROR (#{person_error_counter += 1}): " + person.errors.full_messages.join(';')
            end

          end

          import.set('SFPersonIDToTWPersonID', get_tw_person_id) # write to db
          logger.info 'SFPersonIDToTWPersonID'
          ap get_tw_person_id

          # loop 2: Get non-preferred records and save as alternate values

          added_counter = 0
          error_counter = 0

          # file.rewind maybe?
          # id          pref_id       family_name
          # sue         ''            jones
          # peggy       sue           brown

          file.each_with_index do |row, i| # uses path & file from loop 1
            pref_id = row['PrefID']
            next if pref_id.to_i == 0 # handle only non-preferred records


            non_pref_family_name = row['FamilyName'] # use the non-preferred person's family name as default alternate name

            # a = AlternateValue.create(type: 'AlternateValue::Translation', value: char_for_key_3i(row['CharRu']).capitalize, alternate_value_object: descriptor, alternate_value_object_attribute: 'key_name', language_id: lngru)
            if get_tw_person_id[pref_id]
              puts "working with SF.PrefID: #{pref_id} (from SF.PersonID: #{row['PersonID']}), TW.person_id: #{get_tw_person_id[pref_id]}"
              # pref_person.alternate_values.new(value: non_pref_family_name, type: 'AlternateValue::AlternateSpelling', alternate_value_object_attribute: 'last_name')
              a = AlternateValue::AlternateSpelling.new(
                  alternate_value_object_type: 'Person',
                  alternate_value_object_id: get_tw_person_id[pref_id],
                  value: non_pref_family_name,
                  alternate_value_object_attribute: 'last_name',
                  is_community_annotation: true # if no project_id
              )

              begin
                a.save!
                logger.info "Attribute added (#{added_counter += 1})"
              rescue ActiveRecord::RecordInvalid
                logger.info "Attribute ERROR (#{error_counter += 1}): invalid attribute -- " + a.errors.full_messages.join(';')
              end
            end
          end
          logger.info "person_error_counter = #{person_error_counter}, added_counter = #{added_counter}, error_counter = #{error_counter}"
        end

        desc 'time rake tw:project_import:sf_import:start:create_users user_id=1 data_directory=~/src/onedb2tw/working/'
        LoggedTask.define create_users: [:data_directory, :backup_directory, :environment, :user_id] do |logger|

          logger.info 'Running create_users...'

=begin
        Most logic for authorized users (one login per user) vs. file users (same authorized user for Orthoptera, Plecoptera, and Phasmida but each is different in each SF)

          # ProjectMembers: id, project_id, user_id, created_at, updated_at, created_by_id, updated_by_id, is_project_administrator
          #   * Cannot annotate a project_member
          # Users: id, email, password_digest, created_at, updated_at, remember_token, created_by_id, updated_by_id, is_administrator,
          #   password_reset_token, password_reset_token_date, name, current_sign_in_at, last_sign_in_at, current_sign_in_ip, last_sign_in_ip,
          #   hub_tab_order, api_access_token, is_flagged_for_password_reset, footprints, sign_in_count,
          #     * Annotations: FullName, TaxaShowSpecs, CiteShowSpecs, SpmnShowSpecs
          #     * Since no annotations for project_member, could add notes to Users for (Access, LastLogin, NumLogins, LastEdit, NumEdits) by SF

          # tblFileUsers: FileUserID, AuthUserID, FileID, Access, LastLogin, NumLogins, LastEdit, NumEdits, CreatedOn, CreatedBy
          # tblAuthUsers: AuthUserID, Name, HashedPassword, FullName, TaxaShowSpecs, CiteShowSpecs, SpmnShowSpecs, LastUpdate, ModifiedBy,
          #   CreatedOn, CreatedBy

          # Fields for potential data attributes
          #   AuthUserID

          # create a ControlledVocabularyTerm of type Predicate (to be used in DataAttribute in User instance below)
          # predicates = {
          #     'AuthUserID' => Predicate.find_or_create_by(name: 'AuthUserID', definition: 'Unique user name id', project_id: Current.project_id)
          # }
          # Now that User is identifiable, we can use an identifier for the unique AuthUserID (vs. FileUserID)
          # Create Namespace for Identifier: Species File, tblAuthUsers, SF AuthUserID
          # 'Key3' => Namespace.find_or_create_by(name: '3i_Source_ID', short_name: '3i_Source_ID')     # 'Key3' was key in hash @data.keywords.merge! in 3i.rake ??

=end

          auth_user_namespace = Namespace.find_or_create_by(institution: 'Species File', name: 'tblAuthUsers', short_name: 'SF AuthUserID')

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          skipped_file_ids = import.get('SkippedFileIDs')

          # find unique editors/admin, i.e. people getting users accounts in TW
          unique_auth_users = {} # unique sf.authorized users with edit+ access, not stored in Import, used only in this task
          sf_file_user_id_to_sf_auth_user_id = {} # not stored in Import; multiple file users map onto same auth user
          get_tw_user_id = {} # key = sf.file_user_id, value = tw.user_id
          get_sf_file_id = {} # key = sf.file_user_id, value sf.file_id; for future use when creating projects and project members

          @user_index = {}
          project_url = 'speciesfile.org'

          path = @args[:data_directory] + 'tblFileUsers.txt'
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

          file.each_with_index do |row, i|
            next if skipped_file_ids.include? row['FileID'].to_i
            au_id = row['AuthUserID']
            fu_id = row['FileUserID']
            # next if [0, 8].freeze.include?(row['Access'].to_i)
            next if [8].freeze.include?(row['Access'].to_i) # in some cases, user access has been rescinded after user edited something; keep this user, if no name, use NoName_1, 2, 3, etc.

            logger.info "WARNING - NON UNIQUE FileUserID: #{fu_id}" if sf_file_user_id_to_sf_auth_user_id[fu_id]

            sf_file_user_id_to_sf_auth_user_id[fu_id] = au_id

            if unique_auth_users[au_id]
              unique_auth_users[au_id].push fu_id
            else
              unique_auth_users[au_id] = [fu_id]
            end

            get_sf_file_id[fu_id] = row['FileID']
          end

          path = @args[:data_directory] + 'tblAuthUsers.txt'
          logger.info "Creating users\n"
          raise "file #{path} not found" if not File.exists?(path)
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

          error_counter = 0
          no_name_counter = 0

          file.each_with_index do |row, i|
            au_id = row['AuthUserID']

            logger.info "working with AuthUser: #{au_id}"

            user_name = row['Name']
            if user_name.blank?
              user_name = "NoName_#{no_name_counter += 1}"
            end

            if au_id.to_i <= 0 || User.where(id: Current.user_id, name: row['FullName']).any?
              unique_auth_users[au_id].each do |fu_id|
                get_tw_user_id[fu_id] = Current.user_id.to_s # @ Making user.id into string for consistency of all hash values being strings
                logger.info "Assigned user #{au_id}:#{fu_id} to import user"
              end
            elsif unique_auth_users[au_id]
              logger.info "is a unique user, creating:  #{i}: #{user_name}"

              user = User.new(
                  name: user_name,
                  password: '12345678',
                  email: 'auth_user_id' + au_id.to_s + '_random' + rand(1000).to_s + '@' + project_url
              )

              if user.save

                unique_auth_users[au_id].each do |fu_id|
                  get_tw_user_id[fu_id] = user.id.to_s # @ Making user.id into string for consistency of all hash values being strings
                end

                @user_index[row['FileUserID']] = user.id # maps multiple FileUserIDs onto single TW user.id

                # create AuthUserID as DataAttribute as InternalAttribute for table users
                # user.data_attributes << InternalAttribute.new(predicate: predicates['AuthUserID'], value: au_id)
                # Now using an identifier for this:
                user.identifiers.new(type: 'Identifier::Local::Import', namespace: auth_user_namespace, identifier: au_id)

                # Do not create project_members right now; store hash of file_user_id => file_id in Import table
                # ProjectMember.create(user: user, project: @project)

              else
                logger.info "User ERROR (#{error_counter += 1}): " + user.errors.full_messages.join(';')
              end

            else
              logger.info " skipping, public access only\n"
            end
          end

          # Save the file user mappings to the import table
          import.set('SFFileUserIDToTWUserID', get_tw_user_id)
          import.set('SFFileUserIDToSFFileID', get_sf_file_id) # will be used when tables containing FileID are imported

          # display user mappings
          puts 'unique authorized users with edit+ access'
          ap unique_auth_users # list of unique authorized users (who may or may not currently have edit+ access via FileUserIDs)
          puts 'multiple FileUserIDs mapped to single AuthUserID'
          ap sf_file_user_id_to_sf_auth_user_id # map multiple FileUserIDs onto single AuthUserID
          puts 'SFFileUserIDToTWUserID'
          ap get_tw_user_id # map multiple FileUserIDs on single TW user.id
          puts 'SFFileUserIDToSFFileID'
          ap get_sf_file_id

        end

        desc 'time rake tw:project_import:sf_import:start:list_skipped_file_ids user_id=1 data_directory=~/src/onedb2tw/working/'
        LoggedTask.define list_skipped_file_ids: [:data_directory, :backup_directory, :environment, :user_id] do |logger|

          logger.info 'Running list_skipped_file_ids...'

          skipped_file_ids = [
              9, # Lepidoptera
              24, # Collembola
              48, # Rhyparochromidae
              54, # Heteroptera
              56, # Membracoidea
              66, # Odonata
              70, # Tortricidae
              77, # Erebidae
              78, # Melanoplus
              80, # Pyrgomorphidae
              81, # Ommexechidae
              82, # Carabidae
              83, # Cicadoidea
              84, # Psychodidae
              85, # Megaloptera
              86, # Scutelleridae
              88, # Praxibulini
              89, # Prostoia
              92 # Dysoniini
          ]

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          import.set('SkippedFileIDs', skipped_file_ids)

          puts 'SkippedFileIDs'
          ap skipped_file_ids
        end

      end # :start


      namespace :last do

        desc 'time rake tw:project_import:sf_import:last:filter_users user_id=1 data_directory=~/src/onedb2tw/working/'
        LoggedTask.define filter_users: [:data_directory, :backup_directory, :environment, :user_id] do |logger|

          logger.info 'Running filter_users...'

          destroyed_counter = 0

          User.all.each do |user|
            puts "user.id = #{user.id} \n"
            unless user.curates_data?
              user.destroy
              puts "destroyed, count = #{destroyed_counter += 1} \n"
            end
          end
        end

      end # :last


    end # :sf_import
  end # :project-import
end # :tw

