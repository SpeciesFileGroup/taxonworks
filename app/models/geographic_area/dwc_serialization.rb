module GeographicArea::DwcSerialization

  extend ActiveSupport::Concern

  included do
  end

  # @return [Hash]
  #   The interface to DWC for verbatim values only on the CE.
  #   See respective georeferences for other implementations.
  #   See GeographicArea for centroids/areas.
  #
  # Serialization checks for this GeographicArea to have shape 
  # have already been done prior to this call. 
  def dwc_georeference_attributes
    { geodeticDatum: nil,    
      footprintWKT: default_geographic_area_geographic_item.geographic_item.geo_object.to_s,
      footprintSRS: Gis::FACTORY.srid.to_s,
      # footprintSpatialFit

      georeferenceProtocol: 'Selected from a controlled Gazetteer.',

      georeferenceRemarks: 'Derived from a geographic area gazeteer.',
      georeferenceVerificationStatus: 'Maximum of second level geopolitical subdivision only.',
      georeferenceSources: dwc_georeference_sources,
    }
  end

  # georeferenceSources
  def dwc_georeference_sources
    default_geographic_area_geographic_item&.data_origin
  end

end
