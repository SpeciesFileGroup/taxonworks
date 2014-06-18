# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :note, traits: [:housekeeping] do
    factory :valid_note do
      association :note_object, factory: :valid_otu
      text 'It was a dark and stormy night.'
    end
  end

end
