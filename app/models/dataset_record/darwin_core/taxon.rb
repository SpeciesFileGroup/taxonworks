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


# rubocop:disable Metric/MethodLength

  def import(dwc_data_attributes = {})
    super
    begin
      DatasetRecord.transaction(requires_new: true) do
        self.metadata.delete('error_data')

        nomenclature_code = get_field_value('nomenclaturalCode')&.downcase&.to_sym || import_dataset.default_nomenclatural_code
        unless Ranks::CODES.include?(nomenclature_code)
          raise DarwinCore::InvalidData.new(
            { "nomenclaturalCode": ["Unrecognized nomenclatural code #{get_field_value('nomenclaturalCode')}"] }
          )
        end
        # parse_results_details = Biodiversity::Parser.parse(get_field_value('scientificName') || '')[:details]&.values&.first

        parse_results = Biodiversity::Parser.parse(get_field_value(:scientificName) || '')
        parse_results_details = parse_results[:details]
        parse_results_details = (parse_results_details.keys - PARSE_DETAILS_KEYS).empty? ? parse_results_details.values.first : nil if parse_results_details

        raise DarwinCore::InvalidData.new({
                                            "scientificName": parse_results[:qualityWarnings] ?
                                                                parse_results[:qualityWarnings].map { |q| q[:warning] } :
                                                                ['Unable to parse scientific name. Please make sure it is correctly spelled.']
                                          }) unless (1..3).include?(parse_results[:quality]) && parse_results_details&.is_a?(Hash)

        raise 'UNKNOWN NAME DETAILS COMBINATION' unless KNOWN_KEYS_COMBINATIONS.include?(parse_results_details.keys - [:authorship])

        name_key = parse_results_details[:uninomial] ? :uninomial : (parse_results_details.keys - [:authorship]).last
        name_details = parse_results_details[name_key]

        name = name_details.kind_of?(Array) ? name_details.first[:value] : name_details

        authorship = parse_results_details.dig(:authorship, :normalized) || get_field_value('scientificNameAuthorship')

        author_name = nil
        year = nil

        # split authorship into name and year
        if authorship.present?
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
            # Fall back to simple name + date parsing if not iczn
            author_name = Utilities::Strings.verbatim_author(authorship)
            year = Utilities::Strings.year_of_publication(authorship)
          end
        end

        if year && (name_published_in_year = get_field_value('namePublishedInYear')) &&
          year != name_published_in_year
          raise DarwinCore::InvalidData.new(
            { "namePublishedInYear": ["parsed year from scientificName or scientificNameAuthorship (#{year}) "\
                                      "does not match namePublishedInYear (#{name_published_in_year})"]
            })
        end
        year ||= get_field_value('namePublishedInYear')

        # TODO validate that rank is a real rank, otherwise Combination will crash on find_or_initialize_by
        rank = get_field_value('taxonRank')
        is_hybrid = metadata['is_hybrid'] # TODO: NO...

        if metadata['parent'].nil?
          if self.import_dataset.use_existing_hierarchy?
            protonym_attributes = { name:, #
                                  cached: get_field_value(:scientificName),
                                  rank_class: Ranks.lookup(nomenclature_code, rank),
                                  verbatim_author: author_name,
                                  year_of_publication: year}
            potential_protonyms = TaxonName.where(protonym_attributes.merge({project:})) # merged project here so data is not leaked in error messages.

            if potential_protonyms.count == 1
              parent = potential_protonyms.first.parent
            elsif potential_protonyms.count > 1
              matching_protonyms = potential_protonyms.map { |proto| "[id: #{proto.id} #{proto.cached_html_name_and_author_year}]" }.join(', ')
              raise DarwinCore::InvalidData.new(
                { "parentNameUsageID": ["parent ID is blank, 'use existing taxon hierarchy' is enabled in settings, " \
                                          "and multiple TaxonNames matched #{protonym_attributes}: #{matching_protonyms}"] })
            else
              raise DarwinCore::InvalidData.new(
                { "parentNameUsageID": ["parent ID is blank, 'use existing taxon hierarchy' is enabled in settings, " \
                                          "and no TaxonNames matched #{protonym_attributes}"] })
            end
          else
            parent = project.root_taxon_name
          end
        else
          parent = TaxonName.find(get_parent.metadata['imported_objects']['taxon_name']['id'])
        end

        if metadata['type'] == 'protonym'

          # if the name is a synonym, we should use the valid taxon's rank and parent
          # I *think* it's ok to do the same for homonyms, since we could have case where homonym's parent is a synonym,
          # and it has been moved from species to subspecies rank.
          # we fetch parent from the source file when calculating original combination, so it's ok to modify it here.
          if metadata['has_external_accepted_name']
            valid_name = get_taxon_name_from_taxon_id(get_field_value(:acceptedNameUsageID))
            rank = valid_name.rank
            parent = valid_name.parent
          elsif parent.is_a? Combination # this can happen when the name is unavailable, it's not a synonym so it doesn't point to anything else
            parent = parent.finest_protonym
          end

          taxon_name = Protonym.find_or_initialize_by({
            name:,
            parent:,
            rank_class: Ranks.lookup(nomenclature_code, rank),
            # also_create_otu: false,
            verbatim_author: author_name,
            year_of_publication: year,
            project:
          })

          unless taxon_name.persisted?
            taxon_name.taxon_name_classifications.build(type: TaxonNameClassification::Icn::Hybrid) if is_hybrid
            taxon_name.data_attributes.build(import_predicate: 'DwC-A import metadata', type: 'ImportAttribute', value: {
              scientificName: get_field_value('scientificName'),
              scientificNameAuthorship: get_field_value('scientificNameAuthorship'),
              taxonRank: get_field_value('taxonRank'),
              metadata:
            })

          end

          # make OC relationships to OC ancestors
          # can't make original combination with Root or if matching pre-existing taxon name
          # Do not make original combination if we assumed the value.
          if metadata['parent'].present? && (metadata.fetch('create_original_combination', true) == true)

            # Loop through parents of original combination based on parentNameUsageID, not TW parent
            # this way we get the name as intended, not with any valid/current names
            original_combination_parents = [find_by_taxonID(get_original_combination.metadata['parent'])].compact

            # build list of parent DatasetRecords
            if original_combination_parents.size > 0
              while (next_parent = find_by_taxonID(original_combination_parents[-1]&.metadata['parent']))
                original_combination_parents << next_parent
              end
            end

            # in cases where the taxon original combination is subgenus of self eg Sima (Sima), the first parent of the list
            # should be dropped because it hasn't been imported yet
            original_combination_parents = original_combination_parents.drop_while {|p| p.status != 'Imported' }

            # convert DatasetRecords into list of Protonyms
            original_combination_parents.map! do |p|
              h = {}
              h[:protonym] = TaxonName.find(p.metadata['imported_objects']['taxon_name']['id'])
              h[:rank] = DatasetRecordField.where(dataset_record_id: p)
                                           .at(get_field_mapping(:taxonRank))
                                           .pick(:value)
                                           .downcase
              h
            end

            original_combination_parents.each do |ancestor|
              ancestor_protonym = ancestor[:protonym]
              ancestor_rank = ancestor[:rank]

              # If OC parent is combination, need to create relationship for lowest element
              if ancestor_protonym.is_a?(Combination)
                ancestor_protonym = ancestor[:protonym].finest_protonym
              end

              if (rank_in_type = ORIGINAL_COMBINATION_RANKS[ancestor_rank&.downcase&.to_sym])

                # if the subgenus is newer than taxon_name's authorship, skip it (the name must have been classified in the subgenus later)
                next if ancestor_rank&.downcase&.to_sym == :subgenus &&
                  !ancestor_protonym.year_integer.nil? &&
                  !taxon_name.year_integer.nil? &&
                  ancestor_protonym.year_integer > taxon_name.year_integer

                taxon_name.save!
                TaxonNameRelationship.find_or_create_by!(type: rank_in_type, subject_taxon_name: ancestor_protonym, object_taxon_name: taxon_name)
              end
            end
          end

          # don't create OC relationship with self if OC was assumed, default to true for any datasets
          # created before this feature existed (since creating OC was always expected then)
          if metadata.fetch('create_original_combination', true)

            # when creating the OC record pointing to self,
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

              # detect if current name rank is genus and original combination is with self at subgenus level, eg Aus (Aus)
              # if so, generate OC relationship with genus (since oc_protonym_rank will be subgenus)
              if oc_protonym_rank == :subgenus && get_field_value('taxonRank').downcase == 'genus' &&
                (get_original_combination&.metadata['parent'] == get_field_value('taxonID'))
                TaxonNameRelationship.create_with(subject_taxon_name: taxon_name).find_or_create_by!(
                  type: ORIGINAL_COMBINATION_RANKS[:genus],
                  object_taxon_name: taxon_name)
              end
            end
          end

          # if taxonomicStatus is a synonym or homonym, create the relationship to acceptedNameUsageID
          if metadata['has_external_accepted_name']
            valid_name = get_taxon_name_from_taxon_id(get_field_value(:acceptedNameUsageID))

            synonym_classes = {
              iczn: {
                synonym: 'TaxonNameRelationship::Iczn::Invalidating::Synonym',
                homonym: 'TaxonNameRelationship::Iczn::Invalidating::Synonym::Objective::ReplacedHomonym',
                misspelling: 'TaxonNameRelationship::Iczn::Invalidating::Usage::Misspelling',
                'original misspelling':  'TaxonNameRelationship::Iczn::Invalidating::Usage::IncorrectOriginalSpelling',

                # invalid can be either a relationship or classification, depending on if 'has_external_accepted_name' is true or not
                invalid: 'TaxonNameRelationship::Iczn::Invalidating'
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

              # workaround to handle cases where Protonym is a synonym, but row marked as synonym has different rank/parent
              # so we use a row that does as the protonym instead. That row could have some other status, but
              # we know it's a synonym.
              if metadata['is_synonym']
                status = :synonym
              end

              type = synonym_classes[nomenclature_code][status.to_sym]


              raise DarwinCore::InvalidData.new(
                { "taxonomicStatus": ['acceptedNameUsageID refers to a different protonym, ' \
                  "but status #{status} did not match synonym, homonym, invalid, misspelling or original misspelling."] }) if type.nil?

              taxon_name.taxon_name_relationships.find_or_initialize_by(object_taxon_name: valid_name, type:)

              if status.to_s == 'synonym'
                # if synonym and not same rank as valid, and not original combination,
                # create a combination with the old parent and rank

                if (old_rank = get_field_value('taxonRank').downcase) != rank.downcase &&
                  metadata['original_combination'] != get_field_value('taxonID') &&
                  ORIGINAL_COMBINATION_RANKS.has_key?(old_rank.downcase.to_sym)

                  # save taxon so we can create a combination
                  taxon_name.save!

                  # stolen from combination handling portion of code
                  parent_elements = create_parent_element_hash.transform_values {|v| v.is_a?(Combination) ? v.finest_protonym : v}

                  combination_attributes = { **parent_elements }
                  combination_attributes[old_rank.downcase] = taxon_name if old_rank

                  # Can't use find_or_initialize_by because of dynamic parameters, causes query to fail because ranks are not columns in db
                  # => PG::UndefinedTable: ERROR:  missing FROM-clause entry for table "genus"
                  # LINE 1: ..."taxon_names" WHERE "taxon_names"."type" = $1 AND "genus"."i...

                  taxon_combination_name = Combination.matching_protonyms(**combination_attributes.transform_values { |v| v.id }).first
                  taxon_combination_name = Combination.create!(combination_attributes) if taxon_combination_name.nil?
                end
              end

              # Add homonym status (if applicable)
              if status == 'homonym'
                taxon_name.taxon_name_classifications.find_or_initialize_by(type: 'TaxonNameClassification::Iczn::Available::Invalid::Homonym')
              end

            else
              raise DarwinCore::InvalidData.new({ "taxonomicStatus": ['No taxonomic status, but acceptedNameUsageID has different protonym'] })
            end

            # if taxonomicStatus is a homonym, invalid, unavailable, excluded, create the status
            # if it's incertae sedis, create the relationship
            # TODO why have an OR with nil? shouldn't the first condition check that?
          elsif get_field_value(:taxonomicStatus) != 'valid' || get_field_value(:taxonomicStatus).nil?
            status_types = {
              invalid: 'TaxonNameClassification::Iczn::Available::Invalid',
              unavailable: 'TaxonNameClassification::Iczn::Unavailable',
              excluded: 'TaxonNameClassification::Iczn::Unavailable::Excluded',
              'nomen nudum': 'TaxonNameClassification::Iczn::Unavailable::NomenNudum',
              ichnotaxon: 'TaxonNameClassification::Iczn::Fossil::Ichnotaxon',
              fossil: 'TaxonNameClassification::Iczn::Fossil',
              'nomen dubium': 'TaxonNameClassification::Iczn::Available::Valid::NomenDubium'
            }.freeze

            if (status = get_field_value(:taxonomicStatus)&.downcase)

              # if name in incertae sedis, attach to finest level known (usually parent) and add TaxonNameRelationship
              if status == 'incertae sedis'

                # if user has provided a `TW:TaxonNameRelationship:incertae_sedis_in_rank` field, use that to determine
                # which rank of parent should be used for I.S. relationship
                if (verbatim_is_rank = get_field_value('TW:TaxonNameRelationship:incertae_sedis_in_rank'))
                  # must save here so that `ancestor_at_rank` works
                  # (otherwise could use `ancestors_through_parents` and check rank manually)
                  taxon_name.save
                  incertae_sedis_parent = taxon_name.ancestor_at_rank(verbatim_is_rank.downcase)

                  if incertae_sedis_parent.nil?
                    available_parent_ranks = taxon_name.ancestors.map { |a| "#{a.rank}: #{a.name}" }.join(', ')
                    raise DarwinCore::InvalidData.new({ "TW:TaxonNameRelationship:incertae_sedis_in_rank":
                                                          ["Taxon #{taxon_name.name} does not have a parent at rank #{verbatim_is_rank}.
                                                            Available ancestors are #{available_parent_ranks}.".squish] })
                  end

                  # Parent should be same as incertae sedis object_taxon
                  # Supplying a parent taxonID with a different rank than the incertae sedis parent
                  # will an original combination relationship with the old parent, which
                  # the ui will render as [Aus] bus, (where the incertae sedis parent is Cus)
                  taxon_name.parent = incertae_sedis_parent

                else
                  # if parent has uncertain placement in rank, taxon's parent should be changed to whichever taxon the parent's UncertainRelationship is with
                  incertae_sedis_parent = parent.iczn_uncertain_placement
                  # if parent doesn't have uncertain placement, make relationship with family or subfamily (FamilyGroup)
                  incertae_sedis_parent ||= taxon_name.ancestors.with_base_of_rank_class('NomenclaturalRank::Iczn::FamilyGroup').first

                  # Parent should be same as incertae sedis object_taxon
                  taxon_name.parent = incertae_sedis_parent
                end

                taxon_name.taxon_name_relationships.find_or_initialize_by(
                  object_taxon_name: incertae_sedis_parent,
                  type: 'TaxonNameRelationship::Iczn::Validating::UncertainPlacement')

              else
                type = status_types[status.to_sym]

                raise DarwinCore::InvalidData.new(
                  { "taxonomicStatus": ["Couldn't find a status that matched #{status}.",
                                        "Possible statuses: [#{status_types.keys.join(", ")}]"] }) if type.nil?

                taxon_name.taxon_name_classifications.find_or_initialize_by(type:)
              end
            end
          end

          # Taxon status might not be "fossil" if synonym, homonym, incertae sedis, etc.
          if get_field_value('TW:TaxonNameClassification:Iczn:Fossil')
            taxon_name.taxon_name_classifications.find_or_initialize_by(type: 'TaxonNameClassification::Iczn::Fossil')
          end

          # add gender or part of speech classification if given
          if (gender = get_field_value('TW:TaxonNameClassification:Latinized:Gender'))
            gender_types = {
              masculine: 'TaxonNameClassification::Latinized::Gender::Masculine',
              feminine: 'TaxonNameClassification::Latinized::Gender::Feminine',
              neuter: 'TaxonNameClassification::Latinized::Gender::Neuter'
            }.freeze

            gender_classification = gender_types[gender.downcase.to_sym]

            raise DarwinCore::InvalidData.new({ "TW:TaxonNameClassification:Latinized:Gender": ["Gender #{gender.downcase} is not one of: masculine, feminine, neuter."] }) if gender_classification.nil?

            taxon_name.taxon_name_classifications.find_or_initialize_by(type: gender_classification)

          elsif (part_of_speech = get_field_value('TW:TaxonNameClassification:Latinized:PartOfSpeech'))
            parts_of_speech_types = {
              adjective: 'TaxonNameClassification::Latinized::PartOfSpeech::Adjective',
              participle: 'TaxonNameClassification::Latinized::PartOfSpeech::Participle',
              'noun in apposition': 'TaxonNameClassification::Latinized::PartOfSpeech::NounInApposition',
              'noun in genitive case': 'TaxonNameClassification::Latinized::PartOfSpeech::NounInGenitiveCase'
            }.freeze

            part_of_speech_classification = parts_of_speech_types[part_of_speech.downcase.to_sym]

            raise DarwinCore::InvalidData.new({ "TW:TaxonNameClassification:Latinized:": ["PartOfSpeech #{part_of_speech.downcase} is not one of: adjective, participle, noun in apposition, noun in genitive case."] }) if part_of_speech_classification.nil?

            taxon_name.taxon_name_classifications.find_or_initialize_by(type: part_of_speech_classification)

            # if taxon has different original combination conjugation, and genus has gender, use OC name.
            # It will be conjugated correctly with new genus and the original combination will use the correct conjugation

            if oc_dataset_record_id != self.id &&
              taxon_name.is_species_rank? &&
              taxon_name.ancestor_at_rank('genus').gender_name

              oc_name = import_dataset.core_records_fields
                            .where(dataset_record_id: oc_dataset_record_id)
                            .at(get_field_mapping(:scientificName))
                            .pick(:value)

              finest_oc_name = oc_name.split.last

              # check if OC name is conjugated differently, then see if current name can be conjugated into oc name
              if finest_oc_name != name and taxon_name.predict_three_forms.values.include?(finest_oc_name)
                taxon_name.name = finest_oc_name
              end
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

          else
            # parent is a protonym, look at parents in checklist to build combination
            parent_elements = create_parent_element_hash
          end

          combination_attributes = { **parent_elements }
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

          # if error exist with taxon_name_relationships, add their errors under the main attribute (:taxon_name_relationships)
          # eg:
          #   original error: {:taxon_name_relationships=>["is invalid"]}
          #   TNR error: [{:object_taxon_name_id=>["The parent Miomyrmecini and the Incertae Sedis placement (Dolichoderinae) should match"]}]
          #   resulting message: {:taxon_name_relationships=>["is invalid", "The parent Miomyrmecini and the Incertae Sedis placement (Dolichoderinae) should match"]}
          # TODO expand to other relationships, like classifications
          if taxon_name.errors.messages[:taxon_name_relationships]
            # skip relationships with no errors
            errored_relationships = taxon_name.taxon_name_relationships.reject { |r| r.errors.empty? }

            # add error messages to taxon_name.errors[:taxon_name_relationships]
            errored_relationships.each { |r| r.errors.map { |error| taxon_name.errors.add(:taxon_name_relationships, message: error.message) } }
          end

          self.metadata[:error_data] = {
            messages: taxon_name.errors.messages
          }
        end

        save!

        if self.status == 'Imported'
          # loop over dependants, see if all other dependencies are met, if so mark them as ready
          metadata['dependants'].each do |dependant_taxonID|
            if dependencies_imported?(dependant_taxonID)
              DatasetRecord::DarwinCore::Taxon.where(status: 'NotReady',
                                                     id: import_dataset.core_records_fields
                                                                       .at(get_field_mapping(:taxonID))
                                                                       .where(value: dependant_taxonID)
                                                                       .select(:dataset_record_id)
              ).first&.update!(status: 'Ready')
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

  # Create a hash of parents from checklist
  # @return [Hash{Symbol => TaxonName}] hash of ranks and TaxonNames of genus and species rank parents
  def create_parent_element_hash
    parent = get_parent

    # if parent is root, return empty hash
    return {} unless parent

    parents = [parent]

    while (next_parent = find_by_taxonID(parents[-1].metadata['parent']))
      parents << next_parent
    end

    # convert DatasetRecords into hash of rank, protonym pairs
    parent_elements = parents.to_h do |p|
      [
        # Key is rank (as set in checklist file)
        DatasetRecordField.where(dataset_record: p)
                          .at(get_field_mapping(:taxonRank))
          &.pick(:value)
          &.downcase&.to_sym,
        # value is Protonym
        TaxonName.find(p.metadata['imported_objects']['taxon_name']['id'])
      ]

    end

    parent_elements.filter! { |p_rank, _| ORIGINAL_COMBINATION_RANKS.has_key?(p_rank) }
    parent_elements
  end

  # @return Optional[DatasetRecord::DarwinCore::Taxon, Array<DatasetRecord::DarwinCore::Taxon>]
  def get_parent
    DatasetRecord::DarwinCore::Taxon.where(id: import_dataset.core_records_fields
                                                             .at(get_field_mapping(:taxonID))
                                                             .with_value(get_field_value(:parentNameUsageID))
                                                             .select(:dataset_record_id)
    ).first
  end

  # @return Optional[DatasetRecord::DarwinCore::Taxon, Array<DatasetRecord::DarwinCore::Taxon>]
  def get_original_combination
    DatasetRecord::DarwinCore::Taxon.where(id: import_dataset.core_records_fields
                                                             .at(get_field_mapping(:taxonID))
                                                             .with_value(get_field_value(:originalNameUsageID))
                                                             .select(:dataset_record_id)
    ).first
  end

  # @return Optional[DatasetRecord::DarwinCore::Taxon, Array<DatasetRecord::DarwinCore::Taxon>]
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
