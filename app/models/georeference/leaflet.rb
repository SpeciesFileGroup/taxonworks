# A Georeference derived from the Leaflet plugin 
#
class Georeference::Leaflet < Georeference

  def dwc_georeference_attributes
    h = {}
    super(h)
    h.merge!(
      georeferenceSources: 'Leaflet',
      georeferenceRemarks: 'Created from a TaxonWorks interface that integrates Leaflet.')
    h[:georeferenceProtocol] =  'Shape "drawn" on a Leaflet map.' if h[:georeferenceProtocol].blank? 
    h
  end

end
