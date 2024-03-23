FactoryBot.define do
  factory :lead, traits: [:housekeeping] do
    factory :valid_lead do
      text { 'A key.' }
    end
  end
end
