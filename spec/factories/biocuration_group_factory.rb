FactoryBot.define do
  sequence :biocuration_group_name do |n|
    "life stage #{n}"
  end

  sequence :biocuration_group_definition do |n|
    "A group of life stages (#{n})."
  end

  factory :biocuration_group, traits: [:housekeeping] do
    factory :valid_biocuration_group do
      name       { generate(:biocuration_group_name) }
      definition { generate(:biocuration_group_definition) }
    end
  end
end
