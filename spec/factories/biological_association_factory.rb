FactoryGirl.define do
  factory :biological_association, traits: [:housekeeping] do
    factory :valid_biological_association do  
      association :biological_relationship, factory: :valid_biological_relationship
      association :biological_association_subject, factory: :valid_otu
      association :biological_association_object, factory: :otu, name: 'other_otu'
    end
  end
end
