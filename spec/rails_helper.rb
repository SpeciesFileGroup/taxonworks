if !ENV['NO_COVERAGE_REPORT'] && ENV['CI']
  require 'simplecov'
  SimpleCov.start

  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
  Codecov.pass_ci_if_error = true
end

ENV['RAILS_ENV'] ||= 'test'

require File.expand_path('../../config/environment', __FILE__)

ActiveRecord::Migration.check_pending!
ActiveRecord::Migration.maintain_test_schema!

require 'amazing_print'
require 'rspec/rails'
require 'spec_helper'

# TODO: this is all kinds of fragile and terrible. Potential fix:
# * [ ] Use FactoryBot not FactoryBotRails
# * [ ] Work backwards with dependencies for a more explicit/logical approach
Dir[Rails.root.join('spec/support/**/*.rb')].sort.reverse.each { |f| require f }

ApplicationRecord.connection.tables.each { |t| ApplicationRecord.connection.reset_pk_sequence!(t) }

FactoryBot.use_parent_strategy = false
