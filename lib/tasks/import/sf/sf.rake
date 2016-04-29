require 'fileutils'

### rake tw:project_import:orth_sf:create_users user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/ no_transaction=true

## check out default user_id if SF.FileUserID < 1

namespace :tw do
  namespace :project_import do
    namespace :species_file do

      desc 'create sources'
      task :create_sources => [:data_directory, :environment, :user_id] do

        # tblRefs columns to import: Title, PubID, Series, Volume, Issue, RefPages, ActualYear, StatedYear, LinkID, LastUpdate, ModifiedBy, CreatedOn, CreatedBy
        # tblRefs other columns: RefID => Source.identifier, FileID => used when creating ProjectSources, ContainingRefID => sfVerbatimRefs contains full
        #   RefStrings attached as data_attributes in ProjectSources (no need for ContainingRefID), AccessCode => n/a, Flags => identifies editor
        #   (use when creating roles and generating author string from tblRefAuthors), CiteDataStatus => can be derived, Verbatim => not used

        # Important note: Need crossref table between SF.PubID and SF.PubType to generate bibtex_type; PubType 1 = journal, 2 = not used, 3 = book or cd, 4 = unpublished source

        species_file_data = Import.find_or_create_by(name: 'SpeciesFileData')
        # get_person_id = species_file_data.get('SFPersonIDToTWPersonID') # not needed until roles
        get_user_id = species_file_data.get('FileUserIDToTWUserID') # for housekeeping
        get_serial_id = species_file_data.get('SFPubIDToTWSerialID') # for FK

        get_source_id = species_file_data.get('SFRefIDToTWSourceID') # cross ref hash
        get_source_id ||= {} # make empty hash if doesn't exist (otherwise it would be nil)
        sf_ref_id_to_tw_source_id = get_source_id

        # Namespace for Identifier
        source_namespace = Namespace.find_or_create_by(institution: 'Species File', name: 'tblRefs', short_name: 'SF RefID')

        path = @args[:data_directory] + 'tblRefs.txt'
        file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: "UTF-16:UTF-8")

        file.each_with_index do |row|

          source = Source::Bibtex.new(
              # bibtex_type: based_on_pub_type,
              title: row['Title'],
              serial_id: get_serial_id[row['PubID']],
              series: row['Series'],
              volume: row['Volume'],
              issue: row['Issue'],
              pages: row['RefPages'],
              year: row['ActualYear'],
              stated_year: row['StatedYear'],
              url: row['LinkID'],
              created_at: row['CreatedOn'],
              updated_at: row['LastUpdate'],
              created_by_id: get_user_id[row['CreatedBy']],
              updated_by_id: get_user_id[row['ModifiedBy']]
          )

        end

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
        # sf_person_id_to_tw_person_id ||= {}

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

