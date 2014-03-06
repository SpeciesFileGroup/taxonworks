FactoryGirl.define do
  factory :collection_object_biological_collection_object, class: 'CollectionObject::BiologicalCollectionObject', traits: [:housekeeping] do
    factory :valid_collection_object_biological_collection_object do
      type 'Specimen'
      total 1
    end
  end
end
