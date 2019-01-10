namespace :tw do
  namespace :project_import do
    namespace :sf_import do
      require 'fileutils'
      require 'logged_task'
      namespace :media do

        desc 'time rake tw:project_import:sf_import:media:images user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        LoggedTask.define images: [:data_directory, :environment, :user_id] do |logger|

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
          get_sf_file_id = import.get('SFTaxonNameIDToSFFileID')
          get_sf_taxon_name_id = import.get('SFSpecimenIDToSFTaxonNameID')
          get_tw_project_id = import.get('SFFileIDToTWProjectID')
          get_tw_person_id = import.get('SFPersonIDToTWPersonID')
          get_tw_user_id = import.get('SFFileUserIDToTWUserID') # for housekeeping
          get_tw_taxon_name_id = import.get('SFTaxonNameIDToTWTaxonNameID')
          get_taxon_name_otu_id = import.get('TWTaxonNameIDToOtuID')
          get_tw_collection_object_id = import.get('SFSpecimenIDToCollObjID')
          get_tw_otu_id = import.get('SFTaxonNameIDToTWOtuID')  # an ill-formed SF taxon name

          # otu_id: get_otu_from_tw_taxon_id[tw_taxon_name_id]  # used for taxon_determination
          # get_tw_collection_object_id = {} # key = SF.SpecimenID, value = TW.collection_object.id OR TW.container.id (assign to all objects within a container)
          #
          #

          path_to_images = @args[:data_directory] + 'images/'
          counter = 0
          no_coll_count = 0
          no_otu_count = 0

          path = @args[:data_directory] + 'tblImages.txt'
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'UTF-16:UTF-8')

          file.each_with_index do |row, i|
            sf_file_id = row['FileID']
            next if skipped_file_ids.include? sf_file_id.to_i
            sf_taxon_name_id = row['TaxonNameID']
            next if excluded_taxa.include? sf_taxon_name_id
            specimen_id = row['SpecimenID']

            # check if specimen_id > 0, use that
            # else check if otu exists for sf_taxon_name_id ( Is it important to check if tw_taxon_name_id exists?  If otu only, just skip, too? )
            # if image assigned to specimen, forget about taxon_name_id
            # If specimen not real specimen (perhaps only a determination), should I assign to otu_id?  yes

            project_id = get_tw_project_id[sf_file_id]

            collection_object_id = get_tw_collection_object_id[specimen_id] if specimen_id.to_i > 0
            tw_taxon_name_id = get_tw_taxon_name_id[sf_taxon_name_id] # may not exist
            otu_id = get_taxon_name_otu_id[tw_taxon_name_id]

            if otu_id.nil?
              if specimen_id.to_i > 0
                 otu_id = get_tw_otu_id[get_sf_taxon_name_id[specimen_id]]
              else  # assume there is a sf_taxon_name_id
                  otu_id = get_tw_otu_id[sf_taxon_name_id]
              end
            end


            puts "Working on SF.TaxonNameID = #{sf_taxon_name_id}, tw.taxon_name_id = #{tw_taxon_name_id}, SF.SpecimenID = #{specimen_id}, collection_object_id = #{collection_object_id}, otu_id = #{otu_id}, project_id = #{project_id}, counter = #{counter += 1} \n"
            puts "ImageID = #{row['ImageID']}, TrueID = #{row['TrueID']}, no_coll_count = #{no_coll_count}, no_otu_count = #{no_otu_count} \n"

            if specimen_id.to_i > 0 && collection_object_id.nil? # 3895/124,719
              puts "No collection object, counter = #{no_coll_count += 1}"
            end
            if otu_id.nil? # 347/124,719
              puts "No otu, counter = #{no_otu_count += 1}"
            end


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
        # desc 'time rake tw:project_import:sf_import:media:specimen_to_taxon_name_ids user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        # LoggedTask.define specimen_to_taxon_name_ids: [:data_directory, :environment, :user_id] do |logger|
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
        #   file = CSV.read(path, col_sep: "\t", headers: true, encoding: 'UTF-16:UTF-8')
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

      end
    end
  end
end
