require 'rgeo'

# RGeo::Geos.preferred_native_interface = :ffi

module Gis

  SPHEROID = 'SPHEROID["WGS-84", 6378137, 298.257223563]'.freeze

  FACTORY = RGeo::Geographic.projected_factory(srid:                    4326,
                                               projection_srid:         4326,
                                               projection_proj4:        "EPSG:4326",
                                               uses_lenient_assertions: true,
                                               has_z_coordinate:        true,
                                               wkb_parser:              {support_ewkb: true},
                                               wkb_generator:           {hex_format: true, emit_ewkb_srid: true})

  # Warm up RGeo/Proj before any forking may occur (solves problems with spring on Mac)
  FACTORY.parse_wkt('POLYGON ((0 0, 1 0, 1 1, 0 1, 0 0))')
end

# RGeo::ActiveRecord::GeometryMixin.set_json_generator(:geojson)

