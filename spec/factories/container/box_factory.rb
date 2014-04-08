FactoryGirl.define do
  factory :container_box, class: Container::Box, traits: [:housekeeping] do
    factory :valid_container_box 
  end
end
