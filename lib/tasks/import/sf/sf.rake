require 'fileutils'

### rake tw:project_import:sf:import_all data_directory=/Users/mbeckman/src/onedb2tw/working/ no_transaction=true

namespace :tw do
  namespace :project_import do
    namespace :orth_sf do


      # desc 'this gets exported with rake --task'
      # task :import_all => [:environment, :project_id, :user_id, :create_otu] do
      #   puts "hello world"
      #   puts "my project id is #{$project_id}"
      #   puts "my user id is #{$user_id}"
      #
      #
      # end
      #
      # task :create_otu do
      #   otu = Otu.create!(name: 'my rake otu')
      #   puts "I created an OTU called #{otu.name}"
      # end

      task :create_project => [:environment, :user_id] do
        # @import_name = 'sf'
        @project = Project.create(name: 'Orthoptera Species File') # @project.id
        $project_id = @project.id
        @sf_file_id = 1 # OrthopteraSF FileID = 1
      end

      # example aggregate tasks
      # task :create_refs => [:environment, :create_users, :create_projects]   do
      #
      # end
      #
      # task :create_collection_objects => [:environment, :create_users, :create_projects] do
      #
      #
      # end
      #
      # task :master_loop => [:create_refs, :create_collection_objects] do
      #
      # end



      desc 'import users'
      task :import_users => [:data_directory, :environment, :user_id] do
        @user_index = {}
        @project = Project.find_by_name('Orthoptera Species File')

        predicates = {
            'FileUserID' => Predicate.create(name: 'tblFileUsers.FileUserID', definition: 'FileUserID in table tblFileUsers.') ,
            'FullName' => Predicate.create(name: 'tblFileUsers.FullName', definition: 'FullName in table tblFileUsers.') ,
            'TaxaShowspecs' => Predicate.create(name: 'tblFileUsers.TaxaShowspecs', definition: 'TaxaShowspecs in table tblFileUsers.')
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
        #
        #
        #

        # find unique editors/admin, i.e. people getting users accounts in TW

        unique_sf_users = {}

        sf_file_id_to_auth_user_id = {}

        path = @args[:data_directory] + 'tblFileUsers.txt'
        file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: "UTF-16:UTF-8")

        file.each_with_index do |row, i|
          au_id = row['AuthUserID']
          fu_id = row['FileUserID']
          next if row['Access'].to_i == 0  # probably not 8 either

          puts "WARNING - NON UNIQUE FileUserID" if sf_file_id_to_auth_user_id[fu_id]
          sf_file_id_to_auth_user_id[fu_id] = au_id

          if unique_sf_users[au_id]
            unique_sf_users[au_id].push fu_id
          else
            unique_sf_users[au_id] = [ fu_id ]
          end
        end

        puts unique_sf_users
        puts sf_file_id_to_auth_user_id

        file_user_id_to_tw_user_id = {}

        path = @args[:data_directory] + 'tblAuthUsers.txt'
        print "\nImporting users\n"
        raise "file #{path} not found" if not File.exists?(path)
        file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: "UTF-16:UTF-8")

        file.each_with_index do |row, i|
          au_id = row['AuthUserID']

          print "working with #{au_id}"


          if unique_sf_users[ au_id ]

            puts "\n  is a unique user, creating:  #{i}: #{row['Name']}"


            person_email = Faker::Internet.email

            u = User.new(
                name: row['Name'],
                password: '12345678',
                email: "#{person_email}"             # "me@myproject.com"

            )


            if u.valid?

              u.save!

              unique_sf_users[au_id].each do |fu_id|
                file_user_id_to_tw_user_id[fu_id] = u.id
              end

              @user_index[row['FileUserId']] = u.id
            else
              puts "     ERROR: " +  u.errors.full_messages.join(';')
            end
          else
            print " skipping, no access code\n"
          end
        end


        #  CollectionObjec.create(asfasdf, created_by: file_user_id_to_tw_user_id[row['CreatedBy'], updated_by: file_user_id_to_tw_user_id[row['ModifiedBy']]])



        ap file_user_id_to_tw_user_id

         # ProjectMember.create(user: u, project: @project)

         # %w{FileUserId FullName TaxaShowspecs}.each do |c|
         #   InternalAttribute.create(predicate: predicates[c], value: row[c], by: u, project: @project) if not row[c].blank?
         # end

          # u.projects << @project             # both of these lines equivalent to above
          # @project.project_members << u

          # att = DataAttribute.new(predicate: p, value: '6', type: 'InternalAttribute', attribute_subject: s, is_community_annotation: true)
          # u.data_attributes.new(type: 'InternalAttribute', controlled_vocabulary_term_id: @data.keywords['Typification'].id, value: ('Lectotype designation: ' + row['Author'].to_s + ', ' + row['Year'].to_s + row['YearRem'].to_s).squish)



      end


# A utility class to index data.
      class ImportedDataSf
        # attr_accessor :people_index, :user_index, :publications_index, :citations_index, :genera_index, :images_index,
        #               :parent_id_index, :statuses, :taxon_index, :citation_to_publication_index, :keywords,
        #               :incertae_sedis, :emendation, :original_combination, :unique_host_plant_index, :host_plant_index
        #
        # def initialize()
        #   @keywords = {} # keyword -> ControlledVocabularyTerm
        #   @people_index = {} # PeopleID -> Person object
        #   @user_index = {} # PeopleID -> User object
        #   @publications_index = {} # Key3 -> Surce object
        #   @citations_index = {} # NEW_REF_ID -> row
        #   @citation_to_publication_index = {} # NEW_REF_ID -> source.id
        #   @genera_index = {} # GENUS_NUMBER -> row
        #   @images_index = {} # TaxonNo -> row
        #   @parent_id_index = {} # Rank:TaxonName -> Taxon.id
        #   @statuses = {}
        #   @taxon_index = {} #Key -> Taxon.id
        #   @in
        certae_sedis = {} #for those taxa which have a parent of incertae sedis
        #   @emendation = {} # taxon name emendation source reference key => row
        #   @original_combination = {} # original combination key => row
        #   @unique_host_plant_index = {}
        #   @host_plant_index = {}
        # end
      end


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

