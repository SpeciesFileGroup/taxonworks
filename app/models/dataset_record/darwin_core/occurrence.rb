class DatasetRecord::DarwinCore::Occurrence < DatasetRecord::DarwinCore

  DWC_CLASSIFICATION_TERMS = %w{kingdom phylum class order family} # genus, subgenus, specificEpithet and infraspecificEpithet are extracted from scientificName
  PARSE_DETAILS_KEYS = %i(uninomial genus species infraspecies)

  def import
    begin
      DatasetRecord.transaction do
        self.metadata.delete("error_data")

        parse_details = Biodiversity::Parser.parse(get_field_value("scientificName") || "")[:details]
        parse_details = (parse_details&.keys - PARSE_DETAILS_KEYS).empty? ? parse_details.values.first : nil if parse_details

        raise DarwinCore::InvalidData.new({ "scientificName": ["Unable to parse scientific name. Please make sure it is correctly spelled."] }) unless parse_details

        names = DWC_CLASSIFICATION_TERMS.map { |t| [t, get_field_value(t)] }

        unless parse_details[:uninomial]
          names << ["genus", parse_details[:genus]]
          names << ["subgenus", parse_details[:subgenus]]
          names << ["species", parse_details[:species]]
          names << ["subspecies", parse_details[:infraspecies]&.first&.dig(:value)]
        else
          names << ["genus", parse_details[:parent]] if parse_details[:parent]
          names << [/subgen/ =~ parse_details[:rank] ? "subgenus" : nil, parse_details[:uninomial]]
        end

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
        attributes.deep_merge!(parse_location_class)
        attributes.deep_merge!(parse_identification_class)

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
          otu: otu
        }.merge(attributes[:taxon_determination]))

        # TODO: If all attributes are equal assume it is the same event and share it with other specimens?
        collecting_event = CollectingEvent.create!({
          collection_objects: [specimen],
          no_dwc_occurrence: true
        }.merge!(attributes[:collecting_event]))

        Georeference::VerbatimData.create!({
          collecting_event: collecting_event,
          error_radius: get_field_value("coordinateUncertaintyInMeters")
        }) if collecting_event.verbatim_latitude && collecting_event.verbatim_longitude

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

  def term_value_changed(name, value)
    if ['institutionCode', 'collectionCode', 'catalogNumber'].include?(name) and self.status != 'Imported'
      ready = get_field_value('catalogNumber').blank?
      ready ||= !!self.import_dataset.get_catalog_number_namespace(get_field_value('institutionCode'), get_field_value('collectionCode'))

      self.metadata.delete("error_data")
      if ready
        self.status = 'Ready'
      else
        self.status = 'NotReady'
        self.metadata["error_data"] = { messages: { catalogNumber: ["Record cannot be imported until namespace is set, see \"Settings\"."] } }
        self.import_dataset.add_catalog_number_namespace(get_field_value('institutionCode'), get_field_value('collectionCode'))
      end

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

  def parse_iso_date(field_name)
    get_field_value(field_name)&.split('/', 2)&.map do |date|
      if date
        named_captures = date.match(%r{^
          (?<year>[0-9]{4})(-(?<month>[0-9]{1,2}))?(-(?<day>[0-9]{1,2}))?  # Date in these formats: YYYY | YYYY-M(M)? | YYYY-M(M)?-D(D)?
          (
            T(?<hour>[0-9]{2}):(?<minute>[0-9]{2}):(?<second>[0-9]{2})(Z)? # Optional time, only THH:MM:SS(Z)? allowed.
          )?
        $}x)&.named_captures&.transform_values! { |v| v&.to_i } # Not (&:to_i) because it would replace nil with 0

        raise DarwinCore::InvalidData.new(
          { "#{field_name}":
            ["Invalid date. Please make sure it conforms to ISO 8601 date format (yyyy-mm-ddThh:mm:ss). If expressing interval separate dates with '/'. Examples: 1972-05; 1983-10-25; 2020-09-22T15:30; 2020-11-30/2020-12-04"]
          }
        ) unless named_captures

        OpenStruct.new(named_captures)
      end
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

    # institutionCode: [repository.acronym] # TODO: Use mappings like with namespaces here as well? (Although probably attempt guessing)
    institution_code = get_field_value(:institutionCode)
    if institution_code
      repository = Repository.find_by(acronym: institution_code)
      raise DarwinCore::InvalidData.new({ "institutionCode": ["Unknown #{institution_code} repository. If valid please register it using '#{institution_code}' as acronym."] }) unless repository
      set_hash_val(res[:specimen], :repository, repository)
    end

    # collectionCode: [catalog_number.namespace]
        # collection_code = get_field_value(:collectionCode)
        # set_hash_val(res[:catalog_number], :namespace, Namespace.create_with({
        #     name: "#{institution_code}-#{collection_code} [CREATED FROM DWC-A IMPORT IN #{project.name} PROJECT]",
        #     delimiter: '-'
        # }).find_or_create_by!(short_name: "#{institution_code}-#{collection_code}")) if collection_code
    namespace_id = self.import_dataset.get_catalog_number_namespace(institution_code, get_field_value(:collectionCode))
    set_hash_val(res[:catalog_number], :namespace, Namespace.find(namespace_id)) if namespace_id

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

    # recordedBy: [collecting_event.collectors and collecting_event.verbatim_collectors]
    set_hash_val(res[:collecting_event], :collectors, parse_people(:recordedBy))
    set_hash_val(res[:collecting_event], :verbatim_collectors, get_field_value(:recordedBy))

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

      set_hash_val(res[:specimen], :preparation_type, preparation_type)
    end

    clear_empty_sub_hashes(res)

    # disposition: [Not mapped]

    # associatedMedia: [Not mapped]

    # associatedReferences: [Not mapped]

    # associatedSequences: [Not mapped]

    # associatedTaxa: [Not mapped]

    # otherCatalogNumbers: [Not mapped]

    # occurrenceRemarks: [Not mapped]
  end

  def parse_event_class
    collecting_event = { }

    # eventID: [Not mapped]

    # parentEventID: [Not mapped]

    # fieldNumber: verbatim_trip_identifier
    set_hash_val(collecting_event, :verbatim_trip_identifier, get_field_value(:fieldNumber))

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

  def parse_location_class
    collecting_event = {}

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
    set_hash_val(collecting_event, :verbatim_locality, get_field_value(:verbatimLocality))

    # minimumElevationInMeters: [Not mapped]
    set_hash_val(collecting_event, :minimum_elevation, get_field_value(:minimumElevationInMeters))

    # maximumElevationInMeters: [Not mapped]
    set_hash_val(collecting_event, :maximum_elevation, get_field_value(:maximumElevationInMeters))

    # verbatimElevation: [Not mapped]
    set_hash_val(collecting_event, :verbatim_elevation, get_field_value(:verbatimElevation))

    # minimumDepthInMeters: [Not mapped. REVISIT]

    # maximumDepthInMeters: [Not mapped. REVISIT]

    # verbatimDepth: [Not mapped. REVISIT]

    # minimumDistanceAboveSurfaceInMeters: [Not mapped]

    # maximumDistanceAboveSurfaceInMeters: [Not mapped]

    # locationAccordingTo: [Not mapped. REVISIT]

    # locationRemarks: [Not mapped. REVISIT]

    # decimalLatitude: [verbatim_latitude]
    set_hash_val(collecting_event, :verbatim_latitude, get_field_value(:decimalLatitude))

    # decimalLongitude: [verbatim_longitude]
    set_hash_val(collecting_event, :verbatim_longitude, get_field_value(:decimalLongitude))

    # geodeticDatum: [verbatim_datum]
    set_hash_val(collecting_event, :verbatim_datum, get_field_value(:geodeticDatum))

    # coordinateUncertaintyInMeters: [verbatim_geolocation_uncertainty]
    set_hash_val(collecting_event, :verbatim_geolocation_uncertainty, get_field_value(:coordinateUncertaintyInMeters)&.send(:+, 'm'))

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

    # georeferencedDate: [Not mapped]

    # georeferenceProtocol: [Not mapped]

    # georeferenceSources: [Not mapped. REVISIT]

    # georeferenceVerificationStatus: [Not mapped]

    # georeferenceRemarks: [Not mapped. REVISIT]

    { collecting_event: collecting_event }
  end

  def parse_identification_class
    taxon_determination = {}

    # identificationID: [Not mapped]

    # identificationQualifier: [Not mapped]

    # typeStatus: [Not mapped]

    # identifiedBy: determiners of taxon determination
    set_hash_val(taxon_determination, :determiners, parse_people(:identifiedBy))

    # dateIdentified: {year,month,day}_made of taxon determination
    start_date, end_date = parse_iso_date(:dateIdentified)

    raise DarwinCore::InvalidData.new({ "dateIdentified": ["Date range for taxon determination is not supported."] }) if end_date

    if start_date
      set_hash_val(taxon_determination, :year_made, start_date.year)
      set_hash_val(taxon_determination, :month_made, start_date.month)
      set_hash_val(taxon_determination, :day_made, start_date.day)
    end

    # identificationReferences: [Not mapped. Can they be imported as citations without breaking semantics?]

    # identificationVerificationStatus: [Not mapped]

    # identificationRemarks: Note for taxon determination
    note = get_field_value(:identificationRemarks)
    taxon_determination[:notes_attributes] = [{text: note}] if note

    { taxon_determination: taxon_determination }
  end

end
