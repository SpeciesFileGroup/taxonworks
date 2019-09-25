# Loosely based on http://elementalselenium.com/tips/67-broken-images
require 'browsermob/proxy'
require 'selenium-webdriver'
require 'rspec/expectations'
require 'capybara/rspec'

server = BrowserMob::Proxy::Server.new("./browserup-proxy-2.0.0/bin/browserup-proxy")
server.start

proxy = server.create_proxy

Capybara.register_driver :selenium do |app|
  profile = Selenium::WebDriver::Firefox::Profile.new

  options = Selenium::WebDriver::Firefox::Options.new
  options.profile = profile
  profile.proxy = proxy.selenium_proxy

  options.headless!

  Capybara::Selenium::Driver.new(
    app,
    browser: :firefox,
    options: options
  )
end

Capybara.configure do |config|
  config.run_server = false
  config.default_driver = :selenium
  config.app_host = 'http://taxonworks'
end

    proxy.new_har

describe "Docker image test", js: true do
  before(:each) do

    visit '/'

    find('#session_email').set('admin@example.com')
    find('#session_password').set('taxonworks')

    click_button 'sign_in'
  end

  context 'dashboard page' do
    it "shows that the dashboard is for the logged in user" do
      expect(page).to have_content("Dashboard for John Doe")
    end

    it "shows the revision matching git HEAD short hash (#{ENV['REVISION']})" do
      expect(page).to have_content(ENV['REVISION'])
    end
  end

  context 'HTTP proxy' do
    it 'has not recorded any error response' do
      errors = proxy.har.entries.select do |x|
        x.response.status >= 400
      end

      expect(errors).to be_empty
    end
  end

  after(:all) do
    puts "\n\n===URLs served==="
    puts "Status\tURL"

    proxy.har.entries.each do |x|
      puts "#{x.response.status}\t#{x.request.url}"
    end

    puts "\n\n"
  end
end
