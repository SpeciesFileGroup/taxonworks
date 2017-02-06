namespace :tw do
  namespace :project_import do
    namespace :sf_import do
      require 'fileutils'
      require 'logged_task'
      namespace :start do

        # Anyone who runs these tasks:  Substitute Your id as user_id, not user_id=1

        ## check out default user_id if SF.FileUserID < 1

        # Outstanding issues for ProjectSources
        #   Add data_attribute to ProjectSources from sfVerbatimRefs (this is instead of dealing with tblRefs.ContainingRefID)
        #   Add tblRefs.Note as?
        #   Currently ProjectSources do not allow data_attributes or notes
        #   Incorporate :create_sf_book_hash and :update_sources_with_book_info into :create_sources

        desc 'time rake tw:project_import:sf_import:start:update_sources_with_booktitle_publisher_address user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        # for bibtex books
        LoggedTask.define :update_sources_with_booktitle_publisher_address => [:data_directory, :environment, :user_id] do |logger|
          # should have combined this into original source creation
          # @todo Not found: Slater, J.A. Date unknown. A Catalogue of the Lygaeidae of the world. << RefID = 44058, PubID = 21898

          logger.info 'Running update sources with booktitle, publisher, address'

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          get_sf_booktitle_publisher_address = import.get('SFPubIDTitlePublisherAddress')
          get_tw_source_id = import.get('SFRefIDToTWSourceID')

          # Read each RefID:PubID; if PubID is included in Book hash, update source record.

          path = @args[:data_directory] + 'tblRefs.txt'
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'UTF-16:UTF-8')

          error_counter = 0
          successful_update_counter = 0

          file.each_with_index do |row, i|
            next if get_sf_booktitle_publisher_address[row['PubID']].nil?
            next if (row['Title'].empty? and row['PubID'] == '0' and row['Series'].empty? and row['Volume'].empty? and row['Issue'].empty? and row['ActualYear'].empty? and row['StatedYear'].empty? and row['ContainingRefID'] == '0') or row['AccessCode'] == '4'

            logger.info "working with SF.RefID #{row['RefID']} = TW.source_id #{get_tw_source_id[row['RefID']]}, SF.PubID = #{row['PubID']}"

            source = Source.find_by(id: get_tw_source_id[row['RefID']].to_i)
            if source.nil? # can't find
              logger.error "Source not found (RefID = #{row['RefID']}), Error #{error_counter += 1}"
            elsif source.class == Source::Verbatim
              logger.info "Verbatim source, skipping"
            elsif not source.update(get_sf_booktitle_publisher_address[row['PubID']])
              logger.error "Failed to update, Error #{error_counter += 1}", {msg: source.errors.messages}
            else
              successful_update_counter += 1
            end

          end
          logger.info "Books processed = #{successful_update_counter}, Errors = #{error_counter}"
        end

        desc 'time rake tw:project_import:sf_import:start:create_sf_book_hash user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        # consists of book_title:, publisher:, and place_published: (address)'
        LoggedTask.define :create_sf_book_hash => [:data_directory, :environment, :user_id] do |logger|
          # Can be run independently at any time

          logger.info 'Running create_sf_book_hash...'

          get_sf_booktitle_publisher_address = {} # key = SF.PubID, value = booktitle, publisher, and address from tblPubs

          path = @args[:data_directory] + 'tblPubs.txt'
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'UTF-16:UTF-8')

          file.each_with_index do |row, i|
            next unless row['PubType'] == '3' # book

            logger.info "working with PubID #{row['PubID']}"

            get_sf_booktitle_publisher_address[row['PubID']] = {booktitle: row['ShortName'], publisher: row['Publisher'], address: row['PlacePublished']}
          end

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          import.set('SFPubIDTitlePublisherAddress', get_sf_booktitle_publisher_address)

          puts 'SFPubIDTitlePublisherAddress'
          ap get_sf_booktitle_publisher_address
        end

        #################### UNUSED #########################
        # desc 'create RefIDToPubID hash      UNUSED!!'
        # task :create_ref_id_to_pub_id_hash => [:data_directory, :environment, :user_id] do
        #   ### time rake tw:project_import:species_file:create_ref_id_to_pub_id_hash user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/
        #
        #   species_file_data = Import.find_or_create_by(name: 'SpeciesFileData')
        #   sf_ref_id_to_sf_pub_id_hash = {}
        #
        #   path = @args[:data_directory] + 'tblRefs.txt'
        #   file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'UTF-16:UTF-8')
        #
        #   file.each do |row|
        #     sf_ref_id_to_sf_pub_id_hash[row['RefID']] = row['PubID']
        #   end
        #
        #   species_file_data.set('SFRefIDToPubID', sf_ref_id_to_sf_pub_id_hash)
        #   puts 'SF.RefID to SF.PubID'
        #   ap sf_ref_id_to_sf_pub_id_hash
        #
        # end

        desc 'time rake tw:project_import:sf_import:start:run_tasks_between_sources_and_source_roles user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        LoggedTask.define :run_tasks_between_sources_and_source_roles => [:create_source_editor_array, :create_source_roles] do |logger|
          logger.info 'Done with :create_source_editor_array, :create_source_roles'
        end

        desc 'time rake tw:project_import:sf_import:start:create_source_roles user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        LoggedTask.define :create_source_roles => [:data_directory, :environment, :user_id] do |logger|

          logger.info 'Running create_source_roles...'

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          get_tw_person_id = import.get('SFPersonIDToTWPersonID')
          get_tw_source_id = import.get('SFRefIDToTWSourceID')
          get_tw_user_id = import.get('SFFileUserIDToTWUserID') # for housekeeping
          source_editor_array = import.get('TWSourceEditorList') # if source.id is in array

          path = @args[:data_directory] + 'tblRefAuthors.txt'
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'UTF-16:UTF-8')

          author_error_counter = 0
          editor_error_counter = 0

          file.each_with_index do |row, i|
            source_id = get_tw_source_id[row['RefID']]
            next if source_id.nil?
            # Reloop if TW.source record is verbatim
            # next if Source.find(source_id).try(:class) == Source::Verbatim # << Hernán's, Source.find(source_id).type == 'Source::Verbatim'
            next if Source.where(id: source_id).pluck(:type)[0] == 'Source::Verbatim' # faster per Matt

            print "working with SF.RefID = #{row['RefID']}, TW.source_id = #{source_id}, position = #{row['SeqNum']} \n"

            role = Role.new(
                person_id: get_tw_person_id[row['PersonID']],
                type: 'SourceAuthor',
                role_object_id: source_id,
                role_object_type: 'Source',
                position: row['SeqNum'],
                # project_id: project_id,   # don't use for SourceAuthor or SourceEditor
                created_at: row['CreatedOn'],
                updated_at: row['LastUpdate'],
                created_by_id: get_tw_user_id[row['CreatedBy']],
                updated_by_id: get_tw_user_id[row['ModifiedBy']]
            )

            if role.save
              is_editor = source_editor_array.include?(source_id)

              if is_editor
                role = Role.new(
                    person_id: get_tw_person_id[row['PersonID']],
                    type: 'SourceEditor',
                    role_object_id: source_id,
                    role_object_type: 'Source',
                    position: row['SeqNum'],
                    # project_id: project_id,
                    created_at: row['CreatedOn'],
                    updated_at: row['LastUpdate'],
                    created_by_id: get_tw_user_id[row['CreatedBy']],
                    updated_by_id: get_tw_user_id[row['ModifiedBy']]
                )

                unless role.save
                  logger.info "Editor role ERROR (#{editor_error_counter += 1}): " + role.errors.full_messages.join(';')
                end
              end

            else
              logger.info "Author role ERROR (#{author_error_counter += 1}): " + role.errors.full_messages.join(';')
            end
          end
          logger.info "author_error_counter = #{author_error_counter}, editor_error_counter = #{editor_error_counter}"
        end

        desc 'time rake tw:project_import:sf_import:start:create_source_editor_array user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        # via tblRefs
        LoggedTask.define :create_source_editor_array => [:data_directory, :environment, :user_id] do |logger|
          # Can be run independently at any time

          logger.info 'Running create_source_editor_array...'

          # is_editor, tblRefs.flags & 2 = 2 if set
          # loop through Refs and store only those w/editors

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          get_tw_source_id = import.get('SFRefIDToTWSourceID')

          tw_source_id_editor_list = []

          path = @args[:data_directory] + 'tblRefs.txt'
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'UTF-16:UTF-8')

          file.each do |row|
            ref_id = row['RefID']

            logger.info "working with SF.RefID = #{ref_id}, TW.source_id = #{get_tw_source_id[ref_id]} \n"

            tw_source_id_editor_list.push(get_tw_source_id[ref_id]) if row['Flags'].to_i & 2 == 2
          end

          import.set('TWSourceEditorList', tw_source_id_editor_list)

          puts 'TWSourceEditorList'
          ap tw_source_id_editor_list
        end

        desc 'time rake tw:project_import:sf_import:start:run_tasks_through_sources user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        # without no_ref_list
        LoggedTask.define :run_tasks_through_sources => [:create_users, :create_people, :map_serials, :map_pub_type,
                                                         :map_ref_links, :list_verbatim_refs, :create_projects, :create_sources] do |logger|
          logger.info 'Ran create_users, create_people, map_serials, map_pub_type, map_ref_links, list_verbatim_refs, create_projects, create_sources'
        end

        desc 'time rake tw:project_import:sf_import:start:create_sources user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        LoggedTask.define :create_sources => [:data_directory, :environment, :user_id] do |logger|
          # @todo: See :create_sf_book_hash and :update_sources_with_book_info above. Should be incorporated here.

          logger.info 'Running create_sources...'

          # tblRefs columns to import: Title, PubID, Series, Volume, Issue, RefPages, ActualYear, StatedYear, LinkID, LastUpdate, ModifiedBy, CreatedOn, CreatedBy
          # tblRefs other columns: RefID => Source.identifier, FileID => used when creating ProjectSources, ContainingRefID => sfVerbatimRefs contains full
          #   RefStrings attached as data_attributes in ProjectSources (no need for ContainingRefID), AccessCode => n/a, Flags => identifies editor
          #   (use when creating roles and generating author string from tblRefAuthors), Note => attach to ProjectSources, CiteDataStatus => can be derived,
          #   Verbatim => not used

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          get_tw_user_id = import.get('SFFileUserIDToTWUserID') # for housekeeping
          get_tw_serial_id = import.get('SFPubIDToTWSerialID') # for FK
          get_sf_pub_type = import.get('SFPubIDToPubType') # = bibtex_type (1=journal=>article, 2=unused, 3=book or cd=>book, 4=unpublished source=>unpublished)
          get_sf_ref_link = import.get('RefIDToRefLink') # key is SF.RefID, value is URL string
          get_sf_verbatim_ref = import.get('RefIDToVerbatimRef') # key is SF.RefID, value is verbatim string
          get_tw_project_id = import.get('SFFileIDToTWProjectID')

          get_tw_source_id = {} # key = SF.RefID, value = TW.source_id

          # byebug

          # Namespace for Identifier
          # source_namespace = Namespace.find_or_create_by(institution: 'Species File', name: 'tblRefs', short_name: 'SF RefID')

          error_counter = 0

          path = @args[:data_directory] + 'tblRefs.txt'
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'UTF-16:UTF-8')

          file.each_with_index do |row, i|
            # break if i == 20
            next if (row['Title'].empty? and row['PubID'] == '0' and row['Series'].empty? and row['Volume'].empty? and row['Issue'].empty? and row['ActualYear'].empty? and row['StatedYear'].empty? and row['ContainingRefID'] == '0') or row['AccessCode'] == '4'
            ref_id = row['RefID']

            logger.info "working with SF.RefID = #{ref_id}, SF.FileID = #{row['FileID']} \n"

            pub_type = get_sf_pub_type[row['PubID']]

            actual_year = row['ActualYear']
            stated_year = row['StatedYear']

            if row['ContainingRefID'].to_i > 0 or actual_year == '0' or stated_year == '0' or actual_year.include?('-') or stated_year.include?('-') or pub_type == 'unpublished'
              # create a verbatim source
              source = Source::Verbatim.new(
                  verbatim: get_sf_verbatim_ref[ref_id],
                  created_at: row['CreatedOn'],
                  updated_at: row['LastUpdate'],
                  created_by_id: get_tw_user_id[row['CreatedBy']],
                  updated_by_id: get_tw_user_id[row['ModifiedBy']]
              )
            else
              source = Source::Bibtex.new(
                  bibtex_type: pub_type,
                  title: row['Title'],
                  serial_id: get_tw_serial_id[row['PubID']],
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
            end

            if source.save

              get_tw_source_id[ref_id] = source.id.to_s

              ProjectSource.create!(
                  project_id: get_tw_project_id[row['FileID']],
                  source_id: source.id,
                  created_at: row['CreatedOn'],
                  updated_at: row['LastUpdate'],
                  created_by_id: get_tw_user_id[row['CreatedBy']],
                  updated_by_id: get_tw_user_id[row['ModifiedBy']]
              )

            else
              logger.info "Source ERROR (#{error_counter += 1}): " + source.errors.full_messages.join(';')
            end
          end

          import.set('SFRefIDToTWSourceID', get_tw_source_id)

          puts 'SFRefIDToTWSourceID'
          ap get_tw_source_id

          logger.info "error_counter = #{error_counter}"
        end

        desc 'time rake tw:project_import:sf_import:start:create_projects user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        LoggedTask.define :create_projects => [:data_directory, :environment, :user_id] do |logger|

          logger.info 'Running create_projects...'

          get_tw_project_id = {} # key = SF.FileID, value = TW.project_id

          # create mb as project member for each project -- commented out for Sandbox
          # user = User.find_by_email('mbeckman@illinois.edu')

          path = @args[:data_directory] + 'tblFiles.txt'
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'UTF-16:UTF-8')

          file.each_with_index do |row, i|
            file_id = row['FileID']
            next if file_id == "0"

            website_name = row['WebsiteName'].downcase # want to be lower case

            project = Project.new(
                name: "#{website_name}_species_file(#{Time.now})",
            )

            if project.save

              get_tw_project_id[file_id] = project.id.to_s

              # commented out project_member for Sandbox use
              # ProjectMember.create!(user_id: user.id, project: project, is_project_administrator: true)

            else
              logger.info "ERROR (#{error_counter += 1}): " + source.errors.full_messages.join(';')
              logger.info "FileID: #{file_id}, sf row created by: #{row['CreatedBy']}, sf row updated by: #{row['ModifiedBy']}    "
            end
          end

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          import.set('SFFileIDToTWProjectID', get_tw_project_id)
          puts 'SFFileIDToTWProjectID'
          ap get_tw_project_id

        end

        desc 'time rake tw:project_import:sf_import:start:list_verbatim_refs user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        # list SF.RefID to VerbatimRefString
        LoggedTask.define :list_verbatim_refs => [:data_directory, :environment, :user_id] do |logger|
          # Can be run independently at any time

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

        desc 'time rake tw:project_import:sf_import:start:map_ref_links user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        # map SF.RefID to Link URL
        LoggedTask.define :map_ref_links => [:data_directory, :environment, :user_id] do |logger|
          # Can be run independently at any time

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

        # :create_no_ref_list_array is now created on the fly in :create_sources (data conflicts)
        # desc 'make array from no_ref_list'
        # task :create_no_ref_list_array => [:data_directory, :environment, :user_id] do
        #   ### rake tw:project_import:sf_start:create_no_ref_list_array user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/
        #   sf_no_ref_list = []
        #
        #   path = @args[:data_directory] + 'direct_from_sf/no_ref_list.txt'
        #   file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'UTF-8')
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

        desc 'time rake tw:project_import:sf_import:start:map_pub_type user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        # map SF.PubID by SF.PubType
        LoggedTask.define :map_pub_type => [:data_directory, :environment, :user_id] do |logger|
          # Can be run independently at any time

          logger.info 'Running map_pub_type...'

          get_sf_pub_type = {} # key = SF.PubID, value = SF.PubType

          path = @args[:data_directory] + 'tblPubs.txt'
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'UTF-16:UTF-8')

          file.each_with_index do |row|

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

            get_sf_pub_type[row['PubID']] = pub_type_string
          end

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          import.set('SFPubIDToPubType', get_sf_pub_type)

          puts 'SFPubIDToPubType'
          ap get_sf_pub_type

        end

        desc 'time rake tw:project_import:sf_import:start:map_serials user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        # map SF.PubID to TW.serial_id
        LoggedTask.define :map_serials => [:environment, :user_id] do |logger|
          # Can be run independently at any time: Why can't the value be cast as string??

          logger.info 'Running map_serials...'

          # pubs = DataAttribute.where(import_predicate: 'SF ID', attribute_subject_type: 'Serial').limit(10).pluck(:value, :attribute_subject_id)
          get_tw_serial_id = DataAttribute.where(import_predicate: 'SF ID', attribute_subject_type: 'Serial').pluck(:value, :attribute_subject_id).to_h

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          import.set('SFPubIDToTWSerialID', get_tw_serial_id)

          puts 'SFPubIDToTWSerialID'
          ap get_tw_serial_id
        end

        desc 'time rake tw:project_import:sf_import:start:create_people user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        LoggedTask.define :create_people => [:data_directory, :environment, :user_id] do |logger|

          logger.info 'Running create_people...'

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
          # $project_id = @project.id

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          get_tw_user_id = import.get('SFFileUserIDToTWUserID') # for housekeeping

          get_tw_person_id ||= {} # key = SF.PersonID, value = TW.person_id; make empty hash if doesn't exist (otherwise it would be nil), used in loop 2

          # create Namespace for Identifier (used in loop below): Species File, tblPeople, SF PersonID
          # 'Key3' => Namespace.find_or_create_by(name: '3i_Source_ID', short_name: '3i_Source_ID')     # 'Key3' was key in hash @data.keywords.merge! ??
          # auth_user_namespace = Namespace.find_or_create_by(institution: 'Species File', name: 'tblAuthUsers', short_name: 'SF AuthUserID')
          person_namespace = Namespace.find_or_create_by(institution: 'Species File', name: 'tblPeople', short_name: 'SF PersonID')

          # No longer using InternalAttribute for following import values; using ImportAttribute instead since it doesn't require a project_id
          # file_id = Predicate.find_or_create_by(name: 'FileID', definition: 'SpeciesFile.FileID', project_id: $project_id)
          # person_roles = Predicate.find_or_create_by(name: 'Roles', definition: 'Bitmap of person roles', project_id: $project_id)
          # example of internal attr:
          # person.data_attributes << InternalAttribute.new(predicate: person_roles, value: row['Role'])
          # person.identifiers.new(type: 'Identifier::Local::Import', namespace: person_namespace, identifier: sf_person_id)
          # # probably only writes to memory, to save in db, use <<

          path = @args[:data_directory] + 'tblPeople.txt'
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'UTF-16:UTF-8')

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

            if person.save

              person.data_attributes << ImportAttribute.new(import_predicate: 'FileID', value: row['FileID'])
              person.data_attributes << ImportAttribute.new(import_predicate: 'Role', value: row['Role'])

              person.identifiers << Identifier::Local::Import.new(namespace: person_namespace, identifier: sf_person_id)

              get_tw_person_id[sf_person_id] = person.id.to_s

            else
              logger.info "Person ERROR (#{person_error_counter += 1}): " + person.errors.full_messages.join(';')
            end

          end

          import.set('SFPersonIDToTWPersonID', get_tw_person_id) # write to db
          logger.info 'SFPersonIDToTWPersonID'
          ap get_tw_person_id

          # loop 2: Get non-preferred records and save as alternate values

          added_counter = 0
          error_counter = 0

          file.each_with_index do |row, i| # uses path & file from loop 1
            pref_id = row['PrefID']
            next if pref_id.to_i == 0 # handle only non-preferred records

            non_pref_family_name = row['FamilyName'] # use the non-preferred person's family name as default alternate name

            if get_tw_person_id[pref_id]
              puts "working with SF.PrefID: #{pref_id} (from SF.PersonID: #{row['PersonID']}), TW.person_id: #{get_tw_person_id[pref_id]}"
              # pref_person.alternate_values.new(value: non_pref_family_name, type: 'AlternateValue::AlternateSpelling', alternate_value_object_attribute: 'last_name')
              a = AlternateValue::AlternateSpelling.new(
                  alternate_value_object_type: 'Person',
                  alternate_value_object_id: get_tw_person_id[pref_id],
                  value: non_pref_family_name,
                  alternate_value_object_attribute: 'last_name'
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

        desc 'time rake tw:project_import:sf_import:start:create_users user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        LoggedTask.define :create_users => [:data_directory, :environment, :user_id] do |logger|

          logger.info 'Running create_users...'

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
          #     'AuthUserID' => Predicate.find_or_create_by(name: 'AuthUserID', definition: 'Unique user name id', project_id: $project_id)
          # }
          # Now that User is identifiable, we can use an identifier for the unique AuthUserID (vs. FileUserID)
          # Create Namespace for Identifier: Species File, tblAuthUsers, SF AuthUserID
          # 'Key3' => Namespace.find_or_create_by(name: '3i_Source_ID', short_name: '3i_Source_ID')     # 'Key3' was key in hash @data.keywords.merge! in 3i.rake ??
          auth_user_namespace = Namespace.find_or_create_by(institution: 'Species File', name: 'tblAuthUsers', short_name: 'SF AuthUserID')

          # find unique editors/admin, i.e. people getting users accounts in TW
          unique_auth_users = {} # unique sf.authorized users with edit+ access, not stored in Import, used only in this task
          sf_file_user_id_to_sf_auth_user_id = {} # not stored in Import; multiple file users map onto same auth user
          get_tw_user_id = {} # key = sf.file_user_id, value = tw.user_id
          get_sf_file_id = {} # key = sf.file_user_id, value sf.file_id; for future use when creating projects and project members

          @user_index = {}
          project_url = 'speciesfile.org'

          path = @args[:data_directory] + 'tblFileUsers.txt'
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'UTF-16:UTF-8')

          file.each_with_index do |row, i|
            au_id = row['AuthUserID']
            fu_id = row['FileUserID']
            next if [0, 8].freeze.include?(row['Access'].to_i)

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
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'UTF-16:UTF-8')

          error_counter = 0

          file.each_with_index do |row, i|
            au_id = row['AuthUserID']

            logger.info "working with AuthUser: #{au_id}"

            if unique_auth_users[au_id]
              logger.info "is a unique user, creating:  #{i}: #{row['Name']}"

              user = User.new(
                  name: row['Name'],
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
          import = Import.find_or_create_by(name: 'SpeciesFileData')
          import.set('SFFileUserIDToTWUserID', get_tw_user_id)
          import.set('SFFileUserIDToSFFileID', get_sf_file_id) # will be used when tables containing FileID are imported

          # display user mappings
          puts 'unique authorized users with edit+ access'
          ap unique_auth_users # list of unique authorized users (who have edit+ access via FileUserIDs)
          puts 'multiple FileUserIDs mapped to single AuthUserID'
          ap sf_file_user_id_to_sf_auth_user_id # map multiple FileUserIDs onto single AuthUserID
          puts 'SFFileUserIDToTWUserID'
          ap get_tw_user_id # map multiple FileUserIDs on single TW user.id
          puts 'SFFileUserIDToSFFileID'
          ap get_sf_file_id

        end

      end
    end
  end
end



