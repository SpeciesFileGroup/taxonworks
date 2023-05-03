class DatasetRecord::DarwinCore::Occurrence < DatasetRecord::DarwinCore

  DWC_CLASSIFICATION_TERMS = %w{kingdom phylum class order family} # genus, subgenus, specificEpithet and infraspecificEpithet are extracted from scientificName
  PARSE_DETAILS_KEYS = %i(uninomial genus species infraspecies)

  ACCEPTED_ATTRIBUTES = {
    :CollectionObject => %I(
      buffered_collecting_event buffered_determinations buffered_other_labels
      total
    ).to_set.freeze,

    :CollectingEvent => %I(
      document_label print_label verbatim_label
      field_notes formation
      group
      lithology
      max_ma maximum_elevation member min_ma minimum_elevation elevation_precision
      start_date_day start_date_month start_date_year end_date_day end_date_month end_date_year
      time_end_hour time_end_minute time_end_second time_start_hour time_start_minute time_start_second
      verbatim_collectors verbatim_date verbatim_datum verbatim_elevation verbatim_geolocation_uncertainty verbatim_habitat
      verbatim_latitude verbatim_locality verbatim_longitude verbatim_method verbatim_trip_identifier
    ).to_set.freeze
  }.freeze

  class ImportProtonym

    def self.create_if_not_exists
      @create_if_not_exists ||= CreateIfNotExists.new
    end

    def self.match_existing
      @match_existing ||= MatchExisting.new
    end

    def execute(origins, parent, name)
      protonym = get_protonym(parent, name)
      raise DatasetRecord::DarwinCore::InvalidData.new(exception_args(origins, parent, name, protonym)) unless protonym&.persisted?
      protonym
    end

    def get_protonym(parent, name)
      name = name.except(:rank_class) if name[:rank_class].nil?

      %I(name masculine_name feminine_name neuter_name).inject(nil) do |protonym, field|
        break protonym unless protonym.nil?

        p = Protonym.find_by(name.slice(:rank_class).merge({field => name[:name], :parent => parent}))

        # Protonym might not exist, or might have intermediate parent not listed in file
        # if it exists, run more expensive query to see if it has an ancestor matching parent name and rank
        if p.nil? && Protonym.where(name.slice(:rank_class).merge({field => name[:name]})).where(project_id: parent.project_id).exists?
          p = Protonym.where(name.slice(:rank_class).merge!({field => name[:name]})).with_ancestor(parent).first

          # check parent.cached_valid_taxon_name_id if not valid, can have obsolete subgenus Aus (Aus) bus -> Aus bus, bus won't have ancestor (Aus)
          if p.nil? && !parent.cached_is_valid
            p = Protonym.where(name.slice(:rank_class).merge!({field => name[:name]})).with_ancestor(parent.valid_taxon_name).first
        end

        end
        p
      end
    end
    class CreateIfNotExists < ImportProtonym
      def get_protonym(parent, name)
        super || Protonym.create({parent: parent, also_create_otu: true}.merge!(name))
      end

      def exception_args(origins, parent, name, protonym)
        {
          origins[name.object_id] => name[:rank_class].present? ?
          protonym.errors.messages.values.flatten :
          ["Rank for #{name[:name]} could not be determined. Please create this taxon name manually and retry."]
        }
      end
    end

    class MatchExisting < ImportProtonym
      def exception_args(origins, parent, name, protonym)
        {
          origins[name.object_id] =>
          ["Protonym #{name[:name]} not found with that name and/or classification. Importing new names is disabled by import settings."]
        }
      end
    end
  end

  def import(dwc_data_attributes = {})
    super
    begin
      DatasetRecord.transaction(requires_new: true) do
        self.metadata.delete("error_data")

        names, origins = parse_taxon_class
        strategy = self.import_dataset.restrict_to_existing_nomenclature? ? ImportProtonym.match_existing : ImportProtonym.create_if_not_exists

        innermost_otu = nil
        innermost_protonym = names.inject(project.root_taxon_name) do |parent, name|
          otu_attributes = name.delete(:otu_attributes)

          unless name[:rank_class] || otu_attributes.present?
            name[:rank_class] = parent.predicted_child_rank(name[:name])&.to_s
            name.delete(:rank_class) unless name[:rank_class] && /::FamilyGroup::/ =~ name[:rank_class]
          end

          strategy.execute(origins, parent, name).tap do |protonym|
            innermost_otu = Otu.find_or_create_by!({taxon_name: protonym}.merge!(otu_attributes)) if otu_attributes
          end
        end

        attributes = parse_record_level_class
        record_level_biocuration_classifications = attributes.dig(:specimen, :biocuration_classifications)
        attributes.deep_merge!(parse_occurrence_class)
        attributes.deep_merge!(parse_event_class)
        attributes.deep_merge!(parse_location_class)
        attributes.deep_merge!(parse_identification_class)

        attributes.deep_merge!(parse_tw_collection_object_data_attributes)
        attributes.deep_merge!(parse_tw_collecting_event_data_attributes)

        attributes.deep_merge!(parse_tw_collection_object_attributes)
        attributes.deep_merge!(parse_tw_collecting_event_attributes)

        append_dwc_attributes(dwc_data_attributes['CollectionObject'], attributes[:specimen])
        append_dwc_attributes(dwc_data_attributes['CollectingEvent'], attributes[:collecting_event])

        Utilities::Hashes::set_unless_nil(attributes[:specimen], :biocuration_classifications,
          (parse_biocuration_group_fields.dig(:specimen, :biocuration_classifications) || []) +
          (record_level_biocuration_classifications || []) +
          (attributes.dig(:specimen, :biocuration_classifications) || [])
        )

        specimen = Specimen.create!({
          no_dwc_occurrence: true
        }.merge!(attributes[:specimen]))

        if attributes[:type_material] && (innermost_otu&.name).nil?

          type_material = TypeMaterial.new(
            {
              protonym: innermost_protonym,
              collection_object: specimen,
            }.merge!(attributes[:type_material])) # protoynm can be overwritten in type_materials hash if OC did not match scientific name / innermost_protonym

          if self.import_dataset.require_type_material_success? # raise error if validations fail and it cannot be imported
            type_material.save!
          else
            # Best effort only, import will proceed even if creating the type material fails
            type_material.save
          end
        end

        if attributes.dig(:catalog_number, :identifier)
          namespace = attributes.dig(:catalog_number, :namespace)
          delete_namespace_prefix!(attributes.dig(:catalog_number, :identifier), namespace)

          identifier = Identifier::Local::CatalogNumber
            .create_with(identifier_object: specimen)
            .find_or_create_by!(attributes[:catalog_number])
          object = identifier.identifier_object

          unless object == specimen
            raise DarwinCore::InvalidData.new({ "catalogNumber" => ["Is already in use"] }) unless self.import_dataset.containerize_dup_cat_no?
            if object.is_a?(Container)
              object.add_container_items([specimen])
            else
              identifier.update!(
                identifier_object: Container::Virtual.containerize([object, specimen])
              )
            end
          end
        end

        Identifier::Local::Import::Dwc.create!(
          namespace: import_dataset.get_core_record_identifier_namespace,
          identifier_object: specimen,
          identifier: get_field_value(:occurrenceID)
        ) unless get_field_value(:occurrenceID).nil? || import_dataset.get_core_record_identifier_namespace.nil?

        specimen.taxon_determinations.create!({
          otu: innermost_otu || innermost_protonym.otus.find_by(name: nil) || innermost_protonym.otus.first # TODO: Might require select-and-confirm functionality
        }.merge(attributes[:taxon_determination]))

        event_id = get_field_value(:eventID)
        unless event_id.nil?
          namespace = get_field_value('TW:Namespace:eventID')

          identifier_type = Identifier::Global.descendants.detect { |c| c.name.downcase == namespace.downcase } if namespace
          identifier_attributes = {
            identifier: event_id,
            identifier_object_type: 'CollectingEvent',
            project_id: Current.project_id
          }

          if identifier_type.nil?
            identifier_type = Identifier::Local::TripCode # TODO: Or maybe Identifier::Local::Import?

            if namespace.nil?
              namespace = import_dataset.get_event_id_namespace
            else
              namespace = Namespace.find_by(Namespace.arel_table[:short_name].matches(namespace)) # Case insensitive match
              raise DarwinCore::InvalidData.new({ "TW:Namespace:eventID" => ["Namespace not found"] }) unless namespace
            end

            identifier_attributes[:namespace] = namespace

            delete_namespace_prefix!(event_id, namespace)
          end

          collecting_event = identifier_type.find_by(identifier_attributes)&.identifier_object
        end

        # TODO: If all attributes are equal assume it is the same event and share it with other specimens? (eventID is an alternate method to detect duplicates)
        if collecting_event
          # if tags have been specified to be added, update the collecting event
          if attributes[:collecting_event][:tags_attributes]
            # get list of preexisting tags, exclude them from update
            current_tags = collecting_event.tags.pluck(:keyword_id).to_set

            new_tags = attributes[:collecting_event][:tags_attributes].reject { |t| current_tags.member?(t[:keyword].id) }

            # add tags if there were any new ones
            unless new_tags.empty?
              collecting_event.tags.build(new_tags)
              collecting_event.save!
            end
          end

          specimen.update!(collecting_event: collecting_event)
        else
          collecting_event = CollectingEvent.create!({
            collection_objects: [specimen],
            no_dwc_occurrence: true
          }.merge!(attributes[:collecting_event]))

          identifier_type.create!({
            identifier_object: collecting_event
          }.merge!(identifier_attributes)) unless identifier_attributes.nil?

          Georeference::VerbatimData.create!({
            collecting_event: collecting_event,
            error_radius: get_field_value("coordinateUncertaintyInMeters"),
            no_cached: true
          }.merge(attributes[:georeference])) if collecting_event.verbatim_latitude && collecting_event.verbatim_longitude
        end

        DwcOccurrenceUpsertJob.perform_later(specimen)

        self.metadata["imported_objects"] = { collection_object: { id: specimen.id } }
        self.status = "Imported"
      end
    rescue DarwinCore::InvalidData => invalid
      self.status = "Errored"
      self.metadata["error_data"] = { messages: invalid.error_data }
    rescue ActiveRecord::RecordInvalid => invalid
      self.status = "Errored"
      self.metadata["error_data"] = {
        messages: invalid.record.errors.messages
      }
    rescue StandardError => e
      raise if Rails.env.development?
      self.status = "Failed"
      self.metadata["error_data"] = {
        exception: {
          message: e.message,
          backtrace: e.backtrace
        }
      }
    ensure
      save!
    end

    self
  end

  private

  def term_value_changed(name, value)
    if ['institutioncode', 'collectioncode', 'catalognumber', 'basisofrecord'].include?(name.downcase) and self.status != 'Imported'
      ready = get_field_value('catalogNumber').blank?
      ready ||= !!self.import_dataset.get_catalog_number_namespace(get_field_value('institutionCode'), get_field_value('collectionCode'))

      self.metadata.delete("error_data")
      if ready
        self.status = 'Ready'
      else
        self.status = 'NotReady'
        self.metadata["error_data"] = { messages: { catalogNumber: ["Record cannot be imported until namespace is set, see \"Settings\"."] } }
      end

      self.import_dataset.add_catalog_number_namespace(get_field_value('institutionCode'), get_field_value('collectionCode'))
      self.import_dataset.add_catalog_number_collection_code_namespace(get_field_value('collectionCode'))

      self.save!
    end
  end

  def get_integer_field_value(field_name)
    value = get_field_value(field_name)

    unless value.blank?
      begin
        raise unless /^\s*(?<integer>[+-]?\d+)\s*$/ =~ value
        value = integer.to_i
      rescue
        raise DarwinCore::InvalidData.new({ field_name => ["'#{value}' is not a valid integer value"] })
      end
    else
      value = nil
    end

    value
  end

  # NOTE: Sometimes an identifier/collector happens to be a non-person (like "ANSP Orthopterist"). Does TW (will) have something for this? Currently imported as an Unvetted Person.
  def parse_people(field_name)
    Person.transaction(requires_new: true) do
      DwcAgent.parse(get_field_value(field_name)).map! { |n| DwcAgent.clean(n) }.map! do |name|
        attributes = {
          last_name: [name[:particle], name[:family]].compact.join(" "),
          first_name: name[:given],
          suffix: name[:suffix],
          prefix: name[:title] || name[:appellation]
        }

        # self.import_dataset.derived_people.merge(Person.where(attributes)).first || # TODO: Doesn't work, fails to detect Person subclasses. Why (besides explanation in Shared::OriginRelationship)?
        Person.where(attributes).joins(:related_origin_relationships).merge(
          OriginRelationship.where(old_object: self.import_dataset)
        ).first ||
        Person::Unvetted.create!(attributes.merge({
          related_origin_relationships: [OriginRelationship.new(old_object: self.import_dataset)]
        }))
      end
    end
  end

  # Parse an iso date string from the specified column name
  #
  # The date may be a single date, or an interval of two dates separated by a slash.
  # The second date may omit higher-order elements that are the same as the first date.
  # See https://en.wikipedia.org/wiki/ISO_8601#Time_intervals for more information.
  #
  # @param [String] field_name The column name to get the date string from
  # @return [Array<OpenStruct>] A list of one or two date structs (with year, month, day, hour, minute, second values)
  def parse_iso_date(field_name)
    value = get_field_value(field_name)

    return nil if value.nil?

    result = Utilities::Dates.parse_iso_date_str(value)
    raise DarwinCore::InvalidData.new(
      {
        "#{field_name}":
          ["Invalid date. Please make sure it conforms to ISO 8601 date format (yyyy-mm-ddThh:mm:ss). If expressing interval separate result with '/'. Examples: 1972-05; 1983-10-25; 2020-09-22T15:30; 2020-11-30/2020-12-04"]
      }
    ) if result.nil?
    result
  end

  # Remove the namespace short name and delimiter from start of string.
  #
  # If the namespace has a verbatim_short_name, that is removed instead of the short_name.
  # The delimiter is only removed if the short_name was found in the identifier.
  # @param [String] identifier_str
  # @param [Namespace] namespace
  def delete_namespace_prefix!(identifier_str, namespace)
    identifier_str&.delete_prefix!(namespace.verbatim_short_name || namespace.short_name)&.delete_prefix!(namespace.delimiter || '') if namespace
  end

  def parse_record_level_class
    res = {
      specimen: {},
      catalog_number: {}
    }
    # type: [Check it is 'PhysicalObject']
    type = get_field_value(:type) || 'PhysicalObject'
    raise DarwinCore::InvalidData.new({ 'type' => ["Only 'PhysicalObject' or empty allowed"] }) if type != 'PhysicalObject'

    # modified: [Not mapped]

    # language: [Not mapped]

    # license: [Not mapped. Possible with Attribution model? To which object(s)?]

    # rightsHolder: [Not mapped. Same questions as license but using roles]

    # accessRights: [Not mapped. Related to license]

    # bibliographicCitation: [Not mapped]

    # references: [Not mapped]

    # institutionID: [Not mapped. Review]

    # collectionID: [Not mapped. Review]

    # datasetID: [Not mapped]

    # institutionCode: [repository.acronym] # TODO: Use mappings like with namespaces here as well? (Although probably attempt guessing)
    institution_code = get_field_value(:institutionCode)
    if institution_code
      repository = Repository.find_by(acronym: institution_code)

      # Some repositories may not have acronyms, in that case search by name as well
      unless repository
        repository_results = Repository.where(Repository.arel_table['name'].matches(Repository.sanitize_sql_like(institution_code)))
        raise DarwinCore::InvalidData.new({ "institutionCode": ["Multiple repositories match the name #{institution_code}. Please use the acronym instead."] }) if repository_results.count > 1
        repository = repository_results.first
      end
      raise DarwinCore::InvalidData.new({ "institutionCode": ["Unknown #{institution_code} repository. If valid please register it using '#{institution_code}' as acronym or name."] }) unless repository
      Utilities::Hashes::set_unless_nil(res[:specimen], :repository, repository)
    end

    # collectionCode: [catalog_number.namespace]
        # collection_code = get_field_value(:collectionCode)
        # Utilities::Hashes::set_unless_nil(res[:catalog_number], :namespace, Namespace.create_with({
        #     name: "#{institution_code}-#{collection_code} [CREATED FROM DWC-A IMPORT IN #{project.name} PROJECT]",
        #     delimiter: '-'
        # }).find_or_create_by!(short_name: "#{institution_code}-#{collection_code}")) if collection_code
    namespace_id = self.import_dataset.get_catalog_number_namespace(institution_code, get_field_value(:collectionCode))
    if namespace_id
      Utilities::Hashes::set_unless_nil(res[:catalog_number], :namespace, Namespace.find(namespace_id))
      Utilities::Hashes::set_unless_nil(res[:catalog_number], :project, self.project)
    end

    # datasetName: [Not mapped]

    # ownerInstitutionCode: [Not mapped]

    # basisOfRecord: [Check it is 'PreservedSpecimen', 'FossilSpecimen']
    basis = get_field_value(:basisOfRecord)
    if 'FossilSpecimen'.casecmp(basis) == 0
      fossil_biocuration = BiocurationClass.find_by(uri: DWC_FOSSIL_URI)

      raise DarwinCore::InvalidData.new(
        { 'basisOfRecord' => ["Biocuration class #{DWC_FOSSIL_URI} is not present in project"] }
      ) if fossil_biocuration.nil?

      Utilities::Hashes::set_unless_nil(res[:specimen], :biocuration_classifications, [BiocurationClassification.new(biocuration_class: fossil_biocuration)])
    else
      raise DarwinCore::InvalidData.new(
        { 'basisOfRecord' => ["Only 'PreservedSpecimen', 'FossilSpecimen' or blank is allowed."] }
      ) unless basis.nil? || 'PreservedSpecimen'.casecmp(basis) == 0
    end

    # informationWithheld: [Not mapped]

    # dataGeneralizations: [Not mapped]

    # dynamicProperties: [Not mapped. Could be ImportAttribute?]

    Utilities::Hashes::delete_nil_and_empty_hash_values(res)
  end

  def parse_occurrence_class
    res = {
      catalog_number: {},
      specimen: {},
      collecting_event: {}
    }

    # occurrenceID: [Mapped in import method]

    # catalogNumber: [catalog_number.identifier]
    Utilities::Hashes::set_unless_nil(res[:catalog_number], :identifier, get_field_value(:catalogNumber))

    # recordNumber: [Not mapped]

    # recordedBy: [collecting_event.collectors and collecting_event.verbatim_collectors]
    Utilities::Hashes::set_unless_nil(res[:collecting_event], :collectors, (parse_people(:recordedBy) rescue nil))
    Utilities::Hashes::set_unless_nil(res[:collecting_event], :verbatim_collectors, get_field_value(:recordedBy))

    # individualCount: [specimen.total]
    Utilities::Hashes::set_unless_nil(res[:specimen], :total, get_field_value(:individualCount) || 1)

    # organismQuantity: [Not mapped. Check relation with invidivialCount]

    # organismQuantityType: [Not mapped. Check relation with invidivialCount]

    # sex: [Find or create by name inside Sex biocuration Group] TODO: Think of duplicates (with and without URI)
    sex = get_field_value(:sex)
    if sex
      raise DarwinCore::InvalidData.new({ "sex": ["Only single-word controlled vocabulary supported at this time."] }) if sex =~ /\s/
      group   = BiocurationGroup.find_by(project_id: Current.project_id, uri: DWC_ATTRIBUTE_URIS[:sex])
      group ||= BiocurationGroup.where(project_id: Current.project_id).where('name ILIKE ?', 'sex').first
      group ||= BiocurationGroup.create!(
        name: 'Sex',
        definition: 'The sex of the individual(s) [CREATED FROM DWC-A IMPORT]',
        uri: DWC_ATTRIBUTE_URIS[:sex]
      )
      # TODO: BiocurationGroup.biocuration_classes not returning AR relation
      sex_biocuration = group.biocuration_classes.detect { |c| c.name.casecmp(sex) == 0 }
      unless sex_biocuration
        sex_biocuration = BiocurationClass.create!(name: sex, definition: "#{sex} individual(s) [CREATED FROM DWC-A IMPORT]")
        Tag.create!(keyword: group, tag_object: sex_biocuration)
      else
        sex = sex_biocuration
      end

      Utilities::Hashes::set_unless_nil(res[:specimen], :biocuration_classifications, [BiocurationClassification.new(biocuration_class: sex_biocuration)])
    end

    # lifeStage: [Not mapped]

    # reproductiveCondition: [Not mapped]

    # behavior: [Not mapped]

    # establishmentMeans: [Not mapped]

    # degreeOfEstablishment [Not mapped]

    # pathway [Not mapped]

    # occurrenceStatus: [Not mapped]

    # preparations: [Match PreparationType by name (case insensitive)]
    preparation_name = get_field_value(:preparations)
    if preparation_name
      preparation_type = PreparationType.find_by(PreparationType.arel_table[:name].matches(preparation_name))

      raise DarwinCore::InvalidData.new({
        "preparations": ["Unknown preparation \"#{preparation_name}\". If it is correct please add it to preparation types and retry."]
      }) unless preparation_type

      Utilities::Hashes::set_unless_nil(res[:specimen], :preparation_type, preparation_type)
    end

    Utilities::Hashes::delete_nil_and_empty_hash_values(res)

    # disposition: [Not mapped]

    # associatedMedia: [Not mapped]

    # associatedReferences: [Not mapped]

    # associatedSequences: [Not mapped]

    # associatedTaxa: [Not mapped]

    # otherCatalogNumbers: [Not mapped]

    # occurrenceRemarks: [specimen note]
    note = get_field_value(:occurrenceRemarks)
    Utilities::Hashes::set_unless_nil(res[:specimen], :notes_attributes, [{text: note}]) if note

    res
  end

  def parse_event_class
    collecting_event = { }

    # eventID: [Mapped in import method]

    # parentEventID: [Not mapped]

    # fieldNumber: verbatim_trip_identifier
    Utilities::Hashes::set_unless_nil(collecting_event, :verbatim_trip_identifier, get_field_value(:fieldNumber))

    start_date, end_date = parse_iso_date(:eventDate)

    year = get_integer_field_value(:year)
    month = get_integer_field_value(:month)
    day = get_integer_field_value(:day)
    startDayOfYear = get_integer_field_value(:startDayOfYear)

    raise DarwinCore::InvalidData.new({ "eventDate": ["Conflicting values. Please check year, month, and day match eventDate"] }) if start_date &&
      (year && start_date.year != year || month && start_date.month != month || day && start_date.day != day)

    year  ||= start_date&.year
    month ||= start_date&.month
    day   ||= start_date&.day

    if startDayOfYear
      raise DarwinCore::InvalidData.new({ "startDayOfYear": ["Missing year value"] }) if year.nil?

      begin
        ordinal = Date.ordinal(year, startDayOfYear)
      rescue Date::Error
        raise DarwinCore::InvalidData.new({ "startDayOfYear": ["Out of range. Please also check year field"] })
      end

      if month && ordinal.month != month || day && ordinal.day != day
        raise DarwinCore::InvalidData.new({ "startDayOfYear": ["Month and/or day of the event date do not match"] })
      end

      month ||= ordinal.month
      day ||= ordinal.day
    end

    # eventDate | (year+month+day) | (year+startDayOfYear): start_date_*
    Utilities::Hashes::set_unless_nil(collecting_event, :start_date_year, year)
    Utilities::Hashes::set_unless_nil(collecting_event, :start_date_month, month)
    Utilities::Hashes::set_unless_nil(collecting_event, :start_date_day, day)

    # eventTime: time_start_*
    %r{^
      (?<start_hour>\d+)(:(?<start_minute>\d+))?(:(?<start_second>\d+))?
      (/(?<end_hour>\d+))?(:(?<end_minute>\d+))?(:(?<end_second>\d+))?
    $}x =~ get_field_value(:eventTime)
    Utilities::Hashes::set_unless_nil(collecting_event, :time_start_hour, start_hour)
    Utilities::Hashes::set_unless_nil(collecting_event, :time_start_minute, start_minute)
    Utilities::Hashes::set_unless_nil(collecting_event, :time_start_second, start_second)
    Utilities::Hashes::set_unless_nil(collecting_event, :time_end_hour, end_hour)
    Utilities::Hashes::set_unless_nil(collecting_event, :time_end_minute, end_minute)
    Utilities::Hashes::set_unless_nil(collecting_event, :time_end_second, end_second)

    endDayOfYear = get_integer_field_value(:endDayOfYear)

    if endDayOfYear
      raise DarwinCore::InvalidData.new({ "endDayOfYear": ["Missing year value"] }) if year.nil?

      begin
        ordinal = Date.ordinal(year, endDayOfYear)
      rescue Date::Error
        raise DarwinCore::InvalidData.new({ "endDayOfYear": ["Out of range. Please also check year field"] })
      end

      month = ordinal.month
      day = ordinal.day

      raise DarwinCore::InvalidData.new({ "eventDate": ["Conflicting values. Please check year and endDayOfYear match eventDate"] }) if end_date &&
      (year && end_date.year != year || month && end_date.month != month || day && end_date.day != day)
    else
      year = end_date&.year
      month = end_date&.month
      day = end_date&.day
    end

    Utilities::Hashes::set_unless_nil(collecting_event, :end_date_year, year)
    Utilities::Hashes::set_unless_nil(collecting_event, :end_date_month, month)
    Utilities::Hashes::set_unless_nil(collecting_event, :end_date_day, day)

    # verbatimEventDate: verbatim_date
    Utilities::Hashes::set_unless_nil(collecting_event, :verbatim_date, get_field_value(:verbatimEventDate))

    # habitat: verbatim_habitat
    Utilities::Hashes::set_unless_nil(collecting_event, :verbatim_habitat, get_field_value(:habitat))

    # samplingProtocol: verbatim_method
    Utilities::Hashes::set_unless_nil(collecting_event, :verbatim_method, get_field_value(:samplingProtocol))

    # sampleSizeValue: [Not mapped]

    # sampleSizeUnit: [Not mapped]

    # samplingEffort: [Not mapped]

    # fieldNotes: field_notes
    Utilities::Hashes::set_unless_nil(collecting_event, :field_notes, get_field_value(:fieldNotes))

    # eventRemarks: [collecting event note]
    note = get_field_value(:eventRemarks)
    Utilities::Hashes::set_unless_nil(collecting_event, :notes_attributes, [{text: note}]) if note

    { collecting_event: collecting_event }
  end

  def parse_location_class
    collecting_event = {}
    georeference = {}

    # locationID: [Not mapped]

    # higherGeographyID: [Not mapped]

    # higherGeography: [Not mapped]

    # continent: [Not mapped]

    # waterBody: [Not mapped]

    # islandGroup: [Not mapped]

    # island: [Not mapped]

    # country: [Not mapped]

    # countryCode: [Not mapped]

    # stateProvince: [Not mapped]

    # county: [Not mapped]

    # municipality: [Not mapped]

    # locality: [Not mapped]

    # verbatimLocality: [verbatim_locality]
    Utilities::Hashes::set_unless_nil(collecting_event, :verbatim_locality, get_field_value(:verbatimLocality))

    # minimumElevationInMeters: [Not mapped]
    Utilities::Hashes::set_unless_nil(collecting_event, :minimum_elevation, get_field_value(:minimumElevationInMeters))

    # maximumElevationInMeters: [Not mapped]
    Utilities::Hashes::set_unless_nil(collecting_event, :maximum_elevation, get_field_value(:maximumElevationInMeters))

    # verbatimElevation: [Not mapped]
    Utilities::Hashes::set_unless_nil(collecting_event, :verbatim_elevation, get_field_value(:verbatimElevation))

    # minimumDepthInMeters: [Not mapped. REVISIT]

    # maximumDepthInMeters: [Not mapped. REVISIT]

    # verbatimDepth: [Not mapped. REVISIT]

    # minimumDistanceAboveSurfaceInMeters: [Not mapped]

    # maximumDistanceAboveSurfaceInMeters: [Not mapped]

    # locationAccordingTo: [Not mapped. REVISIT]

    # locationRemarks: [Not mapped. REVISIT]

    # decimalLatitude: [verbatim_latitude]
    Utilities::Hashes::set_unless_nil(collecting_event, :verbatim_latitude, get_field_value(:decimalLatitude))

    # decimalLongitude: [verbatim_longitude]
    Utilities::Hashes::set_unless_nil(collecting_event, :verbatim_longitude, get_field_value(:decimalLongitude))

    # geodeticDatum: [verbatim_datum]
    Utilities::Hashes::set_unless_nil(collecting_event, :verbatim_datum, get_field_value(:geodeticDatum))

    # coordinateUncertaintyInMeters: [verbatim_geolocation_uncertainty]
    uncertainty = get_field_value(:coordinateUncertaintyInMeters)
    unless uncertainty.nil? || uncertainty =~ /\A[+-]?\d+\z/
      raise DarwinCore::InvalidData.new({ "coordinateUncertaintyInMeters": ["Non-integer value"] })
    end
    Utilities::Hashes::set_unless_nil(collecting_event, :verbatim_geolocation_uncertainty, uncertainty&.send(:+, 'm'))

    # coordinatePrecision: [Not mapped. Fail import if claimed precision is incorrect? Round to precision?]

    # pointRadiusSpatialFit: [Not mapped]

    # verbatimCoordinates: [Not mapped]

    # verbatimLatitude: [Not mapped]

    # verbatimLongitude: [Not mapped]

    # verbatimCoordinateSystem: [Not mapped]

    # verbatimSRS: [Not mapped]

    # footprintWKT: [Not mapped]

    # footprintSRS: [Not mapped]

    # footprintSpatialFit: [Not mapped]

    # georeferencedBy: [Not mapped]
    if georeferenced_by = get_field_value(:georeferencedBy)
      predicate_base_props = {uri: 'http://rs.tdwg.org/dwc/terms/georeferencedBy', project: self.project}
      predicate = Predicate.find_by(predicate_base_props)
      predicate ||= Predicate.where(project: project).find_by(
        Predicate.arel_table[:name].matches('georeferencedBy')
      )
      predicate ||= Predicate.create!(predicate_base_props.merge(
        {
          name: 'georeferencedBy',
          definition: 'A list (concatenated and separated) of names of people, groups, or organizations who determined the georeference (spatial representation) for the Location.'
        })
      )

      georeference[:data_attributes] = [
        InternalAttribute.new(
          type: 'InternalAttribute',
          predicate: predicate,
          value: georeferenced_by
        )
      ]
    end

    # georeferencedDate: [Not mapped]

    # georeferenceProtocol: [Not mapped]

    # georeferenceSources: [Not mapped. REVISIT]

    # georeferenceVerificationStatus: [Not mapped]

    # georeferenceRemarks: [georeference note]
    note = get_field_value(:georeferenceRemarks)
    georeference[:notes_attributes] = [{text: note}] if note

    {
      collecting_event: collecting_event,
      georeference: georeference
    }
  end

  def parse_identification_class
    taxon_determination = {}
    type_material = nil

    # identificationID: [Not mapped]

    # identificationQualifier: [Mapped as part of otu name in parse_taxon_class]

    # typeStatus: [Type material only if scientific name matches scientificName and type term is recognized by TW vocabulary]
    type_status = get_field_value(:typeStatus)
    type_status_parsed = type_status&.match(/^(?<type>\w+)$/i) || type_status&.match(/(?<type>\w+)(\s+OF\s+(?<scientificName>.*))/i)
    scientific_name = get_field_value(:scientificName)&.gsub(/\s+/, ' ')
    type_scientific_name = (type_status_parsed&.[](:scientificName)&.gsub(/\s+/, ' ') rescue nil) || scientific_name

    if type_status_parsed && scientific_name && type_scientific_name.present?

      # if type_scientific_name matches the current name of the occurrence, use that
      if type_scientific_name&.delete_prefix!(scientific_name)&.match(/^\W*$/)
        type_material = {
          type_type: type_status_parsed[:type].downcase
        }
      elsif (original_combination_protonym = Protonym.find_by(cached_original_combination: type_scientific_name, project_id: self.project_id))
        type_material = {
          type_type: type_status_parsed[:type].downcase,
          protonym: original_combination_protonym
        }
      end
    end

    if type_status && type_material.nil?
      raise DarwinCore::InvalidData.new({ "typeStatus": ["Unprocessable typeStatus information"] }) if self.import_dataset.require_type_material_success?
    end

    # identifiedBy: determiners of taxon determination
    Utilities::Hashes::set_unless_nil(taxon_determination, :determiners, parse_people(:identifiedBy))

    # dateIdentified: {year,month,day}_made of taxon determination
    start_date, end_date = parse_iso_date(:dateIdentified)

    raise DarwinCore::InvalidData.new({ "dateIdentified": ["Date range for taxon determination is not supported."] }) if end_date

    if start_date
      Utilities::Hashes::set_unless_nil(taxon_determination, :year_made, start_date.year)
      Utilities::Hashes::set_unless_nil(taxon_determination, :month_made, start_date.month)
      Utilities::Hashes::set_unless_nil(taxon_determination, :day_made, start_date.day)
    end

    # identificationReferences: [Not mapped. Can they be imported as citations without breaking semantics?]

    # identificationVerificationStatus: [Not mapped]

    # identificationRemarks: Note for taxon determination
    note = get_field_value(:identificationRemarks)
    taxon_determination[:notes_attributes] = [{text: note}] if note

    {
      taxon_determination: taxon_determination,
      type_material: type_material
    }
  end

  def parse_taxon_class
    names = []
    otu_names = []
    origins = {}
    # taxonID: [Not mapped. Usually alias of core id]

    # scientificNameID: [Not mapped. Could be mapped with type detection into LSID identifier or global ID]

    # acceptedNameUsageID: [N/A for occurrences]

    # parentNameUsageID: [N/A for occurrences]

    # originalNameUsageID: [N/A for occurrences]

    # nameAccordingToID: [Not mapped]

    # namePublishedInID: [Not mapped]

    # taxonConceptID: [Not mapped]

    # acceptedNameUsage: [Not mapped. Review]

    # parentNameUsage: [N/A for occurrences]

    # originalNameUsage: [Not mapped. Review]

    # nameAccordingTo: [Not mapped]

    # namePublishedIn: [Not mapped]

    # namePublishedInYear: [Not mapped]

    # nomenclaturalCode: [Selects nomenclature code to pick ranks from]
    code = get_field_value(:nomenclaturalCode)&.downcase&.to_sym || import_dataset.default_nomenclatural_code
    unless Ranks::CODES.include?(code)
      raise DarwinCore::InvalidData.new(
        { "nomenclaturalCode": ["Unrecognized nomenclatural code #{get_field_value(:nomenclaturalCode)}"] }
      )
    end

    # kingdom: [Kingdom protonym]
    origins[
      {rank_class: Ranks.lookup(code, "kingdom"), name: get_field_value(:kingdom)}.tap { |h| names << h }.object_id
    ] = :kingdom

    # phylum: [Phylum protonym]
    origins[
      {rank_class: Ranks.lookup(code, "phylum"), name: get_field_value(:phylum)}.tap { |h| names << h }.object_id
    ] = :phylum

    # class: [Class protonym]
    origins[
      {rank_class: Ranks.lookup(code, "class"), name: get_field_value(:class)}.tap { |h| names << h }.object_id
    ] = :class

    # order: [Order protonym]
    origins[
      {rank_class: Ranks.lookup(code, "order"), name: get_field_value(:order)}.tap { |h| names << h }.object_id
    ] = :order

    # family: [Family protonym]
    origins[
      {rank_class: Ranks.lookup(code, "family"), name: get_field_value(:family)}.tap { |h| names << h }.object_id
    ] = :family

    # genus: [Not mapped, extracted from scientificName instead]

    # subgenus: [Not mapped, extracted from scientificName instead]

    # specificEpithet: [Not mapped, extracted from scientificName instead]

    # infraspecificEpithet: [Not mapped, extracted from scientificName instead]

    # scientificName: [Parsed with biodiversity and mapped into several protonyms]
    parse_results = Biodiversity::Parser.parse(get_field_value(:scientificName) || "")
    parse_details = parse_results[:details]
    parse_details = (parse_details&.keys - PARSE_DETAILS_KEYS).empty? ? parse_details.values.first : nil if parse_details

    unless (1..3).include?(parse_results[:quality]) && parse_details
      parse_details = parse_results[:details]&.values&.first
      otu_names << get_field_value(:scientificName)
    end

    raise DarwinCore::InvalidData.new({
      "scientificName": parse_results[:qualityWarnings] ?
        parse_results[:qualityWarnings].map { |q| q[:warning] } :
        ["Unable to parse scientific name. Please make sure it is correctly spelled."]
    }) unless parse_details

    unless parse_details[:uninomial]
      origins[
        {rank_class: Ranks.lookup(code, "genus"), name: parse_details[:genus]}.tap { |h| names << h }.object_id
      ] = :scientificName
      origins[
        {rank_class: Ranks.lookup(code, "subgenus"), name: parse_details[:subgenus]}.tap { |h| names << h }.object_id
      ] = :scientificName
      origins[
        {rank_class: Ranks.lookup(code, "species"), name: parse_details[:species]}.tap { |h| names << h }.object_id
      ] = :scientificName
      origins[
        {rank_class: Ranks.lookup(code, "subspecies"), name: parse_details[:infraspecies]&.map{ |d| d.dig(:value) }&.join(' ') }.tap { |h| names << h }.object_id
      ] = :scientificName
    else
      if parse_details[:parent]
        origins[
          {rank_class: Ranks.lookup(code, "genus"), name: parse_details[:parent]}.tap { |h| names << h }.object_id
        ] = :scientificName
        origins[
          {
            rank_class: /subgen/ =~ parse_details[:rank] ? Ranks.lookup(code, "subgenus") : nil,
            name: parse_details[:uninomial]
          }.tap { |h| names << h }.object_id
        ] = :scientificName
      elsif get_field_value(:genus) == parse_details[:uninomial]
        origins[
          {rank_class: Ranks.lookup(code, "genus"), name: parse_details[:uninomial]}.tap { |h| names << h }.object_id
        ] = :scientificName
      elsif names.reverse.detect { |n| n[:name] }&.dig(:name) != parse_details[:uninomial]
        origins[
          {rank_class: nil, name: parse_details[:uninomial]}.tap { |h| names << h }.object_id
        ] = :scientificName
      end
    end

    names.reject! { |v| v[:name].nil? }

    # taxonRank: [Rank of innermost protonym]
    rank = get_field_value(:taxonRank)
    if rank && otu_names.empty?
      names.last[:rank_class] = Ranks.lookup(code, rank)
      raise DarwinCore::InvalidData.new({ "taxonRank": ["Unknown #{code.upcase} rank #{rank}"] }) unless names.last[:rank_class]
    end

    ident_qualifier = get_field_value(:identificationQualifier)
    if ident_qualifier =~ /^cf[\.\s]/
      otu_names << ident_qualifier
    else
      otu_names << "#{get_field_value(:scientificName)} #{ident_qualifier}"
    end unless ident_qualifier.nil?
    names.last&.merge!({otu_attributes: {name: otu_names.join(' ')}}) unless otu_names.empty?

    # higherClassification: [Several protonyms with ranks determined automatically when possible. Classification lower or at genus level is ignored and extracted from scientificName instead]
    higherClassification = ['|', ':', ';', ','].inject([]) do |names, separator|
      break names if names.size > 1
      get_field_value(:higherClassification)&.split(separator) || []
    end.map! do |name|
      normalize_value!(name)
      {rank_class: nil, name: name}
    end

    curr = 0
    names.each do |name|
      idx = higherClassification[curr..].index { |n| n[:name] == name[:name] }

      if idx
        higherClassification[curr+idx] = name
        curr += idx + 1
      end
    end
    idx = higherClassification.index { |n| n[:rank_class] == Ranks.lookup(code, "genus") }
    higherClassification = higherClassification.slice(0, idx) if idx

    curr = 0
    higherClassification.each do |name|
      if name[:rank_class]
        curr = names.index(name) + 1
      else
        names.insert(curr, name)
        origins[name.object_id] = :higherClassification
        curr += 1
      end
    end

    # verbatimTaxonRank: [Not mapped]

    # scientificNameAuthorship: [verbatim_author of innermost protonym]
    begin
      author_name, year = Utilities::Strings.parse_authorship(get_field_value("scientificNameAuthorship"))

      names.last&.merge!({ verbatim_author: author_name, year_of_publication: year })
    end

    # vernacularName: [Not mapped]

    # taxonomicStatus: [Not mapped. Review]

    # nomenclaturalStatus: [Not mapped. Review]

    # taxonRemarks: [Not mapped]

    [names, origins]
  end

  def parse_tw_collection_object_data_attributes
    attributes = []
    tags = []

    get_tw_data_attribute_fields_for('CollectionObject').each do |attribute|
      append_data_attribute(attributes, attribute)
    end

    get_tw_tag_fields_for('CollectionObject').each do |tag|
      append_tag_attribute(tags, tag)
    end

    {
      specimen: {
        data_attributes_attributes: attributes,
        tags_attributes: tags
      }
    }
  end

  def parse_tw_collecting_event_data_attributes
    attributes = []
    tags = []

    get_tw_data_attribute_fields_for('CollectingEvent').each do |attribute|
      append_data_attribute(attributes, attribute)
    end

    get_tw_tag_fields_for('CollectingEvent').each do |tag|
      append_tag_attribute(tags, tag)
    end

    {
      collecting_event: {
        data_attributes_attributes: attributes,
        tags_attributes: tags
      }
    }
  end

  def append_tag_attribute(tags, tag)
    value = get_field_value(tag[:field])
    return unless value

    keyword = Keyword.find_by(uri: tag[:selector], project: self.project)
    keyword ||= Keyword.where(project: project).find_by(
      Keyword.arel_table[:name].matches(ApplicationRecord.sanitize_sql_like(tag[:selector]))
    )

    if value
      raise DarwinCore::InvalidData.new({ tag[:field] => ["Tag with #{tag[:selector]} URI or name not found"] }) unless keyword

      if value.downcase == "true" || value == "1"
        tags.append({keyword: keyword})
        return
      end

      unless value.downcase == "false" || value == "0"
        raise DarwinCore::InvalidData.new({ tag[:field] => ["Tag value must be \"true\" or \"1\" to apply, or blank, \"false\", or \"0\", to not apply"] })
      end
    end
  end

  def append_data_attribute(attributes, attribute)
    predicate = Predicate.find_by(uri: attribute[:selector], project: self.project)
    predicate ||= Predicate.where(project: project).find_by(
      Predicate.arel_table[:name].matches(ApplicationRecord.sanitize_sql_like(attribute[:selector]))
    )

    value = get_field_value(attribute[:field])
    if value
      raise DarwinCore::InvalidData.new({ attribute[:field] => ["Predicate with #{attribute[:selector]} URI or name not found"] }) unless predicate
      attributes << {
        type: 'InternalAttribute',
        predicate: predicate,
        value: value
      }
    end
  end

  def parse_biocuration_group_fields
    {
      specimen: {
        biocuration_classifications: get_tw_biocuration_groups
          .map { |g| parse_biocuration_group_field(g) }
          .reject(&:nil?)
      }
    }
  end

  def parse_biocuration_group_field(group)
    biocuration_group = BiocurationGroup.find_by(uri: group[:selector], project: self.project)
    biocuration_group ||= BiocurationGroup.where(project: project).find_by(
      BiocurationGroup.arel_table[:name].matches(ApplicationRecord.sanitize_sql_like(group[:selector]))
    )

    value = get_field_value(group[:field])
    if value
      raise DarwinCore::InvalidData.new({ group[:field] => ["Biocuration group with '#{group[:selector]}' URI or name not found"] }) unless biocuration_group

      biocuration_class = BiocurationClass.where(project: project).joins(:tags).merge(
        Tag.where(keyword: biocuration_group)
      ).find_by(uri: value)
      biocuration_class ||= BiocurationClass.where(project: project).joins(:tags).merge(
        Tag.where(keyword: biocuration_group)
      ).find_by(
        BiocurationClass.arel_table[:name].matches(ApplicationRecord.sanitize_sql_like(value))
      )

      raise DarwinCore::InvalidData.new({ group[:field] => ["Biocuration class with '#{value}' URI or name not found"] }) unless biocuration_class

      BiocurationClassification.new(biocuration_class: biocuration_class)
    end
  end

  def parse_tw_collection_object_attributes

    attributes = {}

    get_tw_fields_for('CollectionObject').each do |attribute|
      value = get_field_value(attribute[:field])
      if value
        if !ACCEPTED_ATTRIBUTES[:CollectionObject].include?(attribute[:name])
          raise DarwinCore::InvalidData.new({ attribute[:field] => ["#{attribute[:name]} is not a valid CollectionObject attribute"] })
        end
        attributes[attribute[:name]] = value
      end
    end

    {
      specimen: attributes
    }
  end

  def parse_tw_collecting_event_attributes

    attributes = {}

    get_tw_fields_for('CollectingEvent').each do |attribute|
      value = get_field_value(attribute[:field])
      if value
        if !ACCEPTED_ATTRIBUTES[:CollectingEvent].include?(attribute[:name])
          raise DarwinCore::InvalidData.new({ attribute[:field] => ["#{attribute[:name]} is not a valid CollectingEvent attribute"] })
        end
        attributes[attribute[:name]] = value
      end
    end

    {
      collecting_event: attributes
    }
  end

  def append_dwc_attribute(attributes, predicate, value)
    attributes << {
      type: 'InternalAttribute',
      predicate: predicate,
      value: value
    } if value
  end

  def append_dwc_attributes(dwc_attributes, target)
    dwc_attributes.each do |field, predicate|
      append_dwc_attribute(target[:data_attributes_attributes], predicate, get_field_value(field))
    end
  end

end
