require_relative '../support/geo'

# TODO: Jim, use constants instead of instantiating factories again? 
FactoryGirl.define do

  factory :geographic_item, traits: [:creator_and_updater] do
    factory :valid_geographic_item, aliases: [:geographic_item_with_point_a] do
      point { RSPEC_GEO_FACTORY.point(-88.241413, 40.091655) }
    end

    factory :geographic_item_with_point_m do
      point { RSPEC_GEO_FACTORY.point(-88.196736, 40.090091) }
    end

    factory :geographic_item_with_point_u do
      point { RSPEC_GEO_FACTORY.point(-88.204517, 40.110037) }
    end

    factory :geographic_item_with_point_c do
      point { RSPEC_GEO_FACTORY.point(-88.243386, 40.116402) }
    end

    factory :geographic_item_with_line_string do
      line_string { RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(-32, 21),
                                                   RSPEC_GEO_FACTORY.point(-25, 21),
                                                   RSPEC_GEO_FACTORY.point(-25, 16),
                                                   RSPEC_GEO_FACTORY.point(-21, 20)]) }
    end

    factory :geographic_item_with_polygon do
      shape = RSPEC_GEO_FACTORY.line_string([RSPEC_GEO_FACTORY.point(-32, 21),
                                             RSPEC_GEO_FACTORY.point(-25, 21),
                                             RSPEC_GEO_FACTORY.point(-25, 16),
                                             RSPEC_GEO_FACTORY.point(-21, 20)])
      polygon { RSPEC_GEO_FACTORY.polygon(shape) }
    end

  end
end
