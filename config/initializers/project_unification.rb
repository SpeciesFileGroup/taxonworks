# Autoload project unification modules
#
# The ProjectUnification module and its submodules are used to merge
# one project's data into another project.
#
Rails.application.config.to_prepare do
  # Ensure all ProjectUnification modules are loaded
  # Zeitwerk should handle this automatically via lib/ autoloading,
  # but we explicitly require the main module to ensure availability
  require_dependency Rails.root.join('lib', 'project_unification.rb')
  require_dependency Rails.root.join('lib', 'project_unification', 'model_classifier.rb')
  require_dependency Rails.root.join('lib', 'project_unification', 'validator.rb')
  require_dependency Rails.root.join('lib', 'project_unification', 'migrator.rb')
  require_dependency Rails.root.join('lib', 'project_unification', 'taxon_name_handler.rb')
  require_dependency Rails.root.join('lib', 'project_unification', 'cached_rebuilder.rb')
  require_dependency Rails.root.join('lib', 'project_unification', 'special_handlers.rb')
end
