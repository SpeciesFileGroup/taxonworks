require 'coveralls'
Coveralls.wear!

# require 'simplecov'
# SimpleCov.start

# require 'simplecov-rcov'
# SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter

ENV["RAILS_ENV"] ||= 'test'

require File.expand_path("../../config/environment", __FILE__)

ActiveRecord::Migration.check_pending!
ActiveRecord::Migration.maintain_test_schema!

require 'awesome_print' 
require 'rspec/rails'
require 'capybara/rails'
require 'capybara/rspec'
require 'vcr'
require 'spec_helper'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories. We should likely configure particular support to particular spec tests here.
Dir[Rails.root.join("spec/support/**/*.rb")].sort.reverse.each { |f| require f }

ActiveRecord::Base.connection.tables.each { |t| ActiveRecord::Base.connection.reset_pk_sequence!(t) }

VCR.configure do |c|
  c.default_cassette_options = { re_record_interval: 1.day } # Lets tolerate the penalty of querying external APIs once a day for now.
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock
  c.allow_http_connections_when_no_cassette = true
end

if File.exists?('/usr/bin/chromedriver')
  Capybara.register_driver :selenium do |app|
    Capybara::Selenium::Driver.new(app, :browser => :chrome)
  end
end
# Capybara.javascript_driver = :webkit
