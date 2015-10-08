require 'fileutils'

### rake tw:project_import:lepindex:import_all data_directory=/Users/proceps/src/sf/import/lep_index/ no_transaction=true

#
# VIADOCS.txt
#
# TaxonNo
# SCIENTIFIC_NAME_on_card
# Original_Author
# Original_Year
# Original_Genus
# OrigSubgen
# Original_Species
# Original_Subspecies
# Original_Infrasubspecies
# Availability
# Current_Rank
# valid_parent_id
# Current_superfamily
# Current_family
# Current_subfamily
# Current_tribe
# Current_subtribe
# Current_genus
# CurrSubgen
# Current_species
# Current_subspecies
# Current_author
# Current_year
# ButmothNo
# Last_changed_by
# Date_changed

# IMAGES.txt (LepIndex)
# TaxonNo
# Card_code
# Path
# Front_image
# Back_image

# BUTMOTH_SPECIESFILE_MASTER.txt (Butterflies & Moths Generic Index)
#
# Table BUTMOTH_SPECIESFILE_MASTER 
# GENUS_NUMBER
# GENUS_PAGE_COMMENT
# GENUS_MEMO
# GENUS_REF
# TS_REF
# TS_GENUS
# TS_SPECIES
# TS_AUTHOR
# TS_YEAR
# TS_PAGE_COMMENT
# TS_COUNTRY
# TS_LOCALITY
# TS_TYPE_STATUS
# TS_TYPE_DEPOSITORY
# TS_LECTOTYPE_BY
# TS_COMMENT
# TSD_REF
# TSD_DESIGNATION
# TSD_COMMENT

