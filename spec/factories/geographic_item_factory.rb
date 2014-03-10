#@ffi_factory = ::RGeo::Geos.factory(native_interface: :ffi, srid: 4326, has_m_coordinate: false, has_z_coordinate: true)

require Rails.root + 'spec/support/geo'


FactoryGirl.define do

  factory :geographic_item, traits: [:creator_and_updater] do

    factory :valid_geographic_item, aliases: [:geographic_item_with_point] do

      point { RSPEC_GEO_FACTORY.point(-88.241413, 40.091655) }

    end

    factory :geographic_item_with_line_string do

      line_string { RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(-32, 21),
                                             RSPEC_GEO_FACTORY.point(-25, 21),
                                             RSPEC_GEO_FACTORY.point(-25, 16),
                                             RSPEC_GEO_FACTORY.point(-21, 20)]) }

    end

  end

end
