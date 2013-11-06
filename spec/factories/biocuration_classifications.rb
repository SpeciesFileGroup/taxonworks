# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :biocuration_classification do
    biocuration_class nil
    biological_collection_object nil
    position 1
  end
end
