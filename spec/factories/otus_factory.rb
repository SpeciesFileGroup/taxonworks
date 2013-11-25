FactoryGirl.define do
  factory :otu do
  end

  factory :valid_otu, class: Otu do
    name 'my concept'
  end
end
