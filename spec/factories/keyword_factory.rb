FactoryGirl.define do
  
  factory :keyword, traits: [:housekeeping] do
    factory :valid_keyword do
      name 'Something complicated' 
      definition 'Spectral dissonance.' 
    end
  end

end
