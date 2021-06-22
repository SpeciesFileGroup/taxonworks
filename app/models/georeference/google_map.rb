# A Georeference derived from a Google map.
#
class Georeference::GoogleMap < Georeference

  # coordinates is an Array of Stings of [longitude, latitude]
  # @param [Ignored] geo_type
  # @param [Ignored] shape
  def make_geographic_item(geo_type, shape)
    # self.geographic_item = GeographicItem.new(point: Gis::FACTORY.point(coordinates[0], coordinates[1]))
  end


  # @return [Hash]
  #   The interface to DwC for verbatim values only on the CE.
  #   See respective georeferences for other implementations.
  #
  def dwc_georeference_attributes
    h = { 
      footprintWKT: geographic_item.geo_object.to_s,

      georeferenceSources: 'Google Maps',
      georeferenceRemarks: 'Created from a TaxonWorks interface that integrates Google Maps.',
      georeferenceProtocol: 'Shape "drawn" on a Google Map.',
      georeferenceVerificationStatus: confidences&.collect{|c| c.name}.join('; '), 
      georeferencedBy: creator.name,
      georeferencedDate: created_at
    }

    if geographic_item.type == 'GeographicItem::Point' 
      h[:decimalLatitude] = geographic_item.to_a.first
      h[:decimalLongitude] = geographic_item.to_a.last
      h[:coordinateUncertaintyInMeters] = error_radius 
    end

    h
  end

end
