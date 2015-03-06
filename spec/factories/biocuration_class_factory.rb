FactoryGirl.define do
  # sequence :name_a do |n|
  #   "pinned-#{n}"
  # end
  #
  # sequence :definition_a do |n|
  #   "Associated with a sharp metal spike (#{n})."
  # end

  factory :biocuration_class, traits: [:housekeeping] do
    factory :valid_biocuration_class do
      name { Faker::Lorem.characters(12) }
      definition { Faker::Lorem.sentence(6, false, 3) }
    end
  end
end
