FactoryBot.define do
  factory :attribution, traits: [:housekeeping] do
    factory :valid_attribution do
      license { 'Attribution' }
      association :attribution_object, factory: :valid_image 
    end
  end
end
