# A Georeference derived from the user supplying Wkt
# https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry
class Georeference::Wkt < Georeference
  attr_accessor :wkt

  validate :wkt_is_parseable

  # TODO: should coerce this through SHAPE likely
  def wkt=(value)
    begin
      a = ::Gis::FACTORY.parse_wkt(value)
      b =  a.geometry_type.type_name.tableize.singularize.to_sym

      self.geographic_item = GeographicItem.new(b => a)
      @wkt_error = nil
    rescue RGeo::Error::RGeoError => e
      self.geographic_item = nil
      @wkt_error = e.message
    end
  end

  def wkt_is_parseable
    errors.add(:WKT, @wkt_error) if @wkt_error
  end

  def dwc_georeference_attributes
    h = {}
    super(h)
    h.merge!(
      georeferenceSources: "Undefined WKT source.",
      georeferenceRemarks: "Created by pasting in a shape in WKT (well known text) format.",
      geodeticDatum: nil # TODO: check
    )
    h[:georeferenceProtocol] = 'General purpose georeference derived from any source that produces WKT (well known text).' if h[:georeferenceProtocol].blank?  
    h
  end

end
