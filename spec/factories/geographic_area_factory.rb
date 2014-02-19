# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do

  factory :geographic_area, traits: [:creator_and_updater] do
    geographic_area_type
    data_origin 'Test Data'

    factory :c_geographic_area do
      name "Champaign"
      #association :level0_id, factory: :usa_geographic_area
      #association :level1_id, factory: :il_geographic_area
      #level2_id self.id
      #association :parent_id, factory: :il_geographic_area
    end

    factory :il_geographic_area do
      name "Illinois"
      #association :level0_id, factory: :usa_geographic_area
      #level1_id self.id
      #association :parent_id, factory: :usa_geographic_area
    end

    factory :usa_geographic_area do
      name "United States"
      #level0_id self.id
      #association :parent, factory: :e_geographic_area
    end

    factory :e_geographic_area do
      name "Earth"
      #level0_id nil
      #parent_id nil
    end

  end

end
