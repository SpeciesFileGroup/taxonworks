FactoryGirl.define do
  factory :descriptor, traits: [:housekeeping] do
    factory :valid_descriptor do
      name { Faker::Lorem.word }
      type 'Descriptor::Working'
    end
  end
end

