FactoryGirl.define do
  factory :container, traits: [:housekeeping] do
    factory :valid_container do
      type 'Container::Site'
    end
  end
end
