require 'fileutils'

### rake tw:project_import:sf:import_all data_directory=/Users/proceps/src/sf/import/3i/TXT/ no_transaction=true

namespace :tw do
  namespace :project_import do
    namespace :sf do



      desc 'this gets exported with rake --task'
      task :import_all => [:environment, :project_id, :user_id, :foo] do
        puts "hello world"
        puts "my project id is #{$project_id}"
        puts "my user id is #{$user_id}"
      end

      task :foo do
        Otu.create!(name: 'my rake otu')
        puts "I created an OTU!"
      end

      @import_name = 'sf'
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

