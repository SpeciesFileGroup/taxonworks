# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :citation, traits: [:housekeeping] do
    factory :valid_citation do
      association :source, factory: :valid_source_bibtex
      after(:build) do |citation|
        citation.citation_object ||= FactoryBot.create(:valid_otu, project_id: citation.project_id)
      end
    end
  end
end
