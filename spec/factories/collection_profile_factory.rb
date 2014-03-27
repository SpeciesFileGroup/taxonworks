# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :collection_profile do
    container nil
    otu nil
    type 'dry'
    conservation_status 3
    processing_state 3
    container_condition 3
    condition_of_labels 3
    identification_level 3
    arrangement_level 3
    data_quality 3
    computerization_level 3
    number_of_collection_objects 1
    number_of_containers nil
    created_by_id 1
    updated_by_id 1
    project_id 1
  end
end
