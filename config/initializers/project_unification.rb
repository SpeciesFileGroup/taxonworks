# Autoload project unification modules
#
# The ProjectUnification module and its submodules are used to merge
# one project's data into another project.
#
Rails.application.config.to_prepare do
  require Rails.root.join('lib', 'project_unification.rb')
  require Rails.root.join('lib', 'project_unification', 'model_classifier.rb')
  require Rails.root.join('lib', 'project_unification', 'migrator.rb')
  require Rails.root.join('lib', 'project_unification', 'taxon_name_handler.rb')
  require Rails.root.join('lib', 'project_unification', 'cached_rebuilder.rb')
  require Rails.root.join('lib', 'project_unification', 'special_handlers.rb')
end
