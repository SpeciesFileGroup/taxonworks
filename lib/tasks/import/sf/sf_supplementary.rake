desc 'time rake tw:project_import:sf_import:supplementary:taxon_info user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
LoggedTask.define taxon_info: [:data_directory, :environment, :user_id] do |logger|

  logger.info 'Creating list of taxa with AccessCode = 4'
  taxa_access_code_4 = [1143399, 1143399, 1143402, 1143402, 1143403, 1143403, 1143403, 1143404, 1143405, 1143406, 1143408, 1143414, 1143415, 1143416, 1143417, 1143418, 1143419, 1143420, 1143421, 1143422, 1143423, 1143425, 1143430, 1143431, 1143434, 1143435, 1143436, 1143437, 1143438, 1207769, 1232866]

  logger.info 'Importing SupplementaryTaxonInformation...'

  import = Import.find_or_create_by(name: 'SpeciesFileData')
  skipped_file_ids = import.get('SkippedFileIDs')
  get_sf_file_id = import.get('SFTaxonNameIDToSFFileID')
  get_tw_user_id = import.get('SFFileUserIDToTWUserID') # for housekeeping
  get_tw_taxon_name_id = import.get('SFTaxonNameIDToTWTaxonNameID')
  get_tw_otu_id = import.get('SFTaxonNameIDToTWOtuID') # Note this is an OTU associated with a SF.TaxonNameID (probably a bad taxon name)
  get_taxon_name_otu_id = import.get('TWTaxonNameIDToOtuID') # Note this is the OTU offically associated with a real TW.taxon_name_id
  get_tw_source_id = import.get('SFRefIDToTWSourceID')
  get_sf_verbatim_ref = import.get('RefIDToVerbatimRef') # key is SF.RefID, value is verbatim string

  otu_not_found_array = []
  # are items in title_keywords array processed in order?
  title_keywords = ['abstract', 'comment', 'description', 'diagnosis', 'distribution', 'ecology', 'etymology', 'figure', 'gender', 'horizon', 'note', 'synonymy', 'type']

  path = @args[:data_directory] + 'tblSupplTaxonInfo.txt'
  file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'UTF-16:UTF-8')

  file.each_with_index do |row, i|
    next if taxa_access_code_4.include? row['TaxonNameID'].to_i
    sf_taxon_name_id = row['TaxonNameID']
    sf_file_id = row['FileID'] # get_sf_file_id[sf_taxon_name_id]
    next if skipped_file_ids.include? sf_file_id.to_i
    taxon_name_id = get_tw_taxon_name_id[sf_taxon_name_id] # cannot to_i because if nil, nil.to_i = 0

    if taxon_name_id.nil?
      if get_tw_otu_id[sf_taxon_name_id]
        logger.info "SF.TaxonNameID = #{sf_taxon_name_id} previously created as OTU (otu_only_counter = #{otu_only_counter += 1})"
      elsif otu_not_found_array.include? sf_taxon_name_id # already in array (probably seqnum > 1)
        logger.info "SF.TaxonNameID = #{sf_taxon_name_id} already in otu_not_found_array (total in otu_not_found_counter = #{otu_not_found_counter})"
      else
        otu_not_found_array << sf_taxon_name_id # add SF.TaxonNameID to otu_not_found_array
        logger.info "SF.TaxonNameID = #{sf_taxon_name_id} added to otu_not_found_array (otu_not_found_counter = #{otu_not_found_counter += 1})"
      end
      next
    end



  end

  end