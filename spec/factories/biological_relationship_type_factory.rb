FactoryGirl.define do
  factory :biological_relationship_type, traits: [:housekeeping] do
    factory :valid_biological_relationship_type do     # Base type is not valid alone
      type 'BiologicalRelationshipType::BiologicalRelationshipObjectType'
      association :biological_property, factory: :valid_biological_property
      association :biological_relationship, factory: :valid_biological_relationship
    end
  end
end
