FactoryBot.define do
  factory :template_item, traits: [:housekeeping] do
    factory :valid_template_item do
      composition { FactoryBot.create(:valid_template) }
    end
  end
end
