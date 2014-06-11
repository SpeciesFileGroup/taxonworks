FactoryGirl.define do
  factory :alternate_value, traits: [:creator_and_updater] do
    # technically there is no valid_alternate_value (parent class is abstract), the following
    # are required for all subclasses
    factory :valid_alternate_value do
      type 'AlternateValue::Synonym'
      value 'Blorf'
      alternate_object_attribute 'name'
      association :alternate_object, factory: :valid_otu
    end
  end
end
