class DatasetRecord::DarwinCore::Taxon < DatasetRecord::DarwinCore

  KNOWN_KEYS_COMBINATIONS = [
    %i{uninomial},
    %i{uninomial rank parent},
    %i{genus species},
    %i{genus species infraspecies},
    %i{genus subgenus species},
    %i{genus subgenus species infraspecies}
  ].freeze

  PARSE_DETAILS_KEYS = %i(uninomial genus species infraspecies).freeze

  ORIGINAL_COMBINATION_RANKS = {
    genus: 'TaxonNameRelationship::OriginalCombination::OriginalGenus',
    subgenus: 'TaxonNameRelationship::OriginalCombination::OriginalSubgenus',
    species: 'TaxonNameRelationship::OriginalCombination::OriginalSpecies',
    subspecies: 'TaxonNameRelationship::OriginalCombination::OriginalSubspecies',
    variety: 'TaxonNameRelationship::OriginalCombination::OriginalVariety',
    form: 'TaxonNameRelationship::OriginalCombination::OriginalForm'
  }.freeze

  def import(dwc_data_attributes = {})
    super
    begin
      DatasetRecord.transaction do
        self.metadata.delete('error_data')

        nomenclature_code = get_field_value('nomenclaturalCode')&.downcase&.to_sym || import_dataset.default_nomenclatural_code
        unless Ranks::CODES.include?(nomenclature_code)
          raise DarwinCore::InvalidData.new(
            { "nomenclaturalCode": ["Unrecognized nomenclatural code #{get_field_value('nomenclaturalCode')}"] }
          )
        end
        parse_results_details = Biodiversity::Parser.parse(get_field_value('scientificName') || '')[:details]&.values&.first

        parse_results = Biodiversity::Parser.parse(get_field_value(:scientificName) || '')
        parse_results_details = parse_results[:details]
        parse_results_details = (parse_results_details.keys - PARSE_DETAILS_KEYS).empty? ? parse_results_details.values.first : nil if parse_results_details

        raise DarwinCore::InvalidData.new({
                                            "scientificName": parse_results[:qualityWarnings] ?
                                                                parse_results[:qualityWarnings].map { |q| q[:warning] } :
                                                                ['Unable to parse scientific name. Please make sure it is correctly spelled.']
                                          }) unless (1..3).include?(parse_results[:quality]) && parse_results_details

        raise 'UNKNOWN NAME DETAILS COMBINATION' unless KNOWN_KEYS_COMBINATIONS.include?(parse_results_details.keys - [:authorship])

        name_key = parse_results_details[:uninomial] ? :uninomial : (parse_results_details.keys - [:authorship]).last
        name_details = parse_results_details[name_key]

        name = name_details.kind_of?(Array) ? name_details.first[:value] : name_details

        authorship = parse_results_details.dig(:authorship, :normalized) || get_field_value('scientificNameAuthorship')

        author_name = nil

        # split authorship into name and year
        if nomenclature_code == :iczn
          if (authorship_matchdata = authorship.match(/\(?(?<author>.+),? (?<year>\d{4})?\)?/))

            # regex will include comma, no easy way around it
            author_name = authorship_matchdata[:author].delete_suffix(',')
            year = authorship_matchdata[:year]

            # author name should be wrapped in parentheses if the verbatim authorship was
            if authorship.start_with?('(') and authorship.end_with?(')')
              author_name = '(' + author_name + ')'
            end
          end

        else
          # Fall back to simple name + date parsing
          author_name = Utilities::Strings.verbatim_author(authorship)
          year = Utilities::Strings.year_of_publication(authorship)
        end

        # TODO should a year provided in namePublishedInYear overwrite the parsed value?
        year ||= get_field_value('namePublishedInYear')

        # TODO validate that rank is a real rank, otherwise Combination will crash on find_or_initialize_by
        rank = get_field_value('taxonRank')
        is_hybrid = metadata['is_hybrid'] # TODO: NO...

        if metadata['parent'].nil?
          parent = project.root_taxon_name
        else
          parent = TaxonName.find(get_parent.metadata['imported_objects']['taxon_name']['id'])
        end

        if metadata['type'] == 'protonym'
          protonym_attributes = {
            name: name,
            parent: parent,
            rank_class: Ranks.lookup(nomenclature_code, rank),
            also_create_otu: false,
            verbatim_author: author_name,
            year_of_publication: year
          }

          taxon_name = Protonym.create_with(verbatim_author: author_name, project: project)
                               .find_or_initialize_by(protonym_attributes.slice(:name, :parent, :rank_class, :year_of_publication))

          unless taxon_name.persisted?
            taxon_name.taxon_name_classifications.build(type: TaxonNameClassification::Icn::Hybrid) if is_hybrid
            taxon_name.data_attributes.build(import_predicate: 'DwC-A import metadata', type: 'ImportAttribute', value: {
              scientificName: get_field_value('scientificName'),
              scientificNameAuthorship: get_field_value('scientificNameAuthorship'),
              taxonRank: get_field_value('taxonRank'),
              metadata: metadata
            })

          end

          # create original combination relationships, get parents of original combination to set as subject taxon name

          if get_field_value(:taxonID) == get_field_value(:originalNameUsageID)
            # create relationships for genus rank and below pointing to self and parents

            taxon_name.safe_self_and_ancestors.each do |ancestor|   # does not include self for new records
              if (rank_in_type = ORIGINAL_COMBINATION_RANKS[ancestor&.rank&.downcase&.to_sym])
                TaxonNameRelationship.find_or_create_by!(type: rank_in_type, subject_taxon_name: ancestor, object_taxon_name: taxon_name)
              end
            end

          else  # protonym is not the original combination, need to make relationships to OC ancestors

            unless parent == project.root_taxon_name
              original_combination_parent = TaxonName.find(find_by_taxonID(get_original_combination.metadata['parent'])
                                                 .metadata['imported_objects']['taxon_name']['id'])

              original_combination_parent.safe_self_and_ancestors.each do |ancestor|
                if (rank_in_type = ORIGINAL_COMBINATION_RANKS[ancestor.rank&.downcase&.to_sym])
                  TaxonNameRelationship.find_or_create_by!(type: rank_in_type, subject_taxon_name: ancestor, object_taxon_name: taxon_name)
                end
              end
            end

            # can't assume OC rank is same as valid rank, need to look at OC row to find real rank
            # This is easier for the end-user than adding OC to protonym when importing the OC row,
            # but might be more complex to code

            # get OC dataset_record_id so we can pull the taxonRank from it.
            oc_dataset_record_id = import_dataset.core_records_fields
                                                 .at(get_field_mapping(:taxonID))
                                                 .with_value(get_field_value(:originalNameUsageID))
                                                 .pick(:dataset_record_id)

            oc_protonym_rank = import_dataset.core_records_fields
                                             .where(dataset_record_id: oc_dataset_record_id)
                                             .at(get_field_mapping(:taxonRank))
                                             .pick(:value)
                                             .downcase.to_sym

            if ORIGINAL_COMBINATION_RANKS.has_key?(oc_protonym_rank)
              TaxonNameRelationship.create_with(subject_taxon_name: taxon_name).find_or_create_by!(
                type: ORIGINAL_COMBINATION_RANKS[oc_protonym_rank],
                object_taxon_name: taxon_name)
            end
          end

          # if taxonomicStatus is a synonym or homonym, create the relationship to acceptedNameUsageID
          if metadata['has_external_accepted_name']
            valid_name = get_taxon_name_from_taxon_id(get_field_value(:acceptedNameUsageID))

            synonym_classes = {
              iczn: {
                synonym: 'TaxonNameRelationship::Iczn::Invalidating::Synonym',
                homonym: 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::ReplacedHomonym',
              },
              # TODO support other nomenclatural codes
              # icnp: {
              #   synonym: "TaxonNameRelationship::Icnp::Unaccepting::Synonym",
              #   homonym: "TaxonNameRelationship::Icnp::Unaccepting::Homonym"
              # },
              # icn: {
              #   synonym: "TaxonNameRelationship::Icn::Unaccepting::Synonym",
              #   homonym: "TaxonNameRelationship::Icn::Unaccepting::Homonym"
              # }
            }.freeze

            if (status = get_field_value(:taxonomicStatus)&.downcase)
              type = synonym_classes[nomenclature_code][status.to_sym]

              raise DarwinCore::InvalidData.new({ "taxonomicStatus": ["Status #{status} did not match synonym, homonym, invalid, unavailable, excluded"] }) if type.nil?

              taxon_name.taxon_name_relationships.find_or_initialize_by(object_taxon_name: valid_name, type: type)

              # Add homonym status (if applicable)
              if status == 'homonym'
                taxon_name.taxon_name_classifications.find_or_initialize_by(type: 'TaxonNameClassification::Iczn::Available::Invalid::Homonym')
              end

            else
              raise DarwinCore::InvalidData.new({ "taxonomicStatus": ['No taxonomic status, but acceptedNameUsageID has different protonym'] })
            end

            # if taxonomicStatus is a homonym, invalid, unavailable, excluded, create the status
          elsif get_field_value(:taxonomicStatus) != 'valid' || get_field_value(:taxonomicStatus).nil?
            status_types = {
              invalid: 'TaxonNameClassification::Iczn::Available::Invalid',
              unavailable: 'TaxonNameClassification::Iczn::Unavailable',
              excluded: 'TaxonNameClassification::Iczn::Unavailable::Excluded'
            }.freeze

            if (status = get_field_value(:taxonomicStatus)&.downcase)

              type = status_types[status.to_sym]

              raise DarwinCore::InvalidData.new({ "taxonomicStatus": ["Couldn't find a status that matched #{status}"] }) if type.nil?

              taxon_name.taxon_name_classifications.find_or_initialize_by(type: type)
            end
          end

        elsif metadata['type'] == 'combination'

          # get protonym from staging metadata
          protonym_record = find_by_taxonID(metadata['protonym_taxon_id'])
          # current_name_record = find_by_taxonID(get_field_value(:originalNameUsageID))

          current_name = Protonym.find(protonym_record.metadata['imported_objects']['taxon_name']['id'])

          # because Combination uses named arguments, we need to get the ranks of the parent names to create the combination
          if parent.is_a?(Combination)
            parent_elements = parent.combination_taxon_names.index_by { |protonym| protonym.rank }

          else  # parent is a protonym, so we need to get all parent elements up to genus
            parent_elements = parent.self_and_ancestors.order('taxon_name_hierarchies.generations DESC').to_a
                                    .take_while{ |p| ORIGINAL_COMBINATION_RANKS.has_key?(p&.rank&.to_sym) }
                                    .index_by{ |protonym| protonym.rank}
          end

          combination_attributes = {**parent_elements}
          combination_attributes[rank.downcase] = current_name if rank

          # Can't use find_or_initialize_by because of dynamic parameters, causes query to fail because ranks are not columns in db
          # => PG::UndefinedTable: ERROR:  missing FROM-clause entry for table "genus"
          # LINE 1: ..."taxon_names" WHERE "taxon_names"."type" = $1 AND "genus"."i...

          taxon_name = Combination.matching_protonyms(**combination_attributes.transform_values { |v| v.id }).first
          taxon_name = Combination.new(combination_attributes) if taxon_name.nil?

        else
          raise DarwinCore::InvalidData.new({ "originalNameUsageID": ['Could not determine if name is protonym or combination'] })
        end

        if taxon_name.save
          # TODO add relationships and combinations to this hash
          self.metadata[:imported_objects] = { taxon_name: { id: taxon_name.id } }
          self.status = 'Imported'
        else
          self.status = 'Errored'
          self.metadata[:error_data] = {
            messages: taxon_name.errors.messages
          }
        end

        save!

        if self.status == 'Imported'
          # loop over dependants, see if all other dependencies are met, if so mark them as ready
          metadata['dependants'].each do |dependant_taxonID|
            if dependencies_imported?(dependant_taxonID)
              DatasetRecord::DarwinCore::Taxon.where(id: import_dataset.core_records_fields
                                                                       .at(get_field_mapping(:taxonID))
                                                                       .where(value: dependant_taxonID)
                                                                       .select(:dataset_record_id)
              ).first.update!(status: 'Ready')
            end
          end
        end
      end
    rescue DarwinCore::InvalidData => invalid
      self.status = 'Errored'
      self.metadata['error_data'] = { messages: invalid.error_data }
    rescue ActiveRecord::RecordInvalid => invalid
      self.status = 'Errored'
      self.metadata['error_data'] = {
        messages: invalid.record.errors.messages
      }
    rescue StandardError => e
      raise if Rails.env.development?
      self.status = 'Failed'
      self.metadata[:exception_data] = {
        message: e.message,
        backtrace: e.backtrace
      }
    ensure
      save!
    end

    self
  end

  private

  # @return [DatasetRecord::DarwinCore::Taxon, Array<DatasetRecord::DarwinCore::Taxon>]
  def get_parent
    DatasetRecord::DarwinCore::Taxon.where(id: import_dataset.core_records_fields
                                                             .at(get_field_mapping(:taxonID))
                                                             .with_value(get_field_value(:parentNameUsageID))
                                                             .select(:dataset_record_id)
    ).first
  end

  # @return [DatasetRecord::DarwinCore::Taxon, Array<DatasetRecord::DarwinCore::Taxon>]
  def get_original_combination
    DatasetRecord::DarwinCore::Taxon.where(id: import_dataset.core_records_fields
                                                             .at(get_field_mapping(:taxonID))
                                                             .with_value(get_field_value(:originalNameUsageID))
                                                             .select(:dataset_record_id)
    ).first
  end

  # @return [DatasetRecord::DarwinCore::Taxon, Array<DatasetRecord::DarwinCore::Taxon>]
  def find_by_taxonID(taxon_id)
    DatasetRecord::DarwinCore::Taxon.where(id: import_dataset.core_records_fields
                                                             .at(get_field_mapping(:taxonID))
                                                             .with_value(taxon_id.to_s)
                                                             .select(:dataset_record_id)
    ).first
  end

  # @return [TaxonName]
  def get_taxon_name_from_taxon_id(taxon_id)
    TaxonName.find(DatasetRecord::DarwinCore::Taxon.where(id: import_dataset.core_records_fields
                                                                            .at(get_field_mapping(:taxonID))
                                                                            .with_value(taxon_id.to_s)
                                                                            .select(:dataset_record_id)
    ).pick(:metadata)['imported_objects']['taxon_name']['id'])
  end

  # Check if all dependencies of a taxonID are imported
  def dependencies_imported?(taxon_id)
    dependency_taxon_ids = DatasetRecord::DarwinCore::Taxon.where(id: import_dataset.core_records_fields
                                                                         .at(get_field_mapping(:taxonID))
                                                                         .with_value(taxon_id.to_s)
                                                                         .select(:dataset_record_id)
    ).pick(:metadata)['dependencies']

    DatasetRecord::DarwinCore::Taxon.where(id: import_dataset.core_records_fields
                                                                            .at(get_field_mapping(:taxonID))
                                                                            .with_values(dependency_taxon_ids.map { |d| d.to_s })
                                                                            .select(:dataset_record_id)
    ).where(status: 'Imported').count == dependency_taxon_ids.length


  end

  # TODO add restage button/trigger when relevant fields change. Changing an id here means recalculating dependencies
  def data_field_changed(index, value)
    # if index == get_field_mapping(:parentNameUsageID) && status == "NotReady"
    #   self.status = "Ready" if %w[Ready Imported].include? get_parent&.status
    # end
  end

end
