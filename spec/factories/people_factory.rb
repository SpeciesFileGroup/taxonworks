FactoryGirl.define do

  factory :person_base, class: Person do
    association :creator, factory: :valid_user
    association :updater, factory: :valid_user

    factory :person do
    end

    factory :valid_person do
      last_name "Smith"
    end
  end

end
