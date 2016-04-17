require 'fileutils'

### rake tw:project_import:orth_sf:import_users user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/ no_transaction=true

namespace :tw do
  namespace :project_import do
    namespace :orth_sf do

      task :create_project => [:environment, :user_id] do
        # @import_name = 'sf'
        @project = Project.create(name: 'Orthoptera Species File') # @project.id
        $project_id = @project.id
        @sf_file_id = 1 # OrthopteraSF FileID = 1
      end


      desc 'create users'
      task :create_users => [:data_directory, :environment, :user_id] do
        @user_index = {}
        @project = Project.find_by_name('Orthoptera Species File')
        $project_id = @project.id
        project_url = 'orthopteraspeciesfile.org'

        predicates = {
            'AuthUserID' => Predicate.find_or_create_by(name: 'AuthUserID', definition: 'Unique user name id', project_id: $project_id)
        }

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

        # find unique editors/admin, i.e. people getting users accounts in TW
        unique_auth_users = {}
        file_user_id_to_auth_user_id = {}
        file_user_id_to_tw_user_id = {}

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
        end

        puts unique_auth_users
        puts file_user_id_to_auth_user_id

        path = @args[:data_directory] + 'tblAuthUsers.txt'
        print "\nCreating users\n"
        raise "file #{path} not found" if not File.exists?(path)
        file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: "UTF-16:UTF-8")

        file.each_with_index do |row, i|
          au_id = row['AuthUserID']

          print "working with #{au_id}"

          if unique_auth_users[au_id]
            puts "\n  is a unique user, creating:  #{i}: #{row['Name']}"

            u = User.new(
                name: row['Name'],
                password: '12345678',
                email: 'auth_user_' + au_id.to_s + '_' + rand(1000).to_s + '@' + project_url
            )

            if u.valid?
              u.save!

              unique_auth_users[au_id].each do |fu_id|
                file_user_id_to_tw_user_id[fu_id] = u.id
              end

              @user_index[row['FileUserId']] = u.id # maps multiple FileUserIDs onto single TW user.id

              # create AuthUserID as data attribute for table users
              u.data_attributes << InternalAttribute.new(predicate: predicates['AuthUserID'], value: au_id)

              ProjectMember.create(user: u, project: @project)
            else
              puts "     ERROR: " + u.errors.full_messages.join(';')
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

      end

      desc 'create people'
      task :create_people => [:data_directory, :environment, :user_id] do
        @project = Project.find_by_name('Orthoptera Species File')
        $project_id = @project.id
        # project_url = 'orthopteraspeciesfile.org'

        path = @args[:data_directory] + 'tblPeople.txt'
        file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: "UTF-16:UTF-8")

        # Two loops:
        # Loop # 1
        # loop through entire table (22004 entries)
        # process only those rows where row['PrefID'] == 0
        # create person, how to assign original housekeeping (save hashes from create_users)?
        # save person, validate, etc.
        # save PersonID as identifier or data_attribute or ??
        # save Role (bitmap) as data_attribute (?) for later role assignment; Role & 256 = 256 should indicate name is deletable, but it is often incorrectly set!
        # make SF.PersonID and TW.person.id hash (for processing in second loop)
        #
        # Loop # 2
        # loop through entire table
        # process only those rows where row['PrefID'] > 0
        # identify tw.person.id via row['PrefID'] in hash
        # create alternate_value for tw.person.id using last_name only
        #



      end











      ##################################################################################################################
      def main_build_loop_sf
        print "\nStart time: #{Time.now}\n"

        @import = Import.find_or_create_by(name: @import_name)
        @import.metadata ||= {}
        @data = ImportedDataSf.new
        puts @args
        Utilities::Files.lines_per_file(Dir["#{@args[:data_directory]}/**/*.txt"])
        handle_projects_and_users_sf
        raise '$project_id or $user_id not set.' if $project_id.nil? || $user_id.nil?

        # handle_controlled_vocabulary_3i
        # handle_references_3i
        # handle_taxonomy_3i
        # # $project_id = 1
        # handle_taxon_name_relationships_3i
        # handle_host_plant_name_dictionary_3i
        # handle_host_plants_3i

        print "\n\n !! Success. End time: #{Time.now} \n\n"
      end

      def handle_projects_and_users_sf
        print "\nHandling projects and users "
        email = 'mbeckman@illinois.edu'
        project_name = 'OrthopteraSF'
        user_name = 'SF Import'

        $user_id, $project_id = nil, nil

        if @import.metadata['project_and_users']
          print "from database.\n"
          project = Project.where(name: project_name).first
          user = User.where(email: email).first
          $project_id = project.id
          $user_id = user.id
        else
          print "as newly parsed.\n"

          user = User.where(email: email)
          if user.empty?
            user = User.create(email: email, password: '0rth1234', password_confirmation: '0rth1234', name: user_name, self_created: true)
          else
            user = user.first
          end
          $user_id = user.id # set for project line below

          project = nil
          #project = Project.where(name: project_name).first #################### Comment fot creating a new one
          #project = Project.find(35)

          if project.nil?
            project = Project.create(name: project_name)
          end

          $project_id = project.id
          pm = ProjectMember.new(user: user, project: project, is_project_administrator: true)
          pm.save! if pm.valid?

          @import.metadata['project_and_users'] = true
        end

        @root = Protonym.find_or_create_by(name: 'Root', rank_class: 'NomenclaturalRank', project_id: $project_id)

        @data.keywords.merge!('sf_imported' => Keyword.find_or_create_by(name: 'sf_imported', definition: 'Imported from SF database.'))
      end

    end
  end
end

