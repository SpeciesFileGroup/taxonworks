FactoryGirl.define do
  factory :user do
    email    'frank@example.com'
    password 'frankbar'
    password_confirmation 'frankbar'
  end
end
