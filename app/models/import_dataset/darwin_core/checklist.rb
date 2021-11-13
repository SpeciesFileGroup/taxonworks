class ImportDataset::DarwinCore::Checklist < ImportDataset::DarwinCore
  is_origin_for Person::Unvetted.to_s

  has_many :core_records, foreign_key: 'import_dataset_id', class_name: 'DatasetRecord::DarwinCore::Taxon'
  has_many :extension_records, foreign_key: 'import_dataset_id', class_name: 'DatasetRecord::DarwinCore::Extension'

  # if taxonomicStatus is "obsolete combination", and it is an original combination, then don't create a protonym.
  # the valid combination will create the original combination relationship when it is processed.
  #
  # if it's not the original combination, make it a dependent of the valid/current name (so the protonym is created) and then
  # make a new combination as recorded.
  #
  # valid/current names don't have to be valid, they could be a synonym or homonym.
  # Importantly, each protonym should have only one current name.
  #
  # If status is homonym, set the status of the name to homonym (DwC doesn't give us the info to assert what it's a homonym of),
  # and
  #
  # acceptedNameUsage may either be the replacement name (in the case of a homonym) or the valid name (in the case of a synonym)

  def core_records_class
    DatasetRecord::DarwinCore::Taxon
  end

  def core_records_identifier_name
    'taxonID'
  end

  # Stages core (Taxon) records and all extension records.
  def perform_staging
    records, headers = get_records(source)

    update!(metadata: {
      core_headers: headers[:core],
      extensions_headers: headers[:extensions]
    })

    parse_results_ary = Biodiversity::Parser.parse_ary(records[:core].map { |r| r['scientificName'] || '' })

    # hash of taxonID, record metadata
    records_lut = { }

    # hash of row index, record metadata
    core_records = records[:core].each_with_index.map do |record, index|
      records_lut[record['taxonID']] = {
        index: index,
        type: nil, # will be protonym or combination
        dependencies: [],
        dependants: [],
        synonyms: [],
        synonym_of: nil, # index of current/valid name
        replacing_valid_name: nil,  # taxonID of current/valid name, if record is a homonym or synonym
        is_hybrid: nil,
        is_synonym: nil,
        has_external_accepted_name: nil,   # could be homonym or synonym, either way protonym is not valid. will use taxonomicStatus to determine the kind of relationship
        original_combination: nil, # taxonID of original combination
        protonym_taxon_id: nil,
        parent: record['parentNameUsageID'],
        src_data: record
      }
    end

    # PROCESS OVERVIEW
    # if current name is valid, acceptedNameUsageID will be inside the original combination group, use that row for the protonym
    # if current name is synonym or homonym, acceptedNameUsageID won't be in the group, but use the synonym/homonym row for creating the protonym
    #
    # make combination relationships for other names in group
    # make other names dependent on valid name

    # if group is a synonym, set record[:synonym_of] to index of current name

    #
    # Create original combination relationship for each key in original_combination_groups
    # The protonym should be dependent on the parent of the original combination if it's a subsequent combination



    # identify protonyms by grouping by original combination
    original_combination_groups = { }

    core_records.each_with_index do |record, index|

      # TODO handle when originalNameUsageID is not present

      if record[:src_data]['originalNameUsageID'].blank?
        add_error_message(record, :originalNameUsageID, 'originalNameUsageID must not be blank')
      end

      if records_lut[record[:src_data]['originalNameUsageID']].nil?
        add_error_message(record, :originalNameUsageID, 'originalNameUsageID not found in dataset')
        next
      end
      oc_index = records_lut[record[:src_data]['originalNameUsageID']][:index]

      original_combination_groups[oc_index] ||= []
      original_combination_groups[oc_index] << index

    end

    current_taxonomic_status = Set['valid', 'homonym', 'synonym', 'excluded', 'unidentifiable', 'unavailable'].freeze

    # make combinations dependent on the protonym of each OC group
    original_combination_groups.each do |oc_index, name_items|

      if records_lut[core_records[oc_index][:src_data]['acceptedNameUsageID']].nil?
        name_items.each do |i|
          add_error_message(core_records[i], :acceptedNameUsageID, 'acceptedNameUsageID not found in dataset')
        end
        next
      end

      if name_items.size > 1
        # find the valid name of the group, first by seeing if acceptedNameUsageID is in group, otherwise check against list of known current statuses
        current_item = nil

        # Find accepted name of original combination of group (accepted name will always be the same for all items in a group)
        # and see if it's one of the names in the group
        accepted_name_index = records_lut[core_records[oc_index][:src_data]['acceptedNameUsageID']][:index]

        # if the accepted name is in the group, use it for creating the protonym
        # if it's not in the group, search the statuses of the items to find most eligible name (this happens with synonyms and homonyms)
        if name_items.include? accepted_name_index
          current_item = accepted_name_index
        else
          name_items.each do |index|
            if current_taxonomic_status.include? core_records[index][:src_data]['taxonomicStatus']
              current_item = index
              break
            end
          end

          # TODO handle if no names in group are marked as current / all are obsolete combinations
          if current_item.nil?
            current_item = name_items.first
          end

          core_records[current_item][:has_external_accepted_name] = true

          replacement_taxon_id = core_records[current_item][:src_data]['acceptedNameUsageID']
          core_records[current_item][:replacing_valid_name] = replacement_taxon_id
          core_records[current_item][:dependencies] << records_lut[replacement_taxon_id][:index]
          records_lut[replacement_taxon_id][:dependants] << current_item

        end

        current_record = core_records[current_item]

        current_record[:type] = :protonym
        current_record[:dependants].concat name_items.reject { |i| i == current_item }
        current_record[:protonym_taxon_id] = current_record[:src_data]['taxonID']

        current_record[:original_combination] = current_record[:src_data]['originalNameUsageID']

        # make other names combinations, dependants of current name
        name_items.reject { |i| i == current_item }.each do |index|
          core_records[index][:type] = :combination
          core_records[index][:dependencies] << current_item
          core_records[index][:protonym_taxon_id] = current_record[:src_data]['taxonID']
        end

        # make protonym depend on original combination's parent, if protonym is not the original combination
        if current_record[:index] != oc_index
          current_record[:dependencies] << records_lut[core_records[oc_index][:parent]][:index]
          records_lut[core_records[oc_index][:parent]][:dependants] << current_record[:index]
        end

      else  # if original combination is only name, make it the protonym
        # TODO is it better to replace name_items.first with oc_index?
        current_record = core_records[name_items.first]
        current_record[:type] = :protonym
        current_record[:original_combination] = current_record[:src_data]['taxonID']
        current_record[:protonym_taxon_id] = current_record[:src_data]['taxonID']

        # see if protonym is synonym (or even homonym?), and set replacing_valid_name if so
        if current_record[:src_data]['acceptedNameUsageID'] != current_record[:src_data]['taxonID']
          replacement_taxon_id = current_record[:src_data]['acceptedNameUsageID']
          current_record[:replacing_valid_name] = replacement_taxon_id
          current_record[:has_external_accepted_name] = true
          current_record[:dependencies] << records_lut[replacement_taxon_id][:index]
          records_lut[replacement_taxon_id][:dependants] << current_record[:index]
        end

      end
    end


    core_records.each_with_index do |record, index|
      accepted_name_usage = records_lut[record[:src_data]['acceptedNameUsageID']]

      unless accepted_name_usage
        # TODO are we already checking this higher up?
        add_error_message(record, :acceptedNameUsageID, "acceptedNameUsageID '#{record[:src_data]["acceptedNameUsageID"]}' not found")
      end

      record[:parent] = nil if record[:parent].blank?

      parse_results = parse_results_ary[index]

      record[:is_hybrid] = !!parse_results[:hybrid]

      # set type as combination or protonym based on authorship being in parentheses
      unless parse_results[:details]
        record[:type] = :unknown
        add_error_message(record, :scientificName, "Scientific name #{record[:src_data][:scientificName]} could not be parsed" )
      end

      unless record[:parent].nil?
        if records_lut[record[:parent]]
          parent_index = records_lut[record[:parent]][:index]
          record[:dependencies] << parent_index
          core_records[parent_index][:dependants] << record[:index]
        else
          add_error_message(record, :parentNameUsageID, 'parentNameUsageID not found in dataset')
        end
      end
    end

    # replace dependencies and dependants index values with taxonID values
    core_records.each do |record|
      record[:dependants].map! {|i| core_records[i][:src_data]['taxonID']}.uniq!
      record[:dependencies].map! {|i| core_records[i][:src_data]['taxonID']}.uniq!
    end

    # create new dataset record for each row and mark items as ready
    core_records.each do |record|
      dwc_taxon = DatasetRecord::DarwinCore::Taxon.new(import_dataset: self)
      dwc_taxon.initialize_data_fields(record[:src_data].map { |_, v| v })
      dwc_taxon.status = !record[:error_data] && record[:dependencies] == [] && record[:parent].nil? ? 'Ready' : 'NotReady'
      record.delete(:src_data)
      dwc_taxon.metadata = record

      dwc_taxon.save!
    end

    records[:extensions].each do |extension_type, extension_records|
      extension_records.each do |record|
        dwc_extension = DatasetRecord::DarwinCore::Extension.new(import_dataset: self)
        dwc_extension.initialize_data_fields(record.map { |_, v| v })
        dwc_extension.status = 'Unsupported'
        dwc_extension.metadata = { type: extension_type }

        dwc_extension.save!
      end
    end

  end

  private

  # @param [String, Symbol] column_name
  # @param [Hash] record: The record hash to add the error message to
  # @param [String] message
  def add_error_message(record, column_name, message)
    record[:error_data] ||= {messages: {}}

    if (arry = record.dig(:error_data, :messages, column_name.to_sym))
      arry << message
    else
      record[:error_data][:messages][column_name.to_sym] = [message]
    end
  end

end
