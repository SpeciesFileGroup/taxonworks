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
      # name "pinned"
      # definition "Associated with a sharp metal spike."
      name { Faker::Lorem.word }
      definition { Faker::Lorem.sentence }
    end
  end
end
