FactoryBot.define do
  # sequence :name_a do |n|
  #   "pinned-#{n}"
  # end
  #
  # sequence :definition_a do |n|
  #   "Associated with a sharp metal spike (#{n})."
  # end

  factory :biocuration_class, traits: [:housekeeping] do
    factory :valid_biocuration_class do
      name { Faker::Lorem.characters(number: 12) }
      definition { Faker::Lorem.sentence(word_count: 6, supplemental: false, random_words_to_add: 3) }
    end
  end
end
