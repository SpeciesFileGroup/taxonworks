FactoryGirl.define do
  
  factory :keyword, traits: [:housekeeping] do
    factory :valid_keyword do
      # name 'Something complicated'
      # definition 'Spectral dissonance.'
      name { Faker::Lorem.word }
      definition { Faker::Lorem.sentence }
    end
  end

end
