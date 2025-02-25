# Shared code for data classes that can be indexed/serialized as DwcOccurrence records
module Shared::Dwc::CollectingEventExtensions
  extend ActiveSupport::Concern

  included do

    attr_accessor :georeference_attributes

    # @return [Hash]
    # getter returning georeference related attributes
    def georeference_attributes(force = false)
      if force
        @georeference_attributes = set_georeference_attributes
      else
        @georeference_attributes ||= set_georeference_attributes
      end
    end

  end

  # TODO: Revisit
  # @return [Hash]
  #
  def set_georeference_attributes
    case collecting_event&.dwc_georeference_source
    when :georeference
      collecting_event.preferred_georeference.dwc_georeference_attributes
    when :verbatim
      h = collecting_event.dwc_georeference_attributes

      # Our interpretation is now that georeferencedBy is the person who "computed" the
      # values, not transcribed the values.
      #
      #     if a = collecting_event&.attribute_updater(:verbatim_latitude)
      #       h[:georeferencedBy] = User.find(a).name
      #     end

      # verbatim_longitude could technically be different, but...
      h[:georeferencedDate] = (collecting_event.attribute_updated(:verbatim_latitude) if collecting_event.verbatim_latitude)

      h

    when :geographic_area
      h = collecting_event.geographic_area.dwc_georeference_attributes

      if collecting_event.geographic_area_id && (a = collecting_event.attribute_updater(:geographic_area_id))
        h[:georeferencedBy] = User.find_by(id: a)&.name # User might have been deleted if coming from PaperTrail versioning
      end

      h[:georeferencedDate] = (collecting_event.attribute_updated(:geographic_area_id) if collecting_event.geographic_area_id)

      h
    else
      {}
    end
  end


  def dwc_event_remarks
    collecting_event&.notes&.collect {|n| n.text}&.join(CollectionObject::DWC_DELIMITER).presence
  end

  def dwc_georeference_sources
    georeference_attributes[:georeferenceSources]
  end

  def dwc_georeference_remarks
    georeference_attributes[:georeferenceRemarks]
  end

  def dwc_footprint_wkt
    georeference_attributes[:footprintWKT]
  end

  def dwc_georeferenced_by
    georeference_attributes[:georeferencedBy]
  end

  def dwc_georeferenced_date
    georeference_attributes[:georeferencedDate]
  end

  def dwc_geodetic_datum
    georeference_attributes[:geodeticDatum]
  end

  def dwc_verbatim_srs
    georeference_attributes[:dwcVerbatimSrs]
  end

  # georeferenceDate
  # technically could look at papertrail to see when geographic_area_id appeared
  def dwc_georeferenced_date
    collecting_event&.attribute_updated(:geographic_area_id) if collecting_event&.geographic_area_id
  end

  # TODO: extend to Georeferences when we understand how to describe spatial uncertainty
  def dwc_coordinate_uncertainty_in_meters
    if georeference_attributes[:coordinateUncertaintyInMeters]
      georeference_attributes[:coordinateUncertaintyInMeters]
    else
      collecting_event&.verbatim_geolocation_uncertainty
    end
  end

  def dwc_verbatim_latitude
    collecting_event&.verbatim_latitude
  end

  def dwc_verbatim_longitude
    collecting_event&.verbatim_longitude
  end

  # Prioritize the formalized version of the identifier for data-sharing purposes
  def dwc_field_number
    return nil unless collecting_event
    collecting_event.identifiers.where(type: 'Identifier::Local::FieldNumber').first&.cached || collecting_event&.verbatim_field_number
  end

  def dwc_event_id
    return nil unless collecting_event
    collecting_event.identifiers.where(type: 'Identifier::Local::Event').first&.cached.presence
  end

  # TODO: hmm...
  def dwc_internal_attribute_for(target = :collection_object, dwc_term_name)
    return nil if dwc_term_name.nil?

    case target
    when  :collecting_event
      return nil unless collecting_event
      collecting_event.internal_attributes.includes(:predicate)
        .where(
          controlled_vocabulary_terms: {uri: ::DWC_ATTRIBUTE_URIS[dwc_term_name.to_sym] })
        .pluck(:value)&.join(', ').presence
    when :collection_object
      internal_attributes.includes(:predicate)
        .where(
          controlled_vocabulary_terms: {uri: ::DWC_ATTRIBUTE_URIS[dwc_term_name.to_sym] })
        .pluck(:value)&.join(', ').presence
    else
      nil
    end
  end

  def dwc_water_body
    dwc_internal_attribute_for(:collecting_event, :waterBody)
  end

  def dwc_minimum_depth_in_meters
    dwc_internal_attribute_for(:collecting_event, :minimumDepthInMeters)
  end

  def dwc_maximum_depth_in_meters
    dwc_internal_attribute_for(:collecting_event, :maximumDepthInMeters)
  end

  def dwc_verbatim_depth
    dwc_internal_attribute_for(:collecting_event, :verbatimDepth)
  end

  def dwc_verbatim_coordinates
    return nil unless collecting_event
    [collecting_event.verbatim_latitude, collecting_event.verbatim_longitude].compact.join(' ').presence
  end

  def dwc_verbatim_elevation
    collecting_event&.verbatim_elevation
  end

  def dwc_maximum_elevation_in_meters
    collecting_event&.maximum_elevation
  end

  def dwc_minimum_elevation_in_meters
    collecting_event&.minimum_elevation
  end

  # TODO: Reconcile with Protocol (capital P) assignments
  def dwc_sampling_protocol
    collecting_event&.verbatim_method
  end

  def dwc_verbatim_habitat
    collecting_event&.verbatim_habitat
  end

  # See dwc_recorded_by
  # TODO: Expand to any GlobalIdentifier
  def dwc_recorded_by_id
    if collecting_event
      collecting_event.collectors
        .joins(:identifiers)
        .where(identifiers: {type: ['Identifier::Global::Orcid', 'Identifier::Global::Wikidata']})
        .select('identifiers.identifier_object_id, identifiers.cached')
        .unscope(:order)
        .distinct
        .pluck('identifiers.cached')
        .join(CollectionObject::DWC_DELIMITER)&.presence
    end
  end

  # Definition: A list (concatenated and separated) of names of people, groups, or organizations responsible for recording the original Occurrence. The primary collector or observer, especially one who applies a personal identifier (recordNumber), should be listed first.
  #
  # This was interpreted as collectors (in the field in this context), not those who recorded other aspects of the data.
  def dwc_recorded_by
    v = nil
    if collecting_event
      v = collecting_event.collectors
        .order('roles.position')
        .map(&:name)
        .join(CollectionObject::DWC_DELIMITER)
        .presence
      v = collecting_event.verbatim_collectors.presence if v.blank?
    end
    v
  end

  def dwc_country
    v = try(:collecting_event).try(:geographic_names)
    v[:country] if v
  end

  def dwc_state_province
    v = try(:collecting_event).try(:geographic_names)
    v[:state] if v
  end

  def dwc_county
    v = try(:collecting_event).try(:geographic_names)
    v[:county] if v
  end

  def dwc_locality
    collecting_event.try(:verbatim_locality)
  end

  def dwc_decimal_latitude
    georeference_attributes[:decimalLatitude]
  end

  def dwc_decimal_longitude
    georeference_attributes[:decimalLongitude]
  end

  def dwc_verbatim_locality
    collecting_event.try(:verbatim_locality)
  end

  def dwc_event_time
    return unless collecting_event

    %w{start_time end_time}
      .map { |t| %w{hour minute second}
      .map { |p| collecting_event["#{t}_#{p}"] }
      .map { |p| '%02d' % p if p } # At least two digits
      }
        .map { |t| t.compact.join(':') }
        .reject(&:blank?)
        .join('/').presence
  end

  def dwc_verbatim_event_date
    collecting_event&.verbatim_date
  end

  def dwc_event_date
    return unless collecting_event
    return if collecting_event.start_date_year.blank? # don't need to check end, it requires start in model

    %w{start_date end_date}
      .map { |d| %w{year month day}
      .map { |p| collecting_event["#{d}_#{p}"] }
      .map { |p| '%02d' % p if p } # At least two digits
      }
        .map { |d| d.compact.join('-') }
        .reject(&:blank?)
        .join('/').presence
  end

  def dwc_year
    return unless collecting_event
    collecting_event.start_date_year.presence
  end

  def dwc_month
    return unless collecting_event
    return if collecting_event.start_date_month.present? && collecting_event.end_date_month.present?
    collecting_event.start_date_month.presence
  end

  def dwc_day
    return unless collecting_event
    collecting_event.start_date_day.presence
  end

  def dwc_start_day_of_year
    return unless collecting_event
    collecting_event.start_day_of_year.presence
  end

  def dwc_end_day_of_year
    return unless collecting_event
    collecting_event.end_day_of_year.presence
  end

  def dwc_georeference_protocol
    georeference_attributes[:georeferenceProtocol]
  end

end
