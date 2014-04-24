FactoryGirl.define do

  trait :parent_earth do
    parent {  
      if o = GeographicArea.where(name: 'Earth').first
        o
      else
        FactoryGirl.build(:earth_geographic_area)
      end
    }
    tdwg_parent { parent }
  end

  trait :parent_country do
    parent {
      if o = GeographicArea.where(name: 'United States of America').first
        o
      else
        FactoryGirl.build(:level0_geographic_area)
      end
    }
    tdwg_parent { parent }
    level0 { parent }
  end

  trait :parent_state do
    parent_country    
    parent {
      if o = GeographicArea.where(name: 'Illinois').first
        o
      else
        FactoryGirl.build(:level1_geographic_area)
      end
    }
    tdwg_parent { parent }
    level1 { parent }
  end

  factory :geographic_area, traits: [:creator_and_updater], aliases: [:valid_geographic_area_stack] do

    # TODO: fix to *really* be vaclid
    factory :valid_geographic_area do
      data_origin 'Test Data'
      name 'Test'
      parent factory: :earth_geographic_area
      geographic_area_type factory: :valid_geographic_area_type
    end

    factory :with_data_origin_geographic_area do
      data_origin 'Test Data'

      factory :level2_geographic_area do
        name 'Champaign'
        parent_state
        association :geographic_area_type, factory: :county_geographic_area_type
        after(:build) {|o| o.level2 = o}
      end

      factory :level1_geographic_area do
        name "Illinois"
        parent_country
        association :geographic_area_type, factory: :state_geographic_area_type 
        after(:build) {|o| o.level1 = o}
      end

      factory :level0_geographic_area do
        name 'United States of America'
        iso_3166_a3  'USA'
        iso_3166_a2  'US'
        parent_earth
        association :geographic_area_type, factory: :country_geographic_area_type
        after(:build) {|o| o.level0 = o}
      end

      factory :earth_geographic_area do
        name 'Earth'
        parent_id nil
        level0_id nil
        association :geographic_area_type, factory: :planet_geographic_area_type 
      end

    end
  end

end
