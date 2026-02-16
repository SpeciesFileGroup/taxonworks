# NOTE: Keep the filename lexically first in the list of initializers to ensure that initializers have access to all models.
if defined?(Rake) && Rake.application && (Rake.application.top_level_tasks & %w[jobs:work jobs:workoff]).any?
  Rails.application.config.after_initialize do
    Rails.application.eager_load!
  end
end