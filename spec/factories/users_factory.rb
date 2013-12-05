# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do

  

  sequence :email do |n|
    "person#{n}@example.com"
  end

  trait :default_user_traits do
    email 'default@example.com'
    password 'abcdefgZ123*'
    password_confirmation 'abcdefgZ123*'
  end

  factory :valid_user, class: User, aliases: [:creator, :updater], traits: [:default_user_traits] do
  end


end

