# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define  do
  factory :loan, traits: [:housekeeping] do

#   date_requested '2014-02-26'
#   request_method { Faker::Lorem.word }
#   date_sent '2014-02-26'
#   date_received '2014-02-26'
#   date_return_expected '2014-02-26'
#   association :recipient_person, factory: :valid_person 
#   recipient_address 'MyString'
#   recipient_email { Faker::Internet.email }
#   recipient_phone { Faker::PhoneNumber.phone_number }
#   recipient_country 1
#   association :supervisor_person, factory: :valid_person 
#   supervisor_email { Faker::Internet.email }
#   supervisor_phone { Faker::PhoneNumber.phone_number }
#   date_closed '2014-02-26'

    factory :valid_loan do

    end


    factory :second_loan do
    end
  end
end
