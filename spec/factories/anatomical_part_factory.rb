FactoryBot.define do
  factory :anatomical_part, traits: [:housekeeping] do
    factory :valid_anatomical_part do
      name { 'An anatomical part' }
      # TODO add origin to an otu
    end
  end
end
