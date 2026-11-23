FactoryBot.define do
  factory :project_source do
    # !! Creates a new project, not the spec's project_id; pass `project_id:`
    # !! for a source in the current project.
    factory :valid_project_source,  traits: [:housekeeping] do
      association :project, factory: :valid_project
      association :source, factory: :valid_source
    end
  end
end
