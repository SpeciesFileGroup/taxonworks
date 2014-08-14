# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :loan do
    date_requested '2014-02-26'
    request_method { Faker::Lorem.word }
    date_sent '2014-02-26'
    date_received '2014-02-26'
    date_return_expected '2014-02-26'
    recipient_person_id 1
    recipient_address 'MyString'
    recipient_email { Faker::Internet.email }
    recipient_phone { Faker::PhoneNumber.phone_number }
    recipient_country 1
    supervisor_person_id 1
    supervisor_email { Faker::Internet.email }
    supervisor_phone { Faker::PhoneNumber.phone_number }
    date_closed '2014-02-26'
    created_by_id 1
    updated_by_id 1
    project_id 1

    factory :second_loan, aliases: [:valid_loan] do

    end
  end
end
