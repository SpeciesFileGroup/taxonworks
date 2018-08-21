FactoryBot.define do
  factory :label, traits: [:housekeeping] do
    factory :valid_label do
      text "This is a label\nwith a couple\nlines"
      total 1
      association :label_object, factory: :valid_collecting_event
    end
  end
end
