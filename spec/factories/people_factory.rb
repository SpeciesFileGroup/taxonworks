FactoryGirl.define do
    factory :person do
  end
  factory :valid_person, class: Person do
    last_name "Smith"
  end
end
