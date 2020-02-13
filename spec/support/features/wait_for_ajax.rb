# Thank you ThoughtBot - https://robots.thoughtbot.com/automatically-wait-for-ajax-with-capybara
# TODO: Remove this file. Time has passed, now this shouldn't be required. No spec is currently using this as of 2019-12-29.
#       If you happen to need to wait for AJAX to complete please try to move the resposibility of waiting to Capybara by matching not only selector but
#       content as well (e.g. in a find or expect(page).to have_x(selector, text: "y"), etc.).
#       Don't use find and then use the result to check values or content, instead use expectation matchers from Capybara since those have built-in waiting.
# 
# spec/support/wait_for_ajax.rb
module Features
  module WaitForAjax
    def wait_for_ajax
      Timeout.timeout(Capybara.default_max_wait_time) do
        loop until finished_all_ajax_requests?
      end
    end

    def finished_all_ajax_requests?
      page.evaluate_script('jQuery.active').zero?
    end
  end
end
