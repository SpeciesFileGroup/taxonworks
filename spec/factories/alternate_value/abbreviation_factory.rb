FactoryGirl.define do
  factory :alternate_value_abbreviation, class: 'AlternateValue::Abbreviation', traits: [:creator_and_updater] do
    factory :valid_alternate_value_abbreviation do
      type 'AlternateValue::Abbreviation' # is this right?!
      value 'B.'
      alternate_value_object_attribute 'name'
      association :alternate_value_object, factory: :valid_serial
    end
  end
end
