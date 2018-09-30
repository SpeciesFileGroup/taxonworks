FactoryBot.define do
  factory :attribution, traits: [:housekeeping] do
    factory :valid_attribution do
      license { 'Attribution' } 
    end
  end
end
