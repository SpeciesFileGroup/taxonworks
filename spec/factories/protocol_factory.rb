FactoryBot.define do
  factory :protocol, traits: [:housekeeping] do
    factory :valid_protocol do
      name "Name1"
      short_name "ShortName1"
      description "Description1"
    end
  end
end
