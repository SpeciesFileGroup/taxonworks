require_relative '../../spec/support/initialization_constants'

FactoryGirl.define do
  sequence :email do |n|
    "person#{n}@example.com"
  end

  trait :user_email do
    email 'default@example.com'
  end

  # See spec/support/projects_and_users.rb for the TEST_USER_PASSWORD
  trait :user_password do     
    password { TEST_USER_PASSWORD }              # {} lets us lazy load the variable
    password_confirmation { TEST_USER_PASSWORD }  
  end

  factory :user do
    factory :valid_user, aliases: [:creator, :updater], traits: [:user_password] do
      email
    end
  end

end

