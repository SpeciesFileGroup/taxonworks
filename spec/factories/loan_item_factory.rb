FactoryGirl.define do
  factory :loan_item, traits: [:housekeeping] do
    factory :valid_loan_item, aliases: [:second_loan_item] do
      association :loan, factory: :valid_loan
      association :loan_item_object, factory: :valid_specimen
    end
  end
end
