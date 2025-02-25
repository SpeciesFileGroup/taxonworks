module CollectingEvent::DwcSerialization

  extend ActiveSupport::Concern

  included do
  end

  # @return [Hash]
  #   The interface to DWC for verbatim values only on the CE.
  #   See respective georeferences for other implementations.
  #   See GeographicArea for centroids/areas.
  #
  def dwc_georeference_attributes
    { verbatimLatitude: verbatim_latitude,
      verbatimLongitude: verbatim_longitude,
      georeferenceProtocol: 'Transcribed verbatim from physical human-readable media (e.g. paper specimen label, field notebook).',
      coordinateUncertaintyInMeters: verbatim_geolocation_uncertainty,
      geodeticDatum: verbatim_datum
    }
  end

end
