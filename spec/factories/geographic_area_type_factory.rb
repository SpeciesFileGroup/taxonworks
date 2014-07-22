# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do

  trait :planet_gat do
    geographic_area_type {
      if g = GeographicAreaType.find_by_name('Planet')
        g
      else
        FactoryGirl.build(:planet_geographic_area_type)
      end
    }
  end

  trait :country_gat do
    geographic_area_type {
      if g = GeographicAreaType.find_by_name('Country')
        g
      else
        FactoryGirl.build(:country_geographic_area_type)
      end
    }
  end

  trait :state_gat do
    geographic_area_type {
      if g = GeographicAreaType.find_by_name('State')
        g
      else
        FactoryGirl.build(:state_geographic_area_type)
      end
    }
  end

  trait :county_gat do
    geographic_area_type {
      if g = GeographicAreaType.find_by_name('County')
        g
      else
        FactoryGirl.build(:county_geographic_area_type)
      end
    }
  end

  trait :valid_gat do
    geographic_area_type {
      if g = GeographicAreaType.find_by_name('AnyTpye')
        g
      else
        FactoryGirl.build(:valid_geographic_area_type)
      end
    }
  end

  factory :geographic_area_type, traits: [:creator_and_updater] do

    factory :valid_geographic_area_type do
      name 'AnyType'
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
