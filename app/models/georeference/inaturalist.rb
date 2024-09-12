# A Georeference derived from metadata on an iNaturalist result
# as interpreted by lib/vendor/inaturalist.rb
#
# point only
#
class Georeference::Inaturalist < Georeference

  def dwc_georeference_attributes
    h = {}
    super(h)
    h.merge!(
      georeferenceSources: 'iNaturalist',
      georeferenceRemarks: 'Created from a TaxonWorks interface that imports from iNaturalist.')
    h[:georeferenceProtocol] =  'Extracted from iNatuarlist API based on an iNaturalist observationID' if h[:georeferenceProtocol].blank? 
    h
  end

    
end
