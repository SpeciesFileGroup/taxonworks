# require 'selenium/webdriver'
require 'capybara/rails'
require 'capybara/rspec'

# Leave this in
Capybara.default_max_wait_time = 30

# Set in config/application_settings:
#
# test:
#   selenium:                                          # defaults to firefox, without
#     browser: 'firefox'                               # or chrome
#     firefox_binary_path: ''                          #  '/Applications/FirefoxDeveloperEdition.app/Contents/MacOS/firefox'
#     driver_path: '/usr/local/bin/chromedriver'       # Used when autodetection causes failures (like snaps on Ubuntu 22.04+)


# Settings are taken from config/application_settings.yml

# https://github.com/SeleniumHQ/selenium/wiki/Ruby-Bindings
# https://github.com/SeleniumHQ/docker-selenium/issues/198

if Settings.selenium_settings[:driver_path]
  Selenium::WebDriver::Service.driver_path = Settings.selenium_settings[:driver_path]
end

Capybara.register_driver :selenium do |app|

  case Settings.selenium_settings[:browser]

  when 'chrome'
    options = if Settings.selenium_settings[:headless]
                Selenium::WebDriver::Options.chrome(args: ['--headless'])
    else
      Selenium::WebDriver::Options.chrome
    end
    # Set download preferences
    options.add_preference('download.default_directory', ::Features::Downloads::PATH.to_s)
    options.add_preference('download.prompt_for_download', false)
    options.add_preference('download.directory_upgrade', true)
    options.add_preference('safebrowsing.enabled', false)

    Capybara::Selenium::Driver.new(
      app,
      browser: :chrome,
      options:
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
      Selenium::WebDriver::Firefox.path = p
    end

    profile = Selenium::WebDriver::Firefox::Profile.new

    #  https://forum.shakacode.com/t/how-to-test-file-downloads-with-capybara/347
    profile['browser.download.dir'] = ::Features::Downloads::PATH.to_s
    profile['browser.download.folderList'] = 2
    profile['browser.helperApps.alwaysAsk.force'] = false
    profile['browser.download.manager.showWhenStarting'] = false
    profile['browser.helperApps.neverAsk.saveToDisk'] = 'TEXT/PLAIN;application/zip;'

    options = if Settings.selenium_settings[:headless]
                Selenium::WebDriver::Options.firefox(args: ['--headless'])
    else
      Selenium::WebDriver::Options.firefox
    end

    # options = Selenium::WebDriver::Firefox::Options.new

    options.profile = profile
    options.binary = Settings.selenium_settings[:firefox_binary_path] if Settings.selenium_settings[:firefox_binary_path].present?

    Capybara::Selenium::Driver.new(
      app,
      browser: :firefox,
      options:
    )

  else
    raise 'Error in selenium settings.'
  end
end
