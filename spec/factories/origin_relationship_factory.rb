FactoryGirl.define do
  factory :origin_relationship, traits: [:housekeeping] do
    factory :valid_origin_relationship do
      association :old_object, factory: :valid_specimen
      association :new_object, factory: :valid_specimen
    end
  end
end
