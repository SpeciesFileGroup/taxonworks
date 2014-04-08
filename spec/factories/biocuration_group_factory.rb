FactoryGirl.define do
  factory :biocuration_group, traits: [:housekeeping] do
    factory :valid_biocuration_group do
      name 'life stage'
      definition 'A group of life stages.'
    end
  end
end
