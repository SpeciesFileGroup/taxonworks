FactoryGirl.define do
  factory :human_source, class: 'Source::Human' do
  end
  factory :valid_human_source, class: 'Source::Human' do
    association :person, factory: :valid_person
  end
end
