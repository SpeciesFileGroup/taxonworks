# A Georeference derived from the user supplying Wkt
# https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry
class Georeference::Wkt < Georeference
  attr_accessor :wkt

  # TODO: should coerce this through SHAP likely
  def wkt=(value)
    a = ::Gis::FACTORY.parse_wkt(value)
    b =  a.geometry_type.type_name.tableize.singularize.to_sym
   
    self.geographic_item = GeographicItem.new(b => a)

  end

end
