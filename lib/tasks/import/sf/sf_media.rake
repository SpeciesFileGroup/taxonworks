namespace :tw do
  namespace :project_import do
    namespace :sf_import do
      require 'fileutils'
      require 'logged_task'
      namespace :media do

        desc 'time rake tw:project_import:sf_import:media:image_files user_id=1 data_directory=~/src/onedb2tw/working/'
        LoggedTask.define image_files: [:data_directory, :backup_directory, :environment, :user_id] do |logger|
          import = Import.find_or_create_by(name: 'SpeciesFileData')
          skipped_file_ids = import.get('SkippedFileIDs')
          excluded_taxa = import.get('ExcludedTaxa')
          get_tw_project_id = import.get('SFFileIDToTWProjectID')
          get_tw_user_id = import.get('SFFileUserIDToTWUserID') # for housekeeping
          get_project_website_name = Project.all.map { |p| [p.id, p.name.scan(/^[^_]+/).first] }.to_h

          path = @args[:data_directory] + 'tblImages.txt'
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

          skipped_file_ids << 0

          default_images = {}

          CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8') do |row|
            unless [0, 7].include?(row['AccessCode'].to_i) or row['Status'].to_i == 0
              # HLP: Lets start by not exposing data that could potentially be part of a manuscript for now.
              # Emit a warning to remind us in the future of the missing images.
              logger.warn "Skipping ImageID = #{row['ImageID']}, AccessCode = #{row['AccessCode']}, Status = #{row['Status']}"
              next
            end
            next if skipped_file_ids.include? row['FileID'].to_i
            next if excluded_taxa.include? row['TaxonNameID']

            project_id = get_tw_project_id[row['FileID']].to_i

            begin
              File.open("#{@args[:data_directory]}/images/#{row['ImageID']}") do |image_file|
                Image.create!({
                  image_file: image_file,
                  project_id: project_id,
                  created_by_id: get_tw_user_id[row['CreatedBy']],
                  created_at: row['CreatedOn'],
                  updated_by_id: get_tw_user_id[row['ModifiedBy']],
                  updated_at: row['LastUpdate'],
                  identifiers: [
                    Identifier::Global.new(
                      identifier: image_identifier(get_project_website_name[project_id], row['ImageID']),
                      project_id: project_id,
                      created_by_id: get_tw_user_id[row['CreatedBy']],
                      updated_by_id: get_tw_user_id[row['ModifiedBy']]
                    )
                  ]
                })
              end
            rescue => exception
              logger.error "Unhandled exception ocurred while processing ImageID = #{row['ImageID']}\n\t#{exception.class}: #{exception.message}"
            end

          end

        end

        desc 'time rake tw:project_import:sf_import:media:image_data user_id=1 data_directory=~/src/onedb2tw/working/'
        LoggedTask.define image_data: [:data_directory, :backup_directory, :environment, :user_id] do |logger|
          import = Import.find_or_create_by(name: 'SpeciesFileData')
          get_tw_project_id = import.get('SFFileIDToTWProjectID')
          get_sf_taxon_name_id = import.get('SFSpecimenIDToSFTaxonNameID')
          get_tw_taxon_name_id = import.get('SFTaxonNameIDToTWTaxonNameID')
          get_taxon_name_otu_id = import.get('TWTaxonNameIDToOtuID')
          get_tw_collection_object_id = import.get('SFSpecimenIDToCollObjID')
          get_tw_otu_id = import.get('SFTaxonNameIDToTWOtuID') # an ill-formed SF taxon name
          get_sf_source_metadata = import.get('SFSourceMetadata')
          get_tw_source_id = import.get('SFRefIDToTWSourceID')
          get_project_website_name = Project.all.map { |p| [p.id, p.name.scan(/^[^_]+/).first] }.to_h

          source_reports = Set[]
          verbatim_sources = {}

          CSV.foreach(@args[:data_directory] + 'tblImages.txt', col_sep: "\t", headers: true, encoding: 'BOM|UTF-8') do |row|
            image = Image.joins(:identifiers).merge(
              Identifier.where(identifier: image_identifier(get_project_website_name[get_tw_project_id[row['FileID']].to_i], row['ImageID']))
            ).first
            
            unless image
              logger.info "ImageID = #{row['ImageID']}, AccessCode = #{row['AccessCode']}, Status = #{row['Status']} not found"
              next
            end

            tw_taxon_name_id = get_tw_taxon_name_id[row['TaxonNameID']] # may not exist
            specimen_id = row['SpecimenID']

            otu_id = get_taxon_name_otu_id[tw_taxon_name_id].to_i
            collection_object_ids = get_tw_collection_object_id[specimen_id] || []

            depiction_objects = collection_object_ids.empty? ? [Otu.find_by(id: otu_id)] : CollectionObject.where(id: collection_object_ids).all

            if depiction_objects.compact.empty?
              logger.error "Depiction object not found for ImageID = #{row['ImageID']}, TaxonNameID = #{row['TaxonNameID']}, SpecimenID = #{row['SpecimenID']}"
              next
            end

            ###
            ### Create depictions
            ###
            depiction_objects.each do |depiction_object|
              depiction = Depiction.create({
                depiction_object: depiction_object,
                figure_label: row['Figure'],
                caption: row['Description'],
                image: image,
                created_at: image.created_at,
                updated_at: image.updated_at,
                created_by_id: image.created_by_id,
                updated_by_id: image.updated_by_id,
                project_id: image.project_id
              })

              logger.error "Error saving ImageID = #{row['ImageID']}: #{depiction.errors.full_messages}" unless depiction.errors.empty?
            end

            ###
            ### Create image source
            ###
            source_id = row['SourceID']
            unless source_id == '0'
              source = get_sf_source_metadata[source_id]
              ref_id = source["ref_id"]

              if ref_id == '0'
                unless source['description'].empty?
                  source_id = (verbatim_sources[source_id] ||= Source::Verbatim.create!(verbatim: source['description']).id)
                else
                  source_reports << { reason: 'Empty description and no RefID', source: source }
                  next ###
                end
              else
                source_id = get_tw_source_id[ref_id]
                unless source['description'].empty?
                  Note.create!({
                    text: source['description'],
                    note_object: image,
                    created_at: image.created_at,
                    updated_at: image.updated_at,
                    created_by_id: image.created_by_id,
                    updated_by_id: image.updated_by_id,
                    project_id: image.project_id
                  })
                  source_reports << { reason: 'Description imported as note', source: source }
                end
              end

              citation = Citation.create({
                is_original: true,
                source_id: source_id,
                citation_object: image,
                created_at: image.created_at,
                updated_at: image.updated_at,
                created_by_id: image.created_by_id,
                updated_by_id: image.updated_by_id,
                project_id: image.project_id
              })

              logger.error "Error saving ImageID = #{row['ImageID']}, SourceID = #{row['SourceID']}: #{citation.errors.full_messages}" unless citation.errors.empty?
            end

          end

          logger.warn "Source reports", source_reports
        end

        # Following section now executed in sf_specimens.rake
        # desc 'time rake tw:project_import:sf_import:media:specimen_to_taxon_name_ids user_id=1 data_directory=~/src/onedb2tw/working/'
        # LoggedTask.define specimen_to_taxon_name_ids: [:data_directory, :backup_directory, :environment, :user_id] do |logger|
        #
        #   # First step is to make a SF.SpecimenID to SF.TaxonNameID hash
        #   # (so if tblImages has no TaxonNameID but has SpecimenID, regardless of presence of collection object, can find OTU via bad/ill-formed taxon name id)
        #   # Should probably move this to first instance of going through tblSpecimens
        #
        #   logger.info 'Running create SF.SpecimenID to SF.TaxonNameID hash...'
        #
        #   import = Import.find_or_create_by(name: 'SpeciesFileData')
        #   skipped_file_ids = import.get('SkippedFileIDs')
        #   excluded_taxa = import.get('ExcludedTaxa')
        #
        #   get_sf_taxon_name_id = {} # key = SF.SpecimenID, value = SF.TaxonNameID
        #
        #   path = @args[:data_directory] + 'tblSpecimens.txt'
        #   file = CSV.read(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')
        #
        #   file.each do |row|
        #     next if skipped_file_ids.include? row['FileID'].to_i
        #     sf_taxon_name_id = row['TaxonNameID']
        #     next if excluded_taxa.include? sf_taxon_name_id
        #
        #     specimen_id = row['SpecimenID']
        #
        #     logger.info "working with SF.SpecimenID = #{specimen_id}, SF.TaxonNameID = #{sf_taxon_name_id} \n"
        #
        #     get_sf_taxon_name_id[specimen_id] = sf_taxon_name_id
        #   end
        #
        #   import.set('SFSpecimenIDToSFTaxonNameID', get_sf_taxon_name_id)
        #
        #   puts 'SFSpecimenIDToSFTaxonNameID'
        #   ap get_sf_taxon_name_id
        # end


        desc 'time rake tw:project_import:sf_import:media:create_otu_website_links user_id=1 data_directory=~/src/onedb2tw/working/'
        LoggedTask.define create_otu_website_links: [:data_directory, :backup_directory, :environment, :user_id] do |logger|

          logger.info 'Running create_otu_website_links...'

          # [ERROR]2019-02-15 14:57:25.128: No OTU found for SF.TaxonNameID = 1127018, SF.FileID = 1
          # [ERROR]2019-02-15 14:57:58.072: No OTU found for SF.TaxonNameID = 1158091, SF.FileID = 4
          #     [ERROR]2019-02-15 14:57:58.072: No OTU found for SF.TaxonNameID = 1158092, SF.FileID = 4
          #
          #         Ran all tasks!
          #
          #         real	1m45.005s

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          skipped_file_ids = import.get('SkippedFileIDs')
          excluded_taxa = import.get('ExcludedTaxa')
          get_tw_taxon_name_id = import.get('SFTaxonNameIDToTWTaxonNameID')
          get_tw_project_id = import.get('SFFileIDToTWProjectID')
          get_tw_otu_id = import.get('SFTaxonNameIDToTWOtuID')
          get_taxon_name_otu_id = import.get('TWTaxonNameIDToOtuID')

          data_types = {}
          get_tw_project_id.each_value do |project_id|
            puts project_id
            data_type = Topic.create!(
                name: 'External links to websites',
                definition: 'External links to websites',
                project_id: project_id)
            data_types[project_id] = data_type.id
          end

          # ap data_types

          topic_map = {0 => 'general information', 1 => 'key', 2 => 'distribution map', 3 => 'specimen level information'}

          path = @args[:data_directory] + 'sfTaxonNameWebsiteLinks.txt'
          file = CSV.read(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

          file.each_with_index do |row, i|
            next if skipped_file_ids.include? row['FileID'].to_i
            sf_taxon_name_id = row['TaxonNameID']
            next if excluded_taxa.include? sf_taxon_name_id
            tw_taxon_name_id = get_tw_taxon_name_id[sf_taxon_name_id]
            otu_id = get_taxon_name_otu_id[tw_taxon_name_id]
            if otu_id.nil?
              otu_id = get_tw_otu_id[sf_taxon_name_id]
              if otu_id.nil?
                logger.error "No OTU found for SF.TaxonNameID = #{sf_taxon_name_id}, SF.FileID = #{row['FileID']}"
                next
              end
            end

            links_data_types = row['DataTypes'].to_i
            link_data_type_text = "[#{Utilities::Numbers.get_bits(links_data_types).collect {|i| topic_map[i]}.compact.join(', ')}]" if links_data_types > 0
            link = "* [#{row['Name']}](http://#{row['RootLink']}#{row['LinkSpecs']}) #{link_data_type_text}\n"
            project_id = get_tw_project_id[row['FileID']]

            logger.info "Working with SF.TaxonNameID = '#{row['TaxonNameID']}', TW.TaxonNameID = '#{tw_taxon_name_id}, otu_id = '#{otu_id}, SF.FileID = '#{row['FileID']}', DataTypes = '#{row['DataTypes']}' \n"

            content = nil
            if content = Content.where(topic_id: data_types[project_id], otu_id: otu_id, project_id: project_id).first
              content.update(text: content.text + link)
            else
              content = Content.create!(
                  topic_id: data_types[project_id],
                  otu_id: otu_id,
                  project_id: project_id,
                  text: link)
            end
          end
        end


        desc 'time rake tw:project_import:sf_import:media:create_common_names user_id=1 data_directory=~/src/onedb2tw/working/'
        LoggedTask.define create_common_names: [:data_directory, :backup_directory, :environment, :user_id] do |logger|

          logger.info 'Running create_common_names...'

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          skipped_file_ids = import.get('SkippedFileIDs')
          excluded_taxa = import.get('ExcludedTaxa')
          get_tw_taxon_name_id = import.get('SFTaxonNameIDToTWTaxonNameID')
          get_tw_project_id = import.get('SFFileIDToTWProjectID')
          get_tw_otu_id = import.get('SFTaxonNameIDToTWOtuID')
          get_taxon_name_otu_id = import.get('TWTaxonNameIDToOtuID')
          get_sf_taxon_info = import.get('SFTaxonNameIDMiscInfo')
          tw_language_hash = import.get('SFToTWLanguageHash')
          get_tw_user_id = import.get('SFFileUserIDToTWUserID') # for housekeeping

          path = @args[:data_directory] + 'tblCommonNames.txt'
          file = CSV.read(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

          file.each_with_index do |row, i|
            sf_taxon_name_id = row['TaxonNameID']
            sf_file_id = get_sf_taxon_info[sf_taxon_name_id]['file_id']
            next if skipped_file_ids.include? sf_file_id.to_i
            next if excluded_taxa.include? sf_taxon_name_id
            project_id = get_tw_project_id[sf_file_id]
            tw_taxon_name_id = get_tw_taxon_name_id[sf_taxon_name_id]
            otu_id = get_taxon_name_otu_id[tw_taxon_name_id]
            if otu_id.nil?
              otu_id = get_tw_otu_id[sf_taxon_name_id]
              if otu_id.nil?
                logger.error "No OTU found for SF.TaxonNameID = #{sf_taxon_name_id}, SF.FileID = #{row['FileID']}"
                next
              end
            end

            logger.info "Working with SF.TaxonNameID = '#{sf_taxon_name_id}', TW.TaxonNameID = '#{tw_taxon_name_id}, otu_id = '#{otu_id}, SF.FileID = '#{sf_file_id}', CommonName = '#{row['Name']}', LanguageID = #{row['LanguageID']} \n"

            cn = CommonName.create!(
                name: row['Name'],
                otu_id: otu_id,
                language_id: tw_language_hash[row['LanguageID']],
                project_id: project_id,
                created_at: row['CreatedOn'],
                updated_at: row['LastUpdate'],
                created_by_id: get_tw_user_id[row['CreatedBy']],
                updated_by_id: get_tw_user_id[row['ModifiedBy']]
            )

            # @todo: Do I need a SF to TW common name hash?

          end
        end

        desc 'time rake tw:project_import:sf_import:media:create_language_hash user_id=1 data_directory=~/src/onedb2tw/working/'
        LoggedTask.define create_language_hash: [:data_directory, :backup_directory, :environment, :user_id] do |logger|

          logger.info 'Running create_language_hash...'

          # Errors found:
          # === Summary of warnings and errors for task tw:project_import:sf_import:media:create_language_hash ===
          # [ERROR]2019-03-13 16:44:36.235: SF.LanguageID = 0, SF.Name = Unspecified, SF.LngAbbreviation =  [ errors = 1 ]
          # [ERROR]2019-03-13 16:44:36.289: SF.LanguageID = 72, SF.Name = Kyrgyz, SF.LngAbbreviation =  [ errors = 2 ]
          # [ERROR]2019-03-13 16:44:36.296: SF.LanguageID = 86, SF.Name = Moldavian, SF.LngAbbreviation = mo [ errors = 3 ]
          # [ERROR]2019-03-13 16:44:36.311: SF.LanguageID = 107, SF.Name = Serbo-Croatian, SF.LngAbbreviation = sh [ errors = 4 ]
          # [ERROR]2019-03-13 16:44:36.328: SF.LanguageID = 136, SF.Name = Unicode, SF.LngAbbreviation =  [ errors = 5 ]

          tw_language_hash = {} # key = SF.tblLanguages.ID, value = tw.languages.id

          error_count = 0

          path = @args[:data_directory] + 'tblLanguageList.txt'
          file = CSV.read(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

          file.each_with_index do |row, i|
            sf_language_id = row['LanguageID']
            sf_name = row['Name']
            sf_lng_abbreviation = row['LngAbbreviation']

            puts "Working on LanguageID = #{sf_language_id}, Name = #{sf_name}, Abbreviation = #{sf_lng_abbreviation}"

            tw_language = Language.find_by_english_name(sf_name)
            if tw_language.nil?
              # try matching to alpha-2
              tw_language = Language.find_by_alpha_2(sf_lng_abbreviation)
              if tw_language.nil?
                logger.error "SF.LanguageID = #{sf_language_id}, SF.Name = #{sf_name}, SF.LngAbbreviation = #{sf_lng_abbreviation} [ errors = #{error_count += 1} ]"
                next
              end
            end

            tw_language_hash[sf_language_id] = tw_language.id.to_s
          end

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          import.set('SFToTWLanguageHash', tw_language_hash)

          puts 'SFToTWLanguageHash'
          ap tw_language_hash
        end

        def image_identifier(website_name, image_id)
          "http://#{website_name}.speciesfile.org/Common/basic/ShowImage.aspx?ImageID=#{image_id}"
        end

      end
    end
  end
end
