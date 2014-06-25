FactoryGirl.define do
  factory :serial_chronology, traits: [:creator_and_updater] do
    factory :valid_serial_chronology do
      association :preceding_serial, factory: :valid_serial, name: "First"
      association :succeeding_serial, factory: :valid_serial, name: "Second"
    end
  end
end
