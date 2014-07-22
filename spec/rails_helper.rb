
require 'coveralls'
Coveralls.wear!

ENV["RAILS_ENV"] ||= 'test'

require File.expand_path("../../config/environment", __FILE__)

ActiveRecord::Migration.check_pending!
ActiveRecord::Migration.maintain_test_schema!

require 'awesome_print' 
require 'rspec/rails'
require 'capybara/rails'
require 'capybara/rspec'
require 'spec_helper'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories. We should likely configure particular support to particular spec tests here.
Dir[Rails.root.join("spec/support/**/*.rb")].sort.reverse.each { |f| require f }

ActiveRecord::Base.connection.tables.each { |t| ActiveRecord::Base.connection.reset_pk_sequence!(t) }


