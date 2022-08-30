
# TODO: Create a YAML file (use a rake task to re/generate) and pre-load all types so 
# that they are identical to the production constants 
# we use.
FactoryBot.define do

  trait :planet_gat do
    geographic_area_type {
      GeographicAreaType.find_or_create_by(name: 'Planet')
    }
  end

  trait :country_gat do
    geographic_area_type {
      GeographicAreaType.find_or_create_by(name: 'Country', id: 3)
    }
  end

  trait :state_gat do
    geographic_area_type {
      GeographicAreaType.find_or_create_by(name: 'State', id: 63)
    }
  end

  trait :county_gat do
    geographic_area_type {
      GeographicAreaType.find_or_create_by(name: 'County', id: 33)
    }
  end

  trait :valid_gat do
    geographic_area_type {
      GeographicAreaType.find_or_create_by(name: 'AnyType')
    }
  end

  factory :geographic_area_type, traits: [:creator_and_updater] do
    factory :valid_geographic_area_type do
      name { Faker::Lorem.unique.word + Time.now.to_s }
    end

    factory :planet_geographic_area_type do
      name { 'Planet' }
    end

    factory :country_geographic_area_type do
      name { 'Country' }
    end

    factory :state_geographic_area_type do
      name { 'State' }
    end

    factory :county_geographic_area_type do
      name { 'County' }
    end

    factory :testbox_geographic_area_type do
      name { 'Test Box' }
    end

    factory :feature_geographic_area_type do
      name { 'Feature' }
    end

    factory :named_place_geographic_area_type do
      name { 'Named Place' }
    end
  end

end
