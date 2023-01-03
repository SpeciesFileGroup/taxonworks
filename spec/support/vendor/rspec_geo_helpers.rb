# General shape producing helpers to refactored to here, more tightly bound to geo libs, less
# tightly bound to TW idioms
#
# These produce *projected* geometries, not raw GeoJSON, e.g. RGeo::Geos::CAPIPolygonImpl, and RGeo::Geos::CAPIMultiPolygonImpl
#
module RspecGeoHelpers

  # @return [Polgyon]
  def self.make_polygon(base, offset_x, offset_y, size_x, size_y)
    make_box(base, offset_x, offset_y, size_x, size_y)
  end

  # TODO: 
  #  - actually include another polygon
  #  - change specs to use make_polygon where that's what is intended
  def self.make_multipolygon(base, offset_x, offset_y, size_x, size_y)
    a = make_box(base, offset_x, offset_y, size_x, size_y)
    RSPEC_GEO_FACTORY.multi_polygon([a])
  end

  private

  # @return [Polygon]
  # @param base [Point]
  #   eg RSPEC_GEO_FACTORY.point(33, 28)
  # @param size_x required > 0
  # @param size_y required > 0
  def self.make_box(base, offset_x = 0.0, offset_y  = 0.0, size_x  = 0.0, size_y = 0.0)
    box = RSPEC_GEO_FACTORY.polygon(
      RSPEC_GEO_FACTORY.line_string(
        [
          RSPEC_GEO_FACTORY.point(base.x + offset_x, base.y - offset_y, 0.0),                   # 10,10
          RSPEC_GEO_FACTORY.point(base.x + offset_x + size_x, base.y - offset_y, 0.0),          # 15,10
          RSPEC_GEO_FACTORY.point(base.x + offset_x + size_x, base.y - offset_y - size_y, 0.0), # 15,5
          RSPEC_GEO_FACTORY.point(base.x + offset_x, base.y - offset_y - size_y, 0.0)           # 10,5 
          # Return point not required
        ]
      )
    )
  end

end
