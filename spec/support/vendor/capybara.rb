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
#     chromedriver_path: '/usr/local/bin/chromedriver' # only possible when test_browser is 'chrome'


# Settings are taken from config/application_settings.yml

# https://github.com/SeleniumHQ/selenium/wiki/Ruby-Bindings
# https://github.com/SeleniumHQ/docker-selenium/issues/198

Capybara.register_driver :selenium do |app|

  case Settings.selenium_settings[:browser]


  when 'chrome'
    require 'webdrivers/chromedriver'

   # !! Untested !!

    # caps = Selenium::WebDriver::Remote::Capabilities.chrome("chromeOptions" => {"binary" => <path to chrome (example: chrome portable)>})
    # Capybara::Selenium::Driver.new(app, :browser => :chrome, :driver_path => <path to chrome driver>, :desired_capabilities => caps)

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
    require 'webdrivers/geckodriver'
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

    profile = Selenium::WebDriver::Firefox::Profile.new

    #  https://forum.shakacode.com/t/how-to-test-file-downloads-with-capybara/347
    profile['browser.download.dir'] = ::Features::Downloads::PATH.to_s
    profile['browser.download.folderList'] = 2
    profile['browser.helperApps.alwaysAsk.force'] = false
    profile['browser.download.manager.showWhenStarting'] = false
    profile['browser.helperApps.neverAsk.saveToDisk'] = 'TEXT/PLAIN;application/zip;'

    options = Selenium::WebDriver::Firefox::Options.new
    options.profile = profile

    options.headless! if Settings.selenium_settings[:headless]

    Capybara::Selenium::Driver.new(
      app,
      browser: :firefox,
      options: options
    )

  else
    raise 'Error in selenium settings.'
  end
end

