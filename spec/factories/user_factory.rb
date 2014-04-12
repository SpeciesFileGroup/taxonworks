FactoryGirl.define do
  sequence :email do |n|
    "person#{n}@example.com"
  end

  trait :user_email do
    email 'default@example.com'
  end

  trait :user_password do
    password 'Abcd123!'
    password_confirmation 'Abcd123!'
  end

  factory :user do
    factory :valid_user, aliases: [:creator, :updater], traits: [:user_password] do
      email
    end
  end

end

