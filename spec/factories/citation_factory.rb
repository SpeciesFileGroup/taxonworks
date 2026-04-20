# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :citation, traits: [:housekeeping] do
    factory :valid_citation do
      association :source, factory: :valid_source_bibtex
      after(:build) do |citation|
        FactoryProjectHelpers.assign_project_scoped(citation, :citation_object, :valid_otu)
      end
    end
  end
end
