require 'rgeo'

RGeo::ActiveRecord::SpatialFactoryStore.instance.tap do |config|
  config.default = RGeo::Geographic.projected_factory(
    srid: 4326,
    projection_srid: 4326,
    projection_proj4: 'EPSG:4326',
    uses_lenient_assertions: true,
    has_z_coordinate: true,
    has_z: true,
    buffer_resolution: 4, # May ultimately need ot experiment with this. 
    wkb_parser: {support_ewkb: true},
    wkb_generator: {hex_format: true, emit_ewkb_srid: true})
end

module Gis
  SPHEROID = 'SPHEROID["WGS-84", 6378137, 298.257223563]'.freeze
 
  # Debugging: 
  #   ap Gis::FACTORY.marshal_dump 
  
  FACTORY = RGeo::ActiveRecord::SpatialFactoryStore.instance.default
  
  # Warm up RGeo/Proj before any forking may occur (solves problems with spring on Mac)
  FACTORY.parse_wkt('POLYGON ((0 0, 1 0, 1 1, 0 1, 0 0))')

end
