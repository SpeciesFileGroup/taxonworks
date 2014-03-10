#FFI_FACTORY = ::RGeo::Geos.factory(native_interface: :ffi, srid: 4326, has_m_coordinate: false, has_z_coordinate: true)

# this is the factory for use *only* by rspec
# for normal build- and run-time, use Georeference::FACTORY

RSPEC_GEO_FACTORY = Georeference::FACTORY
