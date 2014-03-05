FactoryGirl.define do
  factory :biocuration_class, traits: [:housekeeping] do
    factory :valid_biocuration_class do
      name "pinned"
      definition "Associated with a sharp metal spike."
    end

  end
end
