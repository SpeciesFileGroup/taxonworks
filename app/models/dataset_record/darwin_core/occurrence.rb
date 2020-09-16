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

        specimen = Specimen.create!({
          total: get_field_value("individualCount") || 1,
          no_dwc_occurrence: true
        })

        determiners = parse_identifiedBy.map! { |n| Person.find_by(n) || Person::Unvetted.create!(n) }

        specimen.taxon_determinations.create!({
          otu: otu,
          determiners: determiners,
          year_made: get_field_value("dateIdentified")
        })


        ### Parse Event class fields
        attributes = parse_event_class

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
    data_fields[index]&.dig("value") if index
  end

  def get_integer_field_value(field_name)
    value = get_field_value(field_name)

    unless value.blank?
      begin
        value = Integer(value)
      rescue
        raise DarwinCore::InvalidData.new({ field_name => ["'#{value} is not a valid integer value"] })
      end
    else
      value = nil
    end

    value
  end

  # NOTE: Sometimes an identifier happens to be a non-person (like "ANSP Orthopterist"). Does TW (will) have something for this? Currently imported as an Unvetted Person.
  def parse_identifiedBy
    DwcAgent.parse(get_field_value("identifiedBy")).map! do |name|
      res = {
        last_name: [name.particle, name.family].compact!.join(" "),
        first_name: name.given,
        suffix: name.suffix,
        prefix: name.title || name.appellation
      }

      if res[:last_name].blank?
        res[:last_name] = res[:first_name]
        res.delete(:first_name)
      end
      res
    end
  end

  def set_hash_val(hsh, key, value)
    hsh[key] = value unless value.nil?
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
      raise DarwinCore::InvalidData.new({ "eventDate": ["Invalid date. Please make sure it conforms to ISO 8601"] })
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
    set_hash_val(collecting_event, :verbatimEventDate, get_field_value(:verbatim_date))

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
