FactoryBot.define do
  factory :lead_item, traits: [:housekeeping] do
    factory :valid_lead_item do
      association :lead, factory: :valid_lead
      association :otu, factory: :valid_otu
    end
  end
end
