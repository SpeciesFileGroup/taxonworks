# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :serial_chronology do
    preceding_serial_id 1
    succeeding_serial_id 1
    created_by_id 1
    modified_by_id 1
  end
end
