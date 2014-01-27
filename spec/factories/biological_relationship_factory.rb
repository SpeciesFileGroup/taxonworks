FactoryGirl.define do
  factory :biological_relationship, traits: [:housekeeping] do
    factory :valid_biological_relationship do  
       name 'host' 
    end
  end
end
