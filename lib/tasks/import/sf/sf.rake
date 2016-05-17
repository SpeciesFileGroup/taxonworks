require 'fileutils'

### rake tw:project_import:species_file:create_users user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/ no_transaction=true

## check out default user_id if SF.FileUserID < 1

namespace :tw do
  namespace :project_import do
    namespace :species_file do

      # Next step: Generate individual SF projects (based on FileID) and populate ProjectSources with FileID=>project_id, source_id
      #   Create all projects at once?
      #   Will need a SF.FileID to TW.project_id hash
      #   Add data_attribute to ProjectSources from sfVerbatimRefs (this is instead of dealing with tblRefs.ContainingRefID)
      #   Add tblRefs.Note as?
      #   Currently ProjectSources do not allow data_attributes or notes         \

      desc 'create  projects'
      task :create_projects => [:data_directory, :environment, :user_id] do
        ### rake tw:project_import:species_file:create_projects user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/

        # @todo .humanize did not make string lower case, having problem creating identifier (data_attribute) containing FileID for each project_id

        species_file_data = Import.find_or_create_by(name: 'SpeciesFileData')
        # Is it really really necessary to track original creator, etc? Don't think so.
        # get_user_id = species_file_data.get('FileUserIDToTWUserID') # for housekeeping
        get_project_id = species_file_data.get('SFFileIDToTWProjectID') # cross ref hash
        get_project_id ||= {} # make empty hash if doesn't exist (otherwise it would be nil)
        sf_file_id_to_tw_project_id = get_project_id

        # file_namespace = Namespace.find_or_create_by(institution: 'Species File', name: 'tblFiles', short_name: 'SF FileID')
        # $user_id = user_id

        path = @args[:data_directory] + 'tblFiles.txt'
        file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: "UTF-16:UTF-8")

        file.each_with_index do |row, i|
          file_id = row['FileID']
          next if file_id == 0

          website_name = row['WebsiteName'].humanize  # want to be lower case
          project = Project.new(
              name: "#{website_name}_species_file",
              created_at: Time.now, # row['CreatedOn'],
              updated_at: Time.now, # row['LastUpdate'],
              created_by_id: $user_id, # get_user_id[row['CreatedBy']],
              updated_by_id: $user_id # get_user_id[row['ModifiedBy']]
          )

          if project.valid?
            project.save!

            # project.identifiers << Identifier::Local::Import.new(namespace: file_namespace, identifier: file_id)
            sf_file_id_to_tw_project_id[file_id] = project.id

          else
            error_counter += 1
            puts "     ERROR (#{error_counter}): " + source.errors.full_messages.join(';')
            puts "  FileID: #{file_id}, sf row created by: #{row['CreatedBy']}, sf row updated by: #{row['ModifiedBy']}    "
          end
        end

        # Write sf_file_id_to_tw_project_id to Imports
        species_file_data.set('SFFileIDToTWProjectID', sf_file_id_to_tw_project_id)
        puts 'SF.FileID to TW.project_id'
        ap sf_file_id_to_tw_project_id

      end

      desc 'create sources'
      task :create_sources => [:data_directory, :environment, :user_id] do
        ### rake tw:project_import:species_file:create_sources user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/

        # @todo Decided not to add identifiers or data_attributes for RefID and FileID for now. Can always be done at a later time.

        # tblRefs columns to import: Title, PubID, Series, Volume, Issue, RefPages, ActualYear, StatedYear, LinkID, LastUpdate, ModifiedBy, CreatedOn, CreatedBy
        # tblRefs other columns: RefID => Source.identifier, FileID => used when creating ProjectSources, ContainingRefID => sfVerbatimRefs contains full
        #   RefStrings attached as data_attributes in ProjectSources (no need for ContainingRefID), AccessCode => n/a, Flags => identifies editor
        #   (use when creating roles and generating author string from tblRefAuthors), Note => attach to ProjectSources, CiteDataStatus => can be derived,
        #   Verbatim => not used

        species_file_data = Import.find_or_create_by(name: 'SpeciesFileData')
        # get_person_id = species_file_data.get('SFPersonIDToTWPersonID') # not needed until roles
        get_user_id = species_file_data.get('FileUserIDToTWUserID') # for housekeeping
        get_serial_id = species_file_data.get('SFPubIDToTWSerialID') # for FK
        get_pub_type = species_file_data.get('SFPubIDToPubType') # = bibtex_type (1=journal=>article, 2=unused,3=book or cd=>book, 4=unpublished source=>unpublished)
        get_ref_link = species_file_data.get('RefIDToRefLink') # key is SF.RefID, value is URL string
        get_verbatim_ref = species_file_data.get('RefIDToVerbatimRef') # key is SF.RefID, value is verbatim string
        no_ref_list = species_file_data.get('SFNoRefList') # contains array of RefInRef ids w/only author info

        get_source_id = species_file_data.get('SFRefIDToTWSourceID') # cross ref hash
        get_source_id ||= {} # make empty hash if doesn't exist (otherwise it would be nil)
        sf_ref_id_to_tw_source_id = get_source_id

        # byebug

        # Namespace for Identifier
        # source_namespace = Namespace.find_or_create_by(institution: 'Species File', name: 'tblRefs', short_name: 'SF RefID')

        error_counter = 0

        path = @args[:data_directory] + 'tblRefs.txt'
        file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: "UTF-16:UTF-8")

        file.each_with_index do |row, i|
          # break if i == 20    # not sure this is breaking?? How did it get around no auth and stated year range??

          ref_id = row['RefID']
          next if no_ref_list.include?(ref_id)

          actual_year = row['ActualYear']
          actual_year = nil if actual_year == '0'
          stated_year = row['StatedYear']
          stated_year = nil if stated_year == '0'

          if actual_year.include?('-') or stated_year.include?('-')
            # create a verbatim source
            source = Source::Verbatim.new(
                verbatim: get_verbatim_ref[ref_id],
                # url: row['LinkID'].to_i > 0 ? get_ref_link[ref_id] : nil,   # Not compatible with verbatim
                created_at: row['CreatedOn'],
                updated_at: row['LastUpdate'],
                created_by_id: get_user_id[row['CreatedBy']],
                updated_by_id: get_user_id[row['ModifiedBy']]
            )
          else
            source = Source::Bibtex.new(
                bibtex_type: get_pub_type[row['PubID']],
                title: row['Title'],
                serial_id: get_serial_id[row['PubID']],
                series: row['Series'],
                volume: row['Volume'],
                number: row['Issue'],
                pages: row['RefPages'],
                year: actual_year,
                stated_year: row['StatedYear'],
                url: row['LinkID'].to_i > 0 ? get_ref_link[ref_id] : nil,
                created_at: row['CreatedOn'],
                updated_at: row['LastUpdate'],
                created_by_id: get_user_id[row['CreatedBy']],
                updated_by_id: get_user_id[row['ModifiedBy']]
            )
          end

          if source.valid?
            source.save!

            # source.identifiers << Identifier::Local::Import.new(namespace: source_namespace, identifier: ref_id)
            sf_ref_id_to_tw_source_id[ref_id] = source.id

          else
            error_counter += 1
            puts "     ERROR (#{error_counter}): " + source.errors.full_messages.join(';')
            puts "  RefID: #{ref_id}, sf row created by: #{row['CreatedBy']}, sf row updated by: #{row['ModifiedBy']}    "
          end
        end

        # Write sf_ref_id_to_tw_source_id to Imports
        species_file_data.set('SFRefIDToTWSourceID', sf_ref_id_to_tw_source_id)
        puts 'SF.RefID to TW.source_id'
        ap sf_ref_id_to_tw_source_id

      end

      desc 'list SF.RefID to VerbatimRefString'
      task :list_verbatim_refs => [:data_directory, :environment, :user_id] do
        ### rake tw:project_import:species_file:list_verbatim_refs user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/direct_from_sf/
        ref_id_to_verbatim_ref = {}

        path = @args[:data_directory] + 'sf_verbatim_refs.txt'
        file = CSV.read(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

        file.each do |row|
          # byebug
          # puts row.inspect
          ref_id = row['RefID']
          print "working with #{ref_id} \n"
          ref_id_to_verbatim_ref[ref_id] = row['RefString']
        end

        i = Import.find_or_create_by(name: 'SpeciesFileData')
        i.set('RefIDToVerbatimRef', ref_id_to_verbatim_ref)

        puts 'RefID to VerbatimRef'
        ap ref_id_to_verbatim_ref

      end

      desc 'map SF.RefID to Link URL'
      task :map_ref_link => [:data_directory, :environment, :user_id] do
        ### rake tw:project_import:species_file:map_ref_link user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/direct_from_sf/
        ref_id_to_ref_link = {}

        path = @args[:data_directory] + 'ref_id_to_ref_link.txt'
        file = CSV.read(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

        file.each do |row|
          # byebug
          # puts row.inspect
          ref_id = row['RefID']
          print "working with #{ref_id} \n"
          ref_id_to_ref_link[ref_id] = row['RefLink']
        end

        i = Import.find_or_create_by(name: 'SpeciesFileData')
        i.set('RefIDToRefLink', ref_id_to_ref_link)

        puts 'RefID to Link URL'
        ap ref_id_to_ref_link

      end

      desc 'make array from no_ref_list'
      task :create_no_ref_list_array => [:data_directory, :environment, :user_id] do
        ### rake tw:project_import:species_file:create_no_ref_list_array user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/direct_from_sf/
        sf_no_ref_list = []

        path = @args[:data_directory] + 'no_ref_list.txt'
        file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'UTF-8')

        file.each do |row|
          sf_no_ref_list.push(row[0])
        end

        i = Import.find_or_create_by(name: 'SpeciesFileData')
        i.set('SFNoRefList', sf_no_ref_list)

        puts 'SF no_ref_list'
        ap sf_no_ref_list

      end

      desc 'map SF.PubID by SF.PubType'
      task :map_pub_type => [:data_directory, :environment, :user_id] do
        sf_pub_id_to_pub_type = {}

        path = @args[:data_directory] + 'tblPubs.txt'
        file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: "UTF-16:UTF-8")

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

          sf_pub_id_to_pub_type[row['PubID']] = pub_type_string
        end

        i = Import.find_or_create_by(name: 'SpeciesFileData')
        i.set('SFPubIDToPubType', sf_pub_id_to_pub_type)

        puts 'SF.PubID to PubType'
        ap sf_pub_id_to_pub_type

      end

      desc 'map SF.PubID to TW.serial_id'
      task :map_serials => [:data_directory, :environment, :user_id] do
        # Build hash similar to file_user_id_to_tw_user_id for SF.PubID (many) to one TW.serial_id
        # DataAttributes associated with a serial record contain multiple SF.PubIDs

        # [4/26/16, 3:21:24 PM] diapriid: erial.includes(:data_attributes).where(data_attributes: {value: 18151, controlled_vocabulary_term_id: 999}).first
        # [4/26/16, 3:22:37 PM] diapriid: Serial.includes(:data_attributes).where(data_attributes: {value: 18151, import_predicate: 'SF ID'}).first
        # [4/26/16, 3:22:50 PM] diapriid: a =  Serial.includes(:data_attributes).where(data_attributes: {value: 18151, import_predicate: 'SF ID'}).first
        # [4/26/16, 3:22:53 PM] diapriid: a.id

        # pubs = DataAttribute.where(import_predicate: 'SF ID', attribute_subject_type: 'Serial').limit(10).pluck(:value, :attribute_subject_id)
        sf_pub_id_to_tw_serial_id = DataAttribute.where(import_predicate: 'SF ID', attribute_subject_type: 'Serial').pluck(:value, :attribute_subject_id).to_h

        i = Import.find_or_create_by(name: 'SpeciesFileData')
        i.set('SFPubIDToTWSerialID', sf_pub_id_to_tw_serial_id)

        puts 'SF.PubID to TW.serial_id'
        ap sf_pub_id_to_tw_serial_id
      end

      desc 'create people'
      task :create_people => [:data_directory, :environment, :user_id] do

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

        species_file_data = Import.find_or_create_by(name: 'SpeciesFileData')
        get_person_id = species_file_data.get('SFPersonIDToTWPersonID') # use in loop 2
        get_person_id ||= {} # make empty hash if doesn't exist (otherwise it would be nil)
        sf_person_id_to_tw_person_id = get_person_id

        get_user_id = species_file_data.get('FileUserIDToTWUserID') # for housekeeping

        # create Namespace for Identifier (used in loop below): Species File, tblPeople, SF PersonID
        # 'Key3' => Namespace.find_or_create_by(name: '3i_Source_ID', short_name: '3i_Source_ID')     # 'Key3' was key in hash @data.keywords.merge! ??
        # auth_user_namespace = Namespace.find_or_create_by(institution: 'Species File', name: 'tblAuthUsers', short_name: 'SF AuthUserID')
        person_namespace = Namespace.find_or_create_by(institution: 'Species File', name: 'tblPeople', short_name: 'SF PersonID')

        # No longer using InternalAttribute for following import values; using ImportAttribute instead since it doesn't require a project_id
        # file_id = Predicate.find_or_create_by(name: 'FileID', definition: 'SpeciesFile.FileID', project_id: $project_id)
        # person_roles = Predicate.find_or_create_by(name: 'Roles', definition: 'Bitmap of person roles', project_id: $project_id)

        path = @args[:data_directory] + 'tblPeople.txt'
        file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: "UTF-16:UTF-8")

        # loop 1

        file.each_with_index do |row, i|
          person_id = row['PersonID']
          next if get_person_id[person_id] # do not create if already exists

          pref_id = row['PrefID']
          next if pref_id.to_i > 0 # alternate spellings will be handled in second loop

          print "working with #{person_id} \n"

          person = Person::Vetted.create(
              # type: 'Person_Vetted',
              last_name: row['FamilyName'],
              first_name: row['GivenName'].blank? ? row['GivenInitials'] : row['GivenName'],
              created_at: row['CreatedOn'],
              updated_at: row['LastUpdate'],
              suffix: row['Suffix'],
              # prefix: '',
              created_by_id: get_user_id[row['CreatedBy']],
              updated_by_id: get_user_id[row['ModifiedBy']]
              # cached: '?'
          )

          # person.created_by_id ||= $user_id
          # person.updated_by_id ||= $user_id

          if person.valid?
            person.save!

            # person.data_attributes << InternalAttribute.new(predicate: file_id, value: row['FileID'])
            person.data_attributes << ImportAttribute.new(import_predicate: 'FileID', value: row['FileID'])
            # person.data_attributes << InternalAttribute.new(predicate: person_roles, value: row['Role'])
            person.data_attributes << ImportAttribute.new(import_predicate: 'Role', value: row['Role'])

            # person.identifiers.new(type: 'Identifier::Local::Import', namespace: person_namespace, identifier: person_id)
            person.identifiers << Identifier::Local::Import.new(namespace: person_namespace, identifier: person_id)

            sf_person_id_to_tw_person_id[person_id] = person.id

          else
            puts "     ERROR: " + person.errors.full_messages.join(';')
            puts " sf row created by: #{row['CreatedBy']}, sf row updated by: #{row['ModifiedBy']}    "
          end

        end

        species_file_data.set('SFPersonIDToTWPersonID', sf_person_id_to_tw_person_id) # write to db
        puts 'SF PersonID mapped to TW person_id'
        ap sf_person_id_to_tw_person_id

        # loop 2

        file.each_with_index do |row, i|
          pref_id = row['PrefID']
          next if pref_id.to_i == 0 # handle only alternate spellings

          non_pref_family_name = row['FamilyName'] # the non-preferred person's family name

          if get_person_id[pref_id]
            puts "working with #{get_person_id[pref_id]}"
            # pref_person.alternate_values.new(value: non_pref_family_name, type: 'AlternateValue::AlternateSpelling', alternate_value_object_attribute: 'last_name')
            a = AlternateValue::AlternateSpelling.new(
                alternate_value_object_type: 'Person',
                alternate_value_object_id: get_person_id[pref_id],
                value: non_pref_family_name,
                alternate_value_object_attribute: 'last_name'
            )
            if a.valid?
              a.save!
              puts "added attribute"
            else
              puts "invalid attribute"
            end

          end
        end

      end

      desc 'create users'
      task :create_users => [:data_directory, :environment, :user_id] do
        @user_index = {}
        # @project = Project.find_by_name('Orthoptera Species File')
        # $project_id = @project.id
        project_url = 'speciesfile.org'

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
        unique_auth_users = {}
        file_user_id_to_auth_user_id = {}
        file_user_id_to_tw_user_id = {}
        file_user_id_to_file_id = {} # not creating projects and project members right now; store info for future use

        path = @args[:data_directory] + 'tblFileUsers.txt'
        file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: "UTF-16:UTF-8")

        file.each_with_index do |row, i|
          au_id = row['AuthUserID']
          fu_id = row['FileUserID']
          next if [0, 8].freeze.include?(row['Access'].to_i) # next if row['Access'].to_i == 0 # probably not 8 either

          puts "WARNING - NON UNIQUE FileUserID" if file_user_id_to_auth_user_id[fu_id]
          file_user_id_to_auth_user_id[fu_id] = au_id

          if unique_auth_users[au_id]
            unique_auth_users[au_id].push fu_id
          else
            unique_auth_users[au_id] = [fu_id]
          end

          file_user_id_to_file_id[fu_id] = row['FileID']
        end

        path = @args[:data_directory] + 'tblAuthUsers.txt'
        print "\nCreating users\n"
        raise "file #{path} not found" if not File.exists?(path)
        file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: "UTF-16:UTF-8") # should it be read, not foreach?

        file.each_with_index do |row, i|
          au_id = row['AuthUserID']

          print "working with #{au_id}"

          if unique_auth_users[au_id]
            puts "\n  is a unique user, creating:  #{i}: #{row['Name']}"

            user = User.new(
                name: row['Name'],
                password: '12345678',
                email: 'auth_user_id' + au_id.to_s + '_random' + rand(1000).to_s + '@' + project_url
            )

            if user.valid?
              user.save!

              unique_auth_users[au_id].each do |fu_id|
                file_user_id_to_tw_user_id[fu_id] = user.id
              end

              @user_index[row['FileUserId']] = user.id # maps multiple FileUserIDs onto single TW user.id

              # create AuthUserID as DataAttribute as InternalAttribute for table users
              # user.data_attributes << InternalAttribute.new(predicate: predicates['AuthUserID'], value: au_id)
              # Now using an identifier for this:
              user.identifiers.new(type: 'Identifier::Local::Import', namespace: auth_user_namespace, identifier: au_id)

              # Do not create project_members right now; store hash of file_user_id => file_id in Import table
              # ProjectMember.create(user: user, project: @project)


            else
              puts "     ERROR: " + user.errors.full_messages.join(';')
            end

          else
            print " skipping, public access only\n"
          end
        end

        # display user mappings
        puts 'unique authorized users with edit+ access'
        ap unique_auth_users # list of unique authorized users (who have edit+ access via FileUserIDs)
        puts 'multiple FileUserIDs mapped to single AuthUserID'
        ap file_user_id_to_auth_user_id # map multiple FileUserIDs onto single AuthUserID
        puts 'multiple FileUserIDs mapped to single TW user.id'
        ap file_user_id_to_tw_user_id # map multiple FileUserIDs on single TW user.id
        puts 'FileUserIDs mapped to FileID'
        ap file_user_id_to_file_id

        # Save the file user mappings to the import table
        i = Import.find_or_create_by(name: 'SpeciesFileData')
        i.set('FileUserIDToTWUserID', file_user_id_to_tw_user_id)
        i.set('FileUserIDToFileID', file_user_id_to_file_id) # will be used when tables containing FileID are imported
        # newvar = i.get('FileUserIDToTWUserID')
        # mytwuserid = newvar[560]
      end

      desc 'No need to create project for users, people, and refs'
      task :create_project => [:environment, :user_id] do
        # @import_name = 'sf'
        # @project = Project.create(name: 'Orthoptera Species File') # @project.id
        # $project_id = @project.id
        # @sf_file_id = 1 # OrthopteraSF FileID = 1
      end

    end
  end
end


