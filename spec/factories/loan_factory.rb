# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define  do
  factory :loan, traits: [:housekeeping] do

    factory :valid_loan do
      recipient_address { Faker::Address.unique.street_name } 
      lender_address { Faker::Address.unique.street_name }
      date_return_expected { Time.now.to_date }
    end

  end
end
