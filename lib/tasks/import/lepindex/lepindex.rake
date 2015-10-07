require 'fileutils'

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


namespace :tw do
  namespace :project_import do
    namespace :lepindex do 

      task :import_all => [:data_directory, :environment] do |t| 
        ActiveRecord::Base.transaction do 
          begin

            # sets user_id/project_id
            @project, @user = initiate_project_and_users('Lepindex', 'i.kitching@nhm.ac.uk') 

            @namespace = Namespace.new(name: 'LEPINDEX', short_name: 'lepindex')
            @namespace.save!

            @predicates = {
              'PRINTED_DATE' => Predicate.create!(name: 'PRINTED_DATE', definition: 'Verbatim value from PRINTED_DATE in REFS_UNIQUE.'),
              'BHL_PAGE' =>  Predicate.create!(name: 'BHL_PAGE', definition: 'Verbatim value from BHL_PAGE in REFS_UNIQUE.'),
              'PART' =>  Predicate.create!(name: 'PART', definition: 'Verbatim value from PART in REFS_UNIQUE.'),
              'PUBLISHER_ADDRESS' =>  Predicate.create!(name: 'PUBLISHER_ADDRESS', definition: 'Verbatim value from PUBLISHER_ADDRESS in REFS_UNIQUE.'),
              'PUBLICATION_MONTH' =>  Predicate.create!(name: 'PUBLICATION_MONTH', definition: 'Verbatim value from PUBLICATION_MONTH in REFS_UNIQUE.'),
              'PUBLICATION_YEAR' =>  Predicate.create!(name: 'PUBLICATION_YEAR', definition: 'Verbatim value from PUBLICATION_YEAR in REFS_UNIQUE, indicates an error in value provided.')
            }
            
            # Rake::Task["tw:project_import:lepindex:handle_uniq"].execute
           
            Rake::Task["tw:project_import:lepindex:handle_viadocs"].execute
            #  Rake::Task["tw:project_import:lepindex:handle_master"].execute
            


            puts "\n\n !! Success \n\n"
            raise
          rescue
            raise
          end
        end
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



