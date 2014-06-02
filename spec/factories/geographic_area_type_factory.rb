# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do

  factory :geographic_area_type, traits: [:creator_and_updater] do

    factory :valid_geographic_area_type do
      name 'AnyPlace'
    end

    factory :planet_geographic_area_type do
      name 'Planet'
    end

    factory :country_geographic_area_type do
      name 'Country'
    end

    factory :state_geographic_area_type do
      name 'State'
    end

    factory :county_geographic_area_type do
      name 'County'
    end

    factory :testbox_geographic_area_type do
      name 'Test Box'
    end
  end
end
