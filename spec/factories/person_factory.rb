FactoryGirl.define do
  factory :person, traits: [:creator_and_updater] do
    factory :valid_person do
      last_name 'Smith'
    end

    factory :source_person_jones do
      last_name 'Jones'
      first_name 'Mike'
    end

    factory :source_person_prefix do
      last_name 'Adams'
      first_name 'John'
      prefix 'Dr.'
    end

    factory :source_person_suffix do
      last_name 'Adams'
      first_name 'James'
      suffix 'Jr.'
    end

    factory :source_person_both_ps do
      last_name 'Adams'
      first_name 'Janet'
      suffix 'III'
      prefix 'Ms.'
    end

  end

end
