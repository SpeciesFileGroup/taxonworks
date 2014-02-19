# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do

  factory :geographic_area_type, traits: [:creator_and_updater] do
    factory :p_geographic_area_type, traits: [:creator_and_updater] do
      name 'Planet'
    end

    factory :c1_geographic_area_type, traits: [:creator_and_updater] do
      name 'Country'
    end

    factory :s_geographic_area_type, traits: [:creator_and_updater] do
      name 'State'
    end

    factory :c2_geographic_area_type, traits: [:creator_and_updater] do
      name 'County'
    end

  end

end
