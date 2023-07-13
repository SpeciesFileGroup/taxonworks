# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

TaxonWorks::Application.load_tasks

# Replace yarn with npm
Rake::Task['yarn:install'].clear if Rake::Task.task_defined?('yarn:install')
Rake::Task['shakapacker:yarn_install'].clear
Rake::Task['shakapacker:check_yarn'].clear
Rake::Task.define_task('shakapacker:verify_install' => ['shakapacker:check_npm'])
Rake::Task.define_task('shakapacker:compile' => ['shakapacker:npm_install'])
