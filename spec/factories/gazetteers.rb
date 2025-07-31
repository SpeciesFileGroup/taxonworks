FactoryBot.define do

  factory :gazetteer, traits: [:housekeeping] do

    factory :valid_gazetteer do
      association :geographic_item, factory: :valid_geographic_item
      name { 'gaz foo' }
    end

    factory :gazetteer_with_random_point do
      association :geographic_item, factory: :random_point_geographic_item
      name { 'gaz random point' }
    end

    factory :gazetteer_with_line_string do
      association :geographic_item, factory: :geographic_item_with_line_string
      name { 'gaz random line string' }
    end

    factory :gazetteer_with_polygon do
      association :geographic_item, factory: :geographic_item_with_polygon
      name { 'gaz random polygon' }
    end

    factory :gazetteer_with_multi_polygon do
      association :geographic_item, factory: :geographic_item_with_multi_polygon
      name { 'gaz random multi-polygon' }
    end
  end
end
