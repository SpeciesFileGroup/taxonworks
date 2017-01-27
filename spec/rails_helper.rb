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

Capybara.default_max_wait_time = 8

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
    # https://github.com/seleniumhq/selenium-google-code-issue-archive/issues/5929
    prefs = {
      'download' => {
        'prompt_for_download' => false, 
        'directory_upgrade' => true, 
        'default_directory' => ::Features::Downloads::PATH.to_s
      }
    }

    Capybara::Selenium::Driver.new(app, browser: :chrome, prefs: prefs)

  when 'firefox'
    # Currently only 47.0.1 is fully supported 
    # navigate to https://ftp.mozilla.org/pub/firefox/releases/47.0.1/
    # download firefox-47.0.1.mac-x86_64.sdk.tar.bz2 
    # mv ~/Downloads/firefox-sdk/bin/Firefox.app /usr/local/bin/firefox/Firefox.app
    # 
    # update config/application_settings test should look _LIKE_ (YRMV):
    #
    #  test: 
    #    selenium:                             
    #      browser: 'firefox'
    #      marionette: false
    #      firefox_binary_path: '/usr/local/bin/firefox/Firefox.app/Contents/MacOS/firefox'    

    p = Settings.selenium_settings[:firefox_binary_path]
    if p 
      Selenium::WebDriver::Firefox::Binary.path = p
    end 

    profile = Selenium::WebDriver::Firefox::Profile.new

    # https://forum.shakacode.com/t/how-to-test-file-downloads-with-capybara/347
    profile["browser.download.dir"] = ::Features::Downloads::PATH.to_s
    profile['browser.download.folderList'] = 2
    profile['browser.helperApps.alwaysAsk.force'] = false
    profile['browser.download.manager.showWhenStarting'] = false
    profile['browser.helperApps.neverAsk.saveToDisk'] = 'TEXT/PLAIN;application/zip;'

    # !! Marionette not successfully tested
    # See https://developer.mozilla.org/en-US/docs/Mozilla/QA/Marionette/WebDriver
    # Download and install 
    # $ cp ~/Downloads/geckodriver-0.8.0-OSX /usr/local/bin/wire
    # $ chmod 700 /usr/local/bin/wire
    if Settings.selenium_settings[:marionette]
      Capybara::Selenium::Driver.new(app, browser: :firefox, marionette: true, profile: profile)
    else
      Capybara::Selenium::Driver.new(app, browser: :firefox, profile: profile)
    end

  else
    raise 'Error in selenium settings.'
  end
end

