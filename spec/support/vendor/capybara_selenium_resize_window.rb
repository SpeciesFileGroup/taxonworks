# Resize selenium browser window to avoid Selenium::WebDriver::Error::MoveTargetOutOfBoundsError errors
#
# Example usage with Rspec (in spec/support/spec_helper.rb):
#     
#   config.before(:each) do
#     set_selenium_window_size(1250, 800) if Capybara.current_driver == :selenium
#   end
#
def set_selenium_window_size(width, height)
  page.driver.browser.manage.window.resize_to(width, height)
end
