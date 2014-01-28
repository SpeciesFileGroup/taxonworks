FactoryGirl.define do
  factory :biological_associations_biological_associations_graph, traits: [:housekeeping] do
    factory :valid_biological_associations_biological_associations_graph do
      association :biological_associations_graph, factory: :valid_biological_associations_graph
      association :biological_association, factory: :valid_biological_association 
    end
  end
end
