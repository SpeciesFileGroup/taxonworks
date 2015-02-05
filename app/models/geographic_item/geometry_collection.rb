class GeographicItem::GeometryCollection < GeographicItem 
  SHAPE_COLUMN = :geometry_collection
  validates_presence_of :geometry_collection

  def st_start_point
    rgeo_to_geo_json =~ /(-?\d+\.?\d*),(-?\d+\.?\d*)/
    Georeference::FACTORY.point($1.to_f, $2.to_f, 0.0)
  end

end
