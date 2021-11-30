# Loosely based on http://elementalselenium.com/tips/67-broken-images
require 'browsermob/proxy'
require 'webdrivers/geckodriver'
require 'rspec/expectations'
require 'capybara/rspec'

server = BrowserMob::Proxy::Server.new("./browserup-proxy-2.0.1/bin/browserup-proxy")
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

    it "has the test project visible" do
      expect(page).to have_content("test_project")
    end
  end

  context 'when ColDP export is fired up' do
    before(:each) do
      click_on 'test_project'
    end

    it 'runs asynchronously' do
      visit 'tasks/exports/coldp/download?otu_id=1'
      expect(page).to have_content('Status: Download creation is in progress...')
      begin
        expect(page).to have_content('Status: Ready to download', wait: 30)
      rescue
        puts page.body
        raise
      end
    end
  end

  context 'when basic nomenclature export is fired up' do
    before(:each) do
      click_on 'test_project'
    end

    it 'runs asynchronously' do
      visit 'tasks/exports/nomenclature/download_basic?taxon_name_id=1'
      expect(page).to have_content('Status: Download creation is in progress...')
      begin
        sleep 30
        puts page.body
        expect(page).to have_content('Status: Ready to download', wait: 30)
      rescue
        puts page.body
        raise
      end
    end
  end

  context 'when uploading a DwC-A' do
    before(:each) do
      click_on 'test_project'
    end

    xit 'stages asynchronously' do
    end
  end

  context 'when using Biodiversity' do
    before(:each) do
      click_on 'test_project'
    end

    it 'returns Testidae as result' do
      visit '/taxon_names/autocomplete.json?term=Test'
      expect(page).to have_content('Testidae')
    end
  end



  # TODO: Make this test inside taxonworks container (without installing anything extra).
  #       This is currently self-tested in Dockerfile
  # context 'ImageMagick settings' do
  #   it 'has 8GiB of disk cache' do
  #     expect(`identify -list resource | grep Disk`).to end_with('8GiB')
  #   end
  # end

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
