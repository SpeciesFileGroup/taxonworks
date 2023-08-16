FactoryBot.define do

  trait :parent_earth do
    parent {
      if o = GeographicArea.where(name: 'Earth').first
        o
      else
        FactoryBot.build(:earth_geographic_area)
      end
    }
  end

  trait :parent_country do
    parent {
      if o = GeographicArea.where(name: 'United States of America').first
        o
      else
        FactoryBot.build(:level0_geographic_area)
      end
    }
    level0 { parent }
  end

  trait :parent_state do
    parent {
      if o = GeographicArea.where(name: 'Illinois').first
        o
      else
        FactoryBot.build(:level1_geographic_area)
      end
    }
    level1 { parent }
  end

  factory :geographic_area, traits: [:creator_and_updater,], aliases: [:geographic_area_stack] do
    #  TODO: fix to *really* be valid
    factory :valid_geographic_area, traits: [:parent_earth] do
      data_origin { 'Test Data' }
      name { 'Test' }
      valid_gat
      after(:build) { |o| o.level0 = o }
    end

    factory :with_data_origin_geographic_area do
      data_origin { 'Test Data' }

      factory :level2_geographic_area, aliases: [:valid_geographic_area_stack] do
        name { 'Champaign' }
        parent_state
        county_gat
        after(:build) { |o|
          o.level2 = o
          o.level1 = o.parent
          o.level0 = o.parent.parent
        }
      end

      factory :level1_geographic_area do
        name { 'Illinois' }
        tdwgID { '74ILL-00' }
        parent_country
        state_gat
        after(:build) { |o|
          o.level1 = o
          o.level0 = o.parent
        }
      end

      factory :level0_geographic_area do
        name { 'United States' }
        iso_3166_a3 { 'USA' }
        iso_3166_a2 { 'US' }
        parent_earth
        country_gat
        after(:build) { |o| o.level0 = o }
      end

      factory :earth_geographic_area do
        name { 'Earth' }
        parent_id { nil }
        level0_id { nil }
        planet_gat
      end

    end
  end

end
