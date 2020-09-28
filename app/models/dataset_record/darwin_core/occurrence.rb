class DatasetRecord::DarwinCore::Occurrence < DatasetRecord

  DWC_CLASSIFICATION_TERMS = %w{kingdom phylum class order family} # genus, subgenus, specificEpithet and infraspecificEpithet are extracted from scientificName

  def import
    begin
      DatasetRecord.transaction do
        self.metadata.delete("error_data")

        parse_details = metadata.dig("parse_results", "details").first

        names = DWC_CLASSIFICATION_TERMS.map { |t| [t, get_field_value(t)] }

        names << ["genus", parse_details.dig("genus", "value")]
        names << ["subgenus", parse_details.dig("infragenericEpithet", "value")]
        names << ["species", parse_details.dig("specificEpithet", "value")]
        names << ["subspecies", parse_details["infraspecificEpithets"]&.first&.dig("value")]

        names.reject! { |v| v[1].nil? }

        raise DarwinCore::InvalidData.new({ "Taxon name": ["Unable to find or create a taxon name with supplied data"] }) if names.empty?

        rank = get_field_value("taxonRank")

        names.last[0] = rank unless rank.blank?

        # TODO: In case of existing duplicate protonyms this may contribute with duplication even further by traversing names by incorrect parent.
        # TODO2: Re-evaluate use of TaxonWorks::Vendor::Biodiversity::Result
        names.map! do |name|
          { rank_class: Ranks.lookup(:iczn, name[0]), name: name[1] }
        end
        names.last.merge!({ verbatim_author: get_field_value("scientificNameAuthorship") })

        parent = project.root_taxon_name
        names.each do |name|
          parent = Protonym.create_with(also_create_otu: true).find_or_create_by!(name.merge({ parent: parent }))
        end

        otu = parent.otus.first # TODO: Might require select-and-confirm functionality

        attributes = parse_record_level_class
        attributes.deep_merge!(parse_occurrence_class)
        attributes.deep_merge!(parse_event_class)

        specimen = Specimen.create!({
          no_dwc_occurrence: true
        }.merge!(attributes[:specimen]))

        if attributes[:catalog_number]
          namespace = attributes.dig(:catalog_number, :namespace)
          attributes.dig(:catalog_number, :identifier)&.delete_prefix!(namespace.verbatim_short_name || namespace.short_name) if namespace
          specimen.identifiers.create!({
            type: Identifier::Local::CatalogNumber
          }.merge!(attributes[:catalog_number]))
        end

        specimen.taxon_determinations.create!({
          otu: otu,
          determiners: parse_people("identifiedBy"),
          year_made: get_field_value("dateIdentified")
        })

        #TODO: If all attributes are equal assume it is the same event and share it with other specimens?
        CollectingEvent.create!({
          collection_objects: [specimen],
          with_verbatim_data_georeference: true,
          verbatim_latitude: get_field_value("decimalLatitude"),
          verbatim_longitude: get_field_value("decimalLongitude"),
          verbatim_datum: get_field_value("geodeticDatum"),
          verbatim_locality: get_field_value("locality"),
          no_dwc_occurrence: true
        }.merge!(attributes[:collecting_event]))

        self.metadata["imported_objects"] = { collection_object: { id: specimen.id } }
        self.status = "Imported"

        DwcOccurrenceUpsertJob.perform_later(specimen)
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

  def get_fields_mapping
    @fields_mapping ||= import_dataset.metadata["core_headers"].each.with_index.inject({}) { |m, (h, i)| m.merge({ h => i, i => h}) }
  end

  def get_field_value(field_name)
    index = get_fields_mapping[field_name.to_s]

    value = data_fields[index]&.dig("value") if index
    value&.strip!
    value&.squeeze!(" ")

    value unless value.blank?
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
    DwcAgent.parse(get_field_value(field_name)).map! do |name|
      attributes = {
        last_name: [name.particle, name.family].compact!.join(" "),
        first_name: name.given,
        suffix: name.suffix,
        prefix: name.title || name.appellation
      }

      if attributes[:last_name].blank?
        attributes[:last_name] = attributes[:first_name]
        attributes[:first_name] = nil
      end

      Person.find_by(attributes) || Person::Unvetted.create!(attributes)
    end
  end

  def set_hash_val(hsh, key, value)
    hsh[key] = value unless value.nil?
  end

  def clear_empty_sub_hashes(hsh)
    hsh.each do |key, value|
      hsh.delete(key) if hsh[key].nil? || hsh[key] == {}
    end
    hsh
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

    # institutionCode: [repository.acronym]
    institution_code = get_field_value(:institutionCode)
    if institution_code
      repository = Repository.find_by(acronym: institution_code)
      raise DarwinCore::InvalidData.new({ "institutionCode": ["Unknown #{institution_code} repository. If valid please register it using '#{institution_code}' as acronym."] }) unless repository
      set_hash_val(res[:specimen], :repository, repository)
    end

    # collectionCode: [catalog_number.namespace]
    collection_code = get_field_value(:collectionCode)
    set_hash_val(res[:catalog_number], :namespace, Namespace.create_with({
        name: "#{institution_code}-#{collection_code} [CREATED FROM DWC-A IMPORT IN #{project.name} PROJECT]",
        delimiter: '-'
    }).find_or_create_by!(short_name: "#{institution_code}-#{collection_code}")) if collection_code

    # datasetName: [Not mapped]

    # ownerInstitutionCode: [Not mapped]

    # basisOfRecord: [Check it is 'PreservedSpecimen']
    basis = get_field_value(:basisOfRecord) || 'PreservedSpecimen'
    raise DarwinCore::InvalidData.new({ 'type' => ["Only 'PreservedSpecimen' or empty allowed"] }) if basis != 'PreservedSpecimen'

    # informationWithheld: [Not mapped]

    # dataGeneralizations: [Not mapped]

    # dynamicProperties: [Not mapped. Could be ImportAttribute?]

    clear_empty_sub_hashes(res)
  end

  def parse_occurrence_class
    res = {
      catalog_number: {},
      specimen: {},
      collecting_event: {}
    }

    # occurrenceID: [SHOULD BE MAPPED. Namespace perhaps should be something fixed and local to project or user-supplied if non-GUID (should be GUID!)]

    # catalogNumber: [catalog_number.identifier]
    set_hash_val(res[:catalog_number], :identifier, get_field_value(:catalogNumber))

    # recordNumber: [Not mapped]

    # recordedBy: [collecting_event.collectors]
    set_hash_val(res[:collecting_event], :collectors, parse_people(:recordedBy))

    # individualCount: [specimen.total]
    set_hash_val(res[:specimen], :total, get_field_value(:individualCount) || 1)

    # organismQuantity: [Not mapped. Check relation with invidivialCount]

    # organismQuantityType: [Not mapped. Check relation with invidivialCount]

    # sex: [Find or create by name inside Sex biocuration Group] TODO: Think of duplicates (with and without URI)
    sex = get_field_value(:sex)
    if sex
      raise DarwinCore::InvalidData.new({ "sex": ["Only single-word controlled vocabulary supported at this time."] }) if sex =~ /\s/
      group   = BiocurationGroup.with_project_id(Current.project_id).where('name ILIKE ?', 'sex').first
      group ||= BiocurationGroup.create!(name: 'Sex', definition: 'The sex of the individual(s) [CREATED FROM DWC-A IMPORT]')
      # TODO: BiocurationGroup.biocuration_classes not returning AR relation
      sex_biocuration = group.biocuration_classes.detect { |c| c.name.casecmp(sex) == 0 }
      unless sex_biocuration
        sex_biocuration = BiocurationClass.create!(name: sex, definition: "#{sex} individual(s) [CREATED FROM DWC-A IMPORT]")
        Tag.create!(keyword: group, tag_object: sex_biocuration)
      else
        sex = sex_biocuration
      end

      set_hash_val(res[:specimen], :biocuration_classifications, [BiocurationClassification.new(biocuration_class: sex_biocuration)])
    end

    # reproductiveCondition: [Not mapped]

    # behavior: [Not mapped]

    # establishmentMeans: [Not mapped]

    # occurrenceStatus: [Not mapped]

    # preparations: [Find or create by name. Might be best to raise exception if doesn't exist yet and request the user to create it. Review]
    preparation = get_field_value(:preparations)
    set_hash_val(res[:specimen], :preparation_type, PreparationType.create_with({
      definition: "'#{preparation}' [CREATED FROM DWC-A IMPORT IN #{project.name} PROJECT]"
    }).find_or_create_by!(name: preparation)) if preparation

    clear_empty_sub_hashes(res)
  end


  def parse_event_class
    collecting_event = { }

    # eventID: [Not mapped]

    # parentEventID: [Not mapped]

    # fieldNumber: verbatim_trip_identifier
    set_hash_val(collecting_event, :verbatim_trip_identifier, get_field_value(:fieldNumber))

    eventDate = get_field_value(:eventDate)

    begin
      start_date = DateTime.iso8601(eventDate) if eventDate
    rescue Date::Error
      raise DarwinCore::InvalidData.new(
        { "eventDate":
          ["Invalid date. Please make sure it conforms to ISO 8601 date format (yyyy-mm-ddThh:mm:ss). Examples: 1972-05; 1983-10-25; 2020-09-22T15:30"]
        }
      )
    end

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
      raise DarwinCore::InvalidData.new({ "startDayOfYear": ["Missing year value"] }) if year.nil? || eventDate.nil?

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
    set_hash_val(collecting_event, :start_date_year, year)
    set_hash_val(collecting_event, :start_date_month, month)
    set_hash_val(collecting_event, :start_date_day, day)

    # eventTime: time_start_*
    /(?<hour>\d+)(:(?<minute>\d+))?(:(?<second>\d+))?/ =~ get_field_value(:eventTime)
    set_hash_val(collecting_event, :time_start_hour, hour)
    set_hash_val(collecting_event, :time_start_minute, minute)
    set_hash_val(collecting_event, :time_start_second, second)

    endDayOfYear = get_integer_field_value(:endDayOfYear)

    if endDayOfYear
      raise DarwinCore::InvalidData.new({ "endDayOfYear": ["Missing year value"] }) if year.nil? || eventDate.nil?

      begin
        ordinal = Date.ordinal(year, endDayOfYear)
      rescue Date::Error
        raise DarwinCore::InvalidData.new({ "endDayOfYear": ["Out of range. Please also check year field"] })
      end

      month = ordinal.month
      day = ordinal.day
    end

    # endDayOfYear: end_date_* ## TODO: Might need to support date ranges for eventDate as this field does not make possible to end next year
    set_hash_val(collecting_event, :end_date_year, year)
    set_hash_val(collecting_event, :end_date_month, month)
    set_hash_val(collecting_event, :end_date_day, day)

    # verbatimEventDate: verbatim_date
    set_hash_val(collecting_event, :verbatim_date, get_field_value(:verbatimEventDate))

    # habitat: verbatim_habitat
    set_hash_val(collecting_event, :verbatim_habitat, get_field_value(:habitat))

    # samplingProtocol: verbatim_method
    set_hash_val(collecting_event, :verbatim_method, get_field_value(:samplingProtocol))

    # sampleSizeValue: [Not mapped]

    # sampleSizeUnit: [Not mapped]

    # samplingEffort: [Not mapped]

    # fieldNotes: field_notes
    set_hash_val(collecting_event, :field_notes, get_field_value(:fieldNotes))

    # eventRemarks: Maybe field_notes (concatenated with fieldNotes)

    { collecting_event: collecting_event }
  end
end
