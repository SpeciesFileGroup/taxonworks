FactoryGirl.define do
  factory :descriptor, traits: [:housekeeping] do
    factory :valid_descriptor do
      descriptor_id 1
    end
  end
end
