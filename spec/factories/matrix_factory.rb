FactoryGirl.define do
  factory :matrix, traits: [:housekeeping] do
    factory :valid_matrix do
      name { Faker::Lorem.word }
    end
  end
end
