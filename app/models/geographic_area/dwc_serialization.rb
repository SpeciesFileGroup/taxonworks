module GeographicArea::DwcSerialization

  extend ActiveSupport::Concern

  included do
  end

  # @return [Hash]
  #   The interface to DwcOccurence records with georeferencing based on a GeographicArea
  def dwc_georeference_attributes
    o = default_geographic_area_geographic_item
    { geodeticDatum: nil,
      footprintWKT: o&.geographic_item&.to_wkt,
      footprintSRS: Gis::FACTORY.srid.to_s,
      # footprintSpatialFit

      georeferenceProtocol: 'Selected from a controlled Gazetteer.',

      georeferenceRemarks: 'Derived from a geographic area gazeteer.',
      georeferenceVerificationStatus: 'Maximum of second level geopolitical subdivision only.',
      georeferenceSources: o&.data_origin,
    }
  end

end
