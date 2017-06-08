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
# require 'selenium/webdriver'
require 'capybara/rails'
require 'capybara/rspec'
require 'vcr'
require 'spec_helper'
require 'paper_trail/frameworks/rspec'


# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories. We should likely configure particular support to particular spec tests here.
Dir[Rails.root.join("spec/support/**/*.rb")].sort.reverse.each { |f| require f }

# ActiveRecord::Base.connection.tables.each { |t| ActiveRecord::Base.connection.reset_pk_sequence!(t) }
# Capybara.default_max_wait_time = 8

# Set in config/application_settings:
#
# test:
#   selenium:                                          # defaults to firefox, without 
#     browser: 'firefox'                               # or chrome
#     marionette: true                                 # only possible when test_browser is 'firefox', and https://github.com/mozilla/geckodriver/releases
#     firefox_binary_path: ''                          #  '/Applications/FirefoxDeveloperEdition.app/Contents/MacOS/firefox'
#     chromedriver_path: '/usr/local/bin/chromedriver' # only possible when test_browser is 'chrome'   


# Settings are taken from config/application_settings.yml

# Potentially informative
# https://github.com/SeleniumHQ/docker-selenium/issues/198

Capybara.register_driver :selenium do |app|


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

    Capybara::Selenium::Driver.new(
      app, 
      browser: :chrome, 
      prefs: prefs,
    )
    

  when 'firefox'
    # https://github.com/SeleniumHQ/selenium/wiki/Ruby-Bindings#Tweaking_Firefox_preferences.md
    # 
    # update config/application_settings test should look _LIKE_ (YRMV):
    #
    #  test: 
    #    selenium:                             
    #      browser: 'firefox'
    #      firefox_binary_path: '/usr/local/bin/firefox/Firefox.app/Contents/MacOS/firefox'    

    p = Settings.selenium_settings[:firefox_binary_path]
    if p 
      Selenium::WebDriver::Firefox::Binary.path = p
    end 

#   caps = Selenium::WebDriver::Remote::Capabilities.chrome("chromeOptions" => {"binary" => <path to chrome (example: chrome portable)>})
#   Capybara::Selenium::Driver.new(app, :browser => :chrome, :driver_path => <path to chrome driver>, :desired_capabilities => caps)

    profile = Selenium::WebDriver::Firefox::Profile.new

    #  https://forum.shakacode.com/t/how-to-test-file-downloads-with-capybara/347
    profile["browser.download.dir"] = ::Features::Downloads::PATH.to_s
    profile['browser.download.folderList'] = 2
    profile['browser.helperApps.alwaysAsk.force'] = false
    profile['browser.download.manager.showWhenStarting'] = false
    profile['browser.helperApps.neverAsk.saveToDisk'] = 'TEXT/PLAIN;application/zip;'

    # prevent redirect
    # profile["network.http.prompt-temp-redirect"] = false

    Capybara::Selenium::Driver.new(
      app, 
      browser: :firefox, 
      profile: profile #, # ,
     # driver_path: '~/.rvm/gems/ruby-2.3.3/bin/geckodriver'
    )

  else
    raise 'Error in selenium settings.'
  end
end

