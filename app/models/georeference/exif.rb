# A Georeference derived from the EXIF data
class Georeference::Exif < Georeference

  def dwc_georeference_attributes
    h = {}
    super(h)
    h.merge!(
      georeferenceSources: "Georeferenced image.",
      georeferenceRemarks: "A georeference extracted from a geo-tagged image.",
      geodeticDatum: nil
    )
    h[:georeferenceProtocol] =  'Derived by extracting image Exif data.' if h[:georeferenceProtocol].blank?
    h
  end

end