namespace :tw do
  namespace :project_import do
    namespace :lepindex do

      $import_name = 'lepindex'

      # A utility class to index data.
      class ImportedData
        attr_accessor :people_index, :user_index, :publications_index, :citations_index
        def initialize()
          @people_index = {}              # PeopleID -> Person object
          @user_index = {}                # PeopleID -> User object
          @publications_index = {}           # unique_fields hash -> Surce object
          @citations_index = {}              # NEW_REF_ID -> Source object
        end
      end

        task :import_all => [:data_directory, :environment] do |t|
        ActiveRecord::Base.transaction do 
          begin

            main_build_loop

            #@namespace = Namespace.new(name: 'LEPINDEX', short_name: 'lepindex')
            #@namespace.save!

            #@predicates = {
            #  'PRINTED_DATE' => Predicate.create!(name: 'PRINTED_DATE', definition: 'Verbatim value from PRINTED_DATE in REFS_UNIQUE.'),
            #  'BHL_PAGE' =>  Predicate.create!(name: 'BHL_PAGE', definition: 'Verbatim value from BHL_PAGE in REFS_UNIQUE.'),
            #  'PART' =>  Predicate.create!(name: 'PART', definition: 'Verbatim value from PART in REFS_UNIQUE.'),
            #  'PUBLISHER_ADDRESS' =>  Predicate.create!(name: 'PUBLISHER_ADDRESS', definition: 'Verbatim value from PUBLISHER_ADDRESS in REFS_UNIQUE.'),
            #  'PUBLICATION_MONTH' =>  Predicate.create!(name: 'PUBLICATION_MONTH', definition: 'Verbatim value from PUBLICATION_MONTH in REFS_UNIQUE.'),
            #  'PUBLICATION_YEAR' =>  Predicate.create!(name: 'PUBLICATION_YEAR', definition: 'Verbatim value from PUBLICATION_YEAR in REFS_UNIQUE, indicates an error in value provided.')
            #}
            
            # Rake::Task["tw:project_import:lepindex:handle_uniq"].execute
           
            # Rake::Task["tw:project_import:lepindex:handle_viadocs"].execute
            #  Rake::Task["tw:project_import:lepindex:handle_master"].execute
            


            puts "\n\n !! Success \n\n"
          rescue
            raise
          end
        end
      end

      def main_build_loop
        @import = Import.find_or_create_by(name: $import_name)
        @import.metadata ||= {}
        @data =  ImportedData.new
        puts @args
        Utilities::Files.lines_per_file(Dir["#{@args[:data_directory]}/**/*.txt"])
        handle_projects_and_users
        handle_references
        handle_list_of_genera

        raise '$project_id or $user_id not set.'  if $project_id.nil? || $user_id.nil?

      end

      def handle_projects_and_users
        print "Handling projects and users "
        #@project, @user = initiate_project_and_users('Lepindex', 'i.kitching@nhm.ac.uk')
        email = 'i.kitching@nhm.ac.uk'
        project_name = 'Lepindex'
        user_name = 'Lepindex Import'
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
            user = User.create(email: email, password: '3242341aas', password_confirmation: '3242341aas', name: user_name, self_created: true)
          else
            user = user.first
          end
          $user_id = user.id # set for project line below

          project = Project.where(name: project_name)
          if project.empty?
            project = Project.create(name: project_name)
          else
            project = project.first
          end

          $project_id = project.id
          pm = ProjectMember.new(user: user, project: project, is_project_administrator: true)
          pm.save! if pm.valid?

          @import.metadata['project_and_users'] = true
        end

        @data.user_index.merge!('0' => user)
        @data.user_index.merge!('' => user)
        @data.user_index.merge!(nil => user)

      end

      def handle_references
        # BUTMOTH_SPECIESFILE_REFS_UNIQUE.txt  (Butterflies & Moths Generic Index)
        #
        # # NEW_REF_ID
        # AUTHOR
        # IN_AUTHOR
        # PUBLICATION_YEAR
        # PUBLICATION_MONTH
        # PRINTED_DATE
        # FULLTITLE
        # PUBLISHER_ADDRESS
        # PUBLISHER_NAME
        # PUBLISHER_INSTITUTE
        # SERIES
        # VOLUME
        # PART
        # PAGE
        # BHLPage

        path = @args[:data_directory] + 'BUTMOTH_SPECIESFILE_REFS_UNIQUE.txt'
        print "\nHandling references\n"
        raise "file #{path} not found" if not File.exists?(path)
        file = CSV.foreach(path, col_sep: "\t", encoding: 'iso-8859-1:UTF-8', headers: true)

        unique_fields =%w{ AUTHOR IN_AUTHOR PUBLICATION_YEAR PUBLICATION_MONTH PRINTED_DATE FULLTITLE PUBLISHER_ADDRESS PUBLISHER_NAME
                        PUBLISHER_INSTITUTE SERIES VOLUME PART }

        month_list = %w{January Fabruary March April May June July August September October November December }

        file.each_with_index do |row, i|
          print "\r#{i}"

          tmp = {}
          unique_fields.each do |c|
            tmp.merge!(c => row[c]) unless row[c].blank?
          end

          if @data.publications_index[tmp].nil?
            url = row['BHLPage'].blank? ? nil : row['BHLPage']
            source = Source::Bibtex.new( address: tmp['PUBLISHER_ADDRESS'],
                                         publisher: tmp['PUBLISHER_NAME'],
                                         series: tmp['SERIES'],
                                         institution: tmp['PUBLISHER_INSTITUTE'],
                                         volume: tmp['VOLUME'],
                                         journal: tmp['FULLTITLE'],
                                         number: tmp['PART'],
                                         url: url,
                                         bibtex_type: 'article'
            )
            if tmp['PUBLICATION_YEAR'] =~/\A\d\d\d\d\z/
              source.year = tmp['PUBLICATION_YEAR']
            elsif !tmp['PUBLICATION_YEAR'].blank?
              source.data_attributes.new(import_predicate: 'PUBLICATION_YEAR', value: tmp['PUBLICATION_YEAR'], type: 'ImportAttribute')
            end
            if tmp['PRINTED_DATE'] =~/\A\d\d\d\d\z/
              source.stated_year = tmp['PRINTED_DATE']
            elsif !tmp['PRINTED_DATE'].blank?
              source.data_attributes.new(import_predicate: 'PRINTED_DATE', value: tmp['PRINTED_DATE'], type: 'ImportAttribute')
            end
            if month_list.include?(tmp['PUBLICATION_MONTH'])
              source.month = tmp['PUBLICATION_MONTH']
            elsif !tmp['PUBLICATION_MONTH'].blank?
              source.data_attributes.new(import_predicate: 'PUBLICATION_MONTH', value: tmp['PUBLICATION_MONTH'], type: 'ImportAttribute')
            end
            source.author = tmp['IN_AUTHOR'].blank? ? tmp['AUTHOR'] : tmp['IN_AUTHOR']

            source.save!
            @data.publications_index.merge! [tmp => source]
          else
            source = @data.publications_index[tmp]
          end
          @data.citations_index.merge![row['NEW_REF_ID'] => row]

        end

        puts "\nResolved \n #{@data.publications_index.keys.count} publications\n"

      end

      def handle_list_of_genera

      end


      def checkpoint_save(import)
        import.metadata_will_change!
        import.save
      end



      task :handle_viadocs=> [:data_directory, :environment] do |t| 
        path = @args[:data_directory] + 'VIADOCS.txt'
        raise "file #{path} not found" if not File.exists?(path)
        CSV.foreach(path, col_sep: "\t", encoding: 'iso-8859-1:UTF-8', headers: true) do |row|
          ap(row)
        end
      end

      task :handle_master=> [:data_directory, :environment] do |t| 
        path = @args[:data_directory] + 'BUTMOTH_SPECIESFILE_MASTER.txt'
        raise "file #{path} not found" if not File.exists?(path)
        CSV.foreach(path, col_sep: "\t", encoding: 'iso-8859-1:UTF-8', headers: true) do |row|
          ap(row)
        end
      end

      # references
      task :handle_uniq=> [:data_directory, :environment] do |t| 
        path = @args[:data_directory] + 'BUTMOTH_SPECIESFILE_REFS_UNIQUE.txt'
        raise "file #{path} not found" if not File.exists?(path)
      
        base_data_attributes = %w{PRINTED_DATE PART PUBLISHER_ADDRESS PUBLICATION_MONTH BHL_PAGE}

        i = 0
        CSV.foreach(path, col_sep: "\t", encoding: 'iso-8859-1:UTF-8', headers: true) do |r|
          i += 1

          next if i < 45517 
          
          error_attributes = []

          print "\r      #{i}"
 #          ap r

          author = r['IN_AUTHOR'].blank? ? r['AUTHOR'] : r['IN_AUTHOR']  

          year = r['PUBLICATION_YEAR']
          unless year =~/\A\d\d\d\d\z/
            error_attributes.push('PUBLICATION_YEAR')
            year = nil
          end

          attributes = {
            bibtex_type: 'article',
            author: author,
            year: year,
            title: r['FULLTITLE'],
            publisher: r['PUBLISHER_NAME'],
            institution: r['PUBLISHER_INSTITUTE'],
            volume: r['VOLUME'],
            series: r['SERIES'],
            pages: r['PAGE'],
            data_attributes_attributes: []
          }

          (base_data_attributes + error_attributes).each do |v|
           attributes[:data_attributes_attributes].push({ predicate: @predicates[v], type: 'InternalAttribute', value: r[v] }) if r[v]
         end

         Source::Bibtex.create!(attributes)

        end
      end
    end
  end
end



