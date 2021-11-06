FactoryBot.define do
  factory :collection_object, traits: [:housekeeping] do
    factory :valid_collection_object do
      type { 'Specimen' }
      total { 1 }
      no_dwc_occurrence { true }
    end
    
    initialize_with { new(type: type) } 
  end
end
