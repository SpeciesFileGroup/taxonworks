# General shape producing helpers to refactored to here, more tightly bound to geo libs, less
# tightly bound to TW idioms
#
# These produce *projected* geometries, not raw GeoJSON, e.g. RGeo::Geos::CAPIPolygonImpl, and RGeo::Geos::CAPIMultiPolygonImpl
#
module RspecGeoHelpers

  # @return [Multipolygon]
  # TODO: rename to 'build_polygon'
  def self.make_box(base, offset_x, offset_y, size_x, size_y)
    box = RSPEC_GEO_FACTORY.polygon(
      RSPEC_GEO_FACTORY.line_string(
        [
          RSPEC_GEO_FACTORY.point(base.x + offset_x, base.y - offset_y, 0.0),
          RSPEC_GEO_FACTORY.point(base.x + offset_x + size_x, base.y - offset_y, 0.0),
          RSPEC_GEO_FACTORY.point(base.x + offset_x + size_x, base.y - offset_y - size_y, 0.0),
          RSPEC_GEO_FACTORY.point(base.x + offset_x, base.y - offset_y - size_y, 0.0)
        ]
      )
    )
    RSPEC_GEO_FACTORY.multi_polygon([box])
  end

  def self.make_polygon(base, offset_x, offset_y, size_x, size_y)
   RSPEC_GEO_FACTORY.polygon(
      RSPEC_GEO_FACTORY.line_string(
        [
          RSPEC_GEO_FACTORY.point(base.x + offset_x, base.y - offset_y, 0.0),
          RSPEC_GEO_FACTORY.point(base.x + offset_x + size_x, base.y - offset_y, 0.0),
          RSPEC_GEO_FACTORY.point(base.x + offset_x + size_x, base.y - offset_y - size_y, 0.0),
          RSPEC_GEO_FACTORY.point(base.x + offset_x, base.y - offset_y - size_y, 0.0)
        ]
      )
    )
  end

  # Unused
  # TODO: 
  #  - rename to 'build_multipolygon'
  #  - actually include another polygon
  def self.make_multipolygon(base, offset_x, offset_y, size_x, size_y)
    a = make_box(base, offset_x, offset_y, size_x, size_y)
    RSPEC_GEO_FACTORY.multi_polygon([a])
  end

end
