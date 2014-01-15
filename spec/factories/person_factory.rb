FactoryGirl.define do

  factory :person, traits: [:creator_and_updater] do
    factory :valid_person do
      last_name "Smith"
    end
  end

end


=begin  The following is the preferred format:
FactoryGirl.define { factory :person, traits: [:creator_and_updater] do
  factory :valid_person do
    last_name "Smith"
  end
end }
=end
