FactoryBot.define do

  # TODO: scope
  minLat = -85
  maxLat = 85
  minLng = -180
  maxLng = 180
  rng = Random.new(Time.now.to_i)

  # FactoryBot.build(:geographic_item, :random_point)
  trait :random_point do
    geography { RSPEC_GEO_FACTORY.point(minLat + rng.rand * (maxLat - minLat),
                                    minLng + rng.rand * (maxLng - minLng)) }
  end

  factory :geographic_item, traits: [:creator_and_updater] do
    factory :valid_geographic_item, aliases: [:geographic_item_with_point_a] do
      geography { GeoBuild::GI_POINT_A }
    end

    factory :random_point_geographic_item do
      random_point
    end

    factory :geographic_item_with_point_m do
      geography { GeoBuild::GI_POINT_M }
    end

    factory :geographic_item_with_point_u do
      geography { GeoBuild::GI_POINT_U }
    end

    factory :geographic_item_with_point_c do
      geography { GeoBuild::GI_POINT_C }
    end

    factory :geographic_item_with_line_string do
      geography { GeoBuild::GI_LS01 }
    end

    factory :geographic_item_with_polygon do
      geography { GeoBuild::GI_POLYGON }
    end

    factory :geographic_item_with_multi_polygon do
      geography { GeoBuild::GI_MULTI_POLYGON }
    end
  end
end
