FactoryBot.define do
  factory :protocol_relationship, traits: [:housekeeping] do
    factory :valid_protocol_relationship do
      association :protocol, factory: :valid_protocol
      association :protocol_relationship_object, factory: :valid_specimen
    end
  end
end
