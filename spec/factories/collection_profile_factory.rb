# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :collection_profile do
    container nil
    otu nil
    conservation_status 1
    processing_state 1
    container_condition 1
    condition_of_labels 1
    identification_level 1
    arrangement_level 1
    data_quality 1
    computerization_level 1
    number_of_collection_objects 1
    number_of_containers nil
    created_by_id 1
    modified_by_id 1
    project_id 1
  end
end
