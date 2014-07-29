# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :source_human, :class => 'Source::Human', traits: [:creator_and_updater] do
  end
end
