# Thank you ThoughtBot - https://robots.thoughtbot.com/automatically-wait-for-ajax-with-capybara
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
