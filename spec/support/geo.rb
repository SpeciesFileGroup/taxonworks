#FFI_FACTORY = ::RGeo::Geos.factory(native_interface: :ffi, srid: 4326, has_m_coordinate: false, has_z_coordinate: true)
FFI_FACTORY = Georeference::FACTORY
