# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :identifier_global_occurrence_id, :class => 'Identifier::Global::OccurrenceId', traits: [:housekeeping] do
  end
end
