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
            if row['AccessCode'].to_i != 0 or row['Status'].to_i != 0
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
                      identifier: "http://#{get_project_website_name[project_id]}.speciesfile.org/" +
                                  "Common/basic/ShowImage.aspx?ImageID=#{row['ImageID']}",
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

        # NOTE: Use argument 'no_images=1' if you want to create depictions without "uploading" the actual images (works much faster)
        desc 'time rake tw:project_import:sf_import:media:images user_id=1 data_directory=~/src/onedb2tw/working/'
        LoggedTask.define images: [:data_directory, :backup_directory, :environment, :user_id] do |logger|
          raise 'TASK NEEDS TO BE REIMPLEMENTED FROM SCRATCH'
          # TODO: SourceID not imported!

          # Images table (15 col)
          # id
          # user_file_name
          # height
          # width
          # image_file_fingerprint
          # image_file_file_name
          # image_file_content_type
          # image_file_file_size
          # image_file_updated_at
          # image_file_meta
          # housekeeping (including project_id)
          #
          # Depictions table (12 columns)
          # id
          # depiction_object_type/id (collection_object, otu)
          # image_id
          # position
          # caption
          # figure_label
          # housekeeping (including project_id)

          # SF.tblImages
          # ImageID
          # TrueID
          # FileID
          # SeqNum
          # TaxonNameID
          # Status
          # ImageTypeID
          # MIME
          # SexID
          # Description
          # SourceID
          # Figure
          # SpecimenID
          # Thumb
          # Xsize
          # Ysize
          # Image
          # AccessCode
          # (housekeeping)

          # have 187,172 taxon determinations (biological_collection_object_id, otu_id)

          # have 92,692 collection objects (collecting_event_id)


          import = Import.find_or_create_by(name: 'SpeciesFileData')
          skipped_file_ids = import.get('SkippedFileIDs')
          excluded_taxa = import.get('ExcludedTaxa')
          # get_sf_file_id = import.get('SFTaxonNameIDToSFFileID')
          get_sf_taxon_name_id = import.get('SFSpecimenIDToSFTaxonNameID')
          get_tw_project_id = import.get('SFFileIDToTWProjectID')
          # get_tw_person_id = import.get('SFPersonIDToTWPersonID')
          get_tw_user_id = import.get('SFFileUserIDToTWUserID') # for housekeeping
          get_tw_taxon_name_id = import.get('SFTaxonNameIDToTWTaxonNameID')
          get_taxon_name_otu_id = import.get('TWTaxonNameIDToOtuID')
          get_tw_collection_object_id = import.get('SFSpecimenIDToCollObjID')
          get_tw_otu_id = import.get('SFTaxonNameIDToTWOtuID') # an ill-formed SF taxon name

          # otu_id: get_otu_from_tw_taxon_id[tw_taxon_name_id]  # used for taxon_determination
          # get_tw_collection_object_id = {} # key = SF.SpecimenID, value = TW.collection_object.id OR TW.container.id (assign to all objects within a container)
          #
          #

          path_to_images = @args[:data_directory] + 'images/'
          counter = 0
          no_coll_count = 0
          no_otu_count = 0

          path = @args[:data_directory] + 'tblImages.txt'
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

          skipped_file_ids << 0

          default_images = {}

          file.each_with_index do |row, i|
            begin
              if row['AccessCode'].to_i != 0 or row['Status'].to_i != 0
                # HLP: Lets start by not exposing data that could potentially be part of a manuscript for now.
                # Emit a warning to remind us in the future of the missing images.
                logger.warn "Skipping ImageID = #{row['ImageID']}, AccessCode = #{row['AccessCode']}, Status = #{row['Status']}"
                next
              end

              sf_file_id = row['FileID']
              next if skipped_file_ids.include? sf_file_id.to_i

              sf_taxon_name_id = row['TaxonNameID']
              next if excluded_taxa.include? sf_taxon_name_id

              specimen_id = row['SpecimenID']
              project_id = get_tw_project_id[sf_file_id]

              #logger.info "ImageID = #{row['ImageID']}, SpecimenID = #{specimen_id}, SF.TaxonNameID = #{sf_taxon_name_id}, FileID = #{sf_file_id}"

              # not yet in db:collection_object_id = get_tw_collection_object_id[specimen_id] if specimen_id.to_i > 0

              tw_taxon_name_id = get_tw_taxon_name_id[sf_taxon_name_id] # may not exist
              otu_id = get_taxon_name_otu_id[tw_taxon_name_id].to_i
              collection_object_id = get_tw_collection_object_id[specimen_id] || []

              if collection_object_id.length > 1
                # Not dealing with SpecimenIDs split into multiple CollectionObjects at this time
                logger.warn "Skipping ImageID = #{row['ImageID']}, collection_object_id = #{collection_object_id}, SpecimenID = #{specimen_id}"
                next
              end

              collection_object_id = collection_object_id.first

              logger.info "ImageID = #{row['ImageID']}, SpecimenID = #{specimen_id}, SF.TaxonNameID = #{sf_taxon_name_id}, FileID = #{sf_file_id}" if otu_id.nil?

              # HLP: By the AccessCode contraint above, otu_id is never nil
              # if otu_id.nil?
              #  if specimen_id.to_i > 0
              #     otu_id = get_tw_otu_id[get_sf_taxon_name_id[specimen_id]]
              #  else  # assume there is a sf_taxon_name_id
              #      otu_id = get_tw_otu_id[sf_taxon_name_id]
              #  end
              # end


              logger.info "Working on SF.TaxonNameID = #{sf_taxon_name_id}, tw.taxon_name_id = #{tw_taxon_name_id}, SF.SpecimenID = #{specimen_id}, collection_object_id = #{collection_object_id}, otu_id = #{otu_id}, project_id = #{project_id}, counter = #{counter += 1}"
              logger.info "ImageID = #{row['ImageID']}, TrueID = #{row['TrueID']}, no_coll_count = #{no_coll_count}, no_otu_count = #{no_otu_count}"

              #if specimen_id.to_i > 0 && collection_object_id.nil? # 3895/124,719
              #  logger.warn "No collection object, counter = #{no_coll_count += 1}"
              #end
              #if otu_id.nil? # 347/124,719
              #  logger.warn "No otu, counter = #{no_otu_count += 1}"
              #end

              depiction_object = collection_object_id.nil? ? Otu.find(otu_id) : CollectionObject.find(collection_object_id)

              # depiction object: if collection_object_id not nil, use it, otherwise use otu_id
              depiction_attributes = {
                  created_at: row['CreatedOn'],
                  updated_at: row['LastUpdate'],
                  created_by_id: get_tw_user_id[row['CreatedBy']],
                  updated_by_id: get_tw_user_id[row['ModifiedBy']],
                  project_id: get_tw_project_id[row['FileID']],
                  depiction_object: depiction_object
              }
              project_id = get_tw_project_id[row['FileID']].to_i
              depiction = nil

              if ENV['no_images'].nil?
                File.open("#{@args[:data_directory]}/images/#{row['ImageID']}") do |file|
                  depiction = Depiction.create(
                      depiction_attributes.merge(
                          image_attributes: {image_file: file, project_id: project_id}
                      )
                  )
                end
              else
                image = default_images[project_id] ||
                    (default_images[project_id] = Image.create!({
                                                                    image_file: File.open('public/images/missing.jpg'),
                                                                    project_id: project_id
                                                                }))
                # Separate instances will be absolutely required later when adding attributions and other relations that may appear
                image = image.dup
                image.save!

                depiction = Depiction.create(depiction_attributes.merge({ image: image }))

                ##### Symlink image file from original Image to avoid broken <img> [WARNING: Deleting Image instance causes all of them to get broken]
                path = ('%09d' % image.id).scan /.{3}/
                FileUtils.mkdir_p 'public/system/images/image_files/' + path[0..1].join('/')
                FileUtils.ln_s(
                    '../../' + (('%09d' % default_images[project_id].id).scan /.{3}/).join('/'),
                    'public/system/images/image_files/' + path.join('/')
                )
                #####
              end
              logger.error "Error saving ImageID = #{row['ImageID']}: #{depiction.errors.full_messages}" unless depiction.errors.empty?

                # can have temporary name w/o OTU via taxon_name_id:  Find OTU via SF.TaxonNameID to TW.otu: if no SF.TaxonNameID, must be SF.SpecimenID, therefore get TW.TaxonNameID via SpecimenID and get the OTU that way.
                # Some no_otus have collection objects but still need otu whether co or not.
                # Have SFTaxonNameIDToTWOtuID  for ill-formed SF taxon names but need a look up from SF.SpecimenID to SF.TaxonNameID


                # if sf_taxon_name_id.to_i == 0
                #   puts "No SF.TaxonNameID"
                # end
                # if specimen_id.to_i == 0
                #   puts "No SF.SpecimenID"
                # end


                # object_ids = []
                # object_type = nil
                # determination_otu = nil
            rescue => exception
              logger.error "Unhandled exception ocurred while processing ImageID = #{row['ImageID']}\n\t#{exception.class}: #{exception.message}"
            end

          end


          # path_to_images = '/something'
          #
          #
          # rows.each do |row|
          #
          # project_id = .... something ...
          #
          # image_filename = row['SOMEThing']
          #
          # path = path_to_images + image_file_name
          # break if !File.exists?(path)
          #
          # image = File.read(path)
          #
          # a = get_tw_collection_object_id[row['SpecimenID']] # specimen  (tw CollectionObject)
          # b = get_tw_taxon_name_id[row['TaxonNameID']] taxon name (tw TaxonName)
          # c = get_taxon_name_otu_id[b] #  OTU from b
          #
          #
          #begin
          # Image.transaction do
          # i = Image.create!(image_file: image, ... creator etc ...)
          #
          # object_ids = []  #  the id of the depcition object
          # object_type = nil #
          #
          # determination_otu = nil
          #
          # if a && b && c
          #
          #   # Add the depiction to a
          #    object_ids = a
          #    object_type = 'CollectionObject'
          #
          #   # Maybe add a determination to the specimen with the
          #   # OTU that matches the taxon name if it doesn't exist
          #    if !TaxonDermination.where(collection_object_id: a, otu_id: c, project_id: project_id).any?
          #       determination_otu = c
          #    end
          #
          # elsif a && b
          #   object_ids = a
          #   object_type = 'CollectionObject'
          #
          #
          #   # could be simplified if every taxon name has an otu
          # o = Otu.where(taxon_name_id: b, project_id: project_id)
          # if o.any?
          #    if  !TaxonDermination.where(collection_object_id: a, otu_id: o.first.id, project_id: project_id).any?
          #       determination_otu = o.first.id
          #    end
          # else
          #   determination_otu = Otu.create!(taxon_name_id: b, project_id: project_id, ...).id
          # end
          #
          # elsif a
          #     ... there should be a c ... so it's OTU
          # elsif b  # (impossible, there is "always an a")
          #
          #   ... never should be hit, no code here
          #
          #
          #
          # else
          #    puts "error!"
          #    break
          # end
          #
          # object_ids.each do |id|
          #   Depiction.create!(depiction_object_id: id, depiction_object_type: object_type, 'image: i, .... creator etc. ...)
          # end
          #
          #  TaxonDetermination.create!(collection_object_id: a, otu_id: determination_otu, project_id: project_id) if determination_otu
          #
          #
          # end
          #
          # rescue ActiveRecord::RecordInvalid
          #   ...something
          # end
          #
          # end


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


      end
    end
  end
end
