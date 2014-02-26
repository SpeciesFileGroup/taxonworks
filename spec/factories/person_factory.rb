FactoryGirl.define do
  factory :person, traits: [:creator_and_updater] do
    factory :valid_person do
      last_name 'Smith'
    end

    factory :source_person_jones do
      last_name 'Jones'
      first_name 'Mike'
    end

    factory :source_person_adam do
      last_name 'Adams'
      first_name 'John'
    end

  end

end
