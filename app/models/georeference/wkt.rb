# A Georeference derived from the user supplying Wkt
# https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry
class Georeference::Wkt < Georeference
  attr_accessor :wkt

  def wkt=(value)

    a = RGeo::WKRep::WKTParser.new
    b = a.parse(value)
    self.geographic_item = GeographicItem.new(geometry_collection: b)

  end

end
