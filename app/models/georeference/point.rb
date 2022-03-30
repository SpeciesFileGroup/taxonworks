# The Georeference added by entering otherwise undocumented point coordinates, with an optional error radius.
class Georeference::Point < Georeference

  def dwc_georeference_attributes
    h = {}
    super(h)
    h.merge!(
      georeferenceSources: "Curator entered point/radius data.",
      georeferenceRemarks: "A generic point georeference.",
      geodeticDatum: nil
    )
    h[:georeferenceProtocol] =  'Created by entering point coordinates in a form, along with an optional error radius.' if h[:georeferenceProtocol].blank?
    h
  end

end
