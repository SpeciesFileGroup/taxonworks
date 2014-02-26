
#@ffi_factory = ::RGeo::Geos.factory(native_interface: :ffi, srid: 4326, has_m_coordinate: false, has_z_coordinate: true)


FactoryGirl.define do

  factory :geographic_item, traits: [:creator_and_updater] do

    factory :geographic_item_with_point do

      point {GEO_FACTORY.point(-88.241413, 40.091655)}

    end

    factory :geographic_item_with_line_string do

      line_string {GEO_FACTORY.line_string([GEO_FACTORY.point(-32, 21),
                                            GEO_FACTORY.point(-25, 21),
                                            GEO_FACTORY.point(-25, 16),
                                            GEO_FACTORY.point(-21, 20)])}

    end

  end

end
