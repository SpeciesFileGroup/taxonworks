# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :loan do
    date_requested "2014-02-26"
    request_method "MyString"
    date_sent "2014-02-26"
    date_received "2014-02-26"
    date_return_expected "2014-02-26"
    recipient_person_id 1
    recipient_address "MyString"
    recipient_email "MyString"
    recipient_phone "MyString"
    recipient_country 1
    supervisor_person_id "MyString"
    supervisor_email "MyString"
    supervisor_phone "MyString"
    date_closed "2014-02-26"
    created_by_id 1
    updated_by_id 1
    project_id 1

    factory :second_loan, aliases: [:valid_loan] do

    end
  end
end
