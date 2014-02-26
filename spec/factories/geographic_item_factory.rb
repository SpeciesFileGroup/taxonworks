
#@ffi_factory = ::RGeo::Geos.factory(native_interface: :ffi, srid: 4326, has_m_coordinate: false, has_z_coordinate: true)


FactoryGirl.define do

  factory :geographic_item, traits: [:creator_and_updater] do

    factory :geographic_item_with_point do

      point {FFI_FACTORY.point(-88.241413, 40.091655)}

    end

    factory :geographic_item_with_line_string do

      line_string {FFI_FACTORY.line_string([FFI_FACTORY.point(-32, 21),
                                            FFI_FACTORY.point(-25, 21),
                                            FFI_FACTORY.point(-25, 16),
                                            FFI_FACTORY.point(-21, 20)])}

    end

  end

end
