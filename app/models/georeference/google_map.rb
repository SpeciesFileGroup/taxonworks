# A Georeference derived from a Google map.
#
class Georeference::GoogleMap < Georeference

  # coordinates is an Array of Stings of [longitude, latitude]
  # @param [Ignored] geo_type
  # @param [Ignored] shape
  def make_geographic_item(geo_type, shape)
    # self.geographic_item = GeographicItem.new(point: Gis::FACTORY.point(coordinates[0], coordinates[1]))
  end

  def dwc_georeference_attributes
    h = {}
    super(h)
    h.merge!(
      georeferenceSources: 'Google Maps',
      georeferenceRemarks: 'Created from a TaxonWorks interface that integrates Google Maps.')
    h[:georeferenceProtocol] = 'Shape "drawn" on a Google Map.' if h[:georeferenceProtocol].blank? 
    h
  end

end
