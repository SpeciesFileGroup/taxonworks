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


# Set in config/application_settings:
#
# test:
#   selenium:                                          # defaults to firefox, without 
#     browser: 'firefox'                               # or chrome
#     marionette: true                                 # only possible when test_browser is 'firefox', and https://github.com/mozilla/geckodriver/releases
#     firefox_binary_path: ''                          #  '/Applications/FirefoxDeveloperEdition.app/Contents/MacOS/firefox'
#     chromedriver_path: '/usr/local/bin/chromedriver' # only possible when test_browser is 'chrome'   
Capybara.register_driver :selenium do |app|
  require 'selenium/webdriver'

  case Settings.selenium_settings[:browser]

  when 'chrome'
    # puts '[Selenium is using chrome.]'.yellow 
    Capybara::Selenium::Driver.new(app, browser: :chrome, set_window_size: '1400x1400')

  when 'firefox'
    # puts '[Selenium is using firefox.]'.yellow 
    # e.g. '/Applications/FirefoxDeveloperEdition.app/Contents/MacOS/firefox'
    p = Settings.selenium_settings[:firefox_binary_path]
    if p 
      # puts "[Selenium is using firefox at #{p}]".yellow 
      Selenium::WebDriver::Firefox::Binary.path = p
    end 

    # !! Marionette not successfully tested
    # See https://developer.mozilla.org/en-US/docs/Mozilla/QA/Marionette/WebDriver
    # Download and install 
    # $ cp ~/Downloads/geckodriver-0.8.0-OSX /usr/local/bin/wire
    # $ chmod 700 /usr/local/bin/wire
    if Settings.selenium_settings[:marionette]
      # puts "[Selenium is using firefox with marionette]".yellow 
      Capybara::Selenium::Driver.new(app, browser: :firefox, marionette: true)
    else
      Capybara::Selenium::Driver.new(app, browser: :firefox)
    end
  else
    raise 'Error in selenium settings.'
  end
end

